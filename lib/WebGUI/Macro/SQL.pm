package WebGUI::Macro::SQL;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

sub _replacement {
	my ($output, @data, $rownum, $temp);
	my ($statement, $format) = WebGUI::Macro::getParams(shift);
	$format = '^0;' if ($format eq "");
	my $result = eval {
		my $sth = WebGUI::SQL->new($statement,$session{dbh});
		while (@data = $sth->array) {
                	$temp = $format; 
                        $temp =~ s/\^(\d+)\;/$data[$1]/g; 
                        $rownum++;
                        $temp =~ s/\^rownum\;/$rownum/g;
			$output .= $temp;
                }
		$sth->finish;
	};
	if ($@) {
		return '<p><b>SQL Macro Failed:</b> '.$@.'<p>';
	} else {
		return $output;
	}
}

sub process {
	my $output = shift;
	$output =~ s/\^SQL\((.*?)\)\;/_replacement($1)/ges;
	return $output;
}

1;

