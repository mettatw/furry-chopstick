# This script is automatically transpiled by furry-chopstick
# https://github.com/mettatw/furry-chopstick
set -euo pipefail

# This weird if is to source the lower part of this script first (setup
# shell functions, bundled files, etc.), then finally run the upper part
# (the main script)
if [[ ${FC_IN_HEADER_NOW:-0} == 0 ]]; then
  FC_IN_HEADER_NOW=1
  source "$0"
