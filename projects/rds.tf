provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet for RDS
resource "aws_subnet" "rds_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Change as needed

  tags = {
    Name = "rds-subnet"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432  # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as needed for your security requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Create the RDS instance
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type        = "gp2"  # General Purpose SSD
  engine             = "postgres"
  engine_version     = "13.3"  # Change as needed
  instance_class     = "db.t2.micro"
  name                = "mydb"
  username            = "admin"
  password            = "password123"  # Use a more secure way to manage passwords
  db_subnet_group_name = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Set to true for production use to avoid accidental deletion
  delete_protection = false

  tags = {
    Name = "example-rds-instance"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "example" {
  name       = "mydb-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet.id]

  tags = {
    Name = "mydb-subnet-group"
  }
}

