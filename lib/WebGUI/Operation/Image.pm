package WebGUI::Operation::Image;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editImage &www_editImageSave &www_viewImage &www_deleteImage &www_deleteImageConfirm &www_listImages &www_deleteImageFile &www_editImageGroup &www_editImageGroupSave &www_viewImageGroup &www_deleteImageGroup &www_deleteImageGroupConfirm);

#-------------------------------------------------------------------
sub www_deleteImage {
        my ($output);
        if (WebGUI::Privilege::isInGroup(9)) {
                $output .= helpIcon(23);
                $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(392).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteImageConfirm&iid='.$session{form}{iid}.'&gid='.$session{form}{gid})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listImages&gid='.$session{form}{gid}).'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageConfirm {
	my ($image);
        if (WebGUI::Privilege::isInGroup(9)) {
                $image = WebGUI::Attachment->new("","images",$session{form}{iid});
		$image->deleteNode;
                WebGUI::SQL->write("delete from images where imageId=$session{form}{iid}");
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageFile {
        if (WebGUI::Privilege::isInGroup(9)) {
                WebGUI::SQL->write("update images set filename='' where imageId=$session{form}{iid}");
                return www_editImage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImage {
        my ($output, %data, $image, $f, $imageGroupId);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(9)) {
		if ($session{form}{iid} eq "new") {
			$imageGroupId = $session{form}{gid};
		} else {
			%data = WebGUI::SQL->quickHash("select * from images where imageId=$session{form}{iid}");
			$imageGroupId = $data{imageGroupId};
		}
                $output = helpIcon(20);
                $output .= '<h1>'.WebGUI::International::get(382).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editImageSave");
                $f->hidden("iid",$session{form}{iid});
                $f->hidden("gid",$imageGroupId);
                $f->readOnly($session{form}{iid},WebGUI::International::get(389));
                $f->text("name",WebGUI::International::get(383),$data{name});
		if ($data{filename} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('op=deleteImageFile&iid='.$data{imageId}).'">'.WebGUI::International::get(391).'</a>',
				WebGUI::International::get(384));
		} else {
			$f->file("filename",WebGUI::International::get(384));
		}
		$f->textarea("parameters",WebGUI::International::get(385),$data{parameters});
		$f->submit;
		$output .= $f->print;
		if ($data{filename} ne "") {
			$image = WebGUI::Attachment->new($data{filename},"images",$data{imageId});
			$output .= '<p>'.WebGUI::International::get(390).'<p><img src="'.$image->getURL.'">';
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImageSave {
        my ($file, $sqlAdd, $test);
        if (WebGUI::Privilege::isInGroup(9)) {
		if ($session{form}{iid} eq "new") {
			$session{form}{iid} = getNextId("imageId");
			WebGUI::SQL->write("insert into images (imageId) values ($session{form}{iid})");
		}
                $file = WebGUI::Attachment->new("","images",$session{form}{iid});
		$file->save("filename");
		if ($file->getFilename) {
			$sqlAdd = ", filename=".quote($file->getFilename);
		}
	        while (($test) = WebGUI::SQL->quickArray("select name from images 
			where name=".quote($session{form}{name})." and imageId<>$session{form}{iid}")) {
        	        if ($session{form}{name} =~ /(.*)(\d+$)/) {
                	        $session{form}{name} = $1.($2+1);
	                } elsif ($test ne "") {
        	                $session{form}{name} .= "2";
                	}
        	}
		WebGUI::SQL->write("update images set name=".quote($session{form}{name}).
                        $sqlAdd.", parameters=".quote($session{form}{parameters}).", userId=$session{user}{userId}, ".
                        " username=".quote($session{user}{username}).
                        ", imageGroupId=".$session{form}{gid}.
			", dateUploaded=".time()." where imageId=$session{form}{iid}");
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listImages {
        my ($f, $output, $sth, %data, @row, $image, $p, $i, $search, $search_group, $imageGroupId, $isImageManager, $imageGroupParentId);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
		$isImageManager = WebGUI::Privilege::isInGroup(9);
		if($session{form}{gid} ne "") { 
			$imageGroupId = $session{form}{gid};
		} else {
			$imageGroupId = 0;
			$session{form}{gid} = 0;
		}
                %data = WebGUI::SQL->quickHash("select parentId,name from imageGroup where imageGroupId=".$imageGroupId);
		if($session{form}{pid} ne "") { 
			$imageGroupParentId = $session{form}{pid};
		} elsif($imageGroupId != 0) {
			$imageGroupParentId = $data{parentId};
		}
                $output = helpIcon(26);
                $output .= '<h1>'.WebGUI::International::get(393).' - '.$data{name}.'</h1>';
                $output .= '<table class="tableData" align="center" width="75%"><tr>';
		if($isImageManager) {
	                $output .= '<td><a href="'.WebGUI::URL::page('op=editImage&iid=new&gid='.$imageGroupId).'">'.WebGUI::International::get(395).'</a>';
	                $output .= '</td>';
	                $output .= '<td><a href="'.WebGUI::URL::page('op=editImageGroup&gid=new&pid='.$imageGroupId).'">'.WebGUI::International::get(543).'</a></td>';
		}
		$f = WebGUI::HTMLForm->new(1);
		$f->raw('<td align="right">');
                $f->hidden("op","listImages");
                $f->text("keyword",'',$session{form}{keyword});
                $f->submit(WebGUI::International::get(170));
                $f->raw('</td>');
		$output .= $f->print;
		$output .= '</tr></table><p>';
                if ($session{form}{keyword} ne "") {
                        $search = " where (name like '%".$session{form}{keyword}.
                        	"%' or username like '%".$session{form}{keyword}.
				"%' or filename like '%".$session{form}{keyword}."%') ";
			$search_group = " where (name like '%".$session{form}{keyword}.
				"%' or description like '%".$session{form}{keyword}."%') and imageGroupId>0";
                } else {
			$search = " where imageGroupId='".$imageGroupId."' ";
			$search_group = " where parentId='".$imageGroupId."' and imageGroupId>0 ";
		}
		# do image groups
		if($imageGroupId > 0) {  # show previous link
                	$row[$i] = '<tr class="tableData">';
			$row[$i] .= '<td colspan="5"><a href="'.WebGUI::URL::page('op=listImages&gid='.$imageGroupParentId)
				.'"><img src="'.$session{config}{extras}.'/smallAttachment.gif" border="0"></a>'
				.'&nbsp;<a href="'.WebGUI::URL::page('op=listImages&gid='.$imageGroupParentId)
				.'">'.WebGUI::International::get(542).'</a></td>'; # FIXME folder icon
                        $row[$i] .= '</tr>';
                        $i++;
		}
                $sth = WebGUI::SQL->read("select * from imageGroup $search_group order by name");
                while (%data = $sth->hash) {
                        $row[$i] = '<tr class="tableData"><td>';
			if ($isImageManager) {
	                        $row[$i] .= deleteIcon('op=deleteImageGroup&gid='.$data{imageGroupId}.'&pid='.$imageGroupId);
                                $row[$i] .= editIcon('op=editImageGroup&gid='.$data{imageGroupId}.'&pid='.$imageGroupId);
			}
                        $row[$i] .= viewIcon('op=viewImageGroup&gid='.$data{imageGroupId}.'&pid='.$imageGroupId);
                        $row[$i] .= '</td>';
			$row[$i] .= '<td><a href="'.WebGUI::URL::page('op=listImages&gid='.$data{imageGroupId}.'&pid='.$imageGroupId)
				.'"><img src="'.$session{config}{extras}.'/smallAttachment.gif" border="0"></a>'
				.'&nbsp;<a href="'.WebGUI::URL::page('op=listImages&gid='.$data{imageGroupId}.'&pid='.$imageGroupId)
				.'">'.$data{name}.'</a></td>'; # FIXME folder icon
                        $row[$i] .= '<td>'.$data{description}.'&nbsp;</td>';
                        $row[$i] .= '<td>&nbsp; </td>';
                        $row[$i] .= '<td>&nbsp; </td>';
                        $row[$i] .= '</tr>';
                        $i++;
                }
                $sth->finish;
		# do images
                $sth = WebGUI::SQL->read("select * from images $search order by name");
                while (%data = $sth->hash) {
			$image = WebGUI::Attachment->new($data{filename},"images",$data{imageId});
                        $row[$i] = '<tr class="tableData"><td>';
			if ($isImageManager) {
	                        $row[$i] .= deleteIcon('op=deleteImage&iid='.$data{imageId}.'&gid='.$data{imageGroupId});
                                $row[$i] .= editIcon('op=editImage&iid='.$data{imageId}.'&gid='.$data{imageGroupId});
			}
                        $row[$i] .= viewIcon('op=viewImage&iid='.$data{imageId}.'&gid='.$data{imageGroupId});
                        $row[$i] .= '</td>';
			$row[$i] .= '<td><a href="'.WebGUI::URL::page('op=viewImage&iid='.$data{imageId}.'&gid='.$data{imageGroupId})
				.'"><img src="'.$image->getThumbnail.'" border="0"></a>';
                        $row[$i] .= '<td>'.$data{name}.'</td>';
                        $row[$i] .= '<td>'.$data{username}.'</td>';
                        $row[$i] .= '<td>'.WebGUI::DateTime::epochToHuman($data{dateUploaded},"%M/%D/%y").'</td>';
                        $row[$i] .= '</tr>';
                        $i++;
                }
                $sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listImages'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBarTraditional($session{form}{pn});
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_viewImage {
        my ($output, %data, $image,$f);
        tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
                %data = WebGUI::SQL->quickHash("select * from images where imageId=$session{form}{iid}");
		$image = WebGUI::Attachment->new($data{filename},"images",$data{imageId});
                $output .= '<h1>'.WebGUI::International::get(396).'</h1>';
		$output .= '<a href="'.WebGUI::URL::page('op=listImages&gid='.$session{form}{gid}).'">'.WebGUI::International::get(397).'</a>';
		$f = WebGUI::HTMLForm->new;
		$f->readOnly($data{imageId},WebGUI::International::get(389));
		$f->readOnly($data{name},WebGUI::International::get(383));
		$f->readOnly($data{filename},WebGUI::International::get(384));
		$f->readOnly($data{parameters},WebGUI::International::get(385));
		$f->readOnly($data{username},WebGUI::International::get(387));
		$f->readOnly(WebGUI::DateTime::epochToHuman($data{dateUploaded},"%z %z"),WebGUI::International::get(388));
		$output .= $f->print;
                $output .= '<p><img src="'.$image->getURL.'">';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageGroup {
        my ($output);
        if (WebGUI::Privilege::isInGroup(9)) {
                $output .= helpIcon(23);
                $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(544).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteImageGroupConfirm&gid='.$session{form}{gid}.'&pid='.$session{form}{pid})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listImages&gid='.$session{form}{pid}).'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageGroupConfirm {
	my ($image, %data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(9)) {
		%data = WebGUI::SQL->quickHash("select parentId from imageGroup where imageGroupId=$session{form}{gid}");
		WebGUI::SQL->write("update images set imageGroupId=$data{parentId} where imageGroupId=$session{form}{gid}");
		WebGUI::SQL->write("update imageGroup set parentId=$data{parentId} where parentId=$session{form}{gid}");
                WebGUI::SQL->write("delete from imageGroup where imageGroupId=$session{form}{gid}");
		$session{form}{gid}=$session{form}{pid};
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImageGroup {
        my ($output, %data, %parent_data, $image, $f);
	tie %data, 'Tie::CPHash';
	tie %parent_data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(9)) {
		if ($session{form}{gid} eq "new") {
		
		} else {
			%data = WebGUI::SQL->quickHash("select * from imageGroup where imageGroupId=$session{form}{gid}");
		}
                %parent_data = WebGUI::SQL->quickHash("select name from imageGroup where imageGroupId=$session{form}{pid}");
                $output = helpIcon(20);
                $output .= '<h1>'.WebGUI::International::get(545).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editImageGroupSave");
                $f->hidden("gid",$session{form}{gid});
                $f->hidden("pid",$session{form}{pid}); #FIXME make this dropdown group tree
                $f->readOnly($session{form}{gid},WebGUI::International::get(546));
                $f->readOnly($parent_data{name},WebGUI::International::get(547));
                $f->text("name",WebGUI::International::get(548),$data{name});
                $f->text("description",WebGUI::International::get(549),$data{description});
		$f->submit;
		$output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImageGroupSave {
        my ($test);
        if (WebGUI::Privilege::isInGroup(9)) {
		if ($session{form}{gid} eq "new") {
			$session{form}{gid} = getNextId("imageGroupId");
			WebGUI::SQL->write("insert into imageGroup (imageGroupId) values ($session{form}{gid})");
		}
	        while (($test) = WebGUI::SQL->quickArray("select name from imageGroup 
			where name=".quote($session{form}{name})." and imageGroupId<>$session{form}{gid}")) {
        	        if ($session{form}{name} =~ /(.*)(\d+$)/) {
                	        $session{form}{name} = $1.($2+1);
	                } elsif ($test ne "") {
        	                $session{form}{name} .= "2";
                	}
        	}
		WebGUI::SQL->write("update imageGroup set name=".quote($session{form}{name}).
                        ", parentId=".$session{form}{pid}.", description=".quote($session{form}{description}).
			" where imageGroupId=$session{form}{gid}");
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_viewImageGroup {
        my ($output, %data, %parent_data, $image,$f);
        tie %data, 'Tie::CPHash';
        tie %parent_data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
                %data = WebGUI::SQL->quickHash("select * from imageGroup where imageGroupId=$session{form}{gid}");
                %parent_data = WebGUI::SQL->quickHash("select name from imageGroup where imageGroupId=".$data{parentId});
                $output .= '<h1>'.WebGUI::International::get(550).'</h1>';
		$output .= '<a href="'.WebGUI::URL::page('op=listImages&gid='.$session{form}{pid}).'">'.WebGUI::International::get(397).'</a>';
		$f = WebGUI::HTMLForm->new;
		$f->readOnly($data{imageGroupId},WebGUI::International::get(546));
		$f->readOnly($parent_data{name},WebGUI::International::get(547)); 
		$f->readOnly($data{name},WebGUI::International::get(548));
		$f->readOnly($data{description},WebGUI::International::get(549));
		$output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

1;


