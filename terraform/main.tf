#/home/dean/dean/projects1/withoutbonus/terraform/main.tf
provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "290623tfstatebucket"
    key    = "nats-cluster-project/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_vpc" "nats_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "nats-vpc"
  }
}

resource "aws_subnet" "nats_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.nats_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "nats-subnet"
  }
}

resource "aws_security_group" "nats_sg" {
  name        = "nats-sg"
  description = "NATS Security Group"
  vpc_id = aws_vpc.nats_vpc.id

  ingress {
    from_port   = 4222
    to_port     = 4222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // you might want to restrict this to your IP
  }

  ingress {
    from_port   = 6222
    to_port     = 6222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Open to the world, again, be cautious
  }

 ingress {
    from_port   = 8222
    to_port     = 8222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Open to the world, again, be cautious
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  // allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "nats_node" {
  count = 3
  ami = "ami-0e342d72b12109f91"
  instance_type = "t2.micro"
  key_name = "0923pairaws"
  subnet_id = aws_subnet.nats_subnet.id
  vpc_security_group_ids = [aws_security_group.nats_sg.id]  

  tags = {
    Name = "nats-node-${count.index}"
  }
}


output "instance_ips" {
  value = [for instance in aws_instance.nats_node : instance.public_ip]
  description = "Public IPs of the NATS nodes"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "nats_igw" {
  vpc_id = aws_vpc.nats_vpc.id

  tags = {
    Name = "nats-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "nats_route_table" {
  vpc_id = aws_vpc.nats_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nats_igw.id
  }

  tags = {
    Name = "nats-route-table"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "nats_route_table_association" {
  subnet_id      = aws_subnet.nats_subnet.id
  route_table_id = aws_route_table.nats_route_table.id
}
