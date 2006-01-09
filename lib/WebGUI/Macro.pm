package WebGUI::Macro;

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


use strict qw(vars subs);


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

my $parenthesis;
$parenthesis = qr /\(                      # Start with '(',
                     (?:                     # Followed by
                     (?>[^()]+)              # Non-parenthesis
                     |(??{ $parenthesis })   # Or a balanced parenthesis block
                     )*                      # zero or more times
                     \)/x;                  # Ending with ')'

my $nestedMacro;
$nestedMacro = qr /(\^                     # Start with carat
                     ([^\^;()]+)            # And one or more none-macro characters -tagged-
                     ((?:                   # Followed by
                     (??{ $parenthesis })   # a balanced parenthesis block
                     |(?>[^\^;])            # Or not a carat or semicolon
#                    |(??{ $nestedMacro }) # Or a balanced carat-semicolon block
                     )*)                    # zero or more times -tagged-
                     ;)/x;                   # End with  a semicolon.




#-------------------------------------------------------------------

=head2 filter ( html )

Removes all the macros from the HTML segment.

=head3 html

The segment to be filtered as a scalar reference.

=cut

sub filter {
	my $content = shift;
        while ($$content =~ /($nestedMacro)/gs) {
		$$content =~ s/\Q$1//gs;
	}
}


#-------------------------------------------------------------------

=head2 negate ( html )

Nullifies all macros in this content segment.

=head3 html

A scalar reference of HTML to be processed.

=cut

sub negate {
	my $html = shift;
	$$html =~ s/\^/\&\#94\;/g;
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
   	while ($$content =~ /$nestedMacro/gs) {
      		my ($macro, $searchString, $params) = ($1, $2, $3);
      		next if ($searchString =~ /^\d+$/); # don't process ^0; ^1; ^2; etc.
      		next if ($searchString =~ /^\-$/); # don't process ^-;
		if ($params ne "") {
      			$params =~ s/(^\(|\)$)//g; # remove parenthesis
      			&process(\$params); # recursive process params
		}
		my $macros = $session->config->get("macros");
		if ($macros->{$searchString} ne "") {
      			my $cmd = "WebGUI::Macro::".$macros->{$searchString};
			my $load = "use ".$cmd;
			eval($load);
			$session->errorHandler->error("Macro failed to compile: $cmd.".$@) if($@);
			my @param;
        		push(@param, $+) while $params =~ m {
                		"([^\"\\]*(?:\\.[^\"\\]*)*)",?
                		|       ([^,]+),?
                		|       ,
        			}gx;
        		push(@param, undef) if substr($params,-1,1) eq ',';
      			$cmd = $cmd."::process";
			my $result = eval{&$cmd($session,@param)};
			if ($@) {
				$session->errorHandler->error("Processing failed on macro: $macro: ".$@);
			} else {
				if ($result =~ /\Q$macro/) {
                                        $result = "Endless macro loop detected. Stopping recursion.";
					$session->errorHandler->warn($macro." : ".$result)
                                }
				$$content =~ s/\Q$macro/$result/ges;
			}
		}
   	}
}

1;

