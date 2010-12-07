package WebGUI::Asset::RichEdit;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Utility;
use WebGUI::International;
use JSON;

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
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,'Asset_RichEdit');
    push(@{$definition}, {
        assetName   => $i18n->get('assetName'),
        icon        => 'richEdit.gif',
        uiLevel     => 5,
        tableName   => 'RichEdit',
        className   => 'WebGUI::Asset::RichEdit',
        properties => {
            disableRichEditor => {
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            askAboutRichEdit => {
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            validElements => {
                fieldType       => 'textarea',
                defaultValue    => 'a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]',
            },
            preformatted => {
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            editorWidth => {
                fieldType       => 'integer',
                defaultValue    => 0,
            },
            editorHeight => {
                fieldType       => 'integer',
                defaultValue    => 0,
            },
            sourceEditorWidth => {
                fieldType       => 'integer',
                defaultValue    => 0,
            },
            sourceEditorHeight => {
                fieldType       => 'integer',
                defaultValue    => 0,
            },
            useBr => {
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            removeLineBreaks => {
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            nowrap=>{
                fieldType       => 'yesNo',
                defaultValue    => 0,
            },
            directionality => {
                fieldType       => 'selectBox',
                defaultValue    => 'ltr',
            },
            toolbarLocation => {
                fieldType       => 'selectBox',
                defaultValue    => 'bottom',
            },
            cssFile => {
                fieldType       => 'text',
                defaultValue    => undef,
            },
            toolbarRow1 => {
                fieldType       => 'checkList',
                defaultValue    => undef,
            },
            toolbarRow2 => {
                fieldType       => 'checkList',
                defaultValue    => undef,
            },
            toolbarRow3 => {
                fieldType       => 'checkList',
                defaultValue    => undef,
            },
            enableContextMenu => {
                fieldType       => "yesNo",
                defaultValue    => 0,
            },
            inlinePopups => {
                fieldType       => "yesNo",
                defaultValue    => 0,
            },
            allowMedia => {
                fieldType       => "yesNo",
                defaultValue    => 0,
            },
        },
    });
    return $class->SUPER::definition($session, $definition);
}



#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,'Asset_RichEdit');
	my %buttons;
	tie %buttons, "Tie::IxHash";
	%buttons = (
		'search' => $i18n->get('search'),
		'replace' => $i18n->get('replace'),
		'cut' => $i18n->get('cut'),
		'copy' => $i18n->get('Copy'),
		'paste' => $i18n->get('paste'),
		'pastetext' => $i18n->get('pastetext'),
		'pasteword' => $i18n->get('pasteword'),
		'undo' => $i18n->get('undo'),
		'redo' => $i18n->get('redo'),
		'bold' => $i18n->get('bold'),
		'italic' => $i18n->get('italic'),
		'underline' => $i18n->get('underline'),
		'strikethrough' => $i18n->get('strikethrough'),
		'justifyleft' => $i18n->get('justifyleft'),
		'justifycenter' => $i18n->get('justifycenter'),
		'justifyright' => $i18n->get('justifyright'),
		'justifyfull' => $i18n->get('justifyfull'),
		'bullist' => $i18n->get('bullist'),
		'numlist' => $i18n->get('numlist'),
		'outdent' => $i18n->get('outdent'),
		'indent' => $i18n->get('indent'),
		'sub' => $i18n->get('sub'),
		'sup' => $i18n->get('sup'),
		'styleselect' => $i18n->get('styleselect'),
		'formatselect' => $i18n->get('formatselect'),
		'fontselect' => $i18n->get('fontselect'),
		'fontsizeselect' => $i18n->get('fontsizeselect'),
		'forecolor' => $i18n->get('forecolor'),
		'backcolor' => $i18n->get('backcolor'),
		'link' => $i18n->get('link'),
		'wgpagetree' => $i18n->get('pagetree'),
		'anchor' => $i18n->get('anchor'),
		'unlink' => $i18n->get('unlink'),
		'tablecontrols' => $i18n->get('tablecontrols'),
		'visualaid' => $i18n->get('visualaid'),
		'hr' => $i18n->get('hr'),
		'advhr' => $i18n->get('advhr'),
		'inserttime' => $i18n->get('inserttime'),
		'insertdate' => $i18n->get('insertdate'),
		'image' => $i18n->get('image'),
		'wginsertimage' => $i18n->get('insertImage'),
		'media' => $i18n->get('media'),
		'charmap' => $i18n->get('charmap'),
		'wgmacro' => $i18n->get('collateral'),
		'emotions' => $i18n->get('emotions'),
		'help' => $i18n->get('help'),
		'iespell' => $i18n->get('iespell'),
		'removeformat' => $i18n->get('removeformat'),
		'code' => $i18n->get('code'),
		'cleanup' => $i18n->get('cleanup'),
		'save' => $i18n->get('save'),
		'preview' => $i18n->get('preview'),
		'fullscreen' => $i18n->get('fullscreen'),
		'print' => $i18n->get('print'),
		'spellchecker' => $i18n->get('Server Side Spell Checker'),
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
			<td></td>
		</tr>!,
		$i18n->get('button'),
		$i18n->get('row 1'),
		$i18n->get('row 2'),
		$i18n->get('row 3');
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
		<td>'.WebGUI::Form::checkbox($self->session, {
			value=>$key,
			name=>"toolbarRow1",
			checked=>$checked1
			}).'</td>
		<td>'.WebGUI::Form::checkbox($self->session, {
			value=>$key,
			name=>"toolbarRow2",
			checked=>$checked2
			}).'</td>
		<td>'.WebGUI::Form::checkbox($self->session, {
			value=>$key,
			name=>"toolbarRow3",
			checked=>$checked3
			}).'</td><td>';
		if ($key eq 'spellchecker' && !($self->session->config->get('availableDictionaries'))) {
			$buttonGrid .= $i18n->get('no dictionaries');
		}
		$buttonGrid .= '</td>
	</tr>
			';
	}
	$buttonGrid .= "</table>";
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get('toolbar buttons'),
		-hoverHelp=>$i18n->get('toolbar buttons description'),
		-value=>$buttonGrid
		);
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("disableRichEditor"),
		-label=>$i18n->get('disable rich edit'),
		-hoverHelp=>$i18n->get('disable rich edit description'),
		-name=>"disableRichEditor"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("askAboutRichEdit"),
		-label=>$i18n->get('using rich edit'),
		-hoverHelp=>$i18n->get('using rich edit description'),
		-name=>"askAboutRichEdit"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("preformatted"),
		-label=>$i18n->get('preformatted'),
		-hoverHelp=>$i18n->get('preformatted description'),
		-name=>"preformatted",
                -uiLevel=>9
                );
	$tabform->getTab("security")->textarea(
		-value=>$self->getValue("validElements"),
		-name=>"validElements",
		-label=>$i18n->get('elements'),
		-hoverHelp=>$i18n->get('elements description'),
		-subtext=>$i18n->get('elements subtext'),
		-uiLevel=>9
		);
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorHeight"),
		-label=>$i18n->get('editor height'),
		-hoverHelp=>$i18n->get('editor height description'),
		-name=>"editorHeight",
                -uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("editorWidth"),
		-label=>$i18n->get('editor width'),
		-hoverHelp=>$i18n->get('editor width description'),
		-name=>"editorWidth",
		-uiLevel=>9
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorHeight"),
		-label=>$i18n->get('source editor height'),
		-hoverHelp=>$i18n->get('source editor height description'),
		-name=>"sourceEditorHeight"
                );
        $tabform->getTab("display")->integer(
                -value=>$self->getValue("sourceEditorWidth"),
		-label=>$i18n->get('source editor width'),
		-hoverHelp=>$i18n->get('source editor width description'),
		-name=>"sourceEditorWidth"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("useBr"),
		-label=>$i18n->get('use br'),
		-hoverHelp=>$i18n->get('use br description'),
		-name=>"useBr",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("removeLineBreaks"),
		-label=>$i18n->get('remove line breaks'),
		-hoverHelp=>$i18n->get('remove line breaks description'),
		-name=>"removeLineBreaks",
                -uiLevel=>9
                );
        $tabform->getTab("display")->yesNo(
                -value=>$self->getValue("nowrap"),
		-label=>$i18n->get('no wrap'),
		-hoverHelp=>$i18n->get('no wrap description'),
		-name=>"nowrap",
                -uiLevel=>9
                );
        $tabform->getTab("properties")->selectBox(
                -value=>[$self->getValue("directionality")],
		-label=>$i18n->get('directionality'),
		-hoverHelp=>$i18n->get('directionality description'),
		-name=>"directionality",
		-options=>{
			ltr=>$i18n->get('left to right'),
			rtl=>$i18n->get('right to left'),
			}
                );
        $tabform->getTab("display")->selectBox(
                -value=>[$self->getValue("toolbarLocation")],
		-label=>$i18n->get('toolbar location'),
		-hoverHelp=>$i18n->get('toolbar location description'),
		-name=>"toolbarLocation",
		-options=>{
			top=>$i18n->get('top'),
			bottom=>$i18n->get('bottom'),
			}
                );
        $tabform->getTab("properties")->text(
                -value=>$self->getValue("cssFile"),
		-label=>$i18n->get('css file'),
		-hoverHelp=>$i18n->get('css file description'),
		-name=>"cssFile"
                );
        $tabform->getTab("properties")->yesNo(
                -value=>$self->getValue("enableContextMenu"),
		-label=>$i18n->get('enable context menu'),
		-hoverHelp=>$i18n->get('enable context menu description'),
		-name=>"enableContextMenu"
                );
    $tabform->getTab("properties")->yesNo(
        -value=>$self->getValue("inlinePopups"),
        -label=>$i18n->get('inline popups'),
        -hoverHelp=>$i18n->get('inline popups description'),
        -name=>"inlinePopups"
    );
    $tabform->getTab("properties")->yesNo(
        value       => $self->getValue("allowMedia"),
        label       => $i18n->get('editForm allowMedia label'),
        hoverHelp   => $i18n->get('editForm allowMedia description'),
        name        => "allowMedia",
    );
	return $tabform;
}

#----------------------------------------------------------------------------

=head2 getAllButtons ( )

Get a list of all the buttons in this MCE

=cut

sub getAllButtons {
    my ( $self ) = @_;
    my @toolbarRows = map{[split "\n", $self->getValue("toolbarRow$_")]} (1..3);
    my @toolbarButtons = map{ @{$_} } @toolbarRows;
    return @toolbarButtons;
}

#----------------------------------------------------------------------------

=head2 getConfig ( )

Get a hashref of configuration to create this MCE. You must run the code
from getLoadPlugins before you can successfully initialize an MCE. You 
must also specify the "elements" key so TinyMCE knows what textarea to 
replace.

=cut

sub getConfig {
    my ($self) = @_;
    my $i18n = WebGUI::International->new($self->session, 'Asset_RichEdit');
    my @plugins;
    push @plugins, "safari";
    push @plugins, "paste";
    push @plugins, "contextmenu"
        if $self->getValue("enableContextMenu");
    push @plugins, "inlinepopups"
        if $self->getValue("inlinePopups");
    push @plugins, "media"
        if $self->getValue( 'allowMedia' );

    my @toolbarRows = map{[split "\n", $self->getValue("toolbarRow$_")]} (1..3);
    my @toolbarButtons = map{ @{$_} } @toolbarRows;
    my %config = (
        mode                    => 'exact',
        theme                   => "advanced",
        relative_urls           => JSON::false(),
        remove_script_host      => JSON::true(),
        auto_reset_designmode   => JSON::true(),
        cleanup_callback        => "tinyMCE_WebGUI_Cleanup",
        urlconverter_callback   => "tinyMCE_WebGUI_URLConvertor",
        theme_advanced_resizing => JSON::true(),
        ( map { "theme_advanced_buttons" . ( $_ + 1 ) => ( join ',', @{ $toolbarRows[$_] } ) } ( 0 .. $#toolbarRows ) ),

        ask               => JSON::false(),
        preformatted      => $self->getValue("preformatted") ? JSON::true() : JSON::false(),
        force_br_newlines => $self->getValue("useBr") ? JSON::true() : JSON::false(),
        force_p_newlines  => $self->getValue("useBr") ? JSON::false() : JSON::true(),
        $self->getValue("useBr") ? ( forced_root_block => JSON::false() ) : (),
        remove_linebreaks => $self->getValue("removeLineBreaks") ? JSON::true() : JSON::false(),
        nowrap            => $self->getValue("nowrap")           ? JSON::true() : JSON::false(),
        directionality    => $self->getValue("directionality"),
        theme_advanced_toolbar_location   => $self->getValue("toolbarLocation"),
        theme_advanced_statusbar_location => "bottom",
        valid_elements                    => $self->getValue("validElements"),
        wg_userIsVisitor                  => $self->session->user->isVisitor ? JSON::true() : JSON::false(),
        paste_postprocess                 => 'tinyMCE_WebGUI_paste_postprocess',
    );
    foreach my $button (@toolbarButtons) {
        if ( $button eq "spellchecker" && $self->session->config->get('availableDictionaries') ) {
            push( @plugins, "-wgspellchecker" );
            $config{spellchecker_rpc_url} = $self->session->url->gateway( '', "op=spellCheck" );
            $config{spellchecker_languages} = join( ',',
                map { ( $_->{default} ? '+' : '' ) . $_->{name} . '=' . $_->{id} }
                    @{ $self->session->config->get('availableDictionaries') } );
        }
        push( @plugins, "table" )      if ( $button eq "tablecontrols" );
        push( @plugins, "save" )       if ( $button eq "save" );
        push( @plugins, "advhr" )      if ( $button eq "advhr" );
        push( @plugins, "fullscreen" ) if ( $button eq "fullscreen" );
        if ( $button eq "advimage" ) {
            push( @plugins, "advimage" );
            $config{external_link_list_url} = "";
        }
        if ( $button eq "advlink" ) {
            $config{external_image_list_url} = "";
            $config{file_browser_callback}   = "mcFileManager.filebrowserCallBack";
            push( @plugins, "advlink" );
        }
        push( @plugins, "emotions" ) if ( $button eq "emotions" );
        push( @plugins, "iespell" )  if ( $button eq "iespell" );
        $config{gecko_spellcheck} = 'true' if ( $button eq "iespell" );
        if ( $button eq "paste" || $button eq "pastetext" || $button eq "pasteword" ) {
            push( @plugins, "paste" );
        }
        if ( $button eq "insertdate" || $button eq "inserttime" || $button eq "insertdatetime" ) {
            $config{plugin_insertdate_dateFormat} = "%Y-%m-%d";
            $config{plugin_insertdate_timeFormat} = "%H:%M:%S";
            push( @plugins, "insertdatetime" );
        }
        push( @plugins, "preview" ) if ( $button eq "preview" );
        if ( $button eq "media" ) {
            push( @plugins, "media" );
        }
        push( @plugins, "searchreplace" )
            if ( $button eq "search" || $button eq "replace" || $button eq "searchreplace" );
        push( @plugins, "print" ) if ( $button eq "print" );
        if ( $button eq "wginsertimage" ) {
            push @plugins, "-wginsertimage";
        }
        if ( $button eq "wgpagetree" ) {
            push @plugins, "-wgpagetree";
        }
        if ( $button eq "wgmacro" ) {
            push @plugins, "-wgmacro";
        }
        if ( $button eq "code" ) {
            $config{theme_advanced_source_editor_width} = $self->getValue("sourceEditorWidth")
                if ( $self->getValue("sourceEditorWidth") > 0 );
            $config{theme_advanced_source_editor_height} = $self->getValue("sourceEditorHeight")
                if ( $self->getValue("sourceEditorHeight") > 0 );
        }
    } ## end foreach my $button (@toolbarButtons)
    my $language = $i18n->getLanguage( '', "languageAbbreviation" );
    unless ($language) {
        $language = $i18n->getLanguage( "English", "languageAbbreviation" );
    }
    $config{language}    = $language;
    $config{content_css} = $self->getValue("cssFile")
        || $self->session->url->extras('tinymce-webgui/defaultcontent.css');
    $config{width}  = $self->getValue("editorWidth")  if ( $self->getValue("editorWidth") > 0 );
    $config{height} = $self->getValue("editorHeight") if ( $self->getValue("editorHeight") > 0 );
    $config{plugins} = join( ",", @plugins );

    return \%config;
} ## end sub getConfig

#-------------------------------------------------------------------

=head2 getList ( )

Returns a list of all available richEditors, considering revisionDate and asset status

NOTE: This is a class method.

=cut

sub getList {
	my $class = shift;
	my $session = shift;
my $sql = "select asset.assetId, assetData.revisionDate from RichEdit left join asset on asset.assetId=RichEdit.assetId left join assetData on assetData.revisionDate=RichEdit.revisionDate and assetData.assetId=RichEdit.assetId where asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' or assetData.tagId=?)) order by assetData.title";
	my $sth = $session->db->read($sql, [ $session->scratch->get('versionTag') ] );
	my %richEditors;
	tie %richEditors, 'Tie::IxHash';
	while (my ($id, $version) = $sth->array) {
		$richEditors{$id} = WebGUI::Asset::RichEdit->new($session, $id, undef, $version)->getTitle;
	}
	$sth->finish;
	return \%richEditors;
}

#-------------------------------------------------------------------

=head2 getLoadPlugins ( )

Get the JS code to load the plugins for this MCE. Needs to be called once
on the page this MCE will be on

=cut

sub getLoadPlugins {
    my ( $self ) = @_;
    my %loadPlugins;
    for my $button ( $self->getAllButtons ) {
        if ( $button eq 'spellchecker' ) {
            $loadPlugins{wgspellchecker} = $self->session->url->extras("tinymce-webgui/plugins/wgspellchecker/editor_plugin.js");
        }
        if ( $button eq 'wginsertimage' ) {
            $loadPlugins{wginsertimage} = $self->session->url->extras("tinymce-webgui/plugins/wginsertimage/editor_plugin.js");
        }
        if ( $button eq 'wgpagetree' ) {
            $loadPlugins{wgpagetree} = $self->session->url->extras("tinymce-webgui/plugins/wgpagetree/editor_plugin.js");
        }
        if ( $button eq 'wgmacro' ) {
            $loadPlugins{wgmacro} = $self->session->url->extras("tinymce-webgui/plugins/wgmacro/editor_plugin.js");
        }
    }

    my $out = '';
    while (my ($plugin, $path) = each %loadPlugins) {
        $out .= "tinymce.PluginManager.load('$plugin', '$path');\n";
    }
    return $out;
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

=head2 getRichEditor ( $nameId )

Return the javascript needed to make the Rich Editor.

=head3 $nameId

The id for the rich editor, should be unique enough to be used as the id parameter
for a HTML tag.

=cut

sub getRichEditor {
	my $self = shift;
	return '' if ($self->getValue('disableRichEditor'));
	my $nameId = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_RichEdit');
    my $ask = $self->getValue("askAboutRichEdit");
#    if ($ask) {
#        $config{oninit} = 'turnOffTinyMCE_'.$nameId;
#    }
    $self->richedit_headTags;
    my $out = '';
    if ($ask) {
        $out = q|<a style="display: block;" href="javascript:toggleEditor('|.$nameId.q|')">|.$i18n->get('Toggle editor').q|</a>|;
    }
    $out .= qq|<script type="text/javascript">\n|;
    if ($ask) {
        $out .= <<"EOHTML1";
function toggleEditor(id) {
    if (!tinyMCE.get(id))
        tinyMCE.execCommand('mceAddControl', false, id);
    else
        tinyMCE.execCommand('mceRemoveControl', false, id);
}
EOHTML1
#function turnOffTinyMCE_$nameId () {
#    if (tinyMCE.get('$nameId')) {
#        tinyMCE.execCommand( 'mceRemoveControl', false, '$nameId');
#    }
#}
#YAHOO.util.Event.onDOMReady(turnOffTinyMCE_$nameId);
    } 

    my $config  = $self->getConfig;
    $config->{ elements } = $nameId;
    if ( $ask ) {
        $config->{mode} = "none";
    }

    $out    .= $self->getLoadPlugins;
    $out    .= "\ttinyMCE.init(" . JSON->new->pretty->encode( $config ) . " );\n";
    $out    .= "</script>";
}


#-------------------------------------------------------------------

=head2 richedit_headTags ( )

Similar to the headTags method for Form plugins, this sets all Javascript and CSS links for the
richeditor to work.

=cut

sub richedit_headTags {
	my $self = shift;
    my $style = $self->session->style;
    my $url   = $self->session->url;
    $style->setScript($url->extras('yui/build/yahoo/yahoo-min.js'),{type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/event/event-min.js'),{type=>"text/javascript"});
    $style->setScript($url->extras('tinymce/jscripts/tiny_mce/tiny_mce_src.js'),{type=>"text/javascript"});
    $style->setScript($url->extras("tinymce-webgui/callbacks.js"),{type=>"text/javascript"});
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->setIsPublic(0);
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Override the method from Asset.pm to change the title of the screen.

=cut

sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	my $i18n = WebGUI::International->new($self->session,"Asset_RichEdit");
    return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get("rich edit edit config"));
}



1;

