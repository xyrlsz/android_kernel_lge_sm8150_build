#!/usr/bin/env bash
set -euo pipefail

rm -rf /tmp/AnyKernel3
git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git /tmp/AnyKernel3

cd /tmp/AnyKernel3

rm -f zImage Image.gz Image.lz4 Image.gz-dtb dtb dtbo.img 2>/dev/null || true

BAKASU_VER=$(cat /tmp/bakasu_tag.txt 2>/dev/null || echo "unknown")

sed -i "s/^kernel.string=.*/kernel.string=Container+Baka-SU-SUSFS ${BAKASU_VER} Kernel for LG V50 (flashlmdd) by GitHub Actions/" anykernel.sh
sed -i 's/^do.devicecheck=.*/do.devicecheck=1/' anykernel.sh
sed -i 's/^do.modules=.*/do.modules=1/' anykernel.sh
sed -i 's/^do.systemless=.*/do.systemless=0/' anykernel.sh
sed -i 's/^do.cleanup=.*/do.cleanup=1/' anykernel.sh
sed -i 's/^do.cleanuponabort=.*/do.cleanuponabort=0/' anykernel.sh
sed -i 's/^device.name1=.*/device.name1=flashlmdd/' anykernel.sh
sed -i 's/^device.name2=.*/device.name2=flashlmdd/' anykernel.sh
# anykernel.sh 里只有 properties() 的选项是小写（kernel.string / do.* / device.name*），
# 顶层的 shell 变量是大写（BLOCK / IS_SLOT_DEVICE / RAMDISK_COMPRESSION），别写错大小写。
# flashlmdd 是 A/B 设备，boot 分区实际叫 boot_a / boot_b，必须交给 AnyKernel3 自动补槽位后缀，
# 否则会报 "Unable to determine boot partition. Aborting..." 而刷入失败。
sed -i 's|^BLOCK=.*|BLOCK=boot;|' anykernel.sh
sed -i 's/^IS_SLOT_DEVICE=.*/IS_SLOT_DEVICE=auto;/' anykernel.sh
sed -i 's/^RAMDISK_COMPRESSION=.*/RAMDISK_COMPRESSION=auto;/' anykernel.sh

echo "===== anykernel.sh 关键项 ====="
grep -E 'kernel.string|do.devicecheck|do.modules|device.name1|^BLOCK=|^IS_SLOT_DEVICE=|^RAMDISK_COMPRESSION=' anykernel.sh

# 上面三条 sed 若因上游变量改名而失效，会被静默忽略并打出不可刷入的 zip，所以这里强制校验
for key in 'BLOCK=boot;' 'IS_SLOT_DEVICE=auto;' 'RAMDISK_COMPRESSION=auto;' \
           'device.name1=flashlmdd' 'do.modules=1' 'do.devicecheck=1'; do
  grep -qF "$key" anykernel.sh || { echo "::error::anykernel.sh 未正确设置（$key）"; exit 1; }
done
