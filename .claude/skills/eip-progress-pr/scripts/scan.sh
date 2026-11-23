#!/usr/bin/env bash
# 掃描目前所在 repo 的進度狀態。
# 只讀不寫：會 fetch 遠端，但不會 commit、push 或改動任何檔案。
#
# 用法：在 repo 裡任何位置執行 bash .claude/skills/eip-progress-pr/scripts/scan.sh

repo=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$repo" ]; then
  echo "目前不在 git repo 裡，請先 cd 到專案資料夾"
  exit 1
fi
cd "$repo" || exit 1

git fetch --quiet origin 2>/dev/null

branch=$(git branch --show-current)
echo "REPO: $repo"
echo "REMOTE: $(git remote get-url origin 2>/dev/null || echo '（沒有 origin）')"
echo "BRANCH: $branch"

# 基底分支：有 origin/dev 用 dev，否則用 main
if git rev-parse --verify --quiet origin/dev >/dev/null; then
  base="dev"
else
  base="main"
fi
echo "BASE: $base"

case "$branch" in
  main|dev) echo "⚠️  目前在 $branch 分支上，不可以直接 commit/push，請先切到自己的 feature 分支" ;;
esac

echo "--- 尚未 commit 的變更 ---"
changes=$(git status --short)
if [ -n "$changes" ]; then echo "$changes"; else echo "（無）"; fi

echo "--- 尚未 push 的 commit ---"
if git rev-parse --verify --quiet "origin/$branch" >/dev/null; then
  unpushed=$(git log --oneline "origin/$branch..HEAD")
  if [ -n "$unpushed" ]; then echo "$unpushed"; else echo "（無）"; fi
else
  echo "（遠端還沒有這個分支，全部 commit 都尚未 push）"
fi

echo "--- 相對 origin/$base 的所有 commit ---"
ahead=$(git log --oneline "origin/$base..HEAD" 2>/dev/null)
if [ -n "$ahead" ]; then echo "$ahead"; else echo "（無）"; fi

echo "--- 這個分支的 PR ---"
if command -v gh >/dev/null; then
  pr=$(gh pr list --head "$branch" --state open --json number,title,url,isDraft \
       -q '.[] | "#\(.number) \(.title) \(.url) draft=\(.isDraft)"' 2>/dev/null)
  if [ -n "$pr" ]; then echo "$pr"; else echo "（沒有開啟中的 PR）"; fi
else
  echo "（沒有安裝 gh，請先安裝並執行 gh auth login）"
fi
