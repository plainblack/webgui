package Hourly::SyncProfilesToLDAP;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Net::LDAP;
use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _alias {
	my %alias = (
	firstName=>"givenname",
	lastName=>"sn",
	email=>"mail",
	companyName=>"o"
	);
	return $alias{$_[0]} || $_[0];
}

#-------------------------------------------------------------------
sub process {
	my (@date, $userId, $u, $userData, $uri, $port, %args, $fieldName, $ldap, $search, $a, $b);
	@date = WebGUI::DateTime::localtime(WebGUI::DateTime::time());
	if ($date[3] == $session{config}{SyncProfilesToLDAP_hour}) { 
		$a = WebGUI::SQL->read("select userId from users where authMethod='LDAP'");
		while (($userId) = $a->array) {
			$u = WebGUI::User->new($userId);
			$userData = WebGUI::Authentication::getParams($userId, 'LDAP');
			$uri = URI->new($userData->{ldapUrl});
			if ($uri->port < 1) {
				$port = 389;
			} else {
				$port = $uri->port;
			}
			%args = (port => $port);
			$ldap = Net::LDAP->new($uri->host, %args);
			if ($ldap) {
				$ldap->bind;
				$search = $ldap->search (base => $uri->dn, filter => $userData->{connectDN});
				if (defined $search->entry(0)) {
					$b = WebGUI::SQL->read("select fieldName from userProfileField where profileCategoryId<>4");
					while (($fieldName) = $b->array) {
						if ($search->entry(0)->get_value(_alias($fieldName)) ne "") {
							WebGUI::SQL->write("replace into userProfileData 
								(userId,fieldName,fieldData) values ("
                                                                .$userId.","
                                                                .quote($fieldName).","
                                                                .quote($search->entry(0)->get_value(_alias($fieldName)))
                                                                .")");
						}
					}
					$b->finish;
					$ldap->unbind;
				} else {
					print "Couldn't connect to LDAP host ".$uri->host." to find user ".$u->username." (".$userId.").\n";
				}
			}
		}
		$a->finish;
	}
}

1;

