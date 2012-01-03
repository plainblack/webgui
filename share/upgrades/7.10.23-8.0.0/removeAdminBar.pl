use WebGUI::Upgrade::Script;

start_step "Editing templates to remove AdminBar macro calls";

use WebGUI::Macro;
use WebGUI::Asset::Template;
use File::Spec;
use Cwd qw(realpath);
use WebGUI::Paths;

my $removeAdminBar = sub {
    my $macro = shift;
    if ($macro->{macro} eq 'AdminBar' || $macro->{macroPackage} eq 'WebGUI::Macro::AdminBar' ) {
        return '';
    }
    else {
        return;
    }
};
my $iter    = WebGUI::Asset::Template->getIsa( session );
ASSET: while (1) {
    my $template = eval { $iter->() };
    if (my $e = Exception::Class->caught()) {
        session->log->error($@);
        next ASSET;
    }
    last ASSET unless $template;

    my $content = $template->template;
    WebGUI::Macro::transform( session, \$content, $removeAdminBar );
    $template->template( $content );
    $template->write;
}

done;

start_step "Removing Admin Bar from config file";

session->config->delete( 'macros/AdminBar' );

done;

start_step "Removing Admin Bar module";

rm_lib('WebGUI::Macro::AdminBar');

done;
