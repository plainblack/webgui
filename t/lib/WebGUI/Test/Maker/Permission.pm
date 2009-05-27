package WebGUI::Test::Maker::Permission;

use base 'WebGUI::Test::Maker';
use Scalar::Util qw( blessed );
use Carp qw( croak );
use Test::More;

my $CLASS = __PACKAGE__;

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

=item className

The class name of a module to work on.  This would be useful for class methods.

=item method

The permissions method to test

=item pass

An array reference of userIds or WebGUI::User objects that should pass the 
permissions test.  If each user has a username, it will be used in the
test comment output instead of the userId.

=item fail

An array reference of userIds or WebGUI::User objects that should fail the 
permissions test.  If each user has a username, it will be used in the
test comment output instead of the userId.


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
            runUsers($session, $o, $m, \@methodArguments, $test->{pass}, 1, $comment);
        }
        if ($test->{fail}) {
            runUsers($session, $o, $m, \@methodArguments, $test->{fail}, 0, $comment);
        }
    }
}

#----------------------------------------------------------------------------

=head2 set

Set a setting.

Currently this module has no settings

=cut

#----------------------------------------------------------------------------

=head2 runUsers

Process an array of users for tests.

=head3 session

A WebGUI session object, used to access and/or alter the default session
user for the tests.

=head3 object

A WebGUI object or class, used for testing.

=head3 method

The method on the object or class to call for each test.

=head3 precedingArguments

Any arguments that should be pushed onto the argument list before a userId.

=head3 users

An array ref of users.

=head3 passing

A boolean, which if true, says that the users are expected to pass each test.
If false, the users will be expected to fail, which means that if they do
fail that the test itself will pass.

=head3 comment

A specific comment to add to the test's comment.  Usually this would
be something like the username or userId.

=cut

sub runUsers {
    my ($session, $object,  $method, $precedingArguments,
        $users,   $passing, $comment ) = @_;
    my $failing = !$passing;
    my $tb = $CLASS->builder;
    # This is to fix detection of SKIP and TODO
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    foreach my $userId (@{ $users }) {
        my @args = @{ $precedingArguments };
        my $oldUser = $session->user;
        $session->user( { userId => $userId  } );
        my $role = $session->user->username
                 ? "user ".$session->user->username
                 : "userId ".$userId;
        $tb->ok(
            ( $object->$method(@args) xor $failing ),
            "$role passes $method check using default user for " . $comment
        );
        $session->user( { user   => $oldUser } );

        # Test the specified userId
        push @args, $userId;
        # Test the userId parameter
        $tb->ok(
            ( $object->$method(@args) xor $failing ),
            "$role passes $method check for " . $comment
        );
    }
}

1;
