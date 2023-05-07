resource "aws_lb" "web_lb" {
    name = "terraform-web-alb"
    load_balancer_type = "application"
    subnets = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_c.id]
    security_groups = [aws_security_group.alb.id]

    #원하면 access log를 s3에 남길 수 있는 옵션이 있음 => 테라폼 공식 document를 보면 있음
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.web_lb.arn
    port = 80
    protocol = "HTTP"

    #By default, return a simple 404 page
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"
    vpc_id = aws_vpc.project1_vpc.id

    #Allow inbound HTTP requests
    ingress {
        from_port = 80
        to_port = 80
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

#타겟 그룹
resource "aws_lb_target_group" "web_tg" {
    name = "terraform-pub-lb-tg"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = aws_vpc.project1_vpc.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

#이제 작성한 것들을 한군데로 묶어줌
resource "aws_lb_listener_rule" "asg" {
    #이부분이 aws 강의에서 rule edit에 들어가서 연필모양 눌러서
    #규칙 변경하고, 리디렉션 하고 route53 호스팅 영역 관리할때 봤던 부분임
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.web_tg.arn
    }
}

output "alb_dns_name" {
    value = aws_lb.web_lb.dns_name
    description = "The domain name of the load balancer"
}

