---
tags:
  - 必先利其器
  - Obsidian
  - 知识管理
  - PARA
  - LLM Wiki
date: 2026-05-24
publish: true
---

# PARA × LLM Wiki：知识库的「双规」之道

> 让你的 Obsidian 知识库既有 PARA 的「执行力」，又有 LLM Wiki 的「沉淀力」

---

如果你在用 PARA（项目-领域-资源-归档）管理笔记，你大概已经经历过这样的场景：

- Clippings 里攒了 30+ 篇文章，读的时候觉得都重要，写完笔记再也没看过
- Diary 写了快 80 篇，每篇都是流水账，跨会话回顾时不知道从哪翻起
- 研究了一个新项目/新领域，写了几篇笔记，几个月后回来发现忘了当初的核心结论
- 同一个概念在不同笔记里反复解释，但从来没互相引用过

反过来，如果你看过 Karpathy 的 LLM Wiki 模式，可能会觉得：raw/ → entities/ → concepts/ 这套结构很清晰，但要我把现有的 PARA 笔记全部搬家？太折腾了。

**这不是「二选一」的问题。** PAR A 和 LLM Wiki 解决的是不同层面的问题，它们可以共存。

---

## 两者的本质区别

```
PARA (Project-Area-Resource-Archive)
├── 回答的是：我现在该做什么？
├── 组织粒度：整个笔记
├── 驱动力：任务推动（项目到期了就该动）
└── 弱点：知识会散落在各个项目里，跨目录的洞察难以积累

LLM Wiki
├── 回答的是：关于这件事我知道什么？
├── 组织粒度：概念/实体/对比（单个知识单元）
├── 驱动力：好奇心推动（读到新东西就更新相关页面）
└── 弱点：没有任务上下文，纯知识库不告诉你下一步该做什么
```

PARA 是**行动导向**的——它服务于"我在做什么"。LLM Wiki 是**知识导向**的——它服务于"我知道什么"。两者不是替换关系，而是互补关系。

用一个比喻：

- **PARA 是你的待办清单和项目文件夹**——告诉你当下该关注什么
- **LLM Wiki 是你的个人维基百科**——告诉你关于某个主题已经积累了哪些认知

一个擅长管「事」，一个擅长管「知」。

---

## 核心理念：三个选择

### 选择一：保持 PARA 的目录结构，不做大改

你不需要把笔记从 `1-Projects/` 搬到 `entities/` 目录下。PARA 的目录结构是为**项目执行**优化的，改掉它反而会破坏工作流。

具体怎么做：

```
ObsidianVault/          ← 你的 vault 根目录
├── 0-Inbox/            ← 临时收件箱
├── 1-Projects/         ← 活跃项目（不改）
├── 2-Areas/            ← 责任领域（不改）
├── 3-Resources/        ← 参考资料（不改）
├── 4-Archive/          ← 归档（不改）
├── Clippings/          ← 文章剪辑（不改）
├── Diary/              ← 每日日记（不改）
│
├── _wiki/              ← 新增：LLM Wiki 知识资产层
│   ├── _index.md       ← 目录：所有 wiki 页面一览
│   ├── _schema.md      ← 规矩：标签分类法、页面门槛、更新策略
│   ├── _log.md         ← 日志：每次知识操作记录
│   │
│   ├── concepts/       ← 概念页：一个概念一页
│   ├── entities/       ← 实体页：一个人/公司/产品一页
│   └── comparisons/    ← 对比页：两个东西的对比分析
│
├── _Navigation/        ← 已有导航目录
├── Templates/          ← 已有模板
└── Assets/             ← 已有附件
```

`_wiki/` 目录加了前导下划线，在 Obsidian 文件列表中靠前展示，方便快速跳转。

关键规则：`_wiki/` 里的页面**只引用不重复**已有笔记的内容。它不替代 `1-Projects/project-x/report.md`，而是引用它。

### 选择二：用「Ingest 仪式」替代「存了就忘」

这是 LLM Wiki 最有价值的部分——**每次摄入一个来源，不只是存档，而是更新知识库**。

你的现状：

```
Clippings/ 收到文章 → 存档 → 再没看过
```

加上 LLM Wiki 模式后：

```
Clippings/ 收到文章
    ↓
提取关键概念和实体
    ↓
检查 _wiki/ 中相关页面已存在吗？
    ├── 已有 → 更新、交叉引用、标注新来源
    └── 没有 → 建新页面（达到门槛才建）
    ↓
更新 _index.md 目录
更新 _log.md 日志
```

**门槛规则**（防止过度建页）：

- 一个概念在 2+ 个来源出现 → 建概念页
- 一个公司/人在 2+ 个来源被重点讨论 → 建实体页
- 一次性阅读的笔记 → 不建 wiki 页，只在 Clippings 里
- 概念页超过 200 行 → 拆分子页

### 选择三：定期做「知识审计」（Lint）

这是 LLM Wiki 另一个有价值的设计——**主动发现知识库的问题**。

每月或每季度跑一次检查：

1. **孤立页面**：`_wiki/` 里没有任何 `[[wikilinks]]` 引用进来的页面
2. **断链**：`[[链接]]` 指向了不存在的笔记
3. **过期内容**：`updated` 日期超过 90 天未更新，但 Diary 中一直在讨论相关话题
4. **矛盾**：两个页面提到同一件事但说法不同
5. **质量信号**：标注了 `confidence: low` 的页面需要补充来源

这不是为了找茬——而是发现那些你「以为已经整理好，但其实没人维护」的知识死角。

---

## 实际操作指南

### 第一步：建立 _wiki/ 目录骨架

在 vault 根目录创建：

```
_wiki/
├── _index.md           # 页面目录（自行维护，每个 wiki 页一行）
├── _schema.md          # 规范文档
├── _log.md             # 操作日志
├── concepts/           # 概念页
├── entities/           # 实体页
└── comparisons/        # 对比页
```

### 第二步：写 _schema.md

这是最重要的一步——**用一页纸定义你的知识管理规矩**。

```markdown
# Wiki Schema

## 领域覆盖
AI Agent、XR（AR/VR/MR）、独立开发、HomeLab、个人上下文系统

## 页面创建门槛
- 概念页：在 2+ 个来源中出现，且值得持续跟踪
- 实体页：公司/产品/人物，有多个维度的信息
- 对比页：需要做明确的 A vs B 分析
- ❌ 不要为一次性阅读的资料创建 wiki 页

## 标签分类法
- 领域: agent, xr, indie-dev, homelab, design
- 类型: concept, product, person, company, tool, framework
- 状态: active, mature, deprecated, speculative
- 来源: paper, article, video, podcast, practice

## 每页必须包含
- YAML frontmatter（title, created, updated, type, tags, source）
- 至少 2 个 [[wikilinks]] 指向其他页面
- 更新日期必须修改

## 更新策略
- 新信息与旧信息矛盾 → 两条都记，标注争议
- 新来源补充已有页面 → 合并，标注 provenance
- 单一来源的 claim → confidence: medium（除非有多源验证）
```

### 第三步：写第一个 wiki 页面

从你最常接触的领域开始——比如 AI Agent 或 XR。

```markdown
---
title: MCP (Model Context Protocol)
created: 2026-05-24
updated: 2026-05-24
type: concept
tags: [agent, tool, protocol, active]
sources:
  - Clippings/OpenClaw-闭门局-agent-生态位.md
  - 3-Resources/Tech/MCP-协议分析.md
confidence: high
---

# MCP (Model Context Protocol)

## 是什么
Anthropic 提出的开放协议，定义 AI agent 如何通过标准化接口调用外部工具。

## 关键事实
- 2024 年底发布，开源
- 类比：MCP 之于 AI = USB-C 之于硬件
- 核心模型：Client → Server → Resource/Tool/Prompt

## 与相关概念的关系
- 对标 [[OpenAI Function Calling]]（但更开放、工具导向）
- 与 [[Agent Orchestration]] 配合使用
- 依赖 [[MCP Server]] 作为执行端

## 当前状态
- 已经有 1000+ 公开 MCP servers
- Claude Desktop、Cursor、VS Code 等已原生支持
- 被质疑：Host 端实现碎片化，缺少访问控制标准

## 来源
- [OpenClaw 闭门局讨论](Clippings/OpenClaw-闭门局-agent-生态位.md) — 2026-04
- [MCP 协议分析笔记](3-Resources/Tech/MCP-协议分析.md) — 2026-05
```

### 第四步：建立 Ingest 流程

每次你在执行一个项目或看一篇文章时，多做一个动作：

1. 文章 → `Clippings/`（照旧）
2. 识别文章里提到的 2-3 个核心概念或实体
3. 到 `_wiki/concepts/` 和 `_wiki/entities/` 检查是否已存在
4. 如有 → 更新现有页面，添加新信息和交叉引用
5. 如无且达到门槛 → 创建新页面
6. 更新 `_index.md`（如新建页面）
7. 追加一行到 `_log.md`

这个流程一次大概 3-5 分钟。**性价比最高的 5 分钟**——因为你在建造的是「下次搜索时能找到」的知识基础设施。

### 第五步：与 Diary 联动

Diary 是你每天积累原始素材的地方。一个简单的惯例：**每周五花 10 分钟回顾本周 Diary，看看有没有值得提升到 _wiki/ 的洞察**。

```markdown
## 2026-W21 Wiki Check-in

回顾本周 Diary（5/18-5/24）：
- 周二讨论了 qmd 替代方案 → 概念已存在（qmd），更新引用
- 周三研究 MCP Server 安全方案 → 新建概念页 "MCP Access Control"
- 周四确认 Hermes Agent fallback 配置 → 更新 entity/hermes-agent

变动：
- ✏️ 更新: concepts/qmd.md
- 📄 新建: concepts/mcp-access-control.md
- ✏️ 更新: entities/hermes-agent.md
```

---

## 时间投入参考

| 阶段 | 频率 | 耗时 |
|------|------|------|
| 搭建 _wiki/ 骨架 | 一次性 | 30 分钟 |
| 写 _schema.md | 一次性 | 20 分钟 |
| 每次 Ingest | 随缘（每次读到好东西） | 3-5 分钟 |
| 每周 Wiki Check-in | 每周一次 | 10 分钟 |
| 每月 Lint | 每月一次 | 15 分钟 |

一个月大概 1.5 小时投入。对比效果：

- **第 1 周**：有了 `_index.md`，终于知道自己的知识库有什么了
- **第 1 月**：概念页和实体页开始积累，Graph View 有了形状
- **第 3 月**：面对新项目时，第一反应是查 `_wiki/` 而不是重新谷歌
- **第 6 月**：知识库变成了可依赖的个人维基百科，跨会话的困惑大幅减少

---

## 何时不需要做这些

如果你符合以下任一情况，这套方法对你来说过度设计了：

- 你的笔记纯粹是"写给自己看"，不需要跨时间回顾
- 你每个领域只有 1-2 篇笔记，交叉引用没什么意义
- 你更喜欢文件夹整理，知识结构化让你觉得麻烦

知识管理是**手段不是目的**——如果这套流程让你觉得在「做家务」而不是「帮你工作」，那就简化或跳过。

---

## 总结

PARA 和 LLM Wiki 不是对手。PARA 管事的执行，Wiki 管知的沉淀。

在实践中，两者的分工很清晰：

| 场景 | 用 PARA | 用 Wiki |
|------|---------|---------|
| 今天要干什么 | ✅ 看 1-Projects/ | ❌ |
| 关于 MCP 我知道什么 | ❌ 可能散在 3 个目录 | ✅ 一个概念页看完 |
| 做项目调研 | ✅ 存到 1-Projects/xxx/ | ✅ 同时更新概念页 |
| 整理日记 | ✅ 按日期归档 | ✅ 每周提炼一次 |
| 回顾知识库全貌 | ❌ 每个目录翻一遍 | ✅ 看 _index.md 就够了 |
| 发现矛盾的知识 | ❌ 除非你刻意找 | ✅ Lint 自动发现 |

你可以从今天开始，就做三件事：

1. 建个 `_wiki/` 目录
2. 写个 `_schema.md`（复制上面的模板改改就行）
3. 找一篇你最近读的最有价值的文章，执行一次 Ingest

五分钟后你就有了第一个 wiki 页面。剩下的慢慢来。
