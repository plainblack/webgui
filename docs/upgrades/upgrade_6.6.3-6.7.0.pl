#!/usr/bin/perl

use lib "../../lib";
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Asset::Snippet;
use WebGUI::Session;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

insertHelpTemplate();

insertXSLTSheets();
insertSyndicatedContentTemplate();

WebGUI::Session::close();

sub insertHelpTemplate{
    print "\tInserting new Help template\n" unless ($quiet);
    my $helpTemplate = <<EOT;
<p><tmpl_var body></p>

<tmpl_if fields>
<dl>
<tmpl_loop fields>
   <dt><tmpl_var title></dt>
      <dd><tmpl_var description></dd>
</tmpl_loop>
</dl>
</tmpl_if>
EOT

    my $folder = WebGUI::Asset->newByUrl('templates/AdminConsole');
    $folder->addChild({
		       namespace=>'AdminConsole',
		       title=>'Help',
		       menuTitle=>'Help',
		       url=>'Help',
		       showInForms=>1,
		       isEditable=>1,
		       className=>"WebGUI::Asset::Template",
		       template=>$helpTemplate},'PBtmplHelp000000000001');
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub insertSyndicatedContentTemplate{
    my $import=WebGUI::Asset->getImportNode;
    
    my $template=q|<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>

<p>
<a href="<tmpl_var rss.url.0.9>">RSS 0.90</a>
<a href="<tmpl_var rss.url.0.91>">RSS 0.91</a>
<a href="<tmpl_var rss.url.1.0>">RSS 1.0</a>
<a href="<tmpl_var rss.url.2.0>">RSS 2.0</a>
</p>
	
<tmpl_if displayTitle>
    <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
    <tmpl_var description><p />
</tmpl_if>

<h1>
<tmpl_if channel.link>
     <a href="<tmpl_var channel.link>" target="_blank"><tmpl_var channel.title></a>
<tmpl_else>
     <tmpl_var channel.title>
</tmpl_if>
</h1>

<tmpl_if channel.description>
    <tmpl_var channel.description><p />
</tmpl_if>


<tmpl_loop item_loop>

<tmpl_if new_rss_site>
<!-- We're in a new RSS group. Output the header. -->
<h2><a href="<tmpl_var site_link>" target="_blank"><tmpl_var site_title></a></h2>
</tmpl_if>

<li>
  <tmpl_if link>
       <a href="<tmpl_var link>" target="_blank"><tmpl_var title></a>    
    <tmpl_else>
       <tmpl_var title>
  </tmpl_if>
     <tmpl_if description>
        - <tmpl_var description>
     </tmpl_if>
<b><tmpl_var site_title></b>
     <br>

</tmpl_loop>|;
    my $template=$templates->addChild(
				      {
				       className=>'WebGUI::Asset::Template',
				       title=>'Default Grouped Aggregate Feeds',
				       namespace=>'SyndicatedContent',
				       menuTitle=>'Default Grouped Aggregate Feeds',
				       url=>'templates/syndicatedcontent/default_grouped_feeds',
				       ownerUserID=>3,
				       groupIdView=>7,
				       groupIdEdit=>4,
				       isHidden=>1,
				       template=>$template
				      },'DPUROtmpl0000000000001'
				     );
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub insertXSLTSheets{
    my $collateral=WebGUI::Asset->newByUrl('collateral');
    
    my $folder=$collateral->addChild(
				     {
				      className=>'WebGUI::Asset::Wobject::Folder',
				      title=>'Syndicated Content XSLT',
				      menuTitle=>'Syndicated Content XSLT',
				      url=>'xslt',
				      startDate=>time(),
				      endDate=>time()+ 60*60*24*365*10,
				      groupEditId=>4,
				      groupViewId=>2
				     }
				    );
    add_090xslt($folder);
    add_091xslt($folder);
    add_10xslt($folder);
    add_20xslt($folder);
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub add_090xslt{
    my $folder=shift;
    my $snippet090=q|<?xml version="1.0"?>
<!--
  Based on XSLT stylesheets originally designed by Rich Manalang (http://manalang.com)
  This XSLT sheet will convert any valid RSS 0.9 feed into basic HTML.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:foo="http://my.netscape.com/rdf/simple/0.9/">
  <xsl:output method="html"/>
  <xsl:template match="/">
    <style>
      <xsl:comment>
        .syndication-content-area {
        }
        .syndication-title {
        font-size: 1.1em;
        font-weight: bold;
        }
        .syndication-description {
        font-size: .9em;
        margin: 0 0 10px 0;
        }
        .syndication-list {
        font-size: .8em;
        margin:0 0 0 20px;
        }
        .syndication-list-item {
        margin: 0 0 5px 0;
        }
        .syndication-list-item a,
        .syndication-list-item a:link {
        color: blue;
        }
        .syndication-list-item a:active,
        .syndication-list-item a:hover {
        color: red;
        }
        li.syndication-list-item{
        padding-bottom: .2em;
        background-color: #e4e4e4;
        }
        .syndication-list-item a:visited {
        color: black;
        text-decoration: none;
        }
        .syndication-list-item-date {
        font-size: .8em;
        }
        .syndication-list-item-description {
        font-size: .9em;
        }
      </xsl:comment>
    </style>
    <xsl:apply-templates select="/rdf:RDF/foo:channel"/>
  </xsl:template>
  <xsl:template match="/rdf:RDF/foo:channel">
You're viewing an <a href="http://www.purplepages.ie/RSS/netscape/rss0.90.html">RSS version 0.9 feed</a>. Please use an RSS feed reader to view this content as intended.
    <div class="syndication-content-area">
      <div class="syndication-title">
        <xsl:value-of select="foo:title"/>
      </div>
      <div class="syndication-description">
        <xsl:value-of select="foo:description"/>
      </div>
      <ul class="syndication-list">
        <xsl:apply-templates select="/rdf:RDF/foo:item"/>
      </ul>
    </div>
  </xsl:template>
  <xsl:template match="/rdf:RDF/foo:item">
    <li class="syndication-list-item">
      <a href="{foo:link}" title="{foo:description}">
        <xsl:value-of select="foo:title"/>
      </a>
    </li>
  </xsl:template>
</xsl:stylesheet>|;
    
    my $snippet=$folder->addChild(
				  {
				   className=>'WebGUI::Asset::Snippet',
				   title=>'RSS 0.9 XSLT Stylesheet',
				   menuTitle=>'RSS 0.9 XSLT ',
				   url=>'xslt/rss0.9.xsl',
				   mimeType=>'application/xml',
				   startDate=>time(),
				   endDate=>time()+ 60*60*24*365*10,
				   groupEditId=>4,
				   groupViewId=>2,
				   snippet=>$snippet090
				  },'SynConXSLT000000000001'
				 );
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub add_091xslt{
    my $folder=shift;
    my $snippet091=q|<?xml version="1.0"?>
<!--
  Title: RSS 0.91, 0.92, 0.93 XSL Template
  Author: Rich Manalang (http://manalang.com)
  Description: This sample XSLT will convert any valid RSS 0.91, 0.92, or 0.93 feed to HTML.
-->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:wfw="http://wellformedweb.org/CommentAPI/">
 	<xsl:output method="html"/>
	<xsl:template match="/">
		<style>
			<xsl:comment>
			.syndication-content-area {
			}
			.syndication-title {
				font-size: 1.1em;
				font-weight: bold;
			}
			.syndication-description {
				font-size: .9em;
				margin: 0 0 10px 0;
			}
			.syndication-list {
				font-size: .8em;
				margin:0 0 0 20px;
			}
                        li.syndication-list-item{
                        padding-bottom: .2em;
                        background-color: #e4e4e4;
                        }
			.syndication-list-item {
				margin: 0 0 5px 0;
			}
			.syndication-list-item a,
			.syndication-list-item a:link {
				color: blue;
			}
			.syndication-list-item a:active,
			.syndication-list-item a:hover {
				color: red;
			}
			.syndication-list-item a:visited {
				color: black;
				text-decoration: none;
			}
			.syndication-list-item-date {
				font-size: .8em;
			}
			.syndication-list-item-description {
				font-size: .9em;
			}
			</xsl:comment>
		</style>
		<xsl:apply-templates select="/rss/channel"/>
	</xsl:template>
	<xsl:template match="/rss/channel">
		<div class="syndication-content-area">
You're viewing an <a href="http://backend.userland.com/rss091">RSS version 0.91 feed</a>. Please use an RSS feed reader to view this content as intended.
			<div class="syndication-title">
				<xsl:value-of select="title"/>
			</div>
			<div class="syndication-description">
				<xsl:value-of select="description"/>
			</div>
			<ul class="syndication-list">
				<xsl:apply-templates select="item"/>
			</ul>

		</div>
	</xsl:template>
	<xsl:template match="/rss/channel/item">
		<li class="syndication-list-item">
			<a href="{link}" title="{description}">
				<xsl:value-of select="title"/>
			</a>
			<div class="syndication-list-item-description">
				<xsl:value-of select="description"/>

			</div>
		</li>
	</xsl:template>
</xsl:stylesheet>|;
    
    my $snippet=$folder->addChild(
				  {
				   className=>'WebGUI::Asset::Snippet',
				   title=>'RSS 0.91 XSLT Stylesheet',
				   menuTitle=>'RSS 0.91 XSLT',
				   url=>'xslt/rss0.91.xsl',
				   mimeType=>'application/xml',
				   startDate=>time(),
				   endDate=>time()+ 60*60*24*365*10,
				   groupEditId=>4,
				   groupViewId=>2,
				   snippet=>$snippet091
				  },'SynConXSLT000000000002'
				 );
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub add_10xslt{
    my $folder=shift;
    my $snippet10=q|<?xml version="1.0" encoding="utf-8"?>
<!--
  Title: RSS 1.0 XSL Template
  Author: Rich Manalang (http://manalang.com)
  Description: This sample XSLT will convert any valid RSS 1.0 feed to HTML.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:foo="http://purl.org/rss/1.0/">
  	<xsl:output method="html"/>
	<xsl:template match="/">
		<style>
			<xsl:comment>
			.syndication-content-area {
			}
			.syndication-title {
				font-size: 1.1em;
				font-weight: bold;
			}
			.syndication-description {
				font-size: .9em;
				margin: 0 0 10px 0;
			}
			.syndication-list {
				font-size: .8em;
				margin:0 0 0 20px;
			}
			.syndication-list-item {
				margin: 0 0 5px 0;
			}
                        li.syndication-list-item{
                        padding-bottom: .2em;
                        background-color: #e4e4e4;
                        }
			.syndication-list-item a,
			.syndication-list-item a:link {
				color: blue;
			}
			.syndication-list-item a:active,
			.syndication-list-item a:hover {
				color: red;
			}
			.syndication-list-item a:visited {
				color: black;
				text-decoration: none;
			}
			.syndication-list-item-date {
				font-size: .8em;
			}
			.syndication-list-item-description {
				font-size: .9em;
			}
			</xsl:comment>
		</style>
		<xsl:apply-templates select="/rdf:RDF/foo:channel"/>
	</xsl:template>
	<xsl:template match="/rdf:RDF/foo:channel">
		<div class="syndication-content-area">
You're viewing an <a href="http://web.resource.org/rss/1.0/">RSS version 1.0 feed</a>. Please use an RSS feed reader to view this content as intended.
			<div class="syndication-title">
				<xsl:value-of select="foo:title"/>
			</div>
			<div class="syndication-description">
				<xsl:value-of select="foo:description"/>
			</div>
			<ul class="syndication-list">
				<xsl:apply-templates select="/rdf:RDF/foo:item"/>
			</ul>

		</div>
	</xsl:template>
	<xsl:template match="/rdf:RDF/foo:item">
		<li class="syndication-list-item">
			<a href="{foo:link}" title="{foo:description}">
				<xsl:value-of select="foo:title"/>
			</a>
			<span class="syndication-list-item-date">
						(
				<xsl:value-of select="dc:date"/>)
			</span>

			<div class="syndication-list-item-description">
				<xsl:value-of select="foo:description"/>
			</div>
		</li>
	</xsl:template>
</xsl:stylesheet>
|;
    my $snippet=$folder->addChild(
				  {
				   className=>'WebGUI::Asset::Snippet',
				   title=>'RSS 1.0 XSLT Stylesheet',
				   menuTitle=>'RSS 1.0 XSLT',
				   mimeType=>'application/xml',
				   url=>'xslt/rss1.0.xsl',
				   startDate=>time(),
				   endDate=>time()+ 60*60*24*365*10,
				   groupEditId=>4,
				   groupViewId=>2,
				   snippet=>$snippet10
				  },'SynConXSLT000000000003'
				 );
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub add_20xslt{
    my $folder=shift;
    my $snippet20=q|<?xml version="1.0"?>
<!--
  Title: RSS 2.0 XSL Template
  Author: Rich Manalang (http://manalang.com)
  Description: This sample XSLT will convert any valid RSS 2.0 feed to HTML.
-->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:wfw="http://wellformedweb.org/CommentAPI/">
 	<xsl:output method="html"/>
	<xsl:template match="/">
		<style>
			<xsl:comment>
			.syndication-content-area {
			}
			.syndication-title {
				font-size: 1.1em;
				font-weight: bold;
			}
			.syndication-description {
				font-size: .9em;
				margin: 0 0 10px 0;
			}
			.syndication-list {
				font-size: .8em;
				margin:0 0 0 20px;
			}
			.syndication-list-item {
				margin: 0 0 5px 0;
			}
                        li.syndication-list-item{
                        padding-bottom: .2em;
                        background-color: #e4e4e4;
                        }
			.syndication-list-item a,
			.syndication-list-item a:link {
				color: blue;
			}
			.syndication-list-item a:active,
			.syndication-list-item a:hover {
				color: red;
			}
			.syndication-list-item a:visited {
				color: black;
				text-decoration: none;
			}
			.syndication-list-item-date {
				font-size: .8em;
			}
			.syndication-list-item-description {
				font-size: .9em;
			}
			</xsl:comment>
		</style>
		<xsl:apply-templates select="/rss/channel"/>
	</xsl:template>
	<xsl:template match="/rss/channel">
		<div class="syndication-content-area">
You're viewing an <a href="http://blogs.law.harvard.edu/tech/rss">RSS version 2.0 feed</a>. Please use an RSS feed reader to view this content as intended.
			<div class="syndication-title">
				<xsl:value-of select="title"/>
			</div>
			<div class="syndication-description">
				<xsl:value-of select="description"/>
			</div>
			<ul class="syndication-list">
				<xsl:apply-templates select="item"/>
			</ul>

		</div>
	</xsl:template>
	<xsl:template match="/rss/channel/item">
		<li class="syndication-list-item">
			<a href="{link}" title="{description}">
				<xsl:value-of select="title"/>
			</a>
			<span class="syndication-list-item-date">
		 		(<xsl:value-of select="pubDate"/>)
			</span>

			<div class="syndication-list-item-description">
				<xsl:value-of select="description"/>
			</div>
		</li>
	</xsl:template>
</xsl:stylesheet>|;
    
    my $snippet=$folder->addChild(
				  {
				   className=>'WebGUI::Asset::Snippet',
				   title=>'RSS 2.0 XSLT Stylesheet',
				   menuTitle=>'RSS 2.0 XSLT',
				   url=>'xslt/rss2.0.xsl',
				   mimeType=>'application/xml',
				   startDate=>time(),
				   endDate=>time()+ 60*60*24*365*10,
				   groupEditId=>4,
				   groupViewId=>2,
				   snippet=>$snippet20
				  },'SynConXSLT000000000004'
				 );
}



