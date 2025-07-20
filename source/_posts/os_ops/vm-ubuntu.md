---
title: vms over ubuntu
date: 2023-12-20 02:31:41
categories: ubuntu
tags:
    - ubuntu
---

1. ubuntu需要修改emulator
```xml
<emulator>/usr/bin/qemu-system-x86_64</emulator>
```
2. 需要cdrom引导安装系统
```xml
<disk type='file' device='disk'>
    <driver name='qemu' type='raw' cache='none' io='native'/>
    <source file='/srv/vm/img/openEuler.raw'/>
    <target dev='vda' bus='virtio'/>
    <boot order='1'/>
</disk>
<disk type='file' device='cdrom'>
    <driver name='qemu' type='raw' cache='none' io='native'/>
    <source file='/srv/vm/img/openEuler-24.03-LTS-SP2-x86_64-dvd.iso'/>
    <target dev='sdb' bus='scsi'/>
    <readonly/>
    <boot order='2'/>
</disk>
```
