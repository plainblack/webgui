package WebGUI::FormProcessor;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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

This is a convenience package to the individual form controls. It allows you to get the form post results back without having to load each form control seperately, instanciate an object, and call methods.

=head1 SYNOPSIS

 use WebGUI::FormProcessor;
 $value = WebGUI::FormProcessor::process("favoriteColor","selectList","black");

 $value = WebGUI::FormProcessor::someFormControlType("fieldName");

 Example:

 $value WebGUI::FormProcessor::text("title");

=head1 METHODS

These functions are available from this package:

=cut

sub _checkEmailAddy {
        return ($_[0] =~ /^([A-Z0-9]+[._+-]?){1,}([A-Z0-9]+[_+-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i);
}

#-------------------------------------------------------------------

=head2 AUTOLOAD ()

Dynamically creates functions on the fly for all the different form control types.

=cut

sub AUTOLOAD {
        our $AUTOLOAD;
        my $name = (split /::/, $AUTOLOAD)[-1];
	my $fieldName = shift;
        my $cmd = "use WebGUI::Form::".$name;
        eval ($cmd);
        if ($@) {
                WebGUI::ErrorHandler::error("Couldn't compile form control: ".$name.". Root cause: ".$@);
                return undef;
        }
        my $class = "WebGUI::Form::".$name;
        return $class->new({name=>$fieldName})->getValueFromPost;
}

#-------------------------------------------------------------------

=head2 fieldType ( name )

Returns a field type. Defaults to "text".

=head3 name

The name of the form variable to retrieve.

=cut

sub fieldType {
	return ($session{form}{$_[0]} || "text");
}


#-------------------------------------------------------------------

=head2 filterContent ( name )

Returns a scalar filter type. Defaults to "most".

=head3 name

The name of the form variable to retrieve.

=cut

sub filterContent {
	return ($session{form}{$_[0]} || "most");
}



#-------------------------------------------------------------------

=head2 password ( name )

Returns a string.

=head3 name

The name of the form variable to retrieve.

=cut

sub password {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 phone ( name )

Returns a string filtered to allow only digits, spaces, and these special characters: + - ( )

=head3 name

The name of the form variable to retrieve.

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

=head3 name

The name of the form variable to retrieve.

=head3 type

The type of form element this variable came from. Defaults to "text" if not specified.

=head3 default

The default value for this variable. If the variable is undefined then the default value will be returned instead.

=cut

sub process {

	my ($name, $type, $default) = @_;
	my $value;
	$type = "text" if ($type eq "");
	$value = &$type($name);

	unless (defined $value) {
		return $default;
	}
	if ($value =~ /^[\s]+$/) {
		return undef;
	}

	return $value;
}


#-------------------------------------------------------------------

=head2 radio ( name )

Returns a string.

=head3 name

The name of the form variable to retrieve.

=cut

sub radio {
	return $session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 radioList ( name )

Returns a string.

=head3 name

The name of the form variable to retrieve.

=cut

sub radioList {
	return $session{form}{$_[0]};
}



#-------------------------------------------------------------------

=head2 template ( name )

Returns a template id. Defaults to "1".

=head3 name

The name of the form variable to retrieve.

=cut

sub template {
	if (exists $session{form}{$_[0]}) {
		return $session{form}{$_[0]};
	}
	return 1;
}



#-------------------------------------------------------------------

=head2 timeField ( name )

Returns the number of seconds since 00:00:00 on a 24 hour clock. Note, this will adjust for the user's time offset in the reverse manner that the form field
adjusts for it in order to make the times come out appropriately.

=head3 name

The name of the form variable to retrieve.

=cut

sub timeField {
	return WebGUI::DateTime::timeToSeconds($session{form}{$_[0]})-($session{user}{timeOffset}*3600);
}


#-------------------------------------------------------------------

=head2 url ( name )

Returns a URL.

=head3 name
The name of the form variable to retrieve.

=cut

sub url {
	if ($session{form}{$_[0]} =~ /mailto:/) {
		return $session{form}{$_[0]};
	} elsif (_checkEmailAddy($session{form}{$_[0]})) {
		return "mailto:".$session{form}{$_[0]};
	} elsif ($session{form}{$_[0]} =~ /^\// || $session{form}{$_[0]} =~ /:\/\// || $session{form}{$_[0]} =~ /^\^/) {
		return $session{form}{$_[0]};
	}
	return "http://".$session{form}{$_[0]};
}


#-------------------------------------------------------------------

=head2 yesNo ( name )

Returns either a 1 or 0 or undef representing yes, no, and undefined. Defaults to "0".

=head3 name

The name of the form variable to retrieve.

=cut

sub yesNo {
	if ($session{form}{$_[0]} > 0) {
		return 1;
	}
	elsif ($session{form}{$_[0]} eq "") {
		return undef;
	}
	else {
		return 0;
	}
}



1;

