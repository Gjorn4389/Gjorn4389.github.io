---
title: bond
date: 2024-8-16 13:33:26
categories: linux
tags:
    - linux
    - bond
---

# mux machine状态机变化

![mux_machine](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/bond_3ad_mux_machine.png)


1)         LACP_Activity: 端口在链路控制中的主从状态，0表示Passive, 1表示Active。

2)         LACP_Timeout: 超时时间，0表示长超时，1表示短超时

3)         Aggregation: 表示端口的聚合能力。 TRUE(1)表示链路是可聚合的，FALSE(0)表示链路是独立链路，不可聚合

4)         Synchronization: 表示端口当前聚合是否完成。TRUE(1)表示发送的链路处于IN_SYNC状态，即端口已被分配到正确的聚合组中， FALSE(0)表示链路为OUT_OF_SYNC状态，即端口还没有选择正确的聚合组

5)         Collecting: TRUE(1)表示当前链路收包enable, 否则为FALSE(0)

6)         Distributing: TRUE(1)表示当前链路发包enable, 否则为FALSE(0)

7)         Defaulted： TRUE(1)表示Actor使用的Partner信息来自管理员配置的默认值。FALSE(0)表示Actor使用的Partner信息来自接收的LACPDU

8)         Expired: TRUE(1)表示Actor RX状态机处于超时状态，否则不在超时状态。

![port_variables_definition](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/bond_3ad_port_valiables_def.png)


1. AD_MUX_DETACHED -> AD_MUX_WAITING: AD_PORT_SELECTED == True || AD_PORT_STANDBY == True
2. AD_MUX_WAITING -> AD_MUX_DETACHED: SELECTED == FALSE
3. AD_MUX_WAITING -> AD_MUX_ATTACHED
    1. port->sm_vars |= AD_PORT_READY_N
    2. 该 aggregator 的所有 Port都READY_N了  ====> AD_PORT_READY
4. AD_MUX_ATTACHED -> AD_MUX_DETACHED
5. AD_MUX_DISTRIBUTING ->


如果前后状态不一致：`port->ntt = true;`  表明需要发送报文

修改actor_oper_port_state，告知交换机当前端口的状态


LACP_STATE_SYNCHRONIZATION    说明agg是active的

## AD_MUX_DETACHED

## AD_MUX_WAITING

## AD_MUX_ATTACHED

## AD_MUX_COLLECTING_DISTRIBUTING

## AD_MUX_COLLECTING

## AD_MUX_DISTRIBUTING



一般的流程
AD_MUX_DETACHED  ->  AD_MUX_WAITING   -> AD_MUX_ATTACHED  -> AD_MUX_COLLECTING_DISTRIBUTING