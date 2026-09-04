# Security Model — Potluck V1 Beta

Potluck의 핵심 보안 원칙은 **UI가 아니라 데이터베이스가 접근을 막아야 한다**는 것이다.

## Private by default

`entries`, `replies`, `spaces`, `space_members`는 모두 Row Level Security(RLS)를 사용한다.

사용자는 자신이 `space_members`에 포함된 공간의 데이터만 읽을 수 있다.

예:
- Creative Circle 멤버 → Creative Circle 기록 읽기 가능
- Career Crew 비멤버 → Career Crew 기록 읽기 불가
- URL/ID를 직접 알아내더라도 RLS가 DB 쿼리를 거부

## Browser key

프론트엔드는 Supabase의 browser-safe publishable/public key만 사용한다.

**절대 프론트엔드에 넣지 않는 것:**
- service_role key
- database password
- JWT secret

service_role은 RLS를 우회할 수 있기 때문이다.

## Write permissions

- entry: 작성자 본인 + 해당 space member일 때만 생성 가능
- entry update/delete: 작성자만
- reply: 해당 entry가 속한 space member만 작성 가능
- profile: 자기 것만 수정
- space rename: owner만
- notification: trigger가 생성하고 recipient만 조회/읽음 처리

## Joining a space

사용자는 `space_members`에 직접 INSERT 권한이 없다.

대신 `join_space_by_code()`라는 SECURITY DEFINER 함수만 사용한다.
이 함수가 유효한 invite code를 확인한 뒤 membership을 추가한다.

## Creating a space

사용자는 `spaces`에 직접 INSERT하지 않는다.

`create_space()` 함수가:
1. space 생성
2. 생성자를 owner membership으로 등록

을 하나의 서버 측 함수 안에서 처리한다.

## Known V1 limitations

- Invite code를 가진 사람은 로그인 후 해당 space에 참여할 수 있다.
- Invite code rotation/revocation UI는 아직 없다.
- Owner transfer/delete workflow는 아직 없다.
- 계정 자체 삭제 UI는 아직 없다.

친구 베타 이후 이 세 가지를 우선 추가해야 한다.
