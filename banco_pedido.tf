provider "aws" {
  region = "us-east-1" # Escolha a região desejada
}

# Criação de um cluster RDS
resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "postgres-pedido"
  allocated_storage      = 20 # Tamanho em GB. O Free Tier suporta até 20GB para PostgreSQL
  engine                  = "postgres"
  #engine_version         = "14" # Verifique a versão mais recente compatível
  database_name           = "Pedido" # Nome do banco de dados a ser criado no cluster
  master_username         = "adminuser"
  master_password         = "yourpassword"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  #db_cluster_instance_class = "db.t3.micro" # Escolha a classe de instância
}

# Criação de uma instância dentro do cluster RDS
resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1 # Número de instâncias no cluster
  identifier         = "my-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.micro" # Escolha a classe de instância
  engine             = "postgres"
  engine_version     = "14" # Verifique a versão mais recente compatível
}

# Criação de um Security Group (caso necessário)
resource "aws_security_group" "db_sg" {
  name        = "db_sg" # your_db_subnet_group
  description = "Allow inbound traffic"
  vpc_id      = "vpc-0ef2ca5473def48a3" # Substitua pelo ID da sua VPC

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Ajuste conforme necessário para restringir o acesso
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_sg"
  }
}

# Criação de um DB Subnet Group (caso necessário)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "your_db_subnet_group"
  subnet_ids = ["subnet-0ed689af76b3f3413", "subnet-0ee7ddaeadc0057b5", "subnet-072329a2763260005"] # Substitua pelos IDs das suas subnets

  tags = {
    Name = "MyDBSubnetGroup"
  }
}