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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
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
        my (%data, $newWidgetId, $pageId, %row, $sth, $newDownloadId);
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
        	WebGUI::Attachment::copy($row{downloadFile},$_[0],$newWidgetId,$row{downloadId},$newDownloadId);
        	WebGUI::Attachment::copy($row{alternateVersion1},$_[0],$newWidgetId,$row{downloadId},$newDownloadId);
        	WebGUI::Attachment::copy($row{alternateVersion2},$_[0],$newWidgetId,$row{downloadId},$newDownloadId);
                WebGUI::SQL->write("insert into DownloadManager_file values ($newDownloadId, $newWidgetId, ".
			quote($row{fileTitle}).", ".quote($row{downloadFile}).", $row{groupToView}, ".
			quote($row{briefSynopsis}).", $row{dateUploaded}, $row{sequenceNumber}, ".
			quote($row{alternateVersion1}).", ".quote($row{alternateVersion2}).")");
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
                WebGUI::SQL->write("insert into DownloadManager values ($widgetId, '$session{form}{paginateAfter}')");
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
		$file = WebGUI::Attachment::save("downloadFile",$session{form}{wid},$downloadId);
		$alt1 = WebGUI::Attachment::save("alternateVersion1",$session{form}{wid},$downloadId);
		$alt2 = WebGUI::Attachment::save("alternateVersion2",$session{form}{wid},$downloadId);
		($sequenceNumber) = WebGUI::SQL->quickArray("select count(*)+1 from DownloadManager_file where widgetId=$session{form}{wid}");
                WebGUI::SQL->write("insert into DownloadManager_file values (".
			$downloadId.
			", ".$session{form}{wid}. 
			", ".quote($session{form}{fileTitle}).
			", ".quote($file).
			", '$session{form}{groupToView}'".
			", ".quote($session{form}{briefSynopsis}).
			", ".time().
			", ".$sequenceNumber.
			", ".quote($alt1).
			", ".quote($alt2).
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
			'<a href="'.$session{page}{url}.
			'?func=deleteDownloadConfirm&wid='.
			$session{form}{wid}.'&did='.$session{form}{did}.'">'.
			WebGUI::International::get(44).'</a>';
                $output .= ' &nbsp; <a href="'.$session{page}{url}.
			'?func=edit&wid='.$session{form}{wid}.'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteDownloadConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from DownloadManager_file where downloadId=$session{form}{did}");
                _reorderDownloads($session{form}{wid});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_download {
	my (%download);
	tie %download,'Tie::CPHash';
	%download = WebGUI::SQL->quickHash("select * from DownloadManager_file where downloadId=$session{form}{did}");
	if (WebGUI::Privilege::isInGroup($download{groupToView})) {
		$session{header}{redirect} = WebGUI::Session::httpRedirect(
			$session{setting}{attachmentDirectoryWeb}."/".
			$session{form}{wid}."/".$session{form}{did}."/".$download{downloadFile}
			);
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
                $output .= formSave();
                $output .= '</table></form>';
		$output .= '<p><a href="'.$session{page}{url}.'?func=addDownload&wid='.
			$session{form}{wid}.'">'.WebGUI::International::get(11,$namespace).'</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
                $sth = WebGUI::SQL->read("select downloadId,fileTitle from DownloadManager_file where widgetId='$session{form}{wid}' order by sequenceNumber");
                while (@download = $sth->array) {
                        $output .= '<tr><td><a href="'.$session{page}{url}.
				'?func=editDownload&wid='.$session{form}{wid}.
				'&did='.$download[0].'"><img src="'.
				$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.
				$session{page}{url}.'?func=deleteDownload&wid='.
				$session{form}{wid}.'&did='.$download[0].'"><img src="'.
				$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.
				$session{page}{url}.'?func=moveDownloadUp&wid='.
				$session{form}{wid}.'&did='.$download[0].'"><img src="'.
				$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.
				$session{page}{url}.'?func=moveDownloadDown&wid='.
				$session{form}{wid}.'&did='.$download[0].
				'"><img src="'.$session{setting}{lib}.
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
		WebGUI::SQL->write("update DownloadManager set paginateAfter='$session{form}{paginateAfter}' where widgetId=$session{form}{wid}");
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
				'<a href="'.$session{page}{url}.'?func=deleteFile&wid='.
				$session{form}{wid}.'&did='.$session{form}{did}.'">'.
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
                                '<a href="'.$session{page}{url}.'?func=deleteFile&alt=1&wid='.
                                $session{form}{wid}.'&did='.$session{form}{did}.'">'.
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
                                '<a href="'.$session{page}{url}.'?func=deleteFile&alt=2&wid='.
                                $session{form}{wid}.'&did='.$session{form}{did}.'">'.
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
        my ($file, $alt1, $alt2);
        if (WebGUI::Privilege::canEditPage()) {
                $file = WebGUI::Attachment::save("downloadFile",$session{form}{wid},$session{form}{did});
                if ($file ne "") {
                        $file = ', downloadFile='.quote($file);
                }
                $alt1 = WebGUI::Attachment::save("alternateVersion1",$session{form}{wid},$session{form}{did});
                if ($alt1 ne "") {
                        $alt1 = ', alternateVersion1='.quote($alt1);
                }
                $alt2 = WebGUI::Attachment::save("alternateVersion2",$session{form}{wid},$session{form}{did});
                if ($alt2 ne "") {
                        $alt2 = ', alternateVersion2='.quote($alt2);
                }
                WebGUI::SQL->write("update DownloadManager_file set ".
                        " downloadId=".$session{form}{did}.
                        ", widgetId=".$session{form}{wid}.
                        ", fileTitle=".quote($session{form}{fileTitle}).
			$file.$alt1.$alt2.
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
        my (@row, $i, $dataRows, $prevNextBar, %data, @test, %fileType, $output, $sth, %download, $flag);
        tie %download, 'Tie::CPHash';
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
        if (defined %data) {
                if ($data{displayTitle} == 1) {
                        $output .= '<h1>'.$data{title}.'</h1>';
                }
		if ($data{description} ne "") {
                	$output .= $data{description}.'<p>';
		}
		$output .= '<table cellpadding="3" cellspacing="1" border="0" width="100%">';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(14,$namespace).
			'</td><td class="tableHeader">'.WebGUI::International::get(15,$namespace).
			'</td><td class="tableHeader">'.WebGUI::International::get(16,$namespace).'</td></tr>';
		$sth = WebGUI::SQL->read("select * from DownloadManager_file where widgetId=$_[0] order by sequenceNumber");
		while (%download = $sth->hash) {
			if (WebGUI::Privilege::isInGroup($download{groupToView})) {
				%fileType = WebGUI::Attachment::getType($download{downloadFile});
				$row[$i] = '<tr><td class="tableData" valign="top">';
				$row[$i] .= '<a href="'.$session{page}{url}.'?func=download&wid='.$_[0].
					'&did='.$download{downloadId}.'"><img src="'.$fileType{icon}.
					'" border=0 width=16 height=16 align="middle">'.
					$download{fileTitle}.' ('.$fileType{extension}.')</a>';
				if ($download{alternateVersion1}) {
					%fileType = WebGUI::Attachment::getType($download{alternateVersion1});
                                	$row[$i] .= ' &middot; <a href="'.$session{page}{url}.'?func=download&wid='.
						$_[0].'&did='.$download{downloadId}.'"><img src="'.$fileType{icon}.
                                        	'" border=0 width=16 height=16 align="middle">('.
                                        	$fileType{extension}.')</a>';
				}
				if ($download{alternateVersion2}) {
					%fileType = WebGUI::Attachment::getType($download{alternateVersion2});
                                	$row[$i] .= ' &middot; <a href="'.$session{page}{url}.'?func=download&wid='.
						$_[0].'&did='.$download{downloadId}.'"><img src="'.$fileType{icon}.
                                        	'" border=0 width=16 height=16 align="middle">('.
                                        	$fileType{extension}.')</a>';
				}
				$row[$i] .= '</td><td class="tableData" valign="top">'.$download{briefSynopsis}.'</td>'.
					'<td class="tableData" valign="top">'.
					epochToHuman($download{dateUploaded},"%M/%D/%y").'</td>'.
					'</tr>';
				$flag = 1;
				$i++;
			}
		}
		$sth->finish;
		unless ($flag) {
			$output .= '<tr><td class="tableData" colspan="3">'.
				WebGUI::International::get(19,$namespace).'</td></tr>';
		}
		($dataRows, $prevNextBar) = paginate($data{paginateAfter},$session{page}{url},\@row);
                $output .= $dataRows;
                $output .= '</table>';
                $output .= $prevNextBar;
	        if ($data{processMacros} == 1) {
        	        $output = WebGUI::Macro::process($output);
        	}
        }
        return $output;
}


1;


