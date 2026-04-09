# via https://piechowski.io/post/git-commands-before-reading-code/

# What Changes the Most
function git-audit-churn --description "Identify highly churned files in the last year"
    set_color yellow
    echo "=== 過去1年で最も変更されたファイル Top 20 ==="
    set_color normal
    git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20
end

# Who Built This
function git-audit-authors --description "Rank contributors by commit count"
    set_color yellow
    echo "=== 全期間のコミット数ランキング ==="
    set_color normal
    git shortlog -sn --no-merges
    set_color yellow
    echo "\n=== 過去6ヶ月のコミット数ランキング ==="
    set_color normal
    git shortlog -sn --no-merges --since="6 months ago"
end

# Where Do Bugs Cluster
function git-audit-bugs --description "Find files with the most bug fixes"
    set_color yellow
    echo "=== バグ修正(fix/bug/broken)が多いファイル Top 20 ==="
    set_color normal
    git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20
end

# Is This Project Accelerating or Dying
function git-audit-velocity --description "Show commit count by month"
    set_color yellow
    echo "=== 月別のコミット数推移 ==="
    set_color normal
    git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
end

# How Often Is the Team Firefighting
function git-audit-firefighting --description "Show revert and hotfix frequency in the last year"
    set_color yellow
    echo "=== 緊急対応(revert, hotfix等)の履歴 (過去1年) ==="
    set_color normal
    git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
end

function git-audit-all --description "Run all git audit commands"
    git-audit-churn
    echo ""
    git-audit-authors
    echo ""
    git-audit-bugs
    echo ""
    git-audit-velocity
    echo ""
    git-audit-firefighting
end
