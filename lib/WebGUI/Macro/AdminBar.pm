package WebGUI::Macro::AdminBar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::AdminConsole;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Macro;
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
	my (%cphash, %hash2, %hash, $r, @item, $query);
	tie %hash, "Tie::IxHash";
	tie %hash2, "Tie::IxHash";
	tie %cphash, "Tie::CPHash";
  #--packages adder
	$var{'packages.canAdd'} = ($session{user}{uiLevel} >= 7);
	$var{'packages.label'} = WebGUI::International::get(376);
	my @packages;
	my $i;
	my $sth = WebGUI::SQL->read("select pageId,title from page where parentId='5'");
        while (my %data = $sth->hash) {
		$data{title} =~ s/'//g;
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
		my $load = "use ".$cmd;
		eval($load);
		WebGUI::ErrorHandler::warn("Wobject failed to compile: $cmd.".$@) if($@);
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
	$i = 0;
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
		$query = "select bufferDate,pageId,title from page where parentId='2' order by bufferDate";
	} else {
		$query = "select bufferDate,pageId,title from page where parentId='2' "
			." and bufferUserId=".quote($session{user}{userId})
			." order by bufferDate";
	}
        $r = WebGUI::SQL->read($query);
        while (%cphash = $r->hash) {
		$cphash{title} =~ s/'//g;
		push @item, [	$cphash{bufferDate},
				WebGUI::URL::page('op=pastePage&pageId='.$cphash{pageId}),
				$cphash{title} . ' ('. WebGUI::International::get(2) .')' ];
	}
        $r->finish;

	# get wobjects and store in array of arrays in order to integrate with pages and sort by buffer date
	if ($session{setting}{sharedClipboard} eq "1") {
        	$query = "select bufferDate,wobjectId,title,namespace from wobject where pageId='2' "
			." order by bufferDate";
	} else {
        	$query = "select bufferDate,wobjectId,title,namespace from wobject where pageId='2' "
			." and bufferUserId=".quote($session{user}{userId})
			." order by bufferDate";
	}
        $r = WebGUI::SQL->read($query);
        while (%cphash = $r->hash) {
		$cphash{title} =~ s/'//g;
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
	%hash = (
		'http://validator.w3.org/check?uri='.WebGUI::URL::escape(WebGUI::URL::page())=>WebGUI::International::get(399),
		);
	my $acParams = WebGUI::AdminConsole->getAdminConsoleParams;
	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
#	$acParams = WebGUI::AdminConsole->getAdminFunction("users");
#	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
#	$acParams = WebGUI::AdminConsole->getAdminFunction("groups");
#	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canUse});
#	$acParams = WebGUI::AdminConsole->getAdminFunction("assets");
#	$hash{$acParams->{url}} = $acParams->{title} if ($acParams->{canView});

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
	return WebGUI::Template::process($templateId,"Macro/AdminBar",\%var);
}




1;

