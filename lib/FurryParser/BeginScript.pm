#!/usr/bin/env perl
# The tag to start a script
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

package FurryParser::BeginScript;

use strict;
use warnings;
use v5.14;

# Pattern
# After args definition, before main script:
# !@begin-script
# In the beginning of a sourced file:
# !@begin-source

my $pat = qr{
  (?: [\n\r] | ^ ) [ ]* \K    # look-behind non-capture, start with new line
  !\@begin-(script|source)     # The command we want
  [ ]* (?: (?= [\n\r] | $ ))  # look-ahead the end of command
}msx; # x allow comment; s treat as single line; m multiline

sub doParse {
  my ($rhContent, $rhVariable, $rhDependency) = (@_);
  foreach my $key (grep { $_ =~ /^text:/ } keys %{$rhContent}) {
    my $nameUnit = (split(/:/, $key, 2))[1];
    if ($rhContent->{$key} =~ /$pat/) {
      my $rslt = "##- Begin Main Script ##" . "\n";
      if ($1 eq "script") {
        $rslt = "!>tmpl/fc-base/sh-beforemain.sh\n$rslt";
      }
      substr($rhContent->{$key}, $-[0], $+[0]-$-[0], $rslt);

      # Prepend and Append template files
      $rhContent->{$key} = "!>tmpl/fc-base/sh-header.sh" . "\n"
      . "##- Defining Parameters ##" . "\n"
      . $rhContent->{$key} . "\n"
      . "##- End Main Script ##" . "\n"
      . "!>tmpl/fc-base/sh-aftermain.sh" . "\n";
    }
  }
}

1;
