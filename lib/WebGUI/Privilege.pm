package WebGUI::Privilege;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::HTTP;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Privilege

=head1 DESCRIPTION

This package provides access to the WebGUI security system and security messages.

=head1 SYNOPSIS

 use WebGUI::Privilege;
 $html =	WebGUI::Privilege::adminOnly();
 $html =	WebGUI::Privilege::insufficient();
 $html =	WebGUI::Privilege::noAccess();
 $html =	WebGUI::Privilege::notMember();
 $html =	WebGUI::Privilege::vitalComponent();

=head1 METHODS 

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 adminOnly ( )

Returns a message stating that this functionality can only be used by administrators. This method also sets the HTTP header status to 401.

=cut

sub adminOnly {
	WebGUI::HTTP::setStatus("401", "Admin Only");
	my ($output, $sth, @data);
        $output = '<h1>'.WebGUI::International::get(35).'</h1>';
	$output .= WebGUI::International::get(36);
	return WebGUI::Operation::Shared::userStyle($output);
}


#-------------------------------------------------------------------

=head2 insufficient ( )

Returns a message stating that the user does not have the required privileges to perform the operation they requested. This method also sets the HTTP header status to 401. 

=cut

sub insufficient {
	WebGUI::HTTP::setStatus("401", "Insufficient Privileges");
	my ($output);
	$output = '<h1>'.WebGUI::International::get(37).'</h1>';
	$output .= WebGUI::International::get(38);
	$output .= '<p>';
	return WebGUI::Operation::Shared::userStyle($output);
}


#-------------------------------------------------------------------

=head2 noAccess ( )

Returns a message stating that the user does not have the privileges necessary to access this page. This method also sets the HTTP header status to 401.

=cut

sub noAccess {
	WebGUI::HTTP::setStatus("401", "No Access");
   	if ($session{user}{userId} eq '1') {
      		return WebGUI::Operation::Auth::www_auth("init");
   	} else {
      		my $output = '<h1>'.WebGUI::International::get(37).'</h1>';
      		$output .= WebGUI::International::get(39);
      		$output .= '<p>';
		return WebGUI::Operation::Shared::userStyle($output);
   	}
}

#-------------------------------------------------------------------

=head2 notMember ( )

Returns a message stating that the user they requested information about is no longer active on this server. This method also sets the HTTP header status to 400.

=cut

sub notMember {
	WebGUI::HTTP::setStatus("400", "Not A Member");
	my ($output);
	$output = '<h1>'.WebGUI::International::get(345).'</h1>';
	$output .= WebGUI::International::get(346);
	$output .= '<p>';
	return WebGUI::Operation::Shared::userStyle($output);
}

#-------------------------------------------------------------------

=head2 vitalComponent ( )

Returns a message stating that the user made a request to delete something that should never delete. This method also sets the HTTP header status to 403. 

=cut

sub vitalComponent {
	WebGUI::HTTP::setStatus("403", "Vital Component");
	my ($output);
        $output = '<h1>'.WebGUI::International::get(40).'</h1>';
	$output .= WebGUI::International::get(41);
	$output .= '<p>';
	return WebGUI::Operation::Shared::userStyle($output);
}



1;

