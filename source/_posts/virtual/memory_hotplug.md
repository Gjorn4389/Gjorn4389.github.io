---
title: Memory Hotplug
date: 2024-2-27 13:33:26
categories: libvirt
tags:
    - libvirt
    - hotplug
    - memory
---

# 热插内存主要流程

## 注册 callback
virConnectDomainEventRegisterAny
|-- qemuConnectDomainEventRegisterAny
    |-- virDomainEventStateRegisterID(conn, driver->domainEventState, ...)
        |-- virObjectEventStateRegisterID
            |-- virEventAddTimeout(-1, **virObjectEventTimer**, state)
            |-- virObjectEventCallbackListAddID                 <--- 在conn中添加callback



## 添加事件
|-- qemuDomainAttachDeviceLiveAndConfig
|-- qemuDomainAttachDeviceLive
|-- qemuDomainAttachMemory
    |-- virDomainMemoryInsert
    |-- event = virDomainEventDeviceAddedNewFromObj(vm, objalias);      构造event
        |-- virDomainEventDeviceAddedClass, **VIR_DOMAIN_EVENT_ID_DEVICE_ADDED**
    |-- virObjectEventStateQueue(**driver->domainEventState**, event);      等待分发
        |-- virObjectEventStateQueueRemote
            |-- virObjectEventQueuePush


## 分发事件
|-- virObjectEventTimer
|-- virObjectEventStateFlush   <--- Timer 到期之后会将调用该函数
    |-- virEventUpdateTimeout
    |-- virObjectEventStateQueueDispatch
        |-- virObjectEventStateDispatchCallbacks
            |-- 在callback池中找匹配的event_id，确定event对应的callback
            |-- event->dispatch(cb->conn, event, cb->cb, cb->opaque);
    |-- virObjectEventCallbackListPurgeMarked
    |-- virObjectEventStateCleanupTimer


## 调用callback的流程

```c
{
    REMOTE_PROC_DOMAIN_EVENT_CALLBACK_DEVICE_ADDED,
    remoteDomainBuildEventCallbackDeviceAdded,
    sizeof(remote_domain_event_callback_device_added_msg),
    (xdrproc_t)xdr_remote_domain_event_callback_device_added_msg
}
```

## 事件的callback注册
static virNetClientProgramEvent remoteEvents[]

|-- remoteDomainBuildEventCallbackDeviceAdded
    |-- virDomainEventDeviceAddedNewFromDom
        |-- virDomainEventDeviceAddedNew
        |-- virDomainEventNew
        |-- virObjectEventNew(klass, **virDomainEventDispatchDefaultFunc**, ...)  <--- 这里注册了一个分发函数，找到对应的处理函数
    |-- virObjectEventStateQueueRemote

