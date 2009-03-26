#!/usr/bin/env perl

#-------------------------------------------------------------------
# Copyright 2009 SDH Corporation.
#-------------------------------------------------------------------

$|++; # disable output buffering
our ($webguiRoot, $configFile, $help, $man);

BEGIN {
    $webguiRoot = "..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Pod::Usage;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Utility;

# Get parameters here, including $help
GetOptions(
    'configFile=s'  => \$configFile,
    'help'          => \$help,
    'man'           => \$man,
);

pod2usage( verbose => 1 ) if $help;
pod2usage( verbose => 2 ) if $man;
pod2usage( msg => "Must specify a config file!" ) unless $configFile;  

my $session = start( $webguiRoot, $configFile );

installFriendManagerSettings($session);
installFriendManagerConfig($session);

# Do your work here
finish($session);

#----------------------------------------------------------------------------
# Your sub here

sub installFriendManagerSettings {
    my $session = shift;
    $session->setting->add('groupIdAdminFriends', 3);
    $session->setting->add('friendManagerViewTemplate', '');
    $session->setting->add('groupsToManageFriends', '2');
}

sub installFriendManagerConfig {
    my $session = shift;
    my $config  = $session->config;
    my $account = $config->get('account');
    my @classes = map { $_->{className} } @{ $account };
    return if isIn('WebGUI::Account::FriendManager', @classes);
    print "Installing FriendManager\n";
    push @{ $account },
        {
            identifier => 'friendManager',
            title      => '^International(title,Account_FriendManager);',
            className  => 'WebGUI::Account::FriendManager',
        }
    ;
    $config->set('account', $account);
}

#----------------------------------------------------------------------------
sub start {
    my $webguiRoot  = shift;
    my $configFile  = shift;
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->set({name => 'Name Your Tag'});
    #
    ##
    
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->commit;
    ##
    
    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

utility - A template for WebGUI utility scripts

=head1 SYNOPSIS

 utility --configFile config.conf ...

 utility --help

=head1 DESCRIPTION

This WebGUI utility script helps you...

=head1 ARGUMENTS

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2008 Plain Black Corporation.

=cut

#vim:ft=perl
