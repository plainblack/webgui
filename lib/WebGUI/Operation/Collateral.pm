package WebGUI::Operation::Collateral;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


# test for ImageMagick. if it's not installed set $hasImageMagick to 0,
# if it is installed it will be set to 1
my $hasImageMagick=1;
eval " use Image::Magick; "; $hasImageMagick=0 if $@;


use strict;
use WebGUI::Collateral;
use WebGUI::CollateralFolder;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use Tie::IxHash;
use WebGUI::URL;
use WebGUI::HTML;


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
	if (WebGUI::Grouping::isInGroup(3)) {
		$menu{WebGUI::URL::page('op=emptyCollateralFolder')} = WebGUI::International::get(980);
#		$menu{WebGUI::URL::page('op=deleteCollateralFolder')} = WebGUI::International::get(760);
	}
	$menu{WebGUI::URL::page('op=listCollateral')} = WebGUI::International::get(766);
	return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_deleteCollateral {
	my $collateral = WebGUI::Collateral->new($session{form}{cid});
        return WebGUI::Privilege::insufficient unless ($collateral->get("userId") == $session{user}{userId} || WebGUI::Grouping::isInGroup(3));
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
	my $collateral = WebGUI::Collateral->new($session{form}{cid});
        return WebGUI::Privilege::insufficient unless ($collateral->get("userId") == $session{user}{userId} || WebGUI::Grouping::isInGroup(3));
	$collateral->delete;
	WebGUI::Session::deleteScratch("collateralPageNumber");
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_deleteCollateralFile {
	my $collateral = WebGUI::Collateral->new($session{form}{cid});
        return WebGUI::Privilege::insufficient unless ($collateral->get("userId") == $session{user}{userId} || WebGUI::Grouping::isInGroup(3));
	$collateral->deleteFile;
	return www_editCollateral($collateral);
}

#-------------------------------------------------------------------
sub www_deleteCollateralFolder {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	return WebGUI::Privilege::vitalComponent() if ($session{scratch}{collateralFolderId} eq "0" || $session{scratch}{collateralFolderId} eq "");
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
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	return WebGUI::Privilege::vitalComponent() if ($session{scratch}{collateralFolderId} eq "0" || $session{scratch}{collateralFolderId} eq "");
        my $folders = WebGUI::CollateralFolder->getTree({-minimumFields => 1});
        if (my $deadFolder = $folders->{$session{scratch}{collateralFolderId}}) {
          my $parentId = $deadFolder->get("parentId");
          $deadFolder->recursiveDelete();
          WebGUI::Session::setScratch("collateralFolderId",$parentId);
        }
        return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_emptyCollateralFolder {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
	$output .= WebGUI::International::get(979).'<p/><div align="center">';
        $output .= '<a href="'.WebGUI::URL::page('op=emptyCollateralFolderConfirm').'">'
                .WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;';
        $output .= '<a href="'.WebGUI::URL::page('op=listCollateral').'">'.WebGUI::International::get(45).'</a>';
	$output .= '</div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_emptyCollateralFolderConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	my @collateralIds = WebGUI::SQL->buildArray("select collateralId from collateral where collateralFolderId=".quote($session{scratch}{collateralFolderId}));
	WebGUI::Collateral->multiDelete(@collateralIds);
        return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_editCollateral {
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(4));
	my ($canEdit, $file, $folderId, $output, $f, $collateral, $image, $error, $x, $y);
	if ($session{form}{cid} eq "new") {
		$collateral->{collateralType} = $session{form}{type};
		$collateral->{collateralId} = "new";
		$collateral->{username} = $session{user}{username};
		$collateral->{userId} = $session{user}{userId};
		$collateral->{parameters} = 'border="0"' if ($session{form}{type} eq "image");
		$collateral->{thumbnailSize} = $session{setting}{thumbnailSize};
	} else {
		my $c = $_[1] || WebGUI::Collateral->new($session{form}{cid});
		$collateral = $c->get;
	}
	$canEdit = ($collateral->{userId} == $session{user}{userId} || WebGUI::Grouping::isInGroup(3));
	$folderId = $session{scratch}{collateralFolderId} || 0;
	$f = WebGUI::HTMLForm->new;
	$f->hidden("op","editCollateralSave");
	$f->hidden("collateralType",$collateral->{collateralType});
	$f->hidden("cid",$collateral->{collateralId});
	$f->hidden("userId", $collateral->{userId});
	$f->hidden("userName", $collateral->{userName});
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
		$f->selectList(
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
			$f->textarea(
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
					-value=>'<a href="'.WebGUI::URL::page('op=deleteCollateralFile&cid='
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
		$output .= helpIcon("image add/edit");
                $output .= '<h1>'.WebGUI::International::get(382).'</h1>';
		if ($canEdit) {
                	if ($collateral->{filename} ne "") {
                        	$f->readOnly(
                                	-value=>'<a href="'.WebGUI::URL::page('op=deleteCollateralFile&cid='
						.$collateral->{collateralId}).'">'.WebGUI::International::get(391).'</a>',
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
        		if ($hasImageMagick) {
        			$image = Image::Magick->new;
				$error = $image->Read($file->getPath);
				($x, $y) = $image->Get('width','height');
				$f->readOnly(
					-value=>$error ? "Error reading image: $error" : "$x x $y",
					-label=>"Image dimensions"
					);
			}
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
		if ($canEdit && $collateral->{collateralType} eq 'image') {
			$f->text(
				-name=>"thumbnailSize",
				-value=>$collateral->{thumbnailSize},
				-label=>"Thumbnail size"
				);
		}
        }
	$f->submit if ($canEdit);
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editCollateralSave {
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(4));
	WebGUI::Session::setScratch("collateralFolderId",$session{form}{collateralFolderId});
	my ($test, $file, $addFile);
	my $collateral = WebGUI::Collateral->new($session{form}{cid});
	$session{form}{thumbnailSize} ||= $session{setting}{thumbnailSize};
	if ($session{form}{cid} eq "new") {
		$session{form}{cid} = $collateral->get("collateralId");
	} elsif ($collateral->get("thumbnailSize") != $session{form}{thumbnailSize}) {
		$collateral->createThumbnail($session{form}{thumbnailSize});
	}
       	$collateral->save("filename", $session{form}{thumbnailSize});
	$session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (($test) = WebGUI::SQL->quickArray("select name from collateral 
		where name=".quote($session{form}{name})." and collateralId<>".quote($collateral->get("collateralId")))) {
        	if ($session{form}{name} =~ /(.*)(\d+$)/) {
                	$session{form}{name} = $1.($2+1);
        	} elsif ($test ne "") {
                	$session{form}{name} .= "2";
                }
        }
	$collateral->set($session{form});
	$session{form}{collateralType} = "";
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_editCollateralFolder {
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(4));
	my ($output, $f, $folder, $folderId, $constraint);
	$output .= '<h1>'.WebGUI::International::get(776).'</h1>';
	if ($session{form}{fid} eq "new") {
		$folder->{collateralFolderId} = "new";
		$folder->{parentId} = $session{scratch}{collateralFolderId} || 0;
	} else {
		$folderId = $session{scratch}{collateralFolderId} || 0;
		$folder = WebGUI::SQL->quickHashRef("select * from collateralFolder where collateralFolderId=".quote($folderId));
		$constraint = "where collateralFolderId<>".quote($folder->{collateralFolderId});
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
		$f->selectList(
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
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(4));
	if ($session{form}{fid} eq "new") {
		$session{form}{fid} = WebGUI::Id::generate();
		WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
		WebGUI::SQL->write("insert into collateralFolder (collateralFolderId) values (".quote($session{form}{fid}).")");
	}
	my $folderId = $session{scratch}{collateralFolderId} || 0;
	$session{form}{name} = "untitled" if ($session{form}{name} eq "");
	while (my ($test) = WebGUI::SQL->quickArray("select name from collateralFolder
                where name=".quote($session{form}{name})." and collateralFolderId<>".quote($folderId))) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
	WebGUI::SQL->write("update collateralFolder set parentId=".quote($session{form}{parentId}).", name=".quote($session{form}{name})
		.", description=".quote($session{form}{description})
		." where collateralFolderId=".quote($folderId));
	return www_listCollateral();
}

#-------------------------------------------------------------------
sub www_listCollateral {
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(4));
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
	WebGUI::Session::setScratch("keyword",$session{form}{keyword});
	WebGUI::Session::setScratch("collateralUser",$session{form}{collateralUser});
	WebGUI::Session::setScratch("collateralType",$session{form}{collateralType});
	WebGUI::Session::setScratch("collateralPageNumber",$session{form}{pn});
	WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
	$folderId = $session{scratch}{collateralFolderId} || 0;
	$constraints = "collateralFolderId=".quote($folderId);
	$constraints .= " and userId=".quote($session{scratch}{collateralUser}) if ($session{scratch}{collateralUser});
	$constraints .= " and collateralType=".quote($session{scratch}{collateralType}) if ($session{scratch}{collateralType});
	$constraints .= " and name like ".quote('%'.$session{scratch}{keyword}.'%') if ($session{scratch}{keyword});
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listCollateral'),"",$session{scratch}{collateralPageNumber});
	$p->setDataByQuery("select collateralId, name, filename, collateralType, dateUploaded, username, parameters 
		from collateral where $constraints order by name");
	$page = $p->getPageData;
	$output = helpIcon("collateral manage");
	$output .= '<h1>'.WebGUI::International::get(757).'</h1>';
	$f = WebGUI::HTMLForm->new(1);
	$f->hidden("op","listCollateral");
	$f->hidden("pn",1);
	$f->text(
		-name=>"keyword",
		-value=>$session{scratch}{keyword},
		-size=>15
		);
	$f->selectList(
		-name=>"collateralUser",
		-value=>[$session{scratch}{collateralUser}],
		-options=>\%user
		);
	$f->selectList(
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
		($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder where collateralFolderId=".quote($folderId));
		$output .= '<tr><td colspan="5" class="tableData"><a href="'.WebGUI::URL::page('op=listCollateral&fid='
			.$parent.'&pn=1')
                        .'"><img src="'.$session{config}{extrasURL}.'/smallAttachment.gif" border="0">'
                        .'&nbsp;'.WebGUI::International::get(542).'</a></td></tr>';
	}
	$sth = WebGUI::SQL->read("select collateralFolderId, name, description from collateralFolder 
		where parentId=".quote($folderId)." order by name");
	while ($data = $sth->hashRef) {
		$output .= '<tr><td class="tableData"><a href="'.WebGUI::URL::page('op=listCollateral&fid='
			.$data->{collateralFolderId}.'&pn=1')
                        .'"><img src="'.$session{config}{extrasURL}.'/smallAttachment.gif" border="0">'
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
		} elsif ($row->{collateralType} eq "snippet") {
			$thumbnail = WebGUI::HTML::filter($row->{parameters},'all');
			$thumbnail =~ s/(\n[^\n]\r?|\r[^\r]\n?)/\&crarr;/gs;
			$thumbnail =~ s/\s{2,}//g;
			$thumbnail =~ s/\s*\&crarr;+\s*/\&crarr;/g;
			$thumbnail =~ s/^(\&crarr;)+//;
			my $crCount = $thumbnail =~ m/\&crarr;/g;
			$thumbnail = substr($thumbnail,0,$session{setting}{snippetsPreviewLength}+$crCount*6);
			$thumbnail .= '...' if (length($row->{parameters}) > $session{setting}{snippetsPreviewLength});
		} else {
			$thumbnail = "";
		}
		$output .= '<td class="tableData">'.$thumbnail.'</td>';
		$output .= "</tr>\n";
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub _htmlAreaCreateTree {
	my ($output);
	my ($name, $description, $url, $image, $indent, $target, $delete) = @_;
	if($delete) {
		$delete  = qq/<a href="javascript:deleteCollateral('$delete')" title="delete $name">/;
		 $delete .= deleteIcon()."</a>";
	}
	$target = ' target="'.$target.'" ' if ($target);
	$output .= '<tr><td align="left" valign="bottom" width="100%">';
	$output .= ('<img src="'.$session{config}{extrasURL}.'/tinymce/images/indent.gif" width="17" heigth="17">') x$indent;
	$output .= '<img src="'.$session{config}{extrasURL}.'/tinymce/images/'.$image.'" align="bottom" alt="'.$name.'">';
	$output .= '<a title="'.$description.'" href="'.$url.'" '.$target.'><b>'.$name.'</b></a></td>';
	$output .= '<td class="delete" align="right" valign="bottom">'.$delete.'</td></tr>';
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlArealistCollateral {
	my (@parents, $sth, $data, $indent);
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));

	my $output = '<table border="0" cellspacing="0" cellpadding="0" width="100%">';
	my $folderId = $session{form}{fid} || 0;
	my $parent = $folderId;
	# push parent folders in array so it can be reversed
	unshift(@parents, $parent);
	until($parent eq '0') {
		($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder where collateralFolderId=".quote($parent));
		unshift(@parents, $parent);
	}
	# Build tree for opened parent folders
	foreach $parent (@parents) { 
		my ($name, $description) = WebGUI::SQL->quickArray("select name, description from 
							collateralFolder where collateralFolderId=".quote($parent));
		my ($itemsInFolder) = WebGUI::SQL->quickArray("select count(*) from collateral where collateralFolderId = ".quote($parent));
		my ($foldersInFolder)=WebGUI::SQL->quickArray("select count(*) from collateralFolder where parentId=".quote($parent));
		my $delete = "fid=$parent" unless ($itemsInFolder + $foldersInFolder);
		$output .= _htmlAreaCreateTree($name, $description, 
				WebGUI::URL::page('op=htmlArealistCollateral&fid='.$parent), "opened.gif", 
				$indent++,"" ,$delete);
	}
	# Extend tree with closed folders in current folder
	$sth = WebGUI::SQL->read("select collateralFolderId, name, description from collateralFolder
		                  where parentId=".quote($folderId)." and collateralFolderId <> '0' order by name");
        while ($data = $sth->hashRef) { 
		my ($itemsInFolder) = WebGUI::SQL->quickArray("select count(*) from collateral where 
							collateralFolderId = ".quote($data->{collateralFolderId}));
		my $delete = 'fid='.$data->{collateralFolderId} unless $itemsInFolder;
		$output .= _htmlAreaCreateTree($data->{name}, $data->{description}, 
					WebGUI::URL::page('op=htmlArealistCollateral&fid='.$data->{collateralFolderId}), 
					"closed.gif", $indent, "", $delete);
        }
	# Extend tree with images in current folder
	$sth = WebGUI::SQL->read("select collateralId, name, filename from collateral where collateralType = 'image' ".
                                 "and collateralFolderId = ".quote($folderId));
	while ($data = $sth->hashRef) {
		$data->{filename} =~ /\.([^\.]+)$/; # Get extension
		my $fileType = $1.'.gif';
		$output .= _htmlAreaCreateTree($data->{filename}, $data->{name},
					WebGUI::URL::page('op=htmlAreaviewCollateral&cid='.$data->{collateralId}),
					$fileType, $indent, "viewer", 'cid='.$data->{collateralId}.'&fid='.$folderId);
	}
	$output .= '</table>';
	$output .= '<script language="javascript">'."\n".'actionComplete("","'.$folderId.'","","");';
	$output .= "\n</script>\n";
	$sth->finish;
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlAreaviewCollateral {
	my($output, $collateral, $file, $x, $y, $image, $error);
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
        $output .= '<table align="center" border="0" cellspacing="0" cellpadding="2" width="100%" height="100%">';
	if($session{form}{cid} eq "" || ! WebGUI::Grouping::isInGroup(4)) {
		$output .= '<tr><td align="center" valign="middle" width="100%" height="100%">';
		$output .= '<p align="center"><br><img src="'.$session{config}{extrasURL}.'/tinymce/images/icon.gif" 
			    border="0"></p>';
		$output .= '<P align=center><STRONG>WebGUI Image Manager<BR>for TinyMCE</STRONG></P>';
		$output .= '</td></tr></table>';
	} else {
		my $c = WebGUI::Collateral->new($session{form}{cid});
		$collateral = $c->get;
		$file = WebGUI::Attachment->new($collateral->{filename},"images",$collateral->{collateralId});
		$output .= '<tr><td class="label" align="center" valign="middle" width="100%">';
		$output .= '<b>'.$file->getFilename.'</b><br>';
		if ($hasImageMagick) {
			$image = Image::Magick->new;
			$error = $image->Read($file->getPath);
			($x, $y) = $image->Get('width','height');
			$output .= $error ? "Error reading image: $error" : "<i>($x &#215; $y)</i>";
		}
		$output .= '</td></tr><tr><td align="center" valign="middle" width="100%" height="100%">';
		$output .= '<img src="'.$file->getThumbnail.'" border="0">';
		$output .= '</td></tr></table>';
		$output .= '<script language="javascript">';
		$output .= "\nvar src = '".$file->getURL."';\n";
		$output .= "if(src.length > 0) {
   				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
		    		}
		    	    </script>\n";
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlAreaUpload {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
	return www_htmlArealistCollateral() if ($session{form}{image} eq "");
	my($test, $file);
	$session{form}{fid} = $session{form}{collateralFolderId} = $session{form}{path};
        my $collateral = WebGUI::Collateral->new("new");
        $session{form}{thumbnailSize} ||= $session{setting}{thumbnailSize};
        $session{form}{cid} = $collateral->get("collateralId");
        $collateral->save("image", $session{form}{thumbnailSize});
        $session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (($test) = WebGUI::SQL->quickArray("select name from collateral
                where name=".quote($session{form}{name})." and collateralId<>".quote($collateral->get("collateralId")))) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
        $collateral->set($session{form});
        $session{form}{collateralType} = "";
        return www_htmlArealistCollateral();
}

#-------------------------------------------------------------------
sub www_htmlAreaDelete {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
	if($session{form}{cid}) { # Delete Image
	        my $collateral = WebGUI::Collateral->new($session{form}{cid});
        	$collateral->delete;
	} elsif($session{form}{fid} and not($session{form}{cid})) {
		return WebGUI::Privilege::vitalComponent() unless ($session{form}{fid} > 999);
	        my ($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder where collateralFolderId=".quote($session{form}{fid}));
	        WebGUI::SQL->write("delete from collateralFolder where collateralFolderId=".quote($session{form}{fid}));
		$session{form}{fid}=$parent;	
	}	
        return www_htmlArealistCollateral();
}

#-------------------------------------------------------------------
sub www_htmlAreaCreateFolder {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
        $session{form}{fid} = WebGUI::Id::generate();
        WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
        WebGUI::SQL->write("insert into collateralFolder (collateralFolderId) values (".quote($session{form}{fid}).")");
        my $folderId = $session{scratch}{collateralFolderId} || 0;
	$session{form}{name} = $session{form}{folder};
        $session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (my ($test) = WebGUI::SQL->quickArray("select name from collateralFolder
                where name=".quote($session{form}{name})." and collateralFolderId<>".quote($folderId))) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
        WebGUI::SQL->write("update collateralFolder set parentId=".quote($session{form}{path}).", name=".quote($session{form}{name})
                .", description=".quote($session{form}{description})." where collateralFolderId=".quote($folderId));
	$session{form}{fid} = $session{form}{path};
        return www_htmlArealistCollateral();
}


1;
