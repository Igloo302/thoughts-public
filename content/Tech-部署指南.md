---
title: 如何部署这个网站
publish: true
date: 2026-02-24
tags: [quartz, obsidian, 部署指南]
---

# 如何部署这个网站

这个网站使用 **Quartz** 构建，基于我的 Obsidian 笔记系统。

## 快速部署

### 1. Fork 仓库

```bash
git clone git@github.com:Igloo302/thoughts-public.git
cd thoughts-public
```

### 2. 安装依赖

```bash
npm install
```

### 3. 本地预览

```bash
npx quartz build --serve
```

访问 http://localhost:8080 查看效果。

### 4. 部署到 GitHub Pages

```bash
git remote add origin git@github.com:YOUR_USERNAME/thoughts-public.git
git push -u origin main
```

然后在 GitHub 仓库设置中开启 Pages：
- Settings → Pages → Source: main branch

---

## 自定义内容

### 添加笔记

将你的 Markdown 笔记放入 `content/` 目录：

```bash
cp ~/Documents/Obsidian/你的笔记.md content/
```

### 配置过滤

编辑 `quartz.config.ts`：

```typescript
export default {
  filters: {
    exclude: ["**/private/**", "**/drafts/**"],
  },
}
```

### 修改主题

编辑 `quartz.layout.ts` 和 `quartz/style.scss`。

---

## 自动化同步

创建同步脚本 `sync.sh`：

```bash
#!/bin/bash
# 只同步带 publish: true 标签的笔记

cd ~/Documents/Obsidian
grep -rl "publish: true" . | while read file; do
    cp "$file" ~/thoughts-public/content/
done

cd ~/thoughts-public
git add .
git commit -m "Auto sync from Obsidian"
git push
```

---

## 混合模式工作流

我采用 **Quartz + Hugo** 混合模式：

| 内容类型 | 平台 | 更新频率 |
|----------|------|----------|
| 知识库 | Quartz | 每周 2-3 次 |
| Prompt 模板 | Quartz | 每周 1-2 次 |
| 深度长文 | Hugo | 每月 1-2 次 |

**优势：**
- Quartz：与 Obsidian 无缝集成，维护成本低
- Hugo：SEO 好，适合正式博客

---

## 资源

- [Quartz 官方文档](https://quartz.jzhao.xyz/)
- [Obsidian 官网](https://obsidian.md/)
- [GitHub Pages 文档](https://pages.github.com/)

---

*有问题？提个 [Issue](https://github.com/Igloo302/thoughts-public/issues) 吧！*
