package WebGUI::TabForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Session;


=head1 NAME

Package WebGUI::TabForm

=head1 DESCRIPTION

Package that makes creating tab-based forms simple through an object-oriented API.

=head1 SYNOPSIS

 use WebGUI::TabForm;
 use Tie::IxHash;
 my %tabs;
 tie %tabs, 'Tie::IxHash';
 %tabs = (
	cool=>{
		label=>"Cool Tab",
		uiLevel=>5
		},
	good=>{
		label=>"Good Tab",
		uiLevel=>8
		}
	);

 $tabform = WebGUI::TabForm->new;

 $tabform->hidden($name, $value);
 $tabform->submit(\%params);

 $html = $tabform->print;

 $HTMLFormObject = $tabform->getTab($tabname);
 $HTMLFormObject->textarea( -name=>$name, -value=>$value, -label=>$label);
 
The best and easiest way to use this package is to just call the methods on the tabs directly. 

 $tabform->get($tabname)->textarea( -name=>$name, -value=>$value, -label=>$label);

=head1 METHODS

These methods are available from this class:

=cut


sub getTab {
	return $_[0]->{_tab}{$_[1]}{form};
}

sub hidden {
	$_[0]->{_form}->hidden($_[1],$_[2]);
}

sub new {
	my ($class, $tabs) = @_;
	my $form = WebGUI::HTMLForm->new(1);
	foreach my $key (keys %{$tabs}) {
		$tabs->{$key}{form} = WebGUI::HTMLForm->new;
	}
	bless {_submit=>WebGUI::Form::submit(),_form=>$form,_tab=>$tabs}, $class;
}



sub print {
	my $output = '
		<script src="'.$session{config}{extrasURL}.'/tabs/utils.js" type="text/javascript"></script>
		<script src="'.$session{config}{extrasURL}.'/tabs/viewport.js" type="text/javascript"></script>
		<script src="'.$session{config}{extrasURL}.'/tabs/global.js" type="text/javascript"></script>
		<script src="'.$session{config}{extrasURL}.'/tabs/cookie.js" type="text/javascript"></script>
		<script src="'.$session{config}{extrasURL}.'/tabs/tabs.js" type="text/javascript"></script>
		<link href="'.$session{config}{extrasURL}.'/tabs/tabs.css" rel="stylesheet" rev="stylesheet" type="text/css">
	';
	my $i = 1;
	my $tabs;
	my $form;	
	foreach my $key (keys %{$_[0]->{_tab}}) {
		$tabs .= '<span id="tab'.$i.'" class="tab';
		if ($i == 1) {
			$tabs .= ' tabActive';
		}
		$tabs .= '">'.$_[0]->{_tab}{$key}{label}.'</span> ';
		$form .= '<div id="content'.$i.'" class="tabBody"><table>';
		$form .= $_[0]->{_tab}{$key}{form}->printRowsOnly;
		$form .= '</table></div>';
		$i++;
	}
	$_[0]->{_form}->raw('<div class="tabs">'.$tabs.$_[0]->{_submit}.'</div>');
	$_[0]->{_form}->raw($form);
	$output .= $_[0]->{_form}->print;
	$output .= '<script>tabInit();</script>';
	return $output;
}

sub submit {
	$_[0]->{_submit} = WebGUI::Form::submit($_[1]);
}

1;

