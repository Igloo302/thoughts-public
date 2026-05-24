# 屏幕记忆管理 - Screen Memory GUI

> 统一管理和可视化 Screenpipe、OpenChronicle 两个屏幕记忆工具的 Web 界面

## 项目概述

开发了一个基于 Python + Flask 的 Web GUI，用于统一管理两个屏幕录制/记忆工具：
- **Screenpipe**: 24/7 本地屏幕和音频录制，AI 驱动的搜索
- **OpenChronicle**: 本地优先的屏幕上下文记忆，为 LLM Agent 提供上下文

## 技术栈

- **后端**: Python 3.12 + Flask
- **前端**: 纯 HTML + JavaScript + CSS（无框架依赖）
- **虚拟环境**: `~/Projects/screenpipe-gui-venv/`
- **端口**: 5555

## 文件位置

| 文件 | 路径 |
|------|------|
| 主程序 | `~/Projects/screen-memory-gui.py` |
| 启动脚本 | `~/Projects/launch-screen-memory-gui.sh` |
| Python 虚拟环境 | `~/Projects/screenpipe-gui-venv/` |
| 命令行快捷方式 | `~/.local/bin/screen-memory-gui` |
| macOS App Bundle | `~/Applications/ScreenMemoryGUI.app` |
| 桌面快捷方式 | `~/Desktop/ScreenMemoryGUI.command` |

## 功能特性

### 双后端管理
- **Screenpipe**: Start / Stop / Shutdown 控制
- **OpenChronicle**: Start / Stop / Pause / Resume 控制
- 实时状态监控（自动刷新）

### 搜索功能
- **Screenpipe 搜索**: All / Screen Text / Audio
- **OpenChronicle 搜索**: Screen Captures / Events & Sessions / All
- 支持按应用、时间范围筛选

### 活动热力图
- GitHub Commit 热力图风格
- 30 天活动视图，按小时分组
- 颜色深度表示活动强度
- 悬停显示详细信息（时间、捕获数、使用的应用）
- 今日活动条形图

### 数据管理
- 一键打开 Screenpipe 数据文件夹 (`~/.screenpipe/`)
- 一键打开 OpenChronicle 数据文件夹 (`~/.openchronicle/`)

## 启动方式

### 方式 1: 命令行
```bash
screen-memory-gui
```

### 方式 2: 桌面快捷方式
双击 `~/Desktop/ScreenMemoryGUI.command`

### 方式 3: macOS App
从 `~/Applications/ScreenMemoryGUI.app` 或 Launchpad 启动

### 方式 4: 手动启动
```bash
cd ~/Projects
source screenpipe-gui-venv/bin/activate
python screen-memory-gui.py
```

启动后自动打开浏览器访问 `http://localhost:5555`

## 数据存储

| 工具 | 数据路径 | 说明 |
|------|----------|------|
| Screenpipe | `~/.screenpipe/` | 截图、视频、OCR 文本、音频转录 |
| OpenChronicle | `~/.openchronicle/` | 屏幕捕获、事件摘要、时间线 |

## 已知问题

- Screenpipe 数据库迁移版本不匹配时需要手动修复（备份并重新迁移）
- OpenChronicle `status` 命令可能因 Gemini API 认证问题超时，已添加 pgrep 降级检测
- 端口 5000 被 AirTunes 占用，使用 5555 端口

## 待办

- [ ] OpenChronicle 搜索功能完善
- [ ] 热力图支持更多自定义选项
- [ ] 添加录制统计面板
- [ ] 支持自定义 pipe 插件管理

## 创建时间

2026-05-08

## 相关资源

- [Screenpipe GitHub](https://github.com/screenpipe/screenpipe)
- [OpenChronicle](https://github.com/openchronicle/openchronicle)
- [Screenpipe 官网](https://screenpi.pe)
