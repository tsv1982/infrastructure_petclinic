resource "aws_security_group" "security_group" {
  name        = "${var.app_name}-security_group"
  description = var.app_environment
  vpc_id      = aws_vpc.vpc.id
 
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }

ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
  }
 
egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = {
    Name        = "${var.app_name}-security_group"
    Environment = var.app_environment
  }
}

