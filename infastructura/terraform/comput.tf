data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250305"]
  }
}

# Create the header once before instances start
resource "null_resource" "init_hosts_file" {
  provisioner "local-exec" {
    command = "echo '[main]' > aws_hosts"
  }
}

resource "aws_instance" "CI-CD_instance" {
  count                  = 2
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = "Key_For_CI-CD-proj"
  subnet_id              = aws_subnet.CI-CD_pub_sub[0].id
  vpc_security_group_ids = [aws_security_group.CI-CD_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt install wget -y && sudo apt install unzip -y && sudo apt install nginx -y

              sudo systemctl start nginx.service
              cd /var/www/html
              sudo wget https://www.tooplate.com/zip-templates/2130_waso_strategy.zip
              sudo unzip 2130_waso_strategy.zip
              cd 2130_waso_strategy
              sudo cp -r * /var/www/html
              sudo systemctl restart nginx.service
              EOF

  tags = {
    Name        = "CI-CD_project"
    Environment = "Production"
  }

  root_block_device {
    volume_size = var.main_vol_size
  }

  # Make sure header is created before appending IPs
  depends_on = [null_resource.init_hosts_file]

  provisioner "local-exec" {
    command = "echo '${self.public_ip}' >> aws_hosts"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '/^[0-9]/d' aws_hosts"
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
  }
}

output "grafana-access" {
  value = { for i in aws_instance.CI-CD_instance : i.tags.Name => ["${i.public_ip}:3000"]... }
}

output "instance_ips" {
  value = [ for i in aws_instance.CI-CD_instance : i.public_ip ]
}

