package WebGUI::Wobject::DataForm;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::MessageLog;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Wobject);

#-------------------------------------------------------------------
sub _createField {
	my $data = $_[0];
	my %param;
	$param{name} = $data->{name};
	$param{name} = "field_".$data->{sequenceNumber} if ($param{name} eq ""); # Empty fieldname not allowed
	$session{form}{$param{name}} =~ s/\^.*?\;//gs ; # remove macro's from user input
	$param{value} = $data->{value};
	$param{size} = $data->{width};
	$param{rows} = $data->{rows} || 5;
	$param{columns} = $data->{width};
	$param{vertical} = 1;
	if ($data->{type} eq "checkbox") {
		$param{value} = ($data->{defaultValue} =~ /checked/i) ? 1 : "";
	}
	if (isIn($data->{type},qw(selectList checkList))) {
		my @defaultValues;
		if ($session{form}{$param{name}}) {
                	@defaultValues = $session{cgi}->param($param{name});
                } else {
                	foreach (split(/\n/, $data->{value})) {
                        	s/\s+$//; # remove trailing spaces
                                push(@defaultValues, $_);
                	}
                }
		$param{value} = \@defaultValues;
	}
	if (isIn($data->{type},qw(selectList checkList radioList))) {
		delete $param{size};
		my %options;
                tie %options, 'Tie::IxHash';
                foreach (split(/\n/, $data->{possibleValues})) {
                	s/\s+$//; # remove trailing spaces
                        $options{$_} = $_;
                }
		$param{options} = \%options;
	} 
	if ($data->{type} eq "yesNo") {
		if ($data->{defaultValue} =~ /yes/i) {
                	$param{value} = 1;
                } elsif ($data->{defaultValue} =~ /no/i) {
                	$param{value} = 0;
                }
	}
	my $cmd = "WebGUI::Form::".$data->{type};
	return &$cmd(\%param);
}

#-------------------------------------------------------------------
sub _fieldAdminIcons {
	my $fid = $_[1];
	my $output;
	$output = deleteIcon('func=deleteField&wid='.$_[0]->get("wobjectId").'&fid='.$fid) unless ($_[2]);
	$output .= editIcon('func=editField&wid='.$_[0]->get("wobjectId").'&fid='.$fid)
	    .moveUpIcon('func=moveFieldUp&wid='.$_[0]->get("wobjectId").'&fid='.$fid)
	    .moveDownIcon('func=moveFieldDown&wid='.$_[0]->get("wobjectId").'&fid='.$fid);
	return $output;
}

#-------------------------------------------------------------------
sub duplicate {
	my ($w, %data, $sth);
	tie %data, 'Tie::CPHash';
	$w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::DataForm->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
	$sth = WebGUI::SQL->read("select * from DataForm_field where wobjectId=".$_[0]->get("wobjectId"));
    	while (%data = $sth->hash) {
		$data{DataForm_fieldId} = "new";
		$w->setCollateral("DataForm_field","DataForm_fieldId",\%data);
    	}
    	$sth->finish;	
}

#-------------------------------------------------------------------
sub getListTemplateVars {
	my $self = shift;
	my $var = shift;
	my @fieldLoop;
	$var->{"back.url"} = WebGUI::URL::page();
	$var->{"back.label"} = WebGUI::International::get(18,$self->get("namespace"));
	my $a = WebGUI::SQL->read("select DataForm_fieldId,name,label,isMailField,type from DataForm_field
		where wobjectId=".$self->get("wobjectId")." order by sequenceNumber");
	while (my $field = $a->hashRef) {
		push(@fieldLoop,{
			"field.name"=>$field->{name},
			"field.id"=>$field->{DataForm_fieldId},
			"field.label"=>$field->{label},
			"field.isMailField"=>$field->{isMailField},
			"field.type"=>$field->{type},
			});
	}
	$a->finish;
	$var->{field_loop} = \@fieldLoop;
	my @recordLoop;
	my $a = WebGUI::SQL->read("select ipAddress,username,userid,submissionDate,DataForm_entryId from DataForm_entry 
		where wobjectId=".$self->get("wobjectId")." order by submissionDate desc");
	while (my $record = $a->hashRef) {
		my @dataLoop;
		my $b = WebGUI::SQL->read("select b.name, b.label, b.isMailField, a.value from DataForm_entryData a left join DataForm_field b
			on a.name=b.name where a.DataForm_entryId=".$record->{DataForm_entryId}."
			order by b.sequenceNumber");
		while (my $data = $b->hashRef) {
			push(@dataLoop,{
				"record.data.name"=>$data->{name},
				"record.data.label"=>$data->{label},
				"record.data.value"=>$data->{value},
				"record.data.isMailField"=>$data->{isMailField}
				});
		}
		$b->finish;
		push(@recordLoop,{
			"record.ipAddress"=>$record->{ipAddress},
			"record.edit.url"=>WebGUI::URL::page("func=view&entryId=".$record->{DataForm_entryId}."&wid=".$self->get("wobjectId")),
			"record.username"=>$record->{username},
			"record.userId"=>$record->{userId},
			"record.submissionDate.epoch"=>$record->{submissionDate},
			"record.submissionDate.human"=>WebGUI::DateTime::epochToHuman($record->{submissionDate}),
			"record.entryId"=>$record->{DataForm_entryId},
			"record.data_loop"=>\@dataLoop
			});
	}
	$a->finish;
	$var->{record_loop} = \@recordLoop;
	return $var;
}

#-------------------------------------------------------------------
sub getRecordTemplateVars {
	my $self = shift;
	my $var = shift;
	$var->{error_loop} = [] unless (exists $var->{error_loop});
	$var->{canEdit} = (WebGUI::Privilege::canEditWobject($self->get("wobjectId")));
	$var->{"entryList.url"} = WebGUI::URL::page('func=view&entryId=list&wid='.$self->get("wobjectId"));
	$var->{"entryList.label"} = WebGUI::International::get(86,$self->get("namespace"));
	$var->{"export.tab.url"} = WebGUI::URL::page('func=exportTab&wid='.$self->get("wobjectId"));
	$var->{"export.tab.label"} = WebGUI::International::get(84,$self->get("namespace"));
	$var->{"back.url"} = WebGUI::URL::page();
	$var->{"back.label"} = WebGUI::International::get(18,$self->get("namespace"));
	$var->{"addField.url"} = WebGUI::URL::page('func=editField&wid='.$self->get("wobjectId"));
	$var->{"addField.label"} = WebGUI::International::get(76,$self->get("namespace"));
	$var->{"form.start"} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({name=>"wid",value=>$self->get("wobjectId")})
		.WebGUI::Form::hidden({name=>"func",value=>"process"});
	my @fields;
	my $where = "where a.wobjectId=".$self->get("wobjectId");
	my $select = "select a.name, a.DataForm_fieldId, a.label, a.status, a.isMailField, a.subtext, a.type, a.defaultValue, a.possibleValues, a.width, a.rows";
	my $join;
	if ($var->{entryId}) {
		$var->{"form.start"} .= WebGUI::Form::hidden({name=>"entryId",value=>$var->{entryId}});
		my $entry = $self->getCollateral("DataForm_entry","DataForm_entryId",$var->{entryId});
		$var->{ipAddress} = $entry->{ipAddress};
		$var->{username} = $entry->{username};
		$var->{userId} = $entry->{userId};
		$var->{date} = WebGUI::DateTime::epochToHuman($entry->{submissionDate});
		$var->{epoch} = $entry->{submissionDate};
		$var->{"edit.URL"} = WebGUI::URL::page('func=view&wid='.$self->get("wobjectId").'&entryId='.$var->{entryId});
		$where .= " and b.DataForm_entryId=".$var->{entryId};
		$join = "left join DataForm_entryData as b on a.name=b.name";
		$select .= ", b.value";
	}
	my %data;
	tie %data, 'Tie::CPHash';
	my $sth = WebGUI::SQL->read("$select from DataForm_field as a $join $where order by a.sequenceNumber");
	while (%data = $sth->hash) {
		my $formValue = $session{form}{$data{name}};
		if (defined $formValue) {
			$data{value} = $formValue;
		} elsif (not exists $data{value}) {
			$data{value} = WebGUI::Macro::process($data{defaultValue});
		}
		my $hidden = (($data{status} eq "hidden" || ($data{isMailField} && !$self->get("mailData"))) && !$session{var}{adminOn});
		push(@fields,{
			"field.form" => _createField(\%data),
			"field.name" => $data{name},
			"field.value" => $data{value},
			"field.label" => $data{label},
			"field.isMailField" => $data{isMailField},
			"field.isHidden" => $hidden,
			"field.isDisplayed" => ($data{status} eq "displayed" && !$hidden),
			"field.isEditable" => ($data{status} eq "editable" && !$hidden),
			"field.isRequired" => ($data{status} eq "required" && !$hidden),
			"field.subtext" => $data{subtext},
			"field.controls" => $self->_fieldAdminIcons($data{DataForm_fieldId},$data{isMailField})
			});
	}
	$sth->finish;
	$var->{field_loop} = \@fields;
	$var->{"form.send"} = WebGUI::Form::submit({value=>WebGUI::International::get(73, $self->get("namespace"))});
	$var->{"form.save"} = WebGUI::Form::submit();
	$var->{"form.end"} = "</form>";	
	return $var;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
		-extendedProperties=>{
			acknowledgement=>{},
			emailTemplateId=>{
				defaultValue=>2
				},
			acknowlegementTemplateId=>{
				defaultValue=>3,
				},
			listTemplateId=>{
				defaultValue=>1,
				},
			mailData=>{
				defaultValue=>0
				}
			},
		-useTemplate=>1
		);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
    	WebGUI::SQL->write("delete from DataForm_field where wobjectId=".$_[0]->get("wobjectId"));
    	WebGUI::SQL->write("delete from DataForm_entry where wobjectId=".$_[0]->get("wobjectId"));
    	WebGUI::SQL->write("delete from DataForm_entryData where wobjectId=".$_[0]->get("wobjectId"));
    	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub sendEmail {
	my $var = $_[1];
	my $message = WebGUI::Macro::process($_[0]->processTemplate($_[0]->get("emailTemplateId"),$var));
	my ($to, $subject, $from, $bcc, $cc);
	foreach my $row (@{$var->{field_loop}}) {
		if ($row->{"field.name"} eq "to") {
			$to = $row->{"field.value"};
		} elsif ($row->{"field.name"} eq "from") {
			$from = $row->{"field.value"};
		} elsif ($row->{"field.name"} eq "cc") {
			$cc = $row->{"field.value"};
		} elsif ($row->{"field.name"} eq "bcc") {
			$bcc = $row->{"field.value"};
		} elsif ($row->{"field.name"} eq "subject") {
			$subject = $row->{"field.value"};
		}
	}
	if ($to =~ /\@/) {
		WebGUI::Mail::send(
			$to,
			$subject,
			$message,
			$cc,
			$from,
			$bcc
			);
	} else {
                my ($userId) = WebGUI::SQL->quickArray("select userId from users where username=".quote($to));
                my $groupId;
                # if no user is found, try finding a matching group
                unless ($userId) {
                        ($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($to));
                }
                unless ($userId || $groupId) {
                        WebGUI::ErrorHandler::warn($_[0]->get("wobjectId").": Unable to send message, no user or group found.");
                } else {
                        WebGUI::MessageLog::addEntry($userId, $groupId, $subject, $message);
                }
        }
}

#-------------------------------------------------------------------
sub uiLevel {
        return 5;
}

#-------------------------------------------------------------------
sub www_deleteField {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	return $_[0]->confirm(WebGUI::International::get(19,$_[0]->get("namespace")),
       		WebGUI::URL::page('func=deleteFieldConfirm&wid='.$_[0]->get("wobjectId").'&fid='.$session{form}{fid}));
}

#-------------------------------------------------------------------
sub www_deleteFieldConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->deleteCollateral("DataForm_field","DataForm_fieldId",$session{form}{fid});
	$_[0]->reorderCollateral("DataForm_field","DataForm_fieldId");
       	return "";
}

#-------------------------------------------------------------------
sub www_edit {
	my $layout = WebGUI::HTMLForm->new;
        $layout->template(
                -name=>"emailTemplateId",
                -value=>$_[0]->getValue("emailTemplateId"),
                -namespace=>$_[0]->get("namespace"),
                -label=>WebGUI::International::get(80,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $layout->template(
                -name=>"acknowlegementTemplateId",
                -value=>$_[0]->getValue("acknowlegementTemplateId"),
                -namespace=>$_[0]->get("namespace"),
                -label=>WebGUI::International::get(81,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $layout->template(
                -name=>"listTemplateId",
                -value=>$_[0]->getValue("listTemplateId"),
                -namespace=>$_[0]->get("namespace")."/List",
                -label=>WebGUI::International::get(87,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
	my $properties = WebGUI::HTMLForm->new;
	$properties->HTMLArea(
		-name=>"acknowledgement",
		-label=>WebGUI::International::get(16, $_[0]->get("namespace")),
		-value=>($_[0]->get("acknowledgement") || WebGUI::International::get(3, $_[0]->get("namespace")))
		);
	$properties->yesNo(
		-name=>"mailData",
		-label=>WebGUI::International::get(74,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("mailData")
		);
	if ($_[0]->get("wobjectId") eq "new") {
        	$properties->whatNext(
			-options=>{
				addField=>WebGUI::International::get(76,$_[0]->get("namespace")),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"addField"
			);
	}
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-helpId=>1,
		-headingId=>7
		);
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->SUPER::www_editSave();
	if ($session{form}{wid} eq "new") {
		$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"from",
			label=>WebGUI::International::get(10,$_[0]->get("namespace")),
			status=>"editable",
			isMailField=>1,
			width=>45,
			type=>"email"
			});
		$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"to",
			label=>WebGUI::International::get(11,$_[0]->get("namespace")),
			status=>"hidden",
			isMailField=>1,
			width=>45,
			type=>"email",
			defaultValue=>$session{setting}{companyEmail}
			});
		$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"cc",
			label=>WebGUI::International::get(12,$_[0]->get("namespace")),
			status=>"hidden",
			isMailField=>1,
			width=>45,
			type=>"email"
			});
		$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"bcc",
			label=>WebGUI::International::get(13,$_[0]->get("namespace")),
			status=>"hidden",
			isMailField=>1,
			width=>45,
			type=>"email"
			});
		$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"subject",
			label=>WebGUI::International::get(14,$_[0]->get("namespace")),
			status=>"editable",
			isMailField=>1,
			width=>45,
			type=>"text",
			defaultValue=>WebGUI::International::get(2,$_[0]->get("namespace"))
			});
	}
        if ($session{form}{proceed} eq "addField") {
            	return $_[0]->www_editField();
        }
       	return "";
}

#-------------------------------------------------------------------
sub www_editField {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
    	my ($output, %field, $f, %fieldStatus);
    	tie %field, 'Tie::CPHash';
    	tie %fieldStatus, 'Tie::IxHash';

	%fieldStatus = ( 
		"hidden" => WebGUI::International::get(4, $_[0]->get("namespace")),
		"visible" => WebGUI::International::get(5, $_[0]->get("namespace")),
		"editable" => WebGUI::International::get(6, $_[0]->get("namespace")),
		"required" => WebGUI::International::get(75, $_[0]->get("namespace")) 
		);
        $session{form}{fid} = "new" if ($session{form}{fid} eq "");
	unless ($session{form}{fid} eq "new") {	
        	%field = WebGUI::SQL->quickHash("select * from DataForm_field where DataForm_fieldId=$session{form}{fid}");
	}
        $output = helpIcon(2,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(20,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("fid",$session{form}{fid});
        $f->hidden("func","editFieldSave");
	$f->text(
                -name=>"label",
                -label=>WebGUI::International::get(77,$_[0]->get("namespace")),
                -value=>$field{label}
                );
        $f->text(
		-name=>"name",
		-label=>WebGUI::International::get(21,$_[0]->get("namespace")),
		-value=>$field{name}
		);
        $f->text(
                -name=>"subtext",
                -value=>$field{subtext},
                -label=>WebGUI::International::get(79,$_[0]->get("namespace")),
                );
        $f->select(
		-name=>"status",
		-options=>\%fieldStatus,
		-label=>WebGUI::International::get(22,$_[0]->get("namespace")),
		-value=>[ $field{status} ||= "editable" ]
		); 
	$f->fieldType(
		-name=>"type",
		-label=>WebGUI::International::get(23,$_[0]->get("namespace")),
		-value=>[$field{type} ||= "text"]
		);
	$f->integer(
		-name=>"width",
		-label=>WebGUI::International::get(8, $_[0]->get("namespace")),
		-value=>($field{width} || 0)
		);
	$f->integer(
                -name=>"rows",
		-value=>$field{rows} || 0,
		-label=>WebGUI::International::get(27, $_[0]->get("namespace")),
		-subtext=>WebGUI::International::get(28, $_[0]->get("namespace")),
		);
        $f->textarea(
		-name=>"possibleValues",
		-label=>WebGUI::International::get(24,$_[0]->get("namespace")),
		-value=>$field{possibleValues},
		-subtext=>'<br>'.WebGUI::International::get(85,$_[0]->get("namespace"))
		);
        $f->textarea(
		-name=>"defaultValue",
		-label=>WebGUI::International::get(25,$_[0]->get("namespace")),
		-value=>$field{defaultValue},
		-subtext=>'<br>'.WebGUI::International::get(85,$_[0]->get("namespace"))
		);
	if ($session{form}{fid} eq "new") {
        	$f->whatNext(
			-options=>{
				addField=>WebGUI::International::get(76,$_[0]->get("namespace")),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"addField"
			);
	}
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editFieldSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$session{form}{name} = $session{form}{label} if ($session{form}{name} eq "");
	$_[0]->setCollateral("DataForm_field","DataForm_fieldId",{
		DataForm_fieldId=>$session{form}{fid},
		width=>$session{form}{width},
		name=>WebGUI::URL::urlize($session{form}{name}),
		label=>$session{form}{label},
		status=>$session{form}{status},
		type=>$session{form}{type},
		possibleValues=>$session{form}{possibleValues},
		defaultValue=>$session{form}{defaultValue},
		subtext=>$session{form}{subtext},
		rows=>$session{form}{rows}
		});
        if ($session{form}{proceed} eq "addField") {
            	$session{form}{fid} = "new";
            	return $_[0]->www_editField();
        }
        return "";
}

#-------------------------------------------------------------------
sub www_exportTab {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$session{header}{filename} = WebGUI::URL::urlize($_[0]->get("title")).".tab";
	$session{header}{mimetype} = "text/plain";
	my @fields = WebGUI::SQL->buildArray("select name from DataForm_field where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	my $select = "select a.DataForm_entryId as entryId, a.ipAddress, a.username, a.userId, a.submissionDate";
	my $from = " from DataForm_entry a";
	my $join;
	my $where = " where a.wobjectId=".$_[0]->get("wobjectId");
	my $orderBy = " order by a.DataForm_entryId";
	my $columnCounter = "b";
	foreach my $field (@fields) {
		my $extension = "";
		$extension = "mail_" if (isIn($field, qw(to from cc bcc subject)));
		$select .= ", ".$columnCounter.".value as ".$extension.$field;
		$join .= " left join DataForm_entryData ".$columnCounter." on a.DataForm_entryId=".$columnCounter.".DataForm_entryId and "
			.$columnCounter.".name=".quote($field);
		$columnCounter++;
	}
	return WebGUI::SQL->quickTab($select.$from.$join.$where.$orderBy);
}

#-------------------------------------------------------------------
sub www_moveFieldDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->moveCollateralDown("DataForm_field","DataForm_fieldId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveFieldUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->moveCollateralUp("DataForm_field","DataForm_fieldId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_process {
	my $entryId = $_[0]->setCollateral("DataForm_entry","DataForm_entryId",{
		DataForm_entryId=>$session{form}{entryId},
                wobjectId=>$_[0]->get("wobjectId"),
                userId=>$session{user}{userId},
                username=>$session{user}{username},
                ipAddress=>$session{env}{REMOTE_ADDR},
                submissionDate=>time()
		},0);
	my ($var, %row, @errors, $updating, $hadErrors);
	$var->{entryId} = $entryId;
	tie %row, "Tie::CPHash";
	my $sth = WebGUI::SQL->read("select DataForm_fieldId,name,status,type,defaultValue,isMailField from DataForm_field 
		where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%row = $sth->hash) {
		my $value = WebGUI::FormProcessor::process($row{name},$row{type},$row{defaultValue});
		if ($row{status} eq "required" || $row{status} eq "editable") {
			$value = WebGUI::Macro::filter($value);
		}
		if ($row{status} eq "required" && ($value =~ /^\s$/ || $value eq "" || not defined $value)) {
		#if ($row{status} eq "required" && ($value =~ /^\s$/ || $value eq "")) {
		#if ($row{status} eq "required" && $value eq "") {
			push (@errors,{
				"error.message"=>$row{name}." ".WebGUI::International::get(29,$_[0]->get("namespace")).".",
				});
			$hadErrors = 1;
			delete $var->{entryId};
		}
		unless ($hadErrors) {
			my ($exists) = WebGUI::SQL->quickArray("select count(*) from DataForm_entryData where DataForm_entryId=$entryId
				and name=".quote($row{name}));
			if ($exists) {
				WebGUI::SQL->write("update DataForm_entryData set value=".quote($value)."
					where DataForm_entryId=$entryId and name=".quote($row{name}));
				$updating = 1;
			} else {
				WebGUI::SQL->write("insert into DataForm_entryData (DataForm_entryId,wobjectId,name,value) values
					($entryId, ".$_[0]->get("wobjectId").", ".quote($row{name}).", ".quote($value).")");
			}
		}
	}
	$sth->finish;
	$var->{error_loop} = \@errors;
	$var = $_[0]->getRecordTemplateVars($var);
	if ($hadErrors && !$updating) {
		WebGUI::SQL->write("delete from DataForm_entryData where DataForm_entryId=".$entryId);
		$_[0]->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
		$_[0]->www_view($var);
	} else {
		$_[0]->sendEmail($var) if ($_[0]->get("mailData") && !$updating);
		return $_[0]->processTemplate($_[0]->get("acknowlegementTemplateId"),$var);
	}
}

#-------------------------------------------------------------------
sub www_view {
	my $var;
	$var->{entryId} = $session{form}{entryId} if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	if ($var->{entryId} eq "list" && WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
		return $_[0]->processTemplate($_[0]->get("listTemplateId"),$_[0]->getListTemplateVars,"DataForm/List");
	}
	$var = $_[1] || $_[0]->getRecordTemplateVars($var);
	return $_[0]->processTemplate($_[0]->get("templateId"),$var);
}



1;


