 # Portfolio Froent-end Using Flutter

## 📝 개요

이 프로젝트는 개인 포트폴리오 작품으로, 태그 기반의 인원 모집 앱을 개발한 프로젝트입니다. 사용자는 자신이 필요한 인원과 조건을 태그로 설정하여 모집할 수 있고, 모집에 참여하고자 하는 사람들은 해당 태그를 기반으로 자신에게 맞는 모집 글을 쉽게 찾을 수 있습니다. 이를 통해 보다 효율적으로 팀을 구성하고, 필요한 사람들을 모집할 수 있는 환경을 제공합니다.

<br />

## 화면 구성
|회원가입 - 이메일 인증 1|회원가입 - 이메일 인증 2|비밀번호 찾기 - 이메일 인증 1|비밀번호 찾기 - 이메일 인증 2|
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/b407367f-2804-4a08-aa2e-d84acf8a4d92"> | <img src="https://github.com/user-attachments/assets/43164d78-2134-46ab-8cd9-7bcbeec31347"> | <img src="https://github.com/user-attachments/assets/419bec2c-ce11-4a89-85a7-3f521a473743"> | <img src="https://github.com/user-attachments/assets/4bb43d03-f851-49db-b8bd-503effb2eb98"> |

|로그인 화면|소셜 로그인 - 구글|소셜 로그인 - 카카오|소셜 로그인 - 네이버|
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/4084c6b5-2236-4868-b35c-57963904d25b"> | <img src="https://github.com/user-attachments/assets/58422c43-f5e2-4d9f-ac94-f85bc4366374"> | <img src="https://github.com/user-attachments/assets/231f3720-1d95-41ca-a093-55b1571df4aa"> | <img src="https://github.com/user-attachments/assets/ad0759ad-afc0-41fc-ada6-49bd63f2c0e3"> |

|다중 기기 관리 1|다중 기기 관리 2|다중 기기 관리 3|서버 - 스케줄링|
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/32046820-455b-4753-bad5-728a0a8c4672"> | <img src="https://github.com/user-attachments/assets/3757ddfb-f6f4-4083-a6a1-c656dd79d51e"> | <img src="https://github.com/user-attachments/assets/e37f157b-9ec2-410e-8192-a0729a740e6c"> | <img src="https://github.com/user-attachments/assets/09249b93-2132-4ba3-a362-b75d948c4fd5"> |
<br />

## 🛠 기술 스택

![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)

## 💡 주요 기능
- **서버 통신** : Dio를 사용하여 서버와 HTTP 통신
- **UI 데이터 관리** : Provider를 사용하여 UI 상태 관리
- **이메일 인증** : 일반 사용자의 회원가입 및 비밀번호 찾기 시 이메일 인증을 통해 보안을 강화
- **소셜 로그인** : Google, Kakao, Naver 소셜 로그인을 SDK를 통해 구현
- **다중 기기 관리** : 하나의 계정으로 여리 기기에서 동시에 로그인할 수 있게 지원하며, JWT를 이용해 각 기기의 세션을 관리

## 💻 실행 방법

### 1. **서버 설치**
[서버 설치](https://github.com/WXXZIN/Portfolio-BE.git)

### 2. **클라이언트 설치**

```bash
$ git clone https://github.com/WXXZIN/Portfolio-FE-Flutter.git
```

### 3. **소셜 로그인 설정**
Google, Kakao, Naver 각각의 소셜 로그인 등록<br />
IOS : com.wxxzin.clientFlutter<br />
Android : com.wxxzin.client_flutter<br />

android/app 경로에 google-services.json 추가

<br />

ios/Runner/info.plist 수정
```bash
...
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
    <string>com.googleusercontent.apps.[IOS_CLIENT_ID]</string>
    </array>
  </dict>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
    <string>kakao[네이티브 앱 키]</string>
    </array>
  </dict>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
    <string>[Naver UrlScheme]</string>
    </array>
  </dict>
</array>
...

...
<key>naverServiceAppUrlScheme</key>
<string>[Naver UrlScheme]</string>
<key>naverConsumerKey</key>
<string>[Naver ConsumerKey]</string>
<key>naverConsumerSecret</key>
<string>[Naver ConsumerSecret]</string>
<key>naverServiceAppName</key>
<string>[Naver ServiceAppName]</string>
...
```

<br />
ios/Runner/GoogleService-info.plist 추가
<br />
<br />

ios/Pods/naveridlogin-sdk-ios/NaverThirdPartyLogin.xcframework/ios-arm64/NaverThirdPartyLogin.framework/Headers 수정 <br />
[동일]/ios-arm64_x86_64-simulator/NaverThirdPartyLogin.framework/Headers 수정

```bash
#define kServiceAppUrlScheme    @"thirdparty20samplegame"

#define kConsumerKey            @"jyvqXeaVOVmV"
#define kConsumerSecret         @"527300A0_COq1_XV33cf"
#define kServiceAppName         @"네이버 아이디로 로그인"
```

### 4. **.env 작성**
프로젝트 루트 경로에 .env 파일 생성

```bash
KAKAO_NATIVE_APP_KEY=
NAVER_CLIENT_ID=
NAVER_CLIENT_SECRET=
NAVER_CLIENT_NAME=
```
