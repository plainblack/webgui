package WebGUI::Test::Maker::HTML;

use base 'WebGUI::Test::Maker';
use Scalar::Util qw( blessed );
use Carp qw( croak );
use Test::More;


=head1 NAME

WebGUI::Test::Maker::HTML -- Test::Maker subclass for WebGUI HTMLs

=head1 SYNOPSIS

 use Test::More;
 use WebGUI::Test::Maker::HTML;

 my $maker   = WebGUI::Test::Maker::HTML->new();

 $maker->prepare({
            object      => $object,
            method      => "www_editSave",
            user        => WebGUI::User->new,
            userId      => "userId",
            formParams  => { ... },
            uploads     => { ... },
            
            # Test for a WebGUI::Session::Privilege page
            test_privilege  => "permission",

            # Test for some regular expressions
            test_regex  => [ qr/../, qr/.../, ... ],
        });

 plan tests => $maker->plan;

 $maker->run;

=head1 DESCRIPTION

This Test::Maker subclass tests the HTML output by WebGUI methods in a 
variety of ways.

Uses WebGUI::Test->getPage to get the HTML for a page, and so is limited
to whatever C<getPage> can access.

=head1 TODO

Provide a method to give a proper HTML::Parser to test with.

Provide a method to test that a certain page was created with a certain 
template.

=head1 DEPENDS

This module depends on

=over 4

=item * 

Test::More

=back

=head1 METHODS

=head2 new

Create a new WebGUI::Test::Maker::HTML object.

=head2 get

Get a setting. Set L<set> for a list of settings.

=cut

#----------------------------------------------------------------------------

=head2 plan

This module plans as follows:

    - 1 and only 1 test for any test_privilege test
    - 1 test for each member of a test_regex test

=cut

sub plan {
    my $self        = shift;
    my $plan;
    
    for my $test ( @{ $self->{_tests} } ) {
        if ($test->{test_privilege}) {
            $plan++;
            next;
        }
        if ($test->{test_regex}) {
            $plan += @{$test->{test_regex}};
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

=back

At least one of the following keys are required:

=over 4

=item test_privilege

Tests for a WebGUI::Session::Privilege response. Valid values for this key
are: adminOnly, insufficient, noAccess, notMember, vitalComponent

=item test_regex

Tests for some regular expressions. This key must be an array reference of 
qr().

=back

The following key are optional:

=over 4

=item user

A WebGUI::User object to use for the test.

=item userId

A user ID to make a WebGUI::User object to use for the test

=item formParams

A hash reference of form parameters to use for the test

=item uploads 

A hash reference of file uploads to use for the test

=back

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
        croak("Couldn't prepare: Test $test_num has test (test_privilege or test_regex)")
            unless $test->{test_privilege} || $test->{test_regex};
        croak("Couldn't prepare: Test $test_num, test_regex is not an array reference")
            if $test->{test_regex} && ref $test->{test_regex} ne "ARRAY";
        croak("Couldn't prepare: Test $test_num, $test->{test_privilege} is not a valid test_privilege value (adminOnly, insufficient, noAccess, notMember, vitalComponent)")
            if $test->{test_privilege} && $test->{test_privilege} !~ m/adminOnly|insufficient|noAccess|notMember|vitalComponent/;

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
    
        # Get the HTML
        my $opts    = {};
        for my $key (qw{ }) {
            $opts->{$key} = $test->{$key};
        }

        my $html
            = WebGUI::Test->getPage( $o, $m, $opts );

        # Run the tests
        if ($test->{test_privilege}) {
            my $priv_method = $test->{test_privilege};
            my $test        = $o->session->privilege->$priv_method();

            like( $html, $test, "$m contains privilege message $priv_method for object " . blessed $o );

            next;
        }
        
        if ($test->{test_regex}) {
            for my $regex ( @{ $test->{test_regex} } ) {
                like( $html, $regex, "$m contains $regex for object " . blessed $o );
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
