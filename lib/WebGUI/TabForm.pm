package WebGUI::TabForm;

use strict;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Session;

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
		$tabs->{$key}{uiLevel} = 9 unless ($tabs->{$key}{uiLevel});
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
		$tabs .= '">'.$_[0]->{_tab}{$key}{name}.'</span> ';
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

