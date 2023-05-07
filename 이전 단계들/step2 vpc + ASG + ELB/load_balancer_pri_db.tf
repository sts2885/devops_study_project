resource "aws_lb" "db_lb" {
    name = "terraform-db-nlb"
    load_balancer_type = "network"

    internal = true

    subnets = [aws_subnet.private_subnet_db_a.id,
                aws_subnet.private_subnet_db_c.id]
}

resource "aws_lb_listener" "db_lb_listener" {
    load_balancer_arn = aws_lb.db_lb.arn
    port = 3306
    protocol = "TCP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.db_lb_tg.arn
    }
}

resource "aws_lb_target_group" "db_lb_tg" {
    name = "terraform-db-lb-tg"
    port = var.mysql_port
    protocol = "TCP"
    vpc_id = aws_vpc.project1_vpc.id

    health_check {
        path = ""
        protocol = "TCP"
        matcher = ""
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

output "db_lb_dns_name" {
    value = aws_lb.db_lb.dns_name
    description = "The domain name of the db tier nlb"
}