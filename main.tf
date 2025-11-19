# Create New VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Pub Subnet
resource "aws_subnet" "pub-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public-subnettt"
    Team = "DEV"
    Number = "1"
  }
}

# Create Prvt Subnet
resource "aws_subnet" "pvt-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnett"
  }
}
# Routing Table For Public
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-route"
  }
  # depends_on = [aws_internet_gateway.igw]
}

# Crete Route Table Association For Public
resource "aws_route_table_association" "pub-route-ass" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.pub-route.id
}
# Routing Table For Private
resource "aws_route_table" "pvt-route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.ngw.id
    #vpc_peering_connection_id = aws_vpc_peering_connection.mypeer.id
  }
  tags = {
    Name = "private-route"
  }
}
#Create Route Table Association For Private
resource "aws_route_table_association" "prt-route-ass" {
  subnet_id      = aws_subnet.pvt-subnet.id
  route_table_id = aws_route_table.pvt-route.id
}
# Pub Sg
resource "aws_security_group" "pub-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public-sg"
  }
}
# Pvt Sg
resource "aws_security_group" "pvt-sg" {
  name        = "private-sg"
  description = "Allow TLS inbound traffic for private sg"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "prvt-sgq"
  }
}


# Ec2 Pub
resource "aws_instance" "public-ec2" {
  ami    = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.pub-subnet.id
  #key_name   = "ajith22"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.pub-sg.id]
  tags = {
    Name = "Public-vgs"
    Team = "DEV"
    Name = "Public-ec2"
  }
}

# EC2 Prvt
resource "aws_instance" "private-ec2" {
  ami    = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.small"
  subnet_id     = aws_subnet.pvt-subnet.id
  #key_name   = "ajith22"
  vpc_security_group_ids = [aws_security_group.pvt-sg.id]
  tags = {
    Name = "Private-vgs"
    Name = "Private-ec2"
    Team = "PROD"
  }
}

# Internet Gate Way
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}
 # EIP # Must Read Before Delete This
 resource "aws_eip" "myeip" {
   vpc   =  true
 }
 #Nat Gate Way
 resource "aws_nat_gateway" "ngw" {
   allocation_id = aws_eip.myeip.id
   subnet_id     = aws_subnet.pub-subnet.id
  
   tags = {
     Name = "natgw"
   }
 }