#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

BEGIN {
        unshift (@INC, "./lib/");
}

use strict;

print "\nWebGUI is checking your system environment...\n\n";


###################################
# Checking Perl
###################################

print "Perl Interpreter:\t";
if ($] >= 5.006) {
	print "OK\n";
} else {
	print "Please upgrade to 5.6 or later!\n";
}

print "DBI module:\t\t";
if (eval { require DBI }) {
	print "OK\n";
} else {
	print "Please install.\n";
}

print "LWP module:\t\t";
if (eval { require LWP }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "Tie::IxHash module:\t";
if (eval { require Tie::IxHash }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "Mysql module:\t\t";
if (eval { require Mysql }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "XML::RSS module:\t";
if (eval { require XML::RSS }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "Digest::MD5 module:\t";
if (eval { require Digest::MD5 }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "Net::LDAP module:\t";
if (eval { require Net::LDAP }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

# this is here to insure they installed correctly.
print "WebGUI modules:\t\t";
if (eval { require WebGUI } && eval { require WebGUI::SQL }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

print "Data::Config module:\t";
if (eval { require Data::Config }) {
        print "OK\n";
} else {
        print "Please install.\n";
}

###################################
# Checking Config File
###################################

print "Config file:\t\t";
my ($config);
$config = new Data::Config './etc/WebGUI.conf';
unless (defined $config) {
	print "Couldn't open it.\n";
} elsif ($config->param('dsn') =~ /\s$/) {
        print "DSN cannot end with a space.\n";
} elsif ($config->param('dsn') !~ /\DBI\:\w+\:\w+/) {
	print "DSN is improperly formatted.\n";
} elsif ($config->param('dbuser') =~ /\s$/) {
	print "dbuser cannot end with a space.\n";
} elsif ($config->param('dbuser') =~ /\s$/) {
	print "dbpass cannot end with a space.\n";
} else {
	print "OK\n";
}

###################################
# Checking database
###################################

print "Database connection:\t";
my ($dbh, $test);
$dbh = DBI->connect($config->param('dsn'), $config->param('dbuser'), $config->param('dbpass'));
unless (defined $dbh) {
	print "Can't connect with info provided.\n";
} else {
	print "OK\n";
	print "Database tables:\t";
	($test) = WebGUI::SQL->quickArray("select count(*) from page",$dbh);
	if ($test < 1) {
		print "Looks like you need to create some tables.\n";
	} else {
		print "OK\n";
	}
	$dbh->disconnect();
}

###################################
# Checking Version
###################################

print "Latest version:\t\t";
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Headers;
my ($header, $userAgent, $request, $response, $version, $referer);
$userAgent = new LWP::UserAgent;
$userAgent->agent("WebGUI-Check/1.0");
$header = new HTTP::Headers;
$referer = "http://".`hostname`;
chomp $referer;
$referer .= "/getversion/";
$header->referer($referer);
$request = new HTTP::Request (GET => "http://www.plainblack.com/downloads/latest-version.txt", $header);
$response = $userAgent->request($request);
$version = $response->content;
chomp $version;
if ($version eq  $WebGUI::VERSION) {
	print "OK\n";
} else {
	print "There is a newer version of WebGUI available.\n";
}


print "\nTesting complete!\n";

