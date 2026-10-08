#!/usr/bin/env bash
set -euo pipefail

export PATH="/home/runner/zyc-clang/bin:/tmp/gcc64/bin:/tmp/gcc32/bin:$PATH"

CFG="out/.config"

echo "===== 启用 BakaSU 配置 ====="
./scripts/config --file "$CFG" \
  -e KSU \
  -e KSU_MANUAL_HOOK

# 禁用手动钩子模式下不需要的选项
./scripts/config --file "$CFG" -d KPROBES
./scripts/config --file "$CFG" \
  -d KSU_MANUAL_HOOK_AUTO_INPUT_HOOK \
  -d KSU_MANUAL_HOOK_AUTO_SETUID_HOOK \
  -d KSU_MANUAL_HOOK_AUTO_INITRC_HOOK

# 处理依赖
make O=out ARCH=arm64 SUBARCH=arm64 \
  CC="ccache clang" \
  HOSTCC="ccache clang" \
  KCFLAGS="-gdwarf-4" \
  olddefconfig

echo ""
echo "===== BakaSU 配置检查 ====="
grep -E "CONFIG_KSU|CONFIG_KPROBES" out/.config || true
