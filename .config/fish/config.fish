if status is-interactive
    # Commands to run in interactive sessions can go here
end
set fish_greeting ""
set -p PATH ~/.local/bin
starship init fish | source
zoxide init fish --cmd cd | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function ls
    command eza --icons $argv
end

# grub
abbr grub 'sudo grub-mkconfig -o /boot/grub/grub.cfg'
# 小黄鸭补帧 需要steam安装正版小黄鸭
abbr lsfg 'LSFG_PROCESS="miyu"'
# fa运行fastfetch
abbr fa fastfetch
abbr reboot 'systemctl reboot'
function sl
    command sl | lolcat
end
function 滚
    sysup
end
function raw
    command ~/.config/scripts/random-anime-wallpaper.sh $argv
end

function 安装
    command yay -S $argv
end

function 卸载
    command yay -Rns $argv
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/shorin/.lmstudio/bin
# End of LM Studio CLI section

function y
    # 1. 使用 -l 确保变量只在本次函数运行中有效
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")

    # 2. 明确调用 command yazi，并只传递当前输入的参数 $argv
    # 注意：不要在 $argv 后面再手动加重复的参数
    command yazi $argv --cwd-file="$tmp"

    # 3. 检查文件并跳转
    if test -f "$tmp"
        set -l cwd (cat -- "$tmp")
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
