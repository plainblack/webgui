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
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_addImage &www_addImageSave &www_editImage &www_editImageSave &www_viewImage
	&www_deleteImage &www_deleteImageConfirm &www_listImages &www_deleteImageFile);

#-------------------------------------------------------------------
sub www_addImage {
	my ($output);
	if (WebGUI::Privilege::isInGroup(4)) {
		$output = helpLink(20);
		$output .= '<h1>'.WebGUI::International::get(382).'</h1>';
		$output .= formHeader();
		$output .= WebGUI::Form::hidden("op","addImageSave");
		$output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(383),
                        WebGUI::Form::text("name",20,128,"Name"));
                $output .= tableFormRow(WebGUI::International::get(384),
                        WebGUI::Form::file("filename"));
		$output .= tableFormRow(WebGUI::International::get(385),
			WebGUI::Form::textArea("parameters",'',50,5));
		$output .= formSave();
		$output .= '</table></form>';	
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addImageSave {
        my ($imageId, $file);
        if (WebGUI::Privilege::isInGroup(4)) {
		$imageId = getNextId("imageId");
		$file = WebGUI::Attachment::save("filename","images",$imageId);
		WebGUI::SQL->write("insert into images values ($imageId, ".quote($session{form}{name}).
			", ".quote($file).", ".quote($session{form}{parameters}).", $session{user}{userId}, ".
			quote($session{user}{username}).", ".time().")");
		return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
        my ($output);
        if (WebGUI::Privilege::isInGroup(4)) {
                $output .= helpLink(23);
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
        if (WebGUI::Privilege::isInGroup(4)) {
                WebGUI::Attachment::deleteSubmission("images",$session{form}{iid});
                WebGUI::SQL->write("delete from images where imageId=$session{form}{iid}");
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImageFile {
        if (WebGUI::Privilege::isInGroup(4)) {
		WebGUI::Attachment::deleteSubmission("images",$session{form}{iid});
                WebGUI::SQL->write("update images set filename='' where imageId=$session{form}{iid}");
                return www_editImage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImage {
        my ($output, %data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
		%data = WebGUI::SQL->quickHash("select * from images where imageId=$session{form}{iid}");
                $output = helpLink(20);
                $output .= '<h1>'.WebGUI::International::get(382).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editImageSave");
                $output .= WebGUI::Form::hidden("iid",$session{form}{iid});
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(389),
                        $data{imageId});
                $output .= tableFormRow(WebGUI::International::get(383),
                        WebGUI::Form::text("name",20,128,$data{name}));
		if ($data{filename} ne "") {
			$output .= tableFormRow(WebGUI::International::get(384),
				'<a href="'.WebGUI::URL::page('op=deleteImageFile&iid='.$data{imageId}).'">'.
				WebGUI::International::get(391).'</a>');
		} else {
                	$output .= tableFormRow(WebGUI::International::get(384),
                        	WebGUI::Form::file("filename"));
		}
                $output .= tableFormRow(WebGUI::International::get(385),
                        WebGUI::Form::textArea("parameters",$data{parameters},50,5));
                $output .= formSave();
                $output .= '</table></form>';
		if ($data{filename} ne "") {
			$output .= '<p>'.WebGUI::International::get(390).'<p><img src="'.
				$session{setting}{attachmentDirectoryWeb}.'/images/'.$session{form}{iid}.
				'/'.$data{filename}.'">';
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editImageSave {
        my ($file);
        if (WebGUI::Privilege::isInGroup(4)) {
                $file = WebGUI::Attachment::save("filename","images",$session{form}{iid});
		if ($file ne "") {
			$file = ", filename=".quote($file);
		}
                WebGUI::SQL->write("update images set imageId=$session{form}{iid}, name=".quote($session{form}{name}).
                        $file.", parameters=".quote($session{form}{parameters}).", userId=$session{user}{userId}, ".
                        " username=".quote($session{user}{username}).", dateUploaded=".time());
                return www_listImages();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listImages {
        my ($output, $sth, %data, @row, $dataRows, $prevNextBar, $i, $search);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
                $output = helpLink(26);
                $output .= '<h1>'.WebGUI::International::get(393).'</h1>';
                $output .= '<table class="tableData" align="center" width="75%"><tr><td>';
                $output .= '<a href="'.WebGUI::URL::page('op=addImage').'">'.WebGUI::International::get(395).'</a>';
                $output .= '</td>'.formHeader().'<td align="right">';
                $output .= WebGUI::Form::hidden("op","listImages");
                $output .= WebGUI::Form::text("keyword",20,50);
                $output .= WebGUI::Form::submit(WebGUI::International::get(170));
                $output .= '</td></form></tr></table><p>';
                if ($session{form}{keyword} ne "") {
                        $search = " where (name like '%".$session{form}{keyword}.
				"%' or filename like '%".$session{form}{keyword}."%') ";
                }
                $sth = WebGUI::SQL->read("select * from images $search order by name");
                while (%data = $sth->hash) {
                        $row[$i] = '<tr class="tableData"><td>';
			if ($session{user}{userId} == $data{userId}) {
	                        $row[$i] .= '<a href="'.WebGUI::URL::page('op=deleteImage&iid='.$data{imageId}).
        	                        '"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a>';
                                $row[$i] .= '<a href="'.WebGUI::URL::page('op=editImage&iid='.$data{imageId}).
                                        '"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a>';
			} else {
                        	$row[$i] .= '<a href="'.WebGUI::URL::page('op=viewImage&iid='.$data{imageId}).
					'"><img src="'.$session{setting}{lib}.'/view.gif" border=0></a>';
			}
                        $row[$i] .= '</td>';
                        $row[$i] .= '<td>'.$data{name}.'</td>';
                        $row[$i] .= '<td>'.$data{username}.'</td>';
                        $row[$i] .= '<td>'.WebGUI::DateTime::epochToHuman($data{dateUploaded},"%M/%D/%y").'</td>';
                        $row[$i] .= '</tr>';
                        $i++;
                }
                $sth->finish;
                ($dataRows, $prevNextBar) = paginate(50,WebGUI::URL::page('op=listImages'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $output .= $dataRows;
                $output .= '</table>';
                $output .= $prevNextBar;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_viewImage {
        my ($output, %data);
        tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4)) {
                %data = WebGUI::SQL->quickHash("select * from images where imageId=$session{form}{iid}");
                $output .= '<h1>'.WebGUI::International::get(396).'</h1>';
		$output .= '<a href="'.WebGUI::URL::page('op=listImages').'">'.WebGUI::International::get(397).'</a>';
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(389),$data{imageId});
                $output .= tableFormRow(WebGUI::International::get(383),$data{name});
                $output .= tableFormRow(WebGUI::International::get(384),$data{filename});
                $output .= tableFormRow(WebGUI::International::get(385),$data{parameters});
                $output .= tableFormRow(WebGUI::International::get(387),$data{username});
                $output .= tableFormRow(WebGUI::International::get(388),
			WebGUI::DateTime::epochToHuman($data{dateUploaded},"%M/%D/%y"));
                $output .= '</table>';
                $output .= '<p><img src="'.$session{setting}{attachmentDirectoryWeb}.'/images/'.$session{form}{iid}.
                	'/'.$data{filename}.'">';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;


