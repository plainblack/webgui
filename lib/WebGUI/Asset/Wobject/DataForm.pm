package WebGUI::Asset::Wobject::DataForm;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
                	@defaultValues = WebGUI::FormProcessor::selectList($param{name});
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
	$output = deleteIcon('func=deleteFieldConfirm;fid='.$fid.';tid='.$tid,$self->get("url"),WebGUI::International::get(19,"Asset_DataForm")) unless ($cantDelete);
	$output .= editIcon('func=editField;fid='.$fid.';tid='.$tid,$self->get("url"))
		.moveUpIcon('func=moveFieldUp;fid='.$fid.';tid='.$tid,$self->get("url"))
		.moveDownIcon('func=moveFieldDown;fid='.$fid.';tid='.$tid,$self->get("url"));
	return $output;
}
#-------------------------------------------------------------------
sub _tabAdminIcons {
	my $self = shift;
	my $tid = shift;
	my $cantDelete = shift;
	my $output;
	$output = deleteIcon('func=deleteTabConfirm;tid='.$tid,$self->get("url"),WebGUI::International::get(100,"Asset_DataForm")) unless ($cantDelete);
	$output .= editIcon('func=editTab;tid='.$tid,$self->get("url"))
		.moveLeftIcon('func=moveTabLeft;tid='.$tid,$self->get("url"))
		.moveRightIcon('func=moveTabRight;tid='.$tid,$self->get("url"));
	return $output;
}


#-------------------------------------------------------------------
sub _tonull { 
	return $_[1] eq "0" ? (undef, undef) : @_ ;
}


#-------------------------------------------------------------------
sub _createTabInit {
	my $id = shift;
	my @tabCount = WebGUI::SQL->quickArray("select count(DataForm_tabId) from DataForm_tab where assetId=".quote($id));
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
				}
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
       $sthTab = WebGUI::SQL->read("select * from DataForm_tab where assetId=".quote($self->getId));
       while (%dataTab = $sthTab->hash) {
               $sthField = WebGUI::SQL->read("select * from DataForm_field where assetId=".quote($self->getId)." AND DataForm_tabId=".quote($dataTab{DataForm_tabId}));
               $dataTab{DataForm_tabId} = "new";
               $newTabId = $newAsset->setCollateral("DataForm_tab","DataForm_tabId",\%dataTab);
               while (%dataField = $sthField->hash) {
                       $dataField{DataForm_fieldId} = "new";
                       $dataField{DataForm_tabId} = $newTabId;
                       $newAsset->setCollateral("DataForm_field","DataForm_fieldId",\%dataField);
               }
               $sthField->finish;
       }
       $sthField = WebGUI::SQL->read("select * from DataForm_field where assetId=".quote($self->getId)." AND DataForm_tabId='0'");
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
	if ($self->getId eq "new" && $session{form}{proceed} ne "manageAssets") {
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
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		DataForm_field => {
                        sql => "select DataForm_field.label as label,
                                        DataForm_field.subtext as subtext,
                                        DataForm_field.possibleValues as possibleValues,
                                        DataForm_field.assetId as assetId,
                                        DataForm_field.DataForm_fieldId as fid,
                                        asset.ownerUserId as ownerId,
                                        asset.url as url,
                                        asset.groupIdView as groupIdView
                                        from DataForm_field, asset
                                        where DataForm_field.assetId = asset.assetId
					and asset.startDate < $now
					and asset.endDate > $now",
                        fieldsToIndex => ["label", "subtext", "possibleValues"],
                        contentType => 'content',
                        url => 'WebGUI::URL::gateway($data{url})',
                        headerShortcut => 'select label from DataForm_field where DataForm_fieldId = \'$data{fid}\'',
                        bodyShortcut => 'select subtext, possibleValues from DataForm_field where DataForm_fieldId = \'$data{fid}\'',
                },
        DataForm_entryData => {
                        sql => "select distinct(DataForm_entryData.assetId) as assetId,
                                        asset.ownerUserId as ownerId,
                                        asset.url as url,
                                        asset.groupIdView as groupIdView,
                                        asset.groupIdEdit as special_groupIdView
                                        from DataForm_entryData, asset
                                        where DataForm_entryData.assetId = asset.assetId
					and asset.startDate < $now
					and asset.endDate > $now",
                        fieldsToIndex => ['select distinct(value) from DataForm_entryData where assetId = \'$data{assetId}\''],
                        contentType => 'assetDetail',
                        url => 'WebGUI::URL::append($data{url}, "func=viewList}")',
                        headerShortcut => 'select title from asset where assetId = \'$data{assetId}\'',
                }
	};
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
	my $fields = WebGUI::SQL->read("select DataForm_fieldId,name,label,isMailField,type from DataForm_field
			where assetId=".quote($self->getId)." order by sequenceNumber");
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
	my $entries = WebGUI::SQL->read("select ipAddress,username,userid,submissionDate,DataForm_entryId from DataForm_entry 
		where assetId=".quote($self->getId)." order by submissionDate desc");
	while (my $record = $entries->hashRef) {
		my @dataLoop;
		my $dloop = WebGUI::SQL->read("select b.name, b.label, b.isMailField, a.value from DataForm_entryData a left join DataForm_field b
			on a.DataForm_fieldId=b.DataForm_fieldId where a.DataForm_entryId=".quote($record->{DataForm_entryId})."
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
			"record.edit.icon"=>editIcon("func=view;entryId=".$record->{DataForm_entryId}, $self->getUrl),
			"record.delete.url"=>$self->getUrl("func=deleteEntry;entryId=".$record->{DataForm_entryId}),
			"record.delete.icon"=>deleteIcon("func=deleteEntry;entryId=".$record->{Asset_DataForm_entryId}, $self->getUrl, WebGUI::International::get('Delete entry confirmation',"Asset_DataForm")),
			"record.username"=>$record->{username},
			"record.userId"=>$record->{userId},
			"record.submissionDate.epoch"=>$record->{submissionDate},
			"record.submissionDate.human"=>WebGUI::DateTime::epochToHuman($record->{submissionDate}),
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
                $url = WebGUI::URL::append($url, 'mode=form');
        }
        if ($params) {
                $url = WebGUI::URL::append($url, $params);
        }
        return $url;
}

#-------------------------------------------------------------------

sub getListUrl {
        my $self = shift;
        my $params = shift;
        my $url = $self->getUrl;
        if ($self->defaultViewForm) {
                $url = WebGUI::URL::append($url, 'mode=list');
        }
        if ($params) {
                $url = WebGUI::URL::append($url, $params);
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
	$var->{"form.start"} = WebGUI::Form::formHeader({action=>$self->getUrl})
		.WebGUI::Form::hidden({name=>"func",value=>"process"});
	my @tabs;
	my $select = "select a.name, a.DataForm_fieldId, a.DataForm_tabId,a.label, a.status, a.isMailField, a.subtext, a.type, a.defaultValue, a.possibleValues, a.width, a.rows, a.extras, a.vertical";
	my $join;
	my $where = "where a.assetId=".quote($self->getId);
	if ($var->{entryId}) {
		$var->{"form.start"} .= WebGUI::Form::hidden({name=>"entryId",value=>$var->{entryId}});
		my $entry = $self->getCollateral("DataForm_entry","DataForm_entryId",$var->{entryId});
		$var->{ipAddress} = $entry->{ipAddress};
		$var->{username} = $entry->{username};
		$var->{userId} = $entry->{userId};
		$var->{date} = WebGUI::DateTime::epochToHuman($entry->{submissionDate});
		$var->{epoch} = $entry->{submissionDate};
		$var->{"edit.URL"} = $self->getFormUrl('entryId='.$var->{entryId});
		$where .= " and b.DataForm_entryId=".quote($var->{entryId});
		$join = "left join DataForm_entryData as b on a.DataForm_fieldId=b.DataForm_fieldId";
		$select .= ", b.value";
	}
	my %data;
	tie %data, 'Tie::CPHash';
	my %tab;
	tie %tab, 'Tie::CPHash';
	my $tabsth = WebGUI::SQL->read("select * from DataForm_tab where assetId=".quote($self->getId)." order by sequenceNumber");
	while (%tab = $tabsth->hash) {
		my @fields;
		my $sth = WebGUI::SQL->read("$select from DataForm_field as a $join $where and a.DataForm_tabId=".quote($tab{DataForm_tabId})." order by a.sequenceNumber");
		while (%data = $sth->hash) {
			my $formValue = $session{form}{$data{name}};
			if ((not exists $data{value}) && $session{form}{func} ne "editSave" && $session{form}{func} ne "editFieldSave" && defined $formValue) {
				$data{value} = $formValue;
				$data{value} = WebGUI::DateTime::setToEpoch($data{value}) if ($data{type} eq "date");
			}
			if (not exists $data{value}) {
				my $defaultValue = $data{defaultValue};
				WebGUI::Macro::process(\$defaultValue);
				$data{value} = $defaultValue;
			}
			my $hidden = (($data{status} eq "hidden" && !$session{var}{adminOn}) || ($data{isMailField} && !$self->get("mailData")));
			my $value = $data{value};
			$value = WebGUI::DateTime::epochToHuman($value,"%z") if ($data{type} eq "date");
			$value = WebGUI::DateTime::epochToHuman($value,"%z %Z") if ($data{type} eq "dateTime");
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
	my $sth = WebGUI::SQL->read("$select from DataForm_field as a $join $where and a.DataForm_tabId = 0 order by a.sequenceNumber");
	while (%data = $sth->hash) {
		my $formValue = $session{form}{$data{name}};
		if ((not exists $data{value}) && $session{form}{func} ne "editSave" && $session{form}{func} ne "editFieldSave" && defined $formValue) {
			$data{value} = $formValue;
			$data{value} = WebGUI::DateTime::setToEpoch($data{value}) if ($data{type} eq "date");
		}
		if (not exists $data{value}) {
			my $defaultValue = $data{defaultValue};
			WebGUI::Macro::process(\$defaultValue);
			$data{value} = $defaultValue;
		}
		my $hidden = (($data{status} eq "hidden" && !$session{var}{adminOn}) || ($data{isMailField} && !$self->get("mailData")));
		my $value = $data{value};
		$value = WebGUI::DateTime::epochToHuman($value,"%z") if ($data{type} eq "date");
		$value = WebGUI::DateTime::epochToHuman($value) if ($data{type} eq "dateTime");
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
	$var->{"form.send"} = WebGUI::Form::submit({value=>WebGUI::International::get(73, "Asset_DataForm")});
	$var->{"form.save"} = WebGUI::Form::submit();
	$var->{"form.end"} = WebGUI::Form::formFooter();
	return $var;
}



#-------------------------------------------------------------------
sub processPropertiesFromFormPost {	
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($session{form}{assetId} eq "new") {
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"from",
			label=>WebGUI::International::get(10,"Asset_DataForm"),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"to",
			label=>WebGUI::International::get(11,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email",
			defaultValue=>$session{setting}{companyEmail}
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"cc",
			label=>WebGUI::International::get(12,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"bcc",
			label=>WebGUI::International::get(13,"Asset_DataForm"),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			name=>"subject",
			label=>WebGUI::International::get(14,"Asset_DataForm"),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"text",
			defaultValue=>WebGUI::International::get(2,"Asset_DataForm")
			});
	}
	if ($session{form}{fid} eq "new") { # hack to get proceed to work.
		$session{whatNext} = $session{form}{proceed};
	} else { $session{whatNext} = "nothing"; }
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
    	WebGUI::SQL->write("delete from DataForm_field where assetId=".quote($self->getId));
    	WebGUI::SQL->write("delete from DataForm_entry where assetId=".quote($self->getId));
    	WebGUI::SQL->write("delete from DataForm_entryData where assetId=".quote($self->getId));
	WebGUI::SQL->write("delete from DataForm_tab where assetId=".quote($self->getId));
    	$self->SUPER::purge();
}

#-------------------------------------------------------------------
sub sendEmail {
	my $self = shift;
	my $var = shift;
	my $message = $self->processTemplate($var,$self->get("emailTemplateId"));
	WebGUI::Macro::process(\$message);
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
                my ($userId) = WebGUI::SQL->quickArray("select userId from users where username=".quote($to));
                my $groupId;
                # if no user is found, try finding a matching group
                unless ($userId) {
                        ($groupId) = WebGUI::SQL->quickArray("select groupId from groups where groupName=".quote($to));
                }
                unless ($userId || $groupId) {
                        WebGUI::ErrorHandler::warn($self->getId.": Unable to send message, no user or group found.");
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
        if ( $session{form}{mode} eq "form") {
                $self->viewForm($passedVars);
        }
        elsif ( $session{form}{mode} eq "list") {
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
        return $self->processTemplate($self->getListTemplateVars,$self->get("listTemplateId"));
}

#-------------------------------------------------------------------

sub viewForm {
	my $self = shift;
	my $passedVars = shift;
	WebGUI::Style::setLink($session{config}{extrasURL}.'/tabs/tabs.css', {"type"=>"text/css"});
	WebGUI::Style::setScript($session{config}{extrasURL}.'/tabs/tabs.js', {"type"=>"text/javascript"});
	my $var;
	$var->{entryId} = $session{form}{entryId} if ($self->canEdit);
	$var = $passedVars || $self->getRecordTemplateVars($var);
	return $self->processTemplate($var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_deleteAllEntries {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
        my $assetId = $session{form}{entryId};
	$self->deleteCollateral("DataForm_entry","assetId",$assetId);
        $session{form}{entryId} = 'list';
        return "";
}

#-------------------------------------------------------------------
sub www_deleteAllEntriesConfirm {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit && $session{form}{entryId}==$self->getId);
	WebGUI::SQL->write("delete from DataForm_entry where assetId=".quote($self->getId));
	return $self->www_view;
}


#-------------------------------------------------------------------
sub www_deleteEntry {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
        my $entryId = $session{form}{entryId};
	$self->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
        $session{form}{entryId} = 'list';
        return "";
}

#-------------------------------------------------------------------
sub www_deleteFieldConfirm {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->deleteCollateral("DataForm_field","DataForm_fieldId",$session{form}{fid});
	$self->reorderCollateral("DataForm_field","DataForm_fieldId");
       	return "";
}

#-------------------------------------------------------------------
sub www_deleteTabConfirm {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->deleteCollateral("DataForm_tab","DataForm_tabId",$session{form}{tid});
	$self->deleteCollateral("DataForm_field","DataForm_tabId",$session{form}{tid});
	$self->reorderCollateral("DataForm_tab","DataForm_tabId");
       	return "";
}

#-------------------------------------------------------------------
#sub www_edit {
#        my $self = shift;
#	return WebGUI::Privilege::insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("data form add/edit","Asset_DataForm");
#        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("7","Asset_DataForm"));
#}

#-------------------------------------------------------------------
sub www_editField {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
    	my (%field, $f, %fieldStatus,$tab);
    	tie %field, 'Tie::CPHash';
    	tie %fieldStatus, 'Tie::IxHash';
	%fieldStatus = ( 
		"hidden" => WebGUI::International::get(4, "Asset_DataForm"),
		"visible" => WebGUI::International::get(5, "Asset_DataForm"),
		"editable" => WebGUI::International::get(6, "Asset_DataForm"),
		"required" => WebGUI::International::get(75, "Asset_DataForm") 
		);
        $session{form}{fid} = "new" if ($session{form}{fid} eq "");
	unless ($session{form}{fid} eq "new") {	
        	%field = WebGUI::SQL->quickHash("select * from DataForm_field where DataForm_fieldId=".quote($session{form}{fid}));
	}
	$tab = WebGUI::SQL->buildHashRef("select DataForm_tabId,label from DataForm_tab where assetId=".quote($self->getId));
	$tab->{0} = WebGUI::International::get("no tab","Asset_DataForm");
        $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
		-name => "fid",
		-value => $session{form}{fid}
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
	if ($session{form}{fid} eq "new" && $session{form}{proceed} ne "manageAssets") {
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
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$session{form}{name} = $session{form}{label} if ($session{form}{name} eq "");
	$session{form}{tid} = "0" if ($session{form}{tid} eq "");
	$session{form}{name} = WebGUI::URL::urlize($session{form}{name});
        $session{form}{name} =~ s/\-//g;
        $session{form}{name} =~ s/\///g;
	$self->setCollateral("DataForm_field","DataForm_fieldId",{
		DataForm_fieldId=>$session{form}{fid},
		width=>$session{form}{width},
		name=>$session{form}{name},
		label=>$session{form}{label},
		DataForm_tabId=>$session{form}{tid},
		status=>$session{form}{status},
		type=>$session{form}{type},
		possibleValues=>$session{form}{possibleValues},
		defaultValue=>$session{form}{defaultValue},
		subtext=>$session{form}{subtext},
		rows=>$session{form}{rows},
		vertical=>$session{form}{vertical},
		extras=>$session{form}{extras},
		}, "1","1", _tonull("DataForm_tabId",$session{form}{tid}));
	if($session{form}{position}) {
		WebGUI::SQL->write("update DataForm_field set sequenceNumber=".quote($session{form}{position}).
					" where DataForm_fieldId=".quote($session{form}{fid}));
	}
	$self->reorderCollateral("DataForm_field","DataForm_fieldId", _tonull("DataForm_tabId",$session{form}{tid})) if ($session{form}{fid} ne "new");
        if ($session{whatNext} eq "editField" || $session{form}{proceed} eq "editField") {
            $session{form}{fid} = "new";
            return $self->www_editField;
        }
        return "";
}

#-------------------------------------------------------------------
sub www_editTab {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
    	my (%tab, $f);
    	tie %tab, 'Tie::CPHash';
        $session{form}{tid} = "new" if ($session{form}{tid} eq "");
	unless ($session{form}{tid} eq "new") {	
        	%tab = WebGUI::SQL->quickHash("select * from DataForm_tab where DataForm_tabId=".quote($session{form}{tid}));
	}
        $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
		-name => "tid",
		-value => $session{form}{tid}
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
	if ($session{form}{tid} eq "new") {
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
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$session{form}{name} = $session{form}{label} if ($session{form}{name} eq "");
	$session{form}{name} = WebGUI::URL::urlize($session{form}{name});
        $session{form}{name} =~ s/\-//g;
        $session{form}{name} =~ s/\///g;
	$self->setCollateral("DataForm_tab","DataForm_tabId",{
		DataForm_tabId=>$session{form}{tid},
		label=>$session{form}{label},
		subtext=>$session{form}{subtext}
		});
        if ($session{form}{proceed} eq "editTab") {
            $session{form}{tid} = "new";
            return $self->www_editTab;
        }
        return "";
}

#-------------------------------------------------------------------
sub www_exportTab {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        WebGUI::HTTP::setFilename($self->get("url").".tab","text/plain");
        my %fields = WebGUI::SQL->buildHash("select DataForm_fieldId,name from DataForm_field where
                assetId=".quote($self->getId)." order by sequenceNumber");
        my @data;
        my $entries = WebGUI::SQL->read("select * from DataForm_entry where assetId=".quote($self->getId));
        my $i;
        my $noMailData = ($self->get("mailData") == 0);
        while (my $entryData = $entries->hashRef) {
                $data[$i] = {
                        entryId => $entryData->{DataForm_entryId},
                        ipAddress => $entryData->{ipAddress},
                        username => $entryData->{username},
                        userId => $entryData->{userId},
                        submissionDate => WebGUI::DateTime::epochToHuman($entryData->{submissionDate}),
                        };
                my $values = WebGUI::SQL->read("select value,DataForm_fieldId from DataForm_entryData where
                        DataForm_entryId=".quote($entryData->{DataForm_entryId}));
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
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->moveCollateralDown("DataForm_field","DataForm_fieldId",$session{form}{fid},_tonull("DataForm_tabId",$session{form}{tid}));
	return "";
}

#-------------------------------------------------------------------
sub www_moveFieldUp {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->moveCollateralUp("DataForm_field","DataForm_fieldId",$session{form}{fid},_tonull("DataForm_tabId",$session{form}{tid}));
	return "";
}

#-------------------------------------------------------------------
sub www_moveTabRight {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->moveCollateralDown("DataForm_tab","DataForm_tabId",$session{form}{tid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveTabLeft {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->moveCollateralUp("DataForm_tab","DataForm_tabId",$session{form}{tid});
	return "";
}

#-------------------------------------------------------------------
sub www_process {
	my $self = shift;
	my $entryId = $self->setCollateral("DataForm_entry","DataForm_entryId",{
		DataForm_entryId=>$session{form}{entryId},
                assetId=>$self->getId,
                userId=>$session{user}{userId},
                username=>$session{user}{username},
                ipAddress=>$session{env}{REMOTE_ADDR},
                submissionDate=>time()
		},0);
	my ($var, %row, @errors, $updating, $hadErrors);
	$var->{entryId} = $entryId;
	tie %row, "Tie::CPHash";
	my $sth = WebGUI::SQL->read("select DataForm_fieldId,label,name,status,type,defaultValue,isMailField from DataForm_field 
		where assetId=".quote($self->getId)." order by sequenceNumber");
	while (%row = $sth->hash) {
		my $value = $row{defaultValue};
		if ($row{status} eq "required" || $row{status} eq "editable") {
			$value = WebGUI::FormProcessor::process($row{name},$row{type},$row{defaultValue});
			WebGUI::Macro::filter(\$value);
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
                        WebGUI::Macro::process(\$value);
                }
		unless ($hadErrors) {
			my ($exists) = WebGUI::SQL->quickArray("select count(*) from DataForm_entryData where DataForm_entryId=".quote($entryId)."
				and DataForm_fieldId=".quote($row{DataForm_fieldId}));
			if ($exists) {
				WebGUI::SQL->write("update DataForm_entryData set value=".quote($value)."
					where DataForm_entryId=".quote($entryId)." and DataForm_fieldId=".quote($row{DataForm_fieldId}));
				$updating = 1;
			} else {
				WebGUI::SQL->write("insert into DataForm_entryData (DataForm_entryId,DataForm_fieldId,assetId,value) values
					(".quote($entryId).", ".quote($row{DataForm_fieldId}).", ".quote($self->getId).", ".quote($value).")");
			}
		}
	}
	$sth->finish;
	$var->{error_loop} = \@errors;
	$var = $self->getRecordTemplateVars($var);
	if ($hadErrors && !$updating) {
		WebGUI::SQL->write("delete from DataForm_entryData where DataForm_entryId=".quote($entryId));
		$self->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
		$self->processStyle($self->view($var));
	} else {
		$self->sendEmail($var) if ($self->get("mailData") && !$updating);
		return WebGUI::Style::process($self->processTemplate($var,$self->get("acknowlegementTemplateId")),$self->get("styleTemplateId")) if $self->defaultViewForm;
	}
}

1;


