---
title: snipaste picgo ubuntu
date: 2023-12-22 00:52:05
categories: ubuntu
tags:
    - ubuntu
    - picgo
---

# AppImage 缺少依赖
`sudo apt install libfuse2 xclip`


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

## 启动picgo时报错sandbox相关
> The SUID sandbox helper binary was found, but is not configured correctly. Rather than run without sandboxing I'm aborting now. You need to make sure that /tmp/.mount_PicGo-r9KnKV/chrome-sandbox is owned by root and has mode 4755.

1. 运行时添加免沙箱命令 `--no-sandbox`
2. ~~启用非特权用户命名空间克隆~~
```shell
# 临时设置
sudo sysctl kernel.unprivileged_userns_clone=1

# 永久设置
echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 编译
> linux下有bug,配置了静默启动还是会有mini窗口

1. 部署docker
2. 安装 elctron
    + 依赖: [build instructions linux](https://www.electronjs.org/docs/latest/development/build-instructions-linux)
    + `apt install -y npm nodejs`
3. `npm install --legacy-peer-deps`
4. 修改代码
```patch
--- a/src/main/apis/app/window/windowList.ts
+++ b/src/main/apis/app/window/windowList.ts
@@ -129,7 +129,7 @@ windowList.set(IWindowList.MINI_WINDOW, {
     const obj: IBrowserWindowOptions = {
       height: 64,
       width: 64,
-      show: isLinux,
+      show: false,
       frame: false,
       fullscreenable: false,
       skipTaskbar: true,
```
5. `npm run build`: 生成在`dist_electron/`
