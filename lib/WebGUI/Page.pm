package WebGUI::Page;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Persistent::Tree;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Persistent::Tree);

=head1 NAME

Package WebGUI::Page

=head1 DESCRIPTION

This package provides utility functions for WebGUI's page system.

=head1 SYNOPSIS

 use WebGUI::Page;
 $integer = WebGUI::Page::countTemplatePositions($templateId);
 $html = WebGUI::Page::drawTemplate($templateId);
 $html = WebGUI::Page::generate();
 $hashRef = WebGUI::Page::getTemplateList();
 $template = WebGUI::Page::getTemplate();
 $hashRef = WebGUI::Page::getTemplatePositions($templateId);
 $url = WebGUI::Page::makeUnique($url,$pageId);

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------

sub classSettings {
     return {
          properties => {
               pageId          => { key => 1 },
               parentId        => { defaultValue => 0 },
               title           => { quote => 1 },
               styleId         => { defaultValue => 0 },
               ownerId         => { defaultValue => 0 },
               sequenceNumber  => { defaultValue => 1 },
               metaTags        => { quote => 1 },
               urlizedTitle    => { quote => 1 },
               defaultMetaTags => { defaultValue => 0 },
               menuTitle    => { quote => 1 },
               synopsis     => { quote => 1 },
               templateId   => { defaultValue => 1 },
               startDate    => { defaultValue => 946710000 },
               endDate      => { defaultValue => 2082783600 },
               redirectURL  => { quote => 1 },
               userDefined1 => { quote => 1 },
               userDefined2 => { quote => 1 },
               userDefined3 => { quote => 1 },
               userDefined4 => { quote => 1 },
               userDefined5 => { quote => 1 },
               languageId   => { defaultValue => 1 },
               groupIdView  => { defaultValue => 3 },
               groupIdEdit  => { defaultValue => 3 },
               hideFromNavigation => { defaultValue => 0 },
          },
          useDummyRoot => 1,
          table => 'page'
     }
}

#-------------------------------------------------------------------

=head2 countTemplatePositions ( templateId ) 

Returns the number of template positions in the specified page template.

=over

=item templateId

The id of the page template you wish to count.

=back

=cut

sub countTemplatePositions {
        my ($template, $i);
        $template = getTemplate($_[0]);
        $i = 1;
        while ($template =~ m/position$i\_loop/) {
                $i++;
        }
        return $i-1;
}

#-------------------------------------------------------------------

=head2 deCache ( [ pageId ] )

Deletes the cached version of a specified page.

=over

=item pageId

The id of the page to decache. Defaults to the current page id.

=back

=cut

sub deCache {
	my $cache = WebGUI::Cache->new;
	my $pageId = $_[0] || $session{page}{pageId};
	$cache->deleteByRegex("m/^page_".$pageId."_\\d+\$/");
}

#-------------------------------------------------------------------

=head2 drawTemplate ( templateId )

Returns an HTML string containing a small representation of the page template.

=over

=item templateId

The id of the page template you wish to draw.

=back

=cut

sub drawTemplate {
	my $template = getTemplate($_[0]);
	$template =~ s/\n//g;
	$template =~ s/\r//g;
	$template =~ s/\'/\\\'/g;
	$template = WebGUI::Macro::negate($template);
	$template =~ s/\<script.*?\>.*?\<\/script\>//gi;
	$template =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
	$template =~ s/\<tmpl_loop\s+position(\d+)\_loop\>.*?\<\/tmpl\_loop\>/$1/ig;
	return $template;
}


#-------------------------------------------------------------------

=head2 generate ( )

Generates the content of the page.

=cut

sub generate {
        return WebGUI::Privilege::noAccess() unless (WebGUI::Privilege::canViewPage());
	my %var;
	$var{'page.canEdit'} = WebGUI::Privilege::canEditPage();
        $var{'page.toolbar'} = pageIcon()
       		.deleteIcon('op=deletePage')
		.editIcon('op=editPage')
		.moveUpIcon('op=movePageUp')
		.moveDownIcon('op=movePageDown')
		.cutIcon('op=cutPage');
	my $sth = WebGUI::SQL->read("select * from wobject where pageId=".$session{page}{pageId}." order by sequenceNumber, wobjectId");
        while (my $wobject = $sth->hashRef) {
		my $wobjectToolbar = wobjectIcon()
         		.deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
              		.editIcon('func=edit&wid='.${$wobject}{wobjectId})
             		.moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
             		.moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
              		.moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
              		.moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
            		.cutIcon('func=cut&wid='.${$wobject}{wobjectId})
            		.copyIcon('func=copy&wid='.${$wobject}{wobjectId});
             	if (${$wobject}{namespace} ne "WobjectProxy" && isIn("WobjectProxy",@{$session{config}{wobjects}})) {
             		$wobjectToolbar .= shortcutIcon('func=createShortcut&wid='.${$wobject}{wobjectId});
         	}
       		if (${$wobject}{namespace} eq "WobjectProxy") {
          		my $originalWobject = $wobject;
      			my ($wobjectProxy) = WebGUI::SQL->quickHashRef("select * from WobjectProxy where wobjectId=".${$wobject}{wobjectId});
        		$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$wobjectProxy->{proxiedWobjectId});
           		if (${$wobject}{namespace} eq "") {
             			$wobject = $originalWobject;
         		} else {
           			${$wobject}{startDate} = ${$originalWobject}{startDate};
          			${$wobject}{endDate} = ${$originalWobject}{endDate};
          			${$wobject}{templatePosition} = ${$originalWobject}{templatePosition};
             			${$wobject}{_WobjectProxy} = ${$originalWobject}{wobjectId};
           			if ($wobjectProxy->{overrideTitle}) {
             				${$wobject}{title} = ${$originalWobject}{title};
            			}
         			if ($wobjectProxy->{overrideDisplayTitle}) {
           				${$wobject}{displayTitle} = ${$originalWobject}{displayTitle};
           			}
        			if ($wobjectProxy->{overrideDescription}) {
         				${$wobject}{description} = ${$originalWobject}{description};
         			}
         			if ($wobjectProxy->{overrideTemplate}) {
       					${$wobject}{templateId} = $wobjectProxy->{proxiedTemplateId};
       				}
        		}
      		}
                my $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
                my $w = eval{$cmd->new($wobject)};
                WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root cause: ".$@) if($@);
		push(@{$var{'position'.$wobject->{templatePosition}.'_loop'}},{
                        'wobject.canView'=>WebGUI::Privilege::canViewWobject($wobject->{wobjectId}),
        		'wobject.canEdit'=>WebGUI::Privilege::canEditWobject($wobject->{wobjectId}),
			'wobject.toolbar'=>$wobjectToolbar,
			'wobject.namespace'=>$wobject->{namespace},
			'wobject.id'=>$wobject->{wobjectId},
			'wobject.isInDateRange'=>$w->inDateRange,
			'wobject.content'=>eval{$w->www_view}
			});
		WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace}. Root cause: ".$@) if($@);
	}
	$sth->finish;
	return WebGUI::Template::process(getTemplate(),\%var);
}


#-------------------------------------------------------------------

=head2 getTemplateList

Returns a hash reference containing template ids and template titles for all the page templates available in the system. 

=cut

sub getTemplateList {
	return WebGUI::Template::getList("page");
}

#-------------------------------------------------------------------

=head2 getTemplate ( [ templateId ] )

Returns an HTML template.

=over

=item templateId

The id of the page template you wish to retrieve. Defaults to the current page's template id.

=back

=cut

sub getTemplate {
	my $templateId = $_[0] || $session{page}{templateId};
	return WebGUI::Template::get($templateId,"page");
}

#-------------------------------------------------------------------

=head2 getTemplatePositions ( templateId ) 

Returns a hash reference containing the positions available in the specified page template.

=over

=item templateId

The id of the page template you wish to retrieve the positions from.

=back

=cut

sub getTemplatePositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	for ($i=1; $i<=countTemplatePositions($_[0]); $i++) {
		$hash{$i} = $i;
	}
	return \%hash;
}

#-------------------------------------------------------------------

=head2 makeUnique ( pageURL, pageId )

Returns a unique page URL.

=over

=item url

The URL you're hoping for.

=item pageId

The page id of the page you're creating a URL for.

=back

=cut

sub makeUnique {
        my ($url, $test, $pageId);
        $url = $_[0];
        $pageId = $_[1] || "new";
        while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$url' and pageId<>'$pageId'")) {
                if ($url =~ /(.*)(\d+$)/) {
                        $url = $1.($2+1);
                } elsif ($test ne "") {
                        $url .= "2";
                }
        }
        return $url;
}

1;

