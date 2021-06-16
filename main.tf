resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id
}

resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  tags = {
    Name = "${var.environment}-Public-RouteTable"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}-Public-Subnet-1"
  }
}

resource "aws_route_table_association" "a" {
  route_table_id = aws_route_table.dev-route-table.id
  subnet_id = aws_subnet.subnet-1.id
}

resource "aws_security_group" "allow_web_traffic" {
  name = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS for secured ports"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "174.101.241.104/32"]
  }

  ingress {
    description = "Concourse"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "my-app"
  }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id = aws_subnet.subnet-1.id
  private_ips = [
    "10.0.1.50"]
  security_groups = [
    aws_security_group.allow_web_traffic.id]

}

resource "aws_eip" "one" {
  vpc = true
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.dev-gw]
}

resource "aws_instance" "my-web" {
  ami = var.ami_instance
  instance_type = var.instance_type
  availability_zone = "${var.region}b"
  key_name = "hari-aws-key-east-2"

  tags = {
    Name = "my-app"
  }

  security_groups = [
    aws_security_group.allow_web_traffic.name]
}