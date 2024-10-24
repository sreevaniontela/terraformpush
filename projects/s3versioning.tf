provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create an S3 bucket with versioning enabled
resource "aws_s3_bucket" "versioned_bucket" {
  bucket = "my-unique-versioned-bucket-12345"  # Change to a unique bucket name
  acl    = "private"  # Set the ACL (Access Control List)

  versioning {
    enabled = true  # Enable versioning
  }

  tags = {
    Name        = "versioned-bucket"
    Environment = "Dev"
  }
}

