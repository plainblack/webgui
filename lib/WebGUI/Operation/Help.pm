package WebGUI::Operation::Help;

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
use Tie::CPHash;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewHelp &www_viewHelpIndex);

#-------------------------------------------------------------------
sub www_viewHelp {
        my ($output, %help, @data, $sth);
	tie %help, 'Tie::CPHash';
	%help = WebGUI::SQL->quickHash("select * from help where helpId=$session{form}{hid}",$session{dbh});
        $output = '<h1>Help: '.$help{action}.' '.$help{object}.'</h1>';
	$help{body} =~ s/\n/\<br\>/g;
	$output .= $help{body};
	$output .= '<p><b>See Also:';
        $sth = WebGUI::SQL->read("select helpId, action, object from help where object='$help{object}' and action<>'$help{action}' order by action",$session{dbh});
        while (@data = $sth->array) {
                $output .= ' <a href="'.$session{page}{url}.'?op=viewHelp&hid='.$data[0].'">'.$data[1].' '.$data[2].'</a>';
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select helpId, action, object from help where helpId in ($help{seeAlso}) order by action",$session{dbh});
        while (@data = $sth->array) {
                $output .= ' <a href="'.$session{page}{url}.'?op=viewHelp&hid='.$data[0].'">'.$data[1].' '.$data[2].'</a>';
        }
        $sth->finish;
        return $output;
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	my ($sth, @data, $output, $previous);
	$output = '<h1>Help Index</h1>';
	$output .= '<table width="100%"><tr><td valign="top"><b>Sorted By Action</b><p>';
	$sth = WebGUI::SQL->read("select helpId, action, object from help order by action,object",$session{dbh});
	while (@data = $sth->array) {
		if ($data[1] ne $previous) {
			$output .= '<p><b>'.$data[1].'</b><br>';
			$previous = $data[1];
		} 
		$output .= '<li><a href="'.$session{page}{url}.'?op=viewHelp&hid='.$data[0].'">'.$data[2].'</a><br>';
	}
	$sth->finish;
	$output .= '</td><td valign="top"><b>Sorted By Object</b><p>';
        $sth = WebGUI::SQL->read("select helpId, object, action from help order by object,action",$session{dbh});
        while (@data = $sth->array) {
                if ($data[1] ne $previous) {
                        $output .= '<p><b>'.$data[1].'</b><br>';
                        $previous = $data[1];
                }
                $output .= '<li><a href="'.$session{page}{url}.'?op=viewHelp&hid='.$data[0].'">'.$data[2].'</a><br>';
        }
        $sth->finish;
	$output .= '</td></tr></table>';
	return $output;
}

1;
