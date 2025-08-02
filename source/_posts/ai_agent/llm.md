---
title: deploy llm
date: 2025-8-2 13:33:26
categories: ai
tags:
    - ai
    - llm
---

# 部署Qwen-7B-Chat
> [官网文档](https://help.aliyun.com/zh/alinux/use-an-ai-container-image-to-deploy-qwen-7b-chat-on-nvidia-gpu-accelerated-instances)

1. 创建PyTorch AI容器
    ```shell
    sudo docker pull ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/pytorch:2.2.0.1-3.2304-cu121
    sudo docker run -itd --name pytorch --gpus all --net host -v $HOME/workspace:/workspace \
    ac2-registry.cn-hangzhou.cr.aliyuncs.com/ac2/pytorch:2.2.0.1-3.2304-cu121
    ```
2. 进入容器环境: `sudo docker exec -it -w /workspace pytorch /bin/bash`
3. 启动聊天机器人: `cd /workspace/Qwen; python3 cli_demo.py -c ../qwen-7b-chat`