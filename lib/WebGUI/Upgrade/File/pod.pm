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

WebGUI::Upgrade::File::pod - Upgrade class for POD documents

=cut

package WebGUI::Upgrade::File::pod;
use Moose;
use POSIX qw(_exit);
with 'WebGUI::Upgrade::File';

sub once { 1 }

sub run {
    my $self = shift;
    my $configFile = shift;
    if ( ! $self->quiet ) {
        my $pid = fork;
        if (! $pid) {
            require Pod::Perldoc;
            @ARGV = ($self->file);
            Pod::Perldoc->run;
            _exit;
        }
        waitpid $pid, 0;
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

