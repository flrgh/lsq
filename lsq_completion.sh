_list_queries(){
    [[ -e $HOME/.lsqrc ]] && . $HOME/.lsqrc
    [[ -z $LSQ_BASEDIR ]] && exit
    [[ -d $LSQ_BASEDIR/queries ]] || exit
    queries=$(/bin/ls $LSQ_BASEDIR/queries | grep -oE "^(.+)\.lql$" | sed 's/\.lql//')
}

_comp_queries(){
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$queries
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

_list_queries
complete -F _comp_queries lsq
