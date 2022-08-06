.DEFAULT_GOAL := help

OS = $(shell echo $(shell uname) | tr A-Z a-z)
ARCH = $(if $(filter $(shell uname -m), arm64 aarch64),arm64,amd64)

DIRENV = _vendor/bin/direnv

.PHONY: deps
deps:_vendor/bin/direnv env ## ready dependency

.PHONY: env
env: ## load env
	$(DIRENV) allow

_vendor/bin/direnv: _vendor/bin/direnv-v2.31.0
	cd $(@D) && ln -sf $(<F) $(@F)
	$@ --version

_vendor/bin/direnv-%:
	curl -f -SsL -o $@ https://github.com/direnv/direnv/releases/download/$*/direnv.$(OS)-$(ARCH)
	chmod +x $@

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'