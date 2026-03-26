#!/bin/bash
set -e

echo "🦞 ACT Gateway Installer for OpenClaw (Linux/macOS)"
echo "=================================================="

# 1. 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，请先安装 Python 3.10 或更高版本"
    exit 1
fi
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [[ "$PYTHON_VERSION" < "3.10" ]]; then
    echo "❌ Python 版本过低（$PYTHON_VERSION），需要 >=3.10"
    exit 1
fi
echo "✅ Python $PYTHON_VERSION 已安装"

# 2. 安装路径
INSTALL_DIR="$HOME/.act-gateway"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 3. 下载代码
if command -v git &> /dev/null; then
    echo "📥 使用 git 克隆代码..."
    git clone https://github.com/deepseek609609-collab/ACT-OpenClaw-Bridge.git
    CODE_DIR="$INSTALL_DIR/ACT-OpenClaw-Bridge"
else
    echo "📥 未找到 git，下载 zip 压缩包..."
    ZIP_URL="https://github.com/deepseek609609-collab/ACT-OpenClaw-Bridge/archive/refs/heads/main.zip"
    ZIP_FILE="$INSTALL_DIR/bridge.zip"
    curl -L -o "$ZIP_FILE" "$ZIP_URL"
    unzip -q "$ZIP_FILE" -d "$INSTALL_DIR"
    rm "$ZIP_FILE"
    CODE_DIR="$INSTALL_DIR/ACT-OpenClaw-Bridge-main"
fi
cd "$CODE_DIR"

# 4. 创建虚拟环境
echo "🐍 创建 Python 虚拟环境..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. 创建系统服务
if command -v systemctl &> /dev/null; then
    # Linux systemd (用户级)
    SERVICE_FILE="$HOME/.config/systemd/user/act-gateway.service"
    mkdir -p "$(dirname "$SERVICE_FILE")"
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=ACT Gateway for OpenClaw
After=network.target

[Service]
Type=simple
WorkingDirectory=$CODE_DIR
ExecStart=$CODE_DIR/venv/bin/python $CODE_DIR/act_gateway.py
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable act-gateway.service
    systemctl --user start act-gateway.service
    echo "✅ 已创建 systemd 用户服务并启动"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS launchd
    SERVICE_FILE="$HOME/Library/LaunchAgents/com.act-gateway.plist"
    cat > "$SERVICE_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.act-gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>$CODE_DIR/venv/bin/python</string>
        <string>$CODE_DIR/act_gateway.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$CODE_DIR/gateway.log</string>
    <key>StandardErrorPath</key>
    <string>$CODE_DIR/gateway.err</string>
</dict>
</plist>
EOF
    launchctl load "$SERVICE_FILE"
    launchctl start com.act-gateway
    echo "✅ 已创建 launchd 服务并启动"
else
    echo "⚠️ 无法识别操作系统，请手动启动服务："
    echo "   cd $CODE_DIR && source venv/bin/activate && python act_gateway.py &"
fi

# 6. 添加 OpenClaw 技能
SKILL_DIR="$HOME/.openclaw/workspace/skills/act-bridge"
mkdir -p "$SKILL_DIR"
cat > "$SKILL_DIR/SKILL.md" <<'EOF'
---
name: act-bridge
description: 安全执行工具（支持超时、限流、熔断）。通过 ACT Gateway 调用受控工具。
---

## 可用工具

- **天气查询**：`weather.get_current`，参数 `city`（字符串）
- **慢工具演示**：`weather.slow`
- **错误工具演示**：`weather.error`

## 调用方法

使用 `curl` 请求本地 ACT Gateway：

```bash
curl -s -X POST http://localhost:9000/act/dispatch \
  -H "Content-Type: application/json" \
  -d '{"intent": "weather.get_current", "params": {"city": "Beijing"}}'
```

返回结果中的 `payload` 即为所需数据。如果 `execution.status` 不是 `ok`，则根据 `error.code` 处理。

### 示例：查询天气
当用户询问天气时，使用 `weather.get_current` 工具，将城市名作为参数传入。
EOF
echo "✅ 已添加 OpenClaw 技能: $SKILL_DIR/SKILL.md"

# 7. 生成所有 ACT 工具的 OpenClaw 技能镜像
echo "🔄 生成 OpenClaw 技能镜像..."
cd "$CODE_DIR"
source venv/bin/activate
pip install act-kernel  # 确保 ACT Kernel 已安装
python act_openclaw_skill_mirror.py
echo "✅ 已生成所有 ACT 工具的 OpenClaw 技能镜像"

# 7. 测试服务
echo "🔍 等待服务启动..."
sleep 3
if curl -s http://localhost:9000/health > /dev/null; then
    echo "🎉 ACT Gateway 运行正常！"
else
    echo "⚠️ 服务可能尚未启动，请稍后手动检查：curl http://localhost:9000/health"
fi

echo ""
echo "=================================================="
echo "✨ 安装完成！"
echo ""
echo "现在你可以在 OpenClaw 中使用 ACT 技能了。"
echo "例如，在对话中说："使用 act-bridge 查询北京天气""
echo ""
echo "手动测试："
echo "  curl http://localhost:9000/health"
echo "  curl -X POST http://localhost:9000/act/dispatch -H 'Content-Type: application/json' -d '{\"intent\": \"weather.get_current\", \"params\": {\"city\": \"Beijing\"}}'"
echo ""
echo "查看日志："
if command -v systemctl &> /dev/null; then
    echo "  journalctl --user -u act-gateway -f"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  tail -f $CODE_DIR/gateway.log"
else
    echo "  $CODE_DIR/gateway.log"
fi
echo ""
echo "如需卸载，运行： curl -fsSL https://raw.githubusercontent.com/act-kernel/act-openclaw-bridge/main/uninstall.sh | bash"
