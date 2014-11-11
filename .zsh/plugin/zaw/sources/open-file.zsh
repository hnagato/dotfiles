function zaw-callback-open-file() {
    # file_path, file_dir
    filep="${(q)1}"
    filed=`echo ${filep%/*}`

    # TODO: symlink to directory
    if [[ -d "$1" ]]; then
        zaw zaw-src-open-file "$1"
    else
        BUFFER="qlmanage -p ${(q)1} && cd $filed"
        # BUFFER="gnome-open ${(q)1}"
        # BUFFER="open ${(q)1}"
        # accept-line
        zle accept-line
    fi
}
