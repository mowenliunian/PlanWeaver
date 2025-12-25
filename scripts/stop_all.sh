#!/bin/bash

# 确保脚本在项目根目录下执行
cd "$(dirname "$0")/.."

echo "Stopping PlanWeaver..."
echo ""

# 停止 Network
if pgrep -f 'openagents network start' >/dev/null; then
    echo "Stopping network..."
    pkill -f 'openagents network start'
fi

# 使用 PID 文件停止 Agents
stopped=0
for pid_file in pids/*.pid; do
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        agent_name=$(basename "$pid_file" .pid)

        if ps -p "$pid" >/dev/null 2>&1; then
            echo "Stopping $agent_name (PID: $pid)..."
            kill "$pid"
            rm "$pid_file"
            stopped=$((stopped + 1))
        else
            echo "$agent_name (PID: $pid) already stopped"
            rm "$pid_file"
        fi
    fi
done

# 如果没有 PID 文件，尝试强制杀死进程
if [ $stopped -eq 0 ]; then
    pkill -f 'openagents agent start'
fi

# 清理 PID 目录
if [ -d pids ] && [ -z "$(ls -A pids)" ]; then
    rmdir pids
fi

echo "---------------------------------------------------"
echo "✅ PlanWeaver stopped!"
echo ""
