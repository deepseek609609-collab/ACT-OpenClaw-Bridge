# Contributing to ACT Gateway

<div align="right">
  <small><a href="#中文版">中文版</a> | <a href="#english">English</a></small>
</div>

---

<a name="english"></a>
## English

Thank you for your interest in contributing to ACT Gateway! We welcome contributions from everyone.

### How to Contribute

1. **Fork the Repository**
   - Click the "Fork" button at the top right of the repository page

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ACT-OpenClaw-Bridge.git
   cd ACT-OpenClaw-Bridge
   ```

3. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Your Changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

5. **Test Your Changes**
   ```bash
   # Run tests
   python -m pytest tests/
   
   # Run linting
   python -m flake8 .
   ```

6. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add: Description of your changes"
   ```

7. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template

### Development Setup

```bash
# Clone the repository
git clone https://github.com/deepseek609609-collab/ACT-OpenClaw-Bridge.git
cd ACT-OpenClaw-Bridge

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -e .

# Run tests
python -m pytest tests/
```

### Code Style

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) for Python code
- Use type hints where appropriate
- Write docstrings for all public functions and classes
- Keep functions small and focused

### Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to docs
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed

### Questions?

Feel free to open an issue or join our discussions!

---

<a name="中文版"></a>
## 中文版

感谢您对 ACT Gateway 项目的贡献感兴趣！我们欢迎所有人的贡献。

### 如何贡献

1. **Fork 仓库**
   - 点击仓库页面右上角的 "Fork" 按钮

2. **克隆你的 Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ACT-OpenClaw-Bridge.git
   cd ACT-OpenClaw-Bridge
   ```

3. **创建分支**
   ```bash
   git checkout -b feature/你的功能名称
   ```

4. **进行修改**
   - 遵循现有的代码风格
   - 为新功能添加测试
   - 根据需要更新文档

5. **测试你的修改**
   ```bash
   # 运行测试
   python -m pytest tests/
   
   # 运行代码检查
   python -m flake8 .
   ```

6. **提交更改**
   ```bash
   git add .
   git commit -m "Add: 你的修改描述"
   ```

7. **推送到你的 Fork**
   ```bash
   git push origin feature/你的功能名称
   ```

8. **创建 Pull Request**
   - 前往原始仓库
   - 点击 "New Pull Request"
   - 选择你的分支
   - 填写 PR 模板

### 开发环境设置

```bash
# 克隆仓库
git clone https://github.com/deepseek609609-collab/ACT-OpenClaw-Bridge.git
cd ACT-OpenClaw-Bridge

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt
pip install -e .

# 运行测试
python -m pytest tests/
```

### 代码风格

- Python 代码遵循 [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- 适当使用类型提示
- 为所有公共函数和类编写文档字符串
- 保持函数小而专注

### 问题标签

- `bug`: 某些功能无法正常工作
- `enhancement`: 新功能或请求
- `documentation`: 文档改进或添加
- `good first issue`: 适合新手的任务
- `help wanted`: 需要额外关注的问题

### 有问题？

随时可以创建 issue 或加入我们的讨论！