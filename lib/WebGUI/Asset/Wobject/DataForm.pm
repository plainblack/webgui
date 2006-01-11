package WebGUI::Asset::Wobject::DataForm;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::MessageLog;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);

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
	$param{vertical} = $data->{vertical};
	$param{extras} = $data->{extras};
		
	if ($data->{type} eq "checkbox") {
		$param{value} = ($data->{defaultValue} =~ /checked/i) ? 1 : "";
	}
	if (isIn($data->{type},qw(selectList checkList))) {
		my @defaultValues;
		if ($session{form}{$param{name}}) {
                	@defaultValues = $self->session->form->selectList($param{name});
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
	my $self = shift;
	my $fid = shift;
	my $tid = shift;
	my $cantDelete = shift;
	my $output;
	$output = $self->session->icon->delete('func=deleteFieldConfirm;fid='.$fid.';tid='.$tid,$self->get("url"),WebGUI::International::get(19,"Asset_DataForm")) unless ($cantDelete);
	$output .= $self->session->icon->edit('func=editField;fid='.$fid.';tid='.$tid,$self->get("url"))
		.$self->session->icon->moveUp('func=moveFieldUp;fid='.$fid.';tid='.$tid,$self->get("url"))
		.$self->session->icon->moveDown('func=moveFieldDown;fid='.$fid.';tid='.$tid,$self->get("url"));
	return $output;
}
#-------------------------------------------------------------------
sub _tabAdminIcons {
	my $self = shift;
	my $tid = shift;
	my $cantDelete = shift;
	my $output;
	$output = $self->session->icon->delete('func=deleteTabConfirm;tid='.$tid,$self->get("url"),WebGUI::International::get(100,"Asset_DataForm")) unless ($cantDelete);
	$output .= $self->session->icon->edit('func=editTab;tid='.$tid,$self->get("url"))
		.$self->session->icon->moveLeft('func=moveTabLeft;tid='.$tid,$self->get("url"))
		.$self->session->icon->moveRight('func=moveTabRight;tid='.$tid,$self->get("url"));
	return $output;
}


#-------------------------------------------------------------------
sub _tonull { 
	return $_[1] eq "0" ? (undef, undef) : @_ ;
}


#-------------------------------------------------------------------
sub _createTabInit {
	my $id = shift;
	my @tabCount = $self->session->db->quickArray("select count(DataForm_tabId) from DataForm_tab where assetId=".$self->session->db->quote($id));
	my $output = '<script type="text/javascript">var numberOfTabs = '.$tabCount[0].'; initTabs();</script>';
	return $output;
}

#-------------------------------------------------------------------

sub defaultViewForm {
        my $self = shift;
        return ($self->get("defaultView") == 0);
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_DataForm"),
		uiLevel => 5,
                tableName=>'DataForm',
		icon=>'dataForm.gif',
                className=>'WebGUI::Asset::Wobject::DataForm',
                properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000141',
				},
			acknowledgement=>{
				fieldType=>"textarea",
				defaultValue=>undef
				},
			emailTemplateId=>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000085',
				},
			acknowlegementTemplateId=>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000104',
				},
			listTemplateId=>{
				defaultValue=>'PBtmpl0000000000000021',
				fieldType=>"template"
				},
			mailData=>{
				defaultValue=>0,
				fieldType=>"yesNo"
				},
			defaultView=>{
				defaultValue=>0,
				fieldType=>"integer"
				},
			groupToViewEntries=>{
				defaultValue=>7,
				fieldType=>"group"
				},
			}
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
       my (%dataField, %dataTab, $sthField, $sthTab, $newTabId);
       tie %dataTab, 'Tie::CPHash';
       tie %dataField, 'Tie::CPHash';
       $sthTab = $self->session->db->read("select * from DataForm_tab where assetId=".$self->session->db->quote($self->getId));
       while (%dataTab = $sthTab->hash) {
               $sthField = $self->session->db->read("select * from DataForm_field where assetId=".$self->session->db->quote($self->getId)." AND DataForm_tabId=".$self->session->db->quote($dataTab{DataForm_tabId}));
               $dataTab{DataForm_tabId} = "new";
               $newTabId = $newAsset->setCollateral("DataForm_tab","DataForm_tabId",\%dataTab);
               while (%dataField = $sthField->hash) {
                       $dataField{DataForm_fieldId} = "new";
                       $dataField{DataForm_tabId} = $newTabId;
                       $newAsset->setCollateral("DataForm_field","DataForm_fieldId",\%dataField);
               }
               $sthField->finish;
       }
       $sthField = $self->session->db->read("select * from DataForm_field where assetId=".$self->session->db->quote($self->getId)." AND DataForm_tabId='0'");
       while (%dataField = $sthField->hash) {
               $dataField{DataForm_fieldId} = "new";
               $newAsset->setCollateral("DataForm_field","DataForm_fieldId",\%dataField);
       }
       $sthField->finish;
       $sthTab->finish;
       return $newAsset;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	$tabform->getTab("display")->template(
		-name=>"templateId",
      		-value=>$self->getValue("templateId"),
      		-namespace=>"DataForm",
                -label=>WebGUI::International::get(82,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('82 description',"Asset_DataForm"),
		-afterEdit=>'func=edit',
		-defaultValue=>"PBtmpl0000000000000141"
   		);
        $tabform->getTab("display")->template(
                -name=>"emailTemplateId",
                -value=>$self->getValue("emailTemplateId"),
                -namespace=>"DataForm",
                -label=>WebGUI::International::get(80,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('80 description',"Asset_DataForm"),
                -afterEdit=>'func=edit'
                );
        $tabform->getTab("display")->template(
                -name=>"acknowlegementTemplateId",
                -value=>$self->getValue("acknowlegementTemplateId"),
                -namespace=>"DataForm",
                -label=>WebGUI::International::get(81,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('81 description',"Asset_DataForm"),
                -afterEdit=>'func=edit'
                );
        $tabform->getTab("display")->template(
                -name=>"listTemplateId",
                -value=>$self->getValue("listTemplateId"),
                -namespace=>"DataForm/List",
                -label=>WebGUI::International::get(87,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('87 description',"Asset_DataForm"),
                -afterEdit=>'func=edit'
                );
	$tabform->getTab("display")->radioList(
		-name=>"defaultView",
                -options=>{ 0 => WebGUI::International::get('data form','Asset_DataForm'),
                            1 => WebGUI::International::get('data list','Asset_DataForm'),},
		-label=>WebGUI::International::get('defaultView',"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('defaultView description',"Asset_DataForm"),
		-value=>$self->getValue("defaultView"),
		);
	$tabform->getTab("properties")->HTMLArea(
		-name=>"acknowledgement",
		-label=>WebGUI::International::get(16, "Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('16 description', "Asset_DataForm"),
		-value=>($self->get("acknowledgement") || WebGUI::International::get(3, "Asset_DataForm"))
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"mailData",
		-label=>WebGUI::International::get(74,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('74 description',"Asset_DataForm"),
		-value=>$self->getValue("mailData")
		);

	$tabform->getTab("security")->group(
		-name=>"groupToViewEntries",
		-label=>WebGUI::International::get('group to view entries', "Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('group to view entries description',"Asset_DataForm"),
		-value=>$self->getValue("groupToViewEntries")
		);

	if ($self->getId eq "new" && $self->session->form->process("proceed") ne "manageAssets") {
        	$tabform->getTab("properties")->whatNext(
			-options=>{
				editField=>WebGUI::International::get(76,"Asset_DataForm"),
				""=>WebGUI::International::get(745,"Asset_DataForm")
				},
			-value=>"editField"
			);
	}
	
	return $tabform;
}


#-------------------------------------------------------------------
sub getListTemplateVars {
	my $self = shift;
	my $var = shift;
	my @fieldLoop;
	$var->{"back.url"} = $self->getFormUrl;
	$var->{"back.label"} = WebGUI::International::get('go to form',"Asset_DataForm");
	#$var->{"entryId"} = $self->getId;
	#$var->{"delete.url"} = $self->getUrl.";func=deleteAllEntries";
	#$var->{"delete.label"} = WebGUI::International::get(91,"Asset_DataForm");
	my $fields = $self->session->db->read("select DataForm_fieldId,name,label,isMailField,type from DataForm_field
			where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
	while (my $field = $fields->hashRef) {
		push(@fieldLoop,{
			"field.name"=>$field->{name},
			"field.id"=>$field->{DataForm_fieldId},
			"field.label"=>$field->{label},
			"field.isMailField"=>$field->{isMailField},
			"field.type"=>$field->{type},
			});
	}
	$fields->finish;
	$var->{field_loop} = \@fieldLoop;
	my @recordLoop;
	my $entries = $self->session->db->read("select ipAddress,username,userid,submissionDate,DataForm_entryId from DataForm_entry 
		where assetId=".$self->session->db->quote($self->getId)." order by submissionDate desc");
	while (my $record = $entries->hashRef) {
		my @dataLoop;
		my $dloop = $self->session->db->read("select b.name, b.label, b.isMailField, a.value from DataForm_entryData a left join DataForm_field b
			on a.DataForm_fieldId=b.DataForm_fieldId where a.DataForm_entryId=".$self->session->db->quote($record->{DataForm_entryId})."
			order by b.sequenceNumber");
		while (my $data = $dloop->hashRef) {
			push(@dataLoop,{
				"record.data.name"=>$data->{name},
				"record.data.label"=>$data->{label},
				"record.data.value"=>$data->{value},
				"record.data.isMailField"=>$data->{isMailField}
				});
		}
		$dloop->finish;
		push(@recordLoop,{
			"record.ipAddress"=>$record->{ipAddress},
			"record.edit.url"=>$self->getUrl("func=view;entryId=".$record->{DataForm_entryId}),
			"record.edit.icon"=>$self->session->icon->edit("func=view;entryId=".$record->{DataForm_entryId}, $self->getUrl),
			"record.delete.url"=>$self->getUrl("func=deleteEntry;entryId=".$record->{DataForm_entryId}),
			"record.delete.icon"=>$self->session->icon->delete("func=deleteEntry;entryId=".$record->{Asset_DataForm_entryId}, $self->getUrl, WebGUI::International::get('Delete entry confirmation',"Asset_DataForm")),
			"record.username"=>$record->{username},
			"record.userId"=>$record->{userId},
			"record.submissionDate.epoch"=>$record->{submissionDate},
			"record.submissionDate.human"=>$self->session->datetime->epochToHuman($record->{submissionDate}),
			"record.entryId"=>$record->{DataForm_entryId},
			"record.data_loop"=>\@dataLoop
			});
	}
	$entries->finish;
	$var->{record_loop} = \@recordLoop;	
	return $var;
}

#-------------------------------------------------------------------

sub getFormUrl {
        my $self = shift;
        my $params = shift;
        my $url = $self->getUrl;
        unless ($self->defaultViewForm) {
                $url = $self->session->url->append($url, 'mode=form');
        }
        if ($params) {
                $url = $self->session->url->append($url, $params);
        }
        return $url;
}

#-------------------------------------------------------------------

sub getListUrl {
        my $self = shift;
        my $params = shift;
        my $url = $self->getUrl;
        if ($self->defaultViewForm) {
                $url = $self->session->url->append($url, 'mode=list');
        }
        if ($params) {
                $url = $self->session->url->append($url, $params);
        }
        return $url;
}

#-------------------------------------------------------------------
sub getRecordTemplateVars {
	my $self = shift;
	my $var = shift;
	$var->{error_loop} = [] unless (exists $var->{error_loop});
	$var->{canEdit} = ($self->canEdit);
	#$var->{"entryList.url"} = $self->getUrl('func=view;entryId=list');
	$var->{"entryList.url"} = $self->getListUrl;
	$var->{"entryList.label"} = WebGUI::International::get(86,"Asset_DataForm");
	$var->{"export.tab.url"} = $self->getUrl('func=exportTab');
	$var->{"export.tab.label"} = WebGUI::International::get(84,"Asset_DataForm");
	$var->{"delete.url"} = $self->getUrl('func=deleteEntry;entryId='.$var->{entryId});
	$var->{"delete.label"} = WebGUI::International::get(90,"Asset_DataForm");
	$var->{"back.url"} = $self->getUrl;
	$var->{"back.label"} = WebGUI::International::get(18,"Asset_DataForm");
	$var->{"addField.url"} = $self->getUrl('func=editField');
	$var->{"addField.label"} = WebGUI::International::get(76,"Asset_DataForm");
	# add Tab label, url, header and init
	$var->{"addTab.label"}=  WebGUI::International::get(105,"Asset_DataForm");;
	$var->{"addTab.url"}= $self->getUrl('func=editTab');
	$var->{"tab.init"}= _createTabInit($self->getId);
	$var->{"form.start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session,{name=>"func",value=>"process"});
	my @tabs;
	my $select = "select a.name, a.DataForm_fieldId, a.DataForm_tabId,a.label, a.status, a.isMailField, a.subtext, a.type, a.defaultValue, a.possibleValues, a.width, a.rows, a.extras, a.vertical";
	my $join;
	my $where = "where a.assetId=".$self->session->db->quote($self->getId);
	if ($var->{entryId}) {
		$var->{"form.start"} .= WebGUI::Form::hidden($self->session,{name=>"entryId",value=>$var->{entryId}});
		my $entry = $self->getCollateral("DataForm_entry","DataForm_entryId",$var->{entryId});
		$var->{ipAddress} = $entry->{ipAddress};
		$var->{username} = $entry->{username};
		$var->{userId} = $entry->{userId};
		$var->{date} = $self->session->datetime->epochToHuman($entry->{submissionDate});
		$var->{epoch} = $entry->{submissionDate};
		$var->{"edit.URL"} = $self->getFormUrl('entryId='.$var->{entryId});
		$where .= " and b.DataForm_entryId=".$self->session->db->quote($var->{entryId});
		$join = "left join DataForm_entryData as b on a.DataForm_fieldId=b.DataForm_fieldId";
		$select .= ", b.value";
	}
	my %data;
	tie %data, 'Tie::CPHash';
	my %tab;
	tie %tab, 'Tie::CPHash';
	my $tabsth = $self->session->db->read("select * from DataForm_tab where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
	while (%tab = $tabsth->hash) {
		my @fields;
		my $sth = $self->session->db->read("$select from DataForm_field as a $join $where and a.DataForm_tabId=".$self->session->db->quote($tab{DataForm_tabId})." order by a.sequenceNumber");
		while (%data = $sth->hash) {
			my $formValue = $session{form}{$data{name}};
			if ((not exists $data{value}) && $self->session->form->process("func") ne "editSave" && $self->session->form->process("func") ne "editFieldSave" && defined $formValue) {
				$data{value} = $formValue;
				$data{value} = $self->session->datetime->setToEpoch($data{value}) if ($data{type} eq "date");
			}
			if (not exists $data{value}) {
				my $defaultValue = $data{defaultValue};
				WebGUI::Macro::process($self->session,\$defaultValue);
				$data{value} = $defaultValue;
			}
			my $hidden = (($data{status} eq "hidden" && !$self->session->var->get("adminOn")) || ($data{isMailField} && !$self->get("mailData")));
			my $value = $data{value};
			$value = $self->session->datetime->epochToHuman($value,"%z") if ($data{type} eq "date");
			$value = $self->session->datetime->epochToHuman($value,"%z %Z") if ($data{type} eq "dateTime");
			push(@fields, {
				"tab.field.form" => _createField(\%data),
				"tab.field.name" => $data{name},
				"tab.field.tid" => $data{DataForm_tabId},
				"tab.field.value" => $value,
				"tab.field.label" => $data{label},
				"tab.field.isMailField" => $data{isMailField},
				"tab.field.isHidden" => $hidden,
				"tab.field.isDisplayed" => ($data{status} eq "visible" && !$hidden),
				"tab.field.isRequired" => ($data{status} eq "required" && !$hidden),
				"tab.field.subtext" => $data{subtext},
				"tab.field.controls" => $self->_fieldAdminIcons($data{DataForm_fieldId},$data{DataForm_tabId},$data{isMailField})
			});
		}
		$sth->finish;
		push(@tabs, {
			"tab.start" => '<div id="tabcontent'.$tab{sequenceNumber}.'" class="tabBody">',
			"tab.end" =>'</div>',
			"tab.sequence" => $tab{sequenceNumber},
			"tab.label" => $tab{label},
			"tab.tid" => $tab{DataForm_tabId},
			"tab.subtext" => $tab{subtext},
			"tab.controls" => $self->_tabAdminIcons($tab{DataForm_tabId}),
			"tab.field_loop" => \@fields,
		});
	}
	
	my @fields;
	my $sth = $self->session->db->read("$select from DataForm_field as a $join $where and a.DataForm_tabId = 0 order by a.sequenceNumber");
	while (%data = $sth->hash) {
		my $formValue = $session{form}{$data{name}};
		if ((not exists $data{value}) && $self->session->form->process("func") ne "editSave" && $self->session->form->process("func") ne "editFieldSave" && defined $formValue) {
			$data{value} = $formValue;
			$data{value} = $self->session->datetime->setToEpoch($data{value}) if ($data{type} eq "date");
		}
		if (not exists $data{value}) {
			my $defaultValue = $data{defaultValue};
			WebGUI::Macro::process($self->session,\$defaultValue);
			$data{value} = $defaultValue;
		}
		my $hidden = (($data{status} eq "hidden" && !$self->session->var->get("adminOn")) || ($data{isMailField} && !$self->get("mailData")));
		my $value = $data{value};
		$value = $self->session->datetime->epochToHuman($value,"%z") if ($data{type} eq "date");
		$value = $self->session->datetime->epochToHuman($value) if ($data{type} eq "dateTime");
		my %fieldProperties = (
			"form" => _createField(\%data),
			"name" => $data{name},
			"tid" => $data{DataForm_tabId},
			"inTab".$data{DataForm_tabId} => 1,
			"value" => $value,
			"label" => $data{label},
			"isMailField" => $data{isMailField},
			"isHidden" => $hidden,
			"isDisplayed" => ($data{status} eq "visible" && !$hidden),
			"isRequired" => ($data{status} eq "required" && !$hidden),
			"subtext" => $data{subtext},
			"controls" => $self->_fieldAdminIcons($data{DataForm_fieldId},$data{DataForm_tabId},$data{isMailField})
		);
		push(@fields, { map {("field.".$_ => $fieldProperties{$_})} keys(%fieldProperties) });
		foreach (keys(%fieldProperties)) {
			$var->{"field.noloop.".$data{name}.".$_"} = $fieldProperties{$_};
		}
	}
	$sth->finish;
	$var->{field_loop} = \@fields;
	$tabsth->finish;
	$var->{tab_loop} = \@tabs;
	$var->{"form.send"} = WebGUI::Form::submit($self->session,{value=>WebGUI::International::get(73, "Asset_DataForm")});
	$var->{"form.save"} = WebGUI::Form::submit($self->session,);
	$var->{"form.end"} = WebGUI::Form::formFooter($self->session,);
	return $var;
}



#-------------------------------------------------------------------
sub processPropertiesFromFormPost {	
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->session->form->process("assetId") eq "new") {
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"from",
			label=>WebGUI::International::get(10,"Asset_DataForm"),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"to",
			label=>WebGUI::International::get(11,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email",
			defaultValue=>$self->session->setting->get("companyEmail")
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"cc",
			label=>WebGUI::International::get(12,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"bcc",
			label=>WebGUI::International::get(13,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"subject",
			label=>WebGUI::International::get(14,"Asset_DataForm"),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"text",
			defaultValue=>WebGUI::International::get(2,"Asset_DataForm")
			});
	}
	if ($self->session->form->process("fid") eq "new") { # hack to get proceed to work.
		$session{whatNext} = $self->session->form->process("proceed");
	} else { $session{whatNext} = "nothing"; }
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
    	$self->session->db->write("delete from DataForm_field where assetId=".$self->session->db->quote($self->getId));
    	$self->session->db->write("delete from DataForm_entry where assetId=".$self->session->db->quote($self->getId));
    	$self->session->db->write("delete from DataForm_entryData where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->write("delete from DataForm_tab where assetId=".$self->session->db->quote($self->getId));
    	$self->SUPER::purge();
}

#-------------------------------------------------------------------
sub sanitizeUserInput {
	my $self = shift;
	my $content = shift;
	my $contentType = shift || "text";
	my $msg = WebGUI::HTML::format($content, $contentType);
	
	return $msg;
}

#-------------------------------------------------------------------
sub sendEmail {
	my $self = shift;
	my $var = shift;
	my $message = $self->processTemplate($var,$self->get("emailTemplateId"));
	WebGUI::Macro::process($self->session,\$message);
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
		WebGUI::Mail::send($to, $subject, $message, $cc, $from, $bcc);
	} else {
                my ($userId) = $self->session->db->quickArray("select userId from users where username=".$self->session->db->quote($to));
                my $groupId;
                # if no user is found, try finding a matching group
                unless ($userId) {
                        ($groupId) = $self->session->db->quickArray("select groupId from groups where groupName=".$self->session->db->quote($to));
                }
                unless ($userId || $groupId) {
                        $self->session->errorHandler->warn($self->getId.": Unable to send message, no user or group found.");
                } else {
                        WebGUI::MessageLog::addEntry($userId, $groupId, $subject, $message, "", "", $from);
			if ($cc) {
                                WebGUI::Mail::send($cc, $subject, $message, "", $from);
                        }
                        if ($bcc) {
                                WebGUI::Mail::send($bcc, $subject, $message, "", $from);
                        }
                }
        }
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $passedVars = shift;
	my $var;
        ##Priority encoding
        if ( $self->session->form->process("mode") eq "form") {
                $self->viewForm($passedVars);
        }
        elsif ( $self->session->form->process("mode") eq "list") {
                $self->viewList;
        }
	elsif( $self->defaultViewForm ) {
                $self->viewForm($passedVars);
        }
        else {
                $self->viewList();
        }
}

#-------------------------------------------------------------------

sub viewList {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup($self->get("groupToViewEntries")));
        return $self->processTemplate($self->getListTemplateVars,$self->get("listTemplateId"));
}

#-------------------------------------------------------------------

sub viewForm {
	my $self = shift;
	my $passedVars = shift;
	$self->session->style->setLink($self->session->config->get("extrasURL").'/tabs/tabs.css', {"type"=>"text/css"});
	$self->session->style->setScript($self->session->config->get("extrasURL").'/tabs/tabs.js', {"type"=>"text/javascript"});
	my $var;
	$var->{entryId} = $self->session->form->process("entryId") if ($self->canEdit);
	$var = $passedVars || $self->getRecordTemplateVars($var);
	return $self->processTemplate($var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_deleteAllEntries {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
        my $assetId = $self->session->form->process("entryId");
	$self->deleteCollateral("DataForm_entry","assetId",$assetId);
        $self->session->form->process("entryId") = 'list';
        return "";
}

#-------------------------------------------------------------------
sub www_deleteAllEntriesConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->session->form->process("entryId")==$self->getId);
	$self->session->db->write("delete from DataForm_entry where assetId=".$self->session->db->quote($self->getId));
	return $self->www_view;
}


#-------------------------------------------------------------------
sub www_deleteEntry {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
        my $entryId = $self->session->form->process("entryId");
	$self->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
        $self->session->form->process("entryId") = 'list';
        return "";
}

#-------------------------------------------------------------------
sub www_deleteFieldConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->deleteCollateral("DataForm_field","DataForm_fieldId",$self->session->form->process("fid"));
	$self->reorderCollateral("DataForm_field","DataForm_fieldId");
       	return "";
}

#-------------------------------------------------------------------
sub www_deleteTabConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->deleteCollateral("DataForm_tab","DataForm_tabId",$self->session->form->process("tid"));
	$self->deleteCollateral("DataForm_field","DataForm_tabId",$self->session->form->process("tid"));
	$self->reorderCollateral("DataForm_tab","DataForm_tabId");
       	return "";
}

#-------------------------------------------------------------------
#sub www_edit {
#        my $self = shift;
#	return $self->session->privilege->insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("data form add/edit","Asset_DataForm");
#        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("7","Asset_DataForm"));
#}

#-------------------------------------------------------------------
sub www_editField {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
    	my (%field, $f, %fieldStatus,$tab);
    	tie %field, 'Tie::CPHash';
    	tie %fieldStatus, 'Tie::IxHash';
	%fieldStatus = ( 
		"hidden" => WebGUI::International::get(4, "Asset_DataForm"),
		"visible" => WebGUI::International::get(5, "Asset_DataForm"),
		"editable" => WebGUI::International::get(6, "Asset_DataForm"),
		"required" => WebGUI::International::get(75, "Asset_DataForm") 
		);
        $self->session->form->process("fid") = "new" if ($self->session->form->process("fid") eq "");
	unless ($self->session->form->process("fid") eq "new") {	
        	%field = $self->session->db->quickHash("select * from DataForm_field where DataForm_fieldId=".$self->session->db->quote($self->session->form->process("fid")));
	}
	$tab = $self->session->db->buildHashRef("select DataForm_tabId,label from DataForm_tab where assetId=".$self->session->db->quote($self->getId));
	$tab->{0} = WebGUI::International::get("no tab","Asset_DataForm");
        $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "fid",
		-value => $self->session->form->process("fid")
	);
        $f->hidden(
		-name => "func",
		-value => "editFieldSave"
	);
	$f->text(
                -name=>"label",
                -label=>WebGUI::International::get(77,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('77 description',"Asset_DataForm"),
                -value=>$field{label}
                );
        $f->text(
		-name=>"name",
		-label=>WebGUI::International::get(21,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('21 description',"Asset_DataForm"),
		-value=>$field{name}
		);
	if($field{sequenceNumber} && ! $field{isMailField}) {
		$f->integer(
			-name=>"position",
			-label=>WebGUI::International::get('Field Position',"Asset_DataForm"),
			-hoverHelp=>WebGUI::International::get('Field Position description',"Asset_DataForm"),
			-value=>$field{sequenceNumber}
		);	
	}
	$f->selectBox(
		-name=>"tid",
		-options=>$tab,
		-label=>WebGUI::International::get(104,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('104 description',"Asset_DataForm"),
		-value=>[ $field{DataForm_tabId} || 0 ]
		); 
        $f->text(
                -name=>"subtext",
                -value=>$field{subtext},
                -label=>WebGUI::International::get(79,"Asset_DataForm"),
                -hoverHelp=>WebGUI::International::get('79 description',"Asset_DataForm"),
                );
        $f->selectBox(
		-name=>"status",
		-options=>\%fieldStatus,
		-label=>WebGUI::International::get(22,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('22 description',"Asset_DataForm"),
		-value=> [ $field{status} || "editable" ] ,
		); 
	$f->fieldType(
		-name=>"type",
		-label=>WebGUI::International::get(23,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('23 description',"Asset_DataForm"),
		-value=>$field{type} || "text",
		-types=>[qw(dateTime TimeField float zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList)]
		);
	$f->integer(
		-name=>"width",
		-label=>WebGUI::International::get(8,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('8 description',"Asset_DataForm"),
		-value=>($field{width} || 0)
		);
	$f->integer(
                -name=>"rows",
		-value=>$field{rows} || 0,
		-label=>WebGUI::International::get(27,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('27 description',"Asset_DataForm"),
		-subtext=>WebGUI::International::get(28,"Asset_DataForm"),
		);
	$f->yesNo(
		-name=>"vertical",
		-value=>$field{vertical},
		-label=>WebGUI::International::get('editField vertical label', "Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('editField vertical label description', "Asset_DataForm"),
		-subtext=>WebGUI::International::get('editField vertical subtext', "Asset_DataForm")
		);
	$f->text(
		-name=>"extras",
		-value=>$field{extras},
		-label=>WebGUI::International::get('editField extras label', "Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('editField extras label description', "Asset_DataForm"),
		);
        $f->textarea(
		-name=>"possibleValues",
		-label=>WebGUI::International::get(24,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('24 description',"Asset_DataForm"),
		-value=>$field{possibleValues},
		-subtext=>'<br />'.WebGUI::International::get(85,"Asset_DataForm")
		);
        $f->textarea(
		-name=>"defaultValue",
		-label=>WebGUI::International::get(25,"Asset_DataForm"),
		-hoverHelp=>WebGUI::International::get('25 description',"Asset_DataForm"),
		-value=>$field{defaultValue},
		-subtext=>'<br />'.WebGUI::International::get(85,"Asset_DataForm")
		);
	if ($self->session->form->process("fid") eq "new" && $self->session->form->process("proceed") ne "manageAssets") {
        	$f->whatNext(
			-options=>{
				"editField"=>WebGUI::International::get(76,"Asset_DataForm"),
				"viewDataForm"=>WebGUI::International::get(745,"Asset_DataForm")
				},
			-value=>"editField"
			);
	}
        $f->submit;
	my $ac = $self->getAdminConsole;
	$ac->setHelp("data form fields add/edit","Asset_DataForm");
        return $ac->render($f->print,WebGUI::International::get('20',"Asset_DataForm"));
}

#-------------------------------------------------------------------
sub www_editFieldSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->session->form->process("name") = $self->session->form->process("label") if ($self->session->form->process("name") eq "");
	$self->session->form->process("tid") = "0" if ($self->session->form->process("tid") eq "");
	$self->session->form->process("name") = $self->session->url->urlize($self->session->form->process("name"));
        $self->session->form->process("name") =~ s/\-//g;
        $self->session->form->process("name") =~ s/\///g;
	$self->setCollateral("DataForm_field","DataForm_fieldId",{
		DataForm_fieldId=>$self->session->form->process("fid"),
		width=>$self->session->form->process("width"),
		name=>$self->session->form->process("name"),
		label=>$self->session->form->process("label"),
		DataForm_tabId=>$self->session->form->process("tid"),
		status=>$self->session->form->process("status"),
		type=>$self->session->form->process("type"),
		possibleValues=>$self->session->form->process("possibleValues"),
		defaultValue=>$self->session->form->process("defaultValue"),
		subtext=>$self->session->form->process("subtext"),
		rows=>$self->session->form->process("rows"),
		vertical=>$self->session->form->process("vertical"),
		extras=>$self->session->form->process("extras"),
		}, "1","1", _tonull("DataForm_tabId",$self->session->form->process("tid")));
	if($self->session->form->process("position")) {
		$self->session->db->write("update DataForm_field set sequenceNumber=".$self->session->db->quote($self->session->form->process("position")).
					" where DataForm_fieldId=".$self->session->db->quote($self->session->form->process("fid")));
	}
	$self->reorderCollateral("DataForm_field","DataForm_fieldId", _tonull("DataForm_tabId",$self->session->form->process("tid"))) if ($self->session->form->process("fid") ne "new");
        if ($session{whatNext} eq "editField" || $self->session->form->process("proceed") eq "editField") {
            $self->session->form->process("fid") = "new";
            return $self->www_editField;
        }
        return "";
}

#-------------------------------------------------------------------
sub www_editTab {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
    	my (%tab, $f);
    	tie %tab, 'Tie::CPHash';
        $self->session->form->process("tid") = "new" if ($self->session->form->process("tid") eq "");
	unless ($self->session->form->process("tid") eq "new") {	
        	%tab = $self->session->db->quickHash("select * from DataForm_tab where DataForm_tabId=".$self->session->db->quote($self->session->form->process("tid")));
	}
        $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "tid",
		-value => $self->session->form->process("tid")
	);
        $f->hidden(
		-name => "func",
		-value => "editTabSave"
	);
	$f->text(
                -name=>"label",
		-label=>WebGUI::International::get(101,"Asset_DataForm"),
                -value=>$tab{label}
                );
        $f->textarea(
		-name=>"subtext",
		-label=>WebGUI::International::get(79,"Asset_DataForm"),
		-value=>$tab{subtext},
		-subtext=>""
		);
	if ($self->session->form->process("tid") eq "new") {
        	$f->whatNext(
			-options=>{
				editTab=>WebGUI::International::get(103,"Asset_DataForm"),
				""=>WebGUI::International::get(745,"Asset_DataForm")
				},
			-value=>"editTab"
			);
	}
        $f->submit;
	my $ac = $self->getAdminConsole;
	$ac->setHelp("data form fields add/edit","Asset_DataForm");
        return $ac->render($f->print,WebGUI::International::get('20',"Asset_DataForm"));
}

#-------------------------------------------------------------------
sub www_editTabSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->session->form->process("name") = $self->session->form->process("label") if ($self->session->form->process("name") eq "");
	$self->session->form->process("name") = $self->session->url->urlize($self->session->form->process("name"));
        $self->session->form->process("name") =~ s/\-//g;
        $self->session->form->process("name") =~ s/\///g;
	$self->setCollateral("DataForm_tab","DataForm_tabId",{
		DataForm_tabId=>$self->session->form->process("tid"),
		label=>$self->session->form->process("label"),
		subtext=>$self->session->form->process("subtext")
		});
        if ($self->session->form->process("proceed") eq "editTab") {
            $self->session->form->process("tid") = "new";
            return $self->www_editTab;
        }
        return "";
}

#-------------------------------------------------------------------
sub www_exportTab {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        WebGUI::HTTP::setFilename($self->get("url").".tab","text/plain");
        my %fields = $self->session->db->buildHash("select DataForm_fieldId,name from DataForm_field where
                assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
        my @data;
        my $entries = $self->session->db->read("select * from DataForm_entry where assetId=".$self->session->db->quote($self->getId));
        my $i;
        my $noMailData = ($self->get("mailData") == 0);
        while (my $entryData = $entries->hashRef) {
                $data[$i] = {
                        entryId => $entryData->{DataForm_entryId},
                        ipAddress => $entryData->{ipAddress},
                        username => $entryData->{username},
                        userId => $entryData->{userId},
                        submissionDate => $self->session->datetime->epochToHuman($entryData->{submissionDate}),
                        };
                my $values = $self->session->db->read("select value,DataForm_fieldId from DataForm_entryData where
                        DataForm_entryId=".$self->session->db->quote($entryData->{DataForm_entryId}));
                while (my ($value, $fieldId) = $values->array) {
                        next if (isIn($fields{$fieldId}, qw(to from cc bcc subject)) && $noMailData);
                        $data[$i]{$fields{$fieldId}} = $value;
                }
                $values->finish;
                $i++;
        }
        $entries->finish;
        my @row;
        foreach my $fieldId (keys %fields) {
                next if (isIn($fields{$fieldId}, qw(to from cc bcc subject)) && $noMailData);
                push(@row, $fields{$fieldId});
        }
        my $tab = join("\t",@row)."\n";
        foreach my $record (@data) {
                @row = ();
                foreach my $fieldId (keys %fields) {
                        next if (isIn($fields{$fieldId}, qw(to from cc bcc subject)) && $noMailData);
                        my $value = $record->{$fields{$fieldId}};
                        $value =~ s/\t/\\t/g;
                        $value =~ s/\r//g;
                        $value =~ s/\n/;/g;
                        push(@row, $value);
                }
                $tab .= join("\t", @row)."\n";
        }
        return $tab;
}

#-------------------------------------------------------------------
sub www_moveFieldDown {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->moveCollateralDown("DataForm_field","DataForm_fieldId",$self->session->form->process("fid"),_tonull("DataForm_tabId",$self->session->form->process("tid")));
	return "";
}

#-------------------------------------------------------------------
sub www_moveFieldUp {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->moveCollateralUp("DataForm_field","DataForm_fieldId",$self->session->form->process("fid"),_tonull("DataForm_tabId",$self->session->form->process("tid")));
	return "";
}

#-------------------------------------------------------------------
sub www_moveTabRight {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->moveCollateralDown("DataForm_tab","DataForm_tabId",$self->session->form->process("tid"));
	return "";
}

#-------------------------------------------------------------------
sub www_moveTabLeft {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->moveCollateralUp("DataForm_tab","DataForm_tabId",$self->session->form->process("tid"));
	return "";
}

#-------------------------------------------------------------------
sub www_process {
	my $self = shift;
	my $entryId = $self->setCollateral("DataForm_entry","DataForm_entryId",{
		DataForm_entryId=>$self->session->form->process("entryId"),
                assetId=>$self->getId,
                userId=>$self->session->user->profileField("userId"),
                username=>$self->session->user->profileField("username"),
                ipAddress=>$self->session->env->get("REMOTE_ADDR"),
                submissionDate=$self->session->datetime->time()
		},0);
	my ($var, %row, @errors, $updating, $hadErrors);
	$var->{entryId} = $entryId;
	tie %row, "Tie::CPHash";
	my $sth = $self->session->db->read("select DataForm_fieldId,label,name,status,type,defaultValue,isMailField from DataForm_field 
		where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
	while (%row = $sth->hash) {
		my $value = $row{defaultValue};
		if ($row{status} eq "required" || $row{status} eq "editable") {
			$value = $self->session->form->process($row{name},$row{type},$row{defaultValue});
			WebGUI::Macro::filter(\$value);
			$value = $self->sanitizeUserInput($value) unless ($row{type} eq "HTMLArea");
		}
		if ($row{status} eq "required" && ($value =~ /^\s$/ || $value eq "" || not defined $value)) {
			push (@errors,{
				"error.message"=>$row{label}." ".WebGUI::International::get(29,"Asset_DataForm").".",
				});
			$hadErrors = 1;
			delete $var->{entryId};
		}
		if ($row{status} eq "hidden") {
			$value = $row{defaultValue};
                        WebGUI::Macro::process($self->session,\$value);
                }
		unless ($hadErrors) {
			my ($exists) = $self->session->db->quickArray("select count(*) from DataForm_entryData where DataForm_entryId=".$self->session->db->quote($entryId)."
				and DataForm_fieldId=".$self->session->db->quote($row{DataForm_fieldId}));
			if ($exists) {
				$self->session->db->write("update DataForm_entryData set value=".$self->session->db->quote($value)."
					where DataForm_entryId=".$self->session->db->quote($entryId)." and DataForm_fieldId=".$self->session->db->quote($row{DataForm_fieldId}));
				$updating = 1;
			} else {
				$self->session->db->write("insert into DataForm_entryData (DataForm_entryId,DataForm_fieldId,assetId,value) values
					(".$self->session->db->quote($entryId).", ".$self->session->db->quote($row{DataForm_fieldId}).", ".$self->session->db->quote($self->getId).", ".$self->session->db->quote($value).")");
			}
		}
	}
	$sth->finish;
	$var->{error_loop} = \@errors;
	$var = $self->getRecordTemplateVars($var);
	if ($hadErrors && !$updating) {
		$self->session->db->write("delete from DataForm_entryData where DataForm_entryId=".$self->session->db->quote($entryId));
		$self->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
		$self->processStyle($self->view($var));
	} else {
		$self->sendEmail($var) if ($self->get("mailData") && !$updating);
		return $self->session->style->process($self->processTemplate($var,$self->get("acknowlegementTemplateId")),$self->get("styleTemplateId")) if $self->defaultViewForm;
	}
}

1;


