package WebGUI::Operation::International;

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
use Tie::CPHash;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Paginator;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_listLanguages &www_editLanguage &www_submitTranslation &www_submitTranslationConfirm &www_deleteLanguage &www_deleteLanguageConfirm
	&www_listInternationalMessages &www_editLanguageSave &www_editInternationalMessage &www_editInternationalMessageSave &www_listHelpMessages
	&www_editHelpMessage &www_editHelpMessageSave);


#-------------------------------------------------------------------
sub _submenu {
	my ($output);
	$output = '<table width="100%"><tr>';
	$output .= '<td valign="top" class="content">'.$_[0].'</td>';
	$output .= '<td valign="top" class="tableMenu">';
	$output .= '<li><a href="'.WebGUI::URL::page('op=editLanguage&lid='.$session{form}{lid}).'">'.WebGUI::International::get(598).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}).'">'.WebGUI::International::get(594).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=listHelpMessages&lid='.$session{form}{lid}).'">'.WebGUI::International::get(599).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=submitTranslation&lid='.$session{form}{lid}).'">'.WebGUI::International::get(593).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=listLanguages').'">'.WebGUI::International::get(585).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(493).'</a>';
	$output .= '</td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub www_deleteLanguage {
        my ($output);
        if ($session{form}{lid} < 1000 && $session{form}{lid} > 0) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(587).'<p>';
                $output .= '<div align="center"><a href="'.
                        WebGUI::URL::page('op=deleteLanguageConfirm&lid='.$session{form}{lid})
                        .'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listLanguages').
                        '">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteLanguageConfirm {
        if ($session{form}{lid} < 1000 && $session{form}{lid} > 0) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("delete from language where languageId=".$session{form}{lid});
                WebGUI::SQL->write("delete from international where languageId=".$session{form}{lid});
                WebGUI::SQL->write("delete from help where languageId=".$session{form}{lid});
                WebGUI::SQL->write("delete from userProfileData where fieldName='language' and fieldData=".$session{form}{lid});
                return www_listLanguages();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editHelpMessage {
        my ($output, %data, $f, $language, $action, $object);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                ($language) = WebGUI::SQL->quickArray("select language from language where languageId=".$session{form}{lid});
		$action = WebGUI::International::get(603);
		$object = WebGUI::International::get(604);
                $output = '<h1>'.WebGUI::International::get(602).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->readOnly($session{form}{hid},WebGUI::International::get(600));
                $f->hidden("lid",$session{form}{lid});
                $f->hidden("hid",$session{form}{hid});
		$f->hidden("missing",$session{form}{missing});
                $f->hidden("pn",$session{form}{pn});
                $f->hidden("namespace",$session{form}{namespace});
                $f->hidden("op","editHelpMessageSave");
                %data = WebGUI::SQL->quickHash("select action,object,body from help where helpId=".$session{form}{hid}."  
                        and namespace='".$session{form}{namespace}."' and languageId=".$session{form}{lid});
                $f->text("action",$action,$data{action});
                $f->text("object",$object,$data{object});
                $f->HTMLArea("body",$language,$data{body});
                $f->submit;
                %data = WebGUI::SQL->quickHash("select action,object,body from help where helpId=".$session{form}{hid}." 
			and namespace='".$session{form}{namespace}."' and languageId=1");
                $f->readOnly($data{action},$action);
                $f->readOnly($data{object},$object);
                $f->readOnly($data{body},"English");
                $output .= $f->print;
                return _submenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editHelpMessageSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		if ($session{form}{missing}) {
                	WebGUI::SQL->write("insert into help (body,action,object,namespace,languageId,helpId) values (".quote($session{form}{body}).", "
				.quote($session{form}{action}).", ".quote($session{form}{action}).",".quote($session{form}{namespace}).","
				.$session{form}{lid}.",".$session{form}{hid}.")");
		} else {
			WebGUI::SQL->write("update help set body=".quote($session{form}{body}).", action=".quote($session{form}{action}).", 
                                object=".quote($session{form}{action})." where namespace=".quote($session{form}{namespace})." 
                                and languageId=".$session{form}{lid}." and helpId=".$session{form}{hid});
		}
                return www_listHelpMessages();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editInternationalMessage {
        my ($output, $message, $f, $language);
        if (WebGUI::Privilege::isInGroup(3)) {
		($language) = WebGUI::SQL->quickArray("select language from language where languageId=".$session{form}{lid});
                $output = '<h1>'.WebGUI::International::get(597).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->readOnly($session{form}{iid},WebGUI::International::get(601));
                $f->hidden("lid",$session{form}{lid});
		$f->hidden("missing",$session{form}{missing});
                $f->hidden("iid",$session{form}{iid});
                $f->hidden("pn",$session{form}{pn});
                $f->hidden("namespace",$session{form}{namespace});
                $f->hidden("op","editInternationalMessageSave");
                ($message) = WebGUI::SQL->quickArray("select message from international where internationalId=".$session{form}{iid}." 
                        and namespace='".$session{form}{namespace}."' and languageId=".$session{form}{lid});
                $f->textarea("message",$language,$message);
                $f->submit;
		($message) = WebGUI::SQL->quickArray("select message from international where internationalId=".$session{form}{iid}." 
			and namespace='".$session{form}{namespace}."' and languageId=1");
		$f->readOnly($message,"English");
                $output .= $f->print;
                return _submenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editInternationalMessageSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		if ($session{form}{missing}) {
                	WebGUI::SQL->write("insert into international (message,namespace,languageId,internationalId) values (".quote($session{form}{message})
				.",".quote($session{form}{namespace}).",".$session{form}{lid}.",".$session{form}{iid}.")");
		} else {
                	WebGUI::SQL->write("update international set message=".quote($session{form}{message})." where namespace=".quote($session{form}{namespace})." 
                        	and languageId=".$session{form}{lid}." and internationalId=".$session{form}{iid});
		}
                return www_listInternationalMessages();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editLanguage {
	my ($output, %data, $f);
	tie %data, 'Tie::CPHash';
	if (WebGUI::Privilege::isInGroup(3)) {
		if ($session{form}{lid} eq "new") {
			$data{characterSet} = "ISO-8859-1";
		} else {
			%data = WebGUI::SQL->quickHash("select * from language where languageId=".$session{form}{lid});
		}
		$output = '<h1>'.WebGUI::International::get(589).'</h1>';
		$f = WebGUI::HTMLForm->new;
		$f->readOnly($session{form}{lid},WebGUI::International::get(590));
		$f->hidden("lid",$session{form}{lid});
		$f->hidden("op","editLanguageSave");
		$f->text("language",WebGUI::International::get(591),$data{language});
		$f->text("characterSet",WebGUI::International::get(592),$data{characterSet});
		$f->submit;
		$output .= $f->print;
		if ($session{form}{lid} ne "new") {
			$output .= '<ul>';
			$output .= '<li><a href="'.WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}).'">'.WebGUI::International::get(594).'</a>';
			$output .= '<li><a href="'.WebGUI::URL::page('op=listHelpMessages&lid='.$session{form}{lid}).'">'.WebGUI::International::get(599).'</a>';
			$output .= '<li><a href="'.WebGUI::URL::page('op=submitLanguage&lid='.$session{form}{lid}).'">'.WebGUI::International::get(593).'</a>';
			$output .= '</ul>';
		}
		return _submenu($output);	
	} else {
		return WebGUI::Privilege::adminOnly();
	}
}

#-------------------------------------------------------------------
sub www_editLanguageSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                if ($session{form}{lid} eq "new") {
			$session{form}{lid} = getNextId("languageId");
			WebGUI::SQL->write("insert into language (languageId) values ($session{form}{lid})");
                }
		WebGUI::SQL->write("update language set language=".quote($session{form}{language}).", characterSet=".quote($session{form}{characterSet})." 
			where languageId=".$session{form}{lid});
                return www_editLanguage();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listHelpMessages {
        my ($output, $sth, $key, $p, %data, %newList, %list, $i, $missing, @row, @split,$new);
        tie %data, 'Tie::CPHash';
        tie %list, 'Tie::IxHash';
        tie %newList, 'Tie::IxHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                %data = WebGUI::SQL->quickHash("select language from language where languageId=".$session{form}{lid});
                $missing = '<b>'.WebGUI::International::get(596).'</b>';
                $output = '<h1>'.WebGUI::International::get(595).' ('.$data{language}.')</h1>';
                $sth = WebGUI::SQL->read("select * from help where languageId=".$session{form}{lid});
                while (%data = $sth->hash) {
                        $list{$data{helpId}."-".$data{namespace}} = $data{action}.' '.$data{object};
                }
                $sth->finish;
                $sth = WebGUI::SQL->read("select * from help where languageId=1");
                while (%data = $sth->hash) {
                        unless ($list{$data{helpId}."-".$data{namespace}}) {
                                $list{"missing-".$data{helpId}."-".$data{namespace}} = $missing;
                        }
                }
                $sth->finish;
                foreach $key (sort {$b cmp $a} keys %list) {
                        $newList{$key}=$list{$key};
                }
                foreach $key (keys %newList) {
                        @split = split(/-/,$key);
                        if ($split[0] eq "missing") {
                                $split[0] = $split[1];
                                $split[1] = $split[2];
				$new = 1;
                        } else {
				$new = 0;
			}
                        $row[$i] = editIcon('op=editHelpMessage&lid='.$session{form}{lid}.'&hid='.$split[0].'&namespace='.$split[1].'&pn='.$session{form}{pn}.'&missing='.$new)
                                .' '.$newList{$key}."<br>";
                        $i++;
                }
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listHelpMessages&lid='.$session{form}{lid}),\@row,50);
                $output .= $p->getPage($session{form}{pn});
                $output .= $p->getBarTraditional($session{form}{pn});
                return _submenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listInternationalMessages {
        my ($output, $sth, $new, $key, $p, %data, %newList, %list, $i, $missing, @row, @split);
        tie %data, 'Tie::CPHash';
        tie %list, 'Tie::IxHash';
        tie %newList, 'Tie::IxHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		%data = WebGUI::SQL->quickHash("select language from language where languageId=".$session{form}{lid});
                $missing = '<b>'.WebGUI::International::get(596).'</b>';
                $output = '<h1>'.WebGUI::International::get(595).' ('.$data{language}.')</h1>';
                $sth = WebGUI::SQL->read("select * from international where languageId=".$session{form}{lid});
                while (%data = $sth->hash) {
			$list{$data{internationalId}."-".$data{namespace}} = $data{message};
                }
                $sth->finish;
                $sth = WebGUI::SQL->read("select * from international where languageId=1");
                while (%data = $sth->hash) {
			unless ($list{$data{internationalId}."-".$data{namespace}}) {
				$list{"missing-".$data{internationalId}."-".$data{namespace}} = $missing;
			}
                }
                $sth->finish;
		foreach $key (sort {$b cmp $a} keys %list) {
                	$newList{$key}=$list{$key};
        	}
		foreach $key (keys %newList) {
			@split = split(/-/,$key);
			if ($split[0] eq "missing") {
				$split[0] = $split[1];
				$split[1] = $split[2];
				$new = 1;
			} else {
				$new = 0;
			}
			$row[$i] = editIcon('op=editInternationalMessage&lid='.$session{form}{lid}.'&iid='.$split[0].'&namespace='.$split[1]
				.'&pn='.$session{form}{pn}.'&missing='.$new)
				.' '.$newList{$key}."<br>";
			$i++;
		}
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}),\@row,100);
                $output .= $p->getPage($session{form}{pn});
                $output .= $p->getBarTraditional($session{form}{pn});
                return _submenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listLanguages {
        my ($output, $sth, %data);
	tie %data, 'Tie::CPHash';
	if (WebGUI::Privilege::isInGroup(3)) {
		$output = '<h1>'.WebGUI::International::get(586).'</h1>';
		$output .= '<a href="'.WebGUI::URL::page('op=editLanguage&lid=new').'">'.WebGUI::International::get(584).'</a>';
		$output .= '<p>';
		$sth = WebGUI::SQL->read("select languageId,language from language where languageId<>1 order by language");
		while (%data = $sth->hash) {
			$output .= deleteIcon("op=deleteLanguage&lid=".$data{languageId})
				.editIcon("op=editLanguage&lid=".$data{languageId})
				.' '.$data{language}.'<br>';
		}
		$sth->finish;
        	return $output;
	} else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_submitTranslation {
        my ($output);
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(588).'<p>';
        $output .= '<div align="center"><a href="'.
        	WebGUI::URL::page('op=submitTranslationConfirm&lid='.$session{form}{lid})
                .'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listLanguages').
        	'">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_submitTranslationConfirm {
	my ($sth, @data, $submission);
	$submission = "#language\n\n";
	$sth = WebGUI::SQL->read("select * from language where languageId=".$session{form}{lid});
	while (@data = $sth->array) {
		$submission .= join("\t",@data)."\n"; 
	}
	$sth->finish;
        $submission .= "\n#international\n\n";
        $sth = WebGUI::SQL->read("select * from international where languageId=".$session{form}{lid});
        while (@data = $sth->array) {
                $submission .= join("\t",@data)."\n"; 
        }
        $sth->finish;
        $submission .= "\n#help\n\n";
        $sth = WebGUI::SQL->read("select * from help where languageId=".$session{form}{lid});
        while (@data = $sth->array) {
                $submission .= join("\t",@data)."\n"; 
        }
        $sth->finish;
	WebGUI::Mail::send("info\@plainblack.com","International Message Submission",$submission);
	return www_editLanguage();
}






1;


