package WebGUI::Operation::ProfileSettings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
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
sub _subMenu {
	my ($output);
	$output = '<table width="100%"><tr><td class="tableData" valign="top">';
        $output .= $_[0];
        $output .= '</td><td class="tableMenu" valign="top">';
        $output .= '<li><a href="'.WebGUI::URL::page("op=editProfileCategory").'">'.WebGUI::International::get(490).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page("op=editProfileField").'">'.WebGUI::International::get(491).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page("op=editProfileSettings").'">'.WebGUI::International::get(492).'</a>';
        $output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(493).'</a>';
        $output .= '</td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub www_deleteProfileCategory {
        my ($output);
        if ($session{form}{cid} < 100) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output = '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(466).'<p>';
                $output .= '<div align="center"><a href="'.
                        WebGUI::URL::page('op=deleteProfileCategoryConfirm&cid='.$session{form}{cid}).
                        '">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.
                        WebGUI::International::get(45).'</a></div>';
		return _subMenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
        if ($session{form}{cid} < 100) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
		WebGUI::SQL->write("delete from userProfileCategory where profileCategoryId=$session{form}{cid}");
		WebGUI::SQL->write("update userProfileField set profileCategoryId=1 where profileCategoryId=$session{form}{cid}");
                return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteProfileField {
        my ($output,$protected);
	($protected) = WebGUI::SQL->quickArray("select protected from userProfileField where fieldname=".quote($session{form}{fid}));
        if ($protected) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output = '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(467).'<p>';
                $output .= '<div align="center"><a href="'.
                        WebGUI::URL::page('op=deleteProfileFieldConfirm&fid='.$session{form}{fid}).
                        '">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=editProfileSettings').'">'.
                        WebGUI::International::get(45).'</a></div>';
		return _subMenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
	my ($protected);
	($protected) = WebGUI::SQL->quickArray("select protected from userProfileField where fieldname=".quote($session{form}{fid}));
        if ($protected) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
		WebGUI::SQL->write("delete from userProfileField where fieldName=".quote($session{form}{fid}));
		WebGUI::SQL->write("delete from userProfileData where fieldName=".quote($session{form}{fid}));
                return www_editProfileSettings(); 
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
	my ($output, $f, %data);
	tie %data, 'Tie::CPHash';
	if (WebGUI::Privilege::isInGroup(3)) {
		$output = '<h1>'.WebGUI::International::get(468).'</h1>';
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
		$f->submit;
		$output .= $f->print;
		return _subMenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
	my ($categoryId, $sequenceNumber, $test);
        if (WebGUI::Privilege::isInGroup(3)) {
		$session{form}{categoryName} = 'Unamed' if ($session{form}{categoryName} eq "" || $session{form}{categoryName} eq "''");
		$test = eval($session{form}{categoryName});
		$session{form}{categoryName} = "'".$session{form}{categoryName}."'" if ($test eq "");
		if ($session{form}{cid} eq "new") {
			$categoryId = getNextId("profileCategoryId");
			($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from userProfileCategory");
			WebGUI::SQL->write("insert into userProfileCategory values ($categoryId, ".quote($session{form}{categoryName}).",
				".($sequenceNumber+1).")");
		} else {
			WebGUI::SQL->write("update userProfileCategory set categoryName=".quote($session{form}{categoryName})." where
				profileCategoryId=$session{form}{cid}");
		}
		return www_editProfileSettings();
		return $test;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editProfileField {
	my ($output, $f, %data, %hash, $key);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = '<h1>'.WebGUI::International::get(471).'</h1>';
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
		$f->yesNo("visible",WebGUI::International::get(473),$data{visible});
		$f->yesNo("required",WebGUI::International::get(474),$data{required});
		tie %hash, 'Tie::IxHash';
		%hash = (	'text'=>WebGUI::International::get(475), 
				'textarea'=>WebGUI::International::get(476), 
				'HTMLArea'=>WebGUI::International::get(477), 
				'url'=>WebGUI::International::get(478), 
				'date'=>WebGUI::International::get(479), 
				'email'=>WebGUI::International::get(480),
				'phone'=>WebGUI::International::get(481),
				'integer'=>WebGUI::International::get(482),
				'yesNo'=>WebGUI::International::get(483),
				'select'=>WebGUI::International::get(484)
			);
		$f->select("dataType",\%hash,WebGUI::International::get(486),[$data{dataType}]);
		$f->textarea("dataValues",WebGUI::International::get(487),$data{dataValues});
		$f->textarea("dataDefault",WebGUI::International::get(488),$data{dataDefault});
		tie %hash, 'Tie::CPHash';
		%hash = WebGUI::SQL->buildHash("select profileCategoryId,categoryName from userProfileCategory order by categoryName");
		foreach $key (keys %hash) {
			$hash{$key} = eval $hash{$key};
		}
		$f->select("profileCategoryId",\%hash,WebGUI::International::get(489),[$data{profileCategoryId}]);
                $f->submit;
                $output .= $f->print;
		return _subMenu($output);
	} else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
	my ($sequenceNumber, $fieldName, $test);
        if (WebGUI::Privilege::isInGroup(3)) {
                $session{form}{fieldLabel} = 'Unamed' if ($session{form}{fieldLabel} eq "" || $session{form}{fieldLabel} eq "''");
                $test = eval($session{form}{fieldLabel});
                $session{form}{fieldLabel} = "'".$session{form}{fieldLabel}."'" if ($test eq "");
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
			visible='$session{form}{visible}',
			required='$session{form}{required}',
			dataType=".quote($session{form}{dataType}).",
			dataValues=".quote($session{form}{dataValues}).",
			dataDefault=".quote($session{form}{dataDefault}).",
			profileCategoryId=".quote($session{form}{profileCategoryId})."
			where fieldName=".quote($session{form}{fid}));
		return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
	my ($output, $a, %category, %field, $b);
	tie %category, 'Tie::CPHash';
	tie %field, 'Tie::CPHash';
	if (WebGUI::Privilege::isInGroup(3)) {
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
		return _subMenu($output);
	} else {
		return WebGUI::Privilege::adminOnly();
	}
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
        my ($id, $thisSeq);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}");
                ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1");
                if ($id ne "") {
                        WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$session{form}{cid}");
                        WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$id");
                        _reorderCategories();
                }
                return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
        my ($id, $thisSeq);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}");
                ($id) = WebGUI::SQL->quickArray("select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1");
                if ($id ne "") {
                        WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$session{form}{cid}");
                        WebGUI::SQL->write("update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$id");
                        _reorderCategories();
                }
                return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
        my ($id, $thisSeq, $profileCategoryId);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($session{form}{fid}));
                ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq+1");
                if ($id ne "") {
                        WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($session{form}{fid}));
                        WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($id));
                        _reorderFields($profileCategoryId);
                }
                return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
        my ($id, $thisSeq, $profileCategoryId);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($thisSeq,$profileCategoryId) = WebGUI::SQL->quickArray("select sequenceNumber,profileCategoryId from userProfileField where fieldName=".quote($session{form}{fid}));
                ($id) = WebGUI::SQL->quickArray("select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq-1");
                if ($id ne "") {
                        WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=".quote($session{form}{fid}));
                        WebGUI::SQL->write("update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=".quote($id));
                        _reorderFields($profileCategoryId);
                }
                return www_editProfileSettings();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}





1;

