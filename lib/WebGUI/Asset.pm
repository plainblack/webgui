package WebGUI::Asset;

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

use Scalar::Util qw( blessed weaken );
use Clone qw(clone);
use JSON;
use HTML::Packer;

use Moose;
use WebGUI::Types;
use Data::Dumper;
use WebGUI::FormBuilder;

use WebGUI::Definition::Asset;
define assetName  => ['asset', 'Asset'];
define tableName  => 'assetData';
define icon       => 'assets.gif';
property  title => (
            tab             => "properties",
            label           => ['99','Asset'],
            hoverHelp       => ['99 description','Asset'],
            fieldType       => 'text',
            default         => 'Untitled',
          );
around title => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        my $title = shift;
        $title    = WebGUI::HTML::filter($title, 'all');
        $title    = $self->meta->find_attribute_by_name('title')->default if $title eq '';
        unshift @_, $title;
    }
    $self->$orig(@_);
};

property  menuTitle => (
            tab             => "properties",
            label           => ['411','Asset'],
            hoverHelp       => ['411 description','Asset'],
            uiLevel         => 1,
            fieldType       => 'text',
            builder         => '_default_menuTitle',
            lazy            => 1,
         );
sub _default_menuTitle {
    my $self = shift;
    return $self->title;
}
around menuTitle => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        my $title = shift;
        $title    = WebGUI::HTML::filter($title, 'all');
        $title    = $self->_default_menuTitle if $title eq '';
        unshift @_, $title;
    }
    $self->$orig(@_);
};

property  url => (
            tab             => "properties",
            label           => ['104','Asset'],
            hoverHelp       => ['104 description','Asset'],
            uiLevel         => 3,
            fieldType       => 'text',
            lazy            => 1,
            builder         => '_default_url',
          );
sub _default_url {
    return $_[0]->fixUrl;
}

around url => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        my $url = $_[0];
        $url    = $self->fixUrl($url);
        unshift @_, $url;
    }
    $self->$orig(@_);
};
property  isHidden => (
            tab             => "display",
            label           => ['886','Asset'],
            hoverHelp       => ['886 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'yesNo',
            default         => 0,
          );
property  newWindow => (
            tab             => "display",
            label           => ['940','Asset'],
            hoverHelp       => ['940 description','Asset'],
            uiLevel         => 9,
            fieldType       => 'yesNo',
            default         => 0,
          );
property  encryptPage => (
            fieldType       => 'yesNo',
            noFormPost      => sub { return $_[0]->session->config->get("sslEnabled"); },
            tab             => "security",
            label           => ['encrypt page','Asset'],
            hoverHelp       => ['encrypt page description','Asset'],
            uiLevel         => 6,
            default         => 0,
          );
property  ownerUserId => (
            tab             => "security",
            label           => ['108','Asset'],
            hoverHelp       => ['108 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'user',
            default         => '3',
            trigger         => sub { shift->_set_ownerUserId(@_) } ,
          );
sub _set_ownerUserId {
    return;
}
property  groupIdView  => (
            tab             => "security",
            label           => ['872','Asset'],
            hoverHelp       => ['872 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'group',
            default         => '7',
            trigger         => sub { shift->_set_groupIdView(@_) },
          );
sub _set_groupIdView {
    return;
}
property  groupIdEdit => (
            tab             => "security",
            label           => ['871','Asset'],
            excludeGroups   => [1,7],
            hoverHelp       => ['871 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'group',
            default         => '4',
            trigger         => sub { shift->_set_groupIdEdit(@_) } ,
          );
sub _set_groupIdEdit {
    return;
}
property  synopsis => (
            tab             => "meta",
            label           => ['412','Asset'],
            hoverHelp       => ['412 description','Asset'],
            uiLevel         => 3,
            fieldType       => 'textarea',
            default         => undef,
          );
property  extraHeadTags => (
            tab             => "meta",
            label           => ["extra head tags",'Asset'],
            hoverHelp       => ['extra head tags description','Asset'],
            uiLevel         => 5,
            fieldType       => 'codearea',
            default         => undef,
            customDrawMethod=>  'drawExtraHeadTags',
          ); 
around extraHeadTags => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        my $unpacked = $_[0];
        my $packed   = $unpacked;  ##Undo magic aliasing since a reference is passed below
        return if !defined $packed;
        HTML::Packer::minify( \$packed, {
            remove_newlines     => 1,
            do_javascript       => "shrink",
            do_stylesheet       => "minify",
            } );
        $self->extraHeadTagsPacked($packed);
    }
    $self->$orig(@_);
};
property  extraHeadTagsPacked  => (
            fieldType       => 'hidden',
            default         => undef,
            noFormPost      => 1,
            init_args       => undef,
          );
property  usePackedHeadTags => (
            tab             => "meta",
            label           => ['usePackedHeadTags label','Asset'],
            hoverHelp       => ['usePackedHeadTags description','Asset'],
            uiLevel         => 7,
            fieldType       => 'yesNo',
            default         => 0,
          );
property  isPackage => (
            label           => ["make package",'Asset'],
            tab             => "meta",
            hoverHelp       => ['make package description','Asset'],
            uiLevel         => 7,
            fieldType       => 'yesNo',
            default         => 0,
          );
property  isPrototype => (
            tab             => "meta",
            label           => ["make prototype",'Asset'],
            hoverHelp       => ['make prototype description','Asset'],
            uiLevel         => 9,
            fieldType       => 'yesNo',
            default         => 0,
          );
property  isExportable => (
            tab             => 'meta',
            label           => ['make asset exportable','Asset'],
            hoverHelp       => ['make asset exportable description','Asset'],
            uiLevel         => 9,
            fieldType       => 'yesNo',
            default         => 1,
          );
property  inheritUrlFromParent  => (
            tab             => 'meta',
            label           => ['does asset inherit URL from parent','Asset'],
            hoverHelp       => ['does asset inherit URL from parent description','Asset'],
            uiLevel         => 9,
            fieldType       => 'yesNo',
            default         => 0,
            trigger         => \&_set_inheritUrlFromParent,
          );
sub _set_inheritUrlFromParent {
    my ($self, $new, $old) = @_;
    if ($new && ($new != $old)) {
        $self->url($self->url);
    }
};
property  status => (
            noFormPost      => 1,
            fieldType       => 'text',
            default         => 'approved',
          );
property  lastModified => (
            noFormPost      => 1,
            fieldType       => 'DateTime',
            default         => sub { return time() },
          );
property  assetSize => (
            noFormPost      => 1,
            fieldType       => 'integer',
            default         => 0,
          );
property  tagId => (
            noFormPost      => 1,
            fieldType       => 'guid',
            default         => 0,
          );
property  skipNotification => (
             autoGenerate    => 0,
             noFormPost      => 1,
             fieldType       => 'yesNo',
             default         => 0,
          );

has       session => (
            is              => 'ro',
            required        => 1,
          );
has       assetId => (
            is              => 'ro',
            lazy            => 1,
            default         => sub { shift->session->id->generate() },
          );
has       revisionDate => (
            is              => 'rw',
          );
has       uiLevel => (
            is              => 'ro',
            default         => 1,
            init_arg        => undef,
          );
property  revisedBy => (
            is              => 'rw',
            noFormPost      => 1,
            fieldType       => 'guid',
          );
has       [qw/parentId     lineage
              creationDate createdBy
              state stateChanged stateChangedBy
              isLockedBy isSystem lastExportedAs/] => (
            is              => 'rw',
          );
has       className  => (
            is              => 'ro',
            builder         => '_build_className',
            lazy            => 1,
            init_arg        => undef,
          );
sub _build_className {
    my $self = shift;
    return ref $self;
}
has       keywords       => (
            is              => 'rw',
            builder         => '_build_assetKeywords',
            lazy            => 1,
            traits          => [ 'WebGUI::Definition::Meta::Settable' ],
);
sub _build_assetKeywords {
    my $self = shift;
    my $session = $self->session;
    my $keywords = WebGUI::Keyword->new($session);
    return $keywords->getKeywordsForAsset({asset => $self, });
}

around BUILDARGS => sub {
    my $orig       = shift;
    my $className  = shift;

    ##Original arguments start here.
    if (ref $_[0] eq 'HASH') {
        return $className->$orig(@_);
    }
    my $session       = shift;
    my $assetId       = shift;
    my $revisionDate  = shift;

    unless ($assetId) {
        WebGUI::Error::InvalidParam->throw(error => "Asset constructor new() requires an assetId.");
    }

    if ( $revisionDate eq '' ) {
        $revisionDate   = $className->getCurrentRevisionDate( $session, $assetId );
        if ($revisionDate eq '') {
            WebGUI::Error::InvalidParam->throw(error => "Cannot find revision date for assetId", param => $assetId);
        }
    }
    elsif ( $revisionDate =~ /[^0-9]/) {
        WebGUI::Error::InvalidParam->throw(error => "Invalid revision date given", param => $revisionDate);
    }

    my $properties = $session->cache->get("asset".$assetId.$revisionDate);
    unless (exists $properties->{assetId}) { # can we get it from cache?
        my $sql = "select * from asset";
        my $where = " where asset.assetId=?";
        my $placeHolders = [$assetId];
      
        # join all the tables
        foreach my $table ($className->meta->get_tables) {
            $sql .= ",".$table;
            $where .= " and (asset.assetId=".$table.".assetId and ".$table.".revisionDate=?)";
            push @$placeHolders, $revisionDate;
        }

        # fetch properties
        $properties = $session->db->quickHashRef($sql.$where, $placeHolders);
        unless (exists $properties->{assetId}) {
            $session->log->error("Asset $assetId $className $revisionDate is missing properties. Consult your database tables for corruption. ");
            return undef;
        }
        $session->cache->set("asset".$assetId.$revisionDate, $properties, 60*60*24);
    }

    if (defined $properties) {
        $properties->{session} = $session;
        return $className->$orig($properties);
    }
    $session->log->error("Something went wrong trying to instanciate a '$className' with assetId '$assetId', but I don't know what!");
    return undef;
};


use WebGUI::AssetBranch;
use WebGUI::AssetClipboard;
use WebGUI::AssetExportHtml;
use WebGUI::AssetLineage;
use WebGUI::AssetMetaData;
use WebGUI::AssetPackage;
use WebGUI::AssetTrash;
use WebGUI::AssetVersioning;
use WebGUI::Exception;
use strict;
use Tie::IxHash;
require WebGUI::AdminConsole;
require WebGUI::Asset::Shortcut;
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::FormBuilder;
use WebGUI::Keyword;
require WebGUI::ProgressBar;
use WebGUI::ProgressTree;
use Monkey::Patch;
use WebGUI::Fork;
use WebGUI::Search::Index;
use WebGUI::TabForm;
use WebGUI::PassiveAnalytics::Logging;
use WebGUI::Form::ButtonGroup;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

Package to manipulate items in WebGUI's asset system. 

=head1 SYNOPSIS

An asset is the basic class of content in WebGUI. This handles security, urls, and other basic information common to all content items.

The following modules are mixed in via declaration of the same package: AssetBranch.pm, AssetClipboard.pm, AssetExportHtml.pm, AssetLineage.pm, AssetMetaData.pm, AssetPackage.pm, AssetTrash.pm, AssetVersioning.pm.

A lineage is a concatenated series of sequence numbers, each six digits long, that explain an asset's position in its familiy tree. Lineage describes who the asset's ancestors are, how many ancestors the asset has in its family tree (lineage length), and the asset's position (rank) amongst its siblings. In addition, lineage provides enough information about an asset to generate a list of its siblings and descendants.

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addEditLabel ( )

Generate an internationalized label for the add/edit screens that says
whether you're adding or editing an Asset, for clarity.

=cut

sub addEditLabel {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Wobject');
	my $addEdit = ($self->session->form->process("func") eq 'add') ? $i18n->get('add') : $i18n->get('edit');
    return $addEdit.' '.$self->getName;
}

#----------------------------------------------------------------------------

=head2 addEditSaveButtons ( form )

Add the save buttons to the given form. Used by www_add and www_edit to modify
the asset edit form.

=cut

sub addEditSaveButtons {
    my ( $self, $form ) = @_;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, "Asset");

    ###
    # Buttons
    my $buttonGroup = WebGUI::Form::ButtonGroup->new( $session, 
        name => "saveButtons",
        rowClass => 'saveButtons',
    );

    # Approved status
    $buttonGroup->addButton( 'checkbox', {
        name        => 'approved',
        id          => 'approveCheckbox',
        value       => 'approved',
        label       => $i18n->get('560', 'WebGUI'),
        checked     => ( $session->setting->get( 'versionTagMode' ) eq 'autoCommit' ? 1 : 0 ),
    } );

    $buttonGroup->addButton( "submit", {
        name        => "save",
        id          => 'saveButton',
        value       => $i18n->get('save'),
    } );

    if ( $session->config->get("enableSaveAndCommit") ) {
        $buttonGroup->addButton( 'Submit', {
            name  => "saveAndCommit",
            id    => 'saveAndCommitButton',
            value => $i18n->get("save and commit"),
        } );
    }

    $buttonGroup->addButton( 'Submit', {
        name  => "saveAndReturn",
        id    => 'saveAndReturnButton',
        value => $i18n->get("apply"),
    } );

    $buttonGroup->addButton( 'Submit', {
        name    => 'cancel',
        id      => 'cancelButton',
        value   => $i18n->get('cancel','WebGUI'),
    } );

    return $form->addFieldAt( $buttonGroup, 0 );
}

#-------------------------------------------------------------------

=head2 addMissing ( url )

Displays a message to the admin that they have requested a non-existent page and give them an option to create it.

=head3 url

The missing URL.

=cut

sub addMissing {
	my $self = shift;
	my $assetUrl = shift;
	return undef unless ($self->session->isAdminOn);
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $output = $i18n->get("missing page query");
	$output .= '<ul>
			<li><a href="'.$self->getUrl("func=add;className=WebGUI::Asset::Wobject::Layout;url=".$assetUrl).'">'.$i18n->get("add the missing page").'</a></li>
			<li><a href="'.$self->getUrl.'">'.$i18n->get("493","WebGUI").'</a></li>
			</ul>';
	return $output;
}

#-------------------------------------------------------------------

=head2 canAdd ( session, [userId, groupId] )

Verifies that the user has the privileges necessary to add this type of asset and that the requested asset
can be added as a child of this asset. Return a boolean.

A class method.

=head3 session

The session variable.

=head3 userId

Unique hash identifier for a user. If not supplied, current user.

=head3 groupId

Only developers extending this method should use this parameter. By default WebGUI will check groups in this order, whichever is defined:

=over 4

=item *

Group id assigned in the config file for each asset.

=item *

Group assigned by the developer in the asset itself if s/he extended this method to do so.

=item *

The "turn admin on" group which is group id 12.

=back

=cut

sub canAdd {
    my $className = shift;

    # just in case we get called as object method
    $className = $className->get('className') if blessed $className;

    my $session = shift;
    my $userId = shift || $session->user->userId;
    my $user = WebGUI::User->new($session, $userId);
    my $subclassGroupId = shift;
    my $addPrivsGroup = $session->config->get("assets/".$className."/addGroup");
    my $groupId = $addPrivsGroup || $subclassGroupId || '12';
    my $validParent = $className->validParent($session);
    return $user->isInGroup($groupId) && $validParent;
}


#-------------------------------------------------------------------

=head2 canEdit ( [userId] )

Verifies group and user permissions to be able to edit asset. Returns 1 if owner is userId, otherwise returns the result checking if the user is a member of the group that can edit.

=head3 userId

Unique hash identifier for a user. If not supplied, current user.

=cut

sub canEdit {
    my $self = shift;
    my $userId = shift || $self->session->user->userId;
    if ($userId eq $self->get("ownerUserId")) {
        return 1;
    }
    my $user = WebGUI::User->new($self->session, $userId);
    return $user->isInGroup($self->get("groupIdEdit"));
}


#-------------------------------------------------------------------

=head2 canView ( [userId] )

Verifies group and user permissions to be able to view asset. Returns 1 if user is owner of asset. Returns 1 if within the visibility date range of the asset AND user in the View group of asset. Otherwise, returns the result of the canEdit.

Only the owner and the editors can always see the asset, regardless of time/date restrictions on the asset.

=head3 userId

Unique hash identifier for a user. If not specified, uses current userId.

=cut


sub canView {
    my $self = shift;
    my $userId = shift;
    my $user;
    if (defined $userId) {
        $user = WebGUI::User->new($self->session, $userId);
    }
    else {
        $user =  $self->session->user;
        $userId = $user->userId();
    }
    if ($userId eq $self->ownerUserId) {
        return 1;
    }
    elsif ($user->isInGroup($self->groupIdView)) {
        return 1;
    }
    return $self->canEdit($userId);
}


#-------------------------------------------------------------------

=head2 checkView ( )

Returns error messages if a user can't view due to publishing problems,
otherwise it sets the cookie and returns undef. This is sort of a hack
until we find something better.

If SSL in enabled in the config file, and the asset has encryptPage set, and
HTTPS is set and SSLPROXY is not set in the ENV, then this page is redirected
to SSL.

=cut

sub checkView {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
    my $session = $self->session;
	my ($conf, $response) = $self->session->quick(qw(config response));
    if ($conf->get("sslEnabled") && $self->get("encryptPage") && ! $self->session->request->secure) {
        # getUrl already changes url to https if 'encryptPage'
        $response->setRedirect($self->getUrl);
        $response->sendHeader;
        return "chunked";
	}
    elsif ($session->isAdminOn && $self->get("state") =~ /^trash/) { # show em trash
        my $queryFrag = "func=manageTrash";
        if ($self->session->form->process('revision')) {
            $queryFrag .= ";revision=".$self->session->form->process('revision');
        }
		$response->setRedirect($self->getUrl($queryFrag));
        $response->sendHeader;
		return "chunked";
	} 
    elsif ($session->isAdminOn && $self->get("state") =~ /^clipboard/) { # show em clipboard
        my $queryFrag = "func=manageClipboard";
        if ($self->session->form->process('revision')) {
            $queryFrag .= ";revision=".$self->session->form->process('revision');
        }
		$response->setRedirect($self->getUrl($queryFrag));
        $response->sendHeader;
		return "chunked";
	} 
    elsif ($self->get("state") ne "published") { # tell em it doesn't exist anymore
		$session->response->status(410);
		my $notFound = WebGUI::Asset->getNotFound($self->session);
		$self->session->asset($notFound);
		return $notFound->www_view;
	}
	$self->logView();
	return undef;
}

#-------------------------------------------------------------------

=head2 cloneFromDb ( )

Fetches a new fresh clone of this object from the database.  Often used after
calling commit on version tags.

Returns the new Asset object.

=cut

sub cloneFromDb {
	my $self = shift;
    return WebGUI::Asset->newById($self->session,
        $self->getId,
        $self->revisionDate
    );
}

#-------------------------------------------------------------------

=head2 extraHeadTags ( value )

Returns extraHeadTags

=head3 value

If specified, stores it, but also updates extraHeadTagsPacked with the packed version.

=cut

#-------------------------------------------------------------------

=head2 dispatch ( $fragment )

Based on the URL and query parameters in the current request, call internal methods
like www_view, www_edit, etc.  If no query parameter is present, then it returns the output
from the www_view method.  If the requested method does not exist in the object, it returns
the output from the www_view method.

=head3 $fragment

Any leftover part of the requested URL.

=cut

sub dispatch {
    my ($self, $fragment) = @_;
    return undef if $fragment;
    my $session = $self->session;
    my $state = $self->get('state');
    ##Only allow interaction with assets in certain states
    return if $state ne 'published' && $state ne 'archived' && !$session->isAdminOn;
    my $func    = $session->form->param('func') || 'view';
    my $viewing = $func eq 'view' ? 1 : 0;
    my $sub     = $self->can('www_'.$func);
    if (!$sub && $func ne 'view') {
        $sub     = $self->can('www_view');
        $viewing = 1;
    }
    return undef unless $sub;
    my $output = eval { $self->$sub(); };
    if (my $e = Exception::Class->caught('WebGUI::Error::ObjectNotFound::Template')) {
                                         #WebGUI::Error::ObjectNotFound::Template
        $session->log->error(sprintf "%s templateId: %s assetId: %s", $e->error, $e->templateId, $e->assetId);
    }
    elsif ($@) {
        my $message = $@;
        $session->log->error("Couldn't call method www_".$func." on asset for url: ".$session->url->getRequestedUrl." Root cause: ".$message);
    }
    return $output if $output || $viewing;
    ##No output, try the view method instead
    $output = eval { $self->www_view };
    if (my $e = Exception::Class->caught('WebGUI::Error::ObjectNotFound::Template')) {
        $session->log->error(sprintf "%s templateId: %s assetId: %s", $e->error, $e->templateId, $e->assetId);
        return "chunked";
    }
    elsif ($@) {
        warn "logged another warn: $@";
        my $message = $@;
        $session->log->warn("Couldn't call method www_view on asset for url: ".$session->url->getRequestedUrl." Root cause: ".$@);
        return "chunked";
    }
    return $output;
}


#-------------------------------------------------------------------

=head2 drawExtraHeadTags ( )

Draw the Extra Head Tags.  Done with a customDrawMethod because the Template
will override this.

=cut

sub drawExtraHeadTags {
	my ($self, $params) = @_;
    return WebGUI::Form::codearea($self->session, {
        name         => $params->{name},
        value        => $self->get($params->{name}),
        defaultValue => undef,
    });
}

#-------------------------------------------------------------------

=head2 fixUrl ( [value] )

Returns a URL, removing invalid characters and making it unique by
adding a digit to the end if necessary.  URLs are not allowed to be
children of the extrasURL, the uploadsURL, or any defined passthruURL.
If not URL is passed, a URL will be constructed from the Asset's
parent and the menuTitle.

Assets have a maximum length of 250 characters.  Any URL longer than
250 characters will be truncated to the initial 220 characters.

URLs will be passed through $session->url->urlize to make them WebGUI compliant.
That includes any languages specific constraints set up in the default language pack.

=head3 value

Any text string. Most likely will have been the Asset's name or title.  If the string is not passed
in, then a url will be constructed from

=cut

sub fixUrl {
	my $self = shift;
	my $url = shift;

	# build a URL from the parent
	unless ($url) {
        if (my $parent = $self->getParent) {
            $url = $parent->url;
        }
		$url =~ s/(.*)\..*/$1/;
		$url .= '/'.$self->menuTitle;
	}

    # if we're inheriting the URL from our parent, set that appropriately
    if ($self->inheritUrlFromParent) {
        # if we're inheriting the URL from our parent, set that appropriately
        my @parts = split(m{/}, $url);
        # don't do anything unless we need to
        my $inheritUrl = $self->getParent->get('url') . '/' . $parts[-1];
        $url = $inheritUrl if $url ne $inheritUrl;
    }
	$url = $self->session->url->urlize($url);

	# fix urls used by uploads and extras
	# and those beginning with http
	my @badUrls = (
        $self->session->url->make_urlmap_work($self->session->config->get("extrasURL")),
        $self->session->url->make_urlmap_work($self->session->config->get("uploadsURL")),
    );
    foreach my $badUrl (@badUrls) {
        $badUrl =~ s{ / $ }{}x; # Remove trailing slashes from the end of the URL
		if ($badUrl =~ /^http/) {
			$badUrl =~ s{ ^ http .* / } {}x; #Remove everything but the final path fragment from the badUrl
		}
        else {
			$badUrl =~ s{ ^ / }{}x; #Remove leading slashes from bare URLs
		}
		if ($url =~ /^$badUrl/) {
			$url = "_".$url;
		}
	}

	# urls can't be longer than 250 characters
	if (length($url) > 250) {
		$url = substr($url,0,220);
	}

	# remove multiple extensions from the url if there are some
    $url =~ s{
                (\.\w+)* # Strip off any number of extensions
                (?=/)    # Followed by a slash
            }{}xg;       # And delete all of them in the string

	# add automatic extension if we're supposed to
	if ($self->session->setting->get("urlExtension") ne "" #don't add an extension if one isn't set
	&&  !($url =~ /\./)                           # don't add an extension of the url already contains a dot
    &&  $url ne lc($self->getId)                  # but don't assign it the original time
	) {
		$url .= ".".$self->session->setting->get("urlExtension");
	}

    # make sure the url isn't empty after all that filtering
    if ($url eq "") {
        $url = $self->getId;
    }

	# check to see if the url already exists or not, and increment it if it does
    if ($self->urlExists($self->session, $url, {assetId=>$self->getId})) {
        my @parts = split(/\./,$url);
        if ($parts[0] =~ /(.*?)(\d+$)/) {
            $parts[0] = $1.($2+1);
        }
        else {
            $parts[0] .= "2";
        }
        $url = join(".",@parts);
        @_ = ($self, $url);
        goto $self->can('fixUrl');
    }
    return $url;
}

#-------------------------------------------------------------------

=head2 forkWithStatusPage ($args)

Kicks off a WebGUI::Fork running $method with $args (from the args hashref)
and redirects to a ProgressTree status page to show the progress. The
following arguments are required in $args:

=head3 method

The name of the WebGUI::Asset method to call

=head3 args

The arguments to pass that method (see WebGUI::Fork)

=head3 plugin

The WebGUI::Operation::Fork plugin to render (e.g. ProgressTree)

=head3 title

An key in Asset's i18n hash for the title of the rendered console page

=head3 redirect

The full url to redirect to after the fork has finished.

=cut

sub forkWithStatusPage {
    my ( $self, $args ) = @_;
    my $session = $self->session;

    my $process = WebGUI::Fork->start( $session, 'WebGUI::Asset', $args->{method}, $args->{args} );

    if ( my $groupId = $args->{groupId} ) {
        $process->setGroup($groupId);
    }

    my $method = $session->form->get('proceed') || 'manageTrash';
    my $i18n = WebGUI::International->new( $session, 'Asset' );
    my $pairs = $process->contentPairs(
        $args->{plugin}, {
            title   => $i18n->get( $args->{title} ),
            icon    => 'assets',
            dialog  => $args->{dialog},
            message => $args->{message},
            proceed => $args->{redirect} || '',
        }
    );
    $session->response->setRedirect( $self->getUrl($pairs) );
    return 'redirect';
} ## end sub forkWithStatusPage

#-------------------------------------------------------------------

=head2 getClassById ( $session, $assetId )

Class method that looks up a className for an object in the database, using it's assetId.

If a class cannot be found for the requested assetId, then it throws a WebGUI::Error::InvalidParam
exception.

=head3 $session

A WebGUI::Session object.

=head3 $assetId

The assetId of the object to lookup in the database.

=cut

sub getClassById {
	my $class   = shift;
    my $session = shift;
    my $assetId = shift;
    # Cache the className lookup
    my $assetClass  = $session->stow->get("assetClass");
    my $className   = $assetClass->{$assetId};

    return $className if $className;

    $className = $session->db->quickScalar(
            "select className from asset where assetId=?",
            [$assetId]
    );
    $assetClass->{ $assetId } = $className;
    $session->stow->set("assetClass", $assetClass);

    return $className if $className;

    WebGUI::Error::InvalidParam->throw(error => "Couldn't lookup className", param => $assetId);

}


#-------------------------------------------------------------------

=head2 getContainer ( )

Returns a reference to the container asset. If this asset is a container it returns a reference to itself. If this asset is not attached to a container it returns its parent.

=cut

sub getContainer {
	my $self = shift;
	if ($self->session->config->get("assets/".$self->get("className")."/isContainer")) {
		return $self;
	}
	else {
		return $self->getParent;
	}
}

#-------------------------------------------------------------------

=head2 getContentLastModified

Returns the overall modification time of the object and its content in Unix
epoch format, for the purpose of the Last-Modified HTTP header.  Override this
for subclasses that contain content that is not solely lastModified property,
which gets updated every time update() is called.

=cut

sub getContentLastModified {
	my $self = shift;
	return $self->get("lastModified");
}


#-------------------------------------------------------------------

=head2 getDefault ( session )

Constructor. Returns the default object, which is also known by some as the "Home Page". The default object is set in the settings.

=head3 session

A reference to the current session.

=cut

sub getDefault {
	my $class = shift;
	my $session = shift;
	return $class->newById($session, $session->setting->get("defaultPage"));
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Creates and returns a WebGUI::FormBuilder form to edit parameters of an Asset. 

=cut

sub getEditForm {
    my $self      = shift;
    my $session   = $self->session;
    my $i18n      = WebGUI::International->new( $session, "Asset" );
    my $f         = WebGUI::FormBuilder->new( $session );

    ### 
    # Create the main tabset
    # Not using loop to maintain correct order
    $f->addTab( name => "properties", label => $i18n->get("properties") );
    $f->addTab( name => "display", label => $i18n->get(105) );
    $f->addTab( name => "security", label => $i18n->get(107) );
    $f->addTab( name => "meta", label => $i18n->get("Metadata") );

    ###
    # Asset ID and class name
    my $assetId;
    my $class;
    if ( $self->getId eq "new" ) {
        $assetId = "new";
    }
    else {
        $assetId = $self->getId;
    }
    $f->getTab("meta")->addField( "Guid", 
        name        => "assetId",
        value       => $assetId,
        label       => $i18n->get( 'asset id' ),
        hoverHelp   => $i18n->get('asset id description'),
        uiLevel     => 9,
    );
    $f->getTab("meta")->addField( "ClassName", 
        name        => "className",
        value       => $self->className,
        label       => $i18n->get('class name', 'WebGUI'),
        uiLevel     => 9,
    );

    ###
    # Keywords
    $f->getTab( "meta" )->addField( 'Keywords', 
        name        => 'keywords',
        value       => $self->get('keywords'),
        label       => $i18n->get( 'keywords' ),
        hoverHelp   => $i18n->get( 'keywords help' ),
    );

    ###
    # Properties
    foreach my $property ( $self->getProperties ) {
        my $fieldHash = $self->getFieldData( $property );
        next if $fieldHash->{noFormPost};

        # Create tabs to have labels added later
        if ( !$f->getTab( $fieldHash->{tab} ) ) {
            $f->addTab( name => $fieldHash->{tab}, label => $fieldHash->{tab} );
        }

        $f->getTab( $fieldHash->{tab} )->addField( delete $fieldHash->{fieldType}, %{$fieldHash} );
    }

    ###
    # Meta data
    if ( $session->setting->get("metaDataEnabled") ) {
        my $meta = $self->getMetaDataFields();
        foreach my $field ( keys %$meta ) {
            my $fieldType = $meta->{$field}{fieldType} || "text";
            my $options = $meta->{$field}{possibleValues};

            # Add a "Select..." option on top of a select list to prevent from
            # saving the value on top of the list when no choice is made.
            if ( "\l$fieldType" eq "selectBox" ) {
                $options = "|" . $i18n->get("Select") . "\n" . $options;
            }
            my $fieldName   = "metadata_" . $meta->{$field}{fieldId};
            my $fieldData   = {
                label        => $meta->{$field}{fieldName},
                uiLevel      => 5,
                value        => $meta->{$field}{value},
                hoverHelp    => $meta->{$field}{description},
                options      => $options,
                defaultValue => $meta->{$field}{defaultValue},
            };
            $f->getTab('meta')->addField( $fieldType, %{ $fieldData } );
        } ## end foreach my $field ( keys %$meta)
    } ## end if ( $session->setting...)

    return $f;
} ## end sub getEditForm

sub setupFormField {
    my ( $self, $tabform, $fieldName, $extraFields, $overrides ) = @_;
    my %params = %{ $extraFields->{$fieldName} };
    my $tab    = delete $params{tab};

    if ( exists $overrides->{fields}{$fieldName} ) {
        my %overrideParams = %{ $overrides->{fields}{$fieldName} };
        my $overrideTab    = delete $overrideParams{tab};
        $tab = $overrideTab if defined $overrideTab;
        foreach my $key ( keys %overrideParams ) {
            $params{"-$key"} = $overrideParams{$key};
        }
    }

    $tab ||= 'properties';
    return $tabform->getTab($tab)->addField( delete $params{fieldType}, %params);
} ## end sub setupFormField

#-------------------------------------------------------------------

=head2 getEditTemplate ( )

Get the template to edit this asset. Used by www_edit and www_add to present
the form to the user. Uses getEditTemplateId to get the template ID.

=cut

sub getEditTemplate {
    my ( $self ) = @_;
    my $f           = eval { $self->getEditForm };
    if ( $@ ) {
        $self->session->log->error( 
            sprintf "Couldn't build asset edit form for URL: '%s' because: %s", $self->url, $@ 
        );
        die $@;
    }
    $self->addEditSaveButtons( $f );
    $f->action( $self->getUrl ); # Must be changed for www_add/www_addSave

    my $template    = WebGUI::Asset->newById( $self->session, $self->getEditTemplateId );
    $template->addForm( form => $f );
    $template->style( "PBtmpl0000000000000137" );

    return $template;
}

#-------------------------------------------------------------------------

=head2 getEditTemplateId

Get the edit template ID for this asset. Defaults to the Asset Edit template from
the settings

=cut

sub getEditTemplateId {
    my ( $self ) = @_;
    return $self->session->setting->get('templateIdAssetEdit');
}

#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in $self->session->style->generateAdditionalHeadTags if this asset is the current session asset.  Also called in WebGUI::Layout::view for its child assets.  Overriden in Shortcut.pm.

=cut

sub getExtraHeadTags {
	my $self = shift;
	return $self->usePackedHeadTags
            ? $self->extraHeadTagsPacked
            : $self->extraHeadTags
            ;
}

#----------------------------------------------------------------------------

=head2 getFieldData( property )

Returns the form field data for the given property name. Adds the 
overrides from the config file.

=cut

sub getFieldData {
    my ( $self, $property ) = @_;
    my $session         = $self->session;
    my $overrides       = $session->config->get( "assets/" . $self->get("className") . '/fields' ) || {};
    my $attr            = $self->meta->find_attribute_by_name( $property );
    my $fieldType       = $attr->fieldType;
    my $fieldOverrides  = $overrides->{ $property } || {};
    my $fieldHash       = {
                            fieldType   => $fieldType,
                            noFormPost  => $attr->noFormPost,
                            tab         => "properties",
                            %{ $self->getFormProperties( $property ) },
                            %{ $overrides },
                            name        => $property,
                            value       => $self->$property,
                        };

    # Kludge...
    if ( $fieldHash->{fieldType} ~~ ['selectBox', 'workflow'] and ref $fieldHash->{value} ne 'ARRAY' ) {
        $fieldHash->{value} = [ $fieldHash->{value} ];
    }

    return $fieldHash;
};

#----------------------------------------------------------------------------

=head2 getHelpers ( )

Get the AssetHelpers for this asset.

=cut

sub getHelpers {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $conf ) = $session->quick(qw{ config });
    my $i18n        = WebGUI::International->new( $session, "Asset" );

    my $default = { 
        change_url => {
            className   => 'WebGUI::AssetHelper::ChangeUrl',
            label   => $i18n->get('change url'),
        },
        copy => {
            className   => 'WebGUI::AssetHelper::Copy',
            label   => $i18n->get('Copy'),
        },
        copy_branch => {
            className   => 'WebGUI::AssetHelper::CopyBranch',
            label   => $i18n->get('copy branch'),
        },
        shortcut => {
            className   => 'WebGUI::AssetHelper::CreateShortcut',
            label   => $i18n->get( 'create shortcut' ),
        },
        duplicate => {
            className   => 'WebGUI::AssetHelper::Duplicate',
            label       => $i18n->get('duplicate'),
        },
        cut => {
            className   => 'WebGUI::AssetHelper::Cut',
            label   => $i18n->get('cut'),
        },
        edit => {
            url     => $self->getUrl( 'func=edit' ),
            label   => $i18n->get('edit'),
        },
        edit_branch => {
            className   => 'WebGUI::AssetHelper::EditBranch',
            label   => $i18n->get( 'edit branch' ),
        },
        export_html => {
            className   => 'WebGUI::AssetHelper::ExportHtml',
            label   => $i18n->get('export as html'),
        },
        view => {
            url     => $self->getUrl( 'func=view' ),
            label   => $i18n->get('view'),
        },
        lock => {
            className   => 'WebGUI::AssetHelper::Lock',
            label   => $i18n->get('lock'),
        },
        delete => {
            className   => 'WebGUI::AssetHelper::Delete',
            label       => $i18n->get('delete'),
            confirm     => $i18n->get('43'),
        },
    };

    # Merge additional helpers for this class from config
    my $confHelpers = $conf->get('assets/' . $self->className . '/helpers') || {};
    $default = { %$default, %$confHelpers };

    # Process macros in labels
    for my $helper ( values %$default ) {
        WebGUI::Macro::process( \$helper->{label} );
    }

    return $default;
}

#-------------------------------------------------------------------

=head2 getIcon ( [small] )

Returns the icon located under extras/adminConsole/assets.gif

=head3 small

If this evaluates to True, then the smaller extras/adminConsole/small/assets.gif is returned.

=cut

sub getIcon {
	my ($self, $small) = @_;
	my $icon = $self->icon;
	return $self->session->url->extras('assets/small/'.$icon) if ($small);
	return $self->session->url->extras('assets/'.$icon);
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the assetId of an Asset.

=cut


sub getId {
	my $self = shift;
	return $self->assetId;
}

#-------------------------------------------------------------------

=head2 getImportNode ( session )

Constructor. Returns the import node asset object. This is where developers will templates, files, etc to the asset tree that have no other obvious attachment point.

=head3 session

A reference to the current session.

=cut

sub getImportNode {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newById($session, "PBasset000000000000002");
}



#-------------------------------------------------------------------

=head2 getIsa ( $session, [ $offset ] )

A class method to return an iterator for getting all committed Assets by
class (and all sub-classes) as Asset objects, one at a time.  When the end
of the assets is reached, then the iterator will close the database handle
that it uses and return undef.

Assets are processed in order by revisionDate.  If the iterator cannot
instanciate an asset, it will not return undef.  Instead, it will throw
an exception.  This allows the error condition to be distinguished from the
end of the set of assets.

It should be used like this:

    my $productIterator = WebGUI::Asset::Product->getIsa($session);
    ASSET: while (1) {
        my $product = eval { $productIterator->() };
        if (my $e = Exception::Class->caught()) {
            $session->log->error($@);
            next ASSET;
        }
        last ASSET unless $product;
        ##Do something useful with $product
    }

In upgrade scripts, the eval and exception handling are best left off, because it is a good time
to make the user aware that they have broken assets in their database.

=head3 $session

A reference to a WebGUI::Session object.

=head3 $offset

An offset, from the beginning of the results returned from the query, to really begin
returning results.  This allows very large sets of results to be handled in chunks.

=head3 $options

A hashref of options to change how getIsa works.

=head4 returnAll

If set to true, then all assets will be returned, regardless of status and state.

=cut

sub getIsa {
    my $class    = shift;
    my $session  = shift;
    my $offset   = shift;
    my $options  = shift;
    my $tableName = $class->tableName;
    #Strategy, generate the correct set of assetIds
    my $sql = "select assetId from assetData as ad ";
    if ($tableName ne 'assetData') {
        $sql .= "join `$tableName` using (assetId, revisionDate) ";
    }
    $sql .= 'WHERE ';
    if (! $options->{returnAll}) {
        $sql .= q{(status='approved' OR status='archived') AND };
    }
    $sql .= q{revisionDate = (SELECT MAX(revisionDate) FROM assetData AS a WHERE a.assetId = ad.assetId) order by revisionDate };
    if (defined $offset) {
        $sql .= 'LIMIT '. $offset . ',1234567890 ';
    }
    my $sth    = $session->db->read($sql);
    return sub {
        my ($assetId, $revisionDate) = $sth->array;
        if (!$assetId) {
            $sth->finish;
            return undef;
        }
        my $asset = eval { WebGUI::Asset->newPending($session, $assetId); };
        if (!$asset) {
            WebGUI::Error::ObjectNotFound->throw(id => $assetId);
        }
        return $asset;
    };
}


#-------------------------------------------------------------------

=head2 getManagerUrl ( )

Returns the URL for the asset manager.

=cut

sub getManagerUrl {
	my $self = shift;
	return $self->getUrl( 'op=assetManager' );
}



#-------------------------------------------------------------------

=head2 getMedia ( session )

Constructor. Returns the media folder.

=head3 session

A reference to the current session.

=cut

sub getMedia {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newById($session, "PBasset000000000000003");
}


#-------------------------------------------------------------------

=head2 getMenuTitle ( )

Returns the menu title of this asset. If it's not specified or it's "Untitled" then the asset's name will be returned instead.

=cut

sub getMenuTitle {
    my $self = shift;
    my $menuTitle = $self->menuTitle;
    if ( $menuTitle eq '' || lc $menuTitle eq 'untitled' ) {
        return $self->getName;
    }
    return $menuTitle;
}


#-------------------------------------------------------------------

=head2 getName ( )

Returns the human readable name of the asset.

=cut

sub getName {
	my $self = shift;
    if ( ref $self->assetName eq 'ARRAY' ) {
        return WebGUI::International->new($self->session, 'Asset')->get(@{ $self->assetName });
    }
    else {
        return $self->assetName;
    }
}


#-------------------------------------------------------------------

=head2 getNotFound ( session )

Constructor. Returns the not found object. The not found object is set in the settings.

=head3 session

A reference to the current session.

=cut

sub getNotFound {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newById($session, $session->setting->get("notFoundPage"));
}


#-------------------------------------------------------------------

=head2 WebGUI::Asset::getPrototypeList ( session )

Returns an array of all assets that the user can view and edit that are prototypes.

=cut

sub getPrototypeList {
    my $session    = shift;
    if ( $session->isa( 'WebGUI::Asset' ) ) {
        $session    = $session->session;
    }
    my $db      = $session->db;
    my @prototypeIds = $db->buildArray("select distinct assetId from assetData where isPrototype=1");
    my $userUiLevel = $session->user->get('uiLevel');
    my @assets;
    ID: foreach my $id (@prototypeIds) {
        my $asset = WebGUI::Asset->newById($session, $id);
        next ID unless defined $asset;
        next ID unless $asset->get('isPrototype');
        next ID unless ($asset->get('status') eq 'approved' || $asset->get('tagId') eq $session->scratch->get("versionTag"));
        push @assets, $asset;
    }
    return \@assets;

}

#-------------------------------------------------------------------

=head2 getRoot ( session )

Constructor. Returns the root asset object.

=head3 session

A reference to the current session.

=cut

sub getRoot {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newById($session, "PBasset000000000000001");
}


#-------------------------------------------------------------------

=head2 getSearchUrl ( )

Returns the URL for the search screen of the asset manager.

=cut

sub getSearchUrl {
	my $self = shift;
	return $self->getUrl( 'op=assetManager;method=search' );
}



#-------------------------------------------------------------------

=head2 getSeparator

Returns a very unique string that can be used for splitting head and body apart
from the style template.  Made into a method in case it ever has to be changed
again.

=cut

sub getSeparator {
	my $self = shift;
    my $padCharacter = shift || '~';
    my $pad = $padCharacter x 3;
	return $pad.$self->getId.$pad
}

#-------------------------------------------------------------------

=head2 getTempspace ( session )

Constructor. Returns the tempspace folder.

=head3 session

A reference to the current session.

=cut

sub getTempspace {
	my $class = shift;
	my $session = shift;
	return WebGUI::Asset->newById($session, "tempspace0000000000000");
}


#-------------------------------------------------------------------

=head2 getTitle ( )

Returns the title of this asset. If it's not specified or it's "Untitled" then the asset's name will be returned instead.

=cut

sub getTitle {
	my $self = shift;
    my $title = $self->title;
	if ($title eq "" || lc($title) eq "untitled") {
		return $self->getName;
	}
	return $title;
}


#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar placeholder, which can be filled in using the toolbar.js, located
in www/extras/admin/toolbar.js

=cut

sub getToolbar {
    my $self = shift;
    return sprintf '<div class="wg-admin-toolbar yui-skin-sam" id="wg-admin-toolbar-%s"></div>', $self->getId;
}

#-------------------------------------------------------------------

=head2 getUiLevel ( )

Returns the UI Level specified in the asset definition or from the config file if it's overridden. And if neither of those is specified, then it returns 1.

=cut

sub getUiLevel {
	my $self = shift;
	my $uiLevel = shift;
	my $className = $self->get("className");
	return $uiLevel														# passed in
		|| $self->session->config->get("assets/".$className."/uiLevel")	# from config
		|| $self->uiLevel               				                # from definition
		|| 1;															# if all else fails
}


#-------------------------------------------------------------------

=head2 getUrl ( params )

Returns a URL of Asset based upon WebGUI's gateway script.

=head3 params

Name value pairs to add to the URL in the form of:

 name1=value1;name2=value2;name3=value3

=cut

sub getUrl {
	my $self = shift;
	my $params = shift;
	my $url = $self->url;
	$url = $self->session->url->gateway($url,$params);
	if ($self->encryptPage) {
		$url = $self->session->url->getSiteURL().$url;
		$url =~ s/http:/https:/;
	}
	return $url;
}

#-------------------------------------------------------------------

=head2 getViewCacheKey ( )

Returns the cache key for content generated by this Asset's view method.

=cut

sub getViewCacheKey {
	my $self = shift;
    return 'view_'.$self->assetId;
}

#-------------------------------------------------------------------

=head2 getContentLastModifiedBy ( )

Returns the userId that modified the content last.

=cut

sub getContentLastModifiedBy {
        my $self = shift;
        return $self->get("revisedBy");
}

#-------------------------------------------------------------------

=head2 getWwwCacheKey ( )

Returns a cache object specific to this asset, and whether or not the request is in SSL mode.

=cut

sub getWwwCacheKey {
    my $self     = shift;
    my $session  = $self->session;
    my $method   = shift;
    my $cacheKey = join '_', @_, $self->getId;
    if ($session->request->secure) {
        $cacheKey .= '_ssl';
    }
    return $cacheKey;
}


#-------------------------------------------------------------------

=head2 indexContent ( )

Returns an indexer object for this asset. When this method is called the asset's base content gets stored in the index. This method is often overloaded so that a particular asset can insert additional content other than the basic properties. Such uses include indexing attached files or collateral data.

=cut

sub indexContent {
	my $self = shift;
	my $indexer = WebGUI::Search::Index->create($self);
	$indexer->setIsPublic(0) if ($self->getId eq "PBasset000000000000001");
	return $indexer;
}

#-------------------------------------------------------------------

=head2 loadModule ( $className ) 

Loads an asset module if it's not already in memory. This is a class method. Returns
undef on failure to load, otherwise returns the classname.  Will only load classes
in the WebGUI::Asset namespace.

Throws a WebGUI::Invalid::Param error if a non-WebGUI::Asset class is requested to be
loaded.  If there are compilation problems, it will throw a WebGUI::Error::Compile
exception.

=cut

sub loadModule {
    my ($class, $className) = @_;
    if ($className !~ /^WebGUI::Asset(?:::\w+)*$/ ) {
        WebGUI::Error::InvalidParam->throw(param => $className, error => "Not a WebGUI::Asset class",);
    }
    (my $module = $className . '.pm') =~ s{::}{/}g;
    if (eval { require $module; 1 }) {
        return $className;
    }

    WebGUI::Error::Compile->throw(class => $className, error => $@);
    return undef;
}

#-------------------------------------------------------------------

=head2 logView ( )

Logs the view of this asset to the passive profiling mechanism.   If the asset is a Layout, it will also index
all of the children (not descendents) of the Layout.

=cut

sub logView {
	my $self = shift;
	if ($self->session->setting->get("passiveProfilingEnabled")) {
		WebGUI::PassiveProfiling::add($self->session,$self->getId);
		WebGUI::PassiveProfiling::addPage($self->session,$self->getId) if ($self->get("className") eq "WebGUI::Asset::Wobject::Layout");
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 title ( [value] )

Returns the title of the asset.

=head3 value

If specified this value will be used to set the title after it goes through some validation checking.

=cut

#-------------------------------------------------------------------

=head2 menuTitle ( [value] )

Returns the menuTitle of the asset, which is used in navigations.

=head3 value

If specified this value will be used to set the title after it goes through some validation checking.

=cut

#-------------------------------------------------------------------

=head2 new ( propertyHashRef )

Asset Constructor.  This does not create an asset in the database, or look up
properties in the database, but creates a WebGUI::Asset object.

=head3 propertyHashRef

A hash reference of properties to assign to the object.

=head2 new ( session, assetId [,revisionDate ] )

Instanciator. This does not create an asset in the database, but looks up the object's
properties in the database and returns an object with the correct WebGUI::Asset subclass.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the asset you're creating an object reference for. Must not be blank.

=head3 revisionDate

An epoch date that represents a specific version of an asset. By default the most recent version will be used.  If
no revision date is available it will return undef.

=cut

#-------------------------------------------------------------------

=head2 newById ( session, assetId [ , revisionDate ] )

Instances an existing Asset, by looking up the className of the asset specified by the assetId, and then calling new.

If a class cannot be found for the requested assetId, then it throws a
WebGUI::Error::InvalidParam exception.

=head3 session

A reference to the current session.

=head3 assetId

Must be a valid assetId.

Throws a WebGUI::Error::InvalidParam exception if the assetId is not passed.

=head3 revisionDate

An optional, specific revision date for the asset to retrieve. If not specified, the most recent one will be used.

=cut

sub newById {
    my $requestedClass  = shift;
    my $session         = shift;
    my $assetId         = shift;
    if (!$assetId) {
        WebGUI::Error::InvalidParam->throw(error => 'newById must get an assetId');
    }
    my $revisionDate    = shift;

    my $className = WebGUI::Asset->getClassById($session, $assetId);
    my $class     = WebGUI::Asset->loadModule($className);

    return $class->new($session, $assetId, $revisionDate);
}


#-------------------------------------------------------------------

=head2 newByPropertyHashRef ( session,  properties )

Constructor.  This is a class method.  It creates a standalone asset with no parent, with a
varying class, determined by the className entry in the properties hash ref.

The object created is not persisted to the database.

=head3 session

A reference to the current session.

=head3 properties

A hash reference of Asset properties.

=cut

sub newByPropertyHashRef {
    my $class      = shift;
    my $session    = shift;
    my $properties = shift || {};
    $properties->{className} //= $class;
    $properties->{session}     = $session;
    my $className = $class->loadModule($properties->{className});
    return undef unless (defined $className);
    my $object = $className->new($properties);
    return $object;
}

#-------------------------------------------------------------------

=head2 newByUrl ( session, [url, revisionDate] )

Instances an existing Asset, by looking up the classname of the asset specified by the url, and then calling new.
Returns undef if it can't find a classname with that url.  If no URL is specified, and the requested url cannot
be found, it returns the default asset.

=head3 session

A reference to the current session.

=head3 url

Optional string representing a URL.

=head3 revisionDate

A specific revision to instanciate. By default we instanciate the newest published revision.

=cut

sub newByUrl {
	my $class        = shift;
	my $session      = shift;
	my $url          = shift || $session->url->getRequestedUrl;
	my $revisionDate = shift;
	$url =  lc($url);
	$url =~ s/\/$//;
	$url =~ s/^\///;
    $url =~ tr/'"//d;
	if ($url ne "") {
		my ($id) = $session->db->quickArray("select assetId from assetData where url = ? limit 1", [ $url ]);
        if (!$id) {
            WebGUI::Error::ObjectNotFound->throw(error => "The URL was requested, but does not exist in your asset tree.", id => $url);
        }
        return WebGUI::Asset->newById($session, $id, $revisionDate);
	}
	return WebGUI::Asset->getDefault($session);
}

#-------------------------------------------------------------------

=head2 newPending ( session, assetId )

Instances an existing Asset by assetId, ignoring the status and always selecting the most recent revision.

=head3 session

A reference to the current session.

=head3 assetId

The asset's id.  If an assetId is not passed, throws a WebGUI::Error::InvalidParam exception.  If
a revision cannot be found for the requested assetId, then it throws a WebGUI::Error::InvalidParam
exception.

=cut

sub newPending {
    my $class   = shift;
    my $session = shift;
    my $assetId = shift;
    if (!$assetId) {
        WebGUI::Error::InvalidParam->throw(error => 'newPending must get an assetId');
    }
    my $revisionDate = $session->db->quickScalar("SELECT revisionDate FROM assetData WHERE assetId = ? ORDER BY revisionDate DESC LIMIT 1", [ $assetId ]);
    if ($revisionDate ne "") {
        return WebGUI::Asset->newById($session, $assetId, $revisionDate);
    }
    else {
        WebGUI::Error::InvalidParam->throw(error => "Couldn't lookup revisionDate", param => $assetId);
    }
}

#-------------------------------------------------------------------

=head2 outputWidgetMarkup ( width, height, templateId, [styleTemplateId] )

Output the markup required for the widget view. Includes markup to handle the
widget macro in the iframe holding the widgetized asset. This does the following: 

=over 4

=item *

retrieves the content for this asset using its L</view> method

=item *

processes macros in that content

=item *

serializes the processed content in JSON

=item *

writes the JSON to a storage location

=item *

refers the user to download this JSON

=item *

references the appropriate JS files for the templating engine and the widget macro

=item *

invokes the templating engine on this JSON

=back

=head3 width

The width of the iframe. Required for making widget-in-widget function properly.

=head3 height

The height of the iframe. Required for making widget-in-widget function properly.

=head3 templateId

The templateId for this widgetized asset to use. Required for making
widget-in-widget function properly.

=head3 styleTemplateId

The style templateId for this widgetized asset to use. Not required for making
widget-in-widget function properly.

=cut

sub outputWidgetMarkup {
    # get our parameters.
    my $self                = shift;
    my $width               = shift;
    my $height              = shift;
    my $templateId          = shift;
    my $styleTemplateId     = shift;

    # construct / retrieve the values we'll use later.
    my $session         = $self->session;
    my $assetId         = $self->getId;
    my $hexId           = $session->id->toHex($assetId);
    my $conf            = $session->config;
    my $extras          = $session->url->make_urlmap_work($conf->get('extrasURL'));

    # the widgetized version of content that has the widget macro in it is
    # executing in an iframe. this iframe doesn't have a style object.
    # therefore, the macro won't be able to output the stylesheet and JS
    # information it needs to do its work. because of this, we need to output
    # that content manually. construct the filesystem paths for those files.
    my $containerCss    = $extras . '/yui/build/container/assets/container.css';
    my $containerJs     = $extras . '/yui/build/container/container-min.js';
    my $yahooDomJs      = $extras . '/yui/build/yahoo-dom-event/yahoo-dom-event.js';
    my $wgWidgetJs      = $extras . '/wgwidget.js';
    my $ttJs            = $extras . '/tt.js';
    
    # the templating engine requires its source data to be in json format.
    # write this out to disk and then serve the URL to the user. in this case,
    # we'll be serializing the content of the asset which is being widgetized. 
    my $storage         = WebGUI::Storage->get($session, $assetId);
    my $content         = $self->view;
    if($styleTemplateId ne '' && $styleTemplateId ne 'none'){
        $content = $self->session->style->process($content,$styleTemplateId); 
    }
    WebGUI::Macro::process($session, \$content);
    my ($headTags, $body) = WebGUI::HTML::splitHeadBody($content);
    $body = $content;
    my $jsonContent     = to_json( { "asset$hexId" => { content => $body } } );
    $storage->addFileFromScalar("$assetId.js", "data = $jsonContent");
    my $jsonUrl         = $storage->getUrl("$assetId.js");

    # WebGUI.widgetBox.initButton() needs the full URL of the asset being
    # widgetized, and also the full URL of the JS file that does most of the
    # work.
    my $fullUrl         = "http://" . $conf->get("sitename")->[0] . $self->getUrl;
    my $wgWidgetPath    = 'http://' . $conf->get('sitename')->[0] . $extras . '/wgwidget.js';

    # finally, given all of the above, construct our output. WebGUI outputs
    # fully valid XHTML 1.0 Strict, and there's no reason this should be any
    # different.
    my $output          = <<OUTPUT;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title></title>
        <link rel="stylesheet" type="text/css" href="$containerCss" />
        <script type="text/javascript" src="$jsonUrl"></script>
        <script type="text/javascript" src="$ttJs"></script>
        <script type='text/javascript' src='$yahooDomJs'></script>
        <script type='text/javascript' src='$containerJs'></script>
        <script type='text/javascript' src='$wgWidgetJs'></script>
        <script type='text/javascript'>
            function setupPage() {
                WebGUI.widgetBox.doTemplate('widget$hexId'); WebGUI.widgetBox.retargetLinksAndForms();
                WebGUI.widgetBox.initButton( { 'wgWidgetPath' : '$wgWidgetPath', 'fullUrl' : '$fullUrl', 'assetId' : '$assetId', 'width' : $width, 'height' : $height, 'templateId' : '$templateId' } );
            }
            YAHOO.util.Event.addListener(window, 'load', setupPage);
        </script>
        $headTags
    </head>
    <body id="widget$hexId">
        \${asset$hexId.content}
    </body>
</html>
OUTPUT
    return $output;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

Executes what is necessary to make the view() method work with content chunking.

=cut

sub prepareView {
	my $self = shift;
    ##Make the toolbar now and stick it in the cache.
    $self->getToolbar;
    my $style = $self->session->style;
    my @keywords = @{WebGUI::Keyword->new($self->session)->getKeywordsForAsset({asset=>$self, asArrayRef=>1})};
    if (scalar @keywords) {
        $style->setMeta({
            name    => 'keywords',
            content => join(',', @keywords),
        }); 
    }
    $style->setRawHeadTags($self->getExtraHeadTags);
}

#-------------------------------------------------------------------

=head2 prepareWidgetView ( )

Prepares the widget view for this asset. Specifically, sets up some JS to
ensure that links selected / forms submitted in the widgetized form of the
asset open in a new window.

=cut

sub prepareWidgetView {
    my $self            = shift;
    my $templateId      = shift;
    my $template        = WebGUI::Asset::Template->newById($self->session, $templateId);
    my $extras          = $self->session->url->make_urlmap_work($self->session->config->get('extrasURL'));

    $template->prepare;

    $self->{_viewTemplate} = $template;
}

#----------------------------------------------------------------------------

=head2 proceed ( [method] )

Redirect from a form submit based on the given method. By default, checks the "proceed"
form parameter.

Proceed types:

 manageAssets       - Go to the asset manager
 viewParent         - Go to the parent asset
 editParent         - Go to the parent asset edit form
 goBackToPage       - Go to the page specified in the "returnUrl" form param
 *                  - Go to www_* method
 <default>          - Go to the www_view method

=cut

sub proceed {
    my ( $self, $proceed ) = @_;
    my $session = $self->session;

    $proceed ||= $session->form->process('proceed');
    if ($proceed eq "manageAssets") {
        $session->asset($self->getParent);
        return $session->asset->www_manageAssets;
    }
    elsif ($proceed eq "viewParent") {
        $session->response->setRedirect( $self->getParent->getUrl );
        return "redirect";
    }
    elsif ($proceed eq "editParent") {
        $session->response->setRedirect( $self->getParent->getUrl('func=edit') );
        return "redirect";
    }
    elsif ($proceed eq "goBackToPage" && $session->form->process('returnUrl')) {
        $session->response->setRedirect($session->form->process("returnUrl"));
        return "redirect";
    }
    elsif ($proceed ne "") {
        $session->response->setRedirect( $self->getUrl( 'func=' . $proceed ) );
        return "redirect";
    }

    $session->response->setRedirect( $self->getUrl );
    return "redirect";
}

#-------------------------------------------------------------------

=head2 processEditForm ( )

Updates current Asset with data from Form. You can feed back errors by returning an
arrayref containing the error messages. If there is no error you do not have to return
anything.

=cut

sub processEditForm {
    my $self = shift;
    my %data;
    my $form      = $self->session->form;
    my $overrides = $self->session->config->get( "assets/" . $self->get("className") . "/fields" );

    foreach my $property ( $self->getProperties ) {
        next if $self->meta->find_attribute_by_name( $property )->noFormPost;

        my $fieldType      = $self->meta->find_attribute_by_name($property)->fieldType;
        my $fieldOverrides = $overrides->{$property} || {};
        my $fieldHash      = {
            tab => "properties",
            %{ $self->getFormProperties($property) },
            %{$overrides},
            name  => $property,
            value => $self->$property,
        };


        # process the form element
        $data{$property} = $form->process( $property, $fieldType, $fieldHash->{defaultValue}, $fieldHash );
    } ## end foreach my $property ( $self...)

    $data{keywords} = $form->process("keywords");
    if ( $self->session->setting->get("metaDataEnabled") ) {
        my $meta = $self->getMetaDataFields;
        foreach my $field ( keys %{$meta} ) {
            my $value
                = $form->process( "metadata_" . $field, $meta->{$field}{fieldType}, $meta->{$field}{defaultValue} );
            $self->updateMetaData( $field, $value );
        }
    }

    $self->session->db->beginTransaction;
    $self->update( \%data );
    $self->session->db->commit;
    return undef;
} ## end sub processEditForm


#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId, template )

Returns the content generated from this template.  It adds the Asset control
bar to the template variables, as well as all Asset properties and metadata.

=head3 vars

A hash reference containing variables and loops to pass to the template engine.

=head3 templateId

An id referring to a particular template in the templates table.

=head3 template

Instead of passing in a templateId, you may pass in a template object.

=cut

sub processTemplate {
    my $self = shift;
    my $var = shift;
    my $templateId = shift;
    my $template = shift;
    my $session  = $self->session;

    # Sanity checks
    if (ref $var ne "HASH") {
        $session->log->error("First argument to processTemplate() should be a hash reference.");
        return "Error: Can't process template for asset ".$self->getId." of type ".$self->get("className");
    }
    if (!defined $template) {
        $template = eval { WebGUI::Asset->newById($session, $templateId) };
    }
    if (! Exception::Class->caught() ) {
        $var = { %{ $var }, %{ $self->getMetaDataAsTemplateVariables } };
        $var->{'controls'}   = $self->getToolbar if $session->isAdminOn;
        $var->{'assetIdHex'} = $session->id->toHex($self->getId);
        my %vars = (
            %{$self->get},
            'title'     => $self->getTitle,
            'menuTitle' => $self->getMenuTitle,
            %{$var},
        );
        return $template->process(\%vars);
    }
    else {
        $session->log->error("Can't instantiate template $templateId for asset ".$self->getId);
        my $i18n = WebGUI::International->new($self->session, 'Asset');
        return $i18n->get('Error: Cannot instantiate template').' '.$templateId;
    }
}

#-------------------------------------------------------------------

=head2 processStyle ( $output, $noHeadTags )

Returns the output wrappered in a style. Should be overridden by subclasses, because
this one actually doesn't do anything other than return the html back to you and
adds the Asset's extraHeadTags into the raw head tags.

=head3 $output

The content to wrap up.

=head3 $options

Options that alter how the method behaves.

=head4 noHeadTags

If this options is true, then this method will not set the extraHeadTags

=cut

sub processStyle {
	my ($self, $output, $options) = @_;
    my $style   = $self->session->style;
    $style->setRawHeadTags($self->getExtraHeadTags) unless $options->{noHeadTags};
    if ($self->get('synopsis')) {
        $style->setMeta({
            name    => 'Description',
            content => $self->get('synopsis'),
        });
    }
	return $output;
}

#-------------------------------------------------------------------

=head2 publish ( arrayref )

Sets an asset and it's descendants to a state of 'published' regardless of it's current state by default.
Otherwise sets state to published only for assets matching one of the states passed in.

=head3 arrayref

[ 'clipboard', 'clipboard-limbo', 'trash', 'trash-limbo', 'published' ]

=cut

sub publish {
	my $self = shift;
	my $statesToPublish = shift;
	
	my $stateList = $self->session->db->quoteAndJoin($statesToPublish);
	my $where = ($statesToPublish) ? "and state in (".$stateList.")" : "";
	
	my $assetIds = $self->session->db->buildArrayRef("select assetId from asset where lineage like ".$self->session->db->quote($self->lineage.'%')." $where");
        my $idList = $self->session->db->quoteAndJoin($assetIds);
        
	$self->session->db->write("update asset set state='published', stateChangedBy=".$self->session->db->quote($self->session->user->userId).", stateChanged=".time()." where assetId in (".$idList.")");
        foreach my $id (@{$assetIds}) {
                my $asset = WebGUI::Asset->newPending($self->session, $id);
                if (defined $asset) {
                    $asset->purgeCache;
                }
        }
	$self->state("published");

    # Also publish any shortcuts to this asset that are in the trash
    my $shortcuts 
        = WebGUI::Asset::Shortcut->getShortcutsForAssetId($self->session, $self->getId, { 
            returnObjects   => 1,
            statesToInclude => ['trash','trash-limbo'],
        });
    for my $shortcut ( @$shortcuts ) {
        $shortcut->publish;
    }
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

Purges all cache entries associated with this asset, CHI, Session->stow and object caches

=cut

sub purgeCache {
	my $self = shift;
	my $stow = $self->session->stow;
	$stow->delete('assetLineage');
	$stow->delete('assetClass');
	$stow->delete('assetRevision');
    $self->session->cache->remove("asset".$self->getId.$self->revisionDate);
    $self->{_parent};
}


#-------------------------------------------------------------------

=head2 refused ( )

Returns an error message to the user, wrapped in the user's style.  This is most useful for
handling UI errors.  Privilege errors should be still be sent to $session->privilege.

=cut

sub refused {
	my ($self) = @_;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 setSize ( [extra] )

Updates the asset table with the size of the Asset.

=head3 extra

Optional numeric value to adjust the calculated asset size.

=cut

sub setSize {
	my $self = shift;
	my $extra = shift;
	my $sizetest;
	foreach my $key (keys %{$self->get}) {
		$sizetest .= $self->get($key);
	}
    my $size = length($sizetest) + $extra;
	$self->session->db->write("update assetData set assetSize=? where assetId=? and revisionDate=?",[$size, $self->getId, $self->revisionDate]);
	$self->purgeCache;
    $self->assetSize($size);
}
	
#-------------------------------------------------------------------

=head2 setState ( $state )

Updates the asset table with the new state of the asset.

=cut

sub setState {
    my ($self, $state) = @_;
    my $sql = q{
        UPDATE asset
        SET    state          = ?,
               stateChangedBy = ?,
               stateChanged   = ?
        WHERE  assetId = ?
    };
    my @props = ($state, $self->session->user->userId, time);
    $self->session->db->write(
        $sql, [
            @props,
            $self->getId,
        ]
    );
    $self->state($state);
    $self->stateChangedBy($props[1]);
    $self->stateChanged($props[2]);
    $self->purgeCache;
}

#-------------------------------------------------------------------

=head2 write ( )

Stores the current properties of the asset in the database.

=cut

sub write {
	my $self = shift;
    $self->lastModified(time());
	
    my $db = $self->session->db;
    my %data_by_table = ();
    
    PROPERTY: foreach my $property_name ($self->meta->get_all_property_list) {
        my $property  = $self->meta->find_attribute_by_name($property_name);
        my $tableName = $property->tableName;
        my $value     = $self->$property_name;
        if ($property->does('WebGUI::Definition::Meta::Property::Serialize')) {
            $value    = eval { JSON::to_json($value); } || '';
        }
        push @{ $data_by_table{$tableName}->{NAMES}  }, $property_name;
        push @{ $data_by_table{$tableName}->{VALUES} }, $value;
    }
    CLASS: foreach my $tableName (keys %data_by_table) {
        my $table       = $db->quoteIdentifier($tableName);
        my @values      = @{ $data_by_table{$tableName}->{VALUES} };
        my @columnNames = map { $db->quoteIdentifier($_).'=?' } @{ $data_by_table{$tableName}->{NAMES}};
        push @values, $self->getId, $self->revisionDate;
        $db->write("update ".$table." set ".join(",",@columnNames)." where assetId=? and revisionDate=?",\@values);
    }

    # update the asset's size, which also purges the cache.
    $self->setSize();
    WebGUI::Keyword->new($self->session)->setKeywordsForAsset({ asset => $self, keywords => $self->keywords });

    $self->purgeCache;
}

#-------------------------------------------------------------------

=head2 url ( [ value ] ) 

Returns the asset's url without any site specific prefixes. If you want a browser friendly url see the getUrl() method.

=head3 value

The new value to set the URL to.

=cut

#-------------------------------------------------------------------

=head2 urlExists ( session, url [, options] )

Returns true if the asset URL is used within the system. This is a class method.

=head3 session

A reference to the current session.

head3 url

The asset url you'd like to check for.

head3 options

A hash reference of optional parameters that can be passed to refine the search.

head4 assetId

Excludes an asset, by assetId, for the search for the existance of the url.

=cut

sub urlExists {
	my $class = shift;
	my $session = shift;
	my $url = lc(shift);
	my $options = shift || {};
	my $limit = "";
    my $placeholders = [ $url ];
	if (exists $options->{assetId}) {
		$limit = "and assetId<>?";
        push @{ $placeholders }, $options->{assetId};
	}
	my ($test) = $session->db->quickArray("select count(url) from assetData where url=? $limit", $placeholders);
	return $test;
}


#-------------------------------------------------------------------

=head2 valid_parent_classes ( )

Returns an arrayref of classes that this asset is allowed to be a child of. If
a candidate parent passes ->isa for any of these it is a valid parent.

=cut

sub valid_parent_classes {
    return [qw/WebGUI::Asset/];
}

#-------------------------------------------------------------------

=head2 view ( )

The default view method for any asset that doesn't define one. Under all normal circumstances this should be overridden or your asset won't have any output.

=cut

sub view {
	my $self = shift;
	if ($self->session->isAdminOn) {
		return $self->getToolbar.' '.$self->getTitle;
	} else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 www_add ( )

Show the form to add a new child asset.

=cut

sub www_add {
    my $self = shift;
    my $session = $self->session;
    my ( $style, $url ) = $session->quick(qw( style url ));
	my %prototypeProperties;
    my $class = $self->loadModule($self->session->form->process("className","className"));
    return undef unless (defined $class);
	return $self->session->privilege->insufficient() unless ($class->canAdd($self->session));
	if ($self->session->form->process('prototype')) {
		my $prototype = WebGUI::Asset->newById($self->session, $self->session->form->process("prototype"));
		foreach my $property ($prototype->getProperties) { # cycle through rather than copying properties to avoid grabbing stuff we shouldn't grab
            my $definition = $prototype->getProperty($property);
			next if ( $property ~~ [qw(title menuTitle url isPrototype isPackage)]);
			next if ($definition->{noFormPost});
			$prototypeProperties{$property} = $prototype->get($property);
		}
	}
	my %properties = (
		%prototypeProperties,
		parentId => $self->getId,
		groupIdView => $self->get("groupIdView"),
		groupIdEdit => $self->get("groupIdEdit"),
		ownerUserId => $self->get("ownerUserId"),
		encryptPage => $self->get("encryptPage"),
		styleTemplateId => $self->get("styleTemplateId"),
		printableStyleTemplateId => $self->get("printableStyleTemplateId"),
		isHidden => $self->get("isHidden"),
		className=>$class,
		assetId=>"new",
		url=>scalar($self->session->form->param("url")),
		);
	$properties{isHidden} = 1 unless $self->session->config->get("assets/".$class."/isContainer");
	my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
	$newAsset->{_parent} = $self;

    my $template   = eval { $newAsset->getEditTemplate };
    return $@ if $@;
    $template->getForm("form")->action( $self->getUrl );
    $template->getForm("form")->addField( "Hidden", name => "func", value => "addSave" );
    return $template;
}

#----------------------------------------------------------------------------

=head2 www_addSave

Process the add form, creating the new asset.

=cut

sub www_addSave {
    my $self    = shift;
    my $session = $self->session;
    my ( $form ) = $session->quick(qw{ form });

    return $session->privilege->insufficient() unless $self->canEdit;
    if ($self->session->config->get("maximumAssets")) {
        my ($count) = $self->session->db->quickArray("select count(*) from asset");
        my $i18n = WebGUI::International->new($self->session, "Asset");
        return $self->session->style->userStyle($i18n->get("over max assets")) if ($self->session->config->get("maximumAssets") <= $count);
    }

    # Determine what version tag we should use
    my $autoCommitId  = $self->getAutoCommitWorkflowId();

    my ($workingTag, $oldWorking);
    if ( $autoCommitId ) {
        $workingTag
            = WebGUI::VersionTag->create( $session, { 
                groupToUse  => '12',            # Turn Admin On (for lack of something better)
                workflowId  => $autoCommitId,
            } ); 
    }
    else {
        my $parentAsset;
        if ( not defined( $parentAsset = $self->getParent ) ) {
            $parentAsset = WebGUI::Asset->newPending( $session, $self->parentId );
        }
        if ( $parentAsset->hasBeenCommitted ) {
            $workingTag = WebGUI::VersionTag->getWorking( $session );
        }
        else {
            $oldWorking = WebGUI::VersionTag->getWorking($session, 'noCreate');
            $workingTag = WebGUI::VersionTag->new( $session, $parentAsset->tagId );
            $workingTag->setWorking();
        }
    }

    # Add the new asset
    my $object;
    my $className   = $form->process('className','className') || $form->process('class','className');
    $object = $self->addChild({
        className   => $className,
        revisedBy   => $session->user->userId,
        tagId       => $workingTag->getId,
        status      => "pending",
    });
    if ( !defined $object ) {
        my $url = $session->url->page;
        $session->log->error( "Could not add child $className to $url!" );
        return $self->www_view;
    }
    $object->{_parent} = $self;
    $object->url(undef);

    # More version tag stuff
    $object->setVersionLock;
    $object->setAutoCommitTag($workingTag) if (defined $autoCommitId);
    $oldWorking->setWorking if $oldWorking;

    # Process properties from form post
    my $errors = $object->processEditForm;
    if (ref $errors eq 'ARRAY') {
        my $url = $session->url->page;
        $session->log->error( "Cannot add asset $className to $url: '" . join( "', '", @$errors ) . q{'} );
        $session->stow->set('editFormErrors', $errors);
        $object->purge;
        return $self->www_add();
    }

    $object->updateHistory("added");

    # we handle auto commit assets here in case they didn't handle it themselves
    if ($object->getAutoCommitWorkflowId) {
        $object->requestAutoCommit;
        #Since the version tag makes new objects, fetch a fresh one here.
        $object = $object->cloneFromDb;
    }
    # else, try to to auto commit
    else {
        my $commitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
            override        => scalar $session->form->process('saveAndCommit'),
            allowComments   => 1,
            returnUrl       => $self->getUrl,
        });
        if ($commitStatus eq 'redirect') {
            ##Redirect set by tag.  Return nothing to send the user over to the redirect.
            return undef;
        }
        elsif ($commitStatus eq 'commit') {
            ##Commit was successful.  Update the local object cache so that it will no longer
            ##register as locked.
            $object = $object->cloneFromDb;
        }
    }

    # Handle "saveAndReturn" button
    if ( $session->form->process( "saveAndReturn" ) ne "" ) {
        return $object->www_edit;
    }

    # Handle "proceed" form parameter
    return $object->proceed;
}

#-------------------------------------------------------------------

=head2 www_ajaxInlineView ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_ajaxInlineView {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	$self->prepareView;
	return $self->view;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Renders an AdminConsole EditForm, unless canEdit returns False.

=cut

sub www_edit {
    my $self = shift;
    my $session = $self->session;
    my ( $style, $url ) = $session->quick(qw( style url ));
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;

    my $template    = $self->getEditTemplate;
    $template->getForm('form')->addField( "Hidden", name => "func", value => "editSave" );

    return $template;
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Save a new revision of this asset.

=cut

sub www_editSave {
    my $self    = shift;
    my $session = $self->session;
    my ( $form ) = $session->quick(qw{ form });

    ##If this is a new asset (www_add), the parent may be locked.  We should still be able to add a new asset.
    return $session->privilege->locked() unless $self->canEditIfLocked;
    return $session->privilege->insufficient() unless $self->canEdit;

    # Determine what version tag we should use
    my $autoCommitId  = $self->getAutoCommitWorkflowId();

    my ($workingTag, $oldWorking);
    if ( $autoCommitId ) {
        $workingTag
            = WebGUI::VersionTag->create( $session, { 
                groupToUse  => '12',            # Turn Admin On (for lack of something better)
                workflowId  => $autoCommitId,
            } ); 
    }
    else {
        my $parentAsset;
        if ( not defined( $parentAsset = $self->getParent ) ) {
            $parentAsset = WebGUI::Asset->newPending( $session, $self->parentId );
        }
        if ( $parentAsset->hasBeenCommitted ) {
            $workingTag = WebGUI::VersionTag->getWorking( $session );
        }
        else {
            $oldWorking = WebGUI::VersionTag->getWorking($session, 'noCreate');
            $workingTag = WebGUI::VersionTag->new( $session, $parentAsset->tagId );
            $workingTag->setWorking();
        }
    }

    # Add the new revision
    my $object = $self->addRevision({
        revisedBy   => $session->user->userId,
        tagId       => $workingTag->getId,
        status      => "pending",
    });

    # More version tag stuff
    $object->setVersionLock;
    $object->setAutoCommitTag($workingTag) if (defined $autoCommitId);
    $oldWorking->setWorking if $oldWorking;

    # Process properties from form post
    my $errors = $object->processEditForm;
    if (ref $errors eq 'ARRAY') {
        $session->stow->set('editFormErrors', $errors);
        $object->purgeRevision;
        return $self->www_edit();
    }

    $object->updateHistory("edited");

    # we handle auto commit assets here in case they didn't handle it themselves
    if ($object->getAutoCommitWorkflowId) {
        $object->requestAutoCommit;
        #Since the version tag makes new objects, fetch a fresh one here.
        $object = $object->cloneFromDb;
    }
    # else, try to to auto commit
    else {
        my $commitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
            override        => scalar $session->form->process('saveAndCommit'),
            allowComments   => 1,
            returnUrl       => $self->getUrl,
        });
        if ($commitStatus eq 'redirect') {
            ##Redirect set by tag.  Return nothing to send the user over to the redirect.
            return 'redirect';
        }
        elsif ($commitStatus eq 'commit') {
            ##Commit was successful.  Update the local object cache so that it will no longer
            ##register as locked.
            $object = $object->cloneFromDb;
        }
    }

    # Handle "saveAndReturn" button
    if ( $session->form->process( "saveAndReturn" ) ne "" ) {
        return $object->www_edit;
    }

    # Handle "proceed" form parameter
    return $self->proceed;
}

#-------------------------------------------------------------------

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
    
    # don't allow viewing of the root asset
	if ($self->getId eq "PBasset000000000000001") {
		$self->session->response->setRedirect($self->getDefault($self->session)->getUrl);
		return undef;
	}

    # check view privs
	my $check = $self->checkView;
	return $check if (defined $check);

    # if all else fails 
    $self->prepareView;
	$self->session->output->print($self->view);
	return undef;
}

#-------------------------------------------------------------------

=head2 www_widgetView ( )

Returns the view() method of the asset object suitable for widgetizing.

=cut

sub www_widgetView {
    my $self    = shift;
    my $session = $self->session;
    my $style   = $session->style;

    return $session->privilege->noAccess() unless $self->canView;

    my $templateId      = $session->form->process('templateId');
    my $width           = $session->form->process('width');
    my $height          = $session->form->process('height');
    my $styleTemplateId = $session->form->process('styleTemplateId');

    if($templateId eq 'none') {
        $self->prepareView;
    }
    else {
        $self->prepareWidgetView($templateId);
    }
        return $self->outputWidgetMarkup($width, $height, $templateId, $styleTemplateId);
}

__PACKAGE__->meta->make_immutable;
1;
