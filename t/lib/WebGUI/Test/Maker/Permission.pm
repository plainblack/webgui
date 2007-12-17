package WebGUI::Test::Maker::Permission;

use base 'WebGUI::Test::Maker';
use Scalar::Util qw( blessed );
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

        croak("Couldn't prepare: Test $test_num has no object")
            unless $test->{object};
        croak("Couldn't prepare: Test $test_num has no method")
            unless $test->{method};
        croak("Couldn't prepare: Test $test_num has no pass/fail")
            unless $test->{pass} || $test->{fail};
        croak("Couldn't prepare: Test $test_num, pass is not an array reference")
            if $test->{pass} && ref $test->{pass} ne "ARRAY";
        croak("Couldn't prepare: Test $test_num, fail is not an array reference")
            if $test->{fail} && ref $test->{fail} ne "ARRAY";

        # Make sure pass and fail arrayrefs are userIds
        for my $array ( $test->{pass, fail} ) {
            for ( my $i = 0; $i < @$array; $i++ ) {
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
        my $o       = $test->{object};
        my $m       = $test->{method};

        if ($test->{pass}) {
            for my $userId (@{$test->{pass}}) {
                # Test the userId parameter
                ok( $o->$m($userId), "$userId passes $m check for " . blessed $o );

                # Test the default session user
                my $oldUser = $o->session->user;
                $o->session->user( WebGUI::User->new($o->session, $userId) );
                ok( $o->$m(), "$userId passes $m check using default user for " . blessed $o );
                $o->session->user($oldUser);
            }
        }
        if ($test->{fail}) {
            for my $userId (@{$test->{fail}}) {
                # Test the userId parameter
                ok( !($o->$m($userId)), "$userId fails $m check for " . blessed $o );

                # Test the default session user
                my $oldUser = $o->session->user;
                $o->session->user( WebGUI::User->new($o->session, $userId) );
                ok( !($o->$m()), "$userId fails $m check using default user for " . blessed $o );
                $o->session->user($oldUser);
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
