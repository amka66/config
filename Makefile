# Globals #

# TODO OK?
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

include .env

PROJECT_NAME ?= project
PI ?= pipelines/**/dvc.yaml

.DELETE_ON_ERROR:
.PHONY: status env req setup repro all clean pull update fullupdate fetch push lint
# .INTERMEDIATE:
# .SECONDARY:
.DEFAULT_GOAL := status

# Commands #

## Report status of Git, DVC, and more
status:
	$(info >>>> Checking status)
	du -sh .
	git status
	dvc status
	dvc diff
	dvc params diff
	dvc metrics diff
	# dvc plots diff
	dvc status --cloud

## Recreate empty Conda environment
env:
ifneq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME))
ifneq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME)0)
ifneq ($(CONDA_DEFAULT_ENV),mydev)
	$(error <<<< ERROR >>>> Unknown environment `$(CONDA_DEFAULT_ENV)`)
endif
endif
endif
	$(info >>>> Recreating empty environment)
	conda create -y --name $(CONDA_DEFAULT_ENV)

## Install/update Conda and Pip requirements as needed
req:
ifeq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME))
	$(info >>>> Installing requirements)
	conda install -y --update-specs python=3.8
	python3 -m pip install --upgrade-strategy eager -U pip setuptools wheel
	python3 -m pip install --upgrade-strategy eager -U -r requirements.txt
else ifeq ($(CONDA_DEFAULT_ENV),mydev)  # utilities only env
	$(info >>>> Installing requirements)
	conda install -y --update-specs python=3.9
	python3 -m pip install --upgrade-strategy eager -U pip setuptools wheel
	python3 -m pip install --upgrade-strategy eager -U -r requirements-mydev.txt
else ifeq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME)0)  # python 3.7
	$(info >>>> Installing requirements)
	conda install -y --update-specs python=3.7
	python3 -m pip install --upgrade-strategy eager -U pip setuptools wheel
	python3 -m pip install --upgrade-strategy eager -U -r requirements.txt
else
	$(error <<<< ERROR >>>> Unknown environment `$(CONDA_DEFAULT_ENV)`)
endif

## Set up environment: empty environment, install requirements
setup: env req

## Reporoduce pipeline as needed
repro:
ifneq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME))
ifneq ($(CONDA_DEFAULT_ENV),$(PROJECT_NAME)0)
	$(error <<<< ERROR >>>> Unknown environment `$(CONDA_DEFAULT_ENV)`)
endif
endif
	$(info >>>> Reproducing pipeline in environment `$(CONDA_DEFAULT_ENV)`)
	dvc repro $(PI)

## Update environment, reporoduce pipeline, report status
all: req repro status

## Delete auxiliary files created during build
clean:
	$(info >>>> Deleting auxiliary files)
	find . -type f -name '*.py[co]' -delete || true
	find . -path '*/__pycache__*' -delete || true
	find . -path '*/.ipynb_checkpoints*' -delete || true
	find data/processed -type f -name 'cached_*Tokenizer*' -delete || true
	find models -path '*/checkpoint-*' -delete || true
	find . -type f -name '.DS_Store' -delete || true

## Pull changes from Git and DVC as needed
pull:
	$(info >>>> Pulling changes)
	git fetch --all --tags
	git merge --ff-only
	dvc fetch --run-cache
	dvc checkout

## Delete auxiliary files, pull changes, update environment, report status
update: pull req status

## Delete auxiliary files, pull changes, set up environment, report status
fullupdate: clean pull setup status

## Fetch changes from Git and DVC (no workspace updates)
fetch:
	$(info >>>> Fetching changes)
	git fetch --all --tags
	dvc fetch --run-cache

push:
	$(info >>>> Pushing changes)
	dvc push --run-cache
	git push

## Lint using flake8
lint:
	$(info >>>> Linting)
	flake8 src

# Self Documenting Commands #

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
