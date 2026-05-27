# 🚀 리눅스 시스템 관제 자동화 프로젝트 (b1-1)

본 프로젝트는 리눅스 서버 환경에서 **네트워크 보안(SSH/방화벽), 사용자 계정 권한 격리, 디렉토리 위계 설계, 시스템 리소스 실시간 모니터링 및 로그 관리 자동화**를 설계하고 구현한 과정을 담고 있습니다.

---

## 🛠️ 0. 가상 인프라 구축 및 트러블슈팅

실습에 앞서, 관리자 권한(`sudo`)이 제한된 교육장 공용 Mac 환경에서 실제 상용 서비스 서버와 100% 동일한 보안 실습 환경을 만들기 위해 아래와 같이 환경을 구성하고 문제를 해결했습니다.

### 🔍 1) 가상화 도구 선택: OrbStack vs UTM
- **OrbStack (선택 안 함):** 가볍지만 Mac 호스트의 커널을 공유하는 컨테이너 방식입니다. 이로 인해 SSH 포트 변경이나 UFW 방화벽 제어 등 "독립된 서버 보안 실습"을 완벽하게 재현하기 어려워 제외했습니다.

- **UTM (✅ 최종 선택):** 완전한 하드웨어 가상화(QEMU)를 지원하여 실제 서버와 동일하게 독립된 Linux 커널을 구동합니다. 방화벽, 네트워크, 계정 권한 관리를 실제 IDC 환경처럼 완벽하게 커스텀할 수 있어 최종 선택했습니다.

### ❌ 2) 공용 PC의 홈브루(`Homebrew`) 권한 거부 해결 과정
- **문제 현상:** 터미널에서 `brew install --cask utm` 실행 시, 공용 PC 특성상 주요 폴더의 쓰기 권한이 제한되어 `Permission denied` 에러가 발생했습니다.

- **원인 분석:** 기존 설치된 홈브루 폴더의 소유주가 현재 로그인한 계정과 달라 발생한 문제였으며, 공용 PC라 관리자 패스워드를 알 수 없어 권한 변경이 불가능했습니다.

- **해결 방법:** 패키지 매니저 설치 대신 **UTM 공식 홈페이지에서 `.dmg` 파일을 다운로드**하여, 유저 전용 개인 폴더(`~/Applications/`)에 수동으로 복사 배치함으로써 관리자 권한 없이 설치를 성공시켰습니다.

```bash
# 관리자 권한 우회용 수동 설치 스크립트
mkdir -p ~/Applications
hdiutil attach ~/Downloads/UTM.dmg
cp -R /Volumes/UTM/UTM.app ~/Applications/
hdiutil detach /Volumes/UTM
open ~/Applications/UTM.app
```

## 💻 1. 개발 환경 정보 (Environment)

| 항목 | 내용 |
| :--- | :--- |
| **Host OS** | macOS Sequoia (v15.7.4) |
| **가상화 환경** | UTM |
| **Guest OS** | Ubuntu Server 24.04 LTS |
| **Architecture** | x86_64 (intel core i5)|
| **Terminal** | Mac 기본 터미널 + SSH 원격접속|



## 📊 [추가] 세부 시스템 및 네트워크 환경 정보

| 항목 (Item) | 상세 내용 (Details) | 관련 명령어 | 의미 및 비고 |
| :--- | :--- | :--- | :--- |
| **Guest OS 아키텍처** | `x86_64` (64-bit) | `uname -a` | Intel 계열 가상화 아키텍처 확인 |
| **GLIBC 버전** | `v2.35` | `ldd --version` | C 표준 라이브러리 구동 버전 |
| **가상 머신 IP 주소** | `192.168.64.2` | `ip addr` | SSH 및 SCP 접속용 가상 내부 IP |
| **시스템 시간대** | `Asia/Seoul (KST, +0900)` | `timedatectl` | 한국 표준시(KST) 설정 완료 |

> 💡 **환경 교정 기록:** > 가상 머신 최초 빌드 시 시스템 시간대가 `Etc/UTC`로 설정되어 있는 것을 확인하여, `sudo timedatectl set-timezone Asia/Seoul` 명령어를 통해 한국 표준시(KST)로 수동 교정 완료함.

### 스크린샷
**📷 우분투 세부 환경 검증 스크린샷**
![우분투 세부 환경 검증 화면](./docs/img/ubuntu-system-check.png)

