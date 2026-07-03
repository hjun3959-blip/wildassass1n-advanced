---
name: attack-chain-execution
description: >
  执行完整的多阶段攻击工作流程，从侦察到后渗透。当用户需要运行协调的
  攻击链、执行完整的渗透测试序列、执行端到端利用场景或自动化攻击阶段
  转换时触发。将情报收集→漏洞发现→利用→持久化→清理协调到统一的活
  动中，具有阶段协调和结果聚合。
compatibility: Python 3.10+, standard library only
---

# Attack Chain Execution Skill

## 概述

此技能协调多阶段攻击工作流程，自动化从侦察到后渗透的转换。它管理阶段依赖关系并提供统一报告。

## 攻击阶段

### 阶段 1: 情报收集（Intelligence）
目标分析和侦察：
- DNS 解析和 IP 验证
- 端口扫描（常见服务）
- 服务版本检测
- 横幅获取
- 网络拓扑映射

### 阶段 2: 漏洞发现（Discovery）
识别可利用的弱点：
- SUID 二进制文件枚举
- 世界可写文件发现
- 内核版本分析
- 配置审计
- 权限弱点

### 阶段 3: 利用（Exploitation）
尝试利用发现的漏洞：
- SUID 二进制利用
- 内核权限升级
- 服务利用
- 配置滥用

### 阶段 4: 持久化（Persistence）
建立访问持久化和维护：
- 持久化机制安装
- 凭证获取
- 横向移动准备
- 访问保留

### 阶段 5: 清理（Cleanup）
覆盖痕迹和删除证据：
- 日志文件删除/混淆
- 命令历史清理
- 临时文件删除
- Core dump 禁用
- 工件删除

## 输入格式

```python
payload = {
    "target": "192.168.1.100",          # 目标 IP 或主机名
    "phases": [1, 2, 3, 4, 5],         # 要执行的阶段
    "force": False,                     # 启用强制模式
    "timeout": 300                      # 总超时（秒）
}
```

## 输出格式

始终返回此结构：

```json
{
  "skill": "attack-chain-execution",
  "status": "success|partial|failed",
  "campaign": {
    "target": "192.168.1.100",
    "duration_seconds": 0
  },
  "phases": [
    {
      "phase_number": 1,
      "phase_name": "intelligence",
      "status": "completed",
      "findings": []
    }
  ],
  "summary": {
    "phases_executed": 5,
    "phases_successful": 5,
    "access_achieved": false
  }
}
```

## 示例

**示例 1：完整攻击链**
- 输入：执行所有 5 个阶段
- 输出：显示通过情报→发现→利用的多阶段报告

**示例 2：仅限侦察**
- 输入：仅运行阶段 1-2
- 输出：漏洞报告，不进行利用尝试

## 最佳实践

- 顺序协调阶段
- 优雅地处理故障
- 聚合所有阶段的发现
- 仅在授权的环境中使用 `force: true`
