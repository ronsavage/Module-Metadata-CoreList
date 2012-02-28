use Module::Build;

my $class = Module::Build->subclass(code => <<'EOF');

sub ACTION_build
{
	my $self = shift;
	$self->SUPER::ACTION_build(@_);
	$self->run_perl_script('scripts/copy.config.pl');
}
EOF

$class -> new
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
 {   # Deliberately do not use version numbers.
	 Capture::Tiny    => 0,
	 Config::Tiny     => 0,
	 File::HomeDir    => 0,
	 File::Spec       => 0,
	 Hash::FieldHash  => 0,
	 Module::CoreList => 0,
	 Path::Class      => 0,
	 Text::Xslate     => 0,
 },
) -> create_build_script();
