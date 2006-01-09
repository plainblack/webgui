package WebGUI::Asset::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use HTML::Template;
use strict;
use WebGUI::Asset;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Storage;

our @ISA = qw(WebGUI::Asset);


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
sub _getTemplateFile {
	my $templateId = shift;
	my $filename = $templateId.".tmpl";
	$filename =~ s/\//-/g;
	$filename =~ s/ /-/g;
	return WebGUI::Attachment->new($filename,"temp","templates");
}


#-------------------------------------------------------------------
sub _execute {
	my $params = shift;
	my $vars = shift;
	my $t;
	eval {
		$t = HTML::Template->new(%{$params});
	};
	unless ($@) {
	        while (my ($section, $hash) = each %session) {
			next unless (ref $hash eq 'HASH');
        		while (my ($key, $value) = each %$hash) {
        	                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                	        	$t->param("session.".$section.".".$key=>$value);
                        	}
	                }
        	} 
		$t->param(%{$vars});
		$t->param("webgui.version"=>$WebGUI::VERSION);
		$t->param("webgui.status"=>$WebGUI::STATUS);
		return $t->output;
	} else {
		$self->session->errorHandler->error("Error in template. ".$@);
		return WebGUI::International::get('template error', 'Asset_Template').$@;
	}
}


#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_Template"),
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
				namespace=>{
					fieldType=>'combo',
					defaultValue=>undef
					}
                        }
                });
        return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->hidden({
		name=>"returnUrl",
		value=>$self->session->form->process("returnUrl")
		});
	if ($self->getValue("namespace") eq "") {
		my $namespaces = $self->session->db->buildHashRef("select distinct(namespace),namespace 
			from template order by namespace");
		$tabform->getTab("properties")->combo(
			-name=>"namespace",
			-options=>$namespaces,
			-label=>WebGUI::International::get('namespace','Asset_Template'),
			-hoverHelp=>WebGUI::International::get('namespace description','Asset_Template'),
			-value=>[$self->session->form->process("namespace")] 
			);
	} else {
		$tabform->getTab("meta")->readOnly(
			-label=>WebGUI::International::get('namespace','Asset_Template'),
			-hoverHelp=>WebGUI::International::get('namespace description','Asset_Template'),
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
		-label=>WebGUI::International::get('show in forms', 'Asset_Template'),
		-hoverHelp=>WebGUI::International::get('show in forms description', 'Asset_Template'),
		);
        $tabform->getTab("properties")->codearea(
		-name=>"template",
		-label=>WebGUI::International::get('assetName', 'Asset_Template'),
		-hoverHelp=>WebGUI::International::get('template description', 'Asset_Template'),
		-value=>$self->getValue("template")
		);
	return $tabform;
}





#-------------------------------------------------------------------

=head2 getList ( namespace )

Returns a hash reference containing template ids and template names of all the templates in the specified namespace.

NOTE: This is a class method.

=head3 namespace

Specify the namespace to build the list for.

=cut

sub getList {
	my $class = shift;
	my $namespace = shift;
my $sql = "select asset.assetId, assetData.revisionDate from template left join asset on asset.assetId=template.assetId left join assetData on assetData.revisionDate=template.revisionDate and assetData.assetId=template.assetId where template.namespace=".$self->session->db->quote($namespace)." and template.showInForms=1 and asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).")) order by assetData.title";
	my $sth = $self->session->db->read($sql,$self->session->db->getSlave);
	my %templates;
	tie %templates, 'Tie::IxHash';
	while (my ($id, $version) = $sth->array) {
		$templates{$id} = WebGUI::Asset::Template->new($id,undef,$version)->getTitle;
	}	
	$sth->finish;	
	return \%templates;
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
	return $self->processRaw($self->get("template"),$vars);
# skip all the junk below here for now until we have time to bring it inline with the new system
	my $file = _getTemplateFile($self->get("templateId"));
	my $fileCacheDir = $self->session->config->get("uploadsPath").'/temp/templatecache';
	my %params = (
		filename=>$file->getPath,
		global_vars=>1,
   		loop_context_vars=>1,
		die_on_bad_params=>0,
		no_includes=>1,
		file_cache_dir=>$fileCacheDir,
		strict=>0
		);
	my $error=0;
        if ($self->session->config->get("templateCacheType") =~ /file/) {
                eval { mkpath($fileCacheDir) };
                if($@) {
                        $self->session->errorHandler->error("Could not create dir $fileCacheDir: $@\nTemplate file caching disabled");
			$error++;
		}
		if(not -w $fileCacheDir) {
			$self->session->errorHandler->error("Directory $fileCacheDir is not writable. Template file caching is disabled");
			$error++;
		}
	}
	if ($self->session->config->get("templateCacheType") eq "file" && not $error) {
	# disabled until we can figure out what's wrong with it
	#	$params{file_cache} = 1;
	} elsif ($self->session->config->get("templateCacheType") eq "memory") {
		$params{cache} = 1;
	} elsif ($self->session->config->get("templateCacheType") eq "ipc") {
		$params{shared_cache} = 1;
	} elsif ($self->session->config->get("templateCacheType") eq "memory-ipc") {
		$params{double_cache} = 1;
	} elsif ($self->session->config->get("templateCacheType") eq "memory-file" && not $error) {
		$params{double_file_cache} = 1;
	}
	my $template;
	unless (-e $file->getPath) {
		$file->saveFromScalar($self->get("template"));
		unless (-e $file->getPath) {
	                $self->session->errorHandler->error("Could not create file ".$file->getPath."\nTemplate file caching is disabled");
        	        $params{scalarref} = \$template;
			delete $params{filename};
        	}
	}
	return _execute(\%params,$vars);
}




#-------------------------------------------------------------------

=head2 processRaw ( template, vars )

Evaluate a template replacing template commands for HTML. 

NOTE: This is a class method, no instance data required.

=head3 template

A scalar variable containing the template.

=head3 vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

=cut

sub processRaw {
	my $class = shift;
	my $template = shift;
	my $vars = shift;
	return _execute({
		scalarref=>\$template,
		global_vars=>1,
   		loop_context_vars=>1,
		die_on_bad_params=>0,
		no_includes=>1,
		strict=>0 
		},$vars);
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if (WebGUI::Session::isAdminOn()) {
		return $self->getToolbar;
	} else {
		return "";
	}
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("template add/edit","Asset_Template");
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=styleWizard'),WebGUI::International::get("style wizard","Asset_Template")) if ($self->get("namespace") eq "style");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('edit template', 'Asset_Template'));
}

#-------------------------------------------------------------------
sub www_goBackToPage {
	my $self = shift;
	WebGUI::HTTP::setRedirect($self->session->form->process("returnUrl")) if ($self->session->form->process("returnUrl"));
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
	my $output = "";
	if ($self->session->form->process("step") == 2) {
		my $f = WebGUI::HTMLForm->new({action=>$self->getUrl});
		$f->hidden(name=>"func", value=>"styleWizard");
		$f->hidden(name=>"proceed", value=>"manageAssets") if ($self->session->form->process("proceed"));
		$f->hidden(name=>"step", value=>3);
		$f->hidden(name=>"layout", value=>$self->session->form->process("layout"));
		$f->text(name=>"heading", value=>"My Site", label=>"Site Name");
		$f->file(name=>"logo", label=>"Logo", subtext=>"<br />JPEG, GIF, or PNG thats less than 200 pixels wide and 100 pixels tall");
		$f->color(name=>"pageBackgroundColor", value=>"#ccccdd", label=>"Page Background Color");
		$f->color(name=>"headingBackgroundColor", value=>"#ffffff", label=>"Header Background Color");
		$f->color(name=>"headingForegroundColor", value=>"#000000", label=>"Header Text Color");
		$f->color(name=>"bodyBackgroundColor", value=>"#ffffff", label=>"Body Background Color");
		$f->color(name=>"bodyForegroundColor", value=>"#000000", label=>"Body Text Color");
		$f->color(name=>"menuBackgroundColor", value=>"#eeeeee", label=>"Menu Background Color");
		$f->color(name=>"linkColor", value=>"#0000ff", label=>"Link Color");
		$f->color(name=>"visitedLinkColor", value=>"#ff00ff", label=>"Visited Link Color");
		$f->submit;
		$output = $f->print;
	} elsif ($self->session->form->process("step") == 3) {
		my $storageId = $self->session->form->file("logo");
		my $logo;
		if ($storageId) {
			my $storage = WebGUI::Storage::Image->get($self->session->form->file("logo"));
			$logo = $self->addChild({
				className=>"WebGUI::Asset::File::Image",
				title=>$self->session->form->text("heading")." Logo",
				menuTitle=>$self->session->form->text("heading")." Logo",
				url=>$self->session->form->text("heading")." Logo",
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
		background-color: '.$self->session->form->color("pageBackgroundColor").';
		font-family: helvetica;
		font-size: 14px;
	}
	.heading {
		background-color: '.$self->session->form->color("headingBackgroundColor").';
		color: '.$self->session->form->color("headingForegroundColor").';
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
		background-color: '.$self->session->form->color("bodyBackgroundColor").';
		color: '.$self->session->form->color("bodyForegroundColor").';
		width: 55%; ';
if ($self->session->form->process("layout") == 1) {
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
		background-color: '.$self->session->form->color("menuBackgroundColor").';
		width: 25%; ';
if ($self->session->form->process("layout") == 1) {
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
		color: '.$self->session->form->color("linkColor").';
	}
	a:visited {
		color: '.$self->session->form->color("visitedLinkColor").';
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
		'.$self->session->form->text("heading").'
		<div class="endFloat"></div>
	</div>
</div>
<div class="menu">
	<div class="padding">^AssetProxy('.($self->session->form->process("layout") == 1 ? 'flexmenu' : 'toplevelmenuhorizontal').');</div>
</div>
<div class="bodyContent">
	<div class="padding"><tmpl_var body.content></div>
</div>';
if ($self->session->form->process("layout") == 1) {
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
		$output = WebGUI::Form::formHeader({action=>$self->getUrl}).WebGUI::Form::hidden({name=>"func", value=>"styleWizard"});
		$output .= WebGUI::Form::hidden({name=>"proceed", value=>"manageAssets"}) if ($self->session->form->process("proceed"));
		$output .= '<style type="text/css">
			.chooser { float: left; width: 150px; height: 150px; } 
			.representation, .representation td { font-size: 12px; width: 120px; border: 1px solid black; } 
			.representation { height: 130px; }
			</style>';
		$output .= "<p>Choose a layout for this style:</p>";
		$output .= WebGUI::Form::hidden({name=>"step", value=>2});
		$output .= '<div class="chooser">'.WebGUI::Form::radio({name=>"layout", value=>1, checked=>1}).q|<table class="representation"><tbody>
			<tr><td>Logo</td><td>Heading</td></tr>
			<tr><td>Menu</td><td>Body content goes here.</td></tr>
			</tbody></table></div>|;
		$output .= '<div class="chooser">'.WebGUI::Form::radio({name=>"layout", value=>2}).q|<table class="representation"><tbody>
			<tr><td>Logo</td><td>Heading</td></tr>
			<tr><td style="text-align: center;" colspan="2">Menu</td></tr>
			<tr><td colspan="2">Body content goes here.</td></tr>
			</tbody></table></div>|;
		$output .= WebGUI::Form::submit();
		$output .= WebGUI::Form::formFooter();
	}
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),WebGUI::International::get("edit template","Asset_Template")) if ($self->get("url"));
        return $self->getAdminConsole->render($output,WebGUI::International::get('style wizard', 'Asset_Template'));
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getContainer->www_view;
}



1;

