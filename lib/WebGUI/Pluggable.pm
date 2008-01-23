package WebGUI::Pluggable;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
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

=head1 FUNCTIONS

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 instanciate ( module, method, params )

Dynamically ensures that a plugin module is loaded into memory. Then instanciates a new object from the module. Croaks on failure.

=head3 module

The name of the module you'd like to load like "WebGUI::Asset::Snippet";

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

