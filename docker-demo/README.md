# ACT Gateway Demo – 一键体验超时、限流、熔断

```bash
cd docker-demo
docker-compose up
```

然后打开浏览器访问 http://localhost:8080 即可体验。

- **正常调用**：返回天气数据
- **超时工具**：故意慢 2 秒，触发 1 秒超时
- **错误工具**：连续调用 3 次触发熔断
- **限流测试**：连续 5 次调用，第 3 次起被限流拒绝