resource "aws_codepipeline" "static_web_pipeline" {
  name     = "static-web-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = aws_s3_bucket.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.repository_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.repository_name
        OAuthToken             = var.github_token
      }

      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
          ]
        )
        "ProjectName" = "static-web-build"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      /*
      configuration = {
        "BucketName" = aws_s3_bucket.static_web_bucket.bucket
        "Extract"    = "true"
      }
      */
      input_artifacts = [
        "BuildArtifact",
      ]

      configuration = {
        ApplicationName = aws_codedeploy_deployment_group.foo.app_name
        DeploymentGroupName = aws_codedeploy_deployment_group.foo.deployment_group_name
      }

      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeDeploy"
      run_order        = 1
      version          = "1"
    }
  }
}
