package WebGUI::TabForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
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

 $tabform = WebGUI::TabForm->new(\%tabs);

 $tabform->hidden($name, $value);
 $tabform->submit(\%params);

 $html = $tabform->print;

 $HTMLFormObject = $tabform->getTab($tabname);
 $HTMLFormObject->textarea( -name=>$name, -value=>$value, -label=>$label);
 
The best and easiest way to use this package is to just call the methods on the tabs directly. 

 $tabform->get($tabname)->textarea( -name=>$name, -value=>$value, -label=>$label);

=head1 SEE ALSO

This package is an extension to WebGUI::HTMLForm. See that package for documentation of its methods.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Replaces the default form header with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::formHeader() method.

=cut

sub formHeader {
        $_[0]->{_form} = WebGUI::Form::formHeader($_[1]);
}


#-------------------------------------------------------------------

=head2 getTab ( tabName )

Returns a WebGUI::HTMLForm object based upon a tab name created in the constructor.

=head3 tabName

The name of the tab to return the form object for.

=cut

sub getTab {
	return $_[0]->{_tab}{$_[1]}{form};
}


#-------------------------------------------------------------------

=head2 hidden ( hashRef )

Adds a hidden field to the form.

B<NOTE:> This uses the same syntax of the WebGUI::Form::hidden() method.

=cut

sub hidden {
	$_[0]->{_hidden} .= WebGUI::Form::hidden($_[1]);
}


#-------------------------------------------------------------------

=head2 new ( tabHashRef , cssString)

Constructor.

=head3 tabHashRef

A hash reference containing the definition of the tabs. It should be constructed like this:

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

=head3 cssString

A string containing the link to the tab-CascadingStyleSheet

 default = extrasPath.'/tabs/tabs.css'
	
=cut

sub new {
	my ($class, $tabs, $css);
	$class = $_[0];
	$tabs = $_[1];
	$css = $_[2] || $session{config}{extrasURL}.'/tabs/tabs.css';
	foreach my $key (keys %{$tabs}) {
		$tabs->{$key}{form} = WebGUI::HTMLForm->new;
	}
	bless {	_submit=>WebGUI::Form::submit(), _form=>WebGUI::Form::formHeader(), _hidden=>"", _tab=>$tabs, _css=>$css }, $class;
}


#-------------------------------------------------------------------

=head2 print ( )

Returns an HTML string with all the necessary components to draw the tab form.

=cut

sub print {
	my $output = '
		<script src="'.$session{config}{extrasURL}.'/tabs/tabs.js" type="text/javascript"></script>
		<link href="'.$_[0]->{_css}.'" rel="stylesheet" rev="stylesheet" type="text/css">
	';
	$output .= $_[0]->{_form};
	$output .= $_[0]->{_hidden};
	my $i = 1;
	my $tabs;
	my $form;	
	foreach my $key (keys %{$_[0]->{_tab}}) {
		$tabs .= '<span onclick="toggleTab('.$i.')" id="tab'.$i.'" class="tab"';
                if ($_[0]->{_tab}->{$key}{uiLevel} > $session{user}{uiLevel}) {
                        $tabs .= 'style="display: none;"';
                }
                $tabs .= '>'.$_[0]->{_tab}{$key}{label}.'</span> ';
		$form .= '<div id="tabcontent'.$i.'" class="tabBody"><table>';
		$form .= $_[0]->{_tab}{$key}{form}->printRowsOnly;
		$form .= '</table></div>';
		$i++;
	}
	$output .= '<div class="tabs">'.$tabs.$_[0]->{_submit}.'</div>';
	$output .= $form;
	$output .= WebGUI::Form::formFooter();
	$output .= '<script>var numberOfTabs = '.($i-1).'; initTabs();</script>';
	return $output;
}


#-------------------------------------------------------------------

=head2 submit ( hashRef )

Replaces the default submit button with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::submit() method.

=cut

sub submit {
	$_[0]->{_submit} = WebGUI::Form::submit($_[1]);
}


1;

