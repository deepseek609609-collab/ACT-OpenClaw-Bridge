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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9000)
