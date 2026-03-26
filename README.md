# ACT Gateway – 一键安装为 OpenClaw 提供安全执行层

[![PyPI version](https://badge.fury.io/py/act-kernel.svg)](https://pypi.org/project/act-kernel/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**ACT Gateway** 是一个轻量级 HTTP 服务，将 [ACT Kernel](https://github.com/act-kernel/act-kernel) 暴露给 [OpenClaw](https://github.com/openclaw/openclaw) 或其他 Agent 框架，为工具调用提供**超时、重试、限流、熔断、统一返回格式**等生产级能力。

## 一键安装

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/act-kernel/act-openclaw-bridge/main/install.sh | bash
```

### Windows (PowerShell 管理员)
```powershell
powershell -ExecutionPolicy Bypass -Command "& { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/act-kernel/act-openclaw-bridge/main/install.ps1' -OutFile install.ps1; .\install.ps1 }"
```

## 功能
- ✅ 自动检测并安装 Python 3.10+ 虚拟环境
- ✅ 后台运行 ACT Gateway（开机自启）
- ✅ 为 OpenClaw 自动添加 `act-bridge` 技能
- ✅ 演示工具：天气查询、超时、限流、熔断
- ✅ 统一返回格式，便于监控和成本控制

## 验证安装

检查服务健康状态：
```bash
curl http://localhost:9000/health
```

测试工具调用：
```bash
curl -X POST http://localhost:9000/act/dispatch \
  -H "Content-Type: application/json" \
  -d '{"intent": "weather.get_current", "params": {"city": "Beijing"}}'
```

## 在 OpenClaw 中使用

安装完成后，你的 OpenClaw 已自动获得 `act-bridge` 技能。在支持技能的频道中，直接让助手调用即可：

> "使用 act-bridge 查询北京天气"

## 卸载

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/act-kernel/act-openclaw-bridge/main/uninstall.sh | bash
```

### Windows
```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/act-kernel/act-openclaw-bridge/main/uninstall.ps1' -OutFile uninstall.ps1; .\uninstall.ps1
```

## 自定义配置

如需修改端口、限流参数等，编辑 `~/.act-gateway/act-openclaw-bridge/act_gateway.py` 中的工具元数据，然后重启服务。

## 更多信息

- [ACT Kernel 文档](https://github.com/act-kernel/act-kernel)
- [OpenClaw 集成指南](docs/openclaw_skill_example.md)
