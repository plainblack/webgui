package WebGUI::HTMLForm;

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

 $f->button(
	-value=>"Click me!",
	-extras=>qq|onClick="alert('Aaaaaaaggggghh!!!!')"|
	);
 $f->checkbox(
	-name=>"whichOne",
	-label=>"Is red your favorite?",
	-value=>"red"
	);
 $f->checkList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->combo(
	-name=>"fruit",
	-options=>\%fruit,
	-label=>"Choose a fruit or enter your own."
	);
 $f->contentType(
	-name=>"contentType"
	);
 $f->date(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
 $f->dateTime(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
$f->dynamicField(text,
        -name=>"firstName",
        -label=>"First Name"
        );
 $f->email(
	-name=>"emailAddress",
	-label=>"Email Address"
	);
 $f->fieldType(
	-name=>"dataType",
	-label=>"Type of Field"
	);
 $f->file(
	-name=>"image",
	-label=>"Image to Upload"
	);
 $f->filterContent(
	-name=>"filterThisContent",
	-label=>"Filter This Content"
	);
 $f->float(
	-name=>"distance",
	-label=>"5.1"
	);
 $f->group(
	-name=>"groupToPost",
	-label=>"Who can post?"
	);
 $f->hidden(
	-name=>"wid",
	-value=>"55"
	);
 $f->HTMLArea(
	-name=>"description",
	-label=>"Description"
	);
 $f->integer(
	-name=>"size",
	-label=>"Size"
	);
 $f->interval(
	-name=>"timeToLive",
	-label=>"How long should this last?",
	-intervalValue=>12,
	-unitsValue=>"hours"
	);
 $f->password(
	-name=>"identifier",
	-label=>"Password"
	);
 $f->phone(
	-name=>"cellPhone",
	-label=>"Cell Phone"
	);
 $f->radio(
	-name=>"whichOne",
	-label=>"Is red your favorite?",
	-value=>"red"
	);
 $f->radioList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->raw(
	-value=>"text"
	);
 $f->readOnly(
	-value=>"34",
	-label=>"Page ID"
	);
 $f->selectList(
	-name=>"dayOfWeek",
	-options=>\%days,
	-label=>"Which day?"
	);
 $f->submit;
 $f->template(
	-name=>"templateId",
	-label=>"Page Template"
	);
 $f->text(
	-name=>"firstName", 
	-label=>"First Name"
	);
 $f->textarea(
	-name=>"emailMessage",
	-label=>"Email Message"
	);
 $f->timeField(
	-name=>"endDate",
	-label=>"End Date",
	-value=>$endDate
	);
 $f->url(
	-name=>"homepage",
	-label=>"Home Page"
	);
 $f->whatNext(
	-options=>\%options
	);
 $f->yesNo(
	-name=>"happy",
	-label=>"Are you happy?"
	);
 $f->zipcode(
	-name=>"workZip",
	-label=>"Office Zip Code"
	);

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
	unless ($_[0]->{_noTable}) {
		my $class = $_[0]->{_class};
		$class = qq| class="$class" | if($class);
        	return '<tr'.$class.'><td class="formDescription" valign="top">'.$_[1].'</td><td class="tableData">'.$_[2]."</td></tr>\n";
	} else {
		return $_[2];
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

=head2 button ( value [, label, extras, subtext, defaultValue ] )

Adds a button row to this form. Use it in combination with scripting code to make the button perform an action.

=head3 value

The button text for this button. 

=head3 label

The left column label for this form row.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onClick="alert(\'Hello there!\')"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 defaultValue

If no value is specified, a default value to use. Defaults to "save".

=cut

sub button {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $label, $extras, $subtext, $defaultValue) = rearrange([qw(value label extras subtext defaultValue)], @p);
        $output = WebGUI::Form::button({
                "value"=>$value,
                "extras"=>$extras,
		"defaultValue"=>$defaultValue
                });
        $output .= _subtext($subtext);
        $output = $self->_tableFormRow($label,$output);
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 checkbox ( name [, label, checked, subtext, value, extras, uiLevel, defaultValue ] )

Adds a checkbox row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 checked 

If you'd like this box to be defaultly checked, set this to "1".

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no value is specified, we'll use this. Defaults to "1".

=cut

sub checkbox {
	my ($output);
	my ($self, @p) = @_;
    	my ($name, $label, $checked, $subtext, $value, $extras, $uiLevel, $defaultValue) = 
		rearrange([qw(name label checked subtext value extras uiLevel defaultValue)], @p);
	if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::checkbox({
			"name"=>$name,
			"value"=>$value,
			"checked"=>$checked,
			"extras"=>$extras,
			"defaultValue"=>$defaultValue
			});
		$output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
	} else {
		if ($checked) {
			$output = WebGUI::Form::hidden({
				"name"=>$name,
				"value"=>$value,
				"defaultValue"=>$defaultValue
				});
		}
	}
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 checkList ( name, options [ , label, value, vertical, extras, subtext, uiLevel, defaultValue ] )

Adds a checkbox list row to this form.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 label

The left column label for this form row.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is passed, use this. Should be passed as an array reference.

=cut

sub checkList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $vertical, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name options label value vertical extras subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::checkList({
			"name"=>$name,
			"options"=>$options,
			"value"=>$value,
			"vertical"=>$vertical,
			"extras"=>$extras
			});
        	$output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
	} else {
		$output = WebGUI::Form::hiddenList({
			"name"=>$name,
			"options"=>$options,
			"value"=>$value,
			"defaultValue"=>$defaultValue
			});
	}
        $self->{_data} .= $output;
}

sub codearea {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $extras, $wrap, $rows, $columns, $uiLevel, $defaultValue) =
                rearrange([qw(name label value subtext extras wrap rows columns uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::codearea({
                        "name"=>$name,
                        "value"=>$value,
                        "wrap"=>$wrap,
                        "columns"=>$columns,
                        "rows"=>$rows,
                        "extras"=>$extras,
			defaultValue =>$defaultValue
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 combo ( name, options [, label, value, size, multiple, extras, subtext, uiLevel, defaultValue ] )

Adds a combination select list / text box row to this form. If the text box is filled out it will have a value stored in "name"_new where name is the first field passed into this method.

=head3 name

The name field for this form element.

=head3 options

The list of options for this select list. Should be passed as a hash reference.

=head3 label

The left column label for this form row.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is present, will use this. Should be passed as an array reference.

=cut

sub combo {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name options label value size multiple extras subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::combo({
                        "name"=>$name,
			"options"=>$options,
                        "value"=>$value,
                        "size"=>$size,
			"multiple"=>$multiple,
                        "extras"=>$extras,
			"defaultValue"=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
			"defaultValue",$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 contentType ( name, types [, label, value, extras, subtext, uiLevel, defaultValue ] )

Adds a content type select list field to this form.

=head3 name

The name field for this form element.

=head3 types

An array reference of field types to be displayed. The valid types are "code", "mixed", "html", and "text". Defaults to all types.

=head3 label

The left column label for this form row. Defaults to "Content Type".

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "3".

=head3 defaultValue

When no value is specified, we'll use this.

=cut

sub contentType {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $types, $label, $value, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name types label value extras subtext uiLevel defaultValue)], @p);
	$uiLevel = 3 if ($uiLevel eq "");
        if (_uiLevelChecksOut($uiLevel)) {
		$label = WebGUI::International::get(1007) unless ($label);
                $output = WebGUI::Form::fieldType({
                        "name"=>$name,
                        "types"=>$types,
                        "value"=>$value,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 databaseLink (  [name , value, label, afterEdit, extras, uiLevel, defaultValue ] )

Adds a database link select list to the form.

=head3 name

The name of this form element.

=head3 value

The default value for this form element.

=head3 label

The left column label for this form row. Defaults to "Database Link".

=head3 afterEdit

A URL that will be acted upon after editing a database link. Typically there is a link next to the select list that reads "Edit this database link" and this is the URL to go to after editing is complete.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "5".

=head3 defaultValue

When no other value is passed, we'll use this.

=cut

sub databaseLink {
        my ($output, $subtext);
        my ($self, @p) = @_;
        my ($name, $value, $label, $afterEdit, $extras, $uiLevel, $defaultValue) = 
		rearrange([qw(name value label afterEdit extras uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = $label || WebGUI::International::get(1075);
		if (WebGUI::Grouping::isInGroup(3)) {
			if ($afterEdit) {
                                $subtext = editIcon("op=editDatabaseLink&amp;lid=".$value."&amp;afterEdit=".WebGUI::URL::escape($afterEdit));
                        }
                        $subtext .= manageIcon("op=listDatabaseLinks");
		}
        	$output = WebGUI::Form::databaseLink({
                	"name"=>$name,
                	"value"=>$value,
                	"extras"=>$extras,
			"defaultValue"=>$defaultValue
                	});
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			"defaultValue"=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}



#-------------------------------------------------------------------

=head2 date ( name [, label, value, extras, subtext, size, noDate, uiLevel, defaultValue ] )

Adds a date row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default date. Pass as an epoch value. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 noDate

By default a date is placed in the "value" field. Set this to "1" to turn off the default date.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no value is specified, use this. Defaults to today.

=cut

sub date {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $size, $noDate, $uiLevel, $defaultValue) =
                rearrange([qw(name label value extras subtext size noDate uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::date({
                        "name"=>$name,
                        "value"=>$value,
                        "noDate"=>$noDate,
                        "size"=>$size,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>epochToSet($value),
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}



#-------------------------------------------------------------------

=head2 dateTime ( name [, label, value, subtext, uiLevel, dateExtras, timeExtras, defaultValue ] )

Adds a date time row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default date and time. Pass as an epoch value. Defaults to today and now.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 extras 

Extra parameters such as javascript or style sheet information that you wish to add to the form element.

=head3 defaultValue

=cut

sub dateTime {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $uiLevel, $extras, $defaultValue) = 
		rearrange([qw(name label value subtext uiLevel extras defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::dateTime({
                        "name"=>$name,
                        "value"=>$value,
			"extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>epochToSet($value,1),
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
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
                $output = $self->_tableFormRow($param{label},$output);
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

=head2 email ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds an email address row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is specified, this will be used.

=cut

sub email {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::email({
                        "name"=>$name,
                        "value"=>$value,
                        "maxlength"=>$maxlength,
                        "size"=>$size,
                        "extras"=>$extras,
			"defaultValue" => $defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 fieldType ( name, types [, label, value, size, extras, subtext, uiLevel, defaultValue ] )

Adds a field type select list field to this form. This is primarily useful for building dynamic form builders.

=head3 name

The name field for this form element.

=head3 types

An array reference of field types to be displayed. The field names are the names of the methods from this forms package. Note that not all field types are supported. Defaults to all types.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is specified, this will be used.

=cut

sub fieldType {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $types, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name types label value size multiple extras subtext uiLevel $defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::fieldType({
                        "name"=>$name,
                        "types"=>$types,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "size"=>$size,
                        "extras"=>$extras,
			"defaultValue"=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			"defaultValue"=>$defaultValue
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

=cut

sub file {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $subtext, $extras, $size, $uiLevel) =
                rearrange([qw(name label subtext extras size uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::file({
                        "name"=>$name,
                        "size"=>$size,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 filterContent ( [ name, label, value, extras, subtext, uiLevel, defaultValue ] )

Adds a content filter select list to the form for use with the WebGUI::HTML::filter() function.

=head3 name

The name field for this form element. Defaults to "filterContent".

=head3 label

The left column label for this form row. Defaults to "Filter Content" (internationalized).

=head3 value

The default value for this form element. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here
as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is present, this will be used.

=cut

sub filterContent {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name label value extras subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = WebGUI::International::get(418) if ($label eq "");
                $output = WebGUI::Form::filterContent({
                        "name"=>$name,
                        "value"=>$value,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 float ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds an integer row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no other value is specified, this will be used.

=cut

sub float {
	my ($output);
	my ($self, @p) = @_;
	my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
		rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
	if (_uiLevelChecksOut($uiLevel)) {
		$output = WebGUI::Form::float({
			"name"=>$name,
			"value"=>$value,
			"maxlength"=>$maxlength,
			"size"=>$size,
			"extras"=>$extras,
			defaultValue=>$defaultValue
			});
		$output .= _subtext($subtext);
		$output = $self->_tableFormRow($label,$output);
	} else {
		$output = WebGUI::Form::hidden({
			"name"=>$name,
			"value"=>$value,
			defaultValue=>$defaultValue
			});
	}
	$self->{_data} .= $output;
} 



#-------------------------------------------------------------------

=head2 group ( name [, label, value, size, multiple, extras, subtext, uiLevel, excludeGroups, defaultValue ] )

Adds a group pull-down to this form. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size

How many rows should be displayed at once?

=head3 multiple

Set to "1" if multiple groups should be selectable.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 excludeGroups

An array reference containing a list of groups to exclude from the list.

=head3 defaultValue

When no other value is specified, this will be used. Should be passed as an array reference. Defaults to "7" (Everyone).

=cut

sub group {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel, $excludeGroups, $defaultValue) =
                rearrange([qw(name label value size multiple extras subtext uiLevel excludeGroups defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		if (WebGUI::Grouping::isInGroup(3)) {
			$subtext = manageIcon("op=listGroups").$subtext;
		}
                $output = WebGUI::Form::group({
                        "name"=>$name,
                        "size"=>$size,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "extras"=>$extras,
			excludeGroups=>$excludeGroups,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
		my $hashRef = WebGUI::SQL->buildHashRef("select groupId,groupName from groups");
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$hashRef,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 hidden ( name, value [, defaultValue ] )

Adds a hidden row to this form.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 defaultValue

If no value is specified, this will be used instead.

=cut

sub hidden {
        my ($self, @p) = @_;
        my ($name, $value, $defaultValue) = rearrange([qw(name value defaultValue)], @p);
        $self->{_data} .= WebGUI::Form::hidden({
		"name"=>$name,
		"value"=>$value,
		defaultValue=>$defaultValue
		});
}

#-------------------------------------------------------------------

=head2 HTMLArea ( name [, label, value, subtext, extras, wrap, rows, columns, uiLevel, defaultValue ] )

Adds an HTML area row to this form. An HTML area is different than a standard text area in that it provides rich edit functionality and some special error trapping for HTML and other special characters.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, this will be used.

=cut

sub HTMLArea {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $extras, $wrap, $rows, $columns, $uiLevel, $defaultValue) =
                rearrange([qw(name label value subtext extras wrap rows columns uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::HTMLArea({
                        "name"=>$name,
                        "value"=>$value,
                        "wrap"=>$wrap,
                        "columns"=>$columns,
                        "rows"=>$rows,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,	
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 integer ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds an integer row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, this will be used.

=cut

sub integer {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::integer({
                        "name"=>$name,
                        "value"=>$value,
                        "maxlength"=>$maxlength,
                        "size"=>$size,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			"defaultValue"=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 interval ( name [, label, value, extras, subtext, uiLevel, defaultValue ] )

Adds a time interval row to this form.

=head3 name

The the base name for this form element. This form element actually returns two values under different names. They are name_interval and name_units.

=head3 label

The left column label for this form row.

=head3 value 

The number of seconds in this interval.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no value is specified, we'll use this instead. Defaults to 1.

=cut

sub interval {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name label value extras subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::interval({
                        "name"=>$name,
                        "value"=>$value,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
		my ($interval, $units) = WebGUI::DateTime::secondsToInterval($value||$defaultValue||1);
                $output = WebGUI::Form::hidden({
                        "name"=>$name.'_interval',
                        "value"=>$interval
                        });
                $output .= WebGUI::Form::hidden({
                        "name"=>$name.'_units',
                        "value"=>$units
                        });
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

=head2 password ( name [, label, value, subtext, maxlength, extras, size, uiLevel, defaultValue ] )

Adds a password row to this form. 

=head3 name 

The name field for this form element.

=head3 label 

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 maxlength 

The maximum number of characters to allow in this form element.  Defaults to "35".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size 

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to "30" unless overridden in the settings.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

When no value is specified, this will be used instead.

=cut

sub password {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $maxlength, $extras, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value subtext maxlength extras size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::password({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 phone ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds a text row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, we'll use this instead.

=cut

sub phone {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::phone({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 print ( )

Returns the HTML for this form object.

=cut

sub print {
        return $_[0]->{_header}.$_[0]->{_data}.$_[0]->{_footer};
}

#-------------------------------------------------------------------

=head2 printRowsOnly ( )

Returns the HTML for this form object except for the form header and footer.

=cut

sub printRowsOnly {
        return $_[0]->{_data};
}

#-------------------------------------------------------------------

=head2 radio ( name [, label, checked, value, subtext, extras, uiLevel, defaultValue ] )

Adds a radio button row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 checked

If you'd like this radio button to be defaultly checked, set this to "1".

=head3 value

The default value for this form element.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, we'll use this instead.

=cut

sub radio {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $checked, $value, $subtext, $extras, $uiLevel, $defaultValue) =
                rearrange([qw(name label checked value subtext extras uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::radio({
                        "name"=>$name,
                        "value"=>$value,
                        "checked"=>$checked,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
		if ($checked) {
                	$output = WebGUI::Form::hidden({
                        	"name"=>$name,
                        	"value"=>$value,
				defaultValue=>$defaultValue
                        	});
		}
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 radioList ( name, options [, label, value, vertical, extras, subtext, uiLevel, defaultValue ] )

Adds a radio button list row to this form.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element. Should be passed as a scalar.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no other value is specified, we'll use this instead.

=cut

sub radioList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $vertical, $extras, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(name options label value vertical extras subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::radioList({
                        "name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
                        "vertical"=>$vertical,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
			"name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
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

=head2 readOnly ( value [, label, subtext, uiLevel, defaultValue ] )

Adds a read only row to this form. This is mainly used for displaying not editable properties, but it can also be used to quickly insert custom form elements.

=head3 value 

The read only value.

=head3 label

The left column label for this form row.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, we'll use this.

=cut

sub readOnly {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $label, $subtext, $uiLevel, $defaultValue) =
                rearrange([qw(value label subtext uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = $value || $defaultValue;
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 selectList ( name, options [, label, value, size, multiple, extras, subtext, uiLevel, sortByValue, defaultValue ] )

Adds a select list row to this form.

=head3 name

The name field for this form element.

=head3 options 

The list of options for this select list. Should be passed as a hash reference.

=head3 label

The left column label for this form row.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size 

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 sortByValue

A boolean value for whether the values in the options hash should be sorted.

=head3 defaultValue

If no value is specified, this will be used. Pass as an array reference.

=cut

sub selectList {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $options, $label, $value, $size, $multiple, $extras, $subtext, $uiLevel, $sortByValue, $defaultValue) =
                rearrange([qw(name options label value size multiple extras subtext uiLevel sortByValue defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::selectList({
                        "name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
                        "multiple"=>$multiple,
                        "size"=>$size,
                        "extras"=>$extras,
			"sortByValue"=>$sortByValue,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hiddenList({
			"name"=>$name,
                        "options"=>$options,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 submit ( value [ label, extras, subtext, defaultValue ] )

Adds a submit button row to this form.

=head3 value

The button text for this submit button.

=head3 label

The left column label for this form row.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 defaultValue

If no value is specified, this will be used. Defaults to "save".

=cut

sub submit {
        my ($output);
        my ($self, @p) = @_;
        my ($value, $label, $extras, $subtext, $defaultValue) = rearrange([qw(value label extras subtext defaultValue)], @p);
        $output = WebGUI::Form::submit({
                "value"=>$value,
                "extras"=>$extras,
		defaultValue=>$defaultValue
                });
        $output .= _subtext($subtext);
        $output = $self->_tableFormRow($label,$output);
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 template ( name [, value, label, namespace, afterEdit, extras, uiLevel, defaultValue, subtext ] )

Adds a template select list to the form.

=head3 name

The name of this form element.

=head3 value

The default value for this form element.

=head3 label

The left column label for this form row.

=head3 namespace

The namespace (or type) of templates to show in this list. 

=head3 afterEdit

A URL that will be acted upon after editing a template. Typically there is a link next to the select list that reads "Edit this template" and this is the URL to go to after editing is complete.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

If no value is specified, this will be used. 

=head3 subtext

Any extra information you want to include after the field.

=cut

sub template {
        my ($output, $buttons);
        my ($self, @p) = @_;
        my ($name, $value, $label, $namespace, $afterEdit, $extras, $uiLevel, $defaultValue, $subtext) = 
		rearrange([qw(name value label namespace afterEdit extras uiLevel defaultValue subtext)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
		$label = $label || WebGUI::International::get(356);
		if (WebGUI::Grouping::isInGroup(8)) {
        		if ($afterEdit) {
                		$buttons = editIcon("op=editTemplate&tid=".$value."&namespace=".$namespace."&afterEdit=".WebGUI::URL::escape($afterEdit));
        		}
        		$buttons .= manageIcon("op=listTemplates&namespace=$namespace");
		}
        	$output = WebGUI::Form::template({
                	"name"=>$name,
                	"value"=>$value,
                	"namespace"=>$namespace,
                	"extras"=>$extras,
			defaultValue=>$defaultValue
                	});
                $output .= _subtext($buttons.$subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 text ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds a text row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

This will be used if no value is specified.

=cut

sub text {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::text({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 textarea ( name [, label, value, subtext, extras, wrap, rows, columns, uiLevel, defaultValue ] )

Adds a text area row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows 

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

This will be used if no value is specified.

=cut

sub textarea {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $subtext, $extras, $wrap, $rows, $columns, $uiLevel, $defaultValue) =
                rearrange([qw(name label value subtext extras wrap rows columns uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::textarea({
                        "name"=>$name,
                        "value"=>$value,
                        "wrap"=>$wrap,
                        "columns"=>$columns,
                        "rows"=>$rows,
                        "extras"=>$extras,
			defaultValue =>$defaultValue
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 timeField ( name [, label, value, extras, subtext, size, noDate, uiLevel, defaultValue ] )

Adds a date row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default time. Pass as a number of seconds. Defaults to 0.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

This will be used if no value is specified.

=cut

sub timeField {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::time({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>secondsToTime($value),
			defaultValue=>$defaultValue
                        });
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

#-------------------------------------------------------------------

=head2 url ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds a URL row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 2048.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

=cut

sub url {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::url({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 whatNext ( options [, value, name, label, subtext, uiLevel, extras, defaultValue ] )

Adds a "What next?" select list to this form for use with chained action forms in WebGUI.

=head3 options

A hash reference of the possible actions that could happen next.

=head3 value

The selected element in this list.

=head3 name

The name field for this form element. Defaults to "proceed".

=head3 label

The left column label for this form row.

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

Used if value is not specified. 

=cut

sub whatNext {
        my ($output);
        my ($self, @p) = @_;
        my ($options, $value, $name, $label, $subtext, $uiLevel, $extras, $defaultValue) =
                rearrange([qw(options value name label subtext uiLevel extras defaultValue)], @p);
	$uiLevel |= 1;
	$label |= WebGUI::International::get(744);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::whatNext({
                        "name"=>$name,
			"options"=>$options,
                        "value"=>$value,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
                $output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 yesNo ( name [, label, value, extras, subtext, uiLevel, defaultValue ] )

Adds a yes/no radio menu to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value(s) for this form element. Valid values are "1" and "0". 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

This will be used if value is not specified. Defaults to 1.
=cut

sub yesNo {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $extras, $subtext, $uiLevel) =
                rearrange([qw(name label value extras subtext uiLevel)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::yesNo({
                        "name"=>$name,
                        "value"=>$value,
                        "extras"=>$extras
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
		$value = 0 unless ($value);
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value
                        });
        }
        $self->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( name [, label, value, maxlength, extras, subtext, size, uiLevel, defaultValue ] )

Adds a zip code row to this form.

=head3 name

The name field for this form element.

=head3 label

The left column label for this form row.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 subtext

Extra text to describe this form element or to provide special instructions.

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 uiLevel

The UI level for this field. See the WebGUI developer's site for details. Defaults to "0".

=head3 defaultValue

Used if value not specified. 

=cut

sub zipcode {
        my ($output);
        my ($self, @p) = @_;
        my ($name, $label, $value, $maxlength, $extras, $subtext, $size, $uiLevel, $defaultValue) =
                rearrange([qw(name label value maxlength extras subtext size uiLevel defaultValue)], @p);
        if (_uiLevelChecksOut($uiLevel)) {
                $output = WebGUI::Form::zipcode({
                        "name"=>$name,
                        "value"=>$value,
                        "size"=>$size,
                        "maxlength"=>$maxlength,
                        "extras"=>$extras,
			defaultValue=>$defaultValue
                        });
                $output .= _subtext($subtext);
        	$output = $self->_tableFormRow($label,$output);
        } else {
                $output = WebGUI::Form::hidden({
                        "name"=>$name,
                        "value"=>$value,
			defaultValue=>$defaultValue
                        });
        }
        $self->{_data} .= $output;
}




1;

