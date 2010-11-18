package WebGUI::DateTime;

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
use WebGUI::International;

use base 'DateTime';


### Some formats for strftime()
my $MYSQL_TIME     = '%H:%M:%S';
my $MYSQL_DATE     = '%Y-%m-%d';
my $MYSQL_DATETIME = $MYSQL_DATE . q{ } . $MYSQL_TIME;

my $ICAL_DATETIME  = '%Y%m%dT%H%M%SZ';
my $ICAL_DATE      = '%Y%m%d';



=head1 NAME

WebGUI::DateTime - DateTime subclass with additional WebGUI methods

=head1 SYNOPSIS

 # Create an object from a MySQL date/time in the UTC time zone
 my $dt		= WebGUI::DateTime->new("2006-11-06 21:12:45");
 
 # Create an object from an epoch time in the UTC time zone
 my $dt		= WebGUI::DateTime->new(time);
 
 # Create an object from a MySQL date/time in a specific time zone
 my $dt		= WebGUI::DateTime->new( mysql => "2006-11-06 21:12:45", time_zone => "America/Chicago" );
 
 # Create an object from a hash of data
 my $dt		= WebGUI::DateTime->new( year => 2006, month => 11, day => 6 );
 
 
 # Get a string to give to MySQL
 my $mysqlDatetime  = $dt->toDatabase;
 my $mysqlDate      = $dt->toDatabaseDate;
 my $mysqlTime      = $dt->toDatabaseTime

 # Get a string for WebGUI::Form elements
 my $userDatetime   = $dt->toUserTimeZone;
 my $userDate       = $dt->toUserTimeZoneDate;
 my $userTime       = $dt->toUserTimeZoneTime;
 
 # Get strings to be used for iCalendar feeds
 my $ical	        = $dt->toIcal;		
 my $icalDate	    = $dt->toIcalDate;	
 my $icalTime	    = $dt->toIcalTime;	
 
 # Get a string based on the user's preferred date/time format in the user's 
 # time zone.
 my $webguiDate     = $dt->webguiDate;

 # Get a string based on a passed WebGUI date/time format
 my $webguiDate     = $dt->webguiDate($webguiFormat);
 
 ### See perldoc DateTime for additional methods ###

=head1 DESCRIPTION

This module is intended as a drop-in replacement for Perl's DateTime module, 
with additional methods for translating to and from MySQL Date/Time field 
strings.

NOTE: This module replaces WebGUI::Session::DateTime, which has a problem 
dealing with time zones.

=head1 METHODS

=cut



#######################################################################

=head2 new (session, string )

Creates a new object from a MySQL Date/Time string in the format 
"2006-11-06 21:12:45". 

This string is assumed to be in the UTC time zone. If it is not, use the 
"mysql" => string constructor, below.

=head2 new (session, integer )

Creates a new object from an epoch time.

=head2 new (session, "mysql" => string, "time_zone" => string )

Creates a new object from a MySQL Date/Time string that is in the specified 
time zone

=head2 new (session, hash )

Creates a new object from a hash of data passed directly to DateTime. See
perldoc DateTime for the proper keys to be used.

Note: Unless you specify a time_zone, your object will exist in a "floating" 
time zone. It is best that you always specify a time zone, and use UTC before
doing date/time math.

=cut

sub new 
{
	# Drop-in replacement for Perl's DateTime
	my $class	= shift;
    my $param0 = $_[0];
    my $self;
    my $locale = 'en_US';
    my $session;
        
    if (ref $param0 eq "WebGUI::Session") {
       $session = shift;
       my $i18n = WebGUI::International->new($session);
       my $language = $i18n->getLanguage($session->user->get('language'));
	   $locale = $language->{languageAbbreviation} || 'en';
       $locale .= "_".$language->{locale} if ($language->{locale});
    }

	#use Data::Dumper;
	#warn "Args to DateTime->new: ".Dumper \@_;

    if (! scalar(@_)  || $_[0] eq '') {
        $self = $class->SUPER::now();
    }
	elsif (@_ > 1 && grep /^mysql$/, @_) {
		my %hash	= @_;
		$hash{time_zone} ||= "UTC";
		my $string	= delete $hash{mysql};
		my %mysql	= _splitMysql($string);
		$hash{$_}	= $mysql{$_}
				for keys %mysql;
		
		$self	= $class->SUPER::new(%hash);
	}
	elsif (@_ > 1) {
		$self	= $class->SUPER::new(@_);
	}
	elsif ($_[0] =~ /^-?\d+$/) {
		$self	= DateTime->from_epoch(epoch=>$_[0], time_zone=>"UTC", locale=>$locale);
	}
    else {
        $self = $class->SUPER::new(
            _splitMysql($_[0]),
            time_zone   => "UTC",
            locale      => $locale,
        );
    }
	
    #Set the session object
    $self->{_session} = $session;
    
	# If no DateTime object created yet, I don't know how
	unless ($self)
	{
		return undef;
	}
    
	
	return bless $self, $class;
}




#######################################################################

=head2 cloneToUTC

Returns a clone of the current object with the time zone changed to UTC

=cut

sub cloneToUTC {
    my $self = shift;
    my $copy = $self->clone;
    $copy->set_time_zone("UTC");
    return $copy;
}

#######################################################################

=head2 cloneToUserTimeZone

Returns a clone of the current object with the time zone changed to the
current users's time zone.

=cut

sub cloneToUserTimeZone {
    my $self = shift;
    my $copy = $self->clone;
    my $timezone = $self->session->user->get("timeZone");
    $copy->set_time_zone($timezone);
    return $copy;
}

#######################################################################

=head2 from_object

Handle copying all WebGUI::DateTime specific data.  This is a class method.

This method overrides the from_object in DateTime to keep WebGUI::DateTime
specific information being passed between object instances. Most DateTime 
math actually creates new objects.

=cut

sub from_object {
    my $class   = shift;
    my %args    = @_;
    my $session = $args{object}->session;
    my $copy    = $class->SUPER::from_object(@_);
    $copy->session($session);
    return $copy;
}

#######################################################################

=head2 set

Handle copying all WebGUI::DateTime specific data. This is an object method.

This method overrides the set in DateTime to keep WebGUI::DateTime specific
information being passed between object instances. Some DateTime operations
create a new object.

=cut

sub set {
    my $self    = shift;
    my $session = $self->session;

    my $copy = $self->SUPER::set(@_);

    $copy->session($session);
    return $copy;
}

#######################################################################

=head2 toDatabase

Returns a MySQL Date/Time string in the UTC time zone

=cut

sub toDatabase {
    my $self = shift;
    my $copy = $self->cloneToUTC;
    return $copy->strftime($MYSQL_DATETIME);
}

#######################################################################

=head2 toDatabaseDate

Returns a MySQL Date string. Any time data stored by this object will be 
ignored. Is adjusted to the UTC time zone.

=cut

sub toDatabaseDate {
    my $self = shift;
    my $copy = $self->cloneToUTC;
    return $copy->strftime($MYSQL_DATE);
}

#######################################################################

=head2 toDatabaseTime

Returns a MySQL Time string adjusted to UTC. Any date data stored by this object will be 
ignored.

=cut

sub toDatabaseTime {
    my $self = shift;
    my $copy = $self->cloneToUTC;
    return $copy->strftime($MYSQL_TIME);
}

#######################################################################

=head2 toIcal

Returns a Date/Time string in the UTC time zone in the iCalendar format.

 20061124T120000Z

=cut

sub toIcal
{
	my $self	= shift;
	
	if ($self->time_zone->is_utc)
	{
		return $self->strftime($ICAL_DATETIME);
	}
	else
	{
		return $self->clone->set_time_zone("UTC")->strftime($ICAL_DATETIME);
	}
}




#######################################################################

=head2 toIcalDate

Returns only the date portion in the format suitable for iCal. Does not adjust
time zone.

=cut

sub toIcalDate
{
	return $_[0]->strftime($ICAL_DATE);
}




#######################################################################

=head2 toMysql

This method is deprecated and will be removed in the future.

Returns a MySQL Date/Time string in the UTC time zone.  

=cut

sub toMysql
{
	return $_[0]->clone->set_time_zone("UTC")->strftime("%Y-%m-%d %H:%M:%S");
}




#######################################################################

=head2 toMysqlDate

This method is deprecated and will be removed in the future.

Returns a MySQL Date string. Any time data stored by this object will be 
ignored. Is not adjusted for time zone.  

=cut

sub toMysqlDate
{
	return $_[0]->strftime("%Y-%m-%d");
}




#######################################################################

=head2 toMysqlTime

This method is deprecated and will be removed in the future.

Returns a MySQL Time string. Any date data stored by this object will be 
ignored. Is not adjusted for time zone.  

=cut

sub toMysqlTime
{
	return $_[0]->strftime("%H:%M:%S");
}

#######################################################################

=head2 toUserTimeZone

Returns a MySQL Date/Time string in the user's time zone.

=cut

sub toUserTimeZone {
    my $self = shift;
    my $copy = $self->cloneToUserTimeZone;
    return $copy->strftime($MYSQL_DATETIME);
}

#######################################################################

=head2 toUserTimeZoneDate

Returns a MySQL Date string adjusted to the current user's time
zone. Any time data stored by this object will be ignored.

=cut

sub toUserTimeZoneDate {
    my $self = shift;
    my $copy = $self->cloneToUserTimeZone;
    return $copy->strftime($MYSQL_DATE);
}

#######################################################################

=head2 toUserTimeZoneTime

Returns a MySQL Time string adjusted to the current user's time
zone. Any date data stored by this object will be ignored.

=cut

sub toUserTimeZoneTime {
    my $self = shift;
    my $copy = $self->cloneToUserTimeZone;
    return $copy->strftime($MYSQL_TIME);
}

#######################################################################

=head2 truncate

Handle copying all WebGUI::DateTime specific data. This is an object method.

This method overrides the truncate in DateTime to keep WebGUI::DateTime specific
information being passed between object instances. Some DateTime operations
create a new object.

=cut

sub truncate {
    my $self    = shift;
    my $session = $self->session;

    my $copy = $self->SUPER::truncate(@_);

    $copy->session($session);
    return $copy;
}


#######################################################################

=head2 session

gets/sets the session variable in the object.  
This is going to have to be changed eventually so you don't have to set the session

=cut

sub session {
    my $self = shift;
    my $session = shift;
    
    if($session) {
       $self->{_session} = $session;
    }
    
    return $self->{_session};
}



=head2 webguiToStrftime ( format ) 

Change a WebGUI format into a Strftime format.

NOTE: %M in WebGUI's format has no equivalent in strftime format, so it will
be replaced with "_varmonth_". Do something with it.

=cut

sub webguiToStrftime {
    my ( $self, $format ) = @_;
    $format ||= "%z %Z";
    my $session = $self->session;
    my $temp;

    #--- date format preference
    $temp = $session->user->get('dateFormat') || '%y-%M-%D';
    $format =~ s/\%z/$temp/g;

    #--- time format preference
    $temp = $session->user->get('timeFormat') || '%H:%n %p';
    $format =~ s/\%Z/$temp/g;

    #--- convert WebGUI date formats to DateTime formats
    my %conversion = (
                "c" => "B",
                "C" => "b",
                "d" => "d",
                "D" => "e",
                "h" => "I",
                "H" => "l",
                "j" => "H",
                "J" => "k",
                "m" => "m",
                "M" => "_varmonth_",
                "n" => "M",
                "t" => "Z",
                "O" => "z",
                "p" => "P",
                "P" => "p",
                "s" => "S",
                "V" => "V",
                "w" => "A",
                "W" => "a",
                "y" => "Y",
                "Y" => "y"
                );

    $format =~ s/\%(\w)/\~$1/g;
    foreach my $key (keys %conversion) {
        my $replacement = $conversion{$key};
        $format =~ s/\~$key/\%$replacement/g;
    }

    return $format;
}

#######################################################################

=head2 webguiDate ( format )

Parses WebGUI dateFormat string and converts to DateTime format

=head3 format

A string representing the output format for the date. Defaults to '%z %Z'. You can use the following to format your date string:

 %% = % (percent) symbol.
 %c = The calendar month name.
 %C = The calendar month name abbreviated.
 %d = A two digit day.
 %D = A variable digit day.
 %h = A two digit hour (on a 12 hour clock).
 %H = A variable digit hour (on a 12 hour clock).
 %j = A two digit hour (on a 24 hour clock).
 %J = A variable digit hour (on a 24 hour clock).
 %m = A two digit month.
 %M = A variable digit month.
 %n = A two digit minute.
 %O = Offset from GMT/UTC represented in four digit form with a sign. Example: -0600
 %p = A lower-case am/pm.
 %P = An upper-case AM/PM.
 %s = A two digit second.
 %t = Time zone name.
 %V = Week number.
 %w = Day of the week. 
 %W = Day of the week abbreviated. 
 %y = A four digit year.
 %Y = A two digit year. 
 %z = The current user's date format preference.
 %Z = The current user's time format preference.

=cut

sub webguiDate {
   my $self = shift;
   my $session = $self->session;
   return undef unless ($session);

   my $format = $self->webguiToStrftime( shift || "%z %Z" );

   #--- %M
   my $datestr = $self->strftime($format);
   my $temp = int($self->month);
   $datestr =~ s/\%_varmonth_/$temp/g;

   #--- return
   return $datestr;
}
#######################################################################


=head2 _splitMysql ( string )

Class method that splits a MySQL Date/Time string into a hash to be passed into 
DateTime

=cut

sub _splitMysql
{
	my $string	= shift;
	my %hash;

    @hash{ qw( year month day hour minute second ) } 	
        = $string =~ m{
          ^
          \D*
          (\d{1,4})   # Year
          \D+
          (\d{1,2})   # Month
          \D+
          (\d{1,2})   # Day
          (?: \D+
              (\d{1,2})   # Hours
              \D+
              (\d{1,2})   # Minutes
              \D+
              (\d{1,2})   # Seconds
          )?
          \D*
          $
        }x;

    $hash{ hour   } ||= 0;
    $hash{ minute } ||= 0;
    $hash{ second } ||= 0;
	return %hash;
}



=head1 ABOUT TIME ZONES

It is best that all date/time math be done in the UTC time zone, because of such
wonderful things as "daylight savings time" and "leap seconds".

To this end, read the documentation for each method to find out if they 
automatically convert their result into UTC.

=head1 SEE ALSO

=over 8

=item *

perldoc DateTime

=back



=cut

1;
