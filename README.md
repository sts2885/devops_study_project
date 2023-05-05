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

현재 pub-sub-a,c 만 씀
일단 연결을 생각하지 말고 
pri-sub-app-a,c pri-sub-db-a,c 도 똑같이 인프라 만들어
=> web was db 소프트웨어는 띄울 수 있으려나?...
=> web, was는 될거 같아.
=> db가 문제임 클러스터링 할 줄 몰라서
=> 누가 만들어 놓은 오픈소스 하나 없나? 가져다가 올리기만 하고 싶은데?
=> 검색 조금 해보니까 쿠버네티스를 쓰는 경우에도 DB를 스케일링 해야 될 필요가 있네

docker hub, github를 좀 찾아보자

일단 인프라 먼저

step 2-3
web, was, db를 각각 연결
=> 근데 db는 클러스터링은 생각하지 말자고
어짜피 쓸줄도 모르니까.

근데 잠깐, db도 asg를 붙여줘야 되나?
흠...
보통 rds 써버리니까. 이건 고려 안해도 되는 거 아닌가?
db는 인스턴스 그냥 1개만 올릴까?

app tier 에는 alb가 아니라

nlb를 붙여줘야 하는 듯

https://medium.com/awesome-cloud/aws-difference-between-application-load-balancer-and-network-load-balancer-cb8b6cd296a4


https://no-easy-dev.tistory.com/entry/AWS-ALB%EC%99%80-NLB-%EC%B0%A8%EC%9D%B4%EC%A0%90



=> alb를 못쓸건 없음
=> 문제는 alb 보다 nlb가 빠름
=> alb는 l7 단을 지원해서 http 통신이 가능하지만 비교적 느리고
=> nlb는 l4 까지만 지원해서 http 헤더를 못읽는 대신 비교적 빠르다.

was, db는 http 통신을 할 필요가 없어서 nlb가 더 어울린다.



Error: : health_check.matcher is not supported for target_groups with TCP protocol

nlb는 http 안씀 => tcp로 health check해야 되는데
안되는 버그가 있는 듯

https://github.com/hashicorp/terraform-provider-aws/issues/8305

깃허브 issue에서 제일 아래에 matcher와 path를 일부러
빈 String으로 둬라 라는 말대로 한번 해보겠음.

생성 -> pub instance 하나 들어가서 확인해봐야 함.

Error: creating ELBv2 network Load Balancer (terraform-app-tier-alb): InvalidConfigurationRequest: A load balancer cannot be attached to multiple subnets in the same Availability Zone 

멍청해서 private subnet에 az를 안넣었음
=> 안넣어도 돌아간다는걸 깨달았네 ㄷㄷ;;


│ Error: creating ELBv2 Listener (arn:aws:elasticloadbalancing:us-east-1:222170749288:loadbalancer/net/terraform-app-tier-alb/787b0e543abb8cf3): InvalidLoadBalancerAction: The action type 'fixed-response' is not valid with network load balancer

그냥 default_action 자체를 안넣어주면 될듯

│ Error: Insufficient default_action blocks                                                             │                                                                                                       │   on load_balancer_pri_app.tf line 10, in resource "aws_lb_listener" "app_tier_lb_listener_8080":     │   10: resource "aws_lb_listener" "app_tier_lb_listener_8080" {                                        │                                                                                                       │ At least 1 "default_action" blocks are required.

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

보니까 그냥 forward로 보내기 가 있네

redirection까지 있어서 원하면 강의에서 들은거 100퍼센트 다 구현할 수 있을듯...


nlb는 listener rule이 없다는 에러 떠서 주석 처리 하고 실행중


우여곡절 끝에 생성은 됐는데

들어가서 private ip로 curl 8080 을 날리면 날아가는데

elb dns name으로 날리면 안날라감(반응 없음)

보니까 lb target group에 health check 할 인스턴스가 하나도 없음

pri app asg에 pub-tg가 들어가 있었음

이제 target group은 healthy 뜸.

근데 여전히 curl은 안됨

반응이 없는게 전형적인 네트워크가 연결이 안됐을때의 반응인데

https://passwd.tistory.com/entry/Redmine-on-AWS-NLB-%EC%83%9D%EC%84%B1


이 사람 손으로 web - was를 nlb로 연결하는 작업함
=> internal을 쓰더라고?
=> 그리고 나도 손으로 만들어보려다가 facing internet을 했는데
너 igw 연결 안되어 있잖아 warning 뜸

아마 인터넷 통해서 통신 하려고 해서 안되는 거 아닐까?(추측)

테라폼 쓰다보니까 확실히 알겠다.
=> 그냥 modify 하는게 아니라
=> 배포전략에 따라서 생성 -> 연결 -> 삭제 의 순으로 수정을 해야 돼네
=> 수정 그냥 시켰더니 다른 곳에 연결되어있습니다 에러 같은게 발생하기도 하고
=> 100퍼센트 성공을 보장하지는 않네


성공했다~~~~

오늘도 억까를 이겨내고 성공했다아아아아~~~~

여세를 몰아서 db까지 생성만 딱 하고 오늘 마무리 하자

DB도 만들고 있는데 느끼는게

포트이름을 잘못쓴다던지 <- 이런 이름 잘못쓰는 휴먼 폴트가 엄청많이 일어난다.