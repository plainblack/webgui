#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;


my $toVersion = "7.4.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
fixProfileDataWithoutFields($session);
buildNewUserProfileTable($session);

finish($session); # this line required


##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}

#----------------------------------------------------------------------------

sub fixProfileDataWithoutFields {
    my $session     = shift;
    my $db          = $session->db;
    
    use WebGUI::ProfileField;

    print "\tFixing profile data without entries in userProfileField table..." unless $quiet;
    
    for my $fieldName (qw{ firstDayOfWeek language timeZone uiLevel }) {
        next if WebGUI::ProfileField->new($session, $fieldName);
        $db->write(
            q{INSERT INTO userProfileField (fieldName, label, visible, fieldType, protected, editable) 
            VALUES (?,?,0,"ReadOnly",1,0)},
            [$fieldName, $fieldName]
        );
    }

    print "OK!\n" unless $quiet;
}


#----------------------------------------------------------------------------

sub buildNewUserProfileTable {
    my $session     = shift;
    my $db          = $session->db;
    print "\tBuilding new user profile table. This may take a while...\n" unless $quiet; 
    
    use WebGUI::ProfileField;
    use List::Util qw( first );

    print "\t\tCreating structure..." unless $quiet;
    # Create a new temporary table
    $db->write(q{
        CREATE TABLE tmp_userProfileData (
            userId VARCHAR(22) BINARY NOT NULL,
            PRIMARY KEY (userId)
        )
    });

    # Loop through the current fields and add them to the new table
    my @profileFields;
    my $sth = $db->read(q{SELECT fieldName, fieldType FROM userProfileField});
    while (my %fieldData = $sth->hash) {
        push @profileFields, $fieldData{fieldName};
        my $fieldType   = 'WebGUI::Form::'.ucfirst $fieldData{fieldType};
        my $fieldName   = $db->dbh->quote_identifier($fieldData{fieldName});
        eval "use $fieldType;";
        my $dataType = $fieldType->new($session)->get("dbDataType");

        $db->write(
            "ALTER TABLE tmp_userProfileData ADD COLUMN ($fieldName $dataType)"
        );
    }
    print " OK!\n" unless $quiet;

    # Find fields that were not in the userProfileField database.
    print "\t\tLooking for profile fields not defined in User Profiling... \n" unless $quiet;
    my @dataFields  = $db->buildArray("SELECT fieldName FROM userProfileData GROUP BY fieldName");
    for my $dataField (@dataFields) {
        if (!first { $_ eq $dataField } @profileFields) {
            print "\t\t\tCreating invisible, read-only profile field '$dataField'\n" unless $quiet;

            my $fieldType   = 'WebGUI::Form::ReadOnly';
            my $fieldName   = $db->dbh->quote_identifier($dataField);
            eval "use $fieldType;";
            my $dataType = $fieldType->new($session)->get("dbDataType");

            $db->write(
                "ALTER TABLE tmp_userProfileData ADD COLUMN ($fieldName $dataType)"
            );  

            # Create the profile field 
            WebGUI::ProfileField->create($session, $dataField, {
                label       => $dataField,
                fieldType   => "ReadOnly",
                visible     => 0,
                protected   => 1,
            });
        }
    }
    print "\t\t... Done!\n";
   
    print "\t\tMigrating data to temporary table... " unless $quiet;
    # Loop over the old table and put them in the new table
    $sth    = $db->read(q{SELECT userId FROM users});
    while (my $user = $sth->hashRef) {
        # Get all of this user's profile data
        my %profile 
            = $db->buildHash(
                "SELECT fieldName, fieldData FROM userProfileData WHERE userId=?",
                [$user->{userId}]
            );

        # Write to the temp table
        my $sql 
            = q{INSERT INTO tmp_userProfileData } 
            . q{(userId,} . join(",", map { $db->dbh->quote_identifier($_) } keys %profile) . q{)} 
            . q{VALUES (?,} . join(",",("?")x values %profile) . q{)}
            ;
        $db->write($sql, [$user->{userId},values %profile]);
    }
    $sth->finish;
    print "OK!\n" unless $quiet;

    # Delete the old table
    print "\t\tExchanging old data with new... ";
    $db->write("drop table userProfileData");

    # Rename the new table
    $db->write("rename table tmp_userProfileData to userProfileData");
    print "OK!\n" unless $quiet;

    print "\t\t... Done!\n" unless $quiet;
}




# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	updateTemplates($session);
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

#-------------------------------------------------
sub updateTemplates {
	my $session = shift;
	return undef unless (-d "templates-".$toVersion);
        print "\tUpdating templates.\n" unless ($quiet);
	opendir(DIR,"templates-".$toVersion);
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $newFolder = undef;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-".$toVersion."/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.*)$/;
				$properties{id} = $1;
				$first = 0;
			} elsif ($line =~ m/^\#create$/) {
				$create = 1;
			} elsif ($line =~ m/^\#(.*):(.*)$/) {
				$properties{$1} = $2;
			} elsif ($line =~ m/^~~~$/) {
				$head = 1;
			} elsif ($head) {
				$properties{headBlock} .= $line;
			} else {
				$properties{template} .= $line;	
			}
		}
		close(FILE);
		if ($create) {
			$newFolder = createNewTemplatesFolder($importNode) unless (defined $newFolder);
			my $template = $newFolder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub createNewTemplatesFolder {
	my $importNode = shift;
	my $newFolder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => $toVersion." New Templates",
		menuTitle => $toVersion." New Templates",
		url=> $toVersion."_new_templates",
		groupIdView=>"12"
		});
	return $newFolder;
}



