#!/usr/bin/env perl
# Testing of furry-chopstick
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

use strict;
use warnings;
use v5.14;

use File::Basename qw(dirname);
require(dirname(__FILE__) . '/../bin/furry-chopstick-parser.pl');

use Test2::Bundle::Extended;
use Test2::Tools::Spec;

sub evalMain {
  my %hContent;
  my %hVariable;
  my %hDependency;
  eval(main(@_));
  return (\%hContent, \%hVariable, \%hDependency);
}

describe 'The parser program' => sub {
  tests 'Passthru' => sub {
    my $input = "ccc\n567\n";
    my @rslt;

    @rslt = evalMain('name', $input, []);
    is($rslt[0]->{'name'}{'text:main'},
      $input, 'match passthru');

    @rslt = evalMain('name', "", []);
    is($rslt[0]->{'name'}{'text:main'},
      "", 'match passthru empty');

    ok(dies {
      my @rslt = evalMain('name', $input, ['NonExist']);
    }, 'die on not found');
  };
};

done_testing;
