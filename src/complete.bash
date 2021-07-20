__ltmux_complete(){
	[[ $COMP_CWORD -gt 2 ]] && return

	if [[ $COMP_CWORD -eq 1 ]]; then
		COMPREPLY=($(compgen -W "enable disable config info" $2))
		return
	fi

	[[ $3 != config ]] && return

	COMPREPLY=($(compgen -W "install remove" $2))
}

complete -F __ltmux_complete ltmux
