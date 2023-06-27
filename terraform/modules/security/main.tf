#-------------------------------------------------------
#
#-------------------------------------------------------
resource "aws_security_group" "iot_server_sg" {
  name        = "iot-server-sg"
  description = "Security Group for Grafana Servers"
  vpc_id      = var.vpc_id
  tags        = {
    Name = "iot-server-sg"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "iot_balancer_sg" {
  name        = "iot-balancer-sg"
  description = "Security Group for Load Balancer"
  vpc_id      = var.vpc_id
  tags        = {
    Name = "iot-balancer-sg"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}