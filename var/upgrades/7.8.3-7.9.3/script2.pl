report "Doing something more interesting\n";

report session->db->quickScalar('SELECT count(*) from asset');

done;

