package WebGUI::Asset::Sku::Subscription;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
aspect assetName           => ['assetName', 'Asset_Subscription'];
aspect icon                => 'subscription.gif';
aspect tableName           => 'Subscription';
property templateId => (
            tab             => "display",
            fieldType       => "template",
            namespace       => "Subscription",
            default         => 'eqb9sWjFEVq0yHunGV8IGw',
            label           => ["template", 'Asset_Subscription'],
            hoverHelp       => ["template help", 'Asset_Subscription'],
         );
property redeemSubscriptionCodeTemplateId => (
            tab             => "display",
            fieldType       => "template",
            namespace       => "Operation/RedeemSubscription",
            default         => 'PBtmpl0000000000000053',
            label           => ["redeem subscription code template", 'Asset_Subscription'],
            hoverHelp       => ["redeem subscription code template help", 'Asset_Subscription'],
         );
property thankYouMessage => (
            tab             => "properties",
            builder         => '_thankYouMessage_default',
            lazy            => 1,
            fieldType       => "HTMLArea",
            label           => ["thank you message", 'Asset_Subscription'],
            hoverHelp       => ["thank you message help", 'Asset_Subscription'],
         );
sub _thankYouMessage_default {
    my $session = shift->session;
	my $i18n = WebGUI::International->new($session, "Asset_Subscription");
    return $i18n->get("default thank you message");
}
property price => (
            fieldType       => 'float',
            label           => ['subscription price', 'Asset_Subscription'],
            hoverHelp       => ['subscription price description', 'Asset_Subscription'],
            default         => '0.00',
         );
property subscriptionGroup => (
            fieldType       => 'group',
            label           => ['subscription group', 'Asset_Subscription'],
            hoverHelp       => ['subscription group description', 'Asset_Subscription'],
            defaultvalue    => [ 2 ]
         );
property recurringSubscription => (
            fieldType       => 'yesNo',
            label           => ['recurring subscription', 'Asset_Subscription'],
            hoverHelp       => ['recurring subscription description', 'Asset_Subscription'],
            default         => 1,
         );
property duration => ( 
            fieldType       => 'selectBox',
            label           => ['subscription duration', 'Asset_Subscription'],
            hoverHelp       => ['subscription duration description', 'Asset_Subscription'],
            default         => 'Monthly',
            options         => \&_duration_options,
         );
sub _duration_options {
    my $session = shift->session;
    return WebGUI::Shop::Pay->new( $session )->getRecurringPeriodValues,
}
property executeOnSubscription => (
            fieldType       => 'text',
            label           => ['execute on subscription', 'Asset_Subscription'],
            hoverHelp       => ['execute on subscription description', 'Asset_Subscription'],
            default         => '',
         );
property karma => (
    fieldType       => 'integer',
    noFormPost      => \&_karma_noFormPost,
    label           => ['subscription karma', 'Asset_Subscription'],
    hoverHelp       => ['subscription karma description', 'Asset_Subscription'],
    defaultvalue	=> 0,
);
sub _karma_noFormPost {
    my $session = shift->session;
    return ! $session->setting->get('useKarma');
}



use WebGUI::Asset::Template;
use WebGUI::Form;
use WebGUI::Shop::Pay;

=head1 NAME

Package WebGUI::Asset::Sku::Subscription

=head1 DESCRIPTION

This asset makes subscriptionss possible.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::Subscription;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 apply ( [ $userId ] )

Method for subscribing a user.  Adds user to the proper group and sets the expiration date,
adds karma to the user for purchasing a subscription, and then runs any external commands
as specified by the executeOnSubscription property.  Macros in executeOnSubscription are
expanded before the command is executed.

=head3 userId

ID of the user purchasing the subscription.  If omitted, uses the current user as
specified by the session variable.

=cut

sub apply {
	my $self    = shift;
    my $session = $self->session;
	my $userId  = shift || $session->user->userId;
	my $groupId = $self->subscriptionGroup;

	# Make user part of the right group and adjust the expiration date
	my $group   = WebGUI::Group->new($session, $groupId);
    my $user    = WebGUI::User->new($session, $userId);
    if ($user->isInGroup($group->getId) && ! $self->isRecurring) {
        my $expireDate = $group->userGroupExpireDate($userId);
        $expireDate   += $self->getExpirationOffset;
        $group->userGroupExpireDate($userId, $expireDate);
    }
    else {
        $group->addUsers( [$userId], $self->getExpirationOffset );
    }

	# Add karma to the user's account
    if ($session->setting->get('useKarma')) {
        WebGUI::User->new($session,$userId)->karma($self->karma, 'Subscription', 'Added for purchasing subscription '.$self->title);
    }

	# Process the executeOnPurchase field
	my $command = $self->executeOnSubscription;
	WebGUI::Macro::process($session,\$command);
	system($command) if ($self->executeOnSubscription ne "");
}


#-------------------------------------------------------------------

=head2 generateSubscriptionCode ( length )

Generates a subscription code with the given length. Does not save to the db.

=head3 length

The length of the code.

=cut

sub generateSubscriptionCode {
    my $self            = shift;
	my $codeLength      = shift || 64;
	my @codeElements    = ('A'..'Z', 'a'..'z', 0..9, '-');
	my $code;

	for (1 .. $codeLength) {
		$code .= $codeElements[rand(63)];
	}

	return $code;
}

#-------------------------------------------------------------------

=head2 generateSubscriptionCodeBatch ( numberOfCodes, length, expirationDate, name, description )

Creates a batch of subscription codes.

=head3 numberOfCodes

The number of codes in this batch.

=head3 length

The length of each code.

=head3 expirationDate

The epoch for the date when the codes expire.

=head3 name

The name for this batch.

=head3 description

The batch description.

=cut

sub generateSubscriptionCodeBatch {
    my $self            = shift;
    my $numberOfCodes   = shift;
    my $codeLength      = shift;
    my $expirationDate  = shift;
    my $name            = shift || 'Untitled';
    my $description     = shift;
    my $session         = $self->session;
    my $now             = time;

    # Create a new batch and write its properties to the db
    my $batchId = $session->db->setRow( 'Subscription_codeBatch', 'batchId', {
        batchId         => 'new',
        name            => $name,
        description     => $description,
        subscriptionId  => $self->getId,
        expirationDate  => $expirationDate,
        dateCreated     => $now
    });

    # Generate the codes for this batch
    for ( 1 .. $numberOfCodes ) { 
        # Generate a code
		my $code = $self->generateSubscriptionCode( $codeLength );

        # Make sure the code is unique
        while ( $session->db->quickScalar("select code from Subscription_code where code=?", [ $code ] ) ) {
    		$code = $self->generateSubscriptionCode( $codeLength );
        }
		
        # Code is unique so store it
        $session->db->setRow( 'Subscription_code', 'code', 
            {
                batchId             => $batchId,
                status              => 'Unused',
                dateUsed            => 0,
                usedBy              => 0,
            }, 
            $code 
        );
	}

    return $batchId;
}

#-------------------------------------------------------------------

=head2 getAddToCartForm ( )

Returns a form to add this Sku to the cart.  Used when this Sku is part of
a shelf.  Override master class to add different form.

=cut

sub getAddToCartForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_Subscription');
    return
        WebGUI::Form::formHeader($session, {action => $self->getUrl})
      . WebGUI::Form::hidden(    $session, {name => 'func', value => 'purchaseSubscription'})
      . WebGUI::Form::submit(    $session, {value => $i18n->get('purchase button')})
      . WebGUI::Form::formFooter($session)
      ;
}

#-------------------------------------------------------------------

=head2 getAdminConsoleWithSubmenu ( )

Returns an admin console with management links added to the submenu.

=cut

sub getAdminConsoleWithSubmenu {
	my $self    = shift;
    my $session = $self->session;
	my $ac      = $self->getAdminConsole;
	my $i18n    = WebGUI::International->new( $session, 'Asset_Subscription' );

	$ac->addSubmenuItem( $self->getUrl('func=createSubscriptionCodeBatch'),        $i18n->get('generate batch'));
	$ac->addSubmenuItem( $self->getUrl('func=listSubscriptionCodes;selection=dc'), $i18n->get('manage codes')  );
	$ac->addSubmenuItem( $self->getUrl('func=listSubscriptionCodeBatches'),        $i18n->get('manage batches'));

	return $ac;
}

#-------------------------------------------------------------------

=head2 getCode ( code )

Returns a hashref with the properties of the passed code.

=head3 code

The code for which the properties hould be returned.

=cut

sub getCode {
    my $self    = shift;
    my $code    = shift;
    my $session = $self->session;

    my $codeProperties = $session->db->quickHashRef(
         " select * from Subscription_code as t1, Subscription_codeBatch as t2 "
        ." where t1.batchId = t2.batchId and t1.code=? and t2.subscriptionId=?",
        [
            $code,
            $self->getId,
        ]
    );

    return $codeProperties || {};
}

#-------------------------------------------------------------------

=head2 getCodesInBatch ( batchId )

Returns a hashref of hashrefs containing the properties of all the codes in a batch. 
The format is as follows:

    $codes->{ CODE }->{ PROPERTY }

=head3 batchId

The id of the batch.

=cut

sub getCodesInBatch {
    my $self    = shift;
    my $batchId = shift;
    my $session = $self->session;
    my $codes   = {};

    my $sth = $session->db->read('select * from Subscription_code where batchId=?', [
        $batchId
    ]);

    while (my $row = $sth->hashRef) {
        $codes->{ $row->{code} } = $row;
    }

    $sth->finish;

    return $codes;
}

#-------------------------------------------------------------------

=head2 getConfiguredTitle

Returns title + price

=cut

sub getConfiguredTitle {
    my $self = shift;
    return $self->getTitle." (".$self->getOptions->{price}.")";
}

#-------------------------------------------------------------------

=head2 getExpirationOffset ( duration )

Returns the number of seconds tied to one of the allowed intervals used by the commerce system.

=head3 duration

The identifier of the interval. Can be either 'Weekly', 'BiWeekly', 'FourWeekly', 'Monthly', 'Quarterly',
'HalfYearly' or 'Yearly'. Defaults to the duration of the subscription.

=cut

sub getExpirationOffset {
    my $self        = shift;
	my $duration    = shift || $self->duration;
    
    #                                              y, m,  d  
    return $self->session->datetime->addToDate( 1, 0, 0,  7 ) - 1 if $duration eq 'Weekly';
	return $self->session->datetime->addToDate( 1, 0, 0, 14 ) - 1 if $duration eq 'BiWeekly';
	return $self->session->datetime->addToDate( 1, 0, 0, 28 ) - 1 if $duration eq 'FourWeekly';
	return $self->session->datetime->addToDate( 1, 0, 1,  0 ) - 1 if $duration eq 'Monthly';
	return $self->session->datetime->addToDate( 1, 0, 3,  0 ) - 1 if $duration eq 'Quarterly';
	return $self->session->datetime->addToDate( 1, 0, 6,  0 ) - 1 if $duration eq 'HalfYearly';
	return $self->session->datetime->addToDate( 1, 1, 0,  0 ) - 1 if $duration eq 'Yearly';

    # TODO: Throw exception
}

#-------------------------------------------------------------------

=head2 getPrice

Returns configured price, 0.00 if neither of those are available.

=cut

sub getPrice {
    my $self = shift;
    return $self->price || 0.00;
}

#-------------------------------------------------------------------

=head2 getRecurInterval

Returns the duration of this subscription in a format used by the commerce system.

=cut

sub getRecurInterval {
    my $self    = shift;

    return $self->duration;
}

#-------------------------------------------------------------------

=head2 isRecurring

Tells the commerce system this Sku is recurring.

=cut

sub isRecurring {
    my $self = shift;

    return $self->recurringSubscription;
}

#-------------------------------------------------------------------

=head2 onCompletePurchase

Applies the first term of the subscription. This method is called when the payment is successful.

=cut

sub onCompletePurchase {
    my $self = shift;

    $self->apply;
}

#-------------------------------------------------------------------

=head2 prepareView

Prepares the template.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $templateId = $self->templateId;
	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 redeemCode ( code )

Redeems a subscription code. Returns undef if redemption is successful, otherwise an error message is returned.

=head3 code

The code that should be redeemed.

=cut

sub redeemCode {
    my $self    = shift;
    my $code    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, "Asset_Subscription");

    my $properties = $self->getCode( $code );

    if ($properties->{ status } eq 'Unused' && $properties->{ expirationDate } >= time) {
        # Code is ok so apply the subscription
        $self->apply;

        # Set code to Used
        $session->db->write("update Subscription_code set status='Used', dateUsed=? where code =?", [
            time,
            $code,
        ]);
    } else {
        return $i18n->get('redeem code failure');
    }

    return undef;
}

#-------------------------------------------------------------------

=head2 view

Displays the subscription form.

=cut

sub view {
    my ($self) = @_;
    my $session = $self->session;

	my $i18n = WebGUI::International->new($session, "Asset_Subscription");
    my %var = (
        formHeader          => WebGUI::Form::formHeader($session, { action=>$self->getUrl })
            . WebGUI::Form::hidden( $session, { name=>"func", value=>"purchaseSubscription" }),
        formFooter          => WebGUI::Form::formFooter($session),
        purchaseButton      => WebGUI::Form::submit( $session,  { value => $i18n->get("purchase button") }),
        hasAddedToCart      => $self->{_hasAddedToCart},
        continueShoppingUrl => $self->getUrl,
        codeControls        => join (' &middot; ', (
            '<a href="'.$self->getUrl('func=createSubscriptionCodeBatch') .'">'.$i18n->get('generate batch').'</a>',
            '<a href="'.$self->getUrl('func=listSubscriptionCodes')       .'">'.$i18n->get('manage codes').'</a>',
            '<a href="'.$self->getUrl('func=listSubscriptionCodeBatches') .'">'.$i18n->get('manage batches').'</a>',
            )),
        price               => sprintf("%.2f", $self->getPrice),
    );
    my $hasCodes = $self->session->db->quickScalar('select count(*) from Subscription_code as t1, Subscription_codeBatch as t2 where t1.batchId = t2.batchId and t2.subscriptionId=?', [$self->getId]);
    if ($hasCodes) {
        $var{redeemCodeLabel} = $i18n->get('redeem code');
        $var{redeemCodeUrl}   = $self->getUrl('func=redeemSubscriptionCode');

    }
    return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#----------------------------------------------------------------------------

=head2 www_createSubscriptionCodeBatch ( $error )

Form to accept parameters to create a batch of subscription codes.

=head3 error

An HTML array ref of an error message to be returned to the user.

=cut

sub www_createSubscriptionCodeBatch {
    my $self    = shift;
    my $error   = shift;
	my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, "Asset_Subscription");

    # Check privs
    return $session->privilege->adminOnly() unless $self->canEdit;
	
    # Generate error message if errors occurred
	my $errorMessage = $i18n->get('create batch error').'<ul><li>'.join('</li><li>', @{$error}).'</li></ul>' if ($error);
	
    # Generate the properties form for this subscription code batch	
	my $f = WebGUI::HTMLForm->new( $session );
	$f->submit;
	$f->hidden(
		-name       => 'func', 
		-value      => 'createSubscriptionCodeBatchSave'
		);
	$f->integer(
		-name	    => 'noc',
		-label	    => $i18n->get('noc'),
		-hoverHelp  => $i18n->get('noc description'),
		-value	    => $session->form->process("noc") || 1
		);
	$f->integer(
		-name	    => 'codeLength',
		-label	    => $i18n->get('code length'),
		-hoverHelp  => $i18n->get('code length description'),
		-value	    => $session->form->process("codeLength") || 64
		);
	$f->interval(
		-name       => 'expires',
		-label      => $i18n->get('codes expire'),
		-hoverHelp  => $i18n->get('codes expire description'),
		-value      => $session->form->process("expires") || $session->datetime->intervalToSeconds(1, 'months')
		);
    $f->text(
        -name       => 'name',
        -label      => $i18n->get('batch name'),
        -hoverHelp  => $i18n->get('batch name description'),
        -value      => $session->form->process('name'),
        );
	$f->textarea(
		-name	    => 'description',
		-label	    => $i18n->get('batch description'),
		-hoverHelp	=> $i18n->get('batch description description'),
		-value	    => $session->form->process("description"),
		);
	$f->submit;

	return $self->getAdminConsoleWithSubmenu->render( $errorMessage.$f->print, $i18n->get('create batch menu') );
}

#-------------------------------------------------------------------

=head2 www_createSubscriptionCodeBatchSave ( )

Method that accepts the form parameters to create a batch of subscription codes.  

=cut

sub www_createSubscriptionCodeBatchSave {
    my $self    = shift;
	my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, "Asset_Subscription");

    # Check privs
	return $session->privilege->adminOnly() unless $self->canEdit;
		
	my $numberOfCodes   = $session->form->process("noc");
	my $description     = $session->form->process("description");
    my $name            = $session->form->process("name");
	my $expires         = $session->form->interval('expires');
	my $batchId         = $session->id->generate;
    my $codeLength      = $session->form->process("codeLength");

    # Sanity check input
    my @error;
	push(@error, $i18n->get('no description error')) unless ($description);
	push(@error, $i18n->get('code length error')) 
        unless (
                $codeLength >= 10 
            &&  $codeLength <= 64 
            &&  $codeLength =~ m/^\d\d$/
        );

    # Return an error message if an error occurred
	return $self->www_createSubscriptionCodeBatch( \@error ) if @error;

    # Create the code batch
    $self->generateSubscriptionCodeBatch(
        $numberOfCodes,
        $codeLength,
        time() + $expires,
        $name,
        $description,
    );

	return $self->www_listSubscriptionCodeBatches;
}

#-------------------------------------------------------------------

=head2 www_deleteSubscriptionCodeBatch ( )

Deletes a batch of subscription codes.

=cut

sub www_deleteSubscriptionCodeBatch {
    my $self    = shift;
    my $session = $self->session;
    my $batchId = $session->form->process('bid');

    return $session->privilege->insufficient unless $self->canEdit;

    # Remove code batch properties and codes in batch
    $session->db->write( 'delete from Subscription_codeBatch where batchId=?', [ $batchId ] );
    $session->db->write( 'delete from Subscription_code where batchId=?',      [ $batchId ] );

    return $self->www_listSubscriptionCodeBatches;
}

#-------------------------------------------------------------------

=head2 www_deleteSubscriptionCodes ( )

Deletes subscription codes based on either their creation date or their usage date.

=cut

sub www_deleteSubscriptionCodes {
	my $self    = shift;
    my $session = $self->session;

	return $session->privilege->insufficient unless $self->canEdit;
	
    my $selectBy = $session->form->process('selection');

	if ($selectBy eq 'dc') {
        # Delete codes by creation date
        my $from    = $session->form->date( 'dcStart'   );
        my $to      = $session->form->date( 'dcStop'    );

		$session->db->write( 
            'delete from Subscription_code where batchId in '
            .' ( select batchId from Subscription_codeBatch '
            .'   where dateCreated >= ? and dateCreated <= ? and subscriptionId=? '
            .' )', 
            [
                $from,
                $to,
                $self->getId,
            ]
        );
	} 
    elsif ($selectBy eq 'du') {
        # Delete codes by usage date
        my $from    = $session->form->date( 'duStart'   );
        my $to      = $session->form->date( 'duStop'    );

		$session->db->write( 
            'delete from Subscription_code where dateUsed >= ? and dateUsed <= ? and batchId in '
            .'( select batchId from Subscription_codeBatch where subscriptionId=? )',
            [
                $from,
                $to,
            ]
        );
	}

	return $self->www_listSubscriptionCodes;
}

#-------------------------------------------------------------------

=head2 www_listSubscriptionCodeBatches

Display a list of code batches for this subscription.

=cut

sub www_listSubscriptionCodeBatches {
	my $self    = shift;
    my $session = $self->session;
	my $i18n    = WebGUI::International->new( $session, "Asset_Subscription" );

    # Check privs
    return $session->privilege->insufficient unless $self->canEdit;

	my $dcStart     = $session->form->date('dcStart');
	my $dcStop      = $session->datetime->addToTime($session->form->date('dcStop'), 23, 59);
    my $selection   = $session->form->process('selection');

    my $f = WebGUI::HTMLForm->new( $session );
    $f->hidden(
        name    => 'func',
        value   => 'listSubscriptionCodeBatches',
    );

    $f->readOnly(
        label   =>
            WebGUI::Form::radio( $session, { name => 'selection', value => 'dc', checked => ($selection eq 'dc') } )
            . $i18n->get('selection created'),
        value   =>
            WebGUI::Form::date( $session,   { name => 'dcStart',    value=> $dcStart } )
            . ' ' . $i18n->get( 'and' ) . ' ' 
            . WebGUI::Form::date( $session, { name => 'dcStop',     value=> $dcStop } ),
    );
    $f->readOnly(
        label   =>
            WebGUI::Form::radio( $session, { name => 'selection', value => 'all', checked => ($selection ne 'dc') } )
            . $i18n->get('display all'),
        value   => '',
    );
    $f->submit(
        value   => $i18n->get('select'),
    );

    ##Configure the SQL query based on what the user has selected.
    my $sqlQuery  = 'select * from Subscription_codeBatch where subscriptionId=?';
    my $sqlParams = [ $self->getId ];
    if ($selection eq 'dc') {
        $sqlQuery .= ' and dateCreated >= ? and dateCreated <= ?';
        push @{ $sqlParams }, $dcStart, $dcStop;
    }

    # Set up a paginator to paginate the list of batches
	my $p = WebGUI::Paginator->new( $session, $self->getUrl('func=listSubscriptionCodeBatches') );
	$p->setDataByQuery( $sqlQuery, undef, 1, $sqlParams);

    # Fetch the list of batches at the current paginition index
    my $batches = $p->getPageData;

	my $output = $f->print;
	$output .= $p->getBarTraditional($session->form->process("pn"));
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	foreach my $batch ( @{$batches} ) {
		$output .= '<tr><td>';		
        $output .= $session->icon->delete(
            'func=deleteSubscriptionCodeBatch;bid='.$batch->{batchId}, 
            $self->getUrl,
            $i18n->get('delete batch confirm'));
		$output .= '</td>';		
		$output .= '<td>' . $batch->{ name        } . '</td>';
		$output .= '<td>' . $batch->{ description } . '</td>';
		$output .= '<td>'
            . '<a href="' . $self->getUrl('func=listSubscriptionCodes;selection=b;bid=' . $batch->{ batchId }) . '">'
            . $i18n->get('list codes in batch').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session->form->process("pn"));
	
	$output = $i18n->get('no subscription code batches') unless $session->db->quickScalar('select count(*) from Subscription_codeBatch');

	return $self->getAdminConsoleWithSubmenu->render( $output, $i18n->get('manage batches') );
}

#-------------------------------------------------------------------

=head2 www_listSubscriptionCodes ( )

Displays a list of subscription codes for this subscription.

=cut

sub www_listSubscriptionCodes {
    my $self    = shift;
	my $session = $self->session;
	my $i18n    = WebGUI::International->new($session, "Asset_Subscription");

	my ($p, $codes, $output, $where, $ops, $delete);
	return $session->privilege->insufficient unless $self->canEdit;
	my $dcStart     = $session->form->date('dcStart');
	my $dcStop      = $session->datetime->addToTime($session->form->date('dcStop'), 23, 59);
	my $duStart     = $session->form->date('duStart');
	my $duStop      = $session->datetime->addToTime($session->form->date('duStop'), 23, 59);
    my $batchId     = $session->form->process('bid');
    my $selection   = $session->form->process('selection');
	my $batches = 
        $session->db->buildHashRef('select batchId, name from Subscription_codeBatch where subscriptionId=?',
        [
            $self->getId,
        ]);	


    # Build a subscription code selection form
    my $f = WebGUI::HTMLForm->new( $session );
    $f->hidden(
        name    => 'func',
        value   => 'listSubscriptionCodes',
    );
    #--- Selection by date created
    $f->readOnly(
        label   => 
            WebGUI::Form::radio( $session, { name => 'selection', value => 'du', checked => ($selection eq 'du') } ) 
            . $i18n->get('selection used'),
        value   =>
            WebGUI::Form::date( $session,   { name => 'duStart',    value=> $duStart } )
            . ' ' . $i18n->get( 'and' ) . ' ' 
            . WebGUI::Form::date( $session, { name => 'duStop',     value=> $duStop } ),
    );
    #--- Selection by date used
    $f->readOnly(
        label   =>
            WebGUI::Form::radio( $session, { name => 'selection', value => 'dc', checked => ($selection eq 'dc') } )
            . $i18n->get('selection created'),
        value   =>
            WebGUI::Form::date( $session,   { name => 'dcStart',    value=> $dcStart } )
            . ' ' . $i18n->get( 'and' ) . ' ' 
            . WebGUI::Form::date( $session, { name => 'dcStop',     value=> $dcStop } ),
    );
    #--- Selection by batch
    $f->readOnly(
        label   =>
            WebGUI::Form::radio( $session, { name => 'selection', value => 'b', checked => ($selection eq 'b') } )
            . $i18n->get('selection batch name'),
        value   =>
            WebGUI::Form::selectBox( $session, { name => 'bid', value => $batchId, options => $batches } ),
    );
    #--- Submit button
    $f->submit(
        value   => $i18n->get('select'),
    );

	if ($session->form->process("selection") eq 'du') {
		$where = " and dateUsed >= ".$session->db->quote($duStart)." and dateUsed <= ".$session->db->quote($duStop);
		$ops = ';duStart='.$session->form->process('duStart').';duStop='.$session->form->process('duStop').';selection=du';
		$delete = '<a href="'.$self->getUrl('func=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session->form->process("selection") eq 'dc') {
		$where = " and dateCreated >= ".$session->db->quote($dcStart)." and dateCreated <= ".$session->db->quote($dcStop);
		$ops = ';dcStart='.$session->form->process('dcStart').';dcStop='.$session->form->process('dcStop').';selection=dc';
		$delete = '<a href="'.$self->getUrl('func=deleteSubscriptionCodes'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} elsif ($session->form->process("selection") eq 'b') {
		$where = " and t1.batchId=".$session->db->quote($session->form->process("bid"));
		$ops = ';bid='.$session->form->process("bid").';selection=b';
		$delete = '<a href="'.$self->getUrl('func=deleteSubscriptionCodeBatch'.$ops).'">'.$i18n->get('delete codes').'</a>';
	} else {
        return $self->getAdminConsoleWithSubmenu->render( $output, $i18n->get('listSubscriptionCodes title') );
	}
	
	$p = WebGUI::Paginator->new( $session, $self->getUrl('func=listSubscriptionCodes'.$ops) );
	$p->setDataByQuery(
        "select t1.*, t2.* from Subscription_code as t1, Subscription_codeBatch as t2 ".
        " where t1.batchId=t2.batchId and subscriptionId=?".$where,
        undef, undef,
        [
            $self->getId,
        ]
     );

	$codes = $p->getPageData;

	$output = $i18n->get('selection message');
    $output .= $f->print;
	$output .= '<br />'.$delete.'<br />' if ($delete) and $p->getRowCount;
	$output .= $p->getBarTraditional($session->form->process("pn"));
	$output .= '<br />';
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr>';
	$output .= '<th>&nbsp;</th><th>'.$i18n->get('batch id').'</th><th>'.$i18n->get('code').'</th><th>'.$i18n->get('creation date').
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

	return $self->getAdminConsoleWithSubmenu->render( $output, $i18n->get('listSubscriptionCodes title') );
}


#-------------------------------------------------------------------

=head2 www_purchaseSubscription

Add this subscription to the cart.

=cut

sub www_purchaseSubscription {
    my $self = shift;
    if ($self->canView) {
        $self->{_hasAddedToCart} = 1;
        $self->addToCart({price => $self->getPrice});
    }
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_redeemSubscriptionCode ( )

Redeems a subscription code or returns an error.

=cut

sub www_redeemSubscriptionCode {
    my $self    = shift;
	my $session = $self->session;
	my $i18n    = WebGUI::International->new($session, "Asset_Subscription");
    my $code    = $session->form->process("code");
    my $var     = {};

	if ($code) {
        my $error = $self->redeemCode( $code );
 
        my $codeProperties = $self->getCode( $code );
        $var->{ batchDescription    } = $codeProperties->{ description };
        $var->{ message             } = $error || $i18n->get('redeem code success');
	} else {
		$var->{ message             } = $i18n->get('redeem code ask for code');
	}
	
	my $f = WebGUI::HTMLForm->new( $session );
	$f->hidden(
		-name       => 'func',
		-value      => 'redeemSubscriptionCode'
		);
	$f->text(
		-name		=> 'code',
		-label		=> $i18n->get('code'),
		-hoverHelp	=> $i18n->get('code description'),
		-maxLength	=> 64,
		-size		=> 30
		);
	$f->submit;
	$var->{ codeForm } = $f->print;

    return $self->processStyle($self->processTemplate($var, $self->redeemSubscriptionCodeTemplateId));
}

1;

