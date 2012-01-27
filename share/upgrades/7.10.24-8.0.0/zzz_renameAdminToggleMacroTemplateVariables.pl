
use WebGUI::Upgrade::Script;

start_step "Rename AdminToggle Macro template variables";

my $sth = session->db->read( q|SELECT assetId, revisionDate FROM template where namespace="Macro/AdminToggle"| );
ASSET: while ( my ($assetId, $revisionDate) = $sth->array ) {
    my $asset       = eval { WebGUI::Asset->newById( session, $assetId, $revisionDate ); };
    next ASSET if Exception::Class->caught;
    my $template = $asset->get('template');
    $template =~ s/toggle\.url/toggle_url/msg;
    $template =~ s/toggle\.text/toggle_text/msg;
    $asset->update({
        template        => $template,
    });
}


done;

