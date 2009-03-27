package WebGUI::Asset::Wobject::Survey;

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
use JSON;
use WebGUI::International;
use WebGUI::Form::File;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';
use WebGUI::Asset::Wobject::Survey::SurveyJSON;
use WebGUI::Asset::Wobject::Survey::ResponseJSON;
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

#-------------------------------------------------------------------

=head2 definition ( session, [definition] )

Returns an array reference of definitions. Adds tableName, className, properties to array definition.

=head3 definition

An array of hashes to prepend to the list

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_Survey' );
    my %properties;
    tie %properties, 'Tie::IxHash'; ## no critic
    %properties = (
        templateId => {
            fieldType    => 'template',
            defaultValue => 'PBtmpl0000000000000061',
            tab          => 'display',
            namespace    => 'Survey',
            label        => $i18n->get('survey template'),
            hoverHelp    => $i18n->get('survey template help'),
        },
        showProgress => {
            fieldType    => 'yesNo',
            defaultValue => 0,
            tab          => 'properties',
            label        => $i18n->get('Show user their progress'),
            hoverHelp    => $i18n->get('Show user their progress help'),
        },
        showTimeLimit => {
            fieldType    => 'yesNo',
            defaultValue => 0,
            tab          => 'properties',
            label        => $i18n->get('Show user their time remaining'),
            hoverHelp    => $i18n->get('Show user their time remaining'),
        },
        timeLimit => {
            fieldType    => 'integer',
            defaultValue => 0,
            tab          => 'properties',
            label        => $i18n->get('timelimit'),
            hoverHelp    => $i18n->get('timelimit hoverHelp'),
        },
        doAfterTimeLimit => {
            fieldType    => 'selectBox',
            defaultValue => 'exitUrl',
            tab          => 'properties',
            hoverHelp    => $i18n->get('do after timelimit hoverHelp'),
            label        => $i18n->get('do after timelimit label'),
            options      => {
                                'exitUrl'       => $i18n->get('exit url label'),
                                'restartSurvey' => $i18n->get('restart survey label'),
                            },
        },
        groupToEditSurvey => {
            fieldType    => 'group',
            defaultValue => 4,
            label        => $i18n->get('Group to edit survey'),
            hoverHelp    => $i18n->get('Group to edit survey help'),
        },
        groupToTakeSurvey => {
            fieldType    => 'group',
            defaultValue => 2,
            label        => $i18n->get('Group to take survey'),
            hoverHelp    => $i18n->get('Group to take survey help'),
        },
        groupToViewReports => {
            fieldType    => 'group',
            defaultValue => 4,
            label        => $i18n->get('Group to view reports'),
            hoverHelp    => $i18n->get('Group to view reports help'),
        },
        exitURL => {
            fieldType    => 'text',
            defaultValue => undef,
            label        => $i18n->get('Survey Exit URL'),
            hoverHelp    => $i18n->get('Survey Exit URL help'),
        },
        maxResponsesPerUser => {
            fieldType    => 'integer',
            defaultValue => 1,
            label        => $i18n->get('Max user responses'),
            hoverHelp    => $i18n->get('Max user responses help'),
        },
        surveyTakeTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Take Survey Template'),
            hoverHelp    => $i18n->get('Take Survey Template help'),
            defaultValue => 'd8jMMMRddSQ7twP4l1ZSIw',
            namespace    => 'Survey/Take',
        },
        surveyQuestionsId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Questions Template'),
            hoverHelp    => $i18n->get('Questions Template help'),
            defaultValue => 'CxMpE_UPauZA3p8jdrOABw',
            namespace    => 'Survey/Take',
        },
        surveyEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Survey Edit Template'),
            hoverHelp    => $i18n->get('Survey Edit Template help'),
            defaultValue => 'GRUNFctldUgop-qRLuo_DA',
            namespace    => 'Survey/Edit',
        },
        sectionEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Section Edit Template'),
            hoverHelp    => $i18n->get('Section Edit Template help'),
            defaultValue => '1oBRscNIcFOI-pETrCOspA',
            namespace    => 'Survey/Edit',
        },
        questionEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Question Edit Template'),
            hoverHelp    => $i18n->get('Question Edit Template help'),
            defaultValue => 'wAc4azJViVTpo-2NYOXWvg',
            namespace    => 'Survey/Edit',
        },
        answerEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Answer Edit Template'),
            hoverHelp    => $i18n->get('Answer Edit Template help'),
            defaultValue => 'AjhlNO3wZvN5k4i4qioWcg',
            namespace    => 'Survey/Edit',
        },
        overviewTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            defaultValue => 'PBtmpl0000000000000063',
            label        => $i18n->get('Overview Report Template'),
            hoverHelp    => $i18n->get('Overview Report Template help'),
            namespace    => 'Survey/Overview',
        },
        gradebookTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('Grabebook Report Template'),
            hoverHelp    => $i18n->get('Grabebook Report Template help'),
            defaultValue => 'PBtmpl0000000000000062',
            namespace    => 'Survey/Gradebook',
        },
        surveyJSON => {
            fieldType    => 'text',
            defaultValue => '',
            autoGenerate => 0,
            noFormPost  => 1, 
        },
        onSurveyEndWorkflowId => {
            tab          => 'properties',
            defaultValue => undef,
            type         => 'WebGUI::Asset::Wobject::Survey',
            fieldType    => 'workflow',
            label        => 'Survey End Workflow',
            hoverHelp    => 'Workflow to run when user completes the Survey',
            #            label           => $i18n->get('editForm workflowIdAddEntry label'),
            #            hoverHelp       => $i18n->get('editForm workflowIdAddEntry description'),
            none => 1,
        },
    );

    #my $defaultMC = $session->  

    #%properties = ();

    push @{$definition}, {
            assetName         => $i18n->get('assetName'),
            icon              => 'survey.gif',
            autoGenerateForms => 1,
            tableName         => 'Survey',
            className         => 'WebGUI::Asset::Wobject::Survey',
            properties        => \%properties
        };

    return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 surveyJSON_update ( )

Convenience method that delegates to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/update>
and automatically calls L<"persistSurveyJSON"> afterwards.

=cut

sub surveyJSON_update {
    my $self = shift;
    my $ret = $self->surveyJSON->update(@_);
    $self->persistSurveyJSON();
    return $ret;
}

#-------------------------------------------------------------------

=head2 surveyJSON_copy ( )

Convenience method that delegates to L<WebGUI::Asset::Wobject::Survey::SurveyJSON/copy>
and automatically calls L<"persistSurveyJSON"> afterwards.

=cut

sub surveyJSON_copy {
    my $self = shift;
    my $ret =$self->surveyJSON->copy(@_);
    $self->persistSurveyJSON();
    return $ret;
}

#-------------------------------------------------------------------

=head2 surveyJSON_remove ( )

Convenience method that delegates L<WebGUI::Asset::Wobject::Survey::SurveyJSON/remove>
and automatically calls L<"persistSurveyJSON"> afterwards.

=cut

sub surveyJSON_remove {
    my $self = shift;
    my $ret = $self->surveyJSON->remove(@_);
    $self->persistSurveyJSON();
    return $ret;
}

#-------------------------------------------------------------------

=head2 surveyJSON_newObject ( )

Convenience method that delegates L<WebGUI::Asset::Wobject::Survey::SurveyJSON/newObject>
and automatically calls L<"persistSurveyJSON"> afterwards.

=cut

sub surveyJSON_newObject {
    my $self = shift;
    my $ret = $self->surveyJSON->newObject(@_);
    $self->persistSurveyJSON();
    return $ret;
}

#-------------------------------------------------------------------

=head2 recordResponses ( )

Convenience method that delegates to L<WebGUI::Asset::Wobject::Survey::ResponseJSON/recordResponses>
and automatically calls L<"persistSurveyJSON"> afterwards.

=cut

sub recordResponses {
    my $self = shift;
    my $ret = $self->responseJSON->recordResponses(@_);
    $self->persistResponseJSON();
    return $ret;
}

#-------------------------------------------------------------------

=head2 surveyJSON ( [json] )

Lazy-loading mutator for the L<WebGUI::Asset::Wobject::Survey::SurveyJSON> property.

It is stored in the database as a serialized JSON-encoded string in the surveyJSON db field.

If you access and change surveyJSON you will need to manually call L<"persistSurveyJSON"> 
to have your changes persisted to the database. 

=head3 json (optional)

A serialized JSON-encoded string representing a SurveyJSON object. If provided, 
will be used to instantiate the SurveyJSON instance rather than querying the database.

=cut

sub surveyJSON {
    my $self = shift;
    my ($json) = validate_pos(@_, { type => SCALAR, optional => 1 });
    
    if (!$self->{_surveyJSON} || $json) {

        # See if we need to load surveyJSON from the database
        if ( !defined $json ) {
            $json = $self->get("surveyJSON");
        }

        # Instantiate the SurveyJSON instance, and store it
        $self->{_surveyJSON} = WebGUI::Asset::Wobject::Survey::SurveyJSON->new( $self->session, $json );
    }
        
    return $self->{_surveyJSON};
}

#-------------------------------------------------------------------

=head2 responseJSON ( [json], [responseId] )

Lazy-loading mutator for the L<WebGUI::Asset::Wobject::Survey::ResponseJSON> property.

It is stored in the database as a serialized JSON-encoded string in the responseJSON db field.

If you access and change responseJSON you will need to manually call L<"persistResponseJSON"> 
to have your changes persisted to the database. 

=head3 json (optional)

A serialized JSON-encoded string representing a ResponseJSON object. If provided, 
will be used to instantiate the ResponseJSON instance rather than querying the database.

=head3 responseId (optional)

A responseId to use when retrieving ResponseJSON from the database (defaults to the value returned by L<"responseId">)

=cut

sub responseJSON {
    my $self = shift;
    my ($json, $responseId) = validate_pos(@_, { type => SCALAR | UNDEF, optional => 1 }, { type => SCALAR, optional => 1});
    
    if (!defined $responseId) {
        $responseId = $self->responseId;
    }
     
    if (!$self->{_responseJSON} || $json) {

        # See if we need to load responseJSON from the database
        if (!defined $json) {
            $json = $self->session->db->quickScalar( 'select responseJSON from Survey_response where assetId = ? and Survey_responseId = ?', [ $self->getId, $responseId ] );
        }

        # Instantiate the ResponseJSON instance, and store it
        $self->{_responseJSON} = WebGUI::Asset::Wobject::Survey::ResponseJSON->new( $self->surveyJSON, $json );
    }
    
    return $self->{_responseJSON};
}

#-------------------------------------------------------------------

=head2 www_editSurvey ( )

Loads the initial edit survey page. All other edit actions are ajax calls from this page.

=cut

sub www_editSurvey {
    my $self = shift;
    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    return $self->processTemplate( {}, $self->get('surveyEditTemplateId') );
}

#-------------------------------------------------------------------

=head2 www_submitObjectEdit ( )

This is called when an edit is submitted to a survey object. The POST should contain the id and updated params
of the object, and also if the object is being deleted or copied.

In general, the id contains a section index, question index, and answer index, separated by dashes.
See L<WebGUI::Asset::Wobject::Survey::ResponseJSON/sectionIndex>. 

=cut

sub www_submitObjectEdit {
    my $self = shift;
    
    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    my $params = $self->session->form->paramsHashRef();

    # Id is made up of at most: sectionIndex-questionIndex-answerIndex
    my @address = split /-/, $params->{id};

    # See if any special actions were requested..
    if ( $params->{delete} ) {
        return $self->deleteObject( \@address );
    }
    elsif ( $params->{copy} ) {
        return $self->copyObject( \@address );
    }elsif( $params->{removetype} ){
        return $self->removeType(\@address);        
    }elsif( $params->{addtype} ){
        return $self->addType($params->{addtype},\@address);        
    }

    # Update the addressed object
    $self->surveyJSON_update( \@address, $params );

    # Return the updated Survey structure
    return $self->www_loadSurvey( { address => \@address } );
}

#-------------------------------------------------------------------

=head2 www_jumpTo

Allow survey editors to jump to a particular section or question in a
Survey by tricking Survey into thinking they've completed the survey up to that
point. This is useful for user-testing large Survey instances where you don't want 
to waste your time clicking through all of the initial questions to get to the one 
you want to look at. 

Note that calling this method will delete any existing survey responses for the
current user (although only survey builders can call this method so that shouldn't be
a problem).

=cut

sub www_jumpTo {
    my $self = shift;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    my $id = $self->session->form->param('id');

    # When the Edit Survey screen first loads the first section will have an id of 'undefined'
    # In this case, treat it the same as '0'
    $id = $id eq 'undefined' ? 0 : $id;

    $self->session->log->debug("www_jumpTo: $id");

    # Remove existing responses for current user
    $self->session->db->write( 'delete from Survey_response where assetId = ? and userId = ?',
        [ $self->getId, $self->session->user->userId() ] );

    # Break the $id down into sIndex and qIndex
    my ($sIndex, $qIndex) = split /-/, $id;

    # Go through items in surveyOrder until we find the item corresponding to $id
    my $currentIndex = 0;
    for my $address (@{ $self->responseJSON->surveyOrder }) {
        my ($order_sIndex, $order_qIndex) = @{$address}[0,1];

        # For starters, check that we're on the right Section 
        if ($sIndex ne $order_sIndex) {

            # Bad luck, try the next one..
            $currentIndex++;
            next;
        }

        # For a match, either qIndex must be empty (target is a Section), or
        # the qIndices must match
        if (!defined $qIndex || $qIndex eq $order_qIndex) {

            # Set the nextResponse to be the index we're up to
            $self->session->log->debug("Found id: $id at index: $currentIndex in surveyOrder");
            $self->responseJSON->nextResponse( $currentIndex );
            $self->persistResponseJSON(); # Manually persist ResponseJSON to the database
            return $self->www_takeSurvey;
        }

        # Keep looking..
        $currentIndex++;
    }

    # Search failed, so return the Edit Survey page instead.
    $self->session->log->debug("Unable to find id: $id");
    return $self->www_editSurvey;
}

#-------------------------------------------------------------------

sub removeType{
    my $self = shift;
    my $address = shift;
    $self->surveyJSON->removeType($address);
    return $self->www_loadSurvey( { address => $address } );
    
}

#-------------------------------------------------------------------

sub addType{
    my $self = shift;
    my $name = shift;
    my $address = shift;
    $self->surveyJSON->addType($name,$address);
    $self->persistSurveyJSON();
    return $self->www_loadSurvey( { address => $address } );
}

#-------------------------------------------------------------------

=head2 copyObject ( )

Takes the address of a survey object and creates a copy.  The copy is placed at the end of this object's parent's list. 

Returns the address to the new object.

=head3 $address

See L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>

=cut

sub copyObject {
    my ( $self, $address ) = @_;

    # Each object checks the ref and then either updates or passes it to the correct child.  
    # New objects will have an index of -1.
    $address = $self->surveyJSON_copy($address);

    # The parent address of the deleted object is returned.
    return $self->www_loadSurvey( { address => $address } );
}

#-------------------------------------------------------------------

=head2 deleteObject( $address )

Deletes the object matching the passed in address.

Returns the address to the parent object, or the very first section.

=head3 $address

See L<WebGUI::Asset::Wobject::Survey::SurveyJSON/Address Parameter>

=cut

sub deleteObject {
    my ( $self, $address ) = @_;

    # Each object checks the ref and then either updates or passes it to the correct child. 
    # New objects will have an index of -1.
    my $message = $self->surveyJSON_remove($address);

    # The parent address of the deleted object is returned.
    if ( @{$address} == 1 ) {
        $address->[0] = 0;
    }
    else {
        pop @{$address};
    }

    return $self->www_loadSurvey( { address => $address, message => $message } );
}

#-------------------------------------------------------------------

=head2 www_newObject()

Creates a new object from a POST param containing the new objects id concatenated on hyphens.

=cut

sub www_newObject {
    my $self = shift;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    my $ref;

    my $ids = $self->session->form->process('data');

    my @inAddress = split /-/, $ids;

    # Don't save after this as the new object should not stay in the survey
    my $address = $self->surveyJSON->newObject( \@inAddress );

    # The new temp object has an address of NEW, which means it is not a real final address.
    return $self->www_loadSurvey( { address => $address, message => undef } );

}

#-------------------------------------------------------------------

=head2 www_dragDrop

Takes two ids from a form POST. 
The "target" is the object being moved, the "before" is the object directly preceding the "target".

=cut

sub www_dragDrop {
    my $self = shift;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    my $p = from_json( $self->session->form->process('data') );

    my @tid = split /-/, $p->{target}->{id};
    my @bid = split /-/, $p->{before}->{id};

    my $target = $self->surveyJSON->getObject( \@tid );
    $self->surveyJSON_remove( \@tid, 1 );
    my $address = [0];
    if ( @tid == 1 ) {

        #sections can only be inserted after another section so chop off the question and answer portion of
        $#bid = 0;
        $bid[0] = -1 if ( !defined $bid[0] );

        #If target is being moved down, then before has just moved up do to the target being deleted
        $bid[0]-- if($tid[0] < $bid[0]);

        $self->surveyJSON->insertObject( $target, [ $bid[0] ] );
    }
    elsif ( @tid == 2 ) {    #questions can be moved to any section, but a pushed to the end of a new section.
        if ( $bid[0] !~ /\d/ ) {
            $bid[0] = $tid[0];
            $bid[1] = $tid[1];
        }
        elsif ( @bid == 1 ) {    #moved to a new section or head of current section
            if ( $bid[0] !~ /\d/ ) {
                $bid[0] = $tid[0];
                $bid[1] = $tid[1];
            }
            if ( $bid[0] == $tid[0] ) {
                #moved to top of current section
                $bid[1] = -1;
            }
            else {
                #else move to the end of the selected section
                $bid[1] = $#{ $self->surveyJSON->questions( [ $bid[0] ] ) };
            }
        } ## end elsif ( @bid == 1 )
        else{   #Moved within the same section
            $bid[1]-- if($tid[1] < $bid[1]);
        }
        $self->surveyJSON->insertObject( $target, [ $bid[0], $bid[1] ] );
    } ## end elsif ( @tid == 2 )
    elsif ( @tid == 3 ) {    #answers can only be rearranged in the same question
        if ( @bid == 2 and $bid[1] == $tid[1] ) {#moved to the top of the question
            $bid[2] = -1;
            $self->surveyJSON->insertObject( $target, [ $bid[0], $bid[1], $bid[2] ] );
        }
        elsif ( @bid == 3 ) {
            #If target is being moved down, then before has just moved up do to the target being deleted
            $bid[2]-- if($tid[2] < $bid[2]);
            $self->surveyJSON->insertObject( $target, [ $bid[0], $bid[1], $bid[2] ] );
        }
        else {
            #else put it back where it was
            $self->surveyJSON->insertObject( $target, \@tid );
        }
    }

    # Manually persist SuveryJSON since we have directly modified it
    $self->persistSurveyJSON();

    return $self->www_loadSurvey( { address => $address } );
}

#-------------------------------------------------------------------

=head2 www_loadSurvey( [options] )

For loading the survey during editing. 
Returns the survey meta list and the html data for editing a particular survey object.

=head3 options

Can either be a hashref containing the address to be edited.  And/or a the specific variables to be edited.  
If undef, the address is pulled form the form POST.

=cut

sub www_loadSurvey {
    my ( $self, $options ) = @_;
    my $editflag = 1;
    my $address = defined $options->{address} ? $options->{address} : undef;
    if ( !defined $address ) {
        if ( my $inAddress = $self->session->form->process('data') ) {
            if ( $inAddress eq q{-} ) {
                $editflag = 0;
                $address  = [0];
            }
            else {
                $address = [ split /-/, $inAddress ];
            }
        }
        else {
            $address = [0];
        }
    }
    my $var
        = defined $options->{var}
        ? $options->{var}
        : $self->surveyJSON->getEditVars($address);

    my $editHtml;
    if ( $var->{type} eq 'section' ) {
        $editHtml = $self->processTemplate( $var, $self->get('sectionEditTemplateId') );
    }
    elsif ( $var->{type} eq 'question' ) {
        $editHtml = $self->processTemplate( $var, $self->get('questionEditTemplateId') );
    }
    elsif ( $var->{type} eq 'answer' ) {
        $editHtml = $self->processTemplate( $var, $self->get('answerEditTemplateId') );
    }

    # Generate the list of valid goto targets
    my @gotoTargets = $self->surveyJSON->getGotoTargets;

    my %buttons;
    $buttons{question} = $address->[0];
    if ( @{$address} == 2 or @{$address} == 3 ) {
        $buttons{answer} = "$address->[0]-$address->[1]";
    }

    my $data = $self->surveyJSON->getDragDropList($address);
    my $html;
    my ( $scount, $qcount, $acount ) = ( -1, -1, -1 );
    my $lastType;
    my %lastId;
    my @ids;
    my ( $s, $q, $a ) = ( 0, 0, 0 );    #bools on if a button has already been created

    foreach (@{$data}) {
        if ( $_->{type} eq 'section' ) {
            $lastId{section} = ++$scount;
            if ( $lastType eq 'answer' ) {
                $a = 1;
            }
            elsif ( $lastType eq 'question' ) {
                $q = 1;
            }
            $html .= "<li id='$scount' class='section'>S" . ( $scount + 1 ) . ": $_->{text}<\/li><br>\n";
            push( @ids, $scount );
        }
        elsif ( $_->{type} eq 'question' ) {
            $lastId{question} = ++$qcount;
            if ( $lastType eq 'answer' ) {
                $a = 1;
            }
            $html .= "<li id='$scount-$qcount' class='question'>Q" . ( $qcount + 1 ) . ": $_->{text}<\/li><br>\n";
            push @ids, "$scount-$qcount";
            $lastType = 'question';
            $acount   = -1;
        }
        elsif ( $_->{type} eq 'answer' ) {
            $lastId{answer} = ++$acount;
            $html
                .= "<li id='$scount-$qcount-$acount' class='answer'>A"
                . ( $acount + 1 )
                . ": $_->{text}<\/li><br>\n";
            push @ids, "$scount-$qcount-$acount";
            $lastType = 'answer';
        }
    }

    my $return = {
        address  => $address,                    # the address of the focused object
        buttons  => \%buttons,                   # the data to create the Add buttons
        edithtml => $editflag ? $editHtml : q{}, # the html edit the object
        ddhtml   => $html,                       # the html to create the draggable html divs
        ids      => \@ids,                       # list of all ids passed in which are draggable (for adding events)
        type     => $var->{type},                # the object type
        gotoTargets => \@gotoTargets,
    };

    $self->session->http->setMimeType('application/json');

    return to_json($return);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $templateId = $self->get('templateId');
    if ( $self->session->form->process('overrideTemplateId') ne q{} ) {
        $templateId = $self->session->form->process('overrideTemplateId');
    }
    my $template = WebGUI::Asset::Template->new( $self->session, $templateId );
    $template->prepare;
    $self->{_viewTemplate} = $template;
    return;
}

#-------------------------------------------------------------------

=head2 purge

Completely remove from WebGUI.

=cut

sub purge {
    my $self = shift;
    $self->session->db->write( 'delete from Survey_response where assetId = ?',   [ $self->getId() ] );
    $self->session->db->write( 'delete from Survey_tempReport where assetId = ?', [ $self->getId() ] );
    $self->session->db->write( 'delete from Survey where assetId = ?',            [ $self->getId() ] );
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
    my $self = shift;
    WebGUI::Cache->new( $self->session, 'view_' . $self->getId )->delete;
    return $self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
    my $self    = shift;
    my $var     = $self->getMenuVars;

    my ( $code, $overTakeLimit ) = $self->getResponseInfoForView();
    
    $var->{lastResponseCompleted} = $code;
    $var->{lastResponseTimedOut}  = $code > 1 ? 1 : 0;
    $var->{maxResponsesSubmitted} = $overTakeLimit;
    
    my $out = $self->processTemplate( $var, undef, $self->{_viewTemplate} );

    return $out;
}

#-------------------------------------------------------------------

=head2 getMenuVars ( )

Returns the top menu template variables as a hashref.

=cut

sub getMenuVars {
    my $self = shift;

    return {
        edit_survey_url               => $self->getUrl('func=editSurvey'),
        take_survey_url               => $self->getUrl('func=takeSurvey'),
        delete_responses_url          => $self->getUrl('func=deleteResponses'),
        view_simple_results_url       => $self->getUrl('func=exportSimpleResults'),
        view_transposed_results_url   => $self->getUrl('func=exportTransposedResults'),
        view_statistical_overview_url => $self->getUrl('func=viewStatisticalOverview'),
        view_grade_book_url           => $self->getUrl('func=viewGradeBook'),
        user_canTakeSurvey            => $self->session->user->isInGroup( $self->get('groupToTakeSurvey') ),
        user_canViewReports           => $self->session->user->isInGroup( $self->get('groupToViewReports') ),
        user_canEditSurvey            => $self->session->user->isInGroup( $self->get('groupToEditSurvey') ),
    };
}

#-------------------------------------------------------------------

=head2 getResponseInfoForView ( )

Looks to see if this user has a response, looks at the last one to see if it was completed or timed out.
Then it checks to see if the user has reached the max number of responses.

=cut

sub getResponseInfoForView {
    my $self = shift;

    my ( $code, $taken );

    my $maxResponsesPerUser = $self->getValue('maxResponsesPerUser');
    my $userId              = $self->session->user->userId();
    my $anonId 
        = $self->session->form->process('userid')
        || $self->session->http->getCookies->{Survey2AnonId}
        || undef;
    $anonId && $self->session->http->setCookie( Survey2AnonId => $anonId );
    my $ip = $self->session->env->getIp;
    my $string;

    #if there is an anonid or id is for a WG user
    if ( $anonId or $userId != 1 ) {
        $string = 'userId';
        if ($anonId) {
            $string = 'anonId';
            $userId = $anonId;
        }
        my $responseId
            = $self->session->db->quickScalar(
            "select Survey_responseId from Survey_response where $string = ? and assetId = ? and isComplete = 0",
            [ $userId, $self->getId() ] );
        if ( !$responseId ) {
            $code = $self->session->db->quickScalar(
                "select isComplete from Survey_response where $string = ? and assetId = ? and isComplete > 0 order by endDate desc limit 1",
                [ $userId, $self->getId() ]
            );
        }
        $taken
            = $self->session->db->quickScalar(
            "select count(*) from Survey_response where $string = ? and assetId = ? and isComplete > 0",
            [ $userId, $self->getId() ] );

    }
    elsif ( $userId == 1 ) {
        my $responseId = $self->session->db->quickScalar(
            'select Survey_responseId from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete = 0',
            [ $userId, $ip, $self->getId() ]
        );
        if ( !$responseId ) {
            $code = $self->session->db->quickScalar(
                'select isComplete from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete > 0 order by endDate desc limit 1',
                [ $userId, $ip, $self->getId() ]
            );
        }
        $taken = $self->session->db->quickScalar(
            'select count(*) from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete > 0',
            [ $userId, $ip, $self->getId() ]
        );
    }
    return ( $code, $maxResponsesPerUser > 0 && $taken >= $maxResponsesPerUser );
}

#-------------------------------------------------------------------

=head2 newByResponseId ( responseId )

Class method. Instantiates a Survey instance from the given L<"responseId">, and loads the
user response into the Survey instance.

=head3 responseId

An existing L<"responseId">. Will be loaded even if the response isComplete.

=cut

sub newByResponseId {
    my $class = shift;
    my ($session, $responseId) = validate_pos(@_, {isa => 'WebGUI::Session'}, { type => SCALAR });
    
    my ($assetId, $userId) = $session->db->quickArray('select assetId, userId from Survey_response where Survey_responseId = ?',
        [$responseId]);
    
    if (!$assetId) {
        $session->log->warn("ResponseId not bound to valid assetId: $responseId");
        return;
    }
    
    if (!$userId) {
        $session->log->warn("ResponseId not bound to valid userId: $responseId");
        return;
    }
    
    if (my $survey = $class->new($session, $assetId)) {
        # Set the responseId manually rather than calling $self->responseId so that we
        # can load a response regardless of whether it's marked isComplete
        $survey->{responseId} = $responseId;
        return $survey;
    } else {
        $session->log->warn("Unable to instantiate Asset for assetId: $assetId");
        return;
    }
}

#-------------------------------------------------------------------

=head2 www_takeSurvey

The take survey page does very little. It is a simple shell (controlled by surveyTakeTemplateId).

Survey questions are loaded asynchronously via javascript calls to L<"www_loadQuestions">.

=cut

sub www_takeSurvey {
    my $self = shift;
    
    my $out = $self->processTemplate( {}, $self->get('surveyTakeTemplateId') );
    return $self->session->style->process( $out, $self->get('styleTemplateId') );
}

#-------------------------------------------------------------------

=head2 www_deleteResponses

Deletes all responses from this survey instance.

=cut

sub www_deleteResponses {
    my $self = shift;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToEditSurvey') );

    $self->session->db->write( 'delete from Survey_response where assetId = ?', [ $self->getId ] );

    return;
}

#-------------------------------------------------------------------

=head2 www_submitQuestions

Handles questions submitted by the survey taker, adding them to their response.

=cut

sub www_submitQuestions {
    my $self = shift;

    if ( !$self->canTakeSurvey() ) {
        $self->session->log->debug('canTakeSurvey false, surveyEnd');
        return $self->surveyEnd();
    }

    my $responseId = $self->responseId();
    if ( !$responseId ) {
        $self->session->log->debug('No response id, surveyEnd');
        return $self->surveyEnd();
    }

    my $responses = $self->session->form->paramsHashRef();
    delete $responses->{func};

    my @goodResponses = keys %{$responses};    #load everything.

    my $termInfo = $self->recordResponses( $responses );

    if ( $termInfo->[0] ) {
        $self->session->log->debug('Terminal, surveyEnd');
        return $self->surveyEnd( $termInfo->[1] );
    }

    return $self->www_loadQuestions();

#    my $files = 0;
#
#        for my $id(@$orderOf){
#    if a file upload, write to disk
#            my $path;
#            if($id->{'questionType'} eq 'File Upload'){
#                $files = 1;
#                my $storage = WebGUI::Storage->create($self->session);
#                my $filename = $storage->addFileFromFormPost( $id->{'Survey_answerId'} );
#                $path = $storage->getPath($filename);
#            }
#    $self->session->errorHandler->error("Inserting a response ".$id->{'Survey_answerId'}." $responseId, $path, ".$$responses{$id->{'Survey_answerId'}});
#            $self->session->db->write("insert into Survey_questionResponse
#                select ?, Survey_sectionId, Survey_questionId, Survey_answerId, ?, ?, ?, now(), ?, ? from Survey_answer where Survey_answerId = ?",
#                [$self->getId(), $responseId, $$responses{ $id->{'Survey_answerId'} }, '', $path, ++$lastOrder, $id->{'Survey_answerId'}]);
#        }
#    if ($files) {
#        ##special case, need to check for more questions in section, if not, more current up one
#        my $lastA      = $self->getLastAnswerInfo($responseId);
#        my $questionId = $self->getNextQuestionId( $lastA->{'Survey_questionId'} );
#        if ( !$questionId ) {
#            my $currentSection = $self->getCurrentSection($responseId);
#            $currentSection = $self->getNextSection($currentSection);
#            if ($currentSection) {
#                $self->setCurrentSection( $responseId, $currentSection );
#            }
#        }
#        return;
#    }
#    return $self->www_loadQuestions($responseId);

}

#-------------------------------------------------------------------

=head2 www_loadQuestions

Determines which questions to display to the survey taker next, loads and returns them.

=cut

sub www_loadQuestions {
    my $self            = shift;
    my $wasRestarted    = shift;

    if ( !$self->canTakeSurvey() ) {
        $self->session->log->debug('canTakeSurvey false, surveyEnd');
        return $self->surveyEnd();
    }

    my $responseId = $self->responseId();
    if ( !$responseId ) {
        $self->session->log->debug('No responseId, surveyEnd');
        return $self->surveyEnd();
    }
    if ( $self->responseJSON->hasTimedOut( $self->get('timeLimit') ) ) {
        $self->session->log->debug('Response hasTimedOut, surveyEnd');
        return $self->surveyEnd( undef, 2 );
    }

    if ( $self->responseJSON->surveyEnd() ) {
        $self->session->log->debug('Response surveyEnd, so calling surveyEnd');
        return $self->surveyEnd();
    }

    my @questions;
    eval { @questions = $self->responseJSON->nextQuestions(); };
    
    my $section = $self->responseJSON->nextResponseSection();

    #return $self->prepareShowSurveyTemplate($section,$questions);
    $section->{id}              = $self->responseJSON->nextResponseSectionIndex();
    $section->{wasRestarted}    = $wasRestarted;

    my $text = $self->prepareShowSurveyTemplate( $section, \@questions );

    return $text;
}

#-------------------------------------------------------------------

=head2 surveyEnd ( [ $url ], [ $completeCode ]  )

Marks the survey completed with either 1 or the $completeCode and then sends the url to the site home or if defined, $url.

=head3 $url

An optional url to send the user to upon survey completion.

=head3 $completeCode

An optional code (defaults to 1) to say how the user completed the survey.

1 is normal completion.
2 is timed out.

=cut

sub surveyEnd {
    my $self         = shift;
    my $url          = shift;
    my $completeCode = shift;

    $completeCode = defined $completeCode ? $completeCode : 1;

    if ( my $responseId = $self->responseId ) {
        $self->session->db->setRow(
            'Survey_response',
            'Survey_responseId', {
                Survey_responseId => $responseId,
                endDate           => scalar time,         #WebGUI::DateTime->now->toDatabase,
                isComplete        => $completeCode
            }
        );
        
         # Trigger workflow
        if ( my $workflowId = $self->get('onSurveyEndWorkflowId') ) {
            $self->session->log->debug("Triggering onSurveyEndWorkflowId workflow: $workflowId");
            WebGUI::Workflow::Instance->create(
                $self->session,
                {   workflowId => $workflowId,
                    methodName => 'newByResponseId',
                    className  => 'WebGUI::Asset::Wobject::Survey',
                    parameters => $responseId,
                }
            )->start;
        }
    } 
    if ($self->get('doAfterTimeLimit') eq 'restartSurvey' && $completeCode == 2){
        $self->responseJSON->startTime(scalar time);
        undef $self->{_responseJSON};
        undef $self->{responseId};
        return $self->www_loadQuestions('1');
    } else {
        if ( $url !~ /\w/ ) { $url = 0; }
        if ( $url eq 'undefined' ) { $url = 0; }
        if ( !$url ) {
            $url = $self->get('exitURL');
            if ( !$url ) {
                $url = q{/};
            }
        }
    }
    $url = $self->session->url->gateway($url);
    #$self->session->http->setRedirect($url);
    #$self->session->http->setMimeType('application/json');
    my $json = to_json( { type => 'forward', url => $url } );
    return $json;
}

#-------------------------------------------------------------------

=head2 prepareShowSurveyTemplate

Sends the processed template and questions structure to the client

=cut

sub prepareShowSurveyTemplate {
    my ( $self, $section, $questions ) = @_;
#    my %multipleChoice = (
#        'Multiple Choice', 1, 'Gender',        1, 'Yes/No',     1, 'True/False', 1, 'Ideology',       1,
#        'Race',            1, 'Party',         1, 'Education',  1, 'Scale',      1, 'Agree/Disagree', 1,
#        'Oppose/Support',  1, 'Importance',    1, 'Likelihood', 1, 'Certainty',  1, 'Satisfaction',   1,
#        'Confidence',      1, 'Effectiveness', 1, 'Concern',    1, 'Risk',       1, 'Threat',         1,
#        'Security',        1
#    );
    my %textArea    = ( 'TextArea', 1 );
    my %text        = ( 'Text', 1, 'Email', 1, 'Phone Number', 1, 'Text Date', 1, 'Currency', 1 );
    my %slider      = ( 'Slider', 1, 'Dual Slider - Range', 1, 'Multi Slider - Allocate', 1 );
    my %dateType    = ( 'Date',        1, 'Date Range', 1 );
    my %dateShort   = ( 'Year Month', 1 );
    my %fileUpload  = ( 'File Upload', 1 );
    my %hidden      = ( 'Hidden',      1 );

    foreach my $q (@$questions) {
        if    ( $fileUpload{ $q->{questionType} } ) { $q->{fileLoader}   = 1; }
        elsif ( $text{ $q->{questionType} } )       { $q->{textType}     = 1; }
        elsif ( $textArea{ $q->{questionType} } )   { $q->{textAreaType} = 1; }
        elsif ( $hidden{ $q->{questionType} } )     { $q->{hidden}       = 1; }
        elsif ( $self->surveyJSON->multipleChoiceTypes->{ $q->{questionType} } ) {
            $q->{multipleChoice} = 1;
            if ( $q->{maxAnswers} > 1 ) {
                $q->{maxMoreOne} = 1;
            }
        }
        elsif ( $dateType{ $q->{questionType} } ) {
            $q->{dateType} = 1;
        }
        elsif ( $dateShort{ $q->{questionType} } ) {
            $q->{dateShort} = 1;
            foreach my $a(@{$q->{answers}}){
                $a->{months} = [ 
                             {'month' => ''},
                             {'month' => 'January'},
                             {'month' => 'February'},
                             {'month' => 'March'},
                             {'month' => 'April'},
                             {'month' => 'May'},
                             {'month' => 'June'},
                             {'month' => 'July'},
                             {'month' => 'August'},
                             {'month' => 'September'},
                             {'month' => 'October'},
                             {'month' => 'November'},
                             {'month' => 'December'}
                            ];
            }
        }
        elsif ( $slider{ $q->{questionType} } ) {
            $q->{slider} = 1;
            if ( $q->{questionType} eq 'Dual Slider - Range' ) {
                $q->{dualSlider} = 1;
                $q->{a1}         = [ $q->{answers}->[0] ];
                $q->{a2}         = [ $q->{answers}->[1] ];
            }
        }

        if ( $q->{verticalDisplay} ) {
            $q->{verts} = '<p>';
            $q->{verte} = '</p>';
        }
    }
    $section->{questions}         = $questions;
    $section->{questionsAnswered} = $self->responseJSON->{questionsAnswered};
    $section->{totalQuestions}    = @{ $self->responseJSON->surveyOrder };
    $section->{showProgress}      = $self->get('showProgress');
    $section->{showTimeLimit}     = $self->get('showTimeLimit');
    $section->{minutesLeft}
        = int( ( ( $self->responseJSON->startTime() + ( 60 * $self->get('timeLimit') ) ) - time() ) / 60 );

    if(scalar @{$questions} == ($section->{totalQuestions} - $section->{questionsAnswered})){
        $section->{isLastPage} = 1
    }

    my $out = $self->processTemplate( $section, $self->get('surveyQuestionsId') );

    $self->session->http->setMimeType('application/json');
    return to_json( { type => 'displayquestions', section => $section, questions => $questions, html => $out } );
}

##-------------------------------------------------------------------
#
#=head2 loadBothJSON($rId)
#
#Loads both the Survey and the appropriate response objects from JSON.
#
#=head3 $rId
#
#The reponse id to load.
#
#=cut
#
#sub loadBothJSON {
#    my $self = shift;
#    my $rId  = shift;
##    if ( defined $self->surveyJSON and defined $self->responseJSON ) { return; }
#    my $ref = $self->session->db->buildArrayRefOfHashRefs( "
#        select s.surveyJSON,r.responseJSON 
#        from Survey s, Survey_response r 
#        where s.assetId = ? and r.Survey_responseId = ?",
#        [ $self->getId, $rId ] );
#    $self->surveyJSON( $ref->[0]->{surveyJSON} );
#    $self->responseJSON( $ref->[0]->{responseJSON}, $rId );
#}

#-------------------------------------------------------------------

=head2 persistSurveyJSON ( )

Serializes the SurveyJSON instance and persists it to the database.

Calling this method is only required if you have directly accessed and modified 
the L<"surveyJSON"> object.

=cut

sub persistSurveyJSON {
    my $self = shift;

    my $data = $self->surveyJSON->freeze();
    $self->update({surveyJSON=>$data});
#    $self->session->db->write( 'update Survey set surveyJSON = ? where assetId = ?', [ $data, $self->getId ] );

    return;
}

#-------------------------------------------------------------------

=head3 persistResponseJSON

Turns the response object into JSON and saves it to the DB.  

=cut

sub persistResponseJSON {
    my $self = shift;
    my $data = $self->responseJSON->freeze();
    $self->session->db->write( 'update Survey_response set responseJSON = ? where Survey_responseId = ?', [ $data, $self->responseId ] );
    return;
}

#-------------------------------------------------------------------

=head2 responseId

Mutator for the responseIdCookies that determines whether cookies are used as
part of the L<"responseId"> lookup process.

Useful for disabling cookie operations during tests, since WebGUI::Test::getPage
currently does not support cookies.

=cut

sub responseIdCookies {
    my $self = shift;
    my ($x) = validate_pos(@_, {type => SCALAR, optional => 1});
    
    if (defined $x) {
        $self->{_responseIdCookies} = $x;
    }

    # Defaults to true..
    return defined $self->{_responseIdCookies} ? $self->{_responseIdCookies} : 1;
}

#-------------------------------------------------------------------

=head2 responseId( [userId] )

Accessor for the responseId property, which is the unique identifier for a single 
L<WebGUI::Asset::Wobject::Survey::ResponseJSON> instance. See also L<"responseJSON">.

The responseId of the current user is returned, or created if one does not already exist.
If the user is anonymous, the IP is used. Or an emailed or linked code can be used.

=head3 userId (optional)

If specified, this user is used rather than the current user 

=cut

sub responseId {
    my $self = shift;
    my ($userId) = validate_pos(@_, {type => SCALAR, optional => 1});
    
    my $user = WebGUI::User->new($self->session, $userId);

    if (!defined $self->{responseId}) {
    
        my $ip = $self->session->env->getIp;
        my $id = $userId || $self->session->user->userId;
        my $anonId = $self->session->form->process('userid');
        if ($self->responseIdCookies) {
            $anonId ||= $self->session->http->getCookies->{Survey2AnonId}; ## no critic
        }
        $anonId ||= undef;
        
        if ($self->responseIdCookies) {
            $anonId && $self->session->http->setCookie( Survey2AnonId => $anonId );
        }
    
        my ($responseId, $string);

        # if there is an anonid or id is for a WG user
        if ( $anonId or $id != 1 ) {
            $string = 'userId';
            if ($anonId) {
                $string = 'anonId';
                $id     = $anonId;
            }
            $responseId
                = $self->session->db->quickScalar(
                "select Survey_responseId from Survey_response where $string = ? and assetId = ? and isComplete = 0",
                [ $id, $self->getId() ] );
    
        }
        elsif ( $id == 1 ) {
            $responseId = $self->session->db->quickScalar(
                'select Survey_responseId from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete = 0',
                [ $id, $ip, $self->getId() ]
            );
        }
    
        if ( !$responseId ) {
            my $maxResponsesPerUser = $self->get('maxResponsesPerUser');
            my $haveTaken;
    
            if ( $id == 1 ) {
                $haveTaken
                    = $self->session->db->quickScalar(
                    'select count(*) from Survey_response where userId = ? and ipAddress = ? and assetId = ?',
                    [ $id, $ip, $self->getId() ] );
            }
            else {
                $haveTaken
                    = $self->session->db->quickScalar(
                    "select count(*) from Survey_response where $string = ? and assetId = ?",
                    [ $id, $self->getId() ] );
            }
    
            if ( $maxResponsesPerUser == 0 || $haveTaken < $maxResponsesPerUser ) {
                $responseId = $self->session->db->setRow(
                    'Survey_response',
                    'Survey_responseId', {
                        Survey_responseId => 'new',
                        userId            => $id,
                        ipAddress         => $ip,
                        username          => $user ? $user->username : $self->session->user->username,
                        startDate         => scalar time,                      #WebGUI::DateTime->now->toDatabase,
                        endDate           => 0,                                #WebGUI::DateTime->now->toDatabase,
                        assetId           => $self->getId(),
                        anonId            => $anonId
                    }
                );

                # Store the newly created responseId
                $self->{responseId} = $responseId;
                
                # Manually persist ResponseJSON since we have changed $self->responseId
                $self->persistResponseJSON();
            }
            else {
                $self->session->log->debug("haveTaken ($haveTaken) >= maxResponsesPerUser ($maxResponsesPerUser)");
            }
        }
        $self->{responseId} = $responseId;
    }
    return $self->{responseId};
}

#-------------------------------------------------------------------

=head2 canTakeSurvey

Determines if the current user has permissions to take the survey.

=cut

sub canTakeSurvey {
    my $self = shift;

    return $self->{canTake} if ( defined $self->{canTake} );

    if ( !$self->session->user->isInGroup( $self->get('groupToTakeSurvey') ) ) {
        return 0;
    }

    my $maxResponsesPerUser = $self->getValue('maxResponsesPerUser');
    my $ip                  = $self->session->env->getIp;
    my $userId              = $self->session->user->userId();
    my $takenCount          = 0;

    if ( $userId == 1 ) {
        $takenCount = $self->session->db->quickScalar(
            'select count(*) from Survey_response where userId = ? and ipAddress = ? '
            . 'and assetId = ? and isComplete > ?', [ $userId, $ip, $self->getId(), 0 ]
        );
    }
    else {
        $takenCount
            = $self->session->db->quickScalar(
            'select count(*) from Survey_response where userId = ? and assetId = ? and isComplete > ?',
            [ $userId, $self->getId(), 0 ] );
    }

    # A maxResponsesPerUser value of 0 implies unlimited
    if ( $maxResponsesPerUser > 0 && $takenCount >= $maxResponsesPerUser ) {
        $self->{canTake} = 0;
    }
    else {
        $self->{canTake} = 1;
    }
    return $self->{canTake};

}

#-------------------------------------------------------------------

=head2 www_viewGradeBook (){

Returns the Grade Book screen.

=cut

sub www_viewGradeBook {
    my $self    = shift;
    my $db      = $self->session->db;
    
    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToViewReports') );

    my $var = $self->getMenuVars;

    $self->loadTempReportTable();

    my $paginator = WebGUI::Paginator->new($self->session,$self->getUrl('func=viewGradebook'));
    $paginator->setDataByQuery('select userId,username,ipAddress,Survey_responseId,startDate,endDate'
        . ' from Survey_response where assetId='
        . $db->quote($self->getId)
        . ' order by username,ipAddress,startDate');
    my $users = $paginator->getPageData;

    $var->{question_count} = $self->surveyJSON->questionCount;
    
    my @responseloop;
    foreach my $user (@{$users}) {
        my ($correctCount) = $db->quickArray('select count(*) from Survey_tempReport'
            . ' where Survey_responseId=? and isCorrect=1',[$user->{Survey_responseId}]);
        push @responseloop, {
            # response_url is left out because it looks like Survey doesn't have a viewIndividualSurvey feature
            # yet.
            #'response_url'=>$self->getUrl('func=viewIndividualSurvey;responseId='.$user->{Survey_responseId}),
            'response_user_name'=>($user->{userId} eq '1') ? $user->{ipAddress} : $user->{username},
            'response_count_correct' => $correctCount,
            'response_percent' => round(($correctCount/$var->{question_count})*100)
            };
    }
    $var->{response_loop} = \@responseloop;
    $paginator->appendTemplateVars($var);

    my $out = $self->processTemplate( $var, $self->get('gradebookTemplateId') );
    return $self->session->style->process( $out, $self->get('styleTemplateId') );
}

#-------------------------------------------------------------------

=head2 www_viewStatisticalOverview (){

Returns the Statistical Overview screen.

=cut

sub www_viewStatisticalOverview {
    my $self    = shift;
    my $db      = $self->session->db;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToViewReports') );

    $self->loadTempReportTable();
    my $survey  = $self->surveyJSON;
    my $var     = $self->getMenuVars;
    
    my $paginator = WebGUI::Paginator->new($self->session,$self->getUrl('func=viewStatisticalOverview'));
    my @questionloop;
    for ( my $sectionIndex = 0; $sectionIndex <= $#{ $survey->sections() }; $sectionIndex++ ) {
        for ( my $questionIndex = 0; $questionIndex <= $#{ $survey->questions([$sectionIndex]) }; $questionIndex++ ) {
        my $question        = $survey->question( [ $sectionIndex, $questionIndex ] );
        my $questionType    = $question->{questionType};
        my (@answerloop, $totalResponses);;

        if ($questionType eq 'Multiple Choice'){
            $totalResponses = $db->quickScalar('select count(*) from Survey_tempReport'
                . ' where sectionNumber=? and questionNumber=?',[$sectionIndex,$questionIndex]);

            for ( my $answerIndex = 0; $answerIndex <= $#{ $survey->answers([$sectionIndex,$questionIndex]) }; $answerIndex++ ) {
                my $numResponses = $db->quickScalar('select count(*) from Survey_tempReport'
                    . ' where sectionNumber=? and questionNumber=? and answerNumber=?',
                    [$sectionIndex,$questionIndex,$answerIndex]);
                my $responsePercent;
                if ($totalResponses) {
                    $responsePercent = round(($numResponses/$totalResponses)*100);
                } else {
                    $responsePercent = 0;
                }
                my @commentloop;
                my $comments = $db->read('select answerComment from Survey_tempReport'
                    . ' where sectionNumber=? and questionNumber=? and answerNumber=?',
                    [$sectionIndex,$questionIndex,$answerIndex]);
                while (my ($comment) = $comments->array) {
                    push @commentloop,{
                        'answer_comment'=>$comment
                        };
                }
                push @answerloop,{
                    'answer_isCorrect'=>$survey->answer( [ $sectionIndex, $questionIndex, $answerIndex ] )->{isCorrect},
                    'answer' => $survey->answer( [ $sectionIndex, $questionIndex, $answerIndex ] )->{text},
                    'answer_response_count' =>$numResponses,
                    'answer_response_percent' =>$responsePercent,
                    'comment_loop'=>\@commentloop
                    };
            }
        }
        else{
            my $responses = $db->read('select value,answerComment from Survey_tempReport'
                . ' where sectionNumber=? and questionNumber=?',
                [$sectionIndex,$questionIndex]);
            while (my $response = $responses->hashRef) {
                push @answerloop,{
                    'answer_value'      =>$response->{value},
                    'answer_comment'    =>$response->{answerComment}
                    };
            }
        }
        push @questionloop, {
            question                  => $question->{text},
            question_id               => "${sectionIndex}_$questionIndex",
            question_isMultipleChoice => ($questionType eq 'Multiple Choice'),
            question_response_total   => $totalResponses,
            answer_loop               => \@answerloop,
            questionallowComment      => $question->{allowComment}
        };
        }
    }
    $paginator->setDataByArrayRef(\@questionloop);
    @questionloop = @{$paginator->getPageData};

    $var->{question_loop} = \@questionloop;
    $paginator->appendTemplateVars($var);

    my $out = $self->processTemplate( $var, $self->get('overviewTemplateId') );
    return $self->session->style->process( $out, $self->get('styleTemplateId') );
}

#-------------------------------------------------------------------
sub www_exportSimpleResults {
    my $self = shift;

    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToViewReports'));

    $self->loadTempReportTable();

    my $filename = $self->session->url->escape( $self->get('title') . '_results.tab' );
    my $content
        = $self->session->db->quickTab(
        'select * from Survey_tempReport t where t.assetId=? order by t.Survey_responseId, t.order',
        [ $self->getId() ] );
    return $self->export( $filename, $content );
}

#-------------------------------------------------------------------

=head2 www_exportTransposedResults (){

Returns transposed results as a tabbed file.

=cut

sub www_exportTransposedResults {
    my $self = shift;
    return $self->session->privilege->insufficient()
        if !$self->session->user->isInGroup( $self->get('groupToViewReports') );

    $self->loadTempReportTable();

    my $filename = $self->session->url->escape( $self->get('title') . '_transposedResults.tab' );
    my $content
        = $self->session->db->quickTab(
        'select r.userId, r.username, r.ipAddress, r.startDate, r.endDate, r.isComplete, t.*'
        . ' from Survey_tempReport t'
        . ' left join Survey_response r using(Survey_responseId)' 
        . ' where t.assetId=?'
        . ' order by r.userId, r.Survey_responseId, t.order',
        [ $self->getId() ] );
    return $self->export( $filename, $content );
}

#-------------------------------------------------------------------

=head2 export($filename,$content)

Exports the data in $content to $filename, then forwards the user to $filename.

=head3 $filename

The name of the file you want exported.

=head3 $content

The data you want exported (CSV, tab, whatever).

=cut

sub export {
    my $self     = shift;
    my $filename = shift;
    $filename =~ s/[^\w\d\.]/_/g;
    my $content = shift;

    # Create a temporary directory to store files if it doesn't already exist
    my $store    = WebGUI::Storage->createTemp( $self->session );
    my $tmpDir   = $store->getPath();
    my $filepath = $store->getPath($filename);
    if ( !open TEMP, ">$filepath" ) {
        return 'Error - Could not open temporary file for writing.  Please use the back button and try again';
    }
    print TEMP $content;
    close TEMP;
    my $fileurl = $store->getUrl($filename);

    $self->session->http->setRedirect($fileurl);

    return undef;
}

#-------------------------------------------------------------------

=head2 loadTempReportTable

Loads the responses from the survey into the Survey_tempReport table, so that other or custom reports can be ran against this data.

=cut

sub loadTempReportTable {
    my $self = shift;

    my $refs = $self->session->db->buildArrayRefOfHashRefs( 'select * from Survey_response where assetId = ?',
        [ $self->getId() ] );
    $self->session->db->write( 'delete from Survey_tempReport where assetId = ?', [ $self->getId() ] );
    for my $ref (@{$refs}) {
        $self->responseJSON( undef, $ref->{Survey_responseId} );
        my $count = 1;
        for my $q ( @{ $self->responseJSON->returnResponseForReporting() } ) {
            if ( @{ $q->{answers} } == 0 and $q->{comment} =~ /\w/ ) {
                $self->session->db->write(
                    'insert into Survey_tempReport VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $self->getId(),    $ref->{Survey_responseId}, $count++,           $q->{section},
                        $q->{sectionName}, $q->{question},            $q->{questionName}, $q->{questionComment},
                        undef,             undef,                     undef,              undef,
                        undef,             undef,                     undef
                    ]
                );
                next;
            }
            for my $a ( @{ $q->{answers} } ) {
                $self->session->db->write(
                    'insert into Survey_tempReport VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                        $self->getId(),    $ref->{Survey_responseId}, $count++,           $q->{section},
                        $q->{sectionName}, $q->{question},            $q->{questionName}, $q->{questionComment},
                        $a->{id},          $a->{value},               $a->{comment},      $a->{time},
                        $a->{isCorrect},   $a->{value},               undef
                    ]
                );
            }
        }
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 www_editDefaultQuestions

Allows a user to edit the *site wide* default multiple choice questions displayed when adding questions to a survey.

=cut

sub www_editDefaultQuestions{
    my $self = shift;
    my $warning = shift;
    my $session = $self->session;
    my ($output);
    my $bundleId = $session->form->process("bundleId");

    if($bundleId eq 'new'){



    }

    if($warning){$output .= "$warning";}
#    $output .= $tabForm->print;
    

}

1;
