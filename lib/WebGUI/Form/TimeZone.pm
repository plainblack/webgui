package WebGUI::Form::SelectList;

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
use base 'WebGUI::Form::Control';
use WebGUI::DateTime;
use WebGUI::Form::SelectList;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::TimeZone

=head1 DESCRIPTION

Creates a template chooser control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("timezone","DateTime");
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a database connection picker control.

=cut

sub toHtml {
	my $self = shift;
	my $cmd = "WebGUI::Form::SelectList";
	my $selectList = $cmd->new(
		id=>$self->{id},
		name=>$self->{name},
		options=>WebGUI::DateTime::getTimeZones(),
		value=>[$self->{value}],
		extras=>$self->{extras}
		);
	return $selectList->toHtml;
}



1;

