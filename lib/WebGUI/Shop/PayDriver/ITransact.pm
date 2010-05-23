package WebGUI::Shop::PayDriver::ITransact;

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
use XML::Simple;
use Data::Dumper;
use Tie::IxHash;
use LWP::UserAgent;
use HTTP::Request;

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
                sprintf("%.2f",$item->get('price') + $transaction->get('taxes') + $transaction->get('shippingPrice'));
            $recurringData->{ RecurDesc     } = $item->get('configuredTitle');
        }
#       else {
            push @{ $orderItems->{ Item } }, {
                Description     => $item->get('configuredTitle'),
                Cost            => sprintf("%.2f", $item->get('price')),
                Qty             => $item->get('quantity'),
            }
#        }
    }

	# taxes, shipping, etc
	my $i18n = WebGUI::International->new($session, "Shop");
	if ( $transaction->get('taxes') > 0 ) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('taxes'),
			Cost			=> sprintf("%.2f",$transaction->get('taxes')),
			Qty				=> 1,
			};
	}
	if ($transaction->get('shippingPrice') > 0) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('shipping'),
			Cost			=> sprintf("%.2f",$transaction->get('shippingPrice')),
			Qty				=> 1,
			};
	}
	if ($transaction->get('shopCreditDeduction') < 0) {
		push @{ $orderItems->{ Item } }, {
			Description		=> $i18n->get('in shop credit'),
			Cost			=> sprintf("%.2f",$transaction->get('shopCreditDeduction')),
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
    $session->errorHandler->debug("XML Request: $xml");

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

=head2 checkRecurringTransaction ( $xid, $expectedAmount )

Make an XML request back to ITransact to verify a recurring transaction.  Returns 0 if
the transaction cannot be verified or is incorrect.  Otherwise, it returns 1.

NOTE: THIS CODE IS NOT CALLED ANYWHERE.

=head3 $xid

Transaction ID, from ITransact.

=head3 $expectedAmount

The amount we think should be charged in this transaction.

=cut

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
                OperiationXID   => $xid, ##BUGGO, typo?
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
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
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
        credentialsTemplateId  => {
            fieldType    => 'template',
            label        => $i18n->get('credentials template'),
            hoverHelp    => $i18n->get('credentials template help'),
            namespace    => 'Shop/Credentials',
            defaultValue => 'itransact_credentials1',	
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

=head2 doXmlRequest ( xml, [ isGatewayInterface ] )

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
	$request->content_type( 'text/xml' );
	$request->add_content_utf8( $xml );

    # Do the request
    my $response = $userAgent->request($request);
                            
    return $response;
}

#-------------------------------------------------------------------

=head2 getButton 

Return a form to select this payment driver and to accept credentials from those
who wish to use it.

=cut

sub getButton {
    my $self    = shift;
    my $session = $self->session;

    my $payForm = WebGUI::Form::formHeader($session)
        . $self->getDoFormTags('getCredentials')
        . WebGUI::Form::submit($session, {value => $self->get('label') })
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

=head2 processCredentials 

Process the form where credentials (name, address, phone number and credit card information)
are entered.

=cut

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

	return \@error if scalar @error;
    # Everything ok process the actual data
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

#-------------------------------------------------------------------

=head2 getBillingAddress ( $addressId )

The billing address is not handled by WebGUI::Shop::Address, it comes from
www_getCredentials.  However, WebGUI::Shop::Transaction requires an
WebGUI::Shop::Address object.  The billing address is seeded with information
from the shipping address.  If this address info is different, then create
a new address to hand to Transaction.

=head3 $addressId

The id of a WebGUI::Shop::Address.  If not present, then use the shipping
address instead.

=cut

sub getBillingAddress {
    my ($self, $addressId) = @_;

    my $address     = $addressId
                    ? $self->getAddress( $addressId )
                    : $self->getCart->getShippingAddress
                    ;
    
    ##If the user made any changes to the default address, create a new billing address
    ##and use it instead
    if( $address->get('firstName'   ) ne $self->{_billingAddress}->{ 'firstName'    }
     || $address->get('lastName'    ) ne $self->{_billingAddress}->{ 'lastName'     }
     || $address->get('address1'    ) ne $self->{_billingAddress}->{ 'address1'     }
     || $address->get('city'        ) ne $self->{_billingAddress}->{ 'city'         }
     || $address->get('state'       ) ne $self->{_billingAddress}->{ 'state'        }
     || $address->get('code'        ) ne $self->{_billingAddress}->{ 'code'         }
     || $address->get('country'     ) ne $self->{_billingAddress}->{ 'country'      }
     || $address->get('phoneNumber' ) ne $self->{_billingAddress}->{ 'phoneNumber'  }
     || $address->get('email'       ) ne $self->{_billingAddress}->{ 'email'        }
    ) {
        my $billingAddress = $self->getCart->getAddressBook->addAddress( $self->{_billingAddress} );
        return $billingAddress;
    }
    return $address;
}

#-------------------------------------------------------------------

=head2 processPayment ($transaction)

Contact ITransact and submit the payment data to them for processing.

=head3 $transaction

A WebGUI::Shop::Transaction object to pull information from.

=cut

sub processPayment {
    my $self        = shift;
    my $transaction = shift;
    my $session     = $self->session;

    # Get the payment definition XML
    my $xml = $self->_generatePaymentRequestXML( $transaction );

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

=head2 www_getCredentials ( $errors )

Build a templated form for asking the user for their credentials.

=head3 $errors

An array reference of errors to show the user.

=cut

sub www_getCredentials {
    my $self        = shift;
    my $errors      = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $i18n        = WebGUI::International->new($self->session, 'PayDriver_ITransact');
	my $u           = WebGUI::User->new($self->session,$self->session->user->userId);

    # Process address from address book if passed
    my $addressId   = $session->form->process( 'addressId' );
    my $addressData;
    if ( $addressId ) {
        $addressData    = eval{ $self->getAddress( $addressId )->get() } || {};
    }
    else { 
        $addressData    = $self->getCart->getShippingAddress->get;
    }
                   
    my $var = {};

    # Process form errors
    $var->{errors} = [];
    if ($errors) {
        $var->{error_message} = $i18n->get('error occurred message');
        foreach my $error (@{ $errors} ) {
            push @{ $var->{errors} }, { error => $error };
        }
    }
    
    $var->{getSelectAddressButton} = $self->getSelectAddressButton( 'getCredentials' );

    $var->{formHeader} = WebGUI::Form::formHeader($session)
                       . $self->getDoFormTags('pay');

    if ($var->{formHeader}) {
        $var->{formHeader} .= WebGUI::Form::hidden($session, {name => 'addressId', value => $addressId});
    }

    $var->{formFooter} = WebGUI::Form::formFooter();
   
    # Address data form
    $var->{firstNameField} = WebGUI::Form::text($session, {
        name  => 'firstName',
        value => $form->process("firstName") || $addressData->{ "firstName" } || $u->profileField('firstName'),
    });
    $var->{lastNameField} = WebGUI::Form::text($session, {
        name  => 'lastName',
        value => $form->process("lastName") || $addressData->{ "lastName" } || $u->profileField('lastName'),
    });
    $var->{addressField} = WebGUI::Form::text($session, {
        name  => 'address',
        value => $form->process("address") || $addressData->{ address1 } || $u->profileField('homeAddress'),
    });
    $var->{cityField} = WebGUI::Form::text($session, {
        name  => 'city',
        value => $form->process("city") || $addressData->{ city } || $u->profileField('homeCity'),
    });
    $var->{stateField} = WebGUI::Form::text($session, {
        name  => 'state',
        value => $form->process("state") || $addressData->{ state } || $u->profileField('homeState'),
    });
    $var->{codeField} = WebGUI::Form::zipcode($session, {
        name  => 'zipcode',
        value => $form->process("zipcode") || $addressData->{ code } || $u->profileField('homeZip'),
    });
    $var->{countryField} = WebGUI::Form::country($session, {
        name  => 'country',
        value => ($form->process("country",'country', '') || $addressData->{ country } || $u->profileField("homeCountry") || 'United States of A'),
    });
    $var->{phoneField} = WebGUI::Form::phone($session, {
        name  => 'phone',
        value => $form->process("phone",'phone') || $addressData->{ phoneNumber } || $u->profileField("homePhone"),
    });
    $var->{emailField} = WebGUI::Form::email($session, {
        name  => 'email',
        value => $form->process('email', 'email') || $addressData->{ email } || $u->profileField('email'),
    });

    # Credit card information
    $var->{cardNumberField} = WebGUI::Form::text($session, {
        name  => 'cardNumber',
        value => $self->session->form->process("cardNumber"),
    });
    $var->{monthYearField} = WebGUI::Form::readOnly($session, {
        value => _monthYear( $session ),
    });
    $var->{cvv2Field} = WebGUI::Form::integer($session, {
        name  => 'cvv2',
        value => $self->session->form->process("cvv2"),
    }) if $self->get('useCVV2');

    $var->{checkoutButton} = WebGUI::Form::submit($session, {
        value => $i18n->get('checkout button', 'Shop'),
        extras => 'onclick="this.disabled=true;this.form.submit(); return false;"',
    });

    my $template = eval { WebGUI::Asset::Template->newById($session, $self->get("credentialsTemplateId")); };
    my $output;
    if (! Exception::Class->caught()) {
        $template->prepare;
        $output = $template->process($var);
    }
    else {
        $output = $i18n->get('template gone');
    }

    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_pay 

Makes sure that the user has all the requirements for checking out, including
getting credentials, it processes the transaction and then displays a thank
you screen.

=cut

sub www_pay {
    my $self        = shift;
    my $session     = $self->session;
    # Check whether the user filled in the checkout form and process those.
    my $credentialsErrors = $self->processCredentials;

    # Go back to checkout form if credentials are not ok
    return $self->www_getCredentials( $credentialsErrors ) if $credentialsErrors;

    my $addressId      = $session->form->process( 'addressId' );
    my $billingAddress = $self->getBillingAddress($addressId);

    # Payment time!
    my $transaction = $self->processTransaction( $billingAddress );
    ## The billing address object is temporary, just to send to the transaction.
    ## Delete it if we don't need it.
    if ($billingAddress->getId ne $addressId) {
        $billingAddress->delete;
    }
	if ($transaction->get('isSuccessful')) {
	    return $transaction->thankYou();
	}

    # Payment has failed...
    return $self->displayPaymentError($transaction);
}

#-------------------------------------------------------------------

=head2 www_processRecurringTransactionPostback 

Callback method for ITransact to dial up WebGUI and post the results of a
recurring transaction.  This allows WebGUI to renew group memberships or
do whatever other activity a Sku purchase would allow.

=cut

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

    #make sure the same user is used in this transaction as the last {mostly needed for reoccurring transactions
    $self->session->user({userId=>$baseTransaction->get('userId')});
 
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

