#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# Yeah if you're looking at this code you're probably thinking to
# yourself, "What a #$@*ing mess!" That's what we think too. But
# if you know Perl well enough to know that this sucks, then you
# probably don't need to use this script because you know how to
# install Perl modules and such.

our $webguiRoot;

BEGIN {
        $webguiRoot = $ARGV[0] || "..";
        unshift (@INC, $webguiRoot."/lib");
}

use strict;
use CPAN;

print "\nWebGUI is checking your system environment:\n\n";

my ($os, $prereq, $dbi, $dbDrivers);
$prereq = 1;

if ($^O =~ /Win/i) {
	$os = "Microsoftish";
} else {
	$os = "Linuxish";
}

print "Operating System ......................... ".$os."\n";
print "WebGUI Root .............................. ".$webguiRoot."\n";

###################################
# Checking Perl
###################################

print "Perl Interpreter ......................... ";
if ($] >= 5.006) {
	print "OK\n";
} else {
	print "Please upgrade to 5.6 or later!\n";
	print "Test environment exiting, cannot continue without Perl 5.6.\n";
	exit;
}

print "LWP module ............................... ";
if (eval { require LWP }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
        	print "Attempting to install...\n";
		CPAN::Shell->install("LWP");
	} else {
        	print "Please install.\n";
		$prereq = 0;
	}
}

print "HTTP::Request module ..................... ";
if (eval { require HTTP::Request }) {
        print "OK\n";
} else {
        print "Please install LWP.\n";
	$prereq = 0;
}

print "HTTP::Headers module ..................... ";
if (eval { require HTTP::Headers }) {
        print "OK\n";
} else {
        print "Please install LWP.\n";
	$prereq = 0;
}

print "Digest::MD5 module ....................... ";
if (eval { require Digest::MD5 }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
        	print "Attempting to install...\n";
                CPAN::Shell->install("Digest::MD5");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

my $dbi;

print "DBI module ............................... ";
if (eval { require DBI }) {
	print "OK\n";
	$dbi = 1;
} else {
	if ($< == 0 && $os eq "Linuxish") {
        	print "Attempting to install...\n";
                CPAN::Shell->install("DBI");
		eval {require DBI};
		$dbi = 1;
        } else {
                print "Please install.\n";
		$prereq = 0;
		$dbi = 0;
        }
}

print "Avalable database drivers ................ ";
if ($dbi) {
	print join(", ",DBI->available_drivers);
	$dbDrivers = join(", ",DBI->available_drivers);
} else {
	print "None";
	$prereq = 0;
}
print "\n";

print "HTML::Parser module ...................... ";
if (eval { require HTML::Parser }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
                print "Attempting to install...\n";
                CPAN::Shell->install("HTML::Parser");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Tie::IxHash module ....................... ";
if (eval { require Tie::IxHash }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
        	print "Attempting to install...\n";
                CPAN::Shell->install("Tie::IxHash");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Tie::CPHash module ....................... ";
if (eval { require Tie::CPHash }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
        	print "Attempting to install...\n";
                CPAN::Shell->install("Tie::CPHash");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Net::SMTP module ......................... ";
if (eval { require Net::SMTP }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
                print "Attempting to install...\n";
                CPAN::Shell->install("Net::SMTP");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Net::LDAP module ......................... ";
if (eval { require Net::LDAP }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
                print "Attempting to install...\n";
                CPAN::Shell->install("Net::LDAP");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Date::Calc module ........................ ";
if (eval { require Date::Calc }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
                print "Attempting to install...\n";
                CPAN::Shell->install("Date::Calc");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "HTML::CalendarMonthSimple module ......... ";
if (eval { require HTML::CalendarMonthSimple }) {
        print "OK\n";
} else {
	if ($< == 0 && $os eq "Linuxish") {
                print "Attempting to install...\n";
                CPAN::Shell->install("HTML::CalendarMonthSimple");
        } else {
                print "Please install.\n";
		$prereq = 0;
        }
}

print "Image::Magick module (optional) .......... ";
if (eval { require Image::Magick }) {
        print "OK\n";
} else {
        print "Not installed. Thumbnailing will be disabled.\n";
}

# this is here to insure they installed correctly.

if ($prereq) {
	print "WebGUI modules ........................... ";
	if (eval { require WebGUI } && eval { require WebGUI::SQL }) {
	        print "OK\n";
	} else {
	        print "Not Found. Perhaps you're running this script in the wrong place.\n";
		$prereq = 0;
	}

	print "Data::Config module ...................... ";
	if (eval { require Data::Config }) {
	        print "OK\n";
	} else {
	        print "Not Found. Perhaps you're running this script in the wrong place.\n";
		$prereq = 0;
	}

	print "HTML::TagFilter module ................... ";
	if (eval { require HTML::TagFilter }) {
	        print "OK\n";
	} else {
	        print "Not Found. Perhaps you're running this script in the wrong place.\n";
		$prereq = 0;
	}
} else {
	print "Cannot continue without prerequisites.\n";
	exit;
}

unless ($prereq) {
	print "Cannot continue without WebGUI files.\n";
	exit;
}

my (@files, $file, $dir, $error);
if ($os eq "Windowsish") {
	$dir = $webguiRoot."\\etc\\";
} else {
	$dir = $webguiRoot."/etc/";
}
opendir (DIR,$dir) or $error = "Can't open etc (".$dir.") directory!";
if ($error ne "") {
	print $error."\nCannot continue.\n";
	exit;
} else {
        @files = readdir(DIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.conf$/ && $file ne "some_other_site.conf") {
			
			###################################
			# Checking Config File
			###################################

			print "\nFound config file ........................ ".$file."\n";
			print "Verifying file ........................... ";
			my ($config);
			$config = new Data::Config $dir.$file;
			unless (defined $config) {
				print "Couldn't open it.";
				$prereq = 0;
			} elsif ($config->param('dsn') =~ /\s$/) {
        			print "DSN cannot end with a space.";
				$prereq = 0;
			} elsif ($config->param('dsn') !~ /\DBI\:\w+\:\w+/) {
				print "DSN is improperly formatted.";
				$prereq = 0;
			} elsif ($config->param('dbuser') =~ /\s$/) {
				print "dbuser cannot end with a space.";
				$prereq = 0;
			} elsif ($config->param('dbpass') =~ /\s$/) {
				print "dbpass cannot end with a space.";
				$prereq = 0;
                        } elsif ($config->param('extras') =~ /\s$/) {
                                print "extras cannot end with a space.";
                                $prereq = 0;
                        } elsif ($config->param('uploadsPath') =~ /\s$/) {
                                print "uploadsPath cannot end with a space.";
                                $prereq = 0;
                        } elsif ($config->param('uploadsURL') =~ /\s$/) {
                                print "uploadsURL cannot end with a space.";
                                $prereq = 0;
			} else {
				print "OK\n";
			}

			unless ($prereq) {
        			print " Skipping this configuration.\n";
				$prereq = 1;
			} else {

				###################################
				# Checking uploads folder
				###################################

				print "Uploads folder ........................... ";
                        	if (opendir(DIR,$config->param('uploadsPath'))) {
					print "OK\n";
					closedir(DIR);
				} else {
					print "Appears to be missing!\n";
				}

                                ###################################
                                # Checking for database driver 
                                ###################################

                                print "Database driver .......................... ";
				my (@driver);
				@driver = split(/:/,$config->param('dsn'));
                                if ($dbDrivers =~ m/$driver[1]/) {
                                        print "OK\n";
                                } else {
                                        print "Not installed!\n";
                                }

				###################################
				# Checking database
				###################################

				print "Database connection ...................... ";
				my ($dbh, $test);
				unless (eval {$dbh = DBI->connect($config->param('dsn'),$config->param('dbuser'),$config->param('dbpass'))}) {
					print "Can't connect with info provided!\n";
				} else {
					print "OK\n";
					$dbh->disconnect();
				}
			}

                }
        }
        closedir(DIR);
}


###################################
# Checking Version
###################################

print "\nLatest version ........................... ";
my ($header, $userAgent, $request, $response, $version, $referer);
$userAgent = new LWP::UserAgent;
$userAgent->agent("WebGUI-Check/2.0");
$userAgent->timeout(30);
$header = new HTTP::Headers;
$referer = "http://webgui.cli.getversion/".`hostname`;
chomp $referer;
$header->referer($referer);
$request = new HTTP::Request (GET => "http://www.plainblack.com/downloads/latest-version.txt", $header);
$response = $userAgent->request($request);
$version = $response->content;
chomp $version;
if ($response->is_error) {
	print "Couldn't connect to Plain Black Software. Check your connection and try again.\n";
} elsif ($version eq $WebGUI::VERSION) {
	print $version." OK\n";
} else {
	print "You are using ".$WebGUI::VERSION." and ".$version." is available.\n";
}


print "\nTesting complete!\n\n";



