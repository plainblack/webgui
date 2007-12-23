package WebGUI::Test::Maker::Permission;

use base 'WebGUI::Test::Maker';
use Scalar::Util qw( blessed );
use Carp qw( croak );
use Test::More;


=head1 NAME

WebGUI::Test::Maker::Permission -- Test::Maker subclass for WebGUI Permissions

=head1 SYNOPSIS

 use Test::More;
 use WebGUI::Test::Maker::Permission;

 my $maker   = WebGUI::Test::Maker::Permission->new();

 $maker->prepare({
            object      => WebGUI::Asset->new,
            method      => "canView",
            pass        => [userId, userId],
            fail        => [userId, userId],
        });

 plan tests => $maker->plan;

 $maker->run;

=head1 DESCRIPTION

Test generator for testing WebGUI permissions. WebGUI permissions subroutines
take a single argument (a userId), or they use the default user from the
current session. They return true if the user has permission, or false 
otherwise.

This module tests permissions subroutines by running a list of userIds that
should either pass or fail the permissions. 

=head1 DEPENDS

This module depends on

=over 4

=item * 

Test::More

=back

=head1 METHODS

=head2 new

Create a new WebGUI::Test::Maker::Permission object.

=cut

=head2 get

Get a setting. See C<set> for a list of settings.

=cut

#----------------------------------------------------------------------------

=head2 plan

Returns the number of tests currently prepared. This module runs two tests 
for each userId in either the C<pass> or C<fail> keys of the C<prepare()>
hash reference.

=cut

sub plan {
    my $self        = shift;
    my $plan;
    
    for my $test ( @{$self->{_tests}} ) {
        if ($test->{pass}) {
            $plan += @{$test->{pass}} * 2;
        }
        if ($test->{fail}) {
            $plan += @{$test->{fail}} * 2;
        }
    }

    return $plan;
}

#----------------------------------------------------------------------------

=head2 plan_per_test

Returns undef. There is no way to pre-calculate how many tests this will run

=cut

sub plan_per_test {
    return undef;
}

#----------------------------------------------------------------------------

=head2 prepare

Prepare a test(s). Returns the object for convenience. The following keys 
are required:

=over 4

=item object

An instanciated object to work on.

=item method

The permissions method to test

=item pass

An array reference of userIds or WebGUI::User objects that should pass the 
permissions test.

=item fail

An array reference of userIds or WebGUI::User objects that should fail the 
permissions test.

=back

There are no optional parameters.

=cut

sub prepare {
    my $self        = shift;
    my @tests       = @_;
    my $test_num    = 0;
    for my $test (@tests) {
        $test_num++;

        croak("Couldn't prepare: Test $test_num has no object or className")
            unless $test->{object} || exists($test->{className});
        croak("Couldn't prepare: Test $test_num has needs a session object")
            if exists($test->{className}) && !$test->{session};
        croak("Couldn't prepare: Test $test_num has no method")
            unless $test->{method};
        croak("Couldn't prepare: Test $test_num has no pass/fail")
            unless $test->{pass} || $test->{fail};
        croak("Couldn't prepare: Test $test_num, pass is not an array reference")
            if $test->{pass} && ref $test->{pass} ne "ARRAY";
        croak("Couldn't prepare: Test $test_num, fail is not an array reference")
            if $test->{fail} && ref $test->{fail} ne "ARRAY";

        # Make sure pass and fail arrayrefs are userIds
        for my $array ( $test->{'pass'}, $test->{'fail'} ) {
            for ( my $i = 0; $i < @{ $array }; $i++ ) {
                # If is a User object, replace with userId
                if ( blessed $array->[$i] && $array->[$i]->isa("WebGUI::User") ) {
                    $array->[$i] = $array->[$i]->userId;
                }
            }
        }

        push @{$self->{_tests}}, $test;
    }

    return $self;
}

#----------------------------------------------------------------------------

=head2 run

Run the tests we've prepared and delete them as we run them.

=cut

sub run {
    my $self        = shift;
     
    while (my $test = shift @{ $self->{_tests} }) {
        my $session;
        my @methodArguments = ();
        my ($o, $m, $comment);

        if (exists $test->{className}) {
            $o = $test->{className};
            $m = $test->{method};
            $session = $test->{session};
            push @methodArguments, $session;
            $comment = $test->{className};
        }
        else {
            $o = $test->{object};
            $m = $test->{method};
            $session = $o->session;
            $comment = blessed $o;
        }

        ##This needs to be refactored into a sub/method, instead of copy/paste
        ##duplicated in fail, below.
        if ($test->{pass}) {
            for my $userId (@{$test->{pass}}) {
                my @args    = @methodArguments;

                # Test the default session user
                my $oldUser = $session->user;
                $session->user( { userId => $userId } );
                ok( $o->$m(@args), "userId $userId passes $m check using default user for " . $comment );
                $session->user( { user => $oldUser });

                # Test the specified userId
                push @args, $userId;
                # Test the userId parameter
                ok( $o->$m(@args), "userId $userId passes $m check for " . $comment );

            }
        }
        if ($test->{fail}) {
            for my $userId (@{$test->{fail}}) {
                my @args = @methodArguments;

                # Test the default session user
                my $oldUser = $session->user;
                $session->user( { userId => $userId } );
                ok( !($o->$m(@args)), "userId $userId fails $m check using default user for " . $comment );
                $session->user( { user => $oldUser });

                # Test the userId parameter
                push @args, $userId;
                ok( !($o->$m(@args)), "userId $userId fails $m check for " . $comment );

            }
        }
    }
}

#----------------------------------------------------------------------------

=head2 set

Set a setting.

Currently this module has no settings

=cut

1;
