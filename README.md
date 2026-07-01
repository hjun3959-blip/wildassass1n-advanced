# WildAssass1n - 野驴横跨平台 SSS 级越狱框架

**版本**: 2.0.0  
**作者**: WildAssass1n Team  
**平台**: Linux, Android, iOS, Darwin, Windows  
**级别**: SSS (绝密)  

## 概述

WildAssass1n 是一个专业级的横跨平台越狱框架，设计用于在高安全防护环境中实现代码执行。
框架通过多种机制绕过常见的安全限制，提供直连内核、全自动化的攻击能力。

## 核心特性

### 1. 跨平台支持
- **Linux**: 内核级执行、系统调用
- **Android**: WebView 注入、Java 反射、JNI 调用
- **iOS**: WKWebView 注入、Objective-C 互操作
- **Darwin**: macOS 原生执行
- **Windows**: 注入技术、API 调用

### 2. 越狱机制

#### Injector (代码注入引擎)
- **Blob Injection**: 使用 mmap 分配可执行内存
- **CSP Bypass**: 回路避免内容安全策略
- **原型链破坏**: 恢复 eval/Function 构造器
- **跨域访问**: 绕过同源策略限制

#### Breaker (断路器)
- JavaScript 安全限制解除
- eval 功能恢复
- 内存执行能力解锁
- 动态代码执行授权

#### Executor (执行器)
- 直连内核系统调用
- Native 命令执行
- 进程注入和控制
- 跨平台统一接口

### 3. 完整攻击链

1. **Intelligence Gathering** (情报收集)
   - 端口扫描
   - DNS 解析
   - 服务指纹识别

2. **Vulnerability Discovery** (漏洞发现)
   - SUID 二进制检测
   - 世界可写文件
   - Web 应用漏洞

3. **Exploitation** (演练利用)
   - SUID 权限提升
   - SQL Injection
   - XSS 攻击
   - 内核漏洞利用

4. **Post-Exploitation** (后渗透)
   - Cron 持久化
   - SSH 后门
   - Systemd 服务
   - Android/iOS 持久化

5. **Cleanup** (清理)
   - 日志清除
   - 历史记录清理
   - 核心倒归防护

## 文件结构

```
WildAssass1n-Advanced/
├── SKILL.md                    # 技能定义（YAML + Markdown）
├── README.md                   # 框架说明书
├── jailbreak.py                # 核心越狱引擎
├── full_attack_chain.py        # 完整攻击链
├── scripts/
│   ├── android_inject.py      # Android WebView 注入
│   ├── ios_inject.py          # iOS WKWebView 注入
│   ├── linux_exploit.py       # Linux 漏洞利用
│   ├── persistence.py          # 持久化工具
│   └── payload.js             # JavaScript 载荷
├── references/
│   └── cve_database.json       # CVE 数据库
└── assets/
    └── templates/                # 攻击模板
```

## 快速开始

### 基础使用

```bash
# 执行完整攻击链
python3 jailbreak.py --force --target 192.168.1.100 --output report.json

# 使用攻击链模块
python3 full_attack_chain.py --force 192.168.1.100 --output results.json

# Android WebView 注入
python3 scripts/android_inject.py --package com.target.app --js "alert('owned')"

# iOS WKWebView 注入
python3 scripts/ios_inject.py --inject

# Linux 漏洞利用
python3 scripts/linux_exploit.py --force --all
```

### Python API 使用

```python
from jailbreak import WildAssassinJailbreak
from full_attack_chain import WildAssass1nAttackChain

# 方式1：使用核心引擎
engine = WildAssassinJailbreak(force_mode=True)

# 注入代码
result = engine.inject_code(target_pid=1234, shellcode=b"\x90" * 100)

# 恢复eval
engine.restore_eval()

# 执行命令
result = engine.execute_command("ls -la /etc/passwd")
print(result)

# 方式2：使用攻击链
chain = WildAssass1nAttackChain(force_mode=True)
results = chain.execute("192.168.1.100")
print(json.dumps(results, indent=2))
```

## 安全声明

本框架仅用于合法的授权测试和安全研究。
请确保在合法范围内使用，不承担任何非法使用造成的后果。

## 具体能力

### Android WebView
- JavaScript 印射
- Java 反射调用
- CORS 绕过
- 跨域访问

### iOS WKWebView
- WebKit 注入
- Objective-C 互操作
- 沙盒逃逸
- eval 恢复

### Linux
- SUID 二进制漏洞利用
- 内核提权
- Cron 持久化
- 能力提升

## 技术详情

### 代码注入 (
