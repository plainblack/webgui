package WebGUI::i18n::English::PayDriver_ITransact;
use strict;

our $I18N = {
    'error occurred message' => {
        message => q|The following errors occurred:|,
        lastUpdated => 0,
        context => q|The message that tell the user that there were some errors in their submitted credentials.|,
    },
    'ITransact' => {
        message => q|ITransact|,
        lastUpdated => 0,
        context => q|The name of the ITransact plugin|,
    },
	'label' => {
        message => q|Credit Card|,
        lastUpdated => 0,
        context => q|Default ITransact payment gateway label|
    },
    'phone' => {
        message => q|Telephone Number|,
        lastUpdated => 0,
        context => q|Form label in the checkout form of the iTransact module.|
    },
    'country' => {
        message => q|Country|,
        lastUpdated => 0,
        context => q|Form label in the checkout form of the iTransact module.|
    },
	'firstName' => {
		message => q|First name|,
		lastUpdated => 0,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'lastName' => {
		message => q|Last name|,
		lastUpdated => 0,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'address' => {
		message => q|Address|,
		lastUpdated => 1101772170,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'city' => {
		message => q|City|,
		lastUpdated => 1101772171,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'state' => {
		message => q|State|,
		lastUpdated => 1101772173,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'zipcode' => {
		message => q|Zipcode|,
		lastUpdated => 1101772174,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'email' => {
		message => q|Email|,
		lastUpdated => 1101772176,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'cardNumber' => {
		message => q|Credit card number|,
		lastUpdated => 1101772177,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'expiration date' => {
		message => q|Expiration date|,
		lastUpdated => 1101772180,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	'cvv2' => {
		message => q|Verification number (ie. CVV2)|,
		lastUpdated => 1101772182,
		context => q|Form label in the checkout form of the iTransact module.|
	},
	
	'vendorId' => {
		message => q|Username (Vendor ID)|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'vendorId help' => {
		message => q|Fill in the  username or vendor id you got from ITransact.|,
		lastUpdated => 0,
		context => q|Hover help for vendor id in the configuration form of the iTransact module.|
	},

	'use cvv2' => {
		message => q|Use CVV2|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'use cvv2 help' => {
		message => q|Set this option to yes if you want to use CVV2.|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},

	'emailMessage' => {
		message => q|Email message|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
   	'emailMessage help' => {
		message => q|The message that will be appended to the email user will receive from ITransact.|,
		lastUpdated => 0,
		context => q|Hover help for the email message field in the configuration form of the iTransact module.|
	},
 

	'credentials template' => {
		message => q|Credentials Template|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
   	'credentials template help' => {
		message => q|Pick a template to display the form where the user will enter in their billing information and credit card information.|,
		lastUpdated => 0,
		context => q|Hover help for the credentials template field in the configuration form of the iTransact module.|
	},

	'edit credentials template' => {
		message => q|Edit Credentials Template|,
		lastUpdated => 0,
		context => q|Title of the help page.|
	},
   	'edit credentials template help' => {
		message => q|This template is used to display a form to the user where they can enter in contact and credit card billing information.|,
		lastUpdated => 0,
		context => q|Title of the help page.|
	},

   	'errors help' => {
		message => q|A template loop containing a list of errors from processing the form.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'error help' => {
		message => q|One error from the errors loop.  It will have minimal markup.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'checkoutButton help' => {
		message => q|A button with an internationalized label to submit the form and continue the checkout process.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'addressField help' => {
		message => q|A single text field for the user to enter in their street address.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'emailField help' => {
		message => q|A single text field for the user to enter in their email address.|,
		lastUpdated => 1231192368,
		context => q|Template variable help.|
	},

   	'cardNumberField help' => {
		message => q|A single text field for the user to enter in their credit card number.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'monthYearField help' => {
		message => q|A combination form field for the user to enter in the month and year of the expiration date for the credit card.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

   	'cvv2Field help' => {
		message => q|A single text field for the user to enter in their credit card verification number.  If the PayDriver is not configured to use CVV2, then this field will be empty.|,
		lastUpdated => 0,
		context => q|Template variable help.|
	},

	'password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'password help' => {
		message => q|The password for your ITransact account.|,
		lastUpdated => 0,
		context => q|Hover help for the password field in the configuration form of the iTransact module.|
	},
 
	'password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'password help' => {
		message => q|The password for your ITransact account.|,
		lastUpdated => 0,
		context => q|Hover help for the password field in the configuration form of the iTransact module.|
	},

	'credentials template' => {
		message => q|Credentials Template|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
   	'credentials template help' => {
		message => q|Pick a template to display the form where the user will enter in their billing information and credit card information.|,
		lastUpdated => 0,
		context => q|Hover help for the credentials template field in the configuration form of the iTransact module.|
	},
 
	'password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|Form label in the configuration form of the iTransact module.|
	},
	'password help' => {
		message => q|The password for your ITransact account.|,
		lastUpdated => 0,
		context => q|Hover help for the password field in the configuration form of the iTransact module.|
	},

	'module name' => {
		message => q|iTransact|,
		lastUpdated => 0,
		context => q|The displayed name of the payment module.|
	},

	'invalid firstName' => {
		message => q|You have to enter a valid first name.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid first name has been entered.|
	},
	'invalid lastName' => {
		message => q|You have to enter a valid last name.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid last name has been entered.|
	},
	'invalid address' => {
		message => q|You have to enter a valid address.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid street has been entered.|
	},
	'invalid city' => {
		message => q|You have to enter a valid city.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid city has been entered.|
	},
	'invalid state' => {
		message => q|You have to enter a state or province.  If your address does not have one, please enter in the city again.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid city has been entered.|
	},
	'invalid zip' => {
		message => q|You have to enter a valid zipcode.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid zipcode has been entered.|
	},
	'invalid email' => {
		message => q|You have to enter a valid email address.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid email address has been entered.|
	},
	'invalid card number' => {
		message => q|You have to enter a valid credit card number.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid credit card number has been entered.|
	},
	'invalid cvv2' => {
		message => q|You have to enter a valid card security code (ie. cvv2).|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid card security code has been entered.|
	},
	'invalid expiration date' => {
		message => q|You have to enter a valid expiration date.|,
		lastUpdated => 0,
		context => q|An error indicating that an invalid expiration date has been entered.|
	},
	'Itransact' => {
		message => q|Credit Card (ITransact)|,
		lastUpdated => 1215880143,
		context => q|Name of the gateway from the definition|
	},
	'expired expiration date' => {
		message => q|The expiration date on your card has already passed.|,
		lastUpdated => 0,
		context => q|An error indicating that an an expired card was used.|
	},
	'no description' => {
		message => q|No description|,
		lastUpdated => 0,
		context => q|The default description of purchase of users.|
	},
	'template gone' => {
		message => q|The template for entering in credentials has been deleted.  Please notify the site administrator.|,
		lastUpdated => 0,
		context => q|Error message when the getCredentials template cannot be accessed.|
	},
	'show terminal' => {
		message => q|Click here to use your virtual terminal.|,
		lastUpdated => 0,
		context => q|The label of the link that points to the virtual terminal login.|
	},
	'extra info' => {
		message => q|Setting up your ecommerce site is as easy as these few steps:
<p>
<b>Step 1: Get A Merchant Account</b><br />
<a target="_blank" href="http://www.itransact.com/info/merchacct.html">Register for a merchant account now to get started processing online transactions.</a>
</p>

<p>
<b>Step 2: Set Up Your Merchant Account Info</b><br />
See the information toward the bottom of this page to set up your merchant account info.
</p>

<p>
<b>Step 3: Get An SSL Certificate</b><br />
<a target="_blank" href="http://www.completessl.com/plainblack.php">Get an SSL Certificate from CompleteSSL.</a>
</p>

<p>
<b>Step 4: Install The Certificate</b><br />
Contact your hosting provider to install your certificate or install it yourself.
</p>


<p>
<b>Step 5: Enable IP Address</b><br />
For added security the system will not allow just anyone to post requests to the merchant account. We have to tell the merchant account what the IP address of our site (or sites) is. To do this go to your virtual terminal and log in. Go to Account Settings &gt; Fraud Control &gt; and click on the "IP Filter Settings" link. There enter the IP address of your server Set the status to Active and set the module to XML, then hit go. Contact your system administrator for your server IP address. You'll also need to <a href="http://support.paymentclearing.com/">submit a support ticket</a> to let iTransact know that you wish to enable the XML API.
</p>

<p>
<b>Step 6: Enable The Commerce System</b><br />
Set the enabled field to "Yes" in your WebGUI commerce settings.
</p>

<p>
<b>Step 7: Optionally Accept American Express, Discover, and Diners Club</b><br />
By default you'll only be able to accept MasterCard and Visa. If you want to accept others you'll need to follow these steps:
<ol>
	<li>Call the credit card vendor to apply:
		<ul>
		<li>American Express: (800) 528-5200</li>
		<li>Discover: (800) 347-2000</li>
		<li>Diners Club: (800) 525-7376</li> 
		</ul>
	</li>
	<li><a href="http://support.paymentclearing.com/">Submit the account numbers that you get from those companies in a support ticket.</a> to get them registered with your merchant account.</li>
	<li>Go to your virtual terminal and enable these cards under your Account settings.</li>
</ol>
</p>

<hr />

This plugin expects that you set up the following recipe's in your iTransact account. Be very careful to enter the recipe names exactly as given below.<br />
<table border="0" cellpadding="3" cellspacing="0">
  <tr>
    <td align="right"><b>weekly</b></td>
    <td> -> </td>
    <td align="left">7 days</td>
  </tr>
  <tr>
    <td align="right"><b>biweekly</b></td>
    <td> -> </td>
    <td align="left">14 days</td>
  </tr>
   <tr>
    <td align="right"><b>fourweekly</b></td>
    <td> -> </td>
    <td align="left">28 days</td>
  </tr>
  <tr>
    <td align="right"><b>monthly</b></td>
    <td> -> </td>
    <td align="left">30 days</td>
  </tr>
  <tr>
    <td align="right"><b>quarterly</b></td>
    <td> -> </td>
    <td align="left">91 days</td>
  </tr>
  <tr>
    <td align="right"><b>halfyearly</b></td>
    <td> -> </td>
    <td align="left">182 days</td>
  </tr>
  <tr>
    <td align="right"><b>yearly</b></td>
    <td> -> </td>
    <td align="left">365 days</td>
  </tr>
</table><br />
Please note that some of these recipe's are only roughly correct. They don't 'fit' exactly in a whole year. Below the affected recipe's are given together with their difference on a year's basis. <br />
<ul>
  <li><b>monthly</b> (differs 5 days each year, 6 days each leap year)</li>
  <li><b>quarterly</b> (differs 1 day each year, 2 days each leap year)</li>
  <li><b>halfyearly</b> (differs 1 day each year, 2 days each leap year)</li>
  <li><b>yearly</b> (differs 1 day each leap year)</li>
</ul><br />
Also set the 'RECURRING POST-BACK URL' field in the Account Settings part of the virtual terminal to:|,
		lastUpdated => 1189004971,
		context => q|An informational message that's shown in the configuration form of this plugin.|
	},
};

1;

