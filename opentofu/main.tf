provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}
#Security Group
resource "aws_security_group" "minecraft_sg" {
  #Create id within Stack Context using stack_id.hex
  name_prefix = "minecraft-${random_id.stack_id.hex}-" 
  description = "Allow SSH and Minecraft access"
  vpc_id      = data.aws_vpc.default.id
  #Beginning Input Port Range for TCP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Max Input port range for Tcp
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Outgoing Port Block
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Create id within Stack Context
  tags = {
    Name = "minecraft-sg-${random_id.stack_id.hex}" 
  }
}
#Instance Setup
resource "aws_instance" "minecraft" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = var.instance_type # Blueprint option
  key_name      = "minesible-access"
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "MinecraftServer-${random_id.stack_id.hex}"
  }
#passing data to ec2 Instance till EOF is encountered
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y python3
EOF
}

#S3 Backup bucket
resource "aws_s3_bucket" "minecraft_saves"{
  #Temp ID: random_id.stack_id.hex will need to created in place of var if 
  #var.minecraft_s3_bucket is not provided
  bucket = var.minecraft_s3_bucket != null ? var.minecraft_s3_bucket : "minesible-world-backups-${random_id.bucket_id.hex}"
  force_destroy = true
  #Create Server
  count = var.minecraft_s3_bucket == null? 1:0
  tags = {
    Name = "minecraft-saves-${random_id.stack_id.hex}" 
  }
}
#IAM Role
resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2-minecraft-s3-access-${random_id.stack_id.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "minecraft-ec2-role-${random_id.stack_id.hex}"
  }
}
#S3 Policy
resource "aws_iam_role_policy" "s3_policy" {
  name = "ec2-s3-full-access-${random_id.stack_id.hex}"
  role = aws_iam_role.ec2_s3_access.id
  #Set Permissions
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}
#Create ec2 Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "minecraft-ec2-profile-${random_id.stack_id.hex}"
  role = aws_iam_role.ec2_s3_access.name
  tags = {
    Name = "minecraft-instance-profile-${random_id.stack_id.hex}"
  }
}






