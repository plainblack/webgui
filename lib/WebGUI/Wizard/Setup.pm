package WebGUI::Wizard::Setup;

use strict;
use base 'WebGUI::Wizard';

=head1 NAME

WebGUI::Wizard::Setup -- Initial site setup

=cut


sub _get_steps {
    return [qw(
        adminAccount
        companyInformation
        siteStats
        defaultStyle
        finalize
    )];
}

sub wrapStyle {
    my ( $self, $output ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->http->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );
    my $page = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>' . $i18n->get('WebGUI Initial Configuration') . '</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script type="text/javascript">
        function getWebguiProperty (propName) {
            var props = new Array();
            props["extrasURL"] = "' . $session->url->extras() . '";
            props["pageURL"] = "' . $session->url->page( undef, undef, 1 ) . '";
            return props[propName];
        }
    </script>
' . $session->style->generateAdditionalHeadTags . '
    <style type="text/css">
body {
    margin-top:     120px;
    margin-left:    5%;
    margin-right:   5%;
    background-color:   #ccf;
}

h1 { 
    position: absolute; 
    top: 10px;
    padding: 0;
    margin: 0;
    padding-left: 120px; 

    background: url(' . $session->url->extras('wg.gif') . ') no-repeat;
    line-height: 100px;
}

#wrapper {
    background-color: white;
    border: 1px solid black;
    padding: 10px;
}

.stylePicker img {
    margin: 1em 0;
    float: right;
}
.stylePicker {
    overflow: hidden;
    clear: both;
}
.stylePicker.odd {
    background-color: #eee;
}
.stylePicker input {
    float: left;
}
.stylePicker .title {
    font-size: larger;
}

    </style>
</head>
<body><div id="wrapper"> ' . $output . ' </div></body>
</html>';
    $session->http->setMimeType("text/html");
    return $page;
}


sub www_adminAccount {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->http->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $legend = $i18n->get('admin account');
    my $u = WebGUI::User->new( $session, '3' );
    my $f = $self->getForm;
    $f->text(
        -name      => "username",
        -value     => $u->username,
        -label     => $i18n->get(50),
        -hoverHelp => $i18n->get('50 setup description'),
    );
    $f->text(
        -name      => "identifier",
        -value     => "123qwe",
        -label     => $i18n->get(51),
        -hoverHelp => $i18n->get('51 description'),
        -subtext   => '<div style=\"font-size: 10px;\">(' . $i18n->get("password clear text") . ')</div>'
    );
    $f->email(
        -name      => "email",
        -value     => $u->profileField("email"),
        -label     => $i18n->get(56),
        -hoverHelp => $i18n->get('56 description'),
    );
    $f->timeZone(
        -name      => "timeZone",
        -value     => $u->profileField("timeZone"),
        -label     => $i18n->get( 'timezone', 'DateTime' ),
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
    return '<h1>' . $legend . '</h1>' . $f->print;
}

sub www_adminAccountSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;

    my $timezone = $form->timeZone("timeZone");
    my $language = $form->selectBox("language");

    ##update Admin and Visitor users
    my $u = WebGUI::User->new( $session, "3" );
    $u->username( $form->process( "username", "text", "Admin" ) );
    $u->profileField( "email",    $form->email("email") );
    $u->profileField( "timeZone", $timezone );
    $u->profileField( "language", $language );
    $u->identifier( Digest::MD5::md5_base64( $form->process( "identifier", "password", "123qwe" ) ) );

    $u = WebGUI::User->new( $session, "1" );
    $u->profileField( "timeZone", $timezone );
    $u->profileField( "language", $language );

    ##update ProfileField defaults so new users the get the defaults, too
    my $properties;

    my $zoneField = WebGUI::ProfileField->new( $session, 'timeZone' );
    $properties = $zoneField->get();
    $properties->{dataDefault} = $timezone;
    $zoneField->set($properties);

    my $languageField = WebGUI::ProfileField->new( $session, 'language' );
    $properties = $languageField->get();
    $properties->{dataDefault} = $language;
    $languageField->set($properties);

    return;
}

sub www_companyInformation {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->http->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $output = '<h1>' . $i18n->get('company information') . '</h1>';

    my $f = $self->getForm;
    $f->hidden( name => "step", value => "3" );
    $f->text(
        name      => "companyName",
        value     => $session->setting->get("companyName"),
        label     => $i18n->get(125),
        hoverHelp => $i18n->get('125 description'),
    );
    $f->email(
        name      => "companyEmail",
        value     => $session->setting->get("companyEmail"),
        label     => $i18n->get(126),
        hoverHelp => $i18n->get('126 description'),
    );
    $f->url(
        name      => "companyURL",
        value     => $session->setting->get("companyURL"),
        label     => $i18n->get(127),
        hoverHelp => $i18n->get('127 description'),
    );
    $f->submit;
    $output .= $f->print;

    return $output;
}

sub www_companyInformationSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form = $session->form;
    $session->setting->set( 'companyName',  $form->text("companyName") )   if ( $form->get("companyName") );
    $session->setting->set( 'companyURL',   $form->url("companyURL") )     if ( $form->get("companyURL") );
    $session->setting->set( 'companyEmail', $form->email("companyEmail") ) if ( $form->get("companyEmail") );
    return;
}

sub www_siteStats {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->http->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $enableForm  = $self->getForm;
    $enableForm->hidden( name => "enableStats", value => 1 );
    $enableForm->submit( value => $i18n->get( 'enable', 'Activity_SendWebguiStats' ) );

    my $disableForm = $self->getForm;
    $disableForm->hidden( name => "enableStats", value => 0 );
    $disableForm->submit( value => $i18n->get( 'disable', 'Activity_SendWebguiStats' ) );

    my $output = '<h1>' . $i18n->get( 'topicName', 'Activity_SendWebguiStats' ) . '</h1>';
    $output .= ' <p>' . $i18n->get( 'why to send', 'Activity_SendWebguiStats' ) . '</p>
         <p>' . $i18n->get( 'would you participate', 'Activity_SendWebguiStats' ) . '</p>
        <div style="float: left">' . $enableForm->print . '</div><div style="float: left">'
        . $disableForm->print
        . '</div>'
        . '<div style="clear: both;">&nbsp;</div>'
        ;

    return $output;
}

sub www_siteStatsSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    WebGUI::Operation::Statistics::www_enableSendWebguiStats($session) if ( $form->get("enableStats") );
    return;
}

sub www_defaultStyle {
    return WebGUI::Wizard::HomePage::www_pickStyle( @_ );
}

sub www_defaultStyleSave {
    my ( $self, @args ) = @_;
    my $output = WebGUI::Wizard::HomePage::www_pickStyleSave( $self, @args );
    my $session = $self->session;
    # update default site style
    $session->setting->set( "userFunctionStyleId", $self->get('styleTemplateId') );
    my $home    = WebGUI::Asset->getDefault( $session );
    foreach my $asset ( @{ $home->getLineage( [ "self", "descendants" ], { returnObjects => 1 } ) } ) {
        if ( defined $asset ) {
            $asset->update( { styleTemplateId => $self->get("styleTemplateId") } );
        }
    }

    return $output;
}

sub www_finalize {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->http->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    # Delete specialState
    $session->setting->remove( "specialState" );

    my $starterForm  = WebGUI::HTMLForm->new( $session );
    $starterForm->hidden( name => "op", value => "wizard" );
    $starterForm->hidden( name => "wizard_class", value => "WebGUI::Wizard::HomePage" );
    $starterForm->hidden( name => "wizard_step", value => "pickStyle" );
    $starterForm->hidden( name => "initialSetup", value => 1 );
    $starterForm->hidden( name => "styleTemplateId", value => $self->get('styleTemplateId') );
    $starterForm->submit( value => $i18n->get( 'yes please' ) );

    my $finishForm  = $self->getForm;
    $finishForm->hidden( name => "runStarter", value => 0 );
    $finishForm->submit( value => $i18n->get( 'no thanks' ) );

    my $output = '<h1>' . $i18n->get('site starter title') . '</h1>';
    $output .= ' <p>' . $i18n->get('site starter body') . '</p>'
        . '<div style="float: left">' . $starterForm->print . '</div>'
        . '<div style="float: left">' . $finishForm->print . '</div>'
        . '<div style="clear: both">&nbsp;</div>'
        ;

    return $output;
}

sub www_finalizeSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form ) = $session->quick(qw( form ));

    $session->http->setRedirect( $session->url->gateway );
}

1;
