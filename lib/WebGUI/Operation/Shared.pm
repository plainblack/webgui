package WebGUI::Operation::Shared;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

Copies the requested database link in the form variable C<dlid> if the user
is in group Admin (3).  Returns the user to the List Database Links screen.

=cut

#-------------------------------------------------------------------
 sub accountOptions {
	my $session = shift;
	my $i18n = WebGUI::International->new($session);
	my @array;
	if ($session->user->isInGroup(12)) {
		my %hash;
		if ($session->var->get("adminOn")) {
			$hash{'options.display'} .= '<a href="'.$session->url->page('op=switchOffAdmin').'">'.$i18n->get(12).'</a>';
		} else {
			$hash{'options.display'} .= '<a href="'.$session->url->page('op=switchOnAdmin').'">'.$i18n->get(63).'</a>';
		}
	    push(@array,\%hash);
	}
	unless ($session->form->process("op") eq "displayAccount"){
		my %hash;
		$hash{'options.display'} = '<a href="'.$session->url->page('op=auth;method=init').'">'.$i18n->get(342).'</a>';
		push(@array,\%hash);
	}
	unless ($session->form->process("op") eq "editProfile"){
		my %hash;
		$hash{'options.display'} = '<a href="'.$session->url->page('op=editProfile').'">'.$i18n->get(341).'</a>';
		push(@array,\%hash);
	}
	unless ($session->form->process("op") eq "viewProfile"){
		my %hash;
		$hash{'options.display'} = '<a href="'.$session->url->page('op=viewProfile;uid='.$session->user->userId).'">'.$i18n->get(343).'</a>';
		push(@array,\%hash);
	}
	unless ($session->form->process("op") eq "viewInbox"){
		my %hash;
		$hash{'options.display'} = '<a href="'.$session->url->page('op=viewInbox').'">'.$i18n->get(354).'</a>';
		push(@array,\%hash);
	}
	unless ($session->form->process("op") eq "redeemSubscriptionCode") {
		push(@array, {'options.display' => '<a href="'.$session->url->page('op=redeemSubscriptionCode').'">'.$i18n->get('redeem code', 'Subscription').'</a>'});
	}
		
	my %logout;
	$logout{'options.display'} = '<a href="'.$session->url->page('op=auth;method=logout').'">'.$i18n->get(64).'</a>'; 
	push(@array,\%logout);
	if ($session->setting->get("selfDeactivation") && !$session->user->isInGroup(3)){
	   my %hash;
	   $hash{'options.display'} = '<a href="'.$session->url->page('op=auth;method=deactivateAccount').'">'.$i18n->get(65).'</a>';
	   push(@array,\%hash);
	}
	return \@array;
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
	my $i18n = WebGUI::International->new($session);
	my %trusted = (
		'WebGUI::International::get' => sub {$i18n->get(@_)},
		'WebGUI::International::getLanguages' => sub { $i18n->getLanguages(@_) },
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
