package WebGUI::FormProcessor;

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
use WebGUI::DateTime;
use WebGUI::HTML;
use WebGUI::Session;

=head1 NAME

Package WebGUI::FormProcessor;

=head1 DESCRIPTION

This package helps in the processing of the form variables that are returned from any WebGUI form.

=head1 SYNOPSIS

 use WebGUI::FormProcessor;
 $value = WebGUI::FormProcessor::process("favoriteColor","selectList","black");

 $value = WebGUI::FormProcessor::checkbox("whichOne");
 $value = WebGUI::FormProcessor::checkList("dayOfWeek");
 $value = WebGUI::FormProcessor::combo("fruit");
 $value = WebGUI::FormProcessor::contentType("text");
 $value = WebGUI::FormProcessor::date("endDate");
 $value = WebGUI::FormProcessor::dateTime("whenToDoIt");
 $value = WebGUI::FormProcessor::email("emailAddress");
 $value = WebGUI::FormProcessor::fieldType("fieldType");
 $value = WebGUI::FormProcessor::filterContent("javascript");
 $value = WebGUI::FormProcessor::float("distance");
 $value = WebGUI::FormProcessor::group("groupToPost");
 $value = WebGUI::FormProcessor::hidden("wid");
 $value = WebGUI::FormProcessor::hiddenList("colors");
 $value = WebGUI::FormProcessor::HTMLArea("description");
 $value = WebGUI::FormProcessor::integer("size");
 $value = WebGUI::FormProcessor::interval("timeToLive");
 $value = WebGUI::FormProcessor::password("identifier");
 $value = WebGUI::FormProcessor::phone("cellPhone");
 $value = WebGUI::FormProcessor::radio("whichOne");
 $value = WebGUI::FormProcessor::radioList("dayOfWeek");
 $value = WebGUI::FormProcessor::selectList("dayOfWeek");
 $value = WebGUI::FormProcessor::template("templateId");
 $value = WebGUI::FormProcessor::text("firstName");
 $value = WebGUI::FormProcessor::textarea("emailMessage");
 $value = WebGUI::FormProcessor::timeField("wakeupCall");
 $value = WebGUI::FormProcessor::url("homepage");
 $value = WebGUI::FormProcessor::yesNo("happy");
 $value = WebGUI::FormProcessor::zipcode("workZip");

=head1 METHODS

These functions are available from this package:

=cut

sub _checkEmailAddy {
	return ($_[0] =~ /^([A-Z0-9]+[._-]?){1,}([A-Z0-9]+[_-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i);
}

#-------------------------------------------------------------------

=head2 checkbox ( name )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub checkbox {
	return selectList($_[0]);
}


#-------------------------------------------------------------------

=head2 checkList ( name )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub checkList {
	return selectList($_[0]);
}


#-------------------------------------------------------------------

=head2 combo ( name )

Returns either an array of values or a scalar value depending upon what you request.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub combo {
	if ($session{form}{$_[0]."_new"}) {
		return $session{form}{$_[0]."_new"};
	}
	return selectList($_[0]);
}


#-------------------------------------------------------------------

=head2 contentType ( name )

Returns a content type. Defaults to "mixed".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub contentType {
	return ($session{form}{$_[0]} || "mixed");
}

#-------------------------------------------------------------------

=head2 date ( name )

Returns an epoch datestamp.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub date {
	return WebGUI::DateTime::setToEpoch($session{form}{$_[0]});
}


#-------------------------------------------------------------------

=head2 dateTime ( name )

Returns an epoch datestamp.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub dateTime {
	return date($_[0]."_date") + timeField($_[0]."_time");
}

#-------------------------------------------------------------------

=head2 email ( name )

Returns an email address.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub email {
	if (_checkEmailAddy($session{form}{$_[0]})) {
		return $session{form}{$_[0]};
	}
	return undef;
}


#-------------------------------------------------------------------

=head2 fieldType ( name )

Returns a field type. Defaults to "text".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub fieldType {
	return ($session{form}{$_[0]} || "text");
}


#-------------------------------------------------------------------

=head2 filter ( name )

Returns a scalar filter type. Defaults to "most".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub filter {
	return ($session{form}{$_[0]} || "most");
}


#-------------------------------------------------------------------

=head2 float ( name )

Returns a floating point (decimal) number. Defaults to "0.0".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub float {
	if ($session{form}{$_[0]} =~ /^[\d\.\-]+$/) {
		return $session{form}{$_[0]};
	}
	return 0.0;
}


#-------------------------------------------------------------------

=head2 group ( name )

Returns a group Id. Defaults to 2 (registered users).

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub group {
	my $value = selectList($_[0]);
	if (defined $value) {
		return $value;
	}
	return 2;
}

#-------------------------------------------------------------------

=head2 hidden ( name )

Returns a string.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub hidden {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 hiddenList ( name )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub hiddenList {
	return selectList($_[0]);
}


#-------------------------------------------------------------------

=head2 HTMLArea ( name )

Returns a string of HTML that has been cleaned of header information.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub HTMLArea {
	return WebGUI::HTML::cleanSegment($session{form}{$_[0]});
}


#-------------------------------------------------------------------

=head2 integer ( name )

Returns an integer. Defaults to "0".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub integer {
	if ($session{form}{$_[0]} =~ /^[\d\-]+$/) {
		return $session{form}{$_[0]};
	}
	return 0;
}


#-------------------------------------------------------------------

=head2 interval ( name )

Returns an interval in seconds. Defaults to "0".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub interval {
	return (WebGUI::DateTime::intervalToSeconds($session{form}{$_[0]."_interval"},$session{form}{$_[0]."_units"}) || 0);
}


#-------------------------------------------------------------------

=head2 password ( name )

Returns a string.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub password {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 phone ( name )

Returns a string filtered to allow only digits, spaces, and these special characters: + - ( )

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub phone {
	if ($session{form}{$_[0]} =~ /^[\d\s\-\+\(\)]+$/) {
		return $session{form}{$_[0]};
	}
	return undef;
}


#-------------------------------------------------------------------

=head2 process ( name, type [ , default ] )

Returns whatever would be the expected result of the method type that was specified. This method also checks to make sure that the field is not returning a string filled with nothing but whitespace.

=over 

=item name

The name of the form variable to retrieve.

=item type

The type of form element this variable came from. Defaults to "text" if not specified.

=item default

The default value for this variable. If the variable is undefined then the default value will be returned instead.

=back

=cut

sub process {
	my ($name, $type, $default) = @_;
	my $value;
	$type = "text" if ($type eq "");
	$value = &$type($name);
	unless (defined $value) {
		$value = $default;
	}
	if ($value =~ /^[\s]+$/) {
		return undef;
	}
	return $value;
}


#-------------------------------------------------------------------

=head2 radio ( name )

Returns a string.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub radio {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 radioList ( name )

Returns a string.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub radioList {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 selectList ( name )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub selectList {
	my @data = $session{cgi}->param($_[0]);
	return wantarray ? @data : join("\n",@data);
}


#-------------------------------------------------------------------

=head2 template ( name )

Returns a template id. Defaults to "1".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub template {
	if ($session{form}{$_[0]} =~ /^\d+$/) {
		return $session{form}{$_[0]};
	}
	return 1;
}


#-------------------------------------------------------------------

=head2 text ( name )

Returns a string of text.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub text {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 textarea ( name )

Returns a string of text.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub textarea {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 timeField ( name )

Returns the number of seconds since 00:00:00 on a 24 hour clock. Note, this will adjust for the user's time offset in the reverse manner that the form field adjusts for it in order to make the times come out appropriately.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub timeField {
	return WebGUI::DateTime::timeToSeconds($session{form}{$_[0]})-($session{user}{timeOffset}*3600);
}


#-------------------------------------------------------------------

=head2 url ( name )

Returns a URL.

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub url {
	if ($session{form}{$_[0]} =~ /mailto:/) {
		return $session{form}{$_[0]};
	} elsif (_checkEmailAddy($session{form}{$_[0]})) {
		return "mailto:".$session{form}{$_[0]};
	} elsif ($session{form}{$_[0]} =~ /:\/\//) {
		return $session{form}{$_[0]};
	}
	return "http://".$session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 yesNo ( name )

Returns either a 1 or 0 representing yes and no. Defaults to "0".

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub yesNo {
	if ($session{form}{$_[0]} > 0) {
		return 1;
	}
	return 0;
}


#-------------------------------------------------------------------

=head2 zipcode ( name )

Returns a string which allows uppercase alpha characters, digits, spaces, and hypens (dashes).

=over 

=item name

The name of the form variable to retrieve.

=back

=cut

sub zipcode {
	if ($session{form}{$_[0]} =~ /^[A-Z\d\s\-]+$/) {
		return $session{form}{$_[0]};
	}
	return undef;
}



1;

