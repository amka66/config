# # Setup shell environment #

# Make sure file mask is properly set
[ "$(umask)" == "0077" ] || umask 0077 # Set here for `ssh` access (instead of `exit 1`)

# # Adapt shell commands #

# Format command output
alias ls='ls -GFh'
alias tree='tree -CFh --du'
alias du='du -h'
LESSOPEN="| /usr/local/bin/src-hilite-lesspipe.sh %s"
LESS="-R"

# Ask confirmation before overriding
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Ask confirmation before deleting (rm)
alias rm='rm -i'

# # Command shortcuts and utilities - with side effects #

# Shell
alias cd.='cd -P .'
function cdl {
	cd ~/l/${1}
}
alias execb='exec "${BASH}"'
function eu {  # on work machine
	[ ! -e "${2}.url" ] && echo "[InternetShortcut]
URL=${1}" >> "${2}.url"
}

# Tmux
alias mn='tmux -u new -s'
alias ma='tmux -u attach -t'
function m {
	if ! { [ -n "$TMUX" ]; } then
		cdl
		ma base || mn base
	fi
}

# Git+DVC
function fetch {
	echo '--- GIT FETCH ---' &&
	git fetch --all --tags &&
	echo '--- DVC FETCH ---' &&
	dvc fetch --run-cache
}
function pull {
	echo '--- GIT FETCH ---' &&
	git fetch --all --tags &&
	echo '--- GIT MERGE FF---' &&
	git merge --ff-only &&
	echo '--- DVC FETCH ---' &&
	dvc fetch --run-cache &&
	echo '--- DVC CHECKOUT ---' &&
	dvc checkout
}
function push {
	echo '--- DVC PUSH ---' &&
	dvc push --run-cache &&
	echo '--- GIT PUSH ---' &&
	git push
}

# Conda
function ca {
	conda deactivate && conda activate "${1}" && echo "${PATH}"
}

# Jupyter # on work machine
alias jufg='jupyter notebook  --no-browser --ip=127.0.0.1 --port=8888 --port-retries=0 ~'
alias jubg='jufg 2> /dev/null &'
alias ssh-tunnel='ssh -NL localhost:8888:localhost:8888'
alias juo='run-jupyter-notebook-app.sh'

# # Command abbreviations and utilities - no side effects #

# Shell
alias l='ls -al'
alias t='tree -a -L'
alias td='tree -d -L'
alias r.='realpath .'
alias du.='du .'
function txty {  # on work machine
	if [ "${1: -4}" == ".pdf" ]
	then
		pdftotext "$1" - | less
	else
		pandoc -t plain "$1" | less
	fi
}  # this function adds to `open` and `less`
alias p.='echo $PATH'

# Tmux
alias ml='tmux ls'

# Git
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gdn='git diff --no-index'
alias gl='git log --name-status'
alias glg='git log --graph --oneline --all'
alias grl='git reflog --name-status'
alias gsl='git stash list --name-status'

# DVC
alias ds='dvc status'
alias dsc='dvc status --cloud'
alias ddi='dvc diff'
alias drdp='dvc repro --dry -P'
alias dpd='dvc params diff'
alias dmd='dvc metrics diff'
alias dpld='dvc plots diff'

# Git+DVC
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

# Conda
alias ce='conda info --envs'
alias c.='echo $CONDA_DEFAULT_ENV'

# Docker
alias dil='docker image ls --all'
alias dcl='docker container ls --all'
alias dnl='docker network ls'
alias dvl='docker volume ls'

# Jupyter  # on work machine
alias juli='jupyter notebook list'
alias lsofju='lsof -i @localhost:8888'

# Minikube
alias ministart='minikube start --container-runtime=docker --vm=true'
alias miniset='eval $(minikube docker-env)'
