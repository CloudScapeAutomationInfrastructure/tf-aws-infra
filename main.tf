provider "aws" {
  region = var.aws_region
}

resource "random_id" "vpc" {
  byte_length = 2
}

resource "time_static" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = cidrsubnet(var.vpc_cidr_block, 8, random_id.vpc.dec % 256)
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 3)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index}-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-internet-gateway-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_gw.id
  }
  tags = {
    Name = "public-route-table-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer-sg"
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebAppSecurityGroup"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_db_parameter_group" "my_db_parameter_group" {
  family = "mysql8.0"
  name   = "webapp-mysql-param-group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = {
    Name = "webapp-mysql-param-group"
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "my-db-subnet-group"
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  identifier             = "csye6225"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "csye6225"
  username               = "csye6225"
  password               = "password"
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.my_db_parameter_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
}

resource "aws_lb" "web_app_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "web-app-alb"
  }
}

resource "aws_lb_target_group" "web_app_tg" {
  name     = "web-app-tg"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/v1/healthz"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-app-tg"
  }
}

resource "aws_lb_listener" "web_app_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}

resource "aws_launch_template" "web_app_lt" {
  name_prefix   = "csye6225_asg"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.keyname

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
    subnet_id                   = aws_subnet.public[0].id
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y amazon-cloudwatch-agent

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Create environment file for Flask app with all required variables
cat <<EOT > /var/www/html/api/.env
DATABASE_URL="mysql+mysqlconnector://csye6225:password@${aws_db_instance.db_instance.endpoint}/csye6225"
SECRET_KEY="your_secret_key"
S3_BUCKET_NAME="image-upload-s3-bucket-${random_id.s3_bucket.hex}"
AWS_REGION="us-east-2"
SENDGRID_API_KEY="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"
FROM_EMAIL="nag.sr@northeastern.edu"
REPLY_TO_EMAIL="sri15nag@gmail.com"
EOT

# Set ownership for the .env file
sudo chown csye6225:csye6225 /var/www/html/api/.env

# Activate the virtual environment and start the Flask app
cd /var/www/html/api
source venv/bin/activate
nohup python app.py &
EOF
  )
}

resource "aws_autoscaling_group" "web_app_asg" {
  launch_template {
    id      = aws_launch_template.web_app_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier       = aws_subnet.public[*].id
  min_size                  = 3
  max_size                  = 5
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 60
  target_group_arns         = [aws_lb_target_group.web_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "web-app-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 3
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name

  metric_aggregation_type = "Average"
  policy_type             = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name

  metric_aggregation_type = "Average"
  policy_type             = "SimpleScaling"
}
