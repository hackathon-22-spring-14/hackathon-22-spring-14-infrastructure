resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "stamq-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "stamq-igw"
  }
}

resource "aws_subnet" "private-db-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    "Name" = "stamq.private.db.1"
  }
}

resource "aws_subnet" "private-db-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    "Name" = "stamq.private.db.2"
  }
}

resource "aws_subnet" "private-db-3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1d"
  tags = {
    "Name" = "stamq.private.db.3"
  }
}


resource "aws_subnet" "public-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    "Name" = "stamq.pubilc.1"
  }
}

resource "aws_subnet" "private-app" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    "Name" = "stamq.private.app"
  }
}

resource "aws_route_table" "private-app" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "private-app-nat" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private-app.id
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "privatea-app" {
  subnet_id      = aws_subnet.private-app.id
  route_table_id = aws_route_table.private-app.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

# public subnet 用の route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_security_group" "public" {
  name   = "public"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "app" {
  name   = "app"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "app_allow_ing_any" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.app.id
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_allow_eg_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.app.id
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "endpoint_allow_ing_any" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.public.id
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "endpoint_allow_eg_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.public.id
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "database" {
  vpc_id = aws_vpc.vpc.id
  name   = "stamq-vpc.database"
  tags = {
    "Name" = "stamq-vpc.database"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "dev" {
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.dev.id
  subnet_id     = aws_subnet.public-1.id
}
