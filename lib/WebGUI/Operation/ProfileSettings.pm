package WebGUI::Operation::ProfileSettings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_deleteProfileCategoryConfirm &www_deleteProfileFieldConfirm &www_editProfileCategorySave &www_editProfileFieldSave &www_deleteProfileCategory &www_deleteProfileField &www_editProfileCategory &www_editProfileField &www_moveProfileCategoryDown &www_moveProfileCategoryUp &www_moveProfileFieldDown &www_moveProfileFieldUp &www_editProfileSettings);

#-------------------------------------------------------------------
sub _reorderCategories {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select profileCategoryId from userProfileCategory order by sequenceNumber");
        while (($id) = $sth->array) {
                $i++;
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber='$i' where profileCategoryId=$id");
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
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page("op=editProfileCategory")} = WebGUI::International::get(490,"WebGUIProfile");
	$menu{WebGUI::URL::page("op=editProfileField")} = WebGUI::International::get(491,"WebGUIProfile");
        if (($session{form}{op} eq "editProfileField" && $session{form}{fid} ne "new") || $session{form}{op} eq "deleteProfileField") {
		$menu{WebGUI::URL::page('op=editProfileField&fid='.$session{form}{fid})} = WebGUI::International::get(787,"WebGUIProfile");
		$menu{WebGUI::URL::page('op=deleteProfileField&fid='.$session{form}{fid})} = WebGUI::International::get(788,"WebGUIProfile");
	}
        if (($session{form}{op} eq "editProfileCategory" && $session{form}{cid} ne "new") || $session{form}{op} eq "deleteProfileCategory") {
		$menu{WebGUI::URL::page('op=editProfileCategory&cid='.$session{form}{cid})} = WebGUI::International::get(789,"WebGUIProfile");
		$menu{WebGUI::URL::page('op=deleteProfileCategory&cid='.$session{form}{cid})} = WebGUI::International::get(790,"WebGUIProfile");
        }
	$menu{WebGUI::URL::page("op=editProfileSettings")} = WebGUI::International::get(492);
	$menu{WebGUI::URL::page('op=manageSettings')} = WebGUI::International::get(4);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output);
        return WebGUI::Privilege::vitalComponent() if ($session{form}{cid} < 1000);
        $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(466,"WebGUIProfile").'<p>';
        $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteProfileCategoryConfirm&cid='.$session{form}{cid}).
                '">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.
                WebGUI::International::get(45).'</a></div>';
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{cid} < 1000);
	WebGUI::SQL->write("delete from userProfileCategory where profileCategoryId=$session{form}{cid}");
	WebGUI::SQL->write("update userProfileField set profileCategoryId=1 where profileCategoryId=$session{form}{cid}");
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_deleteProfileField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output,$protected);
	($protected) = WebGUI::SQL->quickArray("select protected from userProfileField where fieldname=".quote($session{form}{fid}));
        return WebGUI::Privilege::vitalComponent() if ($protected);
        $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(467,"WebGUIProfile").'<p>';
        $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteProfileFieldConfirm&fid='.$session{form}{fid}).
                '">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.
                WebGUI::International::get(45).'</a></div>';
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($protected);
	($protected) = WebGUI::SQL->quickArray("select protected from userProfileField where fieldname=".quote($session{form}{fid}));
        return WebGUI::Privilege::vitalComponent() if ($protected);
	WebGUI::SQL->write("delete from userProfileField where fieldName=".quote($session{form}{fid}));
	WebGUI::SQL->write("delete from userProfileData where fieldName=".quote($session{form}{fid}));
        return www_editProfileSettings(); 
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, %data);
	tie %data, 'Tie::CPHash';
	$output = '<h1>'.WebGUI::International::get(468,"WebGUIProfile").'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("op","editProfileCategorySave");
	if ($session{form}{cid}) {
		$f->hidden("cid",$session{form}{cid});
		$f->readOnly($session{form}{cid},WebGUI::International::get(469));
		%data = WebGUI::SQL->quickHash("select * from userProfileCategory where profileCategoryId=$session{form}{cid}");
	} else {
                $f->hidden("cid","new");
	}
	$f->text("categoryName",WebGUI::International::get(470),$data{categoryName});
	$f->yesNo(
                -name=>"visible",
                -label=>WebGUI::International::get(473,"WebGUIProfile"),
                -value=>$data{visible}
                );
	$f->yesNo(
		-name=>"editable",
		-value=>$data{editable},
		-label=>WebGUI::International::get(897,"WebGUIProfile")
		);
	$f->submit;
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($sequenceNumber, $test);
	$session{form}{categoryName} = 'Unamed' if ($session{form}{categoryName} eq "" || $session{form}{categoryName} eq "''");
	$test = eval($session{form}{categoryName});
	$session{form}{categoryName} = "'".$session{form}{categoryName}."'" if ($test eq "");
	if ($session{form}{cid} eq "new") {
		$session{form}{cid} = getNextId("profileCategoryId");
		($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileCategory");
		WebGUI::SQL->write("insert into userProfileCategory (profileCategoryId,sequenceNumber) values ($session{form}{cid}, "
			.($sequenceNumber+1).")");
	}
	WebGUI::SQL->write("update userProfileCategory set categoryName=".quote($session{form}{categoryName}).", 
		editable=".$session{form}{editable}.", visible=".$session{form}{visible}." 
		where profileCategoryId=$session{form}{cid}");
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, %data, %hash, $key);
	tie %data, 'Tie::CPHash';
        $output = '<h1>'.WebGUI::International::get(471,"WebGUIProfile").'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","editProfileFieldSave");
	if ($session{form}{fid}) {
              	$f->hidden("fid",$session{form}{fid});
		$f->readOnly($session{form}{fid},WebGUI::International::get(470));
		%data = WebGUI::SQL->quickHash("select * from userProfileField where fieldName=".quote($session{form}{fid}));
	} else {
               	$f->hidden("new",1);
               	$f->text("fid",WebGUI::International::get(470));
	}
	$f->text("fieldLabel",WebGUI::International::get(472),$data{fieldLabel});
	$f->yesNo(
		-name=>"visible",
		-label=>WebGUI::International::get(473,"WebGUIProfile"),
		-value=>$data{visible}
		);
	$f->yesNo(
                -name=>"editable",
                -value=>$data{editable},
                -label=>WebGUI::International::get(897,"WebGUIProfile")
                );
	$f->yesNo(
		-name=>"required",
		-label=>WebGUI::International::get(474,"WebGUIProfile"),
		-value=>$data{required}
		);
	$f->fieldType(
		-name=>"dataType",
		-label=>WebGUI::International::get(486),
		-value=>[$data{dataType} || "text"]
		);
	$f->textarea("dataValues",WebGUI::International::get(487),$data{dataValues});
	$f->textarea("dataDefault",WebGUI::International::get(488),$data{dataDefault});
	tie %hash, 'Tie::CPHash';
	%hash = WebGUI::SQL->buildHash("select profileCategoryId,categoryName from userProfileCategory order by categoryName");
	foreach $key (keys %hash) {
		$hash{$key} = eval $hash{$key};
	}
	$f->select(
		-name=>"profileCategoryId",
		-options=>\%hash,
		-label=>WebGUI::International::get(489,"WebGUIProfile"),
		-value=>[$data{profileCategoryId}]
		);
        $f->submit;
        $output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($sequenceNumber, $fieldName, $test);
        $session{form}{fieldLabel} = 'Unamed' if ($session{form}{fieldLabel} eq "" || $session{form}{fieldLabel} eq "''");
        $test = eval($session{form}{fieldLabel});
        $session{form}{fieldLabel} = "'".$session{form}{fieldLabel}."'" if ($test eq "");
	if ($session{form}{dataDefault} ne "") {
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
			from userProfileField where profileCategoryId=$session{form}{profileCategoryId}");
		WebGUI::SQL->write("insert into userProfileField (fieldName, sequenceNumber, protected)
			values (".quote($session{form}{fid}).", ".($sequenceNumber+1).", 0)");
	}
	WebGUI::SQL->write("update userProfileField set
			fieldLabel=".quote($session{form}{fieldLabel}).",
			visible=$session{form}{visible},
			required=$session{form}{required},
			editable=$session{form}{editable},
			dataType=".quote($session{form}{dataType}).",
			dataValues=".quote($session{form}{dataValues}).",
			dataDefault=".quote($session{form}{dataDefault}).",
			profileCategoryId=".quote($session{form}{profileCategoryId})."
			where fieldName=".quote($session{form}{fid}));
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $a, %category, %field, $b);
	tie %category, 'Tie::CPHash';
	tie %field, 'Tie::CPHash';
	$output = helpIcon(22);
	$output .= '<h1>'.WebGUI::International::get(308).'</h1>';
	$a = WebGUI::SQL->read("select * from userProfileCategory order by sequenceNumber");
	while (%category = $a->hash) {
		$output .= deleteIcon('op=deleteProfileCategory&cid='.$category{profileCategoryId}); 
		$output .= editIcon('op=editProfileCategory&cid='.$category{profileCategoryId}); 
		$output .= moveUpIcon('op=moveProfileCategoryUp&cid='.$category{profileCategoryId}); 
		$output .= moveDownIcon('op=moveProfileCategoryDown&cid='.$category{profileCategoryId}); 
		$output .= ' <b>';
		$output .= eval $category{categoryName};
		$output .= '</b><br>';
		$b = WebGUI::SQL->read("select * from userProfileField where 
			profileCategoryId=$category{profileCategoryId} order by sequenceNumber");
		while (%field = $b->hash) {
			$output .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                        $output .= deleteIcon('op=deleteProfileField&fid='.$field{fieldName});
       	                $output .= editIcon('op=editProfileField&fid='.$field{fieldName});
               	        $output .= moveUpIcon('op=moveProfileFieldUp&fid='.$field{fieldName});
                       	$output .= moveDownIcon('op=moveProfileFieldDown&fid='.$field{fieldName});
                       	$output .= ' ';
			$output .= eval $field{fieldLabel};
			$output .= '<br>';
		}
		$b->finish;
	}
	$a->finish;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}");
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$session{form}{cid}");
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$id");
                _reorderCategories();
        }
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq);
        ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}");
        ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$session{form}{cid}");
                WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$id");
                _reorderCategories();
        }
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($id, $thisSeq, $profileCategoryId);
        ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($session{form}{fid}));
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq+1");
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
        ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($session{form}{fid}));
                WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($id));
                _reorderFields($profileCategoryId);
        }
        return www_editProfileSettings();
}





1;
