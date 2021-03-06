#!/usr/bin/env perl
# Directly import some other scripts
#***************************************************************************
#  Copyright 2014-2017, mettatw
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

package FurryParser::ImportShell;

use strict;
use warnings;
use v5.14;

# Pattern
# Source the file as a fd in shell
# !.template/path
# Export the function of this external file
# !#template/path

my $pat = qr{
  (?: \s | ^ ) \K    # look-behind non-capture, start without non-space
  ! ([.#]) ([^\s;:]+)     # The command we want
  (?: (?= [\s;:] | $ ))  # look-ahead the end of command
}msx; # x allow comment; s treat as single line; m multiline

sub doParse {
  my ($rhContent, $rhVariable, $rhDependency) = (@_);
  foreach my $key (grep { $_ =~ /^text:/ } keys %{$rhContent}) {
    my $nameUnit = (split(/:/, $key, 2))[1];
    while ($rhContent->{$key} =~ /$pat/g) {
      my $symbol = $1;
      my $fname = $2;
      my $startBlock = $-[0];
      my $lenBlock = $+[0]-$-[0];

      # concat original path if relative
      if ($fname =~ /^(\.|\.\.)\//) {
        $fname = ($rhVariable->{'fileid'} =~ s@[^/]+$@@r) . "$fname";
      }
      $fname =~ s@/\+@/@g; # clear repeating slashes
      1 while $fname =~ s@(^|/)([^/]+[^/.]/\.\./|\./)@$1@; # deal with . and ..

      my $rslt = "";
      if ($symbol eq ".") {
        $rslt = "<(~GET!$fname)"
      } else {
        $rslt = "declare -f \"~GET!$fname\"";
      }
      substr($rhContent->{$key}, $startBlock, $lenBlock, $rslt);

      $rhDependency->{$fname} = 1;
      $rhVariable->{'toImport'}{$fname} = 1;
    }
  }
}

1;
