package WebGUI::Shop::PayDriver::ITransact;

use strict;
use XML::Simple;

use base qw/WebGUI::Shop::PayDriver/;

sub _monthYear {
    my $session = shift;
    my $form    = $session->form;

	tie my %months, "Tie::IxHash";
	tie my %years,  "Tie::IxHash";
	%months = map { sprintf( '%02d', $_ ) => sprintf( '%02d', $_ ) } 1 .. 12;
	%years  = map { $_ => $_ } 2004 .. 2099;

    my $monthYear = 
        WebGUI::Form::selectBox( $session, {
            name    => 'expMonth', 
            options => \%months, 
            value   => [ $form->process("expMonth") ]
        })
        . " / "
        . WebGUI::Form::selectBox( $session, {
            name    => 'expYear',
            options => \%years, 
            value   => [ $form->process("expYear") ]
        });

    return $monthYear;
}

#-------------------------------------------------------------------
sub _generateCancelRecurXml {
    my $self        = shift;
    my $transaction = shift;

    # Construct xml
    my $vendorIdentification;
    $vendorIdentification->{ VendorId           } = $self->get('vendorId');
    $vendorIdentification->{ VendorPassword     } = $self->get('password');
    $vendorIdentification->{ HomePage           } = $self->session->setting->get("companyURL");
    
    my $recurUpdate;
    $recurUpdate->{ OperationXID    } = $transaction->get('gatewayId');
    $recurUpdate->{ RemReps         } = 0;
   
    my $xmlStructure = {
        GatewayInterface => {
            VendorIdentification    => $vendorIdentification,
            RecurUpdate             => $recurUpdate,
        }
    };

    my $xml = 
        '<?xml version="1.0" standalone="yes"?>'
        . XMLout( $xmlStructure,
            NoAttr      => 1,
            KeepRoot    => 1,
            KeyAttr     => [],
        );

    return $xml;
}

#-------------------------------------------------------------------

=head2 doXmlRequest ( xml [ isAdministrative ] )

Post an xml request to the ITransact backend. Returns a LWP::UserAgent response object.

=head3 xml

The xml string. Must contain a valid xml header.

=head3 isGatewayInterface

Determines what kind of request the xml is. For GatewayRequests set this value to 1. For SaleRequests set to 0 or
undef.

=cut

sub doXmlRequest {
    my $self                = shift;
    my $xml                 = shift;
    my $isGatewayInterface  = shift;

    # Figure out which cgi script we should post the XML to.
    my $xmlTransactionScript    = $isGatewayInterface
                                ? 'https://secure.paymentclearing.com/cgi-bin/rc/xmltrans2.cgi'
                                : 'https://secure.paymentclearing.com/cgi-bin/rc/xmltrans.cgi'
                                ;
    # Set up LWP
    my $userAgent = LWP::UserAgent->new;
	$userAgent->env_proxy;
	$userAgent->agent("WebGUI");
    
    # Create a request and stuff the xml in it
    my $request = HTTP::Request->new( POST => $xmlTransactionScript );
	$request->content_type( 'application/x-www-form-urlencoded' );
	$request->content( 'xml='.$xml );

    # Do the request
    my $response = $userAgent->request($request);
                            
    return $response;
}

#-------------------------------------------------------------------

=head2 cancelRecurringPayment ( transaction )

Cancels a recurring transaction. Returns an array containing ( isSuccess, gatewayStatus, gatewayError).

=head3 transaction

The instanciated recurring transaction object.

=cut

sub cancelRecurringPayment {
    my $self        = shift;
    my $transaction = shift;
    my $session     = $self->session;
    #### TODO: Throw exception

    # Get the payment definition XML
    my $xml = $self->_generateCancelRecurXml( $transaction );
    $session->errorHandler->info("XML Request: $xml");

    # Post the xml to ITransact 
    my $response = $self->doXmlRequest( $xml, 1 );

    # Process response
	if ($response->is_success) {
		# We got some XML back from iTransact, now parse it.
        $session->errorHandler->info('Starting request');
        my $transactionResult = XMLin( $response->content );
		unless (defined $transactionResult->{ RecurUpdateResponse }) {
			# GatewayFailureResponse: This means the xml is invalid or has the wrong mime type
            $session->errorHandler->info( "GatewayFailureResponse: result: [" . $response->content . "]" );
            return( 
                0, 
                $transactionResult->{ Status }, 
                $transactionResult->{ ErrorMessage } . ' Category: ' . $transactionResult->{ ErrorCategory } 
            );
		} else {
            # RecurUpdateResponse: We have succesfully sent the XML and it was correct. Note that this doesn't mean
            # that the cancellation has succeeded. It only has if Status is set to OK and the remaining terms is 0.
            $session->errorHandler->info( "RecurUpdateResponse: result: [" . $response->content . "]" );
            my $transactionData = $transactionResult->{ RecurUpdateResponse };

            my $status          = $transactionData->{ Status            };
            my $errorMessage    = $transactionData->{ ErrorMessage      };
            my $errorCategory   = $transactionData->{ ErrorCategory     };
            my $remainingTerms  = $transactionData->{ RecurDetails      }->{ RemReps    };
            
            # Uppercase the status b/c the documentation is not clear on the case.
            my $isSuccess       = uc( $status ) eq 'OK' && $remainingTerms == 0;
       
            return ( $isSuccess, $status, "$errorMessage Category: $errorCategory" );
		}
	} else {
		# Connection Error
        $session->errorHandler->info("Connection error");

        return ( 0, undef, 'ConnectionError', $response->status_line );
	}
}

#-------------------------------------------------------------------
sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;

    my $i18n = WebGUI::International->new($session, 'PayDriver_ITransact');

    tie my %fields, 'Tie::IxHash';
    %fields = (
        vendorId        => {
           fieldType    => 'text',
           label        => $i18n->echo('vendorId'),
           hoverHelp    => $i18n->echo('vendorId help'),
        },
        password        => {
            fieldType   => 'password',
            label       => $i18n->echo('password'),
            hoverHelp   => $i18n->echo('password help'),
        },
        useCVV2         => {
            fieldType   => 'yesNo',
            label       => $i18n->echo('use cvv2'),
            hoverHelp   => $i18n->echo('use cvv2 help'),
        },
        emailMessage    => {
            fieldType   => 'textarea',
            label       => $i18n->echo('emailMessage'),
            hoverHelp   => $i18n->echo('emailMessage help'),
        },
        # readonly stuff from old plugin here?
    );
 
    push @{ $definition }, {
        name        => $i18n->echo('Itransact'),
        properties  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub _generatePaymentRequestXML {
    my $self            = shift;
    my $transaction     = shift;
    my $session         = $self->session;
    my $paymentAddress  = $self->{ _billingAddress };
    my $cardData        = $self->{ _cardData };

    # Set up the XML.
    # --- Customer data part ---
    my $billingAddress;
    $billingAddress->{ Address1    } = $paymentAddress->{ address1     };
#    $billingAddress->{ Address2    } = $paymentAddress->{ address2     };
#    $billingAddress->{ Address3    } = $paymentAddress->{ address3     };
    $billingAddress->{ FirstName   } = $paymentAddress->{ firstName    };
    $billingAddress->{ LastName    } = $paymentAddress->{ lastName     };
    $billingAddress->{ City        } = $paymentAddress->{ city         };
    $billingAddress->{ State       } = $paymentAddress->{ state        };
    $billingAddress->{ Zip         } = $paymentAddress->{ code         };
    $billingAddress->{ Country     } = $paymentAddress->{ country      };
    $billingAddress->{ Phone       } = $paymentAddress->{ phoneNumber  };

    my $cardInfo;
    $cardInfo->{ CCNum      } = $cardData->{ acct       };
    $cardInfo->{ CCMo       } = $cardData->{ expMonth   };
    $cardInfo->{ CCYr       } = $cardData->{ expYear    };
    $cardInfo->{ CVV2Number } = $cardData->{ cvv2       } if $self->get('useCVV2');

    my $customerData;
    $customerData->{ Email                          } = $paymentAddress->{ email };
    $customerData->{ BillingAddress                 } = $billingAddress;
    $customerData->{ AccountInfo    }->{ CardInfo   } = $cardInfo;

    # --- Transaction data part ---
    my $emailText;
    $emailText->{ EmailTextItem     } = [
        $self->get('emailMessage'),
        'ID: '. $transaction->getId,
    ];

    # Process items
    my ($orderItems, $recurringData);
    my $items = $transaction->getItems;

    # Check if recurring payments have a unique transaction
    #### TODO: Throw the correct Exception Class
    WebGUI::Error::InvalidParam->throw( error => 'Recurring transaction mixed with other transactions' )
        if ( (scalar @{ $items } > 1) && (grep { $_->getSku->isRecurring } @{ $items }) );

    foreach my $item (@{ $items }) {
        my $sku = $item->getSku;

        # Since recur recipes are based on intervals defined in days, the first term will payed NOW. Since the
        # subscription start NOW too, we never need an initial amount for recurring payments.
        if ( $sku->isRecurring ) {
            $recurringData->{ RecurRecipe   } = $self->resolveRecurRecipe( $sku->getRecurInterval );
            $recurringData->{ RecurReps     } = 99999;
            $recurringData->{ RecurTotal    } = 
                $item->get('price') + $transaction->get('taxes') + $transaction->get('shippingPrice');
            $recurringData->{ RecurDesc     } = $item->get('configuredTitle');
        }
        else {
            push @{ $orderItems->{ Item } }, {
                Description     => $item->get('configuredTitle'),
                Cost            => $item->get('price'),
                Qty             => $item->get('quantity'),
            }
        }
    }

	# taxes, shipping, etc
	my $i18n = WebGUI::International->new($session, "Shop");
    #### TODO: Don't add this if the transaction is recurring
	if ( $transaction->get('taxes') > 0 ) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('taxes'),
			Cost			=> $transaction->get('taxes'),
			Qty				=> 1,
			};
	}
    #### TODO: Don't add this if the transaction is recurring
	if ($transaction->get('shippingPrice') > 0) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('shipping'),
			Cost			=> $transaction->get('shippingPrice'),
			Qty				=> 1,
			};
	}
	if ($transaction->get('shopCreditDeduction') < 0) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('in shop credit'),
			Cost			=> $transaction->get('shopCreditDeduction'),
			Qty				=> 1,
			};
	}

    my $vendorData;
    $vendorData->{ Element  }->{ Name   } = 'transactionId';
    $vendorData->{ Element  }->{ Value  } = $transaction->getId;

    my $transactionData;
    $transactionData->{ VendorId        } = $self->get('vendorId');
    $transactionData->{ VendorPassword  } = $self->get('password');
    $transactionData->{ VendorData      } = $vendorData;
    $transactionData->{ HomePage        } = $self->session->setting->get("companyURL");
    $transactionData->{ RecurringData   } = $recurringData if $recurringData;
    $transactionData->{ EmailText       } = $emailText if $emailText;
    $transactionData->{ OrderItems      } = $orderItems;

    # --- The XML structure ---
    my $xmlStructure = {
        SaleRequest => {
            CustomerData    => $customerData,
            TransactionData => $transactionData,
        }
    };

    my $xml = 
        '<?xml version="1.0" standalone="yes"?>'
        . XMLout( $xmlStructure,
            NoAttr      => 1,
            KeepRoot    => 1,
            KeyAttr     => [],
        );

    return $xml;
}

#-------------------------------------------------------------------
sub getButton {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'PayDriver_ITansact');

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $i18n->echo('ITransact') })
        . WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------
sub processCredentials {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
	my $i18n    = WebGUI::International->new($session,'CommercePaymentITransact');
    my @error;

    # Check address data
	push @error, $i18n->get( 'invalid firstName'    ) unless $form->process( 'firstName' );
	push @error, $i18n->get( 'invalid lastName'     ) unless $form->process( 'lastName'  );
	push @error, $i18n->get( 'invalid address'      ) unless $form->process( 'address'   );
	push @error, $i18n->get( 'invalid city'         ) unless $form->process( 'city'      );
	push @error, $i18n->get( 'invalid email'        ) unless $form->email  ( 'email'     );
	push @error, $i18n->get( 'invalid zip'          ) 
        if ( !$form->zipcode( 'zipcode' ) && $form->process( 'country' ) eq 'United States' );
	
    # Check credit card data
	push @error, $i18n->get( 'invalid card number'  ) unless $form->integer('cardNumber');	
	push @error, $i18n->get( 'invalid cvv2'         ) if ($self->get('useCVV2') && !$form->integer('cvv2'));

	# Check if expDate and expYear have sane values
	my ($currentYear, $currentMonth) = $self->session->datetime->localtime;
    my $expires = $form->integer( 'expYear' ) . sprintf '%02d', $form->integer( 'expMonth' );
    my $now     = $currentYear                . sprintf '%02d', $currentMonth;

    push @error, $i18n->get('invalid expiration date') unless $expires =~ m{^\d{6}$};
    push @error, $i18n->get('expired expiration date') unless $expires >= $now;

    # Everything ok process the actual data
	unless (@error) {
		$self->{ _cardData } = {
			acct		=> $form->integer( 'cardNumber' ),
			expMonth	=> $form->integer( 'expMonth'   ),
			expYear		=> $form->integer( 'expYear'    ),
			cvv2		=> $form->integer( 'cvv2'       ),
		};	
		
		$self->{ _billingAddress } = {
			address1	=> $form->process( 'address'    ),
			code	    => $form->zipcode( 'zipcode'    ),
			city		=> $form->process( 'city'       ),
			firstName	=> $form->process( 'firstName'  ),
			lastName	=> $form->process( 'lastName'   ),
			email		=> $form->email  ( 'email'      ),
			state		=> $form->process( 'state'      ),
			country		=> $form->process( 'country'    ),
			phoneNumber => $form->process( 'phone'      ),
		};

		return;
	}
			
	return \@error;
}


#-------------------------------------------------------------------
sub processPayment {
    my $self        = shift;
    my $transaction = shift;
    my $session     = $self->session;

    # Get the payment definition XML
    my $xml = $self->_generatePaymentRequestXML( $transaction );
    $session->errorHandler->info("XML Request: $xml");

	# Set up LWP
    my $userAgent = LWP::UserAgent->new;
	$userAgent->env_proxy;
	$userAgent->agent("WebGUI ");
    
    # Create a request and stuff the xml in it
    $session->errorHandler->info('Starting request');
    my $xmlTransactionScript = 'https://secure.paymentclearing.com/cgi-bin/rc/xmltrans.cgi';
    my $request = HTTP::Request->new( POST => $xmlTransactionScript );
	$request->content_type( 'application/x-www-form-urlencoded' );
	$request->content( 'xml='.$xml );

    # Do the request
    my $response = $userAgent->request($request);

    # Process response
	if ($response->is_success) {
		# We got some XML back from iTransact, now parse it.
        $session->errorHandler->info('Starting request');
        my $transactionResult = XMLin( $response->content );
#### TODO: More checking: price, address, etc
		unless (defined $transactionResult->{ TransactionData }) {
			# GatewayFailureResponse: This means the xml is invalid or has the wrong mime type
            $session->errorHandler->info("GatewayFailureResponse: result: [".$response->content."]");
            return( 
                0, 
                undef, 
                $transactionResult->{ Status }, 
                $transactionResult->{ ErrorMessage } . ' Category: ' . $transactionResult->{ ErrorCategory } 
            );
		} else {
            # SaleResponse: We have succesfully sent the XML and it was correct. Note that this doesn't mean that
            # the transaction has succeeded. It only has if Status is set to OK.
            $session->errorHandler->info("SaleResponse: result: [".$response->content."]");
            my $transactionData = $transactionResult->{ TransactionData };

            my $status          = $transactionData->{ Status            };
            my $errorMessage    = $transactionData->{ ErrorMessage      };
            my $errorCategory   = $transactionData->{ ErrorCategory     };
            my $gatewayCode     = $transactionData->{ XID               };
            my $isSuccess       = $status eq 'OK';
       
            return ( $isSuccess, $gatewayCode, $status, "$errorMessage Category: $errorCategory" );
		}
	} else {
		# Connection Error
        $session->errorHandler->info("Connection error");

        return ( 0, undef, 'ConnectionError', $response->status_line );
	}
}

#-------------------------------------------------------------------
sub www_processRecurringTransactionPostback {
	my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
	
    # Get posted data of interest
    my $originatingXid  = $form->process( 'orig_xid' );
    my $status          = $form->process( 'status' );
    my $xid             = $form->process( 'xid' );
    my $errorMessage    = $form->process( 'error_message' );

    # Fetch the original transaction
    my $baseTransaction = WebGUI::Shop::Transaction->newByGatewayId( $session, $originatingXid, $self->getId );

    # Create a new transaction for this term
    my $transaction     = $baseTransaction->duplicate( {
        originatingTransactionId    => $baseTransaction->getId,  
    });

    # Check the transaction status and act accordingly
    if ( uc $status eq 'OK' ) {
        # The term was succesfully payed
        $transaction->completePurchase( $xid, $status, $errorMessage );
    }
    else {
        # The term has not been payed succesfully
        $transaction->denyPurchase( $xid, $status, $errorMessage );
    }
}

#-------------------------------------------------------------------
sub www_getCredentials {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $i18n    = WebGUI::International->new($self->session, 'CommercePaymentITransact');
	my $u       = WebGUI::User->new($self->session,$self->session->user->userId);

	my $f = WebGUI::HTMLForm->new( $session );
    $self->getDoFormTags( 'pay', $f );

    # Address data form
	$f->text(
		-name	    => 'firstName',
		-label	    => $i18n->get('firstName'),
		-value	    => $form->process("firstName") || $u->profileField('firstName'),
	);
	$f->text(
		-name	    => 'lastName',
		-label	    => $i18n->get('lastName'),
		-value	    => $form->process("lastName") || $u->profileField('lastName'),
	);
	$f->text(
		-name	    => 'address',
		-label	    => $i18n->get('address'),
		-value	    => $form->process("address") || $u->profileField('homeAddress'),
	);
	$f->text(
		-name	    => 'city',
		-label	    => $i18n->get('city'),
		-value	    => $form->process("city") || $u->profileField('homeCity'),
	);
	$f->text(
		-name	    => 'state',
		-label	    => $i18n->get('state'),
		-value	    => $form->process("state") || $u->profileField('homeState'),
	);
	$f->zipcode(    
		-name	    => 'zipcode',
		-label	    => $i18n->get('zipcode'),
		-value	    => $form->process("zipcode") || $u->profileField('homeZip'),
	);
	$f->country(    
		-name       => "country",
		-label      => $i18n->get("country"),
		-value      => ($form->process("country",'country') || $u->profileField("homeCountry") || 'United States'),
	);
    $f->phone(
		-name       => "phone",
		-label      => $i18n->get("phone"),
		-value      => $form->process("phone",'phone') || $u->profileField("homePhone"),
	);
	$f->email(
		-name	    => 'email',
		-label	    => $i18n->get('email'),
		-value	    => $self->session->form->process("email") || $u->profileField('email'),
	);

    # Credit card information
	$f->text(
		-name	    => 'cardNumber',
		-label	    => $i18n->get('cardNumber'),
		-value	    => $self->session->form->process("cardNumber"),
	);
	$f->readOnly(
		-label	    => $i18n->get('expiration date'),
		-value	    => _monthYear( $session ),
	);
	$f->integer(
		-name	=> 'cvv2',
		-label	=> $i18n->get('cvv2'),
		-value  => $self->session->form->process("cvv2")
	) if ($self->get('useCVV2'));
    $f->submit(
        -value  => 'Checkout',
    );
    
	return $session->style->userStyle($f->print);	
}

#-------------------------------------------------------------------
sub www_pay {
    my $self    = shift;
    my $session = $self->session;

    # Check whether the user filled in the checkout form and process those.
    my $credentialsErrors = $self->processCredentials;
    
    # Go back to checkout form if credentials are not ok
    return $self->www_getCredentials( $credentialsErrors ) if $credentialsErrors;

    # Payment time!
    my $transaction = $self->processTransaction;

    return $transaction->www_thankYou($session);
}

1;

