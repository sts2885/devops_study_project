resource "aws_lb" "was_lb" {
    name = "terraform-was-nlb"
    load_balancer_type = "network"

    #공식 문서에 false로 하라고 되어 있었는데
    #igw 가 아니라 nat가 연결되어있어서 사설 ip로 통신해야 할듯
    internal = true

    #공식 테라폼 문서에 보니까 nlb는 security group을 넣는 항목이 없다.
    subnets = [aws_subnet.private_subnet_was_a.id, 
                aws_subnet.private_subnet_was_c.id]
}

resource "aws_lb_listener" "was_lb_listener" {
    load_balancer_arn = aws_lb.was_lb.arn
    port = 8080
    protocol = "TCP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.was_lb_tg.arn
    }
}

/*
resource "aws_security_group" "app_tier_nlb" {
    name = "terraform-app-tier-nlb"
    vpc_id = aws_vpc.project1_vpc.id

    #Allow inbound 8080
    ingress {
        from_port = 8080
        to_port = 8080
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
*/

#타겟 그룹
resource "aws_lb_target_group" "was_lb_tg" {
    name = "terraform-was-lb-tg"
    port = var.server_port
    protocol = "TCP"
    vpc_id = aws_vpc.project1_vpc.id

    health_check {
        #path = "/"
        path = ""
        protocol = "TCP"
        #matcher = "200"
        matcher = ""
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

/*
resource  "aws_lb_listener_rule" "app_tier_lb_listener_rule" {
    listener_arn = aws_lb_listener.app_tier_lb_listener_8080.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_tier_lb_tg.arn
    }
}
*/

#dns name이 있냐?
output "was_lb_dns_name" {
    value = aws_lb.was_lb.dns_name
    description = "The domain name of the was tier nlb"
}




