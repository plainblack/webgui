#! /usr/bin/perl
use strict;

use lib "/data/WebGUI/lib";

$ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";

use Apache::Registry (); 
use Apache::DBI ();
use CGI (); CGI->compile(':all');
use CGI::Carp ();
use DBI ();
use DBD::mysql ();
use Data::Config ();
use Tie::CPHash ();
use Tie::IxHash ();
use Net::LDAP ();
use Net::SMTP ();
use File::Copy ();
use File::Path ();
use FileHandle ();
use POSIX ();
use WebGUI ();


1;


