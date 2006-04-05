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
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Mail::Send;
use WebGUI::Macro;
use WebGUI::Inbox;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub _createField {
	my $self = shift;
	my $data = $_[0];
	my %param;
	$param{name} = $data->{name};
	$param{name} = "field_".$data->{sequenceNumber} if ($param{name} eq ""); # Empty fieldname not allowed
	my $name = $param{name};
	$name =~ s/\^.*?\;//gs ; # remove macro's from user input
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
		if ($self->session->form->param($name)) {
                	@defaultValues = $self->session->form->selectList($name);
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
	return &$cmd($self->session, \%param);
}

#-------------------------------------------------------------------
sub _fieldAdminIcons {
	my $self = shift;
	my $fid = shift;
	my $tid = shift;
	my $cantDelete = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	my $output;
	$output = $self->session->icon->delete('func=deleteFieldConfirm;fid='.$fid.';tid='.$tid,$self->get("url"),$i18n->get(19)) unless ($cantDelete);
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
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	my $output;
	$output = $self->session->icon->delete('func=deleteTabConfirm;tid='.$tid,$self->get("url"),$i18n->get(100)) unless ($cantDelete);
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
	my $self = shift;
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
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_DataForm");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
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
        return $class->SUPER::definition($session, $definition);
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
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	my $tabform = $self->SUPER::getEditForm;
	$tabform->getTab("display")->template(
		-name=>"templateId",
      		-value=>$self->getValue("templateId"),
      		-namespace=>"DataForm",
                -label=>$i18n->get(82),
                -hoverHelp=>$i18n->get('82 description'),
		-afterEdit=>'func=edit',
		-defaultValue=>"PBtmpl0000000000000141"
   		);
        $tabform->getTab("display")->template(
                -name=>"emailTemplateId",
                -value=>$self->getValue("emailTemplateId"),
                -namespace=>"DataForm",
                -label=>$i18n->get(80),
                -hoverHelp=>$i18n->get('80 description'),
                -afterEdit=>'func=edit'
                );
        $tabform->getTab("display")->template(
                -name=>"acknowlegementTemplateId",
                -value=>$self->getValue("acknowlegementTemplateId"),
                -namespace=>"DataForm",
                -label=>$i18n->get(81),
                -hoverHelp=>$i18n->get('81 description'),
                -afterEdit=>'func=edit'
                );
        $tabform->getTab("display")->template(
                -name=>"listTemplateId",
                -value=>$self->getValue("listTemplateId"),
                -namespace=>"DataForm/List",
                -label=>$i18n->get(87),
                -hoverHelp=>$i18n->get('87 description'),
                -afterEdit=>'func=edit'
                );
	$tabform->getTab("display")->radioList(
		-name=>"defaultView",
                -options=>{ 0 => $i18n->get('data form'),
                            1 => $i18n->get('data list'),},
		-label=>$i18n->get('defaultView'),
		-hoverHelp=>$i18n->get('defaultView description'),
		-value=>$self->getValue("defaultView"),
		);
	$tabform->getTab("properties")->HTMLArea(
		-name=>"acknowledgement",
		-label=>$i18n->get(16),
		-hoverHelp=>$i18n->get('16 description'),
		-value=>($self->get("acknowledgement") || $i18n->get(3))
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"mailData",
		-label=>$i18n->get(74),
		-hoverHelp=>$i18n->get('74 description'),
		-value=>$self->getValue("mailData")
		);

	$tabform->getTab("security")->group(
		-name=>"groupToViewEntries",
		-label=>$i18n->get('group to view entries'),
		-hoverHelp=>$i18n->get('group to view entries description'),
		-value=>$self->getValue("groupToViewEntries")
		);

	if ($self->getId eq "new" && $self->session->form->process("proceed") ne "manageAssets") {
        	$tabform->getTab("properties")->whatNext(
			-options=>{
				editField=>$i18n->get(76),
				""=>$i18n->get(745)
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
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	my @fieldLoop;
	$var->{"back.url"} = $self->getFormUrl;
	$var->{"back.label"} = $i18n->get('go to form');
	#$var->{"entryId"} = $self->getId;
	#$var->{"delete.url"} = $self->getUrl.";func=deleteAllEntries";
	#$var->{"delete.label"} = $i18n->get(91);
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
			"record.delete.icon"=>$self->session->icon->delete("func=deleteEntry;entryId=".$record->{Asset_DataForm_entryId}, $self->getUrl, $i18n->get('Delete entry confirmation')),
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
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	$var->{error_loop} = [] unless (exists $var->{error_loop});
	$var->{canEdit} = ($self->canEdit);
	#$var->{"entryList.url"} = $self->getUrl('func=view;entryId=list');
	$var->{"entryList.url"} = $self->getListUrl;
	$var->{"entryList.label"} = $i18n->get(86);
	$var->{"export.tab.url"} = $self->getUrl('func=exportTab');
	$var->{"export.tab.label"} = $i18n->get(84);
	$var->{"delete.url"} = $self->getUrl('func=deleteEntry;entryId='.$var->{entryId});
	$var->{"delete.label"} = $i18n->get(90);
	$var->{"back.url"} = $self->getUrl;
	$var->{"back.label"} = $i18n->get(18);
	$var->{"addField.url"} = $self->getUrl('func=editField');
	$var->{"addField.label"} = $i18n->get(76);
	# add Tab label, url, header and init
	$var->{"addTab.label"}=  $i18n->get(105);;
	$var->{"addTab.url"}= $self->getUrl('func=editTab');
	$var->{"tab.init"}= $self->_createTabInit($self->getId);
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
			my $formValue = $self->session->form->process($data{name});
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
				"tab.field.form" => $self->_createField(\%data),
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
	my $sth = $self->session->db->read("select from DataForm_field as a $join $where and a.DataForm_tabId = '0' order by a.sequenceNumber");
	while (%data = $sth->hash) {
		my $formValue = $self->session->form->process($data{name});
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
			"form" => $self->_createField(\%data),
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
	$var->{"form.send"} = WebGUI::Form::submit($self->session,{value=>$i18n->get(73)});
	$var->{"form.save"} = WebGUI::Form::submit($self->session,);
	$var->{"form.end"} = WebGUI::Form::formFooter($self->session,);
	return $var;
}



#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	# this one is so nutz that we don't even bother preparing, we just execute the whole thing
	my $passedVars = shift;
	##Priority encoding
	if ( $self->session->form->process("mode") eq "form") {
		$self->{_view} = $self->viewForm($passedVars);
	} elsif ( $self->session->form->process("mode") eq "list") {
		$self->{_view} = $self->viewList;
	} elsif( $self->defaultViewForm ) {
		$self->{_view} = $self->viewForm($passedVars);
	} else {
		$self->{_view} = $self->viewList();
	}
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {	
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $i18n = WebGUI::International->new($self->session, "Asset_DataForm");
	if ($self->session->form->process("assetId") eq "new") {
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"from",
			label=>$i18n->get(10),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"to",
			label=>$i18n->get(11),
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
			label=>$i18n->get(12),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"bcc",
			label=>$i18n->get(13),
			status=>"hidden",
			isMailField=>1,
			width=>0,
			type=>"email"
			});
		$self->setCollateral("DataForm_field","DataForm_fieldId",{
			DataForm_fieldId=>"new",
			DataForm_tabId=>0,
			name=>"subject",
			label=>$i18n->get(14),
			status=>"editable",
			isMailField=>1,
			width=>0,
			type=>"text",
			defaultValue=>$i18n->get(2)
			});
	}
	if ($self->session->form->process("fid") eq "new") { # hack to get proceed to work.
		$self->session->stow->set('whatNext',$self->session->form->process("proceed"));
	} else { $self->session->stow->set('whatNext','nothing'); }
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
		my $mail = WebGUI::Mail::Send->create($self->session,{to=>$to, subject=>$subject, cc=>$cc, from=>$from, bcc=>$bcc});
		$mail->addText($message);
		$mail->queue;
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
			WebGUI::Inbox->new($self->session)->addMessage({
				userId=>$userId,
				groupId=>$groupId,
				subject=>$subject,
				message=>$message,
				status=>'complete'
				});
                        my $mail =  WebGUI::Mail::Send->create($self->session,{to=>$cc, subject=>$subject, from=>$from});
			if ($cc) {
                               
				$mail->addText($message);
				$mail->queue;
                        }
                        if ($bcc) {
                                WebGUI::Mail::Send->create($self->session, {to=>$bcc, subject=>$subject, from=>$from});
				$mail->addText($message);
				$mail->queue;
                        }
                }
        }
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	return $self->{_view}; # see prepareView()
}

#-------------------------------------------------------------------

sub viewList {
	my $self = shift;
	return $self->session->privilege::insufficient() unless ($self->session->user->isInGroup($self->get("groupToViewEntries")));
	return $self->processTemplate($self->getListTemplateVars,$self->get("listTemplateId"));
}

#-------------------------------------------------------------------

sub viewForm {
	my $self = shift;
	my $passedVars = shift;
	my $var;
	$self->session->style->setLink($self->session->config->get("extrasURL").'/tabs/tabs.css', {"type"=>"text/css"});
	$self->session->style->setScript($self->session->config->get("extrasURL").'/tabs/tabs.js', {"type"=>"text/javascript"});
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
sub www_editField {
	my $self = shift;
	my $fid = shift || $self->session->form->process("fid") || 'new';
	$self->session->errorHandler->warn("fid: $fid");
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    	my (%field, $f, %fieldStatus,$tab);
    	tie %field, 'Tie::CPHash';
    	tie %fieldStatus, 'Tie::IxHash';
	%fieldStatus = ( 
		"hidden" => $i18n->get(4),
		"visible" => $i18n->get(5),
		"editable" => $i18n->get(6),
		"required" => $i18n->get(75) 
		);
	unless ($fid eq "new") {	
        	%field = $self->session->db->quickHash("select * from DataForm_field where DataForm_fieldId=".$self->session->db->quote($fid));
	}
	$tab = $self->session->db->buildHashRef("select DataForm_tabId,label from DataForm_tab where assetId=".$self->session->db->quote($self->getId));
	$tab->{0} = $i18n->get("no tab");
        $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "fid",
		-value => $fid
	);
        $f->hidden(
		-name => "func",
		-value => "editFieldSave"
	);
	$f->text(
                -name=>"label",
                -label=>$i18n->get(77),
                -hoverHelp=>$i18n->get('77 description'),
                -value=>$field{label}
                );
        $f->text(
		-name=>"name",
		-label=>$i18n->get(21),
		-hoverHelp=>$i18n->get('21 description'),
		-value=>$field{name}
		);
	if($field{sequenceNumber} && ! $field{isMailField}) {
		$f->integer(
			-name=>"position",
			-label=>$i18n->get('Field Position'),
			-hoverHelp=>$i18n->get('Field Position description'),
			-value=>$field{sequenceNumber}
		);	
	}
	$f->selectBox(
		-name=>"tid",
		-options=>$tab,
		-label=>$i18n->get(104),
		-hoverHelp=>$i18n->get('104 description'),
		-value=>[ $field{DataForm_tabId} || 0 ]
		); 
        $f->text(
                -name=>"subtext",
                -value=>$field{subtext},
                -label=>$i18n->get(79),
                -hoverHelp=>$i18n->get('79 description'),
                );
        $f->selectBox(
		-name=>"status",
		-options=>\%fieldStatus,
		-label=>$i18n->get(22),
		-hoverHelp=>$i18n->get('22 description'),
		-value=> [ $field{status} || "editable" ] ,
		); 
	$f->fieldType(
		-name=>"type",
		-label=>$i18n->get(23),
		-hoverHelp=>$i18n->get('23 description'),
		-value=>$field{type} || "text",
		-types=>[qw(dateTime TimeField float zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList)]
		);
	$f->integer(
		-name=>"width",
		-label=>$i18n->get(8),
		-hoverHelp=>$i18n->get('8 description'),
		-value=>($field{width} || 0)
		);
	$f->integer(
                -name=>"rows",
		-value=>$field{rows} || 0,
		-label=>$i18n->get(27),
		-hoverHelp=>$i18n->get('27 description'),
		-subtext=>$i18n->get(28),
		);
	$f->yesNo(
		-name=>"vertical",
		-value=>$field{vertical},
		-label=>$i18n->get('editField vertical label'),
		-hoverHelp=>$i18n->get('editField vertical label description'),
		-subtext=>$i18n->get('editField vertical subtext')
		);
	$f->text(
		-name=>"extras",
		-value=>$field{extras},
		-label=>$i18n->get('editField extras label'),
		-hoverHelp=>$i18n->get('editField extras label description'),
		);
        $f->textarea(
		-name=>"possibleValues",
		-label=>$i18n->get(24),
		-hoverHelp=>$i18n->get('24 description'),
		-value=>$field{possibleValues},
		-subtext=>'<br />'.$i18n->get(85)
		);
        $f->textarea(
		-name=>"defaultValue",
		-label=>$i18n->get(25),
		-hoverHelp=>$i18n->get('25 description'),
		-value=>$field{defaultValue},
		-subtext=>'<br />'.$i18n->get(85)
		);
	if ($fid eq "new" && $self->session->form->process("proceed") ne "manageAssets") {
        	$f->whatNext(
			-options=>{
				"editField"=>$i18n->get(76),
				"viewDataForm"=>$i18n->get(745)
				},
			-value=>"editField"
			);
	}
        $f->submit;
	my $ac = $self->getAdminConsole;
	$ac->setHelp("data form fields add/edit","Asset_DataForm");
        return $ac->render($f->print,$i18n->get('20'));
}

#-------------------------------------------------------------------
sub www_editFieldSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->session->form->process("name") = $self->session->form->process("label") if ($self->session->form->process("name") eq "");
	my $tid = $self->session->form->process("tid", 'selectBox') || "0";
	my $name = $self->session->url->urlize($self->session->form->process("name"));
        $name =~ s/\-//g;
        $name =~ s/\///g;
	$self->setCollateral("DataForm_field","DataForm_fieldId",{
		DataForm_fieldId=>$self->session->form->process("fid"),
		width=>$self->session->form->process("width", 'integer'),
		name=>$name,
		label=>$self->session->form->process("label"),
		DataForm_tabId=>$tid,
		status=>$self->session->form->process("status", 'selectBox'),
		type=>$self->session->form->process("type", 'fieldType'),
		possibleValues=>$self->session->form->process("possibleValues", 'textarea'),
		defaultValue=>$self->session->form->process("defaultValue", 'textarea'),
		subtext=>$self->session->form->process("subtext"),
		rows=>$self->session->form->process("rows", 'integer'),
		vertical=>$self->session->form->process("vertical", 'yesNo'),
		extras=>$self->session->form->process("extras"),
		}, "1","1", _tonull("DataForm_tabId",$tid));
	if($self->session->form->process("position")) {
		$self->session->db->write("update DataForm_field set sequenceNumber=".$self->session->db->quote($self->session->form->process("position", 'integer')).
					" where DataForm_fieldId=".$self->session->db->quote($self->session->form->process("fid")));
	}
	$self->reorderCollateral("DataForm_field","DataForm_fieldId", _tonull("DataForm_tabId",$tid)) if ($self->session->form->process("fid") ne "new");
        if ($self->session->stow->get('whatNext') eq "editField" || $self->session->form->process("proceed") eq "editField") {
            return $self->www_editField('new');
        }
        return "";
}

#-------------------------------------------------------------------
sub www_editTab {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    	my (%tab, $f);
    	tie %tab, 'Tie::CPHash';
        my $tid = shift || $self->session->form->process("tid") || "new";
	$self->session->errorHandler->warn("tid: $tid");
	unless ($tid eq "new") {	
        	%tab = $self->session->db->quickHash("select * from DataForm_tab where DataForm_tabId=".$self->session->db->quote($tid));
	}
        $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "tid",
		-value => $tid
	);
        $f->hidden(
		-name => "func",
		-value => "editTabSave"
	);
	$f->text(
                -name=>"label",
		-label=>$i18n->get(101),
                -value=>$tab{label}
                );
        $f->textarea(
		-name=>"subtext",
		-label=>$i18n->get(79),
		-value=>$tab{subtext},
		-subtext=>""
		);
	if ($tid eq "new") {
        	$f->whatNext(
			-options=>{
				editTab=>$i18n->get(103),
				""=>$i18n->get(745)
				},
			-value=>"editTab"
			);
	}
        $f->submit;
	my $ac = $self->getAdminConsole;
	$ac->setHelp("data form fields add/edit","Asset_DataForm");
	return $ac->render($f->print,$i18n->get('103')) if $tid eq "new";
	return $ac->render($f->print,$i18n->get('102'));
}

#-------------------------------------------------------------------
sub www_editTabSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $name = $self->session->form->process("name") || $self->session->form->process("label");;
	$name = $self->session->url->urlize($name);
	$name =~ s/\-//g;
	$name =~ s/\///g;
	$self->setCollateral("DataForm_tab","DataForm_tabId",{
		DataForm_tabId=>$self->session->form->process("tid"),
		label=>$self->session->form->process("label"),
		subtext=>$self->session->form->process("subtext", 'textarea')
		});
        if ($self->session->form->process("proceed") eq "editTab") {
            return $self->www_editTab("new");
        }
        return "";
}

#-------------------------------------------------------------------
sub www_exportTab {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        $self->session->http->setFilename($self->get("url").".tab","text/plain");
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
	return $self->session->privilege->insufficient() unless $self->canView;
	my $entryId = $self->setCollateral("DataForm_entry","DataForm_entryId",{
		DataForm_entryId=>$self->session->form->process("entryId"),
                assetId=>$self->getId,
                userId=>$self->session->user->userId,
                username=>$self->session->user->username,
                ipAddress=>$self->session->env->get("REMOTE_ADDR"),
                submissionDate=>$self->session->datetime->time()
		},0);
	my ($var, %row, @errors, $updating, $hadErrors);
	$var->{entryId} = $entryId;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
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
				"error.message"=>$row{label}." ".$i18n->get(29).".",
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
					where DataForm_entryId=".$self->session->db->quote($entryId)." and DataForm_fieldId=".$self->session->db->quote($row{DataForm_fieldId})) if $self->canEdit;
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
		$self->prepareView($var);
		$self->processStyle($self->view);
	} else {
		$self->sendEmail($var) if ($self->get("mailData") && !$updating);
		return $self->session->style->process($self->processTemplate($var,$self->get("acknowlegementTemplateId")),$self->get("styleTemplateId")) if $self->defaultViewForm;
	}
}

#-------------------------------------------------------------------
=head2 www_view ( )

Overwrite www_view method and call the superclass object, passing in a 1 to disable cache

=cut

sub www_view {
	my $self = shift;
	$self->SUPER::www_view(1);
	
}

1;


