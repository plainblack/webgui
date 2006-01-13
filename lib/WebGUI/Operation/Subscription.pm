package WebGUI::Operation::Subscription;

use strict;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use Tie::IxHash;
use WebGUI::Paginator;
use WebGUI::Subscription;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::AdminConsole;
use WebGUI::Asset::Template;
use WebGUI::Form;
use WebGUI::International;

#-------------------------------------------------------------------
sub _generateCode {
	my $session = shift;
	my ($codeLength, @codeElements, $code, $i);
	$codeLength = shift || 64;
	@codeElements = ('A'..'Z', 'a'..'z', 0..9, '-');
	
	for ($i=0; $i < $codeLength; $i++) {
		$code .= $codeElements[rand(63)];
	}

	return $code;
}

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
	my $i18n = WebGUI::International->new($session, "Subscription");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"subscriptions");
        if ($help) {
                $ac->setHelp($help, 'Subscription');
        }
	$ac->addSubmenuItem($session->url->page('op=editSubscription;sid=new'), $i18n->get('add subscription'));
	$ac->addSubmenuItem($session->url->page('op=createSubscriptionCodeBatch'), $i18n->get('generate batch')); 
	$ac->addSubmenuItem($session->url->page('op=listSubscriptionCodes'), $i18n->get('manage codes'));
	$ac->addSubmenuItem($session->url->page('op=listSubscriptionCodeBatches'), $i18n->get('manage batches'));
	$ac->addSubmenuItem($session->url->page('op=listSubscriptions'), 'Manage Subscriptions');
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_createSubscriptionCodeBatch {
	my $session = shift;
	my (%subscriptions, $f, $error, $errorMessage);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	$error = shift;
	my $i18n = WebGUI::International->new($session, "Subscription");

	$errorMessage = $i18n->get('create batch error').'<ul><li>'.join('</li><li>', @{$error}).'</li></ul>' if ($error);
	
	tie %subscriptions, "Tie::IxHash";
	%subscriptions = $session->db->buildHash("select subscriptionId, name from subscription where deleted != 1 order by name");
	
	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name => 'op', 
		-value => 'createSubscriptionCodeBatchSave'
		);
	$f->integer(
		-name	=> 'noc',
		-label	=> $i18n->get('noc'),
		-hoverHelp	=> $i18n->get('noc description'),
		-value	=> $session->form->process("noc") || 1
		);
	$f->integer(
		-name	=> 'codeLength',
		-label	=> $i18n->get('code length'),
		-hoverHelp	=> $i18n->get('code length description'),
		-value	=> $session->form->process("codeLength") || 64
		);
	$f->interval(
		-name	=> 'expires',
		-label	=> $i18n->get('codes expire'),
		-hoverHelp	=> $i18n->get('codes expire description'),
		-value	=> $session->form->process("expires") || $session->datetime->intervalToSeconds(1, 'months')
		);
	my @sub = $session->form->selectList("subscriptionId");
	$f->selectList(
		-name	=> 'subscriptionId',
		-label	=> $i18n->get('association'), 
		-hoverHelp	=> $i18n->get('association description'), 
		-options=> \%subscriptions,
		-multiple=>1,
		-size	=> 5,
		-value  => \@sub
		);
	$f->textarea(
		-name	=> 'description',
		-label	=> $i18n->get('batch description'),
		-hoverHelp	=> $i18n->get('batch description description'),
		-value	=> $session->form->process("description")
		);
	$f->submit;

	return _submenu($errorMessage.$f->print, 'create batch menu', 'create batch');
}
	
#-------------------------------------------------------------------
sub www_createSubscriptionCodeBatchSave {
	my $session = shift;
	my ($numberOfCodes, $description, $expires, $batchId, @codeElements, $currentCode, $code, $i, @subscriptions, 
		@error, $creationEpoch);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $i18n = WebGUI::International->new($session, "Subscription");	
	
	$numberOfCodes = $session->form->process("noc");
	$description = $session->form->process("description");
	$expires = $session->form->interval('expires');
	$batchId = $session->id->generate;

	push(@error, $i18n->get('no description error')) unless ($description);
	push(@error, $i18n->get('no association error')) unless ($session->form->process("subscriptionId"));
	push(@error, $i18n->get('code length error')) unless ($session->form->process("codeLength") >= 10 && $session->form->process("codeLength") <= 64 && $session->form->process("codeLength") =~ m/^\d\d$/);

	return www_createSubscriptionCodeBatch(\@error) if (@error);

	$creationEpoch =$session->datetime->time();
	
	$session->db->write("insert into subscriptionCodeBatch (batchId, description) values (".
		$session->db->quote($batchId).", ".$session->db->quote($description).")");

	for ($currentCode=0; $currentCode < $numberOfCodes; $currentCode++) {
		$code = _generateCode($session->form->process("codeLength"));
		$code = _generateCode($session->form->process("codeLength")) while ($session->db->quickArray("select code from subscriptionCode where code=".$session->db->quote($code)));
		
		$session->db->write("insert into subscriptionCode (batchId, code, status, dateCreated, dateUsed, expires, usedBy)".
			" values (".$session->db->quote($batchId).",".$session->db->quote($code).", 'Unused', ".$session->db->quote($creationEpoch).", 0, ".$session->db->quote($expires).", 0)");
		@subscriptions = $session->form->selectList('subscriptionId');
		foreach (@subscriptions) {
			$session->db->write("insert into subscriptionCodeSubscriptions (code, subscriptionId) values (".
				$session->db->quote($code).", ".$session->db->quote($_).")");
		}
	}
	
	return www_listSubscriptionCodeBatches();
}

#-------------------------------------------------------------------
sub www_deleteSubscription {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	WebGUI::Subscription->new($session,$session->form->process("sid"))->delete;
	return www_listSubscriptions();
}

#-------------------------------------------------------------------
sub www_deleteSubscriptionCodeBatch {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	$session->db->write("delete from subscriptionCodeBatch where batchId=".$session->db->quote($session->form->process("bid")));
	$session->db->write("delete from subscriptionCode where batchId=".$session->db->quote($session->form->process("bid")));
	
	return www_listSubscriptionCodeBatches();
}

#-------------------------------------------------------------------
sub www_deleteSubscriptionCodes {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	if ($session->form->process("selection") eq 'dc') {
		$session->db->write("delete from subscriptionCode where dateCreated >= ".$session->db->quote($session->form->process("dcStart")).
			' and dateCreated <= '.$session->db->quote($session->form->process("dcStop")));
	} elsif ($session->form->process("selection") eq 'du') {
		$session->db->write("delete from subscriptionCode where dateUsed >= ".$session->db->quote($session->form->process("duStart")).
			' and dateUsed <= '.$session->db->quote($session->form->process("duStop")));
	}

	return www_listSubscriptionCodes();
}

#-------------------------------------------------------------------
sub www_editSubscription {
	my $session = shift;
	my ($properties, $subscriptionId, $durationInterval, $durationUnits, $f);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $i18n = WebGUI::International->new($session, "Subscription");
	
	unless ($session->form->process("sid") eq 'new') {
		$properties = WebGUI::Subscription->new($session,$session->form->process("sid"))->get;
	}

	$subscriptionId = $session->form->process("sid") || 'new';

	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name => 'op', 
		-value => 'editSubscriptionSave'
		);
	$f->hidden(
		-name => 'sid', 
		-value => $subscriptionId
	);
	$f->readOnly(
		-label	=> $i18n->get('subscriptionId'),
		-value	=> $subscriptionId
		);
	$f->text(
		-name	=> 'name',
		-label	=> $i18n->get('subscription name'),
		-hoverHelp	=> $i18n->get('subscription name description'),
		-value	=> $properties->{name}
		);
	$f->float(
		-name	=> 'price',
		-label	=> $i18n->get('subscription price'),
		-hoverHelp	=> $i18n->get('subscription price description'),
		-value	=> $properties->{price} || '0.00'
		);
	$f->textarea(
		-name	=> 'description',
		-label	=> $i18n->get('subscription description'),
		-hoverHelp	=> $i18n->get('subscription description description'),
		-value	=> $properties->{description}
		);
	$f->group(
		-name	=> 'subscriptionGroup',
		-label	=> $i18n->get('subscription group'),
		-hoverHelp	=> $i18n->get('subscription group description'),
		-value	=> [$properties->{subscriptionGroup} || 2]
		);
	$f->selectBox(
		-name	=> 'duration',
		-label	=> $i18n->get('subscription duration'),
		-hoverHelp	=> $i18n->get('subscription duration description'),
		-value	=> [$properties->{duration} || 'Monthly'],
		-options=> WebGUI::Commerce::Payment->recurringPeriodValues($session),
		);
	$f->text(
		-name	=> 'executeOnSubscription',
		-label	=> $i18n->get('execute on subscription'),
		-hoverHelp	=> $i18n->get('execute on subscription description'),
		-value	=> $properties->{executeOnSubscription}
		);
	if ($session->setting->get("useKarma")) {
		$f->integer(
			-name	=> 'karma',
			-label	=> $i18n->get('subscription karma'),
			-hoverHelp	=> $i18n->get('subscription karma description'),
			-value	=> $properties->{karma} || 0
			);
	}
	$f->submit;

	return _submenu($f->print, 'edit subscription title', 'subscription add/edit');
}

#-------------------------------------------------------------------
sub www_editSubscriptionSave {
	my $session = shift;
	my (@relevantFields);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	@relevantFields = qw(subscriptionId name price description subscriptionGroup duration executeOnSubscription karma);
	WebGUI::Subscription->new($session,$session->form->process("sid"))->set({map {$_ => $session->form->process($_)} @relevantFields);
		
	return www_listSubscriptions();
}

#-------------------------------------------------------------------
sub www_listSubscriptionCodeBatches {
	my $session = shift;
	my ($p, $batches, $output);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $i18n = WebGUI::International->new($session, "Subscription");
	
	$p = WebGUI::Paginator->new($session,$session->url->page('op=listSubscriptionCodeBatches'));
	$p->setDataByQuery("select * from subscriptionCodeBatch");

	$batches = $p->getPageData;

	$output = $p->getBarTraditional($session->form->process("pn"));
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	foreach (@{$batches}) {
		$output .= '<tr><td>';		
		$output .= $session->icon->delete('op=deleteSubscriptionCodeBatch;bid='.$_->{batchId}, undef, $i18n->get('delete batch confirm'));
		$output .= '<td>'.$_->{description}.'</td>';
		$output .= '<td><a href="'.$session->url->page('op=listSubscriptionCodes;selection=b;bid='.$_->{batchId}).'">'.$i18n->get('list codes in batch').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session->form->process("pn"));
	
	$output = $i18n->get('no subscription code batches') unless (@{$batches});

	return _submenu($output, 'manage batches', 'manage batch');
}

#-------------------------------------------------------------------
sub www_listSubscriptionCodes {
	my $session = shift;
	my ($p, $codes, $output, $where, $ops, $delete);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	my $i18n = WebGUI::International->new($session, "Subscription");
	
	my $dcStart = $session->form->date('dcStart');
	my $dcStop  = $session->datetime->addToTime($session->form->date('dcStop'),23,59);
	my $duStart = $session->form->date('duStart');
	my $duStop  = $session->datetime->addToTime($session->form->date('duStop'),23,59);
	my $batches = $session->db->buildHashRef("select batchId, description from subscriptionCodeBatch");	

	$output .= $i18n->get('selection message');
	
	$output .= WebGUI::Form::formHeader;
	$output .= WebGUI::Form::hidden($session,{name=>'op', value=>'listSubscriptionCodes'});
	$output .= '<table>';
	$output .= '<td>'.WebGUI::Form::radio($session,{name=>'selection', value => 'du', checked=>($session->form->process("selection") eq 'du')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection used').'</td>';
	$output .= '<td>'.WebGUI::Form::date($session,{name=>'duStart', value=>$duStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'duStop', value=>$duStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio($session,{name=>'selection', value => 'dc', checked=>($session->form->process("selection") eq 'dc')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection created').'</td>';
	$output .= '<td>'.WebGUI::Form::date($session,{name=>'dcStart', value=>$dcStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'dcStop', value=>$dcStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio($session,{name=>'selection', value => 'b', checked=>($session->form->process("selection") eq 'b')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection batch id').'</td>';
	$output .= '<td>'.WebGUI::Form::selectList($session,{name => 'bid', value => [$session->form->process("bid")], options => $batches});
	$output .= '</tr><tr>';
	$output .= '<td></td>';
	$output .= '<td>'.WebGUI::Form::submit($session,{value=>$i18n->get('select')}).'</td>';
	$output .= '</tr>';
	$output .= '</table>';
	$output .= WebGUI::Form::formFooter;
	
	if ($session->form->process("selection") eq 'du') {
		$where = " and dateUsed >= ".$session->db->quote($duStart)." and dateUsed <= ".$session->db->quote($duStop);
		$ops = ';duStart='.$duStart.';duStop='.$duStop.';selection=du';
		$delete = '<a href="'.$session->url->page('op=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session->form->process("selection") eq 'dc') {
		$where = " and dateCreated >= ".$session->db->quote($dcStart)." and dateCreated <= ".$session->db->quote($dcStop);
		$ops = ';dcStart='.$dcStart.';dcStop='.$dcStop.';selection=dc';
		$delete = '<a href="'.$session->url->page('op=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session->form->process("selection") eq 'b') {
		$where = " and t1.batchId=".$session->db->quote($session->form->process("bid"));
		$ops = ';bid='.$session->form->process("bid").';selection=b';
		$delete = '<a href="'.$session->url->page('op=deleteSubscriptionCodeBatch'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} else {
		return _submenu($output, 'listSubscriptionCodes title', 'subscription codes manage');
	}
	
	$p = WebGUI::Paginator->new($session,$session->url->page('op=listSubscriptionCodes'.$ops));
	$p->setDataByQuery("select t1.*, t2.* from subscriptionCode as t1, subscriptionCodeBatch as t2 where t1.batchId=t2.batchId ".$where);

	$codes = $p->getPageData;

	$output .= '<br />'.$delete.'<br />' if ($delete);
	$output .= $p->getBarTraditional($session->form->process("pn"));
	$output .= '<br />';
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr>';
	$output .= '<th>'.$i18n->get('batch id').'</th><th>'.$i18n->get('code').'</th><th>'.$i18n->get('creation date').
		'</th><th>'.$i18n->get('dateUsed').'</th><th>'.$i18n->get('status').'</th>';	$output .= '</tr>';
	foreach (@{$codes}) {
		$output .= '<tr>';
		$output .= '<td>'.$_->{batchId}.'</td>';
		$output .= '<td>'.$_->{code}.'</td>';
		$output .= '<td>'.$session->datetime->epochToHuman($_->{dateCreated}).'</td>';
		$output .= '<td>';
		$output .= $session->datetime->epochToHuman($_->{dateUsed}) if ($_->{dateUsed});
		$output .= '</td>';
		$output .= '<td>'.$_->{status}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session->form->process("pn"));

	return _submenu($output, 'listSubscriptionCodes title', 'subscription codes manage');
}

#-------------------------------------------------------------------
sub www_listSubscriptions {
	my $session = shift;
	my ($p, $subscriptions, $output);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	my $i18n = WebGUI::International->new($session, "Subscription");
	
	$p = WebGUI::Paginator->new($session,$session->url->page('op=listSubscriptions'));
	$p->setDataByQuery('select subscriptionId, name from subscription where deleted != 1');
	$subscriptions = $p->getPageData;

	$output = $p->getBarTraditional($session->form->process("pn"));
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	foreach (@{$subscriptions}) {
		$output .= '<tr>';
		$output .= '<td>'.$session->icon->edit('op=editSubscription;sid='.$_->{subscriptionId});
		$output .= $session->icon->delete('op=deleteSubscription;sid='.$_->{subscriptionId}, undef, $i18n->get('delete subscription confirm')).'</td>';
		$output .= '<td>'.$_->{name}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session->form->process("pn"));
	
	$output = $i18n->get('no subscriptions') unless (@{$subscriptions});
	
	return _submenu($output, 'manage subscriptions', 'subscription manage');
}

#-------------------------------------------------------------------
sub www_purchaseSubscription {
	my $session = shift;
	WebGUI::Commerce::ShoppingCart->new($session)->add($session->form->process("sid"), 'Subscription');
	
	return WebGUI::HTTP::setRedirect($session->url->page('op=checkout'));
}

#-------------------------------------------------------------------
sub www_redeemSubscriptionCode {
	my $session = shift;
	my (%codeProperties, @subscriptions, %var, $f);
	my $i18n = WebGUI::International->new($session, "Subscription");
	
	if ($session->form->process("code")) {
		%codeProperties = $session->db->quickHash("select * from subscriptionCode as t1, subscriptionCodeBatch as t2 where ".
			"t1.batchId = t2.batchId and t1.code=".$session->db->quote($session->form->process("code"))." and (t1.dateCreated + t1.expires) > ".$session->db->quote(time));

		if ($codeProperties{status} eq 'Unused') {
			# Code is ok
			@subscriptions = $session->db->buildArray("select subscriptionId from subscriptionCodeSubscriptions where code=".$session->db->quote($session->form->process("code")));
			foreach (@subscriptions) {
				WebGUI::Subscription->new($session,$_)->apply;
			}

			# Set code to Used
			$session->db->write("update subscriptionCode set status='Used', dateUsed=".$session->db->quote(time)." where code=".$session->db->quote($session->form->process("code")));

			$var{batchDescription} = $codeProperties{description};
			$var{message} = $i18n->get('redeem code success');
		} else {
			$var{message} = $i18n->get('redeem code failure');
		}
	} else {
		$var{message} = $i18n->get('redeem code ask for code');
	}
	
	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name => 'op',
		-value => 'redeemSubscriptionCode'
		);
	$f->text(
		-name		=> 'code',
		-label		=> $i18n->get('code'),
		-hoverHelp	=> $i18n->get('code description'),
		-maxLength	=> 64,
		-size		=> 30
		);
	$f->submit;
	$var{codeForm} = $f->print;

	return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000053")->process(\%var));
}

1;
