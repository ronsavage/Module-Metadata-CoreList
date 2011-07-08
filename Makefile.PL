use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
 ($] ge '5.005') ?
 (
  AUTHOR   => 'Ron Savage (ron@savage.net.au)',
  ABSTRACT => 'Cross-check Build.PL/Makefile.PL pre-reqs with Module::CoreList for a specific version of Perl',
 ) : (),
 clean =>
 {
	 FILES => 'blib/* Makefile MANIFEST Module-Metadata-CorePrereqs-*'
 },
 dist =>
 {
	 COMPRESS => 'gzip',
	 SUFFIX   => 'gz'
},
 DISTNAME  => 'Module-Metadata-CorePrereqs',
 NAME      => 'Module::Metadata::CorePrereqs',
 PL_FILES  => {},
 PREREQ_PM =>
 {
	 Module::CoreList => 0,
	 'Test::More'     => 0,
	 "Test::Pod"      => 0,
 },
 VERSION_FROM => 'lib/Module/Metadata/CorePrereqs.pm',
);
