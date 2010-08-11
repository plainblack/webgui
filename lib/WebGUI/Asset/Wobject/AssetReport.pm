package WebGUI::Asset::Wobject::AssetReport;

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
use WebGUI::Paginator;
use WebGUI::Utility;
use Class::C3;
use base qw/WebGUI::Asset::Wobject/;


#-------------------------------------------------------------------

=head2 canAdd ( session, [userId, groupId] )

Verifies that the user has the privileges necessary to add this type of asset and that the requested asset
can be added as a child of this asset. Return a boolean.

A class method.

=head3 session

The session variable.

=head3 userId

Unique hash identifier for a user. If not supplied, current user.

=head3 groupId

Only developers extending this method should use this parameter. By default WebGUI will check groups in this order, whichever is defined:

=over 4

=item *

Group id assigned in the config file for each asset.

=item *

Group assigned by the developer in the asset itself if s/he extended this method to do so.

=item *

The "turn admin on" group which is group id 12.

=back

=cut

sub canAdd {
    my $className       = shift;
    my $session         = shift;
    my $userId          = shift || $session->user->userId;
    my $user            = WebGUI::User->new($session, $userId);
    my $subclassGroupId = shift;
    my $addPrivsGroup   = $session->config->get("assets/".$className."/addGroup");
    my $groupId         = $addPrivsGroup || $subclassGroupId || '3';
    my $validParent     = $className->validParent($session);
    return $user->isInGroup($groupId) && $validParent;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_AssetReport' );

    tie my %properties, 'Tie::IxHash', (
        settings => {
            tab          => 'properties',
            fieldType    => 'AssetReportQuery',
            defaultValue => undef,
        },
        templateId => {
            tab          => "display",
            fieldType    => "template",
            namespace    => "AssetReport",
            defaultValue => "sJtcUCfn0CVbKdb4QM61Yw",
            label        => $i18n->get("templateId label"),
            hoverHelp    => $i18n->get("templateId description"),
        },
        paginateAfter => {
            tab             => 'display',
            fieldType       => 'integer',
            defaultValue    => 25,
            label           => $i18n->get( 'paginateAfter label' ),
            hoverHelp       => $i18n->get( 'paginateAfter description' ),
        },
    );

    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        autoGenerateForms => 1,
        tableName         => 'AssetReport',
        className         => 'WebGUI::Asset::Wobject::AssetReport',
        properties        => \%properties,
    };

    return $class->SUPER::definition( $session, $definition );
} ## end sub definition


#----------------------------------------------------------------------------

=head2 prepareView ( ) 

Prepare the view. Add stuff to HEAD.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView(@_);
    my $session = $self->session;

    # Prepare the template
    my $template = WebGUI::Asset::Template->new( $session, $self->get("templateId") );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_template} = $template;

    return;
} ## end sub prepareView

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get template variables common to all views of the Asset Report.

=cut

sub getTemplateVars {
    my $self     = shift;
    my $session  = $self->session;
    my $db       = $session->db;

    my $var      = $self->get;

    #Build the lineage query
    my $settings = JSON->new->decode($self->getValue("settings"));

    #TO DO - ADD CACHE CONTROL

    my $assetId  = $settings->{startNode};
    my $asset    = WebGUI::Asset->newByDynamicClass($session,$assetId);

    my $rules               = {};
    $rules->{'isa'}         = $settings->{className};
    
    #Build where condition
    my $condition           = $settings->{anySelect};
    $rules->{'whereClause'} = undef;
    my $where               = $settings->{where};
    foreach my $key (keys %{$where}) {
        my $clause    = $where->{$key};
        my $prop      = $self->secure_identifier($clause->{propSelect});
        my $op        = $self->validate_clause($clause->{opSelect});
        my $value     = $db->quote($clause->{valText});
        
        $rules->{'whereClause'} .= qq{ $condition } if ($key > 1);
        $rules->{'whereClause'} .= qq{$prop $op $value};
    }

    if($rules->{'whereClause'}) {
        $rules->{'joinClass'}   = $settings->{className};
    }

    #Build the order by condition
    my $order                 = $settings->{order};
    my @order                 = keys %{$order};
    if(scalar(@order)) {
        $rules->{'orderByClause'} = undef;
        foreach my $key (@order) {
            my $orderBy     = $order->{$key};
            my $orderSelect = $self->secure_identifier($orderBy->{orderSelect});
            my $dirSelect   = (lc($orderBy->{dirSelect}) eq "desc") ? "DESC" : "ASC";

            $rules->{'orderByClause'} .= q{, } if($key > 1);
            $rules->{'orderByClause'} .= qq{$orderSelect $dirSelect};
        }
    }

    if($settings->{'limit'}) {
        $rules->{'limit'} = $settings->{'limit'};
    }
    my $sql = $asset->getLineageSql(["descendants"],$rules);

    my $p    = WebGUI::Paginator->new($session,$self->getUrl,$self->get("paginateAfter"));
    $p->setDataByQuery($sql);

    #Build the data for all the assets on the page
    $var->{'asset_loop'} = [];
    my $data = $p->getPageData;
    foreach my $row (@{$data}) {
        my $returnAsset = WebGUI::Asset->new($session,$row->{assetId},$row->{className},$row->{revisionDate});
        push(@{$var->{'asset_loop'}},$returnAsset->get);
    }

    #Append template variables
    $p->appendTemplateVars($var);

    return $var;
}

#----------------------------------------------------------------------------

=head2 secure_identifier ( identifier )

Checks the identifier and passes back a secure string.

=cut

sub secure_identifier {
    my $self       = shift;
    my $db         = $self->session->db;
    my $identifier = shift;

    my @parts      = split(/\./,$identifier);
    if(scalar(@parts) > 1) {
        my $table  = $parts[0];
        my $column = $parts[1];
        $identifier = $db->dbh->quote_identifier($table).".".$db->dbh->quote_identifier($column);
    }
    else {
        $identifier = $db->dbh->quote_identifier($identifier);
    }
    
    return $identifier;
} ## end sub view

#----------------------------------------------------------------------------

=head2 validate_clause ( clause )

validates a clause against valid types.  Returns "=" if no match is found.

=cut

sub validate_clause {
    my $self     = shift;
    my $clause   = shift;
    my $ops      = WebGUI::Form::AssetReportQuery->getOps();
    unless ($ops->{$clause}) {
        $clause = "=";
    }
    return $clause;
} ## end sub view

#----------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self     = shift;
    my $var      = $self->getTemplateVars;
    
    return $self->processTemplate( $var, undef, $self->{_template} );
} ## end sub view

1;
