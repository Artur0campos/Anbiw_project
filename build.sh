#!/bin/bash
set -e

echo "🔧 [1/4] Limpando build anterior..."
rm -f bzImage initramfs.cpio.gz

echo "🧠 [2/4] Compilando o kernel..."
make -C linux ARCH=x86_64 CROSS_COMPILE= bzImage

echo "📦 [3/4] Criando o initramfs com BusyBox..."
cd rootfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..

echo "🚀 [4/4] Iniciando sistema via QEMU..."
qemu-system-x86_64 \
  -kernel linux/arch/x86/boot/bzImage \
  -initrd initramfs.cpio.gz \
  -nographic \
  -append "console=ttyS0"
