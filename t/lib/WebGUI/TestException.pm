package WebGUI::TestException;

use strict;

use Test::Builder;
use WebGUI::Exception;
use Sub::Uplevel qw( uplevel );
use Exporter qw(import);

our @EXPORT = qw( throws_deeply );

=head1 NAME

Package WebGUI::TestException

=head1 DESCRIPTION

This module provides a convenient way to test for thrown exceptions. The idea is based on Test::Exception, which
does provide a means to test for a specific exception class, but cannot test attributes of that class, which is
necessary in the WebGUI test suite. This module can do that.

=head1 CAVEATS

This module uses Sub::Uplevel. In Test::Exception some hocus pocus is being done with the caller() function. The
functions _quiet_caller and _try_as_caller are directly copied from Test::Exception. I do not know why this
hocuspocus is being in that module however, since doing 'eval { uplevel 1, $codeRef }' seems to work too. On my
platform at least =). For the time being, I leave those subs in here so that they may be used. They are commented
out by default, though.

=cut

#----------------------------------------------------------------------------
sub _quiet_caller (;$) { ## no critic Prototypes
    my $height = $_[0];
    $height++;
    if( wantarray and !@_ ) {
        return (CORE::caller($height))[0..2];
    }
    else {
        return CORE::caller($height);
    }
}

#----------------------------------------------------------------------------
sub _try_as_caller {
    my $coderef = shift;

    # local works here because Sub::Uplevel has already overridden caller
    local *CORE::GLOBAL::caller;
    { no warnings 'redefine'; *CORE::GLOBAL::caller = \&_quiet_caller; }

    eval { uplevel 3, $coderef };
    return $@;
};

=head2 throws_deeply ( $codeRef, $expectClass, $fields, $message )

Executes the code ref and verifies it throws an exception of the given class with the given fields.

=head3 $codeRef

The code ref containing the code to be evalled.

=head3 $expectClass

The class name the thrown exception should have.

=head3 $fields

Hashref containg the exception fields and their expected values.

=head3 $message

The message that should be displayed by prove for this test.

=cut

#----------------------------------------------------------------------------
sub throws_deeply {
    my $evalBlock   = shift;
    my $expectClass = shift;
    my $fields      = shift;
    my $message     = shift;
    my $testBuilder = Test::Builder->new;

    # Dunno why uplevel 1 might not work and why caller is redefined. 
    # Copied _try_as_caller and _quiet_caller are from Test::Exception.
    # Uplevel 1 seems to work though.
    #_try_as_caller( $evalBlock );
    eval { uplevel 1, $evalBlock };
    
    my $e = Exception::Class->caught();
    my $gotClass = ref $e;

    # Check class
    unless ($gotClass eq $expectClass) {
        $testBuilder->ok(0, $message);
        $testBuilder->diag("Wrong class:\n\texpected : '$expectClass'\n\t     got : '$gotClass'");

        return 0;
    }

    # Check fields
    my $errors;
    foreach (keys %$fields) {
        my $result = $e->$_;

        unless ( $result eq $fields->{$_} ) {
            $errors .= "'$_' => \n\texpected : '".$fields->{$_}."'\n\t     got : '$result'\n";
        }
    }
    if ($errors) {
        $testBuilder->ok(0, $message);
        $testBuilder->diag("Fields do not match:\n$errors");

        return 0;
    }

    # Test passed.
    $testBuilder->ok(1, $message);
    return 1;
}

1;

