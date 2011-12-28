package WebGUI::Operation::AdSpace;

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
use WebGUI::AdSpace;
use WebGUI::AdSpace::Ad;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::HTMLForm;
use WebGUI::Storage;

=head1 NAME

Package WebGUI::Operation::AdSpace

=head1 DESCRIPTION

Operation handler for advertising functions.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user is allowed to use this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminAdSpace") );
}

#-------------------------------------------------------------------

=head2 www_clickAd ( )

Handles a click on an advertisement.

=cut

sub www_clickAd {
	my $session = shift;
	my $id = $session->form->param("id");
	return undef unless $id;
	my $url = WebGUI::AdSpace->countClick($session, $id);
	$session->response->setRedirect($url);
	return undef;
}

#-------------------------------------------------------------------

=head2 www_deleteAd ( )

Deletes an ad.

=cut

sub www_deleteAd {
	my $session = shift;
	return $session->privilege->insufficient unless canView($session);
	WebGUI::AdSpace::Ad->new($session, $session->form->param("adId"))->delete;
	return www_editAdSpace($session);
}

#-------------------------------------------------------------------

=head2 www_deleteAdSpace ( )

Deletes an ad space.

=cut

sub www_deleteAdSpace {
	my $session = shift;
	return $session->privilege->insufficient unless canView($session);
	WebGUI::AdSpace->new($session, $session->form->param("adSpaceId"))->delete;
	return www_manageAdSpaces($session);
}

#-------------------------------------------------------------------

=head2 www_editAd ( )

Displays form for editing an ad. 

=cut

sub www_editAd {
	my $session = shift;
        my $params  = shift;
	return $session->privilege->insufficient unless canView($session);
	my $id = $session->form->param("adId") || "new";
	my $ac = WebGUI::AdminConsole->new($session,"adSpace");
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my $ad = WebGUI::AdSpace::Ad->new($session,$id);
	$ac->addSubmenuItem($session->url->page("op=editAdSpace;adSpaceId=".$session->form->param("adSpaceId")), $i18n->get("edit this ad space"));
	$ac->addSubmenuItem($session->url->page("op=editAdSpace"), $i18n->get("add ad space"));
	$ac->addSubmenuItem($session->url->page("op=manageAdSpaces"), $i18n->get("manage ad spaces"));
	my $f = WebGUI::HTMLForm->new($session);

	$f->submit;
	$f->hidden(name=>"adId", value=>$id);
	$f->hidden(name=>"adSpaceId", value=> $session->form->param("adSpaceId"));
	$f->readOnly(label=>$i18n->get("ad id"), value=>$id);
	$f->hidden(name=>"op", value=>"editAdSave");
	my $value = $ad->get("isActive") if defined $ad;
	$f->yesNo(
		name=>"isActive",
		value=>$value,
		hoverHelp => $i18n->get("is active help"),
		label=>$i18n->get("is active")
		);
	$value = $ad->get("title") if defined $ad;
	$f->text(
		name=>"title",
		value=>$value,
		hoverHelp => $i18n->get("title help"),
		label=>$i18n->get("title")
		);
	$value = $ad->get("url") if defined $ad;
	$f->url(
		name=>"url",
		value=>$value,
		hoverHelp => $i18n->get("url help"),
		label=>$i18n->get("url")
		);
	$value = $ad->get("priority") if defined $ad;
	$f->integer(
		name=>"priority",
		value=>$value,
		hoverHelp => $i18n->get("priority help"),
		label=>$i18n->get("priority"),
		);
	$value = $ad->get("impressionsBought") if defined $ad;
	$f->integer(
		name=>"impressionsBought",
		value=>$value,
		hoverHelp => $i18n->get("impressions bought help"),
		label=>$i18n->get("impressions bought"),
		subtext=> defined $ad ? $i18n->get("used").": ".$ad->get("impressions") : undef
		);
	$value = $ad->get("clicksBought") if defined $ad;
	$f->integer(
		name=>"clicksBought",
		value=>$value,
		hoverHelp => $i18n->get("clicks bought help"),
		label=>$i18n->get("clicks bought"),
		subtext=> defined $ad ? $i18n->get("used").": ".$ad->get("clicks") : undef
		);
	$value = $ad->get("type") if defined $ad;
	$f->selectBox(
		name=>"type",
		value=>$value,
		options=>{
			text=>$i18n->get("text"),
			image=>$i18n->get("image"),
			rich=>$i18n->get("rich"),
			},
		defaultValue=>"text",
		hoverHelp => $i18n->get("type help"),
		label=>$i18n->get("type")
		);
	$f->fieldSetStart($i18n->get("text"));
	$value = $ad->get("adText") if defined $ad;
	$f->text(
		name=>"adText",
		size=>60,
		value=>$value,
		hoverHelp => $i18n->get("ad text help"),
		label=>$i18n->get("ad text")
		);
	$value = $ad->get("borderColor") if defined $ad;
	$f->color(
		name=>"borderColor",
		value=>$value,
		defaultValue=>"#000000",
		hoverHelp => $i18n->get("border color help"),
		label=>$i18n->get("border color")
		);
	$value = $ad->get("textColor") if defined $ad;
	$f->color(
		name=>"textColor",
		value=>$value,
		defaultValue=>"#000000",
		hoverHelp => $i18n->get("text color help"),
		label=>$i18n->get("text color")
		);
	$value = $ad->get("backgroundColor") if defined $ad;
	$f->color(
		name=>"backgroundColor",
		value=>$value,
		defaultValue=>"#ffffff",
		hoverHelp => $i18n->get("background color help"),
		label=>$i18n->get("background color")
		);
	$f->fieldSetEnd;
	$f->fieldSetStart($i18n->get("image"));
	$f->image(
		label=>$i18n->get("image"),
		hoverHelp=>$i18n->get("image help"),
		name=>"image"
		);
	if (defined $ad && $ad->get("storageId")) {
		my $storage = WebGUI::Storage->get($session, $ad->get("storageId"));
		$f->readOnly(value=>'<img src="'.$storage->getUrl($storage->getFiles->[0]).'" style="border: 0px;" />');
	}
	$f->fieldSetEnd;
	$f->fieldSetStart($i18n->get("rich"));
	$value = $ad->get("richMedia") if defined $ad;
	$f->codearea(
		name=>"richMedia",
		label=>$i18n->get("rich"),
		value=>$value,
		hoverHelp=>$i18n->get("rich help")
		);
	$f->fieldSetEnd;
	$f->submit;
	$ac->render($f->print, $i18n->get("edit advertisement"));
}

#-------------------------------------------------------------------

=head2 www_editAdSave ( )

The save method for www_editAd()

=cut

sub www_editAdSave {
	my $session = shift;
	return $session->privilege->insufficient unless canView($session);
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my %properties = (
		type=>$session->form->process("type", "selectBox"),	
		url=>$session->form->process("url", "url"),	
		isActive=>$session->form->process("isActive", "yesNo"),	
		textColor=>$session->form->process("textColor", "color"),	
		backgroundColor=>$session->form->process("backgroundColor", "color"),	
		borderColor=>$session->form->process("borderColor", "color"),	
		title=>$session->form->process("title", "text"),	
		adText=>$session->form->process("adText", "text"),	
		richMedia=>$session->form->process("richMedia", "codearea"),	
		priority=>$session->form->process("priority", "integer"),	
		impressionsBought=>$session->form->process("impressionsBought", "integer"),	
		clicksBought=>$session->form->process("clicksBought", "integer"),
		);
	my $storageId = $session->form->process("image","image");
	$properties{storageId} = $storageId if (defined $storageId);

	if ($session->form->param("adId") eq "new") {
		WebGUI::AdSpace::Ad->create($session, $session->form->param("adSpaceId"), \%properties);
	} else {
		my $ad = WebGUI::AdSpace::Ad->new($session, $session->form->param("adId"));
		if (defined $storageId && $ad->get("storageId")) {
			WebGUI::Storage->get($session, $ad->get("storageId"))->delete;
		}
		$ad->set(\%properties);
	}
	return www_editAdSpace($session);
}


#-------------------------------------------------------------------

=head2 www_editAdSpace ( [ adSpace, params ] )

Edit or add an ad space form. C<adSpace> is an instantiated WebGUI::AdSpace
object. C<params> is a hash reference of parameters with the following keys:

 errors         -> An array reference of error messages to the user

=cut

sub www_editAdSpace {
    my $session = shift;
    my $adSpace = shift;
    my $params  = shift;

    return $session->privilege->insufficient unless canView($session);
    
    my $i18n    = WebGUI::International->new( $session, "AdSpace" );
    my $ac      = WebGUI::AdminConsole->new( $session, "adSpace" );
    my $f       = WebGUI::HTMLForm->new($session);

    # Get the adspace we're working with
    my $id;
    if ( $adSpace ) {
        $id         = $adSpace->getId;
    } else {
        $id         = $session->form->param("adSpaceId") || "new";
        $adSpace    = WebGUI::AdSpace->new($session, $id);
    }
    
    if ( $adSpace ) {
        $ac->addSubmenuItem(
            $session->url->page("op=editAd;adSpaceId=".$id), $i18n->get("add an ad")
        );
    }
    $ac->addSubmenuItem(
        $session->url->page("op=manageAdSpaces"), $i18n->get("manage ad spaces")
    );

    # Give the errors to the user
    if ( $params->{errors} ) {
        $f->raw( '<p>' . $i18n->get('error heading') . '</p>'
                . '<ul>' 
                . join( "", map { '<li>' . $_ . '</li>' } @{ $params->{errors} } )
                . '</ul>'
        );
    }

    # Build the form
    $f->submit;
    $f->hidden( name => "adSpaceId", value => $id );
    $f->readOnly( label => $i18n->get("ad space id"), value => $id );
    $f->hidden( name => "op", value => "editAdSpaceSave" );
    $f->text(
        name        => "name",
        value       => $session->form->get('name') || ($adSpace && $adSpace->get("name")),
        hoverHelp   => $i18n->get("name help"),
        label       => $i18n->get("name"),
    );
    $f->text(
        name        => "title",
        value       => $session->form->get('title') || ($adSpace && $adSpace->get('title')),
        hoverHelp   => $i18n->get("title help"),
        label       => $i18n->get("title"),
    );
    $f->textarea(
        name        => "description",
        value       => $session->form->get('description') || ($adSpace && $adSpace->get('description')),
        hoverHelp   => $i18n->get("description help"),
        label       => $i18n->get("description"),
    );
    $f->integer(
        name            => "minimumClicks",
        value           => $session->form->get('minimumClicks') || ($adSpace && $adSpace->get('minimumClicks')),
        defaultValue    => 1000,
        hoverHelp       => $i18n->get("minimum clicks help"),
        label           => $i18n->get("minimum clicks"),
    );
    $f->integer(
        name            => "minimumImpressions",
        value           => $session->form->get('minimumImpressions') || ($adSpace && $adSpace->get('minimumImpressions')),
        defaultValue    => 1000,
        hoverHelp       => $i18n->get("minimum impressions help"),
        label           => $i18n->get("minimum impressions"),
    );
    $f->integer(
        name            => "width",
        value           => $session->form->get('width') || ($adSpace && $adSpace->get('width')),
        defaultValue    => 468,
        hoverHelp       => $i18n->get("width help"),
        label           => $i18n->get("width"),
    );
    $f->integer(
        name            => "height",
        value           => $session->form->get('height') || ($adSpace && $adSpace->get('height')),
        defaultValue    => 60,
        hoverHelp       => $i18n->get("height help"),
        label           => $i18n->get("height"),
    );
    $f->submit;

    # Show the ads in this adspace.
    my $ads     = "";
    my $code    = "";
    if ( $adSpace ) {
        $code = '<p style="padding: 5px; line-height: 20px; text-align: center; border: 3px outset black; font-family: helvetica; font-size: 11px; width: 200px; float: right;">'.$i18n->get("macro code prompt").'<br /><b>&#94;AdSpace('.$adSpace->get("name").');</b></p>';
        my $rs = $session->db->read("select adId, title, renderedAd from advertisement where adSpaceId=?",[$id]);
        while (my ($adId, $title, $ad) = $rs->array) {
            $ads    .= '<div style="margin: 15px; float: left;">'.$session->icon->delete("op=deleteAd;adSpaceId=".$id.";adId=".$adId, undef, $i18n->get("confirm ad delete"))
                    . $session->icon->edit( "op=editAd;adSpaceId=" . $id . ";adId=" . $adId )
                    . ' ' . $title . '<br />' . $ad . '</div>'
                    ;
        }
        $ads .= '<div style="clear: both;"></div>';
    }

    return $ac->render($code.$f->print.$ads, $i18n->get("edit ad space"));
}


#-------------------------------------------------------------------

=head2 www_editAdSpaceSave ( )

Save the www_editAdSpace method.

=cut

sub www_editAdSpaceSave {
    my $session = shift;

    return $session->privilege->insufficient unless canView($session);

    my $i18n    = WebGUI::International->new( $session, "AdSpace" );
    
    my %properties = (
        name               => $session->form->process("name",               "text"),	
        title              => $session->form->process("title",              "text"),	
        description        => $session->form->process("description",        "textarea"),	
        width              => $session->form->process("width",              "integer"),	
        height             => $session->form->process("height",             "integer"),	
        minimumClicks      => $session->form->process("minimumClicks",      "integer"),	
        minimumImpressions => $session->form->process("minimumImpressions", "integer"),	
    );

    ### Validate form entry
    my @errors;
    # Adspace titles cannot contain ] characters because of caching in the Layout asset
    if ( $properties{name} =~ /[\]]/ ) {
        push @errors, $i18n->get('error invalid characters');            
    }

    if ( @errors ) {
        return www_editAdSpace( $session, undef, { errors => \@errors } );
    }

    # Create the new Ad Space
    if ($session->form->param("adSpaceId") eq "new") {
        my $adSpace = WebGUI::AdSpace->create($session, \%properties);
        return www_editAdSpace($session, $adSpace);
    } 
    # Edit the existing Ad Space
    else {
        my $adSpace = WebGUI::AdSpace->new($session, $session->form->param("adSpaceId"));
        $adSpace->set(\%properties);
    }

    return www_manageAdSpaces($session);
}

#-------------------------------------------------------------------

=head2 www_manageAdSpaces ( )

Manage ad spaces.

=cut

sub www_manageAdSpaces {
	my $session = shift;
	return $session->privilege->insufficient unless canView($session);
	my $ac = WebGUI::AdminConsole->new($session,"adSpace");
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my $output = "";
	foreach my $adSpace (@{WebGUI::AdSpace->getAdSpaces($session)}) {
		$output .= '<div style="float: left; margin: 10px;">'
			.$session->icon->delete("op=deleteAdSpace;adSpaceId=".$adSpace->getId, undef, $i18n->get("confirm ad space delete"))
			.$session->icon->edit("op=editAdSpace;adSpaceId=".$adSpace->getId)
			.' '.$adSpace->get("title").'<br />'
			.$adSpace->displayImpression(1)
			.'</div>';
	}	
	$output .= '<div style="clear: both;"></div>';
	$ac->addSubmenuItem($session->url->page("op=editAdSpace"), $i18n->get("add ad space"));
	return $ac->render($output);
}


1;
