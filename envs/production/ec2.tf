resource "aws_instance" "ec2" {
  ami                         = "ami-011facbea5ec0363b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-1.id
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.ec2-key.key_name
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.systems-manager.name
}

resource "aws_eip" "ec2-eip" {
  vpc      = true
  instance = aws_instance.ec2.id
}

#--------------------------------------------------------------
# Key Pair
#--------------------------------------------------------------

resource "aws_key_pair" "ec2-key" {
  key_name   = "common-ssh"
  public_key = tls_private_key._.public_key_openssh
}

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
  name = "stamq-ec2-sg"

  description = "EC2 service security group for stamq"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = { for i in var.ingress_config : i.port => i }

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
# IAM Role
#--------------------------------------------------------------

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "systems-manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2" {
  name               = "stamq-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.systems-manager.arn
}

resource "aws_iam_instance_profile" "systems-manager" {
  name = "stamq-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}