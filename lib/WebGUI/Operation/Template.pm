package WebGUI::Operation::Template;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::Grouping;
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

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new;
        if ($help) {
                $ac->setHelp($help);
        }
        $ac->setAdminFunction("templates");
        $ac->addSubmenuItem(WebGUI::URL::page('op=editTemplate&tid=new&namespace='.$session{form}{namespace}), WebGUI::International::get(505));
        if ($session{form}{op} eq "editTemplate" && ($session{form}{tid} ne "new" || $session{form}{op} ne "deleteTemplateConfirm")) {
                $ac->addSubmenuItem(
			WebGUI::URL::page('op=editTemplate&tid='.$session{form}{tid}.'&namespace='.$session{form}{namespace}),
			WebGUI::International::get(851)
			);
                $ac->addSubmenuItem(
			WebGUI::URL::page('op=copyTemplate&tid='.$session{form}{tid}.'&namespace='.$session{form}{namespace}), 
			WebGUI::International::get(852)
			);
               	$ac->addSubmenuItem(
			WebGUI::URL::page('op=deleteTemplate&tid='.$session{form}{tid}.'&namespace='.$session{form}{namespace}), 
			WebGUI::International::get(853)
			);
                $ac->addSubmenuItem(
			WebGUI::URL::page('op=listTemplates&namespace='.$session{form}{namespace}),
			WebGUI::International::get(854)
			);
        }
        $ac->addSubmenuItem(WebGUI::URL::page('op=listTemplates'), WebGUI::International::get(855));
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_copyTemplate {
        if (WebGUI::Grouping::isInGroup(8)) {
		my $template = WebGUI::Template::get($session{form}{tid},$session{form}{namespace});
		$template->{name} .= " (copy)";
		$template->{templateId} = "new";
		WebGUI::Template::set($template);
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplate {
        my ($output);
        if ($session{form}{tid} =~ /^\d+$/ && $session{form}{tid} < 1000 && $session{form}{tid} > 0) {
		return _submenu(WebGUI::Privilege::vitalComponent());
        } elsif (WebGUI::Grouping::isInGroup(8)) {
                $output .= WebGUI::International::get(502).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteTemplateConfirm&tid='.$session{form}{tid}.'&namespace='
			.$session{form}{namespace})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listTemplates&namespace='
			.$session{form}{namespace}).'">'.WebGUI::International::get(45).'</a></div>';
                return _submenu($output,'42',"template delete");
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplateConfirm {
	my ($a, $pageId);
        if ($session{form}{tid} =~ /^\d+$/ && $session{form}{tid} < 1000 && $session{form}{tid} > 0) {
		return _submenu(WebGUI::Privilege::vitalComponent());
        } elsif (WebGUI::Grouping::isInGroup(8)) {
		if ($session{form}{namespace} eq "Page") {
			$a = WebGUI::SQL->read("select * from page where templateId=".quote($session{form}{tid}));
			while (($pageId) = $a->array) {
				WebGUI::SQL->write("update wobject set templatePosition=1 where pageId=".quote($pageId));
			}
			$a->finish;
                	WebGUI::SQL->write("update page set templateId=2 where templateId=".quote($session{form}{tid}));
		}
                WebGUI::SQL->write("delete from template where templateId=".quote($session{form}{tid})
			." and namespace=".quote($session{form}{namespace}));
                return www_listTemplates();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editTemplate {
        my ($namespaces, %template, $f);
	tie %template, 'Tie::CPHash';
        if (WebGUI::Grouping::isInGroup(8)) {
		if ($session{form}{tid} eq "new" || $session{form}{tid} eq "") {
			if ($session{form}{namespace} eq "Page") {
				$template{template} = "<table>\n <tr>\n  <td>\n\n<tmpl_var page.position1>\n\n".
					"</td>\n </tr>\n</table>\n";
			} else {
				$template{template} = "<h1><tmpl_var title></h1>\n\n";
			}
		} else {
                	%template = WebGUI::SQL->quickHash("select * from template where templateId=".quote($session{form}{tid})." and
				namespace=".quote($session{form}{namespace}));
		}
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editTemplateSave");
		$f->readOnly($session{form}{tid},WebGUI::International::get(503));
                $f->raw('<input type="hidden" name="op2" value="'.$session{form}{afterEdit}.'" />');
		if ($session{form}{tid} eq "new") {
			$namespaces = WebGUI::SQL->buildHashRef("select distinct(namespace),namespace 
				from template order by namespace");
			$f->select("namespace",$namespaces,WebGUI::International::get(721),[$session{form}{namespace}]);
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
        	return _submenu($f->print,'507',"template add/edit");
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
        if (WebGUI::Grouping::isInGroup(8)) {
		if ($session{form}{template} eq "" && $session{form}{namespace} eq "Page") {
			$session{form}{template} = "<table>\n<tr>\n<td>\n\n<tmpl_var page.position1>\n\n</td>\n </tr>\n</table>\n";
		}
		$session{form}{tid} = WebGUI::Template::set({
			templateId=>$session{form}{tid},
			namespace=>$session{form}{namespace},
			name=>$session{form}{name},
			template=>$session{form}{template}
			});
		if ($session{form}{op2} eq "") {
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
        if (WebGUI::Grouping::isInGroup(8)) {
		$where = "and namespace=".quote($session{form}{namespace}) if ($session{form}{namespace});
                $sth = WebGUI::SQL->read("select templateId,name,namespace from template where isEditable=1 $where order by namespace,name");
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
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listTemplates&namespace='.$session{form}{namespace}));
		$p->setDataByArrayRef(\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$output .= $p->getPage($session{form}{pn});
		$output .= '</table>';
		$output .= $p->getBarTraditional($session{form}{pn});
                return _submenu($output,'506',"templates manage");
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
