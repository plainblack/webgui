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
our @EXPORT = qw(&www_editImage &www_editImageSave &www_viewImage &www_deleteImage &www_deleteImageConfirm &www_listImages &www_deleteImageFile);

#-------------------------------------------------------------------
sub www_deleteImage {
        my ($output);
        if (WebGUI::Privilege::isInGroup(4)) {
                $output .= helpIcon(23);
                $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(392).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteImageConfirm&iid='.$session{form}{iid})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listImages').'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageConfirm {
	my ($image);
        if (WebGUI::Privilege::isInGroup(4)) {
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
        if (WebGUI::Privilege::isInGroup(4)) {
                WebGUI::SQL->write("update images set filename='' where imageId=$session{form}{iid}");
                return www_editImage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImage {
        my ($output, %data, $image, $f);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
		if ($session{form}{iid} eq "new") {
		
		} else {
			%data = WebGUI::SQL->quickHash("select * from images where imageId=$session{form}{iid}");
		}
                $output = helpIcon(20);
                $output .= '<h1>'.WebGUI::International::get(382).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editImageSave");
                $f->hidden("iid",$session{form}{iid});
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
        if (WebGUI::Privilege::isInGroup(4)) {
		if ($session{form}{iid} eq "new") {
			$session{form}{iid} = getNextId("imageId");
			WebGUI::SQL->write("insert into images (imageId) values ($session{form}{iid})");
		}
                $file = WebGUI::Attachment->new("","images",$session{form}{iid});
		$file->save("filename");
		if ($file->getFilename) {
			$sqlAdd = ", filename=".quote($file->getFilename);
		}
	        while (($test) = WebGUI::SQL->quickArray("select name from images where name='$session{form}{name}'")) {
        	        if ($session{form}{name} =~ /(.*)(\d+$)/) {
                	        $session{form}{name} = $1.($2+1);
	                } elsif ($test ne "") {
        	                $session{form}{name} .= "2";
                	}
        	}
		WebGUI::SQL->write("update images set name=".quote($session{form}{name}).
                        $sqlAdd.", parameters=".quote($session{form}{parameters}).", userId=$session{user}{userId}, ".
                        " username=".quote($session{user}{username}).
			", dateUploaded=".time()." where imageId=$session{form}{iid}");
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listImages {
        my ($f, $output, $sth, %data, @row, $image, $p, $i, $search, $isAdmin);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
                $output = helpIcon(26);
                $output .= '<h1>'.WebGUI::International::get(393).'</h1>';
                $output .= '<table class="tableData" align="center" width="75%"><tr><td>';
                $output .= '<a href="'.WebGUI::URL::page('op=editImage&iid=new').'">'.WebGUI::International::get(395).'</a>';
                $output .= '</td>';
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
                }
		$isAdmin = WebGUI::Privilege::isInGroup(3);
                $sth = WebGUI::SQL->read("select * from images $search order by name");
                while (%data = $sth->hash) {
			$image = WebGUI::Attachment->new($data{filename},"images",$data{imageId});
                        $row[$i] = '<tr class="tableData"><td>';
			if ($session{user}{userId} == $data{userId} || $isAdmin) {
	                        $row[$i] .= deleteIcon('op=deleteImage&iid='.$data{imageId});
                                $row[$i] .= editIcon('op=editImage&iid='.$data{imageId});
			}
                        $row[$i] .= viewIcon('op=viewImage&iid='.$data{imageId});
                        $row[$i] .= '</td>';
			$row[$i] .= '<td><a href="'.WebGUI::URL::page('op=viewImage&iid='.$data{imageId})
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
		$output .= '<a href="'.WebGUI::URL::page('op=listImages').'">'.WebGUI::International::get(397).'</a>';
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


1;


