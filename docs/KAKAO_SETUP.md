# 카카오 로그인 설정

## 1. Kakao Developers 앱 설정

- **카카오 로그인** → **활성화** ON
- **Redirect URI**에 `kakao0891301df18eee1e5221f7374cf1bb6d://oauth` 등록
- **플랫폼**: iOS/Android 추가 시 패키지명·번들 ID 등록

### Android: 키 해시 등록 (필수)

Android에서 카카오 로그인을 쓰려면 **키 해시**를 Kakao 콘솔에 등록해야 합니다.

1. [Kakao Developers](https://developers.kakao.com/console/app) → 해당 앱 → **앱 설정** → **플랫폼** → **Android** 추가/편집
2. **키 해시** 란에 아래 명령어로 얻은 값을 등록

**디버그 키 해시** (개발 중 테스트용):

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android 2>/dev/null | openssl sha1 -binary | openssl base64
```

**릴리스 키 해시** (배포용):  
사용 중인 릴리스 keystore로 위와 같이 `-alias`, `-keystore`, `-storepass`를 넣어 실행한 뒤 나온 값을 등록하면 됩니다.

- 키 해시는 **앱 코드에 넣지 않고**, Kakao Developers **플랫폼 설정**에만 등록합니다.

## 4. 동작 흐름 (현재 구현)

1. 앱 실행 → **로그인 화면** (카카오 로그인 버튼)
2. **카카오로 로그인** 탭 → 카카오톡 또는 카카오계정 로그인
3. 로그인 성공 시 **인증 코드**를 화면에 표시 (백엔드 전송은 보류)
4. **홈으로 이동** → 기존 홈 화면

나중에 백엔드 연동 시 이 인증 코드를 `POST /auth/kakao` body `{ "code": "인증코드" }` 로 보내면 됩니다.
