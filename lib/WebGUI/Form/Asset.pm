package WebGUI::Form::Asset;

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
use base 'WebGUI::Form::Control';
use HTML::Entities;
use WebGUI::Asset;
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::Form::Text;

=head1 NAME

Package WebGUI::Form::Asset

=head1 DESCRIPTION

Creates an asset selector field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

The name of the field. Defaults to "asset".

=head4 class

Limits the list of selectable assets to a specific class, such as "WebGUI::Asset::Wobject::Article", specified by this parameter.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "Asset");
	push(@{$definition}, {
		label=>{
			defaultValue=>$i18n->get("asset"),
			},
		name=>{
			defaultValue=>"asset",
			},
		class=>{
			defaultValue=> undef
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Asset')->get('asset');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a link.

=cut

sub getValueAsHtml {
    my $self = shift;
#    my $asset = WebGUI::Asset->newById($self->session,$self->getDefaultValue);
    my $asset = WebGUI::Asset->newById($self->session,$self->getOriginalValue);
    if (defined $asset) {
        return '<a href="'.$asset->getUrl.'">'.$asset->getTitle.'</a>';
    }
    return undef;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an asset selector.

=cut

sub toHtml {
	my $self = shift;
    my $asset = $self->getOriginalValue ? WebGUI::Asset->newById($self->session, $self->getOriginalValue) : WebGUI::Asset->getRoot($self->session); 
	my $url = $asset->getUrl("op=formHelper;sub=assetTree;class=Asset;formId=".$self->get('id'));
	$url .= ";classLimiter=".$self->get("class") if ($self->get("class"));
        return WebGUI::Form::Hidden->new($self->session,
                        name=>$self->get("name"),
                        extras=>$self->get("extras"),
                        value=>$asset->getId,
			id=>$self->get("id"),
                        )->toHtml
                .WebGUI::Form::Text->new($self->session,
                        name=>$self->get("name")."_display",
                        extras=>' readonly="1" ',
                        value=>$asset->get("title"),
			id=>$self->get('id')."_display"
                        )->toHtml
                .WebGUI::Form::Button->new($self->session,
                        value=>"...",
                        extras=>'onclick="window.open(\''.$url.'\',\'assetPicker\',\'scrollbars=yes, toolbar=no, location=no, status=no, directories=no, width=400, height=400\');"'
                        )->toHtml;
}

#-------------------------------------------------------------------

=head2 www_assetTree ( session )

Returns a list of the all the current Asset's children as form.  The children can be filtered via the
form variable C<classLimiter>.  A crumb trail is provided for navigation.

=cut

sub www_assetTree {
	my $session = shift;
	$session->response->setCacheControl("none");
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestorIter = $base->getLineageIterator(["self","ancestors"]);
        while ( 1 ) {
            my $ancestor;
            eval { $ancestor = $ancestorIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $session->log->error($x->full_message);
                next;
            }
            last unless $ancestor;
		my $url = $ancestor->getUrl("op=formHelper;sub=assetTree;class=Asset;formId=".$session->form->process("formId"));
		$url .= ";classLimiter=".$session->form->process("classLimiter","className") if ($session->form->process("classLimiter","className"));
		push(@crumb,'<a href="'.$url.'" class="crumb">'.$ancestor->get("menuTitle").'</a>');
	}
	my $output = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
		.base {
        		font-family:  "Lucida Grande", "Lucida Sans Unicode", Tahoma, Verdana, Arial, sans-serif;
			font-size: 12px;
		}
		a {
        		color: #0f3ccc;
        		text-decoration: none;
		}
		a:hover {
			color: #000080;
			text-decoration: underline;	
		}
		.selectLink {
			color: #cc7700;
		}
		.crumb {
			color: orange;
		}
		.crumbTrail {
			padding: 3px;
			background-color: #eeeeee;
			-moz-border-radius: 10px;
		}
		.traverse {
			font-size: 15px;
		}
		</style></head><body>
		<div class="base">
		<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n";
	my $childIter = $base->getLineageIterator(["children","self"]);
	my $i18n = WebGUI::International->new($session);
	my $limit = $session->form->process("classLimiter","className");
        while ( 1 ) {
            my $child;
            eval { $child = $childIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $session->log->error($x->full_message);
                next;
            }
            last unless $child;
		next unless $child->canView;
		if ($limit eq "" || $child->get("className") =~ /^$limit/) {
            my $tempChild = $child->get("title");
            $tempChild =~ s/(\'|\")/\\$1/g;
			$output .= '<a href="#" class="selectLink" onclick="window.opener.document.getElementById(\''.$session->form->process("formId")
				.'\').value=\''.$child->getId.'\';window.opener.document.getElementById(\''.
				$session->form->process("formId").'_display\').value=\''.encode_entities($tempChild).'\';window.close();">['.$i18n->get("select").']</a> ';
		} else {
			$output .= '['.$i18n->get("select").'] ';
		}
		my $url = $child->getUrl("op=formHelper;sub=assetTree;class=Asset;formId=".$session->form->process("formId"));
		$url .= ";classLimiter=".$session->form->process("classLimiter","className") if ($session->form->process("classLimiter","className"));
		$output .= '<a href="'.$url.'" class="traverse">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$output .= '</div></body></html>';
	$session->style->useEmptyStyle("1");
	return $output;
}


1;

