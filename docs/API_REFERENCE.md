# Scenely Backend API 참조

> Backend: [scenely_server](https://github.com/LayKim2/scenely_server) (FastAPI, Python)  
> Flutter 앱에서 API 연동 시 이 문서를 참조하세요.

---

## 1. 백엔드 구조 요약

- **스택**: FastAPI, Uvicorn, PostgreSQL, Redis, Celery, AWS S3, Google Gemini/Transcribe, yt-dlp
- **실제 진입점**: `app/main.py` (루트 `main.py`는 스텁)
- **실행**: Docker Compose 시 API는 **포트 8000**, CORS `allow_origins=["*"]`
- **인증**: 대부분 API가 **JWT 필수** (`Authorization: Bearer <token>`). 카카오 로그인으로 토큰 발급

---

## 2. API 엔드포인트 정리

### 인증 (`/auth`)

| 메서드 | 경로 | 설명 | 요청/응답 |
|--------|------|------|------------|
| POST | `/auth/kakao` | 카카오 인증 코드로 로그인 | **Body:** `{ "code": "카카오인증코드" }` → **응답:** `{ accessToken, user: { id, email?, nickname?, profileImage? } }` |
| GET | `/auth/me` | 현재 로그인 유저 정보 | **Header:** `Authorization: Bearer <token>` → **응답:** `{ id, email?, nickname?, profileImage? }` |

### 미디어 소스 (`/media`) — **모두 인증 필요**

| 메서드 | 경로 | Body | 응답 |
|--------|------|------|------|
| POST | `/media/presign` | `{ fileName?, fileSize?, mimeType? }` | `{ mediaSourceId, uploadUrl }` |
| POST | `/media/youtube` | `{ youtubeUrl: string }` | `{ mediaSourceId }` |

- **YouTube**: URL 넣으면 **mediaSourceId**만 생성
- **파일**: presign으로 **uploadUrl** 받고, 클라이언트가 그 URL로 PUT 업로드 후 같은 **mediaSourceId** 사용

### 작업(Job) (`/jobs`) — **모두 인증 필요**

| 메서드 | 경로 | Body / 파라미터 | 응답 |
|--------|------|------------------|------|
| POST | `/jobs` | `{ mediaSourceId, jobType?, targetLang? }` (기본 jobType=DAILY_LESSON, targetLang=en-US) | `201` → `{ jobId }` |
| GET | `/jobs/me` | - | `[ { id, jobType, status, progress, createdAt } ]` |
| GET | `/jobs/{job_id}` | - | `{ status, progress, message? }` |
| GET | `/jobs/{job_id}/result` | - | `{ dailyLesson, transcriptWords? }` (완료된 job만) |

**Job 생성 순서**

1. **YouTube**: `POST /media/youtube` → `mediaSourceId` → `POST /jobs` with `mediaSourceId` → `jobId`
2. **파일**: `POST /media/presign` → 업로드 → `mediaSourceId` 사용 → `POST /jobs` with `mediaSourceId` → `jobId`

### 레슨 결과 (`/lessons`) — **인증 필요**

| 메서드 | 경로 | 응답 |
|--------|------|------|
| GET | `/lessons/{job_id}` | `{ analysis?, dailyLesson, transcriptWords? }` (job 완료 시) |

- `dailyLesson`: 문장 단위 학습 구간 배열
- `transcriptWords`: 단어별 타임스탬프
- 서버는 **Video/StudyContent** 형태가 아니라 **dailyLesson + transcriptWords** 구조

### 업로드 presign (`/uploads`)

| 메서드 | 경로 | 응답 |
|--------|------|------|
| POST | `/uploads/presign` | `{ uploadId, uploadUrl }` (인증 없음으로 보임, 서버 코드 확인 필요) |

---

## 3. 서버 응답 스키마 (Flutter 매핑 시 참고)

### JobResultResponse / Lesson 결과

- `analysis`: (선택) JSON
- `dailyLesson`: `DailyLessonItem[]`
- `transcriptWords`: `TranscriptWord[]` (선택)

### DailyLessonItem (서버)

```json
{
  "startSec": 0.0,
  "endSec": 0.0,
  "sentence": "string",
  "reason": "string | null",
  "suggestedActivity": "string | null",
  "clipAudioUrl": "string | null",
  "items": [
    { "term": "string", "meaningKo": "string", "exampleEn": "string" }
  ]
}
```

### TranscriptWord (서버)

```json
{
  "word": "string",
  "startSeconds": 0.0,
  "endSeconds": 0.0
}
```

- Flutter `TranscriptWord`는 `text` 필드 사용 → 서버 `word`와 매핑 필요

---

## 4. Flutter 연동 시 유의사항

### 4.1 API 경로

- 서버는 **`/api` prefix 없음**. 경로는 `/auth`, `/media`, `/jobs`, `/lessons` 등.
- Flutter `ApiService`의 `$baseUrl/api/jobs` → `$baseUrl/jobs`로 수정 필요.

### 4.2 인증

- `/media/*`, `/jobs/*`, `/lessons/*`, `/auth/me`는 모두 **JWT 필요**.
- 모든 요청에 `Authorization: Bearer <accessToken>` 헤더 추가.
- 카카오 로그인 후 `POST /auth/kakao`로 `accessToken` 발급 → 저장(예: secure storage).

### 4.3 영상 입력 플로우 (video_input_screen)

**YouTube**

1. `POST /media/youtube` body `{ youtubeUrl }` → `mediaSourceId`
2. `POST /jobs` body `{ mediaSourceId, jobType?, targetLang? }` → `jobId`

**파일**

1. `POST /media/presign` (필요 시 body에 fileName 등) → `mediaSourceId`, `uploadUrl`
2. `uploadUrl`로 파일 PUT 업로드
3. `POST /jobs` body `{ mediaSourceId }` → `jobId`

### 4.4 응답 모델 매핑

- 서버는 **Video/StudyContent**를 반환하지 않음. `dailyLesson` + `transcriptWords` (+ `analysis`)만 반환.
- Flutter에서 서버 응답을 파싱해 `StudyContent` / `Word` / `TranscriptWord` 등으로 변환하는 레이어 필요.
- 서버 `TranscriptWord.word` ↔ Flutter `TranscriptWord.text` 매핑.

### 4.5 Base URL

- 개발: `http://localhost:8000` 또는 에뮬레이터용 `http://10.0.2.2:8000` (Android), `http://127.0.0.1:8000` (iOS)
- 배포 시 실제 서버 URL로 설정 (환경 변수/설정 파일 권장)

---

## 5. 체크리스트 (Flutter 수정 시)

- [ ] baseUrl 설정 (환경/설정 가능하게)
- [ ] API prefix `/api` 제거 → `/jobs`, `/media` 등
- [ ] 카카오 로그인 → `POST /auth/kakao` → accessToken 저장
- [ ] 모든 API 요청에 `Authorization: Bearer <token>` 추가
- [ ] YouTube: `POST /media/youtube` → `POST /jobs` 2단계로 변경
- [ ] 파일: `POST /media/presign` → PUT 업로드 → `POST /jobs`
- [ ] Job 상태: `GET /jobs/{id}` 응답에 맞게 파싱
- [ ] Job 결과: `GET /jobs/{id}/result` 또는 `GET /lessons/{id}` → dailyLesson/transcriptWords 파싱 후 Flutter 모델로 변환
- [ ] TranscriptWord: 서버 `word` ↔ Flutter `text` 매핑
