---
tags:
  - reference
  - screenpipe
  - memory
date: 2026-05-10
parent: "[[长期记忆系统]]"
---

# 📸 Screenpipe 调研笔记

## 基本信息

- **Repo**: [mediar-ai/screenpipe](https://github.com/mediar-ai/screenpipe)
- **语言**: Rust
- **类型**: 屏幕 + 音频连续录制
- **存储**: 本地 SQLite
- **平台**: macOS / Windows / Linux
- **核心功能**: OCR 文字提取、音频转录、屏幕帧捕获

## 数据结构

Screenpipe 的数据存储在本地 SQLite 数据库中，主要表包括：

- `frames` — 屏幕帧记录（时间戳、图像路径、OCR 文字）
- `audio_transcriptions` — 音频转录文本
- `ocr_text` — OCR 提取的文字内容

## 优劣分析

**优势**:
- 信息最完整，能看到用户在屏幕上的一切
- OCR 可提取代码、网页、聊天内容
- 跨平台，社区活跃

**劣势**:
- 数据量极大（视频帧），存储和索引开销大
- 隐私风险最高（记录所有屏幕内容）
- 本地 LLM 做 OCR 摘要需要额外算力

## 集成方式

通过读取 SQLite 数据库，提取 OCR 文字和时间戳，包装为 Hindsight MemoryItem：
- `content`: "用户在 [时间] 浏览了 [应用] 的内容：[OCR 摘要]"
- `metadata`: `{frame_id, timestamp, app_name, ocr_text, ...}`

## 备注

> 数据在工作 Mac 上，需要先确认实际数据库路径和 schema。
