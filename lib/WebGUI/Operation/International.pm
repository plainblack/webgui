package WebGUI::Operation::International;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::Operation::Shared;
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
	$export = "#Exported from ".$session{setting}{companyName}." (http://".$session{env}{SERVER_NAME}.") by "
		.$session{user}{username}." (".$session{user}{email}.")\n";
        $export .= "#".$data{language}." translation export for WebGUI ".$WebGUI::VERSION.".\n\n";
        $export .= "#language\n\n";
        $export .= "delete from language where languageId=".$_[0].";\n";
        $export .= "insert into language (languageId,language,characterSet,toolbar) values ("
        	.$data{languageId}.", ".quote($data{language}).", ".quote($data{characterSet}).", "
		.quote($data{toolbar}).");\n";
        $export .= "\n#international messages\n\n";
        $sth = WebGUI::SQL->read("select * from international where languageId=".$_[0]." order by lastUpdated desc");
        while (%data = $sth->hash) {
                $export .= "delete from international where languageId=".$_[0]." and namespace="
                        .quote($data{namespace})." and internationalId=".$data{internationalId}.";\n";
                $export .= "insert into international (internationalId,languageId,namespace,message,lastUpdated";
		$export .= ",context" if ($_[0] == 1);
		$export .= ") values ("
                        .$data{internationalId}.",".$data{languageId}.",".quote($data{namespace})
                        .",".quote($data{message}).", ".$data{lastUpdated};
		$export .= ",".quote($data{context}) if ($_[0] == 1);
		$export .= ");\n";
        }
        $sth->finish;
	return $export;
}

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editLanguage&lid=new')} = WebGUI::International::get(584);
	if ($session{form}{lid} == 1) {
		$menu{WebGUI::URL::page('op=addInternationalMessage&lid=1')} = "Add a new message.";
	}
        if ($session{form}{lid} ne "new" && $session{form}{lid} ne "") {
		$menu{WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid})} = 
			WebGUI::International::get(594);
		$menu{WebGUI::URL::page('op=exportTranslation&lid='.$session{form}{lid})} = WebGUI::International::get(718);
		$menu{WebGUI::URL::page('op=submitTranslation&lid='.$session{form}{lid})} = WebGUI::International::get(593);
		$menu{WebGUI::URL::page('op=editLanguage&lid='.$session{form}{lid})} = WebGUI::International::get(598);
		$menu{WebGUI::URL::page("op=deleteLanguage&lid=".$session{form}{lid})} = WebGUI::International::get(791);
        }
	$menu{WebGUI::URL::page('op=listLanguages')} = WebGUI::International::get(585);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_addInternationalMessage {
	my ($output,$f);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
	$output = '<h1>Add English Message</h1>';
	$f = WebGUI::HTMLForm->new();
	$f->hidden("lid",1);
	$f->hidden("op","addInternationalMessageSave");
	$f->combo("namespace",
		WebGUI::SQL->buildHashRef("select namespace,namespace from international where languageId=1 order by namespace")
		,"Namespace",['WebGUI']);
	$f->textarea("message","Message");
	$f->textarea("context","Context");
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
	my $namespace = $session{form}{namespace_new} || $session{form}{namespace};
 	WebGUI::SQL->write("insert into international (languageId, internationalId, namespace, message, lastUpdated, 
		context) values
		(1,$nextId,".quote($namespace).",".quote($session{form}{message}).",".time().",
		".quote($session{form}{context}).")");
	return "<b>Message was added with id $nextId.</b>".www_listInternationalMessages();
}

#-------------------------------------------------------------------
sub www_deleteLanguage {
        my ($output);
        return WebGUI::Privilege::vitalComponent() if ($session{form}{lid} < 1000 && $session{form}{lid} > 0);
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
        $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(587).'<p>';
        $output .= '<div align="center"><a href="'.
                WebGUI::URL::page('op=deleteLanguageConfirm&lid='.$session{form}{lid})
                .'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listLanguages').
                '">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteLanguageConfirm {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{lid} < 1000 && $session{form}{lid} > 0);
        WebGUI::SQL->write("delete from language where languageId=".$session{form}{lid});
        WebGUI::SQL->write("delete from international where languageId=".$session{form}{lid});
        WebGUI::SQL->write("delete from userProfileData where fieldName='language' and fieldData=".$session{form}{lid});
	$session{form}{lid} = "";
        return www_listLanguages();
}

#-------------------------------------------------------------------
sub www_editInternationalMessage {
        my ($output, $message, $context, $f, $language);
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
	($language) = WebGUI::SQL->quickArray("select language from language where languageId=".$session{form}{lid});
        $output = '<h1>'.WebGUI::International::get(597).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->readOnly($session{form}{iid},WebGUI::International::get(601));
        $f->hidden("lid",$session{form}{lid});
	$f->hidden("status",$session{form}{status});
        $f->hidden("iid",$session{form}{iid});
        $f->hidden("pn",$session{form}{pn});
        $f->hidden("namespace",$session{form}{namespace});
        $f->hidden("op","editInternationalMessageSave");
        ($message) = WebGUI::SQL->quickArray("select message from international where internationalId=".$session{form}{iid}." 
                and namespace='".$session{form}{namespace}."' and languageId=".$session{form}{lid});
        $f->textarea("message",$language,$message);
        $f->submit;
	($message, $context) = WebGUI::SQL->quickArray("select message,context from international where internationalId=".$session{form}{iid}." 
		and namespace='".$session{form}{namespace}."' and languageId=1");
	$f->readOnly(WebGUI::Macro::negate($message),"English");
        $f->readOnly(
		-label=>"Message Context",
		-value=>$context
		);
        $output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editInternationalMessageSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
	if ($session{form}{status} eq "missing") {
               	WebGUI::SQL->write("insert into international (message,namespace,languageId,internationalId,lastUpdated) 
			values (".quote($session{form}{message}).",".quote($session{form}{namespace})
			.",".$session{form}{lid}.",".$session{form}{iid}.", ".time().")");
	} else {
               	WebGUI::SQL->write("update international set message=".quote($session{form}{message}).", lastUpdated="
			.time()." where namespace=".quote($session{form}{namespace})." 
                       	and languageId=".$session{form}{lid}." and internationalId=".$session{form}{iid});
	}
        return www_listInternationalMessages();
}

#-------------------------------------------------------------------
sub www_editLanguage {
	my ($output, $dir, @files, $file, %data, $f, %options);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
	tie %data, 'Tie::CPHash';
        $dir = $session{config}{extrasPath}.$session{os}{slash}."toolbar";
        opendir (DIR,$dir) or WebGUI::ErrorHandler::warn("Can't open toolbar directory!");
        @files = readdir(DIR);
        foreach $file (@files) {
                if ($file ne ".." && $file ne ".") {
			$options{$file} = $file;
                }
        }
        closedir(DIR);
	if ($session{form}{lid} eq "new") {
		$data{characterSet} = "ISO-8859-1";
		$data{toolbar} = "default";
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
	$f->select("toolbar",\%options,WebGUI::International::get(746),[$data{toolbar}]);
	$f->submit;
	$output .= $f->print;
	return _submenu($output);	
}

#-------------------------------------------------------------------
sub www_editLanguageSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
        if ($session{form}{lid} eq "new") {
		$session{form}{lid} = getNextId("languageId");
		WebGUI::SQL->write("insert into language (languageId) values ($session{form}{lid})");
        }
	WebGUI::SQL->write("update language set language=".quote($session{form}{language}).", 
		characterSet=".quote($session{form}{characterSet}).", toolbar=".quote($session{form}{toolbar})."
		where languageId=".$session{form}{lid});
        return www_editLanguage();
}

#-------------------------------------------------------------------
sub www_exportTranslation {
	$session{header}{mimetype} = 'text/plain';
	return _export($session{form}{lid});
}

#-------------------------------------------------------------------
sub www_listInternationalMessages {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
        my ($output, $sth, $key, $p, $status,%data, %list, $deprecated, $i, $missing, @row, $f, $outOfDate, $ok);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select language from language where languageId=".$session{form}{lid});
        $missing = '<b>'.WebGUI::International::get(596).'</b>';
        $outOfDate = '<b>'.WebGUI::International::get(719).'</b>';
        $ok = WebGUI::International::get(720);
	$deprecated = WebGUI::International::get(723);
        $output = '<h1>'.WebGUI::International::get(595).' ('.$data{language}.')</h1>';
	WebGUI::Session::setScratch("internationalSearchId",$session{form}{internationalSearchId});
	WebGUI::Session::setScratch("internationalSearchKeyword",$session{form}{internationalSearchKeyword});
	WebGUI::Session::setScratch("internationalSearchNamespace",$session{form}{internationalSearchNamespace});
	$f = WebGUI::HTMLForm->new(1);
	$f->hidden("op","listInternationalMessages");
	$f->hidden("lid",$session{form}{lid});
	my $selectedNamespace = $session{scratch}{internationalSearchNamespace} || "Any";
	my %namespaces;
	tie %namespaces, 'Tie::IxHash';
	%namespaces = (
		""=>"Any",
		WebGUI::SQL->buildHash("select distinct namespace,namespace from international order by namespace")
		);
	$f->selectList(
		-name=>"internationalSearchNamespace",
		-value=>[$selectedNamespace],
		-options=>\%namespaces
		);
	$f->integer(
		-name=>"internationalSearchId",
		-value=>$session{scratch}{internationalSearchId},
		-size=>4,
		-maxLength=>4
		);
	$f->text(
		-name=>"internationalSearchKeyword",
		-value=>$session{scratch}{internationalSearchKeyword},
		-size=>20
		);
	$f->submit("search");
	$output .= $f->print;	
	my $search;
	my $searchFlag = 0;
	if ($session{scratch}{internationalSearchKeyword} ne "") {
		$search = " and message like ".quote("%".$session{scratch}{internationalSearchKeyword}."%");
		$searchFlag = 1;
	}
	if ($session{scratch}{internationalSearchNamespace} ne "") {
		$search .= " and namespace=".quote($session{scratch}{internationalSearchNamespace});
		$searchFlag = 1;
	}
	if ($session{scratch}{internationalSearchId}) {
		$search .= " and internationalId=".$session{scratch}{internationalSearchId};
		$searchFlag = 1;
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
       	$sth = WebGUI::SQL->read("select * from international where languageId=1");
       	while (%data = $sth->hash) {
		$key = $data{namespace}."-".$data{internationalId};
		if ($searchFlag) {
			if ($list{"z-".$key}) {
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
		} else {
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
			."&status=".$list{$key}{status})."</td><td>".$list{$key}{namespace}."</td><td>"
			.$list{$key}{id}."</td><td>".$list{$key}{message}."</td></tr>\n";
		$i++;
        }
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listInternationalMessages&lid='.$session{form}{lid}),100);
	$p->setDataByArrayRef(\@row);
        $output .= $p->getBarTraditional($session{form}{pn});
	$output .= '<table style="font-size: 11px;" width="100%">';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(434).'</td><td class="tableHeader">'.
		WebGUI::International::get(575).'</td><td class="tableHeader">'.WebGUI::International::get(721)
		.'</td><td class="tableHeader">'.WebGUI::International::get(722)
		.'</td><td class="tableHeader" width="100%">'.WebGUI::International::get(230).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
	$output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu(WebGUI::Macro::negate($output));
}

#-------------------------------------------------------------------
sub www_listLanguages {
        my ($output, $sth, %data);
	tie %data, 'Tie::CPHash';
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(10));
	$output = '<h1>'.WebGUI::International::get(586).'</h1>';
	$sth = WebGUI::SQL->read("select languageId,language from language where languageId<>1 order by language");
	while (%data = $sth->hash) {
		$output .= '<a href="'.WebGUI::URL::page("op=editLanguage&lid=".$data{languageId}).'">'.$data{language}.'<br>';
	}
	$sth->finish;
       	return _submenu($output);
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
