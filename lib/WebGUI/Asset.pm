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

use Carp;
use Scalar::Util qw( blessed );
use Clone qw(clone);
use JSON;
use HTML::Packer;

use WebGUI::Definition::Asset;
attribute assetName  => 'asset';
attribute tableName  => 'assetData';
attribute icon       => 'assets.gif';
attribute uiLevel    => 1;
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
        $title    = $self->meta->get_attribute('title')->default if $title eq '';
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
    return $_[0]->assetId;
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
          );
property  groupIdView  => (
            tab             => "security",
            label           => ['872','Asset'],
            hoverHelp       => ['872 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'group',
            default         => '7',
          );
property  groupIdEdit => (
            tab             => "security",
            label           => ['871','Asset'],
            excludeGroups   => [1,7],
            hoverHelp       => ['871 description','Asset'],
            uiLevel         => 6,
            fieldType       => 'group',
            default         => '4',
          );
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
    if (@_ > 1) {
        my $unpacked = $_[0];
        my $packed   = $unpacked;  ##Undo magic aliasing since a reference is passed below
        HTML::Packer::minify( \$packed, {
            remove_comments     => 1,
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
          );
around inheritUrlFromParent => sub {
    my $orig = shift;
    my $self = shift;
    $self->$orig(@_);
    if (@_ > 0 && $_[0]) {
        $self->url($self->url);
    }
};
property  status => (
            noFormPost      => 1,
            fieldType       => 'text',
            default         => 'pending',
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
has       [qw/parentId     lineage
              creationDate createdBy
              state stateChanged stateChangedBy
              isLockedBy isSystem lastExportedAs/] => (
            is              => 'rw',
          );
has       className  => (
            is              => 'ro',
            builder         => '_build_className',
            init_arg        => undef,
          );
sub _build_className {
    my $self = shift;
    return ref $self;
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

    my $properties = eval{$session->cache->get(["asset",$assetId,$revisionDate])};
    unless (exists $properties->{assetId}) { # can we get it from cache?
        my $sql = "select * from asset";
        my $where = " where asset.assetId=?";
        my $placeHolders = [$assetId];
      
        # join all the tables
        foreach my $table ($className->meta->get_tables) {
            $sql .= ",".$table;
            $where .= " and (asset.assetId=".$table.".assetId and ".$table.".revisionDate=".$revisionDate.")";
        }

        # fetch properties
        $properties = $session->db->quickHashRef($sql.$where, $placeHolders);
        unless (exists $properties->{assetId}) {
            $session->errorHandler->error("Asset $assetId $className $revisionDate is missing properties. Consult your database tables for corruption. ");
            return undef;
        }
        eval{ $session->cache->set(["asset",$assetId,$revisionDate], $properties, 60*60*24) };
    }

    if (defined $properties) {
        $properties->{session} = $session;
        return $className->$orig($properties);
    }	
    $session->errorHandler->error("Something went wrong trying to instanciate a '$className' with assetId '$assetId', but I don't know what!");
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
use WebGUI::AdminConsole;
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Keyword;
use WebGUI::ProgressBar;
use WebGUI::Search::Index;
use WebGUI::TabForm;
use WebGUI::Utility;

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

#-------------------------------------------------------------------

=head2 addMissing ( url )

Displays a message to the admin that they have requested a non-existent page and give them an option to create it.

=head3 url

The missing URL.

=cut

sub addMissing {
	my $self = shift;
	my $assetUrl = shift;
	return undef unless ($self->session->var->isAdminOn);
	my $ac = $self->getAdminConsole;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $output = $i18n->get("missing page query");
	$output .= '<ul>
			<li><a href="'.$self->getUrl("func=add;class=WebGUI::Asset::Wobject::Layout;url=".$assetUrl).'">'.$i18n->get("add the missing page").'</a></li>
			<li><a href="'.$self->getUrl.'">'.$i18n->get("493","WebGUI").'</a></li>
			</ul>';
	return $ac->render($output);
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
    if ($userId eq $self->get("ownerUserId")) {
        return 1;
    }
    elsif ($user->isInGroup($self->get("groupIdView"))) {
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
	my ($conf, $env, $var, $http) = $self->session->quick(qw(config env var http));
    if ($conf->get("sslEnabled") && $self->get("encryptPage") && ! $env->sslRequest) {
        # getUrl already changes url to https if 'encryptPage'
        $http->setRedirect($self->getUrl);
        $http->sendHeader;
        return "chunked";
	}
    elsif ($var->isAdminOn && $self->get("state") =~ /^trash/) { # show em trash
        my $queryFrag = "func=manageTrash";
        if ($self->session->form->process('revision')) {
            $queryFrag .= ";revision=".$self->session->form->process('revision');
        }
		$http->setRedirect($self->getUrl($queryFrag));
        $http->sendHeader;
		return "chunked";
	} 
    elsif ($var->isAdminOn && $self->get("state") =~ /^clipboard/) { # show em clipboard
        my $queryFrag = "func=manageTrash";
        if ($self->session->form->process('revision')) {
            $queryFrag .= ";revision=".$self->session->form->process('revision');
        }
		$http->setRedirect($self->getUrl($queryFrag));
        $http->sendHeader;
		return "chunked";
	} 
    elsif ($self->get("state") ne "published") { # tell em it doesn't exist anymore
		$http->setStatus("410");
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
    return WebGUI::Asset->new($self->session,
        $self->getId,
        $self->get('className'),
        $self->get('revisionDate')
    );
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

=head2 DESTROY ( )

Completely remove an asset from existence.

=cut

sub DESTROY {
	my $self = shift;

	# Let the parent be garbage collected if no one else is referencing
	# him.  firstChild and lastChild are weak references, so no need to
	# worry about them here.
	delete $self->{_parent};

	$self = undef;
}


#-------------------------------------------------------------------

=head2 extraHeadTags ( value )

Returns extraHeadTags

=head3 value

If specified, stores it, but also updates extraHeadTagsPacked with the packed version.

=cut

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
		$url = $self->getParent->url;
		$url =~ s/(.*)\..*/$1/;
		$url .= '/'.$self->menuTitle;
	}

    # if we're inheriting the URL from our parent, set that appropriately
    if ($self->inheritUrlFromParent) {
        # if we're inheriting the URL from our parent, set that appropriately
        my @parts = split(m{/}, $url);
        # don't do anything unless we need to
        if($url ne $self->getParent->get('url') . '/' . $parts[-1]) {
            $url = $self->getParent->get('url') . '/' . $parts[-1];
        }
    }
	$url = $self->session->url->urlize($url);

	# fix urls used by uploads and extras
	# and those beginning with http
	my @badUrls = (
        $self->session->config->get("extrasURL"),
        $self->session->config->get("uploadsURL"),
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
        $url = $self->fixUrl($url);
    }
    return $url;
}


#-------------------------------------------------------------------

=head2 getAdminConsole ( )

Returns a reference to a WebGUI::AdminConsole object.

=cut

sub getAdminConsole {
	my $self = shift;
	unless (exists $self->{_adminConsole}) {
		$self->{_adminConsole} = WebGUI::AdminConsole->new($self->session,"assets");
	}
	$self->{_adminConsole}->setIcon($self->getIcon);
	return $self->{_adminConsole};
}


#-------------------------------------------------------------------

=head2 getClassById ( $session, $assetId )

Class method that looks up a className for an object in the database, using it's assetId.

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

    $session->errorHandler->error("Couldn't find className for asset '$assetId'");
    return undef;

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

Creates and returns a tabform to edit parameters of an Asset. See L<getEditTabs> for
adding additional tabs.

=cut

sub getEditForm {
    my $self    = shift;
    my $session = $self->session;
	my $i18n = WebGUI::International->new($session, "Asset");
	my $ago = $i18n->get("ago");
	my $tabform = WebGUI::TabForm->new($session,undef,undef,$self->getUrl());
	my $overrides = $session->config->get("assets/".$self->get("className"));

    # Set the appropriate URL
    # If we're adding a new asset, don't set anything
    if ( $session->form->get( "func" ) ne "add" ) {
        $tabform->formHeader( { action => $self->getUrl, method => "POST" } );
    }

	if ($session->config->get("enableSaveAndCommit")) {
		$tabform->submitAppend(WebGUI::Form::submit($session, {
            name    => "saveAndCommit", 
            value   => $i18n->get("save and commit"),
            }));
	}

    $tabform->submitAppend( 
        WebGUI::Form::submit ( $session, {
            name    => "saveAndReturn",
            value   => $i18n->get( "apply" ),
        } ) 
    );

	$tabform->hidden({
		name=>"func",
		value=>"editSave"
		});
	my $assetId;
	my $class;
	if ($self->getId eq "new") {
		$assetId = "new";
		$class = $session->form->process("class","className");
	}
	else {
		# revision history
		$assetId = $self->getId;
		$class = $self->get('className');
		my $ac = $self->getAdminConsole;
		$ac->addSubmenuItem($self->getUrl("func=manageRevisions"),$i18n->get("revisions").":");
		my $rs = $session->db->read("select revisionDate from assetData where assetId=? order by revisionDate desc limit 5", [$assetId]);
		while (my ($version) = $rs->array) {
			my ($interval, $units) = $session->datetime->secondsToInterval(time() - $version);
			$ac->addSubmenuItem($self->getUrl("func=edit;revision=".$version), $interval." ".$units." ".$ago);
		}
	}
	if (my $proceed = $session->form->process("proceed")) {
		$tabform->hidden({
			name=>"proceed",
			value=>$proceed,
        });
        if (my $returnUrl = $session->form->process('returnUrl')) {
            $tabform->hidden({
                name=>"returnUrl",
                value=>$returnUrl,
            });
        }
	}
	
	# create tabs
	tie my %tabs, 'Tie::IxHash';
	foreach my $tabspec ($self->getEditTabs) {
		$tabs{$tabspec->[0]} = {
			label	=> $tabspec->[1],
			uiLevel	=> $tabspec->[2],
			};
	}
	foreach my $tab (keys %{$overrides->{tabs}}) {
		foreach my $key (keys %{$overrides->{tabs}{$tab}}) {
			$tabs{$tab}{$key} = $overrides->{tabs}{$tab}{$key};
		}
	}
	foreach my $tab (keys %tabs) {
		$tabform->addTab($tab, $tabs{$tab}{label}, $tabs{$tab}{uiLevel});
	}

	# process errors
	my $errors = $session->stow->get('editFormErrors');
	if ($errors) {
		$tabform->getTab("properties")->readOnly(
			-value=>"<p>Some error(s) occurred:<ul><li>".join('</li><li>', @$errors).'</li></ul></p>',
		);
	}

	# build the definition to the generate form
    my @properties = (
		assetId	=> {
			fieldType	=> "guid",
			label		=> ["asset id",'Asset'],
			value		=> $assetId,
			hoverHelp	=> ['asset id description','Asset'],
			uiLevel		=> 9,
			tab			=> "meta",
		},
		class	=> {
			fieldType	=> "className",
			label		=> ["class name",'WebGUI'],
			value		=> $class,
			uiLevel		=> 9,
			tab			=> "meta",
		},
		keywords => {
			label       => ['keywords','Asset'],
			hoverHelp   => ['keywords help','Asset'],
			value       => $self->get('keywords'),
			fieldType	=> 'keywords',
			tab			=> 'meta',
		},
	);
    foreach my $property ($self->getProperties) {
        push @properties, $property => $self->getProperty($property);
    }

    if ($session->setting->get("metaDataEnabled")) {
		my $meta = $self->getMetaDataFields();
		foreach my $field (keys %$meta) {
			my $fieldType = $meta->{$field}{fieldType} || "text";
			my $options = $meta->{$field}{possibleValues};
			# Add a "Select..." option on top of a select list to prevent from
			# saving the value on top of the list when no choice is made.
			if("\l$fieldType" eq "selectBox") {
				$options = "|" . $i18n->get("Select") . "\n" . $options;
			}
            push @properties, "metadata_".$meta->{$field}{fieldId} => {
				tab				=> "meta",
				label        	=> $meta->{$field}{fieldName},
				uiLevel      	=> 5,
				value        	=> $meta->{$field}{value},
				extras       	=> qq/title="$meta->{$field}{description}"/,
				options      	=> $options,
				defaultValue 	=> $meta->{$field}{defaultValue},
				fieldType		=> $fieldType
			};
		}
		# add metadata management
		if ($session->user->isAdmin) {
			push @properties, '_metadatamanagement' => {
				tab			=> "meta",
				fieldType	=> "readOnly",
				value		=> '<p><a href="'.$self->session->url->page("func=editMetaDataField;fid=new").'">'.$i18n->get('Add new field').'</a></p>',
				hoverHelp	=> $i18n->get('Add new field description'),
			};
		}
    }
	
	# generate the form	
    for (my $i = 0; $i < @properties; $i += 2) {
	    my $fieldName = $properties[$i];	
		my %fieldHash = %{$properties[$i+1]};
		my %params = (name => $fieldName, value => $self->get($fieldName));

		# apply config file changes
		foreach my $key (keys %{$overrides->{fields}{$fieldName}}) {
			$fieldHash{$key} = $overrides->{fields}{$fieldName}{$key};
		}

		# Kludge.
		if (isIn($fieldHash{fieldType}, 'selectBox', 'workflow') and ref $params{value} ne 'ARRAY') {
			$params{value} = [$params{value}];
		}

		%params = (%fieldHash, %params);
		delete $params{tab};
		delete $params{tableName};

		# if there isnt a tab specified lets define one
		my $tab = $fieldHash{tab} || "properties";

        #draw the field
	    $tabform->getTab($tab)->dynamicField(%params);
	}

	# send back the rendered form
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getEditTabs ()

Returns a list of arrayrefs, one per extra tab to add to the edit
form.  The default is no extra tabs.  Override this in a subclass to
add extra tabs.

Each array ref will have 3 fields:

=over 4

=item tabName

This is the name of the tab that you will use in the definition subroutine to
add fields to the new tab.

=item label

This should be an internationalized label that will be displayed on the tab.

=item uiLevel

This is the UI level for the tab.

=back

Please see the example below for adding 1 tab.

    sub getEditTabs {
        my $self = shift;
        my $i18n = WebGUI::International->new($self->session,"myNamespace");
        return ($self->SUPER::getEditTabs, ['myTab', $i18n->get('myTabName'), 9]);
    }

=cut

sub getEditTabs {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	return (["properties", $i18n->get("properties"), 1],
		["display", $i18n->get(105), 5],
		["security", $i18n->get(107), 6],
		["meta", $i18n->get("Metadata"), 3]);
}


#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in $self->session->style->generateAdditionalHeadTags if this asset is the current session asset.  Also called in WebGUI::Layout::view for its child assets.  Overriden in Shortcut.pm.

=cut

sub getExtraHeadTags {
	my $self = shift;
	return $self->get('usePackedHeadTags') 
            ? $self->get('extraHeadTagsPacked')
            : $self->get("extraHeadTags")
            ;
}


#-------------------------------------------------------------------

=head2 getIcon ( [small] )

Returns the icon located under extras/adminConsole/assets.gif

=head3 small

If this evaluates to True, then the smaller extras/adminConsole/small/assets.gif is returned.

=cut

sub getIcon {
	my ($self, $small) = @_;
	my $icon = $self->getAttribute("icon");
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

A class method to return an iterator for getting all Assets by class (and all sub-classes)
as Asset objects, one at a time.  When the end of the assets is reached, then the iterator
will close the database handle that it uses and return undef.

It should be used like this:

my $productIterator = WebGUI::Asset::Product->getIsa($session);
while (my $product = $productIterator->()) {
  ##Do something useful with $product
}

=head3 $session

A reference to a WebGUI::Session object.

=head3 $offset

An offset, from the beginning of the results returned from the query, to really begin
returning results.  This allows very large sets of results to be handled in chunks.

=cut

sub getIsa {
    my ($class, $session, $offset) = @_;
    my $tableName = $class->getAttribute('tableName');
    my $sql = "select distinct(assetId) from $tableName";
    if (defined $offset) {
        $sql .= ' LIMIT '. $offset . ',1234567890';
    }
    my $sth = $session->db->read($sql);
    return sub {
        my ($assetId) = $sth->array;
        if (!$assetId) {
            $sth->finish;
            return undef;
        }
        return WebGUI::Asset->newPending($session, $assetId);
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
	if ($self->get("menuTitle") eq "" || lc($self->get("menuTitle")) eq "untitled") {
		return $self->getName;
	}
	return $self->get("menuTitle");
}


#-------------------------------------------------------------------

=head2 getName ( )

Returns the human readable name of the asset.

=cut

sub getName {
	my $self = shift;
    return WebGUI::International->new($self->session, 'Asset')->get($self->getAttribute('assetName'));
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

=head2 getPrototypeList ( )

Returns an array of all assets that the user can view and edit that are prototypes.

=cut

sub getPrototypeList {
    my $self    = shift;
    my $session = $self->session;
    my $db      = $session->db;
    my @prototypeIds = $db->buildArray("select distinct assetId from assetData where isPrototype=1");
    my $userUiLevel = $session->user->profileField('uiLevel');
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

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
    my $self = shift;
    return undef unless $self->canEdit && $self->session->var->isAdminOn;
    return $self->{_toolbar}
        if (exists $self->{_toolbar});
    my $userUiLevel = $self->session->user->profileField("uiLevel");
    my $uiLevels = $self->session->config->get("assetToolbarUiLevel");
    my $i18n = WebGUI::International->new($self->session, "Asset");
    my $toolbar = "";
    my $commit;
    if ($self->canEditIfLocked) {
        $toolbar .= $self->session->icon->delete('func=delete',$self->get("url"),$i18n->get(43))
            if ($userUiLevel >= $uiLevels->{"delete"});
        $toolbar .= $self->session->icon->edit('func=edit',$self->get("url"))
            if ($userUiLevel >= $uiLevels->{"edit"});
    }
    else {
        $toolbar .= $self->session->icon->locked('func=manageRevisions',$self->get("url"))
            if ($userUiLevel >= $uiLevels->{"revisions"});
    }
    $toolbar .= $self->session->icon->cut('func=cut',$self->get("url"))
        if ($userUiLevel >= $uiLevels->{"cut"});

    if ($userUiLevel >= $uiLevels->{"copy"}) {
        $toolbar .= $self->session->icon->copy('func=copy',$self->get("url"));
        # if this asset has children, create a more full-featured menu for copying
        if ($self->getChildCount) {
            $toolbar
                .= '<div class="yuimenu wg-contextmenu">'
                . '<div class="bd">'
                . '<ul class="first-of-type">'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy") . '">' . $i18n->get("this asset only") . '</a></li>'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy;with=children") . '">' . $i18n->get("with children") . '</a></li>'
                . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
                . $self->getUrl("func=copy;with=descendants") . '">' . $i18n->get("with descendants") . '</a></li>'
                . '</ul></div></div>';
        }
    }
    $toolbar .= $self->session->icon->shortcut('func=createShortcut',$self->get("url"))
        if ($userUiLevel >= $uiLevels->{"shortcut"} && !$self->isa('WebGUI::Asset::Shortcut'));

    $self->session->style->setLink($self->session->url->extras('assetToolbar/assetToolbar.css'), {rel=>"stylesheet",type=>"text/css"});
    $self->session->style->setLink($self->session->url->extras('yui/build/menu/assets/skins/sam/menu.css'), {rel=>"stylesheet",type=>"text/css"});
    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('yui/build/container/container_core-min.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('yui/build/menu/menu-min.js'), {type=>"text/javascript"});
    $self->session->style->setScript($self->session->url->extras('assetToolbar/assetToolbar.js'), {type=>"text/javascript"});
    my $output
        = '<div class="yui-skin-sam wg-toolbar">'
        . '<img src="' . $self->getIcon(1) . '" title="' . $self->getName . '" alt="' . $self->getName . '" class="wg-toolbar-icon" />'
        . '<div class="yuimenu wg-contextmenu">'
        . '<div class="bd">'
        . '<ul class="first-of-type">';
    if ($userUiLevel >= $uiLevels->{"changeUrl"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=changeUrl") . '">' . $i18n->get("change url") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"editBranch"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=editBranch") . '">' . $i18n->get("edit branch") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"revisions"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=manageRevisions") . '">' . $i18n->get("revisions") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"view"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl . '">' . $i18n->get("view") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"lock"} && !$self->isLocked) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl('func=lock') . '">' . $i18n->get("lock") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"export"} && $self->session->config->get("exportPath")) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl('func=export') . '">' . $i18n->get('Export','Icon') . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"promote"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=promote") . '">' . $i18n->get("promote") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"demote"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=demote") . '">' . $i18n->get("demote") . '</a></li>';
    }
    if ($userUiLevel >= $uiLevels->{"manage"}) {
        $output
            .= '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getManagerUrl . '">' . $i18n->get("manage") . '</a></li>';
    }
    $output .= '</ul></div></div>' . $toolbar . '</div>';
    $self->{_toolbar} = $output;
    return $output;
}

#-------------------------------------------------------------------

=head2 getToolbarState ( )

Returns 0 if the state is normal, and 1 if the toolbar state has been toggled. See toggleToolbar() for details.

=cut

sub getToolbarState {
	my $self = shift;
	return $self->{_toolbarState};
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
		|| $self->getAttribute('uiLevel')               				# from definition
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

=head2 isValidRssItem ( )

Returns true iff this asset should be included in RSS feeds from the
RSS From Parent asset.  If false, this asset will be ignored when
generating feeds, even if it appears in the item list.  Defaults to
true.

=cut

sub isValidRssItem { 1 }

#-------------------------------------------------------------------

=head2 loadModule ( $className ) 

Loads an asset module if it's not already in memory. This is a class method. Returns
undef on failure to load, otherwise returns the classname.  Will only load classes
in the WebGUI::Asset namespace.

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

    WebGUI::Error::Compile->throw(class => $className, cause => $@);
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

=cut

=head2 new ( session, assetId [, className, revisionDate ] )

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
Returns undef if it can't find the classname.

=head3 session

A reference to the current session.

=head3 assetId

Must be a valid assetId

=head3 revisionDate

A specific revision date for the asset to retrieve. If not specified, the most recent one will be used.

=cut

sub newById {
    my $requestedClass  = shift;
    my $session         = shift;
    my $assetId         = shift;
    my $revisionDate    = shift;
 
# Some code requires that these situations not die.
#    confess "newById requires WebGUI::Session" 
#        unless $session && blessed $session eq 'WebGUI::Session';
#    confess "newById requires assetId"
#        unless $assetId;
# So just return instead
    return undef unless ( $session && blessed $session eq 'WebGUI::Session' ) 
        && $assetId;

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
		if ($id ne "" || $class ne "") {
			return WebGUI::Asset->newById($session, $id, $revisionDate);
		}
        else {
			$session->errorHandler->warn("The URL $url was requested, but does not exist in your asset tree.");
			return undef;
		}
	}
	return WebGUI::Asset->getDefault($session);
}

#-------------------------------------------------------------------

=head2 newPending ( session, assetId )

Instances an existing Asset by assetId, ignoring the status and always selecting the most recent revision.

=head3 session

A reference to the current session.

=head3 assetId

The asset's id

=cut

sub newPending {
    my $class   = shift;
    my $session = shift;
    my $assetId = shift;
    Carp::croak "First parameter to newPending needs to be a WebGUI::Session object"
        unless $session && $session->isa('WebGUI::Session');
    Carp::croak "Second parameter to newPending needs to be an assetId"
        unless $assetId;
    my ($className, $revisionDate) = $session->db->quickArray("SELECT asset.className, assetData.revisionDate FROM asset INNER JOIN assetData ON asset.assetId = assetData.assetId WHERE asset.assetId = ? ORDER BY assetData.revisionDate DESC LIMIT 1", [ $assetId ]);
    if ($className ne "" || $revisionDate ne "") {
        return WebGUI::Asset->new($session, $assetId, $className, $revisionDate);
    }
    else {
        Carp::croak "Invalid asset id '$assetId' requested!";
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

=cut

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
    my $extras          = $conf->get('extrasURL');

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
    my $template        = WebGUI::Asset::Template->new($self->session, $templateId);
    my $extras          = $self->session->config->get('extrasURL');

    $template->prepare;

    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates current Asset with data from Form. You can feed back errors by returning an
arrayref containing the error messages. If there is no error you do not have to return
anything.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my %data;
    my $form = $self->session->form;
	my $overrides = $self->session->config->get("assets/".$self->get("className")."/fields");

	foreach my $property ($self->getProperties) {
		my %params = %{$self->getProperty($property)};

		# apply config file changes
		foreach my $key (keys %{$overrides->{$property}}) {
			$params{$key} = $overrides->{$property}{$key};
		}
		
		# deal with properties that can't be posted through the form
		if ($params{noFormPost}) {
			if ($form->process("assetId") eq "new" && $self->get($property) eq "") {
				$data{$property} = $params{defaultValue};
			}
			next;
		}
		
		# process the form element
		$params{name} = $property;
		$params{value} = $self->get($property);
		$data{$property} = $form->process(
			$property,
			$params{fieldType},
			$params{defaultValue},
			\%params
			);
	}
    $data{keywords} = $form->process("keywords");
    if ($self->session->setting->get("metaDataEnabled")) {
        my $meta = $self->getMetaDataFields;
	    foreach my $field (keys %{$meta}) {
            my $value = $form->process("metadata_".$field, $meta->{$field}{fieldType}, $meta->{$field}{defaultValue});
		   	$self->updateMetaData($field, $value);
	    }
    }
	$self->session->db->beginTransaction;
	$self->update(\%data);
	$self->session->db->commit;
    return undef;
}


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

    # Sanity checks
    if (ref $var ne "HASH") {
        $self->session->errorHandler->error("First argument to processTemplate() should be a hash reference.");
        return "Error: Can't process template for asset ".$self->getId." of type ".$self->get("className");
    }
    $template = WebGUI::Asset->new($self->session, $templateId,"WebGUI::Asset::Template") unless (defined $template);
    if (defined $template) {
        $var = { %{ $var }, %{ $self->getMetaDataAsTemplateVariables } };
        $var->{'controls'} = $self->getToolbar if $self->session->var->isAdminOn;
        my %vars = (
            %{$self->get},
            'title'     => $self->getTitle,
            'menuTitle' => $self->getMenuTitle,
            %{$var},
        );
        return $template->process(\%vars);
    }
    else {
        $self->session->errorHandler->error("Can't instantiate template $templateId for asset ".$self->getId);
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
	
	my $assetIds = $self->session->db->buildArrayRef("select assetId from asset where lineage like ".$self->session->db->quote($self->get("lineage").'%')." $where");
        my $idList = $self->session->db->quoteAndJoin($assetIds);
        
	$self->session->db->write("update asset set state='published', stateChangedBy=".$self->session->db->quote($self->session->user->userId).", stateChanged=".$self->session->datetime->time()." where assetId in (".$idList.")");
        foreach my $id (@{$assetIds}) {
                my $asset = WebGUI::Asset->newById($self->session, $id);
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

Purges all cache entries associated with this asset.

=cut

sub purgeCache {
	my $self = shift;
	my $stow = $self->session->stow;
	$stow->delete('assetLineage');
	$stow->delete('assetClass');
	$stow->delete('assetRevision');
    eval{$self->session->cache->delete(["asset",$self->getId,$self->get("revisionDate")])};
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

=head2 toggleToolbar ( )

Toggles a toolbar to a special state so that custom toolbars can be rendered under special circumstances. This is mostly useful for macros that wish to proxy an asset but not display the toolbar.

=cut

sub toggleToolbar {
	my $self = shift;
	if ($self->{_toolbarState}) {
		$self->{_toolbarState} = 0;
	} else {
		$self->{_toolbarState} = 1;
	}
}


#-------------------------------------------------------------------

=head2 write ( )

Stores the current properties of the asset in the database.

=cut

sub write {
	my $self = shift;
    $self->lastModified(time());
	
    my $db = $self->session->db;
    CLASS: foreach my $meta (reverse $self->meta->get_all_class_metas()) {
        my $table       = $db->quoteIdentifier($meta->tableName);
        my @properties  = $meta->get_property_list;
        my @values      = map { $self->$_ } @properties;      
        my @columnNames = map { $db->quoteIdentifier($_).'=?' } @properties;
        push @values, $self->getId, $self->revisionDate;
 	    $db->write("update ".$table." set ".join(",",@columnNames)." where assetId=? and revisionDate=?",\@values);
    }

    # update the asset's size, which also purges the cache.
    $self->setSize();

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

=head2 validParent ( )

Make sure that the current session asset is a valid parent for the child and return true or false.
For example, a WikiPage would check for a WikiMaster.  It should be overridden by those children
that need to perform that kind of check.

This is a class method.

=cut

sub validParent {
    return 1;
}

#-------------------------------------------------------------------

=head2 view ( )

The default view method for any asset that doesn't define one. Under all normal circumstances this should be overridden or your asset won't have any output.

=cut

sub view {
	my $self = shift;
	if ($self->session->var->isAdminOn) {
		return $self->getToolbar.' '.$self->getTitle;
	} else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 www_add ( )

Adds a new Asset based upon the class of the current form. Returns the Asset calling method www_edit();  The
new Asset will inherit security and style properties from the current asset, the parent.

=cut

sub www_add {
	my $self = shift;
	my %prototypeProperties;
    my $class = $self->loadModule($self->session->form->process("class","className"));
    return undef unless (defined $class);
	return $self->session->privilege->insufficient() unless ($class->canAdd($self->session));
	if ($self->session->form->process('prototype')) {
		my $prototype = WebGUI::Asset->new($self->session, $self->session->form->process("prototype"),$class);
		foreach my $property ($prototype->getProperties) { # cycle through rather than copying properties to avoid grabbing stuff we shouldn't grab
            my $definition = $prototype->getProperty($property);
			next if (isIn($property,qw(title menuTitle url isPrototype isPackage)));
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
		url=>$self->session->form->param("url")
		);
	$properties{isHidden} = 1 unless $self->session->config->get("assets/".$class."/isContainer");
	my $newAsset = WebGUI::Asset->newByPropertyHashRef($self->session,\%properties);
	$newAsset->{_parent} = $self;
	return $newAsset->www_edit();
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

=head2 www_changeUrl ( )

Allows a user to change a url permanently to something else.

=cut

sub www_changeUrl {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $f = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
	$f->hidden(name=>"func", value=>"changeUrlConfirm");
	$f->hidden(name=>"proceed", value=>$self->session->form->param("proceed"));
	$f->text(name=>"url", value=>$self->get('url'), label=>$i18n->get("104"), hoverHelp=>$i18n->get('104 description'));
	$f->yesNo(name=>"confirm", value=>0, label=>$i18n->get("confirm change"), hoverHelp=>$i18n->get("confirm change url message"), subtext=>'<br />'.$i18n->get("confirm change url message"));
	$f->submit;
	return $self->getAdminConsole->render($f->print,$i18n->get("change url"));
}

#-------------------------------------------------------------------

=head2 www_changeUrlConfirm ( )

This actually does the change url of the www_changeUrl() function.

=cut

sub www_changeUrlConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->_invokeWorkflowOnExportedFiles($self->session->setting->get('changeUrlWorkflow'), 1);

	if ($self->session->form->process("confirm","yesNo") && $self->session->form->process("url","text")) {
		$self->update({url=>$self->session->form->process("url","text")});
	 	my $rs = $self->session->db->read("select revisionDate from assetData where assetId=? and revisionDate<>?",[$self->getId, $self->get("revisionDate")]);
                while (my ($version) = $rs->array) {
                	my $old = WebGUI::Asset->new($self->session, $self->getId, $self->get("className"), $version);
                        $old->purgeRevision if defined $old;
                }
	}

	if ($self->session->form->param("proceed") eq "manageAssets") {
		$self->session->http->setRedirect($self->getManagerUrl);
	} else {
		$self->session->http->setRedirect($self->getUrl());
	}

	return undef;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Renders an AdminConsole EditForm, unless canEdit returns False.

=cut

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	return $self->getAdminConsole->render($self->getEditForm->print, $self->addEditLabel);
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves and updates history. If canEdit, returns www_manageAssets() if a new Asset is created, otherwise returns www_view().  Will return an insufficient Privilege if canEdit returns False, or if the submitted form does not pass the C<$session->form->validToken> check.

NOTE: Don't try to override or overload this method. It won't work. What you are looking for is processPropertiesFromFormPost().

=cut

sub www_editSave {
    my $self    = shift;
    my $session = $self->session;

    ##If this is a new asset (www_add), the parent may be locked.  We should still be able to add a new asset.
    my $isNewAsset = $session->form->process("assetId") eq "new" ? 1 : 0;
    return $session->privilege->locked() if (!$self->canEditIfLocked and !$isNewAsset);
    return $session->privilege->insufficient() unless $self->canEdit && $session->form->validToken;
    if ($self->session->config("maximumAssets")) {
        my ($count) = $self->session->db->quickArray("select count(*) from asset");
        my $i18n = WebGUI::International->new($self->session, "Asset");
        return $self->session->style->userStyle($i18n->get("over max assets")) if ($self->session->config("maximumAssets") <= $count);
    }
    my $object;
    if ($isNewAsset) {
        $object = $self->addChild({className=>$session->form->process("class","className")});	
        return $self->www_view unless defined $object;
        $object->{_parent} = $self;
        $object->url(undef);
    } 
    else {
        if ($self->canEditIfLocked) {
            $object = $self->addRevision;
        } 
        else {
            return $session->asset($self->getContainer)->www_view;
        }
    }

    # Process properties from form post
    my $errors = $object->processPropertiesFromFormPost;
    if (ref $errors eq 'ARRAY') {
        $session->stow->set('editFormErrors', $errors);
        if ($session->form->process('assetId') eq 'new') {
            $object->purge;
            return $self->www_add();
        } else {
            $object->purgeRevision;
            return $self->www_edit();
        }
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
    my $proceed = $session->form->process('proceed');
    if ($proceed eq "manageAssets") {
        $session->asset($object->getParent);
        return $session->asset->www_manageAssets;
    }
    elsif ($proceed eq "viewParent") {
        $session->asset($object->getParent);
        return $session->asset->www_view;
    }
    elsif ($proceed eq "goBackToPage" && $session->form->process('returnUrl')) {
        $session->http->setRedirect($session->form->process("returnUrl"));
        return undef;
    }
    elsif ($proceed ne "") {
        my $method = "www_".$session->form->process("proceed");
        $session->asset($object);
        return $session->asset->$method();
    }

    $session->asset($object->getContainer);
    return $session->asset->www_view;
}


#-------------------------------------------------------------------

=head2 www_manageAssets ( )

Redirect to the asset manager content handler (for backwards 
compatibility)

=cut

sub www_manageAssets {
    my $self = shift;
    $self->session->http->setRedirect( $self->getManagerUrl );
    return "redirect";
}

#-------------------------------------------------------------------

=head2 www_view ( )

Returns the view() method of the asset object if the requestor canView.

=cut

sub www_view {
	my $self = shift;
    
    # don't allow viewing of the root asset
	if ($self->getId eq "PBasset000000000000001") {
		$self->session->http->setRedirect($self->getDefault($self->session)->getUrl);
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

1;
