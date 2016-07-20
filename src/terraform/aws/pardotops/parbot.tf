resource "aws_ecr_repository" "parbot" {
  name = "parbot"
}

resource "aws_ecs_cluster" "parbot_production" {
  name = "parbot_production"
}
