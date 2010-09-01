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

use WebGUI::Test;
use WebGUI::Form::DynamicField;
use WebGUI::Form::SelectList;
use WebGUI::Session;
use Data::Dumper;

#The goal of this test is to verify that all SelectList type Forms
#can be generated directly and via DynamicField

use Test::More; # increment this value for each test you create

##In general, there should be many tests for each form type
#	Object creation, direct
#	Object creation, DynamicField
#	sortByName set for direct
#	sortByName set for dynamic
#	getName set for direct
#	compare output of toHtml from both objects
#	compare output of toHtmlWithWrapper from both objects
my $numTests = 8*14;

my $session = WebGUI::Test->session;

my $i18n = WebGUI::International->new($session);

# put your tests here


plan tests => $numTests;


my ($direct, $dynamic);

$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'SelectList',
	name => 'mySelectList',
	label => 'list of selections',
	options => join("\n", qw(a b c d e f g h)),
	value => join("\n", qw(a e c g)),
	sortByValue => 1,
	multiple => 1,
);
$direct = WebGUI::Form::SelectList->new($session,{
	name => 'mySelectList',
	label => 'list of selections',
	options => { a=>'a', b=>'b', c=>'c', d=>'d', e=>'e', f=>'f', g=>'g', h=>'h', },
	value => [ qw(a c e g) ],
	sortByValue => 1,
	multiple => 1,
});

is(ref $dynamic, "WebGUI::Form::SelectList", 'checking dynamic SelectList');
is(ref $direct, "WebGUI::Form::SelectList", 'checking direct SelectList');
is($direct->getName($session), $i18n->get('484','WebGUI'), 'Check getName');
is($dynamic->get('sortByValue'), 1, 'dynamic CheckList was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct CheckList was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching SelectList output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching SelectList output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'CheckList',
	name => 'myCheckList',
	label => 'list of selections',
	options => join("\n", qw(a b c d e f g h)),
	value => join("\n", qw(a c e g)),
	sortByValue => 1,
);
$direct = WebGUI::Form::CheckList->new($session,{
	name => 'myCheckList',
	label => 'list of selections',
	options => { a=>'a', b=>'b', c=>'c', d=>'d', e=>'e', f=>'f', g=>'g', h=>'h', },
	value => [ qw(a c e g) ],
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::CheckList", 'checking dynamic CheckList');
is(ref $direct, "WebGUI::Form::CheckList", 'checking direct CheckList');
is($direct->getName($session), $i18n->get('941','WebGUI'), 'Check getName');
is($dynamic->get('sortByValue'), 1, 'dynamic CheckList was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct CheckList was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching CheckList output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching CheckList output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching CheckList output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'RadioList',
	name => 'myRadioList',
	label => 'list of selections',
	options => join("\n", qw(a b c d e f g h)),
	value => 'b',
	sortByValue => 1,
);
$direct = WebGUI::Form::RadioList->new($session,{
	name => 'myRadioList',
	label => 'list of selections',
	options => { a=>'a', b=>'b', c=>'c', d=>'d', e=>'e', f=>'f', g=>'g', h=>'h', },
	value => 'b',
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::RadioList", 'checking dynamic RadioList');
is(ref $direct, "WebGUI::Form::RadioList", 'checking direct RadioList');
is($direct->getName($session), $i18n->get('942','WebGUI'), 'Radio getName');
is($dynamic->get('sortByValue'), 1, 'dynamic RadioList was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct RadioList was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching RadioList output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching RadioList output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching RadioList output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'SelectBox',
	name => 'mySelectBox',
	label => 'list of selections',
	options => join("\n", qw(a b c d e f g h)),
	value => 'b',
	sortByValue => 1,
);
$direct = WebGUI::Form::SelectBox->new($session,{
	name => 'mySelectBox',
	label => 'list of selections',
	options => { a=>'a', b=>'b', c=>'c', d=>'d', e=>'e', f=>'f', g=>'g', h=>'h', },
	value => 'b',
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::SelectBox", 'checking dynamic SelectBox');
is(ref $direct, "WebGUI::Form::SelectBox", 'checking direct SelectBox');
is($direct->getName($session), $i18n->get('487','WebGUI'), 'SelectBox getName');
is($dynamic->get('sortByValue'), 1, 'dynamic SelectBox was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct SelectBox was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching SelectBox output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching SelectBox output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching SelectBox output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'HiddenList',
	name => 'myHiddenList',
	label => 'list of groups',
	sortByValue => 1,
);
$direct = WebGUI::Form::HiddenList->new($session,{
	name => 'myHiddenList',
	label => 'list of groups',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::HiddenList", 'checking dynamic HiddenList');
is(ref $direct, "WebGUI::Form::HiddenList", 'checking direct HiddenList');
is($direct->getName($session), $i18n->get('hidden list','WebGUI'), 'HiddenList getName');
is($dynamic->get('sortByValue'), 1, 'dynamic HiddenList was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct HiddenList was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching HiddenList output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching HiddenList output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching HiddenList output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'Group',
	name => 'myGroup',
	label => 'list of groups',
	sortByValue => 1,
);
$direct = WebGUI::Form::Group->new($session,{
	name => 'myGroup',
	label => 'list of groups',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::Group", 'checking dynamic Group');
is(ref $direct, "WebGUI::Form::Group", 'checking direct Group');
is($direct->getName($session), $i18n->get('group','WebGUI'), 'Group getName');
is($dynamic->get('sortByValue'), 1, 'dynamic Group was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct Group was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching Group output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching Group output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching Group output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'Group',
	name => 'myGroup',
	label => 'list of groups',
	sortByValue => 1,
	value => '',
);
$direct = WebGUI::Form::Group->new($session,{
	name => 'myGroup',
	label => 'list of groups',
	sortByValue => 1,
	value => '',
});


is(ref $dynamic, "WebGUI::Form::Group", 'checking dynamic Group');
is(ref $direct, "WebGUI::Form::Group", 'checking direct Group');
is($direct->getName($session), $i18n->get('group','WebGUI'), 'Group getName');
is($dynamic->get('sortByValue'), 1, 'dynamic Group was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct Group was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching Group output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching Group output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching Group output, toHtmlAsHidden");



$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'TimeZone',
	name => 'myTimeZone',
	label => 'list of time zones',
	sortByValue => 1,
);
$direct = WebGUI::Form::TimeZone->new($session,{
	name => 'myTimeZone',
	label => 'list of time zones',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::TimeZone", 'checking dynamic TimeZone');
is(ref $direct, "WebGUI::Form::TimeZone", 'checking direct TimeZone');
is($direct->getName($session), $i18n->get('timezone','DateTime'), 'TimeZone getName');
is($dynamic->get('sortByValue'), 1, 'dynamic TimeZone was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct TimeZone was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching TimeZone output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching TimeZone output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching TimeZone output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'ContentType',
	name => 'myContentType',
	label => 'list of content types',
	sortByValue => 1,
);
$direct = WebGUI::Form::ContentType->new($session,{
	name => 'myContentType',
	label => 'list of content types',
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::ContentType", 'checking dynamic ContentType');
is(ref $direct, "WebGUI::Form::ContentType", 'checking direct ContentType');
is($direct->getName($session), $i18n->get('1007','WebGUI'), 'ContentType getName');
is($dynamic->get('sortByValue'), 1, 'dynamic ContentType was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct ContentType was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching ContentType output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching ContentType output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching ContentType output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'FilterContent',
	name => 'myFilterContent',
	label => 'list of types to filter',
	sortByValue => 1,
);
$direct = WebGUI::Form::FilterContent->new($session,{
	name => 'myFilterContent',
	label => 'list of types to filter',
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::FilterContent", 'checking dynamic FilterContent');
is(ref $direct, "WebGUI::Form::FilterContent", 'checking direct FilterContent');
is($direct->getName($session), $i18n->get('418','WebGUI'), 'FilterContent getName');
is($dynamic->get('sortByValue'), 1, 'dynamic FilterContent was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct FilterContent was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching FilterContent output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching FilterContent output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching FilterContent output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'LdapLink',
	name => 'myLdapLink',
	label => 'list of ldap links',
	sortByValue => 1,
);
$direct = WebGUI::Form::LdapLink->new($session,{
	name => 'myLdapLink',
	label => 'list of ldap links',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::LdapLink", 'checking dynamic LdapLink');
is(ref $direct, "WebGUI::Form::LdapLink", 'checking direct LdapLink');
is($direct->getName($session), $i18n->get("LDAPLink_1075","AuthLDAP"), 'LdapLink getName');
is($dynamic->get('sortByValue'), 1, 'dynamic LdapLink was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct LdapLink was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching LdapLink output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching LdapLink output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching LdapLink output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'Template',
	name => 'myTemplate',
	label => 'list of ldap links',
	sortByValue => 1,
);
$direct = WebGUI::Form::Template->new($session,{
	name => 'myTemplate',
	label => 'list of ldap links',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::Template", 'checking dynamic Template');
is(ref $direct, "WebGUI::Form::Template", 'checking direct Template');
is($direct->getName($session), $i18n->get("assetName","Asset_Template"), 'Template getName');
is($dynamic->get('sortByValue'), 1, 'dynamic Template was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct Template was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching Template output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching Template output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching Template output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'WhatNext',
	name => 'myWhatNext',
	label => 'list of what to do next',
	sortByValue => 1,
);
$direct = WebGUI::Form::WhatNext->new($session,{
	name => 'myWhatNext',
	label => 'list of what to do next',
	sortByValue => 1,
});


is(ref $dynamic, "WebGUI::Form::WhatNext", 'checking dynamic WhatNext');
is(ref $direct, "WebGUI::Form::WhatNext", 'checking direct WhatNext');
is($direct->getName($session), $i18n->get('744','WebGUI'), 'WhatNext getName');
is($dynamic->get('sortByValue'), 1, 'dynamic WhatNext was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct WhatNext was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching WhatNext output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching WhatNext output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching WhatNext output, toHtmlAsHidden");


$dynamic = WebGUI::Form::DynamicField->new(
	$session,
	fieldType => 'DatabaseLink',
	name => 'myDatabaseLink',
	label => 'list of databases',
	sortByValue => 1,
);
$direct = WebGUI::Form::DatabaseLink->new($session,{
	name => 'myDatabaseLink',
	label => 'list of databases',
	sortByValue => 1,
});

is(ref $dynamic, "WebGUI::Form::DatabaseLink", 'checking dynamic DatabaseLink');
is(ref $direct, "WebGUI::Form::DatabaseLink", 'checking direct DatabaseLink');
is($direct->getName($session), $i18n->get('1075','WebGUI'), 'DatabaseLink getName');
is($dynamic->get('sortByValue'), 1, 'dynamic DatabaseLink was assigned sortByValue');
is($direct->get('sortByValue'), 1, 'direct DatabaseLink was assigned sortByValue');
is($dynamic->toHtml, $direct->toHtml, "matching DatabaseLink output, toHtml");
is($dynamic->toHtmlWithWrapper, $direct->toHtmlWithWrapper, "matching DatabaseLink output, toHtmlWithWrapper");
is($dynamic->toHtmlAsHidden, $direct->toHtmlAsHidden, "matching DatabaseLink output, toHtmlAsHidden");
