package WebGUI::HTMLForm;

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
sub _subtext {
	my $output;
        if ($_[0] ne "") {
                $output .= '<span class="formSubtext"> '.$_[0].'</span>';
        } 
	return $output;
}

#-------------------------------------------------------------------
sub _tableFormRow {
	my $self = shift;
	my $label = shift;
	my $formControl = shift;
	my $hoverHelp = shift;
	unless ($self->{_noTable}) {
		my $class = $self->{_class};
		$class = qq| class="$class" | if($class);
		$hoverHelp =~ s/\r/ /g;	
		$hoverHelp =~ s/\n/ /g;	
		$hoverHelp =~ s/&amp;/& amp;/g;	
		$hoverHelp =~ s/&gt;/& gt;/g;	
		$hoverHelp =~ s/&lt;/& lt;/g;	
		$hoverHelp =~ s/&/&amp;/g;	
		$hoverHelp =~ s/>/&gt;/g;	
		$hoverHelp =~ s/</&lt;/g;	
		$hoverHelp =~ s/"/&quot;/g;	
		$hoverHelp =~ s/'/\\'/g;	
		$hoverHelp =~ s/^\s+//;
		my $tooltip = qq|onmouseover="return escape('$hoverHelp')"| if ($hoverHelp);
        	return '<tr'.$class.'><td '.$tooltip.' class="formDescription" valign="top" style="width: 25%;">'.$label.'</td><td class="tableData" style="width: 75%;">'.$formControl."</td></tr>\n";
	} else {
		return $formControl;
	}
}

#-------------------------------------------------------------------
sub _uiLevelChecksOut {
	if ($_[0] <= $session{user}{uiLevel}) {
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
        my $name = (split /::/, $AUTOLOAD)[-1];
        my @params = @_;
        my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);    
        if ($@) {
                WebGUI::ErrorHandler::error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }       
        my $class = "WebGUI::Form::".$name;
        $self->{_data} .= $class->new(@params)->toHtmlWithWrapper;
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
                                                                                                                             
=head2 dynamicField ( fieldType , options )
                                                                                                                             
Adds a dynamic field to this form. This is primarily useful for building dynamic form fields.
Because of the dynamic nature of this field, it supports only the -option=>value 
way of specifying parameters.
                                                                                                                             
=head3 fieldType

The field type to use. The field name is the name of the method from this forms package.

=head3 options

The field options. See the documentation for the desired field for more information.
                                                                                                                             
=cut

sub dynamicField {
	my $self = shift;
	my $fieldType = shift;
	my %param = @_;
	foreach my $key (keys %param) {		# strip off the leading minus sign in each parameter key.
		$key=~/^-(.*)$/;
		$param{$1} = $param{$key};
		delete $param{$key};
	}
	my $output;
        if (_uiLevelChecksOut($param{uiLevel})) {
		$output = WebGUI::Form::dynamicField($fieldType, \%param);
                $output .= _subtext($param{subtext});
                $output = $self->_tableFormRow($param{label},$output,$param{hoverHelp});
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$param{name},
                        "value"=>$param{value},
			"defaultValue"=>$param{defaultValue}
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 file ( name [, label, subtext, extras, size, uiLevel ] )

Adds a file browse row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 hoverHelp

A string of text or HTML to be displayed when a user's mouse hover's over a field label. It is meant to describe to the user what to use the field for.

=cut

sub file {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $subtext, $extras, $size, $uiLevel,$hoverHelp) =
                rearrange([qw(name label subtext extras size uiLevel hoverHelp)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::file({
                        "name"=>$name,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output,$hoverHelp);
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 new ( [ noTable, action, method, extras, enctype, tableExtras ] )

Constructor.

=head3 noTable

If this is set to "1" then no table elements will be wrapped around each form element. Defaults to "0".

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
        my ($self, @p) = @_;
        my ($noTable, $action, $method, $extras, $enctype, $tableExtras) =
                rearrange([qw(noTable action method extras enctype tableExtras)], @p);
	$noTable = $noTable || 0;
	$header = "\n\n".WebGUI::Form::formHeader({
		"action"=>$action,
		"extras"=>$extras,
		"method"=>$method,
		"enctype"=>$enctype
		});
	$header .= "\n<table ".$tableExtras.'><tbody>' unless ($noTable);
	$footer = "</tbody></table>\n" unless ($noTable);
	$footer .= WebGUI::Form::formFooter();
        bless {_noTable => $noTable, _header => $header, _footer => $footer, _data => ''}, $self;
}

#-------------------------------------------------------------------

=head2 print ( )

Returns the HTML for this form object.

=cut

sub print {
        return $_[0]->{_header}.$_[0]->{_data}.$_[0]->{_footer}.'<script language="JavaScript" type="text/javascript" src="'.$session{config}{extrasURL}.'/wz_tooltip.js"></script>';
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

