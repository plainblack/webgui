package EnableSurvey2;

use strict;
use Readonly;
use WebGUI::Session;
use Carp;
use Tie::IxHash;
use List::MoreUtils qw(none insert_after_string);
use File::Slurp;

#----------------------------------------------------------------------------
sub apply {
    my ( $class, $session, $force ) = @_;

    say("# Running EnableSurvey2..");
    
#    if ($session->db->quickScalar('show tables like "Survey_response"') =~ m/Survey_response/) {
#        say('Survey2 already enabled');
#        return;
#    }
    
    update_db_schema($session);
    add_templates($session);
}

sub say {
    local $\ = "\n";
    print @_ if $ENV{VERBOSE};
}

sub update_db_schema {
    my $session = shift;
    
    say('Updating db schema..');
    foreach my $assetId ($session->db->buildArray('select assetId from Survey')) {
        my $survey = WebGUI::Asset->newByDynamicClass($session, $assetId);
        $survey->purge() if $survey;
    }
    $session->db->write("drop table if exists Survey");
    $session->db->write("drop table if exists Survey_answer");
    $session->db->write("drop table if exists Survey_question");
    $session->db->write("drop table if exists Survey_questionResponse");
    $session->db->write("drop table if exists Survey_response");
    $session->db->write("drop table if exists Survey_section");
    $session->db->write("drop table if exists Survey_tempReport");
    my $sql = read_file('/data/WebGUI/Survey.sql');
    my @statements = grep {/^(DROP|CREATE)/i} split(/;\n/, $sql);
    foreach my $s (@statements) {
         $session->db->write($s);
    }
}

sub add_templates {
    my $session = shift;

    say('Importing templates..');
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set( { name => "Adding Survey2 Packages" } );
    addPackage( $session, '/data/WebGUI/survey_templates.wgpkg' );
    $versionTag->commit;
}

# Add a package to the import node
sub addPackage {
    my $session = shift;
    my $file    = shift;

    # Make a storage location for the package
    my $storage = WebGUI::Storage->createTemp($session);
    $storage->addFileFromFilesystem($file);

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage($storage);

    # Make the package not a package anymore
    $package->update( { isPackage => 0 } );

    # Set the default flag for templates added
    my $assetIds = $package->getLineage( [ 'self', 'descendants' ],
        { includeOnlyClasses => ['WebGUI::Asset::Template'], } );
    for my $assetId ( @{$assetIds} ) {
        my $asset = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        $asset->update( { isDefault => 1 } );
    }

    return;
}

1;
