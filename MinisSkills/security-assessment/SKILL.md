---
name: security-assessment
description: >
  执行全面的系统安全评估，识别漏洞、配置错误和利用向量。当用户要求
  扫描安全问题、发现漏洞、审计系统安全、评估攻击面、检查CVE、识别
  权限提升路径或发现弱配置时触发。覆盖SUID二进制文件、世界可写文件、
  内核漏洞、弱权限等。
compatibility: Python 3.10+, standard library only
---

# Security Assessment Skill

## 概述

此技能对目标系统进行多阶段安全分析，以识别可利用的弱点。它将自动发现与智能漏洞评估相结合，构建攻击向量的优先列表。

## 何时使用此技能

当以下情况触发此技能：
- 用户请求安全审计或漏洞扫描
- 需要评估系统攻击面
- 识别潜在的权限升级方法
- 发现利用机会
- 检查已知的易受攻击软件或配置

## 工作流程

技能执行三阶段评估：

### 阶段 1：侦察（Reconnaissance）
收集系统信息并识别运行的服务：
- OS 类型和内核版本
- 已安装软件和版本
- 网络服务和开放端口
- 用户账户和组
- CPU 核心数、内存、运行时间

### 阶段 2：漏洞发现（Vulnerability Discovery）
搜索已知的弱配置：
- SUID/SGID 二进制文件（具有已知漏洞）
- 世界可写的敏感文件
- 与系统版本匹配的内核漏洞
- 关键位置中的弱文件权限
- Sudo 配置错误
- 危险的进程能力
- 缺少粘性位的目录

### 阶段 3：风险评估（Risk Assessment）
按可利用性和影响对发现进行排名：
- **临界（Critical）**: 立即可能权限升级
- **高（High）**: 权限升级，有轻微条件
- **中（Medium）**: 信息泄露或横向移动
- **低（Low）**: 防御绕过或轻微权限获得

## 输入格式

```python
payload = {
    "target": "127.0.0.1",              # 可选：目标系统（默认：localhost）
    "deep_scan": False,                 # 可选：包括详尽检查
    "timeout": 60                       # 可选：每次检查的最大秒数
}
```

## 输出格式

始终返回此结构：

```json
{
  "skill": "security-assessment",
  "status": "success|failed",
  "findings": [
    {
      "type": "suid_binary|world_writable|kernel_vuln|weak_perms|capabilities",
      "severity": "critical|high|medium|low",
      "path": "/path/to/resource",
      "description": "人类可读的描述",
      "impact": "攻击者能做什么",
      "remediation": "如何修复此问题",
      "references": ["CVE-2021-4034"],
      "confidence": 0.95
    }
  ],
  "summary": {
    "total_findings": 0,
    "critical_count": 0,
    "high_count": 0,
    "risk_score": 0.0
  },
  "recommendations": ["按优先级顺序的推荐操作"]
}
```

## 示例

### 示例 1：基本系统审计
**输入**: 用户想要检查 Linux 系统是否存在明显的安全问题

**过程**:
1. 扫描已知漏洞的 SUID 二进制文件 (nmap, vim, find, bash)
2. 检查 /etc, /tmp, /var 中的世界可写文件
3. 识别内核版本并检查 CVE 数据库
4. 使用严重性级别报告发现

**输出**: 结构化报告，包含 5-15 个发现、风险分数和修复步骤

### 示例 2：深度安全分析
**输入**: 需要合规性审计的全面审计

**过程**:
1. 完整的系统侦察
2. Sudo 配置检查
3. 枚举所有具有特殊权限的二进制文件
4. 分析网络暴露
5. 与 CVE 数据库交叉引用

**输出**: 执行摘要 + 详细发现报告

## 最佳实践

- **全面性**: 检查多条攻击路径，而不仅仅是明显的路径
- **解释影响**: 描述攻击者能做什么，而不仅仅是什么错误
- **优先级排列**: 用户需要知道首先要修复什么
- **包括修复**: 不仅报告问题，还要建议解决方案
- **参考来源**: 链接到 CVE、建议和技术文档

## 备注

- 评估是非破坏性的；不对目标系统进行任何更改
- 需要适当的权限来检查所有系统区域
- 发现是时间点；系统可能在扫描之间更改
- 深度扫描模式更彻底但更慢
