package WebGUI::Macro::UsersOnline;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------
  Authors of Macro: 
	 Carlos Rivero (http://www.carlosrivero.com),
	 Bernd Kalbfuss-Zimmermann
 -------------------------------------------------------------------

=cut

use strict;
use Net::DNS;
use WebGUI::Asset;
use WebGUI::International;
use WebGUI::Session::DateTime;
use WebGUI::SQL;
use WebGUI::User;

=head1 NAME

Package WebGUI::Macro::UsersOnline;

=head1 DESCRIPTION

Macro for displaying users that are online.

=cut

#-------------------------------------------------------------------

=head2 process ( [templateId], [minutes], [maxMembers], [maxVisitors] )

Returns a fragment of HTML code showing the number of users online. Appearance
can be altered by specifying an alternative template.

=head3 templateId

The ID of the template to be processed. The default is 'h_T2xtOxGRQ9QJOR6ebLpQ'.

=head3 minutes

The number of minutes the last activity may date back for a user to count as 
online.cThe default is 5 minutes.

=head3 maxMembers

The maximum number of members to be returned in the members template loop. The
default is 10.

=head3 maxVisitors

The maximum number of visitors to be returned in the visitors template loop. The
default is 10.

=cut

sub process {

	# Assign parameters
	my $session = shift;
	my $templateId = shift;
	my $minutes = shift;
	my $maxMembers = shift;
	my $maxVisitors = shift;

	# Assign default values
	$templateId ||= "h_T2xtOxGRQ9QJOR6ebLpQ";
	$minutes = 5 unless defined $minutes;
	$maxMembers = 10 unless defined $maxMembers;
	$maxVisitors = 10 unless defined $maxVisitors;


	# Create hash of template variables
	my %var;
	# Obtain internationalization instance
	my $i18n = WebGUI::International->new($session, "Macro_UsersOnline");
	# Get preferred time format of current user
	my $time_format = $session->user->profileField("timeFormat");

	# Calculate epoch time for comparison to last activity
	my $dt = $session->datetime;
	my $epoch = $dt->time();
	$epoch = $session->datetime->addToTime($epoch, 0, -$minutes, 0);
		
	# Let private subroutines do the work
	_visitors($session, \%var, $epoch, $maxVisitors);
	_members($session, \%var, $epoch, $maxMembers);

	# Calculate the total number of active users
	$var{'total'} = $var{'members'} + $var{'visitors'};
	# Set some flags
   	$var{'isVisitor'}  = 1 if ($session->user->isVisitor);
	$var{'hasMembers'} = 1 if $var{'member_loop'};

	# Assign labels
	$var{'usersOnline_label'} = $i18n->get("Users Online");
	$var{'members_label'} = $i18n->get("Members");
	$var{'visitors_label'} = $i18n->get("Visitors");
	$var{'total_label'} = $i18n->get("Total");
	$var{'membersOnline_label'} = $i18n->get("Members Online");
	$var{'visitorsOnline_label'} = $i18n->get("Visitors Online");
	$var{'avatar_label'} = $i18n->get("Avatar");
	$var{'name_label'} = $i18n->get("Name");
	$var{'alias_label'} = $i18n->get("Alias");
	$var{'session_label'} = $i18n->get("Session");
	$var{'ip_label'} = $i18n->get("IP");
	$var{'lastActivity_label'} = $i18n->get("Last Activity");
	
	# Process Template
    my $template = eval { WebGUI::Asset->newById($session,$templateId); };
    if (Exception::Class->caught) {
        #Rethrow with the correct error
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
        );
    }
	return $template->process(\%var);
}

#-------------------------------------------------------------------

=head2 _visitors ( session, varRef, epoch, maxVisitors )

Fills template variables concerning visitors, i.e. the number of visitors and
all variables in the visitors loop. Private subroutine used by process().

=head3 session

A reference to the current session.

=head3 varRef

A reference to the hash of template variables.

=head3 epoch

Epoch time for comparison to last activity.

=head3 maxVisitors

The maximum number of visitors to be returned in the visitors template loop.

=cut

sub _visitors {

	# Assign parameters
	my $session = shift;
	my $var = shift;
	my $epoch = shift;
	my $maxVisitors = shift;

	# Obtain some session-associated objects
	my $db = $session->db();
	my $dt = $session->datetime;
	# Get preferred time format of current user
	my $time_format = $session->user->profileField("timeFormat");

	# SQL conditional clause for filtering server IP
	my $ip_clause;

	# Check whether instance of Apache2::ServerRec is available
	if(my $hostname = $session->request->uri->host) {

		# Look up server IP addresses
		my $res = Net::DNS::Resolver->new();
		my $query = $res->search($hostname);
		if ($query) {
			foreach my $rr ($query->answer) {
				next unless $rr->type eq "A";
				# Generate SQL clause which excludes server IPs
				$ip_clause = $ip_clause . "AND STRCMP(lastIp, '" . $rr->address . "') ";
			}
		}
	}

	# Determine the number of visitors. Server IP adresses and the loopback
	# network are excluded. We only count IPs - not sessions. The reason is
	# that crawlers tend to open multiple sessions(e.g. googlebot) and thereby
 	# increase the count artificially. Note, that the number determined here
	# may deviate from the number of items returned in the visitor loop.
	$var->{'visitors'} = $db->quickScalar("SELECT COUNT(DISTINCT lastIp) FROM " . 
		"userSession WHERE (lastPageView > $epoch) AND (userId = 1) AND " .
		"lastIp NOT LIKE '127.%.%.%'" . $ip_clause);
	  
	# Query session IDs and IPs of visitors
	my $query = $db->prepare("SELECT sessionId, lastIp, lastPageView FROM " .
		"userSession WHERE (lastPageView > $epoch) AND (userId = 1) AND " .
		"lastIp NOT LIKE '127.%.%.%' " . $ip_clause . "LIMIT $maxVisitors");
	$query->execute;

	# Iterate through rows
	while (my %row = $query->hash) {
	    # Add item to visitor template loop
	    push(@{$var->{'visitor_loop'}}, {
			sessionId => $row{'sessionId'},
			ip => $row{'lastIp'},
			lastActivity => $dt->epochToHuman($row{'lastPageView'}, $time_format)
	    });
	}
	return;
}


#-------------------------------------------------------------------

=head2 _members ( session, varRef, epoch, maxMembers )

Fills template variables concerning members, i.e. the number of members and
all variables in the members loop. Private subroutine used by process().

=head3 session

A reference to the current session.

=head3 varRef

A reference to the hash of template variables.

=head3 epoch

Epoch time for comparison to last activity.

=head3 maxMembers

The maximum number of members to be returned in the members template loop.

=cut

sub _members {
	
	# Assign parameters
	my $session = shift;
	my $var = shift;
	my $epoch = shift;
	my $maxMembers = shift;

	# Obtain some session-associated objects
	my $db = $session->db();
	my $dt = $session->datetime;
	# Get preferred time format of current user
	my $time_format = $session->user->profileField("timeFormat");

	# Determine the number of registered users that are online. The Admin 
	# account is excluded from the list.
	$var->{'members'} = $db->quickScalar("SELECT COUNT(DISTINCT userId) FROM " . 
		"userSession where (lastPageView > $epoch) and (userId != '1') and " . 
		"(userId != '3')");

	# Query the names of registered users that are online. The showOnline flag
	# in the user profile is respected.
	my $query = $db->prepare("SELECT userId, sessionId, lastIp, lastPageView " . 
		"FROM userSession WHERE (lastPageView > $epoch) AND (userId != '1') " .
		"AND (userId != '3') LIMIT $maxMembers");
	$query->execute;

	# Iterate through rows
	while (my %row = $query->hash) {
		# Create instance of WebGUI::User for the user id from the current row
		my $user = WebGUI::User->new($session, $row{'userId'});
	    
		# Only show users with the "showOnline" flag set to true
		if ($user->profileField("showOnline")) {
	    	# Find URL of avatar if available
			my $avatar_url;
			my $avatar = $user->profileField("avatar");
			if ($avatar) {
		    		my $storage = WebGUI::Storage->get($session, $avatar);
		    		my @files = @{ $storage->getFiles() };
		    		# We assume it is the first file in the storage. But maybe
					# that is incorrect?
		    		$avatar_url = $storage->getUrl($files[0]);
			}
		
			# Add item to member template loop
			push(@{$var->{'member_loop'}}, {
		    		username => $user->username(),
		    		firstName => $user->profileField("firstName"),
		    		middleName => $user->profileField("middleName"),
		    		lastName => $user->profileField("lastName"),
		    		alias => $user->profileField("alias"),
		    		avatar => $avatar_url,
		    		uid => $row{'userId'},
		    		sessionId => $row{'sessionId'},
		    		ip => $row{'lastIp'},
		    		lastActivity => $dt->epochToHuman($row{'lastPageView'}, $time_format)
			});
		}
	}
	return;
}

1;
