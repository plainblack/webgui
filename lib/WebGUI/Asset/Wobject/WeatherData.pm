package WebGUI::Asset::Wobject::WeatherData;

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

use strict;
use Weather::Com::Finder;
use WebGUI::International;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
with 'WebGUI::Role::Asset::Dashlet';
define tableName => 'WeatherData';
define assetName => ["assetName", 'Asset_WeatherData'];
define icon      => 'weatherData.gif';
property partnerId => (
            fieldType   => "text",
            tab         => "properties",
            default     => undef,
            hoverHelp   => ["partnerId help", 'Asset_WeatherData'],
            label       => ["partnerId", 'Asset_WeatherData'],
            subtext     => \&_partnerId_subtext,
          );
sub _partnerId_subtext {
    my $session = shift->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_WeatherData');
    return '<a href="http://www.weather.com/services/xmloap.html">'.$i18n->get("you need a weather.com key").'</a>';
}
property licenseKey => (
            fieldType   => "text",
            tab         => "properties",
            default     => undef,
            hoverHelp   => ["licenseKey help", 'Asset_WeatherData'],
            label       => ["licenseKey", 'Asset_WeatherData'],
         );
property templateId => (
            fieldType   => "template",
            tab         => "display",
            default     => 'WeatherDataTmpl0000001',
            namespace   => "WeatherData",
            hoverHelp   => ["Current Weather Conditions Template to use", 'Asset_WeatherData'],
            label       => ["Template", 'Asset_WeatherData'],
         );
property locations => (
            fieldType   => "textarea",
            default     => "Madison, WI\nToronto, Canada\n53536",
            tab         => "properties",
            hoverHelp   => ["Your list of default weather locations", 'Asset_WeatherData'],
            label       => ["Default Locations", 'Asset_WeatherData'],
            dashletOverridable => 1,
         );

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;
    my $session = $self->session;
	my %var;
    my $url = $self->session->url;
    
	if ($self->partnerId ne "" && $self->licenseKey ne "") {
        my $overrides = $self->fetchUserOverrides($self->getParent->getId);
        my $locations = $overrides->{locations} || $self->locations;
		foreach my $location (split("\n", $locations)) {
            my $loop_data;
            my $link_data = [];
            my $cached_data = $session->cache->get( join "", $self->getId, $location );
            if ($cached_data) {
                $loop_data = $cached_data->{locations};
                $link_data = $cached_data->{links} || [];
            }
            else {
                my $weather = Weather::Com::Finder->new({
                    'partner_id' => $self->partnerId, 
                    'license'    => $self->licenseKey,
                    'cache'		 => '/tmp',
                    });	
                next unless defined $weather;

                foreach my $foundLocation(@{$weather->find($location)}) {
                    my $current_conditions = $foundLocation->current_conditions;
                    my $conditions = $current_conditions->description;
                    $conditions    =~ s/\b(\w)/uc($1)/eg;
                    my $tempC      = $current_conditions->temperature;
                    my $tempF;
                    $tempF = sprintf("%.0f",(((9/5)*$tempC) + 32)) if($tempC);
                    my $icon = $current_conditions->icon || "na";

                    push @{$loop_data}, {
                        query       => $location,
                        cityState   => $foundLocation->name || $location,
                        sky         => $conditions || 'N/A',
                        tempF       => (defined $tempF)?$tempF:'N/A',
                        tempC       => (defined $tempC)?$tempC:'N/A',
                        smallIcon   => $url->extras("wobject/WeatherData/small_icons/".$icon.".png"),
                        mediumIcon  => $url->extras("wobject/WeatherData/medium_icons/".$icon.".png"),
                        largeIcon   => $url->extras("wobject/WeatherData/large_icons/".$icon.".png"),
                        iconUrl     => $url->extras("wobject/WeatherData/medium_icons/".$icon.".png"),
                        iconAlt     => $conditions,
                        last_fetch  => time(),
                    };
                    for my $lnk (@{$foundLocation->current_conditions->{WEATHER}{lnks}{link}} ) {
                        if (! $link_data) {
                            push @{ $link_data }, {
                                link_url    => $lnk->{l},
                                link_title  => $lnk->{t},
                            };
                        }
                    }
                }
                my $cached_data = {
                    locations => $loop_data,
                    links     => $link_data,
                };
                $session->cache->set( join( "", $self->getId, $location ), $cached_data, $self->get('cacheTimeout'));
            }
            push @{$var{'ourLocations.loop'}}, @{ $loop_data };
            if (!$var{links_loop}) {
                $var{links_loop} = $link_data;
            }
		}
	}
	return $self->processTemplate(\%var, undef, $self->{_viewTemplate});
}

__PACKAGE__->meta->make_immutable;
1;
