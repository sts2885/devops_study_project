resource "aws_launch_configuration" "app_lc" {
    image_id = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.app_instance.id]
    key_name = "DevOps_Study"

    user_data = <<-EOF
                #!/bin/bash
                echo "This is WAS" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "app_asg" {
    launch_configuration = aws_launch_configuration.app_lc.name
    vpc_zone_identifier = [aws_subnet.private_subnet_app_a.id,
                            aws_subnet.private_subnet_app_c.id]
    
    target_group_arns = [aws_lb_target_group.app_lb_tg.arn]
    health_check_type = "ELB"

    min_size=  2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-app-nlb-example"
        propagate_at_launch = true
    }
}