package WebGUI::Macro::RenderThingData;

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
use WebGUI::Asset::Template;
use WebGUI::International;
use WebGUI::Asset::Wobject::Thingy;

=head1 NAME

Package WebGUI::Macro::RenderThingData

=head1 DESCRIPTION

Macro that allows users to render thing data.

=head2 process ( thingURL, templateHint, callerAssetId )

=head3 thingHint

The URL from which to pull the thingId and thingDataId

=head3 templateHint

Optional.  Specifies the templateId or template url to use.  If omitted, the default thingy view template will be used.

=head3 callerAssetId

Optional.  Passes an assetId to the template (as a template var named callerAssetId) so that the the assetId of of
the caller can be known by the called template.  Generally you should pass <tmpl_var assetId>.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $thingDataUrl, $templateHint, $callerAssetId ) = @_;
    my $i18n = WebGUI::International->new($session, 'Macro_RenderThingData');
    return $i18n->get('no template') if !$templateHint;

    my $gateway = $session->config->get('gateway');
    my $uri     = URI->new( $thingDataUrl );
    my $thingy_url = $uri->path;
    $thingy_url =~ s/^$gateway//;

    my $urlHash = { $uri->query_form };
    my $thingId = $urlHash->{'thingId'};
    my $thingDataId = $urlHash->{'thingDataId'};

    my $thing = WebGUI::Asset::Wobject::Thingy->newByUrl( $session, $thingy_url );

    # TODO: i18n
    return ( $i18n->get('bad url') . $thingDataUrl ) if !$thing || !$thingId || !$thingDataId;

    # Render
    my $output = $thing->www_viewThingData( $thingId, $thingDataId, $templateHint, $callerAssetId );

    # FIX: Temporary solution (broken map due to template rendering <script> tags)
    return $i18n->get('bad tags') if $output =~ /script>/;

    return $output;
}


1;

