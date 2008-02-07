package WebGUI::Commerce::Payment::Check;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Commerce::Payment::Check

=head1 DESCRIPTION

Payment plug-in for check transactions.

=cut

use strict;
use WebGUI::HTMLForm;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Item;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::SQL;
use base 'WebGUI::Commerce::Payment::Cash';

#-------------------------------------------------------------------
sub getPaymentMethod {
	my $self = shift;
    unless($self->{_paymentMethod}) { 
        $self->{_paymentMethod} = "check";
    }
    return $self->{_paymentMethod};
}

#-------------------------------------------------------------------
sub i18n {
	my $self = shift;
    unless (exists $self->{_i18n}) {
       $self->{_i18n} = WebGUI::International->new($self->session,'CommercePaymentCheck');
    }
    return $self->{_i18n};
}

#-------------------------------------------------------------------

=head2 init ( namespace )

Constructor for the Check plugin.

=head3 session

A copy of the session object

=head3 namespace

The namespace of the plugin.

=cut

sub init {
	my ($class, $self);
	$class = shift;
	my $session   = shift;
    my $namespace = shift || 'Check';
	$self = $class->SUPER::init($session,$namespace);
	return $self;
}

#-------------------------------------------------------------------
sub name {
	return 'Check';
}


1;

