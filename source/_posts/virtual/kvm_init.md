---
title: kvm_init
date: 2024-7-17 13:33:26
categories: qemu
tags:
    - qemu
    - kvm
---

# kvm_init 函数

1. 确定有多少个CPU：num_cpus[SMP, hotpluggable]
2. KVMParkedVcpu { vcpu_id, kvm_fd } 列表记录vcpu
3. 检查KVM版本
4. kvm创建虚机，返回一个fd：kvm_ioctl(s, KVM_CREATE_VM, type);