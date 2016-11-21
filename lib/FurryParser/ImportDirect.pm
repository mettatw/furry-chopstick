#!/usr/bin/env perl
# Directly import some other scripts
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

package FurryParser::ImportDirect;

use strict;
use warnings;
use v5.14;

# Pattern
# Import and evaluate template: (pass context TO the sub-template)
# !>template/path
# Import template but don't evaluate: (pull text IN)
# !<template/path

my $pat = qr{
  (?: \s | ^ ) \K    # look-behind non-capture, start without non-space
  ([ ]{2,})? ! ([<>]) ([^\s;:]+)     # The command we want
  (?: (?= [\s;:] | $ ))  # look-ahead the end of command
}msx; # x allow comment; s treat as single line; m multiline

sub doParse {
  my ($rhContent, $rhVariable, $rhDependency) = (@_);
  foreach my $key (grep { $_ =~ /^text:/ } keys %{$rhContent}) {
    my $nameUnit = (split(/:/, $key, 2))[1];
    while ($rhContent->{$key} =~ /$pat/g) {
      my $indent = $1;
      my $symbol = $2;
      my $fname = $3;
      my $rslt = "";
      if ($symbol eq "<") {
        $rslt = "[% insertFn = '$fname' %]"
        # We use text:xxx here since out:xxx contains a template, but we're importing raw text
        . "[% insertPt = 'text:$nameUnit' %]"
        . "[% txt.\$insertFn.\$insertPt";
      } else {
        $rslt = "[% PROCESS '$fname:out:$nameUnit' | trim";
      }
      if (defined $indent) {
        $rslt .= " | indent('$indent')";
      }
      $rslt .= " %]";

      substr($rhContent->{$key}, $-[0], $+[0]-$-[0], $rslt);
      $rhDependency->{$fname} = 1;
    }
  }
}

1;
