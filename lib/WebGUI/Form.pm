package WebGUI::Form;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use HTTP::BrowserDetect;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Form

=head1 DESCRIPTION

Base forms package. Eliminates some of the normal code work that goes along with creating forms. Used by the HTMLForm package.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::checkbox({name=>"whichOne", value=>"red"});
 $html = WebGUI::Form::checkList({name=>"dayOfWeek", options=>\%days});
 $html = WebGUI::Form::combo({name=>"fruit",options=>\%fruit});
 $html = WebGUI::Form::contentType({name=>"contentType");
 $html = WebGUI::Form::date({name=>"endDate", value=>$endDate});
 $html = WebGUI::Form::dateTime({name=>"begin", value=>$begin});
 $html = WebGUI::Form::email({name=>"emailAddress"});
 $html = WebGUI::Form::fieldType({name=>"fieldType");
 $html = WebGUI::Form::file({name=>"image"});
 $html = WebGUI::Form::formHeader();
 $html = WebGUI::Form::filterContent({value=>"javascript"});
 $html = WebGUI::Form::float({name=>"distance"});
 $html = WebGUI::Form::group({name=>"groupToPost"});
 $html = WebGUI::Form::hidden({name=>"wid",value=>"55"});
 $html = WebGUI::Form::hiddenList({name=>"wid",value=>"55",options=>\%options});
 $html = WebGUI::Form::HTMLArea({name=>"description"});
 $html = WebGUI::Form::integer({name=>"size"});
 $html = WebGUI::Form::interval({name=>"timeToLive", interval=>12, units=>"hours"});
 $html = WebGUI::Form::password({name=>"identifier"});
 $html = WebGUI::Form::phone({name=>"cellPhone"});
 $html = WebGUI::Form::radio({name=>"whichOne", value=>"red"});
 $html = WebGUI::Form::radioList({name="dayOfWeek", options=>\%days});
 $html = WebGUI::Form::selectList({name=>"dayOfWeek", options=>\%days, value=>\@array"});
 $html = WebGUI::Form::submit();
 $html = WebGUI::Form::template({name=>"templateId"});
 $html = WebGUI::Form::text({name=>"firstName"});
 $html = WebGUI::Form::textarea({name=>"emailMessage"});
 $html = WebGUI::Form::timeField({name=>"begin", value=>$begin});
 $html = WebGUI::Form::url({name=>"homepage"});
 $html = WebGUI::Form::yesNo({name=>"happy"});
 $html = WebGUI::Form::zipcode({name=>"workZip"});

=head1 METHODS 

All of the functions in this package accept the input of a hash reference containing the parameters to populate the form element. These functions are available from this package:

=cut

#-------------------------------------------------------------------
sub _cssFile {
        return '<link rel="stylesheet" type="text/css" media="all" href="'.$session{config}{extrasURL}.'/'.$_[0].'" />'."\n";
}

#-------------------------------------------------------------------
sub _fixMacros {
	my $value = shift;
	$value =~ s/\^/\&\#94\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------
sub _fixSpecialCharacters {
	my $value = shift;
	$value =~ s/\&/\&amp\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _fixTags {
	my $value = shift;
	$value =~ s/\</\&lt\;/g;
        $value =~ s/\>/\&gt\;/g;
	return $value;
}

#-------------------------------------------------------------------
sub _javascriptFile {
        return '<script language="JavaScript" src="'.$session{config}{extrasURL}.'/'.$_[0].'"></script>'."\n";
}

#-------------------------------------------------------------------

=head2 checkbox ( hashRef )

Returns a checkbox form element.

=over

=item name

The name field for this form element.

=item checked 

If you'd like this box to be defaultly checked, set this to "1".

=item value

The default value for this form element. Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub checkbox {
        my ($checkedText, $value);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        $value = $_[0]->{value} || 1;
        return '<input type="checkbox" name="'.$_[0]->{name}.'" value="'.$value.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 checkList ( hashRef )

Returns checkbox list.

=over

=item name

The name field for this form element.

=item options

The list of options for this list. Should be passed as a hash reference.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

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
                $output .= ${$_[0]->{options}}{$key};
		if ($_[0]->{vertical}) {
			$output .= "<br />\n";
		} else {
			$output .= " &nbsp; &nbsp;\n";
		}
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 combo ( hashRef )

Returns a select list and a text field. If the text box is filled out it will have a value stored in "name"_new.

=over

=item name

 The name field for this form element.

=item options

The list of options for the select list. Should be passed as a hash reference.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item size

The number of characters tall this form element should be. Defaults to "1".

=item multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

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

=head2 contentType ( hashRef )

Returns a content type select list field. This is usually used to help tell WebGUI how to treat posted content.

=over

=item name

The name field for this form element.

=item types 

An array reference of field types to be displayed. The types are "mixed", "html", "code", and "text".  Defaults to all.

=item value

The default value for this form element. Defaults to "mixed".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub contentType {
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) It was done this way because a huge
	# if/elsif construct executes much more quickly than a bunch of
	# unnecessary database hits.
	my @types = qw(mixed html code text);
	$_[0]->{types} = \@types unless ($_[0]->{types});
	foreach $type (@{$_[0]->{types}}) {
		if ($type eq "text") {
			$hash{text} = WebGUI::International::get(1010);
		} elsif ($type eq "mixed") {
			$hash{mixed} = WebGUI::International::get(1008);
		} elsif ($type eq "code") {
			$hash{code} = WebGUI::International::get(1011);
		} elsif ($type eq "html") {
        		$hash{html} = WebGUI::International::get(1009);
		}
	}
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras}
		});
}
#-------------------------------------------------------------------

=head2 date ( hashRef )

Returns a date field.

=over

=item name

The name field for this form element.

=item value

The default date. Pass as an epoch value. Defaults to today.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item noDate

By default a date is placed in the "value" field. Set this to "1" to turn off the default date.

=back

=cut

sub date {
	my $value = epochToSet($_[0]->{value}) unless ($_[0]->{noDate} && $_[0]->{value} eq '');
        my $size = $_[0]->{size} || 10;
        my $output = _cssFile("calendar/calendar-win2k-1.css")
		._javascriptFile('calendar/calendar.js')
        	._javascriptFile('calendar/lang/calendar-en.js')
        	._javascriptFile('calendar/calendar-setup.js');
	$output .= text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'id="'.$_[0]->{name}.'Id" '.$_[0]->{extras},
		maxlength=>10
		});
	$output .= '<script type="text/javascript"> 
			Calendar.setup({ 
				inputField : "'.$_[0]->{name}.'Id", 
				ifFormat : "%Y-%m-%d", 
				showsTime : false, 
				timeFormat : "12",
				mondayFirst : false
				}); 
			</script>';
	return $output;
}



#-------------------------------------------------------------------

=head2 dateTime ( hashRef )

Returns a date/time field.

=over

=item name

The the base name for this form element. This form element actually returns two values under different names. They are name_date and name_time.

=item value

The date and time. Pass as an epoch value. Defaults to today and now.

=item extras 

Extra parameters to add to the date/time form element such as javascript or stylesheet information.

=back

=cut

sub dateTime {
	my $value = epochToSet($_[0]->{value},1);
        my $output = _cssFile("calendar/calendar-win2k-1.css")
                ._javascriptFile('calendar/calendar.js')
                ._javascriptFile('calendar/lang/calendar-en.js')
                ._javascriptFile('calendar/calendar-setup.js');
        $output .= text({
                name=>$_[0]->{name},
                value=>$value,
                size=>19,
                extras=>'id="'.$_[0]->{name}.'Id" '.$_[0]->{extras},
                maxlength=>19
                });
        $output .= '<script type="text/javascript">
                        Calendar.setup({
                                inputField : "'.$_[0]->{name}.'Id",
                                ifFormat : "%Y-%m-%d %H:%M:%S",
                                showsTime : true,
                                timeFormat : "12",
                                mondayFirst : false
                                });
                        </script>';
	return $output;
}



#-------------------------------------------------------------------

=head2 email ( hashRef )

Returns an email address field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub email {
        my ($output);
	$output = _javascriptFile('emailCheck.js');;
	$output .= text({
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		size=>$_[0]->{size},
		extras=>' onChange="emailCheck(this.value)" '.$_[0]->{extras}
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 fieldType ( hashRef )

Returns a field type select list field. This is primarily useful for building dynamic form builders.

=over

=item name

The name field for this form element.

=item types 

An array reference of field types to be displayed. The field names are the names of the methods from this forms package. Note that not all field types are supported. Defaults to all.

=item value

The default value for this form element.

=item size

The number of characters tall this form element should be. Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub fieldType {
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) It was done this way because a huge
	# if/elsif construct executes much more quickly than a bunch of
	# unnecessary database hits.
	my @types = qw(dateTime time zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList);
	$_[0]->{types} = \@types unless ($_[0]->{types});
	foreach $type (@{$_[0]->{types}}) {
		if ($type eq "text") {
			$hash{text} = WebGUI::International::get(475);
		} elsif ($type eq "timeField") {
        		$hash{timeField} = WebGUI::International::get(971);
		} elsif ($type eq "dateTime") {
        		$hash{dateTime} = WebGUI::International::get(972);
		} elsif ($type eq "textarea") {
        		$hash{textarea} = WebGUI::International::get(476);
		} elsif ($type eq "HTMLArea") {
        		$hash{HTMLArea} = WebGUI::International::get(477);
		} elsif ($type eq "url") {
        		$hash{url} = WebGUI::International::get(478);
		} elsif ($type eq "date") {
        		$hash{date} = WebGUI::International::get(479);
		} elsif ($type eq "email") {
        		$hash{email} = WebGUI::International::get(480);
		} elsif ($type eq "phone") {
        		$hash{phone} = WebGUI::International::get(481);
		} elsif ($type eq "integer") {
        		$hash{integer} = WebGUI::International::get(482);
		} elsif ($type eq "yesNo") {
        		$hash{yesNo} = WebGUI::International::get(483);
		} elsif ($type eq "selectList") {
        		$hash{selectList} = WebGUI::International::get(484);
		} elsif ($type eq "radioList") {
        		$hash{radioList} = WebGUI::International::get(942);
		} elsif ($type eq "checkList") {
        		$hash{checkList} = WebGUI::International::get(941);
		} elsif ($type eq "zipcode") {
			$hash{zipcode} = WebGUI::International::get(944);
		} elsif ($type eq "checkbox") {
        		$hash{checkbox} = WebGUI::International::get(943);
		}
	}
	# This is a hack for reverse compatibility with a bug where this field used to allow an array ref.
	my $value = $_[0]->{value};
	unless ($value eq "ARRAY") {
		$value = [$value];
	}
	return selectList({
		options=>\%hash,
		name=>$_[0]->{name},
		value=>$_[0]->{value},
		extras=>$_[0]->{extras},
		size=>$_[0]->{size}
		});
}

#-------------------------------------------------------------------

=head2 file ( hashRef )

Returns a file upload field.

=over

=item name

The name field for this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub file {
        my ($size);
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="file" name="'.$_[0]->{name}.'" size="'.$size.'" '.$_[0]->{extras}.'>';
}


#-------------------------------------------------------------------

=head2 filterContent ( hashRef )

Returns a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

=over

=item name

The name field for this form element. This defaults to "filterContent".

=item value

The default value for this form element. 

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub filterContent {
	my %filter;
	tie %filter, 'Tie::IxHash';
	%filter = (
		'none'=>WebGUI::International::get(420), 
                'macros'=>WebGUI::International::get(891), 
                'javascript'=>WebGUI::International::get(526), 
		'most'=>WebGUI::International::get(421),
		'all'=>WebGUI::International::get(419)
		);
	my $name = $_[0]->{name} || "filterContent";
        return selectList({
		name=>$name,
		options=>\%filter,
		value=>[$_[0]->{value}],
		extras=>$_[0]->{extras}
		});
}

#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Returns a form header.

=over

=item action

The form action. Defaults to the current page.

=item method

The form method. Defaults to "POST".

=item enctype

The form enctype. Defaults to "multipart/form-data".

=item extras

If you want to add anything special to the form header like javascript actions or stylesheet info, then use this.

=back

=cut

sub formHeader {
        my $action = $_[0]->{action} || WebGUI::URL::page();
	my $hidden;
	if ($action =~ /\?/) {
		my ($path,$query) = split(/\?/,$action);
		$action = $path;
		my @params = split(/\&/,$query);
		foreach my $param (@params) {
			$param =~ s/amp;(.*)/$1/;
			my ($name,$value) = split(/\=/,$param);
			$hidden .= hidden({name=>$name,value=>$value});
		}
	}
        my $method = $_[0]->{method} || "POST";
        my $enctype = $_[0]->{enctype} || "multipart/form-data";
	return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$_[0]->{extras}.'>'.$hidden;
}


#-------------------------------------------------------------------

=head2 float ( hashRef )

Returns an floating point field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub float {
        my $value = $_[0]->{value} || 0;
        my $size = $_[0]->{size} || 11;
        my $output = _javascriptFile('inputCheck.js');
	$output .= text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789.\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength}
		});
	return $output;
}




#-------------------------------------------------------------------

=head2 group ( hashRef ] )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=over

=item name

The name field for this form element.

=item value 

The selected group id(s) for this form element.  This should be passed as an array reference. Defaults to "7" (Everyone).

=item size

How many rows should be displayed at once?

=item multiple

Set to "1" if multiple groups should be selectable.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item excludeGroups

An array reference containing a list of groups to exclude from the list.

=back

=cut

sub group {
        my (%hash, $value, $where);
	$value = $_[0]->{value};
	if ($$value[0] eq "") { #doing long form otherwise arrayRef didn't work
		$value = [7];
	}
	tie %hash, 'Tie::IxHash';
	my $exclude = $_[0]->{excludeGroups};
	if ($$exclude[0] ne "") {
		$where = "where groupId not in (".join(",",@$exclude).")";
	}
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups $where order by groupName");
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

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=back

=cut

sub hidden {
        return '<input type="hidden" name="'.$_[0]->{name}.'" value="'._fixQuotes($_[0]->{value}).'">'."\n";
}


#-------------------------------------------------------------------

=head2 hiddenList ( hashRef )

Returns a list of hidden fields. This is primarily to be used by the HTMLForm package, but we decided to make it a public method in case anybody else had a use for it.

=over

=item name

The name of this field.

=item options 

A hash reference where the key is the "name" of the hidden field.

=item value

An array reference where each value in the array should be a name from the hash (if you want it to show up in the hidden list). 

=back

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

Returns an HTML area. An HTML area is different than a standard text area in that it provides rich edit functionality and some special error trapping for HTML and other special characters.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=item rows

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=item columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=item popupToggle

Defaults to "0". If set to "1" the rich editor will be a pop-up editor. If set to "0" the rich editor will be inline.

NOTE: WebGUI uses a great variety of rich editors. Not all of them are capable of inline mode, so even if you leave this set to "0" the editor may be a pop-up anyway.

=back

=cut

sub HTMLArea {
        my ($output, $rows, $columns, $htmlArea);
	my $browser = HTTP::BrowserDetect->new($session{env}{HTTP_USER_AGENT});
        my $button = '<input type="button" onClick="openEditWindow(this.form.'.$_[0]->{name}.')" value="'
		.WebGUI::International::get(171).'" style="font-size: 8pt;"><br>';
        $output = '<script language="JavaScript">function fixChars(element) {element.value = element.value.replace(/~V/mg,"-");}</script>';
	if ($session{user}{richEditor} eq "editOnPro2") {
		$output .= '<script language="JavaScript">
			var formObj;
			function openEditWindow(obj) {
	                	formObj = obj;
				window.open("'.$session{config}{extrasURL}.'/eopro.html","editWindow","width=720,height=450,resizable=1");
			} </script>';
	} elsif ($session{user}{richEditor} eq "htmlArea" && $browser->ie && $browser->version >= 5.5) {
		if ($session{user}{richEditorMode} eq "popup" || $_[0]->{popupToggle}) {
			$output .= '<script language="JavaScript">
                       	var formObj;
               		var extrasDir="'.$session{config}{extrasURL}.'";
               		function openEditWindow(obj) {
             			formObj = obj;
                       		window.open("'.$session{config}{extrasURL}.'/htmlArea/editor.html","editWindow","width=490,height=400,resizable=1");                   }
               		function setContent(content) {
                     		formObj.value = content;
                		} </script>';
                       	$output .= $button;
		} else {
			$output .= _javascriptFile('htmlArea/editor.js');
               		$output .= '<script>'."\n";
               		$output .= '_editor_url = "'.$session{config}{extrasURL}.'/htmlArea/";'."\n";
               		$output .= '</script>'."\n";
			$htmlArea = 1;
		}
        } elsif ($session{user}{richEditor} eq "midas" && (($browser->ie && $browser->version >= 6) || ($browser->gecko && $browser->version >= 1.3))) {
                        $output .= '<script language="JavaScript">
                                var formObj; var extrasDir="'.$session{config}{extrasURL}.'";
                                function openEditWindow(obj) {
                                        formObj = obj;
                                        window.open("'.$session{config}{extrasURL}.'/midas/editor.html","editWindow","width=600,height=400,resizable=1");                    }
                                </script>';
                        $output .= $button;
	} elsif ($session{user}{richEditor} eq "classic" && $browser->ie && $browser->version >= 5) {
			$output .= '<script language="JavaScript">
				var formObj; var extrasDir="'.$session{config}{extrasURL}.'";
        	       		function openEditWindow(obj) {
	               			formObj = obj;
                	 		window.open("'.$session{config}{extrasURL}.'/ie5edit.html","editWindow","width=490,height=400,resizable=1");			}
        	       		function setContent(content) { formObj.value = content; } </script>';
			$output .= $button;
	} elsif ($session{user}{richEditor} eq "lastResort") {
		$output .= '<script language="JavaScript">
			var formObj;
	               var extrasDir="'.$session{config}{extrasURL}.'";
        	       function openEditWindow(obj) {
	               formObj = obj;
        	         window.open("'.$session{config}{extrasURL}.'/lastResortEdit.html","editWindow","width=500,height=410");
			}
        	       function setContent(content) {
                	 formObj.value = content;
	               } </script>';
		$output .= $button;
	}
	$rows = $_[0]->{rows} || ($session{setting}{textAreaRows}+7);
	$columns = $_[0]->{columns} || ($session{setting}{textAreaCols}+5);
        $output .= textarea({
                name=>$_[0]->{name},
                value=>$_[0]->{value},
                wrap=>$_[0]->{wrap},
                columns=>$columns,
                rows=>$rows,
                extras=>$_[0]->{extras}.' onBlur="fixChars(this.form.'.$_[0]->{name}.')"'
                });
        if ($htmlArea) {
            	$output .= '<script language="Javascript1.2">'."\n";
            	$output .= 'editor_generate("'.$_[0]->{name}.'");'."\n";
            	$output .= '</script>'."\n";
        }
	return $output;	
}

#-------------------------------------------------------------------

=head2 integer ( hashRef )

Returns an integer field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub integer {
        my ($output, $size, $value);
        $value = $_[0]->{value} || 0;
        $size = $_[0]->{size} || 11;
        $output = _javascriptFile('inputCheck.js');
	$output .= text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789-\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength}
		});
	return $output;
}

#-------------------------------------------------------------------

=head2 interval ( hashRef )

Returns a time interval field.

=over

=item name

The the base name for this form element. This form element actually returns two values under different names. They are name_interval and name_units.

=item intervalValue

The default value for interval portion of this form element. Defaults to '1'.

=item unitsValue

The default value for units portion of this form element. Defaults to 'seconds'. Possible values are 'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', and 'years'.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub interval {
        my (%units, $output, $intervalValue, $unitsValue);
        $intervalValue = (defined $_[0]->{intervalValue}) ? $_[0]->{intervalValue} : 1;
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

=over

=item name 

The name field for this form element.

=item value

The default value for this form element.

=item maxlength 

The maximum number of characters to allow in this form element. Defaults to "35".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size 

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to "30" unless overridden in the settings.

=back

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

Returns a telephone number field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub phone {
        my $output = _javascriptFile('inputCheck.js');
        my $maxLength = $_[0]->{maxLength} || 30;
	$output .= text({
		name=>$_[0]->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789-()+ \')" '.$_[0]->{extras},
		value=>$_[0]->{value},
		size=>$_[0]->{size}
		});
	return $output;
}

#-------------------------------------------------------------------

=head2 radio ( hashRef )

Returns a radio button.

=over

=item name

The name field for this form element.

=item checked

If you'd like this radio button to be defaultly checked, set this to "1".

=item value

The default value for this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'


=back

=cut

sub radio {
        my ($checkedText);
        $checkedText = ' checked="1"' if ($_[0]->{checked});
        return '<input type="radio" name="'.$_[0]->{name}.'" value="'.$_[0]->{value}.'"'.$checkedText.' '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 radioList ( hashRef )

Returns a radio button list field.

=over

=item name

The name field for this form element.

=item options

The list of options for this list. Should be passed as a hash reference.

=item value

The default value for this form element. This should be passed as a scalar.

=item vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub radioList {
        my ($output, $key, $checked);
        foreach $key (keys %{$_[0]->{options}}) {
		$checked = 0;
                $checked = 1 if ($key eq $_[0]->{value});
		$output .= radio({
			name=>$_[0]->{name},
			value=>$key,
			checked=>$checked,
			extras=>$_[0]->{extras}
			});
		$output .= ' '.$_[0]->{options}->{$key};
                if ($_[0]->{vertical}) {
                        $output .= "<br />\n";
                } else {
                        $output .= " &nbsp; &nbsp;\n";
                }
        }
	return $output;
}

#-------------------------------------------------------------------

=head2 selectList ( hashRef )

Returns a select list field.

=over

=item name

The name field for this form element.

=item options 

The list of options for this select list. Should be passed as a hash reference.

=item value

The default value(s) for this form element. This should be passed as an array reference.

=item size 

The number of characters tall this form element should be. Defaults to "1".

=item multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

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
		$output .= '>'.${$_[0]->{options}}{$key}.'</option>';
	}
	$output	.= '</select>'; 
	return $output;
}

#-------------------------------------------------------------------

=head2 submit ( hashRef )

Returns a submit button.

=over

=item value

The button text for this submit button. Defaults to "save".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub submit {
        my ($label, $extras, $subtext, $class, $output, $name, $value, $wait);
        $value = $_[0]->{value} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
	$wait = WebGUI::International::get(452);
        return '<input type="submit" value="'.$value.'" onClick="this.value=\''.$wait.'\'" '.$_[0]->{extras}.'>';
}

#-------------------------------------------------------------------

=head2 template ( hashRef )

Returns a select list of templates.

=over

=item name

The name field for this form element. Defaults to "templateId".

=item value 

The unique identifier for the selected template. Defaults to "1".

=item namespace

The namespace for the list of templates to return. If this is omitted, all templates will be displayed.

=back

=cut

sub template {
        my $templateId = $_[0]->{value} || 1;
	my $name = $_[0]->{name} || "templateId";
        return selectList({
                name=>$name,
                options=>WebGUI::Template::getList($_[0]->{namespace}),
                value=>[$templateId]
                });
}

#-------------------------------------------------------------------

=head2 text ( hashRef )

Returns a text input field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub text {
        my ($size, $maxLength, $value);
        $value = _fixSpecialCharacters($_[0]->{value});
	$value = _fixQuotes($value);
	$value = _fixMacros($value);
        $maxLength = $_[0]->{maxlength} || 255;
        $size = $_[0]->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="text" name="'.$_[0]->{name}.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$_[0]->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 textarea ( hashRef )

Returns a text area field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=item rows 

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=item columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub textarea {
        my ($columns, $value, $rows, $wrap);
	$wrap = $_[0]->{wrap} || "virtual";
	$rows = $_[0]->{rows} || $session{setting}{textAreaRows} || 5;
	$columns = $_[0]->{columns} || $session{setting}{textAreaCols} || 50;
	$value = _fixSpecialCharacters($_[0]->{value});
	$value = _fixTags($value);
	$value = _fixMacros($value);
        return '<textarea name="'.$_[0]->{name}.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.
		$wrap.'" '.$_[0]->{extras}.'>'.$value.'</textarea>';
}

#-------------------------------------------------------------------

=head2 timeField ( hashRef )

Returns a time field, 24 hour format.

=over

=item name

The name field for this form element.

=item value

The default value for this form element. Defaults to the current time (like "15:03:42").

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 8.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to 8.

=back

=cut

sub timeField {
        my $value = WebGUI::DateTime::secondsToTime($_[0]->{value});
        my $output = _javascriptFile('inputCheck.js');
	$output .= text({
		name=>$_[0]->{name},
		value=>$value,
		size=>$_[0]->{size} || 8,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789:\')" '.$_[0]->{extras},
		maxlength=>$_[0]->{maxlength} || 8
		});
	$output .= '<input type="button" style="font-size: 8pt;" onClick="window.timeField = this.form.'.
		$_[0]->{name}.';clockSet = window.open(\''.$session{config}{extrasURL}.
		'/timeChooser.html\',\'timeChooser\',\'WIDTH=230,HEIGHT=100\');return false" value="'.
		WebGUI::International::get(970).'">';
	return $output;
}

#-------------------------------------------------------------------

=head2 url ( hashRef )

Returns a URL field.

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.  Defaults to 2048.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub url {
        my $maxLength = $_[0]->{maxlength} || 2048;
	my $output = _javascriptFile('addHTTP.js');
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

=head2 whatNext ( hashRef ] )

Returns a "What next?" select list for use with chained action forms in WebGUI.

=over

=item options

A hash reference of the possible actions that could happen next.

=item value

The selected element in this list. 

=item name

The name field for this form element. Defaults to "proceed".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

=cut

sub whatNext {
        my ($name);
        $name = $_[0]->{name} || "proceed";
        return selectList({
                options=>$_[0]->{options},
                name=>$name,
                value=>[$_[0]->{value}],
                extras=>$_[0]->{extras}
                });

}

#-------------------------------------------------------------------

=head2 yesNo ( hashRef )

Returns a yes/no radio field. 

=over

=item name

The name field for this form element.

=item value

The default value(s) for this form element. Valid values are "1" and "0". Defaults to "1".

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=back

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

=over

=item name

The name field for this form element.

=item value

The default value for this form element.

=item maxlength

The maximum number of characters to allow in this form element.

=item extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=item size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=back

=cut

sub zipcode {
        my $output = _javascriptFile('inputCheck.js');
        my $maxLength = $_[0]->{maxLength} || 10;
	$output .= text({
		name=>$_[0]->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$_[0]->{name}.',\'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- \')" '.$_[0]->{extras},
		value=>$_[0]->{value},
		size=>$_[0]->{size}
		});
	return $output;
}




1;


