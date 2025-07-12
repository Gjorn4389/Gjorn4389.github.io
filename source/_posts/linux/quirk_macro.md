---
title: quirk macro
date: 2025-7-12 13:33:26
categories: linux
tags:
    - linux
    - kernel 6.15
---

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

# Reference
[container_of 函数详解](https://blog.csdn.net/u011029104/article/details/136190755)

