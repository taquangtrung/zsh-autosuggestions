
#--------------------------------------------------------------------#
# History Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix and whose first word names a runnable command (executable
# on $PATH, shell builtin, function, alias, or reserved word). Stale
# entries that reference tools no longer installed are skipped.
#

_zsh_autosuggest_strategy_history() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m) and (x~y) glob operator
	setopt EXTENDED_GLOB

	# Escape backslashes and all of the glob operators so we can use
	# this string as a pattern to search the $history associative array.
	# - (#m) globbing flag enables setting references for match data
	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the history items that match the prefix, excluding those that match
	# the ignore pattern
	local pattern="$prefix*"
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
	fi

	# Get all history event numbers whose entries match the pattern,
	# ordered most recent first.
	local -a history_match_keys
	history_match_keys=(${(k)history[(R)$~pattern]})

	# Return the most recent match whose first word names a real command
	# (executable, builtin, function, alias, reserved word, or an executable
	# at the given path).
	local key candidate first_word
	for key in $history_match_keys; do
		candidate=$history[$key]
		first_word=${${(z)candidate}[1]}
		[[ -z $first_word ]] && continue

		if whence -- "$first_word" >/dev/null 2>&1; then
			typeset -g suggestion=$candidate
			return
		fi
	done

	typeset -g suggestion=
}
