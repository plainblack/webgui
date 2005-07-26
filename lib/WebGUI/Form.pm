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

This is a convenience package which provides a simple interface to use all of the form controls without having to load each one seperately, create objects, and call methods.

=head1 SYNOPSIS

 use WebGUI::Form;

 $html = WebGUI::Form::formFooter();
 $html = WebGUI::Form::formHeader();

 $html = WebGUI::Form::anyFieldType(%properties);

 Example:

 $html = WebGUI::Form::text(%properties);

=head1 METHODS 

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 AUTOLOAD ()

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
	our $AUTOLOAD;
	my $name = (split /::/, $AUTOLOAD)[-1];
	my @params = @_;
	my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);
        if ($@) {
        	WebGUI::ErrorHandler::error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }
	my $class = "WebGUI::Form::".$name;
	return $class->new(@params)->toHtml;
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
	$uploadControl .= 'var uploader = new FileUploadControl("fileUploadControl", images, "'.WebGUI::International::get('removeLabel','WebGUI').'");
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
                                                                                                                                                      
=head2 ldapLink ( hashRef )
                                                                                                                                                       
Returns a select list of ldap links.
                                                                                                                                                       
=head3 name
                                                                                                                                                       
The name field for this form element. Defaults to "ldapLinkId".
                                                                                                                                                       
=head3 value
                                                                                                                                               
The default value(s) for this form element. This should be passed as an array reference. 
                                                                                                                                         
=head3 defaultValue

This will be used if no value is specified. Defaults to 0 (the WebGUI database).

=head3 size 

The number of characters tall this form element should be. Defaults to "1".

=head3 multiple

A boolean value for whether this select list should allow multiple selections. Defaults to "0".

=head3 extras

If you want to add anything special to this form element like javascript actions, or stylesheet information, you'd add it in here as follows:

 'onChange="this.form.submit()"'

=cut
                                                                                                                                                             
sub ldapLink {
	my $params = shift;
    my $value = $params->{value} || [$params->{defaultValue}] || [0];
    my $name = $params->{name} || "ldapLinkId";
	my $size = $params->{size} || 1;
	my $multiple = $params->{multiple} || 0;
	my $extras = $params->{extras} || "";
    return selectList({
                name=>$name,
                options=>WebGUI::LDAPLink::getList(),
                value=>$value,
				size=>$size,
				multiple=>$multiple,
				extras=>$extras
                });
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
		extras=>'onkeyup="doInputCheck(this.form.'.$params->{name}.',\'0123456789-()+ \')" '.$params->{extras},
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
	my $userId = $session{user}{userId};
	my $templateList = WebGUI::Asset::Template->getList($params->{namespace});

	#Remove entries from template list that the user does not have permission to view.
        for my $assetId ( keys %{$templateList} ) {
       	  my $asset = WebGUI::Asset::Template->new($assetId);

          if (!$asset->canView($userId)) {
            delete $templateList->{$assetId}; 
	  }
	}
        return selectList({
                name=>$name,
                options=>$templateList,
                value=>[$templateId],
		extras=>$params->{extras}
                });
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



1;


