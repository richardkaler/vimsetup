#!/bin/bash

# Copyright 2024 Richard Kaler
#
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }

if ! is_user_root ; then
	echo Current user is logged in as "$(whoami)" which is good
	echo Executing this script as root will create a vim profile for root - and not the regular user as intended
else
	echo -e "You are executing this script with sudo or as root\nAborting! Execute again as a non-root user"
	exit 1
fi

if mkdir -p "$HOME/tmp"; then
	echo created "$HOME/tmp" to store log file
else
	echo failed to create log file directory
fi

#logfile info
logloc="$HOME/tmp/vimsetup.log"

#pipe entire script to log
{
	echo running script at "$(date)"

#Install vim if it's not already installed
if ! [[ $(which vim) ]]; then
	sudo apt-get install vim -y
else
	echo vim is already installed
fi

#install git
if ! [[ $(which git) ]]; then
	sudo apt-get install git -y
else
	echo git is already installed
fi

#Install curl with force as it was not installing properly prior
	if ! [[ $(which curl) ]]; then
		sudo apt-get install curl -y
		sleep 1s && wait
	else
		echo curl is already installed
	fi
#Install vim plugin manager - and with force since previous installs have failed
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if ! [[ -d "$HOME/.vim" ]]; then
	echo vim-plug failed to create at least some required directories or they have not been detected yet
	echo continuing script anyway
else
	echo vim-plug created necessary directories
fi

#Install shellcheck
#echo "installing shellcheck"
sudo apt-get install shellcheck -y

#Install ale
echo "installing ale"
curl -sS https://webi.sh/vim-ale | sh

echo "
\" Vim-licence (c) 2024 McUsr
\" Miniscule shellcheck setup
\" you :copen the quick fix list however you open the quickfix list!
\"
if exists(\"current_compiler\")
	finish
	endif
	let current_compiler = \"shellcheck\"

	CompilerSet makeprg=shellcheck\ -f\ gcc\ \"%:p\"
	CompilerSet errorformat=
	\ '%f:%l:%c: %trror: %m,' .
	\ '%f:%l:%c: %tarning: %m,' .
	\ '%I%f:%l:%c: note: %m'
	" | tee ~/.vim/compiler

	echo "
	if filereadable(\"/etc/vim/vimrc.local\")
		source /etc/vim/vimrc.local
		endif

		if has(\"syntax\")
			syntax on
			endif

			set laststatus=2
			syntax on
			filetype indent on
			filetype on
			set smartindent
			set filetype=sh
			set ignorecase


			highlight Cursor guifg=white guibg=black
			highlight iCursor guifg=white guibg=steelblue

			autocmd ColorScheme * highlight Normal ctermbg=None
			autocmd ColorScheme * highlight NonText ctermbg=None

			set guicursor=n-v-c:block-Cursor
			set guicursor+=i:ver100-iCursor
			set guicursor+=n-v-c:blinkon0
			set guicursor+=i:blinkwait10

			\" Source a global configuration file if available
			if filereadable(\"/etc/vim/vimrc.local\")
				source /etc/vim/vimrc.local
				endif


				\" Correct file indentations for bash

				filetype plugin indent on
				\" show existing tab with 4 spaces width
				set tabstop=4
				\" when indenting with '>', use 4 spaces width
				set shiftwidth=4
				\" On pressing tab, insert 4 spaces
				set expandtab

				set errorformat+=%f:%l:%c\ %m

				\" Add line numbers
				set number
				set nospell

				highlight AleTitleBar guibg=#RRGGBB guifg=#RRGGBB
				command! Tnew tabnew | execute 'source /etc/vim/vimrc'
				nnoremap n nzz
				nnoremap } }zz
				:nnoremap <expr> z<esc> 'mz' . v:count . 'o<esc>\`z'
				" | sudo tee -a /etc/vim/vimrc
			} | tee -a "$logloc"


#Optional - work in progress. Oct 27, 2024
#NOTE: DO NOT attempt to source as that process is automatic with shellcheck and vim

#echo '
#disable=SC2002 #www.shellcheck.net/wiki/SC2002
#disable=SC2038 #www.shellcheck.net/wiki/SC2038
#disable=SC2002 #www.shellcheck.net/wiki/SC2002
#disable=SC2227 #www.shellcheck.net/wiki/SC2227
#disable=SC2145 #www.shellcheck.net/wiki/SC2145
#disable=SC2124 #www.shellcheck.net/wiki/SC2124
#disable=SC2164 #www.shellcheck.net/wiki/SC2164
#disable=SC2015 #www.shellcheck.net/wiki/SC2015
#disable=SC2009 #www.shellcheck.net/wiki/SC2009
#disable=SC2015 #www.shellcheck.net/wiki/SC2015
#disable=SC2009 #www.shellcheck.net/wiki/SC2009
#disable=SC2034 #www.shellcheck.net/wiki/SC2034
#' > ~/.shellcheckrc

