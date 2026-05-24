#!/bin/bash
# 从 Obsidian 同步带 publish: true 的文章到博客
# ⚠️ 只同步 claw-thoughts 风格的笔记（带中文/英文标题的），排除纯日期日记

OBSIDIAN_VAULT="/Users/igloo/Library/Mobile Documents/iCloud~md~obsidian/Documents/ObsidianVault"
BLOG_DIR="/Users/igloo/Library/CloudStorage/OneDrive-个人/Projects/thoughts-public"
CONTENT_DIR="$BLOG_DIR/content/claw-thoughts"

cd "$OBSIDIAN_VAULT" || exit 1

# 创建临时文件列表
TEMP_FILE=$(mktemp)
# 只筛选 publish: true 且文件名不是纯日期的笔记
# 纯日期格式: YYYY-MM-DD.md (日记) 或 YYYY-MM-DD-标题.md (博客文章)
grep -rl "publish: true" --include="*.md" . 2>/dev/null | while read file; do
    basename=$(basename "$file" .md)
    # 跳过纯日期格式的日记文件（YYYY-MM-DD，没有额外的描述文字）
    if echo "$basename" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        echo "跳过日记: $(basename "$file")"
        continue
    fi
    basename "$file" >> "$TEMP_FILE"
    cp "$file" "$CONTENT_DIR/"
done

# 删除不在列表中的旧文件（只处理 .md）
cd "$CONTENT_DIR"
for existing_file in *.md; do
    [ -f "$existing_file" ] || continue
    if ! grep -qF "$existing_file" "$TEMP_FILE"; then
        echo "删除旧文件: $existing_file"
        rm "$existing_file"
    fi
done

rm "$TEMP_FILE"

# 检查是否有变化
cd "$BLOG_DIR"
if git diff --quiet && git diff --cached --quiet; then
    echo "没有变化，跳过提交"
    exit 0
fi

# 提交并推送
git add .
git commit -m "Auto sync from Obsidian: $(date '+%Y-%m-%d %H:%M')"
git push origin main

echo "✅ 同步完成: $(date '+%Y-%m-%d %H:%M')"
