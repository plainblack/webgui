package WebGUI::Asset::Wobject::HttpProxy::Parse;

use strict;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use HTML::Parser;
use HTML::Entities;
use URI::URL;
use parent qw(HTML::Parser);

=head1 NAME

Package WebGUI::Asset::Wobject::HttpProxy::Parse

=head1 DESCRIPTION

HTML parser for Asset::Wobject::HttpProxy.  Is not able to parse its
own output.

=cut
 
my %tag_attr = (
	"body background" => 1,
	"base href" => 1,
	"a href" => 1,
	"img src" => 1,
	"img lowsrc" => 1,
	"img usemap" => 1,
	"form action" => 1,
	"input src" => 1,
	"link href" => 1,
	"frame src" => 1,
	"applet codebase" => 1,
	"iframe src" => 1,
	"area href" => 1,
	"script src" => 1
	);

=head2 new ( $class, $session)

Constructor for parser.

=cut

sub new {
  	my $pack = shift;
  	my $self = $pack->SUPER::new();
  	$self->{_session} = shift;
  	$self->{Url} = shift;
  	$self->{Content} = shift;
  	$self->{assetId} = shift;
	$self->{rewriteUrls} = shift;
	$self->{assetUrl} = shift;
    
    my $pfilter = shift;
    $pfilter =~ s/\r//g;
    my @patterns = split(/\n/,$pfilter); 
    $self->{patternFilter} = \@patterns;
   
    $self->{Filtered} ="";
  	$self->{FormAction} = "";
  	$self->{FormActionIsDefined} = 0;
	$self->{recurseCheck} = 0;
  	$self;
}


=head2 filter 

=cut

sub filter {
  	my $self=shift;
  	$self->parse($self->{Content}); # Make paths absolute and let them return to us
  	$self->eof;
	my $i18n = WebGUI::International->new($self->session, 'Asset_HttpProxy');
	return $i18n->get('no recursion') if ($self->{recurseCheck});
  	return $self->{Filtered};
}

## some items stolen from HTML::Filter




=head2 output ( $text )

Appends $text to the filtered output.

=cut

sub output { 
	$_[0]->{Filtered} .= $_[1]; 
}

=head2 declaration ($text)

Adds $text as an HTML declaration

=cut

sub declaration { 
	$_[0]->output("<!$_[1]>") 
}



=head2 comment ($text)

Adds $text as an HTML comment

=cut

sub comment { 
	$_[0]->output("<!--$_[1]-->") 
}


=head2 text ($text)

Adds $text as direct text

=cut

sub text { 
	$_[0]->output($_[1]) 
}

=head2 end ($text)

Adds $text as a closing HTML tag.

=cut

sub end { 
	$_[0]->output("</$_[1]>") 
}


=head2 session 

Returns a copy of the session variable.

=cut

sub session { 
	return $_[0]->{_session};
}


=head2 start 

Override the method from the master class to handle recursing through the content and
rewriting URLs.

=cut

sub start {
  	my $self = shift;
  	my ($tag, $attr, $attrseq, $origtext) = @_;
    
    # Set a flag for self-closing tags
    my $selfclose;
    
    # Check on the div class and div id attributes to see if we're proxying ourself.
	if($tag eq "div" && $attr->{'class'} eq 'wobjectHttpProxy' && $attr->{'id'} eq ('assetId'.$self->{assetId})) { 
		$self->{recurseCheck} = 1;
	}
  	$self->output("<$tag");
  	for (keys %$attr) {
		if ($_ eq '/') {
		   $selfclose   = 1;
		   next;
		}
    		$self->output(" $_=\"");
    		my $val = $attr->{$_};
    		if ( $self->{ rewriteUrls } && (lc($tag) eq "input" || lc($tag) eq "textarea" || lc($tag) eq "select") 
       			&& (lc($_) eq "name" || lc($_) eq "submit")) {  # Rewrite input type names
      			$val = 'HttpProxy_' . $val;
    		}
    		if (lc($tag) eq "form" && not $self->{FormActionIsDefined}) {
       			$self->{FormAction} = $self->{Url};
    		}
    		if ($tag_attr{"$tag $_"}) { # needs rewrite
      			if ($val =~ /^\?/) {   # link that starts with ?  i.e. <a href="?var=hello">
				my @urlBase = split(/\?/, $self->{Url}); 
				$val = URI::URL::url($urlBase[0] . $val);

                        # catch internal # anchors
                        } elsif ($val =~ /^#/){
                                $val = URI::URL::url($val);
                        
      			} else {
        			$val = URI::URL::url($val)->abs($self->{Url},1); # make absolute
      			}
      			if ($val->scheme eq "http" || $val->scheme eq "https") {
        			if ($self->{rewriteUrls} && lc($tag) ne "iframe") { 
          				if (lc($tag) eq "form" && lc($_) eq "action") {  # Found FORM ACTION
	    					$self->{FormActionIsDefined}=1;
            					$self->{FormAction} = $val;  # set FormAction to include hidden field later
            					$val = $self->{assetUrl};    # Form Action returns to us
          				} else {
						    $val =~ s/\n//g;	# Bugfix 757068
                            
                            #Determine if pattern should not be rewritten
                            my $rewritePattern = 0;
                            foreach my $pattern (@{$self->{patternFilter}}) {
                                if($val =~ m/$pattern/i) {
                                    $rewritePattern = 1;
                                } 
                            }
                              
                            if($rewritePattern) {
                                $val = URI::URL::url($val)->abs($self->{Url},1); # make absolute
                            }
                            else {
                                $val = $self->session->url->append($self->{assetUrl},'proxiedUrl='.$self->session->url->escape($val).';func=view'); # return to us
                            }
                        }
        			}
      			}
    		}
    		$self->output($val.'"');
  	}

    # Close the tag
    if ( $selfclose ) {
        $self->output( " /" );
    }
  	$self->output(">");

    # Prepare our form action if necessary
  	if ($self->{ rewriteUrls } && $self->{FormAction} ne "") {
    		$self->output('<input type="hidden" name="FormAction" value="'.$self->{FormAction}.'">');
    		$self->output('<input type="hidden" name="func" value="view">');
    		$self->{FormAction} = '';
    		$self->{FormActionIsDefined}=0;
  	}
}


1;
