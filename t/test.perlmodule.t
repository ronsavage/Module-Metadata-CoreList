use Module::Metadata::CoreList;

use Test::More tests => 1;

# ------------------------

my(@report) = map{chomp; s/\s+$//; $_} `perl -MModule::Metadata::CoreList -e 'Module::Metadata::CoreList -> new(module_name => 'warnings', perl_version => 5.008001) -> check_perl_module'`;
my($expect) = <<EOS;
Module names which match the regexp qr/warnings/ in Perl V 5.008001: warnings, warnings::register.
EOS
my(@expect) = split(/\n/, $expect);

is_deeply(\@report, \@expect, 'Check output from (effectively) running cc.perlmodule.pl on module "warnings"');
