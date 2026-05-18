# progress-bar Skill

给长时间运行的任务提供有趣的纯文本进度提示。

## 功能特性

- **5种进度样式**：经典方块、气泡填充、吃豆人、阶梯爬升、条形生长
- **3种更新模式**：主动推送式、状态标记式、查询式
- **自动识别**：包装命令自动提取百分比
- **多任务支持**：可同时追踪多个任务进度

## 位置

```
~/.openclaw/skills/progress-bar/
├── SKILL.md
├── progress-bar.js
├── state.json
└── package.json
```

## 使用方式

### 基本命令

```bash
# 开始任务
progress-bar start --total 100 --title "下载文件" --style pacman

# 更新进度
progress-bar update 50 --id download1

# 完成任务
progress-bar complete

# 查询状态
progress-bar status

# 自动包装命令
progress-bar run -- brew install ffmpeg
```

### 样式预览

```
classic: [█████░░░░░] 50%
bubbles: [🔵🔵🔵⚪⚪] 60%
pacman:  😋 🔴🔴🔴🔴🔴 83%
stairs:  🟩🟩🟩⬜⬜⬜ 50%
bars:    ▰▰▰▰▱▱▱▱▱ 44%
```

## 支持的自动识别工具

- wget / curl - HTTP 下载进度
- brew - 包管理安装进度
- git clone - 克隆进度
- pip / npm / docker - 容器镜像下载
- dd / cp - 文件复制进度

## 多任务示例

```bash
# 启动两个并发任务
progress-bar start --id task1 --title "下载A" --total 100
progress-bar start --id task2 --title "下载B" --total 100

# 分别更新
progress-bar update 30 --id task1
progress-bar update 50 --id task2

# 查看列表
progress-bar list

# 完成并清理
progress-bar complete --id task1
progress-bar clear --id task2
```

## Changelog

- v1.1.0: 增加多任务支持、环境检测（TTY vs 消息通道）、更多进度识别 pattern
- v1.0.0: 初始版本，5种样式，基本命令

---
Created by igloo & 雪
