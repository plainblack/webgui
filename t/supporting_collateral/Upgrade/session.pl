use WebGUI::Upgrade::Script;
my $s = session;
::isa_ok $s, 'WebGUI::Session';
::is $s, session, 'session properly cached';
::is $s->user->getId, 3, 'admin user set for session';

$s->getId;

