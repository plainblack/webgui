package WebGUI::Widget::DownloadManager;

our $namespace = "DownloadManager";

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
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderDownloads {
        my ($sth, $i, $did);
        $sth = WebGUI::SQL->read("select downloadId from DownloadManager_file where widgetId=$_[0] order by sequenceNumber");
        while (($did) = $sth->array) {
                WebGUI::SQL->write("update DownloadManager_file set sequenceNumber='$i' where downloadId=$did");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my (%data, $file, $newWidgetId, $pageId, %row, $sth, $newDownloadId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
        $pageId = $_[1] || $data{pageId};
        $newWidgetId = create(
		$pageId,
		$namespace,
		$data{title},
		$data{displayTitle},
		$data{description},
		$data{processMacros},
		$data{templatePosition}
		);
        WebGUI::SQL->write("insert into DownloadManager values ($newWidgetId, $data{paginateAfter})");
        $sth = WebGUI::SQL->read("select * from DownloadManager_file where widgetId=$_[0]");
        while (%row = $sth->hash) {
                $newDownloadId = getNextId("downloadId");
		$file = WebGUI::Attachment->new($row{downloadFile},$_[0],$row{downloadId});
		$file->copy($newWidgetId,$newDownloadId);
                $file = WebGUI::Attachment->new($row{alternateVersion1},$_[0],$row{downloadId});
                $file->copy($newWidgetId,$newDownloadId);
                $file = WebGUI::Attachment->new($row{alternateVersion2},$_[0],$row{downloadId});
                $file->copy($newWidgetId,$newDownloadId);
                WebGUI::SQL->write("insert into DownloadManager_file values ($newDownloadId, $newWidgetId, ".
			quote($row{fileTitle}).", ".quote($row{downloadFile}).", $row{groupToView}, ".
			quote($row{briefSynopsis}).", $row{dateUploaded}, $row{sequenceNumber}, ".
			quote($row{alternateVersion1}).", ".quote($row{alternateVersion2}).
			", $row{displayThumbnails})");
        }
	$sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        purgeWidget($_[0],$_[1],$namespace);
	WebGUI::SQL->write("delete from DownloadManager_file where widgetId=$_[0]");
}

#-------------------------------------------------------------------
sub widgetName {
        return WebGUI::International::get(1,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
        tie %hash,'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
                $output .= '<h1>'.WebGUI::International::get(2,$namespace).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(
			WebGUI::International::get(99),
			WebGUI::Form::text("title",20,30,widgetName())
			);
                $output .= tableFormRow(
			WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle",1,1)
			);
                $output .= tableFormRow(
			WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros",1,1)
			);
                %hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(
			WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash)
			);
                $output .= tableFormRow(
			WebGUI::International::get(85),
			WebGUI::Form::textArea("description",'',50,5,1)
			);
                $output .= tableFormRow(
                        WebGUI::International::get(20,$namespace),
                        WebGUI::Form::text("paginateAfter",20,30,50)
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(21,$namespace),
                        WebGUI::Form::checkbox("displayThumbnails",1,1)
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(3,$namespace),
                        WebGUI::Form::checkbox("proceed",1,1)
                        );
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
        my ($widgetId);
        if (WebGUI::Privilege::canEditPage()) {
                $widgetId = create(
			$session{page}{pageId},
			$session{form}{widget},
			$session{form}{title},
			$session{form}{displayTitle},
			$session{form}{description},
			$session{form}{processMacros},
			$session{form}{templatePosition}
			);
                WebGUI::SQL->write("insert into DownloadManager values ($widgetId, '$session{form}{paginateAfter}', '$session{form}{displayThumbnails}')");
                if ($session{form}{proceed} == 1) {
                        $session{form}{wid} = $widgetId;
                        return www_addDownload();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addDownload {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output .= '<h1>'.WebGUI::International::get(4,$namespace).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addDownloadSave");
                $output .= '<table>';
                $output .= tableFormRow(
                        WebGUI::International::get(6,$namespace),
                        WebGUI::Form::file("downloadFile")
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(17,$namespace),
                        WebGUI::Form::file("alternateVersion1")
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(18,$namespace),
                        WebGUI::Form::file("alternateVersion2")
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(5,$namespace),
                        WebGUI::Form::text("fileTitle",20,128,WebGUI::International::get(5,$namespace))
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(8,$namespace),
                        WebGUI::Form::text("briefSynopsis",50,256)
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(7,$namespace),
                        WebGUI::Form::groupList("groupToView",2)
                        );
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addDownloadSave {
        my ($downloadId,$file,$alt1,$alt2,$sequenceNumber);
        if (WebGUI::Privilege::canEditPage()) {
                $downloadId = getNextId("downloadId"); 
		$file = WebGUI::Attachment->new("",$session{form}{wid},$downloadId);
		$file->save("downloadFile");
		$alt1 = WebGUI::Attachment->new("",$session{form}{wid},$downloadId);
		$alt1->save("alternateVersion1");
		$alt2 = WebGUI::Attachment->new("",$session{form}{wid},$downloadId);
		$alt2->save("alternateVersion2");
		($sequenceNumber) = WebGUI::SQL->quickArray("select count(*)+1 from DownloadManager_file where widgetId=$session{form}{wid}");
                WebGUI::SQL->write("insert into DownloadManager_file values (".
			$downloadId.
			", ".$session{form}{wid}. 
			", ".quote($session{form}{fileTitle}).
			", ".quote($file->getFilename).
			", '$session{form}{groupToView}'".
			", ".quote($session{form}{briefSynopsis}).
			", ".time().
			", ".$sequenceNumber.
			", ".quote($alt1->getFilename).
			", ".quote($alt2->getFilename).
			")");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                duplicate($session{form}{wid});
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
                return www_editDownload();
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
                return www_edit();
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
        my ($output, %data, %hash, @array, $sth, @download);
        tie %data, 'Tie::CPHash';
        tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
                %data = getProperties($namespace,$session{form}{wid});
                $output .= helpLink(1,$namespace);
                $output .= '<h1>'.WebGUI::International::get(9,$namespace).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(
			WebGUI::International::get(99),
			WebGUI::Form::text("title",20,30,$data{title})
			);
                $output .= tableFormRow(
			WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle})
			);
                $output .= tableFormRow(
			WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros","1",
			$data{processMacros})
			);
                %hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(
			WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array)
			);
                $output .= tableFormRow(
			WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$data{description},50,5,1)
			);
                $output .= tableFormRow(
                        WebGUI::International::get(20,$namespace),
                        WebGUI::Form::text("paginateAfter",20,30,$data{paginateAfter})
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(21,$namespace),
                        WebGUI::Form::checkbox("displayThumbnails","1",$data{displayThumbnails})
                        );
                $output .= formSave();
                $output .= '</table></form>';
		$output .= '<p><a href="'.WebGUI::URL::page('func=addDownload&wid='.$session{form}{wid})
			.'">'.WebGUI::International::get(11,$namespace).'</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
                $sth = WebGUI::SQL->read("select downloadId,fileTitle from DownloadManager_file where widgetId='$session{form}{wid}' order by sequenceNumber");
                while (@download = $sth->array) {
                        $output .= '<tr><td><a href="'.
				WebGUI::URL::page('func=editDownload&wid='.$session{form}{wid}.'&did='.$download[0])
				.'"><img src="'.
				$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.
				WebGUI::URL::page('func=deleteDownload&wid='.$session{form}{wid}.'&did='.$download[0])
				.'"><img src="'.
				$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.
				WebGUI::URL::page('func=moveDownloadUp&wid='.$session{form}{wid}.'&did='.$download[0])
				.'"><img src="'.
				$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.
				WebGUI::URL::page('func=moveDownloadDown&wid='.$session{form}{wid}.'&did='.$download[0])
				.'"><img src="'.$session{setting}{lib}.
				'/downArrow.gif" border=0></a></td><td>'.$download[1].'</td><tr>';
                }
                $sth->finish;
                $output .= '</table>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
                update();
		WebGUI::SQL->write("update DownloadManager set paginateAfter='$session{form}{paginateAfter}', displayThumbnails='$session{form}{displayThumbnails}' where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editDownload {
        my ($output, %download);
        tie %download,'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%download = WebGUI::SQL->quickHash("select * from DownloadManager_file where downloadId='$session{form}{did}'");
                $output .= '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("did",$session{form}{did});
                $output .= WebGUI::Form::hidden("func","editDownloadSave");
                $output .= '<table>';
		if ($download{downloadFile} ne "") {
                        $output .= tableFormRow(
				WebGUI::International::get(6,$namespace),
				'<a href="'.WebGUI::URL::page('func=deleteFile&wid='.
				$session{form}{wid}.'&did='.$session{form}{did}).'">'.
				WebGUI::International::get(13,$namespace).'</a>
				');
                } else {
                        $output .= tableFormRow(
				WebGUI::International::get(6,$namespace),
				WebGUI::Form::file("downloadFile")
				);
                }
                if ($download{alternateVersion1} ne "") {
                        $output .= tableFormRow(
                                WebGUI::International::get(17,$namespace),
                                '<a href="'.WebGUI::URL::page('func=deleteFile&alt=1&wid='.
                                $session{form}{wid}.'&did='.$session{form}{did}).'">'.
                                WebGUI::International::get(13,$namespace).'</a>
                                ');
                } else {
                        $output .= tableFormRow(
                                WebGUI::International::get(17,$namespace),
                                WebGUI::Form::file("alternateVersion1")
                                );
                }
                if ($download{alternateVersion2} ne "") {
                        $output .= tableFormRow(
                                WebGUI::International::get(18,$namespace),
                                '<a href="'.WebGUI::URL::page('func=deleteFile&alt=2&wid='.
                                $session{form}{wid}.'&did='.$session{form}{did}).'">'.
                                WebGUI::International::get(13,$namespace).'</a>
                                ');
                } else {
                        $output .= tableFormRow(
                                WebGUI::International::get(18,$namespace),
                                WebGUI::Form::file("alternateVersion2")
                                );
                }
                $output .= tableFormRow(
                        WebGUI::International::get(5,$namespace),
                        WebGUI::Form::text("fileTitle",20,128,$download{fileTitle})
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(8,$namespace),
                        WebGUI::Form::text("briefSynopsis",50,256,$download{briefSynopsis})
                        );
                $output .= tableFormRow(
                        WebGUI::International::get(7,$namespace),
                        WebGUI::Form::groupList("groupToView",$download{groupToView})
                        );
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editDownloadSave {
        my ($file, $alt1, $alt2, $sqlAdd);
        if (WebGUI::Privilege::canEditPage()) {
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
                        " downloadId=".$session{form}{did}.
                        ", widgetId=".$session{form}{wid}.
                        ", fileTitle=".quote($session{form}{fileTitle}).
			$sqlAdd.
                        ", groupToView='$session{form}{groupToView}'".
                        ", briefSynopsis=".quote($session{form}{briefSynopsis}).
                        ", dateUploaded=".time().
			" where downloadId=".$session{form}{did}
                        );
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDownloadDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from DownloadManager_file where downloadId=$session{form}{did}");
                @data = WebGUI::SQL->quickArray("select downloadId from DownloadManager_file where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber+1 where downloadId=$session{form}{did}");
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber-1 where downloadId=$data[0]");
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDownloadUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from DownloadManager_file where downloadId=$session{form}{did}");
                @data = WebGUI::SQL->quickArray("select downloadId from DownloadManager_file where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber-1 where downloadId=$session{form}{did}");
                        WebGUI::SQL->write("update DownloadManager_file set sequenceNumber=sequenceNumber+1 where downloadId=$data[0]");
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
        my ($url, @row, $head, $searchForm, $i, $p, $search, %data, @test, $file, $alt1, $alt2, $output, $sth, 
		%download, $flag, $sort, $sortDirection);
        tie %download, 'Tie::CPHash';
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
        if (defined %data) {
		$url = WebGUI::URL::page();
                if ($data{displayTitle} == 1) {
                        $output .= '<h1>'.$data{title}.'</h1>';
                }
		if ($data{description} ne "") {
                	$output .= $data{description}.'<p>';
		}
		$searchForm = formHeader();
                $searchForm .= WebGUI::Form::text("keyword",20,50);
                $searchForm .= WebGUI::Form::submit(WebGUI::International::get(170));
                $searchForm .= '</form>';
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
		$sth = WebGUI::SQL->read("select * from DownloadManager_file where widgetId=$_[0] $search $sort $sortDirection");
		while (%download = $sth->hash) {
			if (WebGUI::Privilege::isInGroup($download{groupToView})) {
				$file = WebGUI::Attachment->new($download{downloadFile},
					$_[0], $download{downloadId});
				$row[$i] = '<tr><td class="tableData" valign="top">';
				$row[$i] .= '<a href="'.WebGUI::URL::page('func=download&wid='.$_[0].
					'&did='.$download{downloadId}).'"><img src="'.$file->getIcon.
					'" border=0 width=16 height=16 align="middle">'.
					$download{fileTitle}.' ('.$file->getType.')</a>';
				if ($download{alternateVersion1}) {
                                	$alt1 = WebGUI::Attachment->new($download{alternateVersion1},
						$_[0], $download{downloadId});
                                	$row[$i] .= ' &middot; <a href="'.WebGUI::URL::page('func=download&wid='.
						$_[0].'&did='.$download{downloadId}.'&alternateVersion=1')
						.'"><img src="'.$alt1->getIcon.
                                        	'" border=0 width=16 height=16 align="middle">('.
                                        	$alt1->getType.')</a>';
				}
				if ($download{alternateVersion2}) {
                                	$alt2 = WebGUI::Attachment->new($download{alternateVersion2}, 
						$_[0], $download{downloadId});
                                	$row[$i] .= ' &middot; <a href="'.WebGUI::URL::page('func=download&wid='.
						$_[0].'&did='.$download{downloadId}.'&alternateVersion=2')
						.'"><img src="'.$alt2->getIcon.
                                        	'" border=0 width=16 height=16 align="middle">('.
                                        	$alt2->getType.')</a>';
				}
				$row[$i] .= '</td><td class="tableData" valign="top">';
				if ($data{displayThumbnails} 
					&& isIn($file->getType, qw(gif jpeg jpg tif tiff png bmp))) {
					$row[$i] .= '<img src="'.$file->getThumbnail.
						'" border=0 align="middle" hspace="3">';
				}
				$row[$i] .= $download{briefSynopsis}.'</td>'.
					'<td class="tableData" valign="top">'.
					epochToHuman($download{dateUploaded},"%M/%D/%y").'</td>'.
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
		$p = WebGUI::Paginator->new($url,\@row,$data{paginateAfter});
		$output .= $searchForm if ($p->getNumberOfPages > 1);
		$output .= $head;
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBarTraditional($session{form}{pn});
	        if ($data{processMacros} == 1) {
        	        $output = WebGUI::Macro::process($output);
        	}
        }
        return $output;
}


1;


