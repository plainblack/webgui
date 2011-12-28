package WebGUI::Operation::Shared;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use Safe;

=head1 NAME

Package WebGUI::Operation::Shared

=head1 DESCRIPTION

Shared routines for WebGUI Operations.

=head2 accountOptions ( $session )

TODO: DOCUMENT ME

DEPRECATED - USE Macros to display account options

=cut

#-------------------------------------------------------------------
 sub accountOptions {
	my $session = shift;
    return "";
}

=head2 secureEval ( $session, $code )

Eval $code inside of a Safe compartment to prevent sneaky attacks, mainly for use with
the Profile system, where internationalized labels are stored as perl code inside
the database.

=cut

#-------------------------------------------------------------------
# This function is here to replace the dangerous eval calls in the User Profile System.
sub secureEval {
	my $session = shift;
	my $code = shift;

	# Handle WebGUI function calls
    my $i18n;
	my %trusted = (
        'WebGUI::International::get' => sub {
            $i18n ||= WebGUI::International->new($session);
            $i18n->get(@_);
        },
        'WebGUI::International::getLanguages' => sub {
            $i18n ||= WebGUI::International->new($session);
            $i18n->getLanguages(@_);
        },
		'WebGUI::DateTime::epochToHuman' => sub { $session->datetime->epochToHuman(@_) },
		'$session->datetime->epochToHuman' => sub { $session->datetime->epochToHuman(@_) },
		'WebGUI::Icon::getToolbarOptions' => sub { $session->icon->getToolbarOptions() },
	);
	foreach my $function (keys %trusted ) {
		while ($code =~ /($function\(([^)]*)\)\s*;*)/g) {
			my $cmd = $1;
			my @param = split (/,\s*/,$2);
			@param = map { s/^['"]|['"]$//g; $_; } @param;
			my $output = $trusted{$function}(@param);
			return $output if (ref $output);
			$output =~ s/\'/\\\'/g;
			$code =~ s/\Q$cmd/\'$output\'/g;
		}
	}
	
	# Execute simple perl code like ['English'] for default value.
	# Inside the Safe compartment there's no WebGUI available
	my $compartment = new Safe;
	my $eval = $compartment->reval($code);
	if ($eval) {
		return $eval;
	} 
	return $code;
}


1;
