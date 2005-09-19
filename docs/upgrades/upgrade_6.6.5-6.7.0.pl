my $toVersion = "6.7.0";

use lib "../../lib";
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Asset::Snippet;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Group;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);
WebGUI::Session::refreshUserInfo(3);

WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");

giveSnippetsMimeTypes();
addAssetVersioning();
updateConfigFile();
insertHelpTemplate();
makeSyndicatedContentChanges();
removeOldThemeSystem();
addSectionsToSurveys();
increaseProxyUrlLength();
upgradeRichEdit();

WebGUI::Session::close();

#-------------------------------------------------
sub upgradeRichEdit {
	print "\tUpgrade rich editor to version 1.45.\n" unless ($quiet);
	WebGUI::SQL->write("update RichEdit set extendedValidElements='*[*]' where assetId='PBrichedit000000000001'");
	my $prepend = 'a[name|href|target|title],strong/b[class],em\/i[class],strike[class],u[class],p[dir|class|align],ol,ul,li,br,img[class|src|border=0|alt|title|hspace|vspace|width|height|align],sub,sup,blockquote[dir|style],table[border=0|cellspacing|cellpadding|width|height|class|align],tr[class|rowspan|width|height|align|valign],td[dir|class|colspan|rowspan|width|height|align|valign],div[dir|class|align],span[class|align],pre[class|align],address[class|align],h1[dir|class|align],h2[dir|class|align],h3[dir|class|align],h4[dir|class|align],h5[dir|class|align],h6[dir|class|align],hr';
	WebGUI::SQL->write("update RichEdit set extendedValidElements=concat(".quote($prepend).",',',extendedValidElements) where assetId<>'PBrichedit000000000001'");
	WebGUI::SQL->write("alter table RichEdit change extendedValidElements validElements mediumtext");
}


#-------------------------------------------------
sub increaseProxyUrlLength {
	print "\tMaking HTTP Proxy URLs accept lengths of up to 2048 characters.\n" unless ($quiet);
	WebGUI::SQL->write("alter table HttpProxy change proxiedUrl proxiedUrl text");
}

#-------------------------------------------------
sub giveSnippetsMimeTypes {
	print "\tAllowing snippets to handle mime types.\n" unless ($quiet);
	WebGUI::SQL->write("alter table snippet add column mimeType varchar(50) not null default 'text/html'");
}


#-------------------------------------------------
sub removeOldThemeSystem {
	print "\tRemoving the old theme system.\n" unless ($quiet);
	WebGUI::SQL->write("drop table theme");
	WebGUI::SQL->write("drop table themeComponent");
	WebGUI::Group->new('9')->delete;
}

#-------------------------------------------------
sub makeSyndicatedContentChanges {
	print "\tMaking changes to the syndicated content asset.\n" unless ($quiet);
	WebGUI::SQL->write("alter table SyndicatedContent add column displayMode varchar(20) not null default 'interleaved'");
	WebGUI::SQL->write("alter table SyndicatedContent add column hasTerms varchar(255) not null");
	insertXSLTSheets();
	insertSyndicatedContentTemplate();
}

#-------------------------------------------------
sub addSectionsToSurveys {
	print "\tAdding sections to Surveys.\n" unless ($quiet);
	WebGUI::SQL->write("alter table Survey_question add column Survey_sectionId varchar(22) null");
	WebGUI::SQL->write("create table Survey_section (Survey_id varchar(22) null, Survey_sectionId varchar(22) not null, sectionName text null, sequenceNumber int(11) not null default 1, primary key (Survey_sectionId))");
	my $template = q|<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>	
		<tmpl_if displayTitle>
    <h1><tmpl_var title></h1>
</tmpl_if>


<tmpl_if description>
  <tmpl_var description><p />
</tmpl_if>


<tmpl_if user.canTakeSurvey>
	<tmpl_if response.isComplete>
		<tmpl_if mode.isSurvey>
			<tmpl_var thanks.survey.label>
		<tmpl_else>
			<tmpl_var thanks.quiz.label>
			<div align="center">
				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>
				<br />
				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% 
			</div>
		</tmpl_if>
		<tmpl_if user.canRespondAgain>
			<br /> <br /> <a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	<tmpl_else>
		<tmpl_if response.id>
			<tmpl_var form.header>
			<table width="100%" cellpadding="3" cellspacing="0" border="0" class="content">
				<tr>
					<td valign="top">
					<tmpl_loop question_loop>
						<p><tmpl_var question.question></p>
						<tmpl_var question.answer.label><br />
						<tmpl_var question.answer.field><br />
						<br />
						<tmpl_if question.allowComment>
							<tmpl_var question.comment.label><br />
							<tmpl_var question.comment.field><br />
						</tmpl_if>
					</tmpl_loop>
					</td>
					<td valign="top" nowrap="1">
						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />
						<tmpl_unless mode.isSurvey>
							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />
							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />
						</tmpl_unless>
					</td>
				</tr>
			</table>
			<div align="center"><tmpl_var form.submit></div>
			<tmpl_var form.footer>
		<tmpl_else>
			<a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	</tmpl_if>
<tmpl_else>
	<tmpl_if mode.isSurvey>
		<tmpl_var survey.noprivs.label>
	<tmpl_else>
		<tmpl_var quiz.noprivs.label>
	</tmpl_if>
</tmpl_if>
<br />
<br />
<tmpl_if user.canViewReports>
	<a href="<tmpl_var report.gradebook.url>"><tmpl_var report.gradebook.label></a> 
	&bull;
	<a href="<tmpl_var report.overview.url>"><tmpl_var report.overview.label></a> 
	&bull;
	<a href="<tmpl_var delete.all.responses.url>"><tmpl_var delete.all.responses.label></a> 
	<br />
	<a href="<tmpl_var export.answers.url>"><tmpl_var export.answers.label></a> 
	&bull;
	<a href="<tmpl_var export.questions.url>"><tmpl_var export.questions.label></a> 
	&bull;
	<a href="<tmpl_var export.responses.url>"><tmpl_var export.responses.label></a> 
	&bull;
	<a href="<tmpl_var export.composite.url>"><tmpl_var export.composite.label></a> 
</tmpl_if>


<tmpl_if session.var.adminOn>
	<p>
		<a href="<tmpl_var question.add.url>"><tmpl_var question.add.label></a>
	</p>
		<p><a href="<tmpl_var section.add.url>"><tmpl_var section.add.label></a></p>

	<tmpl_loop section.edit_loop>
		<tmpl_var section.edit.controls>
          	<b><tmpl_var section.edit.sectionName></b>
		<br />
<tmpl_loop section.questions_loop>
&nbsp;&nbsp;&nbsp;<tmpl_var question.edit.controls><tmpl_var question.edit.question>
		</tmpl_loop>
	<br />
        </tmpl_loop>
	
	
</tmpl_if> |; 
	my $properties = { 'template' => $template };
	my $currentVersion = WebGUI::Asset::Template->new('PBtmpl0000000000000061');
	my $newVersion = $currentVersion->addRevision($properties);
	

}

#-------------------------------------------------
sub updateConfigFile {
	print "\tUpdating config file.\n" unless ($quiet);
	my $pathToConfig = '../../etc/'.$configFile;
	my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig, 'PURGE'=>1);
	my %newConfig;
	foreach my $key ($conf->directives) { # delete unwanted stuff
        	unless ($key eq "wobject") {
                	$newConfig{$key} = $conf->get($key);
        	}
	}
	$newConfig{fileCacheSizeLimit} = 100000000;
	$newConfig{DeleteExpiredRevisions_offset} = 365;
	$conf->purge;
	$conf->set(%newConfig);
	$conf->write;
}

#-------------------------------------------------
sub addAssetVersioning {
    	print "\tMaking changes for asset versioning\n" unless ($quiet);
	WebGUI::SQL->write("insert into settings values ('autoCommit','1')");
	WebGUI::SQL->write("create table assetVersionTag (
		tagId varchar(22) not null primary key,
		name varchar(255) not null,
		isCommitted int not null default 0,
		creationDate bigint not null default 0,
		createdBy varchar(22),
		commitDate bigint not null default 0,
		committedBy varchar(22)
		)");
	my $now = time();
	WebGUI::SQL->write("insert into assetVersionTag values ('pbversion0000000000001','Initial Import','1',$now,'3',$now,'3')");
	WebGUI::SQL->write("insert into assetVersionTag values ('pbversion0000000000002','Auto Commit','1',$now,'3',$now,'3')");
	foreach my $table (qw(FileAsset Post RichEdit snippet EventsCalendar_event ImageAsset Thread redirect Shortcut template Article EventsCalendar IndexedSearch MessageBoard SQLReport Folder Navigation Survey WSClient Collaboration HttpProxy Layout Poll SyndicatedContent Product DataForm wobject)) {
		WebGUI::SQL->write("alter table $table add column revisionDate bigint not null");
		WebGUI::SQL->write("update $table set revisionDate=$now");
		WebGUI::SQL->write("alter table $table drop primary key");
		WebGUI::SQL->write("alter table $table add primary key (assetId,revisionDate)");
	}	
	WebGUI::SQL->write("create table assetData (
		assetId varchar(22) not null,
		revisionDate bigint not null,
		revisedBy varchar(22) not null,
		tagId varchar(22) not null,
		status varchar(35) not null default 'pending',
		title varchar(255) not null default 'untitled',
		menuTitle varchar(255) not null default 'untitled',
		url varchar(255) not null,
		ownerUserId varchar(22) not null default '3',
		groupIdView varchar(22) not null default '7',
		groupIdEdit varchar(22) not null default '4',
		startDate bigint not null default 997995720,
		endDate bigint not null default 32472169200,
		synopsis text,
		newWindow int not null default 0,
		isHidden int not null default 0,
		isPackage int not null default 0,
		isPrototype int not null default 0,	
		encryptPage int not null default 0,
		assetSize int not null default 0,
		extraHeadTags text,
		primary key (assetId,revisionDate)
		)");
	my $statement = WebGUI::SQL->prepare("insert into assetData values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	my $sth = WebGUI::SQL->read("select * from asset");
	while (my $data = $sth->hashRef) {
		$statement->execute([
			$data->{assetId},
			$now,
			'3',
			'pbversion0000000000001',
			'approved',
			$data->{title},
			$data->{menuTitle},
			$data->{url},
			$data->{ownerUserId},
			$data->{groupIdView},
			$data->{groupIdEdit},
			$data->{startDate},
			$data->{endDate},
			$data->{synopsis},
			$data->{newWindow},
			$data->{isHidden},
			$data->{isPackage},
			$data->{isPrototype},
			$data->{encryptPage},
			$data->{assetSize},
			$data->{extraHeadTags}
			]);
	}
	$sth->finish;
	WebGUI::SQL->write("alter table asset add column creationDate bigint not null default 997995720");
	WebGUI::SQL->write("alter table asset add column createdBy varchar(22) not null default '3'");
	WebGUI::SQL->write("alter table asset add column stateChanged varchar(22) not null default 997995720");
	WebGUI::SQL->write("alter table asset add column stateChangedBy varchar(22) not null default '3'");
	WebGUI::SQL->write("alter table asset add column isLockedBy varchar(22)");
	WebGUI::SQL->write("update asset set creationDate=$now, createdBy='3'");
	foreach my $field (qw(url groupIdView title menuTitle startDate endDate ownerUserId groupIdEdit synopsis newWindow isHidden isSystem encryptPage assetSize lastUpdated lastUpdatedBy isPackage extraHeadTags isPrototype)) {
		WebGUI::SQL->write("alter table asset drop column $field");
	}
	# clean up the psuedo version tracking in files
	$sth = WebGUI::SQL->read("select olderVersions from FileAsset");
	while (my ($old) = $sth->array) {
		foreach my $storageId (split("\n",$old)) {
			next unless ($storageId);
			WebGUI::Storage->get($storageId)->delete;
		}
	}
	$sth->finish;
	WebGUI::SQL->write("alter table FileAsset drop column olderVersions");
	my $writeStatus = WebGUI::SQL->prepare("update assetData set status=? where assetId=? and revisionDate=?");
	my $sth = WebGUI::SQL->read("select status,assetId,revisionDate from Post");
	while (my ($status,$id,$version) = $sth->array) {
		$writeStatus->execute([$status,$id,$version]);
	}
	$sth->finish;
	$writeStatus->finish;
	WebGUI::SQL->write('alter table Post drop column status');
}

#-------------------------------------------------
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
    my $import=WebGUI::Asset->getImportNode;
    my $folder = $import->addChild({
				    title=>"6.7.0 Help System Template",
				    menuTitle=>"6.7.0 Help System Template",
				    url=>"6-7-0HelpSystemTemplate",
				    className=>"WebGUI::Asset::Wobject::Folder"
				   });
	$folder->commit;
    $folder->addChild({
		       namespace=>'AdminConsole',
		       title=>'Help',
		       menuTitle=>'Help',
		       url=>'Help',
		       showInForms=>1,
		       isEditable=>1,
		       className=>"WebGUI::Asset::Template",
		       template=>$helpTemplate},'PBtmplHelp000000000001')->commit;
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub insertSyndicatedContentTemplate{
    print "\tInserting new syndicated content template\n" unless ($quiet);

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

    my $import=WebGUI::Asset->getImportNode;
    $import->addChild(
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
				  )->commit;
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub insertXSLTSheets{
    print "\tInserting syndicated content XSLT\n" unless ($quiet);
    my $import=WebGUI::Asset->getImportNode;
    
    my $folder=$import->addChild(
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
	$folder->commit;
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
	$snippet->commit;
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
	$snippet->commit;
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
	$snippet->commit;
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
	$snippet->commit;
}



