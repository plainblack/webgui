package WebGUI::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut



use File::Path;
use HTML::Template;
use strict;
use WebGUI::Attachment;
use WebGUI::ErrorHandler;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Template

=head1 DESCRIPTION

This package contains utility methods for WebGUI's template system.

=head1 SYNOPSIS

 use WebGUI::Template;
 $hashRef = WebGUI::Template::get($templateId, $namespace);
 $hashRef = WebGUI::Template::getList($namespace);
 $templateId = WebGUI::Template::getIdByName($name,$namespace);
 $html = WebGUI::Template::process($templateId, $namespace, $vars);
 $templateId = WebGUI::Template::set(\%data);

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------
sub _getTemplateFile {
	my $templateId = shift;
	my $namespace = shift;
	my $filename = $namespace."-".$templateId.".tmpl";
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
		WebGUI::ErrorHandler::warn("Error in template. ".$@);
		return WebGUI::International::get(848).$@;
	}
}

#-------------------------------------------------------------------

=head2 get ( templateId, namespace )

Returns a hash reference containing all of the template parameters.

=head3 templateId

Specify the templateId of the template to retrieve.

=head3 namespace

Specify the namespace of the template to retrieve.

=cut

sub get {
	my $templateId = shift;
	my $namespace = shift;
        return WebGUI::SQL->quickHashRef("select * from template where templateId=".quote($templateId)." and namespace=".quote($namespace),WebGUI::SQL->getSlave);
}


#-------------------------------------------------------------------

=head2 getList ( [ namespace ] )

Returns a hash reference containing template ids and template names of all the templates in the specified namespace.

=head3 namespace

Defaults to "page". Specify the namespace to build the list for.

=cut

sub getList {
	my $namespace = $_[0] || "page";
	return WebGUI::SQL->buildHashRef("select templateId,name from template where namespace=".quote($namespace)." and showInForms=1 order by name",WebGUI::SQL->getSlave);
}


#-------------------------------------------------------------------

=head2 getIdByName ( name, namespace ) {

Returns a template ID by looking up the name for it.

=head3 name

The name to look up.

=head3 namespace

The namespace to focus on when searching.

=cut

sub getIdByName {
	my $name = shift;
	my $namespace = shift;
	my ($templateId) = WebGUI::SQL->quickArray("select templateId from template where namespace=".quote($namespace)." and name=".quote($name),WebGUI::SQL->getSlave);
	return $templateId;
}



#-------------------------------------------------------------------

=head2 process ( templateId, namespace, vars )

Evaluate a template replacing template commands for HTML.

=head3 templateId

Specify the templateId of the template to retrieve.

=head3 namespace

Specify the namespace of the template to retrieve.

=head3 vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

=cut

sub process {
	my $templateId = shift;
	my $namespace = shift;
	my $vars = shift;
	my $file = _getTemplateFile($templateId,$namespace);
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
                        WebGUI::ErrorHandler::warn("Could not create dir $fileCacheDir: $@\nTemplate file caching disabled");
			$error++;
		}
		if(not -w $fileCacheDir) {
			WebGUI::ErrorHandler::warn("Directory $fileCacheDir is not writable. Template file caching is disabled");
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
	unless (-f $file->getPath) {
        	($template) = WebGUI::SQL->quickArray("select template from template where templateId=".quote($templateId)." and namespace=".quote($namespace),WebGUI::SQL->getSlave);
		$file->saveFromScalar($template);
		unless (-f $file->getPath) {
	                WebGUI::ErrorHandler::warn("Could not create file ".$file->getPath."\nTemplate file caching is disabled");
        	        $params{scalarref} = \$template;
			delete $params{filename};
        	}
	}
	return _execute(\%params,$vars);
}

#-------------------------------------------------------------------

=head2 processRaw ( template, vars )

Evaluate a template replacing template commands for HTML.

=head3 template

A scalar variable containing the template.

=head3 vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

=cut

sub processRaw {
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

=head2 set ( data )

Store a template and it's metadata.

=head3 data

A hash reference containing the data to be stored. At minimum the hash reference must include "templateId" and "namespace". The following are the elements allowed to be stored.

 templateId - The unique id for the template. If set to "new" then a new one will be generated.

 namespace - The namespace division for this template.

 template - The content of the template.

 name - A human friendly name for the template.

 showInForms - A boolean indicating whether this template should appear when using the "template" subroutine in WebGUI::Form.

 isEditable - A boolean indicating whether this template should be editable through the template manager. 

=cut

sub set {
	my $data = shift;
	if ($data->{templateId} eq "new") {
		$data->{templateId} = WebGUI::Id::generate();	
		WebGUI::SQL->write("insert into template (templateId,namespace) values (".quote($data->{templateId}).",".quote($data->{namespace}).")");
	}
	my @pairs;
	foreach my $key (keys %{$data}) {
		push(@pairs, $key."=".quote($data->{$key})) unless ($key eq "namespace" || $key eq "templateId");
	}
	WebGUI::SQL->write("update template set ".join(",",@pairs)." where templateId=".quote($data->{templateId})." and namespace=".quote($data->{namespace}));
	my $file = _getTemplateFile($data->{templateId},$data->{namespace});
	$file->delete;
	return $data->{templateId};
}

1;

