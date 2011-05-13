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

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Auth;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my @cleanupUsernames    = ();   # Will be cleaned up when we're done
my $auth;   # will be used to create auth instances
my ($request, $oldRequest, $output);

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test createAccountSave and returnUrl together
# Set up request
my $createAccountSession = WebGUI::Test->newSession(0, {
    returnUrl       => 'REDIRECT_URL',
});

$auth           = WebGUI::Auth->new( $createAccountSession );
my $username    = $createAccountSession->id->generate;
my $language	= "PigLatin";
push @cleanupUsernames, $username;
installPigLatin();
WebGUI::Test->addToCleanup(sub {
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/);
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/);
	rmdir File::Spec->catdir(WebGUI::Test->lib, qw/WebGUI i18n PigLatin/);
});

$createAccountSession->scratch->setLanguageOverride($language);
$output         = $auth->www_createAccountSave( $username, { }, "PASSWORD" ); 
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
    $createAccountSession->response->location, 'REDIRECT_URL',
    "returnUrl field is used to set redirect after createAccountSave",
);

is $createAccountSession->user->profileField('language'), $language, 'languageOverride is taken in to account in createAccountSave';
$createAccountSession->scratch->delete('language');  ##Remove language override

#----------------------------------------------------------------------------
# Test login and returnUrl together
# Set up request

my $loginSession = WebGUI::Test->newSession(0, {
    returnUrl       => 'REDIRECT_LOGIN_URL',
});

$auth           = WebGUI::Auth->new( $loginSession, 3 );
my $username    = $loginSession->id->generate;
push @cleanupUsernames, $username;
$session->setting->set('showMessageOnLogin', 0);
$output         = $auth->login;

is(
    $loginSession->response->location, 'REDIRECT_LOGIN_URL',
    "returnUrl field is used to set redirect after login",
);
is $output, undef, 'login returns undef when showMessageOnLogin is false';

# Session Cleanup
$session->{_request} = $oldRequest;
sub installPigLatin {
    use File::Copy;
	mkdir File::Spec->catdir(WebGUI::Test->lib, 'WebGUI', 'i18n', 'PigLatin');
	copy( 
		WebGUI::Test->getTestCollateralPath('International/lib/WebGUI/i18n/PigLatin/WebGUI.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/)
	);
	copy(
		WebGUI::Test->getTestCollateralPath('International/lib/WebGUI/i18n/PigLatin.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/)
	);
}

