---
tags:
  - 3DGS
  - WindowsVM
  - environment
  - 64号车库
date: 2026-02-26
status: active
area: 2-Areas/Tech
---

# 3DGS 环境配置

> *Windows VM (192.168.5.109) - 端侧 AI Playground 环境配置完成记录*

---

## 📋 硬件配置

| 组件 | 规格 |
|------|------|
| CPU | Intel 12 核 @ 2.50GHz |
| GPU | **NVIDIA GeForce RTX 3060 12GB** ✅ |
| 内存 | 18GB |
| 存储 | 1TB NVMe SSD |
| 系统 | Windows 10 Enterprise LTSC 2024 |

---

## ⚙️ 软件环境

### 已安装的核心组件

| 组件 | 版本 | 用途 |
|------|------|------|
| **Python** | 3.12.10 | 编程语言 |
| **PyTorch** | 2.5.1+cu121 | 深度学习框架（GPU 加速） |
| **CUDA** | 12.1 | GPU 计算支持 |
| **NumPy** | 1.26.4 | 数值计算（降级以兼容 OpenCV） |
| **OpenCV** | 4.8.1 | 图像处理 |
| **Pillow** | 10.0.0 | 图像 I/O |
| **ImageIO** | 2.31.3 | 视频/图像读写 |
| **Tqdm** | 4.66.3 | 进度条显示 |
| **Transformers** | 5.2.0 | Hugging Face 模型 |
| **Accelerate** | 1.12.0 | 分布式训练加速 |
| **Datasets** | 4.6.0 | 数据集处理 |
| **Jupyter Lab** | 4.5.5 | 交互式开发环境 |
| **Matplotlib** | 3.10.8 | 数据可视化 |
| **Pandas** | 3.0.1 | 数据处理 |
| **Scikit-learn** | 1.8.0 | 机器学习工具 |

---

## 🔧 SSH 访问

### 配置方式

**方式 1：使用配置别名（推荐）**
```bash
ssh windows-vm
```

**方式 2：完整命令**
```bash
ssh -i ~/.ssh/windows_vm_key igloo@192.168.5.109
```

### SSH 配置文件

已配置 `~/.ssh/config`：
```
Host windows-vm
    HostName 192.168.5.109
    User igloo
    IdentityFile ~/.ssh/windows_vm_key
```

---

## 🚀 快速开始

### 验证环境

登录 Windows VM 后运行：

```python
import torch
import cv2
import numpy as np
from PIL import Image
import imageio

print("3DGS Environment Check:")
print(f"✓ PyTorch {torch.__version__} (CUDA: {torch.cuda.is_available()})")
print(f"✓ NumPy {np.__version__}")
print(f"✓ OpenCV {cv2.__version__}")
print(f"✓ Pillow {Image.__version__}")
print(f"✓ ImageIO {imageio.__version__}")

if torch.cuda.is_available():
    print(f"✓ GPU: {torch.cuda.get_device_name(0)}")
    print(f"✓ GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
```

**预期输出：**
```
3DGS Environment Check:
✓ PyTorch 2.5.1+cu121 (CUDA: True)
✓ NumPy 1.26.4
✓ OpenCV 4.8.1
✓ Pillow 10.0.0
✓ ImageIO 2.31.3
✓ GPU: NVIDIA GeForce RTX 3060
✓ GPU Memory: 12.0 GB
```

---

## 📦 3DGS 工作流准备

### 基础图像处理脚本

```python
# image_utils.py
import cv2
import numpy as np
from PIL import Image
import imageio
import os

def read_image(path):
    """读取图像（支持多种格式）"""
    return cv2.imread(path)

def resize_image(img, target_size=(1024, 1024)):
    """调整图像大小"""
    return cv2.resize(img, target_size)

def extract_frames(video_path, output_dir, fps=30):
    """从视频中提取帧"""
    cap = cv2.VideoCapture(video_path)
    os.makedirs(output_dir, exist_ok=True)
    
    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        cv2.imwrite(f"{output_dir}/frame_{frame_count:04d}.png", frame)
        frame_count += 1
    
    cap.release()
    print(f"Extracted {frame_count} frames to {output_dir}")
    return frame_count

def create_video(frames_dir, output_path, fps=30):
    """从帧创建视频"""
    frames = sorted([f for f in os.listdir(frames_dir) if f.endswith('.png')])
    frame = cv2.imread(os.path.join(frames_dir, frames[0]))
    h, w, _ = frame.shape
    
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (w, h))
    
    for f in frames:
        frame = cv2.imread(os.path.join(frames_dir, f))
        out.write(frame)
    
    out.release()
    print(f"Created video: {output_path}")
```

---

## 🚗 1:64 小车 3DGS 拍摄计划

### 推荐拍摄对象

| 类型 | 推荐品牌 | 原因 |
|------|----------|------|
| **现代街车** | MiniGT | 漆面好，细节丰富 |
| **国车** | 拓意(XCartoys) | 避震，性价比高 |
| **特种车** | Tiny (微影) | 有特色纹理 |
| **现有车型** | 特斯拉 Model 3 | 现代曲面，已有实物 |

### 拍摄设备清单

- ✅ Sony A7C2（已有）
- ✅ 柔光箱/连续光源
- 🔄 旋转台（需制作）
- 🔄 三脚架

### 拍摄参数建议

| 参数 | 推荐值 |
|------|--------|
| 拍摄张数 | 50-100 张 |
| 分辨率 | 至少 2000x2000 |
| 间隔角度 | 3-5° 一张 |
| 光线 | 柔光，避免高光过曝 |

---

## ✅ 3DGS 工具链（已安装）

### 方案一：Postshot（GUI 端到端）

| 组件 | 版本 | 路径 | 用途 |
|------|------|------|------|
| **Postshot** | latest | `C:\Program Files\Jawset Postshot\` | GUI 端到端 3DGS 工具 |
| postshot.exe | - | `bin\postshot.exe` | 主程序（图形界面）|
| postshot-cli.exe | - | `bin\postshot-cli.exe` | 命令行版本 |

**特点：**
- 零配置，开箱即用
- 内置 COLMAP，无需单独配置
- 支持 NeRF + 3DGS
- 完全本地运行，无需上传云端

**系统要求：**
- Windows 10+
- NVIDIA GPU RTX 2060 / Quadro T400 以上 ✅

---

### 方案二：COLMAP + 代码（命令行）

| 组件 | 版本 | 路径 | 用途 |
|------|------|------|------|
| **COLMAP** | 3.13.0 | `C:\COLMAP\bin\` | 运动结构恢复（SfM）|
| **FFmpeg** | 8.0.1 | `C:\ProgramData\chocolatey\bin\` | 视频处理 |

**COLMAP 验证：**
```bash
# 检查 COLMAP 是否可用
C:\COLMAP\bin\colmap.exe help

# 查看 feature_extractor 帮助
C:\COLMAP\bin\colmap.exe feature_extractor --help
```

**已添加到系统 PATH：**
- `C:\COLMAP\bin\`

---

## 🚀 快速开始

### 方案 A：Postshot（推荐入门）

1. **打开 Postshot**
   - 桌面快捷方式或开始菜单
   - 路径：`C:\Program Files\Jawset Postshot\bin\postshot.exe`

2. **导入照片**
   - File → Import Images
   - 选择拍摄好的小车多角度照片（50-100张）

3. **自动训练**
   - 点击 "Train" 开始训练
   - 实时预览训练进度

4. **导出模型**
   - 支持 .ply 格式导出
   - 可在 Web  viewer 中查看

### 方案 B：COLMAP 命令行

**标准 3DGS 数据准备流程：**

```bash
# 1. 特征提取
colmap feature_extractor \
    --database_path database.db \
    --image_path images/ \
    --ImageReader.camera_model PINHOLE

# 2. 特征匹配
colmap exhaustive_matcher \
    --database_path database.db

# 3. 稀疏重建
colmap mapper \
    --database_path database.db \
    --image_path images/ \
    --output_path sparse/

# 4. 图像去畸变
colmap image_undistorter \
    --image_path images/ \
    --input_path sparse/0 \
    --output_path dense/ \
    --output_type COLMAP
```

---

## 📝 后续待探索

### 进阶工具

- [ ] **gsplat** - PyTorch 原生 3DGS（pip install）
- [ ] **nerfstudio** - 完整 NeRF/3DGS 框架
- [ ] **SuperSplat** - 3DGS 编辑器

### 深度估计

- [ ] **MiDaS** - 单目深度估计
- [ ] **ZoeDepth** - 高精度深度估计

### AI 增强

- [ ] **Ollama** - 本地 LLM 推理
- [ ] **BLIP / CLIP** - 图像理解模型

---

## 🔍 常见问题

### NumPy 版本冲突

**问题：** OpenCV 不支持 NumPy 2.x

**解决：**
```bash
py -3.12 -m pip install "numpy<2" --force-reinstall
```

### 环境验证失败

检查 CUDA 是否可用：
```python
import torch
print(f"CUDA Available: {torch.cuda.is_available()}")
print(f"CUDA Version: {torch.version.cuda}")
```

---

## 📅 更新日志

- **2026-03-02**: 3DGS 工具链完整配置 ✅
  - Postshot 安装（GUI 端到端工具）
  - COLMAP 3.13.0 CUDA 版安装
  - FFmpeg 确认可用
  - 双方案工作流文档化

- **2026-02-26**: 初始环境配置完成
  - Python 3.12.10 安装
  - PyTorch 2.5.1 (CUDA 12.1) 配置
  - NumPy 降级至 1.26.4（兼容性修复）
  - 基础图像处理工具安装完成

---

## 🔗 相关笔记

- [[64 号车库]] - 1:64 模型车收藏与改造
- [[进阶探索路线图]] - 收藏与玩赏指南
- [[让车动起来]] - 动力改造方案
- [[微缩场景入坑三步走]] - 场景制作指南

---

*"Small Scale, Big World. Now in 3D."*