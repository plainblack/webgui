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
use WebGUI::ProfileField;

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

installUserProfileFields($session);
installSettings($session);
upgradeMailQueue($session);

# Do your work here
finish($session);

#----------------------------------------------------------------------------
# Your sub here

sub installUserProfileFields {
    my $session = shift;
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxEmailNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox emails','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 1,
        },
        4,
    );
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxSmsNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox sms','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 0,
        },
        4,
    );
}

sub installSettings {
    my $session = shift;
    $session->setting->add('smsGateway', '');
}

sub upgradeMailQueue {
    my $session = shift;
    $session->db->write('alter table mailQueue add column isInbox TINYINT(4) default 0');
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
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    
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
