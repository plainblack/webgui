package WebGUI::Wobject::MailForm;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "MailForm";
our $name = WebGUI::International::get(1,$namespace);

our @fields = qw(width fromField fromStatus toField toStatus
	ccField ccStatus bccField bccStatus subjectField subjectStatus acknowledgement storeEntries);

#-------------------------------------------------------------------
sub duplicate {
	my ($w, %data, $sth);
	tie %data, 'Tie::CPHash';
	$w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::MailForm->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		width=>$_[0]->get("width"),
        	fromField=>$_[0]->get("fromField"),
        	fromStatus=>$_[0]->get("fromStatus"),
        	toField=>$_[0]->get("toField"),
        	toStatus=>$_[0]->get("toStatus"),
        	ccField=>$_[0]->get("ccField"),
        	ccStatus=>$_[0]->get("ccStatus"),
        	bccField=>$_[0]->get("bccField"),
        	bccStatus=>$_[0]->get("bccStatus"),
        	subjectField=>$_[0]->get("subjectField"),
        	subjectStatus=>$_[0]->get("subjectStatus"),		
		acknowledgement=>$_[0]->get("acknowledgement"),
		storeEntries=>$_[0]->get("storeEntries"),
		});
	$sth = WebGUI::SQL->read("select * from MailForm_field where wobjectId=".$_[0]->get("wobjectId"));
    	while (%data = $sth->hash) {
		$data{MailForm_fieldId} = "new";
		$w->setCollateral("MailForm_field","MailForm_fieldId",\%data);
    	}
    	$sth->finish;	
}

#-------------------------------------------------------------------
sub purge {
    	WebGUI::SQL->write("delete from MailForm_field where wobjectId=".$_[0]->get("wobjectId"));
    	WebGUI::SQL->write("delete from MailForm_entry where wobjectId=".$_[0]->get("wobjectId"));
    	WebGUI::SQL->write("delete from MailForm_entryData where wobjectId=".$_[0]->get("wobjectId"));
    	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
	$_[0]->SUPER::set($_[1],[@fields]);
}

#-------------------------------------------------------------------
sub uiLevel {
        return 5;
}

#-------------------------------------------------------------------
sub www_deleteField {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	return $_[0]->confirm(WebGUI::International::get(19,$namespace),
       		WebGUI::URL::page('func=deleteFieldConfirm&wid='.$_[0]->get("wobjectId").'&fid='.$session{form}{fid}));
}

#-------------------------------------------------------------------
sub www_deleteFieldConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->deleteCollateral("MailForm_field","MailForm_fieldId",$session{form}{fid});
	$_[0]->reorderCollateral("MailForm_field","MailForm_fieldId");
       	return "";
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my ($output, $f, $proceed);
	my %fieldStatus = ( 1 => WebGUI::International::get(4, $namespace),
		2 => WebGUI::International::get(5, $namespace),
		3 => WebGUI::International::get(6, $namespace) );
        # field defaults
        my %data = (
            width => 45,
            fromField => '',
            fromStatus => 3,
            toField => $session{setting}{companyEmail},
            toStatus => 1,
            ccField => '',
            ccStatus => 1,
            bccField => '',
            bccStatus => 1,
            subjectField => WebGUI::International::get(2, $namespace),
            subjectStatus => 3,
            acknowledgement => WebGUI::International::get(3, $namespace),
            storeEntries => 1,
        );
        # initialize fields from existing data, if any
        foreach my $field (@fields) {
            $data{$field} = $_[0]->get($field) if ($_[0]->get($field));
        }
		
        if ($_[0]->get("wobjectId") eq "new") {
            $proceed = 1;
        }
	$output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(7, $namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->integer("width",WebGUI::International::get(8, $namespace),$_[0]->get("width") || 45);
        $f->raw( $_[0]->_textSelectRow("fromField",WebGUI::International::get(10, $namespace),$data{fromField},128,
            "fromStatus",\%fieldStatus,$data{fromStatus}) );
        $f->raw( $_[0]->_textSelectRow("toField",WebGUI::International::get(11, $namespace),$data{toField},128,
            "toStatus",\%fieldStatus,$data{toStatus}) );
        $f->raw( $_[0]->_textSelectRow("ccField",WebGUI::International::get(12, $namespace),$data{ccField},128,
            "ccStatus",\%fieldStatus,$data{ccStatus}) );
        $f->raw( $_[0]->_textSelectRow("bccField",WebGUI::International::get(13, $namespace),$data{bccField},128,
            "bccStatus",\%fieldStatus,$data{bccStatus}) );
        $f->raw( $_[0]->_textSelectRow("subjectField",WebGUI::International::get(14, $namespace),$data{subjectField},128,
            "subjectStatus",\%fieldStatus,$data{subjectStatus}) );		
	$f->HTMLArea("acknowledgement",WebGUI::International::get(16, $namespace),$_[0]->get("acknowledgement") || WebGUI::International::get(3, $namespace));
	$f->yesNo("storeEntries",WebGUI::International::get(26,$namespace),[ $data{storeEntries} ]);
	$f->yesNo("proceed",WebGUI::International::get(15,$namespace),$proceed);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
	return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my ($property);
	foreach my $field (@fields) {
		$property->{$field} = $session{form}{$field};
	}
	$_[0]->SUPER::www_editSave($property);
        if ($session{form}{proceed}) {
            return $_[0]->www_editField();
        } else {
            return "";
        }
}

#-------------------------------------------------------------------
sub www_editField {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
    my ($output, %field, $f);
    tie %field, 'Tie::CPHash';
	my %fieldStatus = ( 1 => WebGUI::International::get(4, $namespace),
		2 => WebGUI::International::get(5, $namespace),
		3 => WebGUI::International::get(6, $namespace) );
		
	my %fieldTypes = ( text => "Textbox",
		checkbox => "Checkbox",
		textarea => "Textarea",
		date => "Date",
		email => "Email Address",
		url => "URL",
		yesNo => "Yes/No",
		select => "Drop-Down Box" );
    
        %field = WebGUI::SQL->quickHash("select * from MailForm_field where MailForm_fieldId='$session{form}{fid}'");
        $output = helpIcon(2,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(20,$namespace).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $session{form}{fid} = "new" if ($session{form}{fid} eq "");
        $f->hidden("fid",$session{form}{fid});
        $f->hidden("func","editFieldSave");
        $f->text("name",WebGUI::International::get(21,$namespace),$field{name});
        my $status = [ $field{status} ||= 3 ]; # make it modifiable by default
        $f->select("status",\%fieldStatus,WebGUI::International::get(22,$namespace),$status); 
        my $type = [ $field{type} ||= "text" ];
        $f->select("type",\%fieldTypes,WebGUI::International::get(23,$namespace),$type);
        $f->textarea("possibleValues",WebGUI::International::get(24,$namespace),$field{possibleValues});
        $f->text("defaultValue",WebGUI::International::get(25,$namespace),$field{defaultValue});
        $f->yesNo("proceed",WebGUI::International::get(15,$namespace));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editFieldSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
    my ($seq);
        if ($session{form}{fid} eq "new") {
            ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from MailForm_field where wobjectId=".$_[0]->get("wobjectId"));
            $session{form}{fid} = getNextId("MailForm_fieldId");
            WebGUI::SQL->write("insert into MailForm_field (wobjectId,MailForm_fieldId,sequenceNumber) values
                (".$_[0]->get("wobjectId").",$session{form}{fid},".($seq+1).")");
        }
        WebGUI::SQL->write("update MailForm_field set name=".quote($session{form}{name}).
    		", status=".quote($session{form}{status}).
    		", type=".quote($session{form}{type}).
    		", possibleValues=".quote($session{form}{possibleValues}).
    		", defaultValue=".quote($session{form}{defaultValue}).
    		" where MailForm_fieldId=$session{form}{fid}");
        if ($session{form}{proceed}) {
            $session{form}{fid} = "new";
            return $_[0]->www_editField();
        } else {
            return "";
        }
}

#-------------------------------------------------------------------
sub www_moveFieldDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->moveCollateralDown("MailForm_field","MailForm_fieldId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveFieldUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->moveCollateralUp("MailForm_field","MailForm_fieldId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($output, $sth, $f, $row, %data);
	tie %data, 'Tie::CPHash';
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description.'<p>';
	
	# get all international text for each field caption
	my %text = (
		from => WebGUI::International::get(10, $namespace),
		to => WebGUI::International::get(11, $namespace),
		cc => WebGUI::International::get(12, $namespace),
		bcc => WebGUI::International::get(13, $namespace),
		subject => WebGUI::International::get(14, $namespace),
	);
	
    if ($session{var}{adminOn}) {
        $output .= '<a href="'.WebGUI::URL::page('func=editField&wid='.$_[0]->get("wobjectId")).'">'
            .WebGUI::International::get(9,$namespace).'</a>';
    }
	
	$f = WebGUI::HTMLForm->new();
	$f->hidden("wid",$_[0]->get("wobjectId"));
	$f->hidden('func','send');
	
    foreach my $field (qw(from to cc bcc subject)) {
        if ($_[0]->get("${field}Status") == 1) {
            # Hidden field, don't show on form for security reasons
        } else {
            my $row = '<tr><td class="formDescription" valign="';
            if ($_[0]->get("${field}Status") == 2) {
                # Read-only field
                $row .= "middle\">\u$field:&nbsp;</td><td class='tableData' valign='middle'>".$_[0]->get("${field}Field");
            } else {
                # Modifiable Field
                if ($field eq 'content') {
                    my $taWidth = $_[0]->get("width") - 9;
                    $row .= "top\">".$text{$field}.":&nbsp;</td><td><textarea name='${field}Field' rows='10' cols='$taWidth'>".$_[0]->get("${field}Field")."</textarea>";
                } else {
                    my $caption = $text{$field};
                    $row .= "top\">$caption:&nbsp;</td><td><input type='text' name='${field}Field' size='".$_[0]->get("width")."' maxlength='128' value='".$_[0]->get("${field}Field")."'>";
                }
            }
            $row .= "</td></tr>";
            $f->raw($row);
        }
    }	
	
	$sth = WebGUI::SQL->read("select * from MailForm_field where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%data = $sth->hash) {
		# process macros on default values
		$data{defaultValue} = $_[0]->processMacros($data{defaultValue});
		if ($data{status} == 1) {
			# hidden field, don't show on form for security reasons
			$row = "";
			# but show for admins
			if ($session{var}{adminOn}) {
				$row = "<tr><td class='formDescription' valign='middle'>\u".$data{name}." (hidden)&nbsp;</td><td class='tableData' valign='middle'>".$data{defaultValue};
				$row .= $_[0]->_fieldAdminIcons($data{MailForm_fieldId});
			}
		} elsif ($data{status} == 2) {
			# read-only field
			$row = "<tr><td class='formDescription' valign='middle'>\u".$data{name}."&nbsp;</td><td class='tableData' valign='middle'>".$data{defaultValue};
			if ($session{var}{adminOn}) {
				$row .= $_[0]->_fieldAdminIcons($data{MailForm_fieldId});
			}
			$row .= "</td></tr>";
		} else {
			# modifiable field
			$row = $_[0]->_createField(\%data);
		}
		$f->raw($row);
	}
	
	$f->submit("Send");
	$output .= $f->print;
	
	return $_[0]->processMacros($output);	
}

#-------------------------------------------------------------------
sub _createField {
	my ($self, $data) = @_;
	
	my $name = WebGUI::URL::urlize($data->{name});
	my $f = WebGUI::HTMLForm->new( 'noTable' );

	SWITCH: for ($data->{type}) {
		/^text$/ && do {
			# maxlength, extras, subtext
			$f->text($name, $data->{name}, $data->{defaultValue}, 255, "", "", $self->get("width"));
			last SWITCH;
		};
		/^email$/ && do {
			# maxlength, extras, subtext
			$f->email($name, $data->{name}, $data->{defaultValue}, 255, "", "", $self->get("width"));
			last SWITCH;
		};
		/^url$/ && do {
			# maxlength, extras, subtext
			$f->url($name, $data->{name}, $data->{defaultValue}, 255, "", "", $self->get("width"));
			last SWITCH;
		};
		/^textarea$/ && do {
			# subtext, extras, wrap, rows, cols
			$f->textarea($name, $data->{name}, $data->{defaultValue}, "", "", "", 10, $self->get("width") - 9);
			last SWITCH;
		};
		/^date$/ && do {
			# extras, subtext
			$f->date($name, $data->{name}, $data->{defaultValue}, "", "", 15); # use small size for a date box
			last SWITCH;
		};
		/^yesNo$/ && do {
			# extras, subtext
			# allow user to enter friendly yes/no for default
			my $value;
			if ($data->{defaultValue} =~ /yes/i) {
				$value = 1;
			} elsif ($data->{defaultValue} =~ /no/i) {
				$value = 0;
			} else {
				$value = 2;
			}
			$f->yesNo($name, $data->{name}, $value, "", "");
			last SWITCH;
		};
		/^checkbox$/ && do {
			# checked, subtext, extras
			# the value option is used for checking the box here
			my $value = ($data->{defaultValue} =~ /checked/i) ? 1 : "";
			$f->checkbox($name, $data->{name}, $value, "", "", "");
			last SWITCH;
		};
		/^select$/ && do {
			# size, multiple, extras, subtext
			my %selectOptions;
			tie %selectOptions, 'Tie::IxHash';
			# add an empty option if no default value is provided
			foreach (split(/\n/, $data->{possibleValues})) {
				$selectOptions{$_} = $_[0]->processMacros($_);
			}
			$f->select($name, \%selectOptions, $data->{name}, [$data->{defaultValue}], "", "", "", "");
			last SWITCH;
		};
	}
	
	my $row = '<tr><td class="formDescription" valign="top">'.$data->{name}.'</td><td class="tableData">'.$f->printRowsOnly();
	if ($session{var}{adminOn}) {
		$row .= $self->_fieldAdminIcons($data->{MailForm_fieldId});
	}
	$row .= '</td></tr>';
	return $row;
}

#-------------------------------------------------------------------
sub _fieldAdminIcons {
	my $fid = $_[1];
	return ' '.deleteIcon('func=deleteField&wid='.$_[0]->get("wobjectId").'&fid='.$fid)
	    .editIcon('func=editField&wid='.$_[0]->get("wobjectId").'&fid='.$fid)
	    .moveUpIcon('func=moveFieldUp&wid='.$_[0]->get("wobjectId").'&fid='.$fid)
	    .moveDownIcon('func=moveFieldDown&wid='.$_[0]->get("wobjectId").'&fid='.$fid);
}

# Other methods
#-------------------------------------------------------------------
# textSelectRow basically combines HTMLForm::text with HTMLForm::select
# to put a text box and select box on the same table row
sub _textSelectRow {
	my ($self, $textName, $textLabel, $textValue, $textMaxLength, $selectName, $selectOptions, $selectValue) = @_;
	my $output;
	$textValue = WebGUI::Form::_fixQuotes($textValue);
	my $textSize = $session{setting}{textBoxSize};
	$output = '<input type="text" name="'.$textName.'" value="'.$textValue.'" size="'.
		$textSize.'" maxlength="'.$textMaxLength.'">';
	$output .= ' ';
	my $selectSize = 1;
	$output .= '<select name="'.$selectName.'" size="'.$selectSize.'">';
	foreach my $key (keys %$selectOptions) {
		$output .= '<option value="'.$key.'"';
		if ($selectValue eq $key) {
		   $output .= " selected";
		}
		$output .= '>'.${$selectOptions}{$key};
	}
	$output .= '</select>';
	return '<tr><td class="formDescription" valign="top">'.$textLabel.'</td><td class="tableData">'.$output."</td></tr>\n";
}

#-------------------------------------------------------------------
sub www_send {
	$session{form}{toField} = $_[0]->get("toField") unless ($session{form}{toField});
	$session{form}{fromField} = $_[0]->get("fromField") unless ($session{form}{fromField});
	$session{form}{subjectField} = $_[0]->get("subjectField") unless ($session{form}{subjectField});
	$session{form}{ccField} = $_[0]->get("ccField") unless ($session{form}{ccField});
	$session{form}{bccField} = $_[0]->get("bccField") unless ($session{form}{bccField});
	
	# store results
	my $entryId = getNextId("MailForm_entryId");
	if ($_[0]->get("storeEntries")) {
		WebGUI::SQL->write("insert into MailForm_entry values ($entryId, ".$_[0]->get("wobjectId").", ".$session{user}{userId}.", ".quote($session{user}{username}).", ".quote($session{env}{REMOTE_ADDR}).", ".quote(time()).")");
	}
	
	# create the message from all fields
	my ($message, $sth, %data);
	$sth = WebGUI::SQL->read("select * from MailForm_field where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%data = $sth->hash) {
		my $urlizedName = WebGUI::URL::urlize($data{name});
		my $value = $session{form}{$urlizedName} || $_[0]->processMacros($data{defaultValue});
		# fix value for special types
		if ($data{type} eq "yesNo") {
			$value = ($value == 1) ? "yes" : "no";
		} elsif ($data{type} eq "checkbox") {
			$value = ($value) ? "checked" : "not checked";
		}
		
		# store results
		if ($_[0]->get("storeEntries")) {
			WebGUI::SQL->write("insert into MailForm_entryData values ($entryId, ".$_[0]->get("wobjectId").", ".$data{sequenceNumber}.", ".quote($data{name}).", ".quote($value).")");
		}
		
		$data{name} .= ":" unless ($data{name} =~ /:$/);
		$message .= "$data{name} $value\n";
	}
	my $error;	
	my $to = $session{form}{toField};
	if ($to =~ /\@/) {
		# send a direct email if the To field is an email address
		my ($subject, $cc, $from, $bcc) = ($session{form}{subjectField},$session{form}{ccField}, 
			$session{form}{fromField},$session{form}{bccField});
		# From is either the logged on user, filled out, or the site
		if ($from && $session{user}) {
			# add their name from their profile if available
			$from = ("$session{user}{firstName} $session{user}{lastName}" || $session{user}{username}) . " <$from>";
		} elsif ($from) {
			# leave the from as-is
		}
		WebGUI::Mail::send($to,$subject,$message,$cc,$from,$bcc);
	} else {
		my ($userId) = WebGUI::SQL->quickArray("select userId from users where username=".quote($to));
		my $groupId;
		# if no user is found, try finding a matching group
		unless ($userId) {
			($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($to));
		}
		unless ($userId || $groupId) {
			$error = "Unable to send message, no user or group found.";
		} else {
			WebGUI::MessageLog::addEntry($userId, $groupId, $session{form}{subjectField}, $message);
		}
	}
	
	my $output = $_[0]->displayTitle;
	$error = $@ if $@;
	$output .= ($error || $_[0]->get("acknowledgement"))."<p>\n<a href=\"./$session{page}{urlizedTitle}\">".WebGUI::International::get(18, $namespace)."</a>";
	return $output;
}

1;


