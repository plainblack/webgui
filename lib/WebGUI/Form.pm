package WebGUI::Form;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::Session;

#-------------------------------------------------------------------
sub _fixQuotes {
        my $value = shift;
	$value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------
sub checkbox {
        my ($output, $name, $value, $checked);
        ($name, $value, $checked) = @_;
        if ($checked) {
                $checked = ' checked';
        }
        $output = '<input type="checkbox" name="'.$name.'" value="'.$value.'"'.$checked.'>';
        return $output;
}

#-------------------------------------------------------------------
sub file {
        my ($output, $name);
        ($name) = @_;
        $output = '<input type="file" name="'.$name.'">';
        return $output;
}

#-------------------------------------------------------------------
sub hidden {
        my ($output, $name, $value);
        ($name, $value) = @_;
	$value = _fixQuotes($value);
        $output = '<input type="hidden" name="'.$name.'" value="'.$value.'">';
        return $output;
}

#-------------------------------------------------------------------
sub password {
        my ($output, $name, $size, $maxLength, $value);
        $name = shift;
        $size = shift;
        if ($size eq "") {
                $size = 15;
        }
        $maxLength = shift;
        if ($maxLength ne "") {
                $maxLength = ' maxlength="'.$maxLength.'"';
        }
        $value = shift;
        $output = '<input type="password" name="'.$name.'" value="'.$value.'" size="'.$size.'" '.$maxLength.'>';
        return $output;
}

#-------------------------------------------------------------------
sub radio {
        my ($output, $name, $value, $checked);
        ($name, $value, $checked) = @_;
        if ($checked) {
                $checked = ' checked';
        }
        $output = '<input type="radio" name="'.$name.'" value="'.$value.'"'.$checked.'>';
        return $output;
}

#-------------------------------------------------------------------
# eg: selectList(name, valueListHashref, selectedArrayref, size, multipleSelection, onChange)
sub selectList {
	my ($output, $valueList, $key, $item, $name, $selected, $size, $multiple, $onChange);
	($name, $valueList, $selected, $size, $multiple, $onChange) = @_;
	if ($size > 1) {
		$size = ' size="'.$size.'"';
	}		
	if ($multiple > 0) {
		$multiple = ' multiple="1"';
	}
	if ($onChange ne "") {
		$onChange = ' onChange="'.$onChange.'"';
	}	
	$output	= '<select name="'.$name.'"'.$size.$multiple.$onChange.'>'; 
	foreach $key (keys %{$valueList}) {
		$output .= '<option value="'.$key.'"';
		foreach $item (@$selected) {
			if ($item eq $key) {
				$output .= " selected";
			}
		}
		$output .= '>'.${$valueList}{$key};
	}
	$output	.= '</select>'; 
        return $output;
}

#-------------------------------------------------------------------
sub submit {
        my ($output, $name, $value);
        $value = shift;
        $name = shift;
        $value = _fixQuotes($value);
        $output = '<input type="submit" name="'.$name.'" value="'.$value.'">';
        return $output;
}

#-------------------------------------------------------------------
sub text {
        my ($output, $assistance, $name, $size, $maxLength, $value);
        ($name, $size, $maxLength, $value, $assistance) = @_;
        if ($size eq "") {
                $size = 15;
        }
	if ($maxLength ne "") {
		$maxLength = ' maxlength="'.$maxLength.'"';
	}
	if ($assistance == 1) {
		$assistance = '<input type="button" style="font-size: 8pt;" onClick="window.dateField = this.form.'.$name.';calendar = window.open(\''.$session{setting}{lib}.'/calendar.html\',\'cal\',\'WIDTH=200,HEIGHT=250\');return false" value="set date">';
	}
	$value = _fixQuotes($value);
        $output = '<input type="text" name="'.$name.'" value="'.$value.'" size="'.$size.'" '.$maxLength.'>'.$assistance;
        return $output;
}

#-------------------------------------------------------------------
sub textArea {
        my ($output, $name, $value, $cols, $rows, $htmlEdit, $wrap);
        ($name, $value, $cols, $rows, $htmlEdit, $wrap) = @_;
        if ($cols eq "") {
                $cols = 50;
        }
        if ($rows eq "") {
                $rows = 5;
        }
	if ($htmlEdit > 0) {
		$output = '<input type="button" onClick="colorText(this.form.'.$name.')" value="color" style="font-size: 8pt;"><input type="button" onClick="boldText(this.form.'.$name.')" value="bold" style="font-size: 8pt;"><input type="button" onClick="italicText(this.form.'.$name.')" value="italics" style="font-size: 8pt;"><input type="button" onClick="centerText(this.form.'.$name.')" value="center" style="font-size: 8pt;"><input type="button" onClick="list(this.form.'.$name.')" value="list" style="font-size: 8pt;"><input type="button" onClick="url(this.form.'.$name.')" value="link" style="font-size: 8pt;"><input type="button" onClick="email(this.form.'.$name.')" value="email" style="font-size: 8pt;"><input type="button" onClick="image(this.form.'.$name.')" value="image" style="font-size: 8pt;"><input type="button" onClick="showMe(this.form.'.$name.')" value="show me" style="font-size: 8pt;"><input type="button" onClick="copyright(this.form.'.$name.')" value="(C)" style="font-size: 8pt;"><input type="button" onClick="registered(this.form.'.$name.')" value="(R)" style="font-size: 8pt;"><input type="button" onClick="trademark(this.form.'.$name.')" value="TM" style="font-size: 8pt;"><br>';
	}
        if ($wrap eq "") {
                $wrap = "virtual";
        }
        $output .= '<textarea name="'.$name.'" cols="'.$cols.'" rows="'.$rows.'" wrap="'.$wrap.'">'.$value.'</textarea>';
        return $output;
}



1;
