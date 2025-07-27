---
title: mwait
date: 2024-11-24 13:33:26
categories: linux
tags:
    - linux
    - kvm
---

# mwait 指令
> A hint that allows the processor to stop instruction execution and enter an implementation-dependent optimized state until occurrence of a class of events.
> MWAIT instruction provides hints to allow the processor to enter an implementation-dependent optimized state. There are two principal targeted usages: address-range monitor and advanced power management. Both usages of MWAIT require the use of the MONITOR instruction.

‌MWAIT是一种CPU处理器指令，主要用于让CPU进入低功耗状态以节省能源，并等待一些事件的发生‌。当CPU使用MWAIT指令时，它可以在不消耗太多能源的情况下监控外部设备的事件，如外部设备的中断或唤醒信号。这种方式不仅节省了电力，还能提高系统的响应速度，因为CPU不必频繁地从低功耗状态中唤醒‌。


# 内核如何使用？

X86_FEATURE_MWAIT (arch/x86/include/asm/cpufeatures.h)

mwait实现 -> arch/x86/include/asm/mwait.h

mwait_idle_with_hints

intel-idle

arch/x86/kernel/process.c


``` c
/*
 * MONITOR/MWAIT with no hints, used for default C1 state. This invokes MWAIT
 * with interrupts enabled and no flags, which is backwards compatible with the
 * original MWAIT implementation.
 */
static __cpuidle void mwait_idle(void)
{
	if (!current_set_polling_and_test()) {
		if (this_cpu_has(X86_BUG_CLFLUSH_MONITOR)) {
			mb(); /* quirk */
			clflush((void *)&current_thread_info()->flags);
			mb(); /* quirk */
		}

		__monitor((void *)&current_thread_info()->flags, 0, 0);
		if (!need_resched()) {
			__sti_mwait(0, 0);
			raw_local_irq_disable();
		}
	}
	__current_clr_polling();
}


struct thread_info {
	unsigned long		flags;		/* low level flags */
	unsigned long		syscall_work;	/* SYSCALL_WORK_ flags */
	u32			status;		/* thread synchronous flags */
#ifdef CONFIG_SMP
	u32			cpu;		/* current CPU */
#endif
};
```


# KVM 支持虚机mwait


kvm_emulate_mwait

kvm_emulate_monitor_mwait


kvm_vm_ioctl_enable_cap

vmx_exec_control

EXIT_REASON_MWAIT_INSTRUCTION

# 参考
[mwait指令](https://www.felixcloutier.com/x86/mwait)