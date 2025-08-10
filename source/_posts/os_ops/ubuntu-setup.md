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

# dpkg --remove --force-remove-reinstreq firefox
apt remove --auto-remove snapd
rm -rf ~/snap/ /snap/ /var/lib/snapd/ /home/gjorn/snap/
apt-mark manual snapd
dpkg --purge --force-depends snapd

echo "Package: snapd Pin: release a=* Pin-Priority: -10" | tee /etc/apt/preferences.d/nosnap.pref
apt update
```

# 安装中文输入法

## fcitx5
`apt-get install -y fcitx5 fcitx5-configtool fcitx5-chinese-addons`
`mkdir -p ~/.config/autostart`
`touch  ~/.config/autostart/fcitx5.desktop`
```
[Desktop Entry]
Type=Application
Name=Fcitx5
Exec=/usr/bin/fcitx5
X-GNOME-Autostart-enabled=true
```
`chmod +x ~/.config/autostart/fcitx5.desktop`

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
4. 在bios中配置使用独显

## CUDA
安装: `apt install nvidia-cuda-toolkit`
检查: `nvcc --version`

## Nvidia Container Toolkit
> [Nvidia Official Guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

1. Configure the production repository:
```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```
2. Update the packages list from the repository:
`sudo apt-get update`
3. Install the NVIDIA Container Toolkit packages:
```shell
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
sudo apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```
4. 配置Docker使用Nvidia运行时
```shell
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
5. 验证是否可用
`sudo docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi`

## CUDNN
> CUda Deep Neural Network
安装: `apt install nvidia-cudnn`
验证:
```python
from torch.backends import cudnn
print(cudnn.is_available())  #返回True说明已经安装了cuDNN
```


# gnome

## 新窗口生成在中央
`gsettings set org.gnome.mutter center-new-windows true`

## 修改字体大小
`apt install -y 新窗口生成在中央`

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

# apt install无法获取dpkg lock
``` shell
function releaseDpkgLock() {
    sudo rm -f /var/cache/apt/archives/lock /var/lib/dpkg/lock
}
```

# 开机挂载硬盘
修改 `/etc/fstab`，使用`blkid`查看每个硬盘的信息

```
/dev/sda1 /mnt/repo1 ntfs defaults 0 0
/dev/sdb1 /mnt/repo2 ntfs defaults 0 0
```

# 安装docker开发环境
1. 安装docker，按照docker官网查看就行
`apt install -y docker`
```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
2. 换国内源:
    + `vim /etc/docker/daemon.json`
        ```json
        {
            "registry-mirrors": [
                "http://hub-mirror.c.163.com",
                "https://mirror.aliyuncs.com",
                "https://docker.mirrors.ustc.edu.cn"
            ]
        }
        ```
    + systemctl restart docker
3. 用户添加docker权限，把用户添加到到docker组
```shell
sudo groupadd docker            #添加docker用户组
sudo gpasswd -a $USER docker    #将登陆用户加入到docker用户组中
newgrp docker                   #更新用户组
```
4. 安装vscode的扩展

# 自定义`term`打开终端
```shell
function term() {
    if [ `whoami` == "root" ]; then
        echo "Can't upport in root"
    fi

    if [ $# -eq 0 ]; then
        gnome-terminal --working-directory="$PWD"
    elif [ -d "$1" ]; then
        gnome-terminal --working-directory="$(realpath "$1")"
    else
        echo "Path not exist: $1"
    fi
}
```

# ssh配置文件
> `/etc/ssh/ssh_config` 会 `Include /etc/ssh/ssh_config.d/*.conf`

```conf
# /etc/ssh/ssh_config.d/node.conf
Host server1
    HostName 192.168.1.100
    User username
    Port 22
```

# 给当前用户root权限
```shell
sudo usermod -aG sudo $USER
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
sudo chmod 440 /etc/sudoers.d/$USER
```