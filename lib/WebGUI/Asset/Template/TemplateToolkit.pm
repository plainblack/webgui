package WebGUI::Asset::Template::TemplateToolkit;

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
use base 'WebGUI::Asset::Template::Parser';
use Template;

#-------------------------------------------------------------------
sub _rewriteVars { # replace dots with underscrores in keys (except in keys that aren't usable as variables (URLs etc.))
        my $vars = shift;
	my $newVars = {};
        foreach my $key (keys %$vars){
                my $newKey = $key;
                $newKey =~ s/\./_/g if $newKey !~ /\//;
		if ( ref $vars->{$key} eq 'ARRAY') {
			foreach my $entry (@{$vars->{$key}}) {
				push(@{$newVars->{$newKey}}, _rewriteVars($entry));
			}
                } elsif(ref $vars->{$key} eq 'HASH') {
                        $newVars->{$newKey} = _rewriteVars($vars->{$key});
                } else {
                        $newVars->{$newKey} = $vars->{$key};
                }
        }
        return $newVars;
}

#-------------------------------------------------------------------

=head2 getName ( )

Returns the human readable name of this parser.

=cut

sub getName {
        my $self = shift;
        return "Template Toolkit";
}

#-------------------------------------------------------------------

=head2 process ( template, vars )

Evaluate a template replacing template commands for HTML. 

=head3 template

A scalar variable containing the template.

=head3 vars

A hash reference containing template variables and loops.

=cut

# TODO: Have this throw an error so we can catch it and print more information
# about the template that has the error. Finding an "ERROR: Error in template" 
# in the error log is not very helpful...
sub process {
    my $self = shift;
    my $template = shift;
    my $vars = $self->addSessionVars(shift);
    my ($t,$output);
    eval {
        $t = Template->new({
            INTERPOLATE  => 1,               # expand "$var" in plain text
            POST_CHOMP   => 1,               # cleanup whitespace 
            EVAL_PERL    => 0,               # evaluate Perl code blocks
        });
        unless ($t->process( \$template, _rewriteVars($vars),\$output)) {
            my $e = $t->error;
            $self->session->log->error($e);
            die $e;
        }
    };
    if ($@) {
        WebGUI::Error::Template->throw( error => $@ );
    }
    return $output;
}

1;
