package WebGUI::Asset::Wobject::Navigation;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::Utility;

use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
aspect assetName => ["assetName", 'Asset_Navigation'];
aspect icon      => 'navigation.gif';
aspect tableName => 'Navigation';

property    templateId => (
                label        => ['1096', 'Asset_Navigation'],
                hoverHelp    => ['1096 description', 'Asset_Navigation'],
                fieldType    => "template",
                default      => 'PBtmpl0000000000000048',
            );
property    mimeType => (
                label        => ['mimeType', 'Asset_Navigation'],
                hoverHelp    => ['mimeType description', 'Asset_Navigation'],
                fieldType    => "mimeType",
                default      => 'text/html',
            );
property    assetsToInclude => (
                fieldType    => 'checkList',
                default      => "descendants",
                label        => ["Relatives To Include", 'Asset_Navigation'],
                hoverHelp    => ["Relatives To Include description", 'Asset_Navigation'],
            );
property    startType => (
                fieldType    => 'selectBox',
                default      => "relativeToCurrentUrl",
                label        => ["Start Point Type", 'Asset_Navigation'],
                hoverHelp    => ["Start Point Type description", 'Asset_Navigation'],
            );
property    startPoint => (
                fieldType   => 'text',
                default     => 0,
                label       => ["Start Point", 'Asset_Navigation'],
                hoverHelp   => ["Start Point description", 'Asset_Navigation'],
            );
property    ancestorEndPoint => (
                noFormPost  => 1,
                fieldType   => 'selectBox',
                default     => 55,
            );
property    descendantEndPoint => (
                noFormPost  => 1,
                fieldType   => 'selectBox',
                default     => 55,
            );
property    showSystemPages => (
                label        => [30, 'Asset_Navigation'],
                fieldType    => 'yesNo',
                default      => 0,
            );
property    showHiddenPages => (
                label        => [31, 'Asset_Navigation'],
                fieldType    => 'yesNo',
                default      => 0,
            );
property    showUnprivilegedPages => (
                label        => [32, 'Asset_Navigation'],
                fieldType    => 'yesNo',
                default      => 0,
            );
property    reversePageLoop => (
                label        => ['reverse page loop', 'Asset_Navigation'],
                fieldType    => 'yesNo',
                default      => 0,
            );

#-------------------------------------------------------------------

=head2 getEditForm ( )

Manually build the edit form due to javascript elements.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
	my $i18n = WebGUI::International->new($self->session, "Asset_Navigation");
   	$tabform->getTab("display")->template(
      		-value=>$self->templateId,
      		-namespace=>"Navigation",
		-label=>$i18n->get(1096),
		-hoverHelp=>$i18n->get('1096 description'),
   		);
   	$tabform->getTab("display")->mimeType(
      		-value=>$self->mimeType,
      		-name=>"mimeType",
		-label=>$i18n->get('mimeType'),
		-hoverHelp=>$i18n->get('mimeType description'),
   		);
	$tabform->hidden({
		name=>"returnUrl",
		value=>$self->session->form->process("returnUrl")
		});
	my ($descendantsChecked, $ancestorsChecked, $selfChecked, $pedigreeChecked, $siblingsChecked);
	my @assetsToInclude = split("\n",$self->assetsToInclude);
	my $afterScript;
	foreach my $item (@assetsToInclude) {
		if ($item eq "self") {
			$selfChecked = 1;
		} elsif ($item eq "descendants") {
			$descendantsChecked = 1;
			$afterScript = "displayNavEndPoint = false;";
		} elsif ($item eq "ancestors") {
			$ancestorsChecked = 1;
		} elsif ($item eq "siblings") {
			$siblingsChecked = 1;
		} elsif ($item eq "pedigree") {
			$pedigreeChecked = 1;
		}
	}
	$tabform->getTab("properties")->selectBox(
		-name=>"startType",
		-options=>{
			specificUrl=>$i18n->get('Specific URL'),
			relativeToCurrentUrl=>$i18n->get('Relative To Current URL'),
			relativeToRoot=>$i18n->get('Relative To Root')
			},
		-value=>[$self->startType],
		-label=>$i18n->get("Start Point Type"),
		-hoverHelp=>$i18n->get("Start Point Type description"),
		-id=>"navStartType",
		-extras=>'onchange="changeStartPoint()"'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("Start Point"),
		-hoverHelp=>$i18n->get("Start Point description"),
		-value=>'<div id="navStartPoint"></div>'
		);
	my %options = ();
	tie %options, 'Tie::IxHash';
	%options = (
		'1'=>'../ (-1)',
		'2'=>'../../ (-2)',
		'3'=>'../../../ (-3)',
		'4'=>'../../../../ (-4)',
		'5'=>'../../../../../ (-5)',
		'55'=>$i18n->get('Infinity')
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navAncestorEnd"><tr><td class="formDescription">'.$i18n->get("Ancestor End Point").'</td><td>'
		.WebGUI::Form::selectBox($self->session,{
			name=>"ancestorEndPoint",
			value=>[$self->ancestorEndPoint],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->getTab("properties")->readOnly(
		-label=>$i18n->get("Relatives To Include"),
		-hoverHelp=>$i18n->get("Relatives To Include description"),
		-value=>WebGUI::Form::checkbox($self->session,{
				checked=>$ancestorsChecked,
				name=>"assetsToInclude",
				extras=>'onchange="toggleAncestorEndPoint()"',
				value=>"ancestors"
				}).$i18n->get('Ancestors').'<br />'
			.WebGUI::Form::checkbox($self->session,{
				checked=>$selfChecked,
				name=>"assetsToInclude",
				value=>"self"
				}).$i18n->get('Self').'<br />'
			.WebGUI::Form::checkbox($self->session,{
				checked=>$siblingsChecked,
				name=>"assetsToInclude",
				value=>"siblings"
				}).$i18n->get('Siblings').'<br />'
			.WebGUI::Form::checkbox($self->session,{
				checked=>$descendantsChecked,
				name=>"assetsToInclude",
				value=>"descendants",
				extras=>'onchange="toggleDescendantEndPoint()"'
				}).$i18n->get('Descendants').'<br />'
			.WebGUI::Form::checkbox($self->session,{
				checked=>$pedigreeChecked,
				name=>"assetsToInclude",
				value=>"pedigree"
				}).$i18n->get('Pedigree').'<br />'
		);
	%options = ();
	tie %options, 'Tie::IxHash';
	%options = (
		'1'=>'./a/ (+1)',
		'2'=>'./a/b/ (+2)',
		'3'=>'./a/b/c/ (+3)',
		'4'=>'./a/b/c/d/ (+4)',
		'5'=>'./a/b/c/d/e/ (+5)',
		'55'=>$i18n->get('Infinity')
		);
	$tabform->getTab("properties")->raw(
		'</tbody><tbody id="navDescendantEnd"><tr><td class="formDescription">'.$i18n->get('Descendant End Point').'</td><td>'
		.WebGUI::Form::selectBox($self->session,{
			name=>"descendantEndPoint",
			value=>[$self->descendantEndPoint],
			options=>\%options
			})
		.'</td></tr></tbody><tbody>'
		);
	$tabform->getTab("display")->yesNo(
		-name=>'showSystemPages',
		-label=>$i18n->get(30),
		-hoverHelp=>$i18n->get('30 description'),
		-value=>$self->showSystemPages
		);
        $tabform->getTab("display")->yesNo(
                -name=>'showHiddenPages',
                -label=>$i18n->get(31),
                -hoverHelp=>$i18n->get('31 description'),
                -value=>$self->showHiddenPages
        	);
        $tabform->getTab("display")->yesNo(
                -name=>'showUnprivilegedPages',
                -label=>$i18n->get(32),
                -hoverHelp=>$i18n->get('32 description'),
                -value=>$self->showUnprivilegedPages
        	);
	$tabform->getTab("display")->yesNo(
		-name=>'reversePageLoop',
		-label=>$i18n->get('reverse page loop'),
		-hoverHelp => $i18n->get('reverse page loop description'),
		-value=>$self->reversePageLoop,
		);
	my $start = $self->startPoint;
	$tabform->getTab("properties")->raw("<script type=\"text/javascript\">
		//<![CDATA[
		var displayNavDescendantEndPoint = true;
		var displayNavAncestorEndPoint = true;
		function toggleDescendantEndPoint () {
			if (displayNavDescendantEndPoint) {
				document.getElementById('navDescendantEnd').style.display='none';
				displayNavDescendantEndPoint = false;
			} else {
				document.getElementById('navDescendantEnd').style.display='';
				displayNavDescendantEndPoint = true;
			}
		}
		function toggleAncestorEndPoint () {
			if (displayNavAncestorEndPoint) {
				document.getElementById('navAncestorEnd').style.display='none';
				displayNavAncestorEndPoint = false;
			} else {
				document.getElementById('navAncestorEnd').style.display='';
				displayNavAncestorEndPoint = true;
			}
		}
		function changeStartPoint () {
			var types = new Array();
			types['specificUrl']='<input type=\"text\" name=\"startPoint\" value=\"".$start."\" />';
			types['relativeToRoot']='<select name=\"startPoint\"><option value=\"0\"".(($start == 0)?' selected=\"1\"':'').">/ (0)</option><option value=\"1\"".(($start eq "1")?' selected=\"1\"':'').">/a/ (+1)</option><option value=\"2\"".(($start eq "2")?' selected=\"1\"':'').">/a/b/ (+2)</option><option value=\"3\"".(($start eq "3")?' selected=\"1\"':'').">/a/b/c/ (+3)</option><option value=\"4\"".(($start eq "4")?' selected=\"1\"':'').">/a/b/c/d/ (+4)</option><option value=\"5\"".(($start eq "5")?' selected=\"1\"':'').">/a/b/c/d/e/ (+5)</option><option value=\"6\"".(($start eq "6")?' selected=\"1\"':'').">/a/b/c/d/e/f/ (+6)</option><option value=\"7\"".(($start eq "7")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/ (+7)</option><option value=\"8\"".(($start eq "8")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/ (+8)</option><option value=\"9\"".(($start eq "9")?' selected=\"1\"':'').">/a/b/c/d/e/f/g/h/i/ (+9)</option></select>';
			types['relativeToCurrentUrl']='<select name=\"startPoint\"><option value=\"-3\"".(($start eq "-3")?' selected=\"1\"':'').">../../.././ (-3)</option><option value=\"-2\"".(($start eq "-2")?' selected=\"1\"':'').">../.././ (-2)</option><option value=\"-1\"".(($start eq "-1")?' selected=\"1\"':'').">.././ (-1)</option><option value=\"0\"".(($start == 0 || $start > 0)?' selected=\"1\"':'').">./ (0)</option></select>';
			document.getElementById('navStartPoint').innerHTML=types[document.getElementById('navStartType').options[document.getElementById('navStartType').selectedIndex].value];
		}
		".$afterScript."
		changeStartPoint();
		".($descendantsChecked ? "" : "toggleDescendantEndPoint();")."
		".($ancestorsChecked ? "" : "toggleAncestorEndPoint();")."
		//]]>
		</script>");
	my $previewButton;# = qq{
                          # <INPUT TYPE="button" VALUE="Preview" NAME="preview"
                          #  OnClick="
                          #      window.open('', 'navPreview', 'toolbar=no,status=no,location=no,scrollbars=yes,resizable=yes');
                          #      this.form.func.value='preview';
                          #      this.form.target = 'navPreview';
                          #      this.form.submit()">};
	my $saveButton = ' <input type="button" class="forwardButton" value="'.$i18n->get(62,'WebGUI').'" onclick="
		this.value=\''.$i18n->get(452,'WebGUI').'\';
		this.form.func.value=\'editSave\';
		this.form.target=\'_self\';
		this.form.submit();
		" />';
	$tabform->{_submit} = $previewButton." ".$saveButton;
	return $tabform;
}



#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
    return undef
        unless $self->canEdit && $self->session->var->isAdminOn;
	if ($self->getToolbarState) {
        my $toolbar = '';
        if ($self->canEditIfLocked) {
            my $userUiLevel = $self->session->user->profileField("uiLevel");
            my $uiLevels = $self->session->config->get("assetToolbarUiLevel");
            my $returnUrl = '';
            if ($self->session->asset) {
                $returnUrl = ";proceed=goBackToPage;returnUrl=".$self->session->url->escape($self->session->asset->getUrl);
            }
            $toolbar = $self->session->icon->edit('func=edit'.$returnUrl,$self->get("url"))
                if ($userUiLevel >= $uiLevels->{"edit"});
        }
        $self->session->style->setLink($self->session->url->extras('assetToolbar/assetToolbar.css'), {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setLink($self->session->url->extras('yui/build/menu/assets/skins/sam/menu.css'), {rel=>"stylesheet",type=>"text/css"});
        $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>"text/javascript"});
        $self->session->style->setScript($self->session->url->extras('yui/build/container/container_core-min.js'), {type=>"text/javascript"});
        $self->session->style->setScript($self->session->url->extras('yui/build/menu/menu-min.js'), {type=>"text/javascript"});
        $self->session->style->setScript($self->session->url->extras('assetToolbar/assetToolbar.js'), {type=>"text/javascript"});
        my $i18n = WebGUI::International->new($self->session, "Asset");
        return '<div class="yui-skin-sam wg-toolbar">'
            . '<img src="' . $self->getIcon(1) . '" title="' . $self->getName . '" alt="' . $self->getName . '" class="wg-toolbar-icon" />'
            . '<div class="yuimenu wg-contextmenu">'
            . '<div class="bd">'
            . '<ul class="first-of-type">'
            . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("func=copy") . '">' . $i18n->get("Copy") . '</a></li>'
            . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl("op=assetManager") . '">' . $i18n->get("manage") . '</a></li>'
            . '<li class="yuimenuitem"><a class="yuimenuitemlabel" href="'
            . $self->getUrl . '">' . $i18n->get("view") . '</a></li>'
            . "</ul></div></div>$toolbar</div>";
    }
    return $self->SUPER::getToolbar;
}



#-------------------------------------------------------------------

=head2 prepareView ( )

Extend the superclass to add metadata and to preprocess the template.

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
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 view ( )

See WebGUI::Asset::view() for details.

=cut

sub view {
	my $self = shift;
	# we've got to determine what our start point is based upon user conditions
	my $start;
	$self->session->asset(WebGUI::Asset->newByUrl($self->session)) unless ($self->session->asset);
	my $current = $self->session->asset;

    # no current asset is set
    unless (defined $current) {
        $current = WebGUI::Asset->getDefault($self->session);
    }

	if ($self->get("startType") eq "specificUrl") {
		$start = WebGUI::Asset->newByUrl($self->session,$self->get("startPoint"));
	} elsif ($self->get("startType") eq "relativeToRoot") {
		unless (($self->get("startPoint")+1) >= $current->getLineageLength) {
			$start = WebGUI::Asset->newByLineage($self->session,substr($current->get("lineage"),0, ($self->get("startPoint") + 1) * 6));
		}
	} elsif ($self->get("startType") eq "relativeToCurrentUrl") {
		$start = WebGUI::Asset->newByLineage($self->session,substr($current->get("lineage"),0, ($current->getLineageLength + $self->get("startPoint")) * 6));
	}
	$start = $current unless (defined $start); # if none of the above results in a start point, then the current page must be it
	my @includedRelationships = split("\n",$self->get("assetsToInclude"));

	my %rules;
	$rules{returnObjects} = 1;
	$rules{endingLineageLength} = $start->getLineageLength+$self->get("descendantEndPoint");
	$rules{assetToPedigree} = $current if (isIn("pedigree",@includedRelationships));
	$rules{ancestorLimit} = $self->get("ancestorEndPoint");
	$rules{orderByClause} = 'rpad(asset.lineage, 255, 9) desc' if ($self->get('reversePageLoop'));
	my @interestingProperties = ('assetId', 'parentId', 'ownerUserId', 'synopsis', 'newWindow');
	my $assets = $start->getLineage(\@includedRelationships,\%rules);	
	my $var = {'page_loop' => []};
    foreach my $property (@interestingProperties) {
		$var->{'currentPage.'.$property} = $current->get($property);
	}
	$var->{'currentPage.menuTitle'} = $current->getMenuTitle;
	$var->{'currentPage.title'}     = $current->getTitle;
	$var->{'currentPage.isHome'} = ($current->getId eq $self->session->setting->get("defaultPage"));
	$var->{'currentPage.url'} = $current->getUrl;
    	$var->{'currentPage.hasChild'} = $current->hasChildren;
    	$var->{'currentPage.rank'} = $current->getRank;
    	$var->{'currentPage.rankIs'.$current->getRank} = 1;
	my $currentLineage = $current->get("lineage");
	my $lineageToSkip = "noskip";
	my $absoluteDepthOfLastPage;
    my $absoluteDepthOfFirstPage;   # Will set on first iteration of loop, below
	my %lastChildren;
	my $previousPageData = undef;
	my $eh = $self->session->errorHandler;
	foreach my $asset (@{$assets}) {

		# skip pages we shouldn't see
		my $pageLineage = $asset->get("lineage");
		next if ($pageLineage =~ m/^$lineageToSkip/);
		
		if ($asset->get("isHidden") && !$self->get("showHiddenPages")) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}
		if ($asset->get("isSystem") && !$self->get("showSystemPages")) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}
		unless ($self->get("showUnprivilegedPages") || $asset->canView) {
			$lineageToSkip = $pageLineage unless ($pageLineage eq "000001");
			next;
		}

        # Set absoluteDepthOfFirstPage after we have determined if the first page is viewable!
        # Otherwise, the indent loop calculation below will be off by 1 (or more)
        if ( !defined $absoluteDepthOfFirstPage ) {
            $absoluteDepthOfFirstPage   = $asset->getLineageLength;
        }

		my $pageData = {};
        my $pageProperties = $asset->get;
        while (my ($property, $propertyValue) = each %{ $pageProperties }) {
			$pageData->{"page.".$property} = $propertyValue;
		}
		$pageData->{'page.menuTitle'} = $asset->getMenuTitle;
		$pageData->{'page.title'}     = $asset->getTitle;
		# build nav variables
		$pageData->{"page.rank"}     = $asset->getRank;
		$pageData->{"page.absDepth"} = $asset->getLineageLength;
		$pageData->{"page.relDepth"} = $asset->getLineageLength - $absoluteDepthOfFirstPage;
		$pageData->{"page.isSystem"} = $asset->get("isSystem");
		$pageData->{"page.isHidden"} = $asset->get("isHidden");
		$pageData->{"page.isViewable"} = $asset->canView;
		$pageData->{'page.isContainer'} = $self->session->config->get("assets/".$asset->get("className")."/isContainer");
  		$pageData->{'page.isUtility'} = $self->session->config->get("assets/".$asset->get("className")."/category") eq "utilities";
		$pageData->{"page.url"} = $asset->getUrl;
		my $indent = $asset->getLineageLength - $absoluteDepthOfFirstPage;
		$pageData->{"page.indent_loop"} = [];
		push(@{$pageData->{"page.indent_loop"}},{'indent'=>$_}) for(1..$indent);
		$pageData->{"page.indent"} = "&nbsp;&nbsp;&nbsp;" x $indent;
		$pageData->{"page.isBranchRoot"} = ($pageData->{"page.absDepth"} == 1);
		$pageData->{"page.isTopOfBranch"} = ($pageData->{"page.absDepth"} == 2);
		$pageData->{"page.isChild"} = ($asset->get("parentId") eq $current->getId);
		$pageData->{"page.isParent"} = ($asset->getId eq $current->get("parentId"));
		$pageData->{"page.isCurrent"} = ($asset->getId eq $current->getId);
		$pageData->{"page.isDescendant"} = ( $pageLineage =~ m/^$currentLineage/ && !$pageData->{"page.isCurrent"});
		$pageData->{"page.isAncestor"} = ( $currentLineage =~ m/^$pageLineage/ && !$pageData->{"page.isCurrent"});
		my $currentBranchLineage = substr($currentLineage,0,12);
		$pageData->{"page.inBranchRoot"} = ($pageLineage =~ m/^$currentBranchLineage/);
		$pageData->{"page.isSibling"} = (
			$asset->get("parentId") eq $current->get("parentId") &&
			$asset->getId ne $current->getId
			);
		$pageData->{"page.inBranch"} = ( 
			$pageData->{"page.isCurrent"} ||
			$pageData->{"page.isAncestor"} ||
			$pageData->{"page.isSibling"} ||
			$pageData->{"page.isDescendant"}
			);
		$pageData->{"page.depthIs".$pageData->{"page.absDepth"}} = 1;
		$pageData->{"page.relativeDepthIs".$pageData->{"page.relDepth"}} = 1;
		my $depthDiff = ($absoluteDepthOfLastPage) ? ($absoluteDepthOfLastPage - $pageData->{'page.absDepth'}) : 0;
		$pageData->{"page.depthDiff"} = $depthDiff;
		$pageData->{"page.depthDiffIs".$depthDiff} = 1;
		if ($depthDiff > 0) {
			push(@{$pageData->{"page.depthDiff_loop"}},{}) for(1..$depthDiff);
		}
		$absoluteDepthOfLastPage = $pageData->{"page.absDepth"};
		$pageData->{"page.hasChild"} = $asset->hasChildren;
                ++$var->{"currentPage.hasSibling"}
                        if $pageData->{"page.isSibling"};
                ++$var->{"currentPage.hasViewableSiblings"}
                        if ($pageData->{"page.isSibling"} && $pageData->{"page.isViewable"});
                ++$var->{"currentPage.hasViewableChildren"}
                        if ($pageData->{"page.isChild"} && $pageData->{"page.isViewable"});

		my $parent = $asset->getParent;
		if (defined $parent) {
            foreach my $property (@interestingProperties) {
				$pageData->{"page.parent.".$property} = $parent->get($property);
			}
			$pageData->{'page.parent.menuTitle'} = $parent->getMenuTitle;
			$pageData->{'page.parent.title'} = $parent->getTitle;
			$pageData->{"page.parent.url"} = $parent->getUrl;
			$pageData->{"page.parent.rank"} = $parent->getRank;
			$pageData->{"page.isRankedFirst"} = 1 unless exists $lastChildren{$parent->getId};
			$lastChildren{$parent->getId} = $asset->getId;			
		}
		$previousPageData->{"page.hasViewableChildren"} = ($previousPageData->{"page.assetId"} eq $pageData->{"page.parentId"});
		push(@{$var->{page_loop}}, $pageData);	
		$previousPageData = $pageData;
	}
	my $counter;
	for($counter=0 ; $counter < scalar( @{$var->{page_loop}} ) ; $counter++) {
		@{$var->{page_loop}}[$counter]->{"page.isRankedLast"} = 1 if 
			($lastChildren{@{$var->{page_loop}}[$counter]->{"page.parent.assetId"}} 
				eq @{$var->{page_loop}}[$counter]->{"page.assetId"});
	}
	return $self->processTemplate($var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_goBackToPage ( )

Do a redirect to the form parameter returnUrl if it exists.

=cut

sub www_goBackToPage {
	my $self = shift;
	$self->session->http->setRedirect($self->session->form->process("returnUrl")) if ($self->session->form->process("returnUrl"));
	return undef;
}

#-------------------------------------------------------------------

=head2 www_view

A web accessible version of the view method.  The SUPER method is overridden so that we can serve
other types aside from text/html.

=cut

sub www_view {
	my $self = shift;
	my $mimeType = $self->mimeType || 'text/html';
	if ($mimeType eq 'text/html') {
		return $self->SUPER::www_view();
	}
	else {
		$self->prepareView();
		$self->session->http->setMimeType($mimeType || 'text/html');
		return $self->view();
	}
}

1;

