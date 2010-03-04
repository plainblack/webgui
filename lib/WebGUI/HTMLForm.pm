package WebGUI::HTMLForm;

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

use CGI::Util qw(rearrange);
use strict qw(vars refs);
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::HTMLForm

=head1 DESCRIPTION

Package that makes HTML forms typed data and significantly reduces the code needed for properties pages in WebGUI.

=head1 SYNOPSIS

 use WebGUI::HTMLForm;
 $f = WebGUI::HTMLForm->new($self->session);

 $f->someFormControlType(
	name=>"someName",
	value=>"someValue"
	);

 Example:

 $f->text(
	name=>"title",
	value=>"My Big Article"
	);

See the list of form control types for details on what's available.

 $f->trClass("class");		# Sets a Table Row class

 $f->print;
 $f->printRowsOnly;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _uiLevelChecksOut {
	my $self = shift;
	if ($_[0] <= $self->session->user->profileField("uiLevel")) {
		return 1;
	} 
    else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 AUTOLOAD ( )
        
Dynamically creates functions on the fly for all the different form control types.

=cut    
        
sub AUTOLOAD {  
    our $AUTOLOAD;
	my $self = shift;
    my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);
    my %params = @_;
	$params{rowClass} ||= $self->{_class};
    my $control = eval { WebGUI::Pluggable::instanciate("WebGUI::Form::".$name, "new", [ $self->session, %params ]) };
    if ($@) {
        $self->session->errorHandler->error($@);
        return undef;
    }
	$self->{_data} .= $control->toHtmlWithWrapper;
}       
        
#-------------------------------------------------------------------

=head2 DESTROY ( )

Disposes of the form object.

=cut

sub DESTROY {
	my $self = shift;
	$self = undef;
}


#-------------------------------------------------------------------

=head2 dynamicForm ( $formDefinition, $listName, $who ) 

Build a form dynamically from an array of hash refs.  The format is
based on the definition sub from Asset, Workflow::Activity and
elements of the ShipDriver and PaymentDriver.

=head3 $formDefinition

An arrayref of hashrefs.  The arrays are processed in order, but the only
way to guarantee the order of the hashes to tie them with Tie::IxHash.

These fields are allowed in each sub hash

=head4 label

A readable, probably internationalized label.

=head4 hoverHelp

A tooltip that will activate when the label is hovered over.

=head4 fieldType

The kind of HTML form field to build.  This is a lower case version of
any WebGUI::Form plugin.

=head4 defaultValue

The default value the form field should have if the caller has no value
for this field.

=head3 $listName

The name of the key in the structure that contains the list of
fields.  For example, in Workflow Activities, it is called "properties".
Inside the Shop modules, it is called "fields".

=head3 $who

In order to populate the form with current information from an object,
you need to it the object.  dynamicForm expects each object to have
a C<get> method to provide that information.

=cut

sub dynamicForm {
	my ($self, $formDefinition, $fieldList, $parent) = @_;
    foreach my $definition (reverse @{$formDefinition}) {
        my $properties = $definition->{$fieldList};
        foreach my $fieldname (keys %{$properties}) {
            my %params;
            foreach my $key (keys %{$properties->{$fieldname}}) {
                $params{$key} = $properties->{$fieldname}{$key};
                if ($fieldname eq "title" && lc($params{$key}) eq "untitled") {
                    $params{$key} = $formDefinition->[0]{name};
                }
            }
            $params{value} = $parent->get($fieldname);
            $params{name}  = $fieldname;
            $self->dynamicField(%params);
        }
    }
}


#-------------------------------------------------------------------

=head2 fieldSetEnd ( ) 

Closes a field set that was opened by fieldSetStart();

=cut

sub fieldSetEnd {
	my $self = shift;
	my $legend = shift;
	$self->{_data} .= "</tbody></table>\n"
		."</fieldset>\n"
		."<table ".$self->{_tableExtras}.' style="width: 100%;"><tbody>'
		."\n";
}


#-------------------------------------------------------------------

=head2 fieldSetStart ( legend ) 

Adds a field set grouping to the form. Note, must be closed with fieldSetEnd().

=head3 legend

A text label to appear with the field set.

=cut

sub fieldSetStart {
	my $self = shift;
	my $legend = shift;
	$self->{_data} .= "</tbody></table>\n"
		."<fieldset>\n<legend>".$legend."</legend>\n"
		."<table ".$self->{_tableExtras}.' style="width: 100%;"><tbody>'
		."\n";
}


#-------------------------------------------------------------------

=head2 new ( session [ properties ] )

Constructor.


=head3 session

A reference to the session.

=head3 properties

A hash of parameters to modify the defaults of the form.

=head4 action

The Action URL for the form information to be submitted to. This defaults to the current page.

=head4 method

The form's submission method. This defaults to "POST" and probably shouldn't be changed.

=head4 extras

If you want to add anything special to your form like javascript actions, or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" onchange="myForm.submit()"'

=head4 enctype 

The encapsulation type for this form. This defaults to "multipart/form-data" and should probably never be changed.

=head4 tableExtras

If you want to add anything special to the form's table like a name or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" class="formTable"'

=cut

sub new {
	my ($header, $footer);
	my $class = shift;
	my $session = shift;
	my %param = @_;
	$header = "\n\n".WebGUI::Form::formHeader($session,{
		action=>($param{action} || $param{'-action'} || $session->url->page),
		extras=>($param{extras} || $param{'-extras'}),
		method=>($param{method} || $param{'-method'}),
		enctype=>($param{enctype} || $param{'-enctype'})
		});
	$header .= "\n<table ".$param{tableExtras}.' style="width: 100%;"><tbody>';
	$footer = "</tbody></table>\n" ;
	$footer .= WebGUI::Form::formFooter($session);
	bless {_session=>$session, _tableExtras=>$param{tableExtras}, _header => $header, _footer => $footer, _data => ''}, $class;
}

#-------------------------------------------------------------------

=head2 print ( )

Returns the HTML for this form object.

=cut

sub print {
	my $self = shift;
    my $style = $self->session->style;
    my $url = $self->session->url;
    $style->setLink($url->extras('/yui/build/container/assets/container.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setLink($url->extras('/hoverhelp.css'),{ type=>'text/css', rel=>"stylesheet" });
    $style->setScript($url->extras('/yui/build/yahoo/yahoo-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/dom/dom-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/event/event-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/yui/build/container/container-min.js'),{ type=>'text/javascript' });
    $style->setScript($url->extras('/hoverhelp.js'),{ type=>'text/javascript' });
        return $self->{_header}.$self->{_data}.$self->{_footer};
}

#-------------------------------------------------------------------

=head2 printRowsOnly ( )

Returns the HTML for this form object except for the form header and footer.

=cut

sub printRowsOnly {
        return $_[0]->{_data};
}


#-------------------------------------------------------------------

=head2 raw ( value, uiLevel )

Adds raw data to the form. This is primarily useful with the printRowsOnly method and if you generate your own form elements.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=cut

sub raw {
        my ($self, @p) = @_;
        my ($value, $uiLevel) = rearrange([qw(value uiLevel)], @p);
        if ($self->_uiLevelChecksOut($uiLevel)) {
		$self->{_data} .= $value;
        }
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

=head2 trClass ( )

Sets a CSS class for the Table Row. By default the class is undefined.

=cut

sub trClass {
	my $self = shift;
	my $class = shift;
	$self->{_class} = $class;
}



1;

