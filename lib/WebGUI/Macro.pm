package WebGUI::Macro;

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
use 5.010;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Macro

=head1 DESCRIPTION

This package is the interface to the WebGUI macro system.

B<NOTE:> This entire system is likely to be replaced in the near future.  It has served WebGUI well since the very beginning but lacks the speed and flexibility that WebGUI users will require in the future.

=head1 SYNOPSIS

 use WebGUI::Macro;

 WebGUI::Macro::filter(\$html);
 WebGUI::Macro::negate(\$html);
 WebGUI::Macro::process($self->session,\$html);

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------
my $macro_re = qr{
    (                               # capture #1 - entire macro call
        \^                              # start with carat
        ([-a-zA-Z0-9_@#/*]{1,64})       # capture #2 - macro name
        (                               # capture #3 - parenthesis
            \(                              # start with open parenthesis
            (?:                             # followed by
                (?> [^()] )                     # non-parenthesis
            |                               # or
                (?>\\[()])                      # Escaped parenthesis
            |                               # or
                (?3)                            # a balanced parenthesis block (recursive)
            )*                              # zero or more times
            \)                              # ending with closing parenthesis
        )?
        ;                               # End with a semicolon.
    )
}msx;

=head2 filter ( html )

Removes all the macros from the HTML segment.

=head3 html

The segment to be filtered as a scalar reference.

=cut

sub filter {
    my $content = shift;
    ${ $content } =~ s/$macro_re//g;
}


#-------------------------------------------------------------------

=head2 negate ( html )

Nullifies all macros in this content segment.

=head3 html

A scalar reference of HTML to be processed.

=cut

sub negate {
    my $html = shift;
    ${ $html } =~ s/\^/&#94;/g;
}


#-------------------------------------------------------------------

=head2 process ( session, html )

Runs all the WebGUI macros to and replaces them in the HTML with their output.

=head3 session

A reference to the current session.

=head3 html

A scalar reference of HTML to be processed.

=cut


sub process {
    my $session = shift;
    my $content = shift;
    return '' if !defined $content;
    our $macrodepth ||= 0;
    local $macrodepth = $macrodepth + 1;
    ${ $content } =~ s{$macro_re}{
        if ( $macrodepth > 16 ) {
            $session->errorHandler->error($2 . " : Too many levels of macro recursion.  Stopping.");
            "Too many levels of macro recursion. Stopping.";
        }
        else {
            my $initialText = $1;
            my $replaceText = _processMacro($session, $2, $3);
            # _processMacro returns undef on failure, use original text
            defined $replaceText ? $replaceText : $initialText;
        }
    }ge;
}


# _processMacro ( $session, $macroname, $parameters )
# processes an individual macro, taking the macro name and parameters as a string
# returns the result text or undef on failure

sub _processMacro {
    my $session = shift;
    my $macroname = shift;
    my $parameters = shift;
    if ($macroname =~ /^[-0-9]$/) {    # ^0; ^1; ^2; and ^-; have special uses, don't replace
        return;
    }
    my $macrofile = $session->config->get("macros")->{$macroname};
    if (!$macrofile) {
        $session->errorHandler->error("No macro with name $macroname defined.");
        return;
    }
    my $macropackage = "WebGUI::Macro::$macrofile";
    if (! eval { WebGUI::Pluggable::load($macropackage) } ) {
        $session->log->error($@);
        return;
    }
    my $process = $macropackage->can('process');
    if (!$process) {
        $session->log->error("Macro has no process sub: $macropackage.");
        return;
    }
    $parameters =~ s/^\(//;
    $parameters =~ s/\)$//;

    my @params;
    while ($parameters =~ m{
        (?<!\z)                             # don't try to match if we are at the end of the string
        (?:                                 # either
            \s* "                               # white space followed by a double quote
            ( (?:                               # capture inside
                [^"\\]                              # something other than backslash or double quote
            |                                   # or
                \\.                                 # a backslash followed by any character
            ) * )                               # as many times as needed
            " \s*                              # end quote and any white space
        |                                   # or
            \s* '                               # same as above, but with single quotes
            ( (?:
                [^'\\]
            |
                \\.
            ) * )
            ' \s*
        |                                   # or
            ([^,]*)                             # anything but a comma
        )
        (?:                                 # followed by
            \z                                  # end of the string
        |                                   # or
            ,                                   # a comma
        )
    }xg) {
        # three matches, only one will exist per run
        push @params, $+;
    }

    for my $param (@params) {
        $param =~ s/\\(.)/$1/xmsg;      # deal with backslash escapes
        process($session, \$param)
            if ($param);                # process any macros
    }
    my $output;
    unless ( eval { $output = $process->($session, @params); 1 } ) {         # call process sub with parameters
        $session->log->error("Unable to process macro '$macroname': $@");
        return;
    }
    $output = ''
        if !defined $output;
    process($session, \$output);                                            # also need to process macros on output
    return $output;
}

1;

