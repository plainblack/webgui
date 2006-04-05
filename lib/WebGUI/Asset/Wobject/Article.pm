package WebGUI::Asset::Wobject::Article;

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
use WebGUI::International;
use WebGUI::Cache;
use WebGUI::Paginator;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::Article

=head1 DESCRIPTION

Asset to display content to the user.  Most content in WebGUI sites
will be Articles.

Articles are Wobjects, so they inherit all the methods and properties of
Wobjects.

=head2 definition ( $class, $definition )

This method defines all properties of an Article and is used to autogenerate
most methods used by the Article.

=head3 $class

$class is used to make sure that inheritance works on Assets and Wobjects.

=head3 $definition

Definition hashref from subclasses.

=head3 Article specific properties

=over 4

=item templateId

ID of a tempate from the Article namespace to display the contents of the Article.

=item linkTitle

The text displayed to the user as a hyperlink to the linkURL.

=item convertCarriageReturns

A boolean.  If set to true, all newlines will be converted to Break tags so that simple
text will come out formatted as paragraphs.

=back

=cut

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Article');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			cacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("cache timeout"),
				hoverHelp => $i18n->get("cache timeout help")
				},
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000002',	
				tab=>"display",
				namespace=>"Article",
                		hoverHelp=>$i18n->get('article template description'),
                		label=>$i18n->get(72)
				},
			linkURL=>{
				tab=>"properties",
				fieldType=>'url',
				defaultValue=>undef,
				label=>$i18n->get(8),
                		hoverHelp=>$i18n->get('link url description'),
                		uiLevel=>3
				},
			linkTitle=>{
				tab=>"properties",
				fieldType=>'text',
				defaultValue=>undef,
				label=>$i18n->get(7),
                		hoverHelp=>$i18n->get('link title description'),
                		uiLevel=>3
				},
			convertCarriageReturns=>{
				tab=>"display",
				fieldType=>'yesNo',
				defaultValue=>0,
				label=>$i18n->get(10),
                		subtext=>' &nbsp; <span style="font-size: 8pt;">'.$i18n->get(11).'</span>',
                		hoverHelp=>$i18n->get('carriage return description'),
                		uiLevel=>5
				}
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'article.gif',
		autoGenerateForms=>1,
		tableName=>'Article',
		className=>'WebGUI::Asset::Wobject::Article',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $templateId = $self->get("templateId");
        if ($self->session->form->process("overrideTemplateId") ne "") {
                $templateId = $self->session->form->process("overrideTemplateId");
        }
	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purgeCache ()

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10 && !$self->session->form->process("overrideTemplateId") && !$self->session->form->process("pn") && !$self->session->form->process("makePrintable")) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %var;
	my $children = $self->getLineage(["children"],{returnObjects=>1,includeOnlyClasses=>["WebGUI::Asset::File","WebGUI::Asset::File::Image"]});
	foreach my $child (@{$children}) {
		if (ref $child eq "WebGUI::Asset::File") {
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
	$var{"new.template"} = $self->getUrl.";overrideTemplateId=";
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
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl,1);
	if ($self->session->form->process("makePrintable") || $var{description} eq "") {
		$var{description} =~ s/\^\-\;//g;
		$p->setDataByArrayRef([$var{description}]);
	} else {
		my @pages = split(/\^\-\;/,$var{description});
		$p->setDataByArrayRef(\@pages);
		$var{description} = $p->getPage;
	}
	$p->appendTemplateVars(\%var);
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10 && !$self->session->form->process("overrideTemplateId") && !$self->session->form->process("pn") && !$self->session->form->process("makePrintable")) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
}

1;

