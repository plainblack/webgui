package WebGUI::Operation::Style;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Form;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_addStyle &www_addStyleSave &www_deleteStyle &www_deleteStyleConfirm &www_editStyle &www_editStyleSave &www_listStyles);

#-------------------------------------------------------------------
sub www_addStyle {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=16"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Style</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","addStyleSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">Style Name</td><td>'.WebGUI::Form::text("name",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Header</td><td>'.WebGUI::Form::textArea("header",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Footer</td><td>'.WebGUI::Form::textArea("footer",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Style Sheet</td><td>'.WebGUI::Form::textArea("styleSheet",'<style>             </style>',50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addStyleSave {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("insert into style set styleId=".getNextId("styleId").", name=".quote($session{form}{name}).", header=".quote($session{form}{header}).", footer=".quote($session{form}{footer}).", styleSheet=".quote($session{form}{styleSheet}),$session{dbh});
                $output = www_listStyles();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteStyle {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{sid} > 25) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=4"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Please Confirm</h1>';
                $output .= 'Are you certain you wish to delete this style and migrate all pages using this style to the "Fail Safe" style?<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deleteStyleConfirm&sid='.$session{form}{sid}.'">Yes, I\'m sure.</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'?op=listStyles">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteStyleConfirm {
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{sid} > 25) {
                WebGUI::SQL->write("delete from style where styleId=".$session{form}{sid},$session{dbh});
                WebGUI::SQL->write("update page set styleId=2 where styleId=".$session{form}{sid},$session{dbh});
                return www_listStyles();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editStyle {
        my ($output, %style);
        if (WebGUI::Privilege::isInGroup(3)) {
                %style = WebGUI::SQL->quickHash("select * from style where styleId=$session{form}{sid}",$session{dbh});
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=11"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Style</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editStyleSave");
                $output .= WebGUI::Form::hidden("sid",$session{form}{sid});
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">Style Name</td><td>'.WebGUI::Form::text("name",20,30,$style{name}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Header</td><td>'.WebGUI::Form::textArea("header",$style{header},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Footer</td><td>'.WebGUI::Form::textArea("footer",$style{footer},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Style Sheet</td><td>'.WebGUI::Form::textArea("styleSheet",$style{styleSheet},50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editStyleSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update style set name=".quote($session{form}{name}).", header=".quote($session{form}{header}).", footer=".quote($session{form}{footer}).", styleSheet=".quote($session{form}{styleSheet})." where styleId=".$session{form}{sid},$session{dbh});
                return www_listStyles();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listStyles {
        my ($output, $sth, @data, $totalItems, $currentPage, $itemsPerPage);
        if (WebGUI::Privilege::isInGroup(3)) {
                $itemsPerPage = 50;
                if ($session{form}{pageNumber} < 1) {
                        $currentPage = 1;
                } else {
                        $currentPage = $session{form}{pageNumber};
                }
                ($totalItems) = WebGUI::SQL->quickArray("select count(*) from style where name<>'Reserved'",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=9"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Styles</h1>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?op=addStyle">Add a new style.</a></div>';
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $sth = WebGUI::SQL->read("select styleId,name from style where name<>'Reserved' order by name limit ".(($currentPage*$itemsPerPage)-$itemsPerPage).",".$itemsPerPage,$session{dbh});
                while (@data = $sth->array) {
                        $output .= '<tr><td valign="top"><a href="'.$session{page}{url}.'?op=deleteStyle&sid='.$data[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?op=editStyle&sid='.$data[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
                        $output .= '<td valign="top">'.$data[1].'</td>';
                }
                $output .= '</table><div class="pagination">';
                if ($currentPage > 1) {
                        $output .= '<a href="'.$session{page}{url}.'?op=listGroups&pageNumber='.($currentPage-1).'">&laquo;Previous Page</a>';
                } else {
                        $output .= '&laquo;Previous Page';
                }
                $output .= ' &middot; ';
                if ($currentPage < round($totalItems/$itemsPerPage)) {
                        $output .= '<a href="'.$session{page}{url}.'?op=listGroups&pageNumber='.($currentPage+1).'">Next Page&raquo;</a>';
                } else {
                        $output .= 'Next Page&raquo;';
                }
                $output .= '</div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}



1;
