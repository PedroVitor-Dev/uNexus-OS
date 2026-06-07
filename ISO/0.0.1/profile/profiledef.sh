#!/usr/bin/env bash

iso_name="unexus-os"
iso_label="UNEXUS_001"
iso_publisher="PedroVitor-Dev <https://github.com/PedroVitor-Dev/uNexus-OS>"
iso_application="uNexus OS live image"
iso_version="0.0.1"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/etc/sudoers.d/10-unexus-live"]="0:0:440"
)
