use FindBin;
use lib "$FindBin::Bin/lib";
use Test::WebGUI::Account;
use Test::WebGUI::Account::Friends;

Test::Class->runtests;
