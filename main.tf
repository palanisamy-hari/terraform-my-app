resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_security_group" "allow_web_traffic" {
  name = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "174.101.241.104/32"]
  }

  tags = {
    Name = "my-app"
  }
}

resource "aws_instance" "my-web" {
  ami = var.ami_instance
  instance_type = var.instance_type
  availability_zone = "${var.region}b"
  key_name = "hari-aws-key-east-2"

  tags = {
    Name = "my-app"
  }

  security_groups = [ aws_security_group.allow_web_traffic.name ]
}