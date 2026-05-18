---
created: 2026-05-01
status: active
tags:
  - skill
  - agent
  - embodiment
  - product
version: 1.0.1
---

# Agent Embodiment v1.0 — 产品方案

> **一句话**：Agent 的「身体感」——知道自己是谁、在哪、周围有什么、能控制什么。

---

## 1. 产品定位

### 1.1 这是什么

Agent Embodiment 是一个 Hermes Agent Skill，让 Agent 拥有物理世界的「身体感知」能力。它不是设备管理平台，不是监控系统，不是自动化工具——它只做一件事：

**让 Agent 知道「有什么」**。

具体做什么、怎么操作，由其他 skill 负责。

Embodiment（具身性）是 AI Agent 的基础能力：
- **自我认知**：知道自己运行在什么机器上、有什么能力
- **环境感知**：发现网络中的设备、理解拓扑结构
- **能力边界**：知道自己能控制什么、不能控制什么
- **状态记忆**：记住设备状态，支持增量更新


### 1.2 解决的问题

| 问题 | 场景 |
|------|------|
| Agent 不知道自己在哪台机器上跑 | "你跑在什么配置上？"→ 答不出 |
| Agent 不知道周围有什么设备 | "连一下那个 NAS"→ 不知道是哪个 |
| Agent 不知道设备有什么能力 | "用 GPU 跑一下"→ 不知道哪台有 GPU |
| 每次都要手动告诉 Agent 设备信息 | "我的 IP 是 192.168.5.xxx"→ 记不住 |
| 设备状态变化 Agent 感知不到 | 关机 / 重启 / 新设备上线 → 不知道 |

### 1.3 适用范围

- **运行环境**：macOS、Linux、Docker 容器
- **Agent 平台**：Hermes Agent（优先）、Claude Code、OpenClaw、Codex CLI
- **网络范围**：本地网络、ZeroTier/Tailscale 等组网
- **设备类型**：服务器、VM、NAS、路由器、推理 GPU、智能设备

---

## 2. 用户故事

### 2.1 首次使用：一日设备清单

> 小陈刚搭好 HomeLab，装了 Hermes Agent 和 Embodiment skill。
>
> **安装后自动触发**新手引导：
> 1. 扫描本机（MacBook M1）→ 记录系统、CPU、内存、摄像头
> 2. 扫描局域网（192.168.5.0/24）→ 发现 PVE、NAS、Windows VM
> 3. 扫描 ZeroTier（192.168.193.0/24）→ 发现网关机
> 4. 探测服务 → PVE 的 8006、Ollama 的 11434、NAS 的 5000
> 5. 生成 schema，汇报摘要
>
> 小陈确认后，schema 就位。

### 2.2 日常使用：打开我的电脑

> 小陈说：「打开我的 Windows 电脑」
>
> Agent 从 schema 查：`name LIKE "Windows" OR type = "vm" AND ip = "192.168.5.109"`
> → 匹配到 Win-RTX5070 → 返回 IP + access method
> → Windows skill 接管操作（SSH/远程桌面）

### 2.3 被动学习：从对话中补充信息

> 小陈 SSH 到 PVE，在对话中说：
> 「PVE 上还有一台 Debian VM，IP 是 192.168.5.105」
>
> Agent **自动识别**新设备信息，调用 `learn_device` 学习到 schema。
> 不打断对话，静默完成。

### 2.4 设备离线：不慌不忙

> Windows VM 被关机了。
>
> 小陈说：「跑一下那个模型」
> → Agent 查 schema → 发现 GPU 在那台 Windows 上 → 尝试连接 → 失败
> → 标记 `status: unreachable`（不是删除）
> → 告诉用户：「Win-RTX5070 连不上，可能是关机了，要我先尝试唤醒吗？」
>
> 如果连续 7 天 unreachable → 自动标记 `status: offline`，建议确认删除。

---

## 3. 核心功能

### 3.1 新手引导（Setup Wizard）⭐

**触发条件**：
- Skill 安装后首次加载 → 自动弹出引导
- body-schema.json 不存在 → 自动弹出引导
- 用户手动触发（`embodiment setup`）

---

**完整流程**：

```
┌─────────────────────────────────────────────────────────┐
│  [Phase 0] 环境检查                                      │
├─────────────────────────────────────────────────────────┤
│  1. 检查 MCP Server 状态                                 │
│     - query_device 工具可用？                            │
│     - learn_device 工具可用？                            │
│     - 失败 → 提示用户检查 config.yaml 中的 mcp_servers   │
│                                                          │
│  2. 检查依赖                                             │
│     - Python 3.8+                                        │
│     - nmap / arp / ping（网络扫描）                       │
│     - 缺失 → 提示安装命令                                │
│                                                          │
│  3. 检查权限                                             │
│     - 网络访问权限（macOS 需要授权）                      │
│     - 摄像头/麦克风权限（可选，用于能力检测）             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  [Phase 1] 本机扫描（~5秒）                              │
├─────────────────────────────────────────────────────────┤
│  扫描内容：                                              │
│  - hostname / OS / arch / CPU / 内存                    │
│  - 网络接口：en0, zt*, utun 等                          │
│  - IP地址：本地 + VPN/组网                               │
│  - MAC地址：用于生成 self.id                            │
│  - 硬件能力：摄像头、麦克风、蓝牙、GPU                   │
│                                                          │
│  输出示例：                                              │
│  ┌────────────────────────────────────────┐             │
│  │ 🖥️  本机信息                           │             │
│  │   hostname: igloo-mac                  │             │
│  │   OS: macOS 15.2 (arm64)               │             │
│  │   CPU: Apple M1                        │             │
│  │   Memory: 16 GB                        │             │
│  │   IPs: 192.168.5.40, 192.168.193.40    │             │
│  │   MAC: aa:bb:cc:dd:ee:ff               │             │
│  │   Capabilities: metal, camera, mic     │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  用户操作：[确认] [修改] [跳过]                          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  [Phase 2] 网络扫描（~30-60秒）                          │
├─────────────────────────────────────────────────────────┤
│  扫描范围：                                              │
│  - 自动检测：en0 → 192.168.5.0/24                       │
│  - 自动检测：zt* → 192.168.193.0/24                     │
│  - 用户可添加其他网段                                    │
│                                                          │
│  扫描过程：                                              │
│  [████████░░░░░░░░░░] 40% - ARP扫描中...                │
│  [████████████████░░░░] 80% - 端口探测中...             │
│  [████████████████████] 100% - 完成                     │
│                                                          │
│  发现设备列表：                                          │
│  ┌────────────────────────────────────────┐             │
│  │ 发现 5 台设备：                         │             │
│  │                                        │             │
│  │ [✓] 192.168.5.100  pve-main            │             │
│  │     Ports: 22, 8006                    │             │
│  │     Type: hypervisor                   │             │
│  │                                        │             │
│  │ [✓] 192.168.5.109  Win-RTX5070         │             │
│  │     Ports: 22, 3389, 11434, 8188       │             │
│  │     Type: vm (inferred)                │             │
│  │                                        │             │
│  │ [✓] 192.168.5.139  FnOS-NAS            │             │
│  │     Ports: 22, 5000                    │             │
│  │     Type: nas                          │             │
│  │                                        │             │
│  │ [?] 192.168.5.1    Unknown             │             │
│  │     Ports: 80, 443                     │             │
│  │     Type: ? (可能是路由器)             │             │
│  │                                        │             │
│  │ [✗] 192.168.5.105  (无响应)            │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  用户操作：[全选] [逐个确认] [添加设备] [重扫]           │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  [Phase 2.5] 记忆补充（~5秒）                             │
├─────────────────────────────────────────────────────────┤
│  Agent 读取自身记忆，补充扫描可能遗漏的设备：              │
│                                                          │
│  工作原理：                                              │
│  - Agent 从自己的记忆（Hindsight / MEMORY.md / 其他）中  │
│    提取设备信息（IP、类型、名称、能力）                  │
│  - 通过 --memory-devices 参数传入 merge-schema.py        │
│  - 脚本负责过滤重复、过滤无效 IP（网段 .0 / 广播 .255） │
│  - 补充到 schema.devices（不覆盖已存在的设备）           │
│  - 标记 source: "memory_supplement", discovered: false   │
│                                                          │
│  调用方式：                                              │
│  ┌────────────────────────────────────────┐             │
│  │ python3 ~/.hermes/.../merge-schema.py   │             │
│  │   --memory-devices '[                   │             │
│  │     {"ip":"192.168.5.100",              │             │
│  │      "type":"hypervisor",               │             │
│  │      "name":"PVE"},                     │             │
│  │     {"ip":"192.168.5.139",              │             │
│  │      "type":"nas",                      │             │
│  │      "name":"FnOS-NAS"}                 │             │
│  │   ]'                                    │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  输出示例：                                              │
│  ┌────────────────────────────────────────┐             │
│  │ 📝 从 Memory 补充 2 台设备：            │             │
│  │                                        │             │
│  │ PVE (192.168.5.100)                    │             │
│  │   Type: hypervisor                     │             │
│  │   Source: memory_supplement            │             │
│  │                                        │             │
│  │ FnOS-NAS (192.168.5.139)               │             │
│  │   Type: nas                            │             │
│  │   Source: memory_supplement            │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  ⚠️ 优雅降级：                                          │
│  - 不传 --memory-devices → 跳过此步骤，不影响主流程      │
│  - JSON 解析失败 → 打印 warning，继续执行                │
│  - 无相关记忆 → 正常继续                                 │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  [Phase 3] 能力探测（可选，~1-2分钟）                     │
├─────────────────────────────────────────────────────────┤
│  对已确认设备深入探测：                                   │
│                                                          │
│  PVE (192.168.5.100):                                    │
│    - SSH连接测试 → 需要认证                              │
│    - 提示：「检测到SSH服务，是否配置访问凭据？」          │
│      [配置SSH密钥] [稍后] [跳过]                         │
│                                                          │
│  Win-RTX5070 (192.168.5.109):                            │
│    - Ollama API → GET /api/tags → 发现模型列表           │
│    - ComfyUI → GET /system_stats → 发现GPU信息           │
│    - 自动补充：capabilities: [cuda, inference, image_gen]│
│                                                          │
│  FnOS-NAS (192.168.5.139):                               │
│    - DSM API → 需要认证                                  │
│    - SMB探测 → 发现共享文件夹                            │
│                                                          │
│  ⚠️ 凭据处理原则：                                       │
│  - 不存储密码/token到schema                              │
│  - SSH：引导用户配置 ~/.ssh/config                       │
│  - API：引导用户设置环境变量或 .env 文件                 │
│  - 可选：记录 access.user 和 access.key_path             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  [Phase 4] 生成 Schema & 演示                            │
├─────────────────────────────────────────────────────────┤
│  1. 生成 body-schema.json                                │
│     - 写入 ~/.hermes/skills/agent-embodiment/            │
│     - 显示摘要：3台设备已确认，2台待认证，1台跳过        │
│                                                          │
│  2. 首次查询演示                                         │
│     ┌────────────────────────────────────────┐          │
│     │ 💡 试试问我：                          │          │
│     │                                        │          │
│     │ 「我有哪些设备？」                      │          │
│     │ 「有GPU的机器是哪台？」                 │          │
│     │ 「Ollama跑在哪？」                      │          │
│     └────────────────────────────────────────┘          │
│                                                          │
│     Agent 自动调用 query_device() 演示效果：             │
│     ┌────────────────────────────────────────┐          │
│     │ 🔍 查询结果：                          │          │
│     │                                        │          │
│     │ 有GPU的设备：                          │          │
│     │ - Win-RTX5070 (192.168.5.109)          │          │
│     │   GPU: RTX 5070 (12GB VRAM)            │          │
│     │   Capabilities: cuda, inference        │          │
│     └────────────────────────────────────────┘          │
│                                                          │
│  3. 完成引导                                             │
│     [✓] Schema 已生成                                    │
│     [✓] MCP 工具可用                                     │
│     [✓] 首次查询成功                                     │
│                                                          │
│     用户操作：[完成] [重新扫描] [手动编辑schema]         │
└─────────────────────────────────────────────────────────┘
```

---

**关于密码/凭据**：

embodiment **不生成也不存储密码**。引导流程中遇到需要认证的设备：

| 场景 | 引导方式 |
|------|---------|
| SSH访问 | 检查 `~/.ssh/config` 是否已配置，未配置则给出示例 |
| API Token | 提示设置环境变量（如 `OLLAMA_API_KEY`） |
| Web登录 | 告知用户「需要认证，稍后可手动配置」 |

**SSH配置示例**（引导中展示）：

```bash
# ~/.ssh/config
Host pve-main
    HostName 192.168.5.100
    User root
    IdentityFile ~/.ssh/id_ed25519

Host win-rtx5070
    HostName 192.168.5.109
    User igloo
    IdentityFile ~/.ssh/id_ed25519
```

配置完成后，embodiment 只记录：
```json
{
  "id": "00:11:22:33:44:55",
  "name": "pve-main",
  "access": {
    "method": "ssh",
    "user": "root",
    "key_path": "~/.ssh/id_ed25519"
  }
}
```

---

**关于MCP安装**：

MCP server 是 skill 的一部分，**不需要用户单独安装**：

```
~/.hermes/skills/agent-embodiment/
├── SKILL.md
├── body-schema.json
├── scripts/
│   ├── discover-self.sh
│   ├── discover-network.sh
│   └── ...
└── mcp/
    └── server.py          ← MCP Server（自动加载）
```

Hermes 启动时会自动：
1. 扫描 `~/.hermes/skills/` 目录
2. 加载每个 skill 的 MCP server（如果有）
3. 注册 MCP 工具到 Agent 上下文

**用户只需要**：
```bash
cp -r agent-embodiment ~/.hermes/skills/
```

**如果MCP加载失败**，引导会提示：
```
⚠️ MCP工具未加载，请检查：

1. 编辑 ~/.hermes/config.yaml
2. 添加：
   mcp_servers:
     embodiment:
       command: python3
       args: ["~/.hermes/skills/agent-embodiment/mcp/server.py"]

3. 重启 Hermes
```

---

**引导特点**：
- 分阶段展示，不一次性丢信息
- 每阶段可跳过/重做
- 发现结果可逐台确认/调整
- 凭据配置是可选的（不强制）
- 首次查询演示让用户立即看到价值

### 3.2 设备发现

**自动发现范围**：

| 层次 | 范围 | 方法 |
|------|------|------|
| Layer 1 | 本地网络 | ARP 表 + ping 扫描 |
| Layer 2 | VPN/组网 | ZeroTier API、Tailscale API |
| Layer 3 | 远程主机 | SSH 代理跳转 |

**协议识别**（端口推断）：

| 端口 | 服务 | 推断设备类型 |
|------|------|------------|
| 22 | SSH | Linux 服务器 |
| 80/443 | HTTP(S) | Web 服务器 |
| 445 | SMB | 文件服务器 / NAS |
| 5000 | Synology DSM | NAS |
| 8006 | PVE Web | Hypervisor |
| 11434 | Ollama API | 推理服务器 |
| 8188 | ComfyUI | 生图服务器 |
| 9090 | TrueNAS | NAS |
| 32400 | Plex | 媒体服务器 |
| 8096 | Jellyfin | 媒体服务器 |

### 3.3 设备查询与匹配

**核心能力**：用户说模糊描述时，能从 schema 中找到正确设备。

| 用户说 | 匹配逻辑 | 返回 |
|--------|---------|------|
| 「打开我的电脑」 | name 模糊匹配 "Windows" / "电脑" | Win-RTX5070 (192.168.5.109) |
| 「那个有 GPU 的机器」 | capabilities 含 "cuda" / "gpu" | 匹配设备列表 |
| 「连一下 Debian VM」 | name/type 模糊匹配 | 192.168.5.105 |
| 「路由器设置」 | type = router | 网关 IP |
| 「跑一下模型」 | capabilities 含 "inference" | 匹配推理服务器 |

**匹配优先级**：
1. exact match（IP / name 精确匹配）
2. fuzzy match（name 包含关键词）
3. capability match（能力匹配）
4. type match（设备类型匹配）
5. 多结果时返回列表让用户选

### 3.4 被动学习

**从对话中自动学习**：

| 触发模式 | 示例 | 学到什么 |
|---------|------|---------|
| IP 地址出现 | 「192.168.5.100 的 PVE」 | IP + type=hypervisor |
| 设备名称 + 操作 | 「SSH 到那台服务器」 | type=server（需确认 IP） |
| 能力暗示 | 「用 GPU 跑模型」 | capabilities 含 gpu/inference |
| 操作结果 | SSH 成功 → uname -a | hostname、OS、架构 |

**学习规则**：
- 高置信度（IP + 类型同时出现）→ 静默自动添加
- 中置信度（只有 IP 或只有类型）→ 询问确认
- 低置信度（模糊描述）→ 不添加，等待更多信息
- 已存在设备 → 只更新状态/能力，不重复创建

### 3.5 设备生命周期

**状态机**：

```
             [新发现]
                │
                ▼
          ┌─────────────┐
          │  reachable   │ ←── 正常在线
          └──────┬──────┘
                 │ 连接失败
                 ▼
          ┌─────────────┐
          │ unreachable  │ ←── 可能是网络波动 / 关机
          └──────┬──────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  [5min 内恢复]      [>5min 未恢复]
  自动改回            │
  reachable           ▼
               ┌─────────────┐
               │   warning   │ ←── 提醒用户
               └──────┬──────┘
                      │ >24h
                      ▼
               ┌─────────────┐
               │   offline   │ ←── 建议确认是否删除
               └──────┬──────┘
                      │ >7 天且用户确认
                      ▼
               ┌─────────────┐
               │   deleted   │ ←── 从 schema 移除
               └─────────────┘
```

**状态说明**：

| 状态 | 含义 | 自动操作 |
|------|------|---------|
| `reachable` | 在线可达 | 无 |
| `unreachable` | 暂时不可达（<5min） | 自动恢复时改回 reachable |
| `warning` | 持续不可达（>5min） | Agent 主动提醒用户 |
| `offline` | 长时间离线（>24h） | 建议清理，但不自动删除 |
| `auth_required` | 需要认证 | 跳过探测，建议配密钥 |
| `deleted` | 已移除 | 自动清理（用户确认后） |

**网络波动 vs 真正离线**：
- 5 分钟内恢复 → 标记 `last_unreachable` 时间戳，不改状态
- 5 分钟-24 小时 → 标记 `status: warning`
- >24 小时 → 标记 `status: offline`
- >7 天 → 建议用户删除

### 3.6 能力发现

设备的能力信息在初始扫描和后续使用中逐步丰富：

**初始**（仅靠端口和基础探测）：
```
{
  "ip": "192.168.5.109",
  "ports": [22, 11434, 8188],
  "capabilities": ["ssh", "inference", "image_gen"],
  "device_type": "vm"  // 基于端口推断
}
```

**后续补充**（通过 MCP 操作深入探测）：
```
{
  "ip": "192.168.5.109",
  "hostname": "Win-RTX5070",
  "os": "Windows 11",
  "arch": "x86_64",
  "ports": [22, 3389, 11434, 8188, 5900],
  "capabilities": ["ssh", "rdp", "cuda", "rtx5070", "vram_12gb", "inference", "image_gen"],
  "device_type": "vm",
  "hypervisor": "pve-main (192.168.5.100)",
  "access": { "method": "ssh", "user": "igloo" }
}
```

---

## 4. 数据模型

### 4.1 body-schema.json

```json
{
  "schema_version": "1.0",
  "last_updated": "2026-05-01T14:00:00+08:00",

  "self": {
    "hostname": "igloo-mac",
    "os": "macOS 15.2",
    "arch": "arm64",
    "cpu": "Apple M1",
    "memory_gb": 16,
    "disks": [{ "mount": "/", "total_gb": 500, "used_gb": 320 }],
    "ips": ["192.168.5.40", "10.147.17.1"],
    "capabilities": ["metal", "camera", "microphone", "bluetooth"]
  },

  "environment": {
    "timezone": "Asia/Shanghai",
    "networks": [
      { "interface": "en0", "subnet": "192.168.5.0/24", "type": "local" },
      { "interface": "zt7kf3yxj2", "subnet": "192.168.193.0/24", "type": "zerotier" }
    ]
  },

  "devices": [
    {
      "id": "00:11:22:33:44:55",
      "name": "pve-main",
      "type": "hypervisor",
      "ips": ["192.168.5.100", "192.168.193.71"],
      "primary_ip": "192.168.5.100",
      "mac": "00:11:22:33:44:55",
      "port": 22,
      "status": "reachable",
      "discovered": true,
      "last_seen": "2026-05-01T13:55:00+08:00",
      "capabilities": ["ssh", "hypervisor", "virtualization"],
      "children": ["aa:bb:cc:dd:ee:ff", "11:22:33:44:55:66"]
    },
    {
      "id": "aa:bb:cc:dd:ee:ff",
      "name": "Win-RTX5070",
      "type": "vm",
      "ips": ["192.168.5.109"],
      "primary_ip": "192.168.5.109",
      "mac": "aa:bb:cc:dd:ee:ff",
      "status": "reachable",
      "discovered": true,
      "last_seen": "2026-05-01T12:00:00+08:00",
      "capabilities": ["ssh", "rdp", "cuda", "vram_12gb", "inference", "image_gen"],
      "parent": "00:11:22:33:44:55"
    }
  ],

  "services": [
    {
      "id": "ollama-main",
      "name": "Ollama",
      "type": "inference",
      "url": "http://192.168.5.109:11434",
      "device_id": "192-168-5-109",
      "capabilities": ["llm", "reasoning"]
    },
    {
      "id": "comfyui-win",
      "name": "ComfyUI",
      "type": "image_gen",
      "url": "http://192.168.5.109:8188",
      "device_id": "192-168-5-109",
      "capabilities": ["image_generation", "workflow"]
    }
  ],

  "discovery_meta": {
    "schema_version": "1.0",
    "last_full_discovery": "2026-05-01T14:00:00+08:00",
    "last_passive_update": "2026-05-01T13:55:00+08:00",
    "discovery_count": 1
  }
}
```

### 4.2 字段说明

|| 字段 | 必填 | 说明 | 敏感 |
|------|------|------|------|
| `id` | ✅ | 设备唯一标识（MAC地址） | ❌ |
| `mac` | ✅ | MAC地址（与id相同） | ❌ |
| `ips` | ✅ | IP地址数组（支持多网络） | ❌ |
| `primary_ip` | ✅ | 主要IP（用于默认连接） | ❌ |
| `name` | ❌ | 设备名称（hostname/别名） | ❌ |
| `type` | ✅ | 设备类型 | ❌ |
| `status` | ✅ | 设备状态 | ❌ |
| `capabilities` | ❌ | 能力列表 | ❌ |
| `ports` | ❌ | 开放端口 | ❌ |
| `access.method` | ❌ | 访问方式（ssh/http） | ❌ |
| `access.user` | ❌ | 用户名 | ⚠️ |
| `access.key_path` | ❌ | SSH 密钥路径 | ❌ |
| `discovered` | ✅ | 自动发现标记 | ❌ |
| `last_seen` | ✅ | 最后在线时间 | ❌ |
| `children` | ❌ | 子设备ID列表（MAC） | ❌ |
| `parent` | ❌ | 父设备ID（MAC） | ❌ |

### 4.3 设备唯一标识（1.0 核心改进）

**为什么用 MAC 地址**：

| 方案 | 问题 |
|------|------|
| IP地址作为id | DHCP下IP会变，多网络环境同一设备有多个IP |
| hostname作为id | 可能重复、可能修改 |
| MAC地址 | **最稳定**，硬件唯一，不随网络变化 |

**合并逻辑**：

```
扫描发现新IP (192.168.193.71)
    │
    ▼
查询MAC (00:11:22:33:44:55)
    │
    ├── MAC已存在于schema？
    │       │
    │       ├── 是 → 追加IP到ips数组，更新primary_ip（如果更优）
    │       │
    │       └── 否 → 新建设备记录
    │
    └── MAC获取失败？
            │
            ▼
        用 hostname + IP 组合作为临时id
        标记 id_type: "temporary"
        后续获取到MAC时再合并
```

**多IP场景**：

```json
{
  "id": "00:11:22:33:44:55",
  "ips": ["192.168.5.100", "192.168.193.71"],
  "primary_ip": "192.168.5.100"
}
```

- `ips`：所有已知IP（本地网络、VPN、ZeroTier等）
- `primary_ip`：默认连接用的IP（通常是本地网络）
- `query_device(ip=xxx)`：匹配ips数组中的任意一个

### 4.4 不存储的字段（黑名单）

以下信息**绝不**写入 schema：

```
password, passwd, secret, token, api_key, apikey,
private_key, pem, key_content, auth_code, cookie,
session_key, credential
```

用户如需记录凭据，应使用：
- Hermes Credential Pool（推荐）
- 1Password / Bitwarden 等密码管理器
- SSH key 认证（配好密钥即可）

---

## 5. 技术架构

### 5.1 组件

```
┌──────────────────────────────────────────────────┐
│                   Agent (Hermes)                   │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │ Skill Load  │  │  MCP Client  │  │  Dialog  │ │
│  └──────┬──────┘  └──────┬───────┘  └────┬─────┘ │
│         │                │               │        │
└─────────┼────────────────┼───────────────┼────────┘
          │                │               │
          ▼                ▼               ▼
┌──────────────────────────────────────────────────┐
│               Embodiment MCP Server                │
│                                                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ Schema   │  │ Learn    │  │ Setup Wizard     │ │
│  │ Reader   │  │ Device   │  │ (first-run)      │ │
│  └────┬─────┘  └────┬─────┘  └────────┬─────────┘ │
│       │              │                 │           │
│       ▼              ▼                 ▼           │
│  ┌──────────────────────────────────────────────┐  │
│  │              body-schema.json                 │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ Discovery │  │ Passive  │  │ Lifecycle        │ │
│  │ Scripts   │  │ Learning │  │ Manager          │ │
│  └──────────┘  └──────────┘  └──────────────────┘ │
└──────────────────────────────────────────────────┘
```

### 5.2 MCP 工具列表（1.0）

**精简原则**：只暴露高频调用的工具，低频操作用脚本。

|| 工具 | 说明 | 触发时机 |
|------|------|---------|
| `query_device` | 查询/匹配设备 | 用户问环境/设备/模糊查找 |
| `learn_device` | 从对话中学习设备信息 | 对话中出现设备信息（被动学习） |

**query_device 参数**：

```python
def query_device(
    name: str = None,        # 按名称模糊匹配
    ip: str = None,          # 按 IP 匹配
    capability: str = None,  # 按能力匹配
    type: str = None,        # 按设备类型匹配
    status: str = None,      # 按状态筛选
) -> dict:
    """
    无参数 → 返回完整 schema
    有参数 → 返回匹配的设备列表
    """
```

**调用示例**：

```bash
# 查全部设备
query_device()

# 模糊查找
query_device(name="Windows")
query_device(capability="cuda")
query_device(type="vm", status="reachable")
```

---

**不暴露为 MCP 的功能**（用脚本实现）：

| 功能 | 实现方式 | 原因 |
|------|---------|------|
| 更新设备信息 | `scripts/update-device.py` | 低频，手动操作 |
| 新手引导 | Skill 加载时自动检测 | 内部逻辑，不需用户调用 |
| 生命周期检查 | 后台定时任务 | 自动化，不占上下文 |
| 验证操作结果 | 调用方 skill 自己做 | 职责分离 |

### 5.3 配置文件

```yaml
# ~/.hermes/config.yaml 中的 embodiment 配置
embodiment:
  # 新手引导
  setup_wizard: auto           # auto | manual | disabled
  setup_networks:              # 扫描哪些网络（留空自动检测）
    - "192.168.5.0/24"
    - "192.168.193.0/24"

  # 生命周期
  lifecycle:
    unreachable_threshold: 5m  # 多久算 unreachable → warning
    offline_threshold: 24h     # 多久算 offline
    auto_cleanup: 7d           # 多久后建议删除
    cleanup_confirm: true      # 需要用户确认才删除

  # 扫描范围
  scan_timeout: 30             # 单设备超时(秒)
  port_timeout: 2              # 单端口超时(秒)
  max_concurrent: 20           # 并发扫描数

  # 被动学习
  passive_learning: true       # 启用被动学习
  auto_confirm: false          # 高置信度是否静默添加

  # 敏感信息
  sensitive_fields:            # 黑名单字段
    - password
    - secret
    - token
    - api_key
```

---

## 6. 用户流程总览

### 首次使用

```
安装 Skill
    │
    ▼
[自动触发] Embodiment MCP Server 启动
    │
    ▼
body-schema.json 不存在？
    ├── 是 → 弹出新手引导
    │        │
    │        ├── Step 1: 本机扫描     [进度条]
    │        ├── Step 2: 网络扫描     [进度条 + 发现列表]
    │        ├── Step 3: 能力探测     [逐台深入]
    │        └── Step 4: 确认汇报     [摘要 + 用户确认]
    │
    └── 否 → 正常加载，进入日常使用

用户确认后 → body-schema.json 就位
```

### 日常使用

```
用户说话
    │
    ├── 包含设备信息 → MCP learn_device 静默学习
    ├── 涉及设备操作
    │       ├── resolve_device(描述) → 匹配设备
    │       ├── 查 capabilities → 确认能否操作
    │       └── 返回 IP + access → 对应 skill 接管
    ├── 检查设备状态
    │       ├── verify_action → 测试连通性
    │       └── 状态变化 → update_device
    └── 普通对话 → 不触发 embodiment
```

### 定时任务

```
定时触发 (默认每小时)
    │
    ▼
check_lifecycle()
    │
    ├── unreachable < 5min → 只更新 last_unreachable
    ├── unreachable > 5min → 标记 warning
    ├── unreachable > 24h → 标记 offline
    ├── offline > 7d → 建议删除
    └── 状态恢复 → 标记 reachable
```

---

## 7. 安全与边界

### 7.1 敏感信息保护

**不存列表**（硬编码黑名单）：

```python
SENSITIVE_FIELDS = {
    "password", "passwd", "secret", "token", "api_key", "apikey",
    "private_key", "pem", "key_content", "auth_code", "cookie",
    "session_key", "credential", "ssh_key_content", "preshared_key"
}
```

用户如需凭据：
- SSH：配置 key-based auth（`~/.ssh/config`）
- API key：环境变量或 Hermes `.env`
- 密码：密码管理器（1Password / Bitwarden）
- Hermes Credential Pool（平台内建）

### 7.2 操作边界

**embodiment 只回答「有什么」，不执行操作。**

| 用户说 | Agent 做 |
|--------|---------|
| 「我有什么设备？」 | 读 schema 回答 |
| 「打开我的电脑」 | 查 schema → 返回 IP + access → 交给其他 skill |
| 「跑一下模型」 | 查 capabilities → 返回推理设备 → 交给推理 skill |
| 「重启 NAS」 | 查 access → 交给 NAS skill |
| 「扫描网络」 | 跑发现脚本 → 更新 schema |

### 7.3 诚实声明

- 发现能力有限 — ping 只能发现存活主机，端口可能被防火墙阻挡
- 不替代专业监控 — 这不是 Zabbix / Prometheus
- Schema 可能过时 — DHCP 下 IP 会变
- 设备状态基于最近一次检测 — 不是实时

---

## 8. 1.0 版本范围

### 包含 ✓

|| 功能 | 优先级 | 说明 |
|------|--------|------|
| **设备唯一标识（MAC地址）** | P0 | 1.0核心改进，解决多网络/IP变化问题 |
| 设备合并逻辑 | P0 | MAC匹配→合并IP，MAC获取失败→临时ID |
| 新手引导（Setup Wizard） | P0 | 安装后自动弹窗，引导用户完成初始化 |
| 本机扫描 | P0 | hostname/OS/CPU/内存/IP/摄像头/音频 |
| 网络扫描（Layer 1+2） | P0 | 本地网络 + ZeroTier 组网 |
| 端口扫描与服务识别 | P0 | 27 种端口的服务推断 |
| schema 读写 | P0 | body-schema.json 的创建和读取 |
| **query_device MCP工具** | P0 | 统一查询接口（替代get_schema + resolve_device） |
| **learn_device MCP工具** | P0 | 从对话中自动学习设备信息 |
| 生命周期管理 | P1 | unreachable→warning→offline 状态机 |
| 能力发现（循序渐进的补充） | P1 | 初始端口推断 → 后续深入探测 |
| 敏感字段黑名单 | P0 | 密码/token 不写入 schema |
| 配置项 | P1 | embodiment 配置段（扫描范围/生命周期阈值） |

### 已知问题（需在实现中处理）

|| 问题 | 影响 | 解决方案 |
|------|------|---------|
| 端口扫描并发 | Bash 3.2 (macOS) 不支持进程替换 | 用临时文件替代 |
| 扫描时间过长 | 全网扫描可能超过30秒 | 分层扫描，后台任务 |
| ARP表排序 | 不同系统输出格式不同 | 统一解析逻辑 |
| MAC获取失败 | 某些设备不响应ARP | 用临时ID，后续补充 |

### 不包含 ✗

|| 功能 | 原因 | 计划版本 |
|------|------|---------|
| 多网络环境自动切换 | 需要更复杂的路由检测 | 1.1 |
| 手动设备管理（增删改） | 优先自动化发现 | 1.1 |
| 扫描边界配置 | 需要用户输入网络范围 | 1.1 |
| 错误处理与重试机制 | 需要更多场景测试 | 1.1 |
| 配置迁移工具 | 从旧schema迁移到新格式 | 1.1 |
| 设备能力自动更新 | 需要定期重扫机制 | 1.2 |
| 设备操作 | 由对应skill负责 | 不在范围内 |
| 实时监控 | 不是Zabbix | 不在范围内 |
| 密码存储 | 太敏感 | 不在范围内 |

---

## 9. 安装与配置

### 安装

```bash
# Hermes Agent 环境
cp -r agent-embodiment ~/.hermes/skills/

# 配置 MCP Server
# 编辑 ~/.hermes/config.yaml
```

```yaml
mcp_servers:
  embodiment:
    command: "/path/to/embodiment/mcp/server.py"
    timeout: 120
    connect_timeout: 60
```

### 配置

```yaml
embodiment:
  setup_wizard: auto
  lifecycle:
    unreachable_threshold: 5m
    offline_threshold: 24h
    auto_cleanup: 7d
    cleanup_confirm: true
  passive_learning: true
  sensitive_fields:
    - password
    - secret
    - token
    - api_key
```

---

## 10. 未来版本（1.1+）

| 版本 | 功能 |
|------|------|
| 1.1 | 定时网络重扫、设备关系图自动生成、更多服务识别 |
| 1.2 | Web 仪表盘、设备操作历史、异常通知 |
| 1.3 | 第三方集成（Home Assistant / Proxmox API 深度集成） |
| 2.0 | 多 Agent 共享 schema、分布式设备管理 |

---

## Changelog

- 2026-05-01: v1.0 初版
- 2026-05-01: v1.0 更新 — MCP工具精简为2个（query_device + learn_device），设备唯一标识改为MAC地址，新增合并逻辑，已知问题记录
- 2026-05-07: v1.0.2 更新 — 新增手动设备管理 manage-device.py（增删改查），SKILL.md/README 同步更新
- 2026-05-08: v1.0.3 更新
  - ✨ **导出/导入**：manage-device.py 支持 export（按类型过滤）和 import（合并/替换模式），三重去重
  - ✨ **标签系统**：manage-device.py 支持 tags 字段，add/update 增删标签，list 按标签过滤
  - ✨ **健康检查**：新增 health-check.py（quick ping / full 端口扫描），自动更新设备状态
  - 🐛 修复 body-schema.json 设备重复问题
  - 🐛 修复 health-check.py 重复显示

