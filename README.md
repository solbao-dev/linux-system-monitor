# 🚀 리눅스 시스템 관제 자동화 프로젝트 (b1-1)

본 프로젝트는 리눅스 서버 환경에서 **네트워크 보안(SSH/방화벽), 사용자 계정 권한 격리, 디렉토리 위계 설계, 시스템 리소스 실시간 모니터링 및 로그 관리 자동화**를 설계하고 구현한 과정을 담고 있습니다.


---
## 🛠️ 0. 가상 인프라 구축 및 트러블슈팅

실습에 앞서, 관리자 권한(`sudo`)이 제한된 교육장 공용 Mac 환경에서 실제 상용 서비스 서버와 100% 동일한 보안 실습 환경을 만들기 위해 아래와 같이 환경을 구성하고 문제를 해결했습니다.
Ubuntu 서버 실습을 위해 Mac 환경에서 Linux VM 환경을 함에 있어, 관리자 권한 없이도 실제 서버와 최대한 동일한 환경을 만드는 것이 목표였습니다.


### 🔍 1) 가상화 도구 선택: OrbStack vs UTM

#### [후보 검토]
| 항목 | OrbStack | UTM |
| :--- | :--- | :--- |
| **설치 방식** | Homebrew로 간편 설치 | DMG 직접 설치 가능 |
| **가상화 방식** | 컨테이너 기반 (Docker 유사) | 완전한 VM (QEMU 기반) |
| **실제 서버와의 유사도** | 낮음 (커널 공유) | ✅ 높음 (독립 커널) |
| **네트워크 설정** | 제한적 | ✅ 실제 서버와 동일하게 설정 가능 |
| **SSH 설정** | 자동 처리됨 | ✅ 직접 설정 필요 (실습 적합) |
| **방화벽(UFW)** | 제한적 | ✅ 완전히 동작 |
| **성능** | 가벼움 | 상대적으로 무거움 |
| **과제 적합도** | ⚠️ 부분적 | ✅ **완전히 적합** |

- **OrbStack (선택 안 함):** 가볍지만 Mac 호스트의 커널을 공유하는 `컨테이너 방식`입니다. 이로 인해 SSH 포트 변경이나 UFW 방화벽 제어, 계정권한 등을 실제서버처럼 완전히 독립적으로 설정하기 어려움을 확인하였습니다. 따라서 orbstack으로는 "독립된 서버 보안 실습"을 완벽하게 재현하기 어려워 제외했습니다.

- **UTM (✅ 최종 선택):** 완전한 하드웨어 가상화(QEMU)를 지원하여 실제 서버와 동일하게 독립된 Linux 커널을 구동합니다. 방화벽, 네트워크, 계정 권한 관리를 실제 IDC 환경처럼 완벽하게 커스텀할 수 있어 최종 선택했습니다. 또한 Ubuntu Server ISO를 직접 설치하므로 실제 서버 배포와 동일한 경험을 쌓을 수 있었습니다. 

- **결정:** ✅ **UTM 선택** (실제 서버 환경과 100% 동일한 환경 구성 가능)

### ❌ 2) 공용 PC의 홈브루(`Homebrew`) 권한 거부 해결 과정
- **문제 현상:** 터미널에서 `brew install --cask utm` 실행 시, 공용 PC 특성상 주요 폴더의 쓰기 권한이 제한되어 `Permission denied` 에러가 발생했습니다.

- **원인 분석:** 기존 설치된 홈브루 폴더의 소유주가 현재 로그인한 계정과 달라 발생한 문제였으며, 공용 PC라 관리자 패스워드를 알 수 없어 권한 변경이 불가능했습니다.

- **해결 방법:** 패키지 매니저 설치 대신 **UTM 공식 홈페이지에서 `.dmg` 파일을 다운로드**하여, 유저 전용 개인 폴더(`~/Applications/`)에 수동으로 복사 배치함으로써 관리자 권한 없이 설치를 성공시켰습니다.

#### 관리자 권한 우회용 수동 설치 스크립트 

```bash
mkdir -p ~/Applications
hdiutil attach ~/Downloads/UTM.dmg
cp -R /Volumes/UTM/UTM.app ~/Applications/
hdiutil detach /Volumes/UTM
open ~/Applications/UTM.app
```
---
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
---
## 🔒2. SSH 보안 설정 (포트 격리 & 루트 접속 차단)  

서버를 개설하면 기본 포트인 22번을 노린 해커들의 무차별 대입 공격(Brute-Force) 스캔이 실시간으로 들어옵니다. 

포트를 임의의 번호(20022)로 바꾸는 것만으로도 대다수의 자동화 공격을 원천 차단할 수 있습니다. 

또한, 모든 권한을 가진 최고 관리자(root) 계정의 다이렉트 로그인을 막아 비밀번호 탈취 시 서버가 통째로 넘어가는 위험을 예방합니다.

```bash
# SSH 설정 파일에서 기본 포트를 20022로 변경하고 root 로그인 차단 설정

sudo sed -i 's/#Port 22/Port 20022/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 변경 사항 적용을 위해 SSH 서비스 재시작

sudo systemctl restart sshd
````

#### 정상작동검증
```bash
sudo ss -tulnp | grep sshd
```
![SHH 보안 설정 결과](./docs/img/ssh-result.png)


- 서버가 20022포트에서 정상적으로 응답을 기다리고있는지 확인 됨(listen)

- SSH 서비스(sshd)가 프로세스 번호 16680번으로 아주 건강하게 잘 작동하고 있는 점 확인 됨.    

---
## 🛡️3. UFW 방화벽 설정 (화이트리스트 정책)

방화벽의 기본 원칙은 **"필요한 문만 열어두고 나머지는 싹 다 닫는 것(화이트리스트)"**입니다.

문이 많이 열려있을수록 외부 공격자가 침투할 수 있는 통로(공격 표면)가 넓어지기 때문입니다. 

본 프로젝트에서는 오직 `운영 목적의 SSH 포트` 와 `에이전트 전용 포트` 만 허용하고 나머지는 철저히 격리합니다.

```bash

# 현재 서버에서 열려있는(수신 대기 중인)포트 확인하기
sudo ss -tulnp

# 현재 방화벽의 상태 최종 확인하기 
sudo ufw status verbose -> `status: inactive` 확인 됨

# 필수 서비스 포트만 선택적으로 허용

1. 방금 검증한 20022번 SSH 포트 허용
sudo ufw allow 20022/tcp  # 보안 SSH 포트

2. 에이전트 앱이 사용한 15034번 포트 허용
sudo ufw allow 15034/tcp  # Agent App 전용 포트

# 방화벽 엔진 활성화 (기존 원격 접속 유지 옵션 포함)
sudo ufw --force enable
```

#### 정상 작동 검증

```bash
sudo ufw status verbose
```
![방화벽 설정 완료](./docs/img/ufw-check.png)
- 방화벽(`ufw`) 상태를 확인하여 보안 포트 20022(SSH)와 에이전트 전용 포트 15034가 정상적으로 허용(ALLOW)되었는지 검증완료 

