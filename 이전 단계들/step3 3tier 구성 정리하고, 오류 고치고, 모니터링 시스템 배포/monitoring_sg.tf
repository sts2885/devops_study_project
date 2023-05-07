/*
아무리 생각해도 security group만 모아 놓고, asg만 모아 놓고 이거 아니라고 생각함.

객체지향에서의 클래스 처럼
각 서비스 단위 혹은 각 구성요소 단위마다(web, was, db) 따로 폴더를 두고, sg, asg, elb 등 모아놔야지.

아무튼 monitoring 정도는 파일 하나에 몰아놔 보자.
*/

resource "aws_security_group" "monitoring_sg" {
    name = "monitoring-sg"
    vpc_id = aws_vpc.project1_vpc.id

    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = var.prometheus_port
        to_port = var.prometheus_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #myip로 해도 상관 없음
    }

    ingress {
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #myip로 해도 상관 없음
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "prometheus_port" {
    description = "Port for prometheus"
    type = number
    default = 9090
}

variable "grafana_port" {
    description = "Port for grafana"
    type = number
    default = 3000
}