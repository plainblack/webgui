package WebGUI::Operation::ProfileSettings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Operation::Shared;

#-------------------------------------------------------------------
sub _reorderCategories {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select profileCategoryId from userProfileCategory order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber='$i' where profileCategoryId=".quote($id));
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _reorderFields {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select fieldName from userProfileField where profileCategoryId=".quote($_[0])." order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                WebGUI::SQL->write("update userProfileField set sequenceNumber='$i' where fieldName=".quote($id));
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        my $help = shift;
	my $namespace = shift;
        $title = WebGUI::International::get($title,$namespace) if ($title);
        my $ac = WebGUI::AdminConsole->new("userProfiling");
        if ($help) {
                $ac->setHelp($help,"WebGUIProfile");
        }
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileCategory;cid=new"), WebGUI::International::get(490,"WebGUIProfile"));
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileField;fid=new"), WebGUI::International::get(491,"WebGUIProfile"));
        if ((($session{form}{op} eq "editProfileField" && $session{form}{fid} ne "new") || $session{form}{op} eq "deleteProfileField") && $session{form}{cid} eq "") {
		$ac->addSubmenuItem(WebGUI::URL::page('op=editProfileField;fid='.$session{form}{fid}), WebGUI::International::get(787,"WebGUIProfile"));
		$ac->addSubmenuItem(WebGUI::URL::page('op=deleteProfileField;fid='.$session{form}{fid}), WebGUI::International::get(788,"WebGUIProfile"));
	}
        if ((($session{form}{op} eq "editProfileCategory" && $session{form}{cid} ne "new") || $session{form}{op} eq "deleteProfileCategory") && $session{form}{fid} eq "") {
		$ac->addSubmenuItem(WebGUI::URL::page('op=editProfileCategory;cid='.$session{form}{cid}), WebGUI::International::get(789,"WebGUIProfile"));
		$ac->addSubmenuItem(WebGUI::URL::page('op=deleteProfileCategory;cid='.$session{form}{cid}), WebGUI::International::get(790,"WebGUIProfile"));
        }
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileSettings"), WebGUI::International::get(492,"WebGUIProfile"));
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::AdminConsole->new("userProfiling")->render(WebGUI::Privilege::vitalComponent()) if (length($session{form}{cid}) != 22 &&  $session{form}{cid} < 1000 && $session{form}{cid} > 0);
	WebGUI::SQL->write("delete from userProfileCategory where profileCategoryId=".quote($session{form}{cid}));
	WebGUI::SQL->write("update userProfileField set profileCategoryId='1' where profileCategoryId=".quote($session{form}{cid}));
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($protected);
	($protected) = WebGUI::SQL->quickArray("select protected from userProfileField where fieldname=".quote($session{form}{fid}));
        return WebGUI::AdminConsole->new("userProfiling")->render(WebGUI::Privilege::vitalComponent()) if ($protected);
	WebGUI::SQL->write("delete from userProfileField where fieldName=".quote($session{form}{fid}));
	WebGUI::SQL->write("delete from userProfileData where fieldName=".quote($session{form}{fid}));
        return www_editProfileSettings(); 
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, %data);
	tie %data, 'Tie::CPHash';
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => "op",
		-value => "editProfileCategorySave",
	);
	if ($session{form}{cid}) {
		$f->hidden(
			-name => "cid",
			-value => $session{form}{cid},
		);
		$f->readOnly(
			-name => $session{form}{cid},
			-label => WebGUI::International::get(469,"WebGUIProfile"),
		);
		%data = WebGUI::SQL->quickHash("select * from userProfileCategory where profileCategoryId=".quote($session{form}{cid}));
	} else {
                $f->hidden(
			-name => "cid",
			-value => "new"
		);
	}
	$f->text(
		-name => "categoryName",
		-label => WebGUI::International::get(470,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('470 description',"WebGUIProfile"),
		-value => $data{categoryName},
	);
	$f->yesNo(
                -name=>"visible",
                -label=>WebGUI::International::get(473,"WebGUIProfile"),
                -hoverHelp=>WebGUI::International::get('473 description',"WebGUIProfile"),
                -value=>$data{visible}
                );
	$f->yesNo(
		-name=>"editable",
		-value=>$data{editable},
		-label=>WebGUI::International::get(897,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('897 description',"WebGUIProfile"),
		);
	$f->submit;
	$output .= $f->print;
	return _submenu($output,'468','user profile category add/edit','WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($sequenceNumber, $test);
	$session{form}{categoryName} = 'Unamed' if ($session{form}{categoryName} eq "" || $session{form}{categoryName} eq "''");
	if ($session{form}{cid} eq "new") {
		$session{form}{cid} = WebGUI::Id::generate();
		($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileCategory");
		WebGUI::SQL->write("insert into userProfileCategory (profileCategoryId,sequenceNumber) values (".quote($session{form}{cid}).", "
			.($sequenceNumber+1).")");
	}
	WebGUI::SQL->write("update userProfileCategory set categoryName=".quote($session{form}{categoryName}).", 
		editable=".$session{form}{editable}.", visible=".$session{form}{visible}." 
		where profileCategoryId=".quote($session{form}{cid}));
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, %data, %hash, $key);
	tie %data, 'Tie::CPHash';
        $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editProfileFieldSave",
        );
	if ($session{form}{fid} ne 'new') {
              	$f->hidden(
			-name => "fid",
			-value => $session{form}{fid},
              	);
		$f->readOnly(
			-value => $session{form}{fid},
			-label => WebGUI::International::get(475,"WebGUIProfile"),
			-hoverHelp => WebGUI::International::get('475 description',"WebGUIProfile"),
		);
		%data = WebGUI::SQL->quickHash("select * from userProfileField where fieldName=".quote($session{form}{fid}));
	} else {
               	$f->hidden(
			-name => "new",
			-value => 1,
               	);
               	$f->text(
			-name => "fid",
			-label => WebGUI::International::get(475,"WebGUIProfile"),
			-hoverHelp => WebGUI::International::get('475 description',"WebGUIProfile"),
               	);
	}
	$f->text(
		-name => "fieldLabel",
		-label => WebGUI::International::get(472,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('472 description',"WebGUIProfile"),
		-value => $data{fieldLabel},
	);
	$f->yesNo(
		-name=>"visible",
		-label=>WebGUI::International::get(473,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('473 description',"WebGUIProfile"),
		-value=>$data{visible}
		);
	$f->yesNo(
                -name=>"editable",
                -value=>$data{editable},
                -label=>WebGUI::International::get(897,"WebGUIProfile"),
                -hoverHelp=>WebGUI::International::get('897 description',"WebGUIProfile"),
                );
	$f->yesNo(
		-name=>"required",
		-label=>WebGUI::International::get(474,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('474 description',"WebGUIProfile"),
		-value=>$data{required}
		);
	$f->fieldType(
		-name=>"dataType",
		-label=>WebGUI::International::get(486,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('486 description',"WebGUIProfile"),
		-value=>$data{dataType},
		-defaultValue=>"text",
		-types=>[qw(dateTime timeZone TimeField float zipcode text textarea HTMLArea url date email phone integer yesNo selectList radioList checkList)]
		);
	$f->textarea(
		-name => "dataValues",
		-label => WebGUI::International::get(487,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('487 description',"WebGUIProfile"),
		-value => $data{dataValues},
	);
	$f->textarea(
		-name => "dataDefault",
		-label => WebGUI::International::get(488,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('488 description',"WebGUIProfile"),
		-value => $data{dataDefault},
	);
	tie %hash, 'Tie::CPHash';
	%hash = WebGUI::SQL->buildHash("select profileCategoryId,categoryName from userProfileCategory order by categoryName");
	foreach $key (keys %hash) {
		$hash{$key} = WebGUI::Operation::Shared::secureEval($hash{$key});
	}
	$f->selectList(
		-name=>"profileCategoryId",
		-options=>\%hash,
		-label=>WebGUI::International::get(489,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('489 description',"WebGUIProfile"),
		-value=>[$data{profileCategoryId}]
		);
        $f->submit;
        $output .= $f->print;
	return _submenu($output,'471','profile settings edit',"WebGUIProfile");
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($sequenceNumber, $fieldName, $test);
        $session{form}{fieldLabel} = 'Unamed' if ($session{form}{fieldLabel} eq "" || $session{form}{fieldLabel} eq "''");
	if ($session{form}{dataDefault} && $session{form}{dataType}=~/List$/) {
                unless ($session{form}{dataDefault} =~ /^\[/) {
                        $session{form}{dataDefault} = "[".$session{form}{dataDefault};
                }
                unless ($session{form}{dataDefault} =~ /\]$/) {
                        $session{form}{dataDefault} .= "]";
                }
        }
	if ($session{form}{new}) {
		($fieldName) = WebGUI::SQL->quickArray("select count(*) from userProfileField 
			where fieldName=".quote($session{form}{fid}));
		if ($fieldName) {
			$session{form}{fid} .= '2';	
		}
		($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) 
			from userProfileField where profileCategoryId=".quote($session{form}{profileCategoryId}));
		WebGUI::SQL->write("insert into userProfileField (fieldName, sequenceNumber, protected)
			values (".quote($session{form}{fid}).", ".($sequenceNumber+1).", 0)");
	}
	WebGUI::SQL->setRow("userProfileField","fieldName",{
			fieldLabel=>$session{form}{fieldLabel},
			visible=>$session{form}{visible},
			required=>$session{form}{required},
			editable=>$session{form}{editable},
			dataType=>$session{form}{dataType},
			dataValues=>$session{form}{dataValues},
			dataDefault=>$session{form}{dataDefault},
			profileCategoryId=>$session{form}{profileCategoryId},
			fieldName=>$session{form}{fid}
			});
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $a, %category, %field, $b);
	tie %category, 'Tie::CPHash';
	tie %field, 'Tie::CPHash';
	$a = WebGUI::SQL->read("select * from userProfileCategory order by sequenceNumber");
	while (%category = $a->hash) {
		$output .= deleteIcon('op=deleteProfileCategoryConfirm;cid='.$category{profileCategoryId},'',WebGUI::International::get(466,"WebGUIProfile")); 
		$output .= editIcon('op=editProfileCategory;cid='.$category{profileCategoryId}); 
		$output .= moveUpIcon('op=moveProfileCategoryUp;cid='.$category{profileCategoryId}); 
		$output .= moveDownIcon('op=moveProfileCategoryDown;cid='.$category{profileCategoryId}); 
		$output .= ' <b>';
		$output .= WebGUI::Operation::Shared::secureEval($category{categoryName});
		$output .= '</b><br />';
		$b = WebGUI::SQL->read("select * from userProfileField where 
			profileCategoryId=".quote($category{profileCategoryId})." order by sequenceNumber");
		while (%field = $b->hash) {
			$output .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                        $output .= deleteIcon('op=deleteProfileFieldConfirm;fid='.$field{fieldName},'',WebGUI::International::get(467,"WebGUIProfile"));
       	                $output .= editIcon('op=editProfileField;fid='.$field{fieldName});
               	        $output .= moveUpIcon('op=moveProfileFieldUp;fid='.$field{fieldName});
                       	$output .= moveDownIcon('op=moveProfileFieldDown;fid='.$field{fieldName});
                       	$output .= ' ';
			$output .= WebGUI::Operation::Shared::secureEval($field{fieldLabel});
			$output .= '<br />';
		}
		$b->finish;
	}
	$a->finish;
	return _submenu($output,undef,"profile settings edit",'WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".quote($session{form}{cid}));
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".quote($session{form}{cid}));
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".quote($id));
                _reorderCategories();
        }
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=".quote($session{form}{cid}));
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=".quote($session{form}{cid}));
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=".quote($id));
                _reorderCategories();
        }
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($session{form}{fid}));
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=".quote($profileCategoryId)." and sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($session{form}{fid}));
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($id));
                _reorderFields($profileCategoryId);
        }
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($session{form}{fid}));
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=".quote($profileCategoryId)." and sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($session{form}{fid}));
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($id));
                _reorderFields($profileCategoryId);
        }
        return www_editProfileSettings();
}





1;
