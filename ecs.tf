provider "aws" {
  region = "us-east-1" # Escolha a região desejada
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "meu-cluster-ecs"
}

# Definição do repositório ECR para os microserviços (assumindo que já existem)
variable "repositorio_pedido" {
  default = "url_do_repositorio_pedido"
}

variable "repositorio_pagamento" {
  default = "url_do_repositorio_pagamento"
}

variable "repositorio_producao" {
  default = "url_do_repositorio_producao"
}

# Definição das tasks
resource "aws_ecs_task_definition" "pedido_task" {
  family                = "pedido"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  cpu                   = "256" # Configuração mínima para o Free Tier
  memory                = "512" # Configuração mínima para o Free Tier
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "pedido",
      image     = var.repositorio_pedido,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "pagamento_task" {
  family                = "pagamento"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "pagamento",
      image     = var.repositorio_pagamento,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "producao_task" {
  family                = "producao"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "producao",
      image     = var.repositorio_producao,
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

# IAM Role para execução das tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
  name       = "ecs_task_execution_role_policy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}