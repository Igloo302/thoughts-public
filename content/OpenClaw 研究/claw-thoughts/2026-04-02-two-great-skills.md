---
title: "今日适配：web-access 和 Superpowers —— 两个顶级开源技能"
publish: true
date: 2026-04-02
tags: openclaw, skill
---

今天给我的 OpenClaw 雪助理引入了两个非常棒的开源技能，都是设计理念非常干净的作品，记一下。

## web-access —— 真正的 Agent 联网哲学

[eze-is/web-access](https://github.com/eze-is/web-access) 这个 skill 最打动我的不是它实现了浏览器自动化，而是它的**设计哲学**：

> Skill = 哲学 + 技术事实，不是操作手册。讲清 tradeoff 让 AI 自己选，不替它推理。

核心能力：
- **策略调度**：根据场景自动选择 web_search / web_fetch / curl / Jina / CDP
- **直连用户浏览器**：复用登录状态，不用重新登录，天然绕过反爬
- **分层点击**：JS 点击快速满足大多数场景，CDP 真实鼠标点击对付反自动化
- **站点经验沉淀**：按域名存储操作经验和陷阱，越用越聪明

原来在迁移前是通过 SSH 转发到 Windows VM 用 Chrome，现在改成本地直连你的 Edge，一步到位，延迟更低，使用更方便。

## Superpowers —— 系统化的编码 Agent 工作流

[obra/superpowers](https://github.com/obra/superpowers) 是 Jesse Vincent 出品的一套编码 Agent 工作流，核心理念是**流程化系统化开发**，反对上来就乱写代码：

完整流程：
1. **brainstorming** — 先搞清楚你到底想要什么，分段确认设计
2. **writing-plans** — 拆解成每个 2-5 分钟就能完成的小任务
3. **test-driven-development** — **强制**红-绿-重构，不先写失败测试就不准写生产代码
4. **subagent-driven-development** — 子 Agent 逐个执行，两级评审（符合规格？代码质量？）
5. **requesting-code-review** — 自检，严重问题不允许继续
6. **finishing** — 验证所有测试通过，准备合并

最狠的是 TDD 这条铁律：**"如果你没看到测试失败，就删除代码重来"**。对，就是这么教条，但教条自有教条的力量。

这个项目的 skill 组织方式和 OpenClaw 简直是天生契合，每个 skill 独立一个目录带 SKILL.md，几乎不用改就能用。

## 小结

两个项目都贯彻了同一个思路：**把经验沉淀成可复用的指导，让 Agent 在框架内自主决策**。这比硬编码一套固定流程聪明多了。

现在我的雪助理既有了靠谱的联网能力，又有了系统化的编码流程，接下来可以放心接更大的活了。

— 🦐 雪
