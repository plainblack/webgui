#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

my $configFile;
my $quiet;
GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);
WebGUI::Session::open("../..",$configFile);


#--------------------------------------------
print "\tMoving replacements.\n" unless ($quiet);
my $replacements = $session{config}{searchAndReplace};
foreach my $key (keys %{$replacements}) {
	WebGUI::SQL->setRow("replacements","replacementId",{
		replacementId=>"new",
		searchFor=>$key,
		replaceWith=>$replacements->{$key}
		});
}



#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
delete $macros->{"\\"};
$macros->{"\\\\"} = "Backslash_pageUrl";
$conf->set("macros"=>$macros);
my $wobjects = $conf->get("wobjects");
my @newWobjects = qw(SOAPClient);
foreach (@{$wobjects}) {
	push(@newWobjects, $_);
}
$conf->set("wobjects"=>\@newWobjects);
$conf->set("searchAndReplace"=>undef);
$conf->write;



#--------------------------------------------
print "\tRemoving unneeded files.\n" unless ($quiet);
unlink("../../lib/WebGUI/Discussion.pm");


#--------------------------------------------
print "\tMigrating Message Board discussions.\n" unless ($quiet);
my $a = WebGUI::SQL->read("select a.wobjectId,a.title,a.description,b.messagesPerPage,a.groupToPost,a.groupToModerate,a.editTimeout,a.karmaPerPost, 
	a.moderationType,a.filterPost,a.addEditStampToPosts from wobject a left join MessageBoard b
	on a.wobjectId=b.wobjectId where a.namespace='MessageBoard'");
while (my $adata = $a->hashRef) {
	my $moderatePosts = 0;
	$moderatePosts = 1 unless ($adata->{moderationType} eq "after");
	my ($seq) = WebGUI::SQL->quickArray("select count(*) from MessageBoard_forums where wobjectId=".$adata->{wobjectId});
	$seq++;
	my $forumId = WebGUI::SQL->setRow("MessageBoard_forums","forumId", {
		forumId=>"new",
		wobjectId=>$adata->{wobjectId},
		title=>$adata->{title},
		description=>$adata->{description},
		sequenceNumber=>$seq
		});
	WebGUI::SQL->write("insert into forum (forumId,moderatePosts,postsPerPage,groupToPost,groupToModerate,editTimeout,karmaPerPost,
		filterPosts,addEditStampToPosts) values ($forumId,$moderatePosts, $adata->{messagesPerPage}, $adata->{groupToPost},
		$adata->{groupToModerate}, $adata->{editTimeout}, $adata->{karmaPerPost}, ".quote($adata->{filterPost}).", 
		$adata->{addEditStampToPosts})");
	my $b = WebGUI::SQL->read("select * from discussion where wobjectId=".$adata->{wobjectId});
	while (my $bdata = $b->hashRef) {
		WebGUI::SQL->write("insert into forumPost (forumPostId, parentId, forumThreadId, userId, username, subject, message, dateOfPost,
			status, views) values ($bdata->{messageId}, $bdata->{pid}, $bdata->{rid}, $bdata->{userId}, ".quote($bdata->{username}).",
			".quote($bdata->{subject}).", ".quote($bdata->{message}).", ".($bdata->{dateOfPost}+0).", ".quote($bdata->{status}).",
			$bdata->{views})");
		if ($bdata->{messageId} == $bdata->{rid}) {
			WebGUI::SQL->write("insert into forumThread (forumThreadId, forumId, rootPostId, lastPostId, lastPostDate, isLocked, status)
				values ($bdata->{rid}, $forumId, $bdata->{messageId}, $bdata->{messageId}, ".($bdata->{dateOfPost}+0).", $bdata->{locked},
				".quote($bdata->{status}).")");
		}
	}
	$b->finish;
}
$a->finish;
WebGUI::SQL->write("alter table MessageBoard drop column messagesPerPage");



#--------------------------------------------
print "\tMigrating Article discussions.\n" unless ($quiet);
my $a = WebGUI::SQL->read("select wobjectId,title,description,groupToPost,groupToModerate,editTimeout,karmaPerPost, 
	moderationType,filterPost,addEditStampToPosts from wobject where namespace='Article'");
while (my $adata = $a->hashRef) {
	my $moderatePosts = 0;
	$moderatePosts = 1 unless ($adata->{moderationType} eq "after");
	my $forumId = getNextId("forumId");
	WebGUI::SQL->write("insert into forum (forumId,moderatePosts,groupToPost,groupToModerate,editTimeout,karmaPerPost,
		filterPosts,addEditStampToPosts) values ($forumId,$moderatePosts, $adata->{groupToPost},
		$adata->{groupToModerate}, $adata->{editTimeout}, $adata->{karmaPerPost}, ".quote($adata->{filterPost}).", 
		$adata->{addEditStampToPosts})");
	WebGUI::SQL->write("update wobject set forumId=$forumId");
	my $b = WebGUI::SQL->read("select * from discussion where wobjectId=".$adata->{wobjectId});
	while (my $bdata = $b->hashRef) {
		WebGUI::SQL->write("insert into forumPost (forumPostId, parentId, forumThreadId, userId, username, subject, message, dateOfPost,
			status, views) values ($bdata->{messageId}, $bdata->{pid}, $bdata->{rid}, $bdata->{userId}, ".quote($bdata->{username}).",
			".quote($bdata->{subject}).", ".quote($bdata->{message}).", ".($bdata->{dateOfPost}+0).", ".quote($bdata->{status}).",
			$bdata->{views})");
		if ($bdata->{messageId} == $bdata->{rid}) {
			WebGUI::SQL->write("insert into forumThread (forumThreadId, forumId, rootPostId, lastPostId, lastPostDate, isLocked, status)
				values ($bdata->{rid}, $forumId, $bdata->{messageId}, $bdata->{messageId}, ".($bdata->{dateOfPost}+0).", $bdata->{locked},
				".quote($bdata->{status}).")");
		}
	}
	$b->finish;
}
$a->finish;


#--------------------------------------------
print "\tMigrating USS discussions.\n" unless ($quiet);
my $a = WebGUI::SQL->read("select wobjectId,groupToPost,groupToModerate,editTimeout,karmaPerPost, moderationType,filterPost,addEditStampToPosts 
	from wobject where namespace='USS'");
while (my $adata = $a->hashRef) {
	my $moderatePosts = 0;
	$moderatePosts = 1 unless ($adata->{moderationType} eq "after");
	my $masterForumId = getNextId("forumId");
	WebGUI::SQL->write("insert into forum (forumId,moderatePosts,groupToPost,groupToModerate,editTimeout,karmaPerPost,
		filterPosts,addEditStampToPosts) values ($masterForumId,$moderatePosts, $adata->{groupToPost},
		$adata->{groupToModerate}, $adata->{editTimeout}, $adata->{karmaPerPost}, ".quote($adata->{filterPost}).", 
		$adata->{addEditStampToPosts})");
	WebGUI::SQL->write("update wobject set forumId=$masterForumId");
	my $b = WebGUI::SQL->read("select USS_submissionId from USS_submission where wobjectId=$adata->{wobjectId}");
	while (my ($submissionId) = $b->array) {
		my $forumId = WebGUI::SQL->setRow("forum","forumId",{
			forumId=>"new",
			masterForumId=>$masterForumId
			});
		WebGUI::SQL->write("update USS_submission set forumId=$forumId where USS_submissionId=$submissionId");
		my $c = WebGUI::SQL->read("select * from discussion where wobjectId=$adata->{wobjectId} and subId=$submissionId");
		while (my $cdata = $c->hashRef) {
			WebGUI::SQL->write("insert into forumPost (forumPostId, parentId, forumThreadId, userId, username, subject, message, dateOfPost,
				status, views) values ($cdata->{messageId}, $cdata->{pid}, $cdata->{rid}, $cdata->{userId}, ".quote($cdata->{username}).",
				".quote($cdata->{subject}).", ".quote($cdata->{message}).", ".($cdata->{dateOfPost}+0).", ".quote($cdata->{status}).",
				$cdata->{views})");
			if ($cdata->{messageId} == $cdata->{rid}) {
				WebGUI::SQL->write("insert into forumThread (forumThreadId, forumId, rootPostId, lastPostId, lastPostDate, isLocked, status)
					values ($cdata->{rid}, $forumId, $cdata->{messageId}, $cdata->{messageId}, ".($cdata->{dateOfPost}+0).", 
					$cdata->{locked}, ".quote($cdata->{status}).")");
			}
		}
		$c->finish;
	}
	$b->finish;
}
$a->finish;


#--------------------------------------------
print "\tGenerating discussion statistics.\n" unless ($quiet);
my $a = WebGUI::SQL->read("select * from discussionSubscription");
while (my $data = $a->hashRef) {
	WebGUI::SQL->write("insert into forumThreadSubscription values ($data->{threadId}, $data->{userId})");
}
$a->finish;
$a = WebGUI::SQL->read("select forumThreadId from forumThread");
while (my ($threadId) = $a->array) {
	my ($views) = WebGUI::SQL->quickArray("select sum(views) from forumPost where forumThreadId=".$threadId);
	$views += 0;
	my ($replies) = WebGUI::SQL->quickArray("select count(*) from forumPost where forumThreadId=".$threadId);
	$replies--;
	my ($lastPostId, $lastPostDate) = WebGUI::SQL->quickArray("select forumPostId, dateOfPost from forumPost where forumThreadId="
		.$threadId." order by dateOfPost desc");
	$lastPostId += 0;
	$lastPostDate += 0;
	WebGUI::SQL->write("update forumThread set views=$views, replies=$replies, lastPostId=$lastPostId, lastPostDate=$lastPostDate
		where forumThreadId=$threadId");
}
$a->finish;
$a = WebGUI::SQL->read("select forumId from forum");
while (my ($forumId) = $a->array) {
	my ($views) = WebGUI::SQL->quickArray("select sum(views) from forumThread where forumId=".$forumId);
	$views +=0;
	my ($threads) = WebGUI::SQL->quickArray("select count(*) from forumThread where forumId=".$forumId);
	$threads += 0;
	my ($replies) = WebGUI::SQL->quickArray("select sum(replies) from forumThread where forumId=".$forumId);
	$replies += 0;
	my ($lastPostId, $lastPostDate) = WebGUI::SQL->quickArray("select lastPostId, lastPostDate from forumThread where forumId=$forumId
		order by lastPostDate desc");
	$lastPostId +=0;
	$lastPostDate +=0;
	WebGUI::SQL->write("update forum set views=$views, replies=$replies, lastPostId=$lastPostId, lastPostDate=$lastPostDate,
		threads=$threads where forumId=$forumId");
}
$a->finish;
my ($max) = WebGUI::SQL->quickArray("select max(forumPostId) from forumPost");
$max++;
WebGUI::SQL->write("update incrementer set nextValue=$max where incrementerId='forumPostId'");
($max) = WebGUI::SQL->quickArray("select max(forumThreadId) from forumThread");
$max++;
WebGUI::SQL->write("update incrementer set nextValue=$max where incrementerId='forumThreadId'");
WebGUI::SQL->write("update forumThread set status='approved' where status='Approved'");
WebGUI::SQL->write("update forumPost set status='approved' where status='Approved'");
WebGUI::SQL->write("update forumThread set status='denied' where status='Denied'");
WebGUI::SQL->write("update forumPost set status='denied' where status='Denied'");
WebGUI::SQL->write("update forumThread set status='pending' where status='Pending'");
WebGUI::SQL->write("update forumPost set status='pending' where status='Pending'");


#--------------------------------------------
print "\tDeleting old discussions.\n" unless ($quiet);
WebGUI::SQL->write("drop table discussion");
WebGUI::SQL->write("drop table discussionSubscription");
WebGUI::SQL->write("delete from incrementer where incrementerId='messageId'");
WebGUI::SQL->write("alter table wobject drop column groupToPost");
WebGUI::SQL->write("alter table wobject drop column groupToModerate");
WebGUI::SQL->write("alter table wobject drop column editTimeout");
WebGUI::SQL->write("alter table wobject drop column karmaPerPost");
WebGUI::SQL->write("alter table wobject drop column moderationType");
WebGUI::SQL->write("alter table wobject drop column filterPost");
WebGUI::SQL->write("alter table wobject drop column addEditStampToPosts");


WebGUI::Session::close();


