package WebGUI::Asset::Wobject::StoryTopic;

$VERSION = "1.0.0";

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
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::Asset::Story;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for New Wobject instances.  You absolutely need 
this method in your new Wobjects.  If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.  

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session, 'Asset_StoryTopic');
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        storiesPer => {
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => $i18n->get('stories per topic'),
            hoverHelp    => $i18n->get('stories per topic help'),
            defaultValue => 15,
        },
        storiesShort => {
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => $i18n->get('stories short'),
            hoverHelp    => $i18n->get('stories short help'),
            defaultValue => 5,
        },
        storyTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('story template'),
            hoverHelp    => $i18n->get('story template help'),
            filter       => 'fixId',
            namespace    => 'Story',
            defaultValue => 'liNZSK4xWGyALU6nu_criw',
        },
    );
    push(@{$definition}, {
        assetName=>$i18n->get('assetName'),
        icon=>'assets.gif',
        autoGenerateForms=>1,
        tableName=>'StoryTopic',
        className=>'WebGUI::Asset::Wobject::StoryTopic',
        properties=>\%properties,
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    $template->prepare;
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self = shift;
    my $session = $self->session;    

    #This automatically creates template variables for all of your wobject's properties.
    my $var = $self->get;
    
    #This is an example of debugging code to help you diagnose problems.
    #WebGUI::ErrorHandler::warn($self->get("templateId")); 
    
    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}


1;
#vim:ft=perl
