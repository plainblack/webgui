package WebGUI::Operation::Navigation;

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
use Tie::IxHash;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Navigation;
use WebGUI::Operation::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::TabForm;
use WebGUI::Cache;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_listNavigation &www_editNavigation &www_editNavigationSave &www_copyNavigation
		 &www_deleteNavigation www_deleteNavigationConfirm www_previewNavigation);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editNavigation')} = 'Add new Navigation.';
	if (($session{form}{op} eq "editNavigation" && $session{form}{navigationId} ne "new") || $session{form}{op} eq "deleteNavigationConfirm") {
                $menu{WebGUI::URL::page('op=editNavigation&identifier='.$session{form}{identifier})} = 
			WebGUI::International::get(18, 'Navigation');
                $menu{WebGUI::URL::page('op=copyNavigation&navigationId='.$session{form}{navigationId})} =
			WebGUI::International::get(19, 'Navigation');
                $menu{WebGUI::URL::page('op=deleteNavigation&navigationId='.$session{form}{navigationId})} =
			WebGUI::International::get(20, 'Navigation');
        }
        $menu{WebGUI::URL::page('op=listNavigation')} = WebGUI::International::get(21, 'Navigation');
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_copyNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my %navigation = WebGUI::SQL->quickHash("select * from Navigation where identifier = ".
							quote($session{form}{identifier}));
	WebGUI::SQL->write("insert into Navigation (navigationId, identifier, depth, method, startAt, stopAtLevel,
						templateId, showSystemPages, showHiddenPages, showUnprivilegedPages,
						reverse)
		values (".getNextId("navigationId").",
                        ".quote('Copy of '.$navigation{identifier}).", $navigation{depth}, ".quote($navigation{method}).
			", ".quote($navigation{startAt}).", $navigation{stopAtLevel}, $navigation{templateId}, 
			$navigation{showSystemPages}, $navigation{showHiddenPages},$navigation{showUnprivilegedPages},
			$navigation{reverse})");
	return www_listNavigation();
}

#-------------------------------------------------------------------
sub www_deleteNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	if ($session{form}{navigationId} < 1000 && $session{form}{navigationId} > 0) {
		return WebGUI::Privilege::vitalComponent();
	}
	my $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(502).'<p>';
        $output .= '<div align="center"><a href="'.
                   WebGUI::URL::page('op=deleteNavigationConfirm&navigationId='.$session{form}{navigationId})
                   .'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listNavigation').'">'.
				WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteNavigationConfirm {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
        if ($session{form}{navigationId} < 1000 && $session{form}{navigationId} > 0) {
                return WebGUI::Privilege::vitalComponent();
        }
	WebGUI::SQL->write("delete from Navigation where navigationId = $session{form}{navigationId}");

	# Also delete cache
	WebGUI::Cache->new("", "Navigation-".$session{config}{configFile})->deleteByRegex("m/^$session{form}{navigationId}-/");
	return www_listNavigation();
}

#-------------------------------------------------------------------
sub www_editNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));

	my $identifier = shift || $session{form}{identifier};
	#return  WebGUI::ErrorHandler::warn("editNavigation called without identifier") unless $identifier;	

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
	my $output = helpIcon("navigation add/edit").'<h1>'.WebGUI::International::get(22, 'Navigation').'</h1>';
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
	return _submenu($output);	
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
		$session{form}{navigationId} = getNextId("navigationId");
		 WebGUI::SQL->write("insert into Navigation (navigationId, identifier)
					values ($session{form}{navigationId}, ".quote($session{form}{identifier}).")");
	}
	$session{form}{startAt} = $session{form}{startAt_new} || $session{form}{startAt}; # Combo field
	WebGUI::SQL->write("update Navigation set depth       = $session{form}{depth},
						  method      = ".quote($session{form}{method}).",
						  startAt     = ".quote($session{form}{startAt}).",
						  stopAtLevel = ".quote($session{form}{stopAtLevel}).",
						  templateId  = $session{form}{templateId},
						  showSystemPages = $session{form}{showSystemPages},
						  showHiddenPages = $session{form}{showHiddenPages},
						  showUnprivilegedPages = $session{form}{showUnprivilegedPages},
						  identifier  = ".quote($session{form}{identifier}).",
						  reverse     = ".quote($session{form}{'reverse'})."
				where navigationId = $session{form}{navigationId}"); 
	# Delete from cache
	WebGUI::Cache->new("", "Navigation-".$session{config}{configFile})->deleteByRegex("m/^$session{form}{navigationId}-/");
	
	return www_listNavigation();  
}

#-------------------------------------------------------------------
sub www_listNavigation {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(3));
	my $output .= helpIcon("navigation manage").'<h1>'.WebGUI::International::get(34,'Navigation').'</h1>';
	my $sth = WebGUI::SQL->read("select navigationId, identifier from Navigation order by identifier");
	my $i = 0;
	my @row = ();
	while (my %data = $sth->hash) {
		$row[$i].= '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deleteNavigation&identifier='.$data{identifier}.'&navigationId='.$data{navigationId})
			.editIcon('op=editNavigation&identifier='.$data{identifier}.'&navigationId='.$data{navigationId})
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
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_previewNavigation {
	#$session{page}{useEmptyStyle} = 1;
	$session{page}{useAdminStyle} = 1;
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
		<h1>Navigation Preview</h1>
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
	
	return $output; 
}

1;
