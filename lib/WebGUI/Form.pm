package WebGUI::Form;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

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
sub groupList {
	my ($output, %hash, @array);
	tie %hash, 'Tie::IxHash';
 	%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
        $array[0] = $_[1];
        $output = selectList($_[0],\%hash,\@array);
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
        my ($output, $assistance, $name, $size, $maxLength, $value, $events);
        ($name, $size, $maxLength, $value, $assistance, $events) = @_;
        if ($size eq "") {
                $size = 15;
        }
	if ($maxLength ne "") {
		$maxLength = ' maxlength="'.$maxLength.'"';
	}
	if ($events ne "") {
		$events = ' '.$events;
	}
	if ($assistance == 1) {
		$assistance = '<input type="button" style="font-size: 8pt;" onClick="window.dateField = this.form.'.$name.';calendar = window.open(\''.$session{setting}{lib}.'/calendar.html\',\'cal\',\'WIDTH=200,HEIGHT=250\');return false" value="'.WebGUI::International::get(34).'">';
	}
	$value = _fixQuotes($value);
        $output = '<input type="text" name="'.$name.'" value="'.$value.'" size="'.$size.'" '.$maxLength.$events.'>'.$assistance;
        return $output;
}

#-------------------------------------------------------------------
sub textArea {
        my ($output, $name, $value, $cols, $rows, $htmlEdit, $wrap);
        ($name, $value, $cols, $rows, $htmlEdit, $wrap) = @_;
	$output = '<script language="JavaScript">function fixChars(element) {element.value = element.value.replace(/~V/mg,"-");}</script>';
        if ($cols eq "") {
                $cols = 50;
        }
        if ($rows eq "") {
                $rows = 5;
        }
	if ($htmlEdit > 0) {
		$output .= '<script language="JavaScript"> var formObj; var extrasDir="'.$session{setting}{lib}.'"; function openEditWindow(obj) { formObj = obj;  if (navigator.userAgent.substr(navigator.userAgent.indexOf("MSIE")+5,1)>=5)  window.open("'.$session{setting}{lib}.'/ieEdit.html","editWindow","width=490,height=400");  else  window.open("'.$session{setting}{lib}.'/nonIeEdit.html","editWindow","width=450,height=240"); } function setContent(content) { formObj.value = content; } </script>';
		$output .= '<input type="button" onClick="openEditWindow(this.form.'.$name.')" value="'.WebGUI::International::get(171).'" style="font-size: 8pt;"><br>';
	}
        if ($wrap eq "") {
                $wrap = "virtual";
        }
        $output .= '<textarea name="'.$name.'" cols="'.$cols.'" rows="'.$rows.'" wrap="'.$wrap.'" onBlur="fixChars(this.form.'.$name.')">'.$value.'</textarea>';
        return $output;
}



1;
