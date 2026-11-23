---
name: eip-progress-pr
description: 整理目前 repo 的更新進度，commit、push 到自己的 feature 分支，再用 gh 開 Draft PR 到 dev，或在既有 PR 留進度留言，讓組員檢查。觸發詞：「整理進度」、「發 PR」、「把更新推上去」、「/eip-progress-pr」。
---

# 進度整理 → PR

把目前 repo 的最新進度整理成摘要，推到自己的 feature 分支，並同步到 GitHub PR，方便組員檢查。

## 事前準備（每位組員一次）

- 安裝 Claude Code
- 安裝 `gh` 並執行 `gh auth login`
- 對 repo 有 push 權限

## 團隊約定

- **只推自己的 feature 分支**。絕對不要 commit 或 push 到 `main`、`dev`。如果目前在 `main`/`dev` 上，先停下來問使用者要開哪個 feature 分支（例如 `feature/<功能名稱>`）。
- **PR 的 base 是 `dev`**，一律開成 **Draft**。這些 PR 是給組員檢查用的，不是要合併；要合併時再由作者執行 `gh pr ready`。
- **同一個 feature 分支只開一個 PR**。之後的更新繼續推到同一個分支，再用留言說明進度。
- **PR 標題格式**：`【<模組名稱><兩位數編號>】<這次的主題>`，例如 `【留言板01】新增初始格式與切版檔案`。
- **PR 描述和留言都不加任何 AI 署名**。
- **一次一步、每步回報**。commit、push、開 PR、留言這些會對外的動作，執行前都要先給使用者看內容並等確認。
- 跟使用者說明一律用繁體中文。

## 步驟

### 1. 掃描進度

在 repo 裡執行：

```bash
bash "$(git rev-parse --show-toplevel)/.claude/skills/eip-progress-pr/scripts/scan.sh"
```

腳本只讀不寫，會列出目前的分支、未 commit 變更、未 push 的 commit、相對 `dev` 的 commit，以及這個分支有沒有開啟中的 PR。

- 如果在 `main`/`dev` 上 → 停下來，照團隊約定處理。
- 如果完全沒有變更、也沒有未 push 的 commit → 告訴使用者沒有新進度，結束。

### 2. 整理進度摘要

看實際的變更內容（`git diff`、`git log -p`），不要只看檔名，整理成：

```
## 本次更新
- <用組員看得懂的話描述做了什麼，例如「新增留言編輯頁的表單欄位」>

## 請大家幫忙看
- <需要組員特別確認的地方；沒有就省略這一節>
```

把摘要給使用者看，等使用者確認或修改。

### 3. Commit 未提交的變更（有才做）

- 先列出要加入的檔案，排除 `.DS_Store`、`.env`、含金鑰的檔案。看到疑似 API key 或密碼要立刻提醒使用者。
- 用具體的檔案路徑 `git add`，不要用 `git add -A`。
- commit 訊息照 repo 既有的風格（例如 `docs: ...`、`feat: ...`），先給使用者看再 commit。

### 4. Push

```bash
git push -u origin <feature 分支>
```

### 5. 同步到 PR

**已經有開啟中的 PR** → 不要開新的，用留言補上這次的進度：

```bash
gh pr comment <PR 編號> --body "<步驟 2 的摘要>"
```

**還沒有 PR** → 開新的 Draft PR：

1. 決定標題：
   - 模組名稱：問使用者。
   - 編號：查同模組已有的 PR，取最大號 +1（沒有就是 01）：
     ```bash
     gh pr list --state all --search "【<模組名稱>" --json title -q '.[].title'
     ```
2. 標題和描述給使用者確認後再開：
   ```bash
   gh pr create --draft --base dev --head <feature 分支> \
     --title "<標題>" --body "<描述>"
   ```

### 6. 回報

說明做了什麼：commit 了哪些、push 到哪個分支、PR 連結（新開的或留言的）。哪一步跳過了也要說，並寫出原因。
