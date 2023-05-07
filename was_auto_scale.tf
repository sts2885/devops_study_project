resource "aws_launch_configuration" "was_lc" {
    image_id = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.was_sg.id]
    key_name = "DevOps_Study"

    user_data = data.template_file.was_user_data.rendered
    /* <<-EOF
                #!/bin/bash
                echo "This is WAS" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    */
    lifecycle {
        create_before_destroy = true
    }
}

data "template_file" "was_user_data" {
    template = file("was_user_data.sh")

    vars = {
        server_port = var.server_port
        node_exporter_port = var.node_exporter_port
    }
}

resource "aws_autoscaling_group" "was_asg" {
    launch_configuration = aws_launch_configuration.was_lc.name
    vpc_zone_identifier = [aws_subnet.private_subnet_was_a.id,
                            aws_subnet.private_subnet_was_c.id]
    
    target_group_arns = [aws_lb_target_group.was_lb_tg.arn]
    health_check_type = "ELB"

    min_size=  2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-was-nlb-asg"
        propagate_at_launch = true
    }
}