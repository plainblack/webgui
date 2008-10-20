package WebGUI::Asset::Wobject::Matrix;

$VERSION = "2.0.0";

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
use warnings;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

#----------------------------------------------------------------------------

=head2 canAddMatrixListing (  )

Returns true if able to add MatrixListings. 

 Checks to make sure that the 
 Calendar has been committed at least once. Checks to make sure that
 the user is in the appropriate group (either the group that can edit
 the calendar, or the group that can edit events in the calendar).

=cut

sub canAddMatrixListing {
    my $self    = shift;

    return 1;
=cut
    my $userId  = shift;

    my $user    = $userId
                ? WebGUI::User->new( $self->session, $userId )
                : $self->session->user
                ;

    return 1 if (
        $user->isInGroup( $self->get("groupIdEventEdit") )
    );
=cut
}

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for Matrix instances. 

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'Asset_Matrix');

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		templateId =>{
			fieldType       =>"template",  
			defaultValue    =>'matrixtmpl000000000001',
			tab             =>"display",
			#www_editSave will ignore anyone's attempts to update this field if this is set to 1
			noFormPost      =>0,  
			#This is an option specific to the template fieldType.
			namespace       =>"Matrix", 
			hoverHelp       =>$i18n->get('template description'),
			label           =>$i18n->get('template label'),
		},
        searchTemplateId=>{
            defaultValue    =>"matrixtmpl000000000005",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Search",
            hoverHelp       =>$i18n->get('search template description'),
            label           =>$i18n->get('search template label'),
        },
        detailTemplateId=>{
            defaultValue    =>"matrixtmpl000000000003",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Detail",
            hoverHelp       =>$i18n->get('detail template description'),
            label           =>$i18n->get('detail template label'),
        },
        ratingDetailTemplateId=>{
            defaultValue    =>"matrixtmpl000000000004",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/RatingDetail",
            hoverHelp       =>$i18n->get('rating detail template description'),
            label           =>$i18n->get('rating detail template label'),
        },
        compareTemplateId=>{
            defaultValue    =>"matrixtmpl000000000002",
            fieldType       =>"template",
            tab             =>"display",
            namespace       =>"Matrix/Compare",
            hoverHelp       =>$i18n->get('compare template description'),
            label           =>$i18n->get('compare template label'),
        },
        defaultSort=>{
            fieldType       =>"selectBox",
            tab             =>"display",
            options         =>{ 
                                score           => $i18n->get('sort by score label'),
                                alphaNumeric    => $i18n->get('sort alpha numeric label'),
                                assetRank       => $i18n->get('sort by asset rank label'),
                                lastUpdated     => $i18n->get('sort by last updated label'),
                              },
            defaultValue    =>"score",
            hoverHelp       =>$i18n->get('default sort description'),
            label           =>$i18n->get('default sort label'),
        },
        compareColorNo=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffaaaa",
            hoverHelp       =>$i18n->get('compare color no description'),
            label           =>$i18n->get('compare color no label'),
        },
        compareColorLimited=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color limited description'),
            label           =>$i18n->get('compare color limited label'),
        },
        compareColorCostsExtra=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color costs extra description'),
            label           =>$i18n->get('compare color costs extra label'),
        },
        compareColorFreeAddOn=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#ffffaa",
            hoverHelp       =>$i18n->get('compare color free add on description'),
            label           =>$i18n->get('compare color free add on label'),
        },
        compareColorYes=>{
            fieldType       =>"color",
            tab             =>"display",
            defaultValue    =>"#aaffaa",
            hoverHelp       =>$i18n->get('compare color yes description'),
            label           =>$i18n->get('compare color yes label'),
        },
        categories=>{
            fieldType       =>"textarea",
            tab             =>"properties",
            defaultValue    =>$i18n->get('categories default value'),
            hoverHelp       =>$i18n->get('categories description'),
            label           =>$i18n->get('categories label'),
            subtext         =>$i18n->get('categories subtext'),
        },
        maxComparisons=>{
            fieldType       =>"integer",
            tab             =>"properties",
            defaultValue    =>25,
            hoverHelp       =>$i18n->get('max comparisons description'),       
            label           =>$i18n->get('max comparisons label'),
        },
        maxComparisonsPrivileged=>{
            fieldType       =>"integer",
            tab             =>"properties",
            defaultValue    =>10,
            hoverHelp       =>$i18n->get('max comparisons privileged description'),
            label           =>$i18n->get('max comparisons privileged label'),
        },
        submissionApprovalWorkflowId=>{
            fieldType       =>"workflow",
            tab             =>"security",
            type            =>'WebGUI::VersionTag',
            defaultValue    =>"pbworkflow000000000003",
            hoverHelp       =>$i18n->get('submission approval workflow description'),
            label           =>$i18n->get('submission approval workflow label'),
        },
        ratingsDuration=>{
            fieldType       =>"interval",
            tab             =>"properties",
            defaultValue    =>7776000, # 3 months 3*30*24*60*60
            hoverHelp       =>$i18n->get('ratings duration description'),
            label           =>$i18n->get('ratings duration label'),
        },
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'matrix.gif',
		autoGenerateForms=>1,
		tableName=>'Matrix',
		className=>'WebGUI::Asset::Wobject::Matrix',
		properties=>\%properties
		});
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 deleteAttribute ( attributeId )

Deletes an attribute and listing data for this attribute from Collateral.

=head3 attributeId

The id of the attribute that should be deleted.

=cut

sub deleteAttribute {

    my $self = shift;
    my $attributeId = shift;

    $self->deleteCollateral("Matrix_attribute","attributeId",$attributeId);
    #TODO: delete listing data, $self->deleteCollateral("Matrix_listingData","attributeId",$attributeId);

    return undef;
}

#-------------------------------------------------------------------

=head2 duplicate ( )

duplicates a Matrix. 

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	return $newAsset;
}

#-------------------------------------------------------------------

=head2 editAttributeSave ( attributeProperties  )

Saves an attribute. 

=head3 attributeProperties

A hashref containing the properties of the attribute.

=cut

sub editAttributeSave {
    my $self                = shift;
    my $attributeProperties = shift;
    my $session             = $self->session;
    my $form                = $session->form;

    return $session->privilege->insufficient() unless $self->canEdit;

    my $attributeId = $self->setCollateral("Matrix_attribute","attributeId",$attributeProperties,0,1);

    return $attributeId;
}

#-------------------------------------------------------------------

=head2 getAttribute  ( attributeId )

Returns a hash reference of the properties of an attribute.

=head3 attributeId

The unique id of an attribute.

=cut

sub getAttribute {
    my ($self, $attributeId) = @_;
    return $self->session->db->quickHashRef("select * from Matrix_attribute where attributeId=?",[$attributeId]);
}

#-------------------------------------------------------------------

=head2 getCategories  (  )

Returns the categories for this Matrix as a hashref.

=cut

sub getCategories {
    my $self = shift;
    my %categories;
    tie %categories, 'Tie::IxHash';
    my $categories = $self->getValue("categories");
    $categories =~ s/\r//g;
    chomp($categories);
    my @categories = split(/\n/,$categories);
    foreach my $category (@categories) {
        $categories{$category} = $category;
    }
    return \%categories;

}


#-------------------------------------------------------------------

=head2 getEditForm ( )

returns the tabform object that will be used in generating the edit page for Matrix.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
=cut
	$tabform->getTab("display")->template(
		-value=>$self->getValue("templateId"),
		-label=>WebGUI::International::get("template_label","Asset_Matrix"),
		-namespace=>"Matrix"
	);
=cut	
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
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purge ( )

removes collateral data associated with a Matrix when the system
purges it's data.  

=cut

sub purge {
	my $self = shift;
	#purge your wobject-specific data here.  This does not include fields 
	# you create for your Matrix asset/wobject table.
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

	#This automatically creates template variables for all of your wobject's properties.
	my $var = $self->get;
	
	#This is an example of debugging code to help you diagnose problems.
	#WebGUI::ErrorHandler::warn($self->get("templateId")); 
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_deleteAttribute ( )

Deletes an Attribute, including listing data for this attribute.

=cut

sub www_deleteAttribute {
    my $self = shift;
    my $attributeId = $self->session->form->process("attributeId");
    return $self->session->privilege->insufficient() unless $self->canEdit;

    $self->deleteAttribute($attributeId);

    return $self->www_listAttributes;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  This method is entirely
optional.  Take it out unless you specifically want to set a submenu in your
adminConsole views.

=cut

#sub www_edit {
#   my $self = shift;
#   return $self->session->privilege->insufficient() unless $self->canEdit;
#   return $self->session->privilege->locked() unless $self->canEditIfLocked;
#   my $i18n = WebGUI::International->new($self->session, "Asset_Matrix");
#   return $self->getAdminConsole->render($self->getEditForm->print, $i18n->get("edit title"));
#}

#-------------------------------------------------------------------

=head2 www_editAttribute ( )

Shows a form to edit or add an attribute. 

=cut

sub www_editAttribute {
    my $self = shift;
    my $session = $self->session;
    my ($attributeId, $attribute);
    
    return $session->privilege->insufficient() unless $self->canEdit;
    my $i18n = WebGUI::International->new($session, "Asset_Matrix");

    $attributeId = $session->form->process("attributeId") || 'new';

    unless($attributeId eq 'new'){
        $attribute = $self->getAttribute($attributeId); 
    }

    my $form = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $form->hidden(
        -name       =>"func",
        -value      =>"editAttributeSave"
        );
    $form->hidden(
        -name       =>"attributeId",
        -value      =>$attributeId,
        );
    $form->text(
        -name       =>"name",
        -value      =>$attribute->{name},
        -label      =>$i18n->get('attribute name label'),
        -hoverHelp  =>$i18n->get('attribute name description'),
        );
    $form->textarea(
        -name       =>"description",
        -value      =>$attribute->{description},    
        -label      =>$i18n->get('attribute description label'),
        -hoverHelp  =>$i18n->get('attribute description description'),
        );
    $form->matrixFieldType(
        -name       =>"fieldType",
        -value      =>$attribute->{fieldType},
        -label      =>$i18n->get('fieldType label'),
        -hoverHelp  =>$i18n->get('fieldType description'),
        );
    my $defaultValueForm = WebGUI::Form::Text($self->session, {
                name=>"defaultValue",
                value=>$attribute->{defaultValue},
                #subtext=>'<br />'.$i18n->get('default value subtext'),
                #width=>200,
                #height=>60,
                resizable=>0,
            });
    my $optionsForm = WebGUI::Form::Textarea($self->session, {
                name=>"options",
                value=>$attribute->{options},
                });

    my $html =  "\n<tr><td colspan='2'>\n";
    $html .=    "\t<div id='optionsAndDefaultValue_module'>\n";
    $html .=    "\t<div class='bd' style='padding:0px;'>\n";
    $html .=    "\t<table cellpadding='0' cellspacing='0' style='width: 100%;'>\n";

    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>"
                .$i18n->get('attribute defaultValue label')
                ."<div class='wg-hoverhelp'>".$i18n->get('attribute defaultValue description')."</div></td>"
                ."<td valign='top' class='tableData' style='padding-left:4px'>"
                .$defaultValueForm."</td>"
                ."\t\n</tr>\n";

    $html .=    "\t<tr><td class='formDescription' valign='top' style='width:180px'>"
                .$i18n->get('attribute options label')
                ."<div class='wg-hoverhelp'>".$i18n->get('attribute options description')."</div></td>"
                ."<td valign='top' class='tableData' style='padding-left:4px'>"
                .$optionsForm."</td>"
                ."\t\n</tr>\n";


    $html .=    "\t</table>";
    $html .=    "\t\n</div>\t\n</div>\n";
    $html .=    "</td></tr>";

    $html .=    "<script type='text/javascript'>\n"
                ."var optionsAndDefaultValue_module = new YAHOO.widget.Module('optionsAndDefaultValue_module',"
                ."{visible:false});\n"
                ."optionsAndDefaultValue_module.render();\n"
                ."YAHOO.util.Event.onContentReady('fieldType_formId', checkFieldType);\n"
                ."YAHOO.util.Event.addListener('fieldType_formId', 'change', checkFieldType);\n"
                ."var hasOptions = {'SelectBox': true,'Combo': true};\n"
                ."function checkFieldType(){\n"
                ."  if (this.value in hasOptions){\n"
                ."      optionsAndDefaultValue_module.show();\n"
                ."  }else{\n"
                ."      optionsAndDefaultValue_module.hide();\n"
                ."  }\n"
                ."}\n"
                ."</script>\n";

    $form->raw($html);
=cut
    $form->text(
        -name       =>"defaultValue",
        -value      =>$attribute->{defaultValue},
        -label      =>$i18n->get('attribute defaultValue label'),
        -hoverHelp  =>$i18n->get('attribute defaultValue description'),
        );
    $form->textarea(
        -name       =>"options",
        -value      =>$attribute->{options},
        -label      =>$i18n->get('attribute options label'),
        -hoverHelp  =>$i18n->get('attribute options description'),
        );    
=cut
    $form->selectBox(
        -name       =>"category",
        -value      =>[$attribute->{category}],
        -label      =>$i18n->get('category label'),
        -hoverHelp  =>$i18n->get('category description'),
        -options    =>$self->getCategories,
        );
    $form->submit;
    return $self->getAdminConsole->render($form->print, $i18n->get('edit attribute title'));
}

#-------------------------------------------------------------------

=head2 www_editAttributeSave ( )

Processes and saves an attribute. 

=cut

sub www_editAttributeSave {
    my $self                = shift;
    my $session             = $self->session;
    my $form                = $session->form;
    
    return $session->privilege->insufficient() unless $self->canEdit;

    my $attributeProperties = {
        attributeId     =>$form->process("attributeId") || 'new',
        assetId         =>$self->getId,
        name            =>$form->process('name'),
        description     =>$form->process('description'),
        fieldType       =>$form->process('fieldType'),
        options         =>$form->process('options'),
        defaultValue    =>$form->process('defaultValue'),
        category        =>$form->process('category'),
   };
    
    $self->editAttributeSave($attributeProperties);

    return $self->www_listAttributes;
}

#-------------------------------------------------------------------

=head2 www_listAttributes ( )

Lists all attributes of this Matrix. 

=cut

sub www_listAttributes {
    my $self    = shift;
    my $session = $self->session;
    
    return $session->privilege->insufficient() unless($self->canEdit);
    
    my $i18n = WebGUI::International->new($session,'Asset_Matrix');
    my $output = "<br /><a href='".$self->getUrl("func=editAttribute;attributeId=new")."'>"
                .$i18n->get('add attribute label')."</a><br /><br />";
    
    my $attributes = $session->db->read("select attributeId, name from Matrix_attribute where assetId=? order by name"
        ,[$self->getId]);
    while (my $attribute = $attributes->hashRef) {
        $output .= $session->icon->delete("func=deleteAttribute;attributeId=".$attribute->{attributeId}
            , $self->getUrl,$i18n->get("delete attribute confirm message"))
            .$session->icon->edit("func=editAttribute;attributeId=".$attribute->{attributeId})
            .' '.$attribute->{name}."<br />\n";
    }
    return $self->getAdminConsole->render($output, $i18n->get('list attributes title'));
}

#-------------------------------------------------------------------
# Everything below here is to make it easier to install your custom
# wobject, but has nothing to do with wobjects in general
#-------------------------------------------------------------------
# cd /data/WebGUI/lib
# perl -MWebGUI::Asset::Wobject::Matrix -e install www.example.com.conf [ /path/to/WebGUI ]
# 	- or -
# perl -MWebGUI::Asset::Wobject::Matrix -e uninstall www.example.com.conf [ /path/to/WebGUI ]
#-------------------------------------------------------------------


use base 'Exporter';
our @EXPORT = qw(install uninstall);
use WebGUI::Session;

#-------------------------------------------------------------------
sub install {
	my $config = $ARGV[0];
	my $home = $ARGV[1] || "/data/WebGUI";
	die "usage: perl -MWebGUI::Asset::Wobject::Matrix -e install www.example.com.conf\n" unless ($home && $config);
	print "Installing asset.\n";
	my $session = WebGUI::Session->open($home, $config);
	$session->config->addToArray("assets","WebGUI::Asset::Wobject::Matrix");
	$session->db->write("create table Matrix (
		assetId                     varchar(22) binary not null,
		revisionDate                bigint      not null,
        templateId                  varchar(22) not null,
        searchTemplateId            varchar(22) not null,
        compareTemplateId           varchar(22) not null,
        detailTemplateId            varchar(22) not null,
        maxComparisons              int(11)     not null default 10,
        maxComparisonsPrivileged    int(11)     not null default 25,
        defaultSort                 varchar(22) not null default 'score',
        categories                  text,
        compareColorNo                  varchar(22) not null default '#ffaaaa',
        compareColorLimited             varchar(22) not null default '#ffffaa',
        compareColorCostsExtra          varchar(22) not null default '#ffffaa',
        compareColorFreeAddOn           varchar(22) not null default '#ffffaa',
        compareColorYes                 varchar(22) not null default '#aaffaa',
        submissionApprovalWorkflowId    varchar(22) not null,
        ratingsDuration                 int(11)     not null default 7776000,
        primary key (assetId, revisionDate)
		)");
    $session->db->write("create table Matrix_attribute (
        assetId             varchar(22)     binary not null,
        attributeId         varchar(22)     binary not null,
        name                varchar(255)    not null,
        description         text,
        fieldType           varchar(255)    not null default 'MatrixField',
        category            varchar(22)     not null,
        options             text,
        defaultValue        varchar(255),
        primary key (attributeId)
    )");
	$session->var->end;
	$session->close;
	print "Done. Please restart Apache.\n";
}

#-------------------------------------------------------------------
sub uninstall {
	my $config = $ARGV[0];
	my $home = $ARGV[1] || "/data/WebGUI";
	die "usage: perl -MWebGUI::Asset::Wobject::Matrix -e uninstall www.example.com.conf\n" unless ($home && $config);
	print "Uninstalling asset.\n";
	my $session = WebGUI::Session->open($home, $config);
	$session->config->deleteFromArray("assets","WebGUI::Asset::Wobject::Matrix");
	my $rs = $session->db->read("select assetId from asset where className='WebGUI::Asset::Wobject::Matrix'");
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Wobject::Matrix");
		$asset->purge if defined $asset;
	}
	$session->db->write("drop table Matrix");
	$session->var->end;
	$session->close;
	print "Done. Please restart Apache.\n";
}


1;
