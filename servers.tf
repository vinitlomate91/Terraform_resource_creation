
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

locals {
    ec2_names = {
        master1 = "master-node01"
        worker1 = "worker-node-1"
        worker2 = "worker-node-2"
    }
}

resource "aws_instance" "servers" {
    for_each = local.ec2_names
    instance_type = var.instance_type
    ami = data.aws_ami.ami_amzn.id
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_security_group_ids = [aws_security_group.k8s_sg.id]
    subnet_id = each.key == "master1" ? tolist(data.aws_subnets.default.ids)[0] : tolist(data.aws_subnets.default.ids)[1]
    key_name = "k8s_1"
    associate_public_ip_address = true
    tags = {
        Name = each.value
    }
}

resource "aws_instance" "github_runner" {
    instance_type = var.instance_type
    ami = data.aws_ami.ami_amzn.id
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_security_group_ids = [aws_security_group.k8s_sg.id]
    subnet_id = tolist(data.aws_subnets.default.ids) [1]
    key_name = "k8s_1"
    associate_public_ip_address = true
    tags = {
        Name = "github_runner"
    }
}

terraform {
  backend "s3" {
    bucket       = "terraforms3328062026"
    key          = "ec2/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}