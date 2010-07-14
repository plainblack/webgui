package WebGUI::Types;

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


use Moose;
use Moose::Util::TypeConstraints;
use JSON ();

=head1 NAME

Package WebGUI::Types

=head1 DESCRIPTION

A package to hold all Moose types for WebGUI::Definition based classes.

=head1 SYNOPSIS

use WebGUI::Types;

=head1 METHODS

These types are provided by this class:

=head2 WebGUI::Type::JSONArray

The JSONArray is an subtype of ArrayRef, with coercions.  If a string is applied to the property
with this type, it ties to pass it through JSON::from_json.  If that fails, then it returns an
empty arrayref.

Similarly, if an undef value is applied, it is coerced into an empty arrayref.

=cut

subtype 'WebGUI::Type::Config'
    => as class_type('WebGUI::Config');

coerce 'WebGUI::Type::Config'
    => from Str
    => via {
        require WebGUI::Config;
        WebGUI::Config->new($_)
    }
;

subtype 'WebGUI::Type::JSONArray'
    => as 'ArrayRef'
;

coerce 'WebGUI::Type::JSONArray'
    => from Str
    => via  { my $struct = eval { JSON::from_json($_); }; $struct ||= []; return $struct; },
;

coerce 'WebGUI::Type::JSONArray'
    => from Undef
    => via  { return []; },
;

subtype 'WebGUI::Type::JSONHash'
    => as 'HashRef'
;

coerce 'WebGUI::Type::JSONHash'
    => from Str
    => via  { my $struct = eval { JSON::from_json($_); }; $struct ||= {}; return $struct; },
;

coerce 'WebGUI::Type::JSONHash'
    => from Undef
    => via  { return {}; },
;

1;
