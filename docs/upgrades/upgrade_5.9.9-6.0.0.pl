#!/usr/bin/perl

use lib "../../lib";
use File::Path;
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Forum;
use WebGUI::Macro;

my $configFile;
my $quiet;
GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);
WebGUI::Session::open("../..",$configFile);


#--------------------------------------------
print "\tMigrating styles.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from style");
while (my $style = $sth->hashRef) {
	if ($style->{styleId} == 3) {
		$style->{body} =~ s/styles\/plainblack\/logo-white\.gif/plainblack.gif/ixsg;
		$style->{body} =~ s/2001-2002/2001-2004/ixsg;
		$style->{body} =~ s/Plain\s+Black\s+Software/Plain Black LLC/ixsg;
	}
	my ($header,$footer) = split(/\^\-\;/,$style->{body});
	my ($newStyleId) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='style'");
       	if ($style->{styleId} > 0 && $style->{styleId} < 25) {
		$newStyleId = $style->{styleId};
	} elsif ($newStyleId > 999) {
       		$newStyleId++;
     	} else {
     		$newStyleId = 1000;
	}
	my $newStyle = $session{setting}{docTypeDec}.'
		<html>
		<head>
			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>
			<tmpl_var head.tags>
		'.$style->{styleSheet}.'
		</head>
		'.$header.'
			<tmpl_var body.content>
		'.$footer.'
		</html>
		';
	WebGUI::SQL->write("insert into template (templateId, name, template, namespace) values (".$newStyleId.",
		".quote($style->{name}).", ".quote($newStyle).", 'style')");
	WebGUI::SQL->write("update page set styleId=".$newStyleId." where styleId=".$style->{styleId});
	WebGUI::SQL->write("update themeComponent set id=".$newStyleId.", type='template' where id=".$style->{styleId}." and type='style'");
}
$sth->finish;
WebGUI::SQL->write("delete from incrementer where incrementerId='styleId'");
WebGUI::SQL->write("delete from settings where name='docTypeDec'");
WebGUI::SQL->write("drop table style");
WebGUI::SQL->write("alter table template add column isEditable int not null default 1");
WebGUI::SQL->write("alter table template add column showInForms int not null default 1");
WebGUI::SQL->write("update template set showInForms=0 where namespace='style' and templateId=10");
WebGUI::SQL->write("update template set isEditable=0, showInForms=0 where namespace='style' and templateId in (1,2,4,5)");
WebGUI::SQL->write("insert into template (templateId, name, template, namespace, isEditable, showInForms) values (6,'Empty','<tmpl_var body.content>','style',0,0)");

my @templateManagers = WebGUI::SQL->buildArray("select userId from groupings where groupId=8");
my $clause;
if ($#templateManagers > 0) {
	$clause = "and userId not in (".join(",",@templateManagers).")";	
}
$sth = WebGUI::SQL->read("select userId,expireDate,groupAdmin from groupings where groupId=5 ".$clause);
while (my $user = $sth->hashRef) {
	WebGUI::SQL->write("insert into groupings (groupId,userId,expireDate,groupAdmin) values (8, ".$user->{userId}.", 
		".$user->{expireDate}.", ".$user->{groupAdmin}.")");
}
$sth->finish;
WebGUI::SQL->write("delete from groups where groupId=5");
WebGUI::SQL->write("delete from groupings where groupId=5");


#--------------------------------------------
print "\tMigrating extra columns to page templates.\n" unless ($quiet);
my $a = WebGUI::SQL->read("select a.wobjectId, a.templatePosition, a.sequenceNumber,  a.pageId, b.templateId, c.width, c.class, c.spacer from wobject a 
	, page b , ExtraColumn c where a.pageId=b.pageId and a.wobjectId=c.wobjectId and a.namespace='ExtraColumn'");
while (my $data = $a->hashRef) {
	my ($template, $name) = WebGUI::SQL->quickArray("select template,name from template where namespace='Page' and templateId=".$data->{templateId});
	$name .= " w/ Extra Column";
	#eliminate the need for compatibility with old-style page templates
	$template =~ s/\^(\d+)\;/_positionFormat5x($1)/eg;
	my $i = 1;
        while ($template =~ m/page\.position$i/) {
                $i++;
        }
        my $position = $i;	
	my $replacement = '<tmpl_var page.position'.$data->{templatePosition}.'></td><td width="'.$data->{spacer}
		.'"></td><td width="'.$data->{width}.'" class="'.$data->{class}.'" valign="top"><tmpl_var page.position'.$position.'>';
	my $spliton = "<tmpl_var page.position".$data->{templatePosition}.">";
	my @parts = split(/$spliton/, $template);
	$template = $parts[0].$replacement.$parts[1];
	my ($id) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='Page'");
	$id++;
	WebGUI::SQL->write("insert into template (templateId, name, template, namespace) values ($id, ".quote($name).", ".quote($template).", 'Page')");
	WebGUI::SQL->write("update page set templateId=$id where pageId=".$data->{pageId});
	WebGUI::SQL->write("update wobject set templatePosition=".$position." where pageId=".$data->{pageId}." and templatePosition=".
		$data->{templatePosition}." and sequenceNumber>".$data->{sequenceNumber}); 
	WebGUI::SQL->write("delete from wobject where wobjectId=".$data->{wobjectId});
	my $b = WebGUI::SQL->read("select wobjectId from wobject where pageId=".$data->{pageId}." order by templatePosition,sequenceNumber");
	my $i = 0;
        while (my ($wid) = $b->array) {
                $i++;
                WebGUI::SQL->write("update wobject set sequenceNumber='$i' where wobjectId=$wid");
        }
        $b->finish;
}
$a->finish;
WebGUI::SQL->write("drop table ExtraColumn");


#--------------------------------------------
print "\tMigrating page templates.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace='Page'");
while (my $template = $sth->hashRef) {
	#eliminate the need for compatibility with old-style page templates
	$template->{template} =~ s/\^(\d+)\;/_positionFormat5x($1)/eg; 
	$template->{template} = '
		<tmpl_if session.var.adminOn>
		<style>
			div.wobject:hover {
				border: 2px ridge gray;
			}
			div.wobject {
				border: 2px hidden;
			}
			.dragable{
  position: relative;
}
.dragTrigger{
  position: relative;
  cursor: move;
}
.dragging{
  position: relative;
  cursor: hand;
  z-index: 2000; 
  background-image: url("^Extras;opaque.gif");
}
.draggedOverTop{
  position: relative;
  border: 1px dotted #aaaaaa;
  border-top: 8px #aaaaaa dotted;
}
.draggedOverBottom {
  position: relative;
  border: 1px dotted #aaaaaa;
  border-bottom: 8px #aaaaaa dotted;
}
.hidden{
  display: none;
}
.blank {
  position: relative;
  cursor: hand;
  background-color: white;
}
.blankOver {
  position: relative;
  cursor: hand;
  background-color: black;
}
.empty {
  position: relative;
  padding: 25px;
  width: 50px;
  height: 100px;
  background-image: url("^Extras;opaque.gif");
}
		</style><script language=JavaScript1.2 src="^Extras;draggable.js"></script>
		</tmpl_if>
		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
			<tmpl_var page.controls>
		</tmpl_if> </tmpl_if>
		'.$template->{template};
	$template->{template} =~ s/\<tmpl_var page\.position(\d+)\>/_positionFormat6x($1)/eg; 
	$template->{template} .= '
<tmpl_if session.var.adminOn> 

<table>
<tr id="blank" class="hidden">
<td>
<div><div class="empty">&nbsp;</div></div>
</td>
</tr>
</table>
<iframe id="dragSubmitter" style="display: none;"></iframe>
<script>
dragable_init("^\;");
</script>
</tmpl_if>
		';
	WebGUI::SQL->write("update template set namespace='page', template=".quote($template->{template})
		." where templateId=".$template->{templateId}." and namespace='Page'");
}
$sth->finish;

#--------------------------------------------
print "\tConverting items into articles.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace='Item'");
while (my $template = $sth->hashRef) {
	$template->{name} =~ s/Default (.*?)/$1/i;
       	if ($template->{templateId} < 1000) {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='Article' and templateId<1000");
		$template->{templateId}++;
	} else {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='Article'");
		if ($template->{templateId} > 999) {
       			$template->{templateId}++;
     		} else {
     			$template->{templateId} = 1000;
		}
	}
	WebGUI::SQL->write("insert into template (templateId,name,template,namespace) values (".$template->{templateId}.",
		".quote($template->{name}).", ".quote($template->{template}).", 'Article')");
}
$sth->finish;
WebGUI::SQL->write("delete from template where namespace='Item'");
WebGUI::SQL->write("update wobject set namespace='Article' where namespace='Item'");
my $sth = WebGUI::SQL->read("select * from Item");
while (my $data = $sth->hashRef) {
	WebGUI::SQL->write("insert into Article (wobjectId,linkURL,attachment) values (".$data->{wobjectId}.",
		".quote($data->{linkURL}).", ".quote($data->{attachment}).")");
}
$sth->finish;
WebGUI::SQL->write("drop table Item");


#--------------------------------------------
print "\tSequencing user submissions.\n" unless ($quiet);
WebGUI::SQL->write("alter table USS_submission add column sequenceNumber int not null");
WebGUI::SQL->write("alter table USS add column USS_id int not null");
WebGUI::SQL->write("alter table USS_submission add column USS_id int not null");
my $ussId = 1000;
my $a = WebGUI::SQL->read("select wobjectId from USS");
while (my ($wobjectId) = $a->array) {
	WebGUI::SQL->write("update USS set USS_id=$ussId where wobjectId=$wobjectId");
	my $b = WebGUI::SQL->read("select USS_submissionId from USS_submission where wobjectId=$wobjectId order by dateSubmitted");
	my $seq = 1;
	while (my ($subId) = $b->array) {
		WebGUI::SQL->write("update USS_submission set sequenceNumber=$seq, USS_id=$ussId where USS_submissionId=$subId");
		$seq++;
	}
	$b->finish;
	$ussId++;
}
$a->finish;
WebGUI::SQL->write("alter table USS_submission drop column wobjectId");
WebGUI::SQL->write("alter table USS add column submissionFormTemplateId int not null default 1");
WebGUI::SQL->write("alter table USS_submission add column contentType varchar(35) not null default 'mixed'");
WebGUI::SQL->write("update USS_submission set contentType='html' where convertCarriageReturns=0");
WebGUI::SQL->write("alter table USS_submission drop column convertCarriageReturns");
WebGUI::SQL->write("insert into incrementer (incrementerId,nextValue) values ('USS_id',$ussId)");
WebGUI::SQL->write("alter table USS_submission add column userDefined1 text");
WebGUI::SQL->write("alter table USS_submission add column userDefined2 text");
WebGUI::SQL->write("alter table USS_submission add column userDefined3 text");
WebGUI::SQL->write("alter table USS_submission add column userDefined4 text");
WebGUI::SQL->write("alter table USS_submission add column userDefined5 text");


#--------------------------------------------
print "\tConverting FAQs into USS Submissions.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace='FAQ'");
while (my $template = $sth->hashRef) {
	$template->{name} =~ s/Default (.*?)/$1/i;
       	if ($template->{templateId} < 1000) {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='USS' and templateId<1000");
		$template->{templateId}++;
	} else {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='USS'");
		if ($template->{templateId} > 999) {
       			$template->{templateId}++;
     		} else {
     			$template->{templateId} = 1000;
		}
	}
	$template->{template} =~ s/\<tmpl\_loop\s+qa\_loop\>/\<tmpl\_loop submissions\_loop\>/igs;
	my $replacement = '
		<tmpl_if submission.currentUser>
			[<a href="<tmpl_var submission.edit.url>"><tmpl_var submission.edit.label></a>]
		</tmpl_if>
		<tmpl_if canModerate>
			<tmpl_var submission.controls>
		</tmpl_if>
		';
	$template->{template} =~ s/\<tmpl\_if\s+session\.var\.adminOn\>\s*\<tmpl\_var\s+qa\.controls\>\s*\<\/tmpl_if\>/$replacement/igs;
	$replacement = ' <tmpl_if canPost>
			<a href="<tmpl_var post.url>"> ';
	$template->{template} =~ s/\<tmpl\_if\s+session\.var\.adminOn\>\s*\<a\s+href="\<tmpl\_var\s+addquestion\.url\>"\>/$replacement/igs;
	$template->{template} =~ s/\<tmpl\_var\s+qa\.question\>/\<tmpl\_var submission\.title\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+qa\.id\>/\<tmpl\_var submission\.id\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+qa\.answer\>/\<tmpl\_var submission\.content\.full\>/igs;
	WebGUI::SQL->write("insert into template (templateId,name,template,namespace) values (".$template->{templateId}.",
		".quote($template->{name}).", ".quote($template->{template}).", 'USS')");
}
$sth->finish;
WebGUI::SQL->write("delete from template where namespace='FAQ'");
my $a = WebGUI::SQL->read("select a.wobjectId,a.groupIdEdit,a.ownerId,a.lastEdited,b.username,a.dateAdded from wobject a left join users b on
	a.ownerId=b.userId where a.namespace='FAQ'");
while (my $data = $a->hashRef) {
	$data->{lastEdited} = 0 unless ($data->{lastEdited});
	$ussId = getNextId("USS_id");
	WebGUI::SQL->write("insert into USS (wobjectId,	USS_id, groupToContribute, submissionsPerPage, filterContent, sortBy, sortOrder, 
		submissionFormTemplateId) values (
		".$data->{wobjectId}.", $ussId, ".$data->{groupIdEdit}.", 1000, 'none', 'sequenceNumber', 'asc', 2)");
	my $b = WebGUI::SQL->read("select * from FAQ_question");
	while (my $sub = $b->hashRef) {
		my $subId = getNextId("USS_submissionId");
		my $forum = WebGUI::Forum->create({});
		WebGUI::SQL->write("insert into USS_submission (USS_submissionId, USS_id, title, username, userId, content, 
			dateUpdated, dateSubmitted, forumId,contentType) values ( $subId, $ussId, ".quote($sub->{question}).", 
			".quote($data->{username}).", ".$data->{ownerId}.", ".quote($sub->{answer}).", ".$data->{lastEdited}.", 
			".$data->{dateAdded}.", ".$forum->get("forumId").", 'html')");
	}
	$b->finish;
}
$a->finish;
WebGUI::SQL->write("update wobject set namespace='USS' where namespace='FAQ'");
WebGUI::SQL->write("drop table FAQ");
WebGUI::SQL->write("drop table FAQ_question");
WebGUI::SQL->write("delete from incrementer where incrementerId='FAQ_questionId'");


#--------------------------------------------
print "\tMigrating Link Lists to USS Submissions.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace='LinkList'");
while (my $template = $sth->hashRef) {
	$template->{name} =~ s/Default (.*?)/$1/i;
       	if ($template->{templateId} < 1000) {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='USS' and templateId<1000");
		$template->{templateId}++;
	} else {
		($template->{templateId}) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='USS'");
		if ($template->{templateId} > 999) {
       			$template->{templateId}++;
     		} else {
     			$template->{templateId} = 1000;
		}
	}
	$template->{template} =~ s/\<tmpl\_loop\s+link\_loop\>/\<tmpl\_loop submissions\_loop\>/igs;
	$template->{template} =~ s/\<tmpl\_if\s+session\.var\.adminOn\>//igs;
	$template->{template} =~ s/\<\/tmpl\_if\>\s*\<\/tmpl\_if\>/\<\/tmpl_if>/igs;
	my $replacement = '
		<tmpl_if submission.currentUser>
			[<a href="<tmpl_var submission.edit.url>"><tmpl_var submission.edit.label></a>]
		</tmpl_if>
		<tmpl_if canModerate>
			<tmpl_var submission.controls>
		';
	$template->{template} =~ s/\<tmpl\_if\s+canEdit\>\s*\<tmpl\_var\s+link\.controls\>\s*/$replacement/igs;
	$replacement = ' <tmpl_if canPost>
			<a href="<tmpl_var post.url>"> ';
	$template->{template} =~ s/\<tmpl\_if\s+canEdit\>\s*\<a\s+href="\<tmpl\_var\s+addlink\.url\>"\>/$replacement/igs;
	$template->{template} =~ s/\<tmpl\_if\s+link\.newWindow\>/\<tmpl\_if submission\.userDefined2\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+link\.url\>/\<tmpl\_var submission\.userDefined1\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+link\.id\>/\<tmpl\_var submission\.id\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+link\.name\>/\<tmpl\_var submission\.title\>/igs;
	$template->{template} =~ s/\<tmpl\_var\s+link\.description\>/\<tmpl\_var submission\.content\.full\>/igs;
	$template->{template} =~ s/\<tmpl\_if\s+link\.description\>/\<tmpl\_if submission\.content\.full\>/igs;
	WebGUI::SQL->write("insert into template (templateId,name,template,namespace) values (".$template->{templateId}.",
		".quote($template->{name}).", ".quote($template->{template}).", 'USS')");
}
$sth->finish;
WebGUI::SQL->write("delete from template where namespace='LinkList'");
my $a = WebGUI::SQL->read("select a.wobjectId,a.groupIdEdit,a.ownerId,a.lastEdited,b.username,a.dateAdded from wobject a left join users b on
	a.ownerId=b.userId where a.namespace='LinkList'");
while (my $data = $a->hashRef) {
	$data->{lastEdited} = 0 unless ($data->{lastEdited});
	$ussId = getNextId("USS_id");
	WebGUI::SQL->write("insert into USS (wobjectId,	USS_id, groupToContribute, submissionsPerPage, filterContent, sortBy, sortOrder, 
		submissionFormTemplateId) values (
		".$data->{wobjectId}.", $ussId, ".$data->{groupIdEdit}.", 1000, 'none', 'sequenceNumber', 'asc', 3)");
	my $b = WebGUI::SQL->read("select * from LinkList_link");
	while (my $sub = $b->hashRef) {
		my $subId = getNextId("USS_submissionId");
		my $forum = WebGUI::Forum->create({});
		WebGUI::SQL->write("insert into USS_submission (USS_submissionId, USS_id, title, username, userId, content, 
			dateUpdated, dateSubmitted, forumId,contentType,userDefined1, userDefined2) values ( $subId, $ussId, ".quote($sub->{name}).", 
			".quote($data->{username}).", ".$data->{ownerId}.", ".quote($sub->{description}).", ".$data->{lastEdited}.", 
			".$data->{dateAdded}.", ".$forum->get("forumId").", 'html', ".quote($sub->{url}).", ".quote($sub->{newWindow}).")");
	}
	$b->finish;
}
$a->finish;
WebGUI::SQL->write("update wobject set namespace='USS' where namespace='LinkList'");
WebGUI::SQL->write("drop table LinkList");
WebGUI::SQL->write("drop table LinkList_link");
WebGUI::SQL->write("delete from incrementer where incrementerId='LinkList_linkId'");



#--------------------------------------------
print "\tUpdating SQL Reports.\n" unless ($quiet);
my %dblink;
$dblink{$session{config}{dsn}}{id} = 0;
$dblink{$session{config}{dsn}}{user} = $session{config}{dbuser};
my $sth = WebGUI::SQL->read("select DSN, databaseLinkId, username, identifier, wobjectId from SQLReport");
while (my $data = $sth->hashRef) {
	my $id = undef;
	next if ($data->{databaseLinkId} > 0);
	foreach my $dsn (keys %dblink) {
		if ($dsn eq $data->{DSN} && $dblink{$dsn}{user} eq $data->{username}) {
			$id = $dblink{$dsn}{id};
			last;
		}
	}
	unless (defined $id) {
		$id = getNextId("databaseLinkId");
		my $title = $data->{username}.'@'.$data->{DSN};
		WebGUI::SQL->write("insert into databaseLink (databaseLinkId, title, DSN, username, identifier) values ($id, ".quote($title).",
			".quote($data->{DSN}).", ".quote($data->{username}).", ".quote($data->{identifier}).")");
		$dblink{$data->{DSN}}{id} = $id;
		$dblink{$data->{DSN}}{user} = $data->{username};
	}
	WebGUI::SQL->write("update SQLReport set databaseLinkId=".$id." where wobjectId=".$data->{wobjectId});
}
$sth->finish;
WebGUI::SQL->write("alter table SQLReport drop column DSN");
WebGUI::SQL->write("alter table SQLReport drop column username");
WebGUI::SQL->write("alter table SQLReport drop column identifier");
use WebGUI::DatabaseLink;
my $templateId;
my $a = WebGUI::SQL->read("select a.databaseLinkId, a.dbQuery, a.template, a.wobjectId, b.title from SQLReport a , wobject b where a.wobjectId=b.wobjectId");
while (my $data = $a->hashRef) {
	next if ($data->{dbQuery} eq "");
	my $db = WebGUI::DatabaseLink->new($data->{databaseLinkId});
	if ($data->{template} ne "") {
                ($templateId) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='SQLReport'");
		if ($templateId > 999) {
			$templateId++;
		} else {
			$templateId = 1000;
		}
		my $b = WebGUI::SQL->unconditionalRead($data->{dbQuery},$db->dbh);
		my @template = split(/\^\-\;/,$data->{template});
		my $final = '<tmpl_if displayTitle>
    			<h1><tmpl_var title></h1>
			</tmpl_if>

			<tmpl_if description>
			    <tmpl_var description><p />
			</tmpl_if>

			<tmpl_if debugMode>
				<ul>
				<tmpl_loop debug_loop>
					<li><tmpl_var debug.output></li>
				</tmpl_loop>
				</ul>
			</tmpl_if>
			'.$template[0].'
			<tmpl_loop rows_loop>	';
		my $i;
		if (defined $b) {
		foreach my $col ($b->getColumnNames) {
			my $replacement = '<tmpl_var row.field.'.$col.'.value>';
			$template[1] =~ s/\^$i\;/$replacement/g;
			$i++;
		}
		}
		$template[1] =~ s/\^rownum\;/\<tmpl_var row\.number\>/g;
		$final .= $template[1].'
			</tmpl_loop>
			'.$template[2].'
			<tmpl_if multiplePages>
  			<div class="pagination">
    				<tmpl_var previousPage>   <tmpl_var pageList>  <tmpl_var nextPage>
  			</div>
			</tmpl_if>';
		WebGUI::SQL->write("insert into template (templateId, name, template, namespace) values ($templateId, 
			".quote($data->{title}).",".quote($final).",'SQLReport')");
	} else {
		$templateId = 1;
	}
	WebGUI::SQL->write("update wobject set templateId=$templateId where wobjectId=".$data->{wobjectId});
}
$a->finish;
WebGUI::SQL->write("alter table SQLReport drop column template");
WebGUI::SQL->write("alter table SQLReport drop column convertCarriageReturns");



#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
delete $macros->{"\\"};
$macros->{"\\\\"} = "Backslash_pageUrl";
$macros->{"Navigation"} = "Navigation";
my %newMacros;
foreach my $macro (keys %{$macros}) {
	unless (
		$macros->{$macro} eq "m_currentMenuHorizontal" 
		|| $macros->{$macro} eq "M_currentMenuVertical" 
		|| $macros->{$macro} eq "s_specificMenuHorizontal" 
		|| $macros->{$macro} eq "S_specificMenuVertical" 
		|| $macros->{$macro} eq "t_topMenuHorizontal" 
		|| $macros->{$macro} eq "T_topMenuVertical" 
		|| $macros->{$macro} eq "p_previousMenuHorizontal" 
		|| $macros->{$macro} eq "P_previousMenuVertical" 
		|| $macros->{$macro} eq "C_crumbTrail" 
		|| $macros->{$macro} eq "FlexMenu" 
		|| $macros->{$macro} eq "PreviousDropMenu" 
		|| $macros->{$macro} eq "rootmenuHorizontal" 
		|| $macros->{$macro} eq "RootTab" 
		|| $macros->{$macro} eq "SpecificDropMenu" 
		|| $macros->{$macro} eq "TopDropMenu" 
		|| $macros->{$macro} eq "Synopsis" 
		|| $macros->{$macro} eq "Question_search" 
		) {
		$newMacros{$macro} = $macros->{$macro};
	}
}
$conf->set("macros"=>\%newMacros);
my $wobjects = $conf->get("wobjects");
my @newWobjects;
foreach my $wobject (@{$wobjects}) {
	unless ($wobject eq "Item" || $wobject eq "FAQ" || $wobject eq "ExtraColumn" || $wobject eq "LinkList") {
		push(@newWobjects,$wobject);
	}
}
push(@newWobjects,"IndexedSearch");
push(@newWobjects,"WSClient");
$conf->set("wobjects"=>\@newWobjects);
$conf->set("emailRecoveryLoggingEnabled"=>1);
$conf->set("passwordChangeLoggingEnabled"=>1);
$conf->set("useSharedInternationalCache"=>1);
$conf->write;


#--------------------------------------------
print "\tUpdating Authentication.\n" unless ($quiet);
WebGUI::SQL->write("delete from authentication where authMethod='WebGUI' and fieldName='passwordLastUpdated'");
WebGUI::SQL->write("delete from authentication where authMethod='WebGUI' and fieldName='passwordTimeout'");
WebGUI::SQL->write("delete from authentication where authMethod='WebGUI' and fieldName='changeUsername'");
WebGUI::SQL->write("delete from authentication where authMethod='WebGUI' and fieldName='changePassword'");

my $authSth = WebGUI::SQL->read("select userId from users where authMethod='WebGUI'");
while (my $authHash = $authSth->hashRef){
   WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData) values ('".$authHash->{userId}."','WebGUI','passwordLastUpdated','".time()."')");
   WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData) values ('".$authHash->{userId}."','WebGUI','passwordTimeout','3122064000')");
   WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData) values ('".$authHash->{userId}."','WebGUI','changeUsername','1')");
   WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData) values ('".$authHash->{userId}."','WebGUI','changePassword','1')");   
}


#--------------------------------------------
print "\tRemoving unneeded files and directories.\n" unless ($quiet);
unlink("../../lib/WebGUI/Wobject/Item.pm");
unlink("../../lib/WebGUI/Wobject/LinkList.pm");
unlink("../../lib/WebGUI/Wobject/FAQ.pm");
unlink("../../lib/WebGUI/Wobject/ExtraColumn.pm");
unlink("../../lib/WebGUI/Authentication.pm");
unlink("../../lib/WebGUI/Operation/Account.pm");
unlink("../../lib/WebGUI/Macro/m_currentMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/M_currentMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/s_specificMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/S_specificMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/t_topMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/T_topMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/p_previousMenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/P_previousMenuVertical.pm");
unlink("../../lib/WebGUI/Macro/C_crumbTrail.pm");
unlink("../../lib/WebGUI/Macro/FlexMenu.pm");
unlink("../../lib/WebGUI/Macro/PreviousDropMenu.pm");
unlink("../../lib/WebGUI/Macro/Synopsis.pm");
unlink("../../lib/WebGUI/Macro/rootmenuHorizontal.pm");
unlink("../../lib/WebGUI/Macro/RootTab.pm");
unlink("../../lib/WebGUI/Macro/SpecificDropMenu.pm");
unlink("../../lib/WebGUI/Macro/TopDropMenu.pm");
unlink("../../lib/WebGUI/Macro/Question_search.pm");
unlink("../../lib/WebGUI/Operation/Search.pm");
rmtree("../../lib/WebGUI/Authentication");
rmtree("../../www/extras/toolbar/default");

#--------------------------------------------
print "\tMigrating wobject privileges.\n" unless ($quiet);
WebGUI::SQL->write("alter table page add column wobjectPrivileges int not null default 0");
WebGUI::SQL->write("update page set wobjectPrivileges=$session{setting}{wobjectPrivileges}");
WebGUI::SQL->write("delete from settings where name='wobjectPrivileges'");


#--------------------------------------------
print "\tMigrating surveys.\n" unless ($quiet);
WebGUI::SQL->write("alter table Survey_response rename Survey_questionResponse");
WebGUI::SQL->write("update Survey_questionResponse set userId='1' where userId='c4ca4238'");
WebGUI::SQL->write("alter table Survey_questionResponse drop primary key");
WebGUI::SQL->write("alter table Survey_questionResponse add primary key (Survey_questionId, Survey_answerId, Survey_responseId)");
WebGUI::SQL->write("create table Survey_response (Survey_id int, Survey_responseId int not null primary key, userId varchar(11), 
	username varchar(255), ipAddress varchar(15), startDate int, endDate int, isComplete int not null default 0)");
my $a = WebGUI::SQL->read("select Survey_id from Survey");
while (my ($surveyId) = $a->array) {
	my $b = WebGUI::SQL->read("select distinct userId from Survey_questionResponse where Survey_id=$surveyId");
	while (my ($userId) = $b->array) {
		my ($username,$ipAddress) = WebGUI::SQL->quickArray("select username,ipAddress from Survey_questionResponse where Survey_id=$surveyId and 
			userId=".quote($userId));
		WebGUI::SQL->write("insert into Survey_response (Survey_id, Survey_responseId, userId, username, isComplete, ipAddress) values ($surveyId,
			".getNextId("Survey_responseId")." ,".quote($userId).", ".quote($username).", 1, ".quote($ipAddress).")");
	}
	$b->finish;
	$b = WebGUI::SQL->read("select distinct ipAddress from Survey_questionResponse where Survey_id=$surveyId and userId='1'");
	while (my ($ipAddress) = $b->array) {
		WebGUI::SQL->write("insert into Survey_response (Survey_id, Survey_responseId, userId, username, isComplete, ipAddress) values (
			$surveyId, ".getNextId("Survey_responseId")." ,'1', 'Visitor', 1, ".quote($ipAddress).")");
	}
	$b->finish;
}
$a->finish;
$a = WebGUI::SQL->read("select Survey_id, Survey_responseId, userId, ipAddress from Survey_response");
while (my $data = $a->hashRef) {
	my ($end) = WebGUI::SQL->quickArray("select max(dateOfResponse) from Survey_questionResponse where Survey_id=".$data->{Survey_id}."
		and ((userId=".quote($data->{userId})." and userId<>1) or (userId=1 and ipAddress=".quote($data->{ipAddress})."))");
	my ($start) = WebGUI::SQL->quickArray("select min(dateOfResponse) from Survey_questionResponse where Survey_id=".$data->{Survey_id}."
		and ((userId=".quote($data->{userId})." and userId<>1) or (userId=1 and ipAddress=".quote($data->{ipAddress})."))");
	WebGUI::SQL->write("update Survey_response set startDate=$start, endDate=$end where Survey_responseId=".$data->{Survey_responseId});
	WebGUI::SQL->write("update Survey_questionResponse set Survey_responseId=".$data->{Survey_responseId}." where Survey_id=".$data->{Survey_id}."
		and ((userId=".quote($data->{userId})." and userId<>1) or (userId=1 and ipAddress=".quote($data->{ipAddress})."))");
}
$a->finish;
WebGUI::SQL->write("alter table Survey_questionResponse drop column userId");
WebGUI::SQL->write("alter table Survey_questionResponse drop column username");
WebGUI::SQL->write("alter table Survey_questionResponse drop column ipAddress");
WebGUI::SQL->write("alter table Survey add column questionsPerPage int not null default 1");
WebGUI::SQL->write("alter table Survey add column responseTemplateId int not null default 1");
WebGUI::SQL->write("alter table Survey add column reportcardTemplateId int not null default 1");
WebGUI::SQL->write("alter table Survey add column overviewTemplateId int not null default 1");
WebGUI::SQL->write("alter table Survey add column maxResponsesPerUser int not null default 1");
WebGUI::SQL->write("alter table Survey add column questionsPerResponse int not null default 9999999");
WebGUI::SQL->write("alter table Survey_question add column gotoQuestion int");

#--------------------------------------------
print "\tMigrating Navigation Macro's.\n" unless ($quiet);
my %dbFields = ( 
	template => { id => [ "templateId", "namespace" ], fields => [ "template" ] },
	wobject => { id => [ "wobjectId" ], fields => [ "description" ] },
	collateral => { id => [ "collateralId" ], fields => [ "parameters" ] }
	);
my %replace;
$replace{'C'} = {
	columns => {
		identifier=>'crumbTrail', depth=>1, method=>'self_and_ancestors', startAt=>'current', stopAtLevel=>'-1',
		templateId=>'2', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>1, seperator=>'&gt;'
		},
	parameter => [ "seperator" ],
	template => q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="crumbTrail">
<tmpl_loop page_loop>
<a class="crumbTrail" 
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},
	};
$replace{'FlexMenu'} = {
	columns => {
		identifier=>'FlexMenu', depth=>99, method=>'pedigree', startAt=>'current', stopAtLevel=>'2',
		templateId=>'1', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "depth" ]
	};
$replace{'M'} = {
	'columns'=>{
		identifier=>'currentMenuVertical', depth=>1, method=>'descendants', startAt=>'current', stopAtLevel=>'-1',
		templateId=>'1', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "depth" ]
	};
$replace{'m'} = {
	'columns'=>{
		identifier=>'currentMenuHorizontal', depth=>1, method=>'descendants',  startAt=>'current',stopAtLevel=>'-1',
		templateId=>'3', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>'&middot;'
		},
	'parameter'=>[ "seperator" ],
	template=>q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="horizontalMenu">
<tmpl_loop page_loop>
<a class="horizontalMenu" 
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},
	};
$replace{'PreviousDropMenu'} = {
	'columns'=>{
		identifier=>'PreviousDropMenu', depth=>99, method=>'self_and_sisters', startAt=>'current',stopAtLevel=>'-1',
		templateId=>'4', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ ]
	};
$replace{'P'} = {
	'columns'=>{
		identifier=>'previousMenuVertical', depth=>1, method=>'descendants', startAt=>'mother', stopAtLevel=>'-1',
		templateId=>'1', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "depth" ]
	};
$replace{'p'} = {
	'columns'=>{
		identifier=>'previousMenuHorizontal', depth=>1, method=>'descendants', startAt=>'mother', stopAtLevel=>'-1',
		templateId=>'3', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>'&middot;'
		},
	'parameter'=>[ "seperator" ],
	template=>q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="horizontalMenu">
<tmpl_loop page_loop>
<a class="horizontalMenu"
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},
	};
$replace{'rootmenu'} = {
	'columns'=>{
		identifier=>'rootmenu', depth=>1, method=>'daughters', startAt=>'root', stopAtLevel=>'-1', 
		templateId=>'3', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>'&middot;'
		},
	'parameter'=>[ "seperator" ],
        template=>q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="horizontalMenu">
<tmpl_loop page_loop>
<a class="horizontalMenu"
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},
	};
$replace{'RootTab'} = {
	'columns'=>{
		identifier=>'RootTab', depth=>99, method=>'daughters', startAt=>'root', stopAtLevel=>'-1',
		templateId=>'5', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ ]
	};
$replace{'SpecificDropMenu'} = {
	'columns'=>{
		identifier=>'SpecificDropMenu', depth=>3, method=>'descendants', startAt=>'home', stopAtLevel=>'-1',
		templateId=>'4', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "startAt", "depth" ]
	};
$replace{'S'} = {
	'columns'=>{
		identifier=>'SpecificMenuVertical', depth=>3, method=>'descendants', startAt=>'home', stopAtLevel=>'-1',
		templateId=>'1', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "startAt", "depth" ]
	};
$replace{'s'} = {
	'columns'=>{
		identifier=>'SpecificMenuHorizontal', depth=>3, method=>'descendants', startAt=>'home', stopAtLevel=>'-1',
		templateId=>'3', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "startAt", "seperator" ],
        template=>q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="horizontalMenu">
<tmpl_loop page_loop>
<a class="horizontalMenu"
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},

	};
$replace{'TopDropMenu'} = {
	'columns'=>{
		identifier=>'TopDropMenu', depth=>0, method=>'self_and_sisters', startAt=>'top', stopAtLevel=>'-1',
		templateId=>'4', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ ]
	};
$replace{'T'} = {
	'columns'=>{
		identifier=>'TopLevelMenuVertical', depth=>0, method=>'self_and_sisters', startAt=>'top', stopAtLevel=>'-1',
		templateId=>'1', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
		},
	'parameter'=>[ "depth" ]
	};
$replace{'Synopsis'} = {
        'columns'=>{
                identifier=>'Synopsis', depth=>99, method=>'self_and_descendants', startAt=>'current', stopAtLevel=>'-1',
                templateId=>'8', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>''
                },
        'parameter'=>[ "depth" ]
        };
$replace{'t'} = {
	'columns'=>{
		identifier=>'TopLevelMenuHorizontal', depth=>0, method=>'self_and_sisters', startAt=>'top', stopAtLevel=>'-1',
		templateId=>'3', showSystemPages=>0, showHiddenPages=>0, showUnprivilegedPages=>0, reverse=>0, seperator=>'&middot;'
		},
	'parameter'=>[ "seperator" ],
        template=>q{<tmpl_if session.var.adminOn>
<tmpl_var config.button>
</tmpl_if>
<span class="horizontalMenu">
<tmpl_loop page_loop>
<a class="horizontalMenu"
   <tmpl_if page.newWindow>target="_blank"</tmpl_if>
   href="<tmpl_var page.url>"><tmpl_var page.menuTitle></a>
   <tmpl_unless "__last__"> __SEPARATOR__ </tmpl_unless>
</tmpl_loop>
</span>},

	};

my ($sth, $data, $code, $table, $column, %identifier);
foreach $table (keys %dbFields){
	$sth = WebGUI::SQL->read("SELECT * FROM $table ");
	die "Cannot read from table $table " if ($!);
	while ($data = $sth->hashRef){
		foreach $column (@{$dbFields{$table}{fields}}){
			$code = $data->{$column};
			while ($code =~ /$WebGUI::Macro::nestedMacro/gs){
				my ($macro, $searchString, $params) = ($1, $2, $3);
				next if ($searchString =~ /^\d+$/); # don't process ^0; ^1; ^2; etc.
				next if ($searchString =~ /^\-$/); # don't process ^-;
				if ($params ne "") {
					$params =~ s/(^\(|\)$)//g; # remove parenthesis
					$params = WebGUI::Macro::process($params); # recursive process params
				}
				my @param = WebGUI::Macro::getParams($params);
				if($replace{$searchString}){
					my $repNav = $replace{$searchString};
                                       my $replaceId = $macro.'_'.join('_',@param);
					# print "\nReplacing macro: $macro\n";
					for(my $i=0; $i<scalar(@param); $i++){
						$repNav->{columns}->{$repNav->{parameter}->[$i]} = $param[$i];
						# print "Found parameters:\n";
						# print "\t".$repNav->{parameter}->[$i].": ".$repNav->{columns}->{$repNav->{parameter}->[$i]}."\n";
					}
					my $doTemplate = ($repNav->{template} && $repNav->{columns}->{seperator});
					if($doTemplate) {
					  if($identifier{cachedTemplate}{$replaceId."_".$repNav->{columns}->{seperator}}) {
						$repNav->{columns}->{templateId} = 
					    	  $identifier{cachedTemplate}{$replaceId."_".$repNav->{columns}->{seperator}};
					  } else {
						$repNav->{template} =~ s/__SEPARATOR__/$repNav->{columns}->{seperator}/g;
						($repNav->{columns}->{templateId}) = WebGUI::SQL->quickArray("select max(templateId)
                                from template where namespace=".quote('Navigation'));
	                        		if ($repNav->{columns}->{templateId} > 999) {
        	                        		$repNav->{columns}->{templateId}++;
                	        		} else {
                        	        		$repNav->{columns}->{templateId} = 1000;
                        			}
					  }
					}
					unless ($identifier{cachedConfig}{$replaceId}) { 
						$identifier{cachedConfig}{$replaceId} = addNavigation($repNav->{columns});
					}
					if($doTemplate && 
					   ! $identifier{cachedTemplate}{$replaceId."_".$repNav->{columns}->{seperator}}) {
  					   WebGUI::SQL->write("insert into template (templateId,namespace,name,template) values
					  ($repNav->{columns}->{templateId}, ".quote('Navigation').", ".
					  quote("AutoGen ".$macro).", ".quote($repNav->{template}).")");	
					}
					my $replacement = "^Navigation($identifier{cachedConfig}{$replaceId});";
					 # print "\tReplacing macro $macro with $replacement ";
					$code =~ s/\Q$macro/$replacement/ges;
				}
			}
			my ($update, @where);
			$update = "UPDATE $table SET $column=".quote($code)." WHERE ";
			foreach (@{$dbFields{$table}{id}}){
				push (@where, $_."=".quote($data->{$_}));
			}
			$update .= join (" AND ", @where);
			WebGUI::SQL->write($update);
		}
	}
	$sth->finish;
}



WebGUI::Session::close();


#-------------------------------------------------------------------
sub _positionFormat5x {
        return "<tmpl_var page.position".($_[0]+1).">";
}

#-------------------------------------------------------------------
sub _positionFormat6x {
	my $newPositionCode = '	
<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
<table border=0 id="position'.$_[0].'" class="content">
            <tbody>
</tmpl_if> </tmpl_if>
		<tmpl_loop position'.$_[0].'_loop>
<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
            <tr id="td<tmpl_var wobject.id>">
            <td>
            <div id="td<tmpl_var wobject.id>_div" class="dragable">      
</tmpl_if></tmpl_if>
			<tmpl_if wobject.canView> 
				<div class="wobject"> <div class="wobject<tmpl_var wobject.namespace>" id="wobjectId<tmpl_var wobject.id>">
				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>
					<tmpl_var wobject.controls><tmpl_if page.canEdit><tmpl_var wobject.controls.drag></tmpl_if>
				</tmpl_if> </tmpl_if>
				<tmpl_if wobject.isInDateRange>
                      			<a name="<tmpl_var wobject.id>"></a>
					<tmpl_var wobject.content>
				</tmpl_if wobject.isInDateRange> 
				</div> </div>
			</tmpl_if>
			<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
         </div>
                </td>
            </tr>
</tmpl_if></tmpl_if>
		</tmpl_loop>
		<tmpl_if session.var.adminOn> 
            </tbody>
        </table>
</tmpl_if>
	';
	return $newPositionCode;
}
#--------------------------------------------
sub addNavigation {
	my $properties = shift;
#	use Data::Dumper; print "\n\n". Dumper($properties);
	my $navId = getNextId("navigationId");
	my $identifier = $properties->{identifier}."_".$navId;
	WebGUI::SQL->write("INSERT INTO Navigation(navigationId, identifier) VALUES ($navId, ".quote($identifier).")");
	my ($update, @set);
	$update = "UPDATE Navigation SET ";
	foreach (keys %{$properties}){
		next if (/seperator/i);
		push (@set, $_."=".quote($properties->{$_})) unless($_ eq "identifier");
	}
	$update .= join(",", @set);
	$update .= " WHERE navigationId=".quote($navId);
	WebGUI::SQL->write($update);
	return $identifier;
}
#--------------------------------------------
