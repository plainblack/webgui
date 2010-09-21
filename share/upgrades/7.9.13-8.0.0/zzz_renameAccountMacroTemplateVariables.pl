
use WebGUI::Upgrade::Script;

start_step "Rename Account Macro template variables";

my $sth = session->db->read( q|SELECT assetId, revisionDate FROM template where namespace="Macro/a_account"| );
ASSET: while ( my ($assetId, $revisionDate) = $sth->array ) {
    my $asset       = eval { WebGUI::Asset->newById( session, $assetId, $revisionDate ); };
    next ASSET if Exception::Class->caught;
    my $template = $asset->get('template');
    $template =~ s/account\.url/account_url/msg;
    $template =~ s/account\.text/account_text/msg;
    $asset->update({
        template        => $template,
    });
}


done;

