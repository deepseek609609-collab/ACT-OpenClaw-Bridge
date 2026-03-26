#!/bin/bash
echo "测试 ACT Gateway 健康状态..."
curl -s http://localhost:9000/health | jq .

echo "测试正常工具调用..."
curl -s -X POST http://localhost:9000/act/dispatch \
  -H "Content-Type: application/json" \
  -d '{"intent": "weather.get_current", "params": {"city": "Beijing"}}' | jq .

echo "测试超时..."
curl -s -X POST http://localhost:9000/act/dispatch \
  -H "Content-Type: application/json" \
  -d '{"intent": "weather.slow"}' | jq .

echo "测试限流（快速连续请求）..."
for i in {1..3}; do
    curl -s -X POST http://localhost:9000/act/dispatch \
      -H "Content-Type: application/json" \
      -d '{"intent": "weather.get_current"}' | jq '.execution.status'
done
