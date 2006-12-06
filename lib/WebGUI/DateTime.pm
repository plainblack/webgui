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

WebGUI::Session::Date - DateTime subclass with additional WebGUI methods

=head1 SYNOPSIS

 my $dt		= $session->date->new("2006-11-06 21:12:45");
 my $dt		= $session->date->new(time);
 my $dt		= $session->date->new({ year => 2006, month => 11, day => 6 });
 
 my $mysql	= $dt->toMysql;		# Make a MySQL date/time string
 my $mysqlDate	= $dt->toMysqlDate;	# Make a MySQL date string
 my $mysqlTime	= $dt->toMysqlTime;	# Make a MySQL time string
 
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

Creates a new object from a MySQL Date/Time string with the UTC time zone.

=head2 new ( integer )

Creates a new object from an epoch time.

=head2 new ( "mysql" => string, "time_zone" => string)

Creates a new object from a MySQL Date/Time string with the specified time zone

=head2 new ( hash )

Creates a new object from a hash of data passed directly to DateTime.

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

Returns a MySQL Date/Time string.

=cut

sub toMysql
{
	return $_[0]->strftime("%Y-%m-%d %H:%M:%S");
}




#######################################################################

=head2 toMysqlDate

Returns a MySQL Date string. Any time data stored by this object will be 
ignored.

=cut

sub toMysqlDate
{
	return $_[0]->strftime("%Y-%m-%d");
}




#######################################################################

=head2 toMysqlTime

Returns a MySQL Time string. Any date data stored by this object will be 
ignored.

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




=head1 SEE ALSO

=over 8

=item *

perldoc DateTime

=back



=cut

1;
