package WebGUI::Account::Contributions;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use WebGUI::Operation::Auth;

use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Contributions

=head1 DESCRIPTION

This is the class which is used to display a users's contributions to the site

=head1 SYNOPSIS

 use WebGUI::Account::Contributions;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_Contributions');
    my $f       = WebGUI::HTMLForm->new($session);

    $f->template(
		name      => "contribStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("contrib style template label"),
        hoverHelp => $i18n->get("contrib style template hoverHelp")
    );
    $f->template(
		name      => "contribLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("contrib layout template label"),
        hoverHelp => $i18n->get("contrib layout template hoverHelp")
    );
    $f->template(
		name      => "contribViewTemplateId",
		value     => $self->getViewTemplateId,
		namespace => "Account/Contrib/View",
		label     => $i18n->get("contrib view template label"),
        hoverHelp => $i18n->get("contrib view template hoverHelp")
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("contribStyleTemplateId", $form->process("contribStyleTemplateId","template"));
    $setting->set("contribLayoutTemplateId", $form->process("contribLayoutTemplateId","template"));
    $setting->set("contribViewTemplateId", $form->process("contribViewTemplateId","template"));
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("contribLayoutTemplateId") || "b4n3VyUIsAHyIvT-W-jziA";
}


#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("contribStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the main view.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("contribViewTemplateId") || "1IzRpX0tgW7iuCfaU2Kk0A";
}


#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $userId  = $self->uid || $session->user->userId;
    my $var     = {};

    #Set the uid just in case;
    #$self->uid($userId);


    #Deal with sort order
    my $sortBy       = $session->form->get("sortBy") || "creationDate";
    my $sort_url     = ($sortBy)?";sortBy=$sortBy":"";
    
    #Deal with sort direction
    my $sortDir      = $session->form->get("sortDir") || "desc";
    my $sortDir_url  = ";sortDir=".(($sortDir eq "desc")?"asc":"desc");

    #Deal with rows per page
    my $rpp          = $session->form->get("rpp") || 25;
    my $rpp_url      = ";rpp=$rpp";
    
    #Cache the base url
    my $contribsUrl  =  $self->getUrl(undef, 'appendUID');

    #Create sortBy headers
    $var->{'title_url'     } = $contribsUrl.";sortBy=title".$sortDir_url.$rpp_url;
   	$var->{'type_url'      } = $contribsUrl.";sortBy=className".$sortDir_url.$rpp_url;
    $var->{'dateStamp_url' } = $contribsUrl.";sortBy=creationDate".$sortDir_url.$rpp_url;
    $var->{'rpp_url'       } = $contribsUrl.$sort_url.";sortDir=".$sortDir;
    
    #Create the paginator
    my $root   = WebGUI::Asset->getRoot( $session );
    my $sql    = $root->getLineageSql(
        [ "self", "descendants" ],
        {
            includeOnlyClasses => [
                'WebGUI::Asset::Wobject::Article',
                'WebGUI::Asset::Post',
                'WebGUI::Asset::Wobject::GalleryAlbum',
                'WebGUI::Asset::Event',
                'WebGUI::Asset::WikiPage',
                'WebGUI::Asset::Post::Thread',
            ],
            whereClause   => "asset.createdBy = '$userId' or assetData.ownerUserId = '$userId'",
            orderByClause => "$sortBy $sortDir"
        }
    );


    my $p  = WebGUI::Paginator->new(
        $session,
        $contribsUrl.";uid=".$userId.$sort_url.";sortDir=".$sortDir.$rpp_url,
        $rpp
    );
    $p->setDataByQuery($sql);
    
    #Export page to template
    my @contribs = ();
    ROW: foreach my $row ( @{$p->getPageData} ) {
        my $assetId    = $row->{assetId};
        my $asset      = eval { WebGUI::Asset->newById( $session, $assetId ); };
        if (Exception::Class->caught()) {
            $session->log->error("Unable to instanciate assetId $assetId: $@");
            next ROW;
        }
        my $props      = $asset->get;
        $props->{url}  = $asset->getUrl;
        if (ref $asset eq "WebGUI::Asset::Post") {
            $asset = $asset->getThread;
            $props = $asset->get;
            $props->{className} = "WebGUI::Asset::Post";
        }
        
        push(@contribs,$props);
    }
    my $contribsCount  = $p->getRowCount;

    $var->{'contributions_loop'  } = \@contribs;
    $var->{'has_contributions'   } = $contribsCount > 0;
    $var->{'contributions_total' } = $contribsCount;

    tie my %rpps, "Tie::IxHash";
    %rpps = (25 => "25", 50 => "50", 100=>"100");
    $var->{'contributions_rpp'  } = WebGUI::Form::selectBox($session,{
        name    =>"rpp",
        options => \%rpps,
        value   => $session->form->get("rpp") || 25,
        extras  => q{onchange="location.href='}.$var->{'rpp_url'}.q{;rpp='+this.options[this.selectedIndex].value"}
    });

    $self->appendCommonVars($var);
    $p->appendTemplateVars($var);

    return $self->processTemplate($var,$self->getViewTemplateId);
}


1;
