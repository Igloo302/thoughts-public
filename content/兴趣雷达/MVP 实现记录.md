---
type: implementation-log
project: 兴趣雷达
created: 2026-05-14
updated: 2026-05-16
tags:
  - project/interest-radar
  - context-os
  - design
---

# 兴趣雷达 · 实现记录

## 当前阶段

**MVP 3 完成。** 兴趣雷达三个 MVP 能力全部交付。

## 定位演进

### v0.1（已废弃 — 2026-05-14）

- 定位：自建采集 + 自建判断 + 自建推送的监控系统
- 实现：interest_radar.py（RSS/GitHub scraping），sources.yaml，cronjob 定时推送
- 问题：太重；采集层和现成工具重复；信号噪声比难以控制

### v0.2（当前 — 2026-05-16）

- 定位：纯相关性判断引擎，不碰采集和推送
- 设计原则：
  - **自适应上下文召回：** 不绑定任何记忆工具，运行时按需探测
  - **Skill 只定义接口：** judge() / batch_judge()，不绑定实现
  - **代码工作交给 Claude Code：** 我只设计接口和流程

## 文件位置

| 文件 | 说明 |
|------|------|
| `~/.hermes/skills/research/personal-radar/SKILL.md` | 主 Skill 定义（完整流程） |
| `~/.hermes/skills/research/personal-radar/references/` | 参考文档（7 个） |
| `~/.hermes/skills/research/personal-radar/scripts/snapshot.py` | 快照管理脚本（Claude Code 编写） |
| Obsidian 兴趣雷达.md | 项目文档 |
| Obsidian MVP 实现记录.md | 本文件 |

## MVP 完成清单

### MVP 1：转发即用 ✅

- [x] SKILL.md 定义自动触发条件
- [x] 内容获取（web_extract → browser fallback）
- [x] 实体抽取
- [x] 自适应上下文召回（快照 → Hindsight → Obsidian → Memory → 种子兴趣）
- [x] 六维度评分
- [x] why_it_matters 生成（必须关联具体项目/兴趣/决策）
- [x] 微信友好输出格式
- [x] 快照缓存（TTL 6h）
- [x] Top 档位强制多源召回
- [x] 并行执行优化

### MVP 2：batch_judge ✅

- [x] batch_judge 接口定义（输入/输出/调用方式）
- [x] 批量评分策略（≤3 完整 / 4-10 共享召回 / >10 初筛）
- [x] 分桶到行为映射（top→push, watch→watch, silent→archive, ignore→skip）
- [x] 调用方 Skill 集成模板
- [x] 输出汇总格式
- [x] 错误处理方案
- [x] references/batch-interface.md
- [x] 真实数据测试（follow-builders 5 条 → 1 条推送）

### MVP 3：反馈闭环 ✅

- [x] 自适应存储策略（不绑定工具，运行时探测）
- [x] confirm/dismiss 触发词定义
- [x] 三种存储方案（hindsight_retain / memory / 快照文件）
- [x] 反馈影响机制（单条/多次的影响量化）
- [x] 快照 dismissed_topics 字段
- [x] 轻量反馈确认回应
- [x] references/feedback-loop.md
- [x] 验证：dismiss 记录存入 Hindsight 后可被召回

## 架构设计

### 核心原则

```
兴趣雷达是 Hermes Skill，不是插件或 Python 库。
SKILL.md 只定义接口行为，不绑定实现。
代码层面的工具（如 snapshot.py）交给 Claude Code 编写。
```

### 自适应上下文召回

| 优先级 | 源 | 说明 |
|--------|-----|------|
| 1 | 快照缓存 | TTL 6h，`~/.hermes/cache/interest-snapshot.json` |
| 2 | Hindsight recall | 主召回，快照过期时执行 |
| 3 | Obsidian 活跃项目 | 补充，无论 Hindsight 是否成功 |
| 4 | Hermes Memory | 前两者结果不足 3 条时 |
| 5 | 种子兴趣 | 以上全部不可用 |

### 自适应反馈存储

| 优先级 | 工具 | 场景 |
|--------|------|------|
| 1 | `hindsight_retain` | Hindsight 可用时 |
| 2 | `memory` | Hermes memory 可用时 |
| 3 | 快照文件 | 回退方案 |

### 接口

- `judge(url/title/content) → {score, bucket, why_it_matters, confidence, action}`（单条）
- `batch_judge(items, top_k=3) → {results, summary, context}`（批量）

## 平台无关化（2026-05-16）

SKILL.md 重构为平台无关版本：

- 去掉所有 Hermes 特定工具引用（hindsight_recall、browser_navigate、memory 等）
- 改为抽象描述，如"Agent 可用的记忆/搜索工具"
- 新增平台适配参考章节（Hermes、Claude Code、Codex/Cursor、ChatGPT）
- 新增配置章节，通过配置文件驱动运行
- 清理 3 个 Hermes 特定的 reference 文件
- 快照脚本注释去掉了 Hermes 引用

现在兴趣雷达可在任何 Agent 平台上运行。

## 已知问题

- web_extract 被 Nous 订阅限制，微信公众号文章需要 fallback 到 browser
- hindsight_reflect 有时不可用，此时跳过
- 快照缓存首次命中需要等待实时召回完成
- batch_judge 目前是 SKILL.md 定义的工作流，不是独立可调用的工具/命令

## 后续路线（Phase 3+）

- [ ] Provider 插件化：将 judge 逻辑拆成独立 Hermes 插件（交 Claude Code）
- [ ] 调用方 Skill 集成：follow-builders / xr-weekly 接入 batch_judge
- [ ] 多语言支持：英文内容判断
- [ ] 判断质量评估：建立 benchmark 测试集
