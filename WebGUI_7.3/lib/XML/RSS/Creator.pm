package XML::RSS::Creator;

use strict;
use Carp;
use vars qw($VERSION $AUTOLOAD @ISA);

$VERSION = '1.06';

my %v0_9_ok_fields = (
		      channel => {
				  title       => '',
				  description => '',
				  link        => '',
				 },
		      image  => {
				 title => '',
				 url   => '',
				 link  => ''
				},
		      textinput => {
				    title       => '',
				    description => '',
				    name        => '',
				    link        => ''
				   },
		      items => [],
		      num_items => 0,
		      version         => '',
		      encoding        => ''
		     );

my %v0_9_1_ok_fields = (
			channel => {
				    title          => '',
				    copyright      => '',
				    description    => '',
				    docs           => '',
				    language       => '',
				    lastBuildDate  => '',
				    link           => '',
				    managingEditor => '',
				    pubDate        => '',
				    rating         => '',
				    webMaster      => ''
				   },
			image  => {
				   title       => '',
				   url         => '',
				   link        => '',
				   width       => '',
				   height      => '',
				   description => ''
				  },
			skipDays  => {
				      day         => ''
				     },
			skipHours => {
				      hour        => ''
				     },
			textinput => {
				      title       => '',
				      description => '',
				      name        => '',
				      link        => ''
				     },
			items           => [],
			num_items       => 0,
			version         => '',
			encoding        => '',
			category        => ''
		       );

my %v1_0_ok_fields = (
		      channel => {
				  title       => '',
				  description => '',
				  link        => '',
				 },
		      image  => {
				 title => '',
				 url   => '',
				 link  => ''
				},
		      textinput => {
				    title       => '',
				    description => '',
				    name        => '',
				    link        => ''
				   },
		      skipDays  => {
				    day         => ''
				   },
		      skipHours => {
				    hour        => ''
				   },
		      items => [],
		      num_items => 0,
		      version         => '',
		      encoding        => '',
		      output          => '',
		     );

my %v2_0_ok_fields = (
		      channel => {
				  title          => '',
				  link           => '',
				  description    => '',
				  language       => '',
				  copyright      => '',
				  managingEditor => '',
				  webMaster      => '',
				  pubDate        => '',
				  lastBuildDate  => '',
				  category       => '',
				  generator      => '',
				  docs           => '',
				  cloud          => '',
				  ttl            => '',
				  image          => '',
				  textinput      => '',
				  skipHours      => '',
				  skipDays       => '',
				 },
		      image  => {
				 title       => '',
				 url         => '',
				 link        => '',
				 width       => '',
				 height      => '',
				 description => ''
				},
		      skipDays  => {
				    day         => ''
				   },
		      skipHours => {
				    hour        => ''
				   },
		      textinput => {
				    title       => '',
				    description => '',
				    name        => '',
				    link        => ''
				   },
		      items           => [],
		      num_items       => 0,
		      version         => '',
		      encoding        => '',
		      category        => '',
		      cloud           => '',
		      ttl             => ''
		     );

my %languages = (
		 'af'    => 'Afrikaans',
		 'sq'    => 'Albanian',
		 'eu'    => 'Basque',
		 'be'    => 'Belarusian',
		 'bg'    => 'Bulgarian',
		 'ca'    => 'Catalan',
		 'zh-cn' => 'Chinese (Simplified)',
		 'zh-tw' => 'Chinese (Traditional)',
		 'hr'    => 'Croatian',
		 'cs'    => 'Czech',
		 'da'    => 'Danish',
		 'nl'    => 'Dutch',
		 'nl-be' => 'Dutch (Belgium)',
		 'nl-nl' => 'Dutch (Netherlands)',
		 'en'    => 'English',
		 'en-au' => 'English (Australia)',
		 'en-bz' => 'English (Belize)',
		 'en-ca' => 'English (Canada)',
		 'en-ie' => 'English (Ireland)',
		 'en-jm' => 'English (Jamaica)',
		 'en-nz' => 'English (New Zealand)',
		 'en-ph' => 'English (Phillipines)',
		 'en-za' => 'English (South Africa)',
		 'en-tt' => 'English (Trinidad)',
		 'en-gb' => 'English (United Kingdom)',
		 'en-us' => 'English (United States)',
		 'en-zw' => 'English (Zimbabwe)',
		 'fo'    => 'Faeroese',
		 'fi'    => 'Finnish',
		 'fr'    => 'French',
		 'fr-be' => 'French (Belgium)',
		 'fr-ca' => 'French (Canada)',
		 'fr-fr' => 'French (France)',
		 'fr-lu' => 'French (Luxembourg)',
		 'fr-mc' => 'French (Monaco)',
		 'fr-ch' => 'French (Switzerland)',
		 'gl'    => 'Galician',
		 'gd'    => 'Gaelic',
		 'de'    => 'German',
		 'de-at' => 'German (Austria)',
		 'de-de' => 'German (Germany)',
		 'de-li' => 'German (Liechtenstein)',
		 'de-lu' => 'German (Luxembourg)',
		 'el'    => 'Greek',
		 'hu'    => 'Hungarian',
		 'is'    => 'Icelandic',
		 'in'    => 'Indonesian',
		 'ga'    => 'Irish',
		 'it'    => 'Italian',
		 'it-it' => 'Italian (Italy)',
		 'it-ch' => 'Italian (Switzerland)',
		 'ja'    => 'Japanese',
		 'ko'    => 'Korean',
		 'mk'    => 'Macedonian',
		 'no'    => 'Norwegian',
		 'pl'    => 'Polish',
		 'pt'    => 'Portuguese',
		 'pt-br' => 'Portuguese (Brazil)',
		 'pt-pt' => 'Portuguese (Portugal)',
		 'ro'    => 'Romanian',
		 'ro-mo' => 'Romanian (Moldova)',
		 'ro-ro' => 'Romanian (Romania)',
		 'ru'    => 'Russian',
		 'ru-mo' => 'Russian (Moldova)',
		 'ru-ru' => 'Russian (Russia)',
		 'sr'    => 'Serbian',
		 'sk'    => 'Slovak',
		 'sl'    => 'Slovenian',
		 'es'    => 'Spanish',
		 'es-ar' => 'Spanish (Argentina)',
		 'es-bo' => 'Spanish (Bolivia)',
		 'es-cl' => 'Spanish (Chile)',
		 'es-co' => 'Spanish (Colombia)',
		 'es-cr' => 'Spanish (Costa Rica)',
		 'es-do' => 'Spanish (Dominican Republic)',
		 'es-ec' => 'Spanish (Ecuador)',
		 'es-sv' => 'Spanish (El Salvador)',
		 'es-gt' => 'Spanish (Guatemala)',
		 'es-hn' => 'Spanish (Honduras)',
		 'es-mx' => 'Spanish (Mexico)',
		 'es-ni' => 'Spanish (Nicaragua)',
		 'es-pa' => 'Spanish (Panama)',
		 'es-py' => 'Spanish (Paraguay)',
		 'es-pe' => 'Spanish (Peru)',
		 'es-pr' => 'Spanish (Puerto Rico)',
		 'es-es' => 'Spanish (Spain)',
		 'es-uy' => 'Spanish (Uruguay)',
		 'es-ve' => 'Spanish (Venezuela)',
		 'sv'    => 'Swedish',
		 'sv-fi' => 'Swedish (Finland)',
		 'sv-se' => 'Swedish (Sweden)',
		 'tr'    => 'Turkish',
		 'uk'    => 'Ukranian'
		);

# define required elements for RSS 0.9
my $_REQ_v0_9 = {
		 channel => {
			     title          => [1,40],
			     description    => [1,500],
			     link           => [1,500]
			    },
		 image => {
			   title          => [1,40],
			   url            => [1,500],
			   link           => [1,500]
			  },
		 item => {
			  title          => [1,100],
			  link           => [1,500]
			 },
		 textinput => {
			       title          => [1,40],
			       description    => [1,100],
			       name           => [1,500],
			       link           => [1,500]
			      }
		};

# define required elements for RSS 0.91
my $_REQ_v0_9_1 = {
		   channel => {
			       title          => [1,100],
			       description    => [1,500],
			       link           => [1,500],
			       language       => [1,5],
			       rating         => [0,500],
			       copyright      => [0,100],
			       pubDate        => [0,100],
			       lastBuildDate  => [0,100],
			       docs           => [0,500],
			       managingEditor => [0,100],
			       webMaster      => [0,100],
			      },
		   image => {
			     title          => [1,100],
			     url            => [1,500],
			     link           => [0,500],
			     width          => [0,144],
			     height         => [0,400],
			     description    => [0,500]
			    },
		   item => {
			    title          => [1,100],
			    link           => [1,500],
			    description    => [0,500]
			   },
		   textinput => {
				 title          => [1,100],
				 description    => [1,500],
				 name           => [1,20],
				 link           => [1,500]
				},
		   skipHours => {
				 hour           => [1,23]
				},
		   skipDays => {
				day            => [1,10]
			       }
		  };

# define required elements for RSS 2.0
my $_REQ_v2_0 = {
		 channel => {
			     title          => [1,100],
			     description    => [1,500],
			     link           => [1,500],
			     language       => [0,5],
			     rating         => [0,500],
			     copyright      => [0,100],
			     pubDate        => [0,100],
			     lastBuildDate  => [0,100],
			     docs           => [0,500],
			     managingEditor => [0,100],
			     webMaster      => [0,100],
			    },
		 image => {
			   title          => [1,100],
			   url            => [1,500],
			   link           => [0,500],
			   width          => [0,144],
			   height         => [0,400],
			   description    => [0,500]
			  },
		 item => {
			  title          => [1,100],
			  link           => [1,500],
			  description    => [0,500]
			 },
		 textinput => {
			       title          => [1,100],
			       description    => [1,500],
			       name           => [1,20],
			       link           => [1,500]
			      },
		 skipHours => {
			       hour           => [1,23]
			      },
		 skipDays => {
			      day            => [1,10]
			     }
		};

my $modules = {
	       'http://purl.org/rss/1.0/modules/syndication/' => 'syn',
	       'http://purl.org/dc/elements/1.1/' => 'dc',
	       'http://purl.org/rss/1.0/modules/taxonomy/' => 'taxo',
	       'http://webns.net/mvcb/' => 'admin'
	      };

my %syn_ok_fields = (
		     updateBase => '',
		     updateFrequency => '',
		     updatePeriod => '',
		    );

my %dc_ok_fields = (
		    title => '',
		    creator => '',
		    subject => '',
		    description => '',
		    publisher => '',
		    contributor => '',
		    date => '',
		    type => '',
		    format => '',
		    identifier => '',
		    source => '',
		    language => '',
		    relation => '',
		    coverage => '',
		    rights => '',
		   );

my %rdf_resource_fields = (
			   'http://webns.net/mvcb/' =>  {
							 generatorAgent => 1,
							 errorReportsTo => 1
							},
			   'http://purl.org/rss/1.0/modules/annotate/'	=> {
									    reference	=> 1
									   },
			   'http://my.theinfo.org/changed/1.0/rss/' => {
									server => 1
								       }
			  );

sub new {
    my $class = shift;
    
    my $self={};
    bless $self, $class;
    
    $self->_initialize(@_);
    
    return $self;
}


sub _initialize {
    my $self = shift;
    my %hash = @_;

    # internal hash
    $self->{_internal} = {};

    # init num of items to 0
    $self->{num_items} = 0;

    # adhere to Netscape limits; no by default
    $self->{'strict'} = 0;

    # initialize items
    $self->{items} = [];

    # namespaces
    $self->{namespaces} = {};
    $self->{rss_namespace} = '';

    # modules
    $self->{modules} = $modules;

    # encode output from as_string?
    (exists($hash{encode_output}))
      ? ($self->{encode_output} = $hash{encode_output})
	: ($self->{encode_output} = 1);

    #get version info
    (exists($hash{version}))
      ? ($self->{version} = $hash{version})
	: ($self->{version} = '1.0');

    # set default output
    (exists($hash{output}))
      ? ($self->{output} = $hash{output})
	: ($self->{output} = "");

    # encoding
    (exists($hash{encoding}))
      ? ($self->{encoding} = $hash{encoding})
	: ($self->{encoding} = 'UTF-8');

    # initialize RSS data structure
    # RSS version 0.9
    if ($self->{version} eq '0.9') {
	# Copy the hashes instead of using them directly to avoid
        # problems with multiple XML::RSS objects being used concurrently
        foreach my $i (qw(channel image textinput)) {
	    my %template=%{$v0_9_ok_fields{$i}};
	    $self->{$i} = \%template;
        }

	# RSS version 0.91
    } elsif ($self->{version} eq '0.91') {
	foreach my $i (qw(channel image textinput skipDays skipHours)) {
	    my %template=%{$v0_9_1_ok_fields{$i}};
	    $self->{$i} = \%template;
        }

	# RSS version 2.0
    } elsif ($self->{version} eq '2.0') {
    	$self->{namespaces}->{'blogChannel'} = "http://backend.userland.com/blogChannelModule";
        foreach my $i (qw(channel image textinput skipDays skipHours)) {
            my %template=%{ $v2_0_ok_fields{$i} };
            $self->{$i} = \%template;
        }

	# RSS version 1.0
	#} elsif ($self->{version} eq '1.0') {
    } else {
	foreach my $i (qw(channel image textinput)) {
	    #foreach my $i (keys(%v1_0_ok_fields)) {
	    my %template=%{$v1_0_ok_fields{$i}};
	    $self->{$i} = \%template;
        }
    }
}

sub _auto_add_modules {
	my $self = shift;
	
	for my $ns (keys %{$self->{namespaces}}) {
	   # skip default namespaces
	   next if $ns eq "rdf" || $ns eq "#default"
			|| exists $self->{modules}{ $self->{namespaces}{$ns} };
	   $self->add_module(prefix => $ns, uri => $self->{namespaces}{$ns})
	}
	
	$self;
}

sub add_module {
    my $self = shift;
    my $hash = {@_};

    $hash->{prefix} =~ /^[a-z_][a-z0-9.-_]*$/ or
      croak "a namespace prefix should look like [a-z_][a-z0-9.-_]*";

    $hash->{uri} or
      croak "a URI must be provided in a namespace declaration";

    $self->{modules}->{$hash->{uri}} = $hash->{prefix};
}

sub add_item {
    my $self = shift;
    my $hash = {@_};

    # strict Netscape Netcenter length checks
    if ($self->{'strict'}) {
	# make sure we have a title and link
	croak "title and link elements are required"
	  unless ($hash->{title} && $hash->{'link'});

	# check string lengths
	croak "title cannot exceed 100 characters in length"
	  if (length($hash->{title}) > 100);
	croak "link cannot exceed 500 characters in length"
	  if (length($hash->{'link'}) > 500);
	croak "description cannot exceed 500 characters in length"
	  if (exists($hash->{description})
	      && length($hash->{description}) > 500);
	
	# make sure there aren't already 15 items
	croak "total items cannot exceed 15 " if (@{$self->{items}} >= 15);
    }

    # add the item to the list
    if (defined($hash->{mode}) && $hash->{mode} eq 'insert') {
	unshift (@{$self->{items}}, $hash);
    } else {
	push (@{$self->{items}}, $hash);
    }

    # return reference to the list of items
    return $self->{items};
}

sub as_rss_0_9 {
    my $self = shift;
    my $output;

    # XML declaration
    my $encoding = exists $$self{encoding} ? qq| encoding="$$self{encoding}"| : '';
    $output .= qq|<?xml version="1.0"$encoding?>\n\n|;

    # RDF root element
    $output .= '<rdf:RDF'."\n".'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n";
    $output .= 'xmlns="http://my.netscape.com/rdf/simple/0.9/">'."\n\n";

    ###################
    # Channel Element #
    ###################
    $output .= '<channel>'."\n";
    $output .= '<title>'. $self->encode($self->{channel}->{title}) .'</title>'."\n";
    $output .= '<link>'. $self->encode($self->{channel}->{'link'}) .'</link>'."\n";
    $output .= '<description>'. $self->encode($self->{channel}->{description}) .'</description>'."\n";
    $output .= '</channel>'."\n\n";

    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image>'."\n";

	# title
	$output .= '<title>'. $self->encode($self->{image}->{title}) .'</title>'."\n";

	# url
	$output .= '<url>'. $self->encode($self->{image}->{url}) .'</url>'."\n";

	# link
	$output .= '<link>'. $self->encode($self->{image}->{'link'}) .'</link>'."\n"
	  if $self->{image}->{link};

	# end image element
	$output .= '</image>'."\n\n";
    }

    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    $output .= '<item>'."\n";
	    $output .= '<title>'. $self->encode($item->{title}) .'</title>'."\n";
	    $output .= '<link>'. $self->encode($item->{'link'}) .'</link>'."\n";

	    # end image element
	    $output .= '</item>'."\n\n";
	}
    }

    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput>'."\n";
	$output .= '<title>'. $self->encode($self->{textinput}->{title}) .'</title>'."\n";
	$output .= '<description>'. $self->encode($self->{textinput}->{description}) .'</description>'."\n";
	$output .= '<name>'. $self->encode($self->{textinput}->{name}) .'</name>'."\n";
	$output .= '<link>'. $self->encode($self->{textinput}->{'link'}) .'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }

    $output .= '</rdf:RDF>';

    return $output;
}

sub as_rss_0_9_1 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0" encoding="'.$self->{encoding}.'"?>'."\n\n";

    # DOCTYPE
    $output .= '<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN"'."\n";
    $output .= '            "http://my.netscape.com/publish/formats/rss-0.91.dtd">'."\n\n";

    # RSS root element
    $output .= '<rss version="0.91">'."\n\n";

    ###################
    # Channel Element #
    ###################
    $output .= '<channel>'."\n";
    $output .= '<title>'. $self->encode($self->{channel}->{title}) .'</title>'."\n";
    $output .= '<link>'. $self->encode($self->{channel}->{'link'}) .'</link>'."\n";
    $output .= '<description>'. $self->encode($self->{channel}->{description}) .'</description>'."\n";

    # language
    if ($self->{channel}->{'dc'}->{'language'}) {
	$output .= '<language>'. $self->encode($self->{channel}->{'dc'}->{'language'}) .'</language>'."\n";
    } elsif ($self->{channel}->{language}) {
	$output .= '<language>'. $self->encode($self->{channel}->{language}).'</language>'."\n";
    }

    # PICS rating
    $output .= '<rating>'. $self->encode($self->{channel}->{rating}) .'</rating>'."\n"
      if $self->{channel}->{rating};

    # copyright
    if ($self->{channel}->{'dc'}->{'rights'}) {
	$output .= '<copyright>'. $self->encode($self->{channel}->{'dc'}->{'rights'}) .'</copyright>'."\n";
    } elsif ($self->{channel}->{copyright}) {
	$output .= '<copyright>'. $self->encode($self->{channel}->{copyright}) .'</copyright>'."\n";
    }

    # publication date
    if ($self->{channel}->{pubDate}) {
	$output .= '<pubDate>'. $self->encode($self->{channel}->{pubDate}) .'</pubDate>'."\n";
    } elsif ($self->{channel}->{'dc'}->{'date'}) {
	$output .= '<pubDate>'. $self->encode($self->{channel}->{'dc'}->{'date'}) .'</pubDate>'."\n";
    }

    # last build date
    if ($self->{channel}->{lastBuildDate}) {
	$output .= '<lastBuildDate>'. $self->encode($self->{channel}->{lastBuildDate}) .'</lastBuildDate>'."\n";
    } elsif ($self->{channel}->{'dc'}->{'date'}) {
	$output .= '<lastBuildDate>'. $self->encode($self->{channel}->{'dc'}->{'date'}) .'</lastBuildDate>'."\n";
    }

    # external CDF URL
    $output .= '<docs>'. $self->encode($self->{channel}->{docs}) .'</docs>'."\n"
      if $self->{channel}->{docs};

    # managing editor
    if ($self->{channel}->{'dc'}->{'publisher'}) {
	$output .= '<managingEditor>'. $self->encode($self->{channel}->{'dc'}->{'publisher'}) .'</managingEditor>'."\n";
    } elsif ($self->{channel}->{managingEditor}) {
	$output .= '<managingEditor>'. $self->encode($self->{channel}->{managingEditor}) .'</managingEditor>'."\n";
    }

    # webmaster
    if ($self->{channel}->{'dc'}->{'creator'}) {
	$output .= '<webMaster>'. $self->encode($self->{channel}->{'dc'}->{'creator'}) .'</webMaster>'."\n";
    } elsif ($self->{channel}->{webMaster}) {
	$output .= '<webMaster>'. $self->encode($self->{channel}->{webMaster}) .'</webMaster>'."\n";
    }

    $output .= "\n";

    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image>'."\n";

	# title
	$output .= '<title>'. $self->encode($self->{image}->{title}) .'</title>'."\n";

	# url
	$output .= '<url>'. $self->encode($self->{image}->{url}) .'</url>'."\n";

	# link
	$output .= '<link>'. $self->encode($self->{image}->{'link'}) .'</link>'."\n"
	  if $self->{image}->{link};

	# image width
	$output .= '<width>'. $self->encode($self->{image}->{width}) .'</width>'."\n"
	  if $self->{image}->{width};

	# image height
	$output .= '<height>'. $self->encode($self->{image}->{height}) .'</height>'."\n"
	  if $self->{image}->{height};

	# description
	$output .= '<description>'. $self->encode($self->{image}->{description}) .'</description>'."\n"
	  if $self->{image}->{description};

	# end image element
	$output .= '</image>'."\n\n";
    }

    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    $output .= '<item>'."\n";
	    $output .= '<title>'. $self->encode($item->{title}) .'</title>'."\n";
	    $output .= '<link>'. $self->encode($item->{'link'}) .'</link>'."\n";

	    $output .= '<description>'. $self->encode($item->{description}) .'</description>'."\n"
	      if $item->{description};

	    # end image element
	    $output .= '</item>'."\n\n";
	}
    }

    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput>'."\n";
	$output .= '<title>'. $self->encode($self->{textinput}->{title}) .'</title>'."\n";
	$output .= '<description>'. $self->encode($self->{textinput}->{description}) .'</description>'."\n";
	$output .= '<name>'. $self->encode($self->{textinput}->{name}) .'</name>'."\n";
	$output .= '<link>'. $self->encode($self->{textinput}->{'link'}) .'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }

    #####################
    # skipHours element #
    #####################
    if ($self->{skipHours}->{hour}) {
	$output .= '<skipHours>'."\n";
	$output .= '<hour>'. $self->encode($self->{skipHours}->{hour}) .'</hour>'."\n";
	$output .= '</skipHours>'."\n\n";
    }

    ####################
    # skipDays element #
    ####################
    if ($self->{skipDays}->{day}) {
	$output .= '<skipDays>'."\n";
	$output .= '<day>'. $self->encode($self->{skipDays}->{day}) .'</day>'."\n";
	$output .= '</skipDays>'."\n\n";
    }

    # end channel element
    $output .= '</channel>'."\n";
    $output .= '</rss>';

    return $output;
}

sub as_rss_1_0 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0" encoding="'.$self->{encoding}.'"?>'."\n\n";

    # RDF namespaces declaration
    $output .="<rdf:RDF"."\n";
    $output .=' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n";
    $output .=' xmlns="http://purl.org/rss/1.0/"'."\n";

    # print all imported namespaces
    while (my($k, $v) = each %{$self->{modules}}) {
	$output.=" xmlns:$v=\"$k\"\n";
    }

    $output .=">"."\n\n";

    ###################
    # Channel Element #
    ###################
    unless ( defined($self->{channel}->{'about'}) ) {
	$output .= '<channel rdf:about="'. $self->encode($self->{channel}->{'link'}) .'">'."\n";
    } else {
	$output .= '<channel rdf:about="'. $self->encode($self->{channel}->{'about'}) .'">'."\n";
    }
    # title
    $output .= '<title>'. $self->encode($self->{channel}->{title}) .'</title>'."\n";

    # link
    $output .= '<link>'. $self->encode($self->{channel}->{'link'}) .'</link>'."\n";

    # description
    $output .= '<description>'. $self->encode($self->{channel}->{description}) .'</description>'."\n";

    # additional elements for RSS 0.91
    # language
    if ($self->{channel}->{'dc'}->{'language'}) {
	$output .= '<dc:language>'. $self->encode($self->{channel}->{'dc'}->{'language'}) .'</dc:language>'."\n";
    } elsif ($self->{channel}->{language}) {
	$output .= '<dc:language>'.  $self->encode($self->{channel}->{language}) .'</dc:language>'."\n";
    }

    # PICS rating - Dublin Core has not decided how to incorporate PICS ratings yet
    #$$output .= '<rss091:rating>'.$self->{channel}->{rating}.'</rss091:rating>'."\n"
    #$if $self->{channel}->{rating};

    # copyright
    if ($self->{channel}->{'dc'}->{'rights'}) {
	$output .= '<dc:rights>'.  $self->encode($self->{channel}->{'dc'}->{'rights'}) .'</dc:rights>'."\n";
    } elsif ($self->{channel}->{copyright}) {
	$output .= '<dc:rights>'.  $self->encode($self->{channel}->{copyright}) .'</dc:rights>'."\n";
    }

    # publication date
    if ($self->{channel}->{'dc'}->{'date'}) {
	$output .= '<dc:date>'.  $self->encode($self->{channel}->{'dc'}->{'date'}) .'</dc:date>'."\n";
    } elsif ($self->{channel}->{pubDate}) {
	$output .= '<dc:date>'.  $self->encode($self->{channel}->{pubDate}) .'</dc:date>'."\n";
    } elsif ($self->{channel}->{lastBuildDate}) {
	$output .= '<dc:date>'.  $self->encode($self->{channel}->{lastBuildDate}) .'</dc:date>'."\n";
    }

    # external CDF URL
    #$output .= '<rss091:docs>'.$self->{channel}->{docs}.'</rss091:docs>'."\n"
    #if $self->{channel}->{docs};

    # managing editor
    if ($self->{channel}->{'dc'}->{'publisher'}) {
	$output .= '<dc:publisher>'.  $self->encode($self->{channel}->{'dc'}->{'publisher'}) .'</dc:publisher>'."\n";
    } elsif ($self->{channel}->{managingEditor}) {
	$output .= '<dc:publisher>'.  $self->encode($self->{channel}->{managingEditor}) .'</dc:publisher>'."\n";
    }

    # webmaster
    if ($self->{channel}->{'dc'}->{'creator'}) {
	$output .= '<dc:creator>'.  $self->encode($self->{channel}->{'dc'}->{'creator'}) .'</dc:creator>'."\n";
    } elsif ($self->{channel}->{webMaster}) {
	$output .= '<dc:creator>'.  $self->encode($self->{channel}->{webMaster})  .'</dc:creator>'."\n";
    }

    # Dublin Core module
    foreach my $dc ( keys %dc_ok_fields ) {
	next if ($dc eq 'language'
		 || $dc eq 'creator'
		 || $dc eq 'publisher'
		 || $dc eq 'rights'
		 || $dc eq 'date');
	$self->{channel}->{dc}->{$dc} and $output .= "<dc:$dc>".  $self->encode($self->{channel}->{dc}->{$dc}) ."</dc:$dc>\n";
    }

    # Syndication module
    foreach my $syn ( keys %syn_ok_fields ) {
	$self->{channel}->{syn}->{$syn} and $output .= "<syn:$syn>".  $self->encode($self->{channel}->{syn}->{$syn}) ."</syn:$syn>\n";
    }

    # Taxonomy module
    if (exists($self->{'channel'}->{'taxo'}) && $self->{'channel'}->{'taxo'}) {
	$output .= "<taxo:topics>\n  <rdf:Bag>\n";
	foreach my $taxo (@{$self->{'channel'}->{'taxo'}}) {
	    $output.= "    <rdf:li resource=\"" . $self->encode($taxo) . "\" />\n";
	}
	$output .= "  </rdf:Bag>\n</taxo:topics>\n";
    }

    # Ad-hoc modules
    while ( my($url, $prefix) = each %{$self->{modules}} ) {
	next if $prefix =~ /^(dc|syn|taxo)$/;
	while ( my($el, $value) = each %{$self->{channel}->{$prefix}} ) {
	    if ( exists( $rdf_resource_fields{ $url } ) and
		 exists( $rdf_resource_fields{ $url }{ $el }) ) {
		$output .= qq!<$prefix:$el rdf:resource="! .
		  $self->encode($value) .
		    qq!" />\n!;
	    } else {
		$output .= "<$prefix:$el>".  $self->encode($value) ."</$prefix:$el>\n";
	    }
	}
    }

    # Seq items
    $output .= "<items>\n <rdf:Seq>\n";

    foreach my $item (@{$self->{items}}) {
	my $about = ( defined($item->{'about'}) ) ? $item->{'about'} : $item->{'link'};
	$output .= '  <rdf:li rdf:resource="'. $self->encode($about) .'" />'."\n";
    }

    $output .= " </rdf:Seq>\n</items>\n";

    $self->{image}->{url} and
      $output .= '<image rdf:resource="'. $self->encode($self->{image}->{url}) .'" />'."\n";

    $self->{textinput}->{'link'} and
      $output .= '<textinput rdf:resource="'. $self->encode($self->{textinput}->{'link'}) .'" />'."\n";

    # end channel element
    $output .= '</channel>'."\n\n";

    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image rdf:about="'. $self->encode($self->{image}->{url}) .'">'."\n";

	# title
	$output .= '<title>'.  $self->encode($self->{image}->{title}) .'</title>'."\n";

	# url
	$output .= '<url>'.  $self->encode($self->{image}->{url}) .'</url>'."\n";

	# link
	$output .= '<link>'.  $self->encode($self->{image}->{'link'}) .'</link>'."\n"
	  if $self->{image}->{link};

	# image width
	#$output .= '<rss091:width>'.$self->{image}->{width}.'</rss091:width>'."\n"
	#    if $self->{image}->{width};

	# image height
	#$output .= '<rss091:height>'.$self->{image}->{height}.'</rss091:height>'."\n"
	#    if $self->{image}->{height};

	# description
	#$output .= '<rss091:description>'.$self->{image}->{description}.'</rss091:description>'."\n"
	#    if $self->{image}->{description};

	# Dublin Core Modules
	foreach my $dc ( keys %dc_ok_fields ) {
	    $self->{image}->{dc}->{$dc} and
	      $output .= "<dc:$dc>".  $self->encode($self->{image}->{dc}->{$dc}) ."</dc:$dc>\n";
	}

	# Ad-hoc modules for images
	while ( my($url, $prefix) = each %{$self->{modules}} ) {
	    next if $prefix =~ /^(dc|syn|taxo)$/;
	    while ( my($el, $value) = each %{$self->{image}->{$prefix}} ) {
		if ( exists( $rdf_resource_fields{ $url } ) and
		     exists( $rdf_resource_fields{ $url }{ $el }) ) {
		    $output .= qq!<$prefix:$el rdf:resource="! .
		      $self->encode($value) .
			qq!" />\n!;
		} else {
		    $output .= "<$prefix:$el>".  $self->encode($value) ."</$prefix:$el>\n";
		}
	    }
	}
	# end image element
	$output .= '</image>'."\n\n";
    }				# end if ($self->{image}->{url}) {

    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    my $about = ( defined($item->{'about'}) ) ? $item->{'about'} : $item->{'link'};
	    $output .= '<item rdf:about="'. $self->encode($about) .'"';
	    $output .= ">\n";
	    $output .= '<title>'.  $self->encode($item->{title}) .'</title>'."\n";
	    $output .= '<link>'.  $self->encode($item->{'link'}) .'</link>'."\n";
	    $item->{description} and $output .= '<description>'.  $self->encode($item->{description}) .'</description>'."\n";

	    # Dublin Core module
	    foreach my $dc ( keys %dc_ok_fields ) {
	    	$item->{dc}->{$dc} and $output .= "<dc:$dc>".  $self->encode($item->{dc}->{$dc}) ."</dc:$dc>\n";
	    }

	    # Taxonomy module
	    if (exists($item->{'taxo'})  && $item->{'taxo'}) {
		$output .= "<taxo:topics>\n  <rdf:Bag>\n";
		foreach my $taxo (@{$item->{'taxo'}}) {
		    $output.= "    <rdf:li resource=\"$taxo\" />\n";
		}
		$output .= "  </rdf:Bag>\n</taxo:topics>\n";
	    }

	    # Ad-hoc modules
	    while ( my($url, $prefix) = each %{$self->{modules}} ) {
		next if $prefix =~ /^(dc|syn|taxo)$/;
		while ( my($el, $value) = each %{$item->{$prefix}} ) {
		    if ( exists( $rdf_resource_fields{ $url } ) and
			 exists( $rdf_resource_fields{ $url }{ $el }) ) {
			$output .= qq!<$prefix:$el rdf:resource="! .
			  $self->encode($value) .
			    qq!" />\n!;
		    } else {
			$output .= "<$prefix:$el>".  $self->encode($value) ."</$prefix:$el>\n";
		    }
		}
	    }
	    # end item element
	    $output .= '</item>'."\n\n";
	}
    }			  # end foreach my $item (@{$self->{items}}) {

    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput rdf:about="'. $self->encode($self->{textinput}->{'link'}) .'">'."\n";
	$output .= '<title>'.  $self->encode($self->{textinput}->{title}) .'</title>'."\n";
	$output .= '<description>'.  $self->encode($self->{textinput}->{description}) .'</description>'."\n";
	$output .= '<name>'.  $self->encode($self->{textinput}->{name}) .'</name>'."\n";
	$output .= '<link>'.  $self->encode($self->{textinput}->{'link'}) .'</link>'."\n";

	# Dublin Core module
	foreach my $dc ( keys %dc_ok_fields ) {
	    $self->{textinput}->{dc}->{$dc}
	      and $output .= "<dc:$dc>".  $self->encode($self->{textinput}->{dc}->{$dc}) ."</dc:$dc>\n";
	}

	# Ad-hoc modules
	while ( my($url, $prefix) = each %{$self->{modules}} ) {
	    next if $prefix =~ /^(dc|syn|taxo)$/;
	    while ( my($el, $value) = each %{$self->{textinput}->{$prefix}} ) {
		$output .= "<$prefix:$el>".  $self->encode($value) ."</$prefix:$el>\n";
	    }
	}

	$output .= '</textinput>'."\n\n";
    }

    $output .= '</rdf:RDF>';
}

sub as_rss_2_0 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0" encoding="'.$self->{encoding}.'"?>'."\n\n";

    # DOCTYPE
    # $output .= '<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN"'."\n";
    # $output .= '            "http://my.netscape.com/publish/formats/rss-0.91.dtd">'."\n\n";

    # RSS root element
    # $output .= '<rss version="0.91">'."\n\n";
    $output .= '<rss version="2.0" xmlns:blogChannel="http://backend.userland.com/blogChannelModule">' . "\n\n";

    ###################
    # Channel Element #
    ###################
    $output .= '<channel>'."\n";
    $output .= '<title>'.$self->encode($self->{channel}->{title}).'</title>'."\n";
    $output .= '<link>'.$self->encode($self->{channel}->{'link'}).'</link>'."\n";
    $output .= '<description>'.$self->encode($self->{channel}->{description}).'</description>'."\n";

    # language
    if ($self->{channel}->{'dc'}->{'language'}) {
        $output .= '<language>'.$self->encode($self->{channel}->{'dc'}->{'language'}).'</language>'."\n";
    } elsif ($self->{channel}->{language}) {
        $output .= '<language>'.$self->encode($self->{channel}->{language}).'</language>'."\n";
    }

    # PICS rating
    # Not supported by RSS 2.0
    # $output .= '<rating>'.$self->{channel}->{rating}.'</rating>'."\n"
    #    if $self->{channel}->{rating};

    # copyright
    if ($self->{channel}->{'dc'}->{'rights'}) {
        $output .= '<copyright>'.$self->encode($self->{channel}->{'dc'}->{'rights'}).'</copyright>'."\n";
    } elsif ($self->{channel}->{copyright}) {
        $output .= '<copyright>'.$self->encode($self->{channel}->{copyright}).'</copyright>'."\n";
    }

    # publication date
    if ($self->{channel}->{pubDate}) {
	$output .= '<pubDate>'.$self->encode($self->{channel}->{pubDate}).'</pubDate>'."\n";
    } elsif ($self->{channel}->{'dc'}->{'date'}) {
        $output .= '<pubDate>'.$self->encode($self->{channel}->{'dc'}->{'date'}).'</pubDate>'."\n";
    } 

    # last build date
    if ($self->{channel}->{'dc'}->{'date'}) {
        $output .= '<lastBuildDate>'.$self->encode($self->{channel}->{'dc'}->{lastBuildDate}).'</lastBuildDate>'."\n";
    } elsif ($self->{channel}->{lastBuildDate}) {
        $output .= '<lastBuildDate>'.$self->encode($self->{channel}->{lastBuildDate}).'</lastBuildDate>'."\n";
    }

    # external CDF URL
    $output .= '<docs>'.$self->encode($self->{channel}->{docs}).'</docs>'."\n"
      if $self->{channel}->{docs};

    # managing editor
    if ($self->{channel}->{'dc'}->{'publisher'}) {
        $output .= '<managingEditor>'.$self->encode($self->{channel}->{'dc'}->{'publisher'}).'</managingEditor>'."\n";
    } elsif ($self->{channel}->{managingEditor}) {
        $output .= '<managingEditor>'.$self->encode($self->{channel}->{managingEditor}).'</managingEditor>'."\n";
    }

    # webmaster
    if ($self->{channel}->{'dc'}->{'creator'}) {
        $output .= '<webMaster>'.$self->encode($self->{channel}->{'dc'}->{'creator'}).'</webMaster>'."\n";
    } elsif ($self->{channel}->{webMaster}) {
        $output .= '<webMaster>'.$self->encode($self->{channel}->{webMaster}).'</webMaster>'."\n";
    }

    # category
    if ($self->{channel}->{'dc'}->{'category'}) {
        $output .= '<category>'.$self->encode($self->{channel}->{'dc'}->{'category'}).'</category>'."\n";
    } elsif ($self->{channel}->{category}) {
        $output .= '<category>'.$self->encode($self->{channel}->{generator}).'</category>'."\n";
    }

    # generator
    if ($self->{channel}->{'dc'}->{'generator'}) {
        $output .= '<generator>'.$self->encode($self->{channel}->{'dc'}->{'generator'}).'</generator>'."\n";
    } elsif ($self->{channel}->{generator}) {
        $output .= '<generator>'.$self->encode($self->{channel}->{generator}).'</generator>'."\n";
    }

    # Insert cloud support here

    # ttl
    if ($self->{channel}->{'dc'}->{'ttl'}) {
        $output .= '<ttl>'.$self->encode($self->{channel}->{'dc'}->{'ttl'}).'</ttl>'."\n";
    } elsif ($self->{channel}->{ttl}) {
        $output .= '<ttl>'.$self->encode($self->{channel}->{ttl}).'</ttl>'."\n";
    }



    $output .= "\n";

    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
        $output .= '<image>'."\n";

        # title
        $output .= '<title>'.$self->encode($self->{image}->{title}).'</title>'."\n";

        # url
        $output .= '<url>'.$self->encode($self->{image}->{url}).'</url>'."\n";

        # link
        $output .= '<link>'.$self->encode($self->{image}->{'link'}).'</link>'."\n"
	  if $self->{image}->{link};

        # image width
        $output .= '<width>'.$self->encode($self->{image}->{width}).'</width>'."\n"
	  if $self->{image}->{width};

        # image height
        $output .= '<height>'.$self->encode($self->{image}->{height}).'</height>'."\n"
	  if $self->{image}->{height};

        # description
        $output .= '<description>'.$self->encode($self->{image}->{description}).'</description>'."\n"
	  if $self->{image}->{description};

        # end image element
        $output .= '</image>'."\n\n";
    }

    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
        if ($item->{title}) {
            $output .= '<item>'."\n";
            $output .= '<title>'.$self->encode($item->{title}).'</title>'."\n"
	      if $item->{title};
            $output .= '<link>'.$self->encode($item->{'link'}).'</link>'."\n"
	      if $item->{link};
            $output .= '<description>'.$self->encode($item->{description}).'</description>'."\n"
	      if $item->{description};

            $output .= '<author>'.$self->encode($item->{author}).'</author>'."\n"
	      if $item->{author};

            $output .= '<category>'.$self->encode($item->{category}).'</category>'."\n"
	      if $item->{category};

            $output .= '<comments>'.$self->encode($item->{comments}).'</comments>'."\n"
	      if $item->{comments};

            # The unique identifier. Use 'permaLink' for an external
            # identifier, or 'guid' for a internal string.
            # (I call it permaLink in the hash for purposes of clarity.)
            if ($item->{permaLink}) {
                $output .= '<guid isPermaLink="true">'.$self->encode($item->{permaLink}).'</guid>'."\n";
            } elsif ($item->{guid}) {
                $output .= '<guid isPermaLink="false">'.$self->encode($item->{guid}).'</guid>'."\n";
            }

            $output .= '<pubDate>'.$self->encode($item->{pubDate}).'</pubDate>'."\n"
	      if $item->{pubDate};

            $output .= '<source url="'.$self->encode($item->{sourceUrl}).'">'.$item->{source}.'</source>'."\n"
	      if $item->{source} && $item->{sourceUrl};

            if (my $e = $item->{enclosure}) {
                $output .= "<enclosure "
		  . join(' ', map {qq!$_="! . $self->encode($e->{$_}) . qq!"!} keys(%$e))
                    . ' />' . "\n";
            }

            # end image element
            $output .= '</item>'."\n\n";
        }
    }

    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
        $output .= '<textInput>'."\n";
        $output .= '<title>'.$self->encode($self->{textinput}->{title}).'</title>'."\n";
        $output .= '<description>'.$self->encode($self->{textinput}->{description}).'</description>'."\n";
        $output .= '<name>'.$self->encode($self->{textinput}->{name}).'</name>'."\n";
        $output .= '<link>'.$self->encode($self->{textinput}->{'link'}).'</link>'."\n";
        $output .= '</textInput>'."\n\n";
    }

    #####################
    # skipHours element #
    #####################
    if ($self->{skipHours}->{hour}) {
        $output .= '<skipHours>'."\n";
        $output .= '<hour>'.$self->encode($self->{skipHours}->{hour}).'</hour>'."\n";
        $output .= '</skipHours>'."\n\n";
    }

    ####################
    # skipDays element #
    ####################
    if ($self->{skipDays}->{day}) {
        $output .= '<skipDays>'."\n";
        $output .= '<day>'.$self->encode($self->{skipDays}->{day}).'</day>'."\n";
        $output .= '</skipDays>'."\n\n";
    }

    # end channel element
    $output .= '</channel>'."\n";
    $output .= '</rss>';

    return $output;
}

sub as_string {
    my $self = shift;
    my $version = ($self->{output} =~ /\d/) ? $self->{output} : $self->{version};
    my $output;

    ###########
    # RSS 0.9 #
    ###########
    if ($version eq '0.9') {
	$output = &as_rss_0_9($self);

	############
	# RSS 0.91 #
	############
    } elsif ($version eq '0.91') {
	$output = &as_rss_0_9_1($self);

	###########
	# RSS 2.0 #
	###########
    } elsif ($version eq '2.0') {
        $output = &as_rss_2_0($self);

	###########
	# RSS 1.0 #
	###########
    } else {
	$output = &as_rss_1_0($self);
    }

    return $output;
}


sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object\n";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    return if $name eq 'DESTROY';

    croak "Unregistered entity: Can't access $name field in object of class $type"
      unless (exists $self->{$name});

    # return reference to RSS structure
    if (@_ == 1) {
	return $self->{$name}->{$_[0]} if defined $self->{$name}->{$_[0]};

	# we're going to set values here
    } elsif (@_ > 1) {
	my %hash = @_;
	my $_REQ;

	# make sure we have required elements and correct lengths
	if ($self->{'strict'}) {
	    ($self->{version} eq '0.9')
	      ? ($_REQ = $_REQ_v0_9)
		: ($_REQ = $_REQ_v0_9_1);
	}

	# store data in object
	foreach my $key (keys(%hash)) {
	    if ($self->{'strict'}) {
		my $req_element = $_REQ->{$name}->{$key};
		confess "$key cannot exceed " . $req_element->[1] . " characters in length"
		  if defined $req_element->[1] && length($hash{$key}) > $req_element->[1];
	    }
	    $self->{$name}->{$key} = $hash{$key};
	}

	# return value
	return $self->{$name};

	# otherwise, just return a reference to the whole thing
    } else {
	return $self->{$name};
    }
    return 0;

    # make sure we have all required elements
    #foreach my $key (keys(%{$_REQ->{$name}})) {
    #my $element = $_REQ->{$name}->{$key};
    #croak "$key is required in $name"
    #if ($element->[0] == 1) && (!defined($hash{$key}));
    #croak "$key cannot exceed ".$element->[1]." characters in length"
    #unless length($hash{$key}) <= $element->[1];
    #}
}


# the code here is a minorly tweaked version of code from
# Matts' rssmirror.pl script
#
my %entity = (
	      nbsp   => "&#160;",
	      iexcl  => "&#161;",
	      cent   => "&#162;",
	      pound  => "&#163;",
	      curren => "&#164;",
	      yen    => "&#165;",
	      brvbar => "&#166;",
	      sect   => "&#167;",
	      uml    => "&#168;",
	      copy   => "&#169;",
	      ordf   => "&#170;",
	      laquo  => "&#171;",
	      not    => "&#172;",
	      shy    => "&#173;",
	      reg    => "&#174;",
	      macr   => "&#175;",
	      deg    => "&#176;",
	      plusmn => "&#177;",
	      sup2   => "&#178;",
	      sup3   => "&#179;",
	      acute  => "&#180;",
	      micro  => "&#181;",
	      para   => "&#182;",
	      middot => "&#183;",
	      cedil  => "&#184;",
	      sup1   => "&#185;",
	      ordm   => "&#186;",
	      raquo  => "&#187;",
	      frac14 => "&#188;",
	      frac12 => "&#189;",
	      frac34 => "&#190;",
	      iquest => "&#191;",
	      Agrave => "&#192;",
	      Aacute => "&#193;",
	      Acirc  => "&#194;",
	      Atilde => "&#195;",
	      Auml   => "&#196;",
	      Aring  => "&#197;",
	      AElig  => "&#198;",
	      Ccedil => "&#199;",
	      Egrave => "&#200;",
	      Eacute => "&#201;",
	      Ecirc  => "&#202;",
	      Euml   => "&#203;",
	      Igrave => "&#204;",
	      Iacute => "&#205;",
	      Icirc  => "&#206;",
	      Iuml   => "&#207;",
	      ETH    => "&#208;",
	      Ntilde => "&#209;",
	      Ograve => "&#210;",
	      Oacute => "&#211;",
	      Ocirc  => "&#212;",
	      Otilde => "&#213;",
	      Ouml   => "&#214;",
	      times  => "&#215;",
	      Oslash => "&#216;",
	      Ugrave => "&#217;",
	      Uacute => "&#218;",
	      Ucirc  => "&#219;",
	      Uuml   => "&#220;",
	      Yacute => "&#221;",
	      THORN  => "&#222;",
	      szlig  => "&#223;",
	      agrave => "&#224;",
	      aacute => "&#225;",
	      acirc  => "&#226;",
	      atilde => "&#227;",
	      auml   => "&#228;",
	      aring  => "&#229;",
	      aelig  => "&#230;",
	      ccedil => "&#231;",
	      egrave => "&#232;",
	      eacute => "&#233;",
	      ecirc  => "&#234;",
	      euml   => "&#235;",
	      igrave => "&#236;",
	      iacute => "&#237;",
	      icirc  => "&#238;",
	      iuml   => "&#239;",
	      eth    => "&#240;",
	      ntilde => "&#241;",
	      ograve => "&#242;",
	      oacute => "&#243;",
	      ocirc  => "&#244;",
	      otilde => "&#245;",
	      ouml   => "&#246;",
	      divide => "&#247;",
	      oslash => "&#248;",
	      ugrave => "&#249;",
	      uacute => "&#250;",
	      ucirc  => "&#251;",
	      uuml   => "&#252;",
	      yacute => "&#253;",
	      thorn  => "&#254;",
	      yuml   => "&#255;",
	     );

my $entities = join('|', keys %entity);

sub encode {
    my ($self, $text) = @_;
    return $text unless $self->{'encode_output'};
    
    my $encoded_text = '';
    
    while ( $text =~ s/(.*?)(\<\!\[CDATA\[.*?\]\]\>)//s ) {
	$encoded_text .= encode_text($1) . $2;
    }
    $encoded_text .= encode_text($text);
    
    return $encoded_text;
}

sub encode_text {
    my $text = shift;
    
    $text =~ s/&(?!(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&amp;/g;
    $text =~ s/&($entities);/$entity{$1}/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;

    return $text;
}

sub strict {
    my ($self,$value) = @_;
    $self->{'strict'} = $value;
}

sub save {
    my ($self,$file) = @_;
    open(OUT,">$file") || croak "Cannot open file $file for write: $!";
    print OUT $self->as_string;
    close OUT;
}


1;
