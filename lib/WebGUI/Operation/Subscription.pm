package WebGUI::Operation::Subscription;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use WebGUI::Id;
use Tie::IxHash;
use WebGUI::Paginator;
use WebGUI::Icon;
use WebGUI::FormProcessor;
use WebGUI::Subscription;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::AdminConsole;
use WebGUI::Template;
use WebGUI::Form;
use WebGUI::International;

#-------------------------------------------------------------------
sub _submenu {
	my $i18n = WebGUI::International->new("Subscription");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("subscriptions");
        if ($help) {
                $ac->setHelp($help, 'Subscription');
        }
	$ac->addSubmenuItem(WebGUI::URL::page('op=editSubscription&sid=new'), $i18n->get('add subscription'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=createSubscriptionCodeBatch'), $i18n->get('generate batch')); 
	$ac->addSubmenuItem(WebGUI::URL::page('op=listSubscriptionCodes'), $i18n->get('manage codes'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=listSubscriptionCodeBatches'), $i18n->get('manage batches'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=listSubscriptions'), 'Manage Subscriptions');
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_createSubscriptionCodeBatch {
	my (%subscriptions, $f, $error, $errorMessage);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	$error = shift;
	my $i18n = WebGUI::International->new("Subscription");

	$errorMessage = $i18n->get('create batch error').'<ul><li>'.join('</li><li>', @{$error}).'</li></ul>' if ($error);
	
	tie %subscriptions, "Tie::IxHash";
	%subscriptions = WebGUI::SQL->buildHash("select subscriptionId, name from subscription where deleted != 1 order by name");
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden('op', 'createSubscriptionCodeBatchSave');
	$f->integer(
		-name	=> 'noc',
		-label	=> $i18n->get('noc'),
		-value	=> $session{form}{noc} || 1
		);
	$f->interval(
		-name	=> 'expires',
		-label	=> $i18n->get('codes expire'),
		-value	=> $session{form}{expires} || WebGUI::DateTime::intervalToSeconds(1, 'months')
		);
	$f->selectList(
		-name	=> 'subscriptionId',
		-label	=> $i18n->get('association'), 
		-options=> \%subscriptions,
		-multiple=>1,
		-size	=> 5,
		-value  => [ ($session{cgi}->param('subscriptionId'))]
		);
	$f->textarea(
		-name	=> 'description',
		-label	=> $i18n->get('batch description'),
		-value	=> $session{form}{description}
		);
	$f->submit;

	return _submenu($errorMessage.$f->print, 'create batch menu', 'create batch');
}
	
#-------------------------------------------------------------------
sub www_createSubscriptionCodeBatchSave {
	my ($numberOfCodes, $description, $expires, $batchId, @codeElements, $currentCode, $code, $i, @subscriptions, 
		@error, $creationEpoch);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	my $i18n = WebGUI::International->new("Subscription");	
	
	$numberOfCodes = $session{form}{noc};
	$description = $session{form}{description};
	$expires = WebGUI::FormProcessor::interval('expires');
	$batchId = WebGUI::Id::generate;

	push(@error, $i18n->get('no description error')) unless ($description);
	push(@error, $i18n->get('no association error')) unless ($session{form}{subscriptionId});
	return www_createSubscriptionCodeBatch(\@error) if (@error);

	$creationEpoch = time();
	
	WebGUI::SQL->write("insert into subscriptionCodeBatch (batchId, description) values (".
		quote($batchId).", ".quote($description).")");
	@codeElements = ('A'..'Z', 'a'..'z', 0..9, '-');

	for ($currentCode=0; $currentCode < $numberOfCodes; $currentCode++) {
		$code = "";
		for ($i=0; $i < 64; $i++) {
			$code .= $codeElements[rand(63)];
		}
		
		WebGUI::SQL->write("insert into subscriptionCode (batchId, code, status, dateCreated, dateUsed, expires, usedBy)".
			" values (".quote($batchId).",".quote($code).", 'Unused', ".quote($creationEpoch).", 0, ".quote($expires).", 0)");
		@subscriptions = $session{cgi}->param('subscriptionId');
		foreach (@subscriptions) {
			WebGUI::SQL->write("insert into subscriptionCodeSubscriptions (code, subscriptionId) values (".
				quote($code).", ".quote($_).")");
		}
	}
	
	return www_listSubscriptionCodeBatches();
}

#-------------------------------------------------------------------
sub www_deleteSubscription {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	WebGUI::Subscription->new($session{form}{sid})->delete;
	return www_listSubscriptions();
}

#-------------------------------------------------------------------
sub www_deleteSubscriptionCodeBatch {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	WebGUI::SQL->write("delete from subscriptionCodeBatch where batchId=".quote($session{form}{bid}));
	WebGUI::SQL->write("delete from subscriptionCode where batchId=".quote($session{form}{bid}));
	
	return www_listSubscriptionCodeBatches();
}

#-------------------------------------------------------------------
sub www_deleteSubscriptionCodes {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	if ($session{form}{selection} eq 'dc') {
		WebGUI::SQL->write("delete from subscriptionCode where dateCreated >= ".quote($session{form}{dcStart}).
			' and dateCreated <= '.quote($session{form}{dcStop}));
	} elsif ($session{form}{selection} eq 'du') {
		WebGUI::SQL->write("delete from subscriptionCode where dateUsed >= ".quote($session{form}{duStart}).
			' and dateUsed <= '.quote($session{form}{duStop}));
	}

	return www_listSubscriptionCodes();
}

#-------------------------------------------------------------------
sub www_editSubscription {
	my ($properties, $subscriptionId, $durationInterval, $durationUnits, $f);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	my $i18n = WebGUI::International->new("Subscription");
	
	unless ($session{form}{sid} eq 'new') {
		$properties = WebGUI::Subscription->new($session{form}{sid})->get;
	}

	$subscriptionId = $session{form}{sid} || 'new';

	$f = WebGUI::HTMLForm->new;
	$f->hidden('op', 'editSubscriptionSave');
	$f->hidden('sid', $subscriptionId);
	$f->readOnly(
		-label	=> $i18n->get('subscriptionId'),
		-value	=> $subscriptionId
		);
	$f->text(
		-name	=> 'name',
		-label	=> $i18n->get('subscription name'),
		-value	=> $properties->{name}
		);
	$f->float(
		-name	=> 'price',
		-label	=> $i18n->get('subscription price'),
		-value	=> $properties->{price} || '0.00'
		);
	$f->textarea(
		-name	=> 'description',
		-label	=> $i18n->get('subscription description'),
		-value	=> $properties->{description}
		);
	$f->group(
		-name	=> 'subscriptionGroup',
		-label	=> $i18n->get('subscription group'),
		-value	=> [$properties->{subscriptionGroup} || 2]
		);
	$f->selectList(
		-name	=> 'duration',
		-label	=> $i18n->get('subscription duration'),
		-value	=> [$properties->{duration} || 'Monthly'],
		-options=> WebGUI::Commerce::Payment::recurringPeriodValues
		);
	$f->text(
		-name	=> 'executeOnSubscription',
		-label	=> $i18n->get('execute on subscription'),
		-value	=> $properties->{executeOnSubscription}
		);
	if ($session{setting}{useKarma}) {
		$f->integer(
			-name	=> 'karma',
			-label	=> $i18n->get('subscription karma'),
			-value	=> $properties->{karma} || 0
			);
	}
	$f->submit;

	return _submenu($f->print, 'edit subscription title', 'subscription add/edit');
}

#-------------------------------------------------------------------
sub www_editSubscriptionSave {
	my (@relevantFields);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	@relevantFields = qw(subscriptionId name price description subscriptionGroup duration executeOnSubscription karma);
	WebGUI::Subscription->new($session{form}{sid})->set({map {$_ => $session{form}{$_}} @relevantFields});
		
	return www_listSubscriptions();
}

#-------------------------------------------------------------------
sub www_listSubscriptionCodeBatches {
	my ($p, $batches, $output);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	my $i18n = WebGUI::International->new("Subscription");
	
	$p = WebGUI::Paginator->new('op=listSubscriptionCodeBatches');
	$p->setDataByQuery("select * from subscriptionCodeBatch");

	$batches = $p->getPageData;

	$output = $p->getBarTraditional($session{form}{pn});
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	foreach (@{$batches}) {
		$output .= '<tr><td>';		
		$output .= deleteIcon('op=deleteSubscriptionCodeBatch&bid='.$_->{batchId}, undef, $i18n->get('delete batch confirm'));
		$output .= '<td>'.$_->{description}.'</td>';
		$output .= '<td><a href="'.WebGUI::URL::page('op=listSubscriptionCodes&selection=b&bid='.$_->{batchId}).'">'.$i18n->get('list codes in batch').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});
	
	return _submenu($output, 'Manage subscription code batches', 'manage batch');
}

#-------------------------------------------------------------------
sub www_listSubscriptionCodes {
	my ($p, $codes, $output, $where, $ops, $delete);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));

	my $i18n = WebGUI::International->new("Subscription");
	
	my $dcStart = WebGUI::FormProcessor::date('dcStart');
	my $dcStop  = WebGUI::FormProcessor::date('dcStop');
	my $duStart = WebGUI::FormProcessor::date('duStart');
	my $duStop  = WebGUI::FormProcessor::date('duStop');
	my $batches = WebGUI::SQL->buildHashRef("select batchId, description from subscriptionCodeBatch");	

	$output .= $i18n->get('selection message');
	
	$output .= WebGUI::Form::formHeader;
	$output .= WebGUI::Form::hidden({name=>'op', value=>'listSubscriptionCodes'});
	$output .= '<table>';
	$output .= '<td>'.WebGUI::Form::radio({name=>'selection', value => 'du', checked=>($session{form}{selection} eq 'du')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection used').'</td>';
	$output .= '<td>'.WebGUI::Form::date({name=>'duStart', value=>$duStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'duStop', value=>$duStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio({name=>'selection', value => 'dc', checked=>($session{form}{selection} eq 'dc')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection created').'</td>';
	$output .= '<td>'.WebGUI::Form::date({name=>'dcStart', value=>$dcStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'dcStop', value=>$dcStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio({name=>'selection', value => 'b', checked=>($session{form}{selection} eq 'b')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('selection batch id').'</td>';
	$output .= '<td>'.WebGUI::Form::selectList({name => 'bid', value => [$session{form}{bid}], options => $batches});
	$output .= '</tr><tr>';
	$output .= '<td></td>';
	$output .= '<td>'.WebGUI::Form::submit({value=>$i18n->get('select')}).'</td>';
	$output .= '</tr>';
	$output .= '</table>';
	$output .= WebGUI::Form::formFooter;
	
	if ($session{form}{selection} eq 'du') {
		$where = " and dateUsed >= ".quote($duStart)." and dateUsed <= ".quote($duStop);
		$ops = '&duStart='.$duStart.'&duStop='.$duStop.'&selection=du';
		$delete = '<a href="'.WebGUI::URL::page('op=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session{form}{selection} eq 'dc') {
		$where = " and dateCreated >= ".quote($dcStart)." and dateCreated <= ".quote($dcStop);
		$ops = '&dcStart='.$dcStart.'&dcStop='.$dcStop.'&selection=dc';
		$delete = '<a href="'.WebGUI::URL::page('op=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session{form}{selection} eq 'b') {
		$where = " and t1.batchId=".quote($session{form}{bid});
		$ops = '&bid='.$session{form}{bid}.'&selection=b';
		$delete = '<a href="'.WebGUI::URL::page('op=deleteSubscriptionCodeBatch'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} else {
		return _submenu($output, 'listSubscriptionCodes title', 'subscription codes manage');
	}
	
	$p = WebGUI::Paginator->new('op=listSubscriptionCodes'.$ops);
	$p->setDataByQuery("select t1.*, t2.* from subscriptionCode as t1, subscriptionCodeBatch as t2 where t1.batchId=t2.batchId ".$where);

	$codes = $p->getPageData;

	$output .= '<br>'.$delete.'<br>' if ($delete);
	$output .= $p->getBarTraditional($session{form}{pn});
	$output .= '<br>';
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr>';
	$output .= '<th>'.$i18n->get('batchId').'</th><th>'.$i18n->get('code').'</th><th>'.$i18n->get('creation date').
		'</th><th>'.$i18n->get('dateUsed').'</th><th>'.$i18n->get('status').'</th>';	$output .= '</tr>';
	foreach (@{$codes}) {
		$output .= '<tr>';
		$output .= '<td>'.$_->{batchId}.'</td>';
		$output .= '<td>'.$_->{code}.'</td>';
		$output .= '<td>'.WebGUI::DateTime::epochToHuman($_->{dateCreated}).'</td>';
		$output .= '<td>';
		$output .= WebGUI::DateTime::epochToHuman($_->{dateUsed}) if ($_->{dateUsed});
		$output .= '</td>';
		$output .= '<td>'.$_->{status}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});

	return _submenu($output, 'listSubscriptionCodes title', 'subscription codes manage');
}

#-------------------------------------------------------------------
sub www_listSubscriptions {
	my ($p, $subscriptions, $output);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	my $i18n = WebGUI::International->new("Subscription");
	
	$p = WebGUI::Paginator->new('op=listSubscriptions');
	$p->setDataByQuery('select subscriptionId, name from subscription where deleted != 1');
	$subscriptions = $p->getPageData;

	$output = $p->getBarTraditional($session{form}{pn});
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	foreach (@{$subscriptions}) {
		$output .= '<tr>';
		$output .= '<td>'.editIcon('op=editSubscription&sid='.$_->{subscriptionId});
		$output .= deleteIcon('op=deleteSubscription&sid='.$_->{subscriptionId}, undef, $i18n->get('delete subscription confirm')).'</td>';
		$output .= '<td>'.$_->{name}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});
	
	$output = $i18n->get('no subscriptions') unless (@{$subscriptions});
	
	return _submenu($output, 'manage subscriptions', 'subscription manage');
}

#-------------------------------------------------------------------
sub www_purchaseSubscription {
	WebGUI::Commerce::ShoppingCart->new->add($session{form}{sid}, 'Subscription');
	
	return WebGUI::Operation::execute('checkout');
}

#-------------------------------------------------------------------
sub www_redeemSubscriptionCode {
	my (%codeProperties, @subscriptions, %var, $f);
	my $i18n = WebGUI::International->new("Subscription");
	
	if ($session{form}{code}) {
		%codeProperties = WebGUI::SQL->quickHash("select * from subscriptionCode as t1, subscriptionCodeBatch as t2 where ".
			"t1.batchId = t2.batchId and t1.code=".quote($session{form}{code})." and (t1.dateCreated + t1.expires) > ".quote(time));

		if ($codeProperties{status} eq 'Unused') {
			# Code is ok
			@subscriptions = WebGUI::SQL->buildArray("select subscriptionId from subscriptionCodeSubscriptions where code=".quote($session{form}{code}));
			foreach (@subscriptions) {
				WebGUI::Subscription->new($_)->apply;
			}

			# Set code to Used
			WebGUI::SQL->write("update subscriptionCode set status='Used', dateUsed=".quote(time)." where code=".quote($session{form}{code}));

			$var{batchDescription} = $codeProperties{description};
			$var{message} = $i18n->get('redeem code success');
		} else {
			$var{message} = $i18n->get('redeem code failure');
		}
	} else {
		$var{message} = $i18n->get('redeem code ask for code');
	}
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden('op','redeemSubscriptionCode');
	$f->text(
		-name		=> 'code',
		-label		=> $i18n->get('code'),
		-maxLength	=> 64,
		-size		=> 64
		);
	$f->submit;
	$var{codeForm} = $f->print;

	return WebGUI::Template::process(1, 'Operation/RedeemSubscription', \%var);
}

1;
