package WebGUI::Asset::Wobject::Carousel;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use JSON;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for New Wobject instances.  You absolutely need 
this method in your new Wobjects.  If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.  

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'Asset_Carousel');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		templateId =>{
			fieldType       =>"template",  
			defaultValue    =>'CarouselTmpl0000000001',
			tab             =>"display",
			noFormPost      =>0,  
			namespace       =>"Carousel", 
			hoverHelp       =>$i18n->get('carousel template description'),
			label           =>$i18n->get('carousel template label'),
		},
		slideWidth =>{
			fieldType       => "integer",  
			defaultValue    => 0,
			tab             => "display",
			hoverHelp       => $i18n->get('carousel slideWidth description'),
			label           => $i18n->get('carousel slideWidth label'),
		},
		slideHeight =>{
			fieldType       => "integer",  
			defaultValue    => 0,
			tab             => "display",
			hoverHelp       => $i18n->get('carousel slideHeight description'),
			label           => $i18n->get('carousel slideHeight label'),
		},
        items =>{
            noFormPost      =>1,
            fieldType       =>'text',
            autoGenerate    =>0,
        },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'Carousel.png',
		autoGenerateForms=>1,
		tableName=>'Carousel',
		className=>'WebGUI::Asset::Wobject::Carousel',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate ( )

duplicates a New Wobject.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
wobject instances, you will need to duplicate them here.

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

returns the tabform object that will be used in generating the edit page for New Wobjects.
This method is optional if you set autoGenerateForms=1 in the definition.

=cut

sub getEditForm {
	my $self    = shift;
	my $tabform = $self->SUPER::getEditForm();
    my $i18n    = WebGUI::International->new($self->session, "Asset_Carousel");

    $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/element/element-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/tabview/tabview-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/editor/editor-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/editor/assets/skins/sam/editor.css'), {type
    =>'text/css', rel=>'stylesheet'});
    $self->session->style->setLink($self->session->url->extras('yui/build/tabview/assets/skins/sam/tabview.css'), {type
    =>'text/css', rel=>'stylesheet'});
    $self->session->style->setScript($self->session->url->extras('wobject/Carousel/carousel.js'), {type =>
    'text/javascript'});

    my $tableRowStart = 
        '<tr id="items_row">'
        .'    <td class="formDescription"  valign="top" style="width: 180px;"><label for="item1">'
              .$i18n->get("items label").'</label><div class="wg-hoverhelp">'.$i18n->get("items description").'</div></td>'
        .'    <td id="items_td" valign="top" class="tableData">'
        .'    <input type="hidden" id="items_formId" name="items" />'
        .'    <input type="button" value="Add item" onclick="window.carouselEditor.addTab()"></input><br />'
        ."    <br />\n";

    $tabform->getTab("properties")->raw($tableRowStart);
    

    my $richedit        = WebGUI::Asset->newByDynamicClass( $self->session, $self->session->setting->get('richEditor') );
    my $config          = JSON->new->encode( $richedit->getConfig );
    my $loadMcePlugins  = $richedit->getLoadPlugins;
    my $items           = $self->get('items') ? JSON->new->decode($self->get('items'))->{items} : [];
    $items              = JSON->new->encode( $items );
    my $i18n            = JSON->new->encode( { "delete" => $i18n->get("delete") } );

    $tabform->getTab('properties')->raw(<<"ENDHTML");
    <div id="carouselEditor"></div>
    <script type="text/javascript">
    $loadMcePlugins
    YAHOO.util.Event.onDOMReady( function() {
        window.carouselEditor = new WebGUI.Carousel.Editor( "carouselEditor", $config, $items, $i18n );
    } );
    </script>
ENDHTML

    my $tableRowEnd = qq|
            </td>
        </tr>
    |;
    $tabform->getTab("properties")->raw($tableRowEnd);
    
    return $tabform;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $form    = $self->session->form;
    $self->SUPER::processPropertiesFromFormPost(@_);

    my $items   = JSON->new->decode( $form->get("items") ); 
    $self->update({ items => JSON->new->encode({ items => $items }) });
    return undef;
}

#-------------------------------------------------------------------

=head2 purge ( )

removes collateral data associated with a Carousel when the system
purges it's data.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
wobject instances, you will need to purge them here.

=cut

sub purge {
	my $self = shift;
	#purge your wobject-specific data here.  This does not include fields 
	# you create for your Carousel asset/wobject table.
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
	my $self = shift;
	my $session = $self->session;	
    my (@item_loop);

	#This automatically creates template variables for all of your wobject's properties.
	my $var = $self->get;

    if($self->getValue('items')){
        $var->{item_loop} = JSON->new->decode($self->getValue('items'))->{items};
    }
	
	#This is an example of debugging code to help you diagnose problems.
	#WebGUI::ErrorHandler::warn($self->get("templateId")); 
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

1;
#vim:ft=perl
