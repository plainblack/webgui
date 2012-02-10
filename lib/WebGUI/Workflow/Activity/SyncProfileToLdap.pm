package WebGUI::Workflow::Activity::SyncProfileToLdap;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::LDAPLink;
use WebGUI::User;

=head1 NAME

Package WebGUI::Workflow::Activity::SyncProfileToLdap

=head1 DESCRIPTION

Synchoronizes the data for one user in your LDAP directory with the WebGUI user's profile. This is a one way sync, so data comes from LDAP to WebGUI, not the other way around.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


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
		name=>$i18n->echo("Synchronize Profile To LDAP"),
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
	my $self = shift;
	my $attribute = shift;
	my %alias = (
		firstName=>"cn",
		lastName=>"sn",
		email=>"mail",
		companyName=>"o"
		);
	if (defined $self->session->config->get('ldapAlias')) {
		%alias = %{$self->session->config->get('ldapAlias')};
	}

	return $alias{$attribute} || $attribute;
}

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self       = shift;
	my $userObject = shift; # Set to the current user by the instance
	my $userId   = $userObject->userId;
	my $auth     = WebGUI::Auth->new($self->session, "LDAP",$userId);
	my $userData = $auth->getParams;
    
    #Don't bother with this script if the user is not using the LDAP auth module.
    return $self->COMPLETE if($userObject->authMethod ne "LDAP");
    
    my $ldapLink = WebGUI::LDAPLink->new($self->session,$userData->{ldapConnection});
	# Just complete if can't setup ldapLink for the user
    
    if($ldapLink) {
        my $ldap = $ldapLink->bind();
        if($ldap) {
            my $uri    = $ldapLink->getURI();
            my $search = $ldap->search(
                base   => $uri->dn,
                scope  =>"sub", 
                filter =>$ldapLink->getValue("ldapIdentity").'='.$userObject->username
            );
		    if($search->code) {
		        $self->session->log->warn("Couldn't search LDAP ".$uri->host." to find user ".$userObject->username." (".$userId.").\nError Message from LDAP: ".$ldapStatusCode{$search->code});
			    return $self->COMPLETE;
            }
			elsif ($search->count == 0) {
                $self->session->log->warn("No results returned for user with dn ".$userData->{connectDN});
                return $self->COMPLETE;
            }
            else {
			    my $sth = $self->session->db->read("select fieldName from userProfileField where profileCategoryId<>4");
                while (my ($fieldName) = $sth->array) {
                    if ($search->entry(0)->get_value($self->_alias($fieldName)) ne "") {
                        $userObject->profileField($fieldName,$search->entry(0)->get_value($self->_alias($fieldName)));
                    }
                }
            }
            $ldap->unbind;
        } else {
            $self->session->log->warn("Error connecting to LDAP: ".$ldapLink->getErrorMessage);
            return $self->ERROR;
        }
	}
	return $self->COMPLETE;
}

1;
