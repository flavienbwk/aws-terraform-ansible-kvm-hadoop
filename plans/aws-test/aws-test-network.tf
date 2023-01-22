resource "aws_vpc" "takh_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_internet_gateway" "takh_gw" {
  vpc_id = aws_vpc.takh_vpc.id
  tags = {
    Name : "Prod gateway"
  }
}

resource "aws_route_table" "takh_rt" {
  vpc_id = aws_vpc.takh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.takh_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.takh_gw.id
  }

  tags = {
    Name = "Prod"
  }
}

resource "aws_subnet" "takh_net" {
  vpc_id                  = aws_vpc.takh_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_route_table_association" "takh_rta" {
  subnet_id      = aws_subnet.takh_net.id
  route_table_id = aws_route_table.takh_rt.id
}

resource "aws_security_group" "takh_sg" {
  name        = "allow_web_traffic"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.takh_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "takh_sg"
  }
}
