#!/usr/bin/env perl
# Separate initial comments from rest of script
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

package FurryParser::SeparateComment;

use strict;
use warnings;
use v5.14;

my $pat = qr{
  (?: \s | ^ ) \K    # look-behind non-capture, start without non-space
  ! ([<>]) ([^\s;:]+)     # The command we want
  (?: (?= [\s;:] | $ ))  # look-ahead the end of command
}msx; # x allow comment; s treat as single line; m multiline

sub doParse {
  my ($rhContent, $rhVariable, $rhDependency) = (@_);
  foreach my $key (grep { $_ =~ /^text:/ } keys %{$rhContent}) {
    my $nameUnit = (split(/:/, $key, 2))[1];
    my $commentChar;
    if ($rhContent->{$key} =~ /^([#;:\/-])/) {
      $commentChar = $1;
    } else { # no comments, done with it
      return
    }

    my $header = "";
    my $content = "";
    my $isInHeader = 1;
    # Find where we switch from initial comments to real contents
    for (split /^/, $rhContent->{$key}) {
      chomp;
      if ($isInHeader == 1 && (/^$commentChar/ || /^\s*$/)) { # Comment line
        $header .= $_ . "\n";
      } else {
        $isInHeader = 0;
        $content .= $_ . "\n";
      }
    }
    # Put contents back
    $rhContent->{$key} = ($content =~ s/\n+$/\n/r); # In case too many trailing newlines
    $rhContent->{"out:$nameUnit"} = $header . $rhContent->{"out:$nameUnit"};
  }
}

1;
