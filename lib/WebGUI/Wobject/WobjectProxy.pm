package WebGUI::Wobject::WobjectProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Page;
use WebGUI::TabForm;
use WebGUI::Template;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(3,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
	my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
                        proxiedWobjectId=>{
				fieldType=>"hidden"
				},
			proxiedNamespace=>{
				fieldType=>"hidden"
				},
			overrideTitle=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideTemplate=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideDisplayTitle=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideDescription=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			proxiedTemplateId=>{
				fieldType=>"template",
				defaultValue=>1
				}
                        }
                );
        bless $self, $class;
}


#-------------------------------------------------------------------
sub uiLevel {
        return 999;
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
        my $layout = WebGUI::HTMLForm->new;
	$properties->hidden(
		-name=>"proxiedNamespace",
		-value=>$_[0]->get("proxiedNamespace")
		);
	$properties->hidden(
		-name=>"proxiedWobjectId",
		-value=>$_[0]->get("proxiedWobjectId")
		);
	$layout->template(
		-name=>"proxiedTemplateId",
		-value=>$_[0]->getValue("proxiedTemplateId"),
		-namespace=>$_[0]->get("proxiedNamespace")
		);
	$properties->yesNo(
		-name=>"overrideTitle",
		-value=>$_[0]->getValue("overrideTitle"),
		-label=>WebGUI::International::get(7,$_[0]->get("namespace"))
		);
	$layout->yesNo(
		-name=>"overrideDisplayTitle",
		-value=>$_[0]->getValue("overrideDisplayTitle"),
		-label=>WebGUI::International::get(8,$_[0]->get("namespace"))
		);
	$properties->yesNo(
		-name=>"overrideDescription",
		-value=>$_[0]->getValue("overrideDescription"),
		-label=>WebGUI::International::get(9,$_[0]->get("namespace"))
		);
	$layout->yesNo(
		-name=>"overrideTemplate",
		-value=>$_[0]->getValue("overrideTemplate"),
		-label=>WebGUI::International::get(10,$_[0]->get("namespace"))
		);
	my @data = WebGUI::SQL->quickArray("select page.urlizedTitle,wobject.title from wobject left join page on wobject.pageId=page.pageId
		where wobject.wobjectId=".$_[0]->get("proxiedWobjectId"));
	$properties->readOnly(
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>'<a href="'.WebGUI::URL::gateway($data[0]).'">'.$data[1].'</a> ('.$_[0]->get("proxiedWobjectId").')'
		);
	return $_[0]->SUPER::www_edit(
                -properties=>$properties->printRowsOnly,
                -layout=>$layout->printRowsOnly,
                -headingId=>2,
                -helpId=>1
                );

}

#-------------------------------------------------------------------
sub www_view {
	return	WebGUI::International::get(4,$_[0]->get("namespace"));
}


1;

