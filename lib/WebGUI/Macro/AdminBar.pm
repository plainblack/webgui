package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(refs vars);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
	return "" unless ($session{var}{adminOn});
	my (%hash2, $miscSelect, $adminSelect, $clipboardSelect, %hash, $output, $contentSelect, $r, $i, @item, $query, %cphash);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
  #--content adder
	$hash{WebGUI::URL::page('op=editPage&npp='.$session{page}{pageId})} = WebGUI::International::get(2);
	if ($session{user}{uiLevel} >= 7) {
		$hash{WebGUI::URL::page('op=selectPackageToDeploy')} = WebGUI::International::get(376);
	}
	foreach my $namespace (@{$session{config}{wobjects}}) {
		my $cmd = "WebGUI::Wobject::".$namespace;	
		my $w = eval{$cmd->new({namespace=>$namespace,wobjectId=>"new"})};
		if ($@) {
			WebGUI::ErrorHandler::warn("Could not use wobject $namespace because: ".$@);
			next;
		}
                next if ($w->uiLevel > $session{user}{uiLevel});
		$hash{WebGUI::URL::page('func=edit&wid=new&namespace='.$namespace)} = $w->name;;
	}
	%hash = sortHash(%hash);
	%hash = (%{{WebGUI::URL::page()=>WebGUI::International::get(1)}},%hash);
        $contentSelect = WebGUI::Form::selectList({
		name=>"contentSelect",
		options=>\%hash,
		extras=>'onChange="goContent()"'
		});
  #--clipboard paster
	%hash2 = ();
	$hash2{WebGUI::URL::page()} = WebGUI::International::get(3);

	# get pages and store in array of arrays in order to integrate with wobjects and sort by buffer date
	if ($session{setting}{sharedClipboard} eq "1") {
		$query = "select bufferDate,pageId,title from page where parentId=2 order by bufferDate";
	} else {
		$query = "select bufferDate,pageId,title from page where parentId=2 "
			." and bufferUserId=$session{user}{userId} "
			." order by bufferDate";
	}
        $r = WebGUI::SQL->read($query);
        while (%cphash = $r->hash) {
		push @item, [	$cphash{bufferDate},
				WebGUI::URL::page('op=pastePage&pageId='.$cphash{pageId}),
				$cphash{title} . ' ('. WebGUI::International::get(2) .')' ];
	}
        $r->finish;

	# get wobjects and store in array of arrays in order to integrate with pages and sort by buffer date
	if ($session{setting}{sharedClipboard} eq "1") {
        	$query = "select bufferDate,wobjectId,title,namespace from wobject where pageId=2 "
			." order by bufferDate";
	} else {
        	$query = "select bufferDate,wobjectId,title,namespace from wobject where pageId=2 "
			." and bufferUserId=$session{user}{userId} "
			." order by bufferDate";
	}
        $r = WebGUI::SQL->read($query);
        while (%cphash = $r->hash) {
		push @item, [	$cphash{bufferDate},
				WebGUI::URL::page('func=paste&wid='.$cphash{wobjectId}),
				$cphash{title} . ' ('. $cphash{namespace} .')' ];
	}
        $r->finish;

	# Reverse sort by bufferDate and and create hash from list values
	my @sorted_item = sort {$b->[0] <=> $a->[0]} @item;
	@item = ();
 	for $i ( 0 .. $#sorted_item ) {
		$hash2{ $sorted_item[$i][1] } = $sorted_item[$i][2];
	}
	@sorted_item = ();

        $clipboardSelect = WebGUI::Form::selectList({
		name=>"clipboardSelect",
		options=>\%hash2,
		extras=>'onChange="goClipboard()"'
		});
   #--admin functions
	%hash = ();
	if (WebGUI::Privilege::isInGroup(3)) {
        	%hash = ( 
			WebGUI::URL::page('op=listGroups')=>WebGUI::International::get(5), 
			WebGUI::URL::page('op=manageSettings')=>WebGUI::International::get(4), 
			WebGUI::URL::page('op=listUsers')=>WebGUI::International::get(7),
			WebGUI::URL::page('op=viewStatistics')=>WebGUI::International::get(144),
			WebGUI::URL::page('op=listDatabaseLinks')=>WebGUI::International::get(981),
		);
	} elsif (WebGUI::Privilege::isInGroup(11)) {
                %hash = (
			WebGUI::URL::page('op=listGroupsSecondary')=>WebGUI::International::get(5), 
			WebGUI::URL::page('op=addUserSecondary')=>WebGUI::International::get(169),
                        %hash
                );
        }
	if (WebGUI::Privilege::isInGroup(4)) {
        	%hash = ( 
			WebGUI::URL::page('op=listRoots')=>WebGUI::International::get(410),
			'http://validator.w3.org/check?uri='.WebGUI::URL::escape(WebGUI::URL::page())=>WebGUI::International::get(399),
			WebGUI::URL::page('op=manageClipboard')=>WebGUI::International::get(949),
                        WebGUI::URL::page('op=listCollateral')=>WebGUI::International::get(394),
			WebGUI::URL::page('op=viewPageTree')=>WebGUI::International::get(447),
			WebGUI::URL::page('op=manageTrash')=>WebGUI::International::get(10),
			%hash
		);
	}
        if (WebGUI::Privilege::isInGroup(5)) {
                %hash = (
			WebGUI::URL::page('op=listStyles')=>WebGUI::International::get(6), 
			%hash
                );
        }
        if (WebGUI::Privilege::isInGroup(6)) {
                %hash = (
			WebGUI::URL::gateway('packages')=>WebGUI::International::get(374),
                        %hash
                );
        }
        if (WebGUI::Privilege::isInGroup(8)) {
                %hash = (
                        WebGUI::URL::page('op=listTemplates')=>WebGUI::International::get(508),
                        %hash
                );
        }
        if (WebGUI::Privilege::isInGroup(9)) {
                %hash = (
                        WebGUI::URL::page('op=listThemes')=>WebGUI::International::get(900),
                        %hash
                );
        }
        if (WebGUI::Privilege::isInGroup(10)) {
                %hash = (
			WebGUI::URL::page('op=listLanguages')=>WebGUI::International::get(585),
                        %hash
                );
        }
        %hash = (  
		WebGUI::URL::page('op=viewHelpIndex')=>WebGUI::International::get(13),
		%hash
	);
	%hash = sortHash(%hash);
        %hash = ( 
		''=>WebGUI::International::get(82), 
		WebGUI::URL::page('op=switchOffAdmin')=>WebGUI::International::get(12),
		%hash
	);
	$adminSelect = WebGUI::Form::selectList({
		name=>"adminSelect",
		options=>\%hash,
		extras=>'onChange="goAdmin()"'
		});
  #--output admin bar
	$output = '
	<div class="adminBar"><table class="adminBar" width="100%" cellpadding="3" cellspacing="0" border="0"><tr>
	<script language="JavaScript" type="text/javascript">	<!--
	function goContent(){
		location = document.content.contentSelect.options[document.content.contentSelect.selectedIndex].value
	}
        function goAdmin(){
                location = document.admin.adminSelect.options[document.admin.adminSelect.selectedIndex].value
        }
        function goClipboard(){
                location = document.clipboard.clipboardSelect.options[document.clipboard.clipboardSelect.selectedIndex].value
        }
	//-->	</script>
	<form name="content"> <td>'.$contentSelect.'</td> </form>
	<form name="clipboard"> <td align="center">'.$clipboardSelect.'</td> </form>
        <form name="admin"> <td align="center">'.$adminSelect.'</td> </form> 
	</tr></table></div>
	';
	return $output;
}




1;

