package WebGUI::Asset::Redirect;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use WebGUI::Session;


=head1 NAME

Package WebGUI::Asset::Redirect 

=head1 DESCRIPTION

Provides a mechanism to redirect pages from the WebGUI site to external sites.

=head1 SYNOPSIS

use WebGUI::Asset::Redirect;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'redirect',
                className=>'WebGUI::Asset::Redirect',
                properties=>{
                                redirectUrl=>{
                                        fieldType=>'url',
                                        defaultValue=>undef
                                        }
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
        $tabform->getTab("properties")->url(
                -name=>"redirectUrl",
                -label=>"Redirect URL",
                -value=>$self->getValue("redirectUrl")
                );
}


#-------------------------------------------------------------------

=head2 getUiLevel ()

Returns the UI level of this asset.

=cut

sub getUiLevel {
	return 9;
}

#-------------------------------------------------------------------

=head2 name 

Returns the displayable name of this asset.

=cut

sub getName {
	return "Redirect";
} 


#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
	my $self = shift;
	if ($session{var}{adminOn}) {
		return $self->www_edit;
	} else {

	}
}


1;

