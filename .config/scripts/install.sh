#!/bin/bash
# ~/.config/scripts/install.sh

echo "🚀 开始恢复 Arch Linux 终极开发环境..."

# ==========================================
# 0. 基础网络与代理准备 (最优先执行，防止后续超时)
# ==========================================
echo "🌐 配置临时安装代理 (127.0.0.1:7890)..."
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7890"

echo "🔧 优化 pacman 配置 (开启色彩、吃豆人特效与并行下载)..."
# 开启色彩
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
# 添加 ILoveCandy 吃豆人特效 (如果没有的话)
sudo grep -q "^ILoveCandy" /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
# 开启 5 个并行下载
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# 1. 安装官方仓库软件
echo "📦 正在安装官方仓库软件..."
sudo pacman -S --needed - <~/.config/pkglist-repo.txt

# 2. 安装/配置 AUR 助手 (假设你用 yay)
if ! command -v yay &>/dev/null; then
  echo "⚙️ 正在安装 yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

# 3. 安装 AUR 软件
echo "📦 正在安装 AUR 软件..."
yay -S --needed - <~/.config/pkglist-aur.txt

# 4. 恢复 Git 裸仓库配置 (Dotfiles)
echo "🔗 正在拉取 Dotfiles..."
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >>~/.gitignore
git clone --bare https://github.com/Evergarden-Alan/myarch.git HOME/.dotfiles

# 尝试检出文件。如果新系统有默认的 .bashrc 冲突，会自动备份并覆盖
dot checkout 2>/dev/null
if [ $? = 0 ]; then
  echo "✅ 配置检出成功！"
else
  echo "⚠️ 发现文件冲突，正在备份默认文件..."
  mkdir -p ~/.config-backup
  dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.config-backup/{}
  dot checkout
fi

dot config --local status.showUntrackedFiles no

# 5. 切换默认 Shell 为 Fish
echo "🐟 正在切换默认 Shell..."
chsh -s $(which fish)

# ---------------------------------------------------
# 6. 配置显示管理器 (greetd + tuigreet)
# ---------------------------------------------------
echo "🖥️ 正在配置 greetd 登录界面..."

# 确保 greetd 和 tuigreet 已经安装（防止 pkglist 里漏掉）
sudo pacman -S --needed greetd tuigreet

# 备份默认的 greetd 配置
if [ -f /etc/greetd/config.toml ]; then
  sudo mv /etc/greetd/config.toml /etc/greetd/config.toml.bak
fi

# 写入针对 Niri 的 greetd 配置
# 注意：这里假设 tuigreet 登录成功后执行 `niri-session`
sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
# The VT to run the greeter on. Can be "next", "current" and a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]
# 使用 tuigreet 作为界面，并指定登录后启动 niri-session
command = "tuigreet --time --cmd niri-session"
# 运行 greeter 的用户，必须是 'greeter'
user = "greeter"
EOF

# 设置开机自启 greetd 服务
echo "🔄 启用 greetd 系统服务..."
sudo systemctl enable greetd.service
# ---------------------------------------------------

echo "🎉 装机完成！请重启系统以应用所有桌面环境 (Niri) 更改。"
