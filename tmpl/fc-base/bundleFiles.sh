#function packFile {
#  local fname="$1"

#  echo "function ~GET!$fname { # {{{"
#  if [[ $fname == *.xz || $fname == *.?xz ]]; then
#    echo "base64 -d <<\"EOF__::$fname\" | xz -dc"
#  else
#    echo "cat <<\"EOF__::$fname\""
#  fi # end if special compressed script

#  if [[ -n "${pogb_fileComment["$fname"]:-}" ]]; then
#    printf '%s\n' "${pogb_fileComment["$fname"]}"
#  fi
#  printf '%s\n' "${pogb_fileContent["$fname"]}"

#  cat <<EOF
#EOF__::$fname
#} # }}}
#EOF
#  echo
#}

#for fname in "${!pogb_fileSource[@]}"; do
#  if [[ "${pogb_fileSource[$fname]}" == 0 ]]; then
#    continue
#  fi

#  packFile "$fname"
#done
