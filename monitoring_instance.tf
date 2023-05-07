resource "aws_instance" "monitoring" {
    ami= "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet_a.id

    user_data = data.template_file.monitoring_user_data.rendered

    security_groups = [aws_security_group.monitoring_sg.id]

    tags = {
        Name = "proj_1_monitoring"
    }

    #count = 2 #<- 2개 생성하고 싶을때.

}

resource "aws_eip" "monitoring_eip" {
    vpc = true

    instance = aws_instance.monitoring.id

    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "monitoring_user_data" {
    template = file("monitoring_user_data.sh")

    vars = {
        server_port = var.server_port
        prometheus_port = var.prometheus_port
        grafana_port = var.grafana_port
    }
}