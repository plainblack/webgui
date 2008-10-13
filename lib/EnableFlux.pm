package EnableFlux;

use strict;
use Readonly;
use WebGUI::Session;
use Carp;
use Tie::IxHash;
use List::MoreUtils qw(none insert_after_string);
my $verbose;

#----------------------------------------------------------------------------
sub apply {
    my ($session, $v) = @_;
    $verbose = $v;
    
    # Ok, let's do it
    modify_db_schema_for_flux($session);
    modify_config_files_for_flux($session);
    create_demo_data($session);
    say("Finished. Don't forget to restart modperl");
}

sub say {
    local $\ = "\n";
    print @_ if $verbose;
}

#----------------------------------------------------------------------------
sub modify_db_schema_for_flux {
    my $session = shift;
    
    # Each command comes in a pair, first reset change (if it has already been applied), second apply change fresh

    say("Modifying db schema..");

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
}

#----------------------------------------------------------------------------
sub modify_config_files_for_flux {
    my $session = shift;
    say("Modifying config files for flux..");
    
    # Add Flux to the list of Content Handlers
    my @content_handlers = @{$session->config->get('contentHandlers') };
    if ( none { $_ eq 'WebGUI::Content::Flux' } @content_handlers ) {
        insert_after_string 'WebGUI::Content::Setup', 'WebGUI::Content::Flux', @content_handlers;
        $session->config->set('contentHandlers', \@content_handlers);
    }

    # Add WebGUI::Workflow::Activity::CheckFluxRules to the list of Activities
    # (keep the list sorted, because we're good citizens)
    my @activities_none = @{$session->config->get('workflowActivities/None') };
    if ( none { $_ eq 'WebGUI::Workflow::Activity::CheckFluxRules' } @activities_none ) {
        push @activities_none, 'WebGUI::Workflow::Activity::CheckFluxRules';
        @activities_none = sort @activities_none;
        $session->config->set('workflowActivities/None', \@activities_none);
    }
}

#----------------------------------------------------------------------------
sub create_demo_data {
    my $session = shift;
    say("Creating demo data..");
    $session->db->write(
        q~
INSERT INTO `fluxRule` (`fluxRuleId`, `name`, `sequenceNumber`, `sticky`, `onRuleFirstTrueWorkflowId`, `onRuleFirstFalseWorkflowId`, `onAccessFirstTrueWorkflowId`, `onAccessFirstFalseWorkflowId`, `onAccessTrueWorkflowId`, `onAccessFalseWorkflowId`, `combinedExpression`) VALUES ('2wKj6EkpLrmU1f6ZVfxzOA','Dependent Rule',2,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('M8EjDc89Q8iqBYb4UTRalA','Simple Rule',1,0,NULL,NULL,NULL,NULL,NULL,NULL,'not e1 or e2'),('Yztbug94AbqQkOKhyOT4NQ','Yet Another Rule',3,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('NgRW4dh2sDSNEwJPGCtWBg','My empty Rule',4,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL),('VVGkA5gBRlNYd6DrFV5anQ','Another Rule',5,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
~
    );
    $session->db->write(
        q~
INSERT INTO `fluxExpression` (`fluxExpressionId`, `fluxRuleId`, `name`, `sequenceNumber`, `operand1`, `operand1Args`, `operand1AssetId`, `operand1Modifier`, `operand1ModifierArgs`, `operand2`, `operand2Args`, `operand2AssetId`, `operand2Modifier`, `operand2ModifierArgs`, `operator`) VALUES ('z3ddMvVUkGx07FeblgFWuw','M8EjDc89Q8iqBYb4UTRalA','Test First Thing',1,'TextValue','{\"value\":  \"test value\"}',NULL,NULL,NULL,'TextValue','{\"value\":  \"test value\"}',NULL,NULL,NULL,'IsEqualTo'),('YiQToMcxB7RUYvmt3CSS-Q','M8EjDc89Q8iqBYb4UTRalA','Test Second Thing',2,'TextValue','{\"value\":  \"boring dry everyday value\"}',NULL,NULL,NULL,'TextValue','{\"value\":  \"super lucky crazy value\"}',NULL,NULL,NULL,'IsEqualTo'),('jNDjhNzuqxinj3r2JG7lXQ','2wKj6EkpLrmU1f6ZVfxzOA','Check Simple Rule',1,'FluxRule','{\"fluxRuleId\":  \"M8EjDc89Q8iqBYb4UTRalA\"}',NULL,NULL,NULL,'TruthValue','{\"value\":  \"1\"}',NULL,NULL,NULL,'IsEqualTo'),('s8wVvTYZyjBt7JqUOs4Urw','2wKj6EkpLrmU1f6ZVfxzOA','Test Something Else',2,'TextValue','{\"value\":  \"test value\"}',NULL,NULL,NULL,'TextValue','{\"value\":  \"test value\"}',NULL,NULL,NULL,'IsEqualTo'),('j9XB0vivxoHYSjuIDIRAEA','Yztbug94AbqQkOKhyOT4NQ','Check Simple Rule',1,'FluxRule','{\"fluxRuleId\":  \"M8EjDc89Q8iqBYb4UTRalA\"}',NULL,NULL,NULL,'TruthValue','{\"value\":  \"1\"}',NULL,NULL,NULL,'IsEqualTo'),('9l9E97tyeuN4HovVDEsKPw','Yztbug94AbqQkOKhyOT4NQ','Check Dependent Rule',2,'FluxRule','{\"fluxRuleId\":  \"2wKj6EkpLrmU1f6ZVfxzOA\"}',NULL,NULL,NULL,'TruthValue','{\"value\":  \"1\"}',NULL,NULL,NULL,'IsEqualTo'),('m5maTmnA55JQW1N-_sOwLg','VVGkA5gBRlNYd6DrFV5anQ','Check the empty Rule',1,'TruthValue','{\"value\":  \"1\"}',NULL,NULL,NULL,'FluxRule','{\"fluxRuleId\":  \"NgRW4dh2sDSNEwJPGCtWBg\"}',NULL,NULL,NULL,'IsEqualTo');
~
    );
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