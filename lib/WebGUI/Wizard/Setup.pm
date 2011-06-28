package WebGUI::Wizard::Setup;

use strict;
use base 'WebGUI::Wizard';

use WebGUI::Wizard::HomePage;

=head1 NAME

WebGUI::Wizard::Setup -- Initial site setup

=head1 DESCRIPTION

A WebGUI::Wizard to perform initial site setup tasks like defining the Admin 
account, entering basic information, and choosing a default style.

=head1 METHODS

=cut

sub _get_steps {
    return [qw(
        adminAccount
        companyInformation
        siteStats
        defaultStyle
    )];
}

#----------------------------------------------------------------------------

=head2 canView ( ) 

A user can view this wizard if the site is newly created or if they are the
admin user

=cut

sub canView {
    my ( $self ) = @_;
    my $session = $self->session;

    # Only specialState="init" or admin user
    return $session->setting->get('specialState') eq 'init' 
        || $session->user->getId eq '3';
}

#----------------------------------------------------------------------------

=head2 wrapStyle ( $output ) 

Wrap the output in the wizard style.

=cut

sub wrapStyle {
    my ( $self, $output ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->response->setCacheControl("none");
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
    background-color:   #1e78f2;
}

h1 {
    position: absolute; 
    top: 10px;
    padding: 0;
    margin: 0;
    padding-left: 120px; 

    background: url(' . $session->url->extras('wg.png') . ') no-repeat;
    line-height: 100px;
}

#wrapper {
    background-color: white;
    border: 1px solid black;
    padding: 10px;
}

/* From asset www_edit */
* { font: 12pt Helvetica, sans-serif; }
label.formDescription { display: block; margin-top: 1em; font-weight: bold }
/* End from asset www_edit */

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
    $session->response->content_type("text/html");
    return $page;
}

#----------------------------------------------------------------------------

=head2 www_adminAccount ( ) 

Display the form to configure the admin account

=cut

sub www_adminAccount {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->response->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $legend = $i18n->get('admin account');
    my $u = WebGUI::User->new( $session, '3' );
    my $f = $self->getForm;
    $f->addField( "text",
        name      => "username",
        value     => $u->username,
        label     => $i18n->get(50),
        hoverHelp => $i18n->get('50 setup description'),
    );
    $f->addField( "text",
        name      => "identifier",
        value     => "123qwe",
        label     => $i18n->get(51),
        hoverHelp => $i18n->get('51 description'),
        subtext   => '<div style=\"font-size: 10px;\">(' . $i18n->get("password clear text") . ')</div>'
    );
    $f->addField( "email",
        name      => "email",
        value     => $u->get("email"),
        label     => $i18n->get(56),
        hoverHelp => $i18n->get('56 description'),
    );
    $f->addField( "timeZone",
        name      => "timeZone",
        value     => $u->get("timeZone"),
        label     => $i18n->get( 'timezone', 'DateTime' ),
        hoverHelp => $i18n->get('timezone help'),
    );
    $f->addField( "selectBox",
        name      => "language",
        value     => $u->get("language"),
        label     => $i18n->get('304'),
        hoverHelp => $i18n->get('language help'),
        options   => $i18n->getLanguages(),
    );
    $f->addField( "submit", name => "send" );
    return '<h1>' . $legend . '</h1>' . $f->toHtml;
}

#----------------------------------------------------------------------------

=head2 www_adminAccountSave ( ) 

Process the form and update the Admin account

=cut

sub www_adminAccountSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;

    my $timezone = $form->timeZone("timeZone");
    my $language = $form->selectBox("language");
    my $email    = $form->email('email');

    ##update Admin and Visitor users
    my $u = WebGUI::User->new( $session, "3" );
    $u->username( $form->process( "username", "text", "Admin" ) );
    $u->update( email     =>    $email,
        timeZone  =>  $timezone, 
        language  =>  $language, 
    );
    $u->identifier( Digest::MD5::md5_base64( $form->process( "identifier", "password", "123qwe" ) ) );
    # The user is now Admin
    $session->user({ userId => "3" });

    $u = WebGUI::User->new( $session, "1" );
    $u->update(
        timeZone => $timezone,
        language => $language,
    );

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

#----------------------------------------------------------------------------

=head2 www_companyInformation ( ) 

Enter basic company information

=cut

sub www_companyInformation {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->response->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $output = '<h1>' . $i18n->get('company information') . '</h1>';

    my $f = $self->getForm;
    $f->addField( "text",
        name      => "companyName",
        value     => $session->setting->get("companyName"),
        label     => $i18n->get(125),
        hoverHelp => $i18n->get('125 description'),
    );
    $f->addField( "email",
        name      => "companyEmail",
        value     => $session->setting->get("companyEmail"),
        label     => $i18n->get(126),
        hoverHelp => $i18n->get('126 description'),
    );
    $f->addField( "url",
        name      => "companyURL",
        value     => $session->setting->get("companyURL"),
        label     => $i18n->get(127),
        hoverHelp => $i18n->get('127 description'),
    );
    $f->addField( "submit", name => "send" );
    $output .= $f->toHtml;

    return $output;
}

#----------------------------------------------------------------------------

=head2 www_companyInformationSave ( ) 

Update the company information

=cut

sub www_companyInformationSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form = $session->form;
    $session->setting->set( 'companyName',  $form->text("companyName") )   if ( $form->get("companyName") );
    $session->setting->set( 'companyURL',   $form->url("companyURL") )     if ( $form->get("companyURL") );
    $session->setting->set( 'companyEmail', $form->email("companyEmail") ) if ( $form->get("companyEmail") );
    return;
}

#----------------------------------------------------------------------------

=head2 www_siteStats ( ) 

Opt-in to the global WebGUI statistics

=cut

sub www_siteStats {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->response->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    my $enableForm  = $self->getForm;
    $enableForm->addField( "hidden", name => "enableStats", value => 1 );
    $enableForm->addField( "submit", name => 'submit', value => $i18n->get( 'enable', 'Activity_SendWebguiStats' ) );

    my $disableForm = $self->getForm;
    $disableForm->addField( "hidden", name => "enableStats", value => 0 );
    $disableForm->addField( "submit", name => 'submit', value => $i18n->get( 'disable', 'Activity_SendWebguiStats' ) );

    my $output = '<h1>' . $i18n->get( 'topicName', 'Activity_SendWebguiStats' ) . '</h1>';
    $output .= ' <p>' . $i18n->get( 'why to send', 'Activity_SendWebguiStats' ) . '</p>
         <p>' . $i18n->get( 'would you participate', 'Activity_SendWebguiStats' ) . '</p>
        <div style="float: left">' . $enableForm->toHtml . '</div><div style="float: left">'
        . $disableForm->toHtml
        . '</div>'
        . '<div style="clear: both;">&nbsp;</div>'
        ;

    return $output;
}

#----------------------------------------------------------------------------

=head2 www_siteStatsSave ( ) 

Opt-in to the global WebGUI statistics

=cut

sub www_siteStatsSave {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    use WebGUI::Operation::Statistics;
    WebGUI::Operation::Statistics::www_enableSendWebguiStats($session) if ( $form->get("enableStats") );
    return;
}

#----------------------------------------------------------------------------

=head2 www_defaultStyle ( ) 

Choose the default site style

=cut

sub www_defaultStyle {
    return WebGUI::Wizard::HomePage::www_pickStyle( @_ );
}

#----------------------------------------------------------------------------

=head2 www_defaultStyleSave ( ) 

Save the default style to all existing pages and the user function style

=cut


sub www_defaultStyleSave {
    my ( $self, @args ) = @_;
    my $output = WebGUI::Wizard::HomePage::www_pickStyleSave( $self, @args );
    my $session = $self->session;

    my $home     = WebGUI::Asset->getDefault( $session );
    WebGUI::Wizard::HomePage::updateDefaultStyle( $self, $self->get('styleTemplateId'), $home );

    return $output;
}

#----------------------------------------------------------------------------

=head2 www_cleanup ( ) 

Give the user a choice to do the Home Page wizard

=cut

sub www_cleanup {
    my ( $self ) = @_;
    my $session = $self->session;
    my $form    = $session->form;
    $session->response->setCacheControl("none");
    my $i18n = WebGUI::International->new( $session, "WebGUI" );

    $self->cleanup;
    # Delete specialState
    $session->setting->remove( "specialState" );

    my $starterForm  = WebGUI::HTMLForm->new( $session );
    $starterForm->hidden( name => "op", value => "wizard" );
    $starterForm->hidden( name => "wizard_class", value => "WebGUI::Wizard::HomePage" );
    $starterForm->hidden( name => "wizard_step", value => "pickStyle" );
    $starterForm->hidden( name => "initialSetup", value => 1 );
    $starterForm->hidden( name => "styleTemplateId", value => $self->get('styleTemplateId') );
    $starterForm->submit( value => $i18n->get( 'yes please' ) );

    my $homeForm    = WebGUI::HTMLForm->new( $session, { action => $session->url->gateway, method => "GET" } );
    $homeForm->submit( value => $i18n->get('no thanks') );

    my $output = '<h1>' . $i18n->get('page builder title') . '</h1>';
    $output .= ' <p>' . $i18n->get('page builder body') . '</p>'
        . '<div style="float: left">' . $starterForm->print . '</div>'
        . '<div style="float: left">' . $homeForm->print . '</div>'
        . '<div style="clear: both">&nbsp;</div>'
        ;

    return $output;
}

1;
