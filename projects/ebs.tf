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

# Create a subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "main-subnet"
  }
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Change to your preferred AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.instance_sg.name]

  tags = {
    Name = "example-instance"
  }
}

# Create an EBS volume
resource "aws_ebs_volume" "example" {
  availability_zone = aws_subnet.main_subnet.availability_zone
  size              = 10  # Size in GB
  tags = {
    Name = "example-volume"
  }
}

# Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "example" {
  device_name = "/dev/sdh"  # Linux: /dev/sdh, Windows: xvdh
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.example.id

  # Wait for the attachment to complete
  depends_on = [aws_instance.example]
}

