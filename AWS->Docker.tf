provider "aws" {
  region = "eu-central-1"
}
resource "aws_instance" "my_ubuntu" {
  ami                    = "ami-015c25ad8763b2f11"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_SG.id]

  user_data = <<EOF
#!/bin/bash
sudo -i
1111
apt-get update
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
y
docker pull pozharn/testnode
docker run -d -p 3000:3000 pozharn/testnode
exit
EOF

  tags = {
    Name = "OpenVPN"
  }
}
resource "aws_security_group" "my_SG" {
  name        = "SG"
  description = "Test for SG"

  dynamic "ingress" {
    for_each = ["22", "80", "443", "943", "30000"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
