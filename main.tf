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


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}

resource "aws_route_table_association" "private_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    from_port   = var.application_port
    to_port     = var.application_port
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
    Name = "app-sg-${random_id.vpc.hex}-${time_static.current.id}-terraform"
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
  # tags = {
  #   Name = "csye6225-db"
  # }
}


resource "aws_instance" "web_app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  disable_api_termination     = false
  key_name                    = var.keyname

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    # Update packages
    sudo apt-get update

    # Replace content of the .env file at /var/www/html/api
    sudo bash -c 'echo "DATABASE_URL=mysql+mysqlconnector://csye6225:password@${aws_db_instance.db_instance.endpoint}/csye6225" > /var/www/html/api/.env'
    
    # Activate the virtual environment and start the Flask app
    cd /var/www/html/api
    source venv/bin/activate
    nohup python app.py &
  EOF

  tags = {
    Name = "web-app-${random_id.vpc.hex}-${time_static.current.id}-terraform"
  }
}
