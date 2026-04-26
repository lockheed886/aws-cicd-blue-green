# Fetch the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Provision the Jenkins Controller EC2 instance
resource "aws_instance" "jenkins_controller" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Place in one of the public subnets from the existing VPC
  subnet_id                   = "subnet-06a81176ed120728c"
  associate_public_ip_address = true
  
  # Attach the security group we created
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # Assumes you have the same key_pair from Assignment 3 available. 
  # Uncomment/adjust this if you copied over your key_pair resource block.
  # key_name = aws_key_pair.deployer.key_name

  # Pass the setup script as user_data
  user_data = file("${path.module}/jenkins_setup.sh")

  tags = {
    Name = "Jenkins-Controller"
  }
}

# Output the public IP address to access Jenkins easily
output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins Controller"
  value       = aws_instance.jenkins_controller.public_ip
}
