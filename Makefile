# SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

ARGS := --verbosity=1

HOST?=$(subst .local.heyk.org,,$(shell hostname))

GUIX := guix

default: help

## dry-run: Test home in a local container
dry-run: ## - dry-run test home configuration in a local container
	$(GUIX) home container config/home.scm $< $(ARGS)

## pull: update packages
pull: ## - update guix distributions
	$(GUIX) pull --channels=channels.scm $(ARGS)

## home: apply guix home configuration.
home: ## - apply guix home configuration
	$(GUIX) home reconfigure config/home.scm $< $(ARGS)

## system: apply guix system configuration.
system: ## - apply guix system configuration
	sudo -E $(GUIX) system reconfigure config/$(HOST).scm $< $(ARGS)

## apply: apply guix configuration to local machine.
apply: ## - apply guix configuration
	$(MAKE) system
	$(MAKE) home

## reuse: check for license header
reuse: ## - check for license header
	$(GUIX) shell -m manifest.scm -- reuse lint

## nrepl: run the nrepl
nrepl: ## - run the nrepl for arei
	$(GUIX) shell guile-next guile-ares-rs -- guile -c '((@ (ares server) run-nrepl-server))'

## check: run linters or any check on code
check: reuse ## - check for license header

.PHONY: help
## help: Show this help.
help: Makefile
	@printf "Usage: make [target] [VARIABLE=value]\nTargets:\n"
	@sed -n 's/^## //p' $< | awk 'BEGIN {FS = ":"}; { if(NF>1 && $$2!="") printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 ; else printf "%40s\n", $$1};'
	@printf "Variables:\n"
	@grep -E "^[A-Za-z0-9_]*\?=" $< | awk 'BEGIN {FS = "\\?="}; { printf "  \033[36m%-25s\033[0m  Default values: %s\n", $$1, $$2}'
