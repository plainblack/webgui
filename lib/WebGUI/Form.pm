package WebGUI::Form;

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

 Package WebGUI::Form

=head1 SYNOPSIS

 use WebGUI::Form;

 WebGUI::Form::checkbox({name=>"whichOne", value=>"red"});
 WebGUI::Form::checkList({name=>"dayOfWeek", options=>\%days});
 WebGUI::Form::combo({name=>"fruit",options=>\%fruit});
 WebGUI::Form::date({name=>"endDate", value=>$endDate});
 WebGUI::Form::email({name=>"emailAddress"});
 WebGUI::Form::file({name=>"image"});
 WebGUI::Form::group({name=>"groupToPost"});
 WebGUI::Form::hidden({name=>"wid",value=>"55"});
 WebGUI::Form::HTMLArea({name=>"description"});
 WebGUI::Form::integer({name=>"size"});
 WebGUI::Form::interval({name=>"timeToLive", interval=>12, units=>"hours"});
 WebGUI::Form::password({name=>"identifier"});
 WebGUI::Form::phone({name=>"cellPhone"});
 WebGUI::Form::radio({name=>"whichOne", value=>"red"});
 WebGUI::Form::radioList({name="dayOfWeek", options=>\%days});
 WebGUI::Form::selectList({name=>"dayOfWeek", options=>\%days, value=>\@array"});
 WebGUI::Form::submit;
 WebGUI::Form::text({name=>"firstName"});
 WebGUI::Form::textarea({name=>"emailMessage"});
 WebGUI::Form::url({name=>"homepage"});
 WebGUI::Form::yesNo({name=>"happy"});
 WebGUI::Form::zipcode({name=>"workZip"});

=head1 DESCRIPTION

 Base forms package. Eliminates some of the normal code work that goes
 along with creating forms. Used by the PowerForm package.

=head1 METHODS

 All of the functions in this package accept the input of a hash
 reference containing the parameters to populate the form element.
 These functions are available from this package:

=cut

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------

=head2 checkbox ( hashRef )

 Returns a checkbox form element.

=item name

 The name field for this form element.

=item checked 

 If you'd like this box to be defaultly checked, set this to "1".

=item value

 The default value for this form element. Defaults to "1".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub checkbox {
        my ($checkedText, $value);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        $value = $_[0]->{value} || 1;
        return '<input type="checkbox" name="'.$_[1]->{name}.'" value="'.$value.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 checkList ( hashRef )

 Returns checkbox list.

=item name

 The name field for this form element.

=item options
 The list of options for this list. Should be passed as a
 hash reference.

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

=cut

sub checkList {
        my ($output, $checked, $key, $item);
        foreach $key (keys %{$_[0]->{options}}) {
		$checked = 0;
		foreach $item (@{$_[0]->{value}}) {
                        if ($item eq $key) {
                                $checked = 1;
                        }
                }
		$output .= checkbox({
			name=>$_[0]->{name},
			value=>$key,
			extras=>$_[0]->{extras},
			checked=>$checked
			});
                $output .= ${$_[0]->{options}}{$key}.' &nbsp; &nbsp;';
                $output .= '<br>' if ($_[0]->{vertical});
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 combo ( hashRef )

 Returns a select list and a text field. If the
 text box is filled out it will have a value stored in "name"_new.

=item name

 The name field for this form element.

=item options
 The list of options for the select list. Should be passed as a
 hash reference.

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

=cut

sub combo {
        my ($output, $size);
	$_[0]->{options}->{''} = '['.WebGUI::International::get(582).']';
	$_[0]->{options}->{_new_} = WebGUI::International::get(581).'-&gt;';
	$output = selectList({
		name=>$_[0]->{name},
		options=>$_[0]->{options},
		value=>$_[0]->{value},
		multiple=>$_[0]->{multiple},
		extras=>$_[0]->{extras}
		});
	$size =  $session{setting}{textBoxSize}-5;
        $output .= text({name=>$_[0]->{name}."_new",size=>$size});
	return $output;
}

#-------------------------------------------------------------------

=head2 date ( hashRef )

 Returns a date field.

=item name

 The name field for this form element.

=item value

 The default date. Pass as an epoch value. Defaults to today.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=item noDate

 By default a date is placed in the "value" field. Set this to "1"
 to turn off the default date.

=cut

sub date {
        my ($subtext, $noDate, $class, $output, $name, $label, $extras, $size, $value);
	$value = epochToSet($_[0]->{value});
        $size = $_[0]->{size} || 10;
	$value = "" if ($_[0]->{noDate});
	$output = text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		maxlength=>10,
		extras=>$_[0]->{extras}
		});
	$output .= '<input type="button" style="font-size: 8pt;" onClick="window.dateField = this.form.'.
		$_[0]->{name}.';calendar = window.open(\''.$session{config}{extras}.
		'/calendar.html\',\'cal\',\'WIDTH=200,HEIGHT=250\');return false" value="'.
		WebGUI::International::get(34).'">';
	return $output;
}



#-------------------------------------------------------------------

=head2 email ( hashRef )

 Adds an email address row to this form.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub email {
        my ($output);
	$output = '<script language="javascript" src="'.$session{config}{extras}.'/emailCheck.js"></script>';
	$output .= text({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>' onChange="emailCheck(this.value)" '.$_[0]->{extras}
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 file ( hashRef )

 Returns a file upload field.

=item name

 The name field for this form element.

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
        my ($size);
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="file" name="'.$_[0]->{name}.'" size="'.$size.'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

 Returns a form header.

=item action

 The form action. Defaults to the current page.

=item method

 The form method. Defaults to "POST".

=item enctype

 The form enctype. Defaults to "multipart/form-data".

=item extras

 If you want to add anything special to the form header like
 javascript actions or stylesheet info, then use this.

=cut

sub formHeader {
	my ($action, $method, $enctype);
        $action = $_[0]->{action} || WebGUI::URL::page();
        $method = $_[0]->{method} || "POST";
        $enctype = $_[0]->{enctype} || "multipart/form-data";
	return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$_[0]->{extras}.'>';

}

#-------------------------------------------------------------------

=head2 group ( hashRef ] )

 Returns a group pull-down field. A group pull down
 provides a select list that provides name value pairs for all the
 groups in the WebGUI system.

=item name

 The name field for this form element.

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

=cut

sub group {
        my (%hash, $value);
	$value = $_[0]->{value};
	if ($$value[0] eq "") { #doing long form otherwise arrayRef didn't work
		$value = [7];
	}
	tie %hash, 'Tie::IxHash';
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$value,
		extras=>$_[0]->{extras},
		size=>$_[0]->{size},
		multiple=>$_[0]->{multiple}
		});
		
}

#-------------------------------------------------------------------

=head2 hidden ( hashRef )

 Returns a hidden field.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=cut

sub hidden {
        return '<input type="hidden" name="'.$_[0]->{name}.'" value="'._fixQuotes($_[0]->{value}).'">'."\n";
}


#-------------------------------------------------------------------

=head2 hiddenList ( hashRef )

 Returns a list of hidden fields. This is primarily to be used by
 the HTMLForm package, but we decided to make it a public method
 in case anybody else had a use for it.

=item name

 The name of this field.

=item options 

 A hash reference where the key is the "name" of the hidden field.

=item value

 An array reference where each value in the array should be a name
 from the hash (if you want it to show up in the hidden list). 

=cut

sub hiddenList {
        my ($output, $key, $item);
        foreach $key (keys %{$_[0]->{options}}) {
                foreach $item (@{$_[0]->{value}}) {
                        if ($item eq $key) {
				$output .= hidden({
					name=>$_[0]->{name},
					value=>$key
					});
                        }
                }
        }
        return $output."\n";
}



#-------------------------------------------------------------------

=head2 HTMLArea ( hashRef )

 Returns an HTML area. An HTML area is different than 
 a standard text area in that it provides rich edit functionality
 and some special error trapping for HTML and other special
 characters.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

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
        my ($output, $value);
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
        $output .= '<input type="button" onClick="openEditWindow(this.form.'.$_[0]->{name}.')" value="'.
        	WebGUI::International::get(171).'" style="font-size: 8pt;"><br>';
	$output .= textarea({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		wrap=>$_[0]->{wrap},
		columns=>$_[0]->{columns},
		rows=>$_[0]->{rows},
		extras=>$_[0]->{extras}.' onBlur="fixChars(this.form.'.$_[0]->{name}.')"'
		});
	return $output;	
}

#-------------------------------------------------------------------

=head2 integer ( hashRef )

 Returns an integer field.

=item name

 The name field for this form element.

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

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub integer {
        my ($output, $size, $value);
        $value = $_[0]->{value} || 0;
        $size = $_[0]->{size} || 11;
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
	$output .= text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doNumCheck(this.form.'.$_[0]->{name}.')"'.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength}
		});
	return $output;
}

#-------------------------------------------------------------------

=head2 interval ( hashRef )

 Adds a time interval row to this form.

=item name

 The the base name for this form element. This form element actually
 returns two values under different names. They are name_interval and
 name_units.

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

=cut

sub interval {
        my (%units, $output, $intervalValue, $unitsValue);
        $intervalValue = $_[0]->{intervalValue} || 1;
        $unitsValue = $_[0]->{unitsValue} || "seconds";
        tie %units, 'Tie::IxHash';
	%units = ('seconds'=>WebGUI::International::get(704),
		'minutes'=>WebGUI::International::get(705),
		'hours'=>WebGUI::International::get(706),
		'days'=>WebGUI::International::get(700),
                'weeks'=>WebGUI::International::get(701),
                'months'=>WebGUI::International::get(702),
                'years'=>WebGUI::International::get(703));
	$output = integer({
		name=>$_[0]->{name}.'_interval',
		value=>$intervalValue,
		extras=>$_[0]->{extras}
		});
	$output .= selectList({
		name=>$_[0]->{name}.'_units',
		value=>[$unitsValue],
		options=>\%units
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 password ( hashRef )

 Returns a password field. 

=item name 

 The name field for this form element.

=item value

 The default value for this form element.

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
        my ($size, $maxLength, $value);
	$value = _fixQuotes($_[0]->{value});
        $maxLength = $_[0]->{maxlength} || 35;
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="password" name="'.$_[0]->{name}.'" value="'.$value.'" size="'.
		$size.'" maxlength="'.$maxLength.'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 phone ( hashRef )

 Returns a phone field.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub phone {
        my ($maxLength);
        $maxLength = shift || 30;
	return text({
		name=>$_[0]->{name},
		maxlength=>$maxLength,
		extras=>$_[0]->{extras},
		value=>$_[0]->{value},
		size=>$_[0]->{size}
		});
}

#-------------------------------------------------------------------

=head2 radio ( hashRef )

 Returns a radio button.

=item name

 The name field for this form element.

=item checked

 If you'd like this radio button to be defaultly checked, set this to "1".

=item value

 The default value for this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub radio {
        my ($checkedText);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        return '<input type="radio" name="'.$_[0]->{name}.'" value="'.$_[0]->{value}.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 radioList ( hashRef )

 Adds a radio button list row to this form.

=item name

 The name field for this form element.

=item options

 The list of options for this list. Should be passed as a
 hash reference.

=item value

 The default value for this form element. 

=item vertical

 If set to "1" the radio button elements will be laid out 
 horizontally. Defaults to "0".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub radioList {
        my ($output, $key, $checked);
        foreach $key (keys %{$_[0]->{options}}) {
                $output .= '<input type="radio" name="'.$_[0]->{name}.'" value="'.$key.'"';
                if ($_[0]->{value} eq $key) {
                        $checked = 1;
                } else {
			$checked = 0;
		}
		$output .= radio({
			name=>$_[0]->{name},
			value=>$key,
			checked=>$checked,
			extras=>$_[0]->{extras}
			});
		$output .= ' '.$_[0]->{options}->{$key};
                $output .= ' &nbsp; &nbsp;';
		$output .= '<br>' if ($_[0]->{vertical});
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 selectList ( hashRef )

 Adds a select list field.

=item name

 The name field for this form element.

=item options 

 The list of options for this select list. Should be passed as a
 hash reference.

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

=cut

sub selectList {
	my ($output, $key, $item, $size, $multiple);
	$size = $_[0]->{size} || 1;
	$multiple = ' multiple="1"' if ($_[0]->{multiple});
	$output	= '<select name="'.$_[0]->{name}.'" size="'.$size.'" '.$_[0]->{extras}.$multiple.'>'; 
	foreach $key (keys %{$_[0]->{options}}) {
		$output .= '<option value="'.$key.'"';
		foreach $item (@{$_[0]->{value}}) {
			if ($item eq $key) {
				$output .= ' selected="1"';
			}
		}
		$output .= ' />'.${$_[0]->{options}}{$key};
	}
	$output	.= '</select>'; 
	return $output;
}

#-------------------------------------------------------------------

=head2 submit ( hashRef )

 Returns a submit button.

=item value

 The button text for this submit button. Defaults to "save".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub submit {
        my ($label, $extras, $subtext, $class, $output, $name, $value, $wait);
        $value = $_[0]->{value} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
	$wait = WebGUI::International::get(452);
        return '<input type="submit" value="'.$value.'" onClick="this.value=\''.$wait.'\'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 text ( hashRef )

 Returns a text input field.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub text {
        my ($size, $maxLength, $value);
	$value = _fixQuotes($_[0]->{value});
        $maxLength = $_[0]->{maxlength} || 255;
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="text" name="'.$_[0]->{name}.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$_[0]->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 textarea ( hashRef )

 Returns a text area field.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

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
        my ($columns, $rows, $wrap);
	$wrap = $_[0]->{virtual} || "virtual";
	$rows = $_[0]->{rows} || $session{setting}{textAreaRows} || 5;
	$columns = $_[0]->{columns} || $session{setting}{textAreaCols} || 50;
        return '<textarea name="'.$_[0]->{name}.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.
		$wrap.'" '.$_[0]->{extras}.'>'.$_[0]->{value}.'</textarea>';
}

#-------------------------------------------------------------------

=head2 url ( hashRef )

 Returns a URL field.

=item name

 The name field for this form element.

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

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub url {
        my ($output, $maxLength);
        $maxLength = $_[0]->{maxlength} || 2048;
	$output = '<script language="JavaScript">function addHTTP(element) {
		if (!element.value.match(":\/\/") && element.value.match(/\.\w+/)) 
		{ element.value = "http://"+element.value}}</script>';
	$output .= text({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras}.' onBlur="addHTTP(this.form.'.$_[0]->{name}.')"',
		size=>$_[0]->{size},
		maxlength=>$maxLength
		});
	return $output;
}

#-------------------------------------------------------------------

=head2 yesNo ( hashRef )

 Returns a yes/no radio field. 

=item name

 The name field for this form element.

=item value

 The default value(s) for this form element. Valid values are "1" 
 and "0". Defaults to "1".

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=cut

sub yesNo {
        my ($subtext, $checkYes, $checkNo, $class, $output, $name, $label, $extras, $value);
	if ($_[0]->{value}) {
		$checkYes = 1;
	} else {
		$checkNo = 1;
	}
	$output = radio({
		checked=>$checkYes,
		name=>$_[0]->{name},
		value=>1,
		extras=>$_[0]->{extras}
		});
	$output .= WebGUI::International::get(138);
	$output .= '&nbsp;&nbsp;&nbsp;';
	$output .= radio({
                checked=>$checkNo,
                name=>$_[0]->{name},
                value=>0,
                extras=>$_[0]->{extras}
                });
        $output .= WebGUI::International::get(139);
	return $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( hashRef )

 Returns a zip code field.

=item name

 The name field for this form element.

=item value

 The default value for this form element.

=item maxlength

 The maximum number of characters to allow in this form element.

=item extras

 If you want to add anything special to this form element like
 javascript actions, or stylesheet information, you'd add it in
 here as follows:

   'onChange="this.form.submit()"'

=item size

 The number of characters wide this form element should be. There
 should be no reason for anyone to specify this.

=cut

sub zipcode {
	#this is here for future expansion
	return text($_[0]);
}




1;


