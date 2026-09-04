# Potluck V1 Beta — Setup

이 버전부터는 **진짜 Supabase 데이터베이스를 사용하는 베타**야.  
약 10–15분이면 연결할 수 있어.

## 1. Supabase 프로젝트 만들기

1. Supabase에서 새 project 생성.
2. 프로젝트가 준비되면 **SQL Editor**로 이동.
3. 이 repo의 `supabase-schema.sql` 전체를 붙여넣고 **Run**.

이 SQL이 다음을 만든다:

- profiles
- spaces
- space_members
- entries
- replies
- notifications
- RLS 보안 정책
- 공간 만들기 / 초대코드 참여 / 나가기 함수
- 답글 notification trigger

## 2. 로그인 설정

Supabase Dashboard → **Authentication → URL Configuration**

- Site URL: 현재 Vercel 주소  
  예: `https://potlucks.vercel.app`
- Redirect URLs에도 같은 주소 추가.
- 로컬 테스트를 원하면 `http://localhost:3000` 같은 로컬 주소도 추가.

Potluck은 이메일 **magic link** 로그인만 사용한다.

## 3. 브라우저 키 연결

Supabase Dashboard → Project Settings / API에서:

- Project URL
- publishable key (또는 현재 dashboard가 보여주는 browser-safe public key)

를 복사.

`config.js`:

```js
window.POTLUCK_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseKey: "YOUR_PUBLISHABLE_KEY"
};
```

여기에 붙여넣는다.

### 중요
`service_role` 키는 절대 넣지 마.
브라우저에 들어가는 키는 공개 가능한 publishable/public key만 사용한다.

## 4. GitHub에 업로드

기존 repo root를 아래 파일로 교체/추가:

- `index.html`
- `config.js`
- `supabase-schema.sql`
- `README.md`
- `SECURITY.md`
- `PRIVACY.md`
- `PRODUCT_LOG.md`

commit 하면 Vercel이 자동 redeploy.

## 5. 첫 테스트

1. 본인 이메일로 로그인 링크 요청.
2. 이메일 링크 클릭.
3. `Create space`로 공간 생성.
4. Space menu → Invite people → 링크 복사.
5. 친구에게 링크 전달.
6. 친구도 로그인 후 링크를 열어 초대코드로 참여.
7. 서로 기록 작성 → reply → Inbox 확인.

## 지금 구현된 것

- email magic-link auth
- profile + EN/KO UI preference
- private spaces
- create space
- invite code/link
- join space
- multiple spaces + switching
- weekly entries
- Made / Learned / Thought / Stuck
- replies
- reply notifications / Inbox
- membership-based RLS
- owner-only rename
- member leave

## 아직 없는 것

- 사진 업로드
- entry 수정/삭제 UI
- space owner transfer/delete UI
- invitation email 발송
- AI weekly synthesis
- password/social login
- push/email notification
- realtime updates

처음 친구 한 명과 쓰는 베타에는 일부러 제외했다.
