#!/bin/bash

# 설치 스크립트 (Linux)
# 사용법: sudo ./install.sh
# 삭제 시: sudo ./install.sh --clean

set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="opencode"
SOURCE_BINARY="$SCRIPT_DIR/opencode-linux-x64"

# 실제 사용자 정보 추출 (sudo 실행 시에도 원래 사용자의 홈 디렉토리를 찾기 위함)
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CONFIG_DEST_DIR="$USER_HOME/.config/opencode"

# --clean 인자가 넘어오면 설치된 파일을 삭제하고 종료합니다.
if [ "$1" == "--clean" ]; then
    echo "==========================================="
    echo "Cleaning up Opencode for Linux..."
    echo "==========================================="

    # 바이너리 삭제
    if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
        echo "Removing binary from $INSTALL_DIR..."
        [ -w "$INSTALL_DIR" ] || SUDO="sudo"
        $SUDO rm -f "$INSTALL_DIR/$BINARY_NAME"
        echo "[SUCCESS] Removed $BINARY_NAME"
    else
        echo "[INFO] $BINARY_NAME not found in $INSTALL_DIR"
    fi

    # 설정 폴더 삭제
    if [ -d "$CONFIG_DEST_DIR" ]; then
        echo "Removing configuration folder: $CONFIG_DEST_DIR"
        rm -rf "$CONFIG_DEST_DIR"
        echo "[SUCCESS] Removed configuration folder"
    else
        echo "[INFO] Configuration folder not found: $CONFIG_DEST_DIR"
    fi

    echo "Cleanup complete!"
    exit 0
fi

# 1. 소스 파일 존재 확인
if [ ! -f "$SOURCE_BINARY" ]; then
    echo "Error: Binary file '$SOURCE_BINARY' not found."
    exit 1
fi

echo "Installing $BINARY_NAME to $INSTALL_DIR..."

# 2. 바이너리 복사
if [ -w "$INSTALL_DIR" ]; then
    cp "$SOURCE_BINARY" "$INSTALL_DIR/$BINARY_NAME"
else
    echo "Requesting root permissions to copy to $INSTALL_DIR..."
    sudo cp "$SOURCE_BINARY" "$INSTALL_DIR/$BINARY_NAME"
fi

# 3. 실행 권한 부여
if [ -w "$INSTALL_DIR/$BINARY_NAME" ]; then
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
else
    sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
fi

# 4. 설정 파일 복사
echo "Copying configuration files..."
CONFIG_SOURCE_DIR="$SCRIPT_DIR/.config/opencode"

if [ -d "$CONFIG_SOURCE_DIR" ]; then
    mkdir -p "$CONFIG_DEST_DIR"
    cp -r "$CONFIG_SOURCE_DIR/"* "$CONFIG_DEST_DIR/"
    # 권한 설정 (사용자 소유로 변경)
    if [ "$REAL_USER" != "root" ]; then
        chown -R "$REAL_USER" "$CONFIG_DEST_DIR"
    fi
    echo "[SUCCESS] Configuration files copied to $CONFIG_DEST_DIR"
else
    echo "[INFO] Configuration source directory '$CONFIG_SOURCE_DIR' not found."
fi

echo "Installation complete!"
echo "You can now use '$BINARY_NAME' command."
