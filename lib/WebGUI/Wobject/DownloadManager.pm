package WebGUI::Wobject::DownloadManager;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "DownloadManager";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub _reorderDownloads {
        my ($sth, $i, $did);
        $sth = WebGUI::SQL->read("select downloadId from DownloadManager_file where wobjectId=$_[0] order by sequenceNumber");
        while (($did) = $sth->array) {
                WebGUI::SQL->write("update DownloadManager_file set sequenceNumber='$i' where downloadId=$did");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($file, $w, %row, $sth, $newDownloadId);
	tie %row, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::DownloadManager->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		paginateAfter=>$_[0]->get("paginateAfter"),
		displayThumbnails=>$_[0]->get("displayThumbnails")
		});
        $sth = WebGUI::SQL->read("select * from DownloadManager_file where wobjectId=".$_[0]->get("wobjectId"));
        while (%row = $sth->hash) {
                $newDownloadId = getNextId("downloadId");
		$file = WebGUI::Attachment->new($row{downloadFile},$_[0]->get("wobjectId"),$row{downloadId});
		$file->copy($w->get("wobjectId"),$newDownloadId);
                $file = WebGUI::Attachment->new($row{alternateVersion1},$_[0]->get("wobjectId"),$row{downloadId});
                $file->copy($w->get("wobjectId"),$newDownloadId);
                $file = WebGUI::Attachment->new($row{alternateVersion2},$_[0]->get("wobjectId"),$row{downloadId});
                $file->copy($w->get("wobjectId"),$newDownloadId);
                WebGUI::SQL->write("insert into DownloadManager_file values ($newDownloadId, ".$w->get("wobjectId").", ".
			quote($row{fileTitle}).", ".quote($row{downloadFile}).", $row{groupToView}, ".
			quote($row{briefSynopsis}).", $row{dateUploaded}, $row{sequenceNumber}, ".
			quote($row{alternateVersion1}).", ".quote($row{alternateVersion2}).")");
        }
	$sth->finish;
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
	WebGUI::SQL->write("delete from DownloadManager_file where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(paginateAfter displayThumbnails)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteFile {
	my ($delete);
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{alt} == 1) {
			$delete = "alternateVersion1";
		} elsif ($session{form}{alt} == 2) {
			$delete = "alternateVersion2";
		} else {
			$delete = "downloadFile";
		}
                WebGUI::SQL->write("update DownloadManager_file set $delete='' where downloadId=$session{form}{did}");
                return $_[0]->www_editDownload();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteDownload {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(12,$namespace).'<p>';
                $output .= '<div align="center">'.
			'<a href="'.WebGUI::URL::page('func=deleteDownloadConfirm&wid='.
			$session{form}{wid}.'&did='.$session{form}{did}).'">'.
			WebGUI::International::get(44).'</a>';
                $output .= ' &nbsp; <a href="'.WebGUI::URL::page('func=edit&wid='.$session{form}{wid}).'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteDownloadConfirm {
        my ($output, $file);
        if (WebGUI::Privilege::canEditPage()) {
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{did});
                $file->deleteNode;
                WebGUI::SQL->write("delete from DownloadManager_file where downloadId=$session{form}{did}");
                _reorderDownloads($session{form}{wid});
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_download {
	my (%download, $file);
	tie %download,'Tie::CPHash';
	%download = WebGUI::SQL->quickHash("select * from DownloadManager_file where downloadId=$session{form}{did}");
	if (WebGUI::Privilege::isInGroup($download{groupToView})) {
		if ($session{form}{alternateVersion} == 1) {
                        $file = WebGUI::Attachment->new($download{alternateVersion1},
                                $session{form}{wid},
                                $session{form}{did});
		} elsif ($session{form}{alternateVersion} == 2) {
                        $file = WebGUI::Attachment->new($download{alternateVersion2},
                                $session{form}{wid},
                                $session{form}{did});
		} else {
			$file = WebGUI::Attachment->new($download{downloadFile},
				$session{form}{wid},
				$session{form}{did});
		}
		$session{header}{redirect} = WebGUI::Session::httpRedirect($file->getURL);
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, %hash, @array, $sth, @download, $paginateAfter, $proceed);
        tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
                if ($_[0]->get("wobjectId") eq "new") {
                        $proceed = 1;
                }
                $output .= helpIcon(1,$namespace);
                $output .= '<h1>'.WebGUI::International::get(9,$namespace).'</h1>';
		$paginateAfter = $_[0]->get("paginateAfter") || 50;
		$f = WebGUI::HTMLForm->new;
		$f->integer("paginateAfter",WebGUI::International::get(20,$namespace),$paginateAfter);
                $f->yesNo("displayThumbnails",WebGUI::International::get(21,$namespace),$_[0]->get("displayThumbnails"));
                $f->yesNo("proceed",WebGUI::International::get(22,$namespace),$proceed);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
		unless ($_[0]->get("wobjectId") eq "new") {
			$output .= '<p><a href="'.WebGUI::URL::page('func=editDownload&did=new&wid='.$_[0]->get("wobjectId"))
				.'">'.WebGUI::International::get(11,$namespace).'</a><p>';
                	$sth = WebGUI::SQL->read("select downloadId,fileTitle from DownloadManager_file where wobjectId='$session{form}{wid}' order by sequenceNumber");
			$output .='<table>';
                	while (@download = $sth->array) {
                        	$output .= '<tr><td>'
					.deleteIcon('func=deleteDownload&wid='.$session{form}{wid}.'&did='.$download[0])
					.editIcon('func=editDownload&wid='.$session{form}{wid}.'&did='.$download[0])
					.moveUpIcon('func=moveDownloadUp&wid='.$session{form}{wid}.'&did='.$download[0])
					.moveDownIcon('func=moveDownloadDown&wid='.$session{form}{wid}.'&did='.$download[0])
					.'</td><td>'.$download[1].'</td></tr>';
                	}
                	$sth->finish;
			$output .= '</table>';
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			paginateAfter=>$session{form}{paginateAfter},
			displayThumbnails=>$session{form}{displayThumbnails}
			});
                if ($session{form}{proceed}) {
                        $_[0]->www_editDownload();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editDownload {
        my ($output, %download, $f);
        tie %download,'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{did} eq "") {
			$session{form}{did} = "new";
		}
		%download = WebGUI::SQL->quickHash("select * from DownloadManager_file where downloadId='$session{form}{did}'");
                $output .= '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $f->hidden("did",$session{form}{did});
                $f->hidden("func","editDownloadSave");
		$f->text("fileTitle",WebGUI::International::get(5,$namespace),$download{fileTitle});
		if ($download{downloadFile} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&wid='.
				$session{form}{wid}.'&did='.$session{form}{did}).'">'.WebGUI::International::get(391).
				'</a>',WebGUI::International::get(6,$namespace));
                } else {
			$f->file("downloadFile",WebGUI::International::get(6,$namespace));
                }
                if ($download{alternateVersion1} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&alt=1&wid='.
				$session{form}{wid}.'&did='.$session{form}{did}).'">'.
				WebGUI::International::get(391).'</a>',WebGUI::International::get(17,$namespace));
                } else {
			$f->file("alternateVersion1",WebGUI::International::get(17,$namespace));
                }
                if ($download{alternateVersion2} ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&alt=2&wid='.
				$session{form}{wid}.'&did='.$session{form}{did}).'">'.
				WebGUI::International::get(391).'</a>',WebGUI::International::get(18,$namespace));
                } else {
			$f->file("alernateVersion2",WebGUI::International::get(18,$namespace));
                }
                $f->text("briefSynopsis",WebGUI::International::get(8,$namespace),$download{briefSynopsis});
                $f->group("groupToView",WebGUI::International::get(7,$namespace),[$download{groupToView}]);
                $f->yesNo("proceed",WebGUI::International::get(22,$namespace));
		$f->submit;
		$output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editDownloadSave {
        my ($file, $alt1, $alt2, $sqlAdd, $seq);
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{did} eq "new") {
			$session{form}{did} = getNextId("downloadId");
			($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from DownloadManager_file where wobjectId=".$_[0]->get("wobjectId"));
			WebGUI::SQL->write("insert into DownloadManager_file (wobjectId,downloadId,sequenceNumber) 
				values (".$_[0]->get("wobjectId").",$session{form}{did},".($seq+1).")");
		}
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{did});
		$file->save("downloadFile");
                if ($file->getFilename ne "") {
                        $sqlAdd = ', downloadFile='.quote($file->getFilename);
                }
                $alt1 = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{did});
		$alt1->save("alternateVersion1");
                if ($alt1->getFilename ne "") {
                        $sqlAdd .= ', alternateVersion1='.quote($alt1->getFilename);
                }
                $alt2 = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{did});
		$alt2->save("alternateVersion2");
                if ($alt2->getFilename ne "") {
                        $sqlAdd = ', alternateVersion2='.quote($alt2->getFilename);
                }
                WebGUI::SQL->write("update DownloadManager_file set ".
                        "fileTitle=".quote($session{form}{fileTitle}).
			$sqlAdd.
                        ", groupToView='$session{form}{groupToView}'".
                        ", briefSynopsis=".quote($session{form}{briefSynopsis}).
                        ", dateUploaded=".time().
			" where downloadId=".$session{form}{did}
                        );
                if ($session{form}{proceed}) {
                        $session{form}{did} = "new";
                        $_[0]->www_editDownload();
                } else {
                        return $_[0]->www_edit();
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDownloadDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from DownloadManager_file where downloadId=$session{form}{did}");
                @data = WebGUI::SQL->quickArray("select downloadId from DownloadManager_file where wobjectId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber+1 where downloadId=$session{form}{did}");
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber-1 where downloadId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDownloadUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from DownloadManager_file where downloadId=$session{form}{did}");
                @data = WebGUI::SQL->quickArray("select downloadId from DownloadManager_file where wobjectId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber-1 where downloadId=$session{form}{did}");
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber+1 where downloadId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
        my ($url, @row, $head, $searchForm, $i, $p, $search, @test, $file, $alt1, $alt2, $output, $sth, 
		%download, $flag, $sort, $sortDirection);
        tie %download, 'Tie::CPHash';
	$url = WebGUI::URL::page();
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	$searchForm = WebGUI::HTMLForm->new(1);
	$searchForm->text("keyword",'',$session{form}{keyword});
	$searchForm->submit(WebGUI::International::get(170));
	$head = '<table cellpadding="3" cellspacing="1" border="0" width="100%">';
	if ($session{form}{keyword} ne "") {
        	$search = " and (fileTitle like '%".$session{form}{keyword}.
			"%' or downloadFile like '%".$session{form}{keyword}.
			"%' or alternateVersion1 like '%".$session{form}{keyword}.
			"%' or alternateVersion2 like '%".$session{form}{keyword}.
			"%' or briefSynopsis like '%".$session{form}{keyword}."%') ";
		$url = WebGUI::URL::append($url,"keyword=".$session{form}{keyword});
        }
	if ($session{form}{sort} ne "") {
		$sort = " order by ".$session{form}{sort};
		$url = WebGUI::URL::append($url,"sort=".$session{form}{sort});
	} else {
		$sort = " order by sequenceNumber";
	}
	if ($session{form}{sortDirection} ne "") {
		$sortDirection = $session{form}{sortDirection};
		$url = WebGUI::URL::append($url,"sortDirection=".$session{form}{sortDirection});
	}
        $head .= '<tr><td class="tableHeader">'.
		sortByColumn("fileTitle",WebGUI::International::get(14,$namespace)).
		'</td><td class="tableHeader">'.
		sortByColumn("briefSynopsis",WebGUI::International::get(15,$namespace)).
		'</td><td class="tableHeader">'.
		sortByColumn("dateUploaded",WebGUI::International::get(16,$namespace)).
		'</td></tr>';
	$sth = WebGUI::SQL->read("select * from DownloadManager_file where wobjectId=".$_[0]->get("wobjectId")." $search $sort $sortDirection");
	while (%download = $sth->hash) {
		if (WebGUI::Privilege::isInGroup($download{groupToView})) {
			$file = WebGUI::Attachment->new($download{downloadFile},
				$_[0]->get("wobjectId"), $download{downloadId});
			$row[$i] = '<tr><td class="tableData" valign="top">';
			$row[$i] .= '<a href="'.WebGUI::URL::page('func=download&wid='.$_[0]->get("wobjectId").
				'&did='.$download{downloadId}).'">'.$download{fileTitle}.'</a>&nbsp;&middot;&nbsp;<a href="'.
				WebGUI::URL::page('func=download&wid='.
				$_[0]->get("wobjectId").'&did='.$download{downloadId}).'"><img src="'.$file->getIcon.
				'" border=0 width=16 height=16 align="middle">'.
				$file->getType.'/'.$file->getSize.'</a>';
			if ($download{alternateVersion1}) {
                               	$alt1 = WebGUI::Attachment->new($download{alternateVersion1},
					$_[0]->get("wobjectId"), $download{downloadId});
                               	$row[$i] .= ' &middot; <a href="'.WebGUI::URL::page('func=download&wid='.
					$_[0]->get("wobjectId").'&did='.$download{downloadId}.'&alternateVersion=1')
					.'"><img src="'.$alt1->getIcon.
                                       	'" border=0 width=16 height=16 align="middle">'.
                                       	$alt1->getType.'/'.$alt1->getSize.'</a>';
			}
			if ($download{alternateVersion2}) {
                               	$alt2 = WebGUI::Attachment->new($download{alternateVersion2}, 
					$_[0]->get("wobjectId"), $download{downloadId});
                               	$row[$i] .= ' &middot; <a href="'.WebGUI::URL::page('func=download&wid='.
					$_[0]->get("wobjectId").'&did='.$download{downloadId}.'&alternateVersion=2')
					.'"><img src="'.$alt2->getIcon.
                                       	'" border=0 width=16 height=16 align="middle">'.
                                       	$alt2->getType.'/'.$alt2->getSize.'</a>';
			}
			$row[$i] .= '</td><td class="tableData" valign="top">';
			if ($_[0]->get("displayThumbnails") 
				&& isIn($file->getType, qw(gif jpeg jpg tif tiff png bmp))) {
				$row[$i] .= '<img src="'.$file->getThumbnail.
					'" border=0 align="middle" hspace="3">';
			}
			$row[$i] .= $download{briefSynopsis}.'</td>'.
				'<td class="tableData" valign="top">'.
				epochToHuman($download{dateUploaded},"%z").'</td>'.
				'</tr>';
			$flag = 1;
			$i++;
		}
	}
	$sth->finish;
	unless ($flag) {
		$head .= '<tr><td class="tableData" colspan="3">'.
			WebGUI::International::get(19,$namespace).'</td></tr>';
	}
	$p = WebGUI::Paginator->new($url,\@row,$_[0]->get("paginateAfter"));
	$output .= $searchForm->print if ($p->getNumberOfPages > 1);
	$output .= $head;
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
	return $_[0]->processMacros($output);
}


1;


