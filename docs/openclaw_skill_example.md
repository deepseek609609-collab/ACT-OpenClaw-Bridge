# 在 OpenClaw 中手动创建 ACT 技能

如果一键安装未自动添加技能，可以手动创建。

1. 创建技能目录：
   ```bash
   mkdir -p ~/.openclaw/workspace/skills/act-bridge
   ```

2. 创建 `SKILL.md` 文件，内容参考上文。

3. 重启 OpenClaw Gateway：
   ```bash
   openclaw gateway --restart
   ```
