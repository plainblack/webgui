#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use JSON;

use WebGUI::Test;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Macro::UsersOnline;

use Test::More; # increment this value for each test you create
use Test::Exception;

my $session = WebGUI::Test->session;

my $template = setupJSONtemplate($session);
my @users = setupUsers($session);
my $i18n = WebGUI::International->new($session,'Macro_UsersOnline');

plan tests => 30;

# Basic testing -----------------------------------------------------------

# Check for default template
lives_ok { WebGUI::Asset->newById($session, 'h_T2xtOxGRQ9QJOR6ebLpQ'); }, 'default template is present';

# Call with default values
my $html = WebGUI::Macro::UsersOnline::process($session);
ok($html, 'call with default template and values returns some output');


# Test labels -------------------------------------------------------------

$session->user({userId => 1});
my $json = WebGUI::Macro::UsersOnline::process($session, $template->getId);
my $vars = JSON::from_json($json);

is($vars->{'usersOnline_label'}, $i18n->get('Users Online'), 'usersOnline_label');
is($vars->{'members_label'}, $i18n->get('Members'), 'members_label');
is($vars->{'visitors_label'}, $i18n->get('Visitors'), 'visitors_label');
is($vars->{'total_label'}, $i18n->get('Total'), 'total_label');
is($vars->{'membersOnline_label'}, $i18n->get('Members Online'), 'membersOnline_label');
is($vars->{'visitorsOnline_label'}, $i18n->get('Visitors Online'), 'visitorsOnline_label');
is($vars->{'avatar_label'}, $i18n->get('Avatar'), 'avatar_label');
is($vars->{'name_label'}, $i18n->get('Name'), 'name_label');
is($vars->{'alias_label'}, $i18n->get('Alias'), 'alias_label');
is($vars->{'session_label'}, $i18n->get('Session'), 'session_label');
is($vars->{'ip_label'}, $i18n->get('IP'), 'ip_label');
is($vars->{'lastActivity_label'}, $i18n->get('Last Activity'), 'lastActivity_label');


# Test logic --------------------------------------------------------------

like($vars->{'visitors'},  qr/[0-9]+/, 'visitors is numeric');
# Does not work in testing environments that run on the loopback interface,
# since these queries are filtered out by the macro.
#    is($vars->{'visitors'} > 0, 1, 'visitors > 0 when calling as visitor');
like($vars->{'members'}, qr/[0-9]+/, 'members is numeric');
cmp_ok($vars->{'members'}, '>', 0, 'members > 0 since we have created one visible active member');
is($vars->{'total'}, $vars->{'visitors'} + $vars->{'members'}, 'total == visitors + members');
ok($vars->{'isVisitor'}, 'isVisitor is true when calling as visitor');
ok(defined $vars->{'hasMembers'}, 'hasMembers is defined since we have created one visible active member');


# Check member loop -------------------------------------------------------

my $allFieldsSet = 1;
my $firstUserPresent = 0;
my $secondUserAbsent = 1;

foreach (@{$vars->{'member_loop'}}) {
    # Check whether first user is present
    if ($_->{'username'} eq 'tester1') {
            # Indicate success
            $firstUserPresent = 1;
            # Check whether alias and name have been set correctly
            $allFieldsSet = $_->{'alias'} eq 'alias1';
            $allFieldsSet &&= $_->{'firstName'} eq 'first1';
            $allFieldsSet &&= $_->{'middleName'} eq 'middle1';
            $allFieldsSet &&= $_->{'lastName'} eq 'last1';
    }

    # Check whether second user is present
    if ($_->{'username'} eq 'tester2') {
            # Indicate failure
            $secondUserAbsent = 0;
    }        

    # Check whether remaining fields have been set. Note that we cannot
    # check for the alias, name or avatar, since these values may be 
    # optional.
    $allFieldsSet &&= $_->{'uid'} =~ /.*/;
    $allFieldsSet &&= $_->{'sessionId'} =~ /.*/;
#        $allFieldsSet &&= $_->{'ip'} =~ /.*/;  # IP is not set for our test user
    $allFieldsSet &&= $_->{'lastActivity'} =~ /.*/;
}
# Check booleans indicating errors
ok($allFieldsSet,     'fields in the member loop have been set correctly');
ok($firstUserPresent, 'the first user is present in the member loop');
ok($secondUserAbsent, 'the second user is absent from the member loop');


# Check visitor loop ------------------------------------------------------

$allFieldsSet = 1;

foreach (@{$vars->{'visitor_loop'}}) {
#        $allFieldsSet &&= $_->{'ip'} =~ /.*/;  # IP is not set for our test user
    $allFieldsSet &&= $_->{'sessionId'} =~ /.*/;
    $allFieldsSet &&= $_->{'lastActivity'} =~ /.*/;
}

# Check booleans indicating errors
ok($allFieldsSet, 'fields in the visitor loop have been set correctly');


# Test macro parameters ---------------------------------------------------

# Call with zero max limits
$json = WebGUI::Macro::UsersOnline::process($session, $template->getId, undef, 0, 0);
$vars = JSON::from_json($json);
ok(!defined $vars->{'hasMembers'},     'hasMembers undefined when display limit is set to zero');
is(@{$vars->{'member_loop'}}  == 0, 1, 'empty member loop when display limit is set to zero');
is(@{$vars->{'visitor_loop'}} == 0, 1, 'empty visitor loop when display limit is set to zero');

# Call with zero max inactivity time
$json = WebGUI::Macro::UsersOnline::process($session, $template->getId, 0, undef, undef);
$vars = JSON::from_json($json);
ok(!defined $vars->{'hasMembers'},     'hasMembers undefined when max inactivity time is set to zero');
is(@{$vars->{'member_loop'}}  == 0, 1, 'empty member loop when max inactivity time is set to zero');
is(@{$vars->{'visitor_loop'}} == 0, 1, 'empty visitor loop when max inactivity time is set to zero');


sub setupUsers {
    my ($session) = @_;
    my @users;
    my $user;

    # Delete any users from previous tests. This is necessary if the test has
    # failed before.
    $user = WebGUI::User->newByUsername($session, 'tester1');
    $user->delete if defined $user;
    $user = WebGUI::User->newByUsername($session, 'tester2');
    $user->delete if defined $user;

    # Create first user
    $user = WebGUI::User->new($session, 'new');
    $user->username("tester1");
    $user->profileField('showOnline', 1);
    $user->profileField('alias', 'alias1');
    $user->profileField('firstName', 'first1');
    $user->profileField('middleName', 'middle1');
    $user->profileField('lastName', 'last1');
    unshift @users, $user;

    # Create second user
    $user = WebGUI::User->new($session, 'new');
    $user->username("tester2");
    $user->profileField('showOnline', 0);
    $user->profileField('alias', 'alias2');
    $user->profileField('firstName', 'first2');
    $user->profileField('middleName', 'middle2');
    $user->profileField('lastName', 'last2');
    unshift @users, $user;

    # Create sessions such that users are added to the userSession table
    foreach (@users) {
        my $newSession = WebGUI::Session->open(WebGUI::Test::file);
        $newSession->user({user => $_});
    }
    addToCleanup(@users);
    return @users;
}


sub setupJSONtemplate {
    my ($session) = @_;
    my $templateBody = <<EOTMPL;
    {
    "members":<tmpl_var members>,
    "visitors":<tmpl_var visitors>,
    "total":<tmpl_var total>,
    <tmpl_if isVisitor>"isVisitor":<tmpl_var isVisitor>,</tmpl_if>
    <tmpl_if hasMembers>"hasMembers":<tmpl_var hasMembers>,</tmpl_if>
    "usersOnline_label":"<tmpl_var usersOnline_label>",
    "members_label":"<tmpl_var members_label>",
    "visitors_label":"<tmpl_var visitors_label>",
    "total_label":"<tmpl_var total_label>",
    "membersOnline_label":"<tmpl_var membersOnline_label>",
    "visitorsOnline_label":"<tmpl_var visitorsOnline_label>",
    "avatar_label":"<tmpl_var avatar_label>",
    "name_label":"<tmpl_var name_label>",
    "alias_label":"<tmpl_var alias_label>",
    "session_label":"<tmpl_var session_label>",
    "ip_label":"<tmpl_var ip_label>",
    "lastActivity_label":"<tmpl_var lastActivity_label>",
    "member_loop":[
        <tmpl_loop member_loop>
        {
            "username":"<tmpl_var username>",
            "firstName":"<tmpl_var firstName>",
            "middleName":"<tmpl_var middleName>",
            "lastName":"<tmpl_var lastName>",
            "alias":"<tmpl_var alias>",
            "avatar":"<tmpl_var avatar>",
            "uid":"<tmpl_var uid>",
            "sessionId":"<tmpl_var sessionId>",
            "ip":"<tmpl_var ip>",
            "lastActivity":"<tmpl_var lastActivity>"
        }<tmpl_unless __last__>,</tmpl_unless>
        </tmpl_loop>
    ],
    "visitor_loop":[
        <tmpl_loop visitor_loop>
        {
            "sessionId":"<tmpl_var sessionId>",
            "ip":"<tmpl_var ip>",
            "lastActivity":"<tmpl_var lastActivity>"
        }<tmpl_unless __last__>,</tmpl_unless>
        </tmpl_loop>
    ]	
    }
EOTMPL
    my $template = WebGUI::Asset->getImportNode($session)->addChild({className=>'WebGUI::Asset::Template', namespace => 'Macro/UsersOnline', template=>$templateBody});
    addToCleanup($template);
    return $template;
}
