package WebGUI::Operation::Style;

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
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_copyStyle &www_deleteStyle &www_deleteStyleConfirm &www_editStyle &www_editStyleSave &www_listStyles);

#-------------------------------------------------------------------
sub www_copyStyle {
	my (%style);
        if (WebGUI::Privilege::isInGroup(5)) {
		%style = WebGUI::SQL->quickHash("select * from style where styleId=$session{form}{sid}");
                WebGUI::SQL->write("insert into style (styleId,name,body,styleSheet) values (".getNextId("styleId").", 
			".quote('Copy of '.$style{name}).", ".quote($style{body}).", ".quote($style{styleSheet}).")");
                return www_listStyles();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteStyle {
        my ($output);
        if ($session{form}{sid} < 26 && $session{form}{sid} > 0) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(5)) {
                $output .= helpIcon(4);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(155).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteStyleConfirm&sid='.$session{form}{sid})
			.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listStyles').
			'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteStyleConfirm {
        if ($session{form}{sid} < 26 && $session{form}{sid} > 0) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(5)) {
                WebGUI::SQL->write("delete from style where styleId=".$session{form}{sid});
                WebGUI::SQL->write("update page set styleId=2 where styleId=".$session{form}{sid});
                return www_listStyles();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editStyle {
        my ($output, %style, $f);
	tie %style, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(5)) {
		if ($session{form}{sid} eq "new") {
			$style{body} = "^AdminBar;\n\n<body>\n\n^-;\n\n</body>";
			$style{styleSheet} = "<style>\n\n</style>";
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
                $f->HTMLArea("body",WebGUI::International::get(501),$style{body},'','','',(5+$session{setting}{textAreaRows}));
                $f->textarea("styleSheet",WebGUI::International::get(154),$style{styleSheet},'','','',(5+$session{setting}{textAreaRows}));
                $f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editStyleSave {
        if (WebGUI::Privilege::isInGroup(5)) {
		if ($session{form}{sid} eq "new") {
			$session{form}{sid} = getNextId("styleId");
			WebGUI::SQL->write("insert into style (styleId) values ($session{form}{sid})");
		}
		$session{form}{body} = "^AdminBar;\n\n<body>\n\n^-;\n\n</body>" if ($session{form}{body} eq "");
                WebGUI::SQL->write("update style set name=".quote($session{form}{name}).", body=".quote($session{form}{body}).",
			styleSheet=".quote($session{form}{styleSheet})." where styleId=".$session{form}{sid});
                return www_listStyles();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listStyles {
        my ($output, $sth, @data, @row, $i, $p);
        if (WebGUI::Privilege::isInGroup(5)) {
                $output = helpIcon(9);
		$output .= '<h1>'.WebGUI::International::get(157).'</h1>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=editStyle&sid=new').
			'">'.WebGUI::International::get(158).'</a><p/></div>';
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
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}



1;
