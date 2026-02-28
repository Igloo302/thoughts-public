# 🌳 Public Garden

这是通过 Quartz 发布的公开数字花园。

## 说明

- **本体位置**: `~/Documents/Obsidian/1-Projects/Public Garden/`
- **网站仓库**: `~/thoughts-public/` (通过软链接引用此目录)
- **访问地址**: https://igloo302.github.io/thoughts-public/

## 发布流程

1. 在此目录下编辑 Markdown 文件
2. 添加 frontmatter：`publish: true`
3. 在 thoughts-public 目录执行 `git add -A && git commit -m "xxx"`
4. post-commit hook 会自动 push 并部署

## 目录结构

```
Public Garden/
├── index.md              # 网站首页
├── claw-thoughts/        # AI 助手专栏
├── openclaw-guide/       # OpenClaw 指南
└── ...                   # 其他公开内容
```
