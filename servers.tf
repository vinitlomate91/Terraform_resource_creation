
data "aws_ami" "ami_amzn" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_security_group" "k8s_sg" {
    description = "Allow ingress and egress traffic for k8s cluster"
    vpc_id = data.aws_vpc.default.id
    tags = {
       name = "k8s_sg"
    }
}

resource "aws_security_group_rule" "k8s_sg_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "k8s_sg_ingress_1" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "k8s_sg_ingress_2" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "k8s_sg_ingress_3" {
    type = "ingress"
    from_port = 30000
    to_port = 32767
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "k8s_sg_ingress_4" {
    type = "ingress"
    from_port = 30937
    to_port = 30937
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_security_group_rule" "k8s_sg_egress" {
    type = "egress"
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.k8s_sg.id
}

resource "aws_instance" "master" {
    instance_type = var.instance_type
    ami = data.aws_ami.ami_amzn.id
    vpc_security_group_ids = [aws_security_group.k8s_sg.id]
    subnet_id = tolist (data.aws_subnets.default.ids) [0]
    key_name = "k8s"
    associate_public_ip_address = true
    tags = {
        name = "master"
    }
}

resource "aws_instance" "worker01" {
    instance_type = var.instance_type
    ami = data.aws_ami.ami_amzn.id
    vpc_security_group_ids = [aws_security_group.k8s_sg.id]
    subnet_id = tolist(data.aws_subnets.default.ids) [1]
    key_name = "k8s"
    associate_public_ip_address = true
    tags = {
        name = "worker01"
    }
}
