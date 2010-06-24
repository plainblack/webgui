package WebGUI::Content::Setup;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Digest::MD5;
use WebGUI::Asset;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::VersionTag;
use WebGUI::Operation::Statistics;

=head1 NAME

Package WebGUI::Setup

=head1 DESCRIPTION

Initializes a new WebGUI install.

=head1 SYNOPSIS

 use WebGUI::Setup;
 WebGUI::Content::Setup::handler();

=head1 SUBROUTINES

These subroutines are available from this package:

=cut




#-------------------------------------------------------------------

=head2 addAsset ( parent, properties ) 

A helper to add assets with less code.

=head3 parent

The parent asset to add to.

=head3 properties

A hash ref of properties to attach to the asset. One must be className.

=cut

sub addAsset {
    my $parent = shift;
    my $properties = shift;
    $properties->{url} = $parent->get("url")."/".$properties->{title};
    $properties->{groupIdEdit} = $parent->get("groupIdEdit");
    $properties->{groupIdView} = $parent->get("groupIdView");
    $properties->{ownerUserId} = $parent->get("ownerUserId");
    $properties->{styleTemplateId} = $parent->get("styleTemplateId");
    $properties->{printableStyleTemplateId} = $parent->get("styleTemplateId");
    return $parent->addChild($properties);
}



#-------------------------------------------------------------------

=head2 addPage ( parent, title ) 

Adds a page to a parent page.

=head3 parent

A parent page asset.

=head3 title

The title of the new page.

=cut

sub addPage {
    my $parent = shift;
    my $title = shift;
    return addAsset($parent, {title=>$title, className => "WebGUI::Asset::Wobject::Layout", displayTitle=>0});
}

#-------------------------------------------------------------------

=head2 handler ( session )

Handles a specialState: "init"

=head3 session

The current WebGUI::Session object.

=cut

sub handler {
	my $session = shift;
    my $form    = $session->form;
    unless ($session->setting->get("specialState") eq "init") {
        return undef;
    }
	$session->http->setCacheControl("none");
	my $i18n = WebGUI::International->new($session, "WebGUI");
    my ($output,$legend) = "";
	if ($form->process("step") eq "2") {
		$legend = $i18n->get('company information');

        my $timezone = $form->timeZone("timeZone");
        my $language = $form->selectBox("language");

        ##update Admin and Visitor users
		my $u = WebGUI::User->new($session,"3");
		$u->username($form->process("username","text","Admin"));
		$u->profileField("email",$form->email("email"));
		$u->profileField("timeZone",$timezone);
		$u->profileField("language",$language);
		$u->identifier(Digest::MD5::md5_base64($form->process("identifier","password","123qwe")));

		$u = WebGUI::User->new($session,"1");
		$u->profileField("timeZone",$timezone);
		$u->profileField("language",$language);

        ##update ProfileField defaults so new users the get the defaults, too
        my $properties;

        my $zoneField     = WebGUI::ProfileField->new($session, 'timeZone');
        $properties       = $zoneField->get();
        $properties->{dataDefault} = $timezone;
        $zoneField->set($properties);

        my $languageField = WebGUI::ProfileField->new($session, 'language');
        $properties       = $languageField->get();
        $properties->{dataDefault} = $language;
        $languageField->set($properties);

		my $f = WebGUI::HTMLForm->new($session,action=>$session->url->gateway());
		$f->hidden( name=>"step", value=>"3");
		$f->text(
			name=>"companyName",
			value=>$session->setting->get("companyName"),
			label=>$i18n->get(125),
			hoverHelp=>$i18n->get('125 description'),
			);
		$f->email(
			name=>"companyEmail",
			value=>$session->setting->get("companyEmail"),
			label=>$i18n->get(126),
			hoverHelp=>$i18n->get('126 description'),
			);
		$f->url(
			name=>"companyURL",
			value=>$session->setting->get("companyURL"),
			label=>$i18n->get(127),
			hoverHelp=>$i18n->get('127 description'),
			);
		$f->submit;
		$output .= $f->print;
	} 
    elsif ($session->form->process("step") eq "3") {
        my $form = $session->form;
		$session->setting->set('companyName',$form->text("companyName")) if ($form->get("companyName"));
		$session->setting->set('companyURL',$form->url("companyURL")) if ($form->get("companyURL"));
		$session->setting->set('companyEmail',$form->email("companyEmail")) if ($form->get("companyEmail"));
        $legend = $i18n->get('topicName','Activity_SendWebguiStats');
        $output .= ' <p>'.$i18n->get('why to send','Activity_SendWebguiStats').'</p>
             <p>'.$i18n->get('would you participate','Activity_SendWebguiStats').'</p>
            <p><a href="'.$session->url->gateway(undef, "step=sitestarter").'">'.$i18n->get('disable','Activity_SendWebguiStats').'</a> &nbsp; &nbsp; &nbsp;
                <a href="'.$session->url->gateway(undef,"step=sitestarter;enableStats=1").'">'.$i18n->get('enable','Activity_SendWebguiStats').'</a></p>
            ';
	} 
    elsif ($session->form->process("step") eq "sitestarter") {
        my $form = $session->form;
        WebGUI::Operation::Statistics::www_enableSendWebguiStats($session) if ($form->get("enableStats"));
        $legend = $i18n->get('site starter title');
        $output .= ' <p>'.$i18n->get('site starter body').'</p>
            <p><a href="'.$session->url->gateway(undef, "step=7").'">'.$i18n->get('no thanks').'</a> &nbsp; &nbsp; &nbsp;
                <a href="'.$session->url->gateway(undef,"step=4").'">'.$i18n->get('yes please').'</a></p>
            ';
	} 
    elsif ($session->form->process("step") eq "4") {
		my $f = WebGUI::HTMLForm->new($session,action=>$session->url->gateway());
		$f->hidden( name=>"step", value=>"5",);
		$f->file(name=>"logo", label=>$i18n->get('logo'));
		$f->submit;
        $legend = $i18n->get('upload logo');
		$output .= $f->print;
	} 
    elsif ($session->form->process("step") eq "5") {
        my $storageId = $session->form->process("logo","image");
        my $url = $session->url;
        my $logoUrl = $url->extras("plainblack.gif");
        if (defined $storageId) {
            my $storage = WebGUI::Storage->get($session, $storageId);
            my $importNode = WebGUI::Asset->getImportNode($session);
            my $logo = addAsset($importNode, {
                title       => $storage->getFiles->[0],
                filename    => $storage->getFiles->[0],
                isHidden    => 1,
                storageId   => $storageId,
                className   => "WebGUI::Asset::File::Image",
                parameters  => 'alt="'.$storage->getFiles->[0].'"'
                });
            $logoUrl = $logo->getStorageLocation->getUrl($logo->get("filename"));
        }
        my $style = $session->style;
        $style->setLink($url->extras('/yui/build/container/assets/skins/sam/container.css'),{ type=>'text/css', rel=>"stylesheet" });
        $style->setLink($url->extras('/yui/build/colorpicker/assets/skins/sam/colorpicker.css'),{ type=>'text/css', rel=>"stylesheet" });
        $style->setScript($url->extras('/yui/build/yahoo/yahoo-min.js'));
        $style->setScript($url->extras('/yui/build/event/event-min.js'));
        $style->setScript($url->extras('/yui/build/dom/dom-min.js'));
        $style->setScript($url->extras('/yui/build/dragdrop/dragdrop-min.js'));
        $style->setScript($url->extras('/yui/build/utilities/utilities.js'));
        $style->setScript($url->extras('/yui/build/container/container-min.js'));
        $style->setScript($url->extras('/yui/build/slider/slider-min.js'));
        $style->setScript($url->extras('/yui/build/colorpicker/colorpicker-min.js'));
        $style->setLink($url->extras('/colorpicker/colorpicker.css'),{ type=>'text/css', rel=>"stylesheet" });
        $style->setScript($url->extras('/colorpicker/colorpicker.js'));
        $style->setScript($url->extras("/styleDesigner/styleDesigner.js"));
        $style->setLink($url->extras("/styleDesigner/styleDesigner.css"), {rel=>"stylesheet", type=>"text/css"});
        $legend = $i18n->get("style designer");
        $output .= '
            <form method="post">
            <input type="submit" value="'.$i18n->get('save').'">
            <input type="hidden" name="step" value="6" />
            <input type="hidden" name="logoUrl" value="'.$logoUrl.'" />
            <script type="text/javascript">
            document.write(WebguiStyleDesigner.draw("^c;","'.$logoUrl.'","'.$storageId.'"));
            </script>
            <input type="submit" value="'.$i18n->get('save').'">
            </form>
            ';
	} 
    elsif ($session->form->process("step") eq "6") {
            my $importNode = WebGUI::Asset->getImportNode($session);
            my $form = $session->form;
            my $snippet = '/* auto generated by WebGUI '.$WebGUI::VERSION.' */
.clearFloat { clear: both; }
body { background-color: '.$form->get("pageBackgroundColor").'; color: '.$form->get("contentTextColor").'}
a { color: '.$form->get("linkColor").';}
a:visited { color: '.$form->get("visitedLinkColor").'; }
#editToggleContainer { padding: 1px; }
#utilityLinksContainer { float: right; padding: 1px; }
#pageUtilityContainer { font-size: 9pt; background-color: '.$form->get("utilityBackgroundColor").'; color: '.$form->get("utilityTextColor").'; }
#pageHeaderContainer { background-color: '.$form->get("headerBackgroundColor").'; color: '.$form->get("headerTextColor").'; }
#pageHeaderLogoContainer { float: left; padding: 5px; background-color: '.$form->get("headerBackgroundColor").';}
#logo { border: 0px; max-width: 300px; }
#companyNameContainer { float: right; padding: 5px; font-size: 16pt; }
#pageBodyContainer { background-color: '.$form->get("contentBackgroundColor").'; color: '.$form->get("contentTextColor").'; }
#mainNavigationContainer { min-height: 300px; padding: 5px; float: left; width: 180px; font-size: 10pt; background-color: '.$form->get("navigationBackgroundColor").'; }
#mainNavigationContainer A, #mainNavigationContainer A:link { color: '.$form->get("navigationTextColor").'; }
#mainBodyContentContainer { padding: 5px; margin-left: 200px; font-family: serif, times new roman; font-size: 12pt; overflow: auto; }
#pageFooterContainer { text-align: center; background-color: '.$form->get("footerBackgroundColor").'; color: '.$form->get("footerTextColor").'; }
#copyrightContainer { font-size: 8pt; }
#pageWidthContainer { width: 80%; margin-left: auto; margin-right: auto; font-family: sans-serif, helvetica, arial; border: 3px solid black; }
';
           my $css = addAsset($importNode, {
                title       => "my-style.css",
                className   => "WebGUI::Asset::Snippet",
                snippet     => $snippet,
                isHidden    => 1,
                mimeType    => "text/css",
                });
    my $styleTemplate = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>^Page(title); - ^c;</title>
<link type="text/css" href="'.$css->getUrl.'" rel="stylesheet" />
<tmpl_var head.tags>
</head>
<body>
^AdminBar;
<div id="pageWidthContainer">
    <div id="pageUtilityContainer">
        <div id="utilityLinksContainer">^a(^@;); :: ^LoginToggle; :: ^r(Print!);</div>
        <div id="editToggleContainer">^AdminToggle;</div>
        <div class="clearFloat"></div>
    </div>
    <div id="pageHeaderContainer">
        <div id="companyNameContainer">^c;</div>
        <div id="pageHeaderLogoContainer"><a href="^H(linkonly);"><img src="'.$form->get("logoUrl").'" id="logo" alt="logo" /></a></div>
        <div class="clearFloat"></div>
    </div>
    <div id="pageBodyContainer">
        <div id="mainNavigationContainer"><p>^AssetProxy("flexmenu");</p></div>
        <div id="mainBodyContentContainer">
        <tmpl_var body.content>
        </div>
        <div class="clearFloat"></div>
    </div>
    <div id="pageFooterContainer">
        <div id="copyrightContainer">&copy;^D(%y); ^c;. ^International(All Rights Reserved);.</div>
        <div class="clearFloat"></div>
    </div>
</div>



</body>
</html>';
        my $style = addAsset($importNode, {
                className   => "WebGUI::Asset::Template",
                title       => $i18n->get("My Style"),
                isHidden    => 1,
                namespace   => "style",
                template    => $styleTemplate
            });
        $session->setting->set("userFunctionStyleId",$style->getId);

        # collect new page info
        my $f = WebGUI::HTMLForm->new($session,action=>$session->url->gateway());
        $f->hidden(name=>"step", value=>"7");
        $f->hidden(name=>"styleTemplateId", value=>$style->getId);
        $f->yesNo(name=>"contactUs",label=>$i18n->get('Contact Us'));
        $f->yesNo(name=>"calendar",label=>$i18n->get("assetName", 'Asset_Calendar'));
        $f->yesNo(name=>"wiki",label=>$i18n->get('assetName', 'Asset_WikiMaster'));
        $f->yesNo(name=>"search",label=>$i18n->get("assetName", 'Asset_Search'));
        $f->yesNo(name=>"aboutUs",label=>$i18n->get("About Us"));
        $f->HTMLArea(name=>"aboutUsContent", richEditId=>"PBrichedit000000000002", 
            value=>$i18n->get("Put your about us content here."));
        if (exists $session->config->get('assets')->{"WebGUI::Asset::Wobject::Collaboration"}) {
            $f->yesNo(name=>"news",label=>$i18n->get(357));
            $f->yesNo(name=>"forums",label=>$i18n->get("Forums"));
            $f->textarea(name=>"forumNames",subtext=>$i18n->get("One forum name per line"), 
                value=>$i18n->get("Support")."\n".$i18n->get("General Discussion"));
        }
        $f->submit;
        $legend = $i18n->get("Initial Pages");
        $output .= $f->print;
	} 
    elsif ($session->form->process("step") eq "7") {
        my $home = WebGUI::Asset->getDefault($session);
        my $form = $session->form;

        # update default site style
        foreach my $asset (@{$home->getLineage(["self","descendants"], {returnObjects=>1})}) {
            if (defined $asset) {
                  $asset->update({styleTemplateId=>$form->get("styleTemplateId")});
            }
        }

        # add new pages
        if ($form->get("aboutUs")) {
            my $page = addPage($home, $i18n->get("About Us"));
            addAsset($page, {
                title               => $i18n->get("About Us"),
                isHidden            => 1,
                className           => "WebGUI::Asset::Wobject::Article",
                description         => $form->get("aboutUsContent"),
                });
        }

        # add forums
        if ($form->get("forums")) {
            my $page = addPage($home, $i18n->get("Forums"));
            my $board = addAsset($page, {
                title               => $i18n->get("Forums"),
                isHidden            => 1,
                className           => "WebGUI::Asset::Wobject::MessageBoard",
                description         => $i18n->get("Discuss your ideas and get help from our community."),
                });
            my $forumNames = $form->get("forumNames");
            $forumNames =~ s/\r//g;
            foreach my $forumName (split "\n", $forumNames) {
                next if $forumName eq "";
                addAsset($board, {
                    title       => $forumName,
                    isHidden    => 1, 
                    className   => "WebGUI::Asset::Wobject::Collaboration"
                    });
            }
        }

        # add news 
        if ($form->get("news")) {
            my $page = addPage($home, $i18n->get(357));
            addAsset($page, {
                title                   => $i18n->get(357),
                isHidden                => 1,
                className               => "WebGUI::Asset::Wobject::Collaboration",
                collaborationTemplateId => "PBtmpl0000000000000112",
                allowReplies            => 0,
                attachmentsPerPost      => 5,
                postFormTemplateId      => "PBtmpl0000000000000068",
                threadTemplateId        => "PBtmpl0000000000000067",
                description             => $i18n->get("All the news you need to know."),
                });
        }

        # add wiki
        if ($form->get("wiki")) {
            my $page = addPage($home, $i18n->get("assetName", 'Asset_WikiMaster'));
            addAsset($page, {
                title               => $i18n->get("assetName", 'Asset_WikiMaster'),
                isHidden            => 1,
                allowAttachments    => 5,
                className           => "WebGUI::Asset::Wobject::WikiMaster",
                description         => $i18n->get("Welcome to our wiki. Here you can help us keep information up to date."),
                });
        }

        # add calendar
        if ($form->get("calendar")) {
            my $page = addPage($home, $i18n->get('assetName', "Asset_Calendar"));
            addAsset($page, {
                title               => $i18n->get('assetName', "Asset_Calendar"),
                isHidden            => 1,
                className           => "WebGUI::Asset::Wobject::Calendar",
                description         => $i18n->get("Check out what is going on."),
                });
        }

        # add contact us
        if ($form->get("contactUs")) {
            my $page = addPage($home, $i18n->get("Contact Us"));
            my $i18n2 = WebGUI::International->new($session, "Asset_DataForm");
            my @fieldConfig = (
                {
                    name=>"from",
                    label=>$i18n2->get("Your Email Address", 'WebGUI'),
                    status=>"required",
                    isMailField=>1,
                    width=>0,
                    type=>"email",
                },
                {
                    name=>"to",
                    label=>$i18n2->get(11),
                    status=>"hidden",
                    isMailField=>1,
                    width=>0,
                    type=>"email",
                    defaultValue=>$session->setting->get("companyEmail"),
                },
                {
                    name=>"cc",
                    label=>$i18n2->get(12),
                    status=>"hidden",
                    isMailField=>1,
                    width=>0,
                    type=>"email",
                },
                {
                    name=>"bcc",
                    label=>$i18n2->get(13),
                    status=>"hidden",
                    isMailField=>1,
                    width=>0,
                    type=>"email",
                },
                {
                    name=>"subject",
                    label=>$i18n2->get(14),
                    status=>"hidden",
                    isMailField=>1,
                    width=>0,
                    type=>"text",
                    defaultValue=>$i18n->get(2),
                },
                {
                    name                => "comments",
                    label               => $i18n->get("comments", 'VersionTag'),
                    status              => "required",
                    type                => "textarea",
                    subtext             => $i18n->get("Tell us how we can assist you."),
                },
            );
            my $dataForm = addAsset($page, {
                title               => $i18n->get("Contact Us"),
                isHidden            => 1,
                className           => "WebGUI::Asset::Wobject::DataForm",
                description         => $i18n->get("We welcome your feedback."),
                acknowledgement     => $i18n->get("Thanks for for your interest in ^c;. We will review your message shortly."),
                mailData            => 1,
                fieldConfiguration  => JSON::to_json(\@fieldConfig),
                });
        }

        # add search
        if ($form->get("search")) {
            my $page = addPage($home, $i18n->get('assetName',"Asset_Search"));
            addAsset($page, {
                title               => $i18n->get('assetName',"Asset_Search"),
                isHidden            => 1,
                className           => "WebGUI::Asset::Wobject::Search",
                description         => $i18n->get("Cannot find what you are looking for? Try our search."),
                searchRoot          => $home->getId,
                });
        }

        # commit the working tag
        my $working = WebGUI::VersionTag->getWorking($session);
        $working->set({name=>"Initial Site Setup"});
        $working->commit;

        # remove init state
		$session->setting->remove('specialState');
		$session->http->setRedirect($session->url->gateway("?setup=complete"));
		return undef;
	} 
    else {
        $legend = $i18n->get('admin account');
		my $u = WebGUI::User->new($session,'3');
		my $f = WebGUI::HTMLForm->new($session,action=>$session->url->gateway());
		$f->hidden( -name=>"step", -value=>"2");
		$f->text(
			-name=>"username",
			-value=>$u->username,
			-label=>$i18n->get(50),
			-hoverHelp=>$i18n->get('50 setup description'),
			);
		$f->text(
			-name=>"identifier",
			-value=>"123qwe",
			-label=>$i18n->get(51),
			-hoverHelp=>$i18n->get('51 description'),
			-subtext=>'<div style=\"font-size: 10px;\">('.$i18n->get("password clear text").')</div>'
			);
		$f->email(
			-name=>"email",
			-value=>$u->profileField("email"),
			-label=>$i18n->get(56),
			-hoverHelp=>$i18n->get('56 description'),
			);
		$f->timeZone(
			-name      => "timeZone",
			-value     => $u->profileField("timeZone"),
			-label     => $i18n->get('timezone','DateTime'),
			-hoverHelp => $i18n->get('timezone help'),
			);
		$f->selectBox(
			-name      => "language",
			-value     => $u->profileField("language"),
			-label     => $i18n->get('304'),
			-hoverHelp => $i18n->get('language help'),
            -options   => $i18n->getLanguages(),
			);
		$f->submit;
		$output .= $f->print; 
	}
	my $page  = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>'.$i18n->get('WebGUI Initial Configuration').' :: '.$legend.'</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript">
function getWebguiProperty (propName) {
var props = new Array();
props["extrasURL"] = "'.$session->url->extras().'";
props["pageURL"] = "'.$session->url->page(undef, undef, 1).'";
return props[propName];
}
</script>'. $session->style->generateAdditionalHeadTags .'
		<style type="text/css">';
    if ($session->form->process("step") != 5) {
        $page .= ' #initBox {
            font-family: georgia, helvetica, arial, sans-serif; color: white; z-index: 10; 
            top: 5%; left: 10%; position: absolute;
            }
            #initBoxSleeve {
                width: 770px;
                height: 475px;
            }
		a { color: black; }
		a:visited { color: black;}
        body { margin: 0; }
            ';
    }
    else {
        $page .= '
            #initBox {
                font-family: georgia, helvetica, arial, sans-serif; color: white; z-index: 10; width: 98%; 
                 height: 98%; top: 10; left: 10; position: absolute;
        }
        ';
    }
    $page .= ' </style> </head> <body> 
            <div id="initBox"><h1>'.$legend.'</h1><div id="initBoxSleeve"> '.$output.'</div></div>
         <img src="'.$session->url->extras('background.jpg').'" style="border-style:none;position: absolute; top: 0; left: 0; width: 100%; height: 1000px; z-index: 1;" />
	</body> </html>';
	$session->http->setMimeType("text/html");
    return $page;
}

1;

