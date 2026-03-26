"""
ACT Runtime for OpenClaw – 替换 OpenClaw 的默认工具执行器，获得超时、重试、限流等能力。
"""

import requests
import json
from typing import Any, Dict

class ACTRuntime:
    """OpenClaw 工具执行器替换层，所有工具调用都经过 ACT Gateway"""

    def __init__(self, gateway_url: str = "http://localhost:9000"):
        self.gateway_url = gateway_url

    def call(self, tool_name: str, action: str, params: Dict[str, Any]) -> Any:
        """执行工具，返回结果，失败时抛出异常"""
        intent = f"{tool_name}.{action}"
        try:
            resp = requests.post(
                f"{self.gateway_url}/act/dispatch",
                json={"intent": intent, "params": params},
                timeout=5
            )
            result = resp.json()
        except Exception as e:
            raise RuntimeError(f"ACT Gateway 调用失败: {e}")

        if result["execution"]["status"] == "ok":
            return result["payload"]
        else:
            error_info = result.get("error", {"message": "Unknown error"})
            raise RuntimeError(f"ACT 执行失败: {error_info}")

# ---------- 替换 OpenClaw 默认执行器的示例 ----------
def patch_openclaw(openclaw_app, gateway_url="http://localhost:9000"):
    """
    将 OpenClaw 的 tool executor 替换为 ACTRuntime。
    假设 openclaw_app 有一个 `tool_executor` 属性或方法。
    """
    act_runtime = ACTRuntime(gateway_url)
    original_execute = openclaw_app.tool_executor.execute

    def wrapped_execute(tool_name, action, params):
        try:
            return act_runtime.call(tool_name, action, params)
        except Exception as e:
            # 可选择记录日志或回退到原始执行器
            # 这里直接抛出，让 OpenClaw 捕获
            raise e

    openclaw_app.tool_executor.execute = wrapped_execute