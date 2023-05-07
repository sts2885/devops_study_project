이번 readme까지는 폴더에 들어가고

main readme는 설명서가 들어가야 할듯
-> 읽는 사람이 보기 힘듦


현황 : 
1. 테라폼 책보고 따라 만들어서 ALB에 ASG도 있지만, default vpc에서 만들었으며, 1티어다.

2. 블로그 하나를 보니까 vpc를 나눴지만 2티어며 ALB와 ASG가 없다.
(devops_study 예제 2-5 부분에서 부터 시작)

3. AWS 강의 들은 곳에서는 3tier로 서비스를 만들었는데 테라폼으로는 아직이다.

그래서 이거 3개를 다 합쳐볼 생각이다.

여기에는 문제 인식, 문제 해결 과정, trouble shooting 과정을 모두 기입하겠다.


# step 1 blog 따라 만들기 #clear

# step 2 기존 코드에 vpc 올리기

# step 3 모니터링 시스템 배포

모니터링 시스템 배포에 앞서 그 동안 jira와 github를 따로따로 쓰고 있었는데 연동하면,

branch commit 내역도 볼 수 있고

프로젝트 진척도를 좀 확인해 볼 수 있지 않을까 싶어서 연동 테스트를 먼저 진행했다.

jira에 커밋 로그를 남겨볼거다.
=> 남기긴 했는데, jira를 통한 배포 과정을 익히기 전까지는 생각만큼 쓸모있지는 않은듯, 보고서 차트가 나오는 것도 아니고.

일단은 모니터링 시스템을 배포하겠다.

기본 구조는 이렇다.
- terraform으로 보안그룹을 추가해서 배포를 한다.

- 어디까지 올릴지가 관건이네

솔직히 미들웨어 하나도 설치 안하고

1. prom, graf, node-ex까지만 올리면 1시간안에도 끝난다.

2. apache, tomcat, mysql ex 올리는건… middle ware 설치가 되어야 되는데?

3. Thanos는 시간이 얼마나 걸릴지 잘 모른다.

4. SMS도 aws 연결이면 또 모르긴 해. 

소 분류가 끝났으면 시간 될때까지 천천히 만들어보자
우선 1 부터다.

step 3-1 인프라 생성 - prom graf node-ex
-public : + 모니터링 infra 1대(오토스케일 없이 1대 코드 추가)
          +  web 2대 asgelb
-app : + was 2대 asgelb
-db : + db 2대 asgelb

후 모니터링 서버 접속해서
- shell script file로 prom, graf 설치
- shell script와 key를 가지고 app, db 에 node ex 설치
=> 라고 생각해봤는데 이정도면 그냥 user data에 넣는걸로 끝나지 않냐? 왜 복잡하게 돌아가?
=> 그치, mutable하게 관리하거나, 중간에 down 안시키고 변경할때 정도나 필요하지 (그나마도 무중단 배포 하면 필요 없음.)

폴더별로 깔끔하게 나누고 싶은데 terraform은 folder가 모듈임
모듈 개념 깔끔하게 잡고, 하위 폴더 전체 실행 같은거 할 줄 알게 될때까지 일단 정리는 보류


userdata만 쉘스크립트로 해두고
node ex, apache만 실행 시켜두고

모니터링 서버 들어가서 프로메테우스, 그라파나만 딱 설치하자
=> terraform에서 output으로 인스턴스들 ip 못 모으나?



# issue 1
asg를 통해 instance를 생성했기 때문에 output으로 ip를 확인 할 수 없음.
프로메테우스에 instance ip를 넣어줘야 하기 때문에 필요함.

그래서 boto3로 직접 가져올까 했지만, 방법은 다 있네

https://github.com/hashicorp/terraform-provider-aws/issues/511

테라폼에서 공식적으로 지원하는 포맷이 아니지만

여기 보니까 유저 한명이 신박한 방법 하나를 발견함

lexsys27이 댓글을 달았습니다. 2018년 6월 29일

data "aws_instances" "workers" {
  instance_tags {
    Name = "lexsys-eks-asg"
  }
}

output "private-ips" {
  value = "${data.aws_instances.workers.private_ips}"
}

output "public-ips" {
  value = "${data.aws_instances.workers.public_ips}"
}

Outputs:

private-ips = [
    10.0.0.75,
    10.0.1.87
]
public-ips = [
    52.44.215.211,
    54.153.70.110
]

print_private_ips.tf를 만들었음.

proj_1_monitoring

terraform-pub-alb-example
terraform-app-nlb-example
terraform-db-nlp-example


이렇게 얻은 ip를 넣고 실행하면 끝이었는데 docker가 설치가 안되었다네? 왜?
아직 설치 중인가?

install 에 -y들어가야 하고
app 뭐시기에 --yes들어가야 함

db_lb_dns_name = "terraform-db-nlb-423dc25a0ce3855e.elb.us-east-1.amazonaws.com"
monitoring_ip = "52.71.213.66"   
was_lb_dns_name = "terraform-was-nlb-1e187b42d168e448.elb.us-east-1.amazonaws.com"
web_alb_dns_name = "terraform-web-alb-978553582.us-east-1.elb.amazonaws.com"

하아.. 이번엔 web alb가 안되는데? ㅋㅋㅋ
이거 할일 왜 적어보인다고 했지? ㅋㅋㅋㅋ


개고생해서 node ex 배포는 성공함
근데 alb는 뭐임? ㅋㅋㅋ
다른거 다 되는데 alb만 안되네?
private ip 8080 포트로도 되는데?

echo """
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 0.0.0.0:9090


  - job_name: 'node_exporter'
    static_configs:
      - targets:
        - "10.1.0.231:9100"
        - "10.1.0.212:9100"
        - "10.1.0.151:9100"
        - "10.1.0.185:9100"
        - "10.1.0.81:9100"
        - "10.1.0.110:9100"
""" | tee /home/ubuntu/prometheus.yml

docker restart prometheus

monitoring user data에는 grafana prom 설치만 해놓고(prometheus job만 남기고)
다 연결 된 후에 들어가서 입력하고 재실행 해주면 됨



같은 subnet 끼리는 apache는 접근되는데
node exporter는 안되고

다른 subnet은 apache도 안되네 이유 분석해야 됨 아 손목아프니까 일단 쉬자

테스트 안하고 ㅏㅎㄴ번에 너무 바꿔서 그래

lb접근은 다됨

monitoring은 --yes 안넣었는데 돼고
나머지는 접근이 안된다?
=> web은 docker 설치ㅏㄱ 안됨 --yes떄문인가?

야 구글 curl 이 안되는데? nat 연결된거 맞음?
httpd는 기본적으로 있는건가 본데?
이게 문제인듯 일단 좀 쉬자
destroy

몇번 돌리다가 깨달았는데 output으로

private ip 띄우는거
=> 이거 요청 자체는
=> name이 같은거 의 private ip를 출력해라 기 때문에

아직 생성 덜 되서 private ip 없는 상태일때
output이 출력되면 리스트가 비어서 나옴

output 보고 싶어서 apply 한번 더 하니까

모니터링 서버는 지우고 나시 만든다?

하기 싫으면 plan 만 쳐서 ip만 확인해야 할듯

엥? 다시 만들고 db 인스턴스 들어가니까 구글 curl 되는데?

node exporter도 깔려있는데?

중간에 destroy가 아니라 modify를 했던건가?


같은 티어에 있던 web서버가 오히려 9100 접근이 안됨

apache는 됐고 들어가 보니까  docker 설치가 안되어 있음

구글 컬도 안됨

eip가 연결이 되어야 인터넷이 되는데?
인터넷 게이트웨이 연결 되어 있는데도?

이게 원래는 LB 통해서 연결 되기 때문에 서비스 하기 위해서
다른 장치가 필요 없고,

보통 web 서버 도 private 영역에 만드는 모양.

근데 지금은 인터넷을 써야 하니까...

얘도 nat 달아줘야 겠네

public routing에 같은 nat의 routing 규칙을 달아주자

좆됐네 ㅋㅋ 안되는데?

애초에 웹 서버 자체가 여기에 올라오면 안되나?

아니 기존처럼은 쓸 수 있는데 뭘 다운로드 받거나 하는 건 안되나 본데?

그렇구나...

web was db 모두 private subnet에 둔다.
https://potato-yong.tistory.com/69

이 당연한걸 나는 클라우드 업체 입사하고 2달동안 몰랐다.

왜냐면 우리 회사 일은 특수 아키텍처를 써서 web이 있는 서브넷이 public + private의 역할을 동시에 한다.

그래서 모든 3tier 아키텍처가 다 이런줄 알았다.

어쩔까?
1. private 서브넷을 하나 더 만든다.
2. 그냥 2티어 구성을 한다.

=> 당연히 1번이지

진짜 다 만들었는데

node exporter health checking도되는데
왜 갑자기 web alb가 안되냐?

일단 피곤해서 머리 안돌아가니까 내일 마저 하자

내일은 마저 끝내고 추가 작업 하고 싶으면 타노스 정도나 좀 만지고

문서화 하고 정리해서 jira, github, blog 작성하자


나 안되는 이유 안거 같아.

=> ALB : 외부 ALB와 내부 ALB로 나뉨
=> 내부ALB는 private ip만 쓰고 내부 통신만 되고
=> 외부 ALB는 인터넷이 연결되서 public ip가 달려야 함
=> 근데 지금 Web tier를 private으로 밀어 넣는 바람에
=> igw가 안달리고, NAT가 달림
=> 단방향이라 안에서 나가는 것만 되고 밖에서 들어오는게 안됨
=> 이거 아마 내 alb로 바꾸거나, alb 위치만(asg는 그대로 두고)
바꾸면 될꺼 같아




db_lb_dns_name = "terraform-db-nlb-06666bd7e7991201.elb.us-east-1.amazonaws.com"
db_private_ips = tolist([])
monitoring_ip = "52.203.56.113"
was_lb_dns_name = "terraform-was-nlb-6054bea8c8eef84c.elb.us-east-1.amazonaws.com"
was_private_ips = tolist([])
web_alb_dns_name = "terraform-web-alb-931314618.us-east-1.elb.amazonaws.com"
web_private_ips = tolist([])


~ db_private_ips   = [
  + "10.1.0.239",
+ + "10.1.0.212",
+ ~ was_private_ips  = [
  + "10.1.0.175",
+ + "10.1.0.149",
+ ~ web_private_ips  = [
  + "10.1.0.82",
+ + "10.1.0.104",





echo """
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 0.0.0.0:9090

  - job_name: 'node_exporter'
    static_configs:
      - targets:
        - "10.1.0.239:9100"
        - "10.1.0.212:9100"
        - "10.1.0.175:9100"
        - "10.1.0.149:9100"
        - "10.1.0.82:9100"
        - "10.1.0.104:9100"
""" | tee /home/ubuntu/prometheus.yml

docker restart prometheus


이제 github readme 설명을 위해 필요한것

설계도
- 3tier (alb 위치 조심해서)
- monitoring 서버
- user data file
- github 주소
- 최종 결과물 스크린샷


개요

전체 프로젝트
=> 테라폼 - 쿠버네티스 - 젠킨스 - 서비스 1종류 이상

phase 1. 테라폼으로 인프라 생성하기


실행법
=> terraform 설치
=> git clone
=> terraform provider 채워 넣고
=> terraform init
=> terraform plan
=> terraform apply



