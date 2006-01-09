package WebGUI::Asset::RichEdit;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::Form;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::International;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::RichEdit

=head1 DESCRIPTION

A configuration for rich editor.

=head1 SYNOPSIS

use WebGUI::Asset::RichEdit;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName','Asset_RichEdit'),
		icon=>'richEdit.gif',
		uiLevel => 5,
                tableName=>'RichEdit',
                className=>'WebGUI::Asset::RichEdit',
                properties=>{
 			askAboutRichEdit=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			validElements=>{
                        	fieldType=>'textarea',
                                defaultValue=>'a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]'
                                },
 			preformatted=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			editorWidth=>{
                        	fieldType=>'integer',
                                defaultValue=>0
                                },
 			editorHeight=>{
                        	fieldType=>'integer',
                                defaultValue=>0
                                },
 			sourceEditorWidth=>{
                        	fieldType=>'integer',
                                defaultValue=>0
                                },
 			sourceEditorHeight=>{
                        	fieldType=>'integer',
                                defaultValue=>0
                                },
 			useBr=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			removeLineBreaks=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			nowrap=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			directionality=>{
                        	fieldType=>'selectBox',
                                defaultValue=>'ltr'
                                },
 			toolbarLocation=>{
                        	fieldType=>'selectBox',
                                defaultValue=>'bottom'
                                },
 			cssFile=>{
                        	fieldType=>'text',
                                defaultValue=>undef
                                },
 			toolbarRow1=>{
                        	fieldType=>'checkList',
                                defaultValue=>undef
                                },
 			toolbarRow2=>{
                        	fieldType=>'checkList',
                                defaultValue=>undef
                                },
 			toolbarRow3=>{
                        	fieldType=>'checkList',
                                defaultValue=>undef
                                },
			enableContextMenu => {
				fildType => "yesNo",
				defaultValue => 0
				}
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my %buttons;
	tie %buttons, "Tie::IxHash";
	%buttons = (
		'search' => WebGUI::International::get('search', 'Asset_RichEdit'),
		'replace' => WebGUI::International::get('replace', 'Asset_RichEdit'),
		'cut' => WebGUI::International::get('cut', 'Asset_RichEdit'),
		'copy' => WebGUI::International::get('copy', 'Asset_RichEdit'),
		'paste' => WebGUI::International::get('paste', 'Asset_RichEdit'),
		'pastetext' => WebGUI::International::get('pastetext', 'Asset_RichEdit'),
		'pasteword' => WebGUI::International::get('pasteword', 'Asset_RichEdit'),
		'undo' => WebGUI::International::get('undo', 'Asset_RichEdit'),
		'redo' => WebGUI::International::get('redo', 'Asset_RichEdit'),
		'bold' => WebGUI::International::get('bold', 'Asset_RichEdit'),
		'italic' => WebGUI::International::get('italic', 'Asset_RichEdit'),
		'underline' => WebGUI::International::get('underline', 'Asset_RichEdit'),
		'strikethrough' => WebGUI::International::get('strikethrough', 'Asset_RichEdit'),
		'justifyleft' => WebGUI::International::get('justifyleft', 'Asset_RichEdit'),
		'justifycenter' => WebGUI::International::get('justifycenter', 'Asset_RichEdit'),
		'justifyright' => WebGUI::International::get('justifyright', 'Asset_RichEdit'),
		'justifyfull' => WebGUI::International::get('justifyfull', 'Asset_RichEdit'),
		'bullist' => WebGUI::International::get('bullist', 'Asset_RichEdit'),
		'numlist' => WebGUI::International::get('numlist', 'Asset_RichEdit'),
		'outdent' => WebGUI::International::get('outdent', 'Asset_RichEdit'),
		'indent' => WebGUI::International::get('indent', 'Asset_RichEdit'),
		'sub' => WebGUI::International::get('sub', 'Asset_RichEdit'),
		'sup' => WebGUI::International::get('sup', 'Asset_RichEdit'),
		'styleselect' => WebGUI::International::get('styleselect', 'Asset_RichEdit'),
		'formatselect' => WebGUI::International::get('formatselect', 'Asset_RichEdit'),
		'fontselect' => WebGUI::International::get('fontselect', 'Asset_RichEdit'),
		'fontsizeselect' => WebGUI::International::get('fontsizeselect', 'Asset_RichEdit'),
		'forecolor' => WebGUI::International::get('forecolor', 'Asset_RichEdit'),
		'backcolor' => WebGUI::International::get('backcolor', 'Asset_RichEdit'),
		'link' => WebGUI::International::get('link', 'Asset_RichEdit'),
		'pagetree' => WebGUI::International::get('pagetree', 'Asset_RichEdit'),
		'anchor' => WebGUI::International::get('anchor', 'Asset_RichEdit'),
		'unlink' => WebGUI::International::get('unlink', 'Asset_RichEdit'),
		'tablecontrols' => WebGUI::International::get('tablecontrols', 'Asset_RichEdit'),
		'visualaid' => WebGUI::International::get('visualaid', 'Asset_RichEdit'),
		'hr' => WebGUI::International::get('hr', 'Asset_RichEdit'),
		'advhr' => WebGUI::International::get('advhr', 'Asset_RichEdit'),
		'inserttime' => WebGUI::International::get('inserttime', 'Asset_RichEdit'),
		'insertdate' => WebGUI::International::get('insertdate', 'Asset_RichEdit'),
		'image' => WebGUI::International::get('image', 'Asset_RichEdit'),
		'insertImage' => WebGUI::International::get('insertImage', 'Asset_RichEdit'),
		'flash' => WebGUI::International::get('flash', 'Asset_RichEdit'),
		'charmap' => WebGUI::International::get('charmap', 'Asset_RichEdit'),
		'collateral' => WebGUI::International::get('collateral', 'Asset_RichEdit'),
		'emotions' => WebGUI::International::get('emotions', 'Asset_RichEdit'),
		'help' => WebGUI::International::get('help', 'Asset_RichEdit'),
		'iespell' => WebGUI::International::get('iespell', 'Asset_RichEdit'),
		'removeformat' => WebGUI::International::get('removeformat', 'Asset_RichEdit'),
		'code' => WebGUI::International::get('code', 'Asset_RichEdit'),
		'cleanup' => WebGUI::International::get('cleanup', 'Asset_RichEdit'),
		'save' => WebGUI::International::get('save', 'Asset_RichEdit'),
		'preview' => WebGUI::International::get('preview', 'Asset_RichEdit'),
		'fullscreen' => WebGUI::International::get('fullscreen', 'Asset_RichEdit'),
		'zoom' => WebGUI::International::get('zoom', 'Asset_RichEdit'),
		'print' => WebGUI::International::get('print', 'Asset_RichEdit'),
#		'advlink' => "Advanced Link",
#		'spacer' => "Toolbar Spacer", 
#		'separator' => "Toolbar Separator", 
#		'rowseparator' => "Toolbar Row Separator",
#		'advimage' => "Advanced Image",
		);
	my $buttonGrid = sprintf qq!<table style="font-size: 11px;">
		<tr style="font-weight: bold;">
			<td>%s</td>
			<td>%s</td>
			<td>%s</td>
			<td>%s</td>
		</tr>!,
		WebGUI::International::get('button','Asset_RichEdit'),
		WebGUI::International::get('row 1','Asset_RichEdit'),
		WebGUI::International::get('row 2','Asset_RichEdit'),
		WebGUI::International::get('row 3','Asset_RichEdit');
	my @toolbarRow1 = split("\n",$self->getValue("toolbarRow1"));
	my @toolbarRow2 = split("\n",$self->getValue("toolbarRow2"));
	my @toolbarRow3 = split("\n",$self->getValue("toolbarRow3"));
	my $evenOddToggle = 0;
	foreach my $key (keys %buttons) {
		$evenOddToggle = $evenOddToggle ? 0 : 1;
		my $checked1 = isIn($key,@toolbarRow1);
		my $checked2 = isIn($key,@toolbarRow2);
		my $checked3 = isIn($key,@toolbarRow3);
		$buttonGrid .= '
	<tr'.($evenOddToggle ? ' style="background-color: #eeeeee;"' : undef).'>
		<td>'.$buttons{$key}.'</td>
		<td>'.WebGUI::Form::checkbox({
			value=>$key,
			name=>"toolbarRow1",
			checked=>$checked1
			}).'</td>
		<td>'.WebGUI::Form::checkbox({
			value=>$key,
			name=>"toolbarRow2",
			checked=>$checked2
			}).'</td>
		<td>'.WebGUI::Form::checkbox({
			value=>$key,
			name=>"toolbarRow3",
			checked=>$checked3
			}).'</td>
	</tr>
			';
	}
	$buttonGrid .= "</table>";
	$tabform->getTab("properties")->readOnly(
		-label=>WebGUI::International::get('toolbar buttons', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('toolbar buttons description', 'Asset_RichEdit'),
		-value=>$buttonGrid
		);
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("askAboutRichEdit"),
		-label=>WebGUI::International::get('using rich edit', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('using rich edit description', 'Asset_RichEdit'),
		-name=>"askAboutRichEdit"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("preformatted"),
		-label=>WebGUI::International::get('preformatted', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('preformatted description', 'Asset_RichEdit'),
		-name=>"preformatted",
                -uiLevel=>9
                );
	$tabform->getTab("security")->textarea(
		-value=>$self->getValue("validElements"),
		-name=>"validElements",
		-label=>WebGUI::International::get('elements', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('elements description', 'Asset_RichEdit'),
		-subtext=>WebGUI::International::get('elements subtext', 'Asset_RichEdit'),
		-uiLevel=>9
		);
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorHeight"),
		-label=>WebGUI::International::get('editor height', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('editor height description', 'Asset_RichEdit'),
		-name=>"editorHeight",
                -uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorWidth"),
		-label=>WebGUI::International::get('editor width', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('editor width description', 'Asset_RichEdit'),
		-name=>"editorWidth",
		-uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorHeight"),
		-label=>WebGUI::International::get('source editor height', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('source editor height description', 'Asset_RichEdit'),
		-name=>"sourceEditorHeight"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorWidth"),
		-label=>WebGUI::International::get('source editor width', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('source editor width description', 'Asset_RichEdit'),
		-name=>"sourceEditorWidth"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("useBr"),
		-label=>WebGUI::International::get('use br', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('use br description', 'Asset_RichEdit'),
		-name=>"useBr",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("removeLineBreaks"),
		-label=>WebGUI::International::get('remove line breaks', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('remove line breaks description', 'Asset_RichEdit'),
		-name=>"removeLineBreaks",
                -uiLevel=>9
                );
        $tabform->getTab("display")->yesNo(
                -value=>$self->getValue("nowrap"),
		-label=>WebGUI::International::get('no wrap', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('no wrap description', 'Asset_RichEdit'),
		-name=>"nowrap",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->selectBox(
                -value=>[$self->getValue("directionality")],
		-label=>WebGUI::International::get('directionality', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('directionality description', 'Asset_RichEdit'),
		-name=>"directionality",
		-options=>{
			ltr=>WebGUI::International::get('left to right', 'Asset_RichEdit'),
			rtl=>WebGUI::International::get('right to left', 'Asset_RichEdit'),
			}
                );
        $tabform->getTab("display")->selectBox(
                -value=>[$self->getValue("toolbarLocation")],
		-label=>WebGUI::International::get('toolbar location', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('toolbar location description', 'Asset_RichEdit'),
		-name=>"toolbarLocation",
		-options=>{
			top=>WebGUI::International::get('top', 'Asset_RichEdit'),
			bottom=>WebGUI::International::get('bottom', 'Asset_RichEdit'),
			}
                );
        $tabform->getTab("properties")->text(
                -value=>$self->getValue("cssFile"),
		-label=>WebGUI::International::get('css file', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('css file description', 'Asset_RichEdit'),
		-name=>"cssFile"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("enableContextMenu"),
		-label=>WebGUI::International::get('enable context menu', 'Asset_RichEdit'),
		-hoverHelp=>WebGUI::International::get('enable context menu description', 'Asset_RichEdit'),
		-name=>"enableContextMenu"
                );
	return $tabform;
}



#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return $self->SUPER::getToolbar();
}



#-------------------------------------------------------------------
sub getRichEditor {
	my $self = shift;
	my $nameId = shift;
	my @toolbarRow1 = split("\n",$self->getValue("toolbarRow1"));	
	push(@toolbarRow1,"contextmenu") if ($self->getValue("enableContextMenu"));
	my @toolbarRow2 = split("\n",$self->getValue("toolbarRow2"));	
	my @toolbarRow3 = split("\n",$self->getValue("toolbarRow3"));	
	my @toolbarButtons = (@toolbarRow1,@toolbarRow2,@toolbarRow3);
	my @plugins;
	my %config = (
		mode => "exact",
		elements => $nameId,
		theme => "advanced",
		relative_urls => "false",
#		remove_script_host => "false",
#		document_base_url => "/",
		auto_reset_designmode => "true",
    		cleanup_callback => "tinyMCE_WebGUI_Cleanup",
    		urlconvertor_callback => "tinyMCE_WebGUI_URLConvertor",
		theme_advanced_buttons1 => join(",",@toolbarRow1),
		theme_advanced_buttons2 => join(",",@toolbarRow2),
		theme_advanced_buttons3 => join(",",@toolbarRow3),
		ask => $self->getValue("askAboutRichEdit") ? "true" : "false",
		preformatted => $self->getValue("preformatted") ? "true" : "false",
		force_br_newlines => $self->getValue("useBr") ? "true" : "false",
		force_p_newlines => $self->getValue("useBr") ? "false" : "true",
		remove_linebreaks => $self->getValue("removeLineBreaks") ? "true" : "false",
		nowrap => $self->getValue("nowrap") ? "true" : "false",
		directionality => $self->getValue("directionality"),
		theme_advanced_toolbar_location => $self->getValue("toolbarLocation"),
		valid_elements => $self->getValue("validElements"),
		);
	foreach my $button (@toolbarButtons) {
		push(@plugins,"table") if ($button eq "tablecontrols");	
		push(@plugins,"save") if ($button eq "save");	
		push(@plugins,"advhr") if ($button eq "advhr");	
		push(@plugins,"fullscreen") if ($button eq "fullscreen");	
		if ($button eq "advimage") {
			push(@plugins,"advimage");
			$config{external_link_list_url} = "";
		}
		if ($button eq "advlink") {
			$config{external_image_list_url} = "";
			$config{file_browser_callback} = "mcFileManager.filebrowserCallBack";
			push(@plugins,"advlink");
		}
		push(@plugins,"emotions") if ($button eq "emotions");	
		push(@plugins,"iespell") if ($button eq "iespell");	
		if ($button eq "paste" || $button eq "pastetext" || $button eq "pasteword") {
			push(@plugins,"paste");
		}
		if ($button eq "insertdate" || $button eq "inserttime" || $button eq "insertdatetime") {
			$config{plugin_insertdate_dateFormat} = "%Y-%m-%d";
			$config{plugin_insertdate_timeFormat} = "%H:%M:%S";
			push(@plugins,"insertdatetime");
		}
		push(@plugins,"preview") if ($button eq "preview");	
		push(@plugins,"zoom") if ($button eq "zoom");	
		if ($button eq "flash") {
			push(@plugins,"flash");
			$config{flash_external_list_url} = "";
		}
		push(@plugins,"searchreplace") if ($button eq "search" || $button eq "replace" || $button eq "searchreplace");	
		push(@plugins,"print") if ($button eq "print");	
		push(@plugins,"contextmenu") if ($button eq "contextmenu");	
		push(@plugins,"insertImage") if ($button eq "insertImage");	
		push(@plugins,"collateral") if ($button eq "collateral");	
		push(@plugins,"pagetree") if ($button eq "pagetree");	
		if ($button eq "code") {
			$config{theme_advanced_source_editor_width} = $self->getValue("sourceEditorWidth") if ($self->getValue("sourceEditorWidth") > 0);
			$config{theme_advanced_source_editor_height} = $self->getValue("sourceEditorHeight") if ($self->getValue("sourceEditorHeight") > 0);
		}
	}
	my $language  = WebGUI::International::getLanguage($self->session->user->profileField("language"),"languageAbbreviation");
	unless ($language) {
		$language = WebGUI::International::getLanguage("English","languageAbbreviation");
	}
	$config{language} = $language;
	$config{content_css} = $self->getValue("cssFile") || $self->session->config->get("extrasURL").'/tinymce2/defaultcontent.css';
	$config{width} = $self->getValue("editorWidth") if ($self->getValue("editorWidth") > 0);
	$config{height} = $self->getValue("editorHeight") if ($self->getValue("editorHeight") > 0);
	$config{plugins} = join(",",@plugins);
	my @directives;
	foreach my $key (keys %config) {
		if ($config{$key} eq "true" || $config{$key} eq "false") {
			push(@directives,$key." : ".$config{$key});
		} else {
			push(@directives,$key." : '".$config{$key}."'");
		}
	}
	$self->session->style->setScript($self->session->config->get("extrasURL")."/tinymce2/jscripts/tiny_mce/tiny_mce.js",{type=>"text/javascript"});
	$self->session->style->setScript($self->session->config->get("extrasURL")."/tinymce2/jscripts/webgui.js",{type=>"text/javascript"});
	return '<script type="text/javascript">
		tinyMCE.init({
			'.join(",\n    ",@directives).'
			});
		</script>';
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	return '<p>'.$self->getToolbar.'</p>' if ($self->session->var->get("adminOn"));
	return undef;
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("rich edit edit config","Asset_RichEdit"));
}



1;

