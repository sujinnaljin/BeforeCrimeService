# BeforeCrimeService

승강기 내 범죄 상황 예방 서비스

## Overview

영상 내 움직임 정도와 지속 시간을 판단하고 알림을 띄움 

## 메인 로직

1. 현재 화면과 이전 화면의 움직임을 비교
2. 움직임의 변화 정도에 따라 폭력적인 행동인가 판단
3. 폭력적인 행동이 일정 시간 지속되는가 판단
4. 긴급 상황으로 인식
5. CCTV 화면에 경고창 띄움이미지 분류



```java
//50프레임동안 움직임의 정도를 저장
int[] movementSumArr = new int[50]; 

//매 프레임마다 실행되는 함수
//최근 50 프레임 동안 얼마나 많은 프레임이 격렬한 움직임 기준치를 초과했는가
int movementCnt = 0;
for(int i = 0; i < 50 ; i++) {
  if(movementThreshold < movementSumArr[i]) {
    movementCnt++;
  }
}

if (movementCnt > 45) {
    //경고창 띄움
}
```



## Preview

![preview](https://media.giphy.com/media/LRBSHMmGb4zCrTo8b4/giphy.gif)



- 빨간점 :  움직임의 변화 (움직임이 격렬할 수록 점 많아짐)
- 초록 글씨 : 움직임의 크기 (움직임이 격렬할 수록 큰 값)
- 노란 그래프 : 초록색 값(`movementValue`)을 그래프로 표현한 것

## Develop Environment

개발 환경 : [프로세싱](<https://processing.org/>)(Processing)

사용 언어 : Java

## 환경 설정
- DetectRedcordMovement.pde : 프로세싱 실행 환경에서 attackUp.mp4를 코드(`.ped`)와 같은 depth의 data 디렉토리 안에 넣어야 함


