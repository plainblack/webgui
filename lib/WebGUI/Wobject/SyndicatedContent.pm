package WebGUI::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use HTML::Entities;
use strict;
use Tie::CPHash;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;
use XML::RSSLite;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			rssUrl=>{},
			templateId=>{
                                defaultValue=>1
                                }
			}
                );
        bless $self, $class;
}


#-------------------------------------------------------------------
sub uiLevel {
        return 6;
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	$properties->url(
		-name=>"rssUrl",
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("rssUrl")
		);
	$layout->template(
                -name=>"templateId",
                -value=>$_[0]->getValue("templateId"),
                -namespace=>$_[0]->get("namespace"),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-headingId=>4,
		-helpId=>1
		);
}


#-------------------------------------------------------------------
sub www_view {
	my %rss;
	my $cache = WebGUI::Cache->new($_[0]->get("rssUrl"),"URL");
	my $rssFile = $cache->get;
	unless (defined $rssFile) {
		$rssFile = $cache->setByHTTP($_[0]->get("rssUrl"),3600);
	}
	$rssFile =~ s#(<title>)(.*?)(</title>)#$1.encode_entities(decode_entities($2)).$3#ges; 
	eval{parseRSS(\%rss, \$rssFile)};
	if ($@) {
		WebGUI::ErrorHandler::warn($_[0]->get("rssUrl")." ".$@);
	}
	my %var;
	$var{"channel.title"} = $rss{title};
	$var{"channel.link"} = $rss{link};
	$var{"channel.description"} = $rss{description};
	my @items;
        foreach my $item (@{$rss{item}}) {
		push (@items,{
			link=>$item->{link},
			title=>$item->{title},
			description=>$item->{description}
			});
	}
	$var{item_loop} = \@items;
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}


1;

