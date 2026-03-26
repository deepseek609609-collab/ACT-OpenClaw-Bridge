"""
ACT Gateway – HTTP Bridge for Deterministic Execution
独立可运行，无需 OpenClaw 即可演示超时、限流、熔断。
"""

import time
import sys
from fastapi import FastAPI
from fastapi.concurrency import run_in_threadpool
from pydantic import BaseModel
from typing import Any, Dict, Optional
import uvicorn

from act import ACTKernel, tool, register_tools_from_module

# ------------------------ 工具定义 ------------------------
@tool(
    name="weather.get_current",
    description="获取天气",
    timeout_ms=2000,
    rate_limit=2,
    capacity=2,
    parameters={"city": {"type": "string"}}
)
def get_weather(params: Dict[str, Any]) -> Dict[str, Any]:
    city = params.get("city", "Beijing")
    time.sleep(0.2)  # 模拟正常延迟
    return {"city": city, "temperature": 22, "condition": "sunny"}

@tool(
    name="weather.slow",
    description="慢工具（超时演示）",
    timeout_ms=1000,
    rate_limit=1
)
def slow_tool(params: Dict[str, Any]) -> Dict[str, Any]:
    time.sleep(2)  # 超过 timeout_ms
    return {"ok": True}

@tool(
    name="weather.error",
    description="错误工具（熔断演示）",
    timeout_ms=1000,
    rate_limit=5
)
def error_tool(params: Dict[str, Any]) -> Dict[str, Any]:
    raise Exception("Intentional tool error")

# ------------------------ 初始化 ACT Kernel ------------------------
kernel = ACTKernel(default_timeout_ms=3000, default_retries=1)
register_tools_from_module(kernel, sys.modules[__name__])

# ------------------------ FastAPI 应用 ------------------------
app = FastAPI(title="ACT Gateway", version="1.0")

class DispatchRequest(BaseModel):
    intent: str
    params: Optional[Dict[str, Any]] = None
    context: Optional[Dict[str, Any]] = None

@app.post("/act/dispatch")
async def dispatch(request: DispatchRequest):
    params = request.params or {}
    context = request.context or {}
    result = await run_in_threadpool(kernel.dispatch, request.intent, params, context)
    return result

@app.get("/health")
async def health():
    return {"status": "ok"}

# ------------------------ MCP 兼容端点 ------------------------
import json
from typing import List, Dict, Any

@app.post("/mcp/tools/list")
async def mcp_list_tools():
    """
    MCP 协议：列出所有可用工具
    符合规范：https://modelcontextprotocol.io/specification/2025-11-25/server/tools
    """
    tools = []
    for (tool_name, action), meta in kernel.registry._metadata.items():
        tool_id = f"{tool_name}.{action}"
        tools.append({
            "name": tool_id,
            "description": meta.get("description", ""),
            "inputSchema": meta.get("parameters", {
                "type": "object",
                "additionalProperties": False
            }),
            # 可选字段，可扩展
            # "outputSchema": meta.get("output_schema"),
            # "execution": {"taskSupport": "forbidden"}
        })
    return {"tools": tools}

@app.post("/mcp/tools/call")
async def mcp_call_tool(request: dict):
    """
    MCP 协议：调用指定工具
    """
    tool_name = request.get("name")
    arguments = request.get("arguments", {})
    
    # 调用 ACT 内核
    result = await run_in_threadpool(kernel.dispatch, tool_name, arguments)
    
    if result["execution"]["status"] == "ok":
        # 成功返回 MCP 标准格式
        payload = result["payload"]
        # 如果 payload 是字典或列表，转为 JSON 文本
        if isinstance(payload, (dict, list)):
            text_content = json.dumps(payload, ensure_ascii=False)
        else:
            text_content = str(payload)
        return {
            "content": [{"type": "text", "text": text_content}],
            "isError": False
        }
    else:
        # 错误返回
        error_info = result.get("error", {"code": "unknown", "message": "Unknown error"})
        return {
            "content": [{"type": "text", "text": error_info.get("message", "Execution failed")}],
            "isError": True
        }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9000)
