---
title: snipaste picgo ubuntu
date: 2023-12-22 00:52:05
categories: ubuntu
tags:
    - ubuntu
    - picgo
---

# Snipaste
> [Snipaste客户端]https://www.snipaste.com/download.html
> 启动APP后可以从/tmp/.mount_SnipasXXXXX中找到png图标

下载 AppImage 格式, 添加到 Applications
+ `vim /usr/share/applications/picgo.desktop`
```
[Desktop Entry]
Type=Application
Name=picGo
Exec=/path/to/snipaste/Snipaste-2.3.1.AppImage
Icon=/path/to/snipaste/Snipaste.png
Terminal=false
```

# ~~flameshot ubuntu 截图工具~~
~~`sudo apt install flameshot`~~


# Picgo
1. [PicGo客户端](https://github.com/Molunerfinn/PicGo)
2. 下载 AppImage 格式
3. 添加到 Applications
    + `vim /usr/share/applications/picgo.desktop`
    ```
    [Desktop Entry]
    Type=Application
    Name=picGo
    Exec=/path/to/picgo/PicGo-2.3.1.AppImage
    Terminal=false
    ```
4. chmod 777: 添加权限

# AppImage 缺少 libfuse2 依赖
`sudo apt install libfuse2`
