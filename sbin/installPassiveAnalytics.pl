#-------------------------------------------------------------------
# PassiveAnalytics is Copyright 2008-2009 SDH Consulting
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
use WebGUI::PassiveAnalytics::Rule;
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
#installLoggingTables($session);
#installPassiveAnalyticsRule($session);
#installPassiveAnalyticsConfig($session);
installWorkflow($session);
#addAdminGroup($session);

finish($session);

#----------------------------------------------------------------------------
# Your sub here

sub installLoggingTables {
    my $session = shift;
    print "\tInstall logging tables... ";
    my $db = $session->db;
    $db->write(<<EOT1);
DROP TABLE IF EXISTS `passiveLog`
EOT1
$db->write(<<EOT1);
CREATE TABLE `passiveLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `assetId`   varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `sessionId` varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `timeStamp` bigint(20),
    `url`       varchar(255) character set utf8 collate utf8_bin NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT1
    $db->write(<<EOT2);
DROP TABLE IF EXISTS `deltaLog`
EOT2
    $db->write(<<EOT2);
CREATE TABLE `deltaLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `assetId`   varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `delta`     integer,           
    `timeStamp` bigint(20),
    `url`       varchar(255) character set utf8 collate utf8_bin NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT2
    $db->write(<<EOT3);
DROP TABLE IF EXISTS `bucketLog`
EOT3
    $db->write(<<EOT3);
CREATE TABLE `bucketLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `Bucket`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `duration`  integer,           
    `timeStamp` datetime
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT3
    print "DONE!\n";
}

#----------------------------------------------------------------------------
# Add the PassiveAnalytics Rule table
sub installPassiveAnalyticsRule {
    my $session = shift;
    print "\tInstall Passive Analytics rule table, via Crud... ";
    # and here's our code
    WebGUI::PassiveAnalytics::Rule->crud_createTable($session);
    print "DONE!\n";
}

#----------------------------------------------------------------------------
# Add the Passive Analytics config file entry
# for the adminConsole and the content handler
sub installPassiveAnalyticsConfig {
    my $session = shift;
    print "\tAdd Passive Analytics entry to the config file... ";
    # Admin Bar/Console
    my $adminConsole = $session->config->get('adminConsole');
    if (!exists $adminConsole->{'passiveAnalytics'}) {
        $adminConsole->{'passiveAnalytics'} = {
            "icon"         => "statistics.gif",
            "uiLevel"      => 1,
            "url"          => "^PageUrl(\"\",op=passiveAnalytics;func=editRuleflow);",
            "title"        => "^International(Passive Analytics,PassiveAnalytics);",
            "groupSetting" => "3",
        };
        $session->config->set('adminConsole', $adminConsole);
    }
    # Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::PassiveAnalytics',@{ $contentHandlers} ) ) {
        my $contentIndex = 0;
        HANDLER: while ($contentIndex <= $#{ $contentHandlers } ) {
            print $contentHandlers->[$contentIndex]."\n";
            ##Insert before Operation
            if($contentHandlers->[$contentIndex] eq 'WebGUI::Content::Operation') {
                splice @{ $contentHandlers }, $contentIndex, 0, 'WebGUI::Content::PassiveAnalytics';
                last HANDLER;
            }
            ++$contentIndex;
        }
        $session->config->set('contentHandlers', $contentHandlers);
    }
    # Workflow Activities
    my $workflowActivities = $session->config->get('workflowActivities');
    my @none = @{ $workflowActivities->{'None'} };
    if (!isIn('WebGUI::Workflow::Activity::SummarizePassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::SummarizePassiveAnalytics';
    }
    if (!isIn('WebGUI::Workflow::Activity::BucketPassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::BucketPassiveAnalytics';
    }
    $workflowActivities->{'None'} = [ @none ];
    $session->config->set('workflowActivities', $workflowActivities);
    print "DONE!\n";
}

#----------------------------------------------------------------------------
# Add the Passive Analytics Workflow
sub installWorkflow {
    my $session = shift;
    print "\tAdd Passive Analytics Workflow... ";
    my $workflow = WebGUI::Workflow->create(
        $session,
        {
            title   => 'Analyze Passive Analytics',
            mode    => 'singleton',
            type    => 'None',
            description => 'Manual changes to this workflow will be lost.  Please only use the Passive Analytics screen to make changes',
        },
        'PassiveAnalytics000001',
    );
    my $summarize = $workflow->addActivity('WebGUI::Workflow::Activity::SummarizePassiveAnalytics');
    my $bucket    = $workflow->addActivity('WebGUI::Workflow::Activity::BucketPassiveAnalytics');
    $summarize->set('title', 'Perform duration analysis');
    $bucket->set(   'title', 'Please log entries into buckets');
    $workflow->update({enabled => 1});
    print "DONE!\n";
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
