package Hourly::IndexedSearch_buildIndex; 

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use DBI;
use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject::IndexedSearch::Search;


#-------------------------------------------------------------------
sub process {
	my $verbose = shift;
	my $indexName = 'IndexedSearch_default';
	my ($dateIndexed) = WebGUI::SQL->quickArray("select max(dateIndexed) from IndexedSearch_docInfo where indexName = ".quote($indexName)); 
	if (WebGUI::DateTime::time()-$dateIndexed < 86400) {
		print " - Recently Indexed: Skipping " if ($verbose);
		return "";
	}	
	print "\n";
	my $htmlFilter = 'all';
	my $stopList = 'none'; 
	undef $stopList if ($stopList eq 'none');
	my $stemmer = 'none'; 
	undef $stemmer  if ($stemmer eq 'none');
	my $backend = 'phrase';
	my $indexInfo = getIndexerParams();
	my $search = WebGUI::Wobject::IndexedSearch::Search->new($indexName);
	$search->recreate('','',stemmer => $stemmer, stoplist => $stopList, backend => $backend);
	my $startTime = WebGUI::DateTime::time();
	foreach my $namespace (keys %{$indexInfo}) {
		my $sth = WebGUI::SQL->read($indexInfo->{$namespace}{sql});
		my $total = $sth->rows;
		my $actual = 1;
		while (my %data = $sth->hash) {
			if ($verbose) {
				print "\r\t\tIndexing $namespace data ($total items) ...".
				(" " x (30 - (length($namespace)) - length("$total"))).
				int(($actual/$total)*100)." %   ";
			}
			my $textToIndex = "";
			foreach my $field (@{$indexInfo->{$namespace}{fieldsToIndex}}) {
				if($field =~ /^\s*select/i) {
					my $sql = eval 'sprintf("%s","'.$field.'")';
					$textToIndex .= join("\n", WebGUI::SQL->buildArray($sql));
				} else {
					$textToIndex .= $data{$field}."\n";
				}
			}
			$textToIndex = WebGUI::HTML::filter($textToIndex,$htmlFilter);
			my $url = eval $indexInfo->{$namespace}{url};
			my $headerShortcut = eval 'sprintf("%s","'.$indexInfo->{$namespace}{headerShortcut}.'")';
			my $bodyShortcut = eval 'sprintf("%s","'.$indexInfo->{$namespace}{bodyShortcut}.'")';
			$search->indexDocument({
						text => $textToIndex,
						location => $url,
						pageId => $data{pageId},
						wobjectId => $data{wid},
						languageId => $data{languageId},
						namespace => $data{namespace},
						page_groupIdView => $data{page_groupIdView},
						wobject_groupIdView => $data{wobject_groupIdView},
						wobject_special_groupIdView => $data{wobject_special_groupIdView},
						headerShortcut => $headerShortcut,
						bodyShortcut => $bodyShortcut,
						contentType => $indexInfo->{$namespace}{contentType},
						ownerId => $data{ownerId}
						});
			$actual++;
		}
	print "\n" if ($verbose && $total);
	}
	print "\t\t".(($search->getDocId -1)." WebGUI items indexed in ".(time() - $startTime)." seconds.\n\t") if ($verbose);
	$search->close;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $now = WebGUI::DateTime::time();
	my %params = ( 
	page => 	{
			sql => "select pageId, 
					title, 
					urlizedTitle, 
					synopsis, 
					languageId,
					ownerId,
					'Page' as namespace,
					groupIdView as page_groupIdView,
					7 as wobject_groupIdView,
					7 as wobject_special_groupIdView
				from page
				where startDate < $now and endDate > $now",
			fieldsToIndex => ["synopsis" , "title"],
			contentType => 'page',
			url => '$data{urlizedTitle}',
			headerShortcut => 'select title from page where pageId = $data{pageId}',
			bodyShortcut => 'select synopsis from page where pageId = $data{pageId}', 
		},
	wobject =>	{
			sql => "select wobject.namespace as namespace, 
					wobject.title as title, 
					wobject.description as description, 
					wobject.wobjectId as wid,
					wobject.addedBy as ownerId,
					page.urlizedTitle as urlizedTitle, 
					page.languageId as languageId, 
					page.pageId as pageId,
					page.groupIdView as page_groupIdView,
					wobject.groupIdView as wobject_groupIdView,
					7 as wobject_special_groupIdView
				from wobject , page 
				where wobject.pageId = page.pageId 
					and wobject.startDate < $now 
					and wobject.endDate > $now
					and page.startDate < $now
					and page.endDate > $now",
			fieldsToIndex => ["title", "description"],
			contentType => 'wobject',
			url => '$data{urlizedTitle}."#".$data{wid}',
			headerShortcut => 'select title from wobject where wobjectId = $data{wid}',
			bodyShortcut => 'select description from wobject where wobjectId = $data{wid}',
		},
	wobjectDiscussion => {
			sql => "select  forumPost.forumPostId,
					forumPost.username,
					forumPost.subject,
					forumPost.message,
					forumPost.userId as ownerId,
					wobject.namespace as namespace,
					wobject.wobjectId as wid,
					forumThread.forumId as forumId,
					page.urlizedTitle as urlizedTitle,
					page.languageId as languageId,
					page.pageId as pageId,
					page.groupIdView as page_groupIdView,
					wobject.groupIdView as wobject_groupIdView,
					7 as wobject_special_groupIdView
				from forumPost, forumThread, wobject, page
				where forumPost.forumThreadId = forumThread.forumThreadId
					and forumThread.forumId = wobject.forumId
					and wobject.pageId = page.pageId
					and wobject.startDate < $now 
					and wobject.endDate > $now
					and page.startDate < $now
					and page.endDate > $now",
			fieldsToIndex => ["username", "subject", "message"],
			contentType => 'discussion',
			url => 'WebGUI::URL::append($data{urlizedTitle},"func=view&wid=$data{wid}&forumId=$data{forumId}&forumOp=viewThread&forumPostId=$data{forumPostId}")',
			headerShortcut => 'select subject from forumPost where forumPostId = $data{forumPostId}',
			bodyShortcut => 'select message from forumPost where forumPostId = $data{forumPostId}',
	},
	userProfileData => {
			sql => "select distinct(userProfileData.userId),
					userProfileData.userId as ownerId,
					'' as languageId,
					b.fieldData as publicProfile,
					'profile' as namespace,
					1 as pageId,
					7 as page_groupIdView,
					7 as wobject_groupIdView,
					7 as wobject_special_groupIdView
					from userProfileData
					LEFT join userProfileData b
						on userProfileData.userId=b.userId 
						and b.fieldName='publicProfile'
					where b.fieldData=1;",
			fieldsToIndex => [ q/select concat(userProfileField.fieldName,' ',userProfileData.fieldData)
						from userProfileField, userProfileCategory, userProfileData
						where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
						and userProfileCategory.visible=1 
						and userProfileField.visible=1
						and userProfileData.fieldName = userProfileField.fieldName
						and fieldData <> ''
						and userProfileData.userId = $data{userId}
					   / ],
			url => '"?op=viewProfile&uid=$data{userId}"',
			contentType => 'profile',
			headerShortcut => 'select username from users where userId = $data{userId}',
			#bodyShortcut => q/select concat(fieldName,': ',fieldData) from userProfileData where userId = $data{userId}/
			bodyShortcut => '$textToIndex',
		}
	);
	foreach my $wobject (@{$session{config}{wobjects}}) {
		my $cmd = "WebGUI::Wobject::".$wobject;
                my $load = 'use '.$cmd;
                eval($load);
                WebGUI::ErrorHandler::warn("Wobject failed to compile: $cmd.".$@) if($@);
		my $w =  $cmd->new({wobjectId=>"new",namespace=>$wobject});
		%params = (%params, %{$w->getIndexerParams($now)});
	}
	return \%params;
}

1;
