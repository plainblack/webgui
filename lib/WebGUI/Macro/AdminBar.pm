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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub process {
	return "" unless ($session{var}{adminOn});
	my @param = WebGUI::Macro::getParams($_[0]);
        my $templateId = $param[0] || 1;
        my %var;
	my (%cphash, %hash2, %hash, $r, $i, @item, $query);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
  #--packages adder
	$var{'packages.canAdd'} = ($session{user}{uiLevel} >= 7);
	$var{'packages.label'} = WebGUI::International::get(376);
	my @packages;
	my $i;
	my $sth = WebGUI::SQL->read("select pageId,title from page where parentId=5");
        while (my %data = $sth->hash) {
		push(@packages, {
        		'package.url'=>WebGUI::URL::page('op=deployPackage&pid='.$data{pageId}),
               		'package.label'=>$data{title},
			'package.count'=>$i
			});
		$i++;
        }
        $sth->finish;
	$var{package_loop} = \@packages;
  #--contenttypes adder
	$var{'contentTypes.label'} = WebGUI::International::get(1083);
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
	$var{'addcontent.label'} = WebGUI::International::get(1);
	my @addcontent;
	my $i = 0;
	foreach my $key (keys %hash) {
		push(@addcontent,{
			'contenttype.url'=>$key,
			'contenttype.label'=>$hash{$key},
			'contenttype.count'=>$i
			});
		$i++;
	}
	$var{'contenttypes_loop'} = \@addcontent;
	$var{'addpage.url'} = WebGUI::URL::page('op=editPage&npp='.$session{page}{pageId});
	$var{'addpage.label'} = WebGUI::International::get(2);
  #--clipboard paster
	$var{'clipboard.label'} = WebGUI::International::get(1082);
	%hash2 = ();

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
	my @clipboard;
	$i = 0;
	foreach my $key (keys %hash2) {
		push(@clipboard,{
			'clipboard.url'=>$key,
			'clipboard.label'=>$hash2{$key},
			'clipboard.count'=>$i
			});
		$i++;
	}
	$var{'clipboard_loop'} = \@clipboard;
   #--admin functions
	%hash = ();
	if (WebGUI::Privilege::isInGroup(3)) {
        	%hash = ( 
			WebGUI::URL::page('op=listGroups')=>WebGUI::International::get(5), 
			WebGUI::URL::page('op=manageSettings')=>WebGUI::International::get(4), 
			WebGUI::URL::page('op=listUsers')=>WebGUI::International::get(7),
			WebGUI::URL::page('op=viewStatistics')=>WebGUI::International::get(144),
			WebGUI::URL::page('op=listDatabaseLinks')=>WebGUI::International::get(981),
			WebGUI::URL::page('op=listNavigation')=>'Manage navigation.'
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
		WebGUI::URL::page('op=switchOffAdmin')=>WebGUI::International::get(12),
		%hash
	);
	$var{'admin.label'} = WebGUI::International::get(82);
	my @admin;
	$i = 0;
	foreach my $key (keys %hash) {	
		push(@admin,{
			'admin.url'=>$key,
			'admin.label'=>$hash{$key},
			'admin.count'=>$i
			});
		$i++;
	}
	$var{'admin_loop'} = \@admin;
	return WebGUI::Template::process(WebGUI::Template::get($templateId,"Macro/AdminBar"),\%var);
}




1;

