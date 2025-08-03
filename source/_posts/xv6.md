---
title: xv6
date: 2023-12-23 09:26:43
categories: os
tags:
    - os
---

# 部署开发环境

## 使用docker部署
> 在main分支中有`docker-compose.yml`，使用 `docker-compose up -d` 搭建环境

## 使用gdb
> [环境配置gdb](https://zhuanlan.zhihu.com/p/638731320)

+ 一个窗口: `make qemu-gdb`
+ 一个窗口: `gdb-multiarch -x .gdbinit`

![gdb tips](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/xv6_gdb_tips.png)


# xv6启动第一个进程
1. `entry.S`
    + 从 `_entry` 开始运行xv6，此时虚拟地址直接映射到物理地址
    + `kernel.ld` 将 xv6内核加载到 `0x80000000`，`0x0~0x80000000` 包含IO设备
    + 设置栈(用于运行c代码)，stack0在`start.c`文件中声明
    + 执行 start.c 中的 start()
2. `start.c`
    + 修改运行模式为 Machine 模式
    + 设置main函数的地址
    + 禁止虚拟地址转换
    + 将所有的中断和异常委托给管理模式
    + 内存保护
    + 产生计时器中断
    + 通过 `mret` 回到 Supervisor 模式
3. `main.c`
    + 初始化设备、子系统
    + `userinit` 执行 `initcode.S`
    + scheduler() 会调度到第一次个proc，即init
4. `init.c`
    + 创建 console
    + 打开文件描述符
    + 启动shell

# 页表

**术语**
+ PTE: Page Table Entry
+ PPN: Physical Page Nuber
+ TLB: Translation Look-aside Buffer

**页表用途**
1. 映射相同的内存到不同的地址空间
2. 用未映射的页面保护内核和用户栈

## 分页
> 内核将所有物理内存映射到其页表，因此可以直接对物理内存操作

### 虚拟地址转化步骤
1. `offset` 12位：一个页表是4096字节，可以用12位二进制数字表示
2. `index` 27位：每个PTE是8字节，一个页表可以储存512个PTE(9位)，index是三级页表(L1、L2、L3各9位)
3. `PPN` 44位：Sv39 RISC-V 仅用到44位物理页码
![虚拟地址转化成物理地址](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/vma2pma.png)
![RISC-V 地址转化](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/riscv_vma_translate.png)

### 内核使用
1. `satp`寄存器: 存放根页表页在内存中的地址
2. 每个 CPU 有独立的 `satp`寄存器，因此不同CPU的虚拟地址空间不同，但是使用同一个内核地址空间
3. 切换进程就需要修改`satp`寄存器 ?


### 常见标记位
+ `PTE_V`: PTE是否存在，0表示不合法
+ `PTE_R`: 是否可读
+ `PTE_W`: 是否可写
+ `PTE_X`: 是否可执行
+ `PTE_U`: 用户能否访问，0表示仅内核可访问

## 内核地址空间

![地址空间映射](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/va_space_2_pa_space.png)

1. 物理地址 `0x8000000` 以下: 保留了设备接口，作为内存映射控制寄存器暴露给软件，通过这些特殊的物理地址与设备交互
2. 内核的虚拟地址和物理地址一致，可以通过虚拟地址直接操作物理内存
    > 内核虚拟地址中非直接映射部分：
    > `trampoline page`: 虚拟地址最后一页
    > `guard page`: 进程的内核栈会有 guard page，防止栈溢出。不会映射到物理地址空间，PTE_V 不设置。
3. 内核会给每个进程分配一个内核栈
    > 内核栈是在系统启动的时候就创建好的吗？对应的内核一直没使用？

## 进程地址空间
![进程地址空间](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/riscv_process_addr_space.png)

1. 不同进程的页表将用户地址转换为物理内存的不同页面，因此进程的内存互相隔离
2. 进程的虚拟内存空间是连续的，对应的物理内存可以是非连续的
3. 将虚拟地址的最后一页映射到trampoline page，所有地址空间都有一个单独的物理内存页
4. 用户栈前一页是 guard page，防止栈溢出

# trap 和 系统调用
> cpu转交控制权: 系统调用、异常、设备中断，将其都称之为trap
> trap处理：CPU的硬件操作、汇编指令集、trap处理程序、设备驱动服务例程
> 三种trap来源：用户空间trap、内核空间trap、定时器中断
1. trap触发，转交控制权到内核
2. 内核保存寄存器和其他状态
3. 执行handler代码
4. 内核恢复寄存器和状态，返回到原来的代码

## trap机制

### 寄存器
> 仅内核态可以读取，每个CPU都有独立的寄存器
1. `stvec`: trap handler的地址
2. `sepc`: 保存程序计数器 `pc`，当trap恢复的时候，`sret`会将`sepc`赋值给`pc`
3. `scause`: trap来源的标志位
4. `sscratch`: trap handler使用
5. `sstatus`
    + `SIE`: 判断中断是否启用，通过清除`SIE`来禁用中断
    + `SPP`: 判断trap的来源，用户态 或 内核态

### trap硬件操作
1. 如果 trap 是设备中断，且`SIE`被清空，不执行任何操作
2. 清除`SIE`禁用中断
3. 将 `pc` 复制到 `sepc`
4. 将当前模式 (用户态、内核态) 保存在`sstatus`的`SPP`中
5. 设置`scause`标志位
6. 转换为内核模式
7. 把`stvec`复制到`pc`
8. 跳转到 `pc` 指令，开始执行

## 用户态trap
1. uservec: 保存用户寄存器(进程TRAPFRAME)
2. usertrap: 确定trap的来源分发到不同的handler，
3. usertrapret: 保留`stvec`，用于下一次trap，设置寄存器
4. userret: 切换页表至原来的页表

## 内核态trap
1. kernelvec: 保存所有寄存器(内核栈)、kerneltrap、恢复寄存器
2. kerneltrap: 分发任务、恢复`sepc`和`sstatus`
    + 异常：panic
    + 计时器中断：yield

## 页面错误异常
> 用户态异常，内核终止故障进程；内核态异常，panic

### 页面错误
> `scause`: 页面错误类型
> `stval`：无法翻译的地址
1. 加载页面错误
2. 存储页面错误
3. 指令页面错误

#### COW fork
1. 父子进程共享物理页面，但只读。
2. 进程存储页面异常：内核复制错误地址的页面，生成可读写副本。此时返回故障指令，就会使用副本的pte

#### lazy allocation
1. 用户态 sbrk 申请内存，此时申请的页表标记为无效。
2. 出现页面错误后，将页表映射到物理内存

#### 磁盘分页
1. 内存换出，保存到磁盘中。
2. 页面故障，将磁盘中存储的页面，读取到内存中。
3. 内存页满之后，需要换出内存页表

# 中断和设备驱动

## 控制台输入

### UART
1. 控制台驱动通过 UART串口，接收键入字符。QEMU模拟了UART硬件，连接到键盘和显示器
2. UART对于软件，可以看做内存映射的控制寄存器
3. `consoleinit`: 初始化UART硬件，对字节输入生成接收中断，对字节输出生成发送中断

## 定时器中断
1. 定时器中断来自每个CPU的时钟硬件
2. `timerinit`: 在一定延迟后生成中断、保存寄存器、使能定时器中断
3. `timervec`: 触发一次软件中断