use WebGUI::Asset;
use WebGUI::Asset::Snippet;
WebGUI::Asset->getRoot(session)->addChild({
    className => 'WebGUI::Asset::Snippet',
    title => 'Test snippet',
});
my $vt = WebGUI::VersionTag->getWorking(session, 'nocreate');
if ($vt) {
    ::addToCleanup($vt);
}
$vt;

