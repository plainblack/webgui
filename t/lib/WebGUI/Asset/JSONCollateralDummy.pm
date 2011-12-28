package WebGUI::Asset::JSONCollateralDummy;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

use strict;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';

define assetName => 'JSON Collateral Dummy';
define tableName => 'jsonCollateralDummy';
define icon      => 'assets.gif';

property jsonField => (
            fieldType    => 'textarea',
            noFormPost   => 1,
            default      => sub { [] },
            traits       => ['Array', 'WebGUI::Definition::Meta::Property::Serialize',],
            isa          => 'WebGUI::Type::JSONArray',
            coerce       => 1,
         );

with 'WebGUI::Role::Asset::JSONCollateral';

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



1;

#vim:ft=perl
