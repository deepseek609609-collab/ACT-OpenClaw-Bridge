# Uninstall ACT Gateway (Windows)
Write-Host "🗑️ 卸载 ACT Gateway" -ForegroundColor Cyan

# 停止并移除启动项
$startupFolder = [Environment]::GetFolderPath('Startup')
$shortcutPath = "$startupFolder\ACT Gateway.lnk"
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
    Write-Host "✅ 已移除启动项" -ForegroundColor Green
}

# 终止进程
$gatewayProcess = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*act-gateway*" -or $_.CommandLine -like "*act_gateway.py*" }
if ($gatewayProcess) {
    $gatewayProcess | Stop-Process -Force
    Write-Host "✅ 已终止 ACT Gateway 进程" -ForegroundColor Green
}

# 删除安装目录
$installDir = "$env:USERPROFILE\.act-gateway"
if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
    Write-Host "✅ 已删除安装目录" -ForegroundColor Green
}

# 删除 OpenClaw 技能
$skillDir = "$env:USERPROFILE\.openclaw\workspace\skills\act-bridge"
if (Test-Path $skillDir) {
    Remove-Item -Recurse -Force $skillDir
    Write-Host "✅ 已删除 OpenClaw 技能" -ForegroundColor Green
}

Write-Host "✅ 卸载完成" -ForegroundColor Green
