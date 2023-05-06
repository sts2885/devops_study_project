
resource "aws_subnet" "private_subnet_app_a" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.128/27"

    availability_zone = "us-east-1a"

    tags = {
        Name = "private_subnet_app_a"
    }
}

resource "aws_subnet" "private_subnet_app_c" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.160/27"

    availability_zone = "us-east-1c"

    tags = {
        Name = "private_subnet_app_c"
    }
}

resource "aws_subnet" "private_subnet_db_a" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.192/27"

    availability_zone = "us-east-1a"

    tags = {
        Name = "private_subnet_db_a"
    }
}

resource "aws_subnet" "private_subnet_db_c" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.224/27"

    availability_zone = "us-east-1c"
    
    tags = {
        Name = "private_subnet_db_c"
    }
}

#eip 달고 natgateway 설정
resource "aws_eip" "nat_ip" {
    vpc = true
    
    #lifecycle여기도 나오네
    #책을 읽고 하길 잘함.
    #이거 apply로 변경되면
    #변경이 아니라 삭제 -> 재생성이라서
    #재생성되는 도중 서비스 멈추면 안되니까
    #생성을 먼저 하고 삭제하라는 명령어임.
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_ip.id

    subnet_id = aws_subnet.public_subnet_a.id

    tags = {
        Name = "NAT_gateway"
    }
}

#private route table 생성
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.project1_vpc.id

    tags = {
        Name = "private_rt"
    }
}

resource "aws_route_table_association" "private_rt_association_app_a" {
    subnet_id = aws_subnet.private_subnet_app_a.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_app_c" {
    subnet_id = aws_subnet.private_subnet_app_c.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_db_a" {
    subnet_id = aws_subnet.private_subnet_db_a.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_db_c" {
    subnet_id = aws_subnet.private_subnet_db_c.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "private_rt_nat" {
    route_table_id = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
}