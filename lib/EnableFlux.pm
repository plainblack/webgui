package EnableFlux;

use strict;
use warnings;
use WebGUI::Session;
use Carp;
use List::MoreUtils qw(none insert_after_string);

=head1 EnableFlux

Utility class for flux-enabling a site.

If Flux ever hits the core this will become the upgrade script.

=cut

#----------------------------------------------------------------------------
sub apply {
    my ( $class, $session, $quiet) = @_;

    update_db($session, $quiet);
    update_config($session, $quiet);
}

#----------------------------------------------------------------------------
sub update_db {
    my $session = shift;
    my $quiet = shift;

    # Each command comes in a pair, first reset change (if it has already been applied), second apply change fresh

    print "Updating db for flux.. " unless $quiet;

    $session->db->write("DELETE FROM settings WHERE name = 'fluxEnabled'");
    $session->db->write("INSERT INTO settings VALUES ('fluxEnabled', '0')");

    drop_col( $session, 'assetData', 'fluxEnabled' );
    $session->db->write("ALTER TABLE assetData ADD COLUMN `fluxEnabled` INT(11) NOT NULL default '0'");

    drop_col( $session, 'assetData', 'fluxRuleIdView' );
    $session->db->write(
        "ALTER TABLE assetData ADD COLUMN `fluxRuleIdView` varchar(22) character set utf8 collate utf8_bin NOT NULL default ''"
    );

    drop_col( $session, 'assetData', 'fluxRuleIdEdit' );
    $session->db->write(
        "ALTER TABLE assetData ADD COLUMN `fluxRuleIdEdit` varchar(22) character set utf8 collate utf8_bin NOT NULL default ''"
    );

    $session->db->write("DROP TABLE IF EXISTS `fluxRule`");
    $session->db->write(
        q~
CREATE TABLE `fluxRule` (
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `name` varchar(255) NOT NULL default 'Undefined',
  `sequenceNumber` int(11) NOT NULL default '1',
  `sticky` tinyint(1) NOT NULL default '0',
  `onRuleFirstTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onRuleFirstFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFirstTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFirstFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `combinedExpression` mediumtext default NULL,
  PRIMARY KEY  (`fluxRuleId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
~
    );

    $session->db->write("DROP TABLE IF EXISTS `fluxRuleUserData`");
    $session->db->write(
        q~
CREATE TABLE `fluxRuleUserData` (
  `fluxRuleUserDataId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `dateRuleFirstChecked` datetime default NULL,
  `dateRuleFirstTrue` datetime default NULL,
  `dateRuleFirstFalse` datetime default NULL,
  `dateAccessFirstAttempted` datetime default NULL,
  `dateAccessFirstTrue` datetime default NULL,
  `dateAccessFirstFalse` datetime default NULL,
  `dateAccessMostRecentlyTrue` datetime default NULL,
  `dateAccessMostRecentlyFalse` datetime default NULL,
  PRIMARY KEY  (`fluxRuleUserDataId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
~
    );

    $session->db->write("DROP TABLE IF EXISTS `fluxExpression`");
    $session->db->write(
        q~
CREATE TABLE `fluxExpression` (
  `fluxExpressionId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `name` varchar(255) NOT NULL default 'Undefined',
  `sequenceNumber` int(11) NOT NULL default '1',
  `operand1` varchar(255) NOT NULL,
  `operand1Args` mediumtext default NULL,
  `operand1AssetId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `operand1Modifier` varchar(255) default NULL,
  `operand1ModifierArgs` mediumtext default NULL,
  `operand2` varchar(255) NOT NULL,
  `operand2Args` mediumtext default NULL,
  `operand2AssetId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `operand2Modifier` varchar(255) default NULL,
  `operand2ModifierArgs` mediumtext default NULL,
  `operator` varchar(255) NOT NULL,
  PRIMARY KEY  (`fluxExpressionId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
~
    );
    
    print "DONE.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub update_config {
    my $session = shift;
    my $quiet = shift;
    print "Updating config file for flux.. " unless $quiet;

    # Add Flux to the list of Content Handlers
    my @content_handlers = @{ $session->config->get('contentHandlers') };
    if ( none { $_ eq 'WebGUI::Content::Flux' } @content_handlers ) {
        insert_after_string 'WebGUI::Content::Setup', 'WebGUI::Content::Flux', @content_handlers;
        $session->config->set( 'contentHandlers', \@content_handlers );
    }

    # Add WebGUI::Workflow::Activity::CheckFluxRules to the list of Activities
    # (keep the list sorted, because we're good citizens)
    my @activities_none = @{ $session->config->get('workflowActivities/None') };
    if ( none { $_ eq 'WebGUI::Workflow::Activity::CheckFluxRules' } @activities_none ) {
        push @activities_none, 'WebGUI::Workflow::Activity::CheckFluxRules';
        @activities_none = sort @activities_none;
        $session->config->set( 'workflowActivities/None', \@activities_none );
    }

    # Add Flux to AdminConsole
    $session->config->set(
        'adminConsole/flux',
        {   icon         => "flux.gif",
            uiLevel      => 5,
            url          => "^PageUrl(\"\",flux=admin);",
            title        => "Flux",
            groupSetting => "groupIdAdminFlux"
        }
    );
    
    print "DONE.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub drop_col {
    my ( $session, $table, $col ) = @_;
    my @cols = $session->db->quickArray("show columns from $table where Field = '$col'");
    if (@cols) {
        $session->db->write("ALTER TABLE $table DROP COLUMN $col");
    }
}

1;
