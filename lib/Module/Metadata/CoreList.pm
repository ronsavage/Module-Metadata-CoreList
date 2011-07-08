package Module::Metadata::CoreList;

use strict;
use warnings;

use File::Spec;

use Module::CoreList;

use Text::Xslate;

our $VERSION = '1.00';

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
	 _dir_name    => '.',
	 _file_name   => '',
	 _perl        => '',
	 _report_type => 'text',
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _standard_keys
	{
		keys %_attr_data;
	}
}

# -----------------------------------------------

sub new
{
	my($class, %arg)	= @_;
	my($self)			= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	return $self;

}	# End of new.

# -----------------------------------------------

sub process_build_pl
{
	my($self, $line_ara) = @_;

	# Assumed input format:
	# build_requires =>
	# {
	#	"Test::More" => 0,
	#	'Test::Pod'  => 0,
	# },
	# configure_requires =>
	# {
	#	Module::Build => 0,
	# },
	# requires =>
	# {
	#	Module::CoreList => 0,
	# },

	my(@name);

	my($candidate) = 0;

	for my $line (@$line_ara)
	{
		if ($line =~ /^\s*(?:build_|configure_|)requires/i)
		{
			$candidate = 1;
		}
		elsif ($candidate && $line =~ /^\s*}/)
		{
			$candidate = 0;
		}
		elsif ($candidate && ($line =~ /^\s*(['"])?([\w:]+)\1?\s*=>\s*(.+),/) )
		{
			push @name, [$2, $3];
		}
	}

	return [sort{$$a[0] cmp $$b[0]} @name];

}	# End of process_build_pl.

# -----------------------------------------------

sub process_makefile_pl
{
	my($self, $line_ara) = @_;

	# Assumed input format:
	# PREREQ_PM =>
	# {
	#	Module::CoreList => 0,
	#	'Test::More'     => 0,
	#	"Test::Pod"      => 0,
	# },

	my(@name);

	my($candidate) = 0;

	for my $line (@$line_ara)
	{
		if ($line =~ /^\s*PREREQ_PM/i)
		{
			$candidate = 1;
		}
		elsif ($candidate && $line =~ /^\s*}/)
		{
			$candidate = 0;
		}
		elsif ($candidate && ($line =~ /^\s*(['"])?([\w:]+)\1?\s*=>\s*(.+),/) )
		{
			push @name, [$2, $3];
		}
	}

	return [sort{$$a[0] cmp $$b[0]} @name];

}	# End of process_makefile_pl.

#  -----------------------------------------------

sub report_as_html
{
	my($self, $module_list) = @_;
	my($templater) = Text::Xslate -> new
		(	
		 input_layer => '',
		 path        => './htdocs/assets/templates/module/metadata/corelist',
		);

	my(%module_list)    = map{($$_[0] => undef)} @$module_list;
	my(%module_version) = map{($$_[0] => $$_[1])} @$module_list;
	my(@present)        = [{td => 'Module'}, {td => $$self{_file_name}}, {td => 'CoreList'}];

	for my $name (@$module_list)
	{
		for my $module (sort keys %{$Module::CoreList::version{$$self{_perl} } })
		{
			if ($module eq $$name[0])
			{
				$module_list{$module} = $Module::CoreList::version{$$self{_perl} }{$module} || 0;

				push @present, [{td => $$name[0]}, {td => $$name[1]} , {td => $module_list{$module} }];
			}
		}
	}

	my(@absent) = [{td => 'Module'}, {td => $$self{_file_name}}];

	for my $name (sort keys %module_list)
	{
		if (! defined $module_list{$name})
		{
			push @absent, [{td => $name} ,{td => $module_version{$name} }];
		}
	}

	print $templater -> render
		(
		 'web.page.tx',
		 {
			 absent_heading  => "Modules found in $$self{_file_name} but not in Module::CoreList V $Module::CoreList::VERSION",
			 absent_modules  => [@absent],
			 options         => "Options: -d $$self{_dir_name} -f $$self{_file_name} -p $$self{_perl}",
			 present_heading => "Modules found in $$self{_file_name} and in Module::CoreList V $Module::CoreList::VERSION",
			 present_modules => [@present],
		 }
		);

} # End of report_as_html.

#  -----------------------------------------------

sub report_as_text
{
	my($self, $module_list) = @_;

	print "Options: -d $$self{_dir_name} -f $$self{_file_name} -p $$self{_perl}. \n";

	my(%module_list)    = map{($$_[0] => undef)} @$module_list;
	my(%module_version) = map{($$_[0] => $$_[1])} @$module_list;

	print "Modules found in $$self{_file_name} and in Module::CoreList V $Module::CoreList::VERSION:\n";

	for my $name (@$module_list)
	{
		for my $module (sort keys %{$Module::CoreList::version{$$self{_perl} } })
		{
			if ($module eq $$name[0])
			{
				$module_list{$module} = $Module::CoreList::version{$$self{_perl} }{$module} || 0;

				print "$module => $$name[1] and $module_list{$module}. \n";
			}
		}
	}

	print "Modules found in $$self{_file_name} but not in Module::CoreList V $Module::CoreList::VERSION: \n";

	for my $name (sort keys %module_list)
	{
		if (! defined $module_list{$name})
		{
			print "$name => $module_version{$name}. \n";
		}
	}

} # End of report_as_text.

#  -----------------------------------------------

sub run
{
	my($self)      = @_;
	my($dir_name)  = $$self{_dir_name};
	my($file_name) = $$self{_file_name};

	if (! $file_name)
	{
		$file_name = 'Build.PL|Makefile.PL';
	}
	elsif ($file_name !~ /^(?:Build.PL|Makefile.PL)$/i)
	{
		die "The file_name option's value must be either Build.PL or Makefile.PL";
	}

	opendir(INX, $dir_name) || die "Can't opendir($dir_name): $!";
	my(@file) = sort grep{/^($file_name)$/} readdir INX;
	closedir INX;

	if ($#file < 0)
	{
		die "Can't find either Build.PL or Makefile.PL in directory '$dir_name'";
	}

	# Read whatever name ends up in $file[0].

	$$self{_file_name} = $file[0];

	open(INX, File::Spec -> catfile($dir_name, $file[0]) ) || die "Can't open($file[0]): $!";
	my(@line) = <INX>;
	close INX;

	chomp @line;

	my($module_list);

	if ($file[0] eq 'Build.PL')
	{
		$module_list = $self -> process_build_pl(\@line);
	}
	else
	{
		$module_list = $self -> process_makefile_pl(\@line);
	}

	if ($$self{_report_type} =~ /^h/i)
	{
		$self -> report_as_html($module_list);
	}
	else
	{
		$self -> report_as_text($module_list);
	}

	# Return 0 for success and 1 for failure.

	return 0;

} # End of run.

# -----------------------------------------------

1;

=head1 NAME

L<Module::Metadata::CoreList> - Cross-check Build.PL/Makefile.PL pre-reqs with Module::CoreList for a specific version of Perl

=head1 Synopsis

	#!/usr/bin/env perl
	
	use strict;
	use warnings;
	
	use Module::Metadata::CoreList;
	
	# -----------------------------------------------
	
	Module::Metadata::CoreList -> new
	(
	dir_name    => '/home/ron/Data-Session',
	perl        => '5.012001',
	report_type => 'html',
	) -> run;

See also scripts/cc.corelist.pl.

=head1 Description

L<Module::Metadata::CoreList> is a pure Perl module.

This module cross-checks a module's pre-requisites with the versions shipped with a specific version of Perl.

It's aim is to aid module authors in fine-tuning the versions of modules listed in Build.PL and Makefile.PL.

It does this by reading Build.PL or Makefile.PL to get a list of pre-requisites, and looks
up those module names in Module::CoreList.

The output report can be in either text or HTML.

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing.

=head1 Constructor and initialization

new(...) returns an object of type L<Module::Metadata::CoreList>.

This is the class's contructor.

Usage: C<< Module::Metadata::CoreList -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options:

=over 4

=item o dir_name => $dir_name

Specify the directory to search in for Build.PL and/or Makefile.PL.

Default: '.'.

This key is optional.

=item o file_name => Build.PL or Makefile.PL

Specify that you only want to process the given file.

Default: ''.

This means the code searches for both Build.PL and Makefile.PL,
and processes the first one after sorting the names alphabetically.

This key is optional.

=item o perl => $version

Specify the specific version of Perl to consider, when accessing L<Module::CoreList>.

Perl V 5.10.1 must be written as 5.010001, and V 5.12.1 as 5.012001.

Default: ''.

This key is mandatory.

=item o report_type => 'html' or 'text'

Specify what type of report to produce. This report is written to STDOUT.

Default: 'text'.

This key is optional.

=back

=head1 Methods

=head2 process_build_pl($line_ara)

Process Build.PL.

$line_ara is an arrayref of lines, chomped, read from Build.PL.

Returns an arrayref of module names extracted from the build_requires, configure_requires and requires
sections of Build.PL.

Each element of the returned arrayref is an arrayref of 2 elements: The module name and the version #.

The arrayref is sorted by module name.

Called from L</run()>.

=head2 process_makefile_pl($line_ara)

Process Makefile.PL.

$line_ara is an arrayref of lines, chomped, read from Makefile.PL.

Returns an arrayref of module names extracted from the PREREQ_PM section of Makefile.PL.

Each element of the returned arrayref is an arrayref of 2 elements: The module name and the version #.

The arrayref is sorted by module name.

Called from L</run()>.

=head2 report_as_html($module_list)

$module_list is the arrayref returned from L</process_build_pl($line_ara)> and L</process_makefile_pl($line_ara)>.

Outputs a HTML report to STDOUT.

Called from L</run()>.

=head2 report_as_text($module_list)

$module_list is the arrayref returned from L</process_build_pl($line_ara)> and L</process_makefile_pl($line_ara)>.

Outputs a text report to STDOUT.

Called from L</run()>.

=head2 run()

Does all the work.

Calls either L<process_build_pl($line_ara)> or L</process_makefile_pl($line_ara)>, then calls either
L</report_as_html($module_list)> or L</report_as_text($module_list)>.

=head1 Author

L<Module::Metadata::CoreList> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
