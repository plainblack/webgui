package WebGUI::Asset::Wobject::HttpProxy::Parse;


# -------------------------------------------------------------------
#  WebGUI is Copyright 2001-2006 Plain Black Corporation.
# -------------------------------------------------------------------
#  Please read the legal notices (docs/legal.txt) and the license
#  (docs/license.txt) that came with this distribution before using
#  this software.
# -------------------------------------------------------------------
#  http://www.plainblack.com                     info@plainblack.com
# -------------------------------------------------------------------


use HTML::Parser;
use HTML::Entities;
use URI::URL;
use WebGUI::URL;  
use vars qw(@ISA);
@ISA = qw(HTML::Parser);

 
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

sub DESTROY {
	my $self = shift;
	$self = undef;
}

sub new {
  	my $pack = shift;
  	my $self = $pack->SUPER::new();
  	$self->{Url} = shift;
  	$self->{Content} = shift;
  	$self->{assetId} = shift;
	$self->{rewriteUrls} = shift;
	$self->{assetUrl} = shift;
  	$self->{Filtered} ="";
  	$self->{FormAction} = "";
  	$self->{FormActionIsDefined} = 0;
	$self->{recurseCheck} = 0;
  	$self;
}


sub filter {
  	my $self=shift;
  	$self->parse($self->{Content}); # Make paths absolute and let them return to us
  	$self->eof;
	return "<p>Error: HttpProxy can't recursively proxy its own content.</p>" if ($self->{recurseCheck});
  	return $self->{Filtered};
}

## some items stolen from HTML::Filter



sub output { 
	$_[0]->{Filtered} .= $_[1]; 
}


sub declaration { 
	$_[0]->output("<!$_[1]>") 
}


sub comment { 
	$_[0]->output("<!--$_[1]-->") 
}

sub text { 
	$_[0]->output($_[1]) 
}


sub end { 
	$_[0]->output("</$_[1]>") 
}

sub start {
  	my $self = shift;
  	my ($tag, $attr, $attrseq, $origtext) = @_;
	# Check on the div class and div id attributes to see if we're proxying ourself.
	if($tag eq "div" && $attr->{'class'} eq 'wobjectHttpProxy' && $attr->{'id'} eq ('assetId'.$self->{assetId})) { 
		$self->{recurseCheck} = 1;
	}
  	$self->output("<$tag");
  	for (keys %$attr) {
		if ($_ eq '/') {
		   $self->output('/');
		   next;
		}
    		$self->output(" $_=\"");
    		my $val = $attr->{$_};
    		if ((lc($tag) eq "input" || lc($tag) eq "textarea" || lc($tag) eq "select") 
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
            					$val = $self->session->url->append($self->{assetUrl},'proxiedUrl='.$self->session->url->escape($val).';func=view'); # return to us
          				}
        			}
      			}
    		}
    		$self->output($val.'"');
  	}
  	$self->output(">");
  	if ($self->{FormAction} ne "") {
    		$self->output('<input type="hidden" name="FormAction" value="'.$self->{FormAction}.'">');
    		$self->output('<input type="hidden" name="func" value="view">');
    		$self->{FormAction} = '';
    		$self->{FormActionIsDefined}=0;
  	}
}


1;
