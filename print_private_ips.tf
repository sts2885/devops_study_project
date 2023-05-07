
data "aws_instances" "web_workers" {
    instance_tags = {
        Name = "terraform-web-alb-asg"
    }
}

data "aws_instances" "was_workers" {
    instance_tags = {
        Name = "terraform-was-nlb-asg"
    }
}

data "aws_instances" "db_workers" {
    instance_tags = {
        Name = "terraform-db-nlb-asg"
    }
}

output "web_private_ips" {
    value = "${data.aws_instances.web_workers.private_ips}"
}

output "was_private_ips" {
    value = "${data.aws_instances.was_workers.private_ips}"
}

output "db_private_ips" {
    value = "${data.aws_instances.db_workers.private_ips}"
}

output "monitoring_ip" {
    value = aws_eip.monitoring_eip.public_ip
}