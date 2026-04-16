#!/usr/bin/env bash

set -euxo pipefail

readonly IMAGE='2025-12-04-raspios-trixie-arm64'
readonly KERNEL='kernel8.img'
readonly DTB='bcm2710-rpi-3-b.dtb'

readonly TMP_DIR="${HOME}/qemu_vms"
readonly IMAGE_FILE="${TMP_DIR}/${IMAGE}.img"
readonly KERNEL_FILE="${TMP_DIR}/${KERNEL}"
readonly DTB_FILE="${TMP_DIR}/${DTB}"

readonly QEMU_SYS='qemu-system-aarch64'

has_qemu () {
  command -v "$QEMU_SYS" &> /dev/null || \
    { echo 'Install QEMU'; exit 1; }
}

run_qemu () {
  "$QEMU_SYS" \
    -machine raspi3b \
    -cpu cortex-a72 \
    -m 1G \
    -smp 4 \
    -kernel "$KERNEL_FILE" \
    -dtb "$DTB_FILE" \
    -sd "$IMAGE_FILE" \
    -append 'rw earlyprintk loglevel=8 console=ttyAMA1,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1' \
    -device usb-net,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device usb-mouse \
    -device usb-kbd \
    -d guest_errors,unimp
}

main () {
  has_qemu
  run_qemu
}

main
