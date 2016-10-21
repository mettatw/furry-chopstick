#!/usr/bin/env perl
# Parser utility
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

use strict;
use warnings;
use v5.14; # say state switch unicode_strings array_base

# Put dependency path in @INC
use Cwd qw(realpath);
use File::Basename qw(dirname);
use lib dirname(realpath(__FILE__)) . '/../lib';

use Getopt::Long;
use Data::Dumper;
$Data::Dumper::Indent = 1; # simple mode: no too fancy indentation

sub main {
  my ($argFileID, $argInput, $rargParsers) = (@_);
  my @argParsers = @{$rargParsers};

  sub doDump {
    my ($target, $nameVar) = (@_);
    return Dumper($target) =~ s/^\$VAR1/$nameVar/r;
  }

  # Needed variables
  my %hContent;
  my %hVariable;
  my %hDependency;

  $hContent{'text:main'} = $argInput;
  $hContent{'out:main'} = "[% INCLUDE '$argFileID:text:main' %]";

  foreach my $parser (@argParsers) {
    require "FurryParser/$parser.pm";
    # Call function with this name, weird syntax due to use strict
    &{\&{"FurryParser::${parser}::doParse"}}(\%hContent, \%hVariable, \%hDependency);
  }

  # Start dumping out
  return "# Automatically generated by furry-chopstick\n\n"
    . doDump(\%hDependency, "\$hDependency{\"$argFileID\"}")
    . "\n"
    . doDump(\%hVariable, "\$hVariable{\"$argFileID\"}")
    . "\n"
    . doDump(\%hContent, "\$hContent{\"$argFileID\"}")
    . "\n";
}

unless (caller) { # If direct invocation of this script
  my @argParsers;
  GetOptions('parser=s' => \@argParsers);

  if (@ARGV < 3) {
    die "Usage: $0 file-id input-file output-file";
  };

  my $argFileID = shift;
  my $argInputFile = shift;
  my $argOutputFile = shift;

  # Read input data as a long string, assigning it to the main text
  my $allContent = do { local(@ARGV, $/) = $argInputFile; <> } or die;

  my $rslt = main $argFileID, $allContent, \@argParsers;

  # Write results to target file
  open my $fdOut, ">" . $argOutputFile or die;
  print {$fdOut} $rslt;
  close $fdOut;
}
