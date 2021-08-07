script = ltmux

config_file = ltmux.conf
info_file   = ltmux.info
keys_file   = ltmux.keys

bin_dir = /usr/local/bin

shell   != which zsh || echo /bin/bash
is_zsh  != which zsh
is_bash != which bash

bash_complete = complete.bash
zsh_complete  = complete.zsh

bash_complete_dir = /etc/bash_completion.d
zsh_complete_dir != \
	which zsh >/dev/null && \
	zsh -c "typeset -p 1 fpath" | \
	sed -e 's/^ *//' | \
	awk '/Completion.*\/Unix/{print}'

help:
	@echo
	@echo "   syntax: make {install|uninstall}"
	@echo

install:   .run_as_root .empty_echo .install_files
	@echo

uninstall: .run_as_root .empty_echo .uninstall_files
	@echo

.run_as_root:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo "\e[31m"; \
		echo "You are not root, run this target as root please!"; \
		echo "\e[0m"; \
		exit 1; \
	fi

.empty_echo:
	@echo

.install_files:
	@echo -n "   Installing files ...................... "
	@[ -z ${root_dir} ] || [ -d ${root_dir}/${bin_dir}           ] || mkdir -p ${root_dir}/${bin_dir}
	@[ -z ${root_dir} ] || [ -d ${root_dir}/${bash_complete_dir} ] || mkdir -p ${root_dir}/${bash_complete_dir}
	@cat src/${script}|\
		sed -e "s:/usr/bin/zsh:${shell}:" |\
		sed -e "/__LTMUX_CONFIG_FILE__/e (base64 src/${config_file} | sed -e 's/^/		/')"  \
		    -e "/__LTMUX_INFO_FILE__/e   (base64 src/${info_file}   | sed -e 's/^/		/')"  \
		    -e "/__LTMUX_CONFIG_KEYS__/e (base64 src/${keys_file}   | sed -e 's/^/		/')" |\
		grep -v \
		  -e "__LTMUX_CONFIG_FILE__" \
		  -e "__LTMUX_CONFIG_KEYS__" \
		  -e "__LTMUX_INFO_FILE__" > ${root_dir}${bin_dir}/${script}
	@chmod 755 ${root_dir}${bin_dir}/${script}
	@[ -z ${is_bash} ] || cp src/${bash_complete} ${root_dir}/${bash_complete_dir}/${script}
	@[ -z ${is_zsh}  ] || cp src/${zsh_complete}  ${root_dir}/${zsh_complete_dir}/_${script}
	@echo DONE

.uninstall_files:
	@echo -n "   Uninstalling files .................... "
	@[ ! -f ${bin_dir}/${script}   ] || rm -f ${bin_dir}/${script}
	@[ ! -f ${bash_complete_dir}/${script} ] || rm -f ${bash_complete_dir}/${script}
	@[ ! -f ${zsh_complete_dir}/_${script} ] || rm -f ${zsh_complete_dir}/_${script}
	@echo DONE
