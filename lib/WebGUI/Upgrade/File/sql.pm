=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

WebGUI::Upgrade::File::sql - Upgrade class for SQL scripts

=cut

package WebGUI::Upgrade::File::sql;
use Moose;
with 'WebGUI::Upgrade::File';

sub run {
    my $self = shift;
    my $configFile = shift;

    my @command_line = (
        $self->upgrade->mysql,
        $self->upgrade->mysqlCommandLine($configFile),
        '--batch',
        '--execute=source ' . $self->file,
    );

    system { $command_line[0] } @command_line
        and die "$!";
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;

