use FindBin;
use lib "$FindBin::Bin/lib";
use Test::WebGUI::Account;
use Test::WebGUI::Account::Friends;
use Test::WebGUI::Account::Contributions;
use Test::WebGUI::Account::User;

Test::Class->runtests;
