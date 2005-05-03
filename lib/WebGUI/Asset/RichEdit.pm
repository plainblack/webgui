package WebGUI::Asset::RichEdit;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Utility;

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
                tableName=>'RichEdit',
                className=>'WebGUI::Asset::RichEdit',
                properties=>{
 			askAboutRichEdit=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			extendedValidElements=>{
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
                        	fieldType=>'selectList',
                                defaultValue=>'ltr'
                                },
 			toolbarLocation=>{
                        	fieldType=>'selectList',
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
		search => "Find",
		replace => "Find and Replace",
		cut => "Cut", 
		copy => "Copy", 
		paste => "Paste",
		undo => "Undo",
		'redo' => "Redo", 
		bold => "Bold",
		italic => "Italic",
		underline => "Underline",
		strikethrough => "Strike Through", 
		justifyleft => "Left Justified", 
		justifycenter => "Centered", 
		justifyright => "Right Justified", 
		justifyfull => "Fully Justified", 
		bullist => "Bulleted List", 
		numlist => "Numbered List", 
		outdent => "Outdent", 
		indent => "Indent", 
		'sub' => "Subscript", 
		sup => "Superscript", 
		styleselect => "Apply Style", 
		formatselect => "Apply Format", 
		fontselect => "Font", 
		fontsizeselect => "Font Size", 
		forecolor => "Foreground Color", 
		backcolor => "Background Color",
		'link' => "Create Hyperlink", 
#		advlink => "Advanced Link",
		pagetree => "WebGUI Page Tree Link",
		anchor => "Anchor",
		'unlink' => "Unlink", 
		tablecontrols => "Table Controls",
		visualaid => "Toggle Table Visual Aid", 
#		spacer => "Toolbar Spacer", 
#		separator => "Toolbar Separator", 
#		rowseparator => "Toolbar Row Separator",
		hr => "Insert Horizontal Rule", 
		advhr => "Advanced Horizontal Rule",
		inserttime => "Insert Time",
		insertdate => "Insert Date",
		image => "Image", 
		insertImage => "WebGUI Image",
#		advimage => "Advanced Image",
		flash => "Flash Movie",
		charmap => "Special Character", 
		collateral => "WebGUI Macro",
		emotions => "Emoticons",
		help => "Help", 
		iespell => "Spell Checker (IE Only)",
		removeformat => "Remove Formatting", 
		code => "View/Edit Source", 
		cleanup => "Clean Up Code", 
		save => "Save / Submit",
		preview => "Preview",
		zoom => "Zoom (IE Only)",
		'print' => "Print",
		);
	my $buttonGrid = '<table style="font-size: 11px;">
		<tr style="font-weight: bold;">
			<td>Button</td>
			<td>Row 1</td>
			<td>Row 2</td>
			<td>Row 3</td>
		</tr>';
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
		-label=>"Toolbar Buttons",
		-value=>$buttonGrid
		);
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("askAboutRichEdit"),
		-label=>"Ask user about using rich edit?",
		-name=>"askAboutRichEdit"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("preformatted"),
		-label=>"Preserve whitespace as preformatted text?",
		-name=>"preformatted",
                -uiLevel=>9
                );
	$tabform->getTab("security")->textarea(
		-value=>$self->getValue("extendedValidElements"),
		-name=>"extendedValidElements",
		-label=>"Extended Valid Elements",
		-subtext=>"<br /> Must appear on one line, no carriage returns.",
		-uiLevel=>9
		);
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorHeight"),
		-label=>"Editor Height",
		-name=>"editorHeight",
                -uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorWidth"),
		-label=>"Editor Width",
		-name=>"editorWidth",
		-uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorHeight"),
		-label=>"Source Editor Height",
		-name=>"sourceEditorHeight"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorWidth"),
		-label=>"Source Editor Width",
		-name=>"sourceEditorWidth"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("useBr"),
		-label=>"Use &lt;br /&gt; instead of &lt;p&gt; on 'Enter'?",
		-name=>"useBr",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("removeLineBreaks"),
		-label=>"Remove line breaks from HTML?",
		-name=>"removeLineBreaks",
                -uiLevel=>9
                );
        $tabform->getTab("display")->yesNo(
                -value=>$self->getValue("nowrap"),
		-label=>"Do not wrap text in editor?",
		-name=>"nowrap",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->selectList(
                -value=>[$self->getValue("directionality")],
		-label=>"Text Direction",
		-name=>"directionality",
		-options=>{
			ltr=>"Left To Right",
			rtl=>"Right To Left"
			}
                );
        $tabform->getTab("display")->selectList(
                -value=>[$self->getValue("toolbarLocation")],
		-label=>"Toolbar Location",
		-name=>"toolbarLocation",
		-options=>{
			top=>"Top",
			bottom=>"Bottom"
			}
                );
        $tabform->getTab("properties")->text(
                -value=>$self->getValue("cssFile"),
		-label=>"CSS File",
		-name=>"cssFile"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("enableContextMenu"),
		-label=>"Enable Context Menu",
		-name=>"enableContextMenu"
                );
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/adminConsole/small/richEdit.gif' if ($small);
	return $session{config}{extrasURL}.'/adminConsole/richEdit.gif';
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

=head2 getUiLevel ()

Returns the UI level of this asset.

=cut

sub getUiLevel {
	return 5;
}

#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "Rich Editor";
} 


#-------------------------------------------------------------------
sub getRichEditor {
	my $self = shift;
	my $calledAsWebMethod = shift;
	my @toolbarRow1 = split("\n",$self->getValue("toolbarRow1"));	
	push(@toolbarRow1,"contextmenu") if ($self->getValue("enableContextMenu"));
	my @toolbarRow2 = split("\n",$self->getValue("toolbarRow2"));	
	my @toolbarRow3 = split("\n",$self->getValue("toolbarRow3"));	
	my @toolbarButtons = (@toolbarRow1,@toolbarRow2,@toolbarRow3);
	my @plugins;
	my %config = (
		mode => "specific_textareas",
		theme => "advanced",
		document_base_url => "/",
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
		extended_valid_elements => $self->getValue("extendedValidElements"),
#		theme_advanced_path_location => $self->getValue("pathLocation"),
		);
	foreach my $button (@toolbarButtons) {
		push(@plugins,"table") if ($button eq "tablecontrols");	
		push(@plugins,"save") if ($button eq "save");	
		push(@plugins,"advhr") if ($button eq "advhr");	
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
		push(@plugins,"") if ($button eq "");	
		push(@plugins,"") if ($button eq "");	
		push(@plugins,"") if ($button eq "");	
		push(@plugins,"") if ($button eq "");	
		push(@plugins,"") if ($button eq "");	
	}
	$config{content_css} = $self->getValue("cssFile") if ($self->getValue("cssFile") ne "");
	$config{width} = $self->getValue("editorWidth") if ($self->getValue("editorWidth") > 0);
	$config{height} = $self->getValue("editorHeight") if ($self->getValue("editorHeight") > 0);
	$config{theme_advanced_source_editor_width} = $self->getValue("sourceEditorWidth") if ($self->getValue("sourceEditorWidth") > 0);
	$config{theme_advanced_source_editor_height} = $self->getValue("sourceEditorHeight") if ($self->getValue("sourceEditorHeight") > 0);
	$config{plugins} = join(",",@plugins);
	my @directives;
	foreach my $key (keys %config) {
		if ($config{$key} eq "true" || $config{$key} eq "false") {
			push(@directives,$key." : ".$config{$key});
		} else {
			push(@directives,$key." : '".$config{$key}."'");
		}
	}
	WebGUI::Style::setScript($session{config}{extrasURL}."/tinymce/jscripts/tiny_mce/tiny_mce.js",{type=>"text/javascript"});
	WebGUI::Style::setScript($session{config}{extrasURL}."/tinymce/jscripts/webgui.js",{type=>"text/javascript"});
	return '<script type="text/javascript">
		tinyMCE.init({
			'.join(",\n    ",@directives).'
			});
		</script>';
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	return '<p>'.$self->getToolbar.'</p>' if ($session{var}{adminOn});
	return undef;
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Rich Editor Configuration");
}



1;

