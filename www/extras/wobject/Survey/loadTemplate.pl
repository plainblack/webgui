#!/usr/bin/perl


use strict;

use DBI;
use File::Slurp;
my $dbh = DBI->connect("DBI:mysql:database=www_norman_com;host=localhost;port=3306", "webgui", "webgui", { RaiseError => 1, AutoCommit => 1 }) or die $!;

my $file = read_file("template.html");

my $sth = $dbh->prepare(qq{ UPDATE template SET template = ?,revisionDate = ? WHERE assetid = ? });
$sth->execute($file, time(),"M3RkJY763xgE1SLYQ4pBqA");
$dbh->disconnect();

