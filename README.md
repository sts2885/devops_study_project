# Project 1 Terraform으로 3tier 구성하고 monitoring system 띄우기

프로젝트 해설 블로그 : 비밀번호 있음
https://cherry-blossome-in-march.tistory.com/12

개요

전체 프로젝트 목표
=> 테라폼 - 쿠버네티스 - 젠킨스 - 서비스 1종류 이상

phase 1. 테라폼으로 인프라 생성하기

실행법
1. terraform 설치
2. git clone
3. terraform provider 채워 넣고
4. terraform init
5. terraform plan
6. terraform apply
7. ip 확인하기
8. prometheus ip 집어넣기
9. grafana 연결하기
10. dash board import


1. Terraform을 설치한다. (다른 블로그를 참고 하면 좋다.)
https://may9noy.tistory.com/422
   
2. git clone https://github.com/sts2885/devops_study_project.git

3. terraform provider 채워 넣기

provider_example.tf를 열고

profile에 본인 계정의 iam_user_name을 입력하고
access_key와 secret_key 를 채워넣으면 끝이다.

4. terraform init
5. terraform plan
6. terraform apply
을 진행하면 인프라는 생성 완료

7. ip 확인하기
Terraform에서는 생성된 인스턴스의 ip 등을 볼 수 있는 기능이 있다. 다만 이건 resource에서 직접 지정해서 만든 인스턴스에 국한되며,
ASG가 생성한 인스턴스는 Terraform이 직접 만든게 아니라 정보가 저장되어 있지는 않다.
이에 대한 우회법의 한 종류를 terraform github의 issue에서 얻었다.
https://github.com/hashicorp/terraform-provider-aws/issues/511

이를 참고해 print_private_ips.tf 에는 auto scaling group을 통해 생성된 인스턴스들의 ip를 출력하는 output 코드를 작성했다.
근데 여기에는 문제가 하나 있는데 terraform은 목표한 인프라 생성이 끝나면 바로 output을 출력하는데
이때는 아직 인스턴스들에 private ip가 제대로 부여되지 않은 모양이다.
근데 terraform은 이걸 기다려야 될 이유가 없으므로 그냥 빈 리스트를 출력해버린다.


## ALB, NLB의 domain name 과 EIP를 부여한 monitoring server의 ip는 잘 출력되지만, 인스턴스들의 private ip는 비어있다.
ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
db_lb_dns_name = "terraform-db-nlb-06666bd7e7991201.elb.us-east-1.amazonaws.com"
db_private_ips = tolist([])
monitoring_ip = "52.203.56.113"
was_lb_dns_name = "terraform-was-nlb-6054bea8c8eef84c.elb.us-east-1.amazonaws.com"
was_private_ips = tolist([])
web_alb_dns_name = "terraform-web-alb-931314618.us-east-1.elb.amazonaws.com"
web_private_ips = tolist([])
ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

아직 100퍼센트 해결법은 잘 모르겠다. 그냥 위 링크한 이슈에서 다른 유저들이 쓴 방법을 쓰면 될 수 도 있겠다.
(하지만 이게 제일 간단했으니까...)

이에 대한 간단한 해결책은 그냥 terraform apply를 한번 더 입력하면

~ db_private_ips   = [
  + "10.1.0.239",
+ + "10.1.0.212",
+ ~ was_private_ips  = [
  + "10.1.0.175",
+ + "10.1.0.149",
+ ~ web_private_ips  = [
  + "10.1.0.82",
+ + "10.1.0.104",

하단에 private ip가 표기될거다.(이때쯤이면 인스턴스 생성이 끝났을 테니까.)

그리고 apply 하시겠습니까? 는 no를 입력해라 (apply 일어나면 monitoring server가 삭제되고 새로 생성된다.)


8. prometheus ip 집어넣기
monitoring 서버에는 이미 prometheus docker 가 설치되어 있으니까
/home/ubuntu/prometheus.yml 파일을 수정하고 다시 실행해준다.(아래 명령어에 ip를 넣고 복붙하면 된다.)

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

9.  grafana 연결하기
10. dash board import

제 블로그를 참고해주신다면 감사하겠습니다.(그냥 들어가서 datasource만 추가해주면 됩니다.)
https://cherry-blossome-in-march.tistory.com/5

