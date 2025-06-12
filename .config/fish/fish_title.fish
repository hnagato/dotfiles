# fish_title.fish
# ref: https://blog.atusy.net/2025/01/26/fish-title-relative-to-projroot/
#
set -l _fish_title_pwd
set -l _fish_title_wd

function fish_title
  if test "$_fish_title_pwd" != "$PWD"
    set _fish_title_pwd $PWD
    if set -l gwd (git rev-parse --show-toplevel 2> /dev/null)
      set -l n (dirname "xx$gwd" | string length) # add extra characters to generate start index
      set _fish_title_wd (string sub --start $n $PWD)
    else
      set _fish_title_wd (basename $PWD)
    end
  end

  echo -- $_fish_title_wd
end
