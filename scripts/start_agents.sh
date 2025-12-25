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
else
    echo "Warning: .env file not found. Ensure environment variables are set manually."
fi

# 检查必要的环境变量
MISSING_VARS=0
if [ -z "$LLM_API_KEY" ]; then
    echo "Error: LLM_API_KEY is not set."
    MISSING_VARS=1
fi
if [ -z "$LLM_MODEL_NAME" ]; then
    echo "Error: LLM_MODEL_NAME is not set."
    MISSING_VARS=1
fi
if [ -z "$LLM_API_BASE" ]; then
    echo "Error: LLM_API_BASE is not set."
    MISSING_VARS=1
fi

if [ $MISSING_VARS -eq 1 ]; then
    echo "Please set the missing environment variables in .env file."
    exit 1
fi

echo "Starting PlanWeaver Network..."

# 启动网络节点
if [ -f network.yaml ]; then
    echo "Starting network node..."
    openagents network start --detach
else
    echo "Error: network.yaml not found in $(pwd)"
    exit 1
fi

# 等待网络节点启动
echo "Waiting for network to initialize..."
sleep 3

# 启动所有 Agent
echo "Starting agents..."
for agent_file in agents/*.yaml; do
    agent_name=$(basename "$agent_file" .yaml)
    echo "Starting $agent_name..."
    openagents agent start "$agent_file" --detach
done

echo "---------------------------------------------------"
echo "✅ All components started successfully!"
echo "You can view the logs in separate terminal sessions or use 'openagents studio' to inspect the network."
echo "To stop the agents, you may need to kill the processes manually or use 'pkill -f openagents'."
