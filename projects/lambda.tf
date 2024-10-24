provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create an S3 bucket to trigger the Lambda function
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-lambda-trigger-bucket"  # Change to a unique bucket name

  tags = {
    Name = "lambda-trigger-bucket"
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "lambda-execution-role"
  }
}

# Create a policy that allows logging and S3 access
resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaPolicy"
  description = "Policy for Lambda execution role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.lambda_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create the Lambda function
resource "aws_lambda_function" "example" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"  # Change based on your handler
  runtime       = "nodejs14.x"      # Change to your preferred runtime
  filename      = "lambda_function.zip"  # Path to your zipped function code

  source_code_hash = filebase64sha256("lambda_function.zip")  # Ensure to have this file in your working directory

  environment {
    BUCKET_NAME = aws_s3_bucket.lambda_bucket.bucket
  }
}

# Create S3 bucket notification for Lambda trigger
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.example.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_function.example]
}

