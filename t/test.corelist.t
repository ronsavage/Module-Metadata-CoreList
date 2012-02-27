use Module::Metadata::CoreList;

use Test::More tests => 1;

# ------------------------

my(@version) = map{chomp; s/\s+$//; $_} `perl -MModule::CoreList -e 'print "$Module::CoreList::VERSION\n"'`;
my(@report)  = map{chomp; s/\s+$//; $_} `perl -MModule::Metadata::CoreList -e 'Module::Metadata::CoreList -> new(perl_version => 5.008001) -> run'`;
my($expect)  = <<EOS;
Options: -d . -f Build.PL -p 5.008001.
Modules found in Build.PL and in Module::CoreList V $version[0]:
File::Spec => 0 and 0.86.
Test::More => 0 and 0.47.
Modules found in Build.PL but not in Module::CoreList V $version[0]:
Config::Tiny => 0.
File::HomeDir => 0.
Hash::FieldHash => 0.
Module::Build => 0.
Module::CoreList => 0.
Path::Class => 0.
Test::Pod => 0.
Text::Xslate => 0.
EOS
my(@expect) = split(/\n/, $expect);

is_deeply(\@report, \@expect, 'Check output from (effectively) running cc.corelist.pl on this module');
