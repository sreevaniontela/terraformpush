provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI ID
  instance_type = "t2.micro"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high_cpu_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "60"
  statistic          = "Average"
  threshold          = "70"
  alarm_description  = "This alarm monitors CPU utilization"
  insufficient_data_actions = []
  alarm_actions      = [] # Specify SNS topic ARNs if needed

  dimensions = {
    InstanceId = aws_instance.example.id
  }
}

