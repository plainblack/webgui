package WebGUI::Asset::JSONCollateralDummy;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use Class::C3;
use base qw/WebGUI::JSONCollateral WebGUI::Asset/;

=head1 NAME

Package WebGUI::Asset::JSONCollateral

=head1 DESCRIPTION

A dummy module for testing the JSON Collateral aspect.  The module really doesn't
do anything, except provide suport modules for testing.

The module inherits directly from WebGUI::Asset.

=head1 SYNOPSIS

use WebGUI::Asset::JSONCollateralDummy;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( )

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        jsonField => {
            label        => 'jsonField',
            hoverHelp    => 'Not really needed, it is for internal data in this test case',
            fieldType    => 'textarea',
            serialize    => 1,
            defaultValue => [],
            noFormPost   => 1,
        },
    );
    push(@{$definition}, {
        assetName=>'JSON Collateral Dummy',
        tableName=>'jsonCollateralDummy',
        autoGenerateForms=>1,
        className=>'WebGUI::Asset::JSONCollateralDummy',
        icon=>'assets.gif',
        properties=>\%properties
        }
    );
    return $class->next::method($session, $definition);
}

1;

#vim:ft=perl
