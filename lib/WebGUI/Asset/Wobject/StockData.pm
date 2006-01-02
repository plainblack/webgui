package WebGUI::Asset::Wobject::StockData;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;

use Finance::Quote;

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
=head2 _appendStockVars ( hash, data, symbol )

Appends stock variables for the symbol passed in to the hash passed in

=head3 hash

hash to append stock variables to

=head3 data

hash reference in the format passed by the fetch method from Finance::Quote

=head3 symbol

stock symbol to append variables for

=cut

sub _appendStockVars {
   my $self = shift;
   my $hash = $_[0];
   my $data = $_[1];
   my $symbol = $_[2];
   $hash->{'stocks.symbol'} = _na($symbol);
   $hash->{'stocks.name'} = _na($data->{$symbol,"name"});
   $hash->{'stocks.last'} = _na($data->{$symbol,"last"});
   $hash->{'stocks.high'} = _na($data->{$symbol,"high"});
   $hash->{'stocks.low'} = _na($data->{$symbol,"low"});
   $hash->{'stocks.date'} = _na($data->{$symbol,"date"});
   $hash->{'stocks.time'} = _na($data->{$symbol,"time"});
	   
   $hash->{'stocks.net'} = _na($data->{$symbol,"net"});
   $hash->{'stocks.net.isDown'} = $hash->{'stocks.net'} < 0;
   $hash->{'stocks.net.isUp'} = $hash->{'stocks.net'} > 0;
   $hash->{'stocks.net.noChange'} = $hash->{'stocks.net'} == 0;
	   
   $hash->{'stocks.net.icon'} =  "nc.gif";
   if($hash->{'stocks.net.isDown'}) {
      $hash->{'stocks.net.icon'} = "down.gif";
   } elsif($hash->{'stocks.net.isUp'}) {
	  $hash->{'stocks.net.icon'} = "up.gif";
   }
   $hash->{'stocks.p_change'} = _na($data->{$symbol,"p_change"});
   $hash->{'stocks.volume'} = _na($data->{$symbol,"volume"});
   $hash->{'stocks.volume.millions'} = _na(WebGUI::Utility::round(($hash->{'stocks.volume'}/1000000),2));
   $hash->{'stocks.avg_vol'} = _na($data->{$symbol,"avg_vol"});
   $hash->{'stocks.bid'} = _na($data->{$symbol,"bid"});
   $hash->{'stocks.ask'} = _na(WebGUI::Utility::commify($data->{$symbol,"ask"}));
   $hash->{'stocks.close'} = _na($data->{$symbol,"close"});
   $hash->{'stocks.open'} = _na($data->{$symbol,"open"});
   $hash->{'stocks.day_range'} = _na($data->{$symbol,"day_range"});
   $hash->{'stocks.year_range'} = _na($data->{$symbol,"year_range"});
   my ($yrLo,$yrHi) = split("-",$hash->{'stocks.year_range'});
   
   $hash->{'stocks.year_high'} = _na($self->_trim($yrHi));
   $hash->{'stocks.year_low'} = _na($self->_trim($yrLo));
   $hash->{'stocks.eps'} = _na($data->{$symbol,"eps"});
   $hash->{'stocks.pe'} = _na($data->{$symbol,"pe"});
   $hash->{'stocks.div_date'} = _na($data->{$symbol,"div_date"});
   $hash->{'stocks.div'} = _na($data->{$symbol,"div"});
   $hash->{'stocks.div_yield'} = _na($data->{$symbol,"div_yield"});
   $hash->{'stocks.cap'} = _na(lc($data->{$symbol,"cap"}));
   $hash->{'stocks.ex_div'} = _na($data->{$symbol,"ex_div"});
   $hash->{'stocks.nav'} = _na($data->{$symbol,"nav"});
   $hash->{'stocks.yield'} = _na($data->{$symbol,"yield"});
   $hash->{'stocks.exchange'} = _na($data->{$symbol,"exchange"});
   $hash->{'stocks.success'} = _na($data->{$symbol,"success"});
   $hash->{'stocks.errormsg'} = _na($data->{$symbol,"errormsg"});
   $hash->{'stocks.method'} = _na($data->{$symbol,"method"});
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
=head2 _appendZero( intger )

Appends a zero to an integer if it is 0-9

=head3 integer

an integer

=cut

sub _appendZero {
   my $self = shift;
   my $num = $_[0];
   if (length($num) == 1) {
      $num = "0".$num;
   }
   return $num;
}

#-------------------------------------------------------------------
=head2 _clearStockEditSession ( )

Clears the session variables from session used by the stock list edit form

=cut

sub _clearStockEditSession {
   my $self = shift;
   $self->session->form->process("symbol") = "";
   $self->session->form->process("stockId") = "";
}

#-------------------------------------------------------------------
=head2 _convertToEpoch (date,time)

Converts the date and time returned by Finance::Quote to an epoch

=head3 date

date format returned by Finance::Quote

=head3 time

time format returned by Finance::Quote

=cut

sub _convertToEpoch {
   my $self = shift;
   my $date = $_[0];
   my $time = $_[1];
   
   my ($month,$day,$year) = split("/",$date);
   $month = $self->_appendZero($month);
   $day = $self->_appendZero($day);   
   my $tfixed = substr($time,0,-2);
   my ($hour,$minute) = split(":",$tfixed);
   if($time =~ m/pm/i) {
      $hour += 12;
   }
   $hour = $self->_appendZero($hour);
   $minute = $self->_appendZero($minute);
   return WebGUI::DateTime::humanToEpoch("$year-$month-$day $hour:$minute:00");
}

#-------------------------------------------------------------------
=head2 _getStocks ( stocks )

Private method which retrieves stock information from the Finance::Quote package

=head3 stocks

list of stock symbols to find passed in as an array reference.  stock symbols should all be uppercase

=cut

sub _getStocks {
   my $self = shift;
   my $stocks = $_[0];   
   #Create a new Finance::Quote object
   my $q = Finance::Quote->new;
   #Disable failover if specified
   unless ($self->getValue("failover")) {
      $q->failover(0);
   }
   #Fetch the stock information and return the results
   return $q->fetch($self->getValue("source"),@{$stocks});
}

#-------------------------------------------------------------------
=head2 _getStockSources (  )

Private method which retrieves the list of available stock sources from Finance::Quote package
and returns the results as a hash reference for the selectList Form API

=cut

sub _getStockSources {
   my $self = shift;
   #Instantiate Finance::Quote
   my $q = Finance::Quote->new;
   #Retrieve array of available sources and sort them
   my @srcs = sort $q->sources;
   #Create a hash reference with the name referencing itself
   my %sources;
   #Tie to IxHash to preserve alphabetical order
   tie %sources, "Tie::IxHash";
   foreach my $src (@srcs) {
      $sources{$src} = $src;
   }
   return \%sources;
}

#-------------------------------------------------------------------
=head2 _submenu

renders the admin console view

=cut

sub _submenu {
   my $self = shift;
   my $workarea = shift;
   my $title = shift;
   my $help = shift;
   my $ac = WebGUI::AdminConsole->new("editstocks");
   $ac->setHelp($help) if ($help);
   $ac->setIcon($self->getIcon);
   return $ac->render($workarea, $title);
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
=head2 definition

defines wobject properties for Stock Data instances

=cut

sub definition {
	my $class = shift;
	my $definition = shift;
	my $properties = {
		templateId =>{
			fieldType=>"template",
			defaultValue=>'StockDataTMPL000000001'
		},
		displayTemplateId=>{
			fieldType=>"template",
			defaultValue=>'StockDataTMPL000000002'
		},
		defaultStocks=>{
			fieldType=>"textarea",
			defaultValue=>"DELL\nMSFT\nORCL\nSUNW\nYHOO"
		},
		source=>{
			fieldType=>"selectList",
			defaultValue=>"usa"
		},
		failover=>{
			fieldType=>"checkbox",
			defaultValue=>undef
		}
	};
	push(@{$definition}, {
		tableName=>'StockData',
		className=>'WebGUI::Asset::Wobject::StockData',
		icon=>'stockData.gif',
		assetName=>WebGUI::International::get("assetName","Asset_StockData"),
		properties=>$properties
	});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
=head2 getEditForm

returns the tabform object that will be used in generating the edit page for Stock Lists

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
   	
	$tabform->getTab("display")->template(
       -value=>$self->get("templateId"),
       -label=>WebGUI::International::get("template_label","Asset_StockData"),
       -namespace=>"StockData"
    );
	
	$tabform->getTab("display")->template(
       -value=>$self->get("displayTemplateId"),
       -label=>WebGUI::International::get("display_template_label","Asset_StockData"),
       -namespace=>"StockData/Display"
    );
	
	$tabform->getTab("properties")->textarea(
	    -name => "defaultStocks",
		-label=> WebGUI::International::get("default_stock_label","Asset_StockData"),
		-value=> $self->getValue("defaultStocks") 
	);
	
	$tabform->getTab("properties")->selectList(
	    -name => "source",
		-label=> WebGUI::International::get("stock_source","Asset_StockData"),
		-options=>$self->_getStockSources(),
		-value=> [$self->getValue("source")],
		-hoverHelp=>WebGUI::International::get("stock_source_description","Asset_StockData")
	);
	
	$tabform->getTab("properties")->yesNo(
	    -name=> "failover",
		-label=> WebGUI::International::get("failover_label","Asset_StockData"),
		-value=>$self->getValue("failover"),
		-hoverHelp=> WebGUI::International::get("failover_description","Asset_StockData")
	);

	return $tabform;
}

#-------------------------------------------------------------------
=head2 purge ( )

removes collateral data associated with a StockData when the system
purges it's data.

=cut

sub purge {
	my $self = shift;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style

=cut

sub view {
	my $self = shift;
    my $var = {};
	#Set some template variables
	$var->{'extrasFolder'} = $self->session->config->get("extrasURL")."/wobject/StockData";
	$var->{'editUrl'} = $self->getUrl("func=editStocks");
	$var->{'isVisitor'} = $self->session->user->profileField("userId") eq 1;
	$var->{'stock.display.url'} = $self->getUrl("func=displayStock&symbol=");
	
	#Build list of stocks as an array
	my $defaults = $self->getValue("defaultStocks");
	#replace any windows newlines
	$defaults =~ s/\r//;
	my @array = split("\n",$defaults);
	#trim default stocks of whitespace
	for (my $i = 0; $i < scalar(@array); $i++) {
		$array[$i] = $self->_trim($array[$i]);
	}
	my $data = $self->_getStocks(\@array);
	
	my @stocks = ();
	foreach my $symbol (@array) {
	   my $hash = {};
	   
	   #Append Template Variables for stock symbol
	   $self->_appendStockVars($hash,$data,$symbol);
	   
	   #Create last update date formats
	   unless ($var->{'lastUpdate.default'}) {
          my $luEpoch = $self->_convertToEpoch($hash->{'stocks.date'},$hash->{'stocks.time'});
	      $var->{'lastUpdate.intl'} = WebGUI::DateTime::epochToHuman($luEpoch,"%y-%m-%d %j:%n");
	      $var->{'lastUpdate.us'} = WebGUI::DateTime::epochToHuman($luEpoch,"%m/%d/%y %h:%n %p");
          $var->{'lastUpdate.default'} = WebGUI::DateTime::epochToHuman($luEpoch,"%C %d %H:%n %P");
       }
	   
	   push (@stocks, $hash);
	}
	$var->{'stocks.loop'} = \@stocks;
	return $self->processTemplate($var, $self->get("templateId"));
}

#-------------------------------------------------------------------
=head2 www_displayStock ( )

Web facing method which allows users to view details about their stocks

=cut

sub www_displayStock {
   my $self = shift;
   my $var = {};
   return WebGUI::Privilege::noAccess() unless $self->canView();
   
   $var->{'extrasFolder'} = $self->session->config->get("extrasURL")."/wobject/StockData";
   
   my $symbol = $self->session->form->process("symbol");
   my $data = $self->_getStocks([$symbol]);
   #Append Template Variables for stock symbol
   $self->_appendStockVars($var,$data,$symbol);
   
   #Configure last update dates
   my $luEpoch = $self->_convertToEpoch($var->{'stocks.date'},$var->{'stocks.time'});
   $var->{'lastUpdate.intl'} = WebGUI::DateTime::epochToHuman($luEpoch,"%y-%m-%d");
   $var->{'lastUpdate.us'} = WebGUI::DateTime::epochToHuman($luEpoch,"%m/%d/%y");
   
   $self->session->setting->get("showDebug") = 0;
   return $self->processTemplate($var, $self->get("displayTemplateId"));
}

#-------------------------------------------------------------------
#=head2 www_edit ( )

#Web facing method which is the default edit page

#=cut

#sub www_edit {
#   my $self = shift;
#   return WebGUI::Privilege::insufficient() unless $self->canEdit;
#   $self->getAdminConsole->setHelp("stock list add/edit","Asset_StockData");
#   return $self->getAdminConsole->render($self->getEditForm->print,
#                  WebGUI::International::get("edit_title","Asset_StockData"));
#}

#-------------------------------------------------------------------
=head2 www_view ( )

Overwrite www_view method and call the superclass object, passing in a 1 to disable cache

=cut

sub www_view {
   my $self = shift;
   $self->SUPER::www_view(1);
}

1;
