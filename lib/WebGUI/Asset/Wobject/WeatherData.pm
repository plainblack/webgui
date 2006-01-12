package WebGUI::Asset::Wobject::WeatherData;

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

 Portions of the below are originally from Weather::Underground, 
 and are not included in this copyright.

=cut

use strict;

use LWP::UserAgent qw($ua);
use Tie::CPHash;
use Tie::IxHash;
use JSON;
use WebGUI::Cache;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
=head2 definition

defines wobject properties for WeatherData instances

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_WeatherData");
	my $properties = {
		templateId =>{
			fieldType=>"template",
			tab=>"display",
			defaultValue=>'WeatherDataTmpl0000001',
			namespace=>"WeatherData",
			hoverHelp=>$i18n->get("Current Weather Conditions Template to use"),
			label=>$i18n->get("Template")
		},
		locations=>{
			fieldType=>"textarea",
			defaultValue=>"Grayslake,IL",
			tab=>"properties",
			hoverHelp=>$i18n->get("Your list of default weather locations"),
			label=>$i18n->get("Default Locations")
		},
	};
	push(@{$definition}, {
		tableName=>'WeatherData',
		className=>'WebGUI::Asset::Wobject::WeatherData',
		assetName=>$i18n->get("assetName"),
		icon=>'weatherData.gif',
		autoGenerateForms=>1,
		properties=>$properties
	});
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
=head2 _getLocationData

Accepts an array ref of locations, and returns 

=cut

sub _getLocationData {
	my $self = shift;
	my $location = shift;
	my $cache = WebGUI::Cache->new($self->session,["weatherLocation",$location]);
	my $locData = $cache->get;
	unless ($locData->{cityState}) {
		my $oldagent;
		my $ua = LWP::UserAgent->new;
		$ua->timeout(10);
		$oldagent = $ua->agent();
		$ua->agent($self->session->env->get("HTTP_USER_AGENT")); # Act as a proxy.
		my $response = $ua->get('http://www.srh.noaa.gov/port/port_zc.php?inputstring='.$location);
		my $document = $response->content;
		$document =~ s/\n/ /g;
		$document =~ s/\s+/ /g;
		$document =~ m!<hr>\s<div\salign="center">\s(.*?)<br>.*?<br>.*?<br>.*?<br>\s(.*?):\s(.*?) &deg;F<br>!;
		$locData = {
			query => $location,
			cityState => $1 || $location,
			sky => $2 || 'N/A',
			tempF => $3 || 'N/A',
			iconUrl => $self->session->config->get("extrasURL").'/wobject/WeatherData/'.$self->_chooseWeatherConditionsIcon($2).'.jpg'
		};
	$cache->set($locData, 60*60) if $locData->{sky} ne 'NULL';
	}
	return $locData;
}

#-------------------------------------------------------------------
=head2 _chooseWeatherConditionsIcon ( currentSkyConditionsEnglish )

Accepts a string that represents the current sky conditions.  Taken
largely from http://www.weather.gov/data/current_obs/weather.php

=cut

sub _chooseWeatherConditionsIcon {
	my $self = shift;
	my $currCond = shift;
	if (isIn($currCond,'','N/A','NULL')) {return 'unknown';}
if (isIn($currCond,'Mostly Cloudy','Mostly Cloudy with Haze','Mostly Cloudy and Breezy')) {return 'bkn';}
if (isIn($currCond,'Fair','Clear','Fair with Haze','Clear with Haze','Fair and Breezy','Clear and Breezy')) {return 'skc';}
if (isIn($currCond,'A Few Clouds','A Few Clouds with Haze','A Few Clouds and Breezy')) {return 'few';}
if (isIn($currCond,'Partly Cloudy','Party Cloudy with Haze','Partly Cloudy and Breezy')) {return 'sct';}
if (isIn($currCond,'Overcast','Overcast with Haze','Overcast and Breezy')) {return 'ovc';}
if (isIn($currCond,'Fog/Mist','Fog','Freezing Fog','Shallow Fog','Partial Fog','Patches of Fog','Fog in Vicinity','Freezing Fog in Vicinity','Shallow Fog in Vicinity','Partial Fog in Vicinity','Patches of Fog in Vicinity','Showers in Vicinity Fog','Light Freezing Fog','Heavy Freezing Fog')) {return 'nfg';}
if (isIn($currCond,'Smoke')) {return 'smoke';}
if (isIn($currCond,'Freezing Rain','Freezing Drizzle','Light Freezing Rain','Light Freezing Drizzle','Heavy Freezing Rain','Heavy Freezing Drizzle','Freezing Rain in Vicinity','Freezing Drizzle in Vicinity')) {return 'fzra';}
if (isIn($currCond,'Ice Pellets','Light Ice Pellets','Heavy Ice Pellets','Ice Pellets in Vicinity','Showers Ice Pellets','Thunderstorm Ice Pellets','Ice Crystals','Hail','Small Hail/Snow Pellets','Light Small Hail/Snow Pellets','Heavy Small Hail/Snow Pellets','Showers Hail','Hail Showers')) {return 'ip';}
if (isIn($currCond,'Freezing Rain Snow','Light Freezing Rain Snow','Heavy Freezing Rain Snow','Freezing Drizzle Snow','Light Freezing Drizzle Snow','Heavy Freezing Drizzle Snow','Snow Freezing Rain| Light Snow Freezing Rain','Heavy Snow Freezing Rain','Snow Freezing Drizzle','Light Snow Freezing Drizzle','Heavy Snow Freezing Drizzle')) {return 'mix';}
if (isIn($currCond,'Rain Ice Pellets','Light Rain Ice Pellets','Heavy Rain Ice Pellets','Drizzle Ice Pellets','Light Drizzle Ice Pellets','Heavy Drizzle Ice Pellets','Ice Pellets Rain','Light Ice Pellets Rain','Heavy Ice Pellets Rain','Ice Pellets Drizzle','Light Ice Pellets Drizzle','Heavy Ice Pellets Drizzle')) {return 'raip';}
if (isIn($currCond,'Rain Snow','Light Rain Snow','Heavy Rain Snow','Snow Rain','Light Snow Rain','Heavy Snow Rain','Drizzle Snow','Light Drizzle Snow','Heavy Drizzle Snow','Snow Drizzle','Light Snow Drizzle','Heavy Snow Drizzle')) {return 'rasn';}
if (isIn($currCond,'Rain Showers','Light Rain Showers','Heavy Rain Showers','Rain Showers in Vicinity','Light Showers Rain','Heavy Showers Rain','Showers Rain','Showers Rain in Vicinity','Rain Showers Fog/Mist','Light Rain Showers Fog/Mist','Heavy Rain Showers Fog/Mist','Rain Showers in Vicinity Fog/Mist','Light Showers Rain Fog/Mist','Heavy Showers Rain Fog/Mist','Showers Rain Fog/Mist','Showers Rain in Vicinity Fog/Mist','Light Rain and Breezy')) {return 'shra';}
if (isIn($currCond,'Thunderstorm','Light Thunderstorm Rain','Heavy Thunderstorm Rain','Thunderstorm Rain Fog/Mist','Light Thunderstorm Rain Fog/Mist','Heavy Thunderstorm Rain Fog/Mist','Thunderstorm Showers in Vicinity','| Light Thunderstorm Rain Haze','Heavy Thunderstorm Rain Haze','Thunderstorm Fog','Light Thunderstorm Rain Fog','Heavy Thunderstorm Rain Fog','Thunderstorm Light Rain','Thunderstorm Heavy Rain','Thunderstorm Rain Fog/Mist','Thunderstorm Light Rain Fog/Mist','Thunderstorm Heavy Rain Fog/Mist','Thunderstorm in Vicinity Fog/Mist','Thunderstorm Showers in Vicinity','Thunderstorm in Vicinity','Thunderstorm in Vicinity Haze','Thunderstorm Haze in Vicinity','Thunderstorm Light Rain Haze','Thunderstorm Heavy Rain Haze','Thunderstorm Fog','Thunderstorm Light Rain Fog','Thunderstorm Heavy Rain Fog','Thunderstorm Hail','Light Thunderstorm Rain Hail','Heavy Thunderstorm Rain Hail','Thunderstorm Rain Hail Fog/Mist','Light Thunderstorm Rain Hail Fog/Mist','Heavy Thunderstorm Rain Hail Fog/Mist','Thunderstorm Showers in Vicinity Hail','| Light Thunderstorm Rain Hail Haze','Heavy Thunderstorm Rain Hail Haze','Thunderstorm Hail Fog','Light Thunderstorm Rain Hail Fog','Heavy Thunderstorm Rain Hail Fog','Thunderstorm Light Rain Hail','Thunderstorm Heavy Rain Hail','Thunderstorm Rain Hail Fog/Mist','Thunderstorm Light Rain Hail Fog/Mist','Thunderstorm Heavy Rain Hail Fog/Mist','Thunderstorm in Vicinity Hail Fog/Mist','Thunderstorm Showers in Vicinity Hail','Thunderstorm in Vicinity Hail','Thunderstorm in Vicinity Hail Haze','Thunderstorm Haze in Vicinity Hail','Thunderstorm Light Rain Hail Haze','Thunderstorm Heavy Rain Hail Haze','Thunderstorm Hail Fog','Thunderstorm Light Rain Hail Fog','Thunderstorm Heavy Rain Hail Fog','Thunderstorm Small Hail/Snow Pellets','Thunderstorm Rain Small Hail/Snow Pellets','Light Thunderstorm Rain Small Hail/Snow Pellets','Heavy Thunderstorm Rain Small Hail/Snow Pellets')) {return 'tsra';}
if (isIn($currCond,'Snow','Light Snow','Heavy Snow','Snow Showers','Light Snow Showers','Heavy Snow Showers','Showers Snow','Light Showers Snow','Heavy Showers Snow','Snow Fog/Mist','Light Snow Fog/Mist','Heavy Snow Fog/Mist','Snow Showers Fog/Mist','Light Snow Showers Fog/Mist','Heavy Snow Showers Fog/Mist','Showers Snow Fog/Mist','Light Showers Snow Fog/Mist','Heavy Showers Snow Fog/Mist','Snow Fog','Light Snow Fog','Heavy Snow Fog','Snow Showers Fog','Light Snow Showers Fog','Heavy Snow Showers Fog','Showers Snow Fog','Light Showers Snow Fog','Heavy Showers Snow Fog','Showers in Vicinity Snow','Snow Showers in Vicinity','Snow Showers in Vicinity Fog/Mist','Snow Showers in Vicinity Fog','Low Drifting Snow','Blowing Snow','Snow Low Drifting Snow','Snow Blowing Snow','Light Snow Low Drifting Snow','Light Snow Blowing Snow','Heavy Snow Low Drifting Snow','Heavy Snow Blowing Snow','Thunderstorm Snow','Light Thunderstorm Snow','Heavy Thunderstorm Snow','Snow Grains','Light Snow Grains','Heavy Snow Grains','Heavy Blowing Snow','Blowing Snow in Vicinity','Light Snow and Breezy')) {return 'sn';}
if (isIn($currCond,'Windy','Fair and Windy','A Few Clouds and Windy','Partly Cloudy and Windy','Mostly Cloudy and Windy','Overcast and Windy')) {return 'wind';}
if (isIn($currCond,'Showers in Vicinity','Showers in Vicinity Fog/Mist','Showers in Vicinity Fog','Showers in Vicinity Haze')) {return 'hi_shwrs';}
if (isIn($currCond,'Freezing Rain Rain','Light Freezing Rain Rain','Heavy Freezing Rain Rain','Rain Freezing Rain','Light Rain Freezing Rain','Heavy Rain Freezing Rain','Freezing Drizzle Rain','Light Freezing Drizzle Rain','Heavy Freezing Drizzle Rain','Rain Freezing Drizzle','Light Rain Freezing Drizzle','Heavy Rain Freezing Drizzle')) {return 'fzrara';}
if (isIn($currCond,'Thunderstorm in Vicinity','Thunderstorm in Vicinity Fog/Mist','Thunderstorm in Vicinity Fog','Thunderstorm Haze in Vicinity','Thunderstorm in Vicinity Haze')) {return 'hi_tsra';}
if (isIn($currCond,'Light Rain','Drizzle','Light Drizzle','Heavy Drizzle','Light Rain Fog/Mist','Drizzle Fog/Mist','Light Drizzle Fog/Mist','Heavy Drizzle Fog/Mist','Light Rain Fog','Drizzle Fog','Light Drizzle Fog','Heavy Drizzle Fog')) {return 'ra1';}
if (isIn($currCond,'Rain','Heavy Rain','Rain Fog/Mist','Heavy Rain Fog/Mist','Rain Fog','Heavy Rain Fog')) {return 'ra';}
if (isIn($currCond,'Funnel Cloud','Funnel Cloud in Vicinity','Tornado/Water Spout')) {return 'nsvrtsra';}
if (isIn($currCond,'Dust','Low Drifting Dust','Blowing Dust','Sand','Blowing Sand','Low Drifting Sand','Dust/Sand Whirls','Dust/Sand Whirls in Vicinity','Dust Storm','Heavy Dust Storm','Dust Storm in Vicinity','Sand Storm','Heavy Sand Storm','Sand Storm in Vicinity')) {return 'dust';}
if (isIn($currCond,'Haze')) {return 'mist';}
}

#-------------------------------------------------------------------
=head2 _na( string )

If string passed in is empty, returns N/A

=head3 string

a string

=cut

sub _na {
   my $str = $_[0];
   unless($str) {
      $str = "N/A";
   }
   return $str;
}
	   
#-------------------------------------------------------------------
=head2 _trim (str)

   Trims whitespace form front and end of a string

=head3 str

a string to trim

=cut

sub _trim {
   my $self = shift;
   my $str = $_[0];
   $str =~ s/^\s//;
   $str =~ s/\s$//;
   return $str;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;
	my $var = $self->get();
	#Set some template variables

	#Build list of locations as an array
	my $defaults = $self->get("locations");
	#replace any windows newlines
	$defaults =~ s/\r//gm;
	my @array = split("\n",$defaults);
	#trim locations of whitespace
	my @locs = ();
	for (my $i = 0; $i < scalar(@array); $i++) {
		$array[$i] = $self->_trim($array[$i]);\
		push (@locs, $self->_getLocationData($array[$i]));
	}
	$var->{'ourLocations.loop'} = \@locs;
	return $self->processTemplate($var, $self->get("templateId"));
}


1;
