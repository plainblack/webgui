
use WebGUI::Upgrade::Script;

use WebGUI::Pluggable;
use WebGUI::ProfileField;

start_step "Move core profile fields to users table...";

my @fields = qw( ableToBeFriend alias allowPrivateMessages avatar cellPhone dateFormat 
    email firstDayOfWeek firstName language lastName publicProfile receiveInboxEmailNotifications 
    receiveInboxSmsNotifications showMessageOnLoginSeen showOnline signature timeFormat timeZone 
    toolbar uiLevel versionTagMode );

# Create the new columns
for my $fieldName ( @fields ) {
    my $field       = WebGUI::ProfileField->new( session, $fieldName );
    my $fieldClass  = $field->getFormControlClass;
    eval { WebGUI::Pluggable::load( $fieldClass ) };
    my $dbType      = $fieldClass->getDatabaseFieldType;
    session->db->write( sprintf q{ ALTER TABLE users ADD COLUMN `%s` %s }, $fieldName, $dbType );
}

# Update the table
my @pairs   = map { q{`users`.`} . $_ . q{`=`userProfileData`.`} . $_ . q{`} } @fields;
session->db->write(
    q{ UPDATE `users`,`userProfileData` SET } . join( ", ", @pairs ) .
    q{ WHERE `users`.`userId` = `userProfileData`.`userId` } 
);

# Drop the old tables
for my $fieldName ( @fields ) {
    session->db->write( qq{ ALTER TABLE userProfileData DROP COLUMN `$fieldName` } );
}

# Move not-profile fields in userProfileData
session->db->write( qq{ ALTER TABLE users ADD privacyFields LONGTEXT } );
session->db->write( qq{ UPDATE users,userProfileData SET users.privacyFields = userProfileData.wg_privacySettings } );
session->db->write( qq{ ALTER TABLE userProfileData DROP COLUMN wg_privacySettings } );

done;
