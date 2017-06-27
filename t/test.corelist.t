use Capture::Tiny 'capture';

use Module::CoreList;
use Module::Metadata::CoreList;

use Test::More tests => 1;

# ------------------------

my($app) = Module::Metadata::CoreList -> new(perl_version => 5.008001);

my($stdout, $stderr, @result) = capture{$app -> run};

my(@report) = map{s/^\s//; s/\s$//; $_} grep{! /^(?:File::HomeDir|Module::CoreList)/} split(/\n/, $stdout);
my($expect) = <<EOS;
Options: -d . -f Makefile.PL -p 5.008001.
Modules found in Makefile.PL and in Module::CoreList V 5.201170621:
Config => 0 and 0.
File::Copy => 0 and 2.06.
File::Spec => 0 and 0.86.
Getopt::Long => 0 and 2.34.
Pod::Usage => 0 and 1.16.
strict => 0 and 1.03.
warnings => 0 and 1.03.
Modules found in Makefile.PL but not in Module::CoreList V 5.201170621:
Capture::Tiny => 0.
Config::Tiny => 0.
Date::Simple => 0.
Moo => 0.
Path::Class => 0.
Text::Xslate => 0.
Types::Standard => 0.
EOS
my(@expect) = split(/\n/, $expect);

is_deeply(\@report, \@expect, 'Check output from (effectively) running cc.corelist.pl on this module');
