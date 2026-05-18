---
tags:
  - reference
  - openchronicle
  - memory
date: 2026-05-10
parent: "[[长期记忆系统]]"
---

# 📋 OpenChronicle 调研笔记

## 基本信息

- **Repo**: [Einsia/OpenChronicle](https://github.com/Einsia/OpenChronicle)
- **语言**: Python
- **类型**: macOS 用户活动事件记录
- **存储**: Markdown + SQLite 索引
- **平台**: macOS（基于 AX Tree / Accessibility API）
- **核心功能**: 应用切换追踪、文件操作记录、URL 访问记录

## 数据结构

OpenChronicle 记录的事件类型包括：

- **应用切换** — `[timestamp] 从 App A 切换到 App B`
- **文件操作** — `[timestamp] 应用 X 打开了文件 Y`
- **URL 访问** — `[timestamp] 浏览器访问了 URL Z`
- **焦点变化** — `[timestamp] 窗口焦点变更`

数据以 Markdown 日志文件存储 + SQLite 索引加速查询。

## 优劣分析

**优势**:
- 结构化好，天然适合作为记忆输入
- 隐私风险低（只记录活动元数据，不记录屏幕内容）
- 数据量小，增量处理效率高
- Python 生态，容易集成

**劣势**:
- 缺少屏幕内容（看不到实际在做什么）
- 依赖 macOS Accessibility API，某些场景可能漏报
- 社区相对较小

## 集成方式

读取 SQLite 索引 + Markdown 日志，提取事件记录：
- `content`: "用户打开了 VS Code，编辑了 config.yaml 的 provider 配置"
- `metadata`: `{event_id, timestamp, event_type, app_name, file_path, ...}`

## 备注

> 数据在工作 Mac 上。OpenChronicle 和 Screenpipe 可以互补：Screenpipe 补全「内容」，OpenChronicle 提供「结构」。
