package WebGUI::Macro::International;

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

=head1 NAME

Package WebGUI::Macro::International

=head1 DESCRIPTION

Macro for displaying an internationalized label from WebGUI's internationalization system.

=head2 process ( label, namespace [, placeholder values] )

Note that a particular language cannot be specified.  It uses either the
current User's setting or the default language for the site.  English is
always used as a fallback.

=head3 label

The label to pull.

=head3 namespace

The namespace to pull the label from.

=head3 placeholder values

The values to be used in the field placeholders.

=cut


#-------------------------------------------------------------------
sub process {
    my $session     = shift;
    my $key         = shift;
    my $namespace   = shift;
    my @args        = @_;

    my $i18n = WebGUI::International->new($session);
    
    if (@args) {
        return sprintf $i18n->get($key, $namespace), @args;
    }
    else {
        return $i18n->get($key, $namespace);
    }
}


1;


