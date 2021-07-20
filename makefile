script = ltmux
config_file = ltmux.conf
info_file   = ltmux.info

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

all: help

deb: root_dir = "./dpkg"
deb: debian_dir = "./${root_dir}/DEBIAN"
deb: deb_tree install make-pkg

help:
	@echo
	@echo "   syntax: make {install|uninstall}"
	@echo

run_as_root:
	@if ! [ "$(shell id -u)" = 0 ]; then \
		echo "\e[31m"; \
		echo "You are not root, run this target as root please!"; \
		echo "\e[0m"; \
		exit 1; \
	fi

make-pkg:
	@mkpkg deb

deb_tree: run_as_root
	@echo -n "Creating debian package tree .......... "
	@[ ! -d ${root_dir} ] || rm -rf ${root_dir}
	@[ -d ${debian_dir} ] || mkdir -p ${debian_dir}
	@cp deb/control ${debian_dir}/
	@cp deb/*rm     ${debian_dir}/ 2>/dev/null || true
	@cp deb/*inst   ${debian_dir}/ 2>/dev/null || true
	@echo "DONE"

uninstall: run_as_root
	@echo -n "Uninstalling files .................... "
	@[ ! -f /usr/local/bin/${script}   ] || rm -f /usr/local/bin/${script}
	@[ ! -f ${bash_complete_dir}/ltmux ] || rm -f ${bash_complete_dir}/ltmux
	@[ ! -f ${zsh_complete_dir}/_ltmux ] || rm -f ${zsh_complete_dir}/_ltmux
	@echo DONE

install: run_as_root
	@echo -n "Installing files ...................... "
	@[ -z ${root_dir} ] || [ -d ${root_dir}/${bin_dir}           ] || mkdir -p ${root_dir}/${bin_dir}
	@[ -z ${root_dir} ] || [ -d ${root_dir}/${bash_complete_dir} ] || mkdir -p ${root_dir}/${bash_complete_dir}
	@cat src/${script}|\
		sed -e "s:/usr/bin/zsh:${shell}:" |\
		sed -e "/__LTMUX_CONFIG_FILE__/e (base64 src/${config_file} | sed -e 's/^/		/')" \
		    -e "/__LTMUX_INFO_FILE__/e (base64  src/${info_file}    | sed -e 's/^/		/')" |\
		grep -v \
		  -e "__LTMUX_CONFIG_FILE" \
		  -e "__LTMUX_INFO_FILE" > ${root_dir}/usr/local/bin/${script}
	@chmod 755 ${root_dir}/usr/local/bin/${script}
	@[ -z ${is_bash} ] || cp src/${bash_complete} ${root_dir}/${bash_complete_dir}/ltmux
	@[ -z ${is_zsh}  ] || cp src/${zsh_complete}  ${root_dir}/${zsh_complete_dir}/_ltmux
	@echo DONE
# @cp src/* $(root_dir)/usr/local/bin/


