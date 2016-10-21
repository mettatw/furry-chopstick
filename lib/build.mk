# Builder generator
#***************************************************************************
#  Copyright 2014-2016, mettatw
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#***************************************************************************

export FURRYCHOP_ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))/..

CACHEDIR := .cache

# ====== Common targets ======

.PHONY: all-cache clean

all:
	@true

all-cache:
	@true

clean: clean-cache
	@true

clean-cache:
	@true

$(CACHEDIR):
	@mkdir -p "$@"

# ====== Builder for cache builder ======

# There might be chances to overwrite this var...
export FURRYCHOP_BIN := $(FURRYCHOP_ROOT)/bin

# Generate one rule for making a cache file
# Usage: $0 file-id source-dir-abs-path list-of-parser-plugins
define genCacheBuilderOnce
$(CACHEDIR)/$1.cache: $2/$1 | $(CACHEDIR)
	@mkdir -p $$(dir $$@)
	@$(FURRYCHOP_BIN)/furry-chopstick-parser.pl "$1" "$$<" "$$@" \
	  $(patsubst %,-p %,$3)
deletecache!$(CACHEDIR)/$1.cache:
	@rm -f "$(CACHEDIR)/$1.cache"

all-cache: $(CACHEDIR)/$1.cache
clean-cache: deletecache!$(CACHEDIR)/$1.cache
endef

# Based on wildcards, generate a bunch of cache file rules
# Usage: $0 base-path wildcard(s) list-of-parser-plugins
# Basically, find all files, create a cache rule for each
define genCacheBuilders
$(foreach frag,\
  $(patsubst $1/%,%,$(wildcard $(patsubst %,$1/%,$2))),\
  $(eval \
    $(call genCacheBuilderOnce,$(frag),$1,$3)
  )\
)
endef

# By default, templates from furry-chopstick are included
$(call genCacheBuilders,$(FURRYCHOP_ROOT),tmpl/**/*.sh,\
  SeparateComment ImportShell ImportDirect)


# ====== Builder for the final script ======

# Generate one rule for making a final script
# Usage: $0 file-id dest-path part
define genBuilderOnce
$2/$1: $(CACHEDIR)/$1.cache | all-cache
	@printf '\033[;32m build %s\033[m\n' "$$@"
	@mkdir -p $$(dir $$@)
	@$(FURRYCHOP_BIN)/furry-chopstick-builder.pl "$3" "$1" "$$<" "$$@" \
	  --prefix-deps="$2" --output-deps=$(CACHEDIR)/$1.dep
delete!$2/$1:
	@rm -f "$2/$1"

all: $2/$1
clean: delete!$2/$1
endef

# Based on wildcards, generate build rules
# Usage: $0 base-path wildcard(s) dest-path part
define genBuilders
$(foreach frag,\
  $(patsubst $1/%,%,$(wildcard $(patsubst %,$1/%,$2))),\
  $(eval \
    $(call genBuilderOnce,$(frag),$3,$4)
  )\
)
endef

# Build two things at once
# Usage: $0 base-path wildcard(s) dest-path part plugin-list
define genBuildersWithCache
$(foreach frag,\
  $(patsubst $1/%,%,$(wildcard $(patsubst %,$1/%,$2))),\
  $(eval \
    $(call genCacheBuilderOnce,$(frag),$1,$5)
    $(call genBuilderOnce,$(frag),$3,$4)
  )\
)
endef

# ====== Misc ======

