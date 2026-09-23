# Linux System Monitor

> **Linux server security, access control, and system monitoring practice**  
> Ubuntu Server 환경에서 보안·권한·리소스 모니터링을 직접 구성하고 검증한 시스템 운영 프로젝트

`Linux` `Ubuntu Server` `SSH` `UFW` `RBAC` `Monitoring` `UTM`

---

## Overview | 프로젝트 소개

This project builds a Linux server practice environment and explores essential operational concepts including remote access, firewall rules, role-based permissions, resource monitoring, and verification.

CODYSSEY Tool Learning 과정에서 **실제 Linux 서버에 가까운 독립 환경을 구성하고 SSH, 방화벽, 사용자 권한, 시스템 리소스와 로그를 직접 다뤄본 프로젝트**입니다.

관리자 권한이 제한된 교육장 Mac이라는 제약 속에서 OrbStack과 UTM을 비교한 뒤, 독립 Linux 커널과 네트워크·보안 설정을 직접 제어할 수 있는 UTM + Ubuntu Server 환경을 선택했습니다.

## Key Areas | 핵심 실습

- Ubuntu Server VM with UTM | UTM 기반 Ubuntu Server 환경 구축
- SSH remote-access configuration | SSH 원격접속 설정·검증
- UFW firewall rules | UFW 방화벽 정책 실습
- Users, groups, and permissions | 사용자·그룹·권한 관리
- RBAC & least privilege | 역할 기반 접근제어와 최소 권한
- Resource & log monitoring | 시스템 자원·로그 모니터링

## Environment | 환경

| Area | Environment |
|---|---|
| Host OS | macOS Sequoia 15.7.4 |
| Virtualization | UTM |
| Guest OS | Ubuntu Server 24.04 LTS |
| Architecture | x86_64 |
| Access | SSH |

## Operational Perspective | 운영 관점

이 프로젝트에서는 설정 자체보다 **설정 후 실제 상태를 다시 확인하는 과정**을 중요하게 다뤘습니다. SSH listen 상태, UFW 허용 규칙, 사용자 그룹과 권한 등을 명령어로 재검증하며 운영 환경에서의 기본적인 확인 습관을 익혔습니다.

또한 보안은 특정 포트 변경 하나로 완성되는 것이 아니라 인증, 방화벽, 최소 권한, 업데이트와 모니터링 등 여러 계층이 함께 작동해야 한다는 관점으로 정리했습니다.

## Learning Log | 상세 학습 기록

VM 도구 선택 과정, 관리자 권한 제약 해결, SSH/UFW/RBAC 구성과 상세 검증 기록은 별도 Learning Log로 보존했습니다.

➡️ **[View Detailed Learning Log](./docs/LEARNING_LOG.md)**

---

**CODYSSEY AI All-in-One · Tool Learning**