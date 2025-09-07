---
title: debian setup
date: 2025-07-19 11:59:23
categories: debian
tags:
    - debian13
---

# 替换repo源
[清华源](https://mirror.tuna.tsinghua.edu.cn/help/debian/)

# command not found
1. `su -`: use root
2. `export PATH=/sbin:$PATH`: PATH not contain /sbin

# set privilages
add `whoami` in /etc/sudoers

# set timezone
`ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime`

# set chinese
1. `apt install -y ibus-libpinyin`: smart pinyin !
2. `im-config`: activate ibus
3. `ibus-setup`: add Chinese-Pinyin
4. `ibus restart`
5. `keyboard`: add input source

# set shortcut
1. terminal: `gnome-terminal`
2. files: `nautilus`

# install nvidia drivers
> [debian wiki for install nvidia driver](https://wiki.debian.org/NvidiaGraphicsDrivers#Debian_13_.22Trixie.22)

> [enable wayland after nvidia driver installed](https://askubuntu.com/questions/1403854/cant-use-wayland-with-nvidia-510-drivers-on-ubuntu-22-04-lts/1403999#1403999)

> [install nvidia driver by run exec](https://www.cnblogs.com/pprp/p/9430836.html)

1. change BIOS Setting: use IGD as first graphics card
2. `apt install linux-headers-$(uname -r)`
3. `apt install build-essential gcc-multilib dkms`
4. forbid nouveau driver
    + `/etc/modprobe.d/blacklist-nouveau.conf`
        ```conf
        blacklist nouveau
        blacklist lbm-nouveau
        options nouveau modeset=0
        alias nouveau off
        alias lbm-nouveau off
        ```
    + `echo options nouveau modeset=0 | tee -a /etc/modprobe.d/nouveau-kms.conf`
4. `update-initramfs -u; reboot`
5. `systemctl stop gdm`
6. `./NVIDIA-Linux-x86_64-580.76.05.run -no-x-check -no-nouveau-check -no-opengl-files --disable-nouveau`
7. modify `/etc/modprobe.d/nvidia-power-management.conf`: enable wayland
    ```conf
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    ```

# install GNOME extensions
> `apt install gnome-shell-extensions`

## appindicator-support
Adds AppIndicator, KStatusNotifierItem and legacy Tray icons support to the Shell

![appindicator-support demo](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/appindicator-support.png)