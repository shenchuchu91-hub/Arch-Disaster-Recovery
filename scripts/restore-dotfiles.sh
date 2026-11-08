#!/usr/bin/env bash
# ==============================================================================
#  🌸 一键克隆并恢复完整 dotfiles 与软件环境 (restore-dotfiles.sh)
#  项目: Arch-Disaster-Recovery
#  维护: shenchuchu91-hub
# ==============================================================================

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "[*] 开始自动化恢复个人软件与桌面环境..."

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[*] 正在克隆 dotfiles 仓库..."
    git clone https://github.com/shenchuchu91-hub/dotfiles.git "$DOTFILES_DIR"
else
    echo "[*] 检测到已存在 ~/dotfiles，正在拉取最新更新..."
    git -C "$DOTFILES_DIR" pull
fi

cd "$DOTFILES_DIR"
chmod +x install.sh
./install.sh

echo "[✓] 个人软件与桌面环境恢复圆满完成！"
