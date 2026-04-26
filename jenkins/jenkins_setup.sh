#!/bin/bash

# Ensure all commands are executed and output is logged (optional but good for user_data)
set -ex

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install prerequisites
sudo apt-get install -y curl wget unzip gnupg software-properties-common apt-transport-https

# 1. Install Java 17 (openjdk-17-jre)
echo "Installing Java 17..."
sudo apt-get install -y openjdk-17-jre

# 2. Install Git
echo "Installing Git..."
sudo apt-get install -y git

# 3. Install Jenkins LTS
echo "Installing Jenkins LTS..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# 4. Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
# Add users to the docker group
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

# 5. Install AWS CLI v2 via curl and unzip
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# 6. Install Terraform via HashiCorp apt repository
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y terraform

echo "Setup complete!"
