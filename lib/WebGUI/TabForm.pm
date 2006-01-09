package WebGUI::TabForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::Style;


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

=head2 addTab ( name, label, uiLevel ) 

Adds a new tab to the tab form.

=head3 name

A key to reference the tab by.

=head3 label

The name that will appear on the tab itself.

=head3 uiLevel

The UI Level the user must have to view the tab. Defaults to '0'.

=cut

sub addTab {
	my $self = shift;
	my $name = shift;
	my $label = shift;
	my $uiLevel = shift || 0;
	$self->{_tab}{$name}{form} = WebGUI::HTMLForm->new(uiLevelOverride=>$self->{_uiLevelOverride});
	$self->{_tab}{$name}{label} = $label;
	$self->{_tab}{$name}{uiLevel} = $uiLevel;
}

#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Replaces the default form header with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::formHeader() method.

=cut

sub formHeader {
	my $self = shift;
	my $form = shift;
        $self->{_form} = WebGUI::Form::formHeader($form);
}


#-------------------------------------------------------------------

=head2 getTab ( tabName )

Returns a WebGUI::HTMLForm object based upon a tab name created in the constructor.

=head3 tabName

The name of the tab to return the form object for.

=cut

sub getTab {
	my $self = shift;
	my $key = shift;
	return $self->{_tab}{$key}{form};
}


#-------------------------------------------------------------------

=head2 hidden ( hashRef )

Adds a hidden field to the form.

B<NOTE:> This uses the same syntax of the WebGUI::Form::hidden() method.

=cut

sub hidden {
	my $self = shift;
	my $params = shift;
	$self->{_hidden} .= WebGUI::Form::Hidden($params);
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
	my $class = shift;
	my $startingTabs = shift;
	my $css = shift || $self->session->config->get("extrasURL").'/tabs/tabs.css';
	my $cancelUrl = shift || $self->session->url->page();
	my $uiLevelOverride = shift;
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	foreach my $key (keys %{$startingTabs}) {
		$tabs{$key}{form} = WebGUI::HTMLForm->new(uiLevelOverride=>$uiLevelOverride);
		$tabs{$key}{label} = $startingTabs->{$key}->{label};
		$tabs{$key}{uiLevel} = $startingTabs->{$key}->{uiLevel};
	}
	my $cancel = WebGUI::Form::button({
			value=>WebGUI::International::get('cancel'),
			extras=>q|onclick="history.go(-1);"|
			});
	bless {	_uiLevelOverride=>$uiLevelOverride, _cancel=>$cancel, _submit=>WebGUI::Form::submit(), _form=>WebGUI::Form::formHeader(), _hidden=>"", _tab=>\%tabs, _css=>$css }, $class;
}


#-------------------------------------------------------------------

=head2 print ( )

Returns an HTML string with all the necessary components to draw the tab form.

=cut

sub print {
	my $self = shift;
	$self->session->style->setScript($self->session->config->get("extrasURL").'/tabs/tabs.js',{type=>"text/javascript"});
	$self->session->style->setLink($self->{_css},{rel=>"stylesheet", rev=>"stylesheet",type=>"text/css"});
	my $output = $self->{_form};
	$output .= $self->{_hidden};
	my $i = 1;
	my $tabs;
	my $form;	
	foreach my $key (keys %{$self->{_tab}}) {
		$tabs .= '<span onclick="toggleTab('.$i.')" id="tab'.$i.'" class="tab"';
                if ($self->{_tab}->{$key}{uiLevel} > $self->session->user->profileField("uiLevel")) {
                        $tabs .= 'style="display: none;"';
                }
                $tabs .= '>'.$self->{_tab}{$key}{label}.'</span> ';
		$form .= '<div id="tabcontent'.$i.'" class="tabBody"><table>';
		$form .= $self->{_tab}{$key}{form}->printRowsOnly;
		$form .= '</table></div>';
		$i++;
	}
	$output .= '<div class="tabs">'.$tabs.$self->{_submit}."&nbsp;&nbsp;".$self->{_cancel}.'</div>';
	$output .= $form;
	$output .= WebGUI::Form::formFooter();
	$output .= '<script type="text/javascript">var numberOfTabs = '.($i-1).'; initTabs();</script>';
	$output .= '<script type="text/javascript" src="'.$self->session->config->get("extrasURL").'/wz_tooltip.js"></script>';
	return $output;
}


#-------------------------------------------------------------------

=head2 submit ( hashRef )

Replaces the default submit button with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::submit() method.

=cut

sub submit {
	my $self = shift;
	my $submit = shift;
	$self->{_submit} = WebGUI::Form::Submit($submit);
}


1;

