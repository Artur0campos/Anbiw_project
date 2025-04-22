#!/bin/bash

set -e

# Caminhos
KERNEL_DIR="linux"
ROOTFS_DIR="rootfs"
INITRAMFS="initramfs.cpio.gz"

# 1. Baixar kernel Linux se não existir
if [ ! -d "$KERNEL_DIR" ]; then
  echo "🔻 Baixando kernel Linux..."
  git clone --depth=1 https://github.com/torvalds/linux.git "$KERNEL_DIR"
fi

# 2. Compilar kernel
echo "⚙️  Compilando kernel..."
cd "$KERNEL_DIR"
make defconfig
make -j$(nproc)
cd ..

# 3. Criar rootfs com BusyBox
echo "📦 Montando rootfs..."
mkdir -p $ROOTFS_DIR/{bin,sbin,etc,proc,sys,usr/bin,dev}

# Baixar busybox se não existir
if [ ! -f "$ROOTFS_DIR/bin/busybox" ]; then
  wget -O "$ROOTFS_DIR/bin/busybox" https://busybox.net/downloads/binaries/1.21.1/busybox-x86_64
  chmod +x "$ROOTFS_DIR/bin/busybox"
  (cd $ROOTFS_DIR/bin && for cmd in $(./busybox --list); do ln -sf busybox "$cmd"; done)
fi

# Copiar init
cp init "$ROOTFS_DIR/init"
chmod +x "$ROOTFS_DIR/init"

# 4. Criar initramfs
echo "📦 Criando initramfs..."
cd "$ROOTFS_DIR"
find . | cpio -o --format=newc | gzip > ../$INITRAMFS
cd ..

# 5. Rodar com QEMU
echo "🚀 Iniciando kernel com QEMU..."
qemu-system-x86_64 \
  -kernel "$KERNEL_DIR/arch/x86/boot/bzImage" \
  -initrd "$INITRAMFS" \
  -nographic \
  -append "console=ttyS0"
