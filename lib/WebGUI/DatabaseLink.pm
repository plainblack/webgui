package WebGUI::DatabaseLink;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::DatabaseLink

=head1 DESCRIPTION

This package contains utility methods for WebGUI's database link system.

=head1 SYNOPSIS

 use WebGUI::DatabaseLink;
 $hashRef = WebGUI::DatabaseLink::getList();
 %databaseLink = WebGUI::DatabaseLink::get($databaseLinkId);
 
 $dbLink = WebGUI::DatabaseLink->new($databaseLinkId);
 $dbh = $dbLink->dbh;
 $dbLink->disconnect;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------
=head2 getList ( )

Returns a hash reference  containing all database links.  The format is:
	databaseLinkId => title

=cut

sub getList {
	my $list = WebGUI::SQL->buildHashRef("select databaseLinkId, title from databaseLink order by title");
	$list->{'0'} = WebGUI::International::get(1076);
	return $list;
}

#-------------------------------------------------------------------
=head2 get ( databaseLinkId )

Returns a hash containing a single database link.

=head3 databaseLinkId

A valid databaseLinkId

=cut

sub get {
		return WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=".quote($_[0]));
}

#-------------------------------------------------------------------
=head2 disconnect ( )

Disconnect cleanly from the current databaseLink.

=cut

sub disconnect {
	my ($class, $value);
	$class = shift;
	$value = shift;
	if (defined $class->{_dbh}) {
		$class->{_dbh}->disconnect() unless ($class->{_databaseLink}{databaseLinkId} eq "0");
	}
}

#-------------------------------------------------------------------
=head2 dbh ( )

Return a DBI handle for the current databaseLink, connecting if necessary.

=cut

sub dbh {
	my ($class, $value);
	my ($dsn, $username, $identifier);
	$class = shift;
	$value = shift;
	
	if (defined $class->{_dbh}) {
		return $class->{_dbh};
	}

	$dsn = $class->{_databaseLink}{DSN};
	$username = $class->{_databaseLink}{username};
	$identifier = $class->{_databaseLink}{identifier};
	if ($class->{_databaseLinkId} eq "0") {
		$class->{_dbh} = $session{dbh};
		return $session{dbh};
	} elsif ($dsn =~ /\DBI\:\w+\:\w+/i) {
		eval{
			$class->{_dbh} = DBI->connect($dsn,$username,$identifier);
		};
		if ($@) {
			WebGUI::ErrorHandler::warn("DatabaseLink [".$_[0]."] ".$@);
		} else {
			return $class->{_dbh};
		}
	} else {
		WebGUI::ErrorHandler::warn("DatabaseLink [".$_[0]."] The DSN specified is of an improper format.");
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 new ( databaseLinkId )

Constructor.

=head3 databaseLinkId

The databaseLinkId of the databaseLink you're creating an object reference for. 

=cut

sub new {
    my ($class, $databaseLinkId, %databaseLink);
    tie %databaseLink, 'Tie::CPHash';
    $class = shift;
	$databaseLinkId = shift;
	unless ($databaseLinkId eq "") {
		if ($databaseLinkId eq "0") {
			%databaseLink = (
				databaseLinkId=>"0",
				DSN=>$session{config}{dsn},
				username=>$session{config}{dbuser},
				identifier=>$session{config}{dbpass},
				title=>"WebGUI Database"
				);
		} else {
			%databaseLink = WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=".quote($databaseLinkId));
		}
	}
	bless {_databaseLinkId => $databaseLinkId, _databaseLink => \%databaseLink }, $class;
}

1;

