package WebGUI::Operation::Collateral;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Node;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use Tie::IxHash;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editCollateral &www_editCollateralSave &www_deleteCollateral 
	&www_deleteCollateralConfirm &www_listCollateral 
	&www_deleteFile &www_editCollateralFolder &www_editCollateralFolderSave &www_deleteCollateralFolder 
	&www_deleteCollateralFolderConfirm);

#-------------------------------------------------------------------
sub _submenu {
	my (%menu);
	tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editCollateralFolder&fid=new')} = WebGUI::International::get(758);
	$menu{WebGUI::URL::page('op=editCollateral&cid=new&type=image')} = WebGUI::International::get(761);
	$menu{WebGUI::URL::page('op=editCollateral&cid=new&type=file')} = WebGUI::International::get(762);
	$menu{WebGUI::URL::page('op=editCollateral&cid=new&type=snippet')} = WebGUI::International::get(763);
	if ($session{form}{op} eq "editCollateral" || $session{form}{op} eq "deleteCollateral") {
		$menu{WebGUI::URL::page('op=editCollateral&cid='.$session{form}{cid})} = WebGUI::International::get(764);
		$menu{WebGUI::URL::page('op=deleteCollateral&cid='.$session{form}{cid})} = WebGUI::International::get(765);
	}
	$menu{WebGUI::URL::page('op=editCollateralFolder')} = WebGUI::International::get(759);
	$menu{WebGUI::URL::page('op=deleteCollateralFolder')} = WebGUI::International::get(760);
	$menu{WebGUI::URL::page('op=listCollateral')} = WebGUI::International::get(766);
	return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_deleteCollateral {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
	$output .= WebGUI::International::get(774).'<p/><div align="center">';
	$output .= '<a href="'.WebGUI::URL::page('op=deleteCollateralConfirm&cid='.$session{form}{cid}).'">'
		.WebGUI::International::get(44).'</a>';
	$output .= '&nbsp;&nbsp;&nbsp;&nbsp;';
	$output .= '<a href="'.WebGUI::URL::page('op=listCollateral').'">'.WebGUI::International::get(45).'</a>';
	$output .= '</div>';
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteCollateralConfirm {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	my $node = WebGUI::Node("images",$session{form}{cid});
	WebGUI::SQL->write("delete from collateral where collateralId=".$session{form}{cid});
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_deleteCollateralFolder {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	return WebGUI::Privilege::vitalComponent() unless ($session{scratch}{collateralFolderId} > 999);
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
	$output .= WebGUI::International::get(775).'<p/><div align="center">';
        $output .= '<a href="'.WebGUI::URL::page('op=deleteCollateralFolderConfirm').'">'
                .WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;';
        $output .= '<a href="'.WebGUI::URL::page('op=listCollateral').'">'.WebGUI::International::get(45).'</a>';
	$output .= '</div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteCollateralFolderConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	return WebGUI::Privilege::vitalComponent() unless ($session{scratch}{collateralFolderId} > 999);
	my ($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder 
		where collateralFolderId=".$session{scratch}{collateralFolderId});
	WebGUI::SQL->write("update collateral set collateralFolderId=$parent 
		where collateralFolderId=$session{scratch}{collateralFolderId}");
        WebGUI::SQL->write("delete from collateralFolder where collateralFolderId=".$session{scratch}{collateralFolderId});
	WebGUI::Session::setScratch("collateralFolderId",$parent);
        return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_deleteFile {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	WebGUI::SQL->write("update collateral set filename='' where collateralId=".$session{form}{cid});
	return www_editCollateral();
}

#-------------------------------------------------------------------
sub www_editCollateral {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	my ($canEdit, $file, $folderId, $output, $f, $collateral);
	if ($session{form}{cid} eq "new") {
		$collateral->{collateralType} = $session{form}{type};
		$collateral->{collateralId} = "new";
		$collateral->{username} = $session{user}{username};
		$collateral->{userId} = $session{user}{userId};
		$collateral->{parameters} = 'border="0"' if ($session{form}{type} eq "image");
	} else {
		$collateral = WebGUI::SQL->quickHashRef("select * from collateral where collateralId=".$session{form}{cid});
	}
	$canEdit = ($collateral->{userId} == $session{user}{userId} || WebGUI::Privilege::isInGroup($session{user}{userId}));
	$folderId = $session{scratch}{collateralFolderId} || 0;
	$f = WebGUI::HTMLForm->new;
	$f->hidden("op","editCollateralSave");
	$f->hidden("collateralType",$collateral->{collateralType});
	$f->hidden("cid",$collateral->{collateralId});
	$f->readOnly(
		-label=>WebGUI::International::get(767),
		-value=>$collateral->{collateralId}
		);
        $f->readOnly(
                -label=>WebGUI::International::get(388),
                -value=>epochToHuman($collateral->{dateUploaded},"%z")
                );
        $f->readOnly(
                -label=>WebGUI::International::get(387),
                -value=>$collateral->{username}
                );
	if ($canEdit) {
		$f->text(
			-name=>"name",
			-value=>$collateral->{name},
			-label=>WebGUI::International::get(768)
			);
		$f->select(
			-name=>"collateralFolderId",
			-value=>[$folderId],
			-label=>WebGUI::International::get(769),
			-options=>WebGUI::SQL->buildHashRef("select collateralFolderId,name from collateralFolder order by name")
			);
	} else {
		$f->readOnly(
			-label=>WebGUI::International::get(768),
			-value=>$collateral->{name}
			);
	}
        if ($collateral->{collateralType} eq "snippet") {
                $output .= '<h1>'.WebGUI::International::get(770).'</h1>';
		if ($canEdit) {
			$f->HTMLArea(
				-name=>"parameters",
				-value=>$collateral->{parameters},
				-label=>WebGUI::International::get(771)
				);
		} else {
			$f->readOnly(
				-value=>$collateral->{parameters},
				-label=>WebGUI::International::get(771)
                                );
		}
        } elsif ($collateral->{collateralType} eq "file") {
                $output .= '<h1>'.WebGUI::International::get(772).'</h1>';
		if ($canEdit) {
			if ($collateral->{filename} ne "") {
				$f->readOnly(
					-value=>'<a href="'.WebGUI::URL::page('op=deleteFile&cid='
						.$collateral->{collateralId}).'">'.WebGUI::International::get(391).'</a>',
                        		-label=>WebGUI::International::get(773)
					);
			} else {
				$f->file(
					-name=>"filename",
					-label=>WebGUI::International::get(773)
					);
			}
		}
		$file = WebGUI::Attachment->new($collateral->{filename},"images",$collateral->{collateralId});
                if ($file->getFilename ne "") {
                        $f->readOnly(
                                -value=>'<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border="0" align="middle" /> '
					.$file->getFilename.'</a>'
                                );
                }
        } else {
		$output .= helpIcon(20);
                $output .= '<h1>'.WebGUI::International::get(382).'</h1>';
		if ($canEdit) {
                	if ($collateral->{filename} ne "") {
                        	$f->readOnly(
                                	-value=>'<a href="'.WebGUI::URL::page('op=deleteFile&cid='
						.$collateral->{collateralId}).'">'.
                                        	WebGUI::International::get(391).'</a>',
                                	-label=>WebGUI::International::get(384)
                        		);
                	} else {
                        	$f->file(
                                	-name=>"filename",
                                	-label=>WebGUI::International::get(384)
                                	);
                	}
		}
		$file = WebGUI::Attachment->new($collateral->{filename},"images",$collateral->{collateralId});
        	if ($file->getFilename ne "") {
			$f->readOnly(
                		-value=>'<a href="'.$file->getURL.'"><img src="'.$file->getThumbnail.'" border="0" /></a>'
				);
        	}
		if ($canEdit) {
                	$f->textarea(
                        	-name=>"parameters",
                        	-value=>$collateral->{parameters},
                        	-label=>WebGUI::International::get(385)
                        	);
		} else {
			$f->readOnly(
				-label=>WebGUI::International::get(385),
				-value=>$collateral->{parameters}
				);
		}
        }
	$f->submit if ($canEdit);
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editCollateralSave {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	WebGUI::Session::setScratch("collateralFolderId",$session{form}{collateralFolderId});
	my ($test, $file, $addFile);
	if ($session{form}{cid} eq "new") {
		$session{form}{cid} = getNextId("collateralId");
		WebGUI::SQL->write("insert into collateral (collateralId,userId,username,collateralType) 
			values ($session{form}{cid},
			$session{user}{userId}, ".quote($session{user}{username}).",
			".quote($session{form}{collateralType}).")");
	}
        $file = WebGUI::Attachment->new("","images",$session{form}{cid});
       	$file->save("filename");
	if ($file->getFilename ne "") {
        	$addFile = ", filename=".quote($file->getFilename);
		$session{form}{name} = $file->getFilename if ($session{form}{name} eq "");
	}
	$session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (($test) = WebGUI::SQL->quickArray("select name from collateral 
		where name=".quote($session{form}{name})." and collateralId<>$session{form}{cid}")) {
        	if ($session{form}{name} =~ /(.*)(\d+$)/) {
                	$session{form}{name} = $1.($2+1);
        	} elsif ($test ne "") {
                	$session{form}{name} .= "2";
                }
        }
	WebGUI::SQL->write("update collateral set name=".quote($session{form}{name}).", parameters="
		.quote($session{form}{parameters}).", collateralFolderId=$session{form}{collateralFolderId}, dateUploaded="
		.time()." $addFile where collateralId=$session{form}{cid}");
	$session{form}{collateralType} = "";
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_editCollateralFolder {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	my ($output, $f, $folder, $folderId, $constraint);
	$output .= '<h1>'.WebGUI::International::get(776).'</h1>';
	if ($session{form}{fid} eq "new") {
		$folder->{collateralFolderId} = "new";
		$folder->{parentId} = $session{scratch}{collateralFolderId} || 0;
	} else {
		$folderId = $session{scratch}{collateralFolderId} || 0;
		$folder = WebGUI::SQL->quickHashRef("select * from collateralFolder where collateralFolderId=$folderId");
		$constraint = "where collateralFolderId<>".$folder->{collateralFolderId};
	}
	$f = WebGUI::HTMLForm->new;
	$f->hidden("op","editCollateralFolderSave");
	$f->hidden("fid",$session{form}{fid});
	$f->readOnly(
		-value=>$folder->{collateralFolderId},
		-label=>WebGUI::International::get(777)
		);
	if ($folder->{collateralFolderId} eq "0") {
		$f->hidden("parentId",0);
	} else {
		$f->select(
                	-name=>"parentId",
                	-value=>[$folder->{parentId}],
                	-label=>WebGUI::International::get(769),
                	-options=>WebGUI::SQL->buildHashRef("select collateralFolderId,name from collateralFolder
				$constraint order by name")
                	);
	}
	$f->text(
		-value=>$folder->{name},
		-name=>"name",
		-label=>WebGUI::International::get(768)
		);
	$f->textarea(
		-value=>$folder->{description},
		-name=>"description",
		-label=>WebGUI::International::get(778)
		);
	$f->submit;
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editCollateralFolderSave {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	if ($session{form}{fid} eq "new") {
		$session{form}{fid} = getNextId("collateralFolderId");
		WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
		WebGUI::SQL->write("insert into collateralFolder (collateralFolderId) values ($session{form}{fid})");
	}
	$session{form}{name} = "untitled" if ($session{form}{name} eq "");
	while (my ($test) = WebGUI::SQL->quickArray("select name from collateralFolder
                where name=".quote($session{form}{name})." and collateralFolderId<>$session{scratch}{collateralFolderId}")) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
	WebGUI::SQL->write("update collateralFolder set parentId=$session{form}{parentId}, name=".quote($session{form}{name})
		.", description=".quote($session{form}{description})
		." where collateralFolderId=$session{scratch}{collateralFolderId}");
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_listCollateral {
	return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(4));
	my (%type, %user, $f, $row, $data, $sth, $url, $output, $parent, $p, $thumbnail, $file, $page, $constraints, $folderId);
	tie %type, 'Tie::IxHash';
	tie %user, 'Tie::IxHash';
	%type = (
		'-delete-'=>WebGUI::International::get(782),
        	image=>WebGUI::International::get(779),
       		file=>WebGUI::International::get(780),
        	snippet=>WebGUI::International::get(781)
        	);
	%user = (
		'-delete-'=>WebGUI::International::get(782),
		%{WebGUI::SQL->buildHashRef("select distinct(userId), username from collateral order by username")}
		);
	$session{form}{keyword} = '-delete-' if (exists $session{form}{keyword} && $session{form}{keyword} eq "");
	WebGUI::Session::setScratch("keyword",$session{form}{keyword});
	WebGUI::Session::setScratch("collateralUser",$session{form}{collateralUser});
	WebGUI::Session::setScratch("collateralType",$session{form}{collateralType});
	WebGUI::Session::setScratch("collateralPageNumber",$session{form}{pn});
	WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
	$folderId = $session{scratch}{collateralFolderId} || 0;
	$constraints = "collateralFolderId=".$folderId;
	$constraints .= " and userId=$session{scratch}{collateralUser}" if ($session{scratch}{collateralUser});
	$constraints .= " and collateralType=".quote($session{scratch}{collateralType}) if ($session{scratch}{collateralType});
	$constraints .= " and name like ".quote('%'.$session{scratch}{keyword}.'%') if ($session{scratch}{keyword});
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listCollateral'),[],"",$session{scratch}{collateralPageNumber});
	$p->setDataByQuery("select collateralId, name, filename, collateralType, dateUploaded, username 
		from collateral where $constraints order by name");
	$page = $p->getPageData;
	$output = helpIcon(49);
	$output .= '<h1>'.WebGUI::International::get(757).'</h1>';
	$f = WebGUI::HTMLForm->new(1);
	$f->hidden("op","listCollateral");
	$f->hidden("pn",1);
	$f->text(
		-name=>"keyword",
		-value=>$session{scratch}{keyword},
		-size=>15
		);
	$f->select(
		-name=>"collateralUser",
		-value=>[$session{scratch}{collateralUser}],
		-options=>\%user
		);
	$f->select(
		-name=>"collateralType",
		-value=>[$session{scratch}{collateralType}],
		-options=>\%type
		);
	$f->submit(WebGUI::International::get(170));
	$output .= '<div align="center">'.$f->print.'</div>';
	$output .= '<table align="center" border="1" cellpadding="2" cellspacing="0">';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(768).'</td><td class="tableHeader">'
		.WebGUI::International::get(783).'</td><td class="tableHeader">'.WebGUI::International::get(387)
		.'</td><td class="tableHeader">'.WebGUI::International::get(388).'</td><td class="tableHeader">'
		.WebGUI::International::get(784).'</td></tr>';
	if ($folderId) {
		($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder 
			where collateralFolderId=$folderId");
		$output .= '<tr><td colspan="5" class="tableData"><a href="'.WebGUI::URL::page('op=listCollateral&fid='
			.$parent.'&pn=1')
                        .'"><img src="'.$session{config}{extras}.'/smallAttachment.gif" border="0">'
                        .'&nbsp;'.WebGUI::International::get(542).'</a></td></tr>';
	}
	$sth = WebGUI::SQL->read("select collateralFolderId, name, description from collateralFolder 
		where parentId=$folderId and collateralFolderId<>0 order by name");
	while ($data = $sth->hashRef) {
		$output .= '<tr><td class="tableData"><a href="'.WebGUI::URL::page('op=listCollateral&fid='
			.$data->{collateralFolderId}.'&pn=1')
                        .'"><img src="'.$session{config}{extras}.'/smallAttachment.gif" border="0">'
                        .'&nbsp;'.$data->{name}.'</a></td><td class="tableData" colspan="4">'.$data->{description}.'</td></tr>';
	}
	$sth->finish;
	foreach $row (@$page) {
		$url = WebGUI::URL::page('op=editCollateral&cid='.$row->{collateralId}.'&fid='.$folderId);
		$output .= '<tr>';
		$output .= '<td class="tableData"><a href="'.$url.'">'.$row->{name}.'</a></td>';
		$output .= '<td class="tableData">'.$type{$row->{collateralType}}.'</td>';
		$output .= '<td class="tableData">'.$row->{username}.'</td>';
		$output .= '<td class="tableData">'.epochToHuman($row->{dateUploaded},"%z").'</td>';
		if ($row->{filename} ne "" && $row->{collateralType} eq "image") {
			$file = WebGUI::Attachment->new($row->{filename},"images",$row->{collateralId});
			$thumbnail = '<a href="'.$url.'"><img src="'.$file->getThumbnail.'" border="0" /></a>';
		} elsif ($row->{filename} ne "" && $row->{collateralType} eq "file") {
			$file = WebGUI::Attachment->new($row->{filename},"images",$row->{collateralId});
			$thumbnail = '<a href="'.$url.'"><img src="'.$file->getIcon.'" border="0" /></a>';
		} else {
			$thumbnail = "";
		}
		$output .= '<td class="tableData">'.$thumbnail.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional;
	return _submenu($output);
}

1;

