#!/usr/bin/env bash

_kvawk_completions() {
	DIR="$HOME/.config/kv.awk/"
	COMPLEN="${#COMP_WORDS[@]}"
	case "$COMPLEN" in
		2)
			# list kv files
			COMPREPLY=($(compgen -W "$(ls "$DIR" | sed 's/.txt//')" -- "${COMP_WORDS[1]}"));;
		3)
			# list commands (skipping aliases)
			COMPREPLY=($(compgen -W "get set list delete" -- "${COMP_WORDS[2]}"));;
		*)
			# continue only if COMPLEN >= 4
			[ "$COMPLEN" -lt 4 ] && return
			# catch command
			COMMAND=($(echo "${COMP_WORDS[2]}" | awk '{print tolower($1)}'))
			# check command validity
			if [[ "$COMMAND" =~ ^(get|set|add|delete|del|rm)$ ]]
			then
				# continue only if not at second argument of set command
				[[ "$COMPLEN" -ne 4 ]] && [[ "$COMMAND" =~ ^(set|add)$ ]] && return
				# list keys
				COMPREPLY=($(compgen -W "$(awk '/^[A-Za-z]/ {print tolower($1)}' "$DIR/${COMP_WORDS[1]}.txt")" -- "${COMP_WORDS[$(($COMPLEN - 1))]}"))
			fi;;
	esac
}

complete -F _kvawk_completions kv.awk
