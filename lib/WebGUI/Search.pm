package WebGUI::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::IxHash;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::Search

=head1 DESCRIPTION

A package built to take the hassle out of creating advanced search functionality in WebGUI applications.

=head1 SYNOPSIS

 use WebGUI::Search;
 $sql = WebGUI::Search::buildConstraints(\@fields);
 $html = WebGUI::Search::form(\%hidden);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 buildConstraints ( fieldList ) { [ all, atLeastOne, exactPhrase, without ] }

Generates and returns the constraints to an SQL where clause based upon input from the user.

=head3 fieldList

An array reference that contains a list of the fields (table columns) to be considered when searching.

=head3 all

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. All the words listed here must be found to be true.

=head3 atLeastOne

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. Any of the words may match in any of the fields for this to be true.

=head3 exactPhrase

A form param with a phrase to search for in the fields of the fieldList. The exact phrase must be found in one of the fields to be true.

=head3 without

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. None of the words may be found in any of the fields for this to be true.

=cut

sub buildConstraints {
	my ($field, $all, $allSub, $exactPhrase, $atLeastOne, $without, @words, $word, $sql);
	if ($session{scratch}{all} ne "") {
		$session{scratch}{all} =~ s/,/ /g;
		$session{scratch}{all} =~ s/\s+/ /g;
		@words = split(/ /,$session{scratch}{all});
		foreach $word (@words) {
			$all .= " and " if ($all ne "");
			$all .= "(";
			foreach $field (@{$_[0]}) {
				$allSub .= " or " if ($allSub ne "");
				$allSub .= " $field like ".quote("%".$word."%");
			}
			$all .= $allSub;
			$allSub = "";
			$all .= ")";
		}
	}
        if ($session{scratch}{exactPhrase} ne "") {
		foreach $field (@{$_[0]}) {
			$exactPhrase .= " or " if ($exactPhrase ne "");
                	$exactPhrase .= " $field like ".quote("%".$session{scratch}{exactPhrase}."%");
		}
        }
        if ($session{scratch}{atLeastOne} ne "") {
                $session{scratch}{atLeastOne} =~ s/,/ /g;
                $session{scratch}{atLeastOne} =~ s/\s+/ /g;
                @words = split(/ /,$session{scratch}{atLeastOne});
                foreach $word (@words) {
			foreach $field (@{$_[0]}) {
                        	$atLeastOne .= " or " if ($atLeastOne ne "");
                        	$atLeastOne .= " $field like ".quote("%".$word."%");
			}
                }
        }
        if ($session{scratch}{without} ne "") {
                $session{scratch}{without} =~ s/,/ /g;
                $session{scratch}{without} =~ s/\s+/ /g;
                @words = split(/ /,$session{scratch}{without});
                foreach $word (@words) {
			foreach $field (@{$_[0]}) {
                        	$without .= " and " if ($without ne "");
                        	$without .= " $field not like ".quote("%".$word."%");
			}
                }
        }
	$sql = "($all) " if ($all ne "");
	$sql .= " and " if ($sql ne "" && $exactPhrase ne "");
	$sql .= " ($exactPhrase) " if ($exactPhrase ne "");
	$sql .= " and " if ($sql ne "" && $atLeastOne ne "");
	$sql .= " ($atLeastOne) " if ($atLeastOne ne "");
	$sql .= " and " if ($sql ne "" && $without ne "");
	$sql .= " ($without) " if ($without ne "");
	return $sql;
}

#-------------------------------------------------------------------

=head2 form ( hiddenFields ) { [ numResults ] }

Generates and returns the advanced search form.

=head3 hiddenFields

A hash reference that contains any name/value pairs that should be included as hidden fields in the search form.

=head3 numResults

A form param that can optionally specify the number of results to display. Defaults to 25.

=cut

sub form {
	WebGUI::Session::setScratch("all",$session{form}{all});
	WebGUI::Session::setScratch("atLeastOne",$session{form}{atLeastOne});
	WebGUI::Session::setScratch("exactPhrase",$session{form}{exactPhrase});
	WebGUI::Session::setScratch("without",$session{form}{without});
	WebGUI::Session::setScratch("numResults",$session{form}{numResults});
        my ($key, $numResults, $output, $f, $resultsText, %results);
        tie %results, 'Tie::IxHash';
        $numResults = $session{scratch}{numResults} || 25;
        $resultsText = WebGUI::International::get(529);
        %results = (10=>'10 '.$resultsText, 25=>'25 '.$resultsText, 50=>'50 '.$resultsText, 100=>'100 '.$resultsText);
        $f = WebGUI::HTMLForm->new(1);
        foreach $key (keys %{$_[0]}) {
                $f->hidden($key,${$_[0]}{$key});
        }
        $output = '<table width="100%" class="tableMenu"><tr><td align="right" width="15%">';
        $output .= '<h1>'.WebGUI::International::get(364).'</h1>';
        $output .= '</td>';
        $f->raw('<td valign="top" width="70%" align="center">');
        $f->raw('<table>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(530).'</td><td class="tableData">');
        $f->text('all','',$session{scratch}{all},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(531).'</td><td class="tableData">');
        $f->text('exactPhrase','',$session{scratch}{exactPhrase},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(532).'</td><td class="tableData">');
        $f->text('atLeastOne','',$session{scratch}{atLeastOne},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></td>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(533).'</td><td class="tableData">');
        $f->text('without','',$session{scratch}{without},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('</table>');
        $f->raw('</td><td width="15%">');
        $f->selectList("numResults",\%results,'',[$numResults]);
        $f->raw('<p/>');
        $f->submit(value=>WebGUI::International::get(170));
        $f->raw('</td>');
        $output .= $f->print;
        $output .= '</tr></table>';
        return $output;
}

#-------------------------------------------------------------------

=head2 toggleURL ( [ pairs ] )

Returns a URL that toggles the value "search" in the user's scratch
variables on and off.

=head3 pairs

URL name value pairs (this=that&foo=bar) to be passed with this toggle.

=cut

sub toggleURL {
	my $pairs = shift;
	my $url = shift || $session{page}{urlizedTitle};
	WebGUI::Session::setScratch("search",$session{form}{search});
	if ($session{scratch}{search}) {
		$url = WebGUI::URL::gateway($url,"search=0");
	} else {
		$url = WebGUI::URL::gateway($url,"search=1");
	}
	$url = WebGUI::URL::append($url,$pairs) if ($pairs);
	return $url;
}

1;


