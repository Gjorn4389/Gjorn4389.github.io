---
title: libvirt event
date: 2024-2-27 13:33:26
categories: libvirt
tags:
    - libvirt
    - event
---

# Event 事件机制

## 事件注册

### virEventRegisterDefaultImpl
1. 基于 poll 的事件注册
2. 必须使用 virEventRunDefaultImpl 来处理事件

### 注册Event的方法 virevent.c

|-- virEventGLibRegisterOnce
|-- virEventRegisterImpl: 注册了 HandleAdd、HandleUpdate、HandleRemove、TimeoutAdd、TimeoutUpdate、TimeoutRemove

+ fd相关的handler
    + virEventAddHandle
    + virEventUpdateHandle
    + virEventRemoveHandle
+ virConnectDomainEventRegisterAny() 类似的接口需要注册以下3个Timeout函数
    + virEventAddTimeout
    + virEventUpdateTimeout
    + virEventRemoveTimeout

**vireventglib.c** 定义glic实现的event操作函数

### 调用方法函数
1. virConnectDomainEventRegisterAny: 增加回调函数用于处理事件
    + 需要使用 VIR_DOMAIN_EVENT_CALLBACK() 宏强制转换提供的函数指针，以匹配此方法的签名
    + virDomainPtr 只在回调函数执行期间有效，要保留对象，就需要 virDomainRef() 获取对域对象的引用
2. virConnectDomainEventDeregisterAny: 移除事件回调
3. virConnectDomainEventRegister: 添加回调接受虚机生命周期通知
4. virConnectDomainEventDeregister: 删除回调函数
5. virDomainEventID: 事件id
6. virDomainEventType: 事件类型


## 事件处理

### 注册事件处理函数

domainEventCallbacks[]


qemuProcessEventHandler ：添加线程池工作函数



### 分发 event，定时处理
|-- virEventAddTimeout(virObjectEventTimer, ...)
    |-- virObjectEventStateFlush
        |-- virObjectEventStateQueueDispatch(state, tempQueue, state->callbacks)
            |-- virObjectEventStateDispatchCallbacks                           <---- 找合适的callback，处理event
                |-- virObjectEventDispatchMatchCallback
                |-- event->dispatch(cb->conn, event, cb->cb, cb->opaque);      <---- callback处理事件
        |-- virObjectEventCallbackListPurgeMarked(state->callbacks);
        |-- virObjectEventStateCleanupTimer


## 创建 DeviceAdded Event Class
VIR_CLASS_NEW(virDomainEventDeviceAdded, virDomainEventClass)
![virDomainEventDeviceAddedClass](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/virDomainEventDeviceAddedClass.png)

event->dispatch 一般都是 virDomainEventDispatchDefaultFunc 根据 event_id 分发，执行对应的函数
![event->dispatch](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/virObjectEvent_dispatch.png)

VIR_DOMAIN_EVENT_ID_DEVICE_ADDED  <============>  virConnectDomainEventDeviceAddedCallback
