package WebGUI::Asset::RSSCapable;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use NEXT;
use WebGUI::Asset::RSSFromParent;

=head1 NAME

WebGUI::Asset::RSSCapable

=head1 DESCRIPTION

An extra mixin class to be included before WebGUI::Asset in any asset
class that wishes its instances to be capable of generating RSS feeds
using the RSSFromParent asset.

=head1 SYNOPSIS

    use base 'WebGUI::Asset::RSSCapable';

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, 'Asset_RSSCapable');

	# We do this prefixing to avoid name collisions because properties aren't namespaced.
	%properties =
	    (
	     rssCapableRssEnabled => { tab => 'display',
				       fieldType => 'yesNo',
				       defaultValue => 1,
				       label => $i18n->get('rssEnabled label'),
				       hoverHelp => $i18n->get('rssEnabled hoverHelp')
				     },
	     rssCapableRssTemplateId => { tab => 'display',
					  fieldType => 'template',
					  defaultValue => 'PBtmpl0000000000000142',
					  namespace => 'RSSCapable/RSS',
					  label => $i18n->get('rssTemplateId label'),
					  hoverHelp => $i18n->get('rssTemplateId hoverHelp')
					},
	     rssCapableRssFromParentId => { fieldType => 'hidden',
					    noFormPost => 1,
					    defaultValue => undef,
					  },
	    );

	push @$definition, { assetName => $i18n->get('assetName'),
			     tableName => 'RSSCapable',
			     autoGenerateForms => 1,
			     className => 'WebGUI::Asset::RSSCapable',
			     icon => 'rssCapable.gif',
			     properties => \%properties
			   };
	return $class->NEXT::definition($session, $definition);
}

#-------------------------------------------------------------------
sub _rssFromParentValid {
	my $self = shift;
	my $rssFromParentId = $self->get('rssCapableRssFromParentId');
	return 0 unless $rssFromParentId;

	my $rssFromParent = WebGUI::Asset->newByDynamicClass($self->session, $rssFromParentId);
	return ($rssFromParent->isa('WebGUI::Asset::RSSFromParent')
		&& $rssFromParent->getParent->getId eq $self->getId);
}

#-------------------------------------------------------------------
sub _updateRssFromParentProperties {
	my $self = shift;
	my $rssFromParent = WebGUI::Asset->newByDynamicClass($self->session,
							     $self->get('rssCapableRssFromParentId'));
	$rssFromParent->update({ title => $self->get('title'),
				 menuTitle => $self->get('menuTitle') });
}

#-------------------------------------------------------------------
sub _purgeExtraRssFromParentAssets {
	my $self = shift;
	my $rssFromParentId = $self->get('rssCapableRssFromParentId');

	foreach my $rssFromParent (@{$self->getLineage(['children'],
						       {returnObjects => 1,
							includeOnlyClasses =>
							['WebGUI::Asset::RSSFromParent']})}) {
		$rssFromParent->purge unless $rssFromParent->getId eq $rssFromParentId;
	}
}

#-------------------------------------------------------------------
sub _ensureRssFromParentPresent {
	my $self = shift;
	if (!$self->_rssFromParentValid) {
		# Create a new one.
		my $rssFromParent = $self->addChild({ className => 'WebGUI::Asset::RSSFromParent',
						      title => $self->get('title'),
						      menuTitle => $self->get('menuTitle'),
						      url => $self->get('url').'.rss'
						    });
		$self->update({ rssCapableRssFromParentId => $rssFromParent->getId });
	}

	$self->_updateRssFromParentProperties;
	$self->_purgeExtraRssFromParentAssets;
}

#-------------------------------------------------------------------
sub _ensureRssFromParentAbsent {
	my $self = shift;
	# Invalidate it, and then it'll get purged along with any others.
	$self->update({ rssCapableRssFromParentId => undef });
	$self->_purgeExtraRssFromParentAssets;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	my $error = $self->NEXT::processPropertiesFromFormPost(@_);
	return $error if ref $error eq 'ARRAY';

	if ($self->get('rssCapableRssEnabled')) {
		$self->_ensureRssFromParentPresent;
	} else {
		$self->_ensureRssFromParentAbsent;
	}

	return;
}

#-------------------------------------------------------------------

=head2 getRssUrl ( )

Returns the site-relative URL to the RSS feed for this asset, or undef
if there is no such feed.

=cut

sub getRssUrl {
	my $self = shift;
	my $rssFromParentId = $self->get('rssCapableRssFromParentId');
	return undef unless defined $rssFromParentId;
	WebGUI::Asset->newByDynamicClass($self->session, $rssFromParentId)->getUrl;
}

#-------------------------------------------------------------------

=head2 getRssItems ( )

Returns a list of RSS items for a feed corresponding to this asset.
Each item may be another asset, or a hash of (properly XMLized)
properties for the <item>..</item> tag.  Defaults to no items.

This is the primary method that RSSCapable assets should override.

=cut

sub getRssItems { () }


#-------------------------------------------------------------------

=head2 www_viewRSS ( )

Default www method for methods that return RSS.  This will redirect to the getRssUrl unless overridden.
=cut

sub www_viewRSS { 
   my $self = shift;
   my $session = $self->session;
   
   my $rssUrl = $self->getRssUrl;
   
   if($rssUrl) {
      $session->http->setRedirect($self->getRssUrl);
   }
   
   return "";
}


1;
