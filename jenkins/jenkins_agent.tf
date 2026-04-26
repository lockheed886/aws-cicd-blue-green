resource "aws_security_group" "jenkins_agent_sg" {
  name        = "jenkins_agent_sg"
  description = "Security group for Jenkins Agent"
  vpc_id      = "vpc-0d27064ace74db5f4" # Using the prod-vpc ID

  ingress {
    description = "Allow SSH from Jenkins Controller ONLY"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Dynamically references the private IP of the Jenkins Controller
    cidr_blocks = ["${aws_instance.jenkins_controller.private_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_agent_sg"
  }
}

resource "aws_instance" "jenkins_agent" {
  # Reuses the Ubuntu 22.04 AMI fetched in jenkins_instance.tf
  ami           = data.aws_ami.ubuntu.id 
  instance_type = "t3.micro"
  
  # TODO: Replace with the actual ID of your private subnet
  subnet_id = "subnet-01a195335ced900d4" 
  
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  key_name               = "devops_key"

  # Inline user_data script for Jenkins Agent
  user_data = <<-EOF
              #!/bin/bash
              set -ex
              
              # Update system
              sudo apt-get update -y
              
              # Install Java 21
              sudo apt-get install -y openjdk-21-jre
              
              # Install Git
              sudo apt-get install -y git
              
              # Install Docker
              sudo apt-get install -y docker.io
              sudo systemctl enable --now docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Jenkins-Agent"
  }
}

output "jenkins_agent_private_ip" {
  description = "The private IP address of the Jenkins Agent"
  value       = aws_instance.jenkins_agent.private_ip
}
