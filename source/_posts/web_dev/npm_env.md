---
title: npm env docker
date: 2025-8-3 15:33:26
categories: Web
tags:
    - docker
    - env
---

# 部署docker

1. 新建容器: `docker run -itd --name npm_dev -v /srv/docker/npm/dev_env:/root/env -w /root/env -p 5555:5555 ubuntu`
2. 安装npm、nodejs: `apt install -y nodejs npm`
