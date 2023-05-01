
#subnet 생성
resource "aws_subnet" "public_subnet_a" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.0/26"

    availability_zone = "us-east-1a"

    tags = {
        Name = "public_subnet_a"
    }
}

resource "aws_subnet" "public_subnet_c" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.64/26"

    availability_zone = "us-east-1c"

    tags = {
        Name = "public_subnet_c"
    }
}

#igw 생성
resource "aws_internet_gateway" "project1_igw" {
    vpc_id = aws_vpc.project1_vpc.id

    tags = {
        Name = "project1_igw"
    }
}

#route table 생성
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.project1_vpc.id

    tags = {
        Name = "public_rt"
    }
}

#서브넷을 route table에 연결
resource "aws_route_table_association" "public_rt_association_a" {
    subnet_id = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_associatiion_c" {
    subnet_id = aws_subnet.public_subnet_c.id
    route_table_id = aws_route_table.public_rt.id
}