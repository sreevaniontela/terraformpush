provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create an IAM Role
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-s3-access-role"
  }
}

# Create a policy that allows S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy that allows S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::your-bucket-name",            # Replace with your bucket name
          "arn:aws:s3:::your-bucket-name/*"            # Replace with your bucket name
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Example EC2 instance using the IAM role
resource "aws_instance" "example" {
  ami               = "ami-0c55b159cbfafe1f0"  # Change to your preferred AMI
  instance_type     = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id  # Attach the IAM role

  tags = {
    Name = "example-instance"
  }
}

# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

