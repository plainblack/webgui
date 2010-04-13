package WebGUI::Pluggable;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Module::Find;
use Carp qw(croak);

# Carps should always bypass this package in error reporting
$Carp::Internal{ __PACKAGE__ }++;

=head1 NAME

Package WebGUI::Pluggable

=head1 DESCRIPTION

This package provides a standard way of quickly and safely dynamically loading plugins. 

=head1 SYNOPSIS

 use WebGUI::Pluggable;

 eval { WebGUI::Pluggable::load($module) };

 my $object = eval { WebGUI::Pluggable::instanciate($module, $method, \@params) };

 my $output = eval { WebGUI::Pluggable::run($module, $function, \@params) };

 my @modules    
    = WebGUI::Pluggable::find( $namespace, 
        { 
            exclude     => [ $moduleToExclude ],
        } 
    );

 my @loadedModules
    = WebGUI::Pluggable::findAndLoad( $namespace, 
        { 
            onLoadFail => sub { warn "Failed to load " . shift . " because " . shift },
        }
    );

=head1 FUNCTIONS

These functions are available from this package:

=cut

#----------------------------------------------------------------------------

=head2 find ( namespace, options )

Return an array of all the modules in the given namespace. Will search all 
@INC directories. C<options> is a hashref of options with the following keys

 exclude        => An arrayref of modules to exclude. A module name can include an asterisk to glob.
 onelevel       => If true, only find sub modules (children), no deeper
                find( "CGI", { onelevel => 1 } ) would match "CGI::Session" but 
                not "CGI::Session::File"
 return         => "name" - Return just the last part of the package, so CGI::Session would return "Session"

=cut

# TODO: If necessary, use File::Find::Rule instead of Module::Find
sub find {
    my $namespace       = shift;
    my $options         = shift;
    
    # Argument sanity
    if ( $options && ref $options ne "HASH" ) {
        WebGUI::Error::InvalidParam->throw( 
            error => "Second argument to find() must be hash reference",
        );
    }
    if ( $options->{ exclude } && ref $options->{ exclude } ne "ARRAY" ) {
        WebGUI::Error::InvalidParam->throw( 
            error => "'exclude' option must be array reference"
        );
    }

    my @modules         = ();

    if ( $options->{ onelevel } ) {
        @modules    = Module::Find::findsubmod $namespace;
    }
    else {
        @modules    = Module::Find::findallmod $namespace;
    }
    
    ### Remove hidden files
    @modules    = grep { !/::[.]/ } @modules;

    ### Exclusions
    # Create a hash for quick lookups
    if ( $options->{ exclude } ) {
        my %modulesHash;
        @modulesHash{ @modules } = ( 1 ) x @modules;
        delete @modulesHash{ @{ $options->{exclude} } };
        @modules    = keys %modulesHash;
        my @excludePatterns = map { s/(?<!\.)\*/.*/g; $_; } grep { /\*/ } @{ $options->{exclude} };
        if (@excludePatterns) {
            my $pattern         = join q{|}, @excludePatterns;
            my $exclusions      = qr/$pattern/;
            @modules = grep { ! m/$exclusions/ } @modules;
        }
    }

    ### Return valu
    # If "name", just grab the last part
    if ( $options->{ return } eq "name" ) {
        @modules = map { /::([^:]+)$/; $1 } @modules;
    }

    return @modules;
}

#----------------------------------------------------------------------------

=head2 findAndLoad ( namespace, options )

Find modules and load them into memory. Returns an array of modules that are
loaded. 

Uses L<find> to find the modules, see L<find> for information on arguments.

Additional options for this method:

   onLoadFail       = A subroutine to run when a module fails to load, given 
                      the following arguments:
                        1) The module name
                        2) The error message from $@

=cut

sub findAndLoad {
    my $namespace   = shift;
    my $options     = shift;

    my @modules     = find( $namespace, $options );
    my @loadedModules;

    MODULE:
    for my $module ( @modules ) {
        # Try to load
        if (!eval { load( $module ) }) {
            if ( $options->{ onLoadFail } ) {
                $options->{ onLoadFail }->( $module, $@ );
            }
            next MODULE;
        }

        # Module loaded successfully
        push @loadedModules, $module;
    }

    return @loadedModules;
}

#-------------------------------------------------------------------

=head2 instanciate ( module, sub, params )

Dynamically ensures that a plugin module is loaded into memory. Then instanciates a new object from the module. Croaks on failure.

=head3 module

The name of the module you'd like to load like "WebGUI::Asset::Snippet";

=head3 sub

The name of the constructor you would like to invoke from the module.  Usually "new", or sometimes "create".

=head3 params

An array ref of params to send to the constructor.  In WebGUI, the first param should be a WebGUI::Session
object.

=cut

sub instanciate {
    my ($module, $sub, $params) = @_;
    if ( ! eval { load($module); 1 } ) {
        croak "Could not instanciate object using $sub on $module: $@";
    }
    # Module loaded properly
    unless ($module->can($sub)) {
        croak "Could not instanciate object using $sub on $module because $sub is not a valid method.";
    }
    my $object;
    if (! eval{$object = $module->$sub(@{$params}); 1}) {
        if ( ref $@ ) {
            die $@;
        }
        croak "Could not instanciate object using $sub on $module because $@";
    }
    if (defined $object) {
        return $object;
    }
    croak "Could not instanciate object using $sub on $module. The result is undefined.";
}

#-------------------------------------------------------------------

=head2 load ( module )

Dynamically ensures that a plugin module is loaded into memory. Croaks on failure.

=head3 module

The name of the module you'd like to load like "WebGUI::Asset::Snippet";

=cut

# Cache results of failures.  Modules with compile errors will pass a require check if done a second time.
my %moduleError;
sub load {
    my $module = shift;
    if ($moduleError{$module}) {
        croak "Could not load $module because $moduleError{$module}";
    }

    # Try to load the module
    my $modulePath = $module . ".pm";
    $modulePath =~ s{::|'}{/}g;
    if (eval { require $modulePath; 1 }) {
        return 1;
    }
    else {
        $moduleError{$module} = $@;
        croak "Could not load $module because $@";
    }
}

#-------------------------------------------------------------------

=head2 run ( module, sub, params )

Dynamically ensures that a plugin module is loaded into memory. Then executes a function in that new module.  Croaks on failure.

=head3 module

The name of the module you'd like to load like "WebGUI::Asset::Snippet";

=head3 sub

The name of a subroutine to execute.

=head3 params

An array reference of parameters to pass in to the sub routine.

=cut

sub run {
    my ($module, $sub, $params) = @_;
    if (! eval { load($module); 1 }) {
        croak "Unable to run $sub on $module: $@";
    }
    elsif (my $sub = $module->can($sub)) {
        # Let any other errors propagate
        return $sub->(@$params);
    }
    else {
        croak "Could not run $sub on $module because it does not exist";
    }
}

1;

