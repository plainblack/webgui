package WebGUI::Macro::RenderThingData;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2011 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Group;
use WebGUI::Asset::Template;
use WebGUI::Asset::Wobject::Thingy;

=head1 NAME

Package WebGUI::Macro::RenderThingData

=head1 DESCRIPTION

Macro that allows users to render thing data.

=head2 process ( thingURL, templateHint )

=head3 thingHint

The URL from which to pull the thingId and thingDataId

=head3 templateHint

Optional.  Specifies the templateId or template url to use.  If omitted, the default thingy view template will be used.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $thingDataUrl, $templateHint ) = @_;
	
    my $uri = URI->new( $thingDataUrl );
    
    my $urlHash = { $uri->query_form };
    my $thingId = $urlHash->{'thingId'};
    my $thingDataId = $urlHash->{'thingDataId'};
    
    my $thing = WebGUI::Asset::Wobject::Thingy->newByUrl( $session, $uri->path );
    
    # TODO: i18n
    return ( "Bad URL: " . $thingDataUrl ) if !$thing || !$thingId || !$thingDataId;
    
    # Render
    my $output = $thing->www_viewThingData( $thingId, $thingDataId, $templateHint );
    
    # FIX: Temporary solution (broken map due to template rendering <script> tags)
    return "RenderThingData: Please specify a template." if !$templateHint;
    return "RenderThingData: Contained bad tags!" if $output =~ /script>/;

    return $output;
}


1;

