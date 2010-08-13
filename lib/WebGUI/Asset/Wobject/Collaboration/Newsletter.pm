package WebGUI::Asset::Wobject::Collaboration::Newsletter;

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
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject::Collaboration';
define assetName => ['assetName', 'Asset_Newsletter'];
define icon      => 'newsletter.gif';
define tableName => 'Newsletter';
property newsletterHeader => (
    default   => undef,
    fieldType => "HTMLArea",
    tab       => "mail",
    label     => [ "newsletter header", 'Asset_Newsletter' ],
    hoverHelp => [ "newsletter header help", 'Asset_Newsletter' ],
);
property newsletterFooter => (
    default   => undef,
    fieldType => "HTMLArea",
    tab       => "mail",
    label     => [ "newsletter footer", 'Asset_Newsletter' ],
    hoverHelp => [ "newsletter footer help", 'Asset_Newsletter' ],
);
property newsletterTemplateId => (
    default   => 'newsletter000000000001',
    fieldType => "template",
    namespace => "newsletter",
    tab       => "mail",
    label     => [ "newsletter template", 'Asset_Newsletter' ],
    hoverHelp => [ "newsletter template help", 'Asset_Newsletter' ],
);
property mySubscriptionsTemplateId => (
    default   => 'newslettersubscrip0001',
    fieldType => "template",
    namespace => "newsletter/mysubscriptions",
    tab       => "display",
    label     => [ "my subscriptions template", 'Asset_Newsletter' ],
    hoverHelp => [ "my subscriptions template help", 'Asset_Newsletter' ],
);
property newsletterCategories => (
    default   => undef,
    fieldType => "checkList",
    tab       => "properties",
    options   => \&_newsletterCategories_options,
    label     => [ "newsletter categories", 'Asset_Newsletter' ],
    hoverHelp => [ "newsletter categories help", 'Asset_Newsletter' ],
    vertical  => 1,
);
sub _newsletterCategories_options {
    my $session = shift->session;
    return $session->db->buildHashRef("select fieldId, fieldName from metaData_properties where fieldType in ('selectBox', 'checkList', 'radioList') order by fieldName");
}

# XXX TODO: Do this in Moose instead, if we can.
#        # Change the default Collaboration template
#        for my $def ( @$definition ) {
#            if ( exists $def->{properties}->{collaborationTemplateId} ) {
#                $def->{properties}->{collaborationTemplateId}->{defaultValue} = 'newslettercs0000000001';
#            }
#        }

use WebGUI::Form;
use WebGUI::International;
use WebGUI::Utility;

#-------------------------------------------------------------------

=head2 getUserSubscriptions ( [ $userId ])

Returns an array of subscriptions for a user.

=head3 $userId

Looks up subscriptions for the user given by $userId.  If no userId is passed,
it will use the current user's userId.

=cut

sub getUserSubscriptions {
    my $self = shift;
    my $userId = shift || $self->session->user->userId;
    my ($subscriptionString) = $self->session->db->quickArray("select subscriptions from Newsletter_subscriptions where
        assetId=? and userId=?", [$self->getId, $userId]);
    return split("\n", $subscriptionString);
}

#-------------------------------------------------------------------

=head2 getViewTemplateVars 

Extends the base method to add custom template variables for the Newsletter.

=cut

override getViewTemplateVars => sub {
    my $self = shift;
    my $var = super();
    $var->{mySubscriptionsUrl} = $self->getUrl("func=mySubscriptions");
    return $var;
};



#-------------------------------------------------------------------

=head2 purge 

Extend the base method to handle deleting information from the Newsletter_subscriptions table.

=cut

override purge => sub {
    my $self = shift;
    $self->session->db->write("delete from Newsletter_subscriptions where assetId=?", [$self->getId]);
    super();
};


#-------------------------------------------------------------------

=head2 setUserSubscriptions ($subscriptions, $userId)

Store subscription information for a user into the database.

=head3 $subscriptions

A string containing newline separated subscriptions for a user.  A "subscription" is the
fieldId of an asset metadata field joined with the metadata value with a tilde "~".

=head3 $userId

Sets subscriptions for the user given by $userId.  If no userId is passed,
it will use the current user's userId.

=cut

sub setUserSubscriptions {
    my $self = shift;
    my $subscriptions = shift;
    my $userId = shift || $self->session->user->userId;
    $self->session->db->write("replace into Newsletter_subscriptions (assetId, userId, subscriptions, lastTimeSent) 
        values (?,?,?,?)", [$self->getId, $userId, $subscriptions, time()]);
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
	my $var = $self->getViewTemplateVars;
	
	#This is an example of debugging code to help you diagnose problems.
	#WebGUI::ErrorHandler::warn($self->get("templateId")); 
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_mySubscriptions 

Build a form to display to the user their current subscriptions, and allow them to
alter them.

=cut

sub www_mySubscriptions {
    my $self = shift;
    return $self->session->privilege->insufficient unless ($self->canView && $self->session->user->isRegistered);
    my %var = ();
    my $meta = $self->getMetaDataFields;
    my @categories = ();
    my @userPrefs = $self->getUserSubscriptions;
    foreach my $id (keys %{$meta}) {
        my @options = ();
        if (isIn($id, split("\n", $self->newsletterCategories))) {
            foreach my $option (split("\n", $meta->{$id}{possibleValues})) {
                $option =~ s/\s+$//;    # remove trailing spaces
                next if $option eq "";  # skip blank values
                my $preferenceName = $id."~".$option;
                push(@options, {
                    optionName  => $option,
                    optionForm  => WebGUI::Form::checkbox($self->session, {
                            name    => "subscriptions",
                            value   => $preferenceName,
                            checked => isIn($preferenceName, @userPrefs),
                            })
                    });
            }
            push (@categories, {
                categoryName    => $meta->{$id}{fieldName},
                optionsLoop     => \@options
                });
        }
    }
    $var{categoriesLoop} = \@categories;
    if (scalar(@categories)) {
        $var{formHeader} = WebGUI::Form::formHeader($self->session, {action=>$self->getUrl, method=>"post"})
            .WebGUI::Form::hidden($self->session, {name=>"func", value=>"mySubscriptionsSave"});
        $var{formFooter} = WebGUI::Form::formFooter($self->session);
        $var{formSubmit} = WebGUI::Form::submit($self->session);
    }
    return $self->processStyle($self->processTemplate(\%var, $self->mySubscriptionsTemplateId));
}

#-------------------------------------------------------------------

=head2 www_mySubscriptionsSave 

Process the mySubscriptions form.

=cut

sub www_mySubscriptionsSave {
    my $self = shift;
    return $self->session->privilege->insufficient unless ($self->canView && $self->session->user->isRegistered);
    my $subscriptions = $self->session->form->process("subscriptions", "checkList");
    $self->setUserSubscriptions($subscriptions);
    return $self->www_view;
}

__PACKAGE__->meta->make_immutable;
1;
