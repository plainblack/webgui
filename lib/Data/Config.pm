package Data::Config;

use strict;
use Carp;
use FileHandle;

use vars qw($CLASS $VERSION);
$CLASS   = 'WebGUI::Config';
$VERSION = '0.8.3';

=head1 NAME

Data::Config - Module that can read easy-to-use configuration files

=head1 SYNOPSIS

Lets say you have a file F<mail.conf>

    name = John Doe
    email = doe@somewhere.net
    server = mail.somewhere.net
    signature = -
    John Doe
    --
    Visit my homepage at http://www.somewhere.net/~doe/
    .

You can read it using the following program:

    use Data::Source;
    my $mailconf = new Data::Source 'mail.conf';

and you can for example print the signature:

    print $mailconf->param('signature');



=head1 DESCRIPTION

This module has been writen in order to provide an easy way to read 
simple configuration files. The format of these configuration files is 
itself extremely easy to understand, so that it can be used even by 
non-tech people (I hope!). 

One of the reason I wrote this module is that I wanted a very easy way 
to feed data to HTML::Template-based scripts. Therefore, the API of 
Data::Config is compatible with HTML::Template, and you can write 
programs as simple as:

    use strict;
    use Data::Config;
    use HTML::template;
    
    my $source = new Data::Config 'file.src';
    my $tmpl = new HTML::Template type => 'filename', 
                source => 'file.tmpl', associate => $source;
    print $tmpl->output;

=head2 Syntax

The syntax of the configuration files is pretty simple. To affect a 
value to a parameter, just write:

    param = value of param

The parameter C<param> will have the value "value of param". 
You can also give multi-lines values this way:

    text = -
    Perl is a language optimized for scanning arbitrary text files, 
    extracting information from those text files, and printing 
    reports based on that information.  It's also a good language 
    for many system management tasks.  The language is intended to 
    be practical (easy to use, efficient, complete) rather than 
    beautiful (tiny, elegant, minimal).
    
    [from perl(1)]
    .

Think of this as a "Unix-inspired" syntax. Instead of giving the value, 
you write '-' to mean "the value will follow" (in Unix, this means the 
data will come from standard input). To end the multi-lines value, you 
simply put a single dot '.' on a line (as in Unix mail, but it needn't 
be on the first column). 

If you need to write several identical records, you can use lists. 
The syntax is:

    list_name {
        # affectations
    }

Example: a version history 

    ## that's the version history of Data::Config :)
    
    history {
        date = 2000.10.10
        vers = 0.7.0
        text = First fully functional release.
    }
    
    history {
        date = 2000.11.04
        vers = 0.7.1
        text = -
        Minor change in the internal structure: options 
        are now grouped.
        .
    }
    
    history {
        date = 2000.11.05
        vers = 0.8.0
        text = -
        Code cleanup (mainly auto-generation of the 
        options accessors). 
        Added list support.
        .
    }

Note that currently, there must be only one item on each line. 
This means you can't write: 

    line { param = value }

but instead

    line {
      param = value
    }

I think that's not a big deal. 

Also note that you can't nest lists. 

You can put some comments in your file. If a line begins with a 
sharp sign '#', it will be ignored. 

=head2 Objects Options

If the default symbols used in the configuration file syntax doesn't 
fit your needs, you can change them using the following methods. 

=over 4

=item affectation_symbol

Use this method to change the affectation symbol. Default is '='.

=item multiline_begin_symbol

Use this method to change the multiline begin symbol. Default is '-'.

=item multiline_end_symbol

Use this method to change the multiline end symbol. Default is '.'.

=item comment_line_symbol

Use this method to change the comment symbol. Default is '#'.

=item list_begin_symbol

Use this method to change the list begin symbol. Default is '{'.

=item list_end_symbol

Use this method to change the list end symbol. Default is '}'.

=item case_sensitive

Use this method to change the case behaviour. Defaults is 1 (case sensitive). 

=back

=head2 Methods

=over 8

=item new

This method creates a new object. You can give an optional parameter, in 
which case the C<read_source()> method is called with that parameter. 

=item read_source ( FILENAME )

=item read_source ( FILEHANDLE )

This method reads the content of the given file and stores the parameters 
values in the object. The argument can be either a filename or a filehandle. 
This is useful if you want to store your parameters in your program:

    use Data::Source;
    my $conf = new Data::Source \*DATA;
    
    $conf->param(-debug => 1);  ## set debug on
    
    if($conf->param('debug')) {
        print "current options:\n";
        print $conf->dump_param(-prefix => '  ');
    }
    
    # ...
    
    __END__
    ## default values
    verbose = 1
    debug = 0
    die_on_errors = 0

Note that you can call the C<read_source()> method several times if you want 
to merge the settings from differents configuration files. 

=item param 

This is the general purpose manipulating method. It can used to get or set 
the value of the parameters of an object. 

1) Return a list of the parameters: 

    @params = $conf->param;

2) Return the value of a parameter:

    print $conf->param('debug');

3) Return the values of a number of parameters:

    @dbg = $conf->param(qw(debug verbose));

4) Set the value of a parameter:

    ## using CGI.pm-like syntax
    $conf->param(-debug => 0);
    
    ## using a hashref
    $conf->param({ debug => 0 });

5) Set the values of a number of parameters
   
    ## using CGI.pm-like syntax
    $conf->param(
        -warn_non_existant => 1, 
        -mangle => 0 
    );
    
    ## using a hashref
    $conf->param(
      { 
        warn_non_existant => 1, 
        mangle => 0 
      }
    );

=item all_parameters

This method returns the list of the parameters of an object.

=item delete ( LIST )

This method deletes the given parameters. 

=item delete_all

This method deletes all the parameters. 

=item clear

This method sets the given parameters to undef. 

=item clear_params

This method sets all the parameters to undef. 

=item dump_param ( OPTIONS )

This method returns a dump of the parameters as a string. It can be used 
to simply print them out, or to save them to a configuration file.

B<Options>

=over 4

=item *

prefix - If you set this option to a string, it will be printed before printing

each parameter. 

=item * 

suffix - If you set this option to a string, it will be printed after printing 
each parameter. 

=back

=back

=head1 VERSION HISTORY

=over 4

=item v0.8.3, Thursday, November 15, 2000

Added the method C<clear()>.

=item v0.8.2, Saturday, November 11, 2000

Added a destructor method. This was needed because of a strange behaviour 
in MacPerl 5.2.0r4. 

=item v0.8.1, Thursday, November 8, 2000

Minor bug corrected: empty or undefined parameters are not added.

Bug corrected: syntaxic symbol are now escaped through quotemeta().

=item v0.8.0, Sunday, November 5, 2000

Code cleanup (mainly auto-generation of the options accessors). 

Added list support.

=item v0.7.1, Saturday, November 4, 2000

Minor change in the internal structure: options are now grouped. 

=item v0.7.0, Tuesday, October 10, 2000

First fully functional release.

=back

=head1 AUTHOR

SE<eacute>bastien Aperghis-Tramoni <madingue@resus.univ-mrs.fr>

=head1 COPYRIGHT

Data::Config is Copyright (C)2000 SE<eacute>bastien Aperghis-Tramoni.

This program is free software. You can redistribute it and/or modify it 
under the terms of either the Perl Artistic License or the GNU General 
Public License, version 2 or later. 

=cut


my @base = (
    options => {
        comment_line_symbol     => '#', 
        affectation_symbol      => '=', 
        multiline_begin_symbol  => '-', 
        multiline_end_symbol    => '.', 
        list_begin_symbol       => '{', 
        list_end_symbol         => '}', 
        case_sensitive          => 1
    }, 
    state => {  }, 
    param => {  }
);

## set the accessors for the object options
for my $option (keys %{$base[1]}) {
    eval qq| sub $option { _get_set_option(shift, '$option', shift) } |;
    warn "[$CLASS] Initialisation error: $@ " if $@;
}


# 
# new()
# ---
sub new {
    my $class = shift;
    my $self = bless { @base }, $class;
    $self->read_source(shift) if @_;
    return $self;
}


# 
# DESTROY()
# -------
sub DESTROY {
    my $self = shift;
    $self->clear_params;
    $self->delete_all;
}


# 
# _get_set_option()
# ---------------
sub _get_set_option {
    my $self   = shift;
    my $option = shift;
    my $value  = shift;
    
    carp "[$CLASS] Uknown option '$option' " unless exists $self->{options}{$option};
    
    if(defined $value) {
        ($value, $self->{options}{$option}) = ($self->{options}{$option}, $value);
        return $value
    } else {
        return $self->{options}{$option}
    }
}


# 
# read_source()
# -----------
sub read_source {
    my $self = shift;
    my $fh   = _file_or_handle(shift);
    my $aff_sym   = $self->affectation_symbol;
    my $multiline = $self->multiline_begin_symbol;
    my $multi_end = $self->multiline_end_symbol;
    my $list      = $self->list_begin_symbol;
    my $list_end  = $self->list_end_symbol;
    local $_;
    
    while(defined($_ = <$fh>)) {
        next if /^\s*$/;  ## skip empty lines
        next if /^\s*#/;  ## skip comments
        chomp;
        
        if(/^\s*(\w+)\s*\Q${list}\E$/) {
            $self->{state}{current_list} = $1;
            $self->{state}{current_stack} = [];
            next 
        }
        
        if(/^\s*\Q${list_end}\E\s*$/) {
            push @{$self->{'param'}{$self->{state}{current_list}}}, { @{$self->{state}{current_stack}} };
            $self->{state}{current_list} = 0;
            $self->{state}{current_stack} = [];
            next 
        }
        
        my($field,$value) = (/^\s*(\w+)\s*\Q${aff_sym}\E\s*(.*)$/);
        
        if($value =~ /^\s*${multiline}\s*$/) {
            $value = '';
            $_ = <$fh>;
            
            while(not /^\s*\Q${multi_end}\E\s*$/) {
                $value .= $_;
                $_ = <$fh>;
            }
        }
        
        $self->param({ $field => $value });
    }
}


# 
# _file_or_handle()
# ---------------
sub _file_or_handle {
    my $file = shift;
    
    if(not ref $file) {
        my $fh = new FileHandle $file;
        croak "[$CLASS] Can't open file '$file': $! " unless defined $fh;
        return $fh
    }
    
    return $file
}


# 
# param()
# -----
sub param {
    my $self = shift;
    return $self->all_parameters unless @_;
    
    my $args = _parse_args(@_);
    
    my @retlist = ();  ## return list
    
    ## get the value of the desired parameters
    for my $arg (@{$args->{'get'}}) {
        #carp("[$CLASS] Parameter '$arg' does not exist ") and 
	next if not exists $self->{'param'}{_case_($self, $arg)};
        
        push @retlist, $self->{'param'}{_case_($self, $arg)}
    }
    
    ## set the names parameters to new values
    my $current_list = $self->{'state'}{current_list};
    my @arg_list = keys %{$args->{'set'}};
    
    if($current_list) {
        unless(exists $self->{'param'}{$current_list}) {
            $self->{'param'}{$current_list} = []
        }
        
        for my $arg (@arg_list) {
            push @{$self->{'state'}{'current_stack'}},  _case_($self, $arg) => $args->{'set'}{$arg}
        }
        
    } else {
        for my $arg (@arg_list) {
            $self->{'param'}{_case_($self, $arg)} = $args->{'set'}{$arg}
        }
    }
    
    return wantarray ? @retlist : $retlist[0]
}


# 
# _case_()
# ------
sub _case_ {
    my $self = shift;
    my $param = shift;
    return ($self->case_sensitive ? $param : lc $param)
}


# 
# _parse_args()
# -----------
sub _parse_args {
    my %args = ( get => [], set => {} );
    
    while(my $arg = shift) {
        if(my $ref_type = ref $arg) {
            
            ## setting multiples parameters using a hashref
            if($ref_type eq 'HASH') {
                local $_;
                for (keys %$arg) {
                    $args{'set'}{$_} = $arg->{$_} if $_
                }
                
            } else {
                carp "[$CLASS] Bad ref $ref_type; ignoring it ";
                next
            }
        
        } else {
           ## setting a parameter to a new value
           if(substr($arg, 0, 1) eq '-') {
               $arg = substr($arg, 1);
               my $val = shift;
               carp("[$CLASS] Undefined value for parameter '$arg' ") and next 
                   if not defined $val;
               $args{'set'}{$arg} = $val if $arg
               
           ## getting the value of a parameter
           } else {
               push @{$args{'get'}}, $arg
           }
        }
    }
    
    return \%args
}


# 
# all_parameters()
# --------------
sub all_parameters {
    my $self = shift;
    return keys %{$self->{'param'}}
}


# 
# delete()
# ------
sub delete {
    my $self = shift;
    
    for my $param (@_) {
        #carp("[$CLASS] Parameter '$param' does not exist ") and 
	next if not exists $self->{'param'}{_case_($self, $param)};
        delete $self->{'param'}{_case_($self, $param)}
    }
}


# 
# delete_all()
# ----------
sub delete_all {
    my $self = shift;
    $self->delete($self->all_parameters)
}


# 
# clear()
# -----
sub clear {
    my $self = shift;
    for my $param (@_) {
        $self->param({$param => ''})
    }
}


# 
# clear_params()
# ------------
sub clear_params {
    my $self = shift;
    for my $param ($self->all_parameters) {
        $self->param({$param => ''})
    }
}


# 
# dump_param()
# ----------
sub dump_param {
    my $self = shift;
    my $args = _parse_args(@_);
    my $prefix = $args->{'set'}{'prefix'} || '';
    my $suffix = $args->{'set'}{'suffix'} || '';
    my $str = '';
    
    for my $param (sort $self->all_parameters) {
        next unless $param;
        ## multi-line value ?
        my $multiline = 1 if $self->param($param) =~ /\n|\r/;
        
        $str .= join '', $prefix, $param, ' ', $self->affectation_symbol, ' ', 
                ($multiline ? $self->multiline_begin_symbol . $/ : ''), 
                $self->param($param), 
                ($multiline ? $self->multiline_end_symbol   . $/ : ''), 
                $suffix, $/;
    }
    
    return $str
}


1;
