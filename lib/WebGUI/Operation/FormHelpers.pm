package WebGUI::Operation::FormHelpers;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

sub _outputWrapper {
	my $title = shift;
	my $body = shift;
	return '<html>
<head>
<title>'.$title.'
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
</head>
<body>
'.$body.'
</body>
</html>';
}



#-------------------------------------------------------------------
sub www_formAssetTree {
	my $base = WebGUI::Asset->newByUrl || WebGUI::Asset->getRoot;
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=formAssetTree;classLimiter=".$session{form}{classLimiter}.";formId="
                        .$session{form}{formId}).'">'.$ancestor->get("menuTitle").'</a>');
	}	
	my $output = '<p>'.join(" &gt; ", @crumb)."</p>\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($child->get("className") =~ /^$session{form}{classLimiter}/) {
			$output .= '<a href="#" onclick="window.opener.document.getElementById(\''.$session{form}{formId}
				.'\').value=\''.$child->getId.'\';window.opener.document.getElementById(\''.
				$session{form}{formId}.'_display\').value=\''.$child->get("title").'\';window.close();">(&bull;)</a> ';
		} else {
			$output .= "(&bull;) ";
		}
		$output .= '<a href="'.$child->getUrl("op=formAssetTree;classLimiter=".$session{form}{classLimiter}.";formId="
			.$session{form}{formId}).'">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$session{page}{useEmptyStyle} = 1;
	return _outputWrapper($i18n->get('choose an asset',$output);
}


#-------------------------------------------------------------------

sub www_richEditPageTree {
	my $f = WebGUI::HTMLForm->new(-action=>"#",-extras=>'name"linkchooser"');
	my $i18n = WebGUI::International->new();
	$f->text(
		-name=>"url",
		-label=>WebGUI::International::get(104),
		-hoverHelp=>WebGUI::International::get('104 description'),
		);
	$f->selectBox(
		-name=>"target",
		-label=>WebGUI::International::get('target'),
		-hoverHelp=>WebGUI::International::get('target description'),
		-options=>{"_self"=>WebGUI::International::get('link in same window'),
		           "_blank"=>WebGUI::International::get('link in new window')},
		);
	$f->button(
		-value=>WebGUI::International::get('done'),
		-extras=>'onclick="createLink()"'
		);
	WebGUI::Style::setScript($session{config}{extrasURL}."/tinymce/jscripts/tiny_mce/tiny_mce_popup.js",{type=>"text/javascript"});
	my $output = '<fieldset><legend>'.$i18n->get('insert a link').'</legend>
		<fieldset><legend>'.$i18n->get('insert a link').'</legend>'.$f->print.'</fieldset>
	<script type="text/javascript">
function createLink() {
    if (window.opener) {        
        if (document.getElementById("url_formId").value == "") {
           alert("'.WebGUI::International::get("link enter alert").'");
           document.getElementById("url_formId").focus();
        }
window.opener.tinyMCE.insertLink("^" + "/" + ";" + document.getElementById("url_formId").value,document.getElementById("target_formId").value);
     window.close();
    }
}
</script><fieldset><legend>'.$i18n->get('pages').'</legend> ';
	my $base = WebGUI::Asset->newByUrl || WebGUI::Asset->getRoot;
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditPageTree").'">'.$ancestor->get("menuTitle").'</a>');
	}	
	$output .= '<p>'.join(" &gt; ", @crumb)."</p>\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		$output .= '<a href="#" onclick="document.getElementById(\'url_formId\').value=\''.$child->get("url").'\'">(&bull;)</a> <a href="'.$child->getUrl("op=richEditPageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$session{page}{useEmptyStyle} = 1;
	return _outputWrapper($i18n->get('choose an asset'),$output.'</fieldset></fieldset>');
}



#-------------------------------------------------------------------
sub www_richEditImageTree {
	my $base = WebGUI::Asset->newByUrl || WebGUI::Asset->getRoot;
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditImageTree").'">'.$ancestor->get("menuTitle").'</a>');
	}	
	my $output = '<p>'.join(" &gt; ", @crumb)."</p>\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($child->get("className") =~ /^WebGUI::Asset::File::Image/) {
			$output .= '<a href="'.$child->getUrl("op=richEditViewThumbnail").'" target="viewer">(&bull;)</a> ';
		} else {
			$output .= "(&bull;) ";
		}
		$output .= '<a href="'.$child->getUrl("op=richEditImageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$session{page}{useEmptyStyle} = 1;
	return _outputWrapper($base->getTitle,$output);
}


#-------------------------------------------------------------------
sub www_richEditViewThumbnail {
	my $image = WebGUI::Asset->newByUrl;
	$session{page}{useEmptyStyle} = 1;
	if ($image->get("className") =~ /WebGUI::Asset::File::Image/) {
		my $output = '<div align="center">';
		$output .= '<img src="'.$image->getThumbnailUrl.'" border="0" alt="Preview">';
		$output .= '<br />';
		$output .= $image->get("filename");
		$output .= '</div>';
		$output .= '<script type="text/javascript">';
		$output .= "\nvar src = '".$image->getFileUrl."';\n";
		$output .= "if(src.length > 0) {
				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
    			}
    		    </script>\n";
		return $output;
	}
	return _outputWrapper($image->getTitle,'<div align="center"><img src="'.$session{config}{extrasURL}.'/tinymce/images/icon.gif" border="0" alt="Image Manager"></div>');
}





1;

