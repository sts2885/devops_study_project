
#subnet 생성
resource "aws_subnet" "public_subnet_a" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.0/27"

    availability_zone = "us-east-1a"

    tags = {
        Name = "public_subnet_a"
    }
}

resource "aws_subnet" "public_subnet_c" {
    vpc_id = aws_vpc.project1_vpc.id
    cidr_block = "10.1.0.32/27"

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

#따라치면서 느낀거지만, 아무리 봐도 igw를 route rule에 포함시키는 코드가 없음

#다른 블로그를 보면 분명히 있는데, 일단 이대로 실행시켜보고
#인스턴스 하나 켜서 인터넷 안되는거 확인 한 다음에 적용시켜보자

#인스턴스 켜서 안되는거 확인함. 손으로 연결하면 바로 되는데 일단 테라폼 코드를 짜보자

resource "aws_route" "public_rt_igw" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project1_igw.id
}