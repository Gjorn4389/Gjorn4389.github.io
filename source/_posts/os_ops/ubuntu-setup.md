---
title: ubuntu setup
date: 2025-07-19 11:59:23
categories: ubuntu
tags:
    - ubuntu
---

# 替换repo源
[清华源](https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/)


# 删除snap
```shell
# snap list
snap remove --purge gnome-42-2204
snap remove --purge gtk-common-themes
snap remove --purge snap-store
snap remove --purge snapd-desktop-integration
snap remove --purge bare
snap remove --purge firefox
snap remove --purge firmware-updater
snap remove --purge core22
snap remove --purge snapd

apt remove --auto-remove snapd
rm -rf ~/snap/ /snap/ /var/lib/snapd/ /home/gjorn/snap/
apt-mark manual snapd
dpkg --purge --force-depends snapd

echo "Package: snapd Pin: release a=* Pin-Priority: -10" | tee /etc/apt/preferences.d/nosnap.pref
apt update
```

# 安装中文输入法
apt-get install -y fcitx5 fcitx5-configtool fcitx5-chinese-addons
mkdir -p ~/.config/autostart
touch  ~/.config/autostart/fcitx5.desktop
```
[Desktop Entry]
Type=Application
Name=Fcitx5
Exec=/usr/bin/fcitx5
X-GNOME-Autostart-enabled=true
```
chmod +x ~/.config/autostart/fcitx5.desktop

# 安装nvidia驱动
1. 在bios中配置使用核显
2. 关闭开源驱动 nouveau
    + `lsmod | grep nouveau`: 查看存在 nouveau 驱动
    + `vim /etc/modprobe.d/blacklist-nouveau.conf`
        ```
        blacklist nouveau
        options nouveau modeset=0
        ```
    + `update-initramfs -u; reboot`: 重启生效
3. 安装nvidia驱动
    + `ubuntu-drivers devices` 查看合适的驱动
    + `apt install -y nvidia-driver-xxx[-server][-open]`: 安装合适的驱动
    + `nvidia-smi`: 查看是否存在显卡
2. 在bios中配置使用独显

# gnome新窗口生成在中央
`gsettings set org.gnome.mutter center-new-windows true`

# 科学上网
使用 clash tun 令chrome、terminal可以使用

[clash-for-linux](https://github.com/nelvko/clash-for-linux-install)

# 下次重启切换到windows
在 `/etc/bash.bashrc` 中 `source /etc/custom/custom_func`

> /etc/custom/custom_func
```shell
#! /bin/bash

function switch2windows() {
    echo "switch to windows"
    # windwos entry index = 4
    sudo grub-reboot 4
    for ((i=3;i>0;i--)) {
        echo "$i seconds reboot"
        sleep 1
    }
    reboot
}
```