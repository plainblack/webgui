package WebGUI::Operation::RichEdit;

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
use WebGUI::Asset;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::Style;

#-------------------------------------------------------------------

sub www_richEditPageTree {
	my $f = WebGUI::HTMLForm->new(-action=>"#",-extras=>'name"linkchooser"');
	$f->text(
		-name=>"url",
		-label=>"URL",
		-extras=>'id="url"'
		);
	$f->selectList(
		-name=>"target",
		-label=>"Target",
		-options=>{"_self"=>"Open link in same window.","_blank"=>"Open link in new window."},
		-extras=>'id="target"'
		);
	$f->button(
		-value=>"Done",
		-extras=>'onclick="createLink()"'
		);
	WebGUI::Style::setScript($session{config}{extrasURL}."/tinymce/jscripts/tiny_mce/tiny_mce_popup.js",{type=>"text/javascript"});
	my $output = '<fieldset><legend>Insert A Link</legend>
		<fieldset><legend>Link Settings</legend>'.$f->print.'</fieldset>
	<script language="javascript">
function createLink() {
    if (window.opener) {        
        if (document.getElementById("url").value == "") {
           alert("You must enter a link url");
           document.getElementById("url").focus();
        }
window.opener.tinyMCE.insertLink("^" + "/" + ";" + document.getElementById("url").value,document.getElementById("target").value);
     window.close();
    }
}
</script><fieldset><legend>Pages</legend> ';
	my $base = WebGUI::Asset->newByUrl || WebGUI::Asset->getRoot;
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnQuickReadObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditPageTree").'">'.$ancestor->get("menuTitle").'</a>');
	}	
	$output .= '<p>'.join(" &gt; ", @crumb)."</p>\n";
	my $children = $base->getLineage(["children"],{returnQuickReadObjects=>1});
	foreach my $child (@{$children}) {
		$output .= '<a href="#" onclick="document.getElementById(\'url\').value=\''.$child->get("url").'\'">(&bull;)</a> <a href="'.$child->getUrl("op=richEditPageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$session{page}{useEmptyStyle} = 1;
	return $output.'</fieldset></fieldset>';
}


#-------------------------------------------------------------------
sub _htmlAreaCreateTree {
	my ($output);
	my ($name, $description, $url, $image, $indent, $target, $delete) = @_;
	if($delete) {
		$delete  = qq/<a href="javascript:deleteCollateral('$delete')" title="delete $name">/;
		 $delete .= deleteIcon()."</a>";
	}
	$target = ' target="'.$target.'" ' if ($target);
	$output .= '<tr><td align="left" valign="bottom" width="100%">';
	$output .= ('<img src="'.$session{config}{extrasURL}.'/tinymce/images/indent.gif" width="17" heigth="17">') x$indent;
	$output .= '<img src="'.$session{config}{extrasURL}.'/tinymce/images/'.$image.'" align="bottom" alt="'.$name.'">';
	$output .= '<a title="'.$description.'" href="'.$url.'" '.$target.'><b>'.$name.'</b></a></td>';
	$output .= '<td class="delete" align="right" valign="bottom">'.$delete.'</td></tr>';
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlArealistCollateral {
	my (@parents, $sth, $data, $indent);
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));

	my $output = '<table border="0" cellspacing="0" cellpadding="0" width="100%">';
	my $folderId = $session{form}{fid} || 0;
	my $parent = $folderId;
	# push parent folders in array so it can be reversed
	unshift(@parents, $parent);
	until($parent eq '0') {
		($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder where collateralFolderId=".quote($parent));
		unshift(@parents, $parent);
	}
	# Build tree for opened parent folders
	foreach $parent (@parents) { 
		my ($name, $description) = WebGUI::SQL->quickArray("select name, description from 
							collateralFolder where collateralFolderId=".quote($parent));
		my ($itemsInFolder) = WebGUI::SQL->quickArray("select count(*) from collateral where collateralFolderId = ".quote($parent));
		my ($foldersInFolder)=WebGUI::SQL->quickArray("select count(*) from collateralFolder where parentId=".quote($parent));
		my $delete = "fid=$parent" unless ($itemsInFolder + $foldersInFolder);
		$output .= _htmlAreaCreateTree($name, $description, 
				WebGUI::URL::page('op=htmlArealistCollateral&fid='.$parent), "opened.gif", 
				$indent++,"" ,$delete);
	}
	# Extend tree with closed folders in current folder
	$sth = WebGUI::SQL->read("select collateralFolderId, name, description from collateralFolder
		                  where parentId=".quote($folderId)." and collateralFolderId <> '0' order by name");
        while ($data = $sth->hashRef) { 
		my ($itemsInFolder) = WebGUI::SQL->quickArray("select count(*) from collateral where 
							collateralFolderId = ".quote($data->{collateralFolderId}));
		my $delete = 'fid='.$data->{collateralFolderId} unless $itemsInFolder;
		$output .= _htmlAreaCreateTree($data->{name}, $data->{description}, 
					WebGUI::URL::page('op=htmlArealistCollateral&fid='.$data->{collateralFolderId}), 
					"closed.gif", $indent, "", $delete);
        }
	# Extend tree with images in current folder
	$sth = WebGUI::SQL->read("select collateralId, name, filename from collateral where collateralType = 'image' ".
                                 "and collateralFolderId = ".quote($folderId));
	while ($data = $sth->hashRef) {
		$data->{filename} =~ /\.([^\.]+)$/; # Get extension
		my $fileType = $1.'.gif';
		$output .= _htmlAreaCreateTree($data->{filename}, $data->{name},
					WebGUI::URL::page('op=htmlAreaviewCollateral&cid='.$data->{collateralId}),
					$fileType, $indent, "viewer", 'cid='.$data->{collateralId}.'&fid='.$folderId);
	}
	$output .= '</table>';
	$output .= '<script language="javascript">'."\n".'actionComplete("","'.$folderId.'","","");';
	$output .= "\n</script>\n";
	$sth->finish;
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlAreaviewCollateral {
	my($output, $collateral, $file, $x, $y, $image, $error);
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
        $output .= '<table align="center" border="0" cellspacing="0" cellpadding="2" width="100%" height="100%">';
	if($session{form}{cid} eq "" || ! WebGUI::Grouping::isInGroup(4)) {
		$output .= '<tr><td align="center" valign="middle" width="100%" height="100%">';
		$output .= '<p align="center"><br><img src="'.$session{config}{extrasURL}.'/tinymce/images/icon.gif" 
			    border="0"></p>';
		$output .= '<P align=center><STRONG>WebGUI Image Manager<BR>for TinyMCE</STRONG></P>';
		$output .= '</td></tr></table>';
	} else {
		my $c = WebGUI::Collateral->new($session{form}{cid});
		$collateral = $c->get;
		$file = WebGUI::Attachment->new($collateral->{filename},"images",$collateral->{collateralId});
		$output .= '<tr><td class="label" align="center" valign="middle" width="100%">';
		$output .= '<b>'.$file->getFilename.'</b><br>';
	#	if ($hasImageMagick) {
	#		$image = Image::Magick->new;
	#		$error = $image->Read($file->getPath);
	#		($x, $y) = $image->Get('width','height');
	#		$output .= $error ? "Error reading image: $error" : "<i>($x &#215; $y)</i>";
	#	}
		$output .= '</td></tr><tr><td align="center" valign="middle" width="100%" height="100%">';
		$output .= '<img src="'.$file->getThumbnail.'" border="0">';
		$output .= '</td></tr></table>';
		$output .= '<script language="javascript">';
		$output .= "\nvar src = '".$file->getURL."';\n";
		$output .= "if(src.length > 0) {
   				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
		    		}
		    	    </script>\n";
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_htmlAreaUpload {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
	return www_htmlArealistCollateral() if ($session{form}{image} eq "");
	my($test, $file);
	$session{form}{fid} = $session{form}{collateralFolderId} = $session{form}{path};
        my $collateral = WebGUI::Collateral->new("new");
        $session{form}{thumbnailSize} ||= $session{setting}{thumbnailSize};
        $session{form}{cid} = $collateral->get("collateralId");
        $collateral->save("image", $session{form}{thumbnailSize});
        $session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (($test) = WebGUI::SQL->quickArray("select name from collateral
                where name=".quote($session{form}{name})." and collateralId<>".quote($collateral->get("collateralId")))) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
        $collateral->set($session{form});
        $session{form}{collateralType} = "";
        return www_htmlArealistCollateral();
}

#-------------------------------------------------------------------
sub www_htmlAreaDelete {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
	if($session{form}{cid}) { # Delete Image
	        my $collateral = WebGUI::Collateral->new($session{form}{cid});
        	$collateral->delete;
	} elsif($session{form}{fid} and not($session{form}{cid})) {
		return WebGUI::Privilege::vitalComponent() unless ($session{form}{fid} > 999);
	        my ($parent) = WebGUI::SQL->quickArray("select parentId from collateralFolder where collateralFolderId=".quote($session{form}{fid}));
	        WebGUI::SQL->write("delete from collateralFolder where collateralFolderId=".quote($session{form}{fid}));
		$session{form}{fid}=$parent;	
	}	
        return www_htmlArealistCollateral();
}

#-------------------------------------------------------------------
sub www_htmlAreaCreateFolder {
        $session{page}{makePrintable}=1; $session{page}{printableStyleId}=10;
	return "<b>Only Content Managers are allowed to use WebGUI Collateral</b>" unless (WebGUI::Grouping::isInGroup(4));
        $session{form}{fid} = WebGUI::Id::generate();
        WebGUI::Session::setScratch("collateralFolderId",$session{form}{fid});
        WebGUI::SQL->write("insert into collateralFolder (collateralFolderId) values (".quote($session{form}{fid}).")");
        my $folderId = $session{scratch}{collateralFolderId} || 0;
	$session{form}{name} = $session{form}{folder};
        $session{form}{name} = "untitled" if ($session{form}{name} eq "");
        while (my ($test) = WebGUI::SQL->quickArray("select name from collateralFolder
                where name=".quote($session{form}{name})." and collateralFolderId<>".quote($folderId))) {
                if ($session{form}{name} =~ /(.*)(\d+$)/) {
                        $session{form}{name} = $1.($2+1);
                } elsif ($test ne "") {
                        $session{form}{name} .= "2";
                }
        }
        WebGUI::SQL->write("update collateralFolder set parentId=".quote($session{form}{path}).", name=".quote($session{form}{name})
                .", description=".quote($session{form}{description})." where collateralFolderId=".quote($folderId));
	$session{form}{fid} = $session{form}{path};
        return www_htmlArealistCollateral();
}





1;

