#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use File::Basename ();
use File::Spec;

my $webguiRoot;
BEGIN {
    $webguiRoot = File::Spec->rel2abs(File::Spec->catdir(File::Basename::dirname(__FILE__), File::Spec->updir));
    unshift @INC, File::Spec->catdir($webguiRoot, 'lib');
}

use CPAN;
use Getopt::Long;
use Pod::Usage;
use Cwd ();


my ($prereq, $dbi, $dbDrivers, $simpleReport, $help, $noprompt);

GetOptions(
    'noprompt' => \$noprompt,
	'simpleReport'=>\$simpleReport,
	'help'=>\$help,
);

pod2usage( verbose => 2 ) if $help;

print "\nWebGUI is checking your system environment:\n\n";

$prereq = 1;

printTest("Operating System");
printResult(getOs());

printTest("WebGUI Root");
printResult($webguiRoot);


###################################
# Checking Perl
###################################

printTest("Perl Interpreter");
if ($] >= 5.010) {
	printResult("OK");
} else {
	failAndExit("Please upgrade to 5.10 or later! Cannot continue without Perl 5.10 or higher.");
}

##Doing this as a global is not nice, but it works
my $missingModule = 0;

checkModule("Test::Tester",                 "0"          );
checkModule("LWP",                          5.833        );
checkModule("HTML::Form",                   5.800,     2 );
checkModule("Net::DNS",                     0.66,        );
checkModule("Try::Tiny",                    0.07,        );
checkModule("HTTP::Request",                1.40         );
checkModule("HTTP::Headers",                1.61         );
checkModule("Test::More",                   0.96,      2 );
checkModule("Test::MockObject",             1.02,      2 );
checkModule("Test::Deep",                   0.095,       );
checkModule("Test::LongString",             0.13,      2 );
checkModule("Test::Exception",              0.27,      2 );
checkModule("Test::Differences",            0.5,       2 );
checkModule("Test::Class",                  0.31,      2 );
checkModule("Test::MockTime",               0.09,      2 );
checkModule("Test::WWW::Mechanize::PSGI",   0.35,      2 );
checkModule("Pod::Coverage",                0.19,      2 );
checkModule("Text::Balanced",               2.00,      2 );
checkModule("Capture::Tiny",                0.08,      2 );
checkModule("Digest::MD5",                  2.38         );
checkModule("DBI",                          1.607        );
checkModule("DBD::mysql",                   4.010        );
checkModule("HTML::Parser",                 3.60         );
checkModule("Archive::Tar",                 1.44         );
checkModule("Archive::Zip",                 1.26         );
checkModule("IO::Zlib",                     1.09         );
checkModule("Compress::Zlib",               2.015        );
checkModule("Net::SMTP",                    2.31         );
checkModule("MIME::Tools",                  5.427        );
checkModule("Net::POP3",                    2.29         );
checkModule("Tie::IxHash",                  1.21         );
checkModule("XML::Simple",                  2.18         );
checkModule("DateTime",                     0.4501       );
checkModule("Time::HiRes",                  1.9719       );
checkModule("DateTime::Format::Strptime",   1.0800       );
checkModule("DateTime::Format::Mail",       0.3001       );
checkModule("DateTime::Format::HTTP",       0.38         );
checkModule("Image::Magick",                "6.0"        );
checkModule("Log::Log4perl",                1.20         );
checkModule("Net::LDAP",                    0.39         );
checkModule("HTML::Highlight",              0.20         );
checkModule("HTML::TagFilter",              1.03         );
checkModule("HTML::Template",               2.9          );
checkModule("HTML::Template::Expr",         0.07,      2 );
checkModule("Template",                     2.20         );
checkModule("XML::FeedPP",                  0.40         );
checkModule("XML::FeedPP::MediaRSS",        0.02         );
checkModule("JSON",                         2.12         );
checkModule("JSON::Any",                    1.22         );
checkModule("JSON::PP",                     0.00         );
checkModule("Config::JSON",                 "1.3.1"      );
checkModule("Text::CSV_XS",                 "0.64"       );
checkModule("Net::CIDR::Lite",              0.20         );
checkModule("Finance::Quote",               1.15         );
checkModule("POE",                          1.005        );
checkModule("POE::Component::IKC::Server",  0.2001       );
checkModule("POE::Component::Client::HTTP", 0.88         );
checkModule("Plack",                        0.9949       );
checkModule("Plack::Request");
checkModule("Plack::Response");
checkModule("Plack::Middleware::Status");
checkModule("Plack::Middleware::Debug");
checkModule("URI::Escape",                  "3.29"       );
checkModule("POSIX"                                      );
checkModule("List::Util"                                 );
checkModule("Color::Calc"                                );
checkModule("Weather::Com::Finder",         "0.5.3"      );
checkModule("HTML::TagCloud",               "0.34"       );
checkModule("Image::ExifTool",              "7.67"       );
checkModule("Archive::Any",                 "0.0932"     );
checkModule("Path::Class",                  '0.16'       );
checkModule("Exception::Class",             "1.26"       );
checkModule("List::MoreUtils",              "0.22"       );
checkModule("File::Path",                   "2.07"       );
checkModule("Module::Find",                 "0.06"       );
checkModule("Class::C3",                    "0.21"       );
checkModule("Params::Validate",             "0.91"       );
checkModule("Clone",                        "0.31"       );
checkModule('JavaScript::Packer',           '1.002'      );
checkModule('CSS::Packer',                  '1.000'      );
checkModule('HTML::Packer',                 "1.000"      );
checkModule('Business::Tax::VAT::Validation', '0.20'     );
checkModule('Crypt::SSLeay',                '0.57'       );
checkModule('Scope::Guard',                 '0.20'       );
checkModule('Digest::SHA',                  '5.47'       );
checkModule("CSS::Minifier::XS",            "0.03"       );
checkModule("JavaScript::Minifier::XS",     "0.05"       );
checkModule("Readonly",                     "1.03"       );
checkModule("Moose",                        "0.93"       );
checkModule("MooseX::Storage",              "0.23"       );
checkModule("MooseX::NonMoose",             '0.07'       );
checkModule("MooseX::Storage::Format::JSON","0.27"       );
checkModule("namespace::autoclean",         "0.09"       );
checkModule("Business::PayPal::API",        "0.62"       );
checkModule("Business::OnlinePayment",      "3.01"       );
checkModule("Business::OnlinePayment::AuthorizeNet",      "3.22"       );
checkModule("Locales",                      "0.10"       );
checkModule("Test::Harness",                "3.17"       );
checkModule("DateTime::Event::ICal",        "0.10"       );
checkModule("Cache::FastMmap",              "1.35"       );
checkModule("Test::Log::Dispatch",          "0"          );
checkModule("CHI",                          "0.34"       );
checkModule('IO::Socket::SSL',                           );
checkModule('Package::Stash',               "0.33"       );
checkModule('HTTP::Exception',                           );
checkModule('Net::Twitter',                 "3.13006"    );
checkModule('PerlIO::eol',                  "0.14"       );
checkModule('Number::Format',                            );
checkModule('Email::Valid',                              );
checkModule('Facebook::Graph',              '0.0505'     );
checkModule('HTTP::BrowserDetect',          '1.19'       );
checkModule('Search::QueryParser',                       );
checkModule('Monkey::Patch',                '0.03'       );
checkModule('UUID::Tiny',                	'1.03'       );
checkModule('App::Cmd',                     '0.311'      );
checkModule('Devel::StackTrace',            '1.27'       );
checkModule('Devel::StackTrace::WithLexicals',  '0.03'   );
checkModule('Kwargs',                                    );
checkModule('Data::ICal',                   '0.16'       );
checkModule('common::sense',                '3.2'        );
checkModule('Geo::Coder::Googlev3',         '0.07'       );
checkModule('IO::File::WithPath',                        );
checkModule('Plack::Middleware::SizeLimit',              );

failAndExit("Required modules are missing, running no more checks.") if $missingModule;

###################################
# Checking WebGUI
###################################

printTest("WebGUI modules");
if (eval { require WebGUI } && eval { require WebGUI::SQL } && eval { require WebGUI::Config }) {
        printResult("OK");
} else {
        failAndExit("Not Found. Perhaps you're running this script from the wrong place.");
}

###################################
# Checking Version
###################################
my $version = getLatestWebguiVersion();
printTest("Your version");
if ($version eq $WebGUI::VERSION."-".$WebGUI::STATUS) {
	printResult("You are using the latest version - $WebGUI::VERSION-$WebGUI::STATUS");
} else {
	printResult("You are using ".$WebGUI::VERSION."-".$WebGUI::STATUS." and ".$version." is available.");
}

require WebGUI::Paths;
require File::Spec;
printTest("Locating WebGUI configs");
my @configs = WebGUI::Paths->siteConfigs;
printResult("OK");
foreach my $filename (@configs) {
    my $shortName = (File::Spec->splitpath($filename))[2];
	print "\n";	
	###################################
	# Checking Config File
	###################################
	printTest("Checking config file");
	printResult($shortName);
    my $config = WebGUI::Config->new($filename);

	###################################
	# Checking uploads folder
	###################################
	printTest("Verifying uploads folder");
        if (opendir(DIR,$config->get("uploadsPath"))) {
		printResult("OK");
		closedir(DIR);
	} else {
		printResult("Appears to be missing!");
	}
	printTest("Verifying DSN");
	my $dsnok = 0;
	if ($config->get("dsn") !~ /\DBI\:\w+\:\w+/) {
		printResult("DSN is improperly formatted.");
	} else {
		printResult("OK");
		$dsnok = 1;
	}

	###################################
	# Checking database
	###################################
	if ($dsnok) {
		printTest("Verifying database connection");
		my ($dbh, $test);
		unless (eval {$dbh = DBI->connect($config->get("dsn"),$config->get("dbuser"),$config->get("dbpass"))}) {
			printResult("Can't connect with info provided!");
		} else {
			printResult("OK");
			$dbh->disconnect();
		}
	}
}



print "\nTesting complete!\n\n";



#----------------------------------------
sub checkModule {
    my $module = shift;
    my $version = shift || 0;
    my $skipInstall = shift;
    my $afterinstall = shift;	
    unless (defined $afterinstall) { $afterinstall = 0; }
    printTest("Checking for module $module");
    my $statement = "require ".$module.";";

    # we tried installing, now what?
    if ($afterinstall == 1) {
        failAndExit("Install of $module failed!") unless eval($statement);
        # //todo: maybe need to check new install module version 
		printResult("OK");
		return;
    } 

    # let's see if the module is installed
    elsif (eval($statement)) {
		$statement = '$'.$module."::VERSION";
		my $currentVersion = eval($statement);

        # is it the correct version
		if ($currentVersion >= $version) {
			printResult("OK");
	    } 

        # not the correct version, now what?
        else {

            # do nothing we're just reporting the modules.
		    if ($simpleReport) {
                printResult("Outdated - Current: ".$currentVersion." / Required: ".$version);
            }

            # do nothing, this module isn't required 
	        elsif ( $skipInstall == 2 ) {
                printResult("Outdated - Current: ".$currentVersion." / Required: ".$version.", but it's optional anyway");
            } 

            # if we're an admin let's offer to install it
            elsif (isRootRequirementMet()) {
                
                my $installThisModule = defined $noprompt ? "y" : "n";
                if ( $installThisModule eq "n" ) {
                    $installThisModule 
                        = prompt ("$currentVersion is installed, but we need at least "
                        . "$version, do you want to upgrade it now?", "y", "y", "n");
                }

                # does the user wish to install it
                if ($installThisModule eq "y") {
                    installModule($module);
                    checkModule($module,$version,$skipInstall,1);
                } 

                # user doesn't wish to install it
                else {
                    printResult("Upgrade aborted by user input.");
                }
            } 

            # we're not root so lets skip it
            else {
                printResult("Outdated - Current: ".$currentVersion." / Required: ".$version
                    .", but you're not root, so you need to ask your administrator to upgrade it.");
		    }
        }

    # module isn't installed, now what?
    } else {

        # skip optional module
        if ($skipInstall == 2) {
            printResult("Not Installed, but it's optional anyway");
		} 

        # skip  
        elsif ($simpleReport) {
           	printResult("Not Installed");
            $missingModule = 1;
		}

        # if we're root lets try and install it
		elsif (  isRootRequirementMet()) {
            my $installThisModule = defined $noprompt ? "y" : "n";
            if ( $installThisModule eq "n" ) {
                $installThisModule 
                    = prompt ("Not installed, do you want to install it now?", 
                        "y", "y", "n"
                    );
            }

            # user wishes to upgrade
            if ($installThisModule eq "y") {
                installModule($module);
                checkModule($module,$version,$skipInstall,1);
            } 

            # install aborted by user
            else {
                printResult("Install aborted by user input.");
                $missingModule = 1;
            }
		} 

        # can't install, not root        
        else {
			printResult("Not installed, but you're not root, so you need to ask your administrator to install it.");
            $missingModule = 1;
		}
    }
}

#----------------------------------------
sub failAndExit {
        my $exitmessage = shift;
        print $exitmessage."\n\n";
        exit;
}

#----------------------------------------
sub getLatestWebguiVersion {
    printTest("Getting current WebGUI version");
    my $currentversionUserAgent = new LWP::UserAgent;
	$currentversionUserAgent->env_proxy;
	$currentversionUserAgent->agent("WebGUI-Check/2.1");
    $currentversionUserAgent->timeout(30);
    $currentversionUserAgent->env_proxy();
    my $header = new HTTP::Headers;
    my $referer = "http://".`hostname`."/webgui-cli-version";
    chomp $referer;
    $header->referer($referer);
    my $currentversionRequest = new HTTP::Request (GET => "http://update.webgui.org/latest-version.txt", $header);
    my $currentversionResponse = $currentversionUserAgent->request($currentversionRequest);
    my $version = $currentversionResponse->content;
    chomp $version;
    if ($currentversionResponse->is_error || $version eq "") {
        printResult("Failed! Continuing without it.");
    } 
    else {
        printResult("OK");
    }
    return $version;
}

#----------------------------------------
sub getOs {
	if ($^O =~ /MSWin32/i || $^O =~ /^Win/i) {
		return "Windowsish";
	}
	return "Linuxish";
}

#----------------------------------------
sub installModule {
        my $module = shift;
        print "Attempting to install ".$module."...\n";
        my $cwd = Cwd::cwd;
        CPAN::Shell->install($module);
        chdir $cwd;
}

#----------------------------------------
sub isRootRequirementMet {
    if (getOs() eq "Linuxish")	 {
	return ($< == 0);	
    } else {
	return 1;
    }
}

#----------------------------------------
sub printTest {
        my $test = shift;
        print sprintf("%-50s", $test.": ");
}

#----------------------------------------
sub printResult {
        my $result = shift;
        print "$result\n";
}

#----------------------------------------
sub prompt {
        my $question = shift;
        my $default = shift;
        my @answers = @_; # the rest are answers
        print "\n".$question." ";
        print "{".join("|",@answers)."} " if ($#answers > 0);
        print "[".$default."] " if (defined $default);
        my $answer = <STDIN>;
        chomp $answer;
        $answer = $default if ($answer eq "");
        $answer = prompt($question,$default,@answers) if (($#answers > 0 && !($answer ~~ @answers)) || $answer eq "");
        return $answer;
}

__END__

=head1 NAME

testEnvironment - Test Perl environment for proper WebGUI support.

=head1 SYNOPSIS

 testEnvironment --simpleReport

 testEnvironment --help

=head1 DESCRIPTION

This WebGUI utility script tests the current Perl environment to make
sure all of WebGUI's dependencies are satisfied. It also checks for
proper installation of WebGUI's libraries.

If any of the required Perl modules is not available or outdated, the
script will ask if it should attempt installation using CPAN. This will
only be possible if the script is being run as a superuser.

The script will attempt to find out the latest available version from
L<http://update.webgui.org>, and compare with the currently installed one.

=over

=item B<--simpleReport>

Prints the status report to standard output, but does not attempt
to upgrade any outdated or missing Perl modules.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut
