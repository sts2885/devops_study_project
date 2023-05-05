resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    vpc_id = aws_vpc.project1_vpc.id

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = var.health_check
        to_port = var.health_check
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
}

variable "health_check" {
    description = "The port ELB will use for Health check to instances"
    type = number
    default = 80
}

variable "ssh_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 22
}
