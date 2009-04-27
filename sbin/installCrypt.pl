#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
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
# Do your work here
installCrypt($session);
finish($session);

#----------------------------------------------------------------------------
# Your sub here
my $quiet;
sub installCrypt {
    my $session = shift;
    print "\tAdd cryptEnabled setting... " unless $quiet;
    if (!$session->db->quickScalar('select count(*) from settings where name=?', ['cryptEnabled'])) {
        $session->setting->add('cryptEnabled',0);
    }
    print "DONE!\n" unless $quiet;
    
    # For now, force crypt on since we assume you want to use it
    # -- delete this when this becomes a wg upgrade script --  
    $session->setting->set('cryptEnabled',1);
    
    print "\tAdd Crypt entry to the config file... " unless $quiet;
    # Admin Bar/Console
    my $adminConsole = $session->config->get('adminConsole');
    if (!exists $adminConsole->{'crypt'}) {
        $adminConsole->{'crypt'} = {
            "icon"         => "crypt.png",
            "uiLevel"      => 1,
            "url"          => "^PageUrl(\"\",op=crypt;func=settings);",
            "title"        => "^International(Crypt,Crypt);",
            "groupSetting" => "3",
        };
        $session->config->set('adminConsole', $adminConsole);
    }
    # Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::Crypt',@{ $contentHandlers} ) ) {
        my $contentIndex = 0;
        HANDLER: while ($contentIndex <= $#{ $contentHandlers } ) {
            ##Insert before Operation
            if($contentHandlers->[$contentIndex] eq 'WebGUI::Content::Operation') {
                splice @{ $contentHandlers }, $contentIndex, 0, 'WebGUI::Content::Crypt';
                last HANDLER;
            }
            ++$contentIndex;
        }
        $session->config->set('contentHandlers', $contentHandlers);
    }
#    # Workflow Activities
#    my $workflowActivities = $session->config->get('workflowActivities');
#    my @none = @{ $workflowActivities->{'None'} };
#    if (!isIn('WebGUI::Workflow::Activity::SummarizeCrypt', @none)) {
#        push  @none, 'WebGUI::Workflow::Activity::SummarizeCrypt';
#    }
#    if (!isIn('WebGUI::Workflow::Activity::BucketCrypt', @none)) {
#        push  @none, 'WebGUI::Workflow::Activity::BucketCrypt';
#    }
#    $workflowActivities->{'None'} = [ @none ];
#    $session->config->set('workflowActivities', $workflowActivities);
    print "DONE!\n" unless $quiet;
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

Install the Copy Sender code on a WebGUI site.  If the RFE for this is accepted, then
the subroutines should be moved into an upgrade script.

=head1 SYNOPSIS

 installCopySender --configFile config.conf ...

 installCopySender --help

=head1 DESCRIPTION

This WebGUI utility script helps you install Copy Sender.

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

Copyright 2001-2009 SDH Consulting Pty, Ltd.

=cut

#vim:ft=perl
