package WebGUI::Asset::Wobject::Carousel;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use JSON;
use WebGUI::International;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => [ 'assetName', 'Asset_Carousel' ];
define icon      => 'Carousel.png';
define tableName => 'Carousel';
property templateId => (
    fieldType  => "template",
    default    => 'CarouselTmpl0000000001',
    tab        => "display",
    noFormPost => 0,
    namespace  => "Carousel",
    hoverHelp  => [ 'carousel template description', 'Asset_Carousel' ],
    label      => [ 'carousel template label', 'Asset_Carousel' ],
);
property slideWidth => (
    fieldType => "integer",
    default   => 0,
    tab       => "display",
    hoverHelp => [ 'carousel slideWidth description', 'Asset_Carousel' ],
    label     => [ 'carousel slideWidth label', 'Asset_Carousel' ],
);
property slideHeight => (
    fieldType       => "integer",
    default         => 0,
    tab             => "display",
    hoverHelp       => ['carousel slideHeight description', 'Asset_Carousel' ],
    label           => ['carousel slideHeight label', 'Asset_Carousel' ],
);
property items => (
    noFormPost   => 1,
    fieldType    => 'text',
);
property autoPlay    => (
    fieldType       => 'yesNo',
    defaultValue    => 0,
    tab             => "properties",
    hoverHelp       => ['carousel autoPlay description', 'Asset_Carousel' ],
    label           => ['carousel autoPlay label', 'Asset_Carousel' ],
);
property autoPlayInterval => (
    fieldType       => 'Integer',
    defaultValue    => 4,
    tab             => 'properties',
    hoverHelp       => ['carousel autoPlayInterval description', 'Asset_Carousel'],
    label           => ['carousel autoPlayInterval label', 'Asset_Carousel'],
);

#-------------------------------------------------------------------

=head2 getEditForm ( )

returns the tabform object that will be used in generating the edit page for New Wobjects.
This method is optional if you set autoGenerateForms=1 in the definition.

=cut

override getEditForm => sub {
	my $self    = shift;
	my $tabform = super();
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

    my $tableRowStart = '    <label for="item1">'
        . $i18n->get("items label").'</label><div class="wg-hoverhelp">'.$i18n->get("items description").'</div>'
        . '    <input type="hidden" id="items_formId" name="items" />'
        . '    <input type="button" value="Add item" onclick="window.carouselEditor.addTab()"></input><br />'
        . "    <br />\n";

    $tabform->getTab("properties")->addField('ReadOnly', value => $tableRowStart);

    if($self->items){
        my @items = @{JSON->new->decode($self->items)->{items}};

        foreach my $item (@items){
            my $itemNr = $item->{sequenceNumber};
            my $itemHTML = "<div id='item_div".$itemNr."' name='item_div_".$itemNr."'>\n"
                ."<span>\n"
                .$i18n->get("id label").'<div class="wg-hoverhelp">'.$i18n->get("id description").'</div>: '
                .'<input type="text" id="itemId'.$itemNr.'" '
                .'name="itemId_'.$itemNr.'" value="'.$item->{itemId}.'">'
                ."</span>\n"
                ."<input type='button' id='deleteItem".$itemNr."' value='Delete this item'
onClick='javascript:deleteItem(this.id)'></input>\n"
                .'<textarea id="item'.$itemNr.'" name="item_'.$itemNr.'" '
                .'class="carouselItemText" rows="#" cols="#" '
                .'style="width: 500px; height: 80px;">'.$item->{text}."</textarea><br />\n";
            
            $itemHTML .= 
                " <script type='text/javascript'>\n"
                .'var myEditor'.$itemNr.' '
                .'= new YAHOO.widget.SimpleEditor("item'.$itemNr.'", '
                ."{height: '80px', width: '500px', handleSubmit: true});\n"
                .'myEditor'.$itemNr.".render()\n"
                ."</script>\n"
                ."</div>\n";
            $tabform->getTab("properties")->addField('ReadOnly', value => $itemHTML);
        }
    }
    else{
        my $itemHTML = "<div id='item_div1' name='item_div_1'>\n"
                ."<span>\n"
                .$i18n->get("id label").'<div class="wg-hoverhelp">'.$i18n->get("id description").'</div>: '
                .' <input type="text" id="itemId1" name="itemId_1" value="carousel_item_1">'
                ."</span>\n"
                ."<input type='button' id='deleteItem1' value='Delete this item' onClick='javascript:deleteItem(this.id)'></input>\n"
                .'<textarea id="item1" name="item_1" class="carouselItemText" rows="#" cols="#" '
                ."style='width: 500px; height: 80px;'></textarea><br />\n";
            
        $itemHTML .= 
                 "<script type='text/javascript'>\n"
                ."var myEditor1 = new YAHOO.widget.SimpleEditor('item1', {height: '80px', width: '500px', handleSubmit: true});\n"
                ."myEditor1.render()\n"
                ."</script>\n";
        $tabform->getTab("properties")->addField('ReadOnly', value => $itemHTML);
    }
    

    $self->session->log->warn('richedit:' .$self->get('richEditor'));
    my $richEditId      = $self->get('richEditor') || "PBrichedit000000000001";
    my $richedit        = WebGUI::Asset->newById( $self->session, $richEditId );
    my $config          = JSON->new->encode( $richedit->getConfig );
    my $loadMcePlugins  = $richedit->getLoadPlugins;
    my $items           = $self->get('items') ? JSON->new->decode($self->get('items'))->{items} : [];
    $items              = JSON->new->encode( $items );
    my $i18nJson        = JSON->new->encode( { "delete" => $i18n->get("delete") } );

    $tabform->getTab('properties')->addField( "ReadOnly", name => 'editor', value => <<"ENDHTML");
    <div id="carouselEditor"></div>
    <script type="text/javascript">
    $loadMcePlugins
    YAHOO.util.Event.onDOMReady( function() {
        window.carouselEditor = new WebGUI.Carousel.Editor( "carouselEditor", $config, $items, $i18nJson );
    } );
    </script>
ENDHTML

    return $tabform;
};

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

override prepareView => sub {
    my $self = shift;
    super();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_viewTemplate} = $template;
};

#-------------------------------------------------------------------

=head2 processEditForm ( )

Used to process properties from the form posted.

=cut

override processEditForm => sub {
    my $self    = shift;
    my $form    = $self->session->form;
    super();
    my $items = JSON->new->decode( $form->get("items") ); 
    $self->update({ items => JSON->new->encode({ items => $items }) });
    return undef;
};

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

    if($self->items){
        $var->{item_loop} = JSON->new->decode($self->items)->{items};
    }
	
	#This is an example of debugging code to help you diagnose problems.
	#WebGUI::ErrorHandler::warn($self->get("templateId")); 
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

__PACKAGE__->meta->make_immutable;
1;
#vim:ft=perl
