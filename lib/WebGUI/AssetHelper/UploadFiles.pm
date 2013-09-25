package WebGUI::AssetHelper::UploadFiles;

use strict;
use base qw/WebGUI::AssetHelper/;
use WebGUI::Form::File;
use WebGUI::TabForm;

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

=head1 NAME

Package WebGUI::AssetHelper::UploadFiles

=head1 DESCRIPTION

Creates multiple file assets from form uploads beneath the current asset.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ()

Opens a new tab for displaying the form and the output for editing a branch.

=cut

sub process {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }

    return {
        openDialog => $self->getUrl( 'uploadFiles' ),
    };
}

#-------------------------------------------------------------------

=head2 www_uploadFiles ( )

Creates a tabform to edit the Asset Tree. If canEdit returns False, returns insufficient Privilege page. 

=cut

sub www_uploadFiles {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset');
    my ( $style, $url ) = $session->quick( qw( style url ) );
    $style->setCss( $url->extras('hoverhelp.css'));
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/container/container-min.js') );
    $style->setScript( $url->extras('hoverhelp.js') );
    $style->setRawHeadTags( <<'ENDHTML' );
<style type="text/css">
    label.formDescription { display: block; margin-top: 1em; font-weight: bold }
</style>
ENDHTML
    my $tabform = WebGUI::TabForm->new($session);
    $tabform->hidden({name=>"op",value=>"assetHelper"});
    $tabform->hidden({name=>"helperId",value=>$self->id});
    $tabform->hidden({name=>"method",value=>"uploadFilesSave"});
    $tabform->hidden({name=>"assetId",value=> $session->form->process('assetId'), });
    if ($session->config->get("enableSaveAndCommit")) {
        $tabform->submitAppend(WebGUI::Form::submit($session, {
            name    => "saveAndCommit", 
            value   => WebGUI::International->new($session, 'Asset')->get("save and commit"),
        }));
    }
    my $prop_tab = $tabform->addTab("properties",$i18n->get("properties","Asset"));
    my $sec_tab  = $tabform->addTab("security",$i18n->get(107,"Asset"),6);
    $prop_tab->yesNo(
        name      => "isHidden",
        value     => 1,
        label     => $i18n->get(886, 'Asset'),
        hoverHelp => $i18n->get('886 description', 'Asset'),
        uiLevel   => 6,
    );
    $prop_tab->yesNo(
        name      => "newWindow",
        value     => 0,
        label     => $i18n->get(940, 'Asset'),
        hoverHelp => $i18n->get('940 description', 'Asset'),
        uiLevel   => 6,
    );
    $prop_tab->file(
        name           => 'upload_files',
        label          => $i18n->get("upload files"),
        hoverHelp      => $i18n->get("upload files description"),
        maxAttachments => 100,
    );
    my $subtext;
    if ($session->user->isAdmin) {
        $subtext = $session->icon->manage('op=listUsers');
    }
    else {
        $subtext = "";
    }
    my $clause;
    if ($session->user->isAdmin) {
        my $group = WebGUI::Group->new($session,4);
        my $contentManagers = $group->getAllUsers();
        push (@$contentManagers, $session->user->userId);
        $clause = "userId in (".$session->db->quoteAndJoin($contentManagers).")";
    }
    else {
        $clause = "userId=".$session->db->quote($asset->get("ownerUserId"));
    }
    my $users = $session->db->buildHashRef("select userId,username from users where $clause order by username");
    $sec_tab->selectBox(
        name      => "ownerUserId",
        options   => $users,
        label     => $i18n->get(108, 'Asset'),
        hoverHelp => $i18n->get('108 description', 'Asset'),
        value     => [$asset->get("ownerUserId")],
        subtext   => $subtext,
        uiLevel   => 6,
    );
    $sec_tab->group(
         name      => "groupIdView",
         label     => $i18n->get(872, 'Asset'),
         hoverHelp => $i18n->get('872 description', 'Asset'),
         value     => [$asset->get("groupIdView")],
         uiLevel   => 6,
    );
    $sec_tab->group(
         name          => "groupIdEdit",
         label         => $i18n->get(871, 'Asset'),
         hoverHelp     => $i18n->get('871 description', 'Asset'),
         value         => [$asset->get("groupIdEdit")],
         excludeGroups => [1,7],
         uiLevel       => 6,
    );

    return $session->style->process(
        '<div class="yui-skin-sam">' . $tabform->print . '</div>',
        "PBtmpl0000000000000137"
    );
}

#-------------------------------------------------------------------

=head2 www_uploadFilesSave ( )

Process form output and create child File/Image assets as approriate.

=cut

sub www_uploadFilesSave {
    my ($self)  = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    return $session->privilege->insufficient() unless ($asset->canEdit && $session->user->isInGroup('4'));
    if ($session->config("maximumAssets")) {
        my ($count) = $session->db->quickArray("select count(*) from asset");
        my $i18n = WebGUI::International->new($session, "Asset");
        return $session->style->userStyle($i18n->get("over max assets")) if ($session->config("maximumAssets") <= $count);
    }

    my $overrides = $session->config->get( "assets/" . $asset->get("className") . "/fields" );
    my $form      = $session->form;

    ##Process the form data that is the same for every uploaded file.
    my %asset_defaults = ();
    foreach my $property_name ( $asset->getProperties ) {
        my $property = $asset->meta->find_attribute_by_name($property_name);
        next if $property->noFormPost;

        my $fieldType      = $property->fieldType;
        my $fieldOverrides = $overrides->{$property_name} || {};
        my $fieldHash      = {
            tab => "properties",
            %{ $asset->getFormProperties($property_name) },
            %{$overrides},
            name  => $property_name,
            value => $asset->$property_name,
        };

        # process the form element
        my $defaultValue = $overrides->{defaultValue} // $asset->$property_name;
        $asset_defaults{$property_name} = $form->process( $property_name, $fieldType, $defaultValue, $fieldHash );
    } ## end foreach my $property ( $asset...)

    ##This is a hack.  File uploads should go through the WebGUI::Form::File API
    my $tempFileStorageId = WebGUI::Form::File->new($session,{name => 'upload_files'})->getValue;
    my $tempStorage       = WebGUI::Storage->get($session, $tempFileStorageId);

    foreach my $filename (@{$tempStorage->getFiles}) {
        my $selfName = $tempStorage->isImage($filename)
                     ? "WebGUI::Asset::File::Image" 
                     :'WebGUI::Asset::File';
 
        my %data = %asset_defaults;

        $data{className}  = $selfName;
        $data{filename}   = $data{title} = $data{menuTitle} = $filename;
        $data{templateId} = 'PBtmpl0000000000000024';
        if ($selfName eq  "WebGUI::Asset::File::Image") {
            $data{templateId} = 'PBtmpl0000000000000088';
        }
        $data{url} = $asset->get('url').'/'.$filename;
        
        #Create the new asset
        my $newAsset = $asset->addChild(\%data);
        
        #Get the current storage location
        my $storage = $newAsset->getStorageLocation();
        $storage->addFileFromFilesystem($tempStorage->getPath($filename));
        $newAsset->applyConstraints;
        
        #Now remove the reference to the storeage location to prevent problems with different revisions.
        delete $newAsset->{_storageLocation};
    }
    $tempStorage->delete;

    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        override        => scalar $session->form->process("saveAndCommit"),
        allowComments   => 1,
        returnUrl       => $asset->getUrl,
    });

    # return JavaScript to close the pop-up window that got opened in process().

    return qq{
        <html><head>
        <script type="text/javascript">
            window.parent.admin.showInfoMessage( "File upload successful." );
            window.parent.admin.closeModalDialog();
        </script>
        </head></html>
    };

}

1;
