---
title: docker
date: 2025-8-3 15:33:26
categories: utils
tags:
    - docker
---

# docker 基本命令

## 进入容器：
1. `docker exec -it xv6-env /bin/bash`: 在容器中开启一个新的终端
    ```shell
    # install `fzf`, dsh + Tab to insert docker name
    function dsh() {
        local container=${1:-$(docker ps --format '{{.Names}}' | fzf)}
        if [ -n "$container" ]; then
            docker exec -it "$container" /bin/bash
        else
            echo "No container selected."
        fi
    }
    ```
2. `docker attach xv6-env`: 进入容器当前执行的终端


# docker-compose

## 安装
> ~~`apt install -y docker-cpmpose`~~
> Python 3.12中移除了 `disutils`模块，导致docker-compose异常：`apt install python3-distutils`

```shell
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

# 常用命令
1. 启动服务: `docker-compose up -d`
2. 停止服务: `docker-compose stop`
3. 删除服务: `docker-compose down`
4. 重启服务: `docker-compose restart`
5. 查看日志: `docker-compose logs`
6. 进入容器: `docker-compose exec <container_name> /bin/bash`
7. 查看容器状态: `docker-compose ps`
8. 构建并启动: `docker-compose up --build -d`


