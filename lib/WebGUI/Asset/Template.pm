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
		WebGUI::ErrorHandler::error("Error in template. ".$@);
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
		value=>$session{form}{returnUrl}
		});
	if ($self->getValue("namespace") eq "") {
		my $namespaces = WebGUI::SQL->buildHashRef("select distinct(namespace),namespace 
			from template order by namespace");
		$tabform->getTab("properties")->combo(
			-name=>"namespace",
			-options=>$namespaces,
			-label=>WebGUI::International::get('namespace','Asset_Template'),
			-hoverHelp=>WebGUI::International::get('namespace description','Asset_Template'),
			-value=>[$session{form}{namespace}] 
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
	my $sth = WebGUI::SQL->read("select asset.assetId, max(assetData.revisionDate) from template left join asset on asset.assetId=template.assetId left join assetData on assetData.revisionDate=template.revisionDate and assetData.assetId=template.assetId where template.namespace=".quote($namespace)." and template.showInForms=1 and asset.state='published' and (assetData.status='approved' or assetData.tagId=".quote($session{scratch}{versionTag}).") group by assetData.assetId order by assetData.title",WebGUI::SQL->getSlave);
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
	my $fileCacheDir = $session{config}{uploadsPath}.$session{os}{slash}."temp".$session{os}{slash}."templatecache";
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
        if ($session{config}{templateCacheType} =~ /file/) {
                eval { mkpath($fileCacheDir) };
                if($@) {
                        WebGUI::ErrorHandler::error("Could not create dir $fileCacheDir: $@\nTemplate file caching disabled");
			$error++;
		}
		if(not -w $fileCacheDir) {
			WebGUI::ErrorHandler::error("Directory $fileCacheDir is not writable. Template file caching is disabled");
			$error++;
		}
	}
	if ($session{config}{templateCacheType} eq "file" && not $error) {
	# disabled until we can figure out what's wrong with it
	#	$params{file_cache} = 1;
	} elsif ($session{config}{templateCacheType} eq "memory") {
		$params{cache} = 1;
	} elsif ($session{config}{templateCacheType} eq "ipc") {
		$params{shared_cache} = 1;
	} elsif ($session{config}{templateCacheType} eq "memory-ipc") {
		$params{double_cache} = 1;
	} elsif ($session{config}{templateCacheType} eq "memory-file" && not $error) {
		$params{double_file_cache} = 1;
	}
	my $template;
	unless (-e $file->getPath) {
		$file->saveFromScalar($self->get("template"));
		unless (-e $file->getPath) {
	                WebGUI::ErrorHandler::error("Could not create file ".$file->getPath."\nTemplate file caching is disabled");
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
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("template add/edit","Asset_Template");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('edit template', 'Asset_Template'));
}

#-------------------------------------------------------------------
sub www_goBackToPage {
	my $self = shift;
	WebGUI::HTTP::setRedirect($session{form}{returnUrl}) if ($session{form}{returnUrl});
	return "";
}


#-------------------------------------------------------------------
sub www_manage {
	my $self = shift;
	#takes the user to the folder containing this template.
	return $self->getParent->www_manageAssets;
}




#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getContainer->www_view;
}



1;

