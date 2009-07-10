package WebGUI::Workflow::Activity::SyncProfilesToLdap;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use Net::LDAP;
use Time::HiRes;
use WebGUI::Auth;
use WebGUI::User;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Workflow::Activity::SyncProfilesToLdap

=head1 DESCRIPTION

Synchoronizes the data in your LDAP directory with the WebGUI user's profile. This is a one way sync, so data comes from LDAP to WebGUI, not the other way around.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
#Status code messages returned by the server
my %ldapStatusCode = ( 0=>'success (0)', 1=>'Operations Error (1)', 2=>'Protocol Error (2)',
        3=>'Time Limit Exceeded (3)', 4=>'Size Limit Exceeded (4)', 5=>'Compare False (5)',
        6=>'Compare True (6)', 7=>'Auth Method Not Supported (7)', 8=>'Strong Auth Required (8)',
        10=>'Referral (10)', 11=>'Admin Limit Exceeded (11)', 12=>'Unavailable Critical Extension (12)',
        13=>'Confidentiality Required (13)', 14=>'Sasl Bind In Progress (14)',
        15=>'No Such Attribute (16)', 17=>'Undefined Attribute Type (17)',
        18=>'Inappropriate Matching (18)', 19=>'Constraint Violation (19)',
        20=>'Attribute Or Value Exists (20)', 21=>'Invalid Attribute Syntax (21)', 32=>'LDAP Entry Does Not Exist (32)',
        33=>'Alias Problem (33)', 34=>'Invalid DN Syntax (34)', 36=>'Alias Dereferencing Problem (36)',
        48=>'Inappropriate Authentication (48)', 49=>'Invalid Credentials (49)',
        50=>'Insufficient Access Rights (50)', 51=>'Busy (51)', 52=>'Unavailable (52)',
        53=>'Unwilling To Perform (53)', 54=>'Loop Detect (54)', 64=>'Naming Violation (64)',
        65=>'Object Class Violation (65)', 66=>'Not Allowed On Non Leaf (66)', 67=>'Not Allowed On RDN (67)',
        68=>'Entry Already Exists (68)', 69=>'Object Class Mods Prohibited (69)',70=>'The results of the request are to large (70)',
        71=>'Affects Multiple DSAs (71)', 80=>'other (80)',81=>'Net::LDAP cannot establish a connection or the connection has been lost (81)',
		85=>'Net::LDAP timeout while waiting for a response from the server (85)',
		86=>'The method of authentication requested in a bind request is unknown to the server (86)',
		87=>'An error occurred while encoding the given search filter. (87)',
		89=>'An invalid parameter was specified (89)',90=>'Out of Memory (90)',91=>'A connection to the server could not be established (91)',
		92=>'An attempt has been made to use a feature not supported by Net::LDAP (92)',
		93=>'The controls required to perform the requested operation were not found. (93)',
		94=>'No results were returned from the server. (94)', 95=>'There are more results in the chain of results. (95)',
		96=>'A loop has been detected. For example when following referals. (96)', 97=>'The referral hop limit has been exceeded. (97)');

#-------------------------------------------------------------------
sub _alias {
    my $self = shift;
	my $key = shift;
	my $session = $self->session;
	#Pull alias from memory.
	my $alias = $self->{_alias};
	#If alias is not in memory, pull it from the config file and set it.
	unless ($alias) {
	   $alias = $session->config->get("ldapAlias");
	   $self->{_alias} = $alias;
	}
	#Print an error message if no aliases are found
	unless (scalar(keys %{$alias}) > 0) {
	   $session->errorHandler->warn("SynchProfilesToLdap: ldapAlias is not configured properly in your WebGUI config file.  Please check to make sure that this setting is enabled and contains alias mappings");
	}
	#Return the value of the key passed in
	return $alias->{$key} || $key;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "AuthLDAP");
	push(@{$definition}, {
		name=>$i18n->get("sync profiles to ldap"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my $object = shift;
	my $instance = shift;
	my $session = $self->session;
	
	# No Results Codes are returned by the server if a search didn't error, but returned no results. These codes should have a different error message returned.
	my @noResultsCodes = (32,94);		

	my $startTime = time;
	my @fieldNames = $self->session->db->buildArray("SELECT fieldName FROM userProfileField WHERE profileCategoryId <> 4");

	my $index = $instance->getScratch('ldapSelectIndex') || 0;
	my $sth = $self->session->db->read("SELECT u.userId AS userId, a1.fieldData AS ldapConnection FROM users AS u INNER JOIN authentication AS a1 ON u.userId = a1.userId WHERE a1.fieldName = 'ldapConnection' AND u.authMethod = 'LDAP' ORDER BY ldapConnection, userId LIMIT $index,18446744073709551615");
	my ($currentLinkId, $link, $ldapUrl, $ldap);
	my $skippingLink = 0;

    my $ttl = $self->getTTL;
	while (my ($userId, $rowLinkId) = $sth->array) {
		if ($rowLinkId ne $currentLinkId) {
			$link->unbind if defined $link;
			$skippingLink = 0;
#			$self->session->errorHandler->warn("DEBUG: SyncProfilesToLdap: Switching to link $rowLinkId");

			$currentLinkId = $rowLinkId;
			$link = WebGUI::LDAPLink->new($self->session, $rowLinkId);
            next unless $link;
			$ldapUrl = $link->get->{ldapUrl};
			$ldap = $link->bind;

			if (my $error = $link->getErrorMessage) {
				$self->session->errorHandler->error("SyncProfilesToLdap: Couldn't bind to LDAP link $ldapUrl ($currentLinkId), skipping: $error");
				$skippingLink = 1;
				next;
			}
		} elsif ($skippingLink) {
			next;
		}
#		$self->session->errorHandler->warn("DEBUG: SyncProfilesToLdap: Syncing profile for user $userId");

		my $user = WebGUI::User->new($self->session, $userId);
		my $username = $user->username;
		my $auth = WebGUI::Auth->new($self->session, 'LDAP', $userId);
		my $userData = $auth->getParams;
		my $result = $ldap->search(base => $userData->{connectDN},
					   filter => "&(objectClass=*)");

		if ($result->code && !isIn($result->code, @noResultsCodes)) {
			$self->session->errorHandler->error("SyncProfilesToLdap: Couldn't search LDAP link $ldapUrl ($currentLinkId) to find user $username ($userId) with DN ".$userData->{connectDN}.": LDAP returned: ".$ldapStatusCode{$result->code});
		} elsif (isIn($result->code, @noResultsCodes) || $result->count == 0) {
			$self->session->errorHandler->warn("SyncProfilesToLdap: No results returned by LDAP server for user with dn ".$userData->{connectDN});
		} else {
			my $entry = $result->entry(0);
			
			foreach my $fieldName (@fieldNames) {
				my $value = $entry->get_value($self->_alias($fieldName));
				next unless length $value;
#				$self->session->errorHandler->warn("DEBUG: SyncProfilesToLdap: Got data for profile field '$fieldName'");
				$user->profileField($fieldName, $value);
			}
		}
	} continue {
		$index++;

		if (time - $startTime >= $ttl) {
#			$self->session->errorHandler->warn("DEBUG: SyncProfilesToLdap: next round");
			$link->unbind if defined $link;
			$instance->setScratch('ldapSelectIndex', $index);
			$sth->finish;
			return $self->WAITING(1);
		}
	}
	
#	$self->session->errorHandler->warn("DEBUG: SyncProfilesToLdap: done");
	$link->unbind if defined $link;
	$instance->deleteScratch('ldapSelectIndex');
	return $self->COMPLETE;
}

1;
