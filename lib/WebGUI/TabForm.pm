package WebGUI::TabForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

 $tabform = WebGUI::TabForm->new($self->session,\%tabs);

 $tabform->hidden({name => $name, value => $value});
 $tabform->submit(\%params);

 $html = $tabform->print;

 $HTMLFormObject = $tabform->getTab($tabname);
 $HTMLFormObject->textarea( -name=>$name, -value=>$value, -label=>$label);
 
The best and easiest way to use this package is to just call the methods on the tabs directly. 

 $tabform->getTab($tabname)->textarea( -name=>$name, -value=>$value, -label=>$label);

=head1 SEE ALSO

This package is an extension to WebGUI::HTMLForm. See that package for documentation of its methods.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addTab ( name, label, uiLevel ) 

Adds a new tab to the tab form. Returns the WebGUI::HTMLForm object created.

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
	$self->{_tab}{$name}{form} = WebGUI::HTMLForm->new($self->session);
	$self->{_tab}{$name}{label} = $label;
	$self->{_tab}{$name}{uiLevel} = $uiLevel;
	return $self->{_tab}{$name}{form};
}

#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Replaces the default form header with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::formHeader($self->session,) method.

=cut

sub formHeader {
	my $self = shift;
	my $form = shift;
        $self->{_form} = WebGUI::Form::formHeader($self->session,$form);
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
    $self->session->log->warn('Trying to fetch non-existant tab: '.$key) if !exists $self->{_tab}{$key};
	return $self->{_tab}{$key}{form};
}


#-------------------------------------------------------------------

=head2 hidden ( hashRef )

Adds a hidden field to the form.

B<NOTE:> This uses the same syntax of the WebGUI::Form::hidden($self->session,) method.

=cut

sub hidden {
	my $self = shift;
	my $params = shift;
	$self->{_hidden} .= WebGUI::Form::Hidden($self->session,$params);
}


#-------------------------------------------------------------------

=head2 new ( session, tabHashRef , cssString)

Constructor.

=head3 session

A reference to the current session.

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
	my $session = shift;
	my $startingTabs = shift;
	my $css = shift || $session->url->extras('tabs/tabs.css');
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	foreach my $key (keys %{$startingTabs}) {
		$tabs{$key}{form} = WebGUI::HTMLForm->new($session);
		$tabs{$key}{label} = $startingTabs->{$key}->{label};
		$tabs{$key}{uiLevel} = $startingTabs->{$key}->{uiLevel};
	}
	my $i18n = WebGUI::International->new($session);
    my $cancelJS  = 'history.go(-1);';
    if (my $cancelURL = $session->request->referer) {
        $cancelJS = sprintf q{window.location.href='%s';}, $cancelURL;
    }
	my $cancel = WebGUI::Form::button($session,{
			value=>$i18n->get('cancel'),
			extras=>sprintf(q|onclick="%s" class="backwardButton"|, $cancelJS),
			});
	bless {	_session=>$session, _cancel=>$cancel, _submit=>WebGUI::Form::submit($session), 
        _form=>WebGUI::Form::formHeader($session), _hidden=>"", _tab=>\%tabs, _css=>$css }, $class;
}


#-------------------------------------------------------------------

=head2 print ( )

Returns an HTML string with all the necessary components to draw the tab form.

=cut

sub print {
	my $self = shift;
    my $style = $self->session->style;
    my $url = $self->session->url;
	$style->setCss($self->{_css});
	$style->setCss($url->extras('/yui/build/fonts/fonts-min.css'));
	$style->setCss($url->extras('/yui/build/tabview/assets/skins/sam/tabview.css'));
    $style->setCss($url->extras('/yui/build/container/assets/container.css'));
    $style->setCss($url->extras('/hoverhelp.css'));
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'));
    $style->setScript($url->extras('/yui/build/container/container-min.js'));
    $style->setScript($url->extras('/yui/build/tabview/tabview-min.js'));
    $style->setScript($url->extras('/hoverhelp.js'));
	my $i = 1;
	my $tabs = '<ul class="yui-nav">';
	my $form = '<div class="yui-content">';
	my $userUiLevel = $self->session->user->get("uiLevel");
	my $first = 1;
	foreach my $key (keys %{$self->{_tab}}) {
		my $hide = '';
		if ($self->{_tab}->{$key}{uiLevel} > $userUiLevel) {
			$hide = 'style="display: none;"';
		}
		my $selected = '';
		if ($first && !$hide) {
			$first = 0;
			$selected = 'class="selected"';
		}
		$tabs .= '<li '.$selected.'><a href="#tab'.$i.'" '.$hide.'><em>'.$self->{_tab}{$key}{label}.'</em></a></li>';
		$form .= '<div id="tab'.$i.'" '.$hide.'><table>'.$self->{_tab}{$key}{form}->printRowsOnly.'</table></div>';
		$i++;
	}
	$tabs .= '</ul>';
	$form .= '</div>';
	my $output = $self->{_form}.$self->{_hidden}.'<div style="position: absolute; top: 10px; right: 10px; z-index: 50000;">'.$self->{_submit}.$self->{_cancel}.'</div><div class="yui-skin-sam"><div id="webguiTabForm" class="yui-navset">'.$tabs.$form.'</div></div>';
	$output .= WebGUI::Form::formFooter($self->session);
	$output .= q{<script type="text/javascript">
		var tabView = new YAHOO.widget.TabView('webguiTabForm');
	</script>};
	return $output;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 submit ( hashRef )

Replaces the default submit button with a new definition.

B<NOTE:> This uses the same syntax of the WebGUI::Form::submit($self->session,) method.

=cut

sub submit {
	my $self = shift;
	my $submit = shift;
	$self->{_submit} = WebGUI::Form::Submit($self->session,$submit);
}

#-------------------------------------------------------------------

=head2 submitAppend ( html )

Appends some HTML to the submit button.

=cut

sub submitAppend {
	my $self = shift;
	my $html = shift;
	$self->{_submit} .= $html;
}

1;

