package WebGUI::Operation::Template;

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
use WebGUI::HTML;
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
our @EXPORT = qw(&www_copyTemplate &www_deleteTemplate &www_deleteTemplateConfirm &www_editTemplate &www_editTemplateSave &www_listTemplates);

#-------------------------------------------------------------------
sub www_copyTemplate {
	my (%template);
        if (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
		%template = WebGUI::SQL->quickHash("select * from template where templateId=$session{form}{tid} and namespace=".quote($session{form}{namespace}));
                WebGUI::SQL->write("insert into template (templateId,name,template,namespace) 
			values (".getNextId("templateId").", 
			".quote('Copy of '.$template{name}).", ".quote($template{template}).",
			".quote($template{namespace}).")");
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplate {
        my ($output);
        if ($session{form}{tid} < 1000 && $session{form}{tid} > 0) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
                $output .= helpIcon(35);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(502).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteTemplateConfirm&tid='.$session{form}{tid}.'&namespace='
			.$session{form}{namespace})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listTemplates&namespace='
			.$session{form}{namespace}).'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplateConfirm {
	my ($a, $pageId);
        if ($session{form}{tid} < 1000 && $session{form}{tid} > 1000) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
		if ($session{form}{namespace} eq "Page") {
			$a = WebGUI::SQL->read("select * from page where templateId=".$session{form}{tid});
			while (($pageId) = $a->array) {
				WebGUI::SQL->write("update wobject set templatePosition=1 where pageId=$pageId");
			}
			$a->finish;
                	WebGUI::SQL->write("update page set templateId=2 where templateId=".$session{form}{tid});
		}
                WebGUI::SQL->write("delete from template where templateId=".$session{form}{tid}
			." and namespace=".quote($session{form}{namespace}));
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editTemplate {
        my ($output, $namespaces, %template, $f);
	tie %template, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
		if ($session{form}{tid} eq "new" || $session{form}{tid} eq "") {
			if ($session{form}{namespace} eq "Page") {
				$template{template} = "<table>\n <tr>\n  <td>\n\n<tmpl_var page.position1>\n\n".
					"</td>\n </tr>\n</table>\n";
			} else {
				$template{template} = "<h1><tmpl_var title></h1>\n\n";
			}
		} else {
                	%template = WebGUI::SQL->quickHash("select * from template where templateId=$session{form}{tid} and
				namespace=".quote($session{form}{namespace}));
		}
                $output .= helpIcon(34);
		$output .= '<h1>'.WebGUI::International::get(507).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editTemplateSave");
		$f->readOnly($session{form}{tid},WebGUI::International::get(503));
                $f->hidden("action2",$session{form}{afterEdit});
		if ($session{form}{tid} eq "new") {
			$namespaces = WebGUI::SQL->buildHashRef("select distinct(namespace),namespace 
				from template order by namespace");
			$f->select("namespace",$namespaces,WebGUI::International::get(721));
		} else {
                	$f->hidden("namespace",$session{form}{namespace});
		}
                $f->hidden("tid",$session{form}{tid});
                $f->text("name",WebGUI::International::get(528),$template{name});
                $f->textarea(
			-name=>"template",
			-label=>WebGUI::International::get(504),
			-value=>$template{template},
			-rows=>(5+$session{setting}{textAreaRows})
			);
                $f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
        if (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
		if ($session{form}{tid} eq "new") {
			($session{form}{tid}) = WebGUI::SQL->quickArray("select max(templateId) 
				from template where namespace=".quote($session{form}{namespace}));
			if ($session{form}{tid} > 999) {
				$session{form}{tid}++;
			} else {
				$session{form}{tid} = 1000;
			}
			WebGUI::SQL->write("insert into template (templateId,namespace) values 
				($session{form}{tid}, ".quote($session{form}{namespace}).")");
		}
		if ($session{form}{template} eq "" && $session{form}{namespace} eq "Page") {
			$session{form}{template} = "<table>\n<tr>\n<td>\n\n<tmpl_var page.position1>\n\n</td>\n </tr>\n</table>\n";
		}
                WebGUI::SQL->write("update template set name=".quote($session{form}{name}).", 
			template=".quote($session{form}{template})."
			where templateId=".$session{form}{tid}." and namespace=".quote($session{form}{namespace}));
		if ($session{form}{action2} eq "") {
                	return www_listTemplates();
		} else {
			return "";
		}
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listTemplates {
        my ($output, $sth, @data, @row, $i, $p, $where);
        if (WebGUI::Privilege::isInGroup($session{setting}{templateManagersGroup})) {
		$where = "where namespace=".quote($session{form}{namespace}) if ($session{form}{namespace});
                $output = helpIcon(33);
		$output .= '<h1>'.WebGUI::International::get(506).'</h1>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=editTemplate&tid=new').
			'">'.WebGUI::International::get(505).'</a><p/></div>';
                $sth = WebGUI::SQL->read("select templateId,name,namespace from template $where order by namespace,name");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td valign="top" class="tableData">'
				.deleteIcon('op=deleteTemplate&tid='.$data[0].'&namespace='.$data[2])
				.editIcon('op=editTemplate&tid='.$data[0].'&namespace='.$data[2])
				.copyIcon('op=copyTemplate&tid='.$data[0].'&namespace='.$data[2])
				.'</td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data[1].'</td>';
			$row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td></tr>';
                        $i++;
                }
		$sth->finish;
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listTemplates&namespace='.$session{form}{namespace}),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$output .= $p->getPage($session{form}{pn});
		$output .= '</table>';
		$output .= $p->getBarTraditional($session{form}{pn});
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}



1;
