package WebGUI::ErrorHandler;

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

use FileHandle;
use strict;
use WebGUI::Session;


=head1 NAME 

Package WebGUI::ErrorHandler

=head1 DESCRIPTION

This package provides simple but effective error handling and logging for WebGUI.

=head1 SYNOPSIS

 use WebGUI::ErrorHandler;
 WebGUI::ErrorHandler::audit(message);
 WebGUI::ErrorHandler::fatalError();
 WebGUI::ErrorHandler::security(message);
 WebGUI::ErrorHandler::warn(message);

=head1 METHODS

These functions are available from this package:

=cut



#-------------------------------------------------------------------
sub _log {
        if (my $log = FileHandle->new(">>".$WebGUI::Session::session{config}{logfile})) {
		return $log;
	} else {
		print STDOUT "Can't open log file: ".$WebGUI::Session::session{config}{logfile}." Check your WebGUI configuration file to set the path of the log file, and check to be sure the web server has the privileges to write to the log file.";;
		WebGUI::Session::close();
		exit;
	}
}

#-------------------------------------------------------------------
sub _stamp {
        return localtime(time)." ".$0." ".$_[0].": ";
}


#-------------------------------------------------------------------

=head2 audit ( message )

Inserts an AUDIT type message into the WebGUI log.

=over

=item message

Whatever message you wish to insert into the log.

=back

=cut

sub audit {
        my $data = _stamp("AUDIT").$WebGUI::Session::session{user}{username}
		." (".$WebGUI::Session::session{user}{userId}.") ".$_[0]."\n";
        my $log = _log();
        print $log $data;
        $log->close;
        $WebGUI::Session::session{debug}{audit} .= $data;
}

#-------------------------------------------------------------------

=head2 fatalError ( )

Outputs an error message to the user and logs an error. Should only be called if the system cannot recover from an error, or if it would be unsafe to attempt to recover from an error (like compile errors or database errors).

=cut

sub fatalError {
        my $cgi;
	if (exists $WebGUI::Session::session{cgi}) {
		$cgi = $WebGUI::Session::session{cgi};
	} else {
		use CGI;
		$cgi = CGI->new;
	}
	print $cgi->header;
	my $data = _stamp("FATAL").$_[0]."\n";
	$data .= "\t".join(",",caller(1))."\n";
	$data .= "\t".join(",",caller(2))."\n";
	$data .= "\t".join(",",caller(3))."\n";
	$data .= "\t".join(",",caller(4))."\n";
       	while (my ($section, $hash) = each %WebGUI::Session::session) {
		if (ref $hash eq 'HASH') {
                        while (my ($key, $value) = each %$hash) {
                               if (ref $value eq 'ARRAY') {
                                        $value = '['.join(', ',@$value).']';
                                } elsif (ref $value eq 'HASH') {
                                        $value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
                                }
                                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                                        $data .= "\t".$section.'.'.$key.' = '.$value."\n";
                                }
                        }
                } elsif (ref $hash eq 'ARRAY') {
                        my $i = 1;
                        foreach (@$hash) {
                                $data .= "\t".$section.'.'.$i.' = '.$_."\n";
                                $i++;
                        }
                }
       	}
        unless ($WebGUI::Session::session{setting}{showDebug}) {
                print WebGUI::International::get(416).'<br>';
                print '<br>'.$WebGUI::Session::session{setting}{companyName};
                print '<br>'.$WebGUI::Session::session{setting}{companyEmail};
                print '<br>'.$WebGUI::Session::session{setting}{companyURL};
        } else {
	        print "<h1>WebGUI Fatal Error</h1>Something unexpected happened that caused this system to fault.<p>"; 
		print "<pre>".$data."</pre>";
	}
        my $log = _log();
        print $log $data;
        $log->close();
	WebGUI::Session::close();
        exit;
}

#-------------------------------------------------------------------

=head2 security ( message )

Adds a SECURITY type message to the log.

=over

=item message

The message you wish to add to the log.

=back

=cut

sub security {
        my $data = _stamp("SECURITY").$WebGUI::Session::session{user}{username}
		." (".$WebGUI::Session::session{user}{userId}
		.") connecting from ".$WebGUI::Session::session{env}{REMOTE_ADDR}." attempted to ".$_[0]."\n";
        my $log = _log(); 
        print $log $data;
        $log->close;
        $WebGUI::Session::session{debug}{security} .= $data;
}

#-------------------------------------------------------------------

=head2 warn ( message )

Adds a WARNING type message to the log.

=over

=item message

The message you wish to add to the log.

=back

=cut

sub warn {
        my ($log);
        my $data = _stamp("WARNING").$_[0]."\n";
        $log = _log();
	print $log $data;	
	$log->close;
        $WebGUI::Session::session{debug}{warning} .= $data;
}

1;

