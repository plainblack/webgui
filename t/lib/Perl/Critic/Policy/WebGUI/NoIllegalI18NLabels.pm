package Perl::Critic::Policy::WebGUI::NoIllegalI18NLabels;

use strict;
use warnings;
use Readonly;
use FindBin;

use Perl::Critic::Utils qw{ :all };
use base 'Perl::Critic::Policy';

use WebGUI::International;
use WebGUI::Test;

=head1 Perl::Critic::Policy::WebGUI::NoIllegalI18NLabels

Scan WebGUI modules for i18n calls and make sure that each
call has a corresponding i18n table entry

=cut

our $VERSION = '0.1';

Readonly::Scalar my $DESC => q{i18n calls that do not have corresponding i18n table entries};

sub supported_parameters { return ()                   }
 
sub default_severity     { return $SEVERITY_LOWEST     }

sub default_themes       { return 'WebGUI'             }

sub applies_to           { return qw/PPI::Token::Word/ }

##Set up a cache of i18n objects.  Later this will be extended to handle scoping,
##probably by having a pointer

sub initialize_if_enabled {
    my ($self, $config) = @_;
    $self->{_i18n_objects} = {};
    my $session = WebGUI::Test->session;
    $self->{i18n} = WebGUI::International->new($session);
    return $TRUE;
}

=head2 violates

Gets called on every block, and then scans it for i18n object creations
and corresponding calls.  It will then check each call to make sure
that the i18n entry that is being requested exists.

For now, do the check without handling nested scopes.  For nested scopes, I need
to find a way to detect the nesting (does PPI have a parent check?) and then
push a scope onto the object for later reference.

=cut

sub violates {
    my ($self, $elem, undef) = @_;
    ##$elem has stringification overloaded by default.
    return unless $elem eq 'new'
               or $elem eq 'get';
    return if !is_method_call($elem);
    if ($elem eq 'new') {  ##Object creation,  check for class.
        my $operator = $elem->sprevious_sibling     or return;
        my $class    = $operator->sprevious_sibling or return;
        return unless $class eq 'WebGUI::International';

        my $symbol_name = _get_symbol_name($class);

        ##It's an i18n object, see if a default namespace was passed in.
        my $arg_list = $elem->snext_sibling;
        return unless ref $arg_list eq 'PPI::Structure::List'; 
        my @arguments = _get_args($arg_list);
        my $namespace = $arguments[1]->[0];
        $namespace = $namespace->string;
        $self->{_i18n_objects}->{$symbol_name} = $namespace;
        return;
    }
    elsif ($elem eq 'get') {  ##i18n fetch?  Check symbol
        my $symbol_name = _get_symbol_name($elem);
        my $arg_list = $elem->snext_sibling;
        return unless ref $arg_list eq 'PPI::Structure::List'; 
        my @arguments = _get_args($arg_list);
        ##Many assumptions being made here
        return unless $arguments[0]->[0]->isa('PPI::Token::Quote');
        my $label = $arguments[0]->[0]->string;
        my $namespace = $self->{_i18n_objects}->{$symbol_name};
        if ($arguments[1]) {
            $namespace = $arguments[1]->[0]->string;
        }
        if (! $self->{i18n}->get($label, $namespace)) {
            return $self->violation(
                $DESC,
                sprintf('label=%s, namespace=%s', $label, $namespace),
                $elem
            );
        }
        return;
    }
    return;
}

sub _get_args {
    my ($list) = @_;
    ##Borrowed from Subroutines/ProhibitManyArgs
    my @inner = $list->schildren;
    if (1 == @inner and $inner[0]->isa('PPI::Statement::Expression')) {
        @inner = $inner[0]->schildren;
    }
    my @arguments = split_nodes_on_comma(@inner);
    return @arguments;
}

sub _get_symbol_name {
    my ($class) = @_;

    my $assignment = $class->sprevious_sibling  or return;
    my $symbol     = $assignment->sprevious_sibling or return;
    return unless ref($symbol) eq 'PPI::Token::Symbol';
    my $symbol_name = $symbol.'';  ##Is there a better way to stringify?
    return $symbol_name;
}

1;
