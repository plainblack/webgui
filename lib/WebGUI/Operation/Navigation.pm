package WebGUI::Operation::Navigation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Navigation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::TabForm;
use WebGUI::Cache;

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
	my $i18n = WebGUI::International->new("Navigation");
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("navigation");
        if ($help) {
                $ac->setHelp($help);
        }
	$ac->addSubmenuItem(WebGUI::URL::page('op=editNavigation'),$i18n->get("add new"));
	if (($session{form}{op} eq "editNavigation" && $session{form}{navigationId} ne "new") || $session{form}{op} eq "deleteNavigationConfirm") {
                $ac->addSubmenuItem(WebGUI::URL::page('op=editNavigation&identifier='.$session{form}{identifier}), $i18n->get("18"));
                $ac->addSubmenuItem(WebGUI::URL::page('op=copyNavigation&navigationId='.$session{form}{navigationId}),$i18n->get("19"));
                $ac->addSubmenuItem(WebGUI::URL::page('op=deleteNavigation&navigationId='.$session{form}{navigationId}),$i18n->get("20"));
        }
        $ac->addSubmenuItem(WebGUI::URL::page('op=listNavigation'), $i18n->get("21"));
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_copyNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my %navigation = WebGUI::SQL->quickHash("select * from Navigation where identifier = ".
							quote($session{form}{identifier}));
	WebGUI::SQL->write("insert into Navigation (navigationId, identifier, depth, method, startAt, stopAtLevel,
						templateId, showSystemPages, showHiddenPages, showUnprivilegedPages,
						reverse)
		values (".quote(WebGUI::Id::generate()).",
                        ".quote($navigation{identifier}.' (copy)').", $navigation{depth}, ".quote($navigation{method}).
			", ".quote($navigation{startAt}).", $navigation{stopAtLevel}, ".quote($navigation{templateId}).", 
			$navigation{showSystemPages}, $navigation{showHiddenPages},$navigation{showUnprivilegedPages},
			$navigation{reverse})");
	return www_listNavigation();
}

#-------------------------------------------------------------------
sub www_deleteNavigationConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
        if ($session{form}{navigationId} < 1000 && $session{form}{navigationId} > 0) {
                return WebGUI::Privilege::vitalComponent();
        }
	WebGUI::SQL->write("delete from Navigation where navigationId = ".quote($session{form}{navigationId}));

	# Also delete cache
	WebGUI::Page->recacheNavigation;
	return www_listNavigation();
}


sub www_editNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $identifier = shift || $session{form}{identifier};
	my $config = WebGUI::Navigation::getConfig($identifier);
	if ($config->{identifier}) {
		# Existing config
	} else {
		$config->{navigationId} = 'new';
		$config->{identifier} = $identifier || 'myIdentifier';
		$config->{assetsToInclude} = "descendants";
		$config->{startType} = "relativeToRoot";
		$config->{startPoint} = 0;
		$config->{baseType} = "relativeToCurrentPage";
		$config->{basePage} = "0";
		$config->{endType} = "relativeToBasePage";
		$config->{endPoint} = "55";
		$config->{templateId} = 1;
		$config->{showSystemPages} = 0;
		$config->{showHiddenPages} = 0;
		$config->{showUnprivilegedPages} = 0;
	}
	my $tabform = WebGUI::TabForm->new;
	$tabform->hidden({
		name=>'op', 
		value=>'editNavigationSave'
		});
	$tabform->hidden({
		name=>'navigationId', 
		value=>$config->{navigationId}
		});
	$tabform->addTab("properties",WebGUI::International::get(23, 'Navigation'));
 	$tabform->getTab("properties")->raw('<input type="hidden" name="op2" value="'.$session{form}{afterEdit}.'" />');
	$tabform->getTab("properties")->readOnly(
		-value=>$config->{navigationId},
                -label=>'navigationId'
                );
	$tabform->getTab("properties")->text(
		-name=>'identifier',
		-value=>$config->{identifier},
		-label=>WebGUI::International::get(24, 'Navigation')
		);
	my ($ancestorsChecked, $descendantsChecked, $selfChecked, $pedigreeChecked, $siblingsChecked);
	my @assetsToInclude = split(",",$config->{assetsToInclude});
	my $afterScript;
	foreach my $item (@assetsToInclude) {
		if ($item eq "self") {
			$selfChecked = 1;
		} elsif ($item eq "descendants") {
			$descendantsChecked = 1;
			$afterScript = "displayNavEndPoint = false;";
		} elsif ($item eq "ancestors") {
			$ancestorsChecked = 1;
			$afterScript = "displayNavStartPoint = false;";
		} elsif ($item eq "siblings") {
			$siblingsChecked = 1;
		} elsif ($item eq "pedigree") {
			$pedigreeChecked = 1;
		}
	}
	$tabform->getTab("properties")->readOnly(
		-label=>"Pages to Include",
		-value=>WebGUI::Form::checkbox({
				checked=>$ancestorsChecked,
				name=>"assetsToInclude",
				value=>"ancestors",
				extras=>'onChange="toggleStartPoint()"'
				}).'Ancestors<br />'
			.WebGUI::Form::checkbox({
				checked=>$selfChecked,
				name=>"assetsToInclude",
				value=>"self"
				}).'Self<br />'
			.WebGUI::Form::checkbox({
				checked=>$siblingsChecked,
				name=>"assetsToInclude",
				value=>"siblings"
				}).'Siblings<br />'
			.WebGUI::Form::checkbox({
				checked=>$descendantsChecked,
				name=>"assetsToInclude",
				value=>"descendants",
				extras=>'onChange="toggleEndPoint()"'
				}).'Descendants<br />'
			.WebGUI::Form::checkbox({
				checked=>$pedigreeChecked,
				name=>"assetsToInclude",
				value=>"pedigree"
				}).'Pedigree<br />'
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navStart"><tr><td class="formDescription">Start Type</td><td>'
		.WebGUI::Form::selectList({
			name=>"startType",
			value=>[$config->{startType}],
			extras=>'id="navStartType" onChange="changeStartPoint()"',
			options=>{
				relativeToRoot=>"Relative To Root",
				relativeToCurrentPage=>"Relative To Current Page"
				}
			})
		.'</td></tr><tr><td class="formDescription">Start Point</td><td><div id="navStartPoint"></div></td></tr></tbody><tbody>'
		);
	$tabform->getTab("properties")->selectList(
		-name=>"baseType",
		-options=>{
			specificUrl=>'Specific URL',
			relativeToCurrentPage=>'Relative To Current Page',
			relativeToRoot=>'Relative To Root'
			},
		-value=>[$config->{baseType}],
		-label=>"Base Type",
		-extras=>'id="navBaseType" onChange="changeBasePage()"'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>"Base Page",
		-value=>'<div id="navBasePage"></div>'
		);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		'55'=>'Infinity',
		'1'=>'./a/ (+1)',
		'2'=>'./a/b/ (+2)',
		'3'=>'./a/b/c/ (+3)',
		'4'=>'./a/b/c/d/ (+4)',
		'5'=>'./a/b/c/d/e/ (+5)'
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navEnd"><tr><td class="formDescription">End Type</td><td>'
		.WebGUI::Form::selectList({
			name=>"endType",
			value=>[$config->{endType}],
			options=>{
				relativeToStartPage=>"Relative To Start Page",
				relativeToBasePage=>"Relative To Base Page"
				}
			})
		.'</td></tr><tr><td class="formDescription">End Point</td><td>'
		.WebGUI::Form::selectList({
			name=>"endPoint",
			value=>[$config->{endPoint}],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->addTab("layout",WebGUI::International::get(105));
	$tabform->getTab("layout")->template(
		-name=>'templateId',
		-label=>WebGUI::International::get(913),
		-value=>$session{form}{templateId} || $config->{templateId},
		-namespace=>'Navigation',
		);
	$tabform->getTab("layout")->yesNo(
		-name=>'showSystemPages',
		-label=>WebGUI::International::get(30,'Navigation'),
		-value=>$session{form}{showSystemPages} || $config->{showSystemPages}
		);
        $tabform->getTab("layout")->yesNo(
                -name=>'showHiddenPages',
                -label=>WebGUI::International::get(31,'Navigation'),
                -value=>$session{form}{showHiddenPages} || $config->{showHiddenPages}
        	);
        $tabform->getTab("layout")->yesNo(
                -name=>'showUnprivilegedPages',
                -label=>WebGUI::International::get(32,'Navigation'),
                -value=>$session{form}{showUnprivilegedPages} || $config->{showUnprivilegedPages}
        	);
	my $script = "<script type=\"text/javascript\">
		var displayNavStartPoint = true;
		function toggleStartPoint () {
			if (displayNavStartPoint) {
				document.getElementById('navStart').style.display='none';
				displayNavStartPoint = false;
			} else {
				document.getElementById('navStart').style.display='';
				displayNavStartPoint = true;
			}
		}
		var displayNavEndPoint = true;
		function toggleEndPoint () {
			if (displayNavEndPoint) {
				document.getElementById('navEnd').style.display='none';
				displayNavEndPoint = false;
			} else {
				document.getElementById('navEnd').style.display='';
				displayNavEndPoint = true;
			}
		}
		var relativeToRoot ='<select name=\"basePage\"><option value=\"0\"".(($config->{basePage} eq "0")?' selected=\"1\"':'').">/ (0)</option><option value=\"1\"".(($config->{basePage} eq "1")?' selected=\"1\"':'').">/a/ (+1)</option><option value=\"2\"".(($config->{basePage} eq "2")?' selected=\"1\"':'').">/a/b/ (+2)</option><option value=\"3\"".(($config->{basePage} eq "3")?' selected=\"1\"':'').">/a/b/c/ (+3)</option><option value=\"4\"".(($config->{basePage} eq "4")?' selected=\"1\"':'').">/a/b/c/d/ (+4)</option><option value=\"5\"".(($config->{basePage} eq "5")?' selected=\"1\"':'').">/a/b/c/d/e/ (+5)</option><option value=\"6\"".(($config->{basePage} eq "6")?' selected=\"1\"':'').">/a/b/c/d/e/f/ (+6)</option><option value=\"7\"".(($config->{basePage} eq "7")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+7)</option><option value=\"8\"".(($config->{basePage} eq "8")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+8)</option><option value=\"9\"".(($config->{basePage} eq "9")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/i/ (+9)</option></select>';
		function changeBasePage () {
			var types = new Array();
			types['specificUrl']='<input type=\"text\" name=\"basePage\">';
			types['relativeToRoot']=relativeToRoot;
			types['relativeToCurrentPage']='<select name=\"basePage\"><option value=\"-3\"".(($config->{basePage} eq "-3")?' selected=\"1\"':'').">../../.././ (-3)</option><option value=\"-2\"".(($config->{basePage} eq "-2")?' selected=\"1\"':'').">../.././ (-2)</option><option value=\"-1\"".(($config->{basePage} eq "-1")?' selected=\"1\"':'').">.././ (-1)</option><option value=\"0\"".(($config->{basePage} eq "0")?' selected=\"1\"':'').">./ (0)</option><option value=\"1\"".(($config->{basePage} eq "1")?' selected=\"1\"':'').">./a/ (+1)</option><option value=\"2\"".(($config->{basePage} eq "2")?' selected=\"1\"':'').">./a/b/ (+2)</option><option value=\"3\"".(($config->{basePage} eq "3")?' selected=\"1\"':'').">./a/b/c/ (+3)</option></select>';
			document.getElementById('navBasePage').innerHTML=types[document.getElementById('navBaseType').options[document.getElementById('navBaseType').selectedIndex].value];
		}
		function changeStartPoint () {
			var types = new Array();
			types['relativeToRoot']=relativeToRoot;
			types['relativeToCurrentPage']='<select name=\"basePage\"><option value=\"-3\"".(($config->{basePage} eq "-3")?' selected=\"1\"':'').">../../.././ (-3)</option><option value=\"-2\"".(($config->{basePage} eq "-2")?' selected=\"1\"':'').">../.././ (-2)</option><option value=\"-1\"".(($config->{basePage} eq "-1")?' selected=\"1\"':'').">.././ (-1)</option></select>';
			document.getElementById('navStartPoint').innerHTML=types[document.getElementById('navStartType').options[document.getElementById('navStartType').selectedIndex].value];
		}
		".$afterScript."
		changeBasePage();
		changeStartPoint();
		toggleStartPoint();
		toggleEndPoint();
		</script>";
	return _submenu($tabform->print.$script,'22',"navigation add/edit");
}

#-------------------------------------------------------------------
sub www_editNavigationOld {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $identifier = shift || $session{form}{identifier};
	my $config = WebGUI::Navigation::getConfig($identifier);
	if ($config->{identifier}) {
		# Existing config
	} else {
		$config->{navigationId} = 'new';
		$config->{identifier} = $identifier || 'myIdentifier';
		$config->{depth} = 99;
		$config->{method}  = 'descendants';
		$config->{startAt} = 'current';
		$config->{stopAtLevel} = -1;
		$config->{templateId} = 1;
		$config->{showSystemPages} = 0;
		$config->{showHiddenPages} = 0;
		$config->{showUnprivilegedPages} = 0;
		$config->{'reverse'} = 0;
	}
	my $output;
	tie my (%tabs) , 'Tie::IxHash';
	%tabs = (
		properties=>{
				label=>WebGUI::International::get(23, 'Navigation'),
			  },
		layout=>{
				label=>WebGUI::International::get(105),
			},
		);
	
	my $f = WebGUI::TabForm->new(\%tabs);
	$f->hidden({name=>'op', value=>'editNavigationSave'});
	$f->hidden({name=>'navigationId', value=>$config->{navigationId}});
 	$f->getTab("properties")->raw('<input type="hidden" name="op2" value="'.$session{form}{afterEdit}.'" />');
	$f->getTab("properties")->readOnly(
		-value=>$config->{navigationId},
                -label=>'navigationId'
                );

	$f->getTab("properties")->text(
		-name=>'identifier',
		-value=>$config->{identifier},
		-label=>WebGUI::International::get(24, 'Navigation')
		);

	my $startAt = $session{form}{startAt} || $config->{startAt};
	my $levels = WebGUI::Navigation::getLevelNames();
	
	# If an alternate value for startAt is specified, add that to the options list as well.
	$levels->{$startAt} = $startAt if (not defined $levels->{$startAt});

        # The documented interface of HTMLForm::combo didn't work. However the old functional interface does...
        $f->getTab("properties")->combo("startAt",$levels,WebGUI::International::get(25,'Navigation'),[$startAt]);
        $f->getTab("properties")->selectList(
                -name=>'method',
                -label=>WebGUI::International::get(28,'Navigation'),
                -options=>WebGUI::Navigation::getMethodNames(),
                -value=>[$session{form}{method} || $config->{method}]
                );
	tie my %stopAtLevels, 'Tie::IxHash';
	%stopAtLevels = (	'-1' 	=> 'no limit',
				'0' 	=> '0. '.WebGUI::International::get(1,'Navigation'),
				'1'	=> '1. '.WebGUI::International::get(2,'Navigation'),
				'2'	=> '2. '.WebGUI::International::get(3,'Navigation'),
				'3'	=> '3.',
				'4'	=> '4.',
				'5'	=> '5.',
				'6'	=> '6.',
				'7'	=> '7.',
				'8'	=> '8.',
				'9'	=> '9.',
			);
        $f->getTab("properties")->selectList(
                -name=>'stopAtLevel',
                -label=>WebGUI::International::get(26,'Navigation'),
                -options=>\%stopAtLevels,
                -value=>[$session{form}{stopAtLevel} || $config->{stopAtLevel}]
                );
	tie my %depths, 'Tie::IxHash';
	%depths = (		'1'	=> '1 level',
				'2'	=> '2 levels',
				'3'	=> '3 levels',
				'4'	=> '4 levels',
				'5'	=> '5 levels',
				'6'	=> '6 levels',
				'7'	=> '7 levels',
				'8'	=> '8 levels',
				'9'	=> '9 levels',
				'99'	=> '99 levels',
		);
        $f->getTab("properties")->selectList(
                -name=>'depth',
                -label=>WebGUI::International::get(27,'Navigation'),
		-options=>\%depths,
                -value=>[$session{form}{depth} || $config->{depth}]
                );
	$f->getTab("properties")->yesNo(
		-name=>'showSystemPages',
		-label=>WebGUI::International::get(30,'Navigation'),
		-value=>$session{form}{showSystemPages} || $config->{showSystemPages}
	);

        $f->getTab("properties")->yesNo(
                -name=>'showHiddenPages',
                -label=>WebGUI::International::get(31,'Navigation'),
                -value=>$session{form}{showHiddenPages} || $config->{showHiddenPages}
        );

        $f->getTab("properties")->yesNo(
                -name=>'showUnprivilegedPages',
                -label=>WebGUI::International::get(32,'Navigation'),
                -value=>$session{form}{showUnprivilegedPages} || $config->{showUnprivilegedPages}
        );

	$f->getTab("layout")->template(
		-name=>'templateId',
		-label=>WebGUI::International::get(913),
		-value=>$session{form}{templateId} || $config->{templateId},
		-namespace=>'Navigation',
	);
        $f->getTab("layout")->yesNo(
                -name=>'reverse',
                -label=>WebGUI::International::get(29,'Navigation'),
                -value=>$session{form}{'reverse'} || $config->{'reverse'}
        );
	# window.open('', 'navPreview', 'toolbar=no,width=400,height=300,status=no,location=no,scrollbars=yes,resizable=yes');
	my $previewButton = qq{
                           <INPUT TYPE="button" VALUE="Preview" NAME="preview"
                            OnClick="
                                window.open('', 'navPreview', 'toolbar=no,status=no,location=no,scrollbars=yes,resizable=yes');
                                this.form.op.value='previewNavigation';
                                this.form.target = 'navPreview';
                                this.form.submit()">};
	my $saveButton = ' <input type="button" value="'.WebGUI::International::get(62).'" onClick="
		this.value=\''.WebGUI::International::get(452).'\';
		this.form.op.value=\'editNavigationSave\';
		this.form.target=\'_self\';
		this.form.submit();
		" >';
	$f->{_submit} = $previewButton." ".$saveButton;
	$output .= $f->print;
	return _submenu($output,'22',"navigation add/edit");
}

#-------------------------------------------------------------------
sub www_editNavigationSave {
	return WebGUI::Privilege::insufficient()  unless (WebGUI::Grouping::isInGroup(3)); 

        # Check on duplicate identifier
	my ($existingNavigationId, $existingIdentifier) = WebGUI::SQL->quickArray("select navigationId,
								identifier from Navigation where identifier = "
								.quote($session{form}{identifier}));
	if(($existingIdentifier && $session{form}{navigationId} eq "new") ||
	   ($existingIdentifier && $existingNavigationId != $session{form}{navigationId})) {
		$session{form}{identifier} = undef;
		return WebGUI::International::get(33,'Navigation').www_editNavigation();
	}
	if ($session{form}{navigationId} eq "new") {
		$session{form}{navigationId} = WebGUI::Id::generate();
		 WebGUI::SQL->write("insert into Navigation (navigationId, identifier)
					values (".quote($session{form}{navigationId}).", ".quote($session{form}{identifier}).")");
	}
	$session{form}{startAt} = $session{form}{startAt_new} || $session{form}{startAt}; # Combo field
	WebGUI::SQL->write("update Navigation set depth       = $session{form}{depth},
						  method      = ".quote($session{form}{method}).",
						  startAt     = ".quote($session{form}{startAt}).",
						  stopAtLevel = ".quote($session{form}{stopAtLevel}).",
						  templateId  = ".quote($session{form}{templateId}).",
						  showSystemPages = $session{form}{showSystemPages},
						  showHiddenPages = $session{form}{showHiddenPages},
						  showUnprivilegedPages = $session{form}{showUnprivilegedPages},
						  identifier  = ".quote($session{form}{identifier}).",
						  reverse     = ".quote($session{form}{'reverse'})."
				where navigationId = ".quote($session{form}{navigationId})); 
	# Delete from cache
	
	WebGUI::Page->recacheNavigation;
	return "";  
}

#-------------------------------------------------------------------
sub www_listNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $output;
	my $sth = WebGUI::SQL->read("select navigationId, identifier from Navigation order by identifier");
	my $i = 0;
	my @row = ();
	while (my %data = $sth->hash) {
		$row[$i].= '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deleteNavigationConfirm&identifier='.$data{identifier}.'&navigationId='.$data{navigationId},'',WebGUI::International::get(502))
			.editIcon('op=editNavigation&identifier='.$data{identifier}.'&navigationId='.$data{navigationId}."&afterEdit=".WebGUI::URL::escape("op=listNavigation"))
			.copyIcon('op=copyNavigation&identifier='.$data{identifier}.'&navigationId='.$data{navigationId})
			.'</td>';
		$row[$i].= '<td valign="top" class="tableData">'.$data{identifier}.'</td>';
		$i++;
	}
	$sth->finish;
	my $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listNavigation'));
	$p->setDataByArrayRef(\@row);
	$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output,'34',"navigation manage");
}

#-------------------------------------------------------------------
sub www_previewNavigation {
	$session{var}{adminOn} = 0;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $nav = WebGUI::Navigation->new(	depth=>$session{form}{depth},
						method=>$session{form}{method},
						startAt=>$session{form}{startAt},
						stopAtLevel=>$session{form}{stopAtLevel},
						templateId=>$session{form}{templateId},
						showSystemPages=>$session{form}{showSystemPages},
						showHiddenPages=>$session{form}{showHiddenPages},
						showUnprivilegedPages=>$session{form}{showUnprivilegedPages},
	                       			'reverse'=>$session{form}{'reverse'},
                                );
	my $output = qq(
		<table width="100%" border="0" cellpadding="5" cellspacing="0">
		<tr><td class="tableHeader" valign="top">
		Configuration
		</td><td class="tableHeader" valign="top">Output</td></tr>
		<tr><td class="tableHeader" valign="top">
		<font size=1>
			Identifier: $session{form}{identifier}<br>
			startAt: $session{form}{startAt}<br>
			method: $session{form}{method}<br>
			stopAtLevel: $session{form}{stopAtLevel}<br>
			depth: $session{form}{depth}<br>
			templateId: $session{form}{templateId}<br>
			reverse: $session{form}{'reverse'}<br>
			showSystemPages: $session{form}{showSystemPages}<br>
			showHiddenPages: $session{form}{showHiddenPages}<br>
			showUnprivilegedPages: $session{form}{showUnprivilegedPages}<br>
		</font>
		</td><td class="tableData" valign="top">
		) . $nav->build . qq(</td></tr></table>);
	
	# Because of the way the system is set up, the preview is cached. So let's remove it again...
	WebGUI::Cache->new($nav->{_identifier}."$session{page}{pageId}", "Navigation-".$session{config}{configFile})->delete;
	
	return _submenu($output,"preview"); 
}

1;
