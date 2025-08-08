---
title: deploy Ollama
date: 2025-8-2 13:33:26
categories: ai
tags:
    - ai
    - Ollama
---

# docker 部署Ollama
> [ollama + ollama webui](https://zhuanlan.zhihu.com/p/7463632184)


1. 创建容器目录: `mkdir /srv/docker/ollama`
2. 创建容器: `docker run -d --gpus=all --name ollama -v /srv/docker/ollama:/root/.ollama -p 11434:11434 ollama/ollama`
3. 进入容器: `docker exec -it ollama /bin/bash`
4. 验证: `ollama`

## 使用 open-webui 访问ollama容器
创建`open-webui`容器: `docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v /srv/docker/open_webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main`

## 单容器部署 open-webui + ollama
创建聚合容器: `docker run -d -p 3000:8080 --gpus=all -v /srv/docker/ollama:/root/.ollama -v /srv/docker/open_webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama`


# 换源

## 修改config
```shell
cat << EOF > ~/.ollama/config.json
{
    "registry": {
        "mirrors": {
            "registry.ollama.ai": "https://registry.ollama.ai"
        }
    }
}
EOF
```
## 下载魔搭社区镜像
`ollama pull modelscope.cn/unsloth/Mistral-Small-3.1-24B-Instruct-2503-GGUF`

## 命令行制定镜像源
`ollama run deepseek-r1:7b --registry-mirror https://registry.ollama.ai`


# 指定量化
`ollama run modelscope2ollama-registry.azurewebsites.net/qwen/Qwen2.5-7B-Instruct-gguf:Q8_0`

# 指定模板
`ollama run modelscope2ollama-registry.azurewebsites.net/qwen/Qwen2.5-7B-Instruct-gguf:Q8_0--qwen2`