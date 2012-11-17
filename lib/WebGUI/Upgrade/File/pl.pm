=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

WebGUI::Upgrade::File::pl - Upgrade class for Perl scripts

=cut

package WebGUI::Upgrade::File::pl;
use Moose;
use Class::MOP::Package;
use File::Spec::Functions qw(devnull);
use Scope::Guard;
use namespace::autoclean -also => qr/^_/;

with 'WebGUI::Upgrade::File';

sub run {
    my $self = shift;
    my $configFile = shift;

    local $ENV{WEBGUI_CONFIG}           = $configFile;
    local $ENV{WEBGUI_UPGRADE_VERSION}  = $self->version;
    my $io_guard;
    if ($self->quiet) {
        open my $stdout_old, '>&=', \*STDOUT;
        open \*STDOUT, '>', devnull;
        $io_guard = Scope::Guard->new(sub {
            close STDOUT;
            open STDOUT, '>&=', $stdout_old;
        });
    }
    return _runScript($self->file);
}

sub _runScript {
    my $file = shift;
    my @res;
    my $err;
    {
        local $@;
        local *_;
        # use an anonymous package for this code.  the namespace will
        # automatically be deleted when this goes out of scope.
        my $anon_package = Class::MOP::Package->create_anon;
        my $wanted = wantarray;
        eval sprintf(<<'END_CODE', $anon_package->name);
            package %s;
            # maintain context
            if ($wanted) {
                @res = do $file;
            }
            elsif (defined $wanted) {
                $res[0] = do $file;
            }
            else {
                do $file;
            }
            # save error as soon as possible, before local removes it
            $err = $@;
END_CODE
    }
    die $err
        if $err;
    return (wantarray ? @res : $res[0]);
}

__PACKAGE__->meta->make_immutable;
1;
