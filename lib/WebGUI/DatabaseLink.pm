package WebGUI::DatabaseLink;

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
use Tie::CPHash;
use WebGUI::SQL;
use WebGUI::International;
use WebGUI::Utility;
use DBI;

=head1 NAME

Package WebGUI::DatabaseLink

=head1 DESCRIPTION

This package contains utility methods for WebGUI's database link system.

=head1 SYNOPSIS

 use WebGUI::DatabaseLink;
 $hashRef = WebGUI::DatabaseLink->getList($session);
 
 $dbLink = WebGUI::DatabaseLink->new($session,$databaseLinkId);
 $dbh = $dbLink->db;
 $dbLink->disconnect;

 $session = $dbLink->session;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 checkPrivileges ( $requestedPrivileges, [$overrideGrants] )

Checks that the database has the requested set of privileges and returns true if it
does.

=head3 requestedPrivileges

An array reference containing the list of privileges to check for this database.

=head3 overrideGrants

An array reference that allows for testing of arbitrary grants.  This argument is
solely for testing, as it bypasses querying the database for grants.

=cut

sub checkPrivileges {
	my $self = shift; 
    my $requestedPrivileges = shift;
    my $overrideGrants = shift;

    ##Get the grants for the database, respecting the override if it has
    ##been passed.
    my @grants;
    if (defined $overrideGrants) {
        @grants = @{ $overrideGrants };
    }
    else {
        @grants = $self->db->buildArray('show grants for current_user');
    }

    ##Parse through the grants, building both the list of grants and the
    ##database which they belong to.
    my @privileges;
	foreach (@grants) {
        ##Checks for grants on all databases '*' or grants on a specific database
		if (m/GRANT ([\w\s\d,]*?) ON ([^.]+)/) {
            my ($privileges, $database) = ($1, $2);
            $database =~ tr/`//d;
            $database =~ s/[%*]/.*/g;
            if ($self->databaseName() =~ /$database/) {
                push(@privileges, (split(/, /,$privileges)));
            }
		}
	}

    # Check if we found any privileges at all
    if (! scalar @privileges) {
        $self->session->errorHandler->warn(
            sprintf( "DatabaseLink: Could not find SQL privileges or no privileges on database '%s' for user '%s' with database link ID '%s' using DSN '%s'",
                $self->databaseName, $self->get->{username},
                $self->getId, $self->get->{DSN},
            )
        );
        return 0;
    }

	# Check if all required privs are present.
	return 1 if (isIn('ALL PRIVILEGES', @privileges));
	
	foreach (@{ $requestedPrivileges }) {
		return 0 unless (isIn(uc($_), @privileges));
	}

    return 1;
}

#-------------------------------------------------------------------

=head2 copy ( )

Returns a new database link id, after copying the properties of this database link to a new entry.

=cut

sub copy {
	my $self = shift; 
	my %params = %{$self->{_databaseLink}};
	$params{databaseLinkId} = "new";
	return $self->session->db->setRow("databaseLink","databaseLinkId",\%params);
}

#-------------------------------------------------------------------

=head2 create ( session, params) 

Constructor. Creates a new database link based upon the passed in params and returns a reference to the database link.

=head3 session

A reference to the current session.

=head3 params

A hash reference containing the list of params to set. See the set() method for details.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $params = shift;
	$params->{databaseLinkId} = "new";
	my $id = $session->db->setRow("databaseLink","databaseLinkId",$params);
	return $class->new($session,$id);
}

#-------------------------------------------------------------------

=head3 delete ( )

Deletes the current database link.

=cut

sub delete {
	my $self = shift;
	$self->session->db->deleteRow("databaseLink","databaseLinkId",$self->getId) unless ($self->getId eq "0");
	$self->disconnect;
}

#-------------------------------------------------------------------

=head3 databaseName ( )

Based on the DSN, figures out what the database name is.

=cut

sub databaseName {
    my $self = shift;
    return $self->{_databaseName} if $self->{_databaseName};
    my @dsnEntries = split(/[:;]/, $self->get->{DSN});

    my $databaseName;
    if ($dsnEntries[2] !~ /=/) {
        $databaseName = $dsnEntries[2];
    }
    else {
        foreach (@dsnEntries) {
            if ($_ =~ m/^(?:database|db|dbname)=(.+)$/) {
                $databaseName = $1;
                last;
            }
        }
    }
    return $databaseName;
}

#-------------------------------------------------------------------

=head2 disconnect ( )

Disconnect cleanly from the current databaseLink. You should always use this method rather than the disconnect method of the actual WebGUI::SQL database handle otherwise you may accidentally close the database handle to the WebGUI database prematurely.

=cut

sub disconnect {
	my ($self, $value);
	$self = shift;
	$value = shift;
	if (defined $self->{_dbh}) {
		$self->{_dbh}->disconnect() unless ($self->getId eq "0");
	}
	undef $self;
}

#-------------------------------------------------------------------

=head2 db ( )

Return a WebGUI::SQL database handle for the current databaseLink, connecting if necessary.

=cut

sub db {
	my $self = shift;
	my $value = shift;
	if (defined $self->{_dbh}) {
		return $self->{_dbh};
	}

	my $dsn        = $self->{_databaseLink}{DSN};
	my $username   = $self->{_databaseLink}{username};
	my $identifier = $self->{_databaseLink}{identifier};
	my $parameters = $self->{_databaseLink}{additionalParameters};

	if ($self->getId eq "0") {
		$self->{_dbh} = $self->session->db;
		return $self->{_dbh};
	}
    else {
        my ($scheme, $driver, $attr_string, $attr_hash, $driver_dsn) = DBI->parse_dsn($dsn);
        if ($driver) {
            my $dbh = WebGUI::SQL->connect($self->session,$dsn,$username,$identifier,$parameters);
            unless (defined $dbh) {
                $self->session->errorHandler->warn("Cannot connect to DatabaseLink [".$self->getId."]");
            }
            $self->{_dbh} = $dbh;
            return $self->{_dbh};
        }
	}
    $self->session->errorHandler->warn("DatabaseLink [".$self->getId."] The DSN specified is of an improper format.");
	return undef;
}

#-------------------------------------------------------------------

=head2 get ( )

Returns the properties of this database link as a hash reference.

=cut

sub get {
	my $self = shift;
	$self->{_databaseLink};
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID of this database link.

=cut

sub getId {
	my $self = shift;
	$self->{_databaseLink}{databaseLinkId};
}


#-------------------------------------------------------------------

=head2 getList ( session )

Class method. Returns a hash reference  containing all database links.  The format is:
	databaseLinkId => title

=head3 session

A reference to the current session.

=cut

sub getList {
	my $class = shift;
	my $session = shift;
	my $list = $session->db->buildHashRef("select databaseLinkId, title from databaseLink where databaseLinkId !=
'0' order by title");
	my $i18n = WebGUI::International->new($session);
	$list->{'0'} = $i18n->get(1076);
	return $list;
}

#-------------------------------------------------------------------

=head2 macroAccessIsAllowed ( )

Returns a boolean indicating if macros are allowed to access this database link.

=cut

sub macroAccessIsAllowed {
    my $self = shift;
    return $self->{_databaseLink}{allowMacroAccess};
}


#-------------------------------------------------------------------

=head2 new ( session, databaseLinkId )

Constructor.

=head3 session

A reference to the current session.

=head3 databaseLinkId

The databaseLinkId of the databaseLink you're creating an object reference for.   databaseLinkId 0
is reserved for the WebGUI database.

=cut

sub new {
	my ($class, $databaseLinkId, %databaseLink);
	tie %databaseLink, 'Tie::CPHash';
	$class = shift;
	my $session = shift;
	$databaseLinkId = shift;
	unless ($databaseLinkId eq "") {
		if ($databaseLinkId eq "0") {
			%databaseLink = (
				databaseLinkId=>"0",
				DSN=>$session->config->get("dsn"),
				username=>$session->config->get("dbuser"),
				identifier=>$session->config->get("dbpass"),
				title=>"WebGUI Database",
				allowedKeywords=>"select\ndescribe\ndesc\nshow\ncall",
                allowMacroAccess=>$session->db->quickScalar("select allowMacroAccess from databaseLink where databaseLinkId='0'"),
                additionalParameters=>'',
				);
		} else {
			%databaseLink = $session->db->quickHash("select * from databaseLink where databaseLinkId=?",[$databaseLinkId]);
		}
	}
	
	unless (defined($databaseLink{databaseLinkId}))
	{
		$session->errorHandler->warn("Could not find database link '".$databaseLinkId."'");
		return undef;
	}
	
	bless {_session=>$session, _databaseLink => \%databaseLink }, $class;
}

#-------------------------------------------------------------------

=head2 queryIsAllowed ( query )

Returns a boolean indicating is the supplied query is allowed for this database link.

=head3 query

The SQL query which is to be investigated.

=cut

sub queryIsAllowed {
	my $self  = shift;
	my $query = shift;

    my ($firstWord) = $query =~ /(\w+)/;
    $firstWord = lc $firstWord;
    return isIn($firstWord, split(/\s+/, lc $self->{_databaseLink}{allowedKeywords})) ? 1 : 0;
}

#-------------------------------------------------------------------

=head2 session

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head3 set ( params ) 

Updates the parameters of this database link.

=head3 params

A hash reference containing the parameters to set.

=head4 DSN

The database service name, which follows the perl DBI DSN structure. DBI:dbtype:dbname;otherparams

=head4 username

THe username to connect to the database with.

=head4 identifier

The password to connect to the database with.

=head4 title

A text label to identify this database to humans in the UI.

=head4 allowedKeywords

A whitespace delimited of keywords that a query may start with.  Checked in
queryIsAllowed.

=head4 allowMacroAccess

A boolean that indicates whether macros are allowed to access this DatabaseLink.

=cut

sub set {
	my $self = shift;
	my $params = shift;
	$params->{databaseLinkId} = $self->getId;
	$self->session->db->setRow("databaseLink","databaseLinkId",$params);
}


1;

