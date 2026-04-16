# macos-qemu-rasberry

WIP: Running Raspberry Pi OS (arm64) under QEMU on macOS.

## Status

Not yet booting to userspace. Currently stopped at:

```
bcm2835_property: unhandled tag 0x00030043
```

This is an unhandled mailbox property tag in QEMU's `bcm2835_property` device
emulation, hit during firmware/kernel init. Investigation ongoing — likely
needs either a newer QEMU with tag support, a patch to handle the tag, or a
different kernel/DTB combination that avoids the call.

## Files

- `install.sh` — stages kernel, DTB, and Raspberry Pi OS image under `~/qemu_vms`.
- `run.sh` — boots the image with `qemu-system-aarch64` (`raspi3b`, cortex-a72).
- `kernel8.img` — kernel shipped with the repo.
- `bcm2710-rpi-3-b.dtb` — device tree blob.
- `device.dts` — device tree source.

## Usage

```sh
./install.sh
./run.sh
```

## Notes / fixes applied so far

- Removed `-nographic`; added `-device usb-mouse -device usb-kbd` so input works
  in the graphical window
  (per [community suggestion](https://community.memfault.com/t/emulating-a-raspberry-pi-in-qemu-interrupt/684/10)).
- Switched to `-sd` for the image and `-cpu cortex-a72`.
- Added USB-net with SSH forwarded to host `localhost:2222`.
- Bookworm console fix: `console=ttyAMA1` instead of `ttyAMA0`
  (Bookworm renamed the console device).

## Next steps

- Reproduce the `0x00030043` tag and identify which mailbox call emits it.
- Try a QEMU build with extended `bcm2835_property` tag handling, or a kernel
  config that doesn't issue the tag.
