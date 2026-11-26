<p align="center">
  <img src="./assets/banner.jpg" width="100%" alt="" />
</p>

<p align="center"><sub>雨还在下</sub></p>

# 系统坏了怎么修

进不去、更新之后黑屏、换硬盘、想退回快照。先对下面的表，再开 Live 盘。盘符用 `lsblk` 看，不要照抄 `nvme0n1`。

完整安装在 [Arch-Linux-Guide](https://github.com/shenchuchu91-hub/Arch-Linux-Guide)。桌面配置在 [dotfiles](https://github.com/shenchuchu91-hub/dotfiles)。

## 先看这个

| 情况 | 去哪 |
| --- | --- |
| 新电脑，或硬盘是空的 | [Arch-Linux-Guide](https://github.com/shenchuchu91-hub/Arch-Linux-Guide)，装完再跑 [dotfiles](https://github.com/shenchuchu91-hub/dotfiles) 的 `install.sh` |
| 更新后黑屏，或 GRUB 坏了 | 这篇，Live 盘里 `chroot` |
| 配置改乱了 | `cd ~/dotfiles && git pull && ./install.sh` |
| 刚用 Timeshift / Snapper 回滚 | 再跑一次 `./install.sh`，把软链接接回去 |
| 换到 NixOS / Fedora | [Linux-Desktop-Matrix](https://github.com/shenchuchu91-hub/Linux-Desktop-Matrix) |
| 游戏没走独显 | [moe-game-launcher](https://github.com/shenchuchu91-hub/moe-game-launcher) |
| SCPSL 准星偏、卡 | [SCPSL-ArchLinux-Optimization](https://github.com/shenchuchu91-hub/SCPSL-ArchLinux-Optimization) |
| 和 Windows 差 8 小时，或 NTFS 只读 | [Linux-DualBoot-Steam-Guide](https://github.com/shenchuchu91-hub/Linux-DualBoot-Steam-Guide) |

## 换机器

用户名示例是 `chuchu`，换成你的。Wi-Fi 名和密码也换成你的。

```bash
iwctl --passphrase <wifi密码> station wlan0 connect <wifi名>
timedatectl set-ntp true
```

分区还是：`p1` 1GB FAT32 挂 `/boot`，剩下挂 `/`。看过 `lsblk` 再格式化。

```bash
pacstrap -K /mnt base base-devel linux linux-headers linux-firmware networkmanager git fish sudo vim
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

useradd -m -G wheel -s /usr/bin/fish chuchu
passwd chuchu
EDITOR=vim visudo
```

`visudo` 里把 `%wheel ALL=(ALL:ALL) ALL` 前面的 `#` 去掉。

```bash
pacman -S grub efibootmgr os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
exit
reboot
```

进去之后：

```bash
sudo pacman -S intel-ucode intel-media-driver nvidia-dkms nvidia-utils lib32-nvidia-utils pipewire wireplumber pipewire-audio pipewire-pulse
```

AMD 换 `amd-ucode`。没有 NVIDIA 就不要装 `nvidia-*`。

然后：

```bash
git clone https://github.com/shenchuchu91-hub/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

脚本会按 `pkglist-native.txt` 补包，再把 niri、fish、kitty 等链到 `~/.config`。已有同名目录会先备份。

## 黑屏、进不去

用 Arch 的 U 盘启动，联网，然后：

```bash
curl -O https://raw.githubusercontent.com/shenchuchu91-hub/Arch-Disaster-Recovery/main/scripts/chroot-mount.sh
chmod +x chroot-mount.sh
./chroot-mount.sh
```

脚本对不上你的盘时，手挂：

```bash
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot
arch-chroot /mnt
```

内核或 initramfs 坏了：

```bash
pacman -Syu linux linux-headers
mkinitcpio -P
grub-mkconfig -o /boot/grub/grub.cfg
exit
reboot
```

NVIDIA 新驱动和内核对不上，开机黑屏。可以先切到 LTS：

```bash
pacman -S linux-lts linux-lts-headers
grub-mkconfig -o /boot/grub/grub.cfg
```

或者从缓存装回旧驱动：

```bash
ls /var/cache/pacman/pkg/nvidia-dkms*
pacman -U /var/cache/pacman/pkg/nvidia-dkms-<旧版本号>.pkg.tar.zst
```

GRUB 没了：

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

## 快照

Timeshift：

```bash
sudo timeshift --list
sudo timeshift --restore --snapshot '<快照名>'
```

Snapper：

```bash
sudo snapper list
sudo snapper rollback <快照编号>
reboot
```

回来之后跑一次 `cd ~/dotfiles && ./install.sh`，软链接才还在。

## 换发行版

```bash
git clone https://github.com/shenchuchu91-hub/Linux-Desktop-Matrix.git
cd Linux-Desktop-Matrix
./setup.sh
```

脚本会问发行版和桌面。NixOS 也可以直接引用仓库里的 `distros/nixos/home-manager/`。

## 别的故障

| 现象 | 去哪 |
| --- | --- |
| 和 Windows 差 8 小时 | [双系统笔记](https://github.com/shenchuchu91-hub/Linux-DualBoot-Steam-Guide) 里的 RTC |
| NTFS 只能读 | 同一篇，关掉 Windows 快速启动 |
| 游戏只用核显 | [moe-game](https://github.com/shenchuchu91-hub/moe-game-launcher) |
| SCPSL 准星偏 | [SCPSL 笔记](https://github.com/shenchuchu91-hub/SCPSL-ArchLinux-Optimization) |

格式化、挂载、chroot 都会碰到整块盘。`lsblk` 对上了再敲。许可是 [MIT](./LICENSE)。

<p align="center"><sub>雨还在下</sub></p>
