package WebGUI::DatabaseLink;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::DatabaseLink

=head1 DESCRIPTION

This package contains utility methods for WebGUI's database link system.

=head1 SYNOPSIS

 use WebGUI::DatabaseLink;
 %links = WebGUI::DatabaseLink::getHash();
 %databaseLink = WebGUI::DatabaseLink::get($databaseLinkId);
 %using = WebGUI::Databaselink::whatIsUsing($databaseLinkId);

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------
=head2 getHash ( )

Returns a hash containing all database links.  The format is:
	databaseLinkId => title

=cut

sub getHash {
		return WebGUI::SQL->buildHash("select databaseLinkId, title from databaseLink order by title");
}

#-------------------------------------------------------------------
=head2 get ( databaseLinkId )

Returns a hash containing a single database link.

=over

=item databaseLinkId

A valid databaseLinkId

=back

=cut

sub get {
		return WebGUI::SQL->quickHash("select * from databaseLink where databaseLinkId=".$_[0]);
}

#-------------------------------------------------------------------
=head2 whatIsUsing ( databaseLinkId )

Returns an array of hashrefs containing wobjects which use a database link.

=over

=item databaseLinkId

A valid databaseLinkId

=back

=cut

sub whatIsUsing {
	my $sql = 'select wobject.wobjectId, wobject.title, page.menuTitle, page.urlizedTitle from wobject, SQLReport, page '.
		'where SQLReport.databaseLinkId = '.$_[0].' and SQLReport.wobjectId = wobject.wobjectId '.
		'and wobject.pageId = page.pageId';
	my $sth = WebGUI::SQL->read($sql);
	my @using;
	while (my $data = $sth->hashRef()) {
		push @using, $data;
	}
	$sth->finish;
	return @using;
}

1;

