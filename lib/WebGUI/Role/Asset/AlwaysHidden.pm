package WebGUI::Role::Asset::AlwaysHidden;

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

=head1 NAME

Package WebGUI::Role::Asset::AlwaysHidden

=head1 DESCRIPTION

Asset Role that guarantees that the isHidden property is always 1.

=head1 SYNOPSIS

with WebGUI::Role::Asset::AlwaysHidden;

=cut

use Moose::Role;

around isHidden => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        shift @_;
        unshift @_, 1;
    }
    $self->$orig(@_);
};

1;
