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

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Auth;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my @cleanupUsernames    = ();   # Will be cleaned up when we're done
my $AUTH_METHOD     = "TEST";   # Used as second argument to WebGUI::Auth->new
my $auth;   # will be used to create auth instances
my ($request, $oldRequest, $output);

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test createAccountSave and returnUrl together
# Set up request
$oldRequest  = $session->request;
$request     = WebGUI::PseudoRequest->new;
$request->setup_param({
    returnUrl       => 'REDIRECT_URL',
});
$session->{_request} = $request;

$auth           = WebGUI::Auth->new( $session, $AUTH_METHOD );
my $username    = $session->id->generate;
my $language	= "PigLatin";
push @cleanupUsernames, $username;
installPigLatin();
WebGUI::Test->addToCleanup(sub {
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/);
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/);
	rmdir File::Spec->catdir(WebGUI::Test->lib, qw/WebGUI i18n PigLatin/);
});

$session->scratch->setLanguageOverride($language);
$output         = $auth->createAccountSave( $username, { }, "PASSWORD" ); 
WebGUI::Test->addToCleanup(sub {
    for my $username ( @cleanupUsernames ) {
        # We don't create actual, real users, so we have to cleanup by hand
        my $userId  = $session->db->quickScalar(
            "SELECT userId FROM users WHERE username=?",
            [ $username ]
        );
        
        my @tableList
            = qw{authentication users userProfileData groupings inbox userLoginLog};

        for my $table ( @tableList ) {
            $session->db->write(
                "DELETE FROM $table WHERE userId=?",
                [ $userId ]
            );
        }
    }
});

is(
    $session->http->getRedirectLocation, 'REDIRECT_URL',
    "returnUrl field is used to set redirect after createAccountSave",
);

is $session->user->profileField('language'), $language, 'languageOverride is taken in to account in createAccountSave';
$session->scratch->delete('language');  ##Remove language override

# Session Cleanup
$session->{_request} = $oldRequest;

#----------------------------------------------------------------------------
# Test login and returnUrl together
# Set up request
$oldRequest  = $session->request;
$request     = WebGUI::PseudoRequest->new;
$request->setup_param({
    returnUrl       => 'REDIRECT_LOGIN_URL',
});
$session->{_request} = $request;

$auth           = WebGUI::Auth->new( $session, $AUTH_METHOD, 3 );
my $username    = $session->id->generate;
push @cleanupUsernames, $username;
$session->setting->set('showMessageOnLogin', 0);
$output         = $auth->login; 

is(
    $session->http->getRedirectLocation, 'REDIRECT_LOGIN_URL',
    "returnUrl field is used to set redirect after login",
);
is $output, undef, 'login returns undef when showMessageOnLogin is false';


# Session Cleanup
$session->{_request} = $oldRequest;
sub installPigLatin {
    use File::Copy;
	mkdir File::Spec->catdir(WebGUI::Test->lib, 'WebGUI', 'i18n', 'PigLatin');
	copy( 
		WebGUI::Test->getTestCollateralPath('WebGUI.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/)
	);
	copy(
		WebGUI::Test->getTestCollateralPath('PigLatin.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/)
	);
}


