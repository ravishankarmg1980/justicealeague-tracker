resource "aws_iam_role" "pipeline_role" {

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "pipeline-role-${var.env}"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "web_pipeline_policy" {
  description = "Policy used in trust relationship with CodePipeline"
  name        = "web-pipeline-policy-${var.env}"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement : [
        {
          Action : [
            "iam:PassRole"
          ],
          Resource : "*",
          Effect : "Allow"
        },
        {
          Action = [
            "s3:*",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action : [
            "codepipeline:*",
            "codedeploy:*",
            "iam:ListRoles",
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:*"
            "codestar-connections:*",
            "iam:PassRole",
          ],
          Resource : "*",
          Effect : "Allow"
        },
      ],
      "Version" : "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "pipeline_policy_attachment" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = aws_iam_policy.web_pipeline_policy.arn
}

resource "aws_iam_role" "static_build_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "build-role-${var.env}"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "build_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.env})"
  name        = "build-policy-${var.env}"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:*"
          ],
          "Resource" = [
            "arn:aws:s3:::*",
            "arn:aws:s3:::*"
          ]
        },
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*"
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "build_policy_attachment" {
  role       = aws_iam_role.static_build_role.name
  policy_arn = aws_iam_policy.build_policy.arn
}

//added for code deploy

resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"          
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  role       = "${aws_iam_role.codedeploy_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# create a service role for ec2 
resource "aws_iam_role" "instance_profile" {
  name = "codedeploy-instance-profile"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# provide ec2 access to s3 bucket to download revision. This role is needed by the CodeDeploy agent on EC2 instances.
resource "aws_iam_role_policy_attachment" "instance_profile_codedeploy" {
  role       = "${aws_iam_role.instance_profile.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "main" {
  name = "codedeploy-instance-profile"
  role = "${aws_iam_role.instance_profile.name}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codedeploy_service.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.artifacts_bucket.arn}",
        "${aws_s3_bucket.artifacts_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.example.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}