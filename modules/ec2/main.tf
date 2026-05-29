resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "ec2" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.this.key_name
  availability_zone = var.availability_zone
  security_groups = [ "${var.security_group_name}" ]
  tags = {
    Name = var.tag_name
  }
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
    encrypted = true 
    delete_on_termination = true
  }
  provisioner "remote-exec" {
    script = "../app/files/install.sh"
    connection {
      type = "ssh"
      user = var.user
      host = self.public_ip
      private_key = tls_private_key.ssh_key.private_key_pem
    }
  }
}