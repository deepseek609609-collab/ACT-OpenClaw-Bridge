#!/bin/bash
set -e

echo "🗑️ 卸载 ACT Gateway"

# 停止并移除服务
if command -v systemctl &> /dev/null; then
    systemctl --user stop act-gateway.service || true
    systemctl --user disable act-gateway.service || true
    rm -f "$HOME/.config/systemd/user/act-gateway.service"
    systemctl --user daemon-reload
elif [[ "$OSTYPE" == "darwin"* ]]; then
    launchctl unload "$HOME/Library/LaunchAgents/com.act-gateway.plist" || true
    rm -f "$HOME/Library/LaunchAgents/com.act-gateway.plist"
fi

# 删除安装目录
rm -rf "$HOME/.act-gateway"

# 删除 OpenClaw 技能
rm -rf "$HOME/.openclaw/workspace/skills/act-bridge"

echo "✅ 卸载完成"
