package WebGUI::Operation::Theme;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Attachment;
use WebGUI::Collateral;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Node;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewTheme &www_deleteThemeComponent &www_deleteThemeComponentConfirm &www_importTheme &www_importThemeValidate &www_importThemeSave &www_exportTheme &www_addThemeComponent &www_addThemeComponentSave &www_deleteTheme &www_deleteThemeConfirm &www_editTheme &www_editThemeSave &www_listThemes);

#-------------------------------------------------------------------
sub _getComponentTypes {
	my %components;
	tie %components, 'Tie::IxHash';
	%components = (
                        file=>WebGUI::International::get(915),
                        image=>WebGUI::International::get(914),
                        snippet=>WebGUI::International::get(916),
                        template=>WebGUI::International::get(913)
                        );
	return \%components;
}


#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editTheme&themeId=new')} = WebGUI::International::get(901);
	$menu{WebGUI::URL::page('op=importTheme')} = WebGUI::International::get(924);
	unless (isIn($session{form}{op}, qw(deleteThemeConfirm viewTheme listThemes)) || $session{form}{themeId} eq "new") {
                $menu{WebGUI::URL::page('op=editTheme&themeId='.$session{form}{themeId})} = WebGUI::International::get(919);
		$menu{WebGUI::URL::page('op=deleteTheme&themeId='.$session{form}{themeId})} = WebGUI::International::get(918);
		$menu{WebGUI::URL::page('op=exportTheme&themeId='.$session{form}{themeId})} = WebGUI::International::get(920);
	}
	$menu{WebGUI::URL::page('op=listThemes')} = WebGUI::International::get(900);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_addThemeComponent {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        my (@q, $output, $defaultList, $component, $f);
	my $types = _getComponentTypes();
        push(@q,{query=>"select collateralType,collateralId,name from collateral where collateralType='file' order by name",type=>"file"});
        push(@q,{query=>"select collateralType,collateralId,name from collateral where collateralType='image' order by name",type=>"image"});
        push(@q,{query=>"select collateralType,collateralId,name from collateral where collateralType='snippet' order by name",type=>"snippet"});
        $output .= '<h1>'.WebGUI::International::get(909).'</h1>';
	my $selectList = '<select name="id" multiple="1" size="10">';
	foreach my $row (@q) {
		my $comp = WebGUI::SQL->buildHashRef($row->{query});
		$selectList .= "\n".'<optgroup label="'.$types->{$row->{type}}.'">';
		foreach my $key (keys %{$comp}) {
			$selectList .= '<option value="'.$key.'">'.$comp->{$key}.'</option>';
		}
		$selectList .= '</optgroup>';
	}	
	my $sth = WebGUI::SQL->read("select templateId,namespace,name from template order by namespace,name");
	my $previous;
	while( my $comp = $sth->hashRef) {	
		if ($previous ne $comp->{namespace}) {
			$selectList .= "\n".'<optgroup label="'.$types->{template}.'/'.$comp->{namespace}.'">';
		}
		$selectList .= '<option value="template_'.$comp->{templateId}.'_'.$comp->{namespace}.'">'.$comp->{name}.'</option>';
		$previous = $comp->{namespace};	
	}
	$sth->finish;
	$selectList .= '</select>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","addThemeComponentSave");
        $f->hidden("themeId",$session{form}{themeId});
        $f->readOnly(
                -value=>$selectList,
                -label=>WebGUI::International::get(911)
                );
        $f->submit;
        $output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_addThemeComponentSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	my @ids = WebGUI::FormProcessor::selectList("id");
	foreach my $id (@ids) {
		$id =~ /^(.*?)\_(.*)/;
		my $type = $1;
		$id = $2;	
	        my $componentId = getNextId("themeComponentId");
        	WebGUI::SQL->write("insert into themeComponent (themeId,themeComponentId,type,id)
                	        values ($session{form}{themeId}, $componentId, ".quote($type).", ".quote($id).")");
	}
        return www_editTheme();
}

#-------------------------------------------------------------------
sub www_deleteTheme {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{themeId} < 1000 && $session{form}{themeId} > 0);
        my $output = helpIcon("theme delete");
	$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(907).'<p>';
        $output .= '<div align="center"><a href="'.
		WebGUI::URL::page('op=deleteThemeConfirm&themeId='.$session{form}{themeId})
		.'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listThemes').
		'">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteThemeConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{themeId} < 1000 && $session{form}{themeId} > 0);
	my $theme = WebGUI::SQL->quickHashRef("select * from theme where themeId=".$session{form}{themeId});
	unless ($theme->{original}) {
        	WebGUI::SQL->write("delete from collateralFolder where name=".quote($theme->{name}));
                my $sth = WebGUI::SQL->read("select type,Id from themeComponent where themeId=".$session{form}{themeId});
                while (my $component = $sth->hashRef) {
			if ($component->{type} eq "template") {
				my ($id,$namespace) = split("_",$component->{id});
				WebGUI::SQL->write("delete from template where templateId=".$id
					." and namespace=".quote($namespace));
			} else {
				my $c = WebGUI::Collateral->new($component->{id});
				$c->delete;
			}
                }
                $sth->finish;
	}
        WebGUI::SQL->write("delete from theme where themeId=".$session{form}{themeId});
        WebGUI::SQL->write("delete from themeComponent where themeId=".$session{form}{themeId});
        return www_listThemes();
}

#-------------------------------------------------------------------
sub www_deleteThemeComponent {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{themeId} < 1000 && $session{form}{themeId} > 0);
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(908).'<p>';
        $output .= '<div align="center"><a href="'.
                WebGUI::URL::page('op=deleteThemeComponentConfirm&themeId='.$session{form}{themeId})
                .'&themeComponentId='.$session{form}{themeComponentId}.'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listThemes').
                '">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteThemeComponentConfirm {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{themeId} < 1000 && $session{form}{themeId} > 0);
        WebGUI::SQL->write("delete from themeComponent where themeComponentId=".$session{form}{themeComponentId});
        return www_editTheme();
}

#-------------------------------------------------------------------
sub www_editTheme {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        my ($output, $theme, $f);
	unless($session{form}{themeId} eq "new") {
               	$theme = WebGUI::SQL->quickHashRef("select * from theme where themeId=$session{form}{themeId}");
	}
        $output .= helpIcon("theme add/edit");
	$output .= '<h1>'.WebGUI::International::get(902).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","editThemeSave");
        $f->hidden("themeId",$session{form}{themeId});
	$f->readOnly($session{form}{themeId},WebGUI::International::get(903));
        $f->text("name",WebGUI::International::get(904),$theme->{name});
        $f->text("designer",WebGUI::International::get(905),$theme->{designer});
        $f->url(
		-name=>"designerURL",
		-label=>WebGUI::International::get(906),
		-value=>$theme->{designerURL}
		);
	if ($session{form}{themeId} eq "new") {
		$f->whatNext(
			-value=>"addComponent",
			-options=>{
				listThemes=>WebGUI::International::get(900),
				addComponent=>WebGUI::International::get(917)
				}
			);
	}
        $f->submit;
	$output .= $f->print;
	unless ($session{form}{themeId} eq "new") {	
		$output .= '<p><a href="'.WebGUI::URL::page('op=addThemeComponent&themeId='.$session{form}{themeId}).'">'
			.WebGUI::International::get(917).'</a><p>';
		my $componentTypes = _getComponentTypes();
		my $query = "select collateral.name as name, themeComponent.themeComponentId as componentId,
				collateral.collateralType as componentType from themeComponent, collateral 
				where collateral.collateralId=themeComponent.id and themeComponent.type=collateral.collateralType
				and themeComponent.themeId=$session{form}{themeId} order by name";
		my $sth = WebGUI::SQL->read($query);
		while (my $component = $sth->hashRef) {
			$output .= deleteIcon('op=deleteThemeComponent&themeId='.$session{form}{themeId}
				.'&themeComponentId='.$component->{componentId})
				.' '.$component->{name}.' ('.$componentTypes->{$component->{componentType}}.')<br>';
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select themeComponentId,id from themeComponent 
			where type='template' and themeId=".$session{form}{themeId});
		while (my $data = $sth->hashRef) {
			my ($templateId,$namespace) = split("_",$data->{id});
			my ($name) = WebGUI::SQL->quickArray("select name from template where
				templateId=".$templateId." and namespace=".quote($namespace));
			$output .= deleteIcon('op=deleteThemeComponent&themeId='.$session{form}{themeId}
				.'&themeComponentId='.$data->{themeComponentId})
				.' '.$name.' ('.$componentTypes->{template}.'/'.$namespace.')<br>';
		}
		$sth->finish;
	}
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editThemeSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	if ($session{form}{themeId} eq "new") {
		$session{form}{themeId} = getNextId("themeId");
		WebGUI::SQL->write("insert into theme (themeId,webguiVersion,original,versionNumber) 
			values ($session{form}{themeId},".quote($WebGUI::VERSION).",1,0)");
	}
        WebGUI::SQL->write("update theme set name=".quote($session{form}{name}).", designer=".quote($session{form}{designer}).",
		designerURL=".quote($session{form}{designerURL})." where themeId=".$session{form}{themeId});
	if ($session{form}{proceed} eq "addComponent") {
		return www_addThemeComponent();
	}
        return www_listThemes();
}



#-------------------------------------------------------------------
sub www_exportTheme {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	my $tempId = "theme".$session{form}{themeId};
	my $propertyFile = WebGUI::Attachment->new("_theme.properties","temp",$tempId);
	WebGUI::SQL->write("update theme set versionNumber=versionNumber+1, webguiVersion=".quote($WebGUI::VERSION)
		." where themeId=".$session{form}{themeId});
	my $theme = WebGUI::SQL->quickHashRef("select * from theme where themeId=".$session{form}{themeId});
	my $sth = WebGUI::SQL->read("select * from themeComponent where themeId=".$session{form}{themeId});
	while (my $component = $sth->hashRef) {
		my $key = $component->{themeComponentId};
		$theme->{components}{$key}{type} = $component->{type};
		if ($component->{type} eq "image") {
			my $c = WebGUI::Collateral->new($component->{id});
			$theme->{components}{$key}{properties} = $c->get;
			$c->copy("temp",$tempId);
			my $a = WebGUI::Attachment->new($c->getFilename,"temp",$tempId);
			$theme->{components}{$key}{properties}{filename} = WebGUI::URL::makeCompliant($c->get("name"))
				.".".$a->getType;
			$a->rename($theme->{components}{$key}{properties}{filename});
		} elsif ($component->{type} eq "file") {
			my $c = WebGUI::Collateral->new($component->{id});
			$theme->{components}{$key}{properties} = $c->get;
			$c->copy("temp",$tempId);
			my $a = WebGUI::Attachment->new($c->getFilename,"temp",$tempId);
                        $theme->{components}{$key}{properties}{filename} = WebGUI::URL::makeCompliant($c->get("name"))
                                .".".$a->getType;
                        $a->rename($theme->{components}{$key}{properties}{filename});
		} elsif ($component->{type} eq "snippet") {
			my $c = WebGUI::Collateral->new($component->{id});
			$theme->{components}{$key}{properties} = $c->get;
		} elsif ($component->{type} eq "template") {
			my ($id, $namespace) = split("_",$component->{id});
			$theme->{components}{$key}{properties} = WebGUI::SQL->quickHashRef("select * from template 
				where templateId=".$id." and namespace=".quote($namespace));
		}
	}
	$sth->finish;
	$propertyFile->saveFromHashref($theme);
	my $packageName = WebGUI::URL::makeCompliant($theme->{name}).".theme.tar.gz";
	$propertyFile->getNode->tar($packageName);
	my $export = WebGUI::Attachment->new($packageName,"temp");
	WebGUI::HTTP::setRedirect($export->getURL);
	return "";
}


#-------------------------------------------------------------------
sub www_importTheme {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	my $output = helpIcon("theme import");
	$output .= '<h1>'.WebGUI::International::get(927).'</h1>';
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"op",
		-value=>"importThemeValidate"
		);
	$f->file(
		-name=>"themePackage",
		-label=>WebGUI::International::get(921)
		);
	$f->submit(WebGUI::International::get(929));
	$output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_importThemeValidate {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	my $output = helpIcon("theme import");
	$output .= '<h1>'.WebGUI::International::get(927).'</h1>';
	my $a = WebGUI::Attachment->new("","temp");
	my $filename = $a->save("themePackage");
	return $output.WebGUI::International::get(935) unless ($filename =~ /\.theme.tar.gz$/);
	my $subnode = time();
	my $extracted = WebGUI::Node->new("temp",$subnode);
	$extracted->untar($filename);
	my $propertiesFile = WebGUI::Attachment->new("_theme.properties","temp",$subnode);
	my $theme = $propertiesFile->getHashref;
	my @themes = WebGUI::SQL->buildArray("select name from theme");
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"op",
		-value=>"importThemeSave"
		);
	$f->readOnly(
		-label=>WebGUI::International::get(904),
		-value=>$theme->{name}
		);
	$f->readOnly(
		-label=>WebGUI::International::get(905),
		-value=>$theme->{designer}
		);
	$f->readOnly(
		-label=>WebGUI::International::get(906),
		-value=>$theme->{designerURL}
		);
	$f->hidden(
		-name=>"extractionPoint",
		-value=>$subnode
		);
	$f->readOnly(
		-label=>WebGUI::International::get(922),
		-value=>"WebGUI ".$theme->{webguiVersion}
		);
	$f->readOnly(
		-label=>WebGUI::International::get(923),
		-value=>$theme->{versionNumber}
		);
	if ($theme->{webguiVersion} > $WebGUI::VERSION) {
		$output .= WebGUI::International::get(926);
	} elsif (isIn($theme->{name},@themes)) {
		$output .= WebGUI::International::get(925);
	} else {
		$output .= WebGUI::International::get(928);
		$f->submit(WebGUI::International::get(929));
	}
	$output .= "<p>".$f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_importThemeSave {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
	my $propertiesFile = WebGUI::Attachment->new("_theme.properties","temp",$session{form}{extractionPoint});
	my $theme = $propertiesFile->getHashref;
	my $themeId = getNextId("themeId");
	WebGUI::SQL->write("insert into theme (themeId,name,designer,designerURL,webguiVersion,versionNumber,original) values
		($themeId, ".quote($theme->{name}).", ".quote($theme->{designer}).", ".quote($theme->{designerURL})
		.", ".quote($theme->{webguiVersion}).", $theme->{versionNumber}, 0)");
	my $collateralFolderId = getNextId("collateralFolderId");
	WebGUI::SQL->write("insert into collateralFolder (collateralFolderId,name,parentId) values ($collateralFolderId,
		".quote($theme->{name}).", 0)");
	foreach my $key (keys %{$theme->{components}}) {
		my $type = $theme->{components}{$key}{type};
		if ($type eq "template") {
			$theme->{components}{$key}{properties}{$type."Id"} = getNextId($type."Id");
			my (@fields, @values);
			foreach my $property (keys %{$theme->{components}{$key}{properties}}) {
				push(@fields,$property);
				push(@values,quote($theme->{components}{$key}{properties}{$property}));
			}
			WebGUI::SQL->write("insert into ".$type." (".join(",",@fields).") values (".join(",",@values).")");
			my $id = $theme->{components}{$key}{properties}{$type."Id"};
			$id .= "_".$theme->{components}{$key}{properties}{namespace} if ($type eq "template");
			WebGUI::SQL->write("insert into themeComponent (themeId,themeComponentId,type,id) 
				values ($themeId, ".getNextId("themeComponentId").", ".quote($type).", ".quote($id).")");
		} elsif (isIn($type, qw(image file snippet))) {
			$theme->{components}{$key}{properties}{collateralFolderId} = $collateralFolderId;
			my $c = WebGUI::Collateral->new("new");
			$c->set($theme->{components}{$key}{properties});
			$c->saveFromFilesystem($propertiesFile->getNode->getPath.$session{os}{slash}
				.$theme->{components}{$key}{properties}{filename});
			WebGUI::SQL->write("insert into themeComponent (themeId,themeComponentId,type,id) 
				values ($themeId, ".getNextId("themeComponentId").", ".quote($type).", "
				.quote($c->get("collateralId")).")");
		}
	}
	return www_listThemes();
}

#-------------------------------------------------------------------
sub www_listThemes {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        my (@data, @row, $i, $p);
        my $output = helpIcon("themes manage");
	$output .= '<h1>'.WebGUI::International::get(899).'</h1>';
        my $sth = WebGUI::SQL->read("select themeId,name,original from theme order by name");
        while (@data = $sth->array) {
                $row[$i] = '<tr><td valign="top" class="tableData">'.deleteIcon('op=deleteTheme&themeId='.$data[0]);
		if ($data[2]) { 
			$row[$i] .= editIcon('op=editTheme&themeId='.$data[0]);
		} else {
			$row[$i] .= viewIcon('op=viewTheme&themeId='.$data[0]);
		}
		$row[$i] .= '</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data[1].'</td></tr>';
                $i++;
        }
	$sth->finish;
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listThemes'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= $p->getPage($session{form}{pn});
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_viewTheme {
        return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(9));
        my ($output, $theme, $f);
        $theme = WebGUI::SQL->quickHashRef("select * from theme where themeId=$session{form}{themeId}");
        $output .= '<h1>'.WebGUI::International::get(930).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->readOnly(
		-value=>$session{form}{themeId},
		-label=>WebGUI::International::get(903)
		);
        $f->readOnly(
                -label=>WebGUI::International::get(904),
                -value=>$theme->{name}
                );
        $f->readOnly(
                -label=>WebGUI::International::get(905),
                -value=>$theme->{designer}
                );
        $f->readOnly(
                -label=>WebGUI::International::get(906),
                -value=>$theme->{designerURL}
                );
        $f->readOnly(
                -label=>WebGUI::International::get(922),
                -value=>"WebGUI ".$theme->{webguiVersion}
                );
        $f->readOnly(
                -label=>WebGUI::International::get(923),
                -value=>$theme->{versionNumber}
                );
        $output .= $f->print;
        my $componentTypes = _getComponentTypes();
        my $query = "select collateral.name as name, themeComponent.themeComponentId as componentId,
                                collateral.collateralType as componentType from themeComponent, collateral
                                where collateral.collateralId=themeComponent.id and themeComponent.type=collateral.collateralType
                                and themeComponent.themeId=$session{form}{themeId} order by name";
            my $sth = WebGUI::SQL->read($query);
             while (my $component = $sth->hashRef) {
                      $output .= $component->{name}.' ('.$componentTypes->{$component->{componentType}}.')<br>';
               }
             $sth->finish;
            $sth = WebGUI::SQL->read("select themeComponentId,id from themeComponent
                        where type='template' and themeId=".$session{form}{themeId});
                while (my $data = $sth->hashRef) {
                        my ($templateId,$namespace) = split("_",$data->{id});
                        my ($name) = WebGUI::SQL->quickArray("select name from template where
                                templateId=".$templateId." and namespace=".quote($namespace));
                                $output .= $name.' ('.$componentTypes->{template}.')<br>';
                }
                $sth->finish;
        return _submenu($output);
}

1;
