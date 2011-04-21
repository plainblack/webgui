package WebGUI::Command::test_content;

use WebGUI::Command -command;
use strict;
use warnings;
use Try::Tiny;
use File::Spec::Functions qw(catfile);

use WebGUI::Paths;
use WebGUI::Session;
use WebGUI::Macro;

our $LAYOUT_CLASS = 'WebGUI::Asset::Wobject::Layout';
our $FOLDER_CLASS = 'WebGUI::Asset::Wobject::Folder';
our %ASSETS;

sub opt_spec {
    return (
        [ 'F|config:s',     'The config file for the site' ],
        [ 'style:s',        'The URL or ID of a style template to use' ],
        [ 'root=s',         'The URL or ID of the asset to put this content.', { default => "/root" } ],
    );
}

sub run {
    my ( $self, $opt, $args ) = @_;

    if ( !$opt->{style} ) {
        die "style is required\n";
    }

    my $session = WebGUI::Session->open( $opt->{f} );
    $self->{_session} = $session;
    my $root    = $self->getAsset( $opt->{root} );
    my $style   = $self->getAsset( $opt->{style} );

    # Create a single page to hold all the content pages
    my $top = $root->addChild({
            className       => $FOLDER_CLASS,
            title           => 'Test Content',
            styleTemplateId => $style->getId,
        });

    # Create category pages for all asset categories
    my %categories = ();
    for my $cat ( keys %{$session->config->get( 'assetCategories' )} ) {
        my $title   = $session->config->get( "assetCategories/$cat/title" );
        WebGUI::Macro::process( $session, \$title );
        $categories{ $cat } = $top->addChild({
            className       => $FOLDER_CLASS,
            title           => $title,
            styleTemplateId => $style->getId,
        });
    }

    # Add individual asset pages to their category pages
    for my $class ( keys %ASSETS ) {
        my @sets    = @{ $self->getPropertySets( $class ) };

        # Set the default style template
        $sets[0]->{styleTemplateId} ||= $style->getId;

        # Put the first one on the given page
        my $cat     = $session->config->get( "assets/$class/category" );
        my $page    = $categories{ $cat }->addChild({
                className       => $LAYOUT_CLASS,
                styleTemplateId => $style->getId,
            });
        my $asset   = $self->buildAsset( $class, $page, $sets[0] );
        $page->title( $asset->getName );
        $page->menuTitle( $asset->getName );

        # Fix the URLs to take the new titles
        $page->url( '' );
        $page->write;
        $asset->url( '' );
        $asset->write;

        # Make subpages for the other ones
        for my $set ( @sets[1..$#sets] ) {
            my $merged_set = {
                %{ $sets[0] },
                %{ $set },
            };
            my $subpage = $page->addChild({
                className       => $LAYOUT_CLASS,
                title           => $set->{title},
                styleTemplateId => $style->getId,
            });
            $self->buildAsset( $class, $subpage, $merged_set );
        }
    }

    print "Done!\nURL: " . $top->getUrl . "\n";
}

=head2 getAsset ( id )

Get an asset based on the given ID or URL.

=cut

sub getAsset {
    my ( $self, $id ) = @_;
    my $session = $self->{_session};
    my $asset;
    try {
        $asset   = WebGUI::Asset->newByUrl( $session, $id );
    }
    catch {
        try {
            $asset   = WebGUI::Asset->newById( $session, $id );
        }
        catch {
            die "Could not find asset '$id'\n";
        };
    };
    return $asset;
}

=head2 buildAsset( class, page, props )

Build one asset on the page

=cut

sub buildAsset {
    my ( $self, $class, $page, $props ) = @_;
    my $session = $self->{_session};

    my $files       = delete $props->{_files}       || [];
    my $children    = delete $props->{_children}    || [];

    my $asset = $page->addChild({
            className   => $class,
            %$props,
        });

    # Add files to storage locations
    my %storage = ();
    for my $file ( @$files ) {
        my $storage;
        if ( !($storage = $storage{ $file->{property} }) ) {
            $storage = $storage{ $file->{property} } = WebGUI::Storage->create( $session );
            $asset->update({ $file->{property} => $storage->getId });
        }
        $storage->addFileFromFilesystem( $file->{file} );
    }

    # Add children

    return $asset;
}

=head2 getPropertySets( class )

Returns an array of hashref of property sets for the given asset class

This is hardcoded for now, but should eventually become a config file of some kind

=cut


# The first set is the default properties, every other set will combine the
# default properties with the set properties
# A special property _children allows for child assets
# A special property _files allows for files
%ASSETS = (
    'WebGUI::Asset::Wobject::Article' => [
        {
            title       => 'Article with Image',
            templateId  => 'PBtmpl0000000000000103',
            description => lorem(),
            isHidden    => 1,
            displayTitle=> 1,
            linkURL     => 'http://webgui.org',
            linkTitle   => 'WebGUI Content Management System',
            _files      => [
                {
                    property    => 'storageId',
                    file        => catfile( WebGUI::Paths->extras, 'wg.png' ),
                },
            ],
        },
        {
            title       => 'Article with Pagination',
            templateId  => 'XdlKhCDvArs40uqBhvzR3w',
            description => lorem(0,1,2) . '<p>^-;</p>' . lorem(3,4,5),
        },
        {
            title       => 'Item',
            templateId  => 'PBtmpl0000000000000123',
            description => lorem(),

        },
        {
            title       => 'Linked Image with Caption',
            templateId  => 'PBtmpl0000000000000115',
            description => lorem(),
            _files      => [
                {
                    property    => 'storageId',
                    file        => catfile( WebGUI::Paths->extras, 'wg.png' ),
                },
            ],
        },
    ],
);

sub getPropertySets {
    my ( $self, $class ) = @_;
    return $ASSETS{ $class };
}

=head2 lorem ( indexes )

Return generated lorem ipsum text. C<indexes> is an array of paragraph indexes
to pull from __DATA__

=cut

our @LOREM;
sub lorem {
    my ( $self, @indexes ) = @_;
    return join "", map { "<p>$_</p>" } split "\n\n", lorem_text( @indexes );
}

sub lorem_text {
    my ( $self, @indexes ) = @_;
    if ( !@LOREM ) {
        @LOREM = <DATA>;
    }
    if ( !@indexes ) {
        @indexes = ( 0..3 );
    }
    return join "\n\n", @LOREM[ @indexes ];
}

1;

__DATA__
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque a velit eget mauris imperdiet auctor. Sed libero massa, laoreet a dapibus sed, scelerisque malesuada eros. Mauris suscipit, nisl nec rhoncus lacinia, libero felis adipiscing neque, eu ultrices ipsum turpis id dui. In tincidunt ipsum eget eros molestie porta. Maecenas in dui augue. Suspendisse eu pretium mauris. Mauris dignissim facilisis ligula aliquet iaculis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut eget diam vitae quam sollicitudin luctus. Morbi a tortor orci, ut vulputate velit. Mauris malesuada lorem dui, non scelerisque lectus. Ut interdum ligula at neque vehicula aliquet. Mauris venenatis dapibus neque, vitae hendrerit ipsum consectetur sed. Fusce hendrerit, nisl et convallis cursus, ligula augue pharetra lorem, ornare fringilla elit mi id nisl. Nullam et sem ut tellus suscipit eleifend.
Maecenas quis est et sapien condimentum porttitor ut in arcu. Ut nec erat lacus. Cras a ante neque, ac lobortis libero. Maecenas aliquet ullamcorper tellus, et fermentum neque porttitor nec. Aenean mollis porttitor nibh et sollicitudin. Aliquam at congue ligula. Aenean vitae dui non urna scelerisque blandit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus at enim cursus leo venenatis faucibus eu sed dui. Nam id sem ac risus molestie iaculis sed quis sapien. Vivamus sed blandit erat. Nullam placerat imperdiet sem ac ornare. Duis sem erat, euismod eget blandit dapibus, hendrerit imperdiet massa. Mauris quis tincidunt risus. Aliquam luctus vulputate turpis, non facilisis sapien rhoncus sed.
Nulla facilisi. Nam a purus a odio porta hendrerit ut et tellus. Sed hendrerit gravida sapien, et dapibus turpis ornare id. Aliquam mattis, eros sed egestas dignissim, turpis leo sollicitudin ante, nec pulvinar odio lorem id mi. Pellentesque neque lacus, faucibus vitae egestas in, placerat eu neque. Nulla libero est, fringilla id tristique sit amet, aliquam tincidunt nulla. Morbi posuere bibendum ipsum, a cursus tellus tempus quis. Etiam eu nisl eget purus consectetur fringilla sed id neque. Maecenas lacinia dolor sed dui vestibulum non interdum urna placerat. Quisque porta condimentum velit, non lobortis sapien feugiat vel. Ut ut fringilla neque.
Vestibulum dignissim sollicitudin sem aliquet condimentum. Donec egestas felis tempus nunc commodo vel fermentum enim porttitor. Curabitur tristique justo et augue elementum mattis. Phasellus rhoncus convallis augue sed viverra. Nam faucibus adipiscing dolor sagittis convallis. Fusce consectetur pretium nunc, sed rhoncus lacus dignissim eu. Quisque non felis non erat auctor adipiscing et vitae neque. Phasellus adipiscing convallis nisi eget sodales. Donec tincidunt nisl eget tellus laoreet faucibus. Vivamus facilisis eros risus, quis tristique orci. In convallis lacus et nisl venenatis id elementum nunc cursus. Cras pellentesque, mi in iaculis venenatis, sem nisl laoreet quam, ac malesuada dui diam sed enim. Phasellus eleifend posuere sagittis.
Integer ipsum dui, facilisis et adipiscing vitae, lacinia vitae arcu. Cras ac sapien eget ipsum faucibus condimentum at et sapien. Sed id nisi ante, non pharetra velit. Sed faucibus tincidunt nisl sed malesuada. Duis pharetra tempor felis vitae tristique. Vestibulum eget lacus eget ipsum interdum feugiat. Sed quis libero sit amet nisi pharetra posuere. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Suspendisse pharetra pharetra erat, et lacinia lectus fringilla eget. Nunc sem mi, blandit ut aliquet ut, ultricies vitae arcu. Quisque quis diam nibh. Proin nec vehicula sapien. Proin varius turpis a ante venenatis accumsan. Vivamus ornare porttitor lacus eget lacinia.
Quisque aliquam malesuada dolor vehicula aliquet. In in mauris nunc, ac pellentesque tortor. Suspendisse tincidunt nunc vel mauris auctor posuere. Nullam ante nibh, lacinia vitae pulvinar elementum, blandit ut leo. Aliquam erat volutpat. Nam quis risus orci. Sed augue nisl, imperdiet non auctor vitae, blandit in turpis. Duis mauris enim, fermentum eget tempor id, tempor ac tortor. In in justo ut urna scelerisque ultrices nec molestie lectus. In dolor arcu, interdum vitae feugiat eget, sagittis quis tortor. Nunc et metus urna, et sollicitudin augue.
Vivamus vel justo ligula. Nulla feugiat, velit sollicitudin lacinia accumsan, tellus diam rutrum quam, venenatis porta mauris leo quis lorem. Ut quis enim et quam dapibus molestie at nec ipsum. Integer ut purus vitae nibh commodo mollis. Quisque laoreet tellus sit amet ipsum tincidunt posuere. Maecenas diam nisi, dictum et sollicitudin vel, consequat a diam. Phasellus eu lacus sit amet mauris interdum aliquet ac luctus nisl. Nam vel justo nec diam viverra suscipit. Quisque et purus et ipsum vehicula pulvinar eu quis leo. Donec et quam at ante ullamcorper hendrerit nec eu arcu. Quisque a lectus quis felis fermentum malesuada sit amet ut eros. Curabitur facilisis semper aliquet. Vivamus lectus quam, pulvinar sed pellentesque vitae, rhoncus nec ipsum. Sed porttitor, quam vitae bibendum auctor, tellus ipsum condimentum risus, ut dictum neque justo sed nunc. Nunc bibendum, sapien ac egestas malesuada, nulla mauris ultricies lectus, ut congue eros nisl ac lacus. Etiam hendrerit, nunc in vestibulum consectetur, felis libero dignissim lectus, luctus tempus ipsum lectus eu tellus. Mauris rhoncus nisi id tortor condimentum adipiscing.
Quisque vel dapibus odio. Fusce porta pellentesque ligula, vel porttitor diam pharetra imperdiet. Aliquam viverra lacus eleifend sapien imperdiet id varius eros pretium. In condimentum lacinia leo non ornare. Suspendisse mollis elementum volutpat. Duis gravida metus id ligula consequat dapibus. Vestibulum laoreet vehicula metus, at aliquam sapien porttitor ac. Nunc non eros sapien, sed semper odio. Fusce tincidunt, massa ultricies fermentum dignissim, nunc dui interdum felis, quis interdum nisl diam et nunc. Donec sed magna eros. Fusce dignissim dictum tristique. Aenean molestie, nulla placerat faucibus aliquet, mauris ipsum tristique lectus, quis mollis mauris urna et ipsum. Etiam condimentum sapien at nisi convallis in tincidunt augue pellentesque. Donec tincidunt viverra fermentum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at consectetur erat. Vestibulum massa orci, bibendum quis cursus nec, commodo sed mauris. Etiam nec condimentum tortor. Fusce eget congue justo. Proin posuere mauris a sem facilisis egestas.
Maecenas mattis porttitor fringilla. Fusce imperdiet mollis tristique. In non lectus vel risus laoreet ultricies. Mauris sit amet ipsum nunc. Mauris a risus nec ligula adipiscing ullamcorper non eget risus. Maecenas sapien nisi, pellentesque ut ornare in, cursus et metus. Praesent nec ligula purus. In hac habitasse platea dictumst. Praesent feugiat aliquet felis, vitae tempus neque imperdiet ut. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris eleifend, libero quis mollis consequat, orci nibh tempus tortor, ac cursus magna turpis tempus ligula. Suspendisse non blandit dui. Sed vel ultricies sem. Vivamus mauris tortor, feugiat non facilisis vel, egestas vitae massa. Vivamus volutpat, quam eu fringilla aliquam, magna est suscipit nulla, quis pulvinar ipsum odio quis lectus. Etiam est lectus, ultrices in tempor nec, scelerisque eu lacus. Quisque a felis mauris, a pellentesque ligula. Nunc pharetra luctus fermentum. Fusce et velit mauris, eget iaculis ante.
Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nullam fringilla lacus at augue pretium sed consectetur tellus vulputate. Sed gravida augue at nibh congue tristique. Praesent ac orci sit amet sem suscipit facilisis eget ut ligula. Fusce magna odio, scelerisque sed pharetra quis, sollicitudin ut massa. Sed nunc metus, lacinia sed ullamcorper at, congue non neque. Cras eu dui quis massa pretium posuere. Morbi purus augue, convallis tempus consectetur ut, ultricies non tortor. Quisque in leo lacus. Nulla sem turpis, tincidunt in congue pulvinar, placerat pharetra velit. Mauris at purus urna. Maecenas interdum velit vitae diam ultrices tempus. Curabitur molestie aliquet odio. Etiam tempus mauris ut dui tincidunt sodales auctor dolor vestibulum. Donec tincidunt, arcu quis ultrices accumsan, nisl dui aliquam arcu, a tempor elit nulla vitae velit. Quisque sed velit lectus, sit amet sodales risus.
