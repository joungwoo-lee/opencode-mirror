# Opencode Offline Setup

이 폴더는 인터넷 연결이 없는 폐쇄망 환경에서 Opencode CLI를 설치하고 관리하기 위한 자동화 도구들을 포함하고 있습니다.

## 1. 주요 특징 (Features)

*   **멀티 OS 지원**: Windows (`install.bat`)와 Linux (`install.sh`)를 모두 지원합니다.
*   **자동 경로 설정**: 별도의 환경 변수(PATH) 설정 없이 즉시 명령어를 사용할 수 있도록 최적의 경로에 설치됩니다.
*   **설정 자동 복사**: 기본 설정 파일(`.config/opencode`)을 사용자 홈 디렉토리에 자동으로 배포합니다.
*   **간편한 삭제/초기화**: `--clean` 옵션 하나로 설치된 바이너리와 설정을 모두 깨끗하게 지울 수 있습니다.

## 2. 폴더 구조 (Structure)

*   `dist/`: 빌드된 실행 파일들이 포함되어야 하는 폴더입니다. (설치 스크립트가 이 폴더 안의 바이너리를 참조합니다.)
    *   `opencode-windows-x64.exe`
    *   `opencode-linux-x64`
*   `.config/opencode/`: 설치 시 사용자의 홈 디렉토리에 복사될 기본 설정 파일 모음입니다.
*   `install.bat` / `install.sh`: OS별 설치 및 삭제 스크립트입니다.

## 3. 설치 방법 (Installation)

### Windows
`install.bat` 파일을 실행합니다. (관리자 권한 없이도 설치 가능)
*   설치 경로: `%LOCALAPPDATA%\Microsoft\WindowsApps\opencode.exe`
*   설정 경로: `%USERPROFILE%\.config\opencode`

### Linux
터미널에서 다음 명령어를 실행합니다:
```bash
sudo ./install.sh
```
*   설치 경로: `/usr/local/bin/opencode`
*   설정 경로: `~/.config/opencode`

## 4. 삭제 및 초기화 (Cleanup)

설치된 파일과 설정을 모두 제거하려면 명령어 뒤에 `--clean` 인자를 붙여 실행합니다.

### Windows
```cmd
install.bat --clean
```

### Linux
```bash
sudo ./install.sh --clean
```

## 5. 빌드 가이드 (Build Guide)

인터넷이 연결된 환경에서 먼저 빌드 스크립트를 실행하여 `dist` 폴더를 준비해야 합니다.

```bash
./build_offline.sh
```
성공적으로 완료되면 `dist` 폴더가 생성되며, 이 폴더를 포함하여 `opencode_offline_setup` 전체를 폐쇄망으로 복사하여 사용하십시오.
