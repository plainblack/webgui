package WebGUI::Macro;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict qw(vars subs);
use WebGUI::ErrorHandler;
use WebGUI::Session;


=head1 NAME

Package WebGUI::Macro

=head1 DESCRIPTION

This package is the interface to the WebGUI macro system.

NOTE: This entire system is likely to be replaced in the near future.  It has served WebGUI well since the very beginning but lacks the speed and flexibility that WebGUI users will require in the future.

=head1 SYNOPSIS

 use WebGUI::Macro;
 $html = WebGUI::Macro::filter($html);
 @array = WebGUI::Macro::getParams($parameterString);
 $html = WebGUI::Macro::negate($html);
 $html = WebGUI::Macro::process($html);

=head1 METHODS

These functions are available from this package:

=cut



our $nestedMacro = qr /(\^                     # Start with carat
                     ([^\^;()]+)            # And one or more none-macro characters -tagged-
                     ((?:                   # Followed by
                     (??{ $parenthesis })   # a balanced parenthesis block
                     |(?>[^\^;])            # Or not a carat or semicolon
#                    |(??{ $nestedMacro }) # Or a balanced carat-semicolon block
                     )*)                    # zero or more times -tagged-
                     ;)/x;                   # End with  a semicolon.



our $parenthesis = qr /\(                      # Start with '(',
                     (?:                     # Followed by
                     (?>[^()]+)              # Non-parenthesis
                     |(??{ $parenthesis })   # Or a balanced parenthesis block
                     )*                      # zero or more times
                     \)/x;                  # Ending with ')'

#-------------------------------------------------------------------

=head2 filter ( html )

Removes all the macros from the HTML segment.

=over

=item html

The segment to be filtered.

=back

=cut

sub filter {
	my $content = shift;
        while ($content =~ /($nestedMacro)/gs) {
		$content =~ s/\Q$1//gs;
	}
	return $content;
}


#-------------------------------------------------------------------

=head2 getParams ( parameterString )

A simple, but error prone mechanism for getting a prameter list from a string. Returns an array of parameters.

=over

=item parameterString

A string containing a comma separated list of paramenters.

=back

=cut

sub getParams {
        my ($data, @param);
        $data = $_[0];
        push(@param, $+) while $data =~ m {
                "([^\"\\]*(?:\\.[^\"\\]*)*)",?
                |       ([^,]+),?
                |       ,
        }gx;
        push(@param, undef) if substr($data,-1,1) eq ',';
	return @param;
}

#-------------------------------------------------------------------

=head2 negate ( html )

Nullifies all macros in this content segment.

=over

=item html

A string of HTML to be processed.

=back

=cut

sub negate {
	my $html = $_[0];
	$html =~ s/\^/\&\#94\;/g;
	return $html;
}


#-------------------------------------------------------------------

=head2 process ( html )

Runs all the WebGUI macros to and replaces them in the HTML with their output.

=over

=item html

A string of HTML to be processed.

=back

=cut

sub process {
   	my $content = shift;
   	while ($content =~ /$nestedMacro/gs) {
      		my ($macro, $searchString, $params) = ($1, $2, $3);
      		next if ($searchString =~ /^\d+$/); # don't process ^0; ^1; ^2; etc.
      		next if ($searchString =~ /^\-$/); # don't process ^-;
		if ($params ne "") {
      			$params =~ s/(^\(|\)$)//g; # remove parenthesis
      			$params = &process($params); # recursive process params
		}
		if ($session{config}{macros}{$searchString} ne "") {
      			my $cmd = "WebGUI::Macro::".$session{config}{macros}{$searchString}."::process";
			my $result = eval{&$cmd($params)};
			if ($@) {
				WebGUI::ErrorHandler::warn("Processing failed on macro: $macro: ".$@);
			} else {
				$content =~ s/\Q$macro/$result/ges;
			}
		}
   	}
   	return $content;
}



1;

