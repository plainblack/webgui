
use WebGUI::Upgrade::Script;

start_step "Convert all tables except assetIndex to InnoDB";

my $get_table = session->db->table_info('', '', '%', 'TABLE');

TABLE: while ( my $table = $get_table->fetchrow_hashref() ) {
    next TABLE if $table->{TABLE_NAME} eq 'assetIndex';
    session->db->write("ALTER TABLE ". $table->{TABLE_NAME}. " ENGINE=InnoDB");
}


done;

