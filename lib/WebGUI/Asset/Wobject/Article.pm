package WebGUI::Asset::Wobject::Article;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		tableName=>'Article',
		className=>'WebGUI::Asset::Wobject::Article',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000002'
				},
			linkURL=>{
				fieldType=>'url',
				defaultValue=>undef
				},
			linkTitle=>{
				fieldType=>'text',
				defaultValue=>undef
				},
			convertCarriageReturns=>{
				fieldType=>'yesNo',
				defaultValue=>0
				}
			}
		});
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Article",
		-hoverHelp=>WebGUI::International::get('article template description','Asset_Article'),
                -label=>WebGUI::International::get(72,"Asset_Article"),
   		);
	$tabform->getTab("properties")->text(
		-name=>"linkTitle",
		-label=>WebGUI::International::get(7,"Asset_Article"),
		-value=>$self->getValue("linkTitle"),
		-hoverHelp=>WebGUI::International::get('link title description','Asset_Article'),
		-uiLevel=>3
		);
        $tabform->getTab("properties")->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(8,"Asset_Article"),
		-value=>$self->getValue("linkURL"),
		-hoverHelp=>WebGUI::International::get('link url description','Asset_Article'),
		-uiLevel=>3
		);
	$tabform->getTab("display")->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(10,"Asset_Article"),
		-value=>$self->getValue("convertCarriageReturns"),
		-subtext=>' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,"Asset_Article").'</span>',
		-hoverHelp=>WebGUI::International::get('carriage return description','Asset_Article'),
		-uiLevel=>5,
		-defaultValue=>0
		);
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/article.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/article.gif';
}

#-------------------------------------------------------------------
sub getIndexerParams {
        my $self = shift;
        my $now = shift;
        return {
                Article => {
                        sql => "select Article.assetId,
					Article.linkTitle,
					Article.linkURL,
					assetData.title,
					assetData.menuTitle,
					assetData.url,
					asset.className,
					assetData.ownerUserId,
					assetData.groupIdView,
					assetData.synopsis,
					wobject.description
				from asset, Article
				left join wobject on wobject.assetId = asset.assetId
				left join assetData asset.assetId=assetData.assetId
				where asset.assetId = Article.assetId
                                        and assetData.startDate < $now
                                        and assetData.endDate > $now",
                        fieldsToIndex => ["linkTitle" ,"linkURL","title","menuTitle","url","synopsis","description" ],
                        contentType => 'content',
                        url => 'WebGUI::URL::gateway($data{url})',
                        headerShortcut => 'select title from asset where assetId = \'$data{assetId}\'',
                        bodyShortcut => 'select description from wobject where assetId = \'$data{assetId}\'',
                }

        };
}

#-------------------------------------------------------------------
sub getName {
	return WebGUI::International::get(1,"Asset_Article");
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	my $children = $self->getLineage(["children"],{returnObjects=>1,includeOnlyClasses=>["WebGUI::Asset::File","WebGUI::Asset::File::Image"]});
	foreach my $child (@{$children}) {
		if (ref $child eq "WebGUI::Asset::File") {
			$var{"attachment.box"} = $child->getBox;
			$var{"attachment.icon"} = $child->getFileIconUrl;
			$var{"attachment.url"} = $child->getFileUrl;
			$var{"attachment.name"} = $child->get("filename");
		} elsif (ref $child eq "WebGUI::Asset::File::Image") {
			$var{"image.url"} = $child->getFileUrl;
			$var{"image.thumbnail"} = $child->getThumbnailUrl; 
		}
	}
        $var{description} = $self->get("description");
	if ($self->get("convertCarriageReturns")) {
		$var{description} =~ s/\n/\<br\>\n/g;
	}
	$var{"new.template"} = $self->getUrl."&overrideTemplateId=";
	$var{"description.full"} = $var{description};
	$var{"description.full"} =~ s/\^\-\;//g;
	$var{"description.first.100words"} = $var{"description.full"};
	$var{"description.first.100words"} =~ s/(((\S+)\s+){100}).*/$1/s;
	$var{"description.first.75words"} = $var{"description.first.100words"};
	$var{"description.first.75words"} =~ s/(((\S+)\s+){75}).*/$1/s;
	$var{"description.first.50words"} = $var{"description.first.75words"};
	$var{"description.first.50words"} =~ s/(((\S+)\s+){50}).*/$1/s;
	$var{"description.first.25words"} = $var{"description.first.50words"};
	$var{"description.first.25words"} =~ s/(((\S+)\s+){25}).*/$1/s;
	$var{"description.first.10words"} = $var{"description.first.25words"};
	$var{"description.first.10words"} =~ s/(((\S+)\s+){10}).*/$1/s;
	$var{"description.first.2paragraphs"} = $var{"description.full"};
	$var{"description.first.2paragraphs"} =~ s/^((.*?\n){2}).*/$1/s;
	$var{"description.first.paragraph"} = $var{"description.first.2paragraphs"};
	$var{"description.first.paragraph"} =~ s/^(.*?\n).*/$1/s;
	$var{"description.first.4sentences"} = $var{"description.full"};
	$var{"description.first.4sentences"} =~ s/^((.*?\.){4}).*/$1/s;
	$var{"description.first.3sentences"} = $var{"description.first.4sentences"};
	$var{"description.first.3sentences"} =~ s/^((.*?\.){3}).*/$1/s;
	$var{"description.first.2sentences"} = $var{"description.first.3sentences"};
	$var{"description.first.2sentences"} =~ s/^((.*?\.){2}).*/$1/s;
	$var{"description.first.sentence"} = $var{"description.first.2sentences"};
	$var{"description.first.sentence"} =~ s/^(.*?\.).*/$1/s;
	my $p = WebGUI::Paginator->new($self->getUrl,1);
	if ($session{form}{makePrintable} || $var{description} eq "") {
		$var{description} =~ s/\^\-\;//g;
		$p->setDataByArrayRef([$var{description}]);
	} else {
		my @pages = split(/\^\-\;/,$var{description});
		$p->setDataByArrayRef(\@pages);
		$var{description} = $p->getPage;
	}
	$p->appendTemplateVars(\%var);
	my $templateId = $self->get("templateId");
        if ($session{form}{overrideTemplateId} ne "") {
                $templateId = $session{form}{overrideTemplateId};
        }
	return $self->processTemplate(\%var, $templateId);
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("article add/edit","Article");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("12","Asset_Article"));
}



1;

