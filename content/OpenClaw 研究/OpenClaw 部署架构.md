---
title: OpenClaw 部署架构与自动化体系
date: 2026-03-11
tags:
  - openclaw
  - infrastructure
  - architecture
publish: false
---

# 🏗 OpenClaw 部署架构与自动化体系

> *记录当前的分布式部署逻辑、资源分配与安全边界。*

## 1. 整体拓扑 (Brain-Muscle-Storage)

我们将系统解耦为三个层级，通过网络互联：

### A. Brain (中枢 - OEC 容器)
* **角色**: 唯一的大脑。所有逻辑、定时任务、Git 同步、外部调用均在此发生。
* **职责**:
    * 运行 OpenClaw 及所有自动化脚本 (Heartbeat)。
    * 维护 Obsidian Vault 的 Git 同步。
    * 监控并调度后端算力。

### B. Data (底座 - OEC 宿主机)
* **角色**: 数据存储与服务运行。
* **职责**:
    * 提供 Docker 运行环境。
    * 提供 NAS 文件存储 (vol1, Download, Photos)。
    * **严格准则**: 仅运行 Docker 服务和 NAS 工具，**禁止乱动任何系统环境**。

### C. Muscle (算力 - Homelab PVE/VM)
* **角色**: 执行终端。
* **职责**:
    * **Win VM**: RTX 3060 重负载算力、模型训练。
    * **macOS VM**: Apple 生态桥接（降级为 Worker Node）。
    * **HA**: 智能硬件/场景控制。

---

## 2. 操作权限准则

作为“指挥官”，必须严格遵守：

1. **绝对禁区**:
    * **PVE 主机 (192.168.5.100)**: 仅允许查询 `qm` 状态，禁止安装/改环境。
    * **OEC 宿主机 (192.168.5.139)**: 仅允许存储管理和 Docker 指令，禁止安装软件。

2. **行为规范**:
    * 所有逻辑代码必须在 **OpenClaw 容器内** 编写与执行。
    * 若需在宿主机执行任务，必须编写 shell 脚本后通过 `docker exec` 或 SSH 远程触发。

---

## 3. 分布式协作逻辑

* **触发者**: OEC 容器 (Brain)
* **执行者**: Homelab (Muscle/Worker)
* **同步方式**:
    * 代码/配置: Git (GitHub 枢纽)
    * 数据传输: SSH / SCP / WebDAV

---

*Powered by OpenClaw Conductor*
EOF
