
#vpc 생성
resource "aws_vpc" "project1_vpc" {
    cidr_block = "10.1.0.0/16"

    tags = {
        Name = "project1_vpc"
    }
}
