data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250305"]
  }
}

resource "aws_instance" "CI-CD_instance" {
  count                     = 1
  instance_type             = "t2.micro"
  ami                       = data.aws_ami.server_ami.id
  key_name                  = "Key_For_CI-CD-proj"
  subnet_id                 = aws_subnet.CI-CD_pub_sub[0].id
  vpc_security_group_ids    = [aws_security_group.CI-CD_sg.id]

  tags = {
    Name       = "CI-CD_project"
    Environment = "Production"
  }

  root_block_device {
    volume_size = var.main_vol_size
  }

  provisioner "local-exec" {
    command = "echo '[main]\n${self.public_ip}' > aws_hosts"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }
}

output "grafana-access" {
  value = { for i in aws_instance.CI-CD_instance : i.tags.Name => "${i.public_ip}:3000" }
}

output "instance_ips" {
  value = [ for i in aws_instance.CI-CD_instance : i.public_ip ]
}

