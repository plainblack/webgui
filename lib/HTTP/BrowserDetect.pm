package HTTP::BrowserDetect;

use strict;
use vars qw($VERSION $REVISION @ISA @EXPORT @EXPORT_OK @ALL_TESTS);
require Exporter;

@ISA	   = qw(Exporter);
@EXPORT	   = qw();
@EXPORT_OK = qw();
$REVISION  = '$Id$';
$VERSION   = '0.97';

# Operating Systems
push @ALL_TESTS,(qw(win16 win3x win31 win95 win98 winnt windows win32 win2k winme mac mac68k macppc os2 unix sun sun4 sun5 suni86 irix irix5 irix6 hpux hpux9 hpux10 aix aix1 aix2 aix3 aix4 linux sco unixware mpras reliant dec sinix freebsd bsd vms x11 amiga));

# Devices
push @ALL_TESTS,(qw(palm audrey iopener wap));

# Browsers
push @ALL_TESTS,(qw(mosaic netscape nav2 nav3 nav4 nav4up nav45 nav45up nav6 nav6up navgold ie ie3 ie4 ie4up ie5 ie5up ie55 ie55up opera opera3 opera4 opera5 lynx aol aol3 aol4 aol5 aol6 neoplanet neoplanet2 avantgo emacs gecko));

# Robots
push @ALL_TESTS,(qw(wget getright robot yahoo altavista lycos infoseek lwp webcrawler linkexchange slurp webtv staroffice lotusnotes konqueror icab google java));

#######################################################################################################
# BROWSER OBJECT

my $default = undef;

sub new {
   my ($class, $user_agent) = @_;
   
   my $self = {};
   bless $self, $class;

   unless (defined $user_agent) {
     $user_agent = $ENV{'HTTP_USER_AGENT'};
   }

   $self->user_agent($user_agent);
   return $self;
}

foreach my $test (@ALL_TESTS) {
    no strict 'refs';
    my $key = uc $test;
    *{$test} = sub { my ($self) = _self_or_default(@_);
		     return $self->{tests}->{$key} };
}

sub _self_or_default {
   my ($self) = $_[0];
   return @_ if (defined $self &&
		 ref $self &&
		 (ref $self eq 'HTTP::BrowserDetect') || UNIVERSAL::isa($self,'HTTP::BrowserDetect'));
   $default ||= HTTP::BrowserDetect->new();
   unshift (@_, $default);
   return @_;
}


sub user_agent {
  my ($self, $user_agent) = _self_or_default(@_);
  if (defined $user_agent) {
    $self->{user_agent} = $user_agent;
    $self->_test();
  }
  return $self->{user_agent};
}

# Private method -- test the UA string
sub _test {
  my ($self) = @_;

  my $ua = lc $self->{user_agent};

  # Browser version
  my ($major, $minor, $beta) = ($ua =~ / \/			# Version starts with a slash
				          [A-Za-z]*		# Eat any letters before the major version
                                          ( [^\.]* )		# Major version number is everything before the first dot
                                          \.			# The first dot
                                          ( [\d]* )		# Minor version number is every digit after the first dot
                                          [\d\.]*		# Throw away remaining numbers and dots
                                          ( [^\s]* )		# Beta version string is up to next space
                                        /x);

  if (index($ua,"compatible") !=-1) {
      ($major, $minor, $beta)    = ($ua =~ / 
				    compatible;       
				    \s*
				    \w*				# Browser name
				    [\s|\/]
				    [A-Za-z]*			# Eat any letters before the major version
				    ( [^\.]* )			# Major version number is everything before first dot
				    \.				# The first dot
				    ( [\d]* )			# Minor version nnumber is digits after first dot
				    [\d\.]*			# Throw away remaining dots and digits
				    ( [^;]* )			# Beta version is up to the ;
				    ;
				    /x);


  }

  if (index($ua,"gecko") !=-1) {
	($major, $minor, $beta) = ($ua =~ /rv:([^\.]*)\.([\d]*)[\d\.]*([^;]*)/x); 		
  }

  $minor = 0+".$minor"; 

  $self->{tests} = {};
  my $tests = $self->{tests};

  # Netscape browsers
  
  $tests->{NETSCAPE}  = (index($ua,"mozilla") != -1 && 
			 index($ua,"spoofer") == -1 && index($ua,"compatible") == -1 &&
			 index($ua,"opera") == -1 && index($ua,"webtv") == -1 && 
			 index($ua,"hotjava") == -1);
  $tests->{NAV2}      = ($tests->{NETSCAPE} && $major == 2);
  $tests->{NAV3}      = ($tests->{NETSCAPE} && $major == 3);
  $tests->{NAV4}      = ($tests->{NETSCAPE} && $major == 4);
  $tests->{NAV4UP}    = ($tests->{NETSCAPE} && $major >= 4); 
  $tests->{NAV45}     = ($tests->{NETSCAPE} && $major == 4 && $minor == .5);
  $tests->{NAV45UP}   = ($tests->{NAV4} && $minor >= .5) || ($tests->{NETSCAPE} && $major >= 5);
  $tests->{NAVGOLD}   = (index($beta,"gold") != -1);
  $tests->{NAV6}      = ($tests->{NETSCAPE} && $major == 5); # go figure
  $tests->{NAV6UP}    = ($tests->{NETSCAPE} && $major >= 5);
  $tests->{GECKO}     = (index($ua,"gecko") != -1);
  
  # Internet Explorer browsers

  $tests->{IE}               = (index($ua,"msie") != -1 || index($ua,'microsoft internet explorer') != -1);  
  $tests->{IE3}              = ($tests->{IE} && $major == 3);
  $tests->{IE4}              = ($tests->{IE} && $major == 4);
  $tests->{IE4UP}            = ($tests->{IE} && $major >= 4);
  $tests->{IE5}              = ($tests->{IE} && $major == 5);
  $tests->{IE5UP}            = ($tests->{IE} && $major >= 5);
  $tests->{IE55}             = ($tests->{IE} && $major == 5 && $minor >= .5);
  $tests->{IE55UP}           = ($tests->{IE5} && $minor >= .5) || ($tests->{IE} && $major >= 6);
 
  # Neoplanet browsers

  $tests->{NEOPLANET}      = (index($ua,"neoplanet") != -1);
  $tests->{NEOPLANET2}     = ($tests->{NEOPLANET} && index($ua,"2.") != -1); 

  # AOL Browsers

  $tests->{AOL}       = (index($ua,"aol")     != -1);
  $tests->{AOL3}      = (index($ua,"aol 3.0") != -1) || ($tests->{AOL} && $tests->{IE3});
  $tests->{AOL4}      = (index($ua,"aol 4.0") != -1) || ($tests->{AOL} && $tests->{IE4});
  $tests->{AOL5}      = (index($ua,"aol 5.0") != -1);
  $tests->{AOL6}      = (index($ua,"aol 6.0") != -1);
  $tests->{AOLTV}     = (index($ua,"navio") != -1) || (index($ua,"navio_aoltv") != -1);

  # Opera browsers
  
  $tests->{OPERA}     = (index($ua,"opera")   != -1);
  $tests->{OPERA3}    = (index($ua,"opera 3") != -1) || (index($ua,"opera/3") != -1);
  $tests->{OPERA4}    = (index($ua,"opera 4") != -1) || (index($ua,"opera/4") != -1);
  $tests->{OPERA5}    = (index($ua,"opera 5") != -1) || (index($ua,"opera/5") != -1);
  
  # Other browsers

  $tests->{STAROFFICE}     = (index($ua,"staroffice") != -1);
  $tests->{ICAB}           = (index($ua,"icab") != -1);
  $tests->{LOTUSNOTES}     = (index($ua,"lotus-notes") != -1);
  $tests->{KONQUEROR}      = (index($ua,"konqueror") != -1);
  $tests->{LYNX}           = (index($ua,"lynx") != -1);
  $tests->{WEBTV}          = (index($ua,"webtv") != -1);
  $tests->{MOSAIC}         = (index($ua,"mosaic") != -1);
  $tests->{WGET}           = (index($ua,"wget") != -1);
  $tests->{GETRIGHT}       = (index($ua,"getright") != -1);
  $tests->{LWP}            = (index($ua,"libwww-perl") != -1 ||
			      index($ua,"lwp-") != -1);
  $tests->{YAHOO}          = (index($ua,"yahoo") != -1);
  $tests->{GOOGLE}         = (index($ua,"google") != -1);
  $tests->{JAVA}           = (index($ua,"java") != -1 ||
			      index($ua,"jdk") != -1);
  $tests->{ALTAVISTA}      = (index($ua,"altavista") != -1);
  $tests->{SCOOTER}        = (index($ua,"scooter") != -1);
  $tests->{LYCOS}          = (index($ua,"lycos") != -1);
  $tests->{INFOSEEK}       = (index($ua,"infoseek") != -1);
  $tests->{WEBCRAWLER}     = (index($ua,"webcrawler") != -1); 
  $tests->{LINKEXCHANGE}   = (index($ua,"lecodechecker") != -1); 
  $tests->{SLURP}          = (index($ua,"slurp") != -1);
  $tests->{ROBOT}          = (($tests->{WGET} ||
			       $tests->{GETRIGHT} ||
			       $tests->{LWP} ||
			       $tests->{YAHOO} ||
			       $tests->{ALTAVISTA} ||
			       $tests->{LYCOS} ||
			       $tests->{INFOSEEK} ||
			       $tests->{WEBCRAWLER} ||
			       $tests->{LINKEXCHANGE} ||
			       $tests->{SLURP} ||
			       $tests->{GOOGLE}) ||
			      index($ua,"bot") != -1 ||
			      index($ua,"spider") != -1 ||
			      index($ua,"crawl") != -1 ||
			      index($ua,"agent") != -1 ||
			      index($ua,"seek") != -1 ||
			      index($ua,"search") != -1 ||
			      index($ua,"reap") != -1 ||
			      index($ua,"worm") != -1 ||
			      index($ua,"find") != -1 ||
			      index($ua,"index") != -1 ||
			      index($ua,"copy") != -1 ||
			      index($ua,"fetch") != -1);

  # Devices

  $tests->{AUDREY}        = (index($ua,"audrey") != -1);
  $tests->{IOPENER}       = (index($ua,"i-opener") != -1);
  $tests->{AVANTGO}        = (index($ua,"avantgo") != -1);
  $tests->{PALM}          = ($tests->{AVANTGO} || 
			     index($ua,"palmos") != -1 );
  $tests->{WAP}           = (index($ua,"up.browser") != -1 ||
			     index($ua,"nokia") != -1 ||
			     index($ua,"alcatel") != -1 ||
			     index($ua,"ericsson") != -1 ||
			     index($ua,"sie-") == 0 ||
			     index($ua,"wmlib") != -1 ||
			     index($ua," wap") != -1 ||
			     index($ua,"wap ") != -1 ||
			     index($ua,"wap/") != -1 ||
			     index($ua,"-wap") != -1 ||
			     index($ua,"wap-") != -1 ||
			     index($ua,"wap") == 0 ||
			     index($ua,"wapper") != -1 ||
			     index($ua,"zetor") != -1);
			     
			     
  # Operating System
  
  $tests->{WIN16}    = (index($ua,"win16") != -1 || index($ua,"16bit") != -1 || index($ua,"windows 3") != -1 ||
			index($ua,"windows 16-bit") != -1);
  $tests->{WIN3X}    = (index($ua,"win16") != -1 || index($ua,"windows 3") != -1 || index($ua,"windows 16-bit") != -1);
  $tests->{WIN31}    = (index($ua,"win16") != -1 || index($ua,"windows 3.1") != -1 || index($ua,"windows 16-bit") != -1);
  $tests->{WIN95}    = (index($ua,"win95") != -1 || index($ua,"windows 95") != -1);
  $tests->{WIN98}    = (index($ua,"win98") != -1 || index($ua,"windows 98") != -1);
  $tests->{WINNT}    = (index($ua,"winnt") != -1 || 
			index($ua,"windows nt") != -1 || 
			index($ua,"nt4") != -1 || 
			index($ua,"nt3") != -1);
  $tests->{WIN2K}    = (index($ua,"nt 5") != -1 || index($ua,"nt5") != -1);
  $tests->{WINME}    = (index($ua,"win 9x 4.90") != -1); # whatever
  $tests->{WIN32}    = (($tests->{WIN95} || $tests->{WIN98} || $tests->{WINME} || $tests->{WINNT} || 
			 $tests->{WIN2K}) || index($ua,"win32") != -1);
  $tests->{WINDOWS}  = (($tests->{WIN16} || $tests->{WIN31} || $tests->{WIN95} || $tests->{WIN98} ||
			 $tests->{WINNT} || $tests->{WIN32} || $tests->{WIN2K} || $tests->{WINME}) || index($ua,"win") != -1);
  
  # Mac operating systems
  
  $tests->{MAC}      = (index($ua,"macintosh") != -1 || index($ua,"mac_") != -1);
  $tests->{MAC68K}   = (($tests->{MAC}) && (index($ua,"68k") != -1 || index($ua,"68000") != -1));
  $tests->{MACPPC}   = (($tests->{MAC}) && (index($ua,"ppc") != -1 || index($ua,"powerpc") != -1));
  
  # Others
  
  $tests->{AMIGA}   = (index($ua,'amiga') != -1);
  $tests->{EMACS}   = (index($ua,'emacs') != -1);
  $tests->{OS2}     = (index($ua,'os/2') != -1);
  
  $tests->{SUN}     = (index($ua,"sun") != -1);
  $tests->{SUN4}    = (index($ua,"sunos 4") != -1);
  $tests->{SUN5}    = (index($ua,"sunos 5") != -1);
  $tests->{SUNI86}  = (($tests->{SUN}) && index($ua,"i86") != -1);
  
  $tests->{IRIX}    = (index($ua,"irix") != -1);
  $tests->{IRIX5}   = (index($ua,"irix5") != -1);
  $tests->{IRIX6}   = (index($ua,"irix6") != -1);
  
  $tests->{HPUX}    = (index($ua,"hp-ux") != -1);
  $tests->{HPUX9}   = (($tests->{HPUX}) && index($ua,"09.") != -1);
  $tests->{HPUX10}  = (($tests->{HPUX}) && index($ua,"10.") != -1);
  
  $tests->{AIX}   = (index($ua,"aix") != -1);
  $tests->{AIX1}  = (index($ua,"aix 1") != -1);
  $tests->{AIX2}  = (index($ua,"aix 2") != -1);
  $tests->{AIX3}  = (index($ua,"aix 3") != -1);
  $tests->{AIX4}  = (index($ua,"aix 4") != -1);
  
  $tests->{LINUX}     = (index($ua,"inux") != -1);
  $tests->{SCO}       = (index($ua,"sco") != -1 || index($ua,"unix_sv") != -1);
  $tests->{UNIXWARE}  = (index($ua,"unix_system_v") != -1);
  $tests->{MPRAS}     = (index($ua,"ncr") != -1);
  $tests->{RELIANT}   = (index($ua,"reliantunix") != -1);
  
  $tests->{DEC} = (index($ua,"dec") != -1 || index($ua,"osf1") != -1 || index($ua,"declpha") != -1 || 
		   index($ua,"alphaserver") != -1 || index($ua,"ultrix") != -1 ||
		   index($ua,"alphastation") != -1);
  
  $tests->{SINIX}    = (index($ua,"sinix") != -1);
  $tests->{FREEBSD}  = (index($ua,"freebsd") != -1);
  $tests->{BSD}      = (index($ua,"bsd") != -1);
  $tests->{X11}      = (index($ua,"x11") != -1);
  $tests->{UNIX}     = ($tests->{X11} || $tests->{SUN} || $tests->{IRIX} || $tests->{HPUX} ||
			$tests->{SCO} || $tests->{UNIXWARE} || $tests->{MPRAS} ||
			$tests->{RELIANT} || $tests->{DEC} || $tests->{LINUX} ||
			$tests->{BSD}); 

  $tests->{VMS} = (index($ua,"vax") != -1 || index($ua,"openvms") != -1);

  $self->{major} = $major;
  $self->{minor} = $minor;
  $self->{beta} = $beta;
}
    
sub browser_string {
    my ($self) = _self_or_default(@_);
    my $browser_string = undef;
    my $user_agent = $self->user_agent;
    if (defined $user_agent) {
        $browser_string = 'Netscape' if $self->netscape;
        $browser_string = 'MSIE' if $self->ie;  
        $browser_string = 'WebTV' if $self->webtv;
        $browser_string = 'AOL Browser' if $self->aol;
        $browser_string = 'Opera' if $self->opera;
        $browser_string = 'Mosaic' if $self->mosaic;
        $browser_string = 'Lynx' if $self->lynx;
    }
    return $browser_string;
}
    
sub os_string {
    my ($self) = _self_or_default(@_);
    my $os_string = undef;
    my $user_agent = $self->user_agent;
    if (defined $user_agent) {
        $os_string = 'Win95' if $self->win95;
        $os_string = 'Win98' if $self->win98;
        $os_string = 'WinNT' if $self->winnt;
        $os_string = 'Mac' if $self->mac;
        $os_string = 'Win3x' if $self->win3x;
        $os_string = 'OS2' if $self->os2;
        $os_string = 'Unix' if $self->unix && !$self->linux;
        $os_string = 'Linux' if $self->linux;
    }
    return $os_string;
}
    
sub version {
  my ($self, $check) = _self_or_default(@_);
  my $version;
  $version = $self->{major} + $self->{minor};
  if (defined $check) { 
    return $check == $version;
  } else {
    return $version;
  }
}
    
sub major {
  my ($self, $check) = _self_or_default(@_);
  my ($version) = $self->{major};
  if (defined $check) { 
    return $check == $version;
  } else {
    return $version;
  }
}
    
sub minor {
  my ($self, $check) = _self_or_default(@_);
  my ($version) = $self->{minor};
  if (defined $check) { 
      return ($check == $self->{minor});
  } else {
    return $version;
  }
}
    
sub beta {
  my ($self, $check) = _self_or_default(@_);
  my ($version) = $self->{beta};
  if ($check) { 
    return $check eq $version;
  } else {
    return $version;
  }
}

1;
    

__END__

=head1 NAME

HTTP::BrowserDetect - Determine the Web browser, version, and platform from an HTTP user agent string

=head1 SYNOPSIS

    use HTTP::BrowserDetect;

    my $browser = new HTTP::BrowserDetect($user_agent_string);

    # Detect operating system
    if ($browser->windows) {
      if ($browser->winnt) ...
      if ($brorwser->win95) ...
    }
    print $browser->mac;

    # Detect browser vendor and version
    print $browser->netscape;
    print $browser->ie;
    if (browser->major(4)) {
	if ($browser->minor() > .5) {
	    ...
	}
    }
    if ($browser->version() > 4) {
      ...;
    }
    
    # Process a different user agent string
    $browser->user_agent($another_user_agent_string);



=head1 DESCRIPTION

The HTTP::BrowserDetect object does a number of tests on an HTTP user
agent string.  The results of these tests are available via methods of
the object.

This module is based upon the JavaScript browser detection code
available at
B<http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html>.

=head2 CREATING A NEW BROWSER DETECT OBJECT AND SETTING THE USER AGENT STRING

=over 4

=item new HTTP::BrowserDetect($user_agent_string)

The constructor may be called with a user agent string specified.
Otherwise, it will use the value specified by $ENV{'HTTP_USER_AGENT'},
which is set by the web server when calling a CGI script.

You may also use a non-object-oriented interface.  For each method,
you may call HTTP::BrowserDetect::method_name().  You will then be
working with a default HTTP::BrowserDetect object that is created
behind the scenes.

=item user_agent($user_agent_string)

Returns the value of the user agent string.  When called with a
parameter, it resets the user agent and reperforms all tests on the
string.  This way you can process a series of user agent strings (from
a log file, perhaps) without creating a new HTTP::BrowserDetect object
each time.

=back

=head2 DETECTING BROWSER VERSION

=over 4

=item major($major)

Returns the integer portion of the browser version.
If passed a parameter, returns true if it equals
the browser major version.

=item minor($minor)

Returns the decimal portion of the browser version as a B<floating-point number> less than 1.  
For example, if the version is 4.05, this method returns .05; if the version is 4.5, this method returns .5.  
B<This is a change in behavior from previous versions of this module, which returned a 
string>.

If passed a parameter, returns true if equals the minor version.  

On occasion a version may have more than one decimal point, such 
as 'Wget/1.4.5'. The minor version does not include the second decimal point, 
or any further digits or decimals.

=item version($version)

Returns the version as a floating-point number.  If passed a
parameter, returns true if it is equal to the version
specified by the user agent string.

=item beta($beta)

Returns any the beta version, consisting of any non-numeric characters
after the version number.  For instance, if the user agent string is
'Mozilla/4.0 (compatible; MSIE 5.0b2; Windows NT)', returns 'b2'.  If
passed a parameter, returns true if equal to the beta version.

=back

=head2 DETECTING OS PLATFORM AND VERSION

The following methods are available, each returning a true or false
value.  Some methods also test for the operating system version.

  windows win16 win3x win31 win95 win98 winnt win32 win2k winme
  mac mac68k macppc
  os2
  unix 
  sun sun4 sun5 suni86 irix irix5 irix6 hpux hpux9 hpux10 
  aix aix1 aix2 aix3 aix4 linux sco unixware mpras reliant 
  dec sinix freebsd bsd
  vms
  amiga

It may not be possibile to detect Win98 in Netscape 4.x and earlier. 
On Opera 3.0, the userAgent string includes "Windows 95/NT4" on all Win32, so you can't distinguish between Win95 and WinNT.

=over 

=item os_string()

Returns one of the following strings, or undef.  This method exists solely for compatibility with the
B<HTTP::Headers::UserAgent> module.

  Win95, Win98, WinNT, Mac, Win3x, OS2, Unix, Linux

=back

=head2 DETECTING BROWSER VENDOR

The following methods are available, each returning a true or false value.  Some methods also
test for the browser version, saving you from checking the version separately.

  netscape nav2 nav3 nav4 nav4up nav45 nav45up navgold nav6 nav6up
  gecko
  ie ie3 ie4 ie4up ie5 ie55
  neoplanet neoplanet2 
  mosaic
  aol aol3 aol4 aol5 aol6
  webtv
  opera
  lynx
  emacs
  staroffice
  lotusnotes
  icab
  konqueror
  java


Netscape 6, even though its called six, in the userAgent string has version number 5.  The nav6 and nav6up methods correctly handle this quirk.

=over

=item browser_string()

Returns one of the following strings, or undef.

Netscape, MSIE, WebTV, AOL Browser, Opera, Mosaic, Lynx

=back

=head2 DETECTING OTHER DEVICES

The following methods are available, each returning a true or false value.

  wap
  audrey
  iopener
  palm
  avantgo

=head2 DETECTING ROBOTS

=item robot()

Returns true if the user agent appears to be a robot, spider,
crawler, or other automated Web client.

The following additional methods are available, each returning a true
or false value.  This is by no means a complete list of robots that
exist on the Web.

  wget
  getright
  yahoo 
  altavista 
  lycos 
  infoseek 
  lwp
  webcrawler 
  linkexchange 
  slurp 
  google

=head1 AUTHOR

Lee Semel, lee@semel.net


=head1 SEE ALSO

"The Ultimate JavaScript Client Sniffer, Version 3.0", B<http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html>.

perl(1), L<HTTP::Headers>, L<HTTP::Headers::UserAgent>.

=head1 COPYRIGHT

Copyright 1999-2001 Lee Semel.  All rights reserved.  This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut


     




