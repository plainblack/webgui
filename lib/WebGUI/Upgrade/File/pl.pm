package WebGUI::Upgrade::File::pl;
use Moose;
use Class::MOP::Class;
use namespace::autoclean -also => qr/^_/;

with 'WebGUI::Upgrade::File';

sub run {
    my $self = shift;

    local $ENV{WEBGUI_CONFIG}           = $self->configFile;
    local $ENV{WEBGUI_UPGRADE_VERSION}  = $self->version;
    local $ENV{WEBGUI_UPGRADE_QUIET}    = $self->quiet;
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
        my $anon_class = Class::MOP::Class->create_anon_class;
        my $wanted = wantarray;
        eval sprintf(<<'END_CODE', $anon_class->name);
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
