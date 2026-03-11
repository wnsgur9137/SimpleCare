---
title: "Fastlane 가이드"
aliases: ["Fastlane", "CI/CD"]
tags:
  - 구현
  - 구현/빌드
created: 2026-01-30
updated: 2026-03-11
status: active
---

# Fastlane 가이드

본 문서는 SimpleCare 프로젝트의 Fastlane 설정 및 사용 방법에 대해 설명합니다.

---

## 목차

1. [개요](#개요)
2. [설치 및 설정](#설치-및-설정)
3. [버전 관리](#버전-관리)
4. [빌드 레인](#빌드-레인)
5. [테스트 레인](#테스트-레인)
6. [인증서 관리 (Match)](#인증서-관리-match)
7. [설정 파일](#설정-파일)

---

## 개요

Fastlane은 iOS 앱의 빌드, 테스트, 배포를 자동화하는 도구입니다. SimpleCare 프로젝트에서는 다음 기능을 위해 사용합니다:

- **버전 관리**: Tuist 프로젝트의 버전/빌드 번호 자동화
- **빌드 자동화**: 개발/프로덕션 빌드 생성
- **테스트 자동화**: 유닛 테스트 실행
- **배포 자동화**: TestFlight 업로드

---

## 설치 및 설정

### 사전 요구사항

- Ruby (시스템 기본 또는 rbenv/rvm)
- Bundler
- Xcode Command Line Tools

### 설치

```bash
# Bundler를 통한 설치 (권장)
bundle install

# 또는 직접 설치
gem install fastlane
```

### 환경 변수 설정

`fastlane/.env` 파일을 생성하고 다음 내용을 설정합니다:

```bash
APPLE_ID="your-apple-id@example.com"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

> ⚠️ `.env` 파일은 `.gitignore`에 포함되어 있으므로 Git에 커밋되지 않습니다.

---

## 버전 관리

SimpleCare는 Tuist를 사용하므로, 버전 정보가 `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` 파일에 저장됩니다.

### 현재 버전 확인

```bash
fastlane current_version
```

### 버전 업데이트

```bash
# 특정 버전으로 설정
fastlane bump version:1.0.0

# 특정 빌드 번호로 설정
fastlane bump build:10

# 버전과 빌드 번호 동시 설정
fastlane bump version:1.0.0 build:1
```

### 시맨틱 버전 증가

```bash
# Major 버전 증가 (X.0.0)
fastlane bump_major

# Minor 버전 증가 (0.X.0)
fastlane bump_minor

# Patch 버전 증가 (0.0.X)
fastlane bump_patch

# 빌드 번호만 증가
fastlane bump_build
```

### 버전 업데이트 프로세스

`bump` 레인 실행 시 다음 작업이 자동으로 수행됩니다:

1. `Project+Templates.swift` 파일의 버전 정보 업데이트
2. `tuist generate --no-open` 실행하여 Xcode 프로젝트 재생성
3. 변경사항 Git 커밋

---

## 빌드 레인

### 빌드 테스트 (시뮬레이터)

컴파일만 수행하고 IPA는 생성하지 않습니다.

```bash
fastlane build_test
```

- **Scheme**: SimpleCare-Dev
- **Configuration**: DEV
- **Destination**: iOS Simulator

### 개발용 빌드

개발용 IPA 파일을 생성합니다.

```bash
fastlane build
```

- **Scheme**: SimpleCare
- **Configuration**: PROD
- **Export Method**: development

### TestFlight 배포

App Store Connect의 TestFlight에 빌드를 업로드합니다.

```bash
fastlane beta
```

- **Scheme**: SimpleCare
- **Configuration**: PROD
- **Export Method**: app-store

---

## 테스트 레인

### 유닛 테스트 실행

```bash
fastlane test
```

- **Scheme**: SimpleCare-Dev
- **Device**: iPhone 15 Pro
- **Clean Build**: 활성화

---

## 인증서 관리 (Match)

Fastlane Match를 사용하여 인증서와 프로비저닝 프로필을 Git 저장소에서 중앙 관리합니다.

### Match 초기화

```bash
fastlane match init
```

### 인증서 동기화

```bash
# 개발용 인증서
fastlane match development

# App Store 배포용 인증서
fastlane match appstore

# Ad-hoc 배포용 인증서
fastlane match adhoc
```

### Match 설정

`fastlane/Matchfile`:

```ruby
git_url("git@github.com:wnsgur9137/fastlane_match")
git_branch("SimpleCare")
storage_mode("git")

type("development")
app_identifier(["com.junhyeok.SimpleCare", "com.junhyeok.SimpleCare-Dev"])
username(ENV["APPLE_ID"])
```

---

## 설정 파일

### Fastfile

레인(Lane) 정의 파일입니다.

**위치**: `fastlane/Fastfile`

**주요 레인**:

| 레인 | 설명 |
|------|------|
| `current_version` | 현재 버전 조회 |
| `bump` | 버전/빌드 번호 업데이트 |
| `bump_major` | Major 버전 증가 |
| `bump_minor` | Minor 버전 증가 |
| `bump_patch` | Patch 버전 증가 |
| `bump_build` | 빌드 번호만 증가 |
| `build_test` | 시뮬레이터 빌드 테스트 |
| `build` | 개발용 IPA 빌드 |
| `beta` | TestFlight 배포 |
| `test` | 유닛 테스트 실행 |

### Appfile

앱 식별자 및 Apple 계정 정보를 정의합니다.

**위치**: `fastlane/Appfile`

```ruby
# 기본 앱 식별자 (개발용)
app_identifier("com.junhyeok.SimpleCare-Dev")
apple_id(ENV["APPLE_ID"])

itc_team_id("125231504") # App Store Connect Team ID
team_id("VW2UR5Y845")    # Developer Portal Team ID

# 프로덕션 레인용 앱 식별자
for_lane :build do
  app_identifier("com.junhyeok.SimpleCare")
end

for_lane :beta do
  app_identifier("com.junhyeok.SimpleCare")
end
```

### Matchfile

인증서 관리 설정을 정의합니다.

**위치**: `fastlane/Matchfile`

### .env

환경 변수를 정의합니다. (Git에 커밋되지 않음)

**위치**: `fastlane/.env`

---

## 문제 해결

### 인증서 관련 오류

```bash
# 인증서 초기화 후 재동기화
fastlane match nuke development
fastlane match development
```

### 프로비저닝 프로필 오류

Xcode에서 자동 서명이 활성화되어 있는지 확인하거나, Match를 통해 프로필을 다시 동기화합니다.

### 버전 정보를 찾을 수 없음

`Project+Templates.swift` 파일에 `appVersion`과 `bundleVersion`이 올바른 형식으로 정의되어 있는지 확인합니다:

```swift
public static let appVersion: Plist.Value = "0.0.1"
public static let bundleVersion: Plist.Value = "1"
```

---

## 참고 자료

- [Fastlane 공식 문서](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [Tuist 공식 문서](https://docs.tuist.io/)
