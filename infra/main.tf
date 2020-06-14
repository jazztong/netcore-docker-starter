// Provider using local credential
provider "aws" {
  region = "ap-southeast-2"
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
