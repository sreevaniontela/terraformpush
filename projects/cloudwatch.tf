provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Example AMI ID, change as necessary
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}

# Create a CloudWatch Alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "60"  # Period in seconds
  statistic          = "Average"
  threshold          = "80"   # Set threshold as needed
  alarm_description  = "This alarm triggers when CPU utilization exceeds 80%."
  dimensions = {
    InstanceId = aws_instance.example.id
  }

  # Actions can be specified here for notification
  alarm_actions = ["arn:aws:sns:us-west-2:123456789012:your-sns-topic"]  # Change to your SNS topic ARN
}

# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/ec2/example-instance-logs"

  retention_in_days = 14  # Set retention period
}

# Create a CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "example" {
  dashboard_name = "example-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.example.id],
          ],
          title = "CPU Utilization",
          view = "timeSeries",
          stacked = false,
          region = "us-west-2",
        },
      },
    ]
  })
}

