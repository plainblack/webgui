package WebGUI::Asset::MatrixListing;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use base 'WebGUI::Asset';
use WebGUI::Utility;



=head1 NAME

Package WebGUI::Asset::MatrixListing

=head1 DESCRIPTION

Describe your New Asset's functionality and features here.

=head1 SYNOPSIS

use WebGUI::Asset::MatrixListing;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 addRevision

   This method exists for demonstration purposes only.  The superclass
   handles revisions to MatrixListing Assets.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->SUPER::addRevision(@_);
	return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for MatrixListing instances.  

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_MatrixListing");
	%properties = (
		templateId => {
			tab             =>"display",
			fieldType       =>"template",  
			defaultValue    =>'MatrixListingTmpl00001',
			noFormPost      =>0,  
			namespace       =>"MatrixListing", 
			hoverHelp       =>$i18n->get('template description'),
			label           =>$i18n->get('template label')
			},
        screenshots => {
            tab             =>"properties",
            fieldType       =>"image",
            defaultValue    =>undef,
            label           =>$i18n->get("screenshots label"),
            hoverHelp       =>$i18n->get("screenshots description")
            },
        description => {
            tab             =>"properties",
            fieldType       =>"HTMLArea",
            defaultValue    =>undef,
            label           =>$i18n->get("description label"),
            hoverHelp       =>$i18n->get("description description")
            },
        version => {
            tab             =>"properties",
            fieldType       =>"text",
            defaultValue    =>undef,
            label           =>$i18n->get("version label"),
            hoverHelp       =>$i18n->get("version description")
            },
        views => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        compares => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        clicks => {
            defaultValue    =>0,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        viewsLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        comparesLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        clicksLastIp => {
            defaultValue    =>undef,
            autoGenerate    =>0,
            noFormPost      =>1,
            },
        maintainer => {
            tab             =>"properties",
            fieldType       =>"user",
            defaultValue    =>$session->user->userId,
            label           =>$i18n->get("maintainer label"),
            hoverHelp       =>$i18n->get("maintainer description")
            },
        manufacturerName => {
            tab             =>"properties",
            fieldType       =>"text",
            defaultValue    =>undef,
            label           =>$i18n->get("manufacturerName label"),
            hoverHelp       =>$i18n->get("manufacturerName description")
            },
        manufacturerURL => {
            tab             =>"properties",
            fieldType       =>"url",
            defaultValue    =>undef,
            label           =>$i18n->get("manufacturerURL label"),
            hoverHelp       =>$i18n->get("manufacturerURL description")
            },
        productURL => {
            tab             =>"properties",
            fieldType       =>"url",
            defaultValue    =>undef,
            label           =>$i18n->get("productURL label"),
            hoverHelp       =>$i18n->get("productURL description")
            },
        lastUpdated => {
            defaultValue    =>time(),
            autoGenerate    =>0,
            noFormPost      =>1,
            },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'MatrixListing.gif',
		autoGenerateForms=>1,
		tableName=>'MatrixListing',
		className=>'WebGUI::Asset::MatrixListing',
		properties=>\%properties
	});
	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate

   This method exists for demonstration purposes only.  The superclass
   handles duplicating MatrixListing Assets.  This method will be called 
   whenever a copy action is executed

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId

Gets the WebGUI::VersionTag workflow to use to automatically commit MatrixListings. 
By specifying this method, you activate this feature.

=cut

sub getAutoCommitWorkflowId {
    my $self = shift;
    return $self->getParent->get("submissionApprovalWorkflowId");
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->setIsPublic(0);
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
    $self->requestAutoCommit;
}


#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a MatrixListing when the system
purges it's data.  

=cut

sub purge {
	my $self = shift;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

sub purgeRevision {
	my $self = shift;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
	my $self = shift;
	my $var = $self->get; # $var is a hash reference.
	$var->{controls} = $self->getToolbar;
	$var->{fileUrl} = $self->getFileUrl;
	$var->{fileIcon} = $self->getFileIconUrl;
	return $self->processTemplate($var,undef, $self->{_viewTemplate});
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page

=cut

sub www_edit {
    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->getParent->canAddMatrixListing();

    my $i18n = WebGUI::International->new($self->session, "Asset_MatrixListing");
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
    return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get('edit matrix listing title'));
}

#-------------------------------------------------------------------

=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	if ($self->session->var->isAdminOn) {
		return $self->getContainer->www_view;
	}
	$self->session->http->setRedirect($self->getFileUrl($self->getValue("showPage")));
	return undef;
}

#-------------------------------------------------------------------
# Everything below here is to make it easier to install your custom
# asset, but has nothing to do with assets in general
#-------------------------------------------------------------------
# cd /data/WebGUI/lib
# perl -MWebGUI::Asset::MatrixListing -e install www.example.com.conf [ /path/to/WebGUI ]
# 	- or -
# perl -MWebGUI::Asset::MatrixListing -e uninstall www.example.com.conf [ /path/to/WebGUI ]
#-------------------------------------------------------------------


use base 'Exporter';
our @EXPORT = qw(install uninstall);
use WebGUI::Session;

#-------------------------------------------------------------------
sub install {
	my $config = $ARGV[0];
	my $home = $ARGV[1] || "/data/WebGUI";
	die "usage: perl -MWebGUI::Asset::MatrixListing -e install www.example.com.conf\n" unless ($home && $config);
	print "Installing asset.\n";
	my $session = WebGUI::Session->open($home, $config);
	$session->config->addToArray("assets","WebGUI::Asset::MatrixListing");
	$session->db->write("create table MatrixListing (
		assetId         varchar(22) binary not null,
		revisionDate    bigint not null,
        title           varchar(255),
        screenshots     varchar(22),
        description     text,
        version         varchar(255),
        views           int(11),
        compares        int(11),
        clicks          int(11),
        viewsLastIp     varchar(255),
        comparesLastIp  varchar(255),
        clicksLastIp    varchar(255),
        lastUpdated     int(11),
        maintainer      varchar(22),
        manufacturerName    varchar(255),
        manufacturerURL     varchar(255),
        productURL          varchar(255),
		primary key (assetId, revisionDate)
		)");
	$session->var->end;
	$session->close;
	print "Done. Please restart Apache.\n";
}

#-------------------------------------------------------------------
sub uninstall {
	my $config = $ARGV[0];
	my $home = $ARGV[1] || "/data/WebGUI";
	die "usage: perl -MWebGUI::Asset::MatrixListing -e uninstall www.example.com.conf\n" unless ($home && $config);
	print "Uninstalling asset.\n";
	my $session = WebGUI::Session->open($home, $config);
	$session->config->deleteFromArray("assets","WebGUI::Asset::MatrixListing");
	my $rs = $session->db->read("select assetId from asset where className='WebGUI::Asset::MatrixListing'");
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::MatrixListing");
		$asset->purge if defined $asset;
	}
	$session->db->write("drop table MatrixListing");
	$session->var->end;
	$session->close;
	print "Done. Please restart Apache.\n";
}


1;

#vim:ft=perl
