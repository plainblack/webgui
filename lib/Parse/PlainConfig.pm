# Parse::PlainConfig.pm -- Parser for plain-text configuration files
#
# (c) 2002, Arthur Corliss <corliss@digitalmages.com>,
#
# $Id$
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#####################################################################

=head1 NAME

Parse::PlainConfig - Parser for plain-text configuration files

=head1 MODULE VERSION

$Id$

=head1 SYNOPSIS

  use Parse::PlainConfig;

  $conf = new Parse::PlainConfig;
  $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '.myrc',
    'PURGE' => 1);

  $conf->purge(1);
  $conf->purge;
  $conf->delim('=');

  $rv = $conf->read('myconf.conf');
  $rv = $conf->read;
  $conf->write('.myrc', 2);

  @directives = $conf->directives;
  $conf->set(KEY1 => 'foo', KEY2 => 'bar');
  $conf->describe(KEY1 => '# This is foo', KEY2 => '# This is bar');
  $field = $conf->get('KEY1');
  ($field1, $field2) = $conf->get(qw(KEY1 KEY2));

  @order = $conf->order;
  $conf->order(@new_order);

  $hashref = $conf->get_ref;

=head1 REQUIREMENTS

Nothing outside of the core Perl modules.

=head1 DESCRIPTION

Parse::PerlConfig provides OO objects which can parse and generate
human-readable configuration files.

=cut

#####################################################################
#
# Environment definitions
#
#####################################################################

package Parse::PlainConfig;

use strict;
use vars qw($VERSION);
use Text::ParseWords;
use Carp;
use Fcntl qw(:flock);

($VERSION) = (q$Revision$ =~ /(\d+(?:\.(\d+))+)/);

#####################################################################
#
# Module code follows
#
#####################################################################

=head1 FILE SYNTAX

The plain parser supports the reconstructions of relatively simple data
structures.  Simple scalar assignment and one-dimensional arrays and hashes
are possible.  Below are are various examples of constructs:

  # Scalar assignment
  FIRST_NAME: Joe
  LAST_NAME: Blow

  # Array assignment
  FAVOURITE_COLOURS: red, yellow, green
  ACCOUNT_NUMBERS:  9956-234-9943211, \
                    2343232-421231445, \
                    004422-03430-0343
  
  # Hash assignment
  CARS:  crown_vic => 1982, \
         geo => 1993

As the example above demonstrates, all lines that begin with a '#' (leading
whitespace is allowed) are ignored as comments.  if '#" occurs in any other
position, it is accepted as part of the passed value.  This means that you
B<cannot> place comments on the same lines as values.

The above example also shows that escaping the end of a line (using '\' as the
trailing character) allows you to assign values that may span multiple lines.
Please note, however, that you still cannot do the following:

  # INCORRECT
  FOO: \
       Bar

Every directive/value pair B<must> start with a key and some part of the value 
on the first line of the assignment.

If any directive is present in the file without a corresponding value, it will 
be omitted from the hash.  In other words, if you have something like the
following:

  BLANK_KEY:

it will not be stored in the configuration hash.

All directives and associated values will have both leading and trailing 
whitespace stripped from them before being stored in the configuration hash.  
Whitespace is allowed within both.

B<Note:> If you wish to use a hash or list delimiter ('=>' & ',') as part of a
scalar value, you B<must> enclose that value within quotation marks.  If you
wish to preserve quotation marks as part of a value, you must escape the
quotation characters.

=head1 SECURITY

B<WARNING:> This parser will attempt to open what ever you pass to it for a
filename as is.  If this object is to be used in programs that run with
permissions other than the calling user, make sure you sanitize any
user-supplied filename strings before passing them to this object.

=head1 METHODS

=head2 new

  $conf = new Parse::PlainConfig;
  $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '.myrc',
    'PURGE' => 1);

The object constructor can be called with or without arguments.  The only
recognised arguments are B<DELIM>, which specifies the directive/value 
delimiter to use in the files, B<FILE>, which specifies a file to read, 
B<PURGE>, which sets the mode of the auto-purge feature, and B<FORCE_SCALAR>,
which forces the specified directives to be read and stored as scalars.  The 
B<PURGE> argument will cause the object to automatically read and parse the 
file if possible.

=cut

sub new {
  my $class = shift;
  my $self = {};
  my %init = (@_);

  bless $self, $class;

  $self->{CONF} = {};
  $self->{COMMENTS} = {};
  $self->{ORDER} = [];
  $self->{FILE} = undef;
  $self->{DELIM} = ':';
  $self->{ERROR} = '';
  $self->{PURGE} = 0;
  $self->{FORCE_SCALAR} = [];

  if (scalar keys %init) {
    $self->purge($init{'PURGE'}) if exists $init{'PURGE'};
    $self->delim($init{'DELIM'}) if exists $init{'DELIM'};
    $self->{'FORCE_SCALAR'} = [ @{ $init{'FORCE_SCALAR'} } ] 
      if exists $init{'FORCE_SCALAR'};
    $self->read($init{'FILE'}) if exists $init{'FILE'};
  }

  return $self;
}

=head2 purge

  $conf->purge(1);
  $conf->purge;

This method either (re)sets the auto-purge mode, or performs an immediate manual
purge.  Auto-purge mode clears the configuration hash each time a
configuration file is read, so that the internal configuration data consists
solely of what is in that file.  If you wanted to combine the settings of
multiple files that each may exclusively hold some directives, setting this to
'off' will load the combined configuration as you read each file.

You can still clobber configuration values, of course, if the same directive
is defined in multiple files.  In that case, the last file's value will be the
one stored in the hash.

This is set to 0, or 'off', by default.

=cut

sub purge {
  my $self = shift;
  my $arg = shift;

  if (defined $arg) {
    $self->{PURGE} = $arg;
  } else {
    $self->{CONF} = {};
    $self->{ORDER} = [];
  }
}

=head2 delim

  $conf->delim('=');

This method gets and/or sets the directive/value delimiter to be used in the 
conf files.  The default delimiter is ':'.  This can be multiple characters.

=cut

sub delim {
  my $self = shift;
  my $delim = shift || $self->{DELIM};

  $self->{DELIM} = $delim;
  
  return $delim;
}

=head2 read

  $rv = $conf->read('myconf.conf');
  $rv = $conf->read;

The read method is called initially with a filename as the only argument.
This causes the parser to read the file and extract all of the configuration
directives from it.  The return value will have one of five values, depending
on the success or type of error encountered:

  RV     Meaning
  ==============================================
  -3     filename never defined
  -2     file does not exist
  -1     file is unreadable
   0     some other error occurred while reading
   1     read was successful

You'll notice that you can also call the read method without an argument.
This is only possible after calling the read method with a filename.  The name
of the file read is stored internally, and can be reread should you need to
restore your configuration hash.  If you call the read method without having
defined that filename at least once, you'll get a return value of -3.

=cut

sub read {
  my $self = shift;
  my $file = shift || $self->{FILE};
  my $purge = $self->{PURGE};
  my ($line, @lines);

  $self->{ERROR} = '';

  # $rv is one of the following values:
  #
  #  -3: filename never defined
  #  -2: file does not exist
  #  -1: file is unreadable
  #   0: error occurred while reading file
  #   1: read was successful

  # Early exit if no valid filename was ever given
  unless ($file) {
    $self->{ERROR} = "No filename was defined for reading.";
    return -3;
  }

  # Update the internal filename
  $self->{FILE} = $file;

  # Early exit if there's problems reading the file
  unless (-e $file) {
    $self->{ERROR} = "No file $file was found for reading.";
    return -2;
  }
  unless (-r _) {
    $self->{ERROR} = "No permissions to read file $file.";
    return -1;
  }

  # Attempt to open the file
  if (open(RCFILE, "< $file")) {

    # Read the file
    flock(RCFILE, LOCK_SH);
    while (defined($line = <RCFILE>)) { 
      $line =~ s/\r?\n$//;
      push(@lines, $line);
    }
    flock(RCFILE, LOCK_UN);
    close(RCFILE);

    # Empty the current config hash and key order
    if ($purge) {
      $self->{CONF} = {};
      $self->{ORDER} = [];
    }

    # Parse the rc file's lines
    $self->_parse(@lines);

  # Set the return value to show the read error
  } else {
    $self->{ERROR} = "Error occured while reading $file: $!";
    return 0;
  }

  # Return the result code
  return 1;
}

=head2 write

  $conf->write('.myrc', 2);

This method writes the current configuration stored in memory to the specified
file, either specified as the first argument, or as stored from an explicit or
implicit B<read> call.

The second argument specifies what kind of whitespace padding, if any, to use
with the directive/value delimiter.  The following values are recognised:

  Value    Meaning
  ================================================
  0        No padding (i.e., written as KEY:VALUE)
  1        Left padding (i.e., written as KEY :VALUE)
  2        Right padding (i.e., written as KEY: VALUE)
  3        Full padding (i.e., written as KEY : VALUE)

Both arguments are optional.

=cut

sub write {
  my $self = shift;
  my $file = shift || $self->{FILE};
  my $padding = shift || 0;
  my $conf = $self->{CONF};
  my $comments = $self->{COMMENTS};
  my $order = $self->{ORDER};
  my $d = $self->{DELIM};
  my (%keys, $comment, $value, $out, $k, $v);

  $self->{ERROR} = '';

  # $rv is one of the following values:
  #
  #  -1: filename never defined
  #  0: error occurred while writing file
  #  1: write was successful

  # Early exit if no valid filename was ever given
  unless (defined $file && $file) {
    $self->{ERROR} = "No filename was defined for writing.";
    return -1;
  }

  $self->{FILE} = $file;

  # Pad the delimiter as specified
  if ($padding == 1) {
    $d = " $d" if $padding;
  } elsif ($padding == 2) {
    $d = "$d " if $padding;
  } elsif ($padding == 3) {
    $d = " $d " if $padding;
  }

  # Compose the new output
  foreach (@$order, sort keys %$conf) {

    # Skip if we've already done this key
    next if exists $keys{$_};

    # Track what keys we've done
    ++$keys{$_};

    if (exists $$conf{$_} && defined $$conf{$_}) {

      $comment = exists $$comments{$_} ? $$comments{$_} : '';
      $value = '';

      # Create a series of lines if it's a hash
      if (ref($$conf{$_}) eq "HASH") {
        foreach $k (sort keys %{ $$conf{$_} }) {
          $v = ${ $$conf{$_} }{$k};
          
          # Escape quotes and encapsulate if it has
          # delimiters
          $k =~ s/"/\\"/g;
          $v =~ s/"/\\"/g;
          $v = "\"$v\"" if $v =~ /(?:,|=>)/;

          # Combine the pairs
          $value .= ", \\\n\t" if length($value) > 0;
          $value .= "$k => $v";
        }

      # Or if it's an array
      } elsif (ref($$conf{$_}) eq "ARRAY") {
        foreach $v (@{ $$conf{$_} }) {

          # Escape quotes and encapsulate if it has
          # delimiters
          $v =~ s/"/\\"/g;
          $v = "\"$v\"" if $v =~ /(?:,|=>)/;

          # Combine the items
          $value .= ", \\\n\t" if length($value) > 0;
          $value .= $v;
        }

      # Or just use the scalar
      } else {
        $value = $$conf{$_};
        $value =~ s/"/\\"/g;
        $value = "\"$value\"" if $value =~ /(?:,|=>)/;
      }

      # Append the line(s) to the output
      $out .= "$comment$_$d$value\n";

    }
  }

  # Attempt to open the file
  if (open(RCFILE, "> $file")) {

    # Write the file
    flock(RCFILE, LOCK_EX);
    print RCFILE $out;
    flock(RCFILE, LOCK_UN);
    close(RCFILE);

  # Opening the file failed
  } else {
    $self->{ERROR} = "Error writing file: $!";
    return 0;
  }

  return 1;
}

=head2 directives

  @directives = $conf->directives;

This method returns a list of all the names of the directives currently 
stored in the configuration hash.

=cut

sub directives {
  my $self = shift;

  return keys %{ $self->{CONF} };
}

=head2 set

  $conf->set(KEY1 => 'foo', KEY2 => 'bar');

The set method takes any number of directive/value pairs and copies them into 
the internal configuration hash.

=cut

sub set {
  my $self = shift;
  my $conf = $self->{CONF};
  my %new = (@_);

  foreach (keys %new) { $$conf{$_} = $new{$_} };
}

=head2 describe

  $conf->describe(KEY1 => '# This is foo', KEY2 => '# This is bar');

The describe method takes any number of key/description pairs which will be
used as comments preceding the directives in any newly written conf file.  If
you do not precede each line with comment characters ('#') this method will
insert them for you.  However, it will not split lines longer than the display
into multiple lines.

=cut

sub describe {
  my $self = shift;
  my $comments = $self->{COMMENTS};
  my %new = (@_);
  my @lines;

  foreach (keys %new) { 
    @lines = split(/\n/, $new{$_});
    foreach (@lines) { $_ =~ s/^/# / if $_ !~ /^\s*#/ };
    $new{$_} = join("\n", @lines) . "\n";
    $$comments{$_} = $new{$_};
  }
}

=head2 get

  $field = $conf->get('KEY1');
  ($field1, $field2) = $conf->get(qw(KEY1 KEY2));

The get method takes any number of directives to retrieve, and returns them.  
Please note that both hash and list values are passed by reference.  In order 
to protect the internal state information, the contents of either reference is
merely a copy of what is in the configuration object's hash.  This will B<not>
pass you a reference to data stored internally in the object.  Because of
this, it's perfectly safe for you to shift off values from a list as you
process it, and so on.

=cut

sub get {
  my $self = shift;
  my $conf = $self->{CONF};
  my @fields = @_;
  my @results;

  # Take an early out if no fields were specified
  return undef unless scalar @fields;

  # Loop through each requested field
  foreach (@fields) {

    # Retrieve the value if it exists in the hash
    if (exists $$conf{$_}) {

      # Copy Array and Hash contents, instead of handing
      # a direct reference over to the internal conf hash
      if (ref($$conf{$_}) =~ /^ARRAY/) {
        push(@results, [ @{ $$conf{$_} } ]);
      } elsif (ref($$conf{$_}) =~ /^HASH/) {
        push(@results, { %{ $$conf{$_} } });

      # Else, just copy the value over
      } else {
        push(@results, $$conf{$_});
      }

    # Push an undef onto the array if it's not defined in the hash
    } else {
      push(@results, undef);
    }
  }

  # Return the values
  return (scalar @fields > 1) ? @results : $results[0];
}

=head2 order

  @order = $conf->order;
  $conf->order(@new_order);

This method returns the current order of the configuration directives as read 
from the file.   If called with a list as an argument, it will set the
directive order with that list.  This method is probably of limited use except 
when you wish to control the order in which directives are written in new conf 
files.

Please note that if there are more directives than are present in this list, 
those extra keys will still be included in the new file, but will appear in
alphabetically sorted order at the end, after all of the keys present in the
list.

=cut

sub order {
  my $self = shift;
  my $order = $self->{ORDER};
  my @new = (@_);

  if (scalar @new) {
    @$order = (@new);
  } else {
    return @$order;
  }
}

=head2 get_ref

  $hashref = $conf->get_ref;

This method is made available for convenience, but it's certainly not
recommended that you use it.  If you need to work directly on the
configuration hash, though, this is one way to do it.

=cut

sub get_ref {
  my $self = shift;

  return $self->{CONF};
}

=head2 error

  warn $conf->error;

This method returns a zero-length string if no errors were registered with the
last operation, or a text message describing the error.

=cut

sub error {
  my $self = shift;

  return $self->{ERROR};
}

sub _parse {
  # This takes a list of lines and parses them for config values,
  # which it saves in the object's namespace.
  #
  # Internal use only.

  my $self = shift;
  my $conf = $self->{CONF};
  my $comments = $self->{COMMENTS};
  my $order = $self->{ORDER};
  my $d = $self->{DELIM};
  my @fscalar = @{ $self->{FORCE_SCALAR} };
  my @lines = @_;
  my ($comment, $line, $key, $value, @items, $item, @tmp, %tmp);

  # Clear the order array
  @$order = ();
  
  # Clear the configuration if PURGE is true
  %$conf = () if $self->{PURGE};

  $comment = '';

  while (defined ($line = shift @lines)) {

    # Skip blank or comment lines
    if ($line =~ /^\s*(?:#.*)$/) {
      $comment .= "$line\n";
      next;
    }

    # Make sure we've got a key and value pair
    if ($line =~ /^\s*([\w\-\.\s]+)$d\s*(\S.*)$/) {

      # Save the pair
      ($key, $value) = ($1, $2);

      # Check for line continuation marks
      while ($value =~ /\\$/) {

        # Strip trailing whitespace and contination mark
        $value =~ s/\s*\\$//;

        # Grab the next line
        if (defined ($line = shift @lines)) {

          # Get the next part of the value
          if ($line =~ /^\s*(.*)$/) {
            $value .= $1;

          # or exit, since there was nothing to append
          } else {
            last;
          }

        # Exit, since we've appeared to run out of lines
        } else {
          last;
        }
      }

      # Strip leading and trailing whitespace
      $value =~ s/^\s+//;
      $value =~ s/\s+$//;
      $key =~ s/\s+$//;
  
      # Store the order the keys were extracted
      push(@$order, $key);

      # Store the associate comment and empty the scalar
      $$comments{$key} = $comment if length($comment) > 0;
      $comment = '';

      # Attempt to determine the value type (scalar, array, hash)
      @tmp = ();
      %tmp = ();

      # It's a hash
      if (scalar (quotewords('\s*=>\s*', 0, $value)) > 1 && 
        scalar (grep /^$key$/, @fscalar) == 0) {
  
        # Yes, we are going to attempt to save any list pairs
        # as hash pairs as well, just to be a little forgiving,
        # should someone screw up the syntax.
        @items = quotewords('\s*(?:,|=>)\s*', 0, $value);
  
        $$conf{$key} = { @items };
  
      } else {
  
        @items = quotewords('\s*,\s*', 0, $value);
  
        # It's a list
        if (scalar @items > 1 && scalar (grep /^$key$/, @fscalar) == 0) {
          $$conf{$key} = [ @items ];
  
        # It's a scalar
        } else {
          $$conf{$key} = (scalar @items > 1) ? $value : $items[0];
        }
      }
    } else {
      $comment .= "$line\n";
    }
  }
}

1;

=head1 HISTORY

None worth noting.  ;-)

=head1 AUTHOR/COPYRIGHT

(c) 2002 Arthur Corliss (corliss@digitalmages.com) 

=cut

