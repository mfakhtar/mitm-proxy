#Add Provider Block
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}


#Add EC2 Block
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "guide-tfe-md" {
  ami                    = "ami-0f8ca728008ff5af4"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.guide-tfe-es-sg.id]
  key_name               = aws_key_pair.ssh_key_pair.key_name

  root_block_device {
    volume_size = "10"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get -y install mitmproxy
  mitmproxy
  EOF

  tags = {
    Name = var.unique_name
  }
  depends_on = [
    aws_key_pair.ssh_key_pair
  ]

}


resource "null_resource" "ssh_connection" {
  provisioner "remote-exec" {
    inline = ["mitmproxy"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${aws_key_pair.ssh_key_pair.key_name}.pem")
      host        = aws_eip.bar.public_dns
    }
  }

  depends_on = [
    aws_eip.bar
  ]
}

