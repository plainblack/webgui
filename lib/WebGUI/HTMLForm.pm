package WebGUI::HTMLForm;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

=head1 NAME

 Package WebGUI::HTMLForm

=head1 SYNOPSIS

 use WebGUI::HTMLForm;
 $f = WebGUI::HTMLForm->new;

 $f->checkbox("toggleGadget","Turn Gadgets On?");
 $f->combo("fruit",\%fruit,"Choose a fruit or enter your own.");
 $f->date("endDate","End Date",$endDate);
 $f->email("emailAddress","Email Address");
 $f->file("image","Image to Upload");
 $f->group("groupToPost","Who can post?");
 $f->hidden("wid","55");
 $f->HTMLArea("description","Description");
 $f->integer("size","Size");
 $f->password("identifier","Password");
 $f->phone("cellPhone","Cell Phone");
 $f->raw("text");
 $f->readOnly("34","Page ID");
 $f->select("dayOfWeek",\%days,"Which day?");
 $f->submit;
 $f->text("firstName", "First Name");
 $f->textarea("emailMessage","Email Message");
 $f->url("homepage","Home Page");
 $f->yesNo("happy","Are you happy?");
 $f->zipcode("workZip","Office Zip Code");

 $f->print;
 $f->printRowsOnly;

=head1 DESCRIPTION

 Package that makes HTML forms typed data and significantly
 reduces the code needed for properties pages in WebGUI. 

=head1 METHODS

 These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

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
        return '<tr><td class="formDescription" valign="top">'.$_[0].'</td><td class="tableData">'.$_[1].'</td></tr>';
}

#-------------------------------------------------------------------

=head2 checkbox ( name [ label, checked, subtext, value, extras ] )

 Adds a checkbox row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item checked 

 If you'd like this box to be defaultly checked, set this to "1".

=item subtext
 
 Extra text to describe this form element or to provide special
 instructions.

=item value

 The default value for this form element. Defaults to "1".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub checkbox {
        my ($subtext, $checkedText, $class, $output, $name, $label, $extras, $checked, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $checked = shift;
        $checkedText = ' checked="1"' if ($checked);
	$subtext = shift;
        $value = shift;
	$value = 1 if ($value eq "");
        $extras = shift;
        $output = '<input type="checkbox" name="'.$name.'" value="'.$value.'"'.$checkedText.' '.$extras.'>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 checkList ( name, options [ label, value, vertical, extras, subtext ] )

 Adds a checkbox list row to this form.

=item name

 The name field for this form element.

=item options
 The list of options for this list. Should be passed as a
 hash reference.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. This should be passed
 as an array reference.

=item vertical

 If set to "1" the radio button elements will be laid out
 horizontally. Defaults to "0".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub checkList {
        my ($label, $subtext, $class, $output, $vertical, $value, $key, $item, $name, $options, $extras);
        $class = shift;
        $name = shift;
        $options = shift;
        $label = shift;
        $value = shift;
        $vertical = shift;
        $extras = shift;
        $subtext = shift;
        foreach $key (keys %{$options}) {
                $output .= '<input type="checkbox" name="'.$name.'" value="'.$key.'"';
                foreach $item (@$value) {
                        if ($item eq $key) {
                                $output .= ' checked="1"';
                        }
                }
                $output .= ' '.$extras.'>'.${$options}{$key}.' &nbsp; &nbsp;';
                $output .= '<br>' if ($vertical);
        }
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 combo ( name, options [ label, value, size, multiple, extras, subtext ] )

 Adds a combination select list / text box row to this form. If the
 text box is filled out it will have a value stored in "name"_new
 where name is the first field passed into this method.

=item name

 The name field for this form element.

=item options
 The list of options for this select list. Should be passed as a
 hash reference.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. This should be passed
 as an array reference.

=item size

 The number of characters tall this form element should be. Defaults
 to "1".

=item multiple

 A boolean value for whether this select list should allow multiple
 selections. Defaults to "0".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub combo {
        my ($label, $subtext, $class, $output, $value, $key, $item, $name, $options, $size, $multiple, $extras);
        $class = shift;
        $name = shift;
        $options = shift;
	${$options}{''} = '['.WebGUI::International::get(582).']';
        $label = shift;
        $value = shift;
        $size = shift || 1;
        $multiple = shift;
        $multiple = ' multiple="1"' if ($multiple);
        $extras = shift;
        $subtext = shift;
        $output = '<select name="'.$name.'" size="'.$size.'" '.$extras.$multiple.'>';
	$output .= '<option value="_new_">'.WebGUI::International::get(581).'-&gt;';
        foreach $key (keys %{$options}) {
                $output .= '<option value="'.$key.'"';
                foreach $item (@$value) {
                        if ($item eq $key) {
                                $output .= " selected";
                        }
                }
                $output .= '>'.${$options}{$key};
        }
        $output .= '</select>';
	$size =  $session{setting}{textBoxSize}-5;
        $output .= '<input type="text" name="'.$name.'_new" size="'.$size.'" maxlength="255">';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 date ( name [ label, value, extras, subtext, size ] )

 Adds a date row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default date. Pass as an epoch value. Defaults to today.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub date {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
	$value = epochToSet($value);
        $extras = shift;
	$subtext = shift;
        $size = shift || 10;
        $output = '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="10" '.$extras.'>';
	$output .= '<input type="button" style="font-size: 8pt;" onClick="window.dateField = this.form.'.
		$name.';calendar = window.open(\''.$session{config}{extras}.
		'/calendar.html\',\'cal\',\'WIDTH=200,HEIGHT=250\');return false" value="'.
		WebGUI::International::get(34).'">';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}



#-------------------------------------------------------------------

=head2 email ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds an email address row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub email {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
        $value = _fixQuotes($value);
        $maxLength = shift || 255;
        $extras = shift;
        $subtext = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
	$output = '<script language="javascript" src="'.$session{config}{extras}.'/emailCheck.js"></script>';
        $output .= '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" onBlur="emailCheck(this.value)" '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 file ( name [ label, subtext, extras, size ] )

 Adds a file browse row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub file {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $value);
        $class = shift;
        $name = shift;
        $label = shift;
	$subtext = shift;
        $extras = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
        $output = '<input type="file" name="'.$name.'" size="'.$size.'" '.$extras.'>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
	$class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 group ( name [ label, value, size, multiple, extras, subtext ] )

 Adds a group pull-down to this form. A group pull down
 provides a select list that provides name value pairs for all the
 groups in the WebGUI system.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. This should be passed
 as an array reference. Defaults to "7" (Everyone).

=item size

 How many rows should be displayed at once?

=item multiple

 Set to "1" if multiple groups should be selectable.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub group {
        my ($size, $multiple, %hash, $subtext, $class, $key, $item, $output, $name, $label, $extras, $value);
        $class = shift;
        $name = shift;
        $label = shift;
	$value = shift;
	if ($$value[0] eq "") { #doing long form otherwise arrayRef didn't work
		$value = [7];
	}
	$size = shift || 1;
	$multiple = shift;
	$multiple = ' multiple="1" ' if ($multiple);
        $extras = shift;
	$subtext = shift;
	tie %hash, 'Tie::IxHash';
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
        $output = '<select name="'.$name.'" size="'.$size.'" '.$multiple.$extras.'>';
        foreach $key (keys %hash) {
                $output .= '<option value="'.$key.'"';
		foreach $item (@$value) {
                	if ($item eq $key) {
                        	$output .= " selected";
			}
                }
                $output .= '>'.$hash{$key};
        }
        $output .= '</select>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
	$class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 hidden ( name [ value ] )

 Adds a hidden row to this form.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=cut

sub hidden {
        my ($class, $output, $name, $value);
        $class = shift;
        $name = shift;
	$value = shift;
	$value = _fixQuotes($value);
        $output = '<input type="hidden" name="'.$name.'" value="'.$value.'">';
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 HTMLArea ( name [ label, value, subtext, extras, wrap, rows, columns ] )

 Adds an HTML area row to this form. An HTML area is different than 
 a standard text area in that it provides rich edit functionality
 and some special error trapping for HTML and other special
 characters.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item wrap

 The method for wrapping text in the text area. Defaults to
 "virtual". There should be almost no reason to specify this.

=item rows

 The number of characters tall this form element should be. There
 should be no reason for anyone to specify this.

=item columns

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub HTMLArea {
        my ($subtext, $class, $output, $name, $value, $columns, $rows, $wrap, $extras, $label);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
	$subtext = shift;
        $extras = shift;
        $wrap = shift || "virtual";
        $rows = shift || $session{setting}{textAreaRows} || 5;
        $columns = shift || $session{setting}{textAreaCols} || 50;
        $output = '<script language="JavaScript">function fixChars(element) {element.value = element.value.replace(/~V/mg,"-");}</script>';
        $value =~ s/\</\&lt\;/g;
        $value =~ s/\>/\&gt\;/g;
	if ($session{setting}{richEditor} eq "edit-on-pro") {
		$output .= '<script language="JavaScript">
			var formObj;
			function openEditWindow(obj) {
	                	formObj = obj;
				window.open("'.$session{config}{extras}.'/eopro.html","editWindow","width=720,height=450,resizable=1");
			}
			</script>';
	} else {
	        $output .= '<script language="JavaScript">
        	       var formObj;
	               var extrasDir="'.$session{config}{extras}.'";
        	       function openEditWindow(obj) {
	               formObj = obj;
        	       if (navigator.userAgent.substr(navigator.userAgent.indexOf("MSIE")+5,1)>=5)
                	 window.open("'.$session{config}{extras}.'/ieEdit.html","editWindow","width=490,height=400,resizable=1");
	               else
        	         window.open("'.$session{config}{extras}.'/nonIeEdit.html","editWindow","width=500,height=410");
	               }
        	       function setContent(content) {
                	 formObj.value = content;
	               } </script>';
	}
        $output .= '<input type="button" onClick="openEditWindow(this.form.'.$name.')" value="'.
        	WebGUI::International::get(171).'" style="font-size: 8pt;"><br>';
        $output .= '<textarea name="'.$name.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.$wrap.
                '" onBlur="fixChars(this.form.'.$name.')" '.$extras.'>'.$value.'</textarea>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 integer ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds an integer row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.
 Defaults to 11.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub integer {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift || 0;
        $value = _fixQuotes($value);
        $maxLength = shift || 11;
        $extras = shift;
        $subtext = shift;
        $size = shift || 11;
        $output = '<script language="JavaScript">function doNumCheck(field) {
		var valid = "0123456789"
		var ok = "yes";
		var temp;
		for (var i=0; i<field.value.length; i++) {
			temp = "" + field.value.substring(i, i+1);
			if (valid.indexOf(temp) == "-1") ok = "no";
		}
		if (ok == "no") {
			field.value = field.value.substring(0, (field.value.length) - 1);
		}
		} </script>';
        $output .= '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" onKeyUp="doNumCheck(this.form.'.$name.')" '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 interval ( name [ label, intervalValue, unitsValue, extras, subtext ] )

 Adds a time interval row to this form.

=item name

 The the base name for this form element. This form element actually
 returns two values under different names. They are name_interval and
 name_units.

=item label

 The left column label for this form row.

=item intervalValue

 The default value for interval portion of this form element. Defaults
 to '1'.

=item unitsValue

 The default value for units portion of this form element. Defaults
 to 'seconds'. Possible values are 'seconds', 'minutes', 'hours',
 'days', 'weeks', 'months', and 'years'.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub interval {
        my ($subtext, %units, $item, $key, $class, $output, $name, $label, $extras, $intervalValue, $unitsValue);
        $class = shift;
        $name = shift;
        $label = shift;
        $intervalValue = shift || 1;
        $unitsValue = shift || "seconds";
        $extras = shift;
        $subtext = shift;
        tie %units, 'Tie::IxHash';
	%units = ('seconds'=>WebGUI::International::get(704),
		'minutes'=>WebGUI::International::get(705),
		'hours'=>WebGUI::International::get(706),
		'days'=>WebGUI::International::get(700),
                'weeks'=>WebGUI::International::get(701),
                'months'=>WebGUI::International::get(702),
                'years'=>WebGUI::International::get(703));
        $output = '<script language="JavaScript">function doNumCheck(field) {
                var valid = "0123456789"
                var ok = "yes";
                var temp;
                for (var i=0; i<field.value.length; i++) {
                        temp = "" + field.value.substring(i, i+1);
                        if (valid.indexOf(temp) == "-1") ok = "no";
                }
                if (ok == "no") {
                        field.value = field.value.substring(0, (field.value.length) - 1);
                }
                } </script>';
        $output .= '<input type="text" name="'.$name.'_interval" value="'.$intervalValue.'"
                size="3" maxlength="11" onKeyUp="doNumCheck(this.form.'.$name.')" '.$extras.'>';
        $output .= '<select name="'.$name.'_units">';
        foreach $key (keys %units) {
                $output .= '<option value="'.$key.'"';
                if ($unitsValue eq $key) {
                	$output .= " selected";
                }
                $output .= '>'.$units{$key};
        }
        $output .= '</select>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}


#-------------------------------------------------------------------

=head2 new ( [ noTable, action, method, extras, enctype ] )

 Constructor.

=item noTable

 If this is set to "1" then no table elements will be wrapped around
 each form element. Defaults to "0".

=item action

 The Action URL for the form information to be submitted to. This
 defaults to the current page.

=item method

 The form's submission method. This defaults to "POST" and probably
 shouldn't be changed.

=item extras

 If you want to add anything special to your form like javascript
 actions, or stylesheet information, you'd add it in here as
 follows:

   'name="myForm" onChange="myForm.submit()"'

=item enctype 

 The ecapsulation type for this form. This defaults to
 "multipart/form-data" and should probably never be changed.

=cut

sub new {
        my ($header, $footer, $noTable, $enctype, $class, $method, $action, $extras);
        $class = shift;
	$noTable = shift || 0;
        $action = shift || WebGUI::URL::page();
        $method = shift || "POST";
        $extras = shift;
	$enctype = shift || "multipart/form-data";
	$header = '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$extras.'>';
	$header .= '<table>' unless ($noTable);
	$footer = '</table>' unless ($noTable);
	$footer .= '</form>';
        bless {_noTable => $noTable, _header => $header, _footer => $footer, _data => ''}, $class;
}

#-------------------------------------------------------------------

=head2 password ( name [ label, value, subtext, maxlength, extras, size ] )

 Adds a password row to this form. 

=item name 

 The name field for this form element.

=item label 

 The left column label for this form row.

=item value

 The default value for this form element.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item maxlength 

 The maximum number of characters to allow in this form element.
 Defaults to "35".

=item extras

 If you want to add anything special to this form element like 
 javascript actions, or stylesheet information, you'd add it in 
 here as follows:

   'onChange="this.form.submit()"'

=item size 

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this. Defaults to "30"
 unless overridden in the settings.

=cut

sub password {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
	$class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
	$value = _fixQuotes($value);
	$subtext = shift;
        $maxLength = shift || 35;
        $extras = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
        $output = '<input type="password" name="'.$name.'" value="'.$value.'" size="'.
		$size.'" maxlength="'.$maxLength.'" '.$extras.'>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
	$class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 phone ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds a text row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub phone {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
        $value = _fixQuotes($value);
        $maxLength = shift || 30;
        $extras = shift;
        $subtext = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
        $output .= '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 print ( )

 Returns the HTML for this form object.

=cut

sub print {
        my ($class);
        $class = shift;
        return $class->{_header}.$class->{_data}.$class->{_footer};
}

#-------------------------------------------------------------------

=head2 printRowsOnly ( )

 Returns the HTML for this form object except for the form header
 and footer.

=cut

sub printRowsOnly {
        my ($class);
        $class = shift;
        return $class->{_data};
}

#-------------------------------------------------------------------

=head2 radio ( name [ label, checked, value, subtext, extras ] )

 Adds a radio button row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item checked

 If you'd like this radio button to be defaultly checked, set this to "1".

=item value

 The default value for this form element.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub radio {
        my ($subtext, $checkedText, $class, $output, $name, $label, $extras, $checked, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $checked = shift;
        $checkedText = ' checked="1"' if ($checked);
        $value = shift;
        $subtext = shift;
        $extras = shift;
        $output = '<input type="radio" name="'.$name.'" value="'.$value.'"'.$checkedText.' '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 radioList ( name, options [ label, value, vertical, extras, subtext ] )

 Adds a radio button list row to this form.

=item name

 The name field for this form element.

=item options
 The list of options for this list. Should be passed as a
 hash reference.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. This should be passed
 as an array reference.

=item vertical

 If set to "1" the radio button elements will be laid out 
 horizontally. Defaults to "0".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub radioList {
        my ($label, $subtext, $class, $output, $vertical, $value, $key, $item, $name, $options, $extras);
        $class = shift;
        $name = shift;
        $options = shift;
        $label = shift;
        $value = shift;
	$vertical = shift;
        $extras = shift;
        $subtext = shift;
        foreach $key (keys %{$options}) {
                $output .= '<input type="radio" name="'.$name.'" value="'.$key.'"';
                foreach $item (@$value) {
                        if ($item eq $key) {
                                $output .= ' checked="1"';
                        }
                }
                $output .= ' '.$extras.'>'.${$options}{$key}.' &nbsp; &nbsp;';
		$output .= '<br>' if ($vertical);
        }
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 raw ( value )

 Adds raw data to the form. This is primarily useful with the 
 printRowsOnly method and if you generate your own form elements.

=cut

sub raw {
        my ($class, $output, $value);
        $class = shift;
        $value = shift;
        $class->{_data} .= $value;
}

#-------------------------------------------------------------------

=head2 readOnly ( value [ label, subtext ] )

 Adds a read only row to this form. This is mainly used for
 displaying not editable properties, but it can also be used to
 quickly insert custom form elements.

=item value 

 The read only value.

=item label

 The left column label for this form row.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub readOnly {
        my ($output, $subtext, $class, $label, $value);
        $class = shift;
        $value = shift;
        $label = shift;
	$subtext = shift;
	$output = $value;
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 select ( name, options [ label, value, size, multiple, extras, subtext ] )

 Adds a select list row to this form.

=item name

 The name field for this form element.

=item options 
 The list of options for this select list. Should be passed as a
 hash reference.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. This should be passed
 as an array reference.

=item size 

 The number of characters tall this form element should be. Defaults
 to "1".

=item multiple

 A boolean value for whether this select list should allow multiple
 selections. Defaults to "0".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub select {
	my ($label, $subtext, $class, $output, $value, $key, $item, $name, $options, $size, $multiple, $extras);
	$class = shift;
	$name = shift;
	$options = shift;
	$label = shift;
	$value = shift;
	$size = shift || 1;
	$multiple = shift;
	$multiple = ' multiple="1"' if ($multiple);
	$extras = shift;
	$subtext = shift;
	$output	= '<select name="'.$name.'" size="'.$size.'" '.$extras.$multiple.'>'; 
	foreach $key (keys %{$options}) {
		$output .= '<option value="'.$key.'"';
		foreach $item (@$value) {
			if ($item eq $key) {
				$output .= " selected";
			}
		}
		$output .= '>'.${$options}{$key};
	}
	$output	.= '</select>'; 
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 submit ( value [ label, extras, subtext ] )

 Adds a submit button row to this form.

=item label

 The left column label for this form row.

=item value

 The button text for this submit button. Defaults to "save".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub submit {
        my ($label, $extras, $subtext, $class, $output, $name, $value, $wait);
	$class = shift;
        $value = shift || WebGUI::International::get(62);
        $label = shift;
        $extras = shift;
	$subtext = shift;
        $value = _fixQuotes($value);
	$wait = WebGUI::International::get(452);
        $output = '<input type="submit" value="'.$value.'" onClick="this.value=\''.$wait.'\'" '.$extras.'>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
	$class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 text ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds a text row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub text {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
	$value = _fixQuotes($value);
        $maxLength = shift || 255;
        $extras = shift;
	$subtext = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
        $output = '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$extras.'>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 textarea ( name [ label, value, subtext, extras, wrap, rows, columns ] )

 Adds a text area row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item wrap

 The method for wrapping text in the text area. Defaults to
 "virtual". There should be almost no reason to specify this.

=item rows 

 The number of characters tall this form element should be. There
 should be no reason for anyone to specify this.

=item columns

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.
 
=cut

sub textarea {
        my ($subtext, $class, $output, $name, $value, $columns, $rows, $wrap, $extras, $label);
	$class = shift;
	$name = shift;
	$label = shift;
	$value = shift;
	$subtext = shift;
	$extras = shift;
	$wrap = shift || "virtual";
	$rows = shift || $session{setting}{textAreaRows} || 5;
	$columns = shift || $session{setting}{textAreaCols} || 50;
        $output .= '<textarea name="'.$name.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.
		$wrap.'" '.$extras.'>'.$value.'</textarea>';
	$output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 url ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds a URL row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.
 Defaults to 2048.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub url {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
        $value = _fixQuotes($value);
        $maxLength = shift || 2048;
        $extras = shift;
        $subtext = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
	$output = '<script language="JavaScript">function addHTTP(element) {
		if (!element.value.match(":\/\/") && element.value.match(/\.\w+/)) 
		{ element.value = "http://"+element.value}}</script>';
        $output .= '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" onBlur="addHTTP(this.form.'.$name.')" '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 yesNo ( name [ label, value, extras, subtext ] )

 Adds a yes/no radio menu to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value(s) for this form element. Valid values are "1" 
 and "0". Defaults to "1".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=cut

sub yesNo {
        my ($subtext, $class, $output, $name, $label, $extras, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift || 0;
        $extras = shift;
        $subtext = shift;
        $output = '<input type="radio" name="'.$name.'" value="1"';
	$output .= ' checked="1"' if ($value == 1);
	$output .= $extras.'>'.WebGUI::International::get(138);
	$output .= '&nbsp;&nbsp;&nbsp;';
        $output .= '<input type="radio" name="'.$name.'" value="0"';
        $output .= ' checked="1"' if ($value == 0);
        $output .= $extras.'>'.WebGUI::International::get(139);
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( name [ label, value, maxlength, extras, subtext, size ] )

 Adds a zip code row to this form.

=item name

 The name field for this form element.

=item label

 The left column label for this form row.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item subtext

 Extra text to describe this form element or to provide special
 instructions.

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub zipcode {
        my ($subtext, $class, $output, $name, $label, $extras, $size, $maxLength, $value);
        $class = shift;
        $name = shift;
        $label = shift;
        $value = shift;
        $value = _fixQuotes($value);
        $maxLength = shift || 255;
        $extras = shift;
        $subtext = shift;
        $size = shift || $session{setting}{textBoxSize} || 30;
        $output = '<input type="text" name="'.$name.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$extras.'>';
        $output .= _subtext($subtext);
        $output = _tableFormRow($label,$output) unless ($class->{_noTable});
        $class->{_data} .= $output;
}




1;
