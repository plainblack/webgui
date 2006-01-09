package WebGUI::HTMLForm;

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

use CGI::Util qw(rearrange);
use strict qw(vars refs);
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::HTMLForm

=head1 DESCRIPTION

Package that makes HTML forms typed data and significantly reduces the code needed for properties pages in WebGUI.

=head1 SYNOPSIS

 use WebGUI::HTMLForm;
 $f = WebGUI::HTMLForm->new;

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
	if ($_[0] <= $self->session->user->profileField("uiLevel")) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 AUTOLOAD ()
        
Dynamically creates functions on the fly for all the different form control types.

=cut    
        
sub AUTOLOAD {  
        our $AUTOLOAD;
	my $self = shift;
        my $name = ucfirst((split /::/, $AUTOLOAD)[-1]);
        my %params = @_;
	$params{uiLevelOverride} ||= $self->{_uiLevelOverride};
	$params{rowClass} = $self->{_class};
        my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);    
        if ($@) {
                $self->session->errorHandler->error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }       
        my $class = "WebGUI::Form::".$name;
        $self->{_data} .= $class->new(%params)->toHtmlWithWrapper;
}       
        
#-------------------------------------------------------------------

=head2 DESTROY ()

Disposes of the form object.

=cut

sub DESTROY {
	my $self = shift;
	$self = undef;
}


#-------------------------------------------------------------------

=head2 new ( [ action, method, extras, enctype, tableExtras ] )

Constructor.

=head3 action

The Action URL for the form information to be submitted to. This defaults to the current page.

=head3 method

The form's submission method. This defaults to "POST" and probably shouldn't be changed.

=head3 extras

If you want to add anything special to your form like javascript actions, or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" onChange="myForm.submit()"'

=head3 enctype 

The ecapsulation type for this form. This defaults to "multipart/form-data" and should probably never be changed.

=head3 tableExtras

If you want to add anything special to the form's table like a name or stylesheet information, you'd add it in here as follows:

 '"name"="myForm" class="formTable"'

=cut

sub new {
	my ($header, $footer);
	my $class = shift;
	my %param = @_;
	$header = "\n\n".WebGUI::Form::formHeader({
		action=>($param{action} || $param{'-action'}),
		extras=>($param{extras} || $param{'-extras'}),
		method=>($param{method} || $param{'-method'}),
		enctype=>($param{enctype} || $param{'-enctype'})
		});
	$header .= "\n<table ".$param{tableExtras}.'><tbody>';
	$footer = "</tbody></table>\n" ;
	$footer .= WebGUI::Form::formFooter();
        bless {_uiLevelOverride=>$param{uiLevelOverride},  _header => $header, _footer => $footer, _data => ''}, $class;
}

#-------------------------------------------------------------------

=head2 print ( )

Returns the HTML for this form object.

=cut

sub print {
        return $_[0]->{_header}.$_[0]->{_data}.$_[0]->{_footer}.'<script type="text/javascript" src="'.$self->session->config->get("extrasURL").'/wz_tooltip.js"></script>';
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
        my ($output);
        my ($self, @p) = @_;
        my ($value, $uiLevel) = rearrange([qw(value uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$self->{_data} .= $value;
        }
        $self->{_data} .= $output;
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

