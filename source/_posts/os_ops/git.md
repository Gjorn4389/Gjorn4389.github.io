---
title: git
date: 2025-7-27 13:33:26
categories: utils
tags:
    - git
---

# 多仓库版本控制
> 从官方仓库fork了一个仓库，但是想要做自己的修改

1. 获取项目代码: `git clone <official_repo_url>`
2. 增加个人上游仓库: `git remote add <remote_name> <git_url>`
3. 重命名: `git remote rename <old_name> <new_name>`

![git_remote](https://raw.githubusercontent.com/Gjorn4389/Gjorn4389.github.io/source/images/git_remote.png)

# github不能使用密码fetch/pull
> remote: Invalid username or token. Password authentication is not supported for Git operations.
fatal: Authentication failed for

1. 生成一个 Token
    > Settings / Developer Settings / Personal access tokens / Tokens(classic)
2. 使用用户名和凭据存储
    + `git config --global credential.helper store`
    + `git push -u origin HEAD`: 输入 Gjorn、Token

# 全局.gitignore
`git config --global core.excludesfile ~/.gitignore_global`

# git lfs
> 管理大文件
