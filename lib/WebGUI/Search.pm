package WebGUI::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black Software.
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

=head1 SYNOPSIS

 use WebGUI::Search;
 $html = WebGUI::Search::form(\%hidden);
 $sql = WebGUI::buildConstraints(\@fields);

=head1 DESCRIPTION

 A package built to take the hassle out of creating advanced search
 functionality in WebGUI applications.

=head1 METHODS

 These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 form ( hiddenFields ) { [ numResults ] }

 Generates and returns the advanced search form.

=item hiddenFields

 A hash reference that contains any name/value pairs that should be
 included as hidden fields in the search form.

=item numResults

 A form param that can optionally specify the number of results to 
 display. Defaults to 25.

=cut

sub form {
	my ($key, $numResults, $output, $f, $resultsText, %results);
	tie %results, 'Tie::IxHash';
	$numResults = $session{form}{numResults} || 25;
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
	$f->text('all','',$session{form}{all});
	$f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(531).'</td><td class="tableData">');
        $f->text('exactPhrase','',$session{form}{exactPhrase});
        $f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(532).'</td><td class="tableData">');
        $f->text('atLeastOne','',$session{form}{atLeastOne});
        $f->raw('</td></td>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(533).'</td><td class="tableData">');
        $f->text('without','',$session{form}{without});
        $f->raw('</td></tr>');
	$f->raw('</table>');
	$f->raw('</td><td width="15%">');
	$f->select("numResults",\%results,'',[$numResults]);
	$f->raw('<p/>');
	$f->submit(WebGUI::International::get(170));
	$f->raw('</td>');
	$output .= $f->print;
	$output .= '</tr></table>';
	return $output;
}

#-------------------------------------------------------------------

=head2 buildConstraints ( fieldList ) { [ all, atLeastOne, exactPhrase, without ] }

 Generates and returns the constraints to an SQL where clause based
 upon input from the user.

=item fieldList

 An array reference that contains a list of the fields (table 
 columns) to be considered when searching.

=item all

 A form param with a comma or space separated list of key words to
 search for in the fields of the fieldList. All the words listed
 here must be found to be true.

=item atLeastOne

 A form param with a comma or space separated list of key words to
 search for in the fields of the fieldList. Any of the words may
 match in any of the fields for this to be true.

=item exactPhrase

 A form param with a phrase to search for in the fields of the
 fieldList. The exact phrase must be found in one of the fields
 to be true.

=item without

 A form param with a comma or space separated list of key words to
 search for in the fields of the fieldList. None of the words may
 be found in any of the fields for this to be true.

=cut

sub buildConstraints {
	my ($field, $all, $allSub, $exactPhrase, $atLeastOne, $without, @words, $word, $sql);
	if ($session{form}{all} ne "") {
		$session{form}{all} =~ s/,/ /g;
		$session{form}{all} =~ s/\s+/ /g;
		@words = split(/ /,$session{form}{all});
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
        if ($session{form}{exactPhrase} ne "") {
		foreach $field (@{$_[0]}) {
			$exactPhrase .= " or " if ($exactPhrase ne "");
                	$exactPhrase .= " $field like ".quote("%".$session{form}{exactPhrase}."%");
		}
        }
        if ($session{form}{atLeastOne} ne "") {
                $session{form}{atLeastOne} =~ s/,/ /g;
                $session{form}{atLeastOne} =~ s/\s+/ /g;
                @words = split(/ /,$session{form}{atLeastOne});
                foreach $word (@words) {
			foreach $field (@{$_[0]}) {
                        	$atLeastOne .= " or " if ($atLeastOne ne "");
                        	$atLeastOne .= " $field like ".quote("%".$word."%");
			}
                }
        }
        if ($session{form}{without} ne "") {
                $session{form}{without} =~ s/,/ /g;
                $session{form}{without} =~ s/\s+/ /g;
                @words = split(/ /,$session{form}{without});
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



1;


