use Module::Build;

Module::Build -> new
(
 module_name    => 'Module::Metadata::CoreList',
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
	 Config::Tiny     => 0,
	 File::HomeDir    => 0,
	 File::Spec       => 0,
	 Hash::FieldHash  => 0,
	 Module::CoreList => 0,
	 Path::Class      => 0,
	 Text::Xslate     => 0,
 },
) -> create_build_script();
