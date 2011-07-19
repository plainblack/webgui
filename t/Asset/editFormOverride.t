use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../t/lib";

use WebGUI::Test;
use WebGUI::Asset;
use Test::More tests => 2;
use Monkey::Patch qw(patch_class);

my $session = WebGUI::Test->session;
WebGUI::Test->originalConfig('assets/WebGUI::Asset::Wobject::Layout');
my $asset = WebGUI::Asset->getTempspace($session)->addChild(
    {
        className => 'WebGUI::Asset::Wobject::Layout',
    }
);

sub capture {
    my $save;
    my $patch = patch_class 'WebGUI::Form::Control' => new => sub {
        my $orig = shift;
        my $self = $orig->(@_);
        my $name = $self->get('name');
        $save = $self if $name && $name eq 'assetsToHide';
        return $self;
    };
    $asset->getEditForm;
#use Data::Dumper::Concise;
#print STDERR '# ' . Dumper $save->{_params};
    return $save;
}

my $config = $session->config;
my $pfx = 'assets/WebGUI::Asset::Wobject::Layout/fields/assetsToHide';
$config->set("$pfx/uiLevel", 1);
is capture->get('uiLevel'), 1;

$config->set("$pfx/uiLevel", "2");
is capture->get('uiLevel'), 2;
