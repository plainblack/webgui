package WebGUI::Asset::Wobject::Poll;


#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Image::Graph;
use WebGUI::Storage::Image;

our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub _hasVoted {
	my $self = shift;
	my ($hasVoted) = $self->session->db->quickArray("select count(*) from Poll_answer 
		where assetId=".$self->session->db->quote($self->getId)." and ((userId=".$self->session->db->quote($self->session->user->userId)."
		and userId<>'1') or (userId=".$self->session->db->quote($self->session->user->userId)." and ipAddress='".$self->session->env->get("REMOTE_ADDR")."'))");
	return $hasVoted;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Poll");
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		tableName=>'Poll',
		icon=>'poll.gif',
		className=>'WebGUI::Asset::Wobject::Poll',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000055'
				},
			active=>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
			karmaPerVote=>{
				fieldType=>"integer",
				defaultValue=>0
				}, 
			graphWidth=>{
				fieldType=>"integer",
				defaultValue=>150
				}, 
			voteGroup=>{
				fieldType=>"group",
				defaultValue=>7
				}, 
			question=>{
				fieldType=>"text",
				defaultValue=>undef
				}, 
			randomizeAnswers=>{
				defaultValue=>1,
				fieldType=>"yesNo"
				},
			a1=>{
				fieldType=>"hidden",
				defaultValue=>undef
				}, 
			a2=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a3=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a4=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a5=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a6=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a7=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a8=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a9=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a10=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a11=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a12=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a13=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a14=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a15=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a16=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a17=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a18=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a19=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                }, 
			a20=>{
                                fieldType=>"hidden",
                                defaultValue=>undef
                                },
			graphConfiguration=>{
				fieldType=>"hidden",
				defaultValue=>undef,
				},
			generateGraph=>{
				fieldType=>"yesNo",
				defaultValue=>0,
				},
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	my $sth = $self->session->db->read("select * from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	while (my $data = $sth->hashRef) {
		$newAsset->setVote($data->{answer}, $data->{userId}, $data->{ipAddress});
	}
	$sth->finish;
	return $newAsset;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm; 
	my $i18n = WebGUI::International->new($self->session,"Asset_Poll");
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Poll",
		-label=>$i18n->get(73),
		-hoverHelp=>$i18n->get('73 description'),
   		);
        my ($i, $answers);
	for ($i=1; $i<=20; $i++) {
                if ($self->get('a'.$i) =~ /\C/) {
                        $answers .= $self->getValue("a".$i)."\n";
                }
        }
	$tabform->getTab("security")->yesNo(
		-name=>"active",
		-label=>$i18n->get(3),
		-hoverHelp=>$i18n->get('3 description'),
		-value=>$self->getValue("active")
		);
        $tabform->getTab("security")->group(
		-name=>"voteGroup",
		-label=>$i18n->get(4),
		-hoverHelp=>$i18n->get('4 description'),
		-value=>[$self->getValue("voteGroup")]
		);
	if ($self->session->setting->get("useKarma")) {
		$tabform->getTab("properties")->integer(
			-name=>"karmaPerVote",
			-label=>$i18n->get(20),
			-hoverHelp=>$i18n->get('20 description'),
			-value=>$self->getValue("karmaPerVote")
			);
	} else {
		$tabform->getTab("properties")->hidden(
			-name=>"karmaPerVote",
			-value=>$self->getValue("karmaPerVote")
			);
	}
	$tabform->getTab("display")->integer(
		-name=>"graphWidth",
		-label=>$i18n->get(5),
		-hoverHelp=>$i18n->get('5 description'),
		-value=>$self->getValue("graphWidth")
		);
	$tabform->getTab("properties")->text(
		-name=>"question",
		-label=>$i18n->get(6),
		-hoverHelp=>$i18n->get('6 description'),
		-value=>$self->getValue("question")
		);
        $tabform->getTab("properties")->textarea(
		-name=>"answers",
		-label=>$i18n->get(7),
		-hoverHelp=>$i18n->get('7 description'),
		-subtext=>('<span class="formSubtext"><br />'.$i18n->get(8).'</span>'),
		-value=>$answers
		);
	$tabform->getTab("display")->yesNo(
		-name=>"randomizeAnswers",
		-label=>$i18n->get(72),
		-hoverHelp=>$i18n->get('72 description'),
		-value=>$self->getValue("randomizeAnswers")
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"resetVotes",
		-label=>$i18n->get(10),
		-hoverHelp=>$i18n->get('10 description')
		) if $self->session->form->process("func") ne 'add';


	if (WebGUI::Image::Graph->getPluginList($self->session)) {
		my $config = {};
		if ($self->get('graphConfiguration')) {
			$config = Storable::thaw($self->get('graphConfiguration'));
		}

		$tabform->addTab('graph', 'Graphing');
		$tabform->getTab('graph')->yesNo(
			-name		=> 'generateGraph',
			-label		=> $i18n->get('generate graph'),
			-hoverHelp	=> $i18n->get('generate graph description'),
			-value		=> $self->getValue('generateGraph'),
		);
		$tabform->getTab('graph')->raw(WebGUI::Image::Graph->getGraphingTab($self->session, $config));
	}

	return $tabform;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing question and answers. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("question")." ".$self->get("answers"));
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
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my (@answer, $i, $property);
	@answer = split("\n",$self->session->form->process("answers"));
        for ($i=1; $i<=20; $i++) {
             	$property->{'a'.$i} = $answer[($i-1)];
        }

	if (WebGUI::Image::Graph->getPluginList($self->session)) {
		my $graph = WebGUI::Image::Graph->processConfigurationForm($self->session);
		$property->{graphConfiguration} = Storable::freeze($graph->getConfiguration);
	}

	$self->update($property);
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId)) if ($self->session->form->process("resetVotes"));
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("delete from Poll_answer where assetId=".$self->session->db->quote($self->getId));
	$self->SUPER::purge();
}	

#-------------------------------------------------------------------
sub setVote {
	my $self = shift;
	my $answer = shift;
	my $userId = shift;
	my $ip = shift;
       	$self->session->db->write("insert into Poll_answer (assetId, answer, userId, ipAddress) values (".$self->session->db->quote($self->getId).", 
		".$self->session->db->quote($answer).", ".$self->session->db->quote($userId).", '$ip')");
}

#-------------------------------------------------------------------
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
				"answer.graphWidth"=>round($self->get("graphWidth")*$tally/$totalResponses),
				"answer.number"=>$i,
				"answer.percent"=>round(100*$tally/$totalResponses),
				"answer.total"=>($tally+0)
                        	});
			push(@dataset, ($tally+0));
			push(@labels, $self->get('a'.$i));
                }
	}
	randomizeArray(\@answers) if ($self->get("randomizeAnswers"));
	$var{answer_loop} = \@answers;

	if ($self->getValue('generateGraph')) {
		my $config = {};
		if ($self->get('graphConfiguration')) {
			$config = Storable::thaw($self->get('graphConfiguration'));
		
			my $graph = WebGUI::Image::Graph->loadByConfiguration($self->session, $config);
			$graph->addDataset(\@dataset);
			$graph->setLabels(\@labels);

			$graph->draw;

			my $storage = WebGUI::Storage::Image->createTemp($self->session);
			my $filename = 'poll'.$self->session->id->generate.".png";
			$graph->saveToStorageLocation($storage, $filename);

			$var{graphUrl} = $storage->getUrl($filename);
			$var{hasImageGraph} = 1;
		}
	}
	
	return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------
sub www_vote {
	my $self = shift;
	my $u;
        if ($self->session->form->process("answer") ne "" && $self->session->user->isInGroup($self->get("voteGroup")) && !($self->_hasVoted())) {
        	$self->setVote($self->session->form->process("answer"),$self->session->user->userId,$self->session->env->get("REMOTE_ADDR"));
		if ($self->session->setting->get("useKarma")) {
			$self->session->user->karma($self->get("karmaPerVote"),"Poll (".$self->getId.")","Voted on this poll.");
		}
		$self->getContainer->purgeCache;
	}
	return $self->getContainer->www_view;
}



1;

