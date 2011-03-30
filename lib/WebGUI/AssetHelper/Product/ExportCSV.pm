package WebGUI::AssetHelper::Product::ExportCSV;

use Moose;
extends 'WebGUI::AssetHelper';

use JSON;
use WebGUI::Asset::Sku::Product;
use WebGUI::Fork;
use WebGUI::Text;
use WebGUI::Asset;
use WebGUI::Storage;

#-------------------------------------------------------------------

=head2 process ( )

Fork the copy operation

=cut

sub process {
    my ($self) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    # Fork the export. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'exportProducts',
    );

    return {
        forkId      => $fork->getId,
    };
}

#-------------------------------------------------------------------

=head2 exportProducts ( )

Export all products from the WebGUI system in a CSV file.  For details
about the file format, see WebGUI::AssetHelper::Product::ImportCSV

Returns a temporary WebGUI::Storage object containing the file.  The
file will be named siteProductData.csv.

=cut

sub exportProducts {
    my ($process, $args) = @_;
    my $session = $process->session;

    # Get all the product IDs
    # Not using getIsa so I can have the number to put into the progress bar
    # This should be perhaps genericized and placed into WebGUI::Asset
    my $tableName   = $session->db->dbh->quote_identifier( WebGUI::Asset::Sku::Product->tableName );
    my $productIds  = $session->db->buildArrayRef(
        "SELECT assetId FROM asset JOIN assetData USING (assetId) JOIN $tableName USING (assetId, revisionDate) WHERE status=? OR status=? HAVING MAX(revisionDate)",
        ['approved','archived'],
    );

    # Preparing to dispense product
    my $status = {
        message     => 'Dispensing product...',
        total       => scalar @{$productIds},
        finished    => 0,
    };
    $process->update( sub { JSON->new->encode( $status ) } );

    # Dispensing product
    my @columns = qw{varSku shortdescription price weight quantity};
    my $productData = WebGUI::Text::joinCSV(qw{mastersku title}, @columns) . "\n";
    @columns = map { $_ eq 'shortdescription' ? 'shortdesc' : $_ } @columns;
    for my $productId ( @$productIds ) {
        my $product   = WebGUI::Asset->newById( $session, $productId );
        my $mastersku = $product->sku;
        my $title     = $product->getTitle;
        my $collateri = $product->getAllCollateral('variantsJSON');
        foreach my $collateral (@{ $collateri }) {
            my @productFields = @{ $collateral }{ @columns };
            $productData .= WebGUI::Text::joinCSV($mastersku, $title, @productFields);
            $productData .= "\n";
        }
        $status->{finished}++;
        $process->update( sub { JSON->new->encode( $status ) } );
    }
    my $storage = WebGUI::Storage->createTemp($session);
    $storage->addFileFromScalar('siteProductData.csv', $productData);

    # Are you still there?
    $status->{redirect} = $storage->getUrl( 'siteProductData.csv' );
    $process->update( sub { JSON->new->encode( $status ) } );
    $session->log->info( "Products exported to " . $status->{redirect} );
}

1;
