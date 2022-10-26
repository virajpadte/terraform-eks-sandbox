resource "aws_ecr_repository" "game_2048" {
  name                 = "game2048"
  image_tag_mutability = "IMMUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}