package WebGUI::Command;
use strict;
use warnings;
use App::Cmd::Setup -app;

=head1 NAME

WebGUI::Command - Base class for WebGUI commands

=head1 SYNOPSIS

 use WebGUI::Command;

 #subroutines that you'd like to call via command line scripts or UI methods

=head1 DESCRIPTION

This is a subclass of App::Cmd::Setup.

=cut


use constant plugin_search_path => __PACKAGE__;

1;

