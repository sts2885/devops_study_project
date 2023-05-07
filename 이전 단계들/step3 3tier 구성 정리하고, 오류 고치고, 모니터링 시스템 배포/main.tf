resource "aws_security_group" "public_sg" {
    name = "terraform-pub-instance"
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

    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
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

resource "aws_security_group" "web_sg" {
    name = "terraform-web-sg"
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

    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
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

resource "aws_security_group" "was_sg" {
    name = "terraform-was-sg"
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

    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
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


resource "aws_security_group" "db_sg" {
    name = "terraform-db-sg"
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

    ingress {
        from_port = var.mysql_port
        to_port = var.mysql_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
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

variable "mysql_port" {
    description = "The port for mysql connection"
    type = number
    default = 3306
}

variable "node_exporter_port" {
    description = "Port for node exporter"
    type = number
    default = 9100
}