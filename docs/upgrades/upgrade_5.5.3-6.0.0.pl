#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Forum;

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
	left join page b on a.pageId=b.pageId left join ExtraColumn c on a.wobjectId=c.wobjectId where a.namespace='ExtraColumn'");
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
		</style>
		</tmpl_if>
		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
			<tmpl_var page.controls>
		</tmpl_if> </tmpl_if>
		'.$template->{template};
	$template->{template} =~ s/\<tmpl_var page\.position(\d+)\>/_positionFormat6x($1)/eg; 
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
	$b->finsih;
	$ussId++;
}
$a->finish;
WebGUI::SQL->write("alter table USS_submission drop column wobjectId");
WebGUI::SQL->write("alter table USS add column submissionFormTemplateId int not null default 1");
WebGUI::SQL->write("alter table USS_submission add column contentType varchar(35) not null default 'mixed'");
WebGUI::SQL->write("update USS_submission set contentType='html' where convertCarriageReturns=0");
WebGUI::SQL->write("alter table USS_submission drop column convertCarriageReturns");
WebGUI::SQL->write("insert into incrementer (incrementerId,nextValue) values ('USS_id',$ussId)");


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
	$ussId = getNextId("USS_id");
	WebGUI::SQL->write("insert into USS (wobjectId,	USS_id, groupToContribute, submissionsPerPage, filterContent, sortBy, sortOrder, 
		submissionFormTemplateId) values (
		".$data->{wobjectId}.", $ussId, ".$data->{groupIdEdit}.", 1000, 'none', 'sequenceNumber', 'asc', 2)");
	my $b = WebGUI::SQL->read("select * from FAQ_question");
	while (my $sub = $b->hashRef) {
		my $subId = getNextId("USS_submissionId");
		my $forum = WebGUI::Forum->create({});
		WebGUI::SQL->write("insert into USS_submission (USS_submissionId, USS_id, title, username, userId, content, 
			dateUpdated, dateSubmited, forumId,contentType) values ( $subId, $ussId, ".quote($sub->{question}).", 
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
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
delete $macros->{"\\"};
$macros->{"\\\\"} = "Backslash_pageUrl";
$conf->set("macros"=>$macros);
my $wobjects = $conf->get("wobjects");
my @newWobjects;
foreach my $wobject (@{$wobjects}) {
	unless ($wobject eq "Item" || $wobject eq "FAQ" || $wobject eq "ExtraColumn") {
		push(@newWobjects,$wobject);
	}
}
$conf->set("wobjects"=>\@newWobjects);
$conf->write;



#--------------------------------------------
print "\tRemoving unneeded files.\n" unless ($quiet);
unlink("../../lib/WebGUI/Operation/Style.pm");
unlink("../../lib/WebGUI/Wobject/Item.pm");
#unlink("../../lib/WebGUI/Wobject/LinkList.pm");
unlink("../../lib/WebGUI/Wobject/FAQ.pm");
unlink("../../lib/WebGUI/Wobject/ExtraColumn.pm");




WebGUI::Session::close();


#-------------------------------------------------------------------
sub _positionFormat5x {
        return "<tmpl_var page.position".($_[0]+1).">";
}

#-------------------------------------------------------------------
sub _positionFormat6x {
	my $newPositionCode = '	
		<tmpl_loop position'.$_[0].'_loop>
			<tmpl_if wobject.canView> 
				<div class="wobject"> <div class="wobject<tmpl_var wobject.namespace>" id="wobjectId<tmpl_var wobject.id>">
				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>
					<tmpl_var wobject.controls>
				</tmpl_if> </tmpl_if>
				<tmpl_if wobject.isInDateRange>
                      			<a name="<tmpl_var wobject.id>"></a>
					<tmpl_var wobject.content>
				</tmpl_if wobject.isInDateRange> 
				</div> </div>
			</tmpl_if>
		</tmpl_loop>
	';
	return $newPositionCode;
}


