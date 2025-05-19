# ALB
resource "aws_lb" "test" {
  name               = "CI-CD-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.CI-CD_sg.id]
  subnets            = [for subnet in aws_subnet.CI-CD_pub_sub : subnet.id]

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "CI-CD-tg" {
  name     = "CI-CD-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.CI-CD-vpc.id

  health_check {
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = length(aws_instance.CI-CD_instance)
  target_group_arn = aws_lb_target_group.CI-CD-tg.arn
  target_id        = aws_instance.CI-CD_instance[count.index].id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.CI-CD-tg.arn
  }
}

