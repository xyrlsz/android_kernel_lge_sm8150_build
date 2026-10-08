#!/usr/bin/env bash
set -euo pipefail

rm -rf /tmp/AnyKernel3
git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git /tmp/AnyKernel3

cd /tmp/AnyKernel3

rm -f zImage Image.gz Image.lz4 Image.gz-dtb dtb dtbo.img 2>/dev/null || true

BAKASU_VER=$(cat /tmp/bakasu_tag.txt 2>/dev/null || echo "unknown")

sed -i "s/^kernel.string=.*/kernel.string=Container+BakaSU ${BAKASU_VER} Kernel for LG V50 (flashlmdd) by GitHub Actions/" anykernel.sh
sed -i 's/^do.devicecheck=.*/do.devicecheck=1/' anykernel.sh
sed -i 's/^do.modules=.*/do.modules=1/' anykernel.sh
sed -i 's/^do.systemless=.*/do.systemless=0/' anykernel.sh
sed -i 's/^do.cleanup=.*/do.cleanup=1/' anykernel.sh
sed -i 's/^do.cleanuponabort=.*/do.cleanuponabort=0/' anykernel.sh
sed -i 's/^device.name1=.*/device.name1=flashlmdd/' anykernel.sh
sed -i 's/^device.name2=.*/device.name2=flashlmdd/' anykernel.sh
sed -i 's|^block=.*|block=/dev/block/bootdevice/by-name/boot;|' anykernel.sh
sed -i 's/^is_slot_device=.*/is_slot_device=0;/' anykernel.sh
sed -i 's/^ramdisk_compression=.*/ramdisk_compression=auto;/' anykernel.sh

echo "===== anykernel.sh 关键项 ====="
grep -E 'kernel.string|do.devicecheck|do.modules|device.name1|block=|is_slot_device' anykernel.sh
