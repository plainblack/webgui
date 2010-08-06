
use WebGUI::Upgrade::Script;

report "\tRemoving Admin Bar... ";

session->config->delete( 'macros/AdminBar' );

report "\tEditing templates to remove AdminBar macro calls...";

use WebGUI::Macro;
use WebGUI::Asset::Template;

my $iter    = WebGUI::Asset::Template->getIsa( session );
ASSET: while (1) {
    my $template = eval { $iter->() };
    if (my $e = Exception::Class->caught()) {
        session->log->error($@);
        next ASSET;
    }
    last ASSET unless $template;

    my $content = $template->template;
    while ( $content =~ m/$WebGUI::Macro::macro_re/g ) {
        my $macroCall   = $1;
        my $macroName   = $2;
        if ( $macroName eq 'AdminBar' ) {
            $content    =~ s/\Q$macroCall//g;
        }
    }

    $template->template( $content );
    $template->write;
}


done;
