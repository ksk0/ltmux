#compdef ltmux

local -a reply
local -a args=(/$'[^\0]#\0'/)

local -a config_options
#
_regex_words config-options "config options" \
	'install:install default tmux config' \
	'remove:remove installed tmux config'

	config_options=($reply[@])

local -a ltmux_commands
#
_regex_words ltmux-commands "ltmux commands" \
	'enable:enable ltmux login script' \
	'disable:disable ltmux login script' \
	'config:manage default ltmux config file:$config_options' \
	'info:show extesive info about ltmux'

	args+=($reply[@])


_regex_arguments _ltmux "${args[@]}"

_ltmux "$@"
