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
    eval { load($module) };
    if ($@) {
        croak "Could not instanciate object using $sub on $module because $module could not be loaded.";
    }
    else {
        unless ($module->can($sub)) {
            croak "Could not instanciate object using $sub on $module because $sub is not a valid method.";
        }
        my $object = eval{$module->$sub(@{$params})};
        if ($@) {
            croak "Could not instanciate object using $sub on $module because $@";
        }
        else {
            unless (defined $object) {
                croak "Could not instanciate object using $sub on $module. The result is undefined.";
            }
            return $object;
        }
    }
}

#-------------------------------------------------------------------

=head2 load ( module )

Dynamically ensures that a plugin module is loaded into memory. Croaks on failure.

=head3 module

The name of the module you'd like to load like "WebGUI::Asset::Snippet";

=cut

sub load {
    my $module = shift;
    my $modulePath = $module.".pm";
    $modulePath =~ s{::}{/}g;
    eval { require $modulePath };
    if ($@) {
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
    eval { load($module) };
    if ($@) {
        croak "Could not run $sub on $module because $module could not be loaded.";
    }
    else {
        my $command = $module."::".$sub;
        no strict qw(refs);
        my $out = eval { &$command(@{$params}) };
        use strict;
        if ($@) {
            croak "Could not run $sub on $module because $@";
        }
        else {
            return $out;
        }
    }
}

1;

