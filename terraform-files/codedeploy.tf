resource "aws_codedeploy_app" "foo_app" {
  compute_platform = "Server"
  name             = "foo_app"
}

resource "aws_codedeploy_deployment_config" "foo" {
  deployment_config_name = "test-deployment-config"


  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }


}


resource "aws_codedeploy_deployment_group" "foo" {
  app_name               = aws_codedeploy_app.foo_app.name
  deployment_group_name  = "bar"
  service_role_arn       = aws_iam_role.codedeploy_service.arn
  deployment_config_name = aws_codedeploy_deployment_config.foo.id

  ec2_tag_filter {
    key   = "env"
    type  = "KEY_AND_VALUE"
    value = "prod"
  }

/*
  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "foo-trigger"
    trigger_target_arn = "foo-topic-arn"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }
*/
}