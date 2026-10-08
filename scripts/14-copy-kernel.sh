#!/usr/bin/env bash
set -euo pipefail

AK="/tmp/AnyKernel3"

if [ ! -f out/arch/arm64/boot/Image.gz ]; then
  echo "::error::Image.gz 未生成"
  ls -la out/arch/arm64/boot/
  exit 1
fi
cp out/arch/arm64/boot/Image.gz "$AK/Image.gz"

if [ -f out/arch/arm64/boot/dtb ]; then
  cp out/arch/arm64/boot/dtb "$AK/dtb"
elif [ -f out/arch/arm64/boot/dtb.img ]; then
  cp out/arch/arm64/boot/dtb.img "$AK/dtb"
fi

rm -rf "$AK/modules"
mkdir -p "$AK/modules"
find out -name '*.ko' -exec cp -v {} "$AK/modules/" \;
echo "模块数量: $(find "$AK/modules" -name '*.ko' | wc -l)"

echo "===== AnyKernel3 内容 ====="
ls -lh "$AK/Image.gz"
if [ -f "$AK/dtb" ]; then
  ls -lh "$AK/dtb"
else
  echo "未带 dtb（沿用原 boot）"
fi
