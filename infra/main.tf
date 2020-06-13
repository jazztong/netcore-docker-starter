provider "aws" {
  region = "ap-southeast-2"
}
// Key pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = "keypair"
  public_key = tls_private_key.key.public_key_openssh
}
// Instance profile
resource "aws_iam_instance_profile" "profile" {
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "role" {
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
// Default VPC
data "aws_vpc" "main" {
  default = true
}
//Security Group
resource "aws_security_group" "sg" {
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
// EC2
resource "aws_instance" "ec2" {
  ami                    = "ami-088ff0e3bde7b3fdf"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  key_name               = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data_base64       = filebase64("${path.module}/user-data.sh")
}

// Output
output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "private_pem" {
  value = tls_private_key.key.private_key_pem
}
