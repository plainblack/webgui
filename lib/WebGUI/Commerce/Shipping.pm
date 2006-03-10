package WebGUI::Commerce::Shipping;

use strict;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use WebGUI::Commerce::ShoppingCart;

#-------------------------------------------------------------------

=head2 calc

Returns the calculated shipping cost. Your plugin must override this method.

=cut

sub calc {
	return WebGUI::ErrorHanlder::fatal('The calc method must be overriden.');
};

#-------------------------------------------------------------------

=head2 description

Returns a description of the shipping configuration. Defaults to the name of your plugin
if you do not overload this method.

=cut

sub description {
	return $_[0]->name;
}

#-------------------------------------------------------------------

=head2 configurationForm

This generates the configuration form that's displayed in the admin console. You must 
extend this method to include parameters specific to this payment module. To do so return
the SUPER::configurationForm method with a printRowsOnly'ed WebGUI::HTMLForm as the argument.

Also be sure to prepend all formfield names with the prepend method. See propend for more info.

=cut

sub configurationForm {
	my ($self, $form, $f);
	$self = shift;
	$form = shift;

	$f = WebGUI::HTMLForm->new($self->session);
	my $i18n = WebGUI::International->new($self->session, 'Commerce');
	$f->yesNo(
		-name	=> $self->prepend('enabled'),
		-value	=> $self->enabled,
		-label	=> $i18n->get('enable'),
		);
	$f->raw($form);

	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 enabled

Returns a boolean indicating whether the plugin is enabled or not.

=cut

sub enabled {
	return $_[0]->{_enabled};
}

#-------------------------------------------------------------------

=head2 get ( property )

Returns property of the plugin.

=head3 property

The name of the property you want.

=cut

sub get {
	return $_[0]->{_properties}{$_[1]};
}

#-------------------------------------------------------------------

=head2 getOptions

Returns a hash containing the parameters of a user configurable shipping method. If
your shipping plugin has an options form you should overload this method.

=cut

sub getOptions {
	return {};
}

#-------------------------------------------------------------------

=head2 getShippingItems

Returns an arrayref containing the items, marked for shipping. If no items are set
using setShippingOptions it this method will default to the shopping cart of the user.

=cut

sub getShippingItems {
	my ($normal, $recurring, @allItems, @items, $self);
	$self = shift;
	
	@allItems = @{$self->{_shippingItems}};
	unless (@allItems) {
		($normal, $recurring) = $self->getShoppingCart->getItems;
		@allItems = (@$normal, @$recurring);
	}
	foreach (@allItems) {
		push(@items, $_) if $_->{item}->needsShipping;
	}

	return [ @items ];
}

#-------------------------------------------------------------------

=head2 getEnabledPlugins

Returns a reference to an array of all enabled instantiated payment plugins.

=cut

sub getEnabledPlugins {
	my ($session) = @_;
	my (@enabledPlugins, $plugin, @plugins);
	@enabledPlugins = $session->db->buildArray("select namespace from commerceSettings where type='Shipping' and fieldName='enabled' and fieldValue='1'");

	foreach (@enabledPlugins) {
		$plugin = WebGUI::Commerce::Shipping->load($session, $_);
		push(@plugins, $plugin) if ($plugin);
	}

	return \@plugins;
}
	
#-------------------------------------------------------------------

=head2 init ( namespace )

Constructor for the plugin. You should extend this method.

=head3 namespace

The namespace of the plugin.

=cut

sub init {
	my ($class, $session, $namespace, $properties, $shoppingCart);
	$class = shift;
	$session = shift;
	$namespace = shift;

	$session->errorHandler->fatal('No namespace passed to init.') unless ($namespace);
	
	$properties = $session->db->buildHashRef("select fieldName, fieldValue from commerceSettings where namespace=".$session->db->quote($namespace)." and type='Shipping'");
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($session);

	bless {_properties=>$properties, 
		_shippingParameters => {}, 
		_shoppingCart => $shoppingCart, 
		_namespace=>$namespace, 
		_session=>$session, 
		_enabled=>$properties->{enabled},
		_shippingItems => []}, $class;
}

#-------------------------------------------------------------------

=head2 getShoppingCart

Returns a WebGUI::Commerce::ShoppingCart object of the current user.

=cut

sub getShoppingCart {
	return $_[0]->{_shoppingCart};
};

#-------------------------------------------------------------------

=head2 load ( namespace )

A convienient method to load a plugin. It handles all error checking and stuff for you.
This is a SUPER class method only and should NOT be overridden.

=head3 namespace

The namespace of the plugin.

=cut

sub load {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
    	my $session = shift;
	$namespace = shift;

	$session->errorHandler->fatal('No namespace passed to load.') unless ($namespace);
	
    	$cmd = "WebGUI::Commerce::Shipping::$namespace";
	$load = "use $cmd";
	eval($load);
	$session->errorHandler->warn("Shipping plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd.'->init($session)');
	$session->errorHandler->warn("Couldn't instantiate shipping plugin: $cmd.".$@) if($@);
	return $plugin;
}

#-------------------------------------------------------------------

=head2 name

Returns the (display) name of the plugin. You must override this method.

=cut

sub name {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the name method in the shipping plugin.");
}

#-------------------------------------------------------------------

=head2 namespace

Returns the namespace of the plugin.

=cut

sub namespace {
	return $_[0]->{_namespace};
}

#-------------------------------------------------------------------

=head2 optionsOk

Indicates whether the options loaded into the plugin (by using either setOptions or processOptionsForm)
are correct. If your plugin is able of being configured by an options form you must overload this method.
Defaults to true.

=cut

sub optionsOk {
	return 1;
}

#-------------------------------------------------------------------

=head2 prepend ( fieldName )

A utility method that prepends fieldName with a string that's used to save configuration data to
the database. Use it on all fields in the configurationForm method.

For instance:

	$f = WebGUI::HTMLForm->new($self->session);
	$f->text(
		-name	=> $self->prepend('MyField');
		-label	=> 'MyField'
	);

=head3 fieldName

The string to prepend.

=cut

sub prepend {
	my ($self, $name);
	$self = shift;
	$name = shift;

	return "~Shipping~".$self->namespace."~".$name;
}

#-------------------------------------------------------------------

=head2 processOptionsForm

Processes the submitted form variables from the optionsForm and stores them
into the plugin. You only need to overload this method if your plugin is capable
of using user configurable options.

=cut

sub processOptionsForm {
}

#-------------------------------------------------------------------

=head2 session

Returns the cached, local session variable.

=cut

sub session {
	my ($self) = @_;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setOptions ( options )

Stores the supplied option hash into the plugin object.

=head3 options

Hashref containing the options.

=cut

sub setOptions {
}

#-------------------------------------------------------------------

=head2 setShippingItems ( items )

Sets the items the shipping is to be calculated for.

=head3 items

Arrayref containing the items.

=cut

sub setShippingItems {
	my ($self, $items);
	$self = shift;
	$items = shift;

	$self->{_shippingItems} = $items;
}

#-------------------------------------------------------------------

=head2 supportsTracking

Returns a boolean indicating whether this plugin supports tracking of the shipment.
Overload this method if your plugin does. Defaults to false.

=cut

sub supportsTracking {
	return 0;
}

#-------------------------------------------------------------------

=head2 trackingInfo

Returns a message containing information about the shipment tracking (ie. where the 
package is or  something like that). If your plugin support these tracking, you probably
want to overload this method. Defaults to "".

=cut

sub trackingInfo {
	return "";
}

#-------------------------------------------------------------------

=head2 trackingNumber

Returns the tracking ID supplied by the shipment company. If your plugin supports tracking
you'll have to overload this method. Defaults to undef.

=cut

sub trackingNumber {
	return undef;
}

#-------------------------------------------------------------------

=head2 trackingUrl

Returns the URL where the user can go to either fill in the tracking number or view the tracking 
info of his package. Overload this method if your plugin supports tracking. Defaults to undef.

=cut

sub  trackingUrl {
	return undef;
}

#-------------------------------------------------------------------

=head2 optionsOk

This method returns a boolean indicating wheter the supplied options (loaded into the plugin 
by either setOptions or processOptionsForm) are valid. Overload if your plugin support configuration 
options. Defaults to true.

=cut

sub optionsOk {
	return 1;	
};

1;

