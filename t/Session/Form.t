#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use Test::More;

plan tests => 4;

my $session = WebGUI::Test->session;
my $token = $session->scratch->get('webguiCsrfToken');

$session->request->env->{'REQUEST_METHOD'} = 'POST';
$session->request->setup_param({ webguiCsrfToken => $token, });
ok($session->form->validToken, 'validToken: right method and form value');

$session->request->env->{'REQUEST_METHOD'} = 'GET';
ok(! $session->form->validToken, '... wrong method, right form value');

$session->request->env->{'REQUEST_METHOD'} = 'POST';
$session->request->setup_param({ webguiCsrfToken => 'bad token', });
ok(! $session->form->validToken, 'validToken: right method and wrong form value');

$session->request->env->{'REQUEST_METHOD'} = 'GET';
ok(! $session->form->validToken, 'validToken: wrong method and form value');
