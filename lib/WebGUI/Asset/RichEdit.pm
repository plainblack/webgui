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
use WebGUI::Asset::Template;
use WebGUI::Macro;
use WebGUI::Session;

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
 			templateId=>{
                        	fieldType=>'template',
                                defaultValue=>'PBtmpl0000000000000180'
                                },
 			askAboutRichEdit=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
 			preformated=>{
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
 			convertNewLinesToBr=>{
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
		replace => "Replace",
		searchreplace => "Find and Replace",
		cut => "Cut", 
		copy => "Copy", 
		paste => "Paste",
		undo => "Undo",
		redo => "Redo", 
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
		sub => "Subscript", 
		sup => "Superscript", 
		styleselect => "Apply Style", 
		formatselect => "Apply Format", 
		code => "Code", 
		fontselect => "Font", 
		fontsizeselect => "Font Size", 
		forecolor => "Foreground Color", 
		backcolor => "Background Color",
		link => "Create Hyperlink", 
#		advlink => "Advanced Link",
		pagetree => "WebGUI Page Tree Link",
		anchor => "Anchor",
		unlink => "Unlink", 
		tablecontrols => "Table Controls",
		table => "Create Table", 
		row_before => "Insert Table Row Before", 
		row_after => "Insert Table Row After",
		delete_row => "Delete Table Row", 
		col_before => "Insert Table Column Before", 
		col_after => "Insert Table Column After", 
		delete_col => "Delete Table Column", 
		visualaid => "Toggle Table Visual Aid", 
#		spacer => "Toolbar Spacer", 
#		separator => "Toolbar Separator", 
#		rowseparator => "Toolbar Row Separator",
		hr => "Insert Horizontal Rule", 
		advhr => "Advanced Horizontal Rule",
		inserttime => "Insert Time",
		insertdate => "Insert Date",
		insertdatetime => "Insert Date and Time",
		image => "Image", 
		insertImage => "WebGUI Image",
#		advimage => "Advanced Image",
#		flash => "Flash Movie",
		charmap => "Special Character", 
		collateral => "WebGUI Macro",
		emotions => "Emoticons",
		help => "Help", 
		iespell => "Internet Explorer Spell Checker",
		removeformat => "Remove Formatting", 
		source => "View Source",
		cleanup => "Clean Up Code", 
#		save => "Save",
		preview => "Preview",
		zoom => "Zoom",
		print => "Print",
		);
        $tabform->getTab("properties")->checkList(
                -name=>"toolbarRow1",
                -label=>"Toolbar Row 1",
		-options=>\%buttons,
                -value=>[$self->getValue("toolbarRow1")]
                );
        $tabform->getTab("properties")->checkList(
                -name=>"toolbarRow2",
                -label=>"Toolbar Row 2",
		-options=>\%buttons,
                -value=>[$self->getValue("toolbarRow2")]
                );
        $tabform->getTab("properties")->checkList(
                -name=>"toolbarRow3",
                -label=>"Toolbar Row 3",
		-options=>\%buttons,
                -value=>[$self->getValue("toolbarRow3")]
                );
        $tabform->getTab("display")->template(
                -value=>$self->getValue("templateId")
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("askAboutRichEdit"),
		-label=>"Ask user about rich using rich edit?",
		-name=>"askAboutRichEdit"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("preformatted"),
		-label=>"Edit preformmated text?",
		-name=>"preformatted"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorWidth"),
		-label=>"Editor Width",
		-name=>"editorWidth"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorHeight"),
		-label=>"Editor Height",
		-name=>"editorHeight"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorWidth"),
		-label=>"Source Editor Width",
		-name=>"sourceEditorWidth"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorHeight"),
		-label=>"Source Editor Height",
		-name=>"sourceEditorHeight"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("useBr"),
		-label=>"Use &lt;br /&gt; instead of &lt;p&gt; on 'Enter'?",
		-name=>"useBr"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("convertNewLinesToBr"),
		-label=>"Convert new lines to &lt;br /&gt; on paste?",
		-name=>"convertNewLinesToBr"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("removeLineBreaks"),
		-label=>"Remove line breaks from HTML?",
		-name=>"removeLineBreaks"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("nowrap"),
		-label=>"Do not wrap text in editor?",
		-name=>"nowrap"
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
	return $session{config}{extrasURL}.'/assets/small/snippet.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/snippet.gif';
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
	return "Snippet";
} 


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	push(@toolbarRow1,"contextmenu") if ($self->getValue("enableContextMenu"));
	my $output = WebGUI::Macro::process($self->get("snippet"));
	$output = '<p>'.$self->getToolbar.'</p>'.$output if ($session{var}{adminOn} && !$calledAsWebMethod);
	return $output unless ($self->getValue("processAsTemplate")); 
	return WebGUI::Asset::Template->processRaw($output);
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        $self->getAdminConsole->setHelp("snippet add/edit","Snippet");
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Rich Editor Configuration");
}



1;

