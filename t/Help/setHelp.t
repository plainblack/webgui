#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib"; ##t/lib

use WebGUI::Test;
use WebGUI::Operation::Help;
use WebGUI::International;
use WebGUI::Session;
use Text::Balanced qw(extract_codeblock);
use Data::Dumper;
use File::Find;

#The goal of this test is to locate all help topics that are set
#in admin consoles.

use Test::More; # increment this value for each test you create
my $numTests = 0;

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

# put your tests here

my $digits  = qr/(\d+)/;
my $bareword  = qr/(\w+)/;
my $quotelike = qr/((['"])([^'"\s]+\s*)+(['"]))/;
my $sub_args  = qr/(($quotelike|$digits)(,\s*)?)+/;
my $sess_arg = qr/(?:\$session|\$self->session)/;

my @helpTopics = ();
find(\&getHelpTopics, $lib);

$numTests = scalar(@helpTopics)
;

plan tests => $numTests;

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList($session);

my %helpTable = ();

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($session, $helpName);
	$helpTable{ $helpName } = $help;
}

foreach my $topic ( @helpTopics ) {
	my ($tag, $namespace, $file) = @{ $topic }{ qw/tag namespace file/ };
	$tag =~ tr/"'//d;
	$namespace =~ tr/'"//d;
	ok(exists $helpTable{$namespace}->{$tag},
	sprintf "help topic: %s->%s inside from %s", $namespace, $tag, $file);
}

sub getHelpTopics {
	return unless /\.pm$/;
	if ($File::Find::name =~ m#(?:Help|i18n)/?$#) {
		$File::Find::prune=1;
		return;
	}
	open my $pmf, $_
		or die "unable to open file $File::Find::name: $!\n";
	my $libFile = '';
	{
		local $/;
		$libFile = <$pmf>;
	}
	close $pmf;
	##Advance pos to first subroutine
	while ( my $subBody = extract_codeblock($libFile, '{}', qr/(?ms).*?^sub (\w+)\s*/) ) {
		if ( $subBody =~ /(\w+)\s*=\s*WebGUI::AdminConsole->new\($sess_arg(?:,\s*($quotelike))?\)/msgc) {
			my $objBody = $subBody;
			my ($obj, $namespace) = ($1,$2);
			if ( $objBody =~ /$obj\->setHelp\(($sub_args)\)/msgc ) {
				my ($tag, $namespace) = split /,\s*/, $1;
				push @helpTopics, {
					file=>$File::Find::name,
					tag=>$tag,
					namespace=>$namespace || 'WebGUI',
				};
			}
		}
		elsif ($subBody =~ /AdminConsole->setHelp\(($sub_args)\)/msgc ) {
			my ($tag, $namespace) = split /,\s*/, $1;
			push @helpTopics, {
				file=>$File::Find::name,
				tag=>$tag,
				namespace=>$namespace || 'WebGUI',
			};
		}
	}
}

