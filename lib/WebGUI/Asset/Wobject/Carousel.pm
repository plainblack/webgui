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

    $self->session->style->setScript($self->session->url->extras('yui/build/editor/editor-min.js'), {type =>
    'text/javascript'});
    $self->session->style->setLink($self->session->url->extras('yui/build/editor/assets/skins/sam/editor.css'), {type
    =>'text/css', rel=>'stylesheet'});
    $self->session->style->setScript($self->session->url->extras('wobject/Carousel/carousel.js'), {type =>
    'text/javascript'});

    my $tableRowStart = 
        '<tr id="items_row">'
        .'    <td class="formDescription"  valign="top" style="width: 180px;"><label for="item1">'
              .$i18n->get("items label").'</label><div class="wg-hoverhelp">'.$i18n->get("items description").'</div></td>'
        .'    <td id="items_td" valign="top" class="tableData">'
        .'    <input type="button" value="Add item" onClick="javascript:addItem()"></input><br />'
        ."    <br />\n";

    $tabform->getTab("properties")->raw($tableRowStart);

    if($self->getValue('items')){
        my @items = @{JSON->new->decode($self->getValue('items'))->{items}};

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
            $tabform->getTab("properties")->raw($itemHTML);
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
        $tabform->getTab("properties")->raw($itemHTML);
    }
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
    my (@items,$items);
    $self->SUPER::processPropertiesFromFormPost(@_);

    foreach my $param ($form->param) {
        if ($param =~ m/^item_/){
            my $sequenceNumber = $param;
            $sequenceNumber =~ s/^item_//;
            if($form->process('itemId_'.$sequenceNumber)){
            push(@items,{
                sequenceNumber  => $sequenceNumber,
                text            => $form->process($param),
                itemId              => $form->process('itemId_'.$sequenceNumber),
            });
            }
        }
    }
    
    my  @sortedItems = sort { $a->{sequenceNumber} cmp $b->{sequenceNumber} } @items;
    @items = ();
    for (my $i=0; $i<scalar @sortedItems; $i++) {
        $sortedItems[$i]->{sequenceNumber} = $i + 1;
        push(@items,$sortedItems[$i]);
    }        
   
    $items = JSON->new->encode({items => \@items});
    $self->update({items => $items});
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
