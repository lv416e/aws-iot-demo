#-------------------------------------------------------
# Elastic Load Balancers (Classic)
#-------------------------------------------------------
resource "aws_elb" "iot_elb" {
  name            = "iot-elb"
  subnets         = var.elb_subnet_ids
  security_groups = var.elb_sg_ids
  tags            = {
    Name = "iot-elb"
  }

  listener {
    instance_port     = "3000"
    instance_protocol = "http"
    lb_port           = "80"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    target              = "HTTP:3000/api/health"
    interval            = 300
  }
}

resource "aws_lb_cookie_stickiness_policy" "iot_elb_cookie_policy" {
  name                     = "iot-elb-cookie-policy"
  load_balancer            = aws_elb.iot_elb.id
  lb_port                  = 80
  cookie_expiration_period = 10800
}