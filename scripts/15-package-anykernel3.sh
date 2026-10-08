#!/usr/bin/env bash
set -euo pipefail

cd /tmp/AnyKernel3

BAKASU_VER=$(cat /tmp/bakasu_tag.txt 2>/dev/null || echo "unknown")

ZIP="$GITHUB_WORKSPACE/boot-flashlmdd-bakasu-${BAKASU_VER}-anykernel-${GITHUB_RUN_NUMBER}.zip"
rm -f "$ZIP"

zip -r9 "$ZIP" . -x ".git/*" "README.md" "*.zip"

ls -lh "$ZIP"
# head 提前退出会让 unzip 收到 SIGPIPE（141），在 set -o pipefail 下会中断脚本
unzip -l "$ZIP" | head -80 || true
