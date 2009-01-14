package WebGUI::Asset::Wobject::Survey;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use base 'WebGUI::Asset::Wobject';
use WebGUI::Asset::Wobject::Survey::SurveyJSON;
use WebGUI::Asset::Wobject::Survey::ResponseJSON;

use Data::Dumper;

#-------------------------------------------------------------------
sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_Survey' );
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        templateId => {
            fieldType    => "template",
            defaultValue => 'PBtmpl0000000000000061',
            tab          => "display",
            namespace    => "Survey",
            hoverHelp    => "A Survey System",
            label        => "Template ID"
        },
        showProgress => {
            fieldType    => "yesNo",
            defaultValue => 0,
            tab          => 'properties',
            label        => "Show user their progress"
        },
        showTimeLimit => {
            fieldType    => "yesNo",
            defaultValue => 0,
            tab          => 'properties',
            label        => "Show user their time remaining"
        },
        timeLimit => {
            fieldType    => 'integer',
            defaultValue => 0,
            tab          => 'properties',
            hoverHelp    => $i18n->get('timelimit hoverHelp'),
            label        => $i18n->get('timelimit')
        },
        groupToEditSurvey => {
            fieldType    => 'group',
            defaultValue => 4,
            label        => "Group to edit survey",
        },
        groupToTakeSurvey => {
            fieldType    => 'group',
            defaultValue => 2,
            label        => "Group to take survey",
        },
        groupToViewReports => {
            fieldType    => 'group',
            defaultValue => 4,
            label        => "Group to view reports",
        },
        exitURL => {
            fieldType    => 'text',
            defaultValue => undef,
            label        => "Set the URL that the survey will exit to",
            hoverHelp =>
                "When the user finishes the survey, they will be sent to this URL.  Leave blank if no forwarding required.",
        },
        maxResponsesPerUser => {
            fieldType    => 'integer',
            defaultValue => 1,
            label        => "Max user reponses",
        },
        overviewTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            defaultValue => 'PBtmpl0000000000000063',
            label        => "Overview template id",
            namespace    => 'Survey/Overview',
        },
        gradebookTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Grabebook template id",
            defaultValue => 'PBtmpl0000000000000062',
            namespace    => 'Survey/Gradebook',
        },
        responseTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Response template id",
            defaultValue => 'PBtmpl0000000000000064',
            namespace    => 'Survey/Response',
        },
        surveyEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Survey edit template id",
            defaultValue => 'GRUNFctldUgop-qRLuo_DA',
            namespace    => 'Survey/Edit',
        },
        surveyTakeTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Take survey template id",
            defaultValue => 'd8jMMMRddSQ7twP4l1ZSIw',
            namespace    => 'Survey/Take',
        },
        surveyQuestionsId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Questions template id",
            defaultValue => 'CxMpE_UPauZA3p8jdrOABw',
            namespace    => 'Survey/Take',
        },
        sectionEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Section Edit Tempalte",
            defaultValue => '1oBRscNIcFOI-pETrCOspA',
            namespace    => 'Survey/Edit',
        },
        questionEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Question Edit Tempalte",
            defaultValue => 'wAc4azJViVTpo-2NYOXWvg',
            namespace    => 'Survey/Edit',
        },
        answerEditTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => "Answer Edit Tempalte",
            defaultValue => 'AjhlNO3wZvN5k4i4qioWcg',
            namespace    => 'Survey/Edit',
        },
    );

    push(
        @{$definition}, {
            assetName         => $i18n->get('assetName'),
            icon              => 'survey.gif',
            autoGenerateForms => 1,
            tableName         => 'Survey',
            className         => 'WebGUI::Asset::Wobject::Survey',
            properties        => \%properties
        }
    );
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 exportAssetData ( )

Override exportAssetData so that surveyJSON is included in package exports etc..

=cut

sub exportAssetData {
    my $self = shift;
    my $hash = $self->SUPER::exportAssetData();
    $self->loadSurveyJSON();
    $hash->{properties}{surveyJSON} = $self->survey->freeze;
    return $hash;
}

#-------------------------------------------------------------------

=head2 importAssetData ( hashRef )

Override importAssetCollateralData so that surveyJSON gets imported from packages

=cut

sub importAssetCollateralData {
    my ( $self, $data ) = @_;
    my $surveyJSON = $data->{properties}{surveyJSON};
    $self->session->db->write( "update Survey set surveyJSON = ? where assetId = ?", [ $surveyJSON, $self->getId ] );
}

#-------------------------------------------------------------------

=head2 duplicate ( )

Override duplicate so that surveyJSON gets duplicated too

=cut

sub duplicate {
    my $self     = shift;
    my $options  = shift;
    my $newAsset = $self->SUPER::duplicate($options);
    $self->loadSurveyJSON();
    $self->session->db->write( "update Survey set surveyJSON = ? where assetId = ?",
        [ $self->survey->freeze, $newAsset->getId ] );
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 loadSurveyJSON ( )

Loads the survey collateral into memory so that the survey objects can be created

=cut

sub loadSurveyJSON {
    my $self     = shift;
    my $jsonHash = shift;
    if ( defined $self->survey ) { return; }    #already loaded

    $jsonHash = $self->session->db->quickScalar( "select surveyJSON from Survey where assetId = ?", [ $self->getId ] )
        if ( !defined $jsonHash );

    $self->{survey} = WebGUI::Asset::Wobject::Survey::SurveyJSON->new( $jsonHash, $self->session->errorHandler );
}

#-------------------------------------------------------------------

=head2 saveSurveyJSON ( )

Saves the survey collateral to the DB

=cut

sub survey       { return shift->{survey}; }
sub littleBuddy  { return shift->{survey}; }
sub allyourbases { return shift->{survey}; }
sub helpmehelpme { return shift->{survey}; }

sub saveSurveyJSON {
    my $self = shift;

    my $data = $self->survey->freeze();

    $self->session->db->write( "update Survey set surveyJSON = ? where assetId = ?", [ $data, $self->getId ] );
}

#-------------------------------------------------------------------

=head2 www_editSurvey ( )

Loads the initial edit survey page.  All other edit actions are JSON calls from this page.

=cut

sub www_editSurvey {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    my %var;
    my $out = $self->processTemplate( \%var, $self->get("surveyEditTemplateId") );

    return $out;
}

#-------------------------------------------------------------------
sub www_submitObjectEdit {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    #    my $ref = @{from_json($self->session->form->process("data"))};
    my $responses = $self->session->form->paramsHashRef();

    my @address = split /-/, $responses->{id};

    $self->loadSurveyJSON();
    if ( $responses->{delete} ) {
        return $self->deleteObject( \@address );
    }
    elsif ( $responses->{copy} ) {
        return $self->copyObject( \@address );
    }

    #   each object checks the ref and then either updates or passes it to the correct child.  New objects will have an index of -1.
    my $message = $self->survey->update( \@address, $responses );

    $self->saveSurveyJSON();

    return $self->www_loadSurvey( { address => \@address } );
} ## end sub www_submitObjectEdit

#-------------------------------------------------------------------
=head2 Allow survey editors to "jump to" a particular section of question in a
Survey by tricking Survey into thinking they've completed the survey up to that
point. Useful for survey builders.
Note that calling this method will delete any existing survey responses for the
current user (although only survey builders can call this method so that shouldn't be
a problem
=cut

sub www_jumpTo {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    my $data = $self->session->form->paramsHashRef();

    $self->session->log->debug("jumpTo to $data->{id}");

    # Remove existing responses for current user
    $self->session->db->write( 'delete from Survey_response where assetId = ? and userId = ?',
        [ $self->getId, $self->session->user->userId() ] );
    my $responseId = $self->getResponseId();

    $self->loadBothJSON();

    # iterate over surveyOrder looking for the jumpTo target
    for my $i ( 0 .. $#{ $self->response->surveyOrder() } ) {
        my $address = $self->response->surveyOrder()->[$i];

        my @possibilities = (
            $self->survey->section($address),
            $self->survey->question($address),
        );
        foreach my $possibilty (@possibilities) {
            if ( ref $possibilty eq 'HASH' && $possibilty->{id} eq $data->{id} ) {
                $self->session->log->debug("Found jumpTo target");
                $self->response->lastResponse( $i - 1 );
                $self->saveResponseJSON();
                last;
            }
        }
    }
    $self->session->log->debug("Unable to find jumpTo target");

    return $self->www_takeSurvey;
}

#-------------------------------------------------------------------
sub copyObject {
    my ( $self, $address ) = @_;

    $self->loadSurveyJSON();

    #each object checks the ref and then either updates or passes it to the correct child.  New objects will have an index of -1.
    $address = $self->survey->copy($address);

    $self->saveSurveyJSON();

    #The parent address of the deleted object is returned.

    return $self->www_loadSurvey( { address => $address } );
}

#-------------------------------------------------------------------
sub deleteObject {
    my ( $self, $address ) = @_;

    $self->loadSurveyJSON();

    my $message = $self->survey->remove($address)
        ; #each object checks the ref and then either updates or passes it to the correct child.  New objects will have an index of -1.

    $self->saveSurveyJSON();

    #The parent address of the deleted object is returned.
    if ( @$address == 1 ) {
        $$address[0] = 0;
    }
    else {
        pop( @{$address} );    # unless @$address == 1 and $$address[0] == 0;
    }

    return $self->www_loadSurvey( { address => $address, message => $message } );
} ## end sub deleteObject

#-------------------------------------------------------------------
sub www_newObject {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    my $ref;

    my $ids = $self->session->form->process("data");

    my @inAddress = split /-/, $ids;

    $self->loadSurveyJSON();

    #Don't save after this as the new object should not stay in the survey
    my $address = $self->survey->newObject( \@inAddress );

    #The new temp object has an address of NEW, which means it is not a real final address.

    return $self->www_loadSurvey( { address => $address, message => undef } );

} ## end sub www_newObject

#-------------------------------------------------------------------
sub www_dragDrop {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    my $p = from_json( $self->session->form->process("data") );

    my @tid = split /-/, $p->{target}->{id};
    my @bid = split /-/, $p->{before}->{id};

    $self->loadSurveyJSON();
    my $target = $self->survey->getObject( \@tid );
    $self->survey->remove( \@tid, 1 );
    my $address = [0];
    if ( @tid == 1 ) {

        #sections can only be inserted after another section so chop off the question and answer portion of
        $#bid = 0;
        $bid[0] = -1 if ( !defined $bid[0] );
        $self->survey->insertObject( $target, [ $bid[0] ] );
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
                $bid[1] = $#{ $self->survey->questions( [ $bid[0] ] ) };
            }
        } ## end elsif ( @bid == 1 )
        $self->survey->insertObject( $target, [ $bid[0], $bid[1] ] );
    } ## end elsif ( @tid == 2 )
    elsif ( @tid == 3 ) {    #answers can only be rearranged in the same question
        if ( @bid == 2 and $bid[1] == $tid[1] ) {
            $bid[2] = -1;
            $self->survey->insertObject( $target, [ $bid[0], $bid[1], $bid[2] ] );
        }
        elsif ( @bid == 3 ) {
            $self->survey->insertObject( $target, [ $bid[0], $bid[1], $bid[2] ] );
        }
        else {

            #else put it back where it was
            $self->survey->insertObject( $target, \@tid );
        }
    }

    $self->saveSurveyJSON();

    return $self->www_loadSurvey( { address => $address } );
} ## end sub www_dragDrop

#-------------------------------------------------------------------
sub www_loadSurvey {
    my ( $self, $options ) = @_;
    my $editflag = 1;

    $self->loadSurveyJSON();

    my $address = defined $options->{address} ? $options->{address} : undef;
    if ( !defined $address ) {
        if ( my $inAddress = $self->session->form->process("data") ) {
            if( $inAddress eq '-' ) {
                 $editflag = 0;
		 $address = [ 0 ];
            } else {
		$address = [ split /-/, $inAddress ];
	    }
        }
        else {
            $address = [0];
        }
    }
    my $message = defined $options->{message} ? $options->{message} : '';
    my $var
        = defined $options->{var}
        ? $options->{var}
        : $self->survey->getEditVars($address);

    my $editHtml;
    if ( $var->{type} eq 'section' ) {
        $editHtml = $self->processTemplate( $var, $self->get("sectionEditTemplateId") );
    }
    elsif ( $var->{type} eq 'question' ) {
        $editHtml = $self->processTemplate( $var, $self->get("questionEditTemplateId") );
    }
    elsif ( $var->{type} eq 'answer' ) {
        $editHtml = $self->processTemplate( $var, $self->get("answerEditTemplateId") );
    }

    # Generate the list of valid goto targets
    my @gotoTargets = $self->survey->getGotoTargets;

    my %buttons;
    $buttons{question} = $$address[0];
    if ( @$address == 2 or @$address == 3 ) {
        $buttons{answer} = "$$address[0]-$$address[1]";
    }

    my $data = $self->survey->getDragDropList($address);
    my $html;
    my ( $scount, $qcount, $acount ) = ( -1, -1, -1 );
    my $lastType;
    my %lastId;
    my @ids;
    my ( $s, $q, $a ) = ( 0, 0, 0 );    #bools on if a button has already been created

    foreach (@$data) {
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
            push( @ids, "$scount-$qcount" );
            $lastType = 'question';
            $acount   = -1;
        }
        elsif ( $_->{type} eq 'answer' ) {
            $lastId{answer} = ++$acount;
            $html .= "<li id='$scount-$qcount-$acount' class='answer'>A" . ( $acount + 1 ) . ": $_->{text}<\/li><br>\n";
            push( @ids, "$scount-$qcount-$acount" );
            $lastType = 'answer';
        }
    } ## end foreach (@$data)

    #address is the address of the focused object
    #buttons are the data to create the Add buttons
    #edithtml is the html edit the object
    #ddhtml is the html to create the draggable html divs
    #ids is a list of all ids passed in which are draggable (for adding events)
    #type is the object type
    my $return = {
        "address", $address, "buttons", \%buttons,
        "edithtml", $editflag ? $editHtml : '',
        "ddhtml",  $html,    "ids",     \@ids,     "type",     $var->{type}
        ,gotoTargets => \@gotoTargets,
    };
    $self->session->http->setMimeType('application/json');
    return to_json($return);
} ## end sub www_loadSurvey

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $templateId = $self->get("templateId");
    if ( $self->session->form->process("overrideTemplateId") ne "" ) {
        $templateId = $self->session->form->process("overrideTemplateId");
    }
    my $template = WebGUI::Asset::Template->new( $self->session, $templateId );
    $template->prepare;
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

sub purge {
    my $self = shift;
    $self->session->db->write( "delete from Survey_response where assetId = ?",   [ $self->getId() ] );
    $self->session->db->write( "delete from Survey_tempReport where assetId = ?", [ $self->getId() ] );
    $self->session->db->write( "delete from Survey where assetId = ?",            [ $self->getId() ] );
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
    my $self = shift;
    WebGUI::Cache->new( $self->session, "view_" . $self->getId )->delete;
    $self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

sub purgeRevision {
    my $self = shift;
    return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
    my $self = shift;
    my %var;

    $var{'edit_survey_url'}               = $self->getUrl('func=editSurvey');
    $var{'take_survey_url'}               = $self->getUrl('func=takeSurvey');
    $var{'view_simple_results_url'}       = $self->getUrl('func=exportSimpleResults');
    $var{'view_transposed_results_url'}   = $self->getUrl('func=exportTransposedResults');
    $var{'view_statistical_overview_url'} = $self->getUrl('func=viewStatisticalOverview');
    $var{'view_grade_book_url'}           = $self->getUrl('func=viewGradeBook');
    $var{'user_canTakeSurvey'}            = $self->session->user->isInGroup( $self->get("groupToTakeSurvey") );
    $var{'user_canViewReports'}           = $self->session->user->isInGroup( $self->get("groupToViewReports") );
    $var{'user_canEditSurvey'}            = $self->session->user->isInGroup( $self->get("groupToEditSurvey") );
    $var{'user_canEditSurvey'}            = $self->session->user->isInGroup( $self->get("groupToEditSurvey") );
    my ( $code, $overTakeLimit ) = $self->getResponseInfoForView();
    $var{'lastResponseCompleted'} = $code;
    $var{'lastResponseTimedOut'}  = $code > 1 ? 1 : 0;
    $var{'maxResponsesSubmitted'} = $overTakeLimit;
    my $out = $self->processTemplate( \%var, undef, $self->{_viewTemplate} );

    return $out;
} ## end sub view

#-------------------------------------------------------------------

=head2 getResponseInfoForView ( )

Looks to see if this user has a response, looks at the last one to see if it was completed or timed out.
Then it checks to see if the user has reached the max number of responses.

=cut

sub getResponseInfoForView {
    my $self = shift;

    my ( $code, $taken );

    my $maxTakes = $self->getValue("maxResponsesPerUser");
    my $id       = $self->session->user->userId();
    my $anonId 
        = $self->session->form->process("userid")
        || $self->session->http->getCookies->{"Survey2AnonId"}
        || undef;
    $self->session->http->setCookie( "Survey2AnonId", $anonId ) if ($anonId);
    my $ip = $self->session->env->getIp;
    my $string;

    #if there is an anonid or id is for a WG user
    if ( $anonId or $id != 1 ) {
        $string = 'userId';
        if ($anonId) {
            $string = 'anonId';
            $id     = $anonId;
        }
        my $responseId
            = $self->session->db->quickScalar(
            "select Survey_responseId from Survey_response where $string = ? and assetId = ? and isComplete = 0",
            [ $id, $self->getId() ] );
        if ( !$responseId ) {
            $code = $self->session->db->quickScalar(
                "select isComplete from Survey_response where $string = ? and assetId = ? and isComplete > 0 order by endDate desc limit 1",
                [ $id, $self->getId() ]
            );
        }
        $taken
            = $self->session->db->quickScalar(
            "select count(*) from Survey_response where $string = ? and assetId = ? and isComplete > 0",
            [ $id, $self->getId() ] );

    } ## end if ( $anonId or $id !=...
    elsif ( $id == 1 ) {
        my $responseId = $self->session->db->quickScalar(
            "select Survey_responseId from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete = 0",
            [ $id, $ip, $self->getId() ]
        );
        if ( !$responseId ) {
            $code = $self->session->db->quickScalar(
                "select isComplete from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete > 0 order by endDate desc limit 1",
                [ $id, $ip, $self->getId() ]
            );
        }
        $taken = $self->session->db->quickScalar(
            "select count(*) from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete > 0",
            [ $id, $ip, $self->getId() ]
        );
    } ## end elsif ( $id == 1 )
    return ( $code, $taken >= $maxTakes );
} ## end sub getResponseInfoForView

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
    my $self = shift;
    $self->SUPER::www_view(@_);
}

#-------------------------------------------------------------------
sub www_takeSurvey {
    my $self = shift;
    my %var;

    eval {
        my $responseId = $self->getResponseId();
        if ( !$responseId ) {
            $self->session->log->debug('No responseId, surveyEnd');

            #            return $self->surveyEnd(); # disabled. let the js handle the exitUrl redirection
        }
        else {
            $self->session->log->debug("ResponseId: $responseId");
        }
    };

    my $out = $self->processTemplate( \%var, $self->get("surveyTakeTemplateId") );
    return $self->session->style->process( $out, $self->get("styleTemplateId") );
} ## end sub www_takeSurvey

#-------------------------------------------------------------------
sub www_deleteResponses {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get('groupToEditSurvey') ) );

    $self->session->db->write( 'delete from Survey_response where assetId = ?', [ $self->getId ] );

    return;
}

#handles questions that were submitted
#-------------------------------------------------------------------
sub www_submitQuestions {
    my $self = shift;

    if ( !$self->canTakeSurvey() ) {
        $self->session->log->debug('canTakeSurvey false, surveyEnd');
        return $self->surveyEnd();
    }

    my $responseId = $self->getResponseId();
    if ( !$responseId ) {
        $self->session->log->debug('No response id, surveyEnd');
        return $self->surveyEnd();
    }

    my $responses = $self->session->form->paramsHashRef();
    delete $$responses{'func'};

    my @goodResponses = keys %$responses;    #load everything.

    $self->loadBothJSON();

    my $termInfo = $self->response->recordResponses( $self->session, $responses );

    $self->saveResponseJSON();

    if ( $termInfo->[0] ) {
        $self->session->log->debug('Terminal, surveyEnd');
        return $self->surveyEnd( $termInfo->[1] );
    }

    return $self->www_loadQuestions();

    my $files = 0;

    #    for my $id(@$orderOf){
    #if a file upload, write to disk
    #        my $path;
    #        if($id->{'questionType'} eq 'File Upload'){
    #            $files = 1;
    #            my $storage = WebGUI::Storage->create($self->session);
    #            my $filename = $storage->addFileFromFormPost( $id->{'Survey_answerId'} );
    #            $path = $storage->getPath($filename);
    #        }
    #$self->session->errorHandler->error("Inserting a response ".$id->{'Survey_answerId'}." $responseId, $path, ".$$responses{$id->{'Survey_answerId'}});
    #        $self->session->db->write("insert into Survey_questionResponse
    #            select ?, Survey_sectionId, Survey_questionId, Survey_answerId, ?, ?, ?, now(), ?, ? from Survey_answer where Survey_answerId = ?",
    #            [$self->getId(), $responseId, $$responses{ $id->{'Survey_answerId'} }, '', $path, ++$lastOrder, $id->{'Survey_answerId'}]);
    #    }
    if ($files) {
        ##special case, need to check for more questions in section, if not, more current up one
        my $lastA      = $self->getLastAnswerInfo($responseId);
        my $questionId = $self->getNextQuestionId( $lastA->{'Survey_questionId'} );
        if ( !$questionId ) {
            my $currentSection = $self->getCurrentSection($responseId);
            $currentSection = $self->getNextSection($currentSection);
            if ($currentSection) {
                $self->setCurrentSection( $responseId, $currentSection );
            }
        }
        return;
    }
    return $self->www_loadQuestions($responseId);
} ## end sub www_submitQuestions

#finds the questions to display next and builds the data structre to hold them
#-------------------------------------------------------------------
sub www_loadQuestions {
    my $self = shift;

    if ( !$self->canTakeSurvey() ) {
        $self->session->log->debug('canTakeSurvey false, surveyEnd');
        return $self->surveyEnd();
    }

    my $responseId = $self->getResponseId();    #also loads the survey and response
    if ( !$responseId ) {
        $self->session->log->debug('No responseId, surveyEnd');
        return $self->surveyEnd();
    }
    if ( $self->response->hasTimedOut( $self->get('timeLimit') ) ) {
        $self->session->log->debug('Response hasTimedOut, surveyEnd');
        return $self->surveyEnd( undef, 2 );
    }

    if ( $self->response->surveyEnd() ) {
        $self->session->log->debug('Response surveyEnd, so calling surveyEnd');
        return $self->surveyEnd();
    }

    my $questions;
    eval { $questions = $self->response->nextQuestions(); };

    my $section = $self->response->nextSection();

    #return $self->prepareShowSurveyTemplate($section,$questions);
    $section->{id} = $self->response->nextSectionId();
    my $text = $self->prepareShowSurveyTemplate( $section, $questions );
    return $text;
} ## end sub www_loadQuestions

#-------------------------------------------------------------------

#called when the survey is over.

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

    if ( my $responseId = $self->getResponseId() ) {    #also loads the survey and response
         #    $self->session->db->write("update Survey_response set endDate = ? and isComplete > 0 where Survey_responseId = ?",[WebGUI::DateTime->now->toDatabase,$responseId]);
        $self->session->db->setRow(
            "Survey_response",
            "Survey_responseId", {
                Survey_responseId => $responseId,
                endDate           => time(),         #WebGUI::DateTime->now->toDatabase,
                isComplete        => $completeCode
            }
        );
    }
    if ( $url !~ /\w/ ) { $url = 0; }
    if ( $url eq "undefined" ) { $url = 0; }
    if ( !$url ) {
        $url
            = $self->session->db->quickScalar(
            "select exitURL from Survey where assetId = ? order by revisionDate desc limit 1",
            [ $self->getId() ] );
        if ( !$url ) {
            $url = "/";
        }
    }

    #    $self->session->http->setRedirect($url);
    return to_json( { "type", "forward", "url", $url } );
} ## end sub surveyEnd

#-------------------------------------------------------------------
#sends the processed template and questions structure to the client
sub prepareShowSurveyTemplate {
    my ( $self, $section, $questions ) = @_;
    my %multipleChoice = (
        'Multiple Choice', 1, 'Gender',        1, 'Yes/No',     1, 'True/False', 1, 'Ideology',       1,
        'Race',            1, 'Party',         1, 'Education',  1, 'Scale',      1, 'Agree/Disagree', 1,
        'Oppose/Support',  1, 'Importance',    1, 'Likelihood', 1, 'Certainty',  1, 'Satisfaction',   1,
        'Confidence',      1, 'Effectiveness', 1, 'Concern',    1, 'Risk',       1, 'Threat',         1,
        'Security',        1
    );
    my %text = ( 'Text', 1, 'Email', 1, 'Phone Number', 1, 'Text Date', 1, 'Currency', 1 );
    my %slider = ( 'Slider', 1, 'Dual Slider - Range', 1, 'Multi Slider - Allocate', 1 );
    my %dateType   = ( 'Date',        1, 'Date Range', 1 );
    my %fileUpload = ( 'File Upload', 1 );
    my %hidden     = ( 'Hidden',      1 );

    foreach my $q (@$questions) {
        if    ( $fileUpload{ $$q{'questionType'} } ) { $q->{'fileLoader'} = 1; }
        elsif ( $text{ $$q{'questionType'} } )       { $q->{'textType'}   = 1; }
        elsif ( $hidden{ $$q{'questionType'} } )     { $q->{'hidden'}     = 1; }
        elsif ( $multipleChoice{ $$q{'questionType'} } ) {
            $q->{'multipleChoice'} = 1;
            if ( $$q{'maxAnswers'} > 1 ) {
                $q->{'maxMoreOne'} = 1;
            }
        }
        elsif ( $dateType{ $$q{'questionType'} } ) {
            $q->{'dateType'} = 1;
        }
        elsif ( $slider{ $$q{'questionType'} } ) {
            $q->{'slider'} = 1;
            if ( $$q{'questionType'} eq 'Dual Slider - Range' ) {
                $q->{'dualSlider'} = 1;
                $q->{'a1'}         = [ $q->{'answers'}->[0] ];
                $q->{'a2'}         = [ $q->{'answers'}->[1] ];
            }
        }

        if ( $$q{'verticalDisplay'} ) {
            $$q{'verts'} = "<p>";
            $$q{'verte'} = "</p>";
        }
    } ## end foreach my $q (@$questions)
    $section->{'questions'}         = $questions;
    $section->{'questionsAnswered'} = $self->response->{questionsAnswered};
    $section->{'totalQuestions'}    = @{ $self->response->surveyOrder };
    $section->{'showProgress'}      = $self->get('showProgress');
    $section->{'showTimeLimit'}     = $self->get('showTimeLimit');
    $section->{'minutesLeft'}
        = int( ( ( $self->response->startTime() + ( 60 * $self->get('timeLimit') ) ) - time() ) / 60 );

    if(scalar @$questions == ($section->{'totalQuestions'} - $section->{'questionsAnswered'})){
        $section->{isLastPage} = 1
    }

    my $out = $self->processTemplate( $section, $self->get("surveyQuestionsId") );

    $self->session->http->setMimeType('application/json');
    return to_json( { "type", "displayquestions", "section", $section, "questions", $questions, "html", $out } );
} ## end sub prepareShowSurveyTemplate

#-------------------------------------------------------------------

sub loadBothJSON {
    my $self = shift;
    my $rId  = shift;
    if ( defined $self->survey and defined $self->response ) { return; }
    my $ref = $self->session->db->buildArrayRefOfHashRefs( "
        select s.surveyJSON,r.responseJSON 
        from Survey s, Survey_response r 
        where s.assetId = ? and r.Survey_responseId = ?",
        [ $self->getId, $rId ] );
    $self->loadSurveyJSON( $ref->[0]->{surveyJSON} );
    $self->loadResponseJSON( $ref->[0]->{responseJSON}, $rId );
}

#-------------------------------------------------------------------
sub loadResponseJSON {
    my $self     = shift;
    my $jsonHash = shift;
    my $rId      = shift;
    $rId = defined $rId ? $rId : $self->{responseId};
    if ( defined $self->response and !defined $rId ) { return; }

    $jsonHash
        = $self->session->db->quickScalar(
        "select responseJSON from Survey_response where assetId = ? and Survey_responseId = ?",
        [ $self->getId, $rId ] )
        if ( !defined $jsonHash );

    $self->{response}
        = WebGUI::Asset::Wobject::Survey::ResponseJSON->new( $jsonHash, $self->session->errorHandler, $self->survey );
} ## end sub loadResponseJSON

#-------------------------------------------------------------------
sub saveResponseJSON {
    my $self = shift;

    my $data = $self->response->freeze();

    $self->session->db->write( "update Survey_response set responseJSON = ? where Survey_responseId = ?",
        [ $data, $self->{responseId} ] );
}

#-------------------------------------------------------------------
sub response {
    my $self = shift;
    return $self->{response};
}

#-------------------------------------------------------------------

sub getResponseId {
    my $self = shift;
    return $self->{responseId} if ( defined $self->{responseId} );

    my $ip = $self->session->env->getIp;
    my $id = $self->session->user->userId();
    my $anonId 
        = $self->session->form->process("userid")
        || $self->session->http->getCookies->{"Survey2AnonId"}
        || undef;
    $self->session->http->setCookie( "Survey2AnonId", $anonId ) if ($anonId);

    my $responseId;

    my $string;

    #if there is an anonid or id is for a WG user
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
            "select Survey_responseId from Survey_response where userId = ? and ipAddress = ? and assetId = ? and isComplete = 0",
            [ $id, $ip, $self->getId() ]
        );
    }

    if ( !$responseId ) {
        my $allowedTakes
            = $self->session->db->quickScalar(
            "select maxResponsesPerUser from Survey where assetId = ? order by revisionDate desc limit 1",
            [ $self->getId() ] );
        my $haveTaken;

        if ( $id == 1 ) {
            $haveTaken
                = $self->session->db->quickScalar(
                "select count(*) from Survey_response where userId = ? and ipAddress = ? and assetId = ?",
                [ $id, $ip, $self->getId() ] );
        }
        else {
            $haveTaken
                = $self->session->db->quickScalar(
                "select count(*) from Survey_response where $string = ? and assetId = ?",
                [ $id, $self->getId() ] );
        }

        if ( $haveTaken < $allowedTakes ) {
            my $time = time();
            $responseId = $self->session->db->setRow(
                "Survey_response",
                "Survey_responseId", {
                    Survey_responseId => "new",
                    userId            => $id,
                    ipAddress         => $ip,
                    username          => $self->session->user->username,
                    startDate         => $time,                            #WebGUI::DateTime->now->toDatabase,
                    endDate           => 0,                                #WebGUI::DateTime->now->toDatabase,
                    assetId           => $self->getId(),
                    anonId            => $anonId
                }
            );
            $self->loadBothJSON($responseId);
            $self->response->createSurveyOrder();
            $self->{responseId} = $responseId;
            $self->saveResponseJSON();

        } ## end if ( $haveTaken < $allowedTakes)
        else {
            $self->session->log->debug("haveTaken ($haveTaken) >= allowedTakes ($allowedTakes)");
        }
    } ## end if ( !$responseId )
    $self->{responseId} = $responseId;
    $self->loadBothJSON($responseId);
    return $responseId;
} ## end sub getResponseId

#-------------------------------------------------------------------

sub canTakeSurvey {
    my $self = shift;

    return $self->{canTake} if ( defined $self->{canTake} );

    if ( !$self->session->user->isInGroup( $self->get("groupToTakeSurvey") ) ) {
        return 0;
    }

    #Does user have too many finished survey responses
    my $maxTakes   = $self->getValue("maxResponsesPerUser");
    my $ip         = $self->session->env->getIp;
    my $id         = $self->session->user->userId();
    my $takenCount = 0;

    if ( $id == 1 ) {
        $takenCount = $self->session->db->quickScalar(
            "select count(*) from Survey_response where userId = ? and ipAddress = ? and assetId = ? 
                and isComplete > ?", [ $id, $ip, $self->getId(), 0 ]
        );
    }
    else {
        $takenCount
            = $self->session->db->quickScalar(
            "select count(*) from Survey_response where userId = ? and assetId = ? and isComplete > ?",
            [ $id, $self->getId(), 0 ] );
    }

    if ( $takenCount >= $maxTakes ) {
        $self->{canTake} = 0;
    }
    else {
        $self->{canTake} = 1;
    }
    return $self->{canTake};

} ## end sub canTakeSurvey

#-------------------------------------------------------------------
sub www_viewGradeBook {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get("groupToViewReports") ) );

    $self->loadTempReportTable();

    my @peoples
        = $self->session->db->quickArray( "SELECT UNIQUE(Survey_responseId) from Survey_tempReport where assetId = ?",
        [ $self->getId() ] );
    for my $people (@peoples) {

        #my $

    }

} ## end sub www_viewGradeBook

#-------------------------------------------------------------------
sub www_exportSimpleResults {
    my $self = shift;

    return $self->session->privilege->insufficient()
        unless ( $self->session->user->isInGroup( $self->get("groupToViewReports") ) );

    $self->loadTempReportTable();

    my $filename = $self->session->url->escape( $self->get("title") . "_results.tab" );
    my $content
        = $self->session->db->quickTab(
        "select * from Survey_tempReport t where t.assetId=? order by t.Survey_responseId, t.order",
        [ $self->getId() ] );
    return $self->export( $filename, $content );
}

#-------------------------------------------------------------------
sub export {
    my $self     = shift;
    my $filename = shift;
    $filename =~ s/[^\w\d\.]/_/g;
    my $content = shift;

    #Create a temporary directory to store files if it doesn't already exist
    my $store    = WebGUI::Storage->createTemp( $self->session );
    my $tmpDir   = $store->getPath();
    my $filepath = $store->getPath($filename);
    unless ( open TEMP, ">$filepath" ) {
        return "Error - Could not open temporary file for writing.  Please use the back button and try again";
    }
    print TEMP $content;
    close TEMP;
    my $fileurl = $store->getUrl($filename);

    $self->session->http->setRedirect($fileurl);

    return undef;
} ## end sub export

sub loadTempReportTable {
    my $self = shift;

    $self->loadSurveyJSON();
    my $refs = $self->session->db->buildArrayRefOfHashRefs( "select * from Survey_response where assetId = ?",
        [ $self->getId() ] );
    $self->session->db->write( "delete from Survey_tempReport where assetId = ?", [ $self->getId() ] );
    for my $ref (@$refs) {
        $self->loadResponseJSON( undef, $ref->{Survey_responseId} );
        my $count = 1;
        for my $q ( @{ $self->response->returnResponseForReporting() } ) {
            if ( @{ $q->{answers} } == 0 and $q->{comment} =~ /\w/ ) {
                $self->session->db->write(
                    "insert into Survey_tempReport VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [
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
                    "insert into Survey_tempReport VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [
                        $self->getId(),    $ref->{Survey_responseId}, $count++,           $q->{section},
                        $q->{sectionName}, $q->{question},            $q->{questionName}, $q->{questionComment},
                        $a->{id},          $a->{value},               $a->{comment},      $a->{time},
                        $a->{isCorrect},   $a->{value},               undef
                    ]
                );
            }
        } ## end for my $q ( @{ $self->response...
    } ## end for my $ref (@$refs)
    return 1;
} ## end sub loadTempReportTable

sub log {
    my $self = shift;
    $self->session->log->debug(shift);
}

1;
