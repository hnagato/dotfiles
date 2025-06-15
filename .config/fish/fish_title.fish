set -l _fish_title_pwd
set -l _fish_title_wd

function _fish_title_get_git_display
  set -l gwd (git rev-parse --show-toplevel 2>/dev/null)
  or return 1

  if test "$PWD" = "$gwd"
    basename $gwd
  else
    set -l relative_path (string replace "$gwd/" "" $PWD)
    if test "$relative_path" = "$PWD"
      set -l real_pwd (realpath $PWD 2>/dev/null || echo $PWD)
      set -l real_gwd (realpath $gwd 2>/dev/null || echo $gwd)
      set relative_path (string replace "$real_gwd/" "" $real_pwd)
    end
    string join "/" (basename $gwd) $relative_path
  end
end

function _fish_title_get_home_display
  set -l home $HOME
  set -l current_pwd (string replace -r '/$' '' $PWD)

  if test "$current_pwd" = "$home"
    echo "~"
  else if string match -q "$home/*" "$current_pwd"
    set -l relative_path (string replace "$home/" "" $current_pwd)
    echo "~/$relative_path"
  else
    return 1
  end
end

function _fish_title_get_display
  if set -l git_display (_fish_title_get_git_display)
    echo -- $git_display
  else if set -l home_display (_fish_title_get_home_display)
    echo -- $home_display
  else
    basename $PWD
  end
end

function fish_title
  if test "$_fish_title_pwd" != "$PWD"
    set _fish_title_pwd $PWD
    set _fish_title_wd (_fish_title_get_display)
  end

  echo -- $_fish_title_wd
end
