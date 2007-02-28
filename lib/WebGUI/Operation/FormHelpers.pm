package WebGUI::Operation::FormHelpers;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Form::Group;
use WebGUI::HTMLForm;
use WebGUI::Storage::Image;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Operation::FormHelpers

=head1 DESCRIPTION

Operational support for various things relating to forms and rich editors.

=cut

#-------------------------------------------------------------------

=head2 www_formAssetTree ( session )

Returns a list of the all the current Asset's children as form.  The children can be filtered via the
form variable C<classLimiter>.  A crumb trail is provided for navigation.

=cut

sub www_formAssetTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		my $url = $ancestor->getUrl("op=formAssetTree;formId=".$session->form->process("formId"));
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
	my $children = $base->getLineage(["children","self"],{returnObjects=>1});
	my $i18n = WebGUI::International->new($session);
	my $limit = $session->form->process("classLimiter","className");
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($limit eq "" || $child->get("className") =~ /^$limit/) {
			$output .= '<a href="#" class="selectLink" onclick="window.opener.document.getElementById(\''.$session->form->process("formId")
				.'\').value=\''.$child->getId.'\';window.opener.document.getElementById(\''.
				$session->form->process("formId").'_display\').value=\''.$child->get("title").'\';window.close();">['.$i18n->get("select").']</a> ';
		} else {
			$output .= '['.$i18n->get("select").'] ';
		}
		my $url = $child->getUrl("op=formAssetTree;formId=".$session->form->process("formId"));
		$url .= ";classLimiter=".$session->form->process("classLimiter","className") if ($session->form->process("classLimiter","className"));
		$output .= '<a href="'.$url.'" class="traverse">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$output .= '</div></body></html>';
	$session->style->useEmptyStyle("1");
	return $output;
}

#-------------------------------------------------------------------

=head2 www_richEditPageTree ( session )

Asset picker for the rich editor.

=cut

sub www_richEditPageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	$session->style->setRawHeadTags(q|<style type="text/css">
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
                </style>
		|);
	$session->style->setScript($session->url->extras('tinymce2/jscripts/tiny_mce/tiny_mce_popup.js'),{type=>"text/javascript"});
	my $i18n = WebGUI::International->new($session);
	my $f = WebGUI::HTMLForm->new($session,-action=>"#");
	$f->text(
		-name=>"url",
		-label=>$i18n->get(104),
		-hoverHelp=>$i18n->get('104 description'),
		);
	my %options = ();
	tie %options, 'Tie::IxHash';
	%options = ("_self"=>$i18n->get('link in same window'),
		           "_blank"=>$i18n->get('link in new window'));
	$f->selectBox(
		-name=>"target",
		-label=>$i18n->get('target'),
		-hoverHelp=>$i18n->get('target description'),
		-options=>\%options
		);
	$f->button(
		-name=>"button",
		-value=>$i18n->get('done'),
		-extras=>'onclick="createLink()"'
		);
	my $output = ' <fieldset><legend>'.$i18n->get('insert a link').'</legend>'.$f->print.'</fieldset>'.<<"JS"
	<script type="text/javascript">
//<![CDATA[
function createLink() {
    if (window.opener) {        
        if (document.getElementById("url_formId").value == "") {
           alert("@{[$i18n->get("link enter alert")]}");
           document.getElementById("url_formId").focus();
        }
	var link = '<a href="'+"^" + "/(" + document.getElementById("url_formId").value+');"';
        var target = document.getElementById('target_formId').value;
        if (target != '_self') link += ' target="' + target + '"';
	link += '>' + window.opener.tinyMCE.selectedInstance.selection.getSelectedHTML() + '</a>';
	window.opener.tinyMCE.execCommand("mceInsertContent",false,link);
     window.close();
    }
}
//]]>
</script>
JS
	.'<fieldset><legend>'.$i18n->get('pages').'</legend> ';
	$output .= '<div class="base">';
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a href="'.$ancestor->getUrl("op=richEditPageTree").'" class="crumb">'.$ancestor->get("menuTitle").'</a>');
	}	
	$output .= '<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n";
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		$output .= '<a href="#" class="selectLink" onclick="document.getElementById(\'url_formId\').value=\''.$child->get("url").'\'">['.$i18n->get("select").']</a> <a href="'.$child->getUrl("op=richEditPageTree").'" class="traverse">'.$child->get("menuTitle").'</a>'."<br />\n";	
	}
	$output .= '</div></fieldset>';
	return $session->style->process($output, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditImageTree ( session )

Similar to www_formAssetTree, except it is limited to only display assets of class WebGUI::Asset::File::Image.
Each link display a thumbnail of the image via www_richEditViewThumbnail.

=cut

sub www_richEditImageTree {
	my $session = shift;
	$session->http->setCacheControl("none");
	$session->style->setRawHeadTags(q| <style type="text/css">
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
                </style>|);
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	my @crumb;
	my $ancestors = $base->getLineage(["self","ancestors"],{returnObjects=>1});
	my $media;
	my @output;
	push(@output, '<div class="base">');
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	foreach my $ancestor (@{$ancestors}) {
		push(@crumb,'<a class="crumb" href="'.$ancestor->getUrl("op=richEditImageTree").'">'.$ancestor->get("menuTitle").'</a>');
		# check if we are in (a subdirectory of) Media
		if ($ancestor->get('assetId') eq 'PBasset000000000000003') {
			$media = $ancestor;
		}
	}	
	if ($media) {
		# if in (a subdirectory of) Media, give user the ability to create folders or upload images
		push(@output, '<p>[ <a href="');
		push(@output, $base->getUrl('op=richEditAddFolder'));
		push(@output, '">'.$i18n->get('Create new folder').'</a> ] &nbsp; [ <a href="');
		push(@output, $base->getUrl('op=richEditAddImage'));
		push(@output, '">'.$i18n->get('Upload new image').'</a> ]</p>');
	} else {
		$media = WebGUI::Asset->getMedia($session);
		# if not in Media, provide a direct link to it
		push(@output, '<p>[ <a href="'.$media->getUrl('op=richEditImageTree').'">'.$media->get('title').'</a> ]</p>');
	}
	push(@output, '<div class="crumbTrail">'.join(" &gt; ", @crumb)."</div><br />\n");
	my $children = $base->getLineage(["children"],{returnObjects=>1});
	foreach my $child (@{$children}) {
		next unless $child->canView;
		if ($child->get("className") =~ /^WebGUI::Asset::File::Image/) {
			push(@output, '<a class="selectLink" href="'.$child->getUrl("op=richEditViewThumbnail").'" target="viewer">['.$i18n->get("select","WebGUI").']</a> ');
		} else {
			push(@output, ' ['.$i18n->get("select","WebGUI")."] ");
		}
		push(@output, '<a class="traverse" href="'.$child->getUrl("op=richEditImageTree").'">'.$child->get("menuTitle").'</a>'."<br />\n");
	}
	push(@output, '</div>');
	return $session->style->process(join('', @output), 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditViewThumbnail ( session )

Displays a thumbnail of an Image Asset in the Image manager for the Rich Editor.  The current
URL in the session object is used to determine which Image is used.

=cut

sub www_richEditViewThumbnail {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $image = WebGUI::Asset->newByUrl($session);
	my $i18n = WebGUI::International->new($session);
	my $output;
	if ($image->get("className") =~ /WebGUI::Asset::File::Image/) {
		$output = '<div align="center">';
		$output .= '<img src="'.$image->getThumbnailUrl.'" style="border-style:none;" alt="'.$i18n->get('preview').'" />';
		$output .= '<br />';
		$output .= $image->get("filename");
		$output .= '</div>';
		$output .= '<script type="text/javascript">';
		$output .= "//<![CDATA[\n";
		if ( $session->config->get("richEditorsUseAssetUrls")) {
			$output .= "\nvar src = '".$image->getUrl."';\n";
		} else {
			$output .= "\nvar src = '".$image->getFileUrl."';\n";
		}
		$output .= "if(src.length > 0) {
				var manager=window.parent;
   				if(manager)		      	
		      		manager.document.getElementById('txtFileName').value = src;
    			}
                    //]]>
    		    </script>\n";
	} else {
		$output = '<div align="center"><img src="'.$session->url->extras('tinymce2/images/icon.gif').'" style="border-style:none;" alt="'.$i18n->get('image manager').'" /></div>';
	}
	return $session->style->process($output, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditAddFolder ( session )

Returns a form to add a folder using the rich editor. The purpose of this feature is to provide a very simple way for end-users to create a folder from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_richEditAddFolder {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'richEditAddFolderSave',
		);
	$f->text(
		label		=> $i18n->get('Folder name'),
		name		=> 'filename',
		);
	$f->submit(
		value		=> $i18n->get('Create'),
		);
	$f->button(
		value		=> $i18n->get('Cancel'),
		extras		=> 'onclick="history.go(-1);"',
		);
	my $html = '<h1>'.$i18n->get('Create new folder').'</h1>'.$f->print;
	return $session->style->process($html, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditAddFolderSave ( session )

Creates a directory under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_richEditAddFolderSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base url
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	# check if user can edit the current asset
	return $session->privilege->insufficient('bare') unless $base->canEdit;

	my $filename = $session->form->process('filename') || 'untitled';
	$base->addChild({
		# Asset properties
		title                    => $filename,
		menuTitle                => $filename,
		url                      => $base->getUrl.'/'.$filename,
		groupIdEdit              => $session->form->process('groupIdEdit') || $base->get('groupIdEdit'),
		groupIdView              => $session->form->process('groupIdView') || $base->get('groupIdView'),
		ownerUserId              => $session->user->userId,
		startDate                => $base->get('startDate'),
		endDate                  => $base->get('endDate'),
		encryptPage              => $base->get('encryptPage'),
		isHidden                 => 1,
		newWindow                => 0,

		# Asset/Wobject properties
		displayTitle             => 1,
		cacheTimeout             => $base->get('cacheTimeout'),
		cacheTimeoutVisitor      => $base->get('cacheTimeoutVisitor'),
		styleTemplateId          => $base->get('styleTemplateId'),
		printableStyleTemplateId => $base->get('printableStyleTemplateId'),

		# Asset/Wobject/Folder properties
		templateId               => 'PBtmpl0000000000000078',

		# Other properties
		#assetId                  => 'new',
		className                => 'WebGUI::Asset::Wobject::Folder',
		#filename                 => $filename,
		});
	$session->http->setRedirect($base->getUrl('op=richEditImageTree'));
	return "";
}

#-------------------------------------------------------------------

=head2 www_richEditAddImage ( session )

Returns a form to add an image using the rich editor. The purpose of this feature is to provide a very simple way for end-users to upload new images from within the rich editor, in stead of having to leave the rich editor and use the asset manager. A very minimal set of options is supplied, all other options should be derived from the current asset.

=cut

sub www_richEditAddImage {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, 'Operation_FormHelpers');
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name		=> 'op',
		value		=> 'richEditAddImageSave',
		);
	$f->image(
		label		=> $i18n->get('File'),
		name		=> 'filename',
		size		=> 10,
		);
	$f->submit(
		value		=> $i18n->get('Upload'),
		);
	$f->button(
		value		=> $i18n->get('Cancel'),
		extras		=> 'onclick="history.go(-1);"',
		);
	my $html = '<h1>'.$i18n->get('Upload new image').'</h1>'.$f->print;
	return $session->style->process($html, 'PBtmpl0000000000000137');
}

#-------------------------------------------------------------------

=head2 www_richEditAddImageSave ( session )

Creates an Image asset under the current asset. The filename should be specified in the form. The Edit and View rights from the current asset are used if not specified in the form. All other properties are copied from the current asset.

=cut

sub www_richEditAddImageSave {
	my $session = shift;
	$session->http->setCacheControl("none");
	# get base url
	my $base = WebGUI::Asset->newByUrl($session) || WebGUI::Asset->getRoot($session);
	#my $base = $session->asset;
	my $url = $base->getUrl;
	# check if user can edit the current asset
	return $session->privilege->insufficient('bare') unless $base->canEdit;

	#my $imageId = WebGUI::Form::Image->create($session);
	my $imageId = WebGUI::Form::Image->new($session,{name => 'filename'})->getValueFromPost;
    my $imageObj = WebGUI::Storage::Image->get($session, $imageId);
	##This is a hack.  It should use the WebGUI::Form::File API to insulate
	##us from future form name changes.
	my $filename = $imageObj->getFiles->[0];
	if ($filename) {
		$base->addChild({
			assetId     => 'new',
			className   => 'WebGUI::Asset::File::Image',
			storageId   => $imageObj->getId,
			filename    => $filename,
			title       => $filename,
			menuTitle   => $filename,
			templateId  => 'PBtmpl0000000000000088',
			url         => $url.'/'.$filename,
			groupIdEdit => $session->form->process('groupIdEdit') || $base->get('groupIdEdit'),
			groupIdView => $session->form->process('groupIdView') || $base->get('groupIdView'),
			ownerUserId => $session->var->get('userId'),
			isHidden    => 1,
			});
	}
	$session->http->setRedirect($url.'?op=richEditImageTree');
    $imageObj->delete;
	return "";
}

#-------------------------------------------------------------------

=head2 www_setupSalesTaxForm ( $session )

Create the AJAX form for displaying, adding and deleting sales tax information.

=cut

sub www_salesTaxTable {
	my $session = shift;

	my $returnTableOnly = 0;

	if ($session->form->process('addDelete') eq 'add') {
		my $state = $session->form->process('addStateId', 'selectBox');
		my $taxRate = $session->form->process('taxRate', 'float');
		my $commerceSalesTaxId = $session->id->generate();
		if ( $state and $taxRate ) {
			$session->db->write('insert into commerceSalesTax (commerceSalesTaxId,regionIdentifier,salesTax) VALUES (?,?,?)', [$commerceSalesTaxId, $state, $taxRate]);
		}
		$returnTableOnly = 1;
	}
	elsif ($session->form->process('addDelete') eq 'delete') {
		my $commerceSalesTaxId = $session->form->process('entryId');
		$session->db->write('delete from commerceSalesTax where commerceSalesTaxId=?',[$commerceSalesTaxId]);
		$returnTableOnly = 1;
	}

	my $existingData = $session->db->buildArrayRefOfHashRefs('select * from commerceSalesTax order by regionIdentifier');

	##To build the form, we need two pieces

	##1: The table contains all information from the database
	my @existingStates = map { $_->{regionIdentifier} } @{ $existingData };
	my %existingStates = map { $_ => 1 } @existingStates;

	##2: The list contains all states except for those in the table;
	my $stateObj = Locale::US->new();
	my @stateNames = $stateObj->all_state_names;
	my @newStates = sort grep {! exists $existingStates{$_} } @stateNames;

	my %orderedStates;
	tie %orderedStates, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session);
	%orderedStates = map { $_ => $_ } 'Select State', @newStates;
	$orderedStates{'Select State'} = $i18n->get('Select State');

	my $statesField = WebGUI::Form::selectBox($session,
		-name    => 'stateChooser',
		-options => \%orderedStates,
		-default => 'Select State',
	);

	my $taxField = WebGUI::Form::float($session,
		-name => 'taxRate',
		-value => '',
		-size => 6,
	);
	my $addButton = WebGUI::Form::button($session,
		-name=>"addTaxInfo",
		-value=>"Add Tax Information",
		-extras=>q!align="right" onclick="addState()"!,
	);

	##build the table to display all existing sales tax

	my $tableRows = '';
	my $deleteIcon = $session->config->get('extrasURL').'/toolbar/bullet/delete.gif';
	foreach my $sRow ( @{$existingData} ) {
		$tableRows .= sprintf <<EOTR, $deleteIcon, $sRow->{commerceSalesTaxId}, $sRow->{regionIdentifier}, $sRow->{salesTax};
<tr>
<td class="cell"><img style="cursor:pointer;" src="%s" onclick="deleteState(event,'%s')"></td>
<td class="cell"><span>%s</span></td>
<td class="cell"><span>%6.4f%%</span></td>
</tr>
EOTR
	}
	my $stateForm = sprintf <<EOSF, $taxField, $statesField, $addButton;
<table id="salesTaxEntryTable">
<tbody>
<tr>
<td class="cell">%s&nbsp;%% tax for</td>
<td class="cell">%s</td>
<td class="cell">%s</td>
</tr>
</tbody>
</table>
EOSF

my $stateTable = sprintf <<EOST, $tableRows;
<table id="salesTaxDataTable" border="1" cellpadding="3">
<tbody>
%s
</tbody>
</table>
EOST
	$stateTable = '' unless $tableRows;
	return $stateForm.$stateTable;
}



1;
