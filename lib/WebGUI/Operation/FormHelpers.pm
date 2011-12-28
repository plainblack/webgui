package WebGUI::Operation::FormHelpers;

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
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Form::Group;
use WebGUI::HTMLForm;
use WebGUI::Pluggable;
use WebGUI::Storage;

=head1 NAME

Package WebGUI::Operation::FormHelpers

=head1 DESCRIPTION

Operational support for various things relating to forms and rich editors.

=cut


#-------------------------------------------------------------------

=head2 www_formHelper ( session )

Calls a form helper. In the URL you must pass the form class name, the subroutine to call and any other 
parameters you wish the form helper to use. Here's an example:

/page?op=formHelper;class=File;sub=assetTree;param1=XXX

=cut

sub www_formHelper {
    my $session     = shift;
    my $form        = $session->form;
    my $class       = "WebGUI::Form::".$form->get("class");
    my $sub         = $form->get("sub");
    return "ERROR" unless (defined $sub && defined $class);
    my $output = eval { WebGUI::Pluggable::run($class, "www_".$sub, [$session]) }; 
    if ($@) {
        $session->log->error($@); 
        return "ERROR";
    }
    return $output;
}



1;
