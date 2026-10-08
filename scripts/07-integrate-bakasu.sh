#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "===== 集成 BakaSU 内核源码 ====="
echo "=========================================="

INPUT_TAG="${BAKASU_TAG_INPUT:-}"

if [ -n "$INPUT_TAG" ]; then
  LATEST_TAG="$INPUT_TAG"
  echo "使用手动指定的 tag: $LATEST_TAG"
else
  echo "正在获取 BakaSU 最新 tag ..."

  RELEASE_TAG=$(curl -sL \
    "https://api.github.com/repos/Baka-SU/BakaSU/releases/latest" \
    | grep '"tag_name"' | head -n1 | awk -F'"' '{print $4}' || true)

  if [ -n "${RELEASE_TAG:-}" ] && [ "$RELEASE_TAG" != "null" ]; then
    LATEST_TAG="$RELEASE_TAG"
    echo "从 Release API 获取到最新 tag: $LATEST_TAG"
  else
    echo "Release API 未返回有效 tag，从 git tags 获取 ..."
    LATEST_TAG=$(git ls-remote --tags --refs "$BAKASU_REPO" \
      | awk -F/ '{print $NF}' \
      | grep -E '^v?[0-9]' \
      | sort -V \
      | tail -n1 || true)

    if [ -z "${LATEST_TAG:-}" ]; then
      echo "::warning::未找到任何 tag，回退到默认分支 main"
      LATEST_TAG="main"
    else
      echo "从 git tags 获取到最新 tag: $LATEST_TAG"
    fi
  fi
fi

echo "最终使用 BakaSU tag/ref: $LATEST_TAG"

# ---- 按 tag 克隆 ----
rm -rf KernelSU
git clone --depth=1 --branch "$LATEST_TAG" "$BAKASU_REPO" KernelSU

cd KernelSU
KSU_COMMIT=$(git rev-parse --short HEAD)
KSU_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "$LATEST_TAG")
echo "BakaSU tag: $KSU_TAG"
echo "BakaSU commit: $KSU_COMMIT"
cd ..

# 保存版本信息，供后续步骤使用
echo "$KSU_TAG" > /tmp/bakasu_tag.txt
echo "$KSU_COMMIT" > /tmp/bakasu_commit.txt

# 软链接到 drivers/kernelsu
ln -sf "$(pwd)/KernelSU/kernel" "$(pwd)/drivers/kernelsu"

# 注册到 drivers/Makefile
if ! grep -q "kernelsu" drivers/Makefile; then
  echo 'obj-$(CONFIG_KSU) += kernelsu/' >> drivers/Makefile
  echo "✓ drivers/Makefile 已添加 kernelsu"
else
  echo "✓ drivers/Makefile 已包含 kernelsu"
fi

# 注册到 drivers/Kconfig
if ! grep -q "kernelsu" drivers/Kconfig; then
  cat >> drivers/Kconfig <<'EOF'

source "drivers/kernelsu/Kconfig"
EOF
  echo "✓ drivers/Kconfig 已添加 kernelsu"
else
  echo "✓ drivers/Kconfig 已包含 kernelsu"
fi

echo "===== BakaSU 源码集成完成 ====="
