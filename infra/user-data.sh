#! /bin/bash
set -e
# Ouput all log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Make sure we have all the latest updates when we launch this instance
yum update -y && yum upgrade -y
# Install components
yum install -y docker amazon-ecr-credential-helper
# Add credential helper to pull from ECR
mkdir -p ~/.docker && chmod 0700 ~/.docker
echo '{"credsStore": "ecr-login"}' > ~/.docker/config.json
# Start docker now and enable auto start on boot
service docker start && chkconfig docker on
# Allow the ec2-user to run docker commands without sudo
usermod -a -G docker ec2-user
# Run application at start
docker run --restart=always -d -p 80:5000 132189507319.dkr.ecr.ap-southeast-2.amazonaws.com/sampleapi:latest