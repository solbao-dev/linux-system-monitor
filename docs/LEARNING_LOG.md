# Linux System Monitor — Learning Log

> CODYSSEY Tool Learning에서 Linux 서버 환경을 직접 구성하며 보안·권한·모니터링을 실습한 상세 기록입니다.

## Learning Scope | 학습 범위

- UTM 기반 Ubuntu Server VM
- SSH 설정과 원격 접속
- UFW firewall
- Linux users / groups / permissions
- RBAC와 최소 권한 원칙
- 시스템 리소스 모니터링
- 로그 관리와 운영 관점의 검증

## Environment | 실습 환경

- Host: macOS Sequoia 15.7.4
- Virtualization: UTM
- Guest: Ubuntu Server 24.04 LTS
- Architecture: x86_64
- Remote access: SSH

## Environment Decision Log | 환경 선택 기록

관리자 권한이 제한된 교육장 Mac에서 실제 서버와 유사한 독립 Linux 환경이 필요했습니다. OrbStack과 UTM을 비교한 뒤, 독립 커널·SSH·UFW·사용자 권한 등을 직접 제어할 수 있는 **UTM 기반 VM**을 선택했습니다.

Homebrew 설치 권한이 제한된 환경에서는 UTM DMG를 사용자 전용 `~/Applications` 경로에 배치하는 방식으로 실습 환경을 구성했습니다.

## Security Practice | 보안 실습

### SSH
SSH 설정을 변경하고 root 직접 로그인을 제한하는 과정을 실습했습니다. 설정 변경 후 `ss` 등으로 서비스의 listen 상태를 확인하며 변경 사항을 검증했습니다.

### UFW
필요한 서비스 포트만 허용하는 whitelist 관점으로 UFW 규칙을 구성하고 `ufw status verbose`로 실제 적용 상태를 확인했습니다.

> 학습 메모: 포트 번호 변경만으로 강한 보안이 완성되는 것은 아니며, 실제 운영에서는 키 기반 인증, 접근제어, 업데이트, 모니터링 등 여러 계층의 보안 통제가 함께 필요합니다.

## Users, Groups & RBAC | 사용자·권한 관리

공용 계정 대신 역할별 사용자와 그룹을 구성하고 최소 권한 원칙을 적용했습니다. 사용자에게 직접 모든 권한을 부여하기보다 역할/그룹을 통해 권한을 관리하는 RBAC 개념을 실습했습니다.

- `agent-common`
- `agent-core`
- `agent-admin`
- `agent-dev`
- `agent-test`

## Monitoring | 시스템 모니터링

CPU, memory, disk 등 시스템 자원의 상태를 확인하고 운영 환경에서 리소스 관측과 로그가 왜 필요한지 학습했습니다. 명령 실행 자체보다 **상태 확인 → 기록 → 이상 징후 판단 → 검증** 흐름에 초점을 두었습니다.

## Troubleshooting | 문제 해결 기록

- 관리자 권한이 없는 교육 환경에서 VM 도구 설치
- VM의 시스템 시간대 UTC → Asia/Seoul 교정
- SSH/UFW 설정 후 실제 listen·allow 상태 재검증
- 사용자·그룹 권한을 역할에 맞게 분리하고 검증

---

> 상세 명령어와 스크린샷 중심의 초기 기록을 포트폴리오 README와 분리해, 운영·보안 학습 과정 자체를 Learning Log로 보존합니다.