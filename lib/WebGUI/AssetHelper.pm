package WebGUI::AssetHelper;

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

=head1 NAME

Package WebGUI::AssetHelper

=head1 DESCRIPTION

Base class for all Asset Helpers, which provide editing and administrative controls for Assets inside
the Admin Console.

=head1 SYNOPSIS

Despite using OO style methods, there are no AssetHelper objects.  This is simply to provide inheritance.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

This is a class method.  Process is the default method called by the Asset Helper content handler.
It returns a hashref, that is converted by the content handler to JSON to be passed back to the
Admin Console.

=head3 $class

The name of the class this method was called as.

=head3 $asset

A WebGUI::Asset object.

=head3 Hashref Payload

Sending all hash keys at the same time may cause unpredictable results.

=head4 error

An error message to the user.  Should always be internationalized.

=head4 message

An informational message to the user.  Should always be internationalized.

=head4 open_tab

A URL. Will open a tab in the Admin Console.  Anything returned by the URL will be displayed in the tab.

=head4 redirect

A URL.  Puts new content into the View tab from the requested URL.

=head4 scriptFile

Loads the requested JavaScript file, referenced by URL.

=head4 scriptMethod

Calls this method.

=head4 scriptArgs

An array reference of arguments that, when used with C<scriptMethod>, will be passed to the javascript method.

=cut

sub process {
    my ($class, $asset) = @_;

    ##This method can do work, or it can delegate out to other methods.

    return {
        error           => q{User, we have a problem.},
        message         => q{A friendly informational method},
        open_tab        => '?op=assetHelper;className=WebGUI::AssetHelper;method=editBranch',
        redirect        => '/home',
        scriptFile      => q{URL},
        scriptMethod    => q{methodName},
        scriptArgs      => [ 'arg1', { another => 'argument' } ],
    };
}

1;
