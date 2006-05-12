package WebGUI::Asset::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Asset';
use WebGUI::International;
use WebGUI::Asset::Template::HTMLTemplate;
use WebGUI::Utility;


=head1 NAME

Package WebGUI::Asset::Template

=head1 DESCRIPTION

Provides a mechanism to provide a templating system in WebGUI.

=head1 SYNOPSIS

use WebGUI::Asset::Template;


=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

Defines the properties of this asset.

=head3 session

A reference to an existing session.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Template");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'template.gif',
                tableName=>'template',
                className=>'WebGUI::Asset::Template',
                properties=>{
                                template=>{
                                        fieldType=>'codearea',
                                        defaultValue=>undef
                                        },
				isEditable=>{
					noFormPost=>1,
					fieldType=>'hidden',
					defaultValue=>1
					},
				showInForms=>{
					fieldType=>'yesNo',
					defaultValue=>1
				},
				parser=>{
					fieldType=>'selectList',
					defaultValue=>[$session->config->get("defaultTemplateParser")]
				},	
				headBlock=>{
					fieldType=>"codearea",
					defaultValue=>undef
					},
				namespace=>{
					fieldType=>'combo',
					defaultValue=>undef
					}
                        }
                });
        return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session, 'Asset_Template');
	$tabform->hidden({
		name=>"returnUrl",
		value=>$self->session->form->get("returnUrl")
		});
	if ($self->getValue("namespace") eq "") {
		my $namespaces = $self->session->dbSlave->buildHashRef("select distinct(namespace),namespace from template order by namespace");
		$tabform->getTab("properties")->combo(
			-name=>"namespace",
			-options=>$namespaces,
			-label=>$i18n->get('namespace'),
			-hoverHelp=>$i18n->get('namespace description'),
			-value=>[$self->session->form->get("namespace")] 
			);
	} else {
		$tabform->getTab("meta")->readOnly(
			-label=>$i18n->get('namespace'),
			-hoverHelp=>$i18n->get('namespace description'),
			-value=>$self->getValue("namespace")
			);	
		$tabform->getTab("meta")->hidden(
			-name=>"namespace",
			-value=>$self->getValue("namespace")
			);
	}
	$tabform->getTab("display")->yesNo(
		-name=>"showInForms",
		-value=>$self->getValue("showInForms"),
		-label=>$i18n->get('show in forms'),
		-hoverHelp=>$i18n->get('show in forms description'),
		);
        $tabform->getTab("properties")->codearea(
		-name=>"template",
		-label=>$i18n->get('assetName'),
		-hoverHelp=>$i18n->get('template description'),
		-value=>$self->getValue("template")
		);
        $tabform->getTab("properties")->codearea(
		-name=>"headBlock",
		-label=>$i18n->get('head block'),
		-hoverHelp=>$i18n->get('head block description'),
		-value=>$self->getValue("headBlock")
		);
	if($self->session->config->get("templateParsers")){
		my @temparray = @{$self->session->config->get("templateParsers")};
		tie my %parsers, 'Tie::IxHash';
		while(my $a = shift @temparray){
			$parsers{$a} = $self->getParser($self->session, $a)->getName();
		}
		my $value = [$self->getValue("parser")];
		$value = \[$self->session->config->get("defaultTemplateParser")] if(!$self->getValue("parser"));
		$tabform->getTab("properties")->selectBox(
			-name=>"parser",
			-options=>\%parsers,
			-value=>$value,
			-label=>$i18n->get('parser'),
			-hoverHelp=>$i18n->get('parser description'),
		);
	}
	return $tabform;
}





#-------------------------------------------------------------------

=head2 getList ( session, namespace )

Returns a hash reference containing template ids and template names of all the templates in the specified namespace.

NOTE: This is a class method.

=head3 session

A reference to the current session.

=head3 namespace

Specify the namespace to build the list for.

=cut

sub getList {
	my $class = shift;
	my $session = shift;
	my $namespace = shift;
my $sql = "select asset.assetId, assetData.revisionDate from template left join asset on asset.assetId=template.assetId left join assetData on assetData.revisionDate=template.revisionDate and assetData.assetId=template.assetId where template.namespace=".$session->db->quote($namespace)." and template.showInForms=1 and asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' or assetData.tagId=".$session->db->quote($session->scratch->get("versionTag")).")) order by assetData.title";
	my $sth = $session->dbSlave->read($sql);
	my %templates;
	tie %templates, 'Tie::IxHash';
	while (my ($id, $version) = $sth->array) {
		$templates{$id} = WebGUI::Asset::Template->new($session,$id,undef,$version)->getTitle;
	}	
	$sth->finish;	
	return \%templates;
}

#-------------------------------------------------------------------

=head2 getParser ( session, parser )

Returns a template parser object.

NOTE: This is a class method.

=head3 session

A reference to the current session.

=head3 parser

A parser class to use. Defaults to "WebGUI::Asset::Template::HTMLTemplate"

=cut

sub getParser {
	my $class = shift;
	my $session = shift;
	my $parser = shift || $session->config->get("defaultTemplateParser") || "WebGUI::Asset::Template::HTMLTemplate";
	if ($parser eq "") {
		return WebGUI::Asset::Template::HTMLTemplate->new($session);
	} else {
		eval("use $parser");
		return $parser->new($session);
	}
}


#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("namespace"));
	$indexer->setIsPublic(0);
}


#-------------------------------------------------------------------

=head2 prepare ( )

This method sets the tags from the head block parameter of the template into the HTML head block in the style. You only need to call this method if you're using the HTML streaming features of WebGUI, like is done in the prepareView()/view()/www_view() methods of WebGUI assets.

=cut

sub prepare {
	my $self = shift;
	$self->{_prepared} = 1;
	my @sent = @{$self->session->stow->get("templateHeadersSent")};
	unless (isIn($self->getId, @sent)) { # don't send head block if we've already sent it for this template
		if ($self->session->style->sent) {
			$self->session->output->print($self->get("headBlock"));
		} else {
			$self->session->style->setRawHeadTags($self->get("headBlock"));
		}
	}
	push(@sent, $self->getId);
	$self->session->stow->set("templateHeadersSent", \@sent);
}


#-------------------------------------------------------------------

=head2 process ( vars )

Evaluate a template replacing template commands for HTML.

=head3 vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

=cut

sub process {
	my $self = shift;
	my $vars = shift;
	$self->prepare unless ($self->{_prepared});
	return $self->getParser($self->session, $self->get("parser"))->process($self->get("template"), $vars);
}


#-------------------------------------------------------------------

=head2 processRaw ( session, template, vars [ , parser ] )

Process an arbitrary template string. This is a class method.

=head3 session

A reference to the current session.

=head3 template

A scalar containing the template text.

=head3 vars

A hash reference containing template variables.

=head3 parser

Optionally specify the class name of a parser to use.

=cut

sub processRaw {
	my $class = shift;
	my $session = shift;
	my $template = shift;
	my $vars = shift;
	my $parser = shift;
	return $class->getParser($session,$parser)->process($template, $vars);
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session, "Asset_Template");
	$self->getAdminConsole->setHelp("template add/edit","Asset_Template");
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=styleWizard'),$i18n->get("style wizard")) if ($self->get("namespace") eq "style");
        return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get('edit template'));
}

#-------------------------------------------------------------------
sub www_goBackToPage {
	my $self = shift;
	$self->session->http->setRedirect($self->session->form->get("returnUrl")) if ($self->session->form->get("returnUrl"));
	return "";
}


#-------------------------------------------------------------------
sub www_manage {
	my $self = shift;
	#takes the user to the folder containing this template.
	return $self->getParent->www_manageAssets;
}


#-------------------------------------------------------------------
sub www_styleWizard {
	my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session, "Asset_Template");
	my $form = $self->session->form;
	my $output = "";
	if ($form->get("step") == 2) {
		my $f = WebGUI::HTMLForm->new($self->session,{action=>$self->getUrl});
		$f->hidden(name=>"func", value=>"styleWizard");
		$f->hidden(name=>"proceed", value=>"manageAssets") if ($form->get("proceed"));
		$f->hidden(name=>"step", value=>3);
		$f->hidden(name=>"layout", value=>$form->get("layout"));
		$f->text(
			name=>"heading",
			value=>"My Site",
			label=>$i18n->get("site name"),
			hoverHelp=>$i18n->get("site name description")
		);
		$f->file(
			name=>"logo",
			label=>$i18n->get("logo"),
			hoverHelp=>$i18n->get("logo description"),
			subtext=>$i18n->get("logo subtext")
		);
		$f->color(
			name=>"pageBackgroundColor",
			value=>"#ccccdd",
			label=>$i18n->get("page background color"),
			hoverHelp=>$i18n->get("page background color description"),
		);
		$f->color(
			name=>"headingBackgroundColor",
			value=>"#ffffff",
			label=>$i18n->get("header background color"),
			hoverHelp=>$i18n->get("header background color description"),
		);
		$f->color(
			name=>"headingForegroundColor",
			value=>"#000000",
			label=>$i18n->get("header text color"),
			hoverHelp=>$i18n->get("header text color description"),
		);
		$f->color(
			name=>"bodyBackgroundColor",
			value=>"#ffffff",
			label=>$i18n->get("body background color"),
			hoverHelp=>$i18n->get("body background color description"),
		);
		$f->color(
			name=>"bodyForegroundColor",
			value=>"#000000",
			label=>$i18n->get("body text color"),
			hoverHelp=>$i18n->get("body text color description"),
		);
		$f->color(
			name=>"menuBackgroundColor",
			value=>"#eeeeee",
			label=>$i18n->get("menu background color"),
			hoverHelp=>$i18n->get("menu background color description"),
		);
		$f->color(
			name=>"linkColor",
			value=>"#0000ff",
			label=>$i18n->get("link color"),
			hoverHelp=>$i18n->get("link color description"),
		);
		$f->color(
			name=>"visitedLinkColor",
			value=>"#ff00ff",
			label=>$i18n->get("visited link color"),
			hoverHelp=>$i18n->get("visited link color description"),
		);
		$f->submit;
		$output = $f->print;
	} elsif ($form->get("step") == 3) {
		my $storageId = $form->get("logo","file");
		my $logo;
		if ($storageId) {
			my $storage = WebGUI::Storage::Image->get($self->session,$storageId);
			$logo = $self->addChild({
				className=>"WebGUI::Asset::File::Image",
				title=>join(' ', $form->get("heading"), $i18n->get('logo')),
				menuTitle=>join(' ', $form->get("heading"), $i18n->get('logo')),
				url=>join(' ', $form->get("heading"), $i18n->get('logo')),
				storageId=>$storage->getId,
				filename=>@{$storage->getFiles}[0],
				templateId=>"PBtmpl0000000000000088"
				});
			$logo->generateThumbnail;
		}
my $style = '<html>
<head>
	<tmpl_var head.tags>
	<title>^Page(title); - ^c;</title>
	<style type="text/css">
	.siteFunctions {
		float: right;
		font-size: 12px;
	}
	.copyright {
		font-size: 12px;
	}
	body {
		background-color: '.$form->get("pageBackgroundColor","color").';
		font-family: helvetica;
		font-size: 14px;
	}
	.heading {
		background-color: '.$form->get("headingBackgroundColor","color").';
		color: '.$form->get("headingForegroundColor","color").';
		font-size: 30px;
		margin-left: 10%;
		margin-right: 10%;
		vertical-align: middle;
	}
	.logo {
		width: 200px; 
		float: left;
		text-align: center;
	}
	.logo img {
		border: 0px;
	}
	.endFloat {
		clear: both;
	}
	.padding {
		padding: 5px;
	}
	.bodyContent {
		background-color: '.$form->get("bodyBackgroundColor","color").';
		color: '.$form->get("bodyForegroundColor","color").';
		width: 55%; ';
if ($form->get("layout") == 1) {
	$style .= '
		float: left;
		height: 75%;
		margin-right: 10%;
		';
} else {
	$style .= '
		width: 80%;
		margin-left: 10%;
		margin-right: 10%;
		';
}
	$style .= '
	}
	.menu {
		background-color: '.$form->get("menuBackgroundColor","color").';
		width: 25%; ';
if ($form->get("layout") == 1) {
	$style .= '
		margin-left: 10%;
		height: 75%;
		float: left;
		';
} else {
	$style .= '
		width: 80%;
		text-align: center;
		margin-left: 10%;
		margin-right: 10%;
		';
}
	$style .= '
	}
	a {
		color: '.$form->get("linkColor","color").';
	}
	a:visited {
		color: '.$form->get("visitedLinkColor","color").';
	}
	</style>
</head>
<body>
^AdminBar;
<div class="heading">
	<div class="padding">
';
	if (defined $logo) {
		$style .= '<div class="logo"><a href="^H(linkonly);">^AssetProxy('.$logo->get("url").');</a></div>';
	}
	$style .= '
		'.$form->get("heading").'
		<div class="endFloat"></div>
	</div>
</div>
<div class="menu">
	<div class="padding">^AssetProxy('.($form->get("layout") == 1 ? 'flexmenu' : 'toplevelmenuhorizontal').');</div>
</div>
<div class="bodyContent">
	<div class="padding"><tmpl_var body.content></div>
</div>';
if ($form->get("layout") == 1) {
	$style .= '<div class="endFloat"></div>';
}
$style .= '
<div class="heading">
	<div class="padding">
		<div class="siteFunctions">^a(^@;); ^AdminToggle;</div>
		<div class="copyright">&copy; ^D(%y); ^c;</div>
	<div class="endFloat"></div>
	</div>
</div>
</body>
</html>';
		return $self->addRevision({
			template=>$style
			})->www_edit;
	} else {
		$output = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl}).WebGUI::Form::hidden($self->session,{name=>"func", value=>"styleWizard"});
		$output .= WebGUI::Form::hidden($self->session,{name=>"proceed", value=>"manageAssets"}) if ($form->get("proceed"));
		$output .= '<style type="text/css">
			.chooser { float: left; width: 150px; height: 150px; } 
			.representation, .representation td { font-size: 12px; width: 120px; border: 1px solid black; } 
			.representation { height: 130px; }
			</style>';
		$output .= $i18n->get('choose a layout');
		$output .= WebGUI::Form::hidden($self->session,{name=>"step", value=>2});
		$output .= '<div class="chooser">'.WebGUI::Form::radio($self->session,{name=>"layout", value=>1, checked=>1}).sprintf(q|<table class="representation"><tbody>
			<tr><td>%s</td><td>%s</td></tr>
			<tr><td>%s</td><td>%s</td></tr>
			</tbody></table></div>|,
			$i18n->get('logo'),
			$i18n->get('heading'),
			$i18n->get('menu'),
			$i18n->get('body content'),
			);
		$output .= '<div class="chooser">'.WebGUI::Form::radio($self->session,{name=>"layout", value=>2}).sprintf(q|<table class="representation"><tbody>
			<tr><td>%s</td><td>%s</td></tr>
			<tr><td style="text-align: center;" colspan="2">%s</td></tr>
			<tr><td colspan="2">%s</td></tr>
			</tbody></table></div>|,
			$i18n->get('logo'),
			$i18n->get('heading'),
			$i18n->get('menu'),
			$i18n->get('body content'),
			);
		$output .= WebGUI::Form::submit($self->session);
		$output .= WebGUI::Form::formFooter($self->session);
	}
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit template")) if ($self->get("url"));
        return $self->getAdminConsole->render($output,$i18n->get('style wizard'));
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getContainer->www_view;
}



1;
