function cm -d "Generate shell command using Claude"
  set -l description (string join " " $argv)
  set -l prompt "Generate a shell command for: $description. Return ONLY the raw command, no markdown, no explanations, no code blocks."
  set -l raw_result (claude -p "$prompt" 2>/dev/null)
  set -l cleaned_command (echo $raw_result | sed -E 's/^```[a-z]*\s*//g' | sed -E 's/```\s*$//g' | string trim | head -1)
  commandline -r "$cleaned_command"
end
