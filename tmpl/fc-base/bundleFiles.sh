[%- PERL %]
# Collect all required bundles
my $dataAll = $stash->get('dataAll');
my %bundles = ( map { %{$dataAll->{$_}{'toImport'}} } 
  (grep { exists $dataAll->{$_}{'toImport'} } keys %$dataAll) );
$stash->set('neededBundles', \%bundles);
[% END -%]
[%- FOREACH entry IN neededBundles -%]
function ~GET![% entry.key %] { # {{{
cat <<"EOF__::[% entry.key %]"
[% fname = entry.key -%]
[%- INCLUDE "$fname:out:main" %]
EOF__::[% entry.key %]
} # }}}

[% END -%]
