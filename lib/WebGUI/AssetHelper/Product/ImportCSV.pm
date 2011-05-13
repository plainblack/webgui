package WebGUI::AssetHelper::Product::ImportCSV;

use Moose;
extends 'WebGUI::AssetHelper';

use PerlIO::eol;
use JSON;
use WebGUI::Exception;
use WebGUI::Fork;
use WebGUI::Text;
use WebGUI::Storage;
use WebGUI::International;

#-------------------------------------------------------------------

=head2 process ( )

Display a dialog to import products

=cut

sub process {
    my ($self) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    return {
        openDialog  => $self->getUrl( 'importProducts' ),
    };
}

#-------------------------------------------------------------------

=head2 importProducts ( )

Import products into the WebGUI system.  If the master sku of a product
exists in the system, it will be updated.  If master skus do not exist,
they will be added.

The first line of the file should contain only the name of the columns,
in any order.  It may not contain comments.

These are the column names, each is required:

=over 4

=item *

mastersku

=item *

varsku

=item *

title

=item *

shortdescription

=item *

price

=item *

weight

=item *

quantity

=back

The following lines will contain product information.  Blank
lines and anything following a '#' sign will be ignored from
the second line of the file, on to the end.

Returns 1 if the import has taken place.  This is to help you know
if old data has been deleted and new has been inserted.

=cut

sub importProducts {
    my ( $process, $args ) = @_;
    $args       ||= {};
    my $session  = $process->session;
    my $parent   = WebGUI::Asset->newById( $session, $args->{assetId} );
    my $filePath = $args->{filePath};
    WebGUI::Error::InvalidParam->throw(error => q{Must provide the path to a file})
        unless $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File could not be found}, brokenFile => $filePath)
        unless -e $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File is not readable}, brokenFile => $filePath)
        unless -r $filePath;
    local $/ = "\x0A"; # Fork alters this!!!
    open my $table, '<:raw:eol(CRLF)', $filePath or
        WebGUI::Error->throw(error => qq{Unable to open $filePath for reading: $!\n});

    # Read in the data
    my $headers;
    $headers = <$table>;
    $session->log->info( "Headers: " . $headers );
    chomp $headers;
    $headers =~ tr/\r//d;
    $headers =~ s/\bsku\b/varSku/;
    my @headers = WebGUI::Text::splitCSV($headers);
    unless ( (join(q{-}, sort @headers) eq 'mastersku-price-quantity-shortdescription-title-varSku-weight')
                and (scalar @headers == 7) ) {
        $session->log->error( "Bad header found in CSV file ($filePath): $headers -- " . join ", ", sort @headers );
        WebGUI::Error::InvalidFile->throw(error => qq{Bad header found in the CSV file}, brokenFile => $filePath);
    }

    my @productData = ();
    my $line = 1;
    while (my $productRow = <$table>) {
        $session->log->info( "Product: " . $productRow );
        chomp $productRow;
        $productRow =~ tr/\r//d;
        $productRow =~ s/\s*#.+$//;
        next unless $productRow;
        local $_;
        my @productRow = WebGUI::Text::splitCSV($productRow);
        WebGUI::Error::InvalidFile->throw(error => qq{Error found in the CSV file}, brokenFile => $filePath, brokenLine => $line)
            unless scalar @productRow == 7;
        push @productData, [ @productRow ];
    }

    if ( @productData == 0 ) {
        $session->log->warn("No products to import");
        $process->update( sub { JSON->new->encode( { message => 'No products' } ) } );
        $process->finish;
        return;
    }

    # Preparing to load product
    my $status = {
        message     => 'Loading product...',
        total       => scalar @productData,
        finished    => 0,
    };
    $process->update( sub { JSON->new->encode( $status ) } );

    ##Okay, if we got this far, then the data looks fine.
    my $fetchProductId = $session->db->prepare('select p.assetId from Product as p join sku as s on p.assetId=s.assetId and p.revisionDate=s.revisionDate where s.sku=? order by p.revisionDate DESC limit 1');
    @headers = map { $_ eq 'shortdescription' ? 'shortdesc' : $_ } @headers;
    my @collateralFields = grep { $_ ne 'title' and $_ ne 'mastersku' } @headers;
    PRODUCT: foreach my $productRow (@productData) {
        my %productRow;
        ##Order the data according to the headers, in whatever order they exist.
        @productRow{ @headers } = @{ $productRow };
        $productRow{price} =~ tr/0-9.//cd;
        ##Isolate just the collateral from the other product information
        my %productCollateral;
        @productCollateral{ @collateralFields } = @productRow{ @collateralFields };

        $fetchProductId->execute([$productRow{mastersku}]);
        my $asset = $fetchProductId->hashRef;

        ##If the assetId exists, we update data for it
        if ($asset->{assetId}) {
            $session->log->warn("Modifying an existing product: $productRow{sku} = $asset->{assetId}\n");
            my $assetId = $asset->{assetId};
            my $product = WebGUI::Asset->newPending($session, $assetId);

            ##Error handling for locked assets
            if ($product->isLocked) {
                $session->log->warn("Product is locked");
                next PRODUCT if $product->isLocked;
            }

            if ($productRow{title} ne $product->getTitle) {
                $product->update({
                    title     => $productRow{title},
                    menuTitle => $productRow{title},
                });
            }
            my $collaterals = $product->getAllCollateral('variantsJSON');
            my $collateralSet = 0;
            ROW: foreach my $collateral (@{ $collaterals }) {
                next ROW unless $collateral->{varSku} eq $productRow{varSku};
                @{ $collateral}{ @collateralFields } = @productCollateral{ @collateralFields };  ##preserve the variant Id field, assign all others
                $product->setCollateral('variantsJSON', 'variantId', $collateral->{variantId}, $collateral);
                $collateralSet=1;
            }
            if (!$collateralSet) {
                ##It must be a new variant
                $product->setCollateral('variantsJSON', 'variantId', 'new', \%productCollateral);
            }
        }
        else {
            ##Insert a new product;
            $session->log->warn("Making a new product: $productRow{sku}\n");
            my $newProduct = $parent->addChild({className => 'WebGUI::Asset::Sku::Product'});
            $newProduct->update({
                title     => $productRow{title},
                menuTitle => $productRow{title},
                url       => $productRow{title},
                sku       => $productRow{mastersku},
            });
            $newProduct->setCollateral('variantsJSON', 'variantId', 'new', \%productCollateral);
            $newProduct->commit;
        }

        # Update our status
        $status->{finished}++;
        $process->update( sub { JSON->new->encode( $status ) } );
    }

    $process->finish;
}

#-----------------------------------------------------------------------------

=head2 www_importProducts (  )

Show the form to upload the CSV file

=cut

sub www_importProducts {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient unless $self->asset->canEdit;
    my $i18n = WebGUI::International->new( $session, 'Asset_Shelf' );

    my $f = $self->getForm( 'importProductsSave' );
    $f->addField( 'file', name => 'importFile' );
    $f->addField( 'submit', name => 'submit', value => $i18n->get('import') );

    return $session->style->process(
        '<h1>' . $i18n->get('import') . '</h1>' . $f->toHtml,
        "PBtmplBlankStyle000001"
    );
}

#-----------------------------------------------------------------------------

=head2 www_importProductsSave ( )

Import the products from the CSV file in a forked process

=cut

sub www_importProductsSave {
    my ( $self ) = @_;
    my $session = $self->session;
    return $session->privilege->insufficient unless $self->asset->canEdit;

    my $storage = WebGUI::Storage->create($session);
    my $productFile = $storage->addFileFromFormPost( 'importFile_file', 1 );

    # Fork the import
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'importProducts',
        { assetId => $self->asset->getId, filePath => $storage->getPath( $productFile ), },
    );

    my $output = '<script type="text/javascript">'
        . sprintf( 'window.parent.admin.processPlugin({ forkId : "%s" });', $fork->getId )
        . 'window.parent.admin.closeModalDialog();'
        . '</script>'
        ;
    return $session->style->process(
        $output,
        "PBtmplBlankStyle000001"
    );
}

1;
