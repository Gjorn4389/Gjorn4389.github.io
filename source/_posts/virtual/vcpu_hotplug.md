---
title: VCPU Hotplug
date: 2024-3-13 13:33:26
categories: libvirt
tags:
    - libvirt
    - hotplug
    - vcpu
---

# 热插vcpu主要流程

## hotpluggable配置缺省值
qemuDomainAttachDevice
qemuDomainAttachDeviceFlags
qemuDomainAttachDeviceLiveAndConfig
qemuDomainAttachDeviceConfig
virDomainDefPostParse
virDomainDefPostParseCommon
virDomainVcpuDefPostParse

以下代码可以确定，当没有配置vcpu的hotpluggable时：
1. 如果使能了vcpu，那么就是不可热插拔
2. 如果没有使能vcpu，那么就是可热插拔
![hotpluggable_not_set](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/plug_vcpu_hotpluggable_not_set.png)