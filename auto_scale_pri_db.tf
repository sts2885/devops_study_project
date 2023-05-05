resource "aws_launch_configuration" "db_lc" {
    image_id = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.db_instance.id]
    key_name = "DevOps_Study"

    user_data = <<-EOF
                #!/bin/bash
                echo "This is DB" > index.html
                nohup busybox httpd -f -p ${var.mysql_port}
                EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "db_asg" {
    launch_configuration = aws_launch_configuration.db_lc.name
    vpc_zone_identifier = [aws_subnet.private_subnet_db_a.id,
                            aws_subnet.private_subnet_db_c.id]
    target_group_arns = [aws_lb_target_group.db_lb_tg.arn]

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-db-nlp-example"
        propagate_at_launch = true
    }
}

