---
title: AI 工具省钱三件套——可能是现在最全的 provider 管理方案一览
date: 2026-05-13
tags:
  - AI Tools
  - Claude
  - Codex
  - 省钱
  - 开源
---

用 Claude Code、Codex 这类 AI coding 工具的朋友，应该都绕不开一个问题：**如何切换到便宜的第三方 provider 来省钱？**

现在国内外的中转 API、官方折扣渠道越来越多，DeepSeek、Kimi、智谱、阿里百炼、小米 MiMo……每个都号称「白菜价」。但实际用起来的痛点不在价格本身，而在 **切换和管理的麻烦**：

- 切了 provider，Codex 旧会话全消失了
- Claude Desktop 不支持直接填第三方 API
- 同时在用 Claude Code、Codex、Gemini CLI，每个都要单独配一遍

最近社区里冒出了三个开源工具，正好分别解决了上面这几个问题。我用了一圈，整理一下它们的定位和用法。

---

## codex-provider-sync：专治 Codex 切 provider 后「失忆」

如果你用 Codex，这是最刚需的一个。

Codex 切换 `model_provider` 后，旧会话在 Desktop 或 `/resume` 里会突然不可见。原因不是会话文件丢了，而是 rollout 文件、SQLite 线程表、项目路径缓存里的 provider metadata 没同步。

[codex-provider-sync](https://github.com/Dailin521/codex-provider-sync) 做的就是把这些位置全部对齐，让历史会话重新出现。

**用法**：

Windows 用户直接下载 Release 里的 `CodexProviderSync.exe`，点几下鼠标就行：

```
打开 EXE → Refresh → 选目标 Provider → Execute
```

macOS / 其他环境走 CLI：

```bash
npm install -g git+https://github.com/Dailin521/codex-provider-sync.git
codex-provider sync
```

其他常用命令：

- `codex-provider status` — 检查当前 provider / rollout / SQLite 诊断
- `codex-provider switch <provider-id>` — 切 provider + 同步一步到位
- `codex-provider restore <backup-dir>` — 从备份恢复

每次 `sync` / `switch` 前都会自动备份到 `~/.codex/backups_state/provider-sync/`，所以放心试。

**需要注意的一个坑**：Codex Desktop 首屏有「最近 50 条会话」的显示限制。CLI `/resume` 能看到，但 Desktop 可能还是显示不全。这个不是工具的锅，是上游限制。

---

## cc-desktop-switch：让 Claude Desktop 用上第三方 API

Claude Desktop 官方只支持 Anthropic 自家的 API Key。你想接 DeepSeek、Kimi、智谱？官方没给选项。

[cc-desktop-switch](https://github.com/lonr-6/cc-desktop-switch) 的解法是在本地跑一个轻量 gateway（默认端口 18080），把第三方 provider 的模型映射成 Claude 认识的模型名，然后一键配置到 Claude Desktop。

**亮点**：
- GUI 界面，支持预设一键填好 API URL 和模型推荐
- 只暴露已映射的模型名到 Claude Desktop，不会看到一堆上游原始 ID
- 内置健康检查、模型可用性检测、SSE 流式测试
- 支持自定义上游 HTTP/SOCKS 代理
- Windows 和 macOS 都支持（arm64 原生包）

**使用流程**：

```
1. 下载安装包启动
2. 选 provider 预设（DeepSeek / Kimi / 智谱 / 阿里百炼 / 小米 MiMo / 自定义）
3. 填入自己的 API Key
4. 调整模型映射 → 点 "Apply to Claude Desktop"
5. 完全重启 Claude Desktop
```

后台运行时，Claude Desktop 通过 `127.0.0.1:18080` 调用 gateway，关窗口后会在系统托盘继续跑。

---

## cc-switch：All-in-One，一个工具管全家

如果你同时在用多个 AI coding 工具，[cc-switch](https://github.com/farion1231/cc-switch) 是覆盖面最广的。

它支持的工具有 **6 个**：Claude Code、Codex、Gemini CLI、OpenCode、OpenClaw、Hermes Agent。

Tauri 2 构建，Windows / macOS / Linux 都能跑，原生体验。

因为社区热度高（GitHub Stars 增长很快），它的赞助商生态也最成熟——MiniMax、SiliconFlow、BytePlus、阿里云等都入驻了，通过内置的优惠链接注册能拿到额外额度。

**用法**：下载对应平台 Release，启动后选择要管理的工具 → 配置 provider → 保存即可。

---

## 怎么选？

| 场景 | 推荐工具 |
|------|---------|
| 只切 Codex provider，旧会话丢失 | **codex-provider-sync** |
| 只想 Claude Desktop 用第三方 API | **cc-desktop-switch** |
| 同时在用多个工具，想统一管理 | **cc-switch** |
| 穷，全都要 | 三个都可以装，互不冲突 |

这三个工具各有侧重，但目标是一致的：**让你在享受第三方低价 API 的同时，不用牺牲使用体验。**

如果你也在用这些工具或者有更好的省钱方案，欢迎交流。
