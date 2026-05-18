---
title: Claw Conductor - 架构与愿景
date: 2026-03-11
tags:
  - claw-conductor
  - openclaw
  - infrastructure
  - product-design
publish: false
---

# 🧠 Claw Conductor: 家庭算力编排中枢

> *"以 AI 为大脑，以硬件为触手，追求算力与能耗的极致平衡。"*

---

## 1. 核心愿景 (Vision)
构建一个**“能源感知型 (Energy-Aware)”**的家庭算力调度器。不追求 24/7 满载的“笨重 AIO 主机”，而是追求通过 AI 指令实现的高效、离散、按需唤醒的分布式算力集群。

## 2. 架构组件 (The Conductor Stack)

### 🧠 Brain (中枢) - OpenClaw
* **节点**: OEC 小主机 (ARM64 Docker)
* **角色**: 指挥官
* **职责**:
    * 状态感知 (Heartbeat & Health Checks)
    * 任务逻辑路由 (云端 API vs 本地 GPU)
    * Obsidian 知识库同步与内容发布
    * 数据存储 (NAS)

### 🚀 Muscle (执行者) - Win VM
* **节点**: Homelab RTX 5070
* **角色**: 算力搬运工
* **职责**: 
    * 3DGS 训练、重载推理、模型微调
    * 策略: 按需唤醒 (WoL/API) -> 计算 -> 自动关机

### 👁 Senses (感知层) - Vision Agent
* **节点**: 摄像头/HomeAssistant
* **角色**: 传感器
* **职责**: 场景监控、事件触发、视觉反馈

---

## 3. 设计准则 (The Principles)

1. **节能优先**: 绝不让高性能设备 (5070) 空转。所有任务由 Brain 评估后再决定是否激活 Muscle。
2. **单一数据源 (SSoT)**: NAS 是所有算力的唯一存储，挂载使用，杜绝多端同步带来的 loop 风险。
3. **安全隔离**: 容器作为隔离边界，严禁将“控制权”完全下放至宿主主机 (OEC/PVE)。
4. **Agentic Dispatching**: 随着能力的提升，未来通过 API 或 Webhook 替代 SSH 原生调用，实现任务状态的双向闭环。

---

## 4. 进化路线 (Roadmap)

### [ ] Phase 1: 基础设施 (Current)
* [x] OEC 大脑部署
* [x] Obsidian 自动 Git 同步与博客发布
* [x] Win VM 的基础控制逻辑

### [ ] Phase 2: 算力自动化
* [ ] 建立 Win VM 的 API 任务分发队列。
* [ ] 优化 5070 的能耗策略：非训练期间自动挂起。

### [ ] Phase 3: 感知与联动
* [ ] 接入 HomeAssistant。
* [ ] 实现视觉事件驱动：当检测到特定场景时，触发自动记录。

---

*“你的 HomeLab 不应该是一个待维护的设备堆，它应该是一个响应你需求的、有生命力的数字中枢。”*
EOF
