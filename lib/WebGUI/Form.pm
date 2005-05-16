package WebGUI::Form;

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

use strict;
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::Asset::RichEdit;
use WebGUI::Asset::Template;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form

=head1 DESCRIPTION

Base forms package. Eliminates some of the normal code work that goes along with creating forms. Used by the HTMLForm package.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::asset({value=>$assetId});
 $html = WebGUI::Form::button({value=>"Click me!", extras=>qq|onclick="alert('Aaaaggggghhh!!!')"|});
 $html = WebGUI::Form::checkbox({name=>"whichOne", value=>"red"});
 $html = WebGUI::Form::checkList({name=>"dayOfWeek", options=>\%days});
 $html = WebGUI::Form::codearea({name=>"stylesheet"});
 $html = WebGUI::Form::color({name=>"highlightColor"});
 $html = WebGUI::Form::combo({name=>"fruit",options=>\%fruit});
 $html = WebGUI::Form::contentType({name=>"contentType");
 $html = WebGUI::Form::databaseLink();
 $html = WebGUI::Form::date({name=>"endDate", value=>$endDate});
 $html = WebGUI::Form::dateTime({name=>"begin", value=>$begin});
 $html = WebGUI::Form::email({name=>"emailAddress"});
 $html = WebGUI::Form::fieldType({name=>"fieldType");
 $html = WebGUI::Form::file({name=>"image"});
 $html = WebGUI::Form::formFooter();
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

=head2 asset ( hashref )

Returns an asset picker control. 

=head3 value

The asset ID assigned to this control. 

=head3 name

The name of this field. Defaults to "asset".

=head3 defaultValue

If no value is specified, use this value.

=head3 class

Limit options to a specific class type such as "WebGUI::Asset::Wobject::Article"

=head3 extras

Assign extra things like javascript events to this form element.

=cut


sub asset {
	my $params = shift;
	my $value = defined($params->{value}) ? $params->{value} : $params->{defaultValue};
	my $name = $params->{name} || "asset";
	my $asset = WebGUI::Asset->newByDynamicClass($value) || WebGUI::Asset->getRoot;
	return hidden({
			name=>$name,
			extras=>'id="'.$name.'" '.$params->{extras},
			value=>$asset->getId
			})
		.text({
			name=>$name."_display",
			extras=>'id="'.$name."_display".'" readonly="1"',
			value=>$asset->get("title")
			})
		.button({
			value=>"...",
			extras=>'onclick="window.open(\''.$asset->getUrl("op=formAssetTree&classLimiter=".$params->{class}."&formId=".$name).'\',\'assetPicker\',\'toolbar=no, location=no, status=no, directories=no, width=400, height=400\');"'
			});

}


#-------------------------------------------------------------------

=head2 button ( hashRef )

Returns a button. Use it in combination with scripting code to make the button perform an action.

=head3 value

The button text for this submit button. Defaults to "save".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onClick="alert(\'You've just pushed me !\')"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub button {
	my $params = shift;
        my $value = $params->{value} || $params->{defaultValue} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
        return '<input type="button" value="'.$value.'" '.$params->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 checkbox ( hashRef )

Returns a checkbox form element.

=head3 name

The name field for this form element.

=head3 checked 

If you'd like this box to be defaultly checked, set this to "1".

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Defaults to 1.

=cut

sub checkbox {
	my $params = shift;
        my $checkedText = ' checked="1"' if ($params->{checked});
        my $value = $params->{value} || $params->{defaultValue} || 1;
        return '<input type="checkbox" name="'.$params->{name}.'" value="'.$value.'"'.$checkedText.' '.$params->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 checkList ( hashRef )

Returns checkbox list.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Should be passed as an array reference.

=cut

sub checkList {
	my $params = shift;
        my ($output, $checked, $key, $item);
	my $values = $params->{value} || $params->{defaultValue};
        foreach $key (keys %{$params->{options}}) {
		$checked = 0;
		foreach $item (@{$values}) {
                        if ($item eq $key) {
                                $checked = 1;
                        }
                }
		$output .= checkbox({
			name=>$params->{name},
			value=>$key,
			extras=>$params->{extras},
			checked=>$checked
			});
                $output .= ${$params->{options}}{$key};
		if ($params->{vertical}) {
			$output .= "<br />\n";
		} else {
			$output .= " &nbsp; &nbsp;\n";
		}
        }
	return $output;
}


sub codearea {
	my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/TabFix.js',{type=>"text/javascript"});
	$params->{extras} = 'style="width: 99%; min-width: 440px; height: 400px" onkeypress="return TabFix_keyPress(event)" onkeydown="return TabFix_keyDown(event)"';
	my $output = textarea($params);
	return $output;
}

#-------------------------------------------------------------------

=head2 color ( hashRef )

Returns a color picker field.

=head3 name

The name field for this form element.

=head3 value

The value for this form element. This should be a scalar containing a hex color like "#000000".

=head3 defaultValue

This will be used if no value is specified.

=cut

sub color {
        my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/colorPicker.js',{ type=>'text/javascript' });
	return '<script type="text/javascript">initColorPicker("'.$params->{name}.'","'.($params->{value}||$params->{defaultValue}).'");</script>';
}


#-------------------------------------------------------------------

=head2 combo ( hashRef )

Returns a select list and a text field. If the text box is filled out it will have a value stored in "name"_new.

=head3 name

The name field for this form element.

=head3 options

The list of options for the select list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Should be passed as an array reference.

=cut

sub combo {
	my $params = shift;
	$params->{options}->{''} = '['.WebGUI::International::get(582).']';
	$params->{options}->{_new_} = WebGUI::International::get(581).'-&gt;';
	my $output = selectList({
		name=>$params->{name},
		options=>$params->{options},
		value=>$params->{value} || $params->{defaultValue},
		multiple=>$params->{multiple},
		extras=>$params->{extras}
		});
	my $size =  $session{setting}{textBoxSize}-5;
        $output .= text({name=>$params->{name}."_new",size=>$size});
	return $output;
}

#-------------------------------------------------------------------

=head2 contentType ( hashRef )

Returns a content type select list field. This is usually used to help tell WebGUI how to treat posted content.

=head3 name

The name field for this form element.

=head3 types 

An array reference of field types to be displayed. The types are "mixed", "html", "code", and "text".  Defaults to all.

=head3 value

The default value for this form element. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Defaults to "mixed".

=cut

sub contentType {
	my $params = shift;
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) It was done this way because a huge
	# if/elsif construct executes much more quickly than a bunch of
	# unnecessary database hits.
	my @types = qw(mixed html code text);
	$params->{types} = \@types unless ($params->{types});
	foreach $type (@{$params->{types}}) {
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
		name=>$params->{name},
		value=>[$params->{value}],
		extras=>$params->{extras},
		defaultValue=>[$params->{defaultValue}]
		});
}


#-------------------------------------------------------------------
                                                                                                                                                      
=head2 databaseLink ( hashRef )
                                                                                                                                                       
Returns a select list of database links.
                                                                                                                                                       
=head3 name
                                                                                                                                                       
The name field for this form element. Defaults to "databaseLinkId".
                                                                                                                                                       
=head3 value
                                                                                                                                               
The unique identifier for the selected template. 
                                                                                                                                         
=head3 defaultValue

This will be used if no value is specified. Defaults to 0 (the WebGUI database).

=cut
                                                                                                                                                             
sub databaseLink {
	my $params = shift;
        my $value = $params->{value} || $params->{defaultValue} || 0;
        my $name = $params->{name} || "databaseLinkId";
        return selectList({
                name=>$name,
                options=>WebGUI::DatabaseLink::getList(),
                value=>[$value]
                });
}
                                                                                                                                                             





#-------------------------------------------------------------------

=head2 date ( hashRef )

Returns a date field.

=head3 name

The name field for this form element.

=head3 value

The default date. Pass as an epoch value. Defaults to today.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 noDate

By default a date is placed in the "value" field. Set this to "1" to turn off the default date.

=head3 defaultValue

This will be used if no value is specified. Defaults to today.

=cut

sub date {
	my $params = shift;
	my $value = epochToSet($params->{value}||$params->{defaultValue}) unless ($params->{noDate} && $params->{value} eq '');
        my $size = $params->{size} || 10;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar.js',{ type=>'text/javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/lang/calendar-en.js',{ type=>'text/javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar-setup.js',{ type=>'text/javascript' });
	WebGUI::Style::setLink($session{config}{extrasURL}.'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
	return text({
		name=>$params->{name},
		value=>$value,
		size=>$size,
		extras=>'id="'.$params->{name}.'Id" '.$params->{extras},
		maxlength=>10
		}) . '<script type="text/javascript"> 
			Calendar.setup({ 
				inputField : "'.$params->{name}.'Id", 
				ifFormat : "%Y-%m-%d", 
				showsTime : false, 
				timeFormat : "12",
				mondayFirst : false
				}); 
			</script>';
}



#-------------------------------------------------------------------

=head2 dateTime ( hashRef )

Returns a date/time field.

=head3 name

The the base name for this form element. This form element actually returns two values under different names. They are name_date and name_time.

=head3 value

The date and time. Pass as an epoch value. Defaults to today and now.

=head3 extras 

Extra parameters to add to the date/time form element such as javascript or stylesheet information.

=head3 defaultValue

This will be used if no value is specified. Defaults to today and now.

=cut

sub dateTime {
	my $params = shift;
	my $value = epochToSet($params->{value}||$params->{defaultValue},1);
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar.js',{ type=>'text/javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/lang/calendar-en.js',{ type=>'text/javascript' });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar-setup.js',{ type=>'text/javascript' });
	WebGUI::Style::setLink($session{config}{extrasURL}.'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
        return text({
                name=>$params->{name},
                value=>$value,
                size=>19,
                extras=>'id="'.$params->{name}.'Id" '.$params->{extras},
                maxlength=>19
                }) . '<script type="text/javascript">
                        Calendar.setup({
                                inputField : "'.$params->{name}.'Id",
                                ifFormat : "%Y-%m-%d %H:%M:%S",
                                showsTime : true,
                                timeFormat : "12",
                                mondayFirst : false
                                });
                        </script>';
}

#-------------------------------------------------------------------

=head2 dynamicField ( fieldType , hashRef )
                                                                                                                         
Returns a dynamic configurable field.
                                                                                                                         
=head3 fieldType

The field type to use. The field name is the name of the method from this forms package.

=head3 options

The field options. See the documentation for the desired field for more information.
                                                                                                                         
=cut

sub dynamicField {
	my $fieldType = shift;
	my $param = shift;

        # Set options for fields that use a list.
        if (isIn($fieldType,qw(selectList checkList radioList))) {
                delete $param->{size};
                my %options;
                tie %options, 'Tie::IxHash';
                foreach (split(/\n/, $param->{possibleValues})) {
                        s/\s+$//; # remove trailing spaces
                        $options{$_} = $_;
                }
		if (exists $param->{options} && ref($param->{options}) eq "HASH") {
			%options = (%{$param->{options}} , %options);
		}
                $param->{options} = \%options;
        }
        # Convert value to list for selectList / checkList
        if (isIn($fieldType,qw(selectList checkList)) && ref $param->{value} ne "ARRAY") {
                my @defaultValues;
                foreach (split(/\n/, $param->{value})) {
                                s/\s+$//; # remove trailing spaces
                                push(@defaultValues, $_);
                }
                $param->{value} = \@defaultValues;
        }

	# Return the appropriate field.
	no strict 'refs';
	return &$fieldType($param);

}

#-------------------------------------------------------------------

=head2 email ( hashRef )

Returns an email address field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub email {
	my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/emailCheck.js',{ type=>'text/javascript' });
	my $output .= text({
		name=>$params->{name},
		value=>$params->{value},
		size=>$params->{size},
		extras=>' onChange="emailCheck(this.value)" '.$params->{extras},
		defaultValue=>$params->{defaultValue}
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 fieldType ( hashRef )

Returns a field type select list field. This is primarily useful for building dynamic form builders.

=head3 name

The name field for this form element.

=head3 types 

An array reference of field types to be displayed. The field names are the names of the methods from this forms package. Note that not all field types are supported. Defaults to all.

=head3 value

The default value for this form element.

=head3 size

The number of characters tall this form element should be. Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub fieldType {
	my $params = shift;
	my (%hash, $output, $type);
 	tie %hash, 'Tie::IxHash';
	# NOTE: What you are about to see is bad code. Do not attempt this
	# without adult supervision. =) 
	my @types = qw(dateTime time float zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList);
	$params->{types} = \@types unless ($params->{types});
	foreach $type (@{$params->{types}}) {
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
		} elsif ($type eq "float") {
        		$hash{float} = WebGUI::International::get("float");
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
	return selectList({
		options=>\%hash,
		name=>$params->{name},
		value=>[$params->{value}],
		extras=>$params->{extras},
		size=>$params->{size},
		defaultValue=>[$params->{defaultValue}]
		});
}

#-------------------------------------------------------------------

=head2 file ( hashRef )

Returns a file upload field.

=head3 name

The name field for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=cut

sub file {
	my $params = shift;
        my $size = $params->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="file" name="'.$params->{name}.'" size="'.$size.'" '.$params->{extras}.' />';
}


#-------------------------------------------------------------------

=head2 files ( hashRef )

Returns a multiple file upload control.

=head3 name

The name field for this form element.

=cut

sub files {
	WebGUI::Style::setScript($session{config}{extrasURL}.'/FileUploadControl.js',{type=>"text/javascript"});
	my $uploadControl = '<div id="fileUploadControl"> </div>
		<script>
		var images = new Array();
		';
	opendir(DIR,$session{config}{extrasPath}.'/fileIcons');
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		unless ($file eq "." || $file eq "..") {
			my $ext = $file;
			$ext =~ s/(.*?)\.gif/$1/;
			$uploadControl .= 'images["'.$ext.'"] = "'.$session{config}{extrasURL}.'/fileIcons/'.$file.'";'."\n";
		}
	}
	$uploadControl .= 'var uploader = new FileUploadControl("fileUploadControl", images);
	uploader.addRow();
	</script>';
	return $uploadControl;
}


#-------------------------------------------------------------------

=head2 filterContent ( hashRef )

Returns a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

=head3 name

The name field for this form element. This defaults to "filterContent".

=head3 value

The default value for this form element. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub filterContent {
	my $params = shift;
	my %filter;
	tie %filter, 'Tie::IxHash';
	%filter = (
		'none'=>WebGUI::International::get(420), 
                'macros'=>WebGUI::International::get(891), 
                'javascript'=>WebGUI::International::get(526), 
		'most'=>WebGUI::International::get(421),
		'all'=>WebGUI::International::get(419)
		);
	my $name = $params->{name} || "filterContent";
        return selectList({
		name=>$name,
		options=>\%filter,
		value=>[$params->{value}],
		extras=>$params->{extras},
		defaultValue=>[$params->{defaultValue}]
		});
}

#-------------------------------------------------------------------

=head2 formFooter ( )

Returns a form footer.

=cut

sub formFooter {
	return "</div></form>\n\n";
}


#-------------------------------------------------------------------

=head2 formHeader ( hashRef )

Returns a form header.

=head3 action

The form action. Defaults to the current page.

=head3 method

The form method. Defaults to "post".

=head3 enctype

The form enctype. Defaults to "multipart/form-data".

=head3 extras

If you want to add anything special to the form header like javascript actions or stylesheet info, then use this.

=cut

sub formHeader {
	my $params = shift;
        my $action = $params->{action} || WebGUI::URL::page();
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
        my $method = $params->{method} || "post";
        my $enctype = $params->{enctype} || "multipart/form-data";
	return '<form action="'.$action.'" enctype="'.$enctype.'" method="'.$method.'" '.$params->{extras}.'><div class="formContents">'.$hidden;
}


#-------------------------------------------------------------------

=head2 float ( hashRef )

Returns an floating point field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub float {
	my $params = shift;
        my $value = $params->{value} || 0;
        my $size = $params->{size} || 11;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
	return text({
		name=>$params->{name},
		value=>$value,
		size=>$size,
		extras=>'onKeyUp="doInputCheck(this.form.'.$params->{name}.',\'0123456789.\')" '.$params->{extras},
		maxlength=>$params->{maxlength},
		defaultValue=>$params->{defaultValue}
		});
}




#-------------------------------------------------------------------

=head2 group ( hashRef ] )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=head3 name

The name field for this form element.

=head3 value 

The selected group id(s) for this form element.  This should be passed as an array reference.

=head3 size

How many rows should be displayed at once?

=head3 multiple

Set to "1" if multiple groups should be selectable.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 excludeGroups

An array reference containing a list of groups to exclude from the list.

=head3 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to 7 (Everyone).

=cut

sub group {
	my $params = shift;
        my (%hash, $value, $where);
	$value = $params->{value};
	if ($$value[0] eq "") { #doing long form otherwise arrayRef didn't work
		$value = [7];
	}
	tie %hash, 'Tie::IxHash';
	my $exclude = $params->{excludeGroups};
	if ($$exclude[0] ne "") {
		$where = "and groupId not in (".quoteAndJoin($exclude).")";
	}
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where showInForms=1 $where order by groupName");
	return selectList({
		options=>\%hash,
		name=>$params->{name},
		value=>$value,
		extras=>$params->{extras},
		size=>$params->{size},
		multiple=>$params->{multiple},
		defaultValue=>$params->{defaultValue}
		});
		
}

#-------------------------------------------------------------------

=head2 hidden ( hashRef )

Returns a hidden field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 defaultValue

This will be used if no value is specified.

=head3 extras

Add extra things like ids and javascript event handlers.

=cut

sub hidden {
	my $params = shift;
        return '<input type="hidden" name="'.$params->{name}.'" value="'._fixQuotes(_fixMacros(_fixSpecialCharacters($params->{value}))).'" '.$params->{extras}.' />'."\n";
}


#-------------------------------------------------------------------

=head2 hiddenList ( hashRef )

Returns a list of hidden fields. This is primarily to be used by the HTMLForm package, but we decided to make it a public method in case anybody else had a use for it.

=head3 name

The name of this field.

=head3 options 

A hash reference where the key is the "name" of the hidden field.

=head3 value

An array reference where each value in the array should be a name from the hash (if you want it to show up in the hidden list). 

=head3 defaultValue

This will be used if no value is specified. Should be passed as an array reference.

=cut

sub hiddenList {
	my $params = shift;
        my ($output, $key, $item);
	my $values = $params->{value} || $params->{defaultValue};
        foreach $key (keys %{$params->{options}}) {
                foreach $item (@{$values}) {
                        if ($item eq $key) {
				$output .= hidden({
					name=>$params->{name},
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

=head3 name

The name field for this form element.

=head3 richEditId

An asset Id of a rich editor to display for this field.

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub HTMLArea {
	my $params = shift;
        my $rows = $params->{rows} || ($session{setting}{textAreaRows}+20);
        my $columns = $params->{columns} || ($session{setting}{textAreaCols}+10);
	my $richEditId = $params->{richEditId} || $session{setting}{richEditor} || "PBrichedit000000000001";
        my $output = textarea({
                name=>$params->{name},
                value=>$params->{value},
                wrap=>$params->{wrap},
                columns=>$columns,
                rows=>$rows,
                extras=>$params->{extras}.' onBlur="fixChars(this.form.'.$params->{name}.')" id="'.$params->{name}.'"'.' mce_editable="true" ',
		defaultValue=>$params->{defaultValue}
                });
	WebGUI::Style::setScript($session{config}{extrasURL}.'/textFix.js',{ type=>'text/javascript' });
	$output .= WebGUI::Asset::RichEdit->new($richEditId)->getRichEditor;
	return $output;
}

#-------------------------------------------------------------------

=head2 integer ( hashRef )

Returns an integer field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 11.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub integer {
	my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
	return text({
		name=>$params->{name},
		value=>$params->{value},
		defaultValue=>$params->{defaultValue} || 0,
		size=>$params->{size} || 11,
		extras=>'onKeyUp="doInputCheck(this.form.'.$params->{name}.',\'0123456789-\')" '.$params->{extras},
		maxlength=>$params->{maxlength}
		});
}

#-------------------------------------------------------------------

=head2 interval ( hashRef )

Returns a time interval field.

=head3 name

The the base name for this form element. This form element actually returns two values under different names. They are name_interval and name_units.

=head3 intervalValue

The default value for interval portion of this form element. Defaults to '1'.

=head3 unitsValue

The default value for units portion of this form element. Defaults to 'seconds'. Possible values are 'seconds', 'minutes', 'hours', 'days', 'weeks', 'months', and 'years'.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub interval {
	my $params = shift;
        my (%units);
        my $value =  $params->{value} || $params->{defaultValue} || 1;
        tie %units, 'Tie::IxHash';
	%units = ('seconds'=>WebGUI::International::get(704),
		'minutes'=>WebGUI::International::get(705),
		'hours'=>WebGUI::International::get(706),
		'days'=>WebGUI::International::get(700),
                'weeks'=>WebGUI::International::get(701),
                'months'=>WebGUI::International::get(702),
                'years'=>WebGUI::International::get(703));
	my ($interval, $units) = WebGUI::DateTime::secondsToInterval($value);
	my $output = integer({
		name=>$params->{name}.'_interval',
		value=>$interval,
		extras=>$params->{extras}
		});
	$output .= selectList({
		name=>$params->{name}.'_units',
		value=>[$units],
		options=>\%units
		});
	return $output;
}


#-------------------------------------------------------------------

=head2 password ( hashRef )

Returns a password field. 

=head3 name 

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength 

The maximum number of characters to allow in this form element. Defaults to "35".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size 

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to "30" unless overridden in the settings.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub password {
	my $params = shift;
	my $value = _fixQuotes($params->{value}||$params->{defaultValue});
        my $maxLength = $params->{maxlength} || 35;
        my $size = $params->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="password" name="'.$params->{name}.'" value="'.$value.'" size="'.
		$size.'" maxlength="'.$maxLength.'" '.$params->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 phone ( hashRef )

Returns a telephone number field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub phone {
	my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
        my $maxLength = $params->{maxlength} || 30;
	return text({
		name=>$params->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$params->{name}.',\'0123456789-()+ \')" '.$params->{extras},
		value=>$params->{value},
		size=>$params->{size},
		defaultValue=>$params->{defaultValue}
		});
}

#-------------------------------------------------------------------

=head2 radio ( hashRef )

Returns a radio button.

=head3 name

The name field for this form element.

=head3 checked

If you'd like this radio button to be defaultly checked, set this to "1".

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. 

=cut

sub radio {
	my $params = shift;
        my $checkedText = ' checked="1"' if ($params->{checked});
	my $value = defined($params->{value}) ? $params->{value} : $params->{defaultValue};
        return '<input type="radio" name="'.$params->{name}.'" value="'.$value.'"'.$checkedText.' '.$params->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 radioList ( hashRef )

Returns a radio button list field.

=head3 name

The name field for this form element.

=head3 options

The list of options for this list. Should be passed as a hash reference.

=head3 value

The default value for this form element. This should be passed as a scalar.

=head3 vertical

If set to "1" the radio button elements will be laid out horizontally. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. 

=cut

sub radioList {
	my $params = shift;
        my ($output, $key, $checked);
	my $value = defined($params->{value}) ? $params->{value} : $params->{defaultValue};
        foreach $key (keys %{$params->{options}}) {
		$checked = 0;
                $checked = 1 if ($key eq $value);
		$output .= radio({
			name=>$params->{name},
			value=>$key,
			checked=>$checked,
			extras=>$params->{extras}
			});
		$output .= ' '.$params->{options}->{$key};
                if ($params->{vertical}) {
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

=head3 name

The name field for this form element.

=head3 options 

The list of options for this select list. Should be passed as a hash reference.

=head3 value

The default value(s) for this form element. This should be passed as an array reference.

=head3 size 

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 sortByValue

A boolean value for whether or not the values in the options hash should be sorted.

=head3 defaultValue

This will be used if no value is specified. Should be passed as an array reference.

=cut

sub selectList {
	my $params = shift;
	my ($output, $key, $item, $size, $multiple);
	$size = $params->{size} || 1;
	$multiple = ' multiple="1"' if ($params->{multiple});
       	$output = '<select name="'.$params->{name}.'" size="'.$size.'" '.$params->{extras}.$multiple.'>';
	my $values = $params->{value} || $params->{defaultValue};
	my %options;
        tie %options, 'Tie::IxHash';
       	if ($params->{sortByValue}) {
               	foreach my $optionKey (sort {"\L${$params->{options}}{$a}" cmp "\L${$params->{options}}{$b}" } keys %{$params->{options}}) {
                         $options{$optionKey} = ${$params->{options}}{$optionKey};
               	}
       	} else {
               	%options = %{$params->{options}};
       	}
       	foreach $key (keys %options) {
           	$output .= '<option value="'.$key.'"';
          	 foreach $item (@{$values}) {
             		if ($item eq $key) {
             			$output .= ' selected="1"';
             		}
           	}
           	$output .= '>'.${$params->{options}}{$key}.'</option>';
	}
	$output	.= '</select>'; 
	return $output;
}


#-------------------------------------------------------------------

=head2 submit ( hashRef )

Returns a submit button.

=head3 value

The button text for this submit button. 

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Defaults to "save".

=cut

sub submit {
	my $params = shift;
        my $value = $params->{value} || $params->{defaultValue} || WebGUI::International::get(62);
        $value = _fixQuotes($value);
	my $wait = WebGUI::International::get(452);
	my $extras = $params->{extras} || 'onclick="this.value=\''.$wait.'\'"';
	return '<input type="submit" value="'.$value.'" '.$extras.' />';

}

#-------------------------------------------------------------------

=head2 template ( hashRef )

Returns a select list of templates.

=head3 name

The name field for this form element. Defaults to "templateId".

=head3 value 

The unique identifier for the selected template.

=head3 namespace

The namespace for the list of templates to return. If this is omitted, all templates will be displayed.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub template {
	my $params = shift;
        my $templateId = $params->{value} || $params->{defaultValue};
	my $name = $params->{name} || "templateId";
        return selectList({
                name=>$name,
                options=>WebGUI::Asset::Template->getList($params->{namespace}),
                value=>[$templateId],
		extras=>$params->{extras}
                });
}

#-------------------------------------------------------------------

=head2 text ( hashRef )

Returns a text input field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub text {
	my $params = shift;
        my $value = _fixSpecialCharacters($params->{value}||$params->{defaultValue});
	$value = _fixQuotes($value);
	$value = _fixMacros($value);
        my $maxLength = $params->{maxlength} || 255;
        my $size = $params->{size} || $session{setting}{textBoxSize} || 30;
        return '<input type="text" name="'.$params->{name}.'" value="'.$value.'" size="'.
                $size.'" maxlength="'.$maxLength.'" '.$params->{extras}.' />';
}

#-------------------------------------------------------------------

=head2 textarea ( hashRef )

Returns a text area field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 wrap

The method for wrapping text in the text area. Defaults to "virtual". There should be almost no reason to specify this.

=head3 rows 

The number of characters tall this form element should be. There should be no reason for anyone to specify this.

=head3 columns

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub textarea {
	my $params = shift;
	my $wrap = $params->{wrap} || "virtual";
	my $rows = $params->{rows} || $session{setting}{textAreaRows} || 5;
	my $columns = $params->{columns} || $session{setting}{textAreaCols} || 50;
	my $value = _fixSpecialCharacters($params->{value} || $params->{defaultValue});
	$value = _fixTags($value);
	$value = _fixMacros($value);
        return '<textarea name="'.$params->{name}.'" cols="'.$columns.'" rows="'.$rows.'" wrap="'.
		$wrap.'" '.$params->{extras}.'>'.$value.'</textarea>';
}

#-------------------------------------------------------------------

=head2 timeField ( hashRef )

Returns a time field, 24 hour format.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element. 

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 8.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this. Defaults to 8.

=head3 defaultValue

This will be used if no value is specified. Defaults to now.

=cut

sub timeField {
	my $params = shift;
        my $value = WebGUI::DateTime::secondsToTime($params->{value}||$params->{defaultValue});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
	my $output = text({
		name=>$params->{name},
		value=>$value,
		size=>$params->{size} || 8,
		extras=>'onKeyUp="doInputCheck(this.form.'.$params->{name}.',\'0123456789:\')" '.$params->{extras},
		maxlength=>$params->{maxlength} || 8
		});
	$output .= '<input type="button" style="font-size: 8pt;" onClick="window.timeField = this.form.'.
		$params->{name}.';clockSet = window.open(\''.$session{config}{extrasURL}.
		'/timeChooser.html\',\'timeChooser\',\'WIDTH=230,HEIGHT=100\');return false" value="'.
		WebGUI::International::get(970).'" />';
	return $output;
}

#-------------------------------------------------------------------

=head2 url ( hashRef )

Returns a URL field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.  Defaults to 2048.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub url {
	my $params = shift;
        my $maxLength = $params->{maxlength} || 2048;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/addHTTP.js',{ type=>'text/javascript' });
	return text({
		name=>$params->{name},
		value=>$params->{value},
		extras=>$params->{extras}.' onBlur="addHTTP(this.form.'.$params->{name}.')"',
		size=>$params->{size},
		maxlength=>$maxLength,
		defaultValue=>$params->{defaultValue}
		});
}

#-------------------------------------------------------------------

=head2 whatNext ( hashRef ] )

Returns a "What next?" select list for use with chained action forms in WebGUI.

=head3 options

A hash reference of the possible actions that could happen next.

=head3 value

The selected element in this list. 

=head3 name

The name field for this form element. Defaults to "proceed".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified.

=cut

sub whatNext {
	my $params = shift;
        my $name = $params->{name} || "proceed";
        return selectList({
                options=>$params->{options},
                name=>$name,
                value=>[$params->{value}],
                extras=>$params->{extras},
		defaultValue=>[$params->{defaultValue}]
                });

}

#-------------------------------------------------------------------

=head2 yesNo ( hashRef )

Returns a yes/no radio field. 

=head3 name

The name field for this form element.

=head3 value

The default value(s) for this form element. Valid values are "1" and "0". Defaults to "1".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 defaultValue

This will be used if no value is specified. Defaults to 1.

=cut

sub yesNo {
	my $params = shift;
        my ($checkYes, $checkNo);
	my $value = $params->{value}||$params->{defaultValue};
	if ($value) {
		$checkYes = 1;
	} else {
		$checkNo = 1;
	}
	my $output = radio({
		checked=>$checkYes,
		name=>$params->{name},
		value=>1,
		extras=>$params->{extras}
		});
	$output .= WebGUI::International::get(138);
	$output .= '&nbsp;&nbsp;&nbsp;';
	$output .= radio({
                checked=>$checkNo,
                name=>$params->{name},
                value=>0,
                extras=>$params->{extras}
                });
        $output .= WebGUI::International::get(139);
	return $output;
}

#-------------------------------------------------------------------

=head2 zipcode ( hashRef )

Returns a zip code field.

=head3 name

The name field for this form element.

=head3 value

The default value for this form element.

=head3 maxlength

The maximum number of characters to allow in this form element.

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=head3 size

The number of characters wide this form element should be. There should be no reason for anyone to specify this.

=head3 defaultValue

This will be used if no value is specified.

=cut

sub zipcode {
	my $params = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
        my $maxLength = $params->{maxlength} || 10;
	return text({
		name=>$params->{name},
		maxlength=>$maxLength,
		extras=>'onKeyUp="doInputCheck(this.form.'.$params->{name}.',\'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- \')" '.$params->{extras},
		value=>$params->{value},
		size=>$params->{size},
		defaultValue=>$params->{defaultValue}
		});
}




1;


