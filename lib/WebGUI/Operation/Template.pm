package WebGUI::Operation::Template;

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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_copyTemplate &www_deleteTemplate &www_deleteTemplateConfirm &www_editTemplate &www_editTemplateSave &www_listTemplates);

#-------------------------------------------------------------------
sub www_copyTemplate {
	my (%template);
        if (WebGUI::Privilege::isInGroup(8)) {
		%template = WebGUI::SQL->quickHash("select * from template where templateId=$session{form}{tid}");
                WebGUI::SQL->write("insert into template (templateId,name,template) values (".getNextId("templateId").", 
			".quote('Copy of '.$template{name}).", ".quote($template{template}).")");
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplate {
        my ($output);
        if ($session{form}{tid} < 1000 && $session{form}{tid} > 1000) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(8)) {
                $output .= helpIcon(35);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(502).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteTemplateConfirm&tid='.$session{form}{tid})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listTemplates').
			'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplateConfirm {
        if ($session{form}{tid} < 1000 && $session{form}{tid} > 1000) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(8)) {
                WebGUI::SQL->write("delete from template where templateId=".$session{form}{tid});
                WebGUI::SQL->write("update page set templateId=2 where templateId=".$session{form}{tid});
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editTemplate {
        my ($output, %template, $f);
	tie %template, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(8)) {
		if ($session{form}{tid} eq "new") {
			$template{template} = "<table>\n <tr>\n  <td>\n\n^0;\n\n  </td>\n </tr>\n</table>\n";
		} else {
                	%template = WebGUI::SQL->quickHash("select * from template where templateId=$session{form}{tid}");
		}
                $output .= helpIcon(34);
		$output .= '<h1>'.WebGUI::International::get(507).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editTemplateSave");
                $f->hidden("tid",$session{form}{tid});
		$f->readOnly($session{form}{tid},WebGUI::International::get(503));
                $f->text("name",WebGUI::International::get(151),$template{name});
                $f->HTMLArea("template",WebGUI::International::get(504),$template{template},'','','',(5+$session{setting}{textAreaRows}));
                $f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
        if (WebGUI::Privilege::isInGroup(8)) {
		if ($session{form}{tid} eq "new") {
			$session{form}{tid} = getNextId("templateId");
			WebGUI::SQL->write("insert into template (templateId) values ($session{form}{tid})");
		}
		$session{form}{template} = "<table>\n <tr>\n  <td>\n\n^0;\n\n  </td>\n </tr>\n</table>\n" if ($session{form}{template} eq "");
                WebGUI::SQL->write("update template set name=".quote($session{form}{name}).", template=".quote($session{form}{template})."
			where templateId=".$session{form}{tid});
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listTemplates {
        my ($output, $sth, @data, @row, $i, $p);
        if (WebGUI::Privilege::isInGroup(8)) {
                $output = helpIcon(33);
		$output .= '<h1>'.WebGUI::International::get(506).'</h1>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=editTemplate&tid=new').
			'">'.WebGUI::International::get(505).'</a><p/></div>';
                $sth = WebGUI::SQL->read("select templateId,name from template order by name");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td valign="top" class="tableData">'
				.deleteIcon('op=deleteTemplate&tid='.$data[0])
				.editIcon('op=editTemplate&tid='.$data[0])
				.copyIcon('op=copyTemplate&tid='.$data[0])
				.'</td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data[1].'</td></tr>';
                        $i++;
                }
		$sth->finish;
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listTemplates'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$output .= $p->getPage($session{form}{pn});
		$output .= '</table>';
		$output .= $p->getBarTraditional($session{form}{pn});
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}



1;
