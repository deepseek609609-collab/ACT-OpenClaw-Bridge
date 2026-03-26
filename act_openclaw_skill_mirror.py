#!/usr/bin/env python3
"""
OpenClaw Skill Mirror – 将 ACT 工具注册表导出为 OpenClaw 技能目录
"""

import os
import json
from pathlib import Path
from typing import Dict, Any

def export_skills(kernel, output_dir: str = None):
    """
    遍历 ACT 内核注册表，为每个工具生成 OpenClaw 技能目录和 SKILL.md

    Args:
        kernel: ACTKernel 实例
        output_dir: OpenClaw workspace skills 目录，默认 ~/.openclaw/workspace/skills
    """
    if output_dir is None:
        output_dir = Path.home() / ".openclaw" / "workspace" / "skills"
    else:
        output_dir = Path(output_dir).expanduser()
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    for (tool_name, action), meta in kernel.registry._metadata.items():
        skill_name = f"act_{tool_name}_{action}"
        skill_dir = output_dir / skill_name
        skill_dir.mkdir(parents=True, exist_ok=True)
        
        # 生成 SKILL.md
        parameters = meta.get("parameters", {})
        param_example = {}
        if "properties" in parameters:
            # 取第一个属性作为示例
            first_prop = next(iter(parameters["properties"]), None)
            if first_prop:
                param_example = {first_prop: "example_value"}
        
        skill_md = f"""---
name: {skill_name}
description: {meta.get('description', f'Call {tool_name}.{action} via ACT Gateway')}
---

## 概述
此技能通过 ACT Gateway 调用 `{tool_name}.{action}` 工具。

## 调用方法
使用 `curl` 请求本地 ACT Gateway：

```bash
curl -s -X POST http://localhost:9000/act/dispatch \\
  -H "Content-Type: application/json" \\
  -d '{{
    "intent": "{tool_name}.{action}",
    "params": {json.dumps(param_example, indent=2)}
  }}'
```

## 参数
```json
{json.dumps(parameters, indent=2)}
```

## 返回值
成功时返回 `payload` 字段中的内容；失败时返回 `error` 字段。

## 示例
当用户请求“{meta.get('description', '执行该工具')}”时，自动调用此技能。
"""
        
        (skill_dir / "SKILL.md").write_text(skill_md, encoding="utf-8")
        print(f"✅ 生成技能: {skill_dir}")

# 如果直接运行，可用于测试
if __name__ == "__main__":
    from act import ACTKernel
    kernel = ACTKernel()
    # 假设已经注册了一些工具（演示时可用）
    export_skills(kernel)