package WebGUI::Asset::RSSFromParent;

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
use HTML::Entities;
use Tie::IxHash;
use base 'WebGUI::Asset';
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset::RSSFromParent

=head1 DESCRIPTION

Generates an RSS feed from the children/descendants of its parent.

=head1 SYNOPSIS

use WebGUI::Asset::RSSFromParent;

=cut

#-------------------------------------------------------------------

=head2 definition 

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_RSSFromParent");

	%properties = ();

	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'rssGear.gif',
		autoGenerateForms=>1,
		tableName=>'RSSFromParent',
		className=>'WebGUI::Asset::RSSFromParent',
		properties=>\%properties
	});

	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 update 

=cut

sub update {
	# Re-force isHidden to 1 on each update; these should always be hidden.
	my $self = shift;
	my $properties = shift;
	$self->SUPER::update(+{%$properties, isHidden => 1});
}

#------------------------------------------------

=head2 _escapeXml 

=cut

sub _escapeXml {
	my $text = shift;
    return $text unless (ref $text eq "");
    return HTML::Entities::encode_numeric($text)
}

#------------------------------------------------

=head2 _tlsOfAsset 

=cut

sub _tlsOfAsset {
	my $self = shift;
	my $asset = shift;
    #Fix Title
    my $title = _escapeXml($asset->get('title'));    
    #Fix Url
    my $url = _escapeXml($self->session->url->getSiteURL() . $asset->getUrl);    
    #Fix Description
    my $description = _escapeXml($asset->get('synopsis'));	
    return ($title,$url,$description);
}

#------------------------------------------------

=head2 { 

=cut

sub isValidRssItem { 0 }

#------------------------------------------------

=head2 displayInFolder2 

=cut

sub displayInFolder2 { 0 }

#------------------------------------------------

=head2 www_view 

=cut

sub www_view {
	my $self = shift;
	return '' unless $self->session->asset->getId eq $self->getId;
	return '' unless $self->getParent->isa('WebGUI::Asset::RSSCapable');
        return '' unless $self->getParent->canView; # Go to parent for auth
	my $parent = $self->getParent;
	my $template = WebGUI::Asset::Template->new($self->session, $parent->get('rssCapableRssTemplateId'));
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->session->http->setMimeType('text/xml');

	my $var = {};
	@$var{'title', 'link', 'description'} = $self->_tlsOfAsset($parent);
	$var->{'generator'} = "WebGUI $WebGUI::VERSION";
	$var->{'lastBuildDate'} = $self->session->datetime->epochToMail($parent->getContentLastModified);
	$var->{'webMaster'} = $self->session->setting->get('companyEmail');
	$var->{'docs'} = 'http://blogs.law.harvard.edu/tech/rss';

	my @items = $parent->getRssItems;
	$var->{'item_loop'} = [];
    my $counter = 0;
	foreach my $item (@items) {
		my $subvar = {};
       
		if (UNIVERSAL::isa($item, 'WebGUI::Asset')) {
			next unless $item->isValidRssItem;
			$subvar = {};
			@$subvar{'title', 'link', 'description'} = $self->_tlsOfAsset($item);
			$subvar->{guid} = $subvar->{link};
			$subvar->{pubDate} = _escapeXml($self->session->datetime->epochToMail($item->get('creationDate')));
		} elsif (ref $item eq 'HASH') {
            foreach my $key (keys %$item) {
                $subvar->{$key} = _escapeXml($item->{$key});
            }
		} else {
			$self->session->errorHandler->error("Don't know what to do with this RSS item: $item");
			next;
		}
        $counter++;
		push @{$var->{'item_loop'}}, $subvar;
	}

	return $self->processTemplate($var, undef, $template);
}

1;
