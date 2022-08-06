.DEFAULT_GOAL := help

OS = $(shell echo $(shell uname) | tr A-Z a-z)
ARCH = $(if $(filter $(shell uname -m), arm64 aarch64),arm64,amd64)

ZIG_OS = $(if $(filter $(shell uname),Darwin),macos,$(if $(filter $(shell uname),Linux),linux,windows))
ZIG_ARCH = $(shell uname -m)
ZIG_VERSION = 0.9.0

DIRENV = _vendor/bin/direnv
DIRENV_VERSION = 2.32.1

.PHONY: run
run: ## run main.zig
	zig run ./main.zig

.PHONY: deps
deps:_vendor/bin/direnv _vendor/zig/zig env ## ready dependency

.PHONY: env
env: ## load env
	$(DIRENV) allow

_vendor/zig/zig: _vendor/zig/zig-$(ZIG_VERSION)
	cd $(@D) && ln -sf $(<F) $(@F)
	$@ version

_vendor/zig/zig-%:
	rm -rf _vendor/zig/*
	curl -f -SsL -o $@.tar.xz https://ziglang.org/download/$*/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*.tar.xz
	tar xf $@.tar.xz -C $(@D)
	rm $@.tar.xz
	mv $(@D)/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*/zig $@
	mv $(@D)/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*/lib _vendor/zig/lib
	rm -rf $(@D)/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*/

_vendor/bin/direnv: _vendor/bin/direnv-v$(DIRENV_VERSION)
	cd $(@D) && ln -sf $(<F) $(@F)
	$@ --version

_vendor/bin/direnv-%:
	rm -f _vendor/bin/direnv-v*
	curl -f -SsL -o $@ https://github.com/direnv/direnv/releases/download/$*/direnv.$(OS)-$(ARCH)
	chmod +x $@

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'