package WebGUI::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::ErrorHandler;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::Template

=head1 DESCRIPTION

This package contains utility methods for WebGUI's template system.

=head1 SYNOPSIS

 use WebGUI::Template;
 $template = WebGUI::Template::get($templateId, $namespace);
 $hashRef = WebGUI::Template::getList($namespace);
 $html = WebGUI::Template::process($template);

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 get ( [ templateId, namespace ] )

Returns a template.

=over

=item templateId

Defaults to "1". Specify the templateId of the template to retrieve.

=item namespace

Defaults to "Page". Specify the namespace of the template to retrieve.

=back

=cut

sub get {
	my $templateId = $_[0] || 1;
	my $namespace = $_[1] || "Page";
        my ($template) = WebGUI::SQL->quickArray("select template from template 
		where templateId=".$templateId." and namespace=".quote($namespace));
        return $template;
}


#-------------------------------------------------------------------

=head2 getList ( [ namespace ] )

Returns a hash reference containing template ids and template names of all the templates in the specified namespace.

=over

=item namespace

Defaults to "Page". Specify the namespace to build the list for.

=back

=cut

sub getList {
	my $namespace = $_[0] || "Page";
	return WebGUI::SQL->buildHashRef("select templateId,name from template where namespace=".quote($namespace)." and showInForms=1 order by name");
}


#-------------------------------------------------------------------

=head2 process ( template [ , vars ] )

Evaluate a template replacing template commands for HTML.

=over

=item template

The template to process.

=item vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

=back

=cut

sub process {
	my ($t, $test, $html);
	$html = $_[0];
	eval {
		$t = HTML::Template->new(
   			scalarref=>\$html,
			global_vars=>1,
   			loop_context_vars=>1,
			die_on_bad_params=>0,
			strict=>0
			);
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
		$t->param(%{$_[1]});
		$t->param("webgui.version"=>$WebGUI::VERSION);
		return $t->output;
	} else {
		WebGUI::ErrorHandler::warn("Error in template. ".$@);
		return WebGUI::International::get(848).$html;
	}
}


1;

