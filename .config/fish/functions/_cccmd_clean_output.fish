# Internal function to clean Claude output by removing markdown code blocks
function _cccmd_clean_output -d "Clean Claude output by removing markdown code blocks"
    echo $argv | sed -E 's/^```[a-z]*\s*//g' | sed -E 's/```\s*$//g' | string trim | head -1
end