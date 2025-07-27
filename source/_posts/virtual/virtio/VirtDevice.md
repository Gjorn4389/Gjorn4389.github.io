---
title: Virt Device
date: 2023-12-10 09:26:43
categories: VirtMachine
tags:
    - protocol
---

# 模型演变
+ 完全虚拟化: 根据硬件设备规范模拟，对Guest透明，不需要修改
+ `Vhost`方案: 将数据面迁移到内核空间
+ `Virtio`协议: 半虚拟化，使用`Virtqueue`传输数据
+ `VT-d`: Intel 在硬件层面提供支持，包含DMA重映射、中断重映射等安全方案
+ `SR-IOV`(Single Root I/O Virtualization): 将一个PCIe设备虚拟成多个功能设备给不同虚机访问使用

# PCI配置空间

## PCI配置空间
TODO

## PCI设备板上存储空间
1. PCI设备提出需要的地址空间大小、板上内存映射类型(内存地址、IO地址)，将其记录在 BAR(Base Address Registers) 中。
2. 由 BIOS(或UEFI) 在系统初始化，访问 `BAR` 统一划分地址空间
    > Q: 热插设备什么时候分配地址空间
3. PCI拓扑关系： cpu <---> Host Bridge <---> pci bus <---> PCI Device
    ![PCI拓扑关系](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/vfio/cpu_pci_topology.png)
4. 确定访问设备：管脚 `IDSEL` 选定目标 PCI 设备，仅需要确定 `Function Number` 和 `Registers Number`

## 模拟PCI设备配置空间

### 确定寄存器地址
> kvmtool 实现
1. 计算 pci_config_address_ptr = &pci_config_address + addr - PCI_CONFIG_ADDRESS
2. 通过 pci_config_address_ptr 来修改配置空间

## 模拟PCI设备BAR
1. `pci_get_mmio_block` 为PCI设备分配内存地址：内存对齐、记录 mmio_blocks 方便后续分配
    ![kvmtool_pci_bar](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/kvmtool_pci_bar.png)
2. `device__register` 将设备注册到 rbtree上，根据 dev_num 来排序，方便检索

# 设备透传

## SR-IVO 标准
> Single Root I/O Virtualization and Sharing
1. 设备分为 PF(Physical Function) 和 VF(Virtual Function)，硬件实现，一个SR-IOV可以支持多个VF，每个VF透传给Guest
2. 每个VF都有独立的用于数据传输的存储空间、队列、中断及命令处理单元，由VMM管理
3. 虚拟机通过VF驱动直接访问物理设备，也可以通过SR-IOV设备的PF结构共享物理设备

## 虚拟配置空间
> 安全考虑Guest不能直接修改配置空间，VMM作为代理对配置空间进行修改
1. Host的BIOS会分配PCI设备的BAR空间，Guest不能直接访问，需要VMM负责映射
2. VF-BAR ---> HPA ---> GPA，VMM只需要完成GPA到HVA的映射
3. 配置空间与数据面隔离，不会影响数据效率

## DMA重映射
1. 背景：防止 Guest DMA 恶意破坏内存
2. 原理：
    + 为 Guest 建立页表（DMA Table，由多个设备共享），页表限制了设备可以访问的内存
    + DMA重映射硬件 根据BDF号确定页表，找到HPA
    + DMA重映射硬件 为外设进行IO地址翻译，也叫IOMMU
3. kvmtool 实现：
    + kvmtool 为 Guest准备多个内存段，提供给外设使用
    + `VFIO_IOMMU_MAP_DMA`：在DMA重映射页表中建立映射关系
    + 内核通知外设进行DMA前，需要把虚拟地址转换为物理地址（通过dma_map的iova、vaddr）
    + 内核创建 IOMMU 的页表，会将VA转成PA，其中记录的是GPA到HPA的映射
    ![kvmtool中的dma映射](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/kvmtool_dma_map.png)

## 中断重映射
1. 背景：避免虚机向其他虚机发送恶意中断
2. 原理：硬件中断重映射单元 对中断进行有效性验证，以中断号为索引查询中断重映射表，代替外设转发中断信号，目的虚机由BDF确定