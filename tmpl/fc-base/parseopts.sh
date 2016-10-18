#!/usr/bin/env bash
# Parse command-line options in shell script
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

# This script is a derived work of "parse_options.sh" from Kaldi project
# ( http://kaldi.sourceforge.net/ )
# located at (root)/egs/wsj/s5/utils/
# which is released with Apache 2.0 license
# Copyright 2012  Johns Hopkins University (Author: Daniel Povey);
#                 Arnab Ghoshal, Karel Vesely

# Parse command-line options.
# To be sourced by another script (as in ". parse_options.sh").
# Option format is: --option-name=arg or option-name=arg
# and shell variable "option_name" gets set to value "arg"
# The exceptions are --help|-h, which takes no arguments, but prints the
# $help_message variable (if defined), and --config|-c, which reads a config file as options

# Need compatibility in this part, since we aren't sure being in bash yet...
if [ -z ${BASH+xxx} ]; then
  echo "$0: you need real BASH to run this script, sh or dash won't work" 1>&2
  exit 32
fi

# Simple function to check if the specified variable is array
function is_array {
  local dec="$(declare -p "$1" 2> /dev/null)"
  [[ "${dec:8:2}" == "-a" ]]
}

# $1 should be in the form of --name=value
function parse_one_option {
  local optionname="${1%%=*}"
  optionname="${optionname#--}"
  optionname="${optionname//-/_}"
  local value="${1#*=}"

  # Read a config file
  if [[ "${optionname}" == "config" ]]; then
    if [[ ! -f "${value}" && ! -h "${value}" ]]; then
      echo "$0: Config file ${value} not found" 1>&2 && exit 58;
    fi
    local thisline
    while read -r thisline; do
      if [[ -n "${thisline}" ]]; then
        parse_one_option "${thisline}"
      fi
    done < "${value}"
    return
  fi

  if is_array "$optionname"; then # Special situation: array
    eval "$optionname[\${#$optionname[@]}]=\"${value}\""
    return
  fi

  # Normal situation: not array
  if [[ -z "${!optionname+xxxx}" ]]; then  # if this option does not exist
    echo "$0: invalid option: $1" 1>&2 && exit 1;
  fi

  # Set the variable to the right value-- the escaped quotes make it work if
  # the option had spaces, like --cmd "queue.pl -sync y"
  eval "export $optionname=\"${value}\""
  return
}

export COMMANDLINE_ORIGINAL="$0 $@"
# Get DEFAULTARG_xxx from environment variable
for varArg in $(compgen -A variable DEFAULTARG_); do
  nameArg="${varArg#DEFAULTARG_}"
  if [[ -n "${!nameArg+xxxx}" ]]; then
    parse_one_option "$nameArg=${!varArg}"
  fi
  COMMANDLINE_ORIGINAL+=" (var:$nameArg=${!varArg})"
  unset nameArg
done; unset varArg

# Now start parsing the real command line options
while true; do
  [[ -z "${1:-}" ]] && break;  # break if there are no arguments
  case "$1" in
  # If the enclosing script is called with --help option, print the help
  # message and exit.  Scripts should put help messages in $help_message
  --help|-h)
    if [[ -z "$help_message" ]]; then
      echo "No help found." 1>&2
    else
      printf "%s\n" "$help_message" 1>&2
    fi
    exit 0 ;;
  --*=*)
    parse_one_option "$1"
    shift 1
    ;;
  *=*)
    # No -- prefix: this also works
    parse_one_option "--$1"
    shift 1
    ;;
  *)
    break
    ;;
  esac
done
