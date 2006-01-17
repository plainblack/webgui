package WebGUI::Test;

use strict;
use warnings;

our ( $SESSION, $WEBGUI_ROOT, $CONFIG_FILE, $WEBGUI_LIB );

use IO::Handle qw[];
use File::Spec qw[];

BEGIN {

    STDERR->autoflush(1);

    ( $CONFIG_FILE, $WEBGUI_LIB ) = @ENV{ qw( WEBGUI_CONFIG WEBGUI_LIB ) };

    unless ( defined $CONFIG_FILE && $CONFIG_FILE ) {
        warn qq/Enviroment variable WEBGUI_CONFIG must be set.\n/;
        exit(1);
    }

    unless ( -e $CONFIG_FILE ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' does not exist.\n/;
        exit(1);
    }

    unless ( -f _ ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' is not a file.\n/;
        exit(1);
    }

    unless ( -r _ ) {
        warn qq/WEBGUI_CONFIG path '$CONFIG_FILE' is not readable by effective uid '$>'.\n/;
        exit(1);
    }

    $WEBGUI_ROOT = $CONFIG_FILE;

    unless ( File::Spec->file_name_is_absolute($WEBGUI_ROOT) ) {
        $WEBGUI_ROOT = File::Spec->rel2abs($WEBGUI_ROOT);
    }

    $CONFIG_FILE = ( File::Spec->splitpath( $WEBGUI_ROOT ) )[2];
    $WEBGUI_ROOT = substr( $WEBGUI_ROOT, 0, index( $WEBGUI_ROOT, File::Spec->catdir( 'etc', $CONFIG_FILE ) ) );
    $WEBGUI_ROOT = File::Spec->canonpath($WEBGUI_ROOT);

    $WEBGUI_LIB  ||= File::Spec->catpath( $WEBGUI_ROOT, 'lib' );

    lib->import( $WEBGUI_LIB );

    unless ( eval "require WebGUI::Session;" ) {
        warn qq/Failed to require package 'WebGUI::Session'. Reason: '$@'.\n/;
        exit(1);
    }

    $SESSION = WebGUI::Session->open( $WEBGUI_ROOT, $CONFIG_FILE );
}

END {
    $SESSION->close if defined $SESSION;
}

sub file {
    return $CONFIG_FILE;
}

sub config {
    return undef unless defined $SESSION;
    return $SESSION->config;
}

sub lib {
    return $WEBGUI_LIB;
}

sub session {
    return $SESSION;
}

sub root {
    return $WEBGUI_ROOT;
}

1;
