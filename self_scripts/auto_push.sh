message=$1
time=$(date +"%Y-%m-%d %H:%M:%S")
commit_message="update posts at $time.$message"

# 添加文件到暂存区
git add -A
echo "git add done"

# 创建提交
git commit -m "$commit_message"
if [ $? -ne 0 ]; then
    exit 0
fi
echo "git commit done"

# pull remote
git pull --rebase
if [ $? -ne 0 ]; then
    exit 0
fi
echo "git pull done"

# 推送到GitHub
git push
echo "git push done"
