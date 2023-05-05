현황 : 
1. 테라폼 책보고 따라 만들어서 ALB에 ASG도 있지만, default vpc에서 만들었으며, 1티어다.

2. 블로그 하나를 보니까 vpc를 나눴지만 2티어며 ALB와 ASG가 없다.

3. AWS 강의 들은 곳에서는 3tier로 서비스를 만들었는데 테라폼으로는 아직이다.

그래서 이거 3개를 다 합쳐볼 생각이다.

여기에는 문제 인식, 문제 해결 과정, trouble shooting 과정을 모두 기입하겠다.


# step 1 blog 따라 만들기 #clear

# step 2 기존 코드에 vpc 올리기

이거도 금방끝나는 작업일듯 -> 둘이 합치기만 하면 끝임
=> 라고 생각했는데 subnet만 바꿔 주면 될거 같은데 좀 복잡하네?


한번에 하려니까 생각보다 복잡한거같아.

중간 단계들로 나누자

step 2-1

3티어 나눴지만 마치 1티어인것처럼 만들자
=> 이러면 기존이랑 똑같다고 생각하고 subnet id만 바꾸면 되겠지?

변경점 : terraform aws_autoscaling_group에서
vpc_identifier 부분에 subnet id가 리스트로 들어감
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

설계도 보고 콘솔에서, 코드 만들수 있나 해보자

=> 다 하고 설계도 그려봤는데
=> 실제 콘솔에서 하는 거랑 다른데? 코드는 ALB랑 ASG가 직접 연결이 안되어 있고 lb target group정도가 ASG에서 가지고 있다 정도만 있는데?
=> 콘솔에서는 직접 연결함


왜 연결이 될까에 대해서 책에서 설명이 한번 되어 있음

AWS first-class integration 덕분에 된다고 하는데, 이렇게 만들면 콘솔에서는 안만들어지지 않냐? 아무튼.
두개를 각자 따로 만들고 위에 저거로 연결 한다는 모양임

Working with AWS service integrations for HTTP APIs

amazon.com
https://docs.aws.amazon.com › latest › developerguide
A first-class integration connects an HTTP API route to an AWS service API. When a client invokes a route that's backed by a first-class integration, API ...

아아~ asg를 보니까 기존 로드 밸런서에 연결 항목에
로드 밸런서 대상 그룹에서 선택 이라고 있네
여기에 target group의 arn이 들어가면 연결을 해주는 구조네


발생한 에러 핸들링 1.

security group이 vpc에 링크되어야 하나봄
지금까지는 default에 넣어서 그런지 지정 안해줘도 들어가 졌는데
=> 이젠 해야 되나 봄

security group에 vpc id를 넣어주면 끝임
vpc_id      = aws_vpc.main.id

제대로 만들어지고 서버도 배포 완료됨
서브넷도 정상적으로 만들어지고, nat도. 

신기했던점. 진짜 콘솔이랑 100퍼센트 똑같구나
resource "aws_lb_listener_rule" "asg" 
    #이부분이 aws 강의에서 rule edit에 들어가서 연필모양 눌러서
    #규칙 변경하고, 리디렉션 하고 route53 호스팅 영역 관리할때 봤던 부분임
    


step 2-2

2번째, 3번째 티어 위치에 같은 소프트웨어 똑같이 배포
=> 이후 둘이 연결

step 2-3
web, was, db를 각각 연결
=> 근데 db는 클러스터링은 생각하지 말자고
어짜피 쓸줄도 모르니까.