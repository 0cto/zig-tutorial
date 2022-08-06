.DEFAULT_GOAL := help

OS = $(shell echo $(shell uname) | tr A-Z a-z)
ARCH = $(if $(filter $(shell uname -m), arm64 aarch64),arm64,amd64)

ZIG_OS = $(if $(filter $(shell uname),Darwin),macos,$(if $(filter $(shell uname),Linux),linux,windows))
ZIG_ARCH = $(shell uname -m)

DIRENV = _vendor/bin/direnv
ZIG = _vendor/bin/zig

.PHONY: deps
deps:_vendor/bin/direnv _vendor/bin/zig env ## ready dependency

.PHONY: env
env: ## load env
	$(DIRENV) allow

.PHONY: zig_version
zig_version: ## load env
	$(ZIG) version

_vendor/bin/zig: _vendor/bin/zig-0.8.1
	cd $(@D) && ln -sf $(<F) $(@F)
	$@ version

_vendor/bin/zig-%:
	rm -f _vendor/bin/zig*
	curl -f -SsL -o $@.tar.xz https://ziglang.org/download/$*/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*.tar.xz
	tar xf $@.tar.xz -C $(@D)
	rm $@.tar.xz
	mv $(@D)/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*/zig $@
	rm -rf $(@D)/zig-$(ZIG_OS)-$(ZIG_ARCH)-$*/

_vendor/bin/direnv: _vendor/bin/direnv-v2.31.0
	cd $(@D) && ln -sf $(<F) $(@F)
	$@ --version

_vendor/bin/direnv-%:
	curl -f -SsL -o $@ https://github.com/direnv/direnv/releases/download/$*/direnv.$(OS)-$(ARCH)
	chmod +x $@

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'