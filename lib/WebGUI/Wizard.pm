package WebGUI::Wizard;

use Scalar::Util qw(blessed);
use WebGUI::Form;

=head1 NAME

WebGUI::Wizard -- Generate wizards

=head1 SYNOPSIS

 package MyWizard;

 use base 'WebGUI::Wizard';

 sub _get_steps { [qw( step1 )] }

 # Show a form for the first step
 sub www_step1 { 
    my ( $self ) = @_;
    my $f   = $self->getForm; # Get a WebGUI::HTMLForm
    $f->text( name => "user" );
    return $f->print;
 }

 # Process the form for the first step
 sub www_step1Save {
     my ( $self ) = @_;
     if ( my $user = $self->session->form->get('user') ) {
         $self->set({ 'user' => $user });
         return;
     }
     else {
         return "Must specify a user!";
     }
 }

 # Override cleanup to provide a friendly message
 sub www_cleanup {
     my ( $self ) = @_;
     $self->cleanup;
     return "Thank you! " . $self->get('user');
 }

=head1 DESCRIPTION

This class allows you to easily create reusable wizards that walk a user 
through a step-by-step process to perform a task.

A user begins a Wizard by visiting ?op=wizard;wizard_class=MyWizard. Then
WebGUI shows the first step's form (in the synopsis above, step1 / www_step1 ).

Once the user completes the form, the www_step1Save subroutine is run. If an 
error is returned, the user is shown the error and the same form again. 
Otherwise, the wizard continues to the next step.

After all the steps in the wizard are complete, the wizard runs www_cleanup
to clean up after the wizard and return the user to their previous page.

All parameters gathered by the wizard are saved between page loads into 
the user's session scratch. Only by finishing or restarting the wizard will 
their progress be lost.

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 new ( session ) 

Create a new instance of a Wizard.

=cut

sub new {
    my ( $class, $session ) = @_;
    die "Require WebGUI::Session as first argument" 
        unless blessed( $session ) && $session->isa( 'WebGUI::Session' );
    return bless { _session => $session, }, $class;
}

#----------------------------------------------------------------------------

=head2 _get_steps ( )

Return all the names of the steps involved in this wizard, in order. Steps may
be skipped and/or back-tracked to.

=cut

# OVERRIDE THIS!
sub _get_steps {
    return [];
}

#----------------------------------------------------------------------------

=head2 canView ( ) 

Returns true if the current user is allowed to view this wizard. You should
override this.

=cut

sub canView {
    return 1;
}

#----------------------------------------------------------------------------

=head2 cleanup ( )

Remove any leftovers after the wizard is finished

=cut

sub cleanup {
    my ( $self ) = @_;
    $self->session->scratch->delete( $self->getCacheKey );
    return;
}

#----------------------------------------------------------------------------

=head2 dispatch ( ) 

Dispatch the request to the correct step(s). Thaw the user's params and freeze
them again after everything's done.

=cut

sub dispatch {
    my ($self) = @_;

    if ( !$self->canView ) {
        return $self->session->privilege->noAccess;
    }

    # See if we process a form
    if ( my $step = $self->getCurrentStep ) { 
        $self->session->log->info( "Processing " . $step );
        # First fold in the new form bits
        $self->thaw;
        my $processSub   = $self->can( 'www_' . $step . 'Save' );
        my $errorMessage = $processSub->($self);
        if ($errorMessage) {
            $self->session->log->info( "Error in " . $step );
            my $formSub = $self->can( 'www_' . $step );
            return $self->wrapStyle( $errorMessage . $formSub->($self) );
        }
        else {
            my $step = $self->getNextStep;
            if ( $step ) {
                # Not done, run the next step
                $self->session->log->info( "Showing next step: " . $step );
                $self->setCurrentStep( $step );
                my $formSub = $self->can( 'www_' . $step );
                my $output = $formSub->($self);
                $self->freeze;
                return $self->wrapStyle( $output );
            }
            else {
                # We're done, run the cleanup
                return $self->wrapStyle( $self->www_cleanup );
            }
        }
    }
    else {
        # Starting over
        $self->cleanup;
        my $step = $self->_get_steps->[0];
        $self->setCurrentStep( $step );
        $self->session->log->info( "Starting wizard: " . $step );
        my $formSub = $self->can( 'www_' . $step );
        my $output = $formSub->($self);
        $self->freeze;
        return $self->wrapStyle( $output );
    }
} ## end sub dispatch

#----------------------------------------------------------------------------

=head2 freeze ( )

Save the current params to long-term storage.

=cut

sub freeze {
    my ( $self ) = @_;
    $self->session->scratch->set( $self->getCacheKey, JSON->new->encode( $self->{_params} || {} ) );
}

#----------------------------------------------------------------------------

=head2 get ( [param] )

Get a hashref of params. If C<param> is specified, get only that specific param.

=cut

sub get {
    my ( $self, $param ) = @_;
    if ( $param ) { 
        return $self->{_params}->{$param};
    }
    return $self->{_params};
}

#----------------------------------------------------------------------------

=head2 getCacheKey ( )

Get the unique key to store the params under.

=cut

sub getCacheKey {
    my ( $self ) = @_;
    return "Wizard " . blessed( $self );
}

#----------------------------------------------------------------------------

=head2 getCurrentStep ( )

Get the name of the current step.

=cut

sub getCurrentStep {
    my ( $self ) = @_;
    if ( $self->{_step} ) {
        return $self->{_step};
    }
    elsif ( $self->session->form->get('wizard_class') eq blessed($self) ) {
        return $self->session->form->get('wizard_step');
    }
    return; # No step, so start at the beginning
}

#----------------------------------------------------------------------------

=head2 getForm ( [step] )

Get a WebGUI::HTMLForm object for a given step, defaulting to the current step.

=cut

sub getForm {
    my ( $self, $step ) = @_;
    $step ||= $self->getCurrentStep;
    my $form = WebGUI::HTMLForm->new( $self->session, 
        action      => $self->getStepUrl( $step ),
    );
    return $form;
}

#----------------------------------------------------------------------------

=head2 getNextStep ( )

Get the name of the next step 

=cut

sub getNextStep {
    my ( $self, $step ) = @_;
    $step ||= $self->getCurrentStep;
    for my $i ( 0 .. @{ $self->_get_steps } - 1 ) {
        if ( $self->_get_steps->[$i] eq $step ) {
            return $self->_get_steps->[ $i + 1 ];
        }
    }
}

#----------------------------------------------------------------------------

=head2 getStepUrl ( step )

Get the URL to go to a specific step. Only used when there is no processing
to do.

=cut

sub getStepUrl {
    my ( $self, $step ) = @_;
    return unless $step;
    return $self->session->url->page( 
        'op=wizard;wizard_class=' . (blessed $self) . ';wizard_step=' . $step
    );
}

#----------------------------------------------------------------------------

=head2 session ( )

Get the WebGUI::Session object

=cut

sub session {
    return $_[0]->{_session};
}

#----------------------------------------------------------------------------

=head2 set ( params )

Set a hashref of params.

=cut

sub set {
    my ( $self, $args ) = @_;
    $self->{_params} = { %{$self->{_params}}, %$args };
    return $self->{_params};
}

#----------------------------------------------------------------------------

=head2 setCurrentStep ( )

Set the current step. Useful before calling dispatch().

=cut

sub setCurrentStep {
    my ( $self, $step ) = @_;
    return $self->{_step} = $step;
}

#----------------------------------------------------------------------------

=head2 thaw ( )

Thaw the user's parameters from the long-term storage, overwriting any current
parameters.

=cut

sub thaw {
    my ( $self ) = @_;
    my $json = $self->session->scratch->get( $self->getCacheKey );
    return $self->{_params} = $json ? JSON->new->decode( $json ) : {};
}

#----------------------------------------------------------------------------

=head2 wrapStyle ( output )

Wrap output in the Wizard style.

TODO: Add wizard-specific template vars like a progress bar and back links

=cut

sub wrapStyle {
    my ( $self, $output ) = @_;

    return $output;
}

#----------------------------------------------------------------------------

=head2 www_cleanup ( ) 

Clean up after the user, removing the variables, and return them to their 
previous place.

NOTE: If you override this, you must remember to call C<cleanup> manually!

=cut

sub www_cleanup {
    my ( $self ) = @_;

    $self->cleanup;
    $self->session->http->setRedirect( $self->session->url->page );
    return "redirect";
}

1;
