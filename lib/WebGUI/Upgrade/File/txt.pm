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

WebGUI::Upgrade::File::txt - Upgrade class for text documents

=cut

package WebGUI::Upgrade::File::txt;
use Moose;
with 'WebGUI::Upgrade::File';

sub once { 1 }

sub run {
    my $self = shift;
    my $configFile = shift;
    if ( ! $self->quiet ) {
        open my $fh, '<', $self->file;
        while ( my $line = <$fh> ) {
            print $line;
        }
        close $fh;
        if (-t) {
            print "\nPress ENTER to continue... ";
            my $nothing = <>;
        }
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

