package WebGUI::Asset::Wobject::Poll;


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
use List::Util;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Image::Graph;
use WebGUI::Storage;
use JSON;
use Try::Tiny;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_Poll'];
define tableName => 'Poll';
define icon      => 'poll.gif';
property templateId => (
                tab          => 'display',
                fieldType    => "template",
                default      => 'PBtmpl0000000000000055',
                label        => [73, 'Asset_Poll'],
                hoverHelp    => ['73 description', 'Asset_Poll'],
                namespace    => "Poll",
         );
property active => (
                tab          => 'properties',
                fieldType    => "yesNo",
                default      => 1,
                label        => [3, 'Asset_Poll'],
                hoverHelp    => ['3 description', 'Asset_Poll'],
            );
property karmaPerVote => (
                fieldType    => 'integer',
                noFormPost   => \&_karmaPerVote_noFormPost,
                default      => 0,
                label        => [20, 'Asset_Poll'],
                hoverHelp    => ['20 description', 'Asset_Poll'],
         ); 
sub _karmaPerVote_noFormPost {
    my $self = shift;
    return ! $self->session->setting->get('useKarma');
}
property graphWidth => (
                fieldType    => "integer",
                default      => 150,
                label        => [5, 'Asset_Poll'],
                hoverHelp    => ['5 description', 'Asset_Poll'],
         ); 
property voteGroup => (
                tab          => 'security',
                fieldType    => "group",
                default      => 7,
                label        => [4, 'Asset_Poll'],
                hoverHelp    => ['4 description', 'Asset_Poll'],
         ); 
property question => (
                tab          => 'properties',
                fieldType    => "text",
                default      => undef,
                label        => [6, 'Asset_Poll'],
                hoverHelp    => ['6 description', 'Asset_Poll'],
         ); 
property randomizeAnswers => (
                tab          => 'properties',
                fieldType    => "yesNo",
                default      => 1,
                label        => [72, 'Asset_Poll'],
                hoverHelp    => ['72 description', 'Asset_Poll'],
         );
property a1 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a2 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a3 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a4 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a5 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a6 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a7 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a8 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a9 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a10 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a11 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a12 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a13 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a14 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a15 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a16 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a17 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a18 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a19 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property a20 => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property graphConfiguration => (
    fieldType  => "hidden",
    default    => undef,
    noFormPost => 1,
);
property generateGraph => (
                noFormPost   => \&_generateGraph_noFormPost,
                fieldType    => 'yesNo',
                default      => 0,
                label        => ['generate graph', 'Asset_Poll'],
                hoverHelp    => ['generate graph description', 'Asset_Poll'],
         );
sub _generateGraph_noFormPost {
    my $self = shift;
    return WebGUI::Image::Graph->getPluginList($self->session) ? 1 : 0;
}
#-------------------------------------------------------------------
sub _hasVoted {
	my $self = shift;
	my ($hasVoted) = $self->session->db->quickArray("select count(*) from Poll_answer 
		where assetId=".$self->session->db->quote($self->getId)." and ((userId=".$self->session->db->quote($self->session->user->userId)."
		and userId<>'1') or (userId=".$self->session->db->quote($self->session->user->userId)." and ipAddress='".$self->session->request->address."'))");
	return $hasVoted;
}

#-------------------------------------------------------------------

=head2 duplicate 

Extend the base method to handle copying Poll answer data.

=cut

override duplicate => sub {
	my $self = shift;
	my $newAsset = super();
	my $sth = $self->session->db->read("select * from Poll_answer where assetId=?", [$self->getId]);
	while (my $data = $sth->hashRef) {
		$newAsset->setVote($data->{answer}, $data->{userId}, $data->{ipAddress});
	}
	$sth->finish;
	return $newAsset;
};

#----------------------------------------------------------------------------

=head2 freezeGraphConfig 

Serializes graph configuration. Returns a scalar containing the serialized
structure.

=cut

sub freezeGraphConfig {
    my $self        = shift;
    my $obj         = shift;
    
    return JSON::to_json($obj);
}


#-------------------------------------------------------------------

=head2 getEditForm 

Extend the base class to handle the answers and graphing plugins.

=cut

##TODO: Pull out all form elements which can come from the definition sub
##and only have hand code in here.

override getEditForm => sub {
	my $self = shift;
	my $fb = super(); 
	my $i18n = WebGUI::International->new($self->session,"Asset_Poll");
    my ($i, $answers);
    for ($i=1; $i<=20; $i++) {
        if ($self->get('a'.$i) =~ /\C/) {
            $answers .= $self->get("a".$i)."\n";
        }
    }
    $fb->getTab("properties")->addField( "textarea", 
		name=>"answers",
		label=>$i18n->get(7),
		hoverHelp=>$i18n->get('7 description'),
		subtext=>('<span class="formSubtext"><br />'.$i18n->get(8).'</span>'),
		value=>$answers
    );
	$fb->getTab("properties")->addField( "YesNo", 
		name=>"resetVotes",
		label=>$i18n->get(10),
		hoverHelp=>$i18n->get('10 description')
		) if $self->session->form->process("func") ne 'add';


	if (WebGUI::Image::Graph->getPluginList($self->session)) {
		my $config = $self->getGraphConfig;

		$fb->addTab(name => 'graph', label => $i18n->get('Graphing','Image_Graph'));
		$fb->getTab('graph')->addField( "yesNo", 
			name		=> 'generateGraph',
			label		=> $i18n->get('generate graph'),
			hoverHelp	=> $i18n->get('generate graph description'),
			value		=> $self->generateGraph,
		);
                # TODO: Fix graphing plugins to use FormBuilder API
		$fb->getTab('graph')->addField(
            'ReadOnly', 
            value => WebGUI::Image::Graph->getGraphingTab($self->session, $config)
        );

	}

	return $fb;
};

#----------------------------------------------------------------------------

=head2 getGraphConfig

Gets and thaws the graph configuration. Returns a reference to the original
data structure.

=cut

sub getGraphConfig {
    my $self    = shift;
    my $config  = $self->get("graphConfiguration");

    return undef unless $config;
    return $self->thawGraphConfig($config);
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing question and answers. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
	$indexer->addKeywords($self->get("question")." ".$self->get("answers"));
};


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 processEditForm 

Extend the base method to handle the answers and the Graphing plugin.

=cut

override processEditForm => sub {
	my $self = shift;
	super();
	my $property = {};
    my $answers = $self->session->form->process("answers");
    $answers =~ s{\r}{}xmsg;
    my @answer = split("\n",$answers);
    for (my $i=1; $i<=20; $i++) {
        $property->{'a'.$i} = $answer[($i-1)] || "";
    }

	if (WebGUI::Image::Graph->getPluginList($self->session)) {
        my $graph;
        try {
		    $graph = WebGUI::Image::Graph->processConfigurationForm($self->session);
        } catch {
            $self->session->log->error( "Graph plugin not available or not functional:  Error: ``$_''" );
        };
        if( $graph ) {
		    $self->setGraphConfig( $graph->getConfiguration );
        }
	}

	$self->update($property);
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId)) if ($self->session->form->process("resetVotes"));
};


#-------------------------------------------------------------------

=head2 purge 

Extend the base method to handle Poll answers.

=cut

override purge => sub {
	my $self = shift;
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	super();
};	

#----------------------------------------------------------------------------

=head2 setGraphConfig

Freezes and stores the configuration for the graphing of this poll. 

=cut

sub setGraphConfig {
    my $self    = shift;
    my $obj     = shift;

    $self->update({
        graphConfiguration  => $self->freezeGraphConfig($obj),
    });
}

#-------------------------------------------------------------------

=head2 setVote ($answer, $userId, $ip)

Accumulates a vote into the database so that it can be counted.

=head3 $answer

The answer selected by the user.

=head3 $userid

The userId of the person who voted.

=head3 $ip

The IP address of the user who voted.

=cut

sub setVote {
    my $self = shift;
    my $answer = shift;
    my $userId = shift;
    my $ip = shift;
    $self->session->db->write("insert into Poll_answer (assetId, answer, userId, ipAddress) values (?,?,?,?)",
        [$self->getId, $answer, $userId, $ip] );
}

#----------------------------------------------------------------------------

=head2 thawGraphConfig 

Deserializes the graph configuration and returns the data structure.

=cut

sub thawGraphConfig {
    my $self        = shift;
    my $string      = shift;
    
    return unless $string;
    return JSON::from_json($string);
}

#-------------------------------------------------------------------

=head2 view 

Generate the poll results with graph if configured to do so.  Display the form
for the user to vote.

=cut

sub view {
	my $self = shift;
	my (%var, $answer, @answers, $showPoll, $f, @dataset, @labels);
        $var{question} = $self->get("question");
	if ($self->get("active") eq "0") {
		$showPoll = 0;
	} elsif ($self->session->user->isInGroup($self->get("voteGroup"))) {
		if ($self->_hasVoted()) {
			$showPoll = 0;
		} else {
			$showPoll = 1;
		}
	} else {
		$showPoll = 0;
	}
	$var{canVote} = $showPoll;
        my ($totalResponses) = $self->session->db->quickArray("select count(*) from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	my $i18n = WebGUI::International->new($self->session,"Asset_Poll");
	$var{"responses.label"} = $i18n->get(12);
	$var{"responses.total"} = $totalResponses;
	$var{"form.start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl});
        $var{"form.start"} .= WebGUI::Form::hidden($self->session,{name=>'func',value=>'vote'});
	$var{"form.submit"} = WebGUI::Form::submit($self->session,{value=>$i18n->get(11)});
	$var{"form.end"} = WebGUI::Form::formFooter($self->session,);
	$totalResponses = 1 if ($totalResponses < 1);
        for (my $i=1; $i<=20; $i++) {
        	if ($self->get('a'.$i) =~ /\C/) {
                        my ($tally) = $self->session->db->quickArray("select count(*) from Poll_answer where answer='a"
				.$i."' and assetId=".$self->session->db->quote($self->getId)." group by answer");
                	push(@answers,{
				"answer.form"=>WebGUI::Form::radio($self->session,{name=>"answer",value=>"a".$i}),
				"answer.text"=>$self->get('a'.$i),
				"answer.graphWidth"=>sprintf('%.0f', $self->get("graphWidth")*$tally/$totalResponses),
				"answer.number"=>$i,
				"answer.percent"=>sprintf('%0.f', 100*$tally/$totalResponses),
				"answer.total"=>($tally+0)
                        	});
			push(@dataset, ($tally+0));
			push(@labels, $self->get('a'.$i));
                }
	}
	@answers = List::Util::shuffle(@answers) if ($self->get("randomizeAnswers"));
	$var{answer_loop} = \@answers;

	if ($self->generateGraph) {
		my $config = $self->getGraphConfig;
        if ($config) {
            my $graph = WebGUI::Image::Graph->loadByConfiguration($self->session, $config);
            $graph->addDataset(\@dataset);
            $graph->setLabels(\@labels);

            $graph->draw;

            my $storage = WebGUI::Storage->createTemp($self->session);
            my $filename = 'poll'.$self->session->id->generate.".png";
            $graph->saveToStorageLocation($storage, $filename);

            $var{graphUrl} = $storage->getUrl($filename);
            $var{hasImageGraph} = 1;
        } else {
            $self->session->errorHandler->error('The graph configuration hash of the Poll ('.$self->getUrl.') is corrupt.');
        }
	}
	
	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_vote 

Web method for the user to add their vote.  If so configured, gives karma
to the user.

=cut

sub www_vote {
	my $self = shift;
	my $u;
        if ($self->session->form->process("answer") ne "" && $self->session->user->isInGroup($self->get("voteGroup")) && !($self->_hasVoted())) {
        	$self->setVote($self->session->form->process("answer"),$self->session->user->userId,$self->session->request->address);
		if ($self->session->setting->get("useKarma")) {
			$self->session->user->karma($self->get("karmaPerVote"),"Poll (".$self->getId.")","Voted on this poll.");
		}
		$self->getContainer->purgeCache;
	}

	return $self->session->asset($self->getContainer)->www_view;
}



__PACKAGE__->meta->make_immutable;
1;

