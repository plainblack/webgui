package WebGUI::Test::Maker;

use base 'Test::Builder::Module';

my $CLASS = __PACKAGE__;

=head1 NAME

WebGUI::Test::Maker

=head1 SYNOPSIS

 use Test::More;
 use WebGUI::Test::Maker;

 my $maker   = WebGUI::Test::Maker->new();

 $maker->set( test => sub { ... } );
 $maker->set( plan_per_test => 2 );

 $maker->prepare({
            title       => "Test something",
            args        => [ ... ],
        });

 plan tests => $maker->plan;

 $maker->run;

=head1 DESCRIPTION

Test generator for generating repeatable tests. 

Set a subroutine that runs some tests and run it over and over with
different arguments.

=head1 DEPENDS

This module depends on

=over 4

=item * 

Test::More

=back

=head1 METHODS

=head2 new

Create a new WebGUI::Test::Maker object.

=cut

sub new {
    my $class   = shift;
    my $self    = {};

    return bless $self, $class;
}

#----------------------------------------------------------------------------

=head2 get

Get a setting. Set L<set> for a list of settings.

=cut

sub get {
    my $self    = shift;
    my $key     = shift;

    return $self->{_settings}->{$key};
}

#----------------------------------------------------------------------------

=head2 plan

Returns the number of tests currently prepared. This module is so generic
that you must set the C<plan_per_test> value before calling this method.

=cut

sub plan {
    my $self        = shift;
    
    return $self->plan_per_test * @{$self->{_tests}};
}

#----------------------------------------------------------------------------

=head2 plan_per_test

Returns the current value of the C<plan_per_test> setting.

=cut

sub plan_per_test {
    return $self->get("plan_per_test");
}

#----------------------------------------------------------------------------

=head2 prepare

Prepare a test(s). Returns the object for convenience. The following keys 
are optional:

=over 4

=item args

An array reference of arguments to the subroutine.

=back

There are no required arguments.

=cut

sub prepare {
    my $self        = shift;
    my @tests       = @_;
    my $test_num    = 0;
    for my $test (@tests) {
        $test_num++;

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

    my $tb = $CLASS->builder;
    # This is to fix SKIP and TODO detection
    local $Test::Builder::Level = $Test::Builder::Level + 1;
     
    while (my $test = shift @{ $self->{_tests} }) {
        my $sub     = $self->get("test");
        if ($test->{args}) {
            $sub->(@{ $test->{args} });
        }
        else {
            $sub->();
        }
    }
}

#----------------------------------------------------------------------------

=head2 set

Set a setting.

Available settings:

=over 4

=item test

A subref that runs some tests. The first argument to this subref will be the
WebGUI::Test::Maker object. The second and subsequent arguments will be the
C<args> key from the prepared test.

=item plan_per_test

Set the number of tests that each C<test> sub runs to be used to plan the 
number of total tests that will be run.

=back

=cut

sub set {
    my $self    = shift;
    my $key     = shift;
    my $value   = shift;

    $self->{_setting}->{$key} = $value;
}

1;
