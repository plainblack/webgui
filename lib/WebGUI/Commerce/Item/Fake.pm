package WebGUI::Commerce::Item::Fake;
# Adding this to cope with sales tax without changing the schema.

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Commerce::Item;
use base 'WebGUI::Commerce::Item';

sub new {
        my $class = shift;
        my $session = shift;
        my $id = shift;
        my $namespace = shift;
        my ($price, $name) = split /\,/, $id, 2;
        bless { _name => $name, _price => $price }, $class;
}

sub useSalesTax { 0 }
sub name { $_[0]{_name} }
sub price { $_[0]{_price} }
sub type { 'Fake' }
sub id { "$_[0]{_price},$_[0]{_name}" }
sub description { $_[0]{_name} }
1;
