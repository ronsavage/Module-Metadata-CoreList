#/usr/bin/env perl

use strict;
use warnings;

# I tried 'require'-ing modules but that did not work.

use Module::Metadata::CoreList; # For the version #.

use Test::More;


# ----------------------

pass('All external modules loaded');

my(@modules) = qw
/
/;

diag "Testing Module::Metadata::CoreList V $Module::Metadata::CoreList::VERSION";

for my $module (@modules)
{
	no strict 'refs';

	my($ver) = ${$module . '::VERSION'} || 'N/A';

	diag "Using $module V $ver";
}

done_testing;
