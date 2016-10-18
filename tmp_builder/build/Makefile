
SHELL := /usr/bin/env bash
DIRMAKEFILE := $(dir $(lastword $(MAKEFILE_LIST)))

FRAGMENT_LIST := $(shell shopt -s globstar; cd $(DIRMAKEFILE)/../src; ls **/*)

CACHEDIR := .cache
CACHE_LIST := $(FRAGMENT_LIST:%=$(CACHEDIR)/%.cache)

.PHONY: all-cache clean

all-cache: $(CACHE_LIST)
	@true

clean:
	if [[ -n "$(CACHEDIR)" && "$(CACHEDIR)" != / && -d "$(CACHEDIR)" ]]; then rm -rf $(CACHEDIR); fi

define buildcache
$(CACHEDIR)/$1.cache: $2/$1 | $$(CACHEDIR)
	@../../bin/furry-chopstick-parser.pl "$1" "$$<" "$$@" \
	  -p ImportDirect 
endef
$(foreach frag,$(FRAGMENT_LIST),$(eval $(call buildcache,$(frag),$(DIRMAKEFILE)/../src)))

define buildfinal
$2/$1: $(CACHEDIR)/$1.cache | all-cache
	@printf '\033[;32m build %s\033[m\n' "$1"
	@../../bin/furry-chopstick-builder.pl "$3" "$1" "$$<" "$$@" \
	  --prefix-deps="$2" --output-deps=$(CACHEDIR)/$1.dep
endef
$(foreach frag,$(FRAGMENT_LIST),$(eval $(call buildfinal,$(frag),.,out:main)))

$(CACHEDIR):
	mkdir -p "$@"

include $(wildcard $(CACHEDIR)/**/*.dep $(CACHEDIR)/*.dep)
