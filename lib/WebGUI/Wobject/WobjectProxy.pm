package WebGUI::Wobject::WobjectProxy;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::MetaData;

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
		-useMetaData=>undef,	# NO MetaData for wobject proxy
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
				},
			proxyByCriteria=>{
				fieldType=>"yesNo",
				defaultValue=>0,
				},
			resolveMultiples=>{
				fieldType=>"selectList",
				defaultValue=>"mostRecent",
				},
			proxyCriteria=>{
				fieldType=>"textarea",
				defaultValue=>"",
				},
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
		where wobject.wobjectId=".quote($_[0]->get("proxiedWobjectId")));
	$properties->readOnly(
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>'<a href="'.WebGUI::URL::gateway($data[0]).'">'.$data[1].'</a> ('.$_[0]->get("proxiedWobjectId").')'
		);
	if($session{setting}{metaDataEnabled}) {
		$properties->yesNo(
			-name=>"proxyByCriteria",
			-value=>$_[0]->getValue("proxyByCriteria"),
			-label=>WebGUI::International::get("Proxy by alternate criteria?",$_[0]->get("namespace")),
			-extras=>q|Onchange="
				if (this.form.proxyByCriteria[0].checked) { 
 					this.form.resolveMultiples.disabled=false;
					this.form.proxyCriteria.disabled=false;
				} else {
 					this.form.resolveMultiples.disabled=true;
					this.form.proxyCriteria.disabled=true;
				}"|
                );
		if ($_[0]->getValue("proxyByCriteria") == 0) {
			$_[0]->{_disabled} = 'disabled=true';
		}
		$properties->selectList(
			-name=>"resolveMultiples",
			-value=>[ $_[0]->getValue("resolveMultiples") ],
			-label=>WebGUI::International::get("Resolve Multiples?",$_[0]->get("namespace")),
			-options=>{
				mostRecent=>WebGUI::International::get("Most Recent",$_[0]->get("namespace")),
				random=>WebGUI::International::get("Random",$_[0]->get("namespace")),
			},
			-extras=>$_[0]->{_disabled}
		);

		 $properties->readOnly(
        		-value=>$_[0]->_drawQueryBuilder(),
		        -label=>WebGUI::International::get("Criteria",$_[0]->get("namespace")),
	        );
	}
	return $_[0]->SUPER::www_edit(
                -properties=>$properties->printRowsOnly,
                -layout=>$layout->printRowsOnly,
                -headingId=>2,
                -helpId=>"wobject proxy add/edit"
                );
}

#-------------------------------------------------------------------
sub www_editSave {
        $_[0]->SUPER::www_editSave();	# This will do the priv check as well.
	my $scratchId = "WobjectProxy_" . $_[0]->get("wobjectId");
	WebGUI::Session::deleteAllScratch($scratchId);
        return "";
}

#-------------------------------------------------------------------
sub _drawQueryBuilder {
	# Initialize operators
	my @textFields = qw|text yesNo selectList radioList|;
	my %operator;
	foreach (@textFields) {
		$operator{$_} = {
				"=" => WebGUI::International::get("is",$_[0]->get("namespace")),
				"!=" => WebGUI::International::get("isnt",$_[0]->get("namespace"))
			};
	}
	$operator{integer} = {
				"=" => WebGUI::International::get("equal to",$_[0]->get("namespace")),
                                "!=" => WebGUI::International::get("not equal to",$_[0]->get("namespace")),
				"<" => WebGUI::International::get("less than",$_[0]->get("namespace")),
				">" => WebGUI::International::get("greater than",$_[0]->get("namespace"))
			};

	# Get the fields and count them	
	my $fields = WebGUI::MetaData::getMetaDataFields();
	my $fieldCount = scalar(keys %$fields);
	
	unless ($fieldCount) {	# No fields found....
		return 'No metadata defined yet.
			<a href="'.WebGUI::URL::page('op=manageMetaData').
			'">Click here</a> to define metadata attributes.';
	}

	# Static form fields
	my $proxyCriteriaField = WebGUI::Form::textarea({
	                	        name=>"proxyCriteria",
        	                	value=>$_[0]->getValue("proxyCriteria"),
					extras=>'style="width: 100%" '.$_[0]->{_disabled}
                	        });
	my $conjunctionField = WebGUI::Form::selectList({
					name=>"conjunction",
					options=>{
						"AND" => WebGUI::International::get("AND",$_[0]->get("namespace")),
						"OR" => WebGUI::International::get("OR",$_[0]->get("namespace"))},
					value=>["OR"],
					extras=>'class="qbselect"',
				});
	
	# html
	my $output;
	$output .= '<script type="text/javascript" language="javascript" src="'.
		$session{config}{extrasURL}.'/wobject/WobjectProxy/querybuilder.js"></script>';
	$output .= '<link href="'.$session{config}{extrasURL}.
			'/wobject/WobjectProxy/querybuilder.css" type="text/css" rel="stylesheet">';

	$output .= qq|<table cellspacing="0" cellpadding=0 border=0 >
			  <tr>
			    <td colspan="5" align="right">$proxyCriteriaField</td>
			  </tr>
			  <tr>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td class="qbtdright">
			    </td>
			  </tr>
			  <tr>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td class="qbtdright">
				$conjunctionField
			    </td>
			  </tr>
	|;

	# Here starts the field loop
	foreach my $field (keys %$fields) {
		my $fieldLabel = $fields->{$field}{fieldName};
		my $fieldType = $fields->{$field}{fieldType} || "text";

		# The operator select field
		my $opFieldName = "op_field".$fields->{$field}{fieldId};
		my $opField = WebGUI::Form::selectList({
						name=>$opFieldName,
						uiLevel=>5,
						options=>$operator{$fieldType},
						extras=>'class="qbselect"'
					});	
		# The value select field
		my $valFieldName = "val_field".$fields->{$field}{fieldId};
		my $valueField = WebGUI::Form::dynamicField($fieldType, {
                                                name=>$valFieldName,
                                                uiLevel=>5,
                                                extras=>qq/title="$fields->{$field}{description}" class="qbselect"/,
                                                possibleValues=>$fields->{$field}{possibleValues},
					});
		# An empty row
		$output .= qq|
                          <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td class="qbtdright"></td>
                          </tr>
			|;
		
		# Table row with field info
		$output .= qq|
			  <tr>
			    <td class="qbtdleft"><p class="qbfieldLabel">$fieldLabel</p></td>
			    <td class="qbtd">
				$opField
			    </td>
			    <td class="qbtd">
				<span class="qbText">$valueField</span>
			    </td>
			    <td class="qbtd"></td>
			    <td class="qbtdright">
				<input class="qbButton" type=button value=Add onclick="addCriteria('$fieldLabel', this.form.$opFieldName, this.form.$valFieldName)"></td>
			  </tr>
			|;
	}
	# Close the table
	$output .= "</table>";

	return $output;
}

#-------------------------------------------------------------------
sub www_view {
	return	WebGUI::International::get(4,$_[0]->get("namespace"));
}


1;

