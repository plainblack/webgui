package WebGUI::Operation::Style;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_copyStyle &www_deleteStyle &www_deleteStyleConfirm &www_editStyle &www_editStyleSave &www_listStyles);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editStyle&sid=new')} = WebGUI::International::get(158);
	if (($session{form}{op} eq "editStyle" && $session{form}{sid} ne "new") || $session{form}{op} eq "deleteStyleConfirm") {
                $menu{WebGUI::URL::page('op=editStyle&sid='.$session{form}{sid})} = WebGUI::International::get(803);
                $menu{WebGUI::URL::page('op=copyStyle&sid='.$session{form}{sid})} = WebGUI::International::get(804);
		$menu{WebGUI::URL::page('op=deleteStyle&sid='.$session{form}{sid})} = WebGUI::International::get(805);
		$menu{WebGUI::URL::page('op=listStyles')} = WebGUI::International::get(814);
	}
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_copyStyle {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
	my (%style);
	tie %style, 'Tie::CPHash';
	%style = WebGUI::SQL->quickHash("select * from style where styleId=$session{form}{sid}");
        WebGUI::SQL->write("insert into style (styleId,name,body,styleSheet) values (".getNextId("styleId").", 
		".quote('Copy of '.$style{name}).", ".quote($style{body}).", ".quote($style{styleSheet}).")");
        return _submenu(www_listStyles());
}

#-------------------------------------------------------------------
sub www_deleteStyle {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{sid} < 1000 && $session{form}{sid} > 0);
        my ($output);
        $output .= helpIcon(4);
	$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(155).'<p>';
        $output .= '<div align="center"><a href="'.
		WebGUI::URL::page('op=deleteStyleConfirm&sid='.$session{form}{sid})
		.'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listStyles').
		'">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteStyleConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{sid} < 1000 && $session{form}{sid} > 0);
        WebGUI::SQL->write("delete from style where styleId=".$session{form}{sid});
        WebGUI::SQL->write("update page set styleId=2 where styleId=".$session{form}{sid});
        return www_listStyles();
}

#-------------------------------------------------------------------
sub www_editStyle {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
        my ($output, %style, $f);
	tie %style, 'Tie::CPHash';
	if ($session{form}{sid} eq "new") {
		$style{body} = "^AdminBar;\n\n<body>\n\n^-;\n\n</body>";
		$style{styleSheet} = '
<style>
.content{
  font-family: helvetica, arial;
  font-size: 10pt;
}
.adminBar {
  background-color: #dddddd;
  font-family: helvetica, arial;
}
.tableMenu {
  background-color: #dddddd;
  font-size: 8pt;
  font-family: Helvetica, Arial;
}
.tableMenu a {
  text-decoration: none;
}
.tableHeader {
  background-color: #dddddd;
  font-size: 10pt;
  font-family: Helvetica, Arial;
}
.tableData {
  font-size: 10pt;
  font-family: Helvetica, Arial;
}
.pollColor {
  background-color: #cccccc;
  border: thin solid #aaaaaa;
}
.pagination {
  font-family: helvetica, arial;
  font-size: 8pt;
  text-align: center;
}
.tab {
  border: 1px solid black;
   background-color: #eeeeee;
}
.tabBody {
   border: 1px solid black;
   border-top: 1px solid black;
   border-left: 1px solid black;
   background-color: #dddddd; 
}
div.tabs {
    line-height: 15px;
    font-size: 14px;
}
.tabHover {
   background-color: #cccccc;
}
.tabActive { 
   background-color: #dddddd; 
}
</style>
		';
	} else {
               	%style = WebGUI::SQL->quickHash("select * from style where styleId=$session{form}{sid}");
	}
        $output .= helpIcon(16);
	$output .= '<h1>'.WebGUI::International::get(156).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","editStyleSave");
        $f->hidden("sid",$session{form}{sid});
	$f->readOnly($session{form}{sid},WebGUI::International::get(380));
        $f->text("name",WebGUI::International::get(151),$style{name});
        $f->textarea("body",WebGUI::International::get(501),$style{body},'','','',(5+$session{setting}{textAreaRows}));
        $f->textarea("styleSheet",WebGUI::International::get(154),$style{styleSheet},'','','',(5+$session{setting}{textAreaRows}));
        $f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editStyleSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
	if ($session{form}{sid} eq "new") {
		$session{form}{sid} = getNextId("styleId");
		WebGUI::SQL->write("insert into style (styleId) values ($session{form}{sid})");
	}
	$session{form}{body} = "^AdminBar;\n\n<body>\n\n^-;\n\n</body>" if ($session{form}{body} eq "");
        WebGUI::SQL->write("update style set name=".quote($session{form}{name}).", body=".quote($session{form}{body}).",
		styleSheet=".quote($session{form}{styleSheet})." where styleId=".$session{form}{sid});
        return www_listStyles();
}

#-------------------------------------------------------------------
sub www_listStyles {
        return WebGUI::Privilege::insufficient unless (WebGUI::Privilege::isInGroup(5));
        my ($output, $sth, @data, @row, $i, $p);
        $output = helpIcon(9);
	$output .= '<h1>'.WebGUI::International::get(157).'</h1>';
        $sth = WebGUI::SQL->read("select styleId,name from style order by name");
        while (@data = $sth->array) {
                $row[$i] = '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deleteStyle&sid='.$data[0])
			.editIcon('op=editStyle&sid='.$data[0])
			.copyIcon('op=copyStyle&sid='.$data[0])
			.'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data[1].'</td></tr>';
                $i++;
        }
	$sth->finish;
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listStyles'),\@row);
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= $p->getPage($session{form}{pn});
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output);
}



1;
