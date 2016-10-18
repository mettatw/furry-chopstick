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

use File::Spec::Functions qw(catfile);
use Template;

#my %vars = (
#  zzz => "[% num + 3000 %]",
#  message  => "Hello World",
#  num => 366
#);

#my $template = Template->new({
#    EVAL_PERL => 1
#  });
##my $tt = "[% PERL %]\nprint '1245\n';\n[% END %]";
#my $tt = '[% GET message %]
#[% TRY -%]
#  [% PERL %]
#    print $context->include(\$stash->get("zzz"));
#  [% END -%]
#[% CATCH %]
#   ERROR! Type: [% error.type %]
#             Info: [% error.info %]
#   [% END -%]000';
#my $output = "";

#$template->process(\$tt, \%vars, \$output);
#print $output . "\n";

#die 1445;

use Getopt::Long;
use Data::Dumper;

sub main {
  my ($argPart, $argFileID, $dirCache, $postfixFile) = (@_);

  # Needed variables
  my %hContent;
  my %hVariable;
  my %hDependency;
  use Data::Dumper;

  my $rloadCache; # Recursive function of loading a cache file
  $rloadCache = sub {
    my ($idFile, $dirCache) = (@_);
    return if (exists $hContent{$idFile});

    # Read cache file as a long string, and eval it
    eval do {
      local(@ARGV, $/) = catfile($dirCache, $idFile . $postfixFile); <>;
    } or die;
    # Load other files I depend on
    foreach my $dep (keys %{$hDependency{$idFile}}) {
      $rloadCache->($dep, $dirCache);
    }
  };
  # Load the main file, let it load the rest automatically
  $rloadCache->($argFileID, $dirCache);

  # Define input and output variable
  my $rslt = "";
  my $input = $hContent{$argFileID}{$argPart};
  # Add error catcher around the template
  $input = '[% TRY %]' . $input . '[% CATCH %][% PERL %]'
    . '$context->throw($stash->get("error"));'
    . '[% END %][% END %]';

  my $oTmpl = Template->new({
      EVAL_PERL => 1,
      ERROR => \"Error: [% error %]"
    });

  # Put all text into some blocks, named (fname):(part)
  my $oCtx = $oTmpl->context();
  foreach my $fname (keys %hContent) {
    foreach my $part (keys %{$hContent{$fname}}) {
      $oCtx->define_block("$fname:$part", $hContent{$fname}{$part});
    }
  }

  # Really evaluate the template now
  $oTmpl->process(\$input, {
      txt => \%hContent,
      deps => \%hDependency,
      dataAll => \%hVariable,
      data => $hVariable{$argFileID} # Vars for current file
    }, \$rslt);
  return $rslt;
}

unless (caller) { # If direct invocation of this script
  if (@ARGV < 4) {
    die "Usage: $0 part-name file-id input-file output-file";
  };

  my $argPart = shift;
  my $argFileID = shift;
  my $argInputFile = shift;
  my $argOutputFile = shift;

  # Sanity check: input-file need to be a real file
  if ( ! -e $argInputFile ) {
    die "Error: Input file $argInputFile does not exist";
  }

  # Compute cache dir based on $argFileID and $argInputFile
  my ($dirCache, $postfixFile);
  if ($argInputFile =~ m@(.*)$argFileID(\.[^\\/]+)?@) {
    $dirCache = $1;
    $postfixFile = $2;
  }

  my $rslt = main $argPart, $argFileID, $dirCache, $postfixFile;

  # Write results to target file
  if ($argOutputFile ne '-') {
    open my $fdOut, ">", $argOutputFile or die;
    print {$fdOut} $rslt;
    close $fdOut;
  } else {
    print $rslt;
  }
}
