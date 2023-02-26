resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = var.generated_key_name
  #key_name   = var.key_name
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name        = "${var.app_name}-aws_key_pair"
    Environment = var.app_environment
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ./${var.generated_key_name}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 ./${var.generated_key_name}.pem"
  }
}

resource "aws_instance" "mysql_instance" {
  instance_type           = var.instance_type
  ami                     = var.ami
  subnet_id               = aws_subnet.private_subnet.id
  security_groups         = [aws_security_group.security_group.id]
  key_name                = aws_key_pair.ssh.key_name
  private_ip              = var.db_private_ips
  disable_api_termination = false
  ebs_optimized           = false  
  
  root_block_device {
    volume_size = "8"
  }

  tags = {
    Name        = "${var.app_name}-mysql_instance"
    Environment = var.app_environment
  }
}

resource "aws_instance" "bastion_instance" {
  instance_type           = var.instance_type
  ami                     = var.ami
  subnet_id               = aws_subnet.public_subnet.id
  security_groups         = [aws_security_group.security_group.id]
  key_name                = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized           = false   
 
  root_block_device {
    volume_size = "8"
  }

  depends_on = [aws_instance.mysql_instance, ]
  
  tags = {
    Name        = "${var.app_name}-bastion_instance"
    Environment = var.app_environment
  } 
}

resource "null_resource" "configuration_of_instances" {
  provisioner "local-exec" {
    command = "echo '[mysql]\nserver1 ansible_host=${aws_instance.mysql_instance.private_ip}\n[mysql:vars]\nansible_ssh_user=ubuntu\nansible_ssh_private_key_file=./${var.generated_key_name}.pem' > hosts.txt"
  }
  provisioner "file" {
    source      = "../absible"
    destination = "/home/ubuntu/"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_eip.eip_bastion.public_ip
      private_key = file("./${var.generated_key_name}.pem")
    }
 } 
  provisioner "remote-exec" {
    inline = ["chmod 400 ./${var.generated_key_name}.pem", "sudo apt update -y", "sudo apt install ansible -y", "ansible-galaxy collection install community.mysql", "export ANSIBLE_HOST_KEY_CHECKING=False", "ansible-playbook ./p_book.yml -i ./hosts.txt"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_eip.eip_bastion.public_ip
      private_key = file("./${var.generated_key_name}.pem")
    }
  }
    depends_on = [aws_instance.bastion_instance, aws_instance.mysql_instance, ]
}

resource "aws_cloudwatch_log_group" "log-group" {
  name           = "${var.app_name}-logs"
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name           = "${var.app_name}_ecs_cluster"
}

data "template_file" "env_vars" {
  template       = file("env_vars.json")
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.app_name}_task_definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "tsv1982/petclinic_01",
    "memory": ${var.fargate_memory},
    "name": "${var.app_name}",
    "networkMode": "awsvpc", 
    "environment": ${data.template_file.env_vars.rendered},
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "${var.app_name}"
        }
      },
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.host_port}
      }
    ]
  }
]
DEFINITION
 depends_on               = [aws_instance.bastion_instance, aws_instance.mysql_instance,]
 execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
 task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "service" {
  name            = "${var.app_name}_service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.task_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.security_group.id]
    subnets          = aws_subnet.public_subnet.*.id
    assign_public_ip = true
  }
}
