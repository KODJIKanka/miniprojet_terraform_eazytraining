data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "securitygroup" {
  source              = "../modules/securitygroup"
  security_group_name = "eazytraining_sg"
}

module "ec2" {
  source              = "../modules/ec2"
  tag_name            = "eazytraining_ec2"
  security_group_name = module.securitygroup.name
  user                = "ubuntu"
  key_name            = "eazytraining"
  availability_zone   = "us-east-1a"
  ami                 = data.aws_ami.ubuntu_ami.id
  instance_type       = var.instance_type
}
module "eip" {
  source   = "../modules/eip"
  eip_name = "eazytraining_eip"
}

module "ebs" {
  source   = "../modules/ebs"
  ebs_size = 10
  ebs_zone = "us-east-1a"
  ebs_tags = {
    Name = "eazytraining_ebs"
  }
}

resource "aws_eip_association" "eip_association" {
  instance_id   = module.ec2.ec2_id
  allocation_id = module.eip.eip_id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  instance_id = module.ec2.ec2_id
  volume_id   = module.ebs.ebs_id
}