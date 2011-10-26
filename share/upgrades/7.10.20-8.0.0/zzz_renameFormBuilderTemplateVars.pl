
use WebGUI::Upgrade::Script;
use WebGUI::Asset::Template;

start_step "Migrating templates to FormBuilder variables...";
version_tag "Migrating templates to FormBuilder";

# Map of namespace => { oldName => newName }
# This is done first.
my %namespaces = (
    "Account/FriendManager/Edit" => {
        formHeader      => "form_header",
        friends_loop    => "form_field_friendToAxe_loop",
        checkForm       => "field",
        # username      => "label",     # This only in the friends_loop, see replacements below
        removeAll       => "form_field_removeAllFriends",
        addUser         => "form_field_userToAdd",
        addManagers     => "form_field_addManagers",
        submit          => "form_field_submit",
        formFooter      => "form_footer",
    },
    "Account/Friends/SendRequest" => {
        form_message_rich   => "form_field_message_field",
        submit_button       => "form_field_submit",
    },
);

# Map of namespace => { match => replacement }
# This is done second
my %replacements = (
    "Account/FriendManager/Edit" => {
        "(<tmpl_var form_header>)" => '%s<tmpl_var form_field_userId><tmpl_var form_field_groupName>',
        "(friendToAxe_loop.+?)username(.+?tmpl_loop)" => '%slabel%s',
    },
);


for my $ns ( keys %namespaces ) {
    # Get all the templates in this namespace
    for my $assetId ( keys %{ WebGUI::Asset::Template->getList( session, $ns ) } ) {
        my $asset   = asset( $assetId );
        my $template = $asset->template;

        for my $old ( keys %{ $namespaces{$ns} || {} } ) {
            my $new = $namespaces{$ns}->{$old};
            $template =~ s/$old/$new/g;
        }

        for my $match ( keys %{ $replacements{$ns} || {} } ) {
            my $replace = $replacements{$ns}->{$match};
            $template =~ s/$match/sprintf( $replace, $1, $2, $3, $4, $5, $6, $7, $8, $9 )/es; # No, I do not feel good about this
        }

        session->log->error( $template );
        $asset->addRevision( {
            template    => $template,
            tagId       => version_tag->getId,
            status      => "pending",
        } );
    }
}

version_tag->commit;
done;
