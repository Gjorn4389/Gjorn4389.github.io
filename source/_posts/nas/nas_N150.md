---
title: N150 nas
date: 2024-8-16 13:33:26
categories: nas
tags:
    - N150
---

# 安装PVE
> [Prepare Installation Media](https://pve.proxmox.com/wiki/Prepare_Installation_Media)

使用`dd`安装PVE镜像，才能install成功
`dd bs=1M conv=fdatasync if=./proxmox-ve_*.iso of=/dev/XYZ`

## 核显SRIOV
> [详见README](https://github.com/strongtz/i915-sriov-dkms)

1. Install build tools: `apt install build-* dkms`
2. Install the kernel and headers for desired version: `apt install proxmox-headers-6.8 proxmox-kernel-6.8` (for unsigned kernel).
3. Download deb package from the [releases page](https://github.com/strongtz/i915-sriov-dkms/releases)
   ```sh
   wget -O /tmp/i915-sriov-dkms_2025.07.22_amd64.deb "https://github.com/strongtz/i915-sriov-dkms/releases/download/2025.07.22/i915-sriov-dkms_2025.07.22_amd64.deb"
   ```
4. Install the deb package with dpkg: `dpkg -i /tmp/i915-sriov-dkms_2025.07.22_amd64.deb`
5. Once finished, the kernel commandline needs to be adjusted: `nano /etc/default/grub` and change `GRUB_CMDLINE_LINUX_DEFAULT` to `intel_iommu=on i915.enable_guc=3 i915.max_vfs=7 module_blacklist=xe`, or add to it if you have other arguments there already.
6. Update `grub` and `initramfs` by executing `update-grub` and `update-initramfs -u`
7. Optionally pin the kernel version and update the boot config via `proxmox-boot-tool`.
8. In order to enable the VFs, a `sysfs` attribute must be set. Install `sysfsutils`, then do `echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = 7" > /etc/sysfs.conf`, assuming your iGPU is on 00:02 bus. If not, use `lspci | grep VGA` to find the PCIe bus your iGPU is on.
9. Reboot the system.
10. When the system is back up again, you should see the number of VFs under 02:00.1 - 02:00.7. Again, assuming your iGPU is on 00:02 bus.
11. You can passthrough the VFs to LXCs or VMs. However, never pass the **PF (02:00.0)** to **VM** which would crash all other VFs.

# immortalwrt

配置称旁路由后，将电脑的网关设置成 LAN 的IP地址，发现能ping通不能连上网。

可能是因为回来的TCP包 ip被改了。可以如下修改。

![immortalwrt配置](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/immortalwrt_lan_firewall.png)


## openclash

按照机场教程搞一下就行


# fnos

## SRIOV直通核显
在分配虚拟显卡后，还要在os内安装 `i915-sriov-dkms`

## 扩展磁盘
1. `fdisk` 创建分区
2. `pvcreate /dev/sdax`
3. 查看当前卷组: `vgdisplay`
4. 扩展卷组: `vgextend <vg_name> /dev/sdb1`


# bilisync
> [官方教程](https://bili-sync.allwens.work/quick-start)

## 部分配置
```yml
    # 这个权限还挺重要
    # user: 1000:1000
    volumes:
      - /srv/docker/bilisync/config/:/app/.config/bili-sync
      - /srv/docker/bilisync/upper_face/:/app/.config/bili-sync/upper_face
      - /srv/docker/bilisync/Videos/:/home/amtoaer/HDDs/Videos/Bilibilis/
```

## 需要验证 `auth_token`
![报错](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/bilisync_authtoken_err.png)

![前端认证状态](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/bilisync_webui_authfront.png)

```py
import sqlite3

conn = sqlite3.connect('/srv/docker/bilisync/bili-sync/data.sqlite')
cursor=conn.cursor()
cursor.execute("SELECT * FROM config")
# <sqlite3.Cursor object at 0x75ae6ceabd40>
for row in cursor.fetchall():
    print(row)
```
![从data.sqlite获取auth_token](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/bilisync_config_sql.png)

## 添加配置
> [bili配置说明](https://bili-sync.allwens.work/configuration)

`window.localStorage.ac_time_value` 获取不到
改为任一时间 `console.log(new Date().getTime())`

## 添加视频

收藏夹: 例如以下地址的`fid`
`https://space.bilibili.com/4677045/favlist?fid=xxxxxxxxx&ftype=create&ctype=21`

