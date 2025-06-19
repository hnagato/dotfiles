# Generate shell command using Claude and place it on command line
function ccmdp -d "Generate command using Claude and place on command line"
    set -l description (string join " " $argv)
    if test -z "$description"
        set description (commandline)
    end

    if test -n "$description"
        # Claude -pでコマンド生成
        set -l raw_result (claude -p "Generate a shell command for: $description. Return ONLY the raw command, no markdown, no explanations, no code blocks.")

        # クリーンアップして最初の行のみ取得
        set -l clean_result (_cccmd_clean_output "$raw_result")

        commandline -r $clean_result
    end
    commandline -f repaint
end