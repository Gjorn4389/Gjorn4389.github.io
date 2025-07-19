---
title: quirk macro
date: 2025-7-12 13:33:26
categories: linux
tags:
    - linux
    - kernel 6.15
---
> 知乎问题：[Linux kernel中有哪些奇技淫巧](https://www.zhihu.com/question/471637144/answer/124475482866) 有感

# container_of 根据成员变量地址求结构体首地址
> 文件位置：[include/linux/container_of.h](https://github.com/torvalds/linux/blob/v6.15/include/linux/container_of.h)

```c
#define typeof_member(T, m)	typeof(((T*)0)->m)

/**
 * container_of - cast a member of a structure out to the containing structure
 * @ptr:	the pointer to the member.
 * @type:	the type of the container struct this is embedded in.
 * @member:	the name of the member within the struct.
 *
 * WARNING: any const qualifier of @ptr is lost.
 */
#define container_of(ptr, type, member) ({				\
	void *__mptr = (void *)(ptr);					\
	static_assert(__same_type(*(ptr), ((type *)0)->member) ||	\
		      __same_type(*(ptr), void),			\
		      "pointer type mismatch in container_of()");	\
	((type *)(__mptr - offsetof(type, member))); })
```

## `static_assert` 编译时检查常量表达式
> 文件位置：[include/linux/build_bug.h](https://github.com/torvalds/linux/blob/v6.15/include/linux/build_bug.h)
```c
#define static_assert(expr, ...) __static_assert(expr, ##__VA_ARGS__, #expr)
#define __static_assert(expr, msg, ...) _Static_assert(expr, msg)
```

检查常量表达式`expr`，编译失败则输出`msg`

当前场景就是判断`__same_type(*(ptr), ((type *)0)->member) || __same_type(*(ptr), void)`


## `__same_type` 检查两个参数是否是同种类型
> 文件位置：[include/linux/compiler_types.h](https://github.com/torvalds/linux/blob/v6.15/include/linux/compiler_types.h)
```c
/* Are two types/vars the same type (ignoring qualifiers)? */
#define __same_type(a, b) __builtin_types_compatible_p(typeof(a), typeof(b))
```

## `((type *)0)->member` 获取成员member的类型
1. `a->member` 代表是a结构体的member变量的地址，即指针a的地址 + member成员变量在结构体中的偏移量
2. 若`a = 0`，那么就是 member成员变量在结构体的地址
3. `((type *)0)->member` 可以直接获取结构体 type 的成员member的类型

## `offsetof` 获取成员member的偏移量
> 文件位置: [include/linux/stddef.h](https://github.com/torvalds/linux/blob/v6.15/include/linux/stddef.h)
```c
#define offsetof(TYPE, MEMBER)	__builtin_offsetof(TYPE, MEMBER)

/* old version in kernel */
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *) 0)->MEMBER)
```

# 链表 List
> 文件位置: [include/linux/list.h](https://github.com/torvalds/linux/blob/v6.15/include/linux/list.h)

## 内存屏障
> [tools/arch/x86/include/asm/barrier.h](https://github.com/torvalds/linux/blob/v6.15/tools/arch/x86/include/asm/barrier.h)

1. 防止编译器优化
2. 保证内存可见性
3. 防止指令重排序

```c
#define mb()	asm volatile("mfence" ::: "memory")
#define rmb()	asm volatile("lfence" ::: "memory")
#define wmb()	asm volatile("sfence" ::: "memory")
#define smp_rmb() barrier()
#define smp_wmb() barrier()
#define smp_mb()  asm volatile("lock; addl $0,-132(%%rsp)" ::: "memory", "cc")
```

## WRITE_ONCE 写入变量
> 文件位置: [tools/include/linux/compiler.h](https://github.com/torvalds/linux/blob/v6.15/tools/include/linux/compiler.h)

>为什么需要 WRITE_ONCE
>1. 防止编译器优化：编译器可能将单个写入拆分成多次访问，这在并发环境中会导致问题
>2. 保证写入完整性：确保写入操作不会被中断
>3. 内存可见性：确保写入对其他CPU核心立即可见

`union { typeof(x) __val; char __c[1]; }`: 即是数据val、又是指针c，因为是`union`

```c
#define WRITE_ONCE(x, val)				\
({							\
	union { typeof(x) __val; char __c[1]; } __u = { .__val = (val) }; 	\
	__write_once_size(&(x), __u.__c, sizeof(x));	\
	__u.__val;					\
})

static __always_inline void __write_once_size(volatile void *p, void *res, int size)
{
	switch (size) {
	case 1: *(volatile  __u8_alias_t *) p = *(__u8_alias_t  *) res; break;
	case 2: *(volatile __u16_alias_t *) p = *(__u16_alias_t *) res; break;
	case 4: *(volatile __u32_alias_t *) p = *(__u32_alias_t *) res; break;
	case 8: *(volatile __u64_alias_t *) p = *(__u64_alias_t *) res; break;
	default:
		barrier();
		__builtin_memcpy((void *)p, (const void *)res, size);
		barrier();
	}
}
```

## READ_ONCE 读取变量
```c
#define READ_ONCE(x)					\
({							\
	union { typeof(x) __val; char __c[1]; } __u = { .__c = { 0 } };			\
	__read_once_size(&(x), __u.__c, sizeof(x));	\
	__u.__val;					\
})
```

## 初始化链表头
> 链表头是一个空节点，没有含义
```c
#define LIST_HEAD_INIT(name) { &(name), &(name) }
#define LIST_HEAD(name) struct list_head name = LIST_HEAD_INIT(name)

static inline void INIT_LIST_HEAD(struct list_head *list)
{
	WRITE_ONCE(list->next, list);
	WRITE_ONCE(list->prev, list);
}
```


# kfifo: 无锁环形队列

# 读写信号量、RCU

# 静态分支预测、jump table


# kthread_run

# CFS调度器

# Reference
[container_of 函数详解](https://blog.csdn.net/u011029104/article/details/136190755)

