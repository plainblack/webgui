use WebGUI::Upgrade::Script;
my $vt = version_tag;
::addToCleanup($vt);

::isa_ok $vt, 'WebGUI::VersionTag';
::is $vt->get('name'), 'Upgrade to 8.3.0 - versiontag', 'auto-naming with short name works';

::is $vt, version_tag, 'second call gives same version tag';
::ok ! $vt->get('isCommitted'), '... and doesn\'t commit version tag';

my $vt2 = version_tag 'Adding This Stuff';
::addToCleanup($vt);
::ok $vt->get('isCommitted'), 'Request for new version tag commits previous tag';
::is $vt2->get('name'), 'Upgrade to 8.3.0 - Adding This Stuff', 'explicit name used correctly';


