resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security group for Jenkins Controller"
  vpc_id      = "vpc-0d27064ace74db5f4"

  # Ingress rule for port 8080 from a specific IP ONLY
  ingress {
    description = "Allow Jenkins web access from specific IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["163.61.129.205/32"] # Replace YOUR_IP_ADDRESS with your actual IP
  }

  # Ingress rule for port 22 (SSH) from anywhere
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule allowing all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}
