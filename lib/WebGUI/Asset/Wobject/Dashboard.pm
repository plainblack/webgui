package WebGUI::Asset::Wobject::Dashboard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::ProfileField;
use Time::HiRes;
use WebGUI::Asset::Wobject;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => [ 'assetName', 'Asset_Dashboard' ];
define icon      => 'dashboard.gif';
define tableName => 'Dashboard';
property templateId => (
    fieldType => "template",
    default   => 'DashboardViewTmpl00001',
    namespace => "Dashboard",
    tab       => 'display',
    label     => [ 'dashboard template field label', 'Asset_Dashboard' ],
    hoverHelp => [ 'dashboard template description', 'Asset_Dashboard' ],
);

property adminsGroupId => (
    fieldType => "group",
    default   => '4',
    tab       => 'security',
    label     => [ 'dashboard adminsGroupId field label', 'Asset_Dashboard' ],
    hoverHelp => [ 'dashboard adminsGroupId description', 'Asset_Dashboard' ],
);

property usersGroupId => (
    fieldType => "group",
    default   => '2',
    label     => [ 'dashboard usersGroupId field label', 'Asset_Dashboard' ],
    hoverHelp => [ 'dashboard usersGroupId description', 'Asset_Dashboard' ],
);

property isInitialized => (
    fieldType    => "yesNo",
    default      => 0,
    noFormPost   => 1,
);

property assetsToHide => (
    default    => undef,
    fieldType  => "checkList",
    noFormPost => \&_assetsToHide_noFormPost,
    label      => [ 'assets to hide', 'Asset_Dashboard' ],
    hoverHelp  => [ 'assets to hide description', 'Asset_Dashboard' ],
    vertical   => 1,
    uiLevel    => 9,
    options    => \&_assetsToHide_options,
);
sub _assetsToHide_noFormPost {
    my $self = shift;
    return $self->session->form->process("func") eq "add" ? 1 : 0;
}
sub _assetsToHide_options {
    my $self    = shift;
    my $session = $self->session;
    my $children = $self->getLineage(["children"],{"returnObjects"=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
    my %childIds;
    foreach my $child (@{$children}) {
        $childIds{$child->getId} = $child->getTitle.' ['.ref($child).']';	
    }
    return \%childIds;
}


#-------------------------------------------------------------------

=head2 canManage 

Determines if the current user can manage this dashboard.  Returns 0
if the user is visitor.  Otherwise, it checks to see if the user is
in the dashboard's adminsGroup.

=cut

sub canManage {
	my $self = shift;
	return 0 if $self->session->user->isVisitor;
	return $self->session->user->isInGroup($self->adminsGroupId);
}

#-------------------------------------------------------------------

=head2 canPersonalize 

Determines if the current user can personalize this dashboard.  Returns
0 if the user is visitor.  Otherwise, it checks to see if the user is
in this dashboard's userGroup.

=cut

sub canPersonalize {
	my $self = shift;
	return 0 if $self->session->user->isVisitor;
	return $self->session->user->isInGroup($self->usersGroupId);
}

#-------------------------------------------------------------------

=head2 discernUserId 

This utility method is used to determine if the user should be shown the view of the
Dashboard that Visitor would see, or their own.

=cut

sub discernUserId {
	my $self = shift;
	return ($self->canManage && $self->session->var->isAdminOn) ? '1' : $self->session->user->userId;
}

#-------------------------------------------------------------------

=head2 getContentPositions 

Gets the locations of content in the dashboard.  If the user has not customized this,
then return default locations.

=cut

sub getContentPositions {
	my $self = shift;
	my $dummy = $self->initialize unless $self->isInitialized;
	my $u = WebGUI::User->new($self->session, $self->discernUserId);
	return $u->profileField($self->getContentPositionsId) 
        || $self->getContentPositionsDefault;
}

#-------------------------------------------------------------------

=head2 getContentPositionsId 

Return the unique contentPostitions ID for this Dashboard.

=cut

sub getContentPositionsId {
    my $self = shift;
    my $id = "contentPositions".$self->getId;
    $id =~ s/-/_/g;
    return $id;
}

#-------------------------------------------------------------------

=head2 getContentPositionsDefault ( )

Returns the default content positions for this Dashboard. 

=cut

sub getContentPositionsDefault {
    my $self    = shift;
    my $dummy   = $self->initialize unless $self->isInitialized;
    # The default positions are saved under the "Visitor" user
    my $u       = WebGUI::User->new($self->session, 1); 
    return $u->profileField($self->getContentPositionsId);
}

#-------------------------------------------------------------------

=head2 getEditForm 

Extend the base method to display lists of assets to hide or show.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	my $i18n = WebGUI::International->new($self->session, "Asset_Dashboard");
	if ($self->session->form->process("func") ne "add") {
		my @assetsToHide = split("\n",$self->getValue("assetsToHide"));
		my $childIter = $self->getLineageIterator(["children"],{excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
		my %childIds;
                while ( 1 ) {
                    my $child;
                    eval { $child = $childIter->() };
                    if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                        $self->session->log->error($x->full_message);
                        next;
                    }
                    last unless $child;
			$childIds{$child->getId} = $child->getTitle.' ['.ref($child).']';	
		}
		$tabform->getTab("display")->checkList(
			-name=>"assetsToHide",
			-value=>\@assetsToHide,
			-options=>\%childIds,
			-label=>$i18n->get('assets to hide'),
			-hoverHelp=>$i18n->get('assets to hide description'),
			-vertical=>1,
			-uiLevel=>9
		);
	}
	return $tabform;
}

#-------------------------------------------------------------------

=head2 initialize 

Add the unique profile field that holds content positions for this dashboard.

=cut

sub initialize {
	my $self = shift;
	my $userPrefField = WebGUI::ProfileField->create($self->session,$self->getContentPositionsId,{
		label=>'\'Dashboard User Preference - Content Positions\'',
		visible=>0,
		protected=>1,
		editable=>0,
		required=>0,
		fieldType=>'textarea'
	});
	$self->update({isInitialized=>1});
}

#-------------------------------------------------------------------

=head2 isManaging 

Returns true if the current user canManage this dashboard, and they have admin mode
turned on.

=cut

sub isManaging {
	my $self = shift;
	return 1 if ($self->canManage && $self->session->var->isAdminOn());
	return 0;
}

#-------------------------------------------------------------------

=head2 prepareView 

Extends the base method to set the extraHeadTags for all children, and to prepare
their templates.

=cut

override prepareView => sub {
	my $self = shift;
	super();
	my @hidden = split("\n",$self->assetsToHide);
	my $childIter = $self->getLineageIterator( ["children"], {excludeClasses=>["WebGUI::Asset::Wobject::Layout","WebGUI::Asset::Wobject::Dashboard"] });
        while ( 1 ) {
            my $child;
            eval { $child = $childIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $self->session->log->error($x->full_message);
                next;
            }
            last unless $child;
        unless ( $child->getId ~~ @hidden || !$child->canView) {
			$self->session->style->setRawHeadTags($child->getExtraHeadTags);
			$child->prepareView;
		}
	}
};


#-------------------------------------------------------------------

=head2 processEditForm 

Extends the base method to handle assetsToHide.

=cut

override processEditForm => sub {
	my $self = shift;
	super();
	if ($self->session->form->process("assetId") eq "new" && $self->session->form->process("class") eq 'WebGUI::Asset::Wobject::Dashboard') {
		$self->initialize;
		if (ref $self->getParent eq 'WebGUI::Asset::Wobject::Layout') {
			$self->getParent->update({assetsToHide=>$self->getParent->assetsToHide."\n".$self->getId});
		}
		$self->update({styleTemplateId=>'PBtmplBlankStyle000001'});
	}
};

#-------------------------------------------------------------------

=head2 purge 

Extends the base method to handle deleting the profile field for storing content positions
for this dashboard.

=cut

override purge => sub {
    my $self = shift;
    my $userPrefField = WebGUI::ProfileField->new($self->session,$self->getContentPositionsId);
    if (defined $userPrefField) {
        $userPrefField->delete;
    }
    super();
};


#-------------------------------------------------------------------

=head2 view 

Render the dashboard.

=cut

sub view {
	my $self = shift;
	my %vars = %{$self->get()};
	
	$self->session->style->setScript( $self->session->url->extras('yui/build/utilities/utilities.js'));
	
	my $templateId = $self->templateId;
    # XXX Not using getLineageIterator because we loop over the children three times...
	# I'm sure there's a more efficient way to do this. We'll figure it out someday.
	my $children = $self->getLineage( ["children"], { returnObjects=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout","WebGUI::Asset::Wobject::Dashboard"] });
	my @positions = split(/\./,$self->getContentPositions);
	my @hidden = split("\n",$self->assetsToHide);
	foreach my $child (@{$children}) {
		push(@hidden,$child->shortcutToAssetId) if ref $child eq 'WebGUI::Asset::Shortcut';
		#the following loop will initially place just-dashletted assets.
		for (my $i = 0; $i < scalar(@positions); $i++) {
			next unless $child->shortcutToAssetId ~~ @hidden;
			my $newChildId = $child->getId;
			my $oldChildId = $child->shortcutToAssetId;
			$positions[$i] =~ s/${oldChildId}/${newChildId}/g;
		}
	}
	my $i = 1;
	my $templateAsset = WebGUI::Asset->newById($self->session, $templateId) || WebGUI::Asset->getImportNode($self->session);
	my $template = $templateAsset->template;
	my $numPositions = 1;
	foreach my $j (2..15) {
		$numPositions = $j if $template =~ m/position${j}\_loop/;
	}

	my @found;
	my $newStuff;
	foreach my $position (@positions) {
		my @assets = split(",",$position);
		foreach my $asset (@assets) {
			foreach my $child (@{$children}) {
				if ($asset eq $child->getId) {
					unless ($asset ~~ @hidden || !$child->canView) {
						$self->session->style->setRawHeadTags($child->getExtraHeadTags);
						$child->{_properties}{title} = $child->getTitle;
						$child->{_properties}{title} = $child->getShortcut->getTitle if (ref $child eq 'WebGUI::Asset::Shortcut');
						if ($i == 1 || $i > $numPositions) {
							push(@{$vars{"position1_loop"}},{
								id=>$child->getId,
								content=>'', #so things in the New Content bar don't display.
								dashletTitle=>$child->{_properties}{title},
								shortcutUrl=>$child->getUrl,
								canPersonalize=>$self->canPersonalize,
								showReloadIcon=>$child->{_properties}{showReloadIcon},
								canEditUserPrefs=>(($self->session->user->isRegistered) && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
							});
							$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';

						} else {
							$child->prepareView;
							push(@{$vars{"position".$i."_loop"}},{
								id=>$child->getId,
								content=>$child->view,
								dashletTitle=>$child->{_properties}{title},
								shortcutUrl=>$child->getUrl,
								canPersonalize=>$self->canPersonalize,
								showReloadIcon=>$child->{_properties}{showReloadIcon},
								canEditUserPrefs=>(($self->session->user->isRegistered) && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
							});
							$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';
						}
					}
					push(@found, $child->getId);
				}
			}
		}
		$i++;
	}
	# deal with unplaced children
	foreach my $child (@{$children}) {
		unless ($child->getId ~~ @found || $child->getId ~~ @hidden) {
			if ($child->canView) {
				$child->{_properties}{title} = $child->getShortcut->title if (ref $child eq 'WebGUI::Asset::Shortcut');
				push(@{$vars{"position1_loop"}},{
					id=>$child->getId,
					content=>'',
					dashletTitle=>$child->getTitle,
					shortcutUrl=>$child->getUrl,
					showReloadIcon=>$child->{_properties}{showReloadIcon},
					canPersonalize=>$self->canPersonalize,
					canEditUserPrefs=>(($self->session->user->isRegistered) && (ref $child eq 'WebGUI::Asset::Shortcut') && (scalar($child->getPrefFieldsToShow) > 0))
				});
				$newStuff .= 'available_dashlets["'.$child->getId.'"]=\''.$child->getUrl.'\';';
			}
		}
	}
	$vars{showAdmin} = ($self->session->var->isAdminOn && $self->canEdit);
	$vars{"dragger.init"} = '
		<script type="text/javascript">
			dragable_init("'.$self->getUrl.'");
		var available_dashlets= new Array();
		'.$newStuff.'
		</script>
	';
	return $self->processTemplate(\%vars, $templateId);
}

#-------------------------------------------------------------------

=head2 www_setContentPositions 

Web method for saving the positions of dashlets in the dashboard.

=cut

sub www_setContentPositions {
	my $self = shift;
	return 'Visitors cannot save settings' if($self->session->user->isVisitor);
	return $self->session->privilege->insufficient() unless ($self->canPersonalize);
	return 'empty' unless $self->isInitialized;
	my $dummy = $self->initialize unless $self->isInitialized;
	my $u = WebGUI::User->new($self->session, $self->discernUserId);
	my $success = $u->profileField($self->getContentPositionsId,$self->session->form->process("map")) eq $self->session->form->process("map");
	return "Map set: ".$self->session->form->process("map") if $success;
	return "Map failed to set.";
}

#-------------------------------------------------------------------

=head2 www_view (  )

Renders self->view based upon current style, subject to timeouts. Returns Privilege::noAccess() if canView is False.

=cut

sub www_view {
        my $self = shift;
        unless ($self->canView) {
                if ($self->state eq "published") { # no privileges, make em log in
                        return $self->session->privilege->noAccess();
                } elsif ($self->session->var->isAdminOn && $self->state =~ /^trash/) { # show em trash
                        $self->session->http->setRedirect($self->getUrl("func=manageTrash"));
                        return undef;
                } elsif ($self->session->var->isAdminOn && $self->state =~ /^clipboard/) { # show em clipboard
                        $self->session->http->setRedirect($self->getUrl("func=manageClipboard"));
                        return undef;
                } else { # tell em it doesn't exist anymore
                        $self->session->http->setStatus(410);
                        return WebGUI::Asset->getNotFound($self->session)->www_view;
                }
        }
        $self->logView();
        $self->prepareView;
        my $style = $self->processStyle($self->view, { noHeadTags => 1});
}



__PACKAGE__->meta->make_immutable;
1;
