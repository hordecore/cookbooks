#!/bin/bash

set -eu

VAGRANT=0
EPEL=1
VIM=1
SSH=1

_EPEL="http://mirror.yandex.ru/centos/7.0.1406/extras/x86_64/Packages/epel-release-7-2.noarch.rpm"
_VAGRANT="https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5_x86_64.rpm"
_VIMRC="https://raw.githubusercontent.com/hordecore/vimrc/master/.vimrc"

epel() {
	if [ "$EPEL" = 1 ]; then
		echo "# EPEL"
		yum -y install $_EPEL
		yum -y install yum-cron bash-completion bridge-utils gcc gcc-c++ gem git psmisc strace vim wget
	fi
}

vim() {
	if [ "$VIM" = 1 ]; then
		[ -f ~/.vimrc ] && return 0
		echo "# VIM"
		mkdir -p ~/.vim/swapfiles
		wget "$_VIMRC" -O ~/.vimrc
	fi
}

vagrant() {
	if [ "$VAGRANT" = 1 ]; then
		echo "# VAGRANT"
		yum -y install lxc lxc-libs lxc-doc lxc-templates 
		yum -y install $_VAGRANT
		vagrant plugin install vagrant-lxc
	fi
}

ssh() {
	if [ "$SSH" = '1' ]; then
		echo "# SSH"
		if [ ! -f ~/.ssh/id.rsa ]; then
			ssh-keygen -f ~/.ssh/id.rsa -N ''
		fi

		sed -E 's/.*(UseDNS|GSSAPIAuthentication).*/\1 no/g' -i /etc/ssh/sshd_config
		systemctl restart sshd || service sshd reload
	fi
}

usage() {
	grep "^[a-z0-9_]*()" $0
	exit 0
}

parse() {
	while [ "$#" != 0 ]; do
		case $1 in
			--help | -h | help )
				usage
				;;
			*	)
				eval "$1"="$2"
				shift
				shift
				;;
		esac
	done
}

main() {
	epel || true
	vim
	ssh
	vagrant
}

parse $@
main
