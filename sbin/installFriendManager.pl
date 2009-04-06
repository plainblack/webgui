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
    print "Installing FriendManager into settings...";
    $session->setting->add('groupIdAdminFriends',         '3');
    $session->setting->add('fmViewTemplateId', '64tqS80D53Z0JoAs2cX2VQ');
    $session->setting->add('fmEditTemplateId', '64tqS80D53Z0JoAs2cX2VQ');
    $session->setting->add('groupsToManageFriends',       '2');
    print "\tDone";
}

sub installFriendManagerConfig {
    my $session = shift;
    my $config  = $session->config;
    my $account = $config->get('account');
    my @classes = map { $_->{className} } @{ $account };
    return if isIn('WebGUI::Account::FriendManager', @classes);
    print "Installing FriendManager into config file...";
    push @{ $account },
        {
            identifier => 'friendManager',
            title      => '^International(title,Account_FriendManager);',
            className  => 'WebGUI::Account::FriendManager',
        }
    ;
    $config->set('account', $account);
    print "\tDone";
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
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    ##
    
    $session->var->end;
    $session->close;
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    my $packageDir = "packages";
    return undef unless (-d $packageDir);
    print "\tUpdating packages.\n";
    opendir(DIR,$packageDir);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       =  $packageDir . "/" . $file;
        addPackage( $session, $file );
    }
}

sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });
    
    # Set the default flag for templates added
    my $assetIds
        = $package->getLineage( ['self','descendants'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Template' ],
        } );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        $asset->update( { isDefault => 1 } );
    }

    return;
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
