# ACT Gateway Installer for OpenClaw (Windows)
Write-Host "🦞 ACT Gateway Installer for OpenClaw (Windows)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. 检查 Python 3.10+
$pythonPath = (Get-Command python3 -ErrorAction SilentlyContinue).Source
if (-not $pythonPath) { $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source }
if (-not $pythonPath) {
    Write-Host "❌ Python 未安装。请安装 Python 3.10 或更高版本 (https://www.python.org/downloads/)" -ForegroundColor Red
    Write-Host "   安装时请勾选 'Add Python to PATH'" -ForegroundColor Red
    exit 1
}
$pythonVersion = & $pythonPath -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
if ($pythonVersion -lt "3.10") {
    Write-Host "❌ Python 版本过低（$pythonVersion），需要 >=3.10" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python $pythonVersion 已安装" -ForegroundColor Green

# 2. 安装路径
$installDir = "$env:USERPROFILE\.act-gateway"
if (Test-Path $installDir) {
    Write-Host "⚠️ 已存在安装目录，将重新安装..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $installDir
}
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Set-Location $installDir

# 3. 下载代码
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "📥 使用 git 克隆代码..." -ForegroundColor Cyan
    git clone https://github.com/act-kernel/act-openclaw-bridge.git
    $codeDir = "$installDir\act-openclaw-bridge"
} else {
    Write-Host "📥 未找到 git，下载 zip 压缩包..." -ForegroundColor Cyan
    $zipUrl = "https://github.com/act-kernel/act-openclaw-bridge/archive/refs/heads/main.zip"
    $zipFile = "$installDir\bridge.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $installDir -Force
    Remove-Item $zipFile
    $codeDir = "$installDir\act-openclaw-bridge-main"
}
Set-Location $codeDir

# 4. 创建虚拟环境
Write-Host "🐍 创建 Python 虚拟环境..." -ForegroundColor Cyan
& $pythonPath -m venv venv
$venvPython = "$codeDir\venv\Scripts\python.exe"
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r requirements.txt

# 5. 创建启动脚本（后台运行）
$startScript = @"
@echo off
cd /d $codeDir
start /B $venvPython act_gateway.py > gateway.log 2>&1
"@
$startScriptPath = "$codeDir\start_gateway.bat"
$startScript | Out-File -FilePath $startScriptPath -Encoding ASCII

# 6. 添加到用户启动项（开机自启）
$startupFolder = [Environment]::GetFolderPath('Startup')
$shortcutPath = "$startupFolder\ACT Gateway.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $startScriptPath
$shortcut.WorkingDirectory = $codeDir
$shortcut.Save()
Write-Host "✅ 已添加到启动项: $shortcutPath" -ForegroundColor Green

# 7. 启动服务
Write-Host "🚀 启动 ACT Gateway..." -ForegroundColor Cyan
Start-Process -NoNewWindow -FilePath $startScriptPath
Start-Sleep -Seconds 3

# 8. 创建 OpenClaw 技能
$skillDir = "$env:USERPROFILE\.openclaw\workspace\skills\act-bridge"
New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
$skillMd = @"
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
curl -s -X POST http://localhost:9000/act/dispatch `
  -H "Content-Type: application/json" `
  -d '{"intent": "weather.get_current", "params": {"city": "Beijing"}}'
```

返回结果中的 `payload` 即为所需数据。如果 `execution.status` 不是 `ok`，则根据 `error.code` 处理。

### 示例：查询天气
当用户询问天气时，使用 `weather.get_current` 工具，将城市名作为参数传入。
"@
$skillMd | Out-File -FilePath "$skillDir\SKILL.md" -Encoding utf8
Write-Host "✅ 已添加 OpenClaw 技能: $skillDir\SKILL.md" -ForegroundColor Green

# 9. 测试服务
Write-Host "🔍 测试服务状态..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9000/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "🎉 ACT Gateway 运行正常！" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 服务响应异常，请检查日志: $codeDir\gateway.log" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ 服务可能尚未就绪，请稍后手动检查: http://localhost:9000/health" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "✨ 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "现在你可以在 OpenClaw 中使用 ACT 技能了。" -ForegroundColor Cyan
Write-Host "例如，在对话中说："使用 act-bridge 查询北京天气"" -ForegroundColor Cyan
Write-Host ""
Write-Host "手动测试：" -ForegroundColor Cyan
Write-Host "  curl http://localhost:9000/health" -ForegroundColor Cyan
Write-Host "  curl -X POST http://localhost:9000/act/dispatch -H 'Content-Type: application/json' -d '{\"intent\": \"weather.get_current\", \"params\": {\"city\": \"Beijing\"}}'" -ForegroundColor Cyan
Write-Host ""
Write-Host "如需卸载，运行： .\uninstall.ps1" -ForegroundColor Cyan
