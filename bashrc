# Make sure mask is properly set
[ "$(umask)" == "0077" ] || umask 0077 # Set here for `ssh` access (instead of `exit 1`)

# Formatting command output (only)
alias ls='ls -GFh'
alias tree='tree -CFh --du'
# LESSOPEN="| /usr/local/bin/src-hilite-lesspipe.sh %s"
# LESS=' -R '

# Ask confirmation before overriding
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
# Ask confirmation before deleting (rm)
alias rm='rm -i'

# Functions

function txty {
	if [ "${1: -4}" == ".pdf" ]
	then
		pdftotext "$1" - | less
	else
		pandoc -t plain "$1" | less
	fi
}
# Adds to `open` and `less`.

function cdl {
	cd ~/l/${1}
}

function eu {
	[ ! -e "${2}.url" ] && echo "[InternetShortcut]
URL=${1}" >> "${2}.url"
}

# Short extensions of command names when applied on specific arguments (only), possibly including special options

alias cd.='cd -P .'
alias execb='exec "${BASH}"'
alias jufg='jupyter notebook  --no-browser --ip=127.0.0.1 --port=8888 --port-retries=0 ~'
alias jubg='jufg 2> /dev/null &'
#alias juter='open -a Terminal jufg' # TODO Doesn't work as a file is expected instead of `jufg`
alias ssh-tunnel='ssh -NL localhost:8888:localhost:8888'
alias juli='jupyter notebook list'
alias lsofju='lsof -i @localhost:8888'
alias juo='~/l/xscripts/run-jupyter-notebook-app.sh'
alias otgt='open-target'
alias ltgt='less-target'
alias ttgt='txty-target'

# Quickest shortcuts of display-oriented commands (no side-effects) with useful parameters

alias l='ls -al'
alias t='tree -a -L'
alias td='tree -d -L'
alias r.='realpath .'

alias c='clear'
alias cl='cdl; clear'

alias o='open'
alias co='code'

alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gdn='git diff --no-index'
alias gl='git log --name-status'
alias glg='git log --graph --oneline --all'
alias grl='git reflog --name-status'
alias gsl='git stash list --name-status'

alias ds='dvc status'
alias dsc='dvc status --cloud'
alias ddi='dvc diff'
alias drdp='dvc repro --dry -P'
alias dpd='dvc params diff'
alias dmd='dvc metrics diff'
alias dpld='dvc plots diff'

alias ce='conda info --envs'
function ca {
	conda deactivate && conda activate "${1}" && echo ${PATH}
}


alias dil='docker image ls --all'
alias dcl='docker container ls --all'
alias dnl='docker network ls'
alias dvl='docker volume ls'

function s {
	echo '--- GIT STATUS ---' &&
	gs &&
	echo '--- DVC STATUS ---' &&
	ds &&
	# echo '--- DVC REPRO DRY ALL ---' &&
	# drdp &&
	echo '--- DVC DIFF ---' &&
	ddi &&
	echo '--- DVC PARAMS DIFF ---' &&
	dpd &&
	echo '--- DVC METRICS DIFF ---' &&
	dmd &&
	echo '--- DVC PLOTS DIFF ---' &&
	dpld
}
function sc {
	s &&
	echo '--- DVC STATUS CLOUD ---' &&
	dsc
}
function f {
	echo '--- GIT FETCH ---' &&
	git fetch --all --tags &&
	echo '--- DVC FETCH ---' &&
	dvc fetch --run-cache
}

function m {
	if ! { [ -n "$TMUX" ]; } then
		cdl
		tmux -u attach -t base || tmux -u new -s base
	fi
}
alias ma='tmux -u attach -t'
alias ml='tmux ls'
alias mk='tmux kill-session -t'

function mvsp {
	if [[ "${1}" != "" ]]; then
		find ${1} -name "* *" -type d | rename 's/ /_/g'    # do the directories first
		find ${1} -name "* *" -type f | rename 's/ /_/g'
	fi
}
