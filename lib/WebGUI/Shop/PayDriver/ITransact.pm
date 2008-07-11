package WebGUI::Shop::PayDriver::ITransact;

use strict;
use XML::Simple;
use Data::Dumper;

use base qw/WebGUI::Shop::PayDriver/;

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
    $recurUpdate->{ OperationXID    } = $transaction->get('transactionCode');
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
            $recurringData->{ RecurRecipe   } = $self->_resolveRecurRecipe( $sku->getRecurInterval );
            $recurringData->{ RecurReps     } = 99999;
            $recurringData->{ RecurTotal    } = 
                $item->get('price') + $transaction->get('taxes') + $transaction->get('shippingPrice');
            $recurringData->{ RecurDesc     } = $item->get('configuredTitle');
        }
#       else {
            push @{ $orderItems->{ Item } }, {
                Description     => $item->get('configuredTitle'),
                Cost            => $item->get('price'),
                Qty             => $item->get('quantity'),
            }
#        }
    }

	# taxes, shipping, etc
	my $i18n = WebGUI::International->new($session, "Shop");
	if ( $transaction->get('taxes') > 0 ) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('taxes'),
			Cost			=> $transaction->get('taxes'),
			Qty				=> 1,
			};
	}
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
    $transactionData->{ OrderItems      } = $orderItems if $orderItems;

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
sub _resolveRecurRecipe {
    my $self        = shift;
    my $duration    = shift;

	my %resolve = (
		Weekly		=> 'weekly',
		BiWeekly	=> 'biweekly',
		FourWeekly	=> 'fourweekly',
		Monthly		=> 'monthly',
		Quarterly	=> 'quarterly',
		HalfYearly	=> 'halfyearly',
		Yearly		=> 'yearly',
		);
	
    # TODO: Throw exception
	return $resolve{ $duration };
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
                "Status: "      . $transactionResult->{ Status }
                ." Message: "   . $transactionResult->{ ErrorMessage } 
                ." Category: "  . $transactionResult->{ ErrorCategory } 
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
       
            return ( $isSuccess, "Status: $status Message: $errorMessage Category: $errorCategory" );
		}
	} else {
		# Connection Error
        $session->errorHandler->info("Connection error");

        return ( 0, undef, 'ConnectionError', $response->status_line );
	}
}

#-------------------------------------------------------------------
sub checkRecurringTransaction {
    my $self            = shift;
    my $xid             = shift;
    my $expectedAmount  = shift;
    my $session         = $self->session;

    my $xmlStructure = {
        GatewayInterface => {
            VendorIdentification    => {
                VendorId        => $self->get('vendorId'),
                VendorPassword  => $self->get('password'),
                HomePage        => ,
            },
            RecurDetails            => {
                OperiationXID   => $xid,
            },
        }
    };

    my $xml = 
        '<?xml version="1.0" standalone="yes"?>'
        . XMLout( $xmlStructure,
            NoAttr      => 1,
            KeepRoot    => 1,
            KeyAttr     => [],
        );

    my $response = $self->doXmlRequest( $xml, 1 );

    if ($response->is_success) {
        $session->errorHandler->info("Check recurring postback response: [".$response->content."]"); 
		# We got some XML back from iTransact, now parse it.
        my $transactionResult = XMLin( $response->content || '<empty></empty>');

        unless (defined $transactionResult->{ RecurDetailsResponse }) {
            # Something went wrong.
            $session->errorHandler->info("Check recurring postback failed!");

            return 0;
		} else {
            $session->errorHandler->info("Check recurring postback! Response: [".$response->content."]");
            
            my $data    = $transactionResult->{ RecurDetailsResponse };

            my $status  = $data->{ Status       };
            my $amount  = $data->{ RecurDetails }->{ RecurTotal };

            $session->errorHandler->info("Check recurring postback! Status: $status");
            if ( $amount != $expectedAmount ) {
                $session->errorHandler->info(
                    "Check recurring postback, received amount: $amount not equal to expected amount: $expectedAmount"
                );

                return 0;
            }
    
            return 1;
		}
	} else {
		# Connection Error
        $session->errorHandler->info("Connection error");

        return 0;
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
           label        => $i18n->get('vendorId'),
           hoverHelp    => $i18n->get('vendorId help'),
        },
        password        => {
            fieldType   => 'password',
            label       => $i18n->get('password'),
            hoverHelp   => $i18n->get('password help'),
        },
        useCVV2         => {
            fieldType   => 'yesNo',
            label       => $i18n->get('use cvv2'),
            hoverHelp   => $i18n->get('use cvv2 help'),
        },
        emailMessage    => {
            fieldType   => 'textarea',
            label       => $i18n->get('emailMessage'),
            hoverHelp   => $i18n->get('emailMessage help'),
        },
        # readonly stuff from old plugin here?
    );
 
    push @{ $definition }, {
        name        => $i18n->get('Itransact'),
        properties  => \%fields,
    };

    return $class->SUPER::definition($session, $definition);
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
sub getButton {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'PayDriver');

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $i18n->get('credit card') })
        . WebGUI::Form::formFooter($session);

    return $payForm;
}

#-------------------------------------------------------------------

=head2 handlesRecurring

Tells the commerce system that this payment plugin can handle recurring payments.

=cut

sub handlesRecurring {
    return 1;
}

#-------------------------------------------------------------------
sub processCredentials {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
	my $i18n    = WebGUI::International->new($session,'PayDriver_ITransact');
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

    # Send the xml to ITransact
    my $response = $self->doXmlRequest( $xml );

    # Process response
	if ($response->is_success) {
		# We got some XML back from iTransact, now parse it.
        my $transactionResult = XMLin( $response->content,  SuppressEmpty => '' );

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
       
            my $message = ($errorCategory) ? " $errorMessage Category: $errorCategory" : $errorMessage;

            return ( $isSuccess, $gatewayCode, $status, $message );
		}
	} else {
		# Connection Error
        $session->errorHandler->info("Connection error");

        return ( 0, undef, 'ConnectionError', $response->status_line );
	}
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Generates an edit form.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, 'PayDriver_ITransact');

    return $session->privilege->insufficient() unless $admin->canManage;

    my $form = $self->getEditForm;
    $form->submit;

    my $terminal = WebGUI::HTMLForm->new($session, action=>"https://secure.paymentclearing.com/cgi-bin/rc/sess.cgi", extras=>'target="_blank"');
    $terminal->hidden(name=>"ret_addr", value=>"/cgi-bin/rc/sure/sure.cgi?sure_template_code=session_check&sure_use_session_mid=1");
    $terminal->hidden(name=>"override", value=>1);
    $terminal->hidden(name=>"cookie_precheck", value=>0);
    $terminal->hidden(name=>"mid", value=>$self->get('vendorId'));
    $terminal->hidden(name=>"pwd", value=>$self->get('password'));
    $terminal->submit(value=>$i18n->get('show terminal'));
    
    my $output = '<br />';
    if ($self->get('vendorId')) {
        $output .= $terminal->print.'<br />';
    }
    $output .= $i18n->get('extra info').'<br />'
            .'<b>https://'.$session->config->get("sitename")->[0]
            .'/?shop=pay;method=do;do=processRecurringTransactionPostback;paymentGatewayId='.$self->getId.'</b>';

    return $admin->getAdminConsole->render($form->print.$output, $i18n->get('payment methods','PayDriver'));
}

#-------------------------------------------------------------------
sub www_getCredentials {
    my $self        = shift;
    my $errors      = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $i18n        = WebGUI::International->new($self->session, 'PayDriver_ITransact');
	my $u           = WebGUI::User->new($self->session,$self->session->user->userId);

    # Process address from address book if passed
    my $addressId   = $session->form->process('addressId');
    my $addressData = {};
    if ( $addressId ) {
        $addressData    = eval{ $self->getAddress( $addressId )->get() } || {};
    }
                   
    my $output;

    # Process form errors
    if ( $errors ) {
    #### TODO: i18n
        $output .= $i18n->get('error occurred message')
            . '<ul><li>' . join( '</li><li>', @{ $errors } ) . '</li></ul>';
    }
    
    $output .= $self->getSelectAddressButton( 'getCredentials' );

	my $f = WebGUI::HTMLForm->new( $session );
    $self->getDoFormTags( 'pay', $f );
    $f->hidden(
        -name       => 'addressId',
        -value      => $addressId,
    ) if $addressId;
   
    # Address data form
	$f->text(
		-name	    => 'firstName',
		-label	    => $i18n->get('firstName'),
		-value	    => $form->process("firstName") || $addressData->{ name } || $u->profileField('firstName'),
	);
	$f->text(
		-name	    => 'lastName',
		-label	    => $i18n->get('lastName'),
		-value	    => $form->process("lastName") || $u->profileField('lastName'),
	);
	$f->text(
		-name	    => 'address',
		-label	    => $i18n->get('address'),
		-value	    => $form->process("address") || $addressData->{ address1 } || $u->profileField('homeAddress'),
	);
	$f->text(
		-name	    => 'city',
		-label	    => $i18n->get('city'),
		-value	    => $form->process("city") || $addressData->{ city } || $u->profileField('homeCity'),
	);
	$f->text(
		-name	    => 'state',
		-label	    => $i18n->get('state'),
		-value	    => $form->process("state") || $addressData->{ state } || $u->profileField('homeState'),
	);
	$f->zipcode(    
		-name	    => 'zipcode',
		-label	    => $i18n->get('zipcode'),
		-value	    => $form->process("zipcode") || $addressData->{ code } || $u->profileField('homeZip'),
	);
	$f->country(    
		-name       => "country",
		-label      => $i18n->get("country"),
		-value      => ($form->process("country",'country') || $addressData->{ country } || $u->profileField("homeCountry") || 'United States'),
	);
    $f->phone(
		-name       => "phone",
		-label      => $i18n->get("phone"),
		-value      => $form->process("phone",'phone') || $addressData->{ phoneNumber } || $u->profileField("homePhone"),
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
    
    $output .= $f->print;
	return $session->style->userStyle( $output );	
}

#-------------------------------------------------------------------
sub www_pay {
    my $self    = shift;
    my $session = $self->session;
    my $address = $self->getAddress( $session->form->process( 'addressId' ) );

    # Check whether the user filled in the checkout form and process those.
    my $credentialsErrors = $self->processCredentials;

    # Go back to checkout form if credentials are not ok
    return $self->www_getCredentials( $credentialsErrors ) if $credentialsErrors;

    # Payment time!
    my $transaction = $self->processTransaction( $address );
	if ($transaction->get('isSuccessful')) {
	    return $transaction->thankYou();
	}

    # Payment has failed...
    return $self->displayPaymentError($transaction);
}

#-------------------------------------------------------------------
sub www_processRecurringTransactionPostback {
	my $self    = shift;
    my $session = $self->session;
	$session->http->setMimeType('text/plain');
    my $form    = $session->form;

    # Get posted data of interest
    my $originatingXid  = $form->process( 'orig_xid'        );
    my $status          = $form->process( 'status'          );
    my $xid             = $form->process( 'xid'             );
    my $errorMessage    = $form->process( 'error_message'   );

    # Fetch the original transaction
    my $baseTransaction = eval{WebGUI::Shop::Transaction->newByGatewayId( $session, $originatingXid, $self->getId )};

    #---- Check the validity of the request -------
    # First check whether the original transaction actualy exists
    if (WebGUI::Error->caught || !(defined $baseTransaction) ) {   
        $session->errorHandler->warn("Check recurring postback: No base transction for XID: [$originatingXid]");
	$session->http->setStatus('500', "No base transction for XID: [$originatingXid]");
        return "Check recurring postback. No base transction for XID: [$originatingXid]";
    }

    # Secondly check if the postback is coming from secure.paymentclearing.com
    # This will most certainly fail on mod_proxied webgui instances
#    unless ( $ENV{ HTTP_HOST } eq 'secure.paymentclearing.com') {
#        $session->errorHandler->info('ITransact Recurring Payment Postback is coming from host: ['.$ENV{ HTTP_HOST }.']');
#        return;
#    }

    # Third, check if the new xid exists and if the amount is correct.
#    my $expectedAmount = sprintf("%.2f", 
#        $baseTransaction->get('amount') + $baseTransaction->get('taxes') + $baseTransaction->get('shippingPrice') );

#    unless ( $self->checkRecurringTransaction( $xid, $expectedAmount ) ) {
#        $session->errorHandler->warn('Check recurring postback: transaction check failed.');
 #       return 'Check recurring postback: transaction check failed.';
#    }
    #---- Passed all test, continue ---------------
 
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

    return "OK";
}

1;

