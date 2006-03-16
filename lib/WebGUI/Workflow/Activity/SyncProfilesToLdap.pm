package WebGUI::Workflow::Activity::SyncProfilesToLdap;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Auth;
use WebGUI::User;

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

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

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
		92=>'An attempt has been made to use a feature not supported by Net::LDAP (92)');

#-------------------------------------------------------------------
sub _alias {
	my %alias = (
		firstName=>"givenName",
		lastName=>"sn",
		email=>"mail",
		companyName=>"o"
		);
	return $alias{$_[0]} || $_[0];
}

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my ($userId, $u, $userData, $uri, $port, %args, $fieldName, $ldap, $search, $a, $b);
	$a = $self->session->db->read("select userId from users where authMethod='LDAP'");
	while (($userId) = $a->array) {
		$u = WebGUI::User->new($self->session, $userId);
		my $auth = WebGUI::Auth->new($self->session, "LDAP",$userId);
		$userData = $auth->getParams;
		$uri = URI->new($userData->{ldapUrl});
		if ($uri->port < 1) {
			$port = 389;
		} else {
			$port = $uri->port;
		}
		%args = (port => $port);
		$ldap = Net::LDAP->new($uri->host, %args);
		if ($ldap) {
		   my $result = $ldap->bind;
		   if ($result->code == 0) {
			   $search = $ldap->search( base=>$userData->{connectDN}, filter=>"&(objectClass=*)" );
			   if($search->code) {
			      	$self->session->errorHandler->warn("Couldn't search LDAP ".$uri->host." to find user ".$u->username." (".$userId.").\nError Message from LDAP: ".$ldapStatusCode{$search->code});
			   } elsif($search->count == 0) {
			      	$self->session->errorHandler->warn("No results returned for user with dn ".$userData->{connectDN});
			   } else {
			      my $user = WebGUI::User->new($self->session, $userId);
				  $b = $self->session->db->read("select fieldName from userProfileField where profileCategoryId<>4");
				  while (($fieldName) = $b->array) {
				     if ($search->entry(0)->get_value(_alias($fieldName)) ne "") {
					    $user->profileField($fieldName,$search->entry(0)->get_value(_alias($fieldName)));
					 }
				  }
				  $b->finish;
			   }
			   $ldap->unbind;
			} else {
		      $self->session->errorHandler->warn("Couldn't bind to LDAP host ".$uri->host."\nError Message from LDAP: ".$ldapStatusCode{$result->code});
		   }
		} 
	}
	$a->finish;
	return $self->COMPLETE;
}

1;
