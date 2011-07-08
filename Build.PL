use Module::Build;

Module::Build -> new
(
 module_name    => 'Module::Metadata::CorePrereqs',
 license        => 'artistic',
 dist_abstract  => 'Cross-check Build.PL/Makefile.PL pre-reqs with Module::CoreList for a specific version of Perl',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
	 "Test::More" => 0,
	 'Test::Pod'  => 0,
 },
 configure_requires =>
 {
 	 Module::Build => 0,
 },
 requires =>
 {
	 CGI              => 0,
	 Module::CoreList => 0,
 },
) -> create_build_script();
