variable "region" {
  default = "us-east-1"
}

resource "aws_vpc" "capstone_developer" {
  cidr_block           = "10.240.0.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "capstone-project"
  }
}

resource "aws_vpc_dhcp_options" "capstone_developer" {
  domain_name         = "us-east-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = "capstone_developer"
  }
}

resource "aws_vpc_dhcp_options_association" "capstone_developer" {
  vpc_id          = "${aws_vpc.capstone_developer.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.capstone_developer.id}"
}

resource "aws_subnet" "capstone_developer" {
  vpc_id     = "${aws_vpc.capstone_developer.id}"
  cidr_block = "10.240.0.0/24"

  tags = {
    Name = "capstone_developer"
  }
}

resource "aws_internet_gateway" "capstone_developer" {
  vpc_id = "${aws_vpc.capstone_developer.id}"

  tags = {
    Name = "capstone_developer"
  }
}

resource "aws_route_table" "capstone_developer" {
  vpc_id = "${aws_vpc.capstone_developer.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.capstone_developer.id}"
  }


  tags = {
    Name = "capstone_developer"
  }
}

resource "aws_route_table_association" "capstone_developer" {
  subnet_id      = "${aws_subnet.capstone_developer.id}"
  route_table_id = "${aws_route_table.capstone_developer.id}"
}

resource "aws_security_group" "capstone_developer" {
  name        = "capstone_developer"
  description = "Kubernetes security group"
  vpc_id      = "${aws_vpc.capstone_developer.id}"

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # define the outbound rule, allow all kinds of accesses from anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "capstone_developer"
  }
}

# Sends your public key to the instance
resource "aws_key_pair" "capstone_developer" {
  key_name   = "capstone_developer"
  public_key = file(var.PUBLIC_KEY_PATH)
}



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "capstone_developer" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.capstone_developer.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.capstone_developer.id}"]
  instance_type               = "t2.micro"
  private_ip                  = "${var.capstone_developer_ip}"
  user_data                   = "name=capstone-developer"
  subnet_id                   = "${aws_subnet.capstone_developer.id}"
  source_dest_check           = false

  tags = {
    Name = "capstone_developer"
  }
}

resource "null_resource" "controller_bootstrap" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.PRIV_KEY_PATH)
    host        = "${aws_instance.capstone_developer.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [ "mkdir -p /home/ubuntu/capstone_developer-scripts" ]
  }

  provisioner "file" {
    source      = "scripts/capstone_developer-bootstrap-machines.sh"
    destination = "/home/ubuntu/capstone_developer-scripts/capstone_developer-bootstrap-machines.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/capstone_developer-scripts/capstone_developer-bootstrap-machines.sh",
      "/home/ubuntu/capstone_developer-scripts/capstone_developer-bootstrap-machines.sh"
    ]
  }
}

output "instance_ips" {
  value = aws_instance.capstone_developer.public_ip
}
