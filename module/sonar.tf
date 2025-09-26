resource "random_id" "force_recreate" {
  byte_length = 8
}
resource "aws_instance" "sonar" {
  ami           = var.sonar_ami_id
  instance_type = var.sonar_instance_type
  key_name      = var.sonar_key_name

  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public[0].id

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable docker
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user

              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              sudo mkdir -p /opt/sonarqube
              sudo tee /opt/sonarqube/docker-compose.yml > /dev/null <<EOL
              version: "3"
              services:
                sonarqube:
                  image: sonarqube:community
                  container_name: sonarqube
                  ports:
                    - "9000:9000"
                  environment:
                    - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
                  volumes:
                    - sonarqube_data:/opt/sonarqube/data
                    - sonarqube_extensions:/opt/sonarqube/extensions
                  restart: unless-stopped

              volumes:
                sonarqube_data:
                sonarqube_extensions:
              EOL

              cd /opt/sonarqube
              sudo /usr/local/bin/docker-compose up -d
              EOF
  tags = {
    Name = "hackaton-sonar"
    ForceCycle = random_id.force_recreate.hex
  }

}
