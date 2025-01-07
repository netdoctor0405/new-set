# acm
resource "aws_acm_certificate" "public_cert" {
  domain_name       = var.fully_qualified_domain_name # *.zeta4.shop
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = {
    Name = "Public Certificate"
  }
}

# Create DNS validation records
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.public_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

# Validate the certificate after DNS records are created
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.public_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

# vpc
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.7.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test_pub_2a" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.7.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pub-2a"
  }
}

resource "aws_subnet" "test_pub_2b" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.7.16.0/20"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pub-2b"
  }
}

resource "aws_subnet" "test_pub_2c" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.7.32.0/20"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pub-2c"
  }
}

resource "aws_subnet" "test_pub_2d" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.7.48.0/20"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pub-2d"
  }
}

resource "aws_subnet" "test_pvt_2a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.7.64.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pvt-2a"
  }
}

resource "aws_subnet" "test_pvt_2b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.7.80.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pvt-2b"
  }
}

resource "aws_subnet" "test_pvt_2c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.7.96.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pvt-2c"
  }
}

resource "aws_subnet" "test_pvt_2d" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.7.112.0/20"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pvt-2d"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "test_pub_rtb" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
  tags = {
    Name = "test-pub-rtb"
  }
}

resource "aws_route_table" "test_pvt_rtb" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-pvt-rtb"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.test_pvt_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.test_bastion.primary_network_interface_id
}

resource "aws_route_table_association" "test_pub_2a_association" {
  subnet_id      = aws_subnet.test_pub_2a.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test_pub_2b_association" {
  subnet_id      = aws_subnet.test_pub_2b.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test_pub_2c_association" {
  subnet_id      = aws_subnet.test_pub_2c.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test_pub_2d_association" {
  subnet_id      = aws_subnet.test_pub_2d.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test_pvt_2a_association" {
  subnet_id      = aws_subnet.test_pvt_2a.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test_pvt_2b_association" {
  subnet_id      = aws_subnet.test_pvt_2b.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2c_association" {
  subnet_id      = aws_subnet.test_pvt_2c.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test_pvt_2d_association" {
  subnet_id      = aws_subnet.test_pvt_2d.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

# ec2
resource "aws_key_pair" "test_key" {
  key_name   = "test-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  # ami                    = data.aws_ami.amazon_linux_2023.id
  ami                    = "ami-049788618f07e189d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_sg_web.id]
  subnet_id              = aws_subnet.test_pub_2c.id
  key_name               = aws_key_pair.test_key.key_name

  user_data = <<-EOF
              #cloud-boothook
              #!/bin/bash
              timedatectl set-timezone Asia/Seoul
              dnf install -y httpd git
              cd /var/www/
              git clone https://github.com/netdoctor0405/html.git
              systemctl enable --now httpd
              EOF

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_ami_from_instance" "my_sale_ami" {
  name               = "my-sale-ami"
  source_instance_id = aws_instance.example.id
  description        = "AMI created from the terraform-webserver instance"

  tags = {
    Name = "my-sale-ami"
  }
}

resource "aws_instance" "test_web01" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_pvt_2a.id
  vpc_security_group_ids = [aws_security_group.test_sg_web.id]
  key_name               = aws_key_pair.test_key.key_name
  user_data              = <<-EOF
              #cloud-boothook
              #!/bin/bash
              dnf install -y httpd
              systemctl enable --now httpd
              echo "<h1>test-web01</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "test-web01"
  }
}

resource "aws_instance" "test_web02" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_pvt_2c.id
  vpc_security_group_ids = [aws_security_group.test_sg_web.id]
  key_name               = aws_key_pair.test_key.key_name
  user_data              = <<-EOF
              #cloud-boothook
              #!/bin/bash
              dnf install -y httpd
              systemctl enable --now httpd
              echo "<h1>test-web02</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "test-web02"
  }
}

resource "aws_instance" "test_bastion" {
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_pub_2a.id
  vpc_security_group_ids = [aws_security_group.test_sg_web.id]
  key_name               = aws_key_pair.test_key.key_name
  source_dest_check      = false

  tags = {
    Name = "test-bastion"
  }
}

resource "aws_security_group" "test_sg_web" {
  vpc_id = aws_vpc.test_vpc.id
  name   = var.security_group_name_web

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["60.196.24.130/32"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg-web"
  }
}

# alb
resource "aws_lb" "frontend" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_sg_alb.id]
  subnets = [
    aws_subnet.test_pub_2a.id,
    aws_subnet.test_pub_2c.id
  ]

  tags = {
    Name = "test-alb"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_tg_alb.arn
  }
}

resource "aws_lb_listener" "secure_listener" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.public_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_tg_alb.arn
  }
}

resource "aws_lb_target_group" "test_tg_alb" {
  name        = "test-tg-alb"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_alb_target_group_attachment" "tgattachment01" {
  count            = 0
  target_group_arn = aws_lb_target_group.test_tg_alb.arn
  target_id        = aws_instance.test_web01.id
  port             = 80
}
resource "aws_alb_target_group_attachment" "tgattachment02" {
  count            = 0
  target_group_arn = aws_lb_target_group.test_tg_alb.arn
  target_id        = aws_instance.test_web02.id
  port             = 80
}

resource "aws_security_group" "test_sg_alb" {
  vpc_id = aws_vpc.test_vpc.id
  name   = var.security_group_name_alb

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg-alb"
  }
}

# alias
resource "aws_route53_record" "alb_alias_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "alb.zeta4.shop"
  type    = "A"

  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}

# asg
resource "aws_launch_template" "test_lt" {
  name          = "test-launch-template"
  image_id      = aws_ami_from_instance.my_sale_ami.id
  instance_type = "t2.micro"

  key_name = "test-key"

  #  user_data = base64encode(<<-EOF
  #              #!/bin/bash
  #              dnf install -y httpd
  #              systemctl enable --now httpd
  #              echo "<h1>test-asg</h1>" > /var/www/html/index.html
  #              EOF
  #  )

  network_interfaces {
    security_groups = [aws_security_group.test_sg_web.id]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test_asg" {
  launch_template {
    id      = aws_launch_template.test_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    aws_subnet.test_pvt_2a.id,
    aws_subnet.test_pvt_2c.id
  ]

  target_group_arns = [aws_lb_target_group.test_tg_alb.arn]
  health_check_type = "ELB"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  tag {
    key                 = "Name"
    value               = "test-asg"
    propagate_at_launch = true # Launch Template에서 생성된 인스턴스에도 전파
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "ScaleInPolicy"
  autoscaling_group_name = aws_autoscaling_group.test_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_description   = "Monitors CPU utilization for test ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  alarm_name          = "ScaleInAlarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = 30
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"

  dimensions = { # 메트릭 데이터를 특정 리소스에 연결
    AutoScalingGroupName = aws_autoscaling_group.test_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "ScaleOutPolicy"
  autoscaling_group_name = aws_autoscaling_group.test_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_description   = "Monitors CPU utilization for test ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  alarm_name          = "ScaleOutAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = 70
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.test_asg.name
  }
}
