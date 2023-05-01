현황 : 
1. 테라폼 책보고 따라 만들어서 ALB에 ASG도 있지만, default vpc에서 만들었으며, 1티어다.

2. 블로그 하나를 보니까 vpc를 나눴지만 2티어며 ALB와 ASG가 없다.

3. AWS 강의 들은 곳에서는 3tier로 서비를 만들었는데 테라폼으로는 아직이다.

그래서 이거 3개를 다 합쳐볼 생각이다.


# step 1 blog 따라 만들기

참고 블로그
https://bosungtea9416.tistory.com/11


## provider.tf는 계정정보를 담고 있기에 push 하지 않음
