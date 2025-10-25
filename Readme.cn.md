# VLESS Trojan 一键安装脚本

[English](Readme.md)|简体中文

> [!Note]
> 中文翻译并非100%准确，因为主要基于Claude-sonnet-4。最终结果可能存在一些问题。如果您发现任何问题或认为存在错误，请提交issues以帮助改进fast-vless。

> ·特别感谢 **JIACDN US** 和 **jia42** 提供的大力支持！  
> 
> ·特别感谢 **[拼好鸽](https://gelxc.cloud)** 提供的大力支持！

## 🚀 项目概述

这是一个轻量级的一键安装脚本，支持以下功能：

- ✅ **最新版Xray安装** - 自动安装最新版本
- 🔒 **高级协议支持** - VLESS + Reality 和 Trojan + Reality 模式  
- 🌐 **流媒体检测** - 媒体解锁检测（基于 ip.check.place）
- 🔗 **自动生成链接** - 直接生成VLESS连接URL，便于客户端导入
- 
---

## 📋 系统要求

- 具有 `root` 权限的VPS或LXC容器
- 如果您没有root权限，请尝试：`su root` 或 `sudo -s`

## ⚡ 快速开始

使用 **root权限** 运行以下命令：

```bash
bash <(curl -L https://raw.githubusercontent.com/Lorry-San/fast-vless/main/xrayvless.sh)
