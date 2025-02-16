#!/bin/bash

# 启动 Flutter Web 服务器并指定端口
flutter run -d web-server --web-port=8081 &

# 获取 Flutter Web 服务器的进程ID
SERVER_PID=$!

# 等待几秒钟确保服务器已经启动
sleep 5

# 获取 Flutter Web 服务器的 URL
URL="http://localhost:8081"

# 使用 osascript 在已打开的 Chrome 窗口中打开 URL
osascript -e "tell application \"Google Chrome\" to open location \"$URL\""
