_list_queries(){
    failed=0
    [[ -e $HOME/.lsqrc ]] && . $HOME/.lsqrc
    [[ -z $LSQ_BASEDIR ]] && echo "lsq error: no \$LSQ_BASEDIR is set--tab completion will not work"
    [[ -d $LSQ_BASEDIR/queries ]] || echo "lsq error: query directory is missing--tab completion will not work"
    queries=$(/bin/ls $LSQ_BASEDIR/queries | grep -oE "^(.+)\.lql$" | sed 's/\.lql//')
}

_comp_queries(){
    _list_queries
    local cur prev #opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$queries
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

if [[ $failed -ne 1 ]]; then
    complete -F _comp_queries lsq
fi
