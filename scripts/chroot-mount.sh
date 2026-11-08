#!/usr/bin/env bash
# ==============================================================================
#  🚑 LiveUSB 紧急修复挂载与 chroot 进入脚本 (chroot-mount.sh)
#  项目: Arch-Disaster-Recovery
#  维护: shenchuchu91-hub
# ==============================================================================

set -e

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[38;2;243;139;168m"
C_GREEN="\033[38;2;166;227;161m"
C_YELLOW="\033[38;2;249;226;175m"
C_BLUE="\033[38;2;137;180;250m"

echo -e "${C_BLUE}======================================================================${C_RESET}"
echo -e "${C_BOLD}🚑 Arch Linux LiveUSB 应急救砖挂载向导${C_RESET}"
echo -e "${C_BLUE}======================================================================${C_RESET}\n"

echo -e "${C_YELLOW}[*] 当前系统块设备与分区列表:${C_RESET}"
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL

echo -e "\n--------------------------------------------------"
read -p "请输入 Arch Linux 的【根分区】设备路径 (例如 /dev/nvme0n1p2 或 /dev/sda2): " ROOT_DEV
if [ ! -b "$ROOT_DEV" ]; then
    echo -e "${C_RED}[!] 错误: 分区 $ROOT_DEV 不存在！${C_RESET}"
    exit 1
fi

read -p "请输入 UEFI 的【EFI 引导分区】设备路径 (例如 /dev/nvme0n1p1 或 /dev/sda1): " EFI_DEV
if [ ! -b "$EFI_DEV" ]; then
    echo -e "${C_RED}[!] 错误: 分区 $EFI_DEV 不存在！${C_RESET}"
    exit 1
fi

echo -e "\n${C_BLUE}[*] 正在准备挂载环境至 /mnt ...${C_RESET}"
umount -R /mnt 2>/dev/null || true

# 挂载根目录
mount "$ROOT_DEV" /mnt
echo -e "${C_GREEN}[✓] 根分区已挂载至 /mnt${C_RESET}"

# 挂载 EFI
mkdir -p /mnt/boot/efi
mkdir -p /mnt/boot
if mount "$EFI_DEV" /mnt/boot 2>/dev/null; then
    echo -e "${C_GREEN}[✓] EFI 分区已挂载至 /mnt/boot${C_RESET}"
elif mount "$EFI_DEV" /mnt/boot/efi 2>/dev/null; then
    echo -e "${C_GREEN}[✓] EFI 分区已挂载至 /mnt/boot/efi${C_RESET}"
fi

echo -e "\n${C_GREEN}${C_BOLD}[✓] 准备就绪！正在进入 arch-chroot 环境...${C_RESET}"
echo -e "${C_YELLOW}常见修复命令参考：${C_RESET}"
echo -e "  - 重新生成引导镜像: mkinitcpio -P"
echo -e "  - 修复更新 GRUB: grub-mkconfig -o /boot/grub/grub.cfg"
echo -e "  - 重新安装内核: pacman -S linux linux-headers"
echo -e "  - 退出 chroot: exit\n"

arch-chroot /mnt
