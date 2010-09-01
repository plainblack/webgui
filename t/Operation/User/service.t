# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

#  Test the user services from WebGUI::Operation::User
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use XML::Simple;
use JSON;
use WebGUI::Operation::User;
use WebGUI::Operation::Auth;
use Data::Dumper;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->config->delete('serviceSubnets');

my ( $response, $responseObj, $auth, $userAndy, $userRed );

#----------------------------------------------------------------------------
# Tests

plan tests => 56;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# www_ajaxCreateUser

# Permissions
# - user
$session->user({ userId => 1 });
$response = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);

# - serviceSubnets
$session->request->env->{REMOTE_ADDR} = '2.2.2.2';
$session->config->set('serviceSubnets',['1.1.1.1/32']);
$session->user({ userId => 3 });
$session->request->setup_body({
    as          => "xml",
});
$response = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/xml', "Correct mime type (as => xml)" );
cmp_deeply(
    XML::Simple::XMLin( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);
$session->request->setup_body({});
$session->config->delete('serviceSubnets');

# Invalid parameters
# - username missing
$session->request->setup_body({
    as                          => "json",
    'auth:WebGUI:identifier'    => 'somethingorother',
    firstName                   => "Andy",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (as => json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'username',
        message     => ignore(),
    },
    "Missing username gets correct error object",
);

# - username exists
$session->request->setup_body({
    username            => "Visitor",
    firstName           => 'Jake',
});
$response = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'username',
        message     => ignore(),
    },
    "Existing username gets correct error object",
);

# Correct operation
# - with webgui password
$session->request->setup_body({
    username                    => "ADufresne",
    'auth:WebGUI:identifier'    => 'Zihuatanejo',
    'auth:WebGUI:changePassword'=> 1,
    firstName                   => "Andy",
    lastName                    => "Dufresne",
    'auth:LDAP:connectDN'       => 'u=andy;o=block-e;dc=shawshank;dc=me',
});
$response   = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json" );
$responseObj    = JSON->new->decode( $response );
cmp_deeply(
    $responseObj,
    { 
        user => superhashof({
            userId          => re(qr/^.{22}$/),
            username        => 'ADufresne',
            firstName       => 'Andy',
            lastName        => 'Dufresne',
            authMethod      => 'WebGUI', # default auth method
        }),
    },
    "Success response contains new users information",
);
$userAndy   = WebGUI::User->new( $session, $responseObj->{user}->{userId} );
is( $userAndy->get("username"), "ADufresne", "User exists and username is correct" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'WebGUI', $userAndy->getId );
is( $auth->getParams->{identifier}, $auth->hashPassword('Zihuatanejo'), "Password is correct" );
is( $auth->getParams->{changePassword}, 1, "Auth param set correctly (WebGUI)" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'LDAP', $userAndy->getId );
is( $auth->getParams->{connectDN}, 'u=andy;o=block-e;dc=shawshank;dc=me', "Auth param set correctly (LDAP)" );

# - without webgui password
$session->request->setup_body({
    username                    => "EBRedding",
    'auth:WebGUI:changePassword'=> 1,
    firstName                   => "Ellis",
    lastName                    => "Redding",
    'auth:LDAP:connectDN'       => 'u=red;o=block-e;dc=shawshank;dc=me',
});
$response   = WebGUI::Operation::User::www_ajaxCreateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json" );
$responseObj    = JSON->new->decode( $response );
cmp_deeply(
    $responseObj,
    { 
        user => superhashof({
            userId          => re(qr/^.{22}$/),
            username        => 'EBRedding',
            firstName       => 'Ellis',
            lastName        => 'Redding',
            authMethod      => 'WebGUI', # default auth method
        }),
    },
    "Success response contains new users information",
) or diag explain $responseObj;
$userRed    = WebGUI::User->new( $session, $responseObj->{user}->{userId} );
is( $userRed->get("username"), "EBRedding", "User exists and username is correct" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'WebGUI', $userRed->getId );
is( $auth->getParams->{changePassword}, 1, "Auth param set correctly (WebGUI)" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'LDAP', $userRed->getId );
is( $auth->getParams->{connectDN}, 'u=red;o=block-e;dc=shawshank;dc=me', "Auth param set correctly (LDAP)" );


#----------------------------------------------------------------------------
# www_ajaxUpdateUser

# Permissions
# - user
$session->user({ userId => 1 });
$response = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);

# - serviceSubnets
$session->request->env->{REMOTE_ADDR} = '2.2.2.2';
$session->config->set('serviceSubnets',['1.1.1.1/32']);
$session->user({ userId => 3 });
$session->request->setup_body({
    as          => "xml",
});
$response = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/xml', "Correct mime type (as => xml)" );
cmp_deeply(
    XML::Simple::XMLin( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);
$session->request->setup_body({});
$session->config->delete('serviceSubnets');

# Invalid parameters
# - no userId parameter
$session->request->setup_body({
    as                          => "json",
    'auth:WebGUI:identifier'    => 'somethingorother',
    firstName                   => "Andy",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (as => json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Missing userId gets correct error object",
);

# - userId doesn't exist
$session->request->setup_body({
    userId                      => "MORGANFREEMANREDHRNG",
    'auth:WebGUI:identifier'    => 'somethingorother',
    firstName                   => "Andy",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Invalid userId gets correct error object",
);

# Correct operation
# - with webgui password
$session->request->setup_body({
    userId                      => $userAndy->getId,
    'auth:WebGUI:identifier'    => 'RichardsHotelAndFishing',
    'auth:WebGUI:changeUsername'=> 1,
    firstName                   => "Richard",
    lastName                    => "Stevens",
    'auth:LDAP:connectDN'       => 'u=rich;o=escapee;dc=shawshank;dc=me',
});
$response   = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json" );
$responseObj    = JSON->new->decode( $response );
cmp_deeply(
    $responseObj,
    { 
        user => superhashof({
            userId          => $userAndy->getId,
            username        => 'ADufresne',
            firstName       => 'Richard',
            lastName        => 'Stevens',
            authMethod      => 'WebGUI', # default auth method
        }),
    },
    "Success response contains new users information",
);
$userAndy   = WebGUI::User->new( $session, $responseObj->{user}->{userId} );
is( $userAndy->get("username"), "ADufresne", "User exists and username is correct" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'WebGUI', $userAndy->getId );
is( $auth->getParams->{identifier}, $auth->hashPassword('RichardsHotelAndFishing'), "Password is correct" );
is( $auth->getParams->{changeUsername}, 1, "Auth param set correctly (WebGUI)" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'LDAP', $userAndy->getId );
is( $auth->getParams->{connectDN}, 'u=rich;o=escapee;dc=shawshank;dc=me', "Auth param set correctly (LDAP)" );

# - without webgui password
$session->request->setup_body({
    userId                      => $userRed->userId,
    'auth:WebGUI:changeUsername'=> 1,
    firstName                   => "Red",
    'auth:LDAP:connectDN'       => 'u=red;o=parollee;dc=shawshank;dc=me',
});
$response   = WebGUI::Operation::User::www_ajaxUpdateUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json" );
$responseObj    = JSON->new->decode( $response );
cmp_deeply(
    $responseObj,
    { 
        user => superhashof({
            userId          => $userRed->userId,
            username        => 'EBRedding',
            firstName       => 'Red',
            lastName        => 'Redding',
            authMethod      => 'WebGUI', # default auth method
        }),
    },
    "Success response contains new users information",
) or diag explain $responseObj;
$userRed    = WebGUI::User->new( $session, $responseObj->{user}->{userId} );
is( $userRed->get("username"), "EBRedding", "User exists and username is correct" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'WebGUI', $userRed->getId );
is( $auth->getParams->{changeUsername}, 1, "Auth param set correctly (WebGUI)" );
$auth   = WebGUI::Operation::Auth::getInstance( $session, 'LDAP', $userRed->getId );
is( $auth->getParams->{connectDN}, 'u=red;o=parollee;dc=shawshank;dc=me', "Auth param set correctly (LDAP)" );

#----------------------------------------------------------------------------
# www_ajaxDeleteUser

# Permissions
# - user
$session->user({ userId => 1 });
$response = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);

# - serviceSubnets
$session->request->env->{REMOTE_ADDR} = '2.2.2.2';
$session->config->set('serviceSubnets',['1.1.1.1/32']);
$session->user({ userId => 3 });
$session->request->setup_body({
    as          => "xml",
});
$response = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/xml', "Correct mime type (as => xml)" );
cmp_deeply(
    XML::Simple::XMLin( $response ),
    {
        error       => 'WebGUI::Error::Unauthorized',
        message     => ignore(),
    },
    "Unauthorized user gets correct error object",
);
$session->request->setup_body({});
$session->config->delete('serviceSubnets');

# Invalid parameters
# - no userId parameter
$session->request->setup_body({
    as                          => "json",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (as => json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Missing userId gets correct error object",
);

# - userId doesn't exist
$session->request->setup_body({
    userId                      => "MORGANFREEMANREDHRNG",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Invalid userId gets correct error object",
);

# - Cannot delete Visitor
$session->request->setup_body({
    userId                      => "1",
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Cannot delete Visitor",
);

# - Cannot delete Admin
$session->request->setup_body({
    userId                      => '3',
});
$session->user({ userId => 3 });
$response   = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', "Correct mime type (default: json)" );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        error       => 'WebGUI::Error::InvalidParam',
        param       => 'userId',
        message     => ignore(),
    },
    "Cannot delete Admin",
);

# Correct operation
$session->request->setup_body({
    userId              => $userAndy->getId,
});
$response = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', 'Correct mime type (default: json)' );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        message     => ignore(),
    },
    "Success returns only message, no error",
);
ok( !WebGUI::User->validUserId( $session, $userAndy->getId ), "UserId no longer exists" );

$session->request->setup_body({
    userId              => $userRed->getId,
});
$response = WebGUI::Operation::User::www_ajaxDeleteUser( $session );
is( $session->http->getMimeType, 'application/json', 'Correct mime type (default: json)' );
cmp_deeply(
    JSON->new->decode( $response ),
    {
        message     => ignore(),
    },
    "Success returns only message, no error",
);
ok( !WebGUI::User->validUserId( $session, $userRed->getId ), "UserId no longer exists" );

#vim:ft=perl
