# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"

  tags = {
    Name = "AppServer"
  }

  security_groups = [aws_security_group.app_sg.name]
}

# Security Group for EC2
resource "aws_security_group" "app_sg" {
  name = "app_server_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# S3 Bucket
resource "aws_s3_bucket" "static_assets" {
  bucket = "static-assets-bucket"
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "static_assets_policy" {
  bucket = aws_s3_bucket.static_assets.id
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::static-assets-bucket/*"
    }
  ]
}
EOT
}
