# Generate shell command using Claude
function ccmdg -d "Generate shell command using Claude"
    set -l description (string join " " $argv)
    set -l raw_result (claude -p "Generate a shell command for: $description. Return ONLY the raw command, no markdown, no explanations, no code blocks.")
    _cccmd_clean_output "$raw_result"
end