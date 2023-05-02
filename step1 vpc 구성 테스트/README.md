현황 : 
1. 테라폼 책보고 따라 만들어서 ALB에 ASG도 있지만, default vpc에서 만들었으며, 1티어다.

2. 블로그 하나를 보니까 vpc를 나눴지만 2티어며 ALB와 ASG가 없다.

3. AWS 강의 들은 곳에서는 3tier로 서비스를 만들었는데 테라폼으로는 아직이다.

그래서 이거 3개를 다 합쳐볼 생각이다.


# step 1 blog 따라 만들기

참고 블로그
https://bosungtea9416.tistory.com/11


## provider.tf는 계정정보를 담고 있기에 push 하지 않음


#따라치다가 느낀거지만, 아무리 봐도 igw를 route rule에 포함시키는 코드가 없음

#다른 블로그를 보면 분명히 있는데, 일단 이대로 실행시켜보고

#인스턴스 하나 켜서 인터넷 안되는거 확인 한 다음에 적용시켜보자


terraform 공식 document에 설명이 되어 잇음

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route.html

aws_route 리소스에 gateway_id에 igw의 id를 넣으면 됨


다 실행해서 정상작동 확인하고 destroy했는데 vpc만 안없어짐. 4분 넘게
기다려도 안되고 에러 뜸
=> 손으로 지우면 지워질 거 같은데?

손으로 지워지니 지워짐

https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/373

unable to destroy vpc

다른사람들도 비슷한듯

근데 뭐 이것뿐이면 굳이 안지워 져도 상관없긴 함