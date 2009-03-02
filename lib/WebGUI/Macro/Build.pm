package WebGUI::Macro::Build;

=head1 LEGAL

 -------------------------------------------------------------------
  (c) Patrick Donelan
 -------------------------------------------------------------------
  http://patspam.com                     pat@patspam.com
 -------------------------------------------------------------------

=cut

use strict;
use Readonly;
use File::Assets;
use CSS::Minifier::XS;           # implicit
use JavaScript::Minifier::XS;    # implicit
use File::Slurp qw(read_file write_file);
use Digest::SHA1 qw(sha1_hex);
use JSON;

Readonly my $STATIC   => 'static';                    # Source files come from uploads/$STATIC
Readonly my $MINIFIED => 'minified';                  # Build dir is uploads/$MINIFIED
Readonly my $ASSETS   => 'assets';                    # Built JS/CSS files are called $ASSETS.js/css

=head1 NAME

Package WebGUI::Macro::Minify

=head2 DESCRIPTION

Build tool for maximising YSlow score. CSS and JS are minified into files called assets.css and assets.js in the build dir.

=head3 FOLDERS

Build dir lives under /data/domains/site.com/uploads/$STATIC (so that we don't clash with any existing urls). 
Normally this would be a symlink to your custom static folder. 
You can create a "frozen" folder inside $STATIC and modify site.com.modproxy.conf to give it a far-future expiry:
	<Location /uploads/static/frozen>
		ExpiresActive On
		ExpiresDefault "access plus 10 years"
	</Location>
Any files in this folder should be revved.

You will need to manually build mod_expires and modify modproxy.conf to load the module:
    LoadModule expires_module modules/mod_expires.so

$MINIFIED folder gets created automatically (it lives under /uploads too).
You should also give it a far-future expiry:
	<Location /uploads/minified>
		ExpiresActive On
		ExpiresDefault "access plus 10 years"
	</Location>

To further maximise your YSlow score, you should make sure modproxy.conf and modperl.conf both contain:
    LoadModule deflate_module modules/mod_deflate.so
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/x-javascript application/x-shockwave-flash  application/javascript
    FileETag none

=head3 MODES

Modes can be specified either as first argument to macro, or via url as ?build=mode.
Expects unmixed args, e.g. only css, only js or all generic assets (e.g. images). 
Assets are symlinked to build dir. They can be specified as file globs (e.g. 'subfolder/*.png') 
or as entire dirs (e.g. 'subfolder/subsubfolder'). 
Digest cached in wg settings table (see get_digest_field_name).
Description of modes:

=head4 default mode
js: re-use previously built $ASSETS.js and cached digest
css: re-use previously built $ASSETS.css and cached digest
images: re-use symlinked images

=head4 debug mode
js: concat into $ASSETS.js and update digest
css: use original css
images: symlink images

=head4 min mode
js: minify into $ASSETS.js and update digest
css: minify into $ASSETS.css, rewrite CSS image urls and update digest
images: symlink images

=head3 JS Widget Best Practices

Each widget should be in a sub-dir with js, css and images
CSS should use local relative path to images
Images should use unique prefix so that they don't clash with other images when copied to minified folder

=cut

#-------------------------------------------------------------------
sub process {
    my ( $session, @args ) = @_;

    if ( !@args ) {
        $session->log->warn('Minify: no args, skipping');
        return;
    }

    my ( $mode, $type, @files ) = process_macro_args( $session, @args );

    if ( $type eq 'js' ) {
        return handle_js( $session, $mode, @files );
    }
    elsif ( $type eq 'css' ) {
        return handle_css( $session, $mode, @files );
    }
    else {
        return handle_assets( $session, $mode, @files );
    }
}

#-------------------------------------------------------------------

=head2 process_macro_args
Figures out what to do based on the macro args, form params etc.. 
=cut 

sub process_macro_args {
    my ( $session, @args ) = @_;

    # Trim whitespace from Macro arguments
    map {s/^\s+|\s$//g} @args;

    # Get mode and remove any mode-related arguments from @args..
    my $form_param = $session->form->param('build') || q{};
    my $mode = 'default';
    foreach my $valid_mode (qw(min debug)) {
        if ( $args[0] eq $valid_mode ) {
            $mode = $valid_mode;
            shift @args;
        }
        elsif ( $form_param eq $valid_mode ) {
            $mode = $valid_mode;
        }
    }
    my $type = get_type(@args);

    $session->log->debug( "Minify: $mode mode for $type on " . @args . ' files' );

    return ( $mode, $type, @args );
}

#-------------------------------------------------------------------

=head2 get_type
Guesses file type (css or js). Anything else (e.g. images) is returns undef.
=cut 

sub get_type {
    my @files = @_;
    foreach my $file (@files) {
        return 'css' if $file =~ /\.css$/i;
        return 'js'  if $file =~ /\.js$/i;
    }
    return;
}

#-------------------------------------------------------------------

=head2 get_digest_field_name ($type)
Generates the field name used to store the cached digest in the settings table
=cut

sub get_digest_field_name {
    my ($type) = @_;
    return "minify_digest_$type";
}

#-------------------------------------------------------------------

=head2 get_digest
Pulls a previously stored digest out of the wg db
=cut

sub get_digest {
    my ( $session, $type ) = @_;
    my $digest = $session->db->quickScalar( 'select value from settings where name = ?',
        [ get_digest_field_name($type) ] );
    return $digest;
}

#-------------------------------------------------------------------

=head2 handle_assets
Assets are symlinked to build dir. They can be specified as file globs (e.g. 'subfolder/*.png') 
or as entire dirs (e.g. 'subfolder/subsubfolder'). 
=cut

sub handle_assets {
    my ( $session, $mode, @files ) = @_;

    # Check if we need to do anything extra for mode..
    if ( $mode ne 'default' ) {

        # N.B. Not needed for CSS images in debug mode, but possibly for js and other things
        link_assets( $session, @files );
    }

    return;    # no output needed for assets
}

#-------------------------------------------------------------------

=head2 link_assets (@files)
Symlink files to the build dir 
=cut

sub link_assets {
    my ( $session, @files ) = @_;
    my $base_dir  = $session->config->get('uploadsPath');
    my $build_dir = "$base_dir/$MINIFIED";

    my $counter = 0;
    foreach my $file (@files) {
        $file =~ s{^[/.]*}{};    # disallow absolute paths
        $file =~ s{\.\.}{}g;     # disallow tree-traversal
        if ( $file =~ /\*/ ) {
            $session->log->debug("Processing file glob: $file");
            while (my $asset = <$base_dir/$STATIC/$file>) {    # probably a security hole
                my $src = $asset;
                $asset =~ s{.*/}{};                            # remove subdirs from path
                my $dest = "$build_dir/$asset";
                create_link( $session, $src, $dest );
                $counter++;
            }
        }
        else {
            $session->log->debug("Processing asset: $file");
            my $src  = "$base_dir/$STATIC/$file";
            $file =~ s{.*/}{};                            # remove subdirs from path
            my $dest = "$build_dir/$file";
            create_link( $session, $src, $dest );
            $counter++;
        }
    }
    $session->log->debug("Minify: linked $counter assets to: $build_dir");
    return;
}

#-------------------------------------------------------------------

=head2 create_link ($src, $dest)
Create a single symlink from $src to $dest
=cut

sub create_link {
    my ( $session, $src, $dest ) = @_;
    if ( -e $dest && !-l $dest ) {
        $session->log->error("Destination file exists but is not a symlink: $dest");
        return;
    }
    else {
        remove( $session, $dest );

        if ( symlink $src, $dest ) {
            $session->log->debug("Symlinked $src to $dest");
            return 1;
        }
        else {
            $session->log->error("Unable to symlink $src to $dest: $!");
            return;
        }
    }
}

#-------------------------------------------------------------------

=head2 handle_css ($mode, @files)
In debug mode, write out link tags to original (untouched) css files.
In min mode, minify css to $ASSETS.css, rewrite CSS image urls and update digest.
In default mode, pluck the digest out of the db and do no work.

This call to the macro should be placed in the HEAD of the document.
=cut

sub handle_css {
    my ( $session, $mode, @files ) = @_;

    # Check if we need to minify..
    if ( $mode eq 'min' ) {
        minify( $session, $mode, 'css', @files );
    }

    my $base_uri = $session->config->get('uploadsURL');

    my $output = q{};
    if ( $mode eq 'debug' ) {

        # Use original css in debug mode
        foreach my $file (@files) {
            my $original_file_uri = "$base_uri/$STATIC/$file";
            $output .= qq~\n<link rel="stylesheet" href="$original_file_uri" type="text/css">~;
        }
    }
    else {

        # Use minified css in both 'min' and 'default' modes
        my $digest = get_digest( $session, 'css' );
        my $asset_uri = "$base_uri/$MINIFIED/$ASSETS.css?digest=$digest";
        $output = qq~<link rel="stylesheet" href="$asset_uri" type="text/css">~;
    }
    return $output;
}

#----------------------------------------------------------------------------

=head2 handle_js

In debug mode, concat js files into $ASSETS.js and update the digest.
In min mode, minify js files into $ASSETS.js and update the digest.
In default mode, pluck the digest out of the db and do no work.

This call to the macro should be placed in the bottom of the BODY of the document

=cut

sub handle_js {
    my ( $session, $mode, @files ) = @_;

    # Check if we need to minify
    if ( $mode ne 'default' ) {    # Minify in both 'min' and 'debug' modes
        minify( $session, $mode, 'js', @files );
    }

    my $base_uri     = $session->config->get('uploadsURL');
    my $digest       = get_digest( $session, 'js' );
    my $asset_uri    = "$base_uri/$MINIFIED/$ASSETS.js?digest=$digest";
    
    return qq~<script type="text/javascript" src="$asset_uri"></script>~;
}

#----------------------------------------------------------------------------

=head2 minify
Minify js or css. Valid modes are 'debug' or 'min':
In min mode:
* js: minify into $ASSETS.js
* css: minify into $ASSETS.css
In debug mode:
* js: concat into $ASSETS.js
* css: invalid mode
=cut

sub minify {
    my ( $session, $mode, $type, @files ) = @_;

    # Only handle js and css
    if ( $type ne 'js' && $type ne 'css' ) {
        $session->log->error('Invalid type, skipping');
        return;
    }

    # Valid modes for js: 'debug' and 'min'
    if ( $type eq 'js' && $mode ne 'debug' && $mode ne 'min' ) {
        $session->log->error("Invalid mode for $type: $mode");
        return;
    }

    # Valid modes for css: 'min'
    if ( $type eq 'css' && $mode ne 'min' ) {
        $session->log->error("Invalid mode for $type: $mode");
        return;
    }

    my $base_dir    = $session->config->get('uploadsPath');
    my $base_uri    = $session->config->get('uploadsURL');
    my $output_path = "$MINIFIED/$ASSETS";
    my $asset_path  = "$base_dir/$output_path.$type";

    if ( !@files ) {
        $session->log->error('Minify: No files to process, skipping');
        return;
    }

    $session->log->debug("minify $mode mode for $type");

    # Start with a clean slate
    remove( $session, $asset_path );

    my $concat = concat( $base_dir, @files );
    my $digest = sha1_hex($concat);
    update_digest( $session, $digest, $type );

    if ( $mode eq 'debug' ) {    # only applies to js
        write_file( $asset_path, $concat );
    }
    else {
        my $assets = File::Assets->new(
            base => {
                dir => $base_dir,
                uri => $base_uri,
            },
            minify => 'xs',
        );

        # Built files go here (if we build at all)
        $assets->set_output_path($output_path);

        # Process the files..
        foreach my $file (@files) {
            $assets->include("$STATIC/$file");
        }
        $assets->export();
    }

    if ( $type eq 'css' ) {
        rewrite_image_urls( $session, $asset_path, $digest );
    }

    $session->log->debug( "Minify: ${mode}'d " . @files . " assets to: $asset_path ($digest)" );
    
    return;
}

#----------------------------------------------------------------------------

=head2 rewrite_image_urls ( $session, $asset_path, $digest )
Append digest query string to the end of all relative CSS image urls in the CSS file specified at $asset_path
=cut

sub rewrite_image_urls {
    my ( $session, $asset_path, $digest ) = @_;
    $session->log->debug('Adding digest to CSS image urls');
    my $content = read_file($asset_path) or $session->log->warn("rewrite_image_urls unable to read $asset_path: $!");
    $content =~ s{url\(([^/][^)]*)\)}{url($1?digest=$digest)}ig;
    write_file( $asset_path, $content ) or $session->log->warn("rewrite_image_urls unable to write $asset_path: $!");
    return;
}

#----------------------------------------------------------------------------

=head2 remove ($session, $file)
Unlink file if it exists
=cut

sub remove {
    my ( $session, $file ) = @_;
    if ( -e $file ) {
        $session->log->debug("Removing file: $file");
        unlink $file or $session->log->warn("Error removing $file: $!");
    }
    return;
}

#----------------------------------------------------------------------------

=head2 update_digest ($session, $digest, $type)
Update the cached digest in the db
=cut

sub update_digest {
    my ( $session, $digest, $type ) = @_;
    my $field_name = get_digest_field_name($type);
    $session->db->write( 'delete from settings where name = ?', [$field_name] );
    $session->db->write( 'insert into settings (name, value) values (?,?)', [ $field_name, $digest ] );
    $session->log->debug("Minify: Set digest: $digest");
    return;
}

#----------------------------------------------------------------------------

=head2 concat ( $base_dir, @files)
Concatenate the specified @files
=cut

sub concat {
    my ( $base_dir, @files ) = @_;
    my @output;
    foreach my $file (@files) {
        my $slurped = read_file("$base_dir/$STATIC/$file");
        push @output, $slurped;
    }
    return join( "\n", @output ) . "\n";
}

1;
