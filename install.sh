#!/usr/bin/env bash

set -euxo pipefail

readonly IMAGE='2025-12-04-raspios-trixie-arm64'
readonly KERNEL='kernel8.img'
readonly DTB='bcm2710-rpi-3-b.dtb'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="${HOME}/qemu_vms"
readonly KERNEL_FILE="${TMP_DIR}/${KERNEL}"
readonly DTB_FILE="${TMP_DIR}/${DTB}"
readonly IMAGE_FILE="${TMP_DIR}/${IMAGE}.img"

readonly IMAGE_URL="https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2025-12-04/${IMAGE}.img.xz"

check_commands () {
  [ "$(uname)" = 'Darwin' ] || \
    { echo 'Must be run on macOS'; exit 1; }

  command -v brew &> /dev/null || \
    { echo 'Install homebrew'; exit 1; }

  command -v curl &> /dev/null || \
    { echo 'Install curl'; exit 1; }

  command -v xz &> /dev/null || \
    brew install xz
}

install_qemu () {
  command -v qemu-system-aarch64 &> /dev/null || \
    brew install qemu
}

change_dir () {
  { mkdir -p "$TMP_DIR" && \
    cd "$TMP_DIR"; } || \
    exit 1
}

stage_kernel_and_dtb () {
  [ -f "$KERNEL_FILE" ] || \
    cp "${SCRIPT_DIR}/${KERNEL}" "$KERNEL_FILE"
  [ -f "$DTB_FILE" ] || \
    cp "${SCRIPT_DIR}/${DTB}" "$DTB_FILE"
}

extract_image () {
  [ -f "${IMAGE}.img.xz" ] || [ -f "${IMAGE}.img" ] || \
    curl -fSL "$IMAGE_URL" -o "${IMAGE}.img.xz"
  [ -f "${IMAGE}.img" ] || \
    xz -dk "${IMAGE}.img.xz"
}

resize_image () {
  # QEMU SD card emulation requires a power-of-two image size.
  qemu-img resize -f raw "$IMAGE_FILE" 8G
}

main () {
  check_commands
  install_qemu
  change_dir
  stage_kernel_and_dtb
  extract_image
  resize_image
}

main
