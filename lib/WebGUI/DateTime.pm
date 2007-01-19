package WebGUI::DateTime;

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

use strict;
use base 'DateTime';


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
 
 
 my $mysql	= $dt->toMysql;		# Make a MySQL date/time string
 my $mysqlDate	= $dt->toMysqlDate;	# Make a MySQL date string
 my $mysqlTime	= $dt->toMysqlTime;	# Make a MySQL time string
 
 
 my $ical	= $dt->toIcal;		# Make an iCal date/time string
 my $icalDate	= $dt->toIcalDate;	# Make an iCal date string
 my $icalTime	= $dt->toIcalTime;	# Make an iCal time string
 
 
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

=head2 new ( string )

Creates a new object from a MySQL Date/Time string in the format 
"2006-11-06 21:12:45". 

This string is assumed to be in the UTC time zone. If it is not, use the 
"mysql" => string constructor, below.

=head2 new ( integer )

Creates a new object from an epoch time.

=head2 new ( "mysql" => string, "time_zone" => string )

Creates a new object from a MySQL Date/Time string that is in the specified 
time zone

=head2 new ( hash )

Creates a new object from a hash of data passed directly to DateTime. See
perldoc DateTime for the proper keys to be used.

Note: Unless you specify a time_zone, your object will exist in a "floating" 
time zone. It is best that you always specify a time zone, and use UTC before
doing date/time math.

=cut

sub new 
{
	# Drop-in replacement for Perl's DateTime.pm
	my $class	= shift;
	my $self;
	
	#use Data::Dumper;
	#warn "Args to DateTime->new: ".Dumper \@_;
	
	if (@_ > 1 && grep /^mysql$/, @_)
	{
		my %hash	= @_;
		$hash{time_zone} ||= "UTC";
		my $string	= delete $hash{mysql};
		my %mysql	= _splitMysql($string);
		$hash{$_}	= $mysql{$_}
				for keys %mysql;
		
		$self	= $class->SUPER::new(%hash);
	}
	elsif (@_ > 1)
	{
		$self	= $class->SUPER::new(@_);
	}
	elsif ($_[0] =~ /^\d+$/)
	{
		$self	= DateTime->from_epoch(epoch=>$_[0], time_zone=>"UTC");
	}
	else
	{
		$self	= $class->SUPER::new(
				(_splitMysql($_[0])),
				time_zone	=> "UTC",
				);
	}
	
	# If no DateTime object created yet, I don't know how
	unless ($self)
	{
		return;
	}
	
	return bless $self, $class;
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
		return $self->strftime('%Y%m%dT%H%M%SZ');
	}
	else
	{
		return $self->clone->set_time_zone("UTC")->strftime('%Y%m%dT%H%M%SZ');
	}
}




#######################################################################

=head2 toIcalDate

Returns only the date portion in the format suitable for iCal. Does not adjust
time zone.

=cut

sub toIcalDate
{
	return $_[0]->strftime('%Y%m%d');
}




#######################################################################

=head2 toMysql

Returns a MySQL Date/Time string in the UTC time zone.  This method is deprecated
and will be removed at some point in the future.

=cut

sub toMysql
{
	return $_[0]->clone->set_time_zone("UTC")->strftime("%Y-%m-%d %H:%M:%S");
}




#######################################################################

=head2 toMysqlDate

Returns a MySQL Date string. Any time data stored by this object will be 
ignored. Is not adjusted for time zone.  This method is deprecated
and will be removed at some point in the future.


=cut

sub toMysqlDate
{
	return $_[0]->strftime("%Y-%m-%d");
}




#######################################################################

=head2 toMysqlTime

Returns a MySQL Time string. Any date data stored by this object will be 
ignored. Is not adjusted for time zone.  This method is deprecated
and will be removed at some point in the future.


=cut

sub toMysqlTime
{
	return $_[0]->strftime("%H:%M:%S");
}




#######################################################################

=head2 _splitMysql ( string )

Class method that splits a MySQL Date/Time string into a hash to be passed into 
DateTime

=cut

sub _splitMysql
{
	my $string	= shift;
	my ($y,$m,$d,$h,$n,$s) 	= split /\D+/,$string;
	my %hash	= (
			year		=> $y,
			month		=> $m,
			day		=> $d,
			hour		=> $h,
			minute		=> $n,
			second		=> $s,
			);
	
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
