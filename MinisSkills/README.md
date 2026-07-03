# MinisSkills Collection

模块化技能库 for WildAssassin 安全测试框架。

## 可用的技能

### security-assessment（安全评估）
对系统进行全面安全评估和漏洞发现。
- 三阶段扫描（侦察 → 发现 → 风险评估）
- SUID 二进制检测
- 世界可写文件发现
- 内核 CVE 检查
- 权限分析
- 风险评分

### attack-chain-execution（攻击链执行）
协调多阶段攻击工作流程。
- 5 个阶段自动化（情报 → 发现 → 利用 → 持久化 → 清理）
- 真实网络操作
- 阶段依赖管理
- 结果聚合

### persistence-establishment（持久化建立）
建立访问持久化机制。
- Cron 作业
- SSH 密钥
- Systemd 服务
- 后门用户

### log-forensics（日志取证）
分析和检查日志文件。
- 日志解析
- 异常检测
- 时间线分析

### network-reconnaissance（网络侦察）
网络发现和探测。
- 端口扫描
- 服务识别
- 网络映射

## 技能格式

每个技能都是一个独立目录，包含：
- `SKILL.md` - 技能定义和说明（必需）
- `scripts/` - 可执行脚本（可选）
- `references/` - 参考文档（可选）
- `evals/` - 评估测试用例（可选）
- `assets/` - 模板和资源（可选）

## 使用示例

```bash
# 基础安全扫描
python -m MinisSkills.security_assessment.scripts.scanner

# 深度扫描并保存报告
python -m MinisSkills.security_assessment.scripts.scanner --deep -o report.json

# 执行攻击链
python -m MinisSkills.attack_chain_execution.scripts.orchestrator 192.168.1.100
```

## 命名约定

- 使用 kebab-case：`security-assessment`, `attack-chain-execution`
- 目录名转换为 snake_case 作为 Python 包
