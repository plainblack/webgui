package WebGUI::Operation::International;

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
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Paginator;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_listLanguages &www_editLanguage &www_submitTranslation &www_submitTranslationConfirm 
	&www_deleteLanguage &www_deleteLanguageConfirm &www_addInternationalMessage &www_addInternationalMessageSave
	&www_listInternationalMessages &www_editLanguageSave &www_editInternationalMessage 
	&www_exportTranslation &www_editInternationalMessageSave );


#-------------------------------------------------------------------
sub _export {
        my ($sth, %data, $export);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select * from language where languageId=".$_[0]);
        $export = "#".$data{language}." translation export for WebGUI ".$WebGUI::VERSION.".\n\n";
        $export .= "#language\n\n";
        $export .= "delete from language where languageId=".$_[0].";\n";
        $export .= "insert into language (languageId,language,characterSet) values ("
        	.$data{languageId}.", ".quote($data{language}).", ".quote($data{characterSet}).");\n";
        $export .= "\n#international\n\n";
        $sth = WebGUI::SQL->read("select * from international where languageId=".$_[0]." order by lastUpdated desc");
        while (%data = $sth->hash) {
                $export .= "delete from international where languageId=".$_[0]." and namespace="
                        .quote($data{namespace})." and internationalId=".$data{internationalId}.";\n";
                $export .= "insert into international (internationalId,languageId,namespace,message,lastUpdated) values ("
                        .$data{internationalId}.",".$data{languageId}.",".quote($data{namespace})
                        .",".quote($data{message}).", ".$data{lastUpdated}.");\n";
        }
        $sth->finish;
	return $export;
}

#-------------------------------------------------------------------
sub _submenu {
	my ($output);
	$output = '<table width="100%"><tr>';
	$output .= '<td valign="top" class="content">'.$_[0].'</td>';
	$output .= '<td valign="top" class="tableMenu" nowrap="1">';
	if ($session{form}{lid} == 1) {
		$output .= '<li><a href="'.WebGUI::URL::page('op=addInternationalMessage&lid=1').'">Add new message.</a>';
	}
	$output .= '<li><a href="'.WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}).'">'.WebGUI::International::get(594).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=editLanguage&lid='.$session{form}{lid}).'">'.WebGUI::International::get(598).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=exportTranslation&lid='.$session{form}{lid}).'">'.WebGUI::International::get(718).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=submitTranslation&lid='.$session{form}{lid}).'">'.WebGUI::International::get(593).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=listLanguages').'">'.WebGUI::International::get(585).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(493).'</a>';
	$output .= '</td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub www_addInternationalMessage {
	my ($output,$f,$namespace);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	$output = '<h1>Add English Message</h1>';
	$namespace = $session{wobject};
	$namespace->{WebGUI} = 'WebGUI';
	$f = WebGUI::HTMLForm->new();
	$f->hidden("lid",1);
	$f->hidden("op","addInternationalMessageSave");
	$f->select("namespace",$namespace,"Namespace",['WebGUI']);
	$f->textarea("message","Message");
	$f->submit;
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_addInternationalMessageSave {
	my ($nextId);
	($nextId) = WebGUI::SQL->quickArray("select max(internationalId) from international where languageId=1 
		and namespace=".quote($session{form}{namespace}));
	$nextId++;
 	WebGUI::SQL->write("insert into international (languageId, internationalId, namespace, message, lastUpdated) values
		(1,$nextId,".quote($session{form}{namespace}).",".quote($session{form}{message}).",".time().")");
	return "<b>Message was added with id $nextId.</b>".www_listInternationalMessages();
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
                	WebGUI::SQL->write("insert into international (message,namespace,languageId,internationalId,lastUpdated) 
				values (".quote($session{form}{message}).",".quote($session{form}{namespace})
				.",".$session{form}{lid}.",".$session{form}{iid}.", ".time().")");
		} else {
                	WebGUI::SQL->write("update international set message=".quote($session{form}{message}).", lastUpdated="
				.time()." where namespace=".quote($session{form}{namespace})." 
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
sub www_exportTranslation {
	$session{header}{mimetype} = 'text/plain';
	return _export($session{form}{lid});
}

#-------------------------------------------------------------------
sub www_listInternationalMessages {
        my ($output, $sth, $key, $p, $search, $status, %data, %list, $deprecated, $i, $missing, @row, $f, $outOfDate, $ok);
        tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                %data = WebGUI::SQL->quickHash("select language from language where languageId=".$session{form}{lid});
                $missing = '<b>'.WebGUI::International::get(596).'</b>';
                $outOfDate = '<b>'.WebGUI::International::get(719).'</b>';
                $ok = WebGUI::International::get(720);
		$deprecated = WebGUI::International::get(723);
                $output = '<h1>'.WebGUI::International::get(595).' ('.$data{language}.')</h1>';
		$f = WebGUI::HTMLForm->new(1);
		$f->hidden("op","listInternationalMessages");
		$f->hidden("lid",$session{form}{lid});
		$f->text("search","",$session{form}{search});
		$f->submit("search");
		$output .= $f->print;
		if ($session{form}{search} ne "") {
			$search = " and message like ".quote("%".$session{form}{search}."%");
		}
                $sth = WebGUI::SQL->read("select * from international where languageId=".$session{form}{lid}.$search);
                while (%data = $sth->hash) {
                        $list{"z-".$data{namespace}."-".$data{internationalId}}{id} = $data{internationalId};
                        $list{"z-".$data{namespace}."-".$data{internationalId}}{namespace} = $data{namespace};
                        $list{"z-".$data{namespace}."-".$data{internationalId}}{message} = $data{message};
                        $list{"z-".$data{namespace}."-".$data{internationalId}}{lastUpdated} = $data{lastUpdated};
                        $list{"z-".$data{namespace}."-".$data{internationalId}}{status} = "deleted";
                }
                $sth->finish;
                $sth = WebGUI::SQL->read("select * from international where languageId=1".$search);
                while (%data = $sth->hash) {
			$key = $data{namespace}."-".$data{internationalId};
                        unless ($list{"z-".$key}) {
                                $list{"a-".$key}{namespace} = $data{namespace};
                                $list{"a-".$key}{id} = $data{internationalId};
                                $list{"a-".$key}{status} = "missing";
                        } else {
				if ($list{"z-".$key}{lastUpdated} < $data{lastUpdated}) {
                                	$list{"o-".$key} = $list{"z-".$key};
					delete($list{"z-".$key});
                                	$list{"o-".$key}{status} = "updated";
				} else {
                                	$list{"q-".$key} = $list{"z-".$key};
					delete($list{"z-".$key});
                                	$list{"q-".$key}{status} = "ok";
				}
			}
                }
                $sth->finish;
                foreach $key (sort {$a cmp $b} keys %list) {
			if ($list{$key}{status} eq "updated") {
				$status = $outOfDate;
			} elsif ($list{$key}{status} eq "missing") {
				$status = $missing;
			} elsif ($list{$key}{status} eq "deleted") {
				$status = $deprecated;
			} else {
				$status = $ok;
			}
			$row[$i] = '<tr valign="top"><td nowrap="1">'.$status."</td><td>"
				.editIcon('op=editInternationalMessage&lid='.$session{form}{lid}
                		.'&iid='.$list{$key}{id}.'&namespace='.$list{$key}{namespace}.'&pn='.$session{form}{pn}
				.'&missing='.$list{$key}{missing})."</td><td>".$list{$key}{namespace}."</td><td>"
				.$list{$key}{id}."</td><td>".$list{$key}{message}."</td></tr>\n";
			$i++;
                }
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}),\@row,100);
                $output .= $p->getBarTraditional($session{form}{pn});
		$output .= '<table style="font-size: 11px;" width="100%">';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(434).'</td><td class="tableHeader">'.
			WebGUI::International::get(575).'</td><td class="tableHeader">'.WebGUI::International::get(721)
			.'</td><td class="tableHeader">'.WebGUI::International::get(722)
			.'</td><td class="tableHeader" width="100%">'.WebGUI::International::get(230).'</td></tr>';
                $output .= $p->getPage($session{form}{pn});
		$output .= '</table>';
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
	WebGUI::Mail::send("info\@plainblack.com","International Message Submission",_export($session{form}{lid}));
	return www_editLanguage();
}






1;


