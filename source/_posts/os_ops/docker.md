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
3. `sudo chown -R $USER:$USER [PATH]`：修改文件所有权


# 安装docker开发环境
1. 安装docker，按照docker官网查看就行
```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
2. 换国内源:
    + `vim /etc/docker/daemon.json`
        ```json
        {
            "registry-mirrors": [
                "http://hub-mirror.c.163.com",
                "https://mirror.aliyuncs.com",
                "https://docker.mirrors.ustc.edu.cn"
            ]
        }
        ```
    + systemctl restart docker
3. 用户添加docker权限，把用户添加到到docker组
```shell
sudo groupadd docker            #添加docker用户组
sudo gpasswd -a $USER docker    #将登陆用户加入到docker用户组中
sudo newgrp docker              #更新用户组
```
4. 安装vscode的扩展

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


