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

CACHEDIR ?= .cache

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

# Get dep files, to determine when to rebuild
-include $(shell test -d $(CACHEDIR) && find $(CACHEDIR) -type f -name '*.dep' -print)

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
ifndef FURRYCHOP_NOBUILTIN
$(call genCacheBuilders,$(FURRYCHOP_ROOT),tmpl/**/*.sh,\
  ImportShell ImportDirect)
endif


# ====== Builder for the final script ======

# Generate one rule for making a final script
# Usage: $0 1:file-id 2:dest-path 3:part [4:dest-name]
define genBuilderOnce
$2/$(if $4,$4,$1): $(CACHEDIR)/$1.cache | all-cache
	@printf '\033[;32m build %s\033[m\n' "$$@"
	@mkdir -p $$(dir $$@)
	@$(FURRYCHOP_BIN)/furry-chopstick-builder.pl "$3" "$1" "$$<" "$$@" \
	  --output-deps=$(CACHEDIR)/$1.dep
delete!$2/$(if $4,$4,$1):
	@rm -f "$$(@:delete!%=%)"

all: $2/$(if $4,$4,$1)
clean: delete!$2/$(if $4,$4,$1)
endef

# Based on wildcards, generate build rules
# Usage: $0 1:base-path 2:wildcard(s) 3:dest-path 4:part [5:dest-rule]
define genBuilders
$(foreach frag,\
  $(patsubst $1/%,%,$(wildcard $(patsubst %,$1/%,$2))),\
  $(eval \
    $(call genBuilderOnce,$(frag),$3,$4,$5)
  )\
)
endef

# Build two things at once
# Usage: $0 1:base-path 2:wildcard(s) 3:dest-path 4:part 5:plugin-list [6:dest-rule]
# Note: when specifying $6, you need to escape. e.g. $$(frag)
define genBuildersWithCache
$(foreach frag,\
  $(patsubst $1/%,%,$(wildcard $(patsubst %,$1/%,$2))),\
  $(eval \
    $(call genCacheBuilderOnce,$(frag),$1,$5)
    $(call genBuilderOnce,$(frag),$3,$4,$6)
  )\
)
endef

# ====== Misc ======

