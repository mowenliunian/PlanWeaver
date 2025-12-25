#!/bin/bash

# 确保脚本在项目根目录下执行
cd "$(dirname "$0")/.."

# 检查 conda 环境
if [[ "$CONDA_DEFAULT_ENV" != "openagents" ]]; then
    echo "Warning: It seems you are not in 'openagents' conda environment."
    echo "Please run 'conda activate openagents' first if you encounter issues."
fi

# 加载环境变量
if [ -f .env ]; then
    echo "Loading environment variables from .env..."
    set -a
    source .env
    set +a
    export DEEPSEEK_API_KEY
else
    echo "Warning: .env file not found. Ensure DEEPSEEK_API_KEY is set manually."
fi

# 检查必要的环境变量
if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "Error: DEEPSEEK_API_KEY is not set."
    echo "Please set DEEPSEEK_API_KEY in .env file."
    exit 1
fi

# 创建必要的目录
mkdir -p logs pids

echo "Starting PlanWeaver..."
echo ""

# 检查网络是否已运行
if curl -s http://localhost:8700 >/dev/null 2>&1; then
    echo "Network is already running at http://localhost:8700"
    echo "Skipping network startup..."
    echo ""
else
    # 启动网络（后台运行）
    echo "Starting network..."
    openagents network start network.yaml > logs/network.log 2>&1 &
    NETWORK_PID=$!
    echo $NETWORK_PID > pids/network.pid
    sleep 3
fi

# 启动所有 Agent
echo "Starting agents in background..."
for agent_file in agents/*.yaml; do
    agent_name=$(basename "$agent_file" .yaml)
    echo "  Starting $agent_name..."
    openagents agent start "$agent_file" > "logs/${agent_name}.log" 2>&1 &
    echo $! > "pids/${agent_name}.pid"
done

echo ""
echo "---------------------------------------------------"
echo "✅ PlanWeaver started!"
echo ""
echo "Network:  http://localhost:8700"
echo "Studio:   Run 'openagents studio -s' in another terminal"
echo "Logs:     logs/"
echo "PIDs:     pids/"
echo ""
echo "To stop: bash scripts/stop_all.sh"
echo ""
