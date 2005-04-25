package WebGUI::Commerce::Shipping;

use strict;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use WebGUI::Commerce::ShoppingCart;


sub calc {
	return WebGUI::ErrorHanlder::fatal('The calc method must be overriden.');
};

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

	$f = WebGUI::HTMLForm->new;
	$f->yesNo(
		-name	=> $self->prepend('enabled'),
		-value	=> $self->enabled,
		-label	=> WebGUI::International::get('enable', 'Commerce'),
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

sub getOptions {
	return {};
}

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

Returns a reference to an array of all enabled instanciated payment plugins.

=cut

sub getEnabledPlugins {
	my (@enabledPlugins, $plugin, @plugins);
	@enabledPlugins = WebGUI::SQL->buildArray("select namespace from commerceSettings where type='Shipping' and fieldName='enabled' and fieldValue='1'");

	foreach (@enabledPlugins) {
		$plugin = WebGUI::Commerce::Shipping->load($_);
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
	my ($class, $namespace, $properties, $shoppingCart);
	$class = shift;
	$namespace = shift;

	WebGUI::ErrorHandler::fatal('No namespace passed to init.') unless ($namespace);
	
	$properties = WebGUI::SQL->buildHashRef("select fieldName, fieldValue from commerceSettings where namespace=".quote($namespace)." and type='Shipping'");
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;

	bless {_properties=>$properties, 
		_shippingParameters => {}, 
		_shoppingCart => $shoppingCart, 
		_namespace=>$namespace, 
		_enabled=>$properties->{enabled},
		_shippingItems => []}, $class;
}

#-------------------------------------------------------------------

sub getShoppingCart {
	return $_[0]->{_shoppingCart};
};

#-------------------------------------------------------------------

=head2 load ( namespace )

A convienient method to load a plugin. It handles all error checking and stuff for you.
This is a SUPER class method only and shoud NOT be overridden.

=head3 namespace

The namespace of the plugin.

=cut

sub load {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
	$namespace = shift;

	WebGUI::ErrorHandler::fatal('No namespace passed to load.') unless ($namespace);
	
    	$cmd = "WebGUI::Commerce::Shipping::$namespace";
	$load = "use $cmd";
	eval($load);
	WebGUI::ErrorHandler::warn("Shipping plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd."->init");
	WebGUI::ErrorHandler::warn("Couldn't instantiate shipping plugin: $cmd.".$@) if($@);
	return $plugin;
}

#-------------------------------------------------------------------

=head2 name

Returns the (display) name of the plugin. You must override this method.

=cut

sub name {
	return WebGUI::ErrorHandler::fatal("You must override the name method in the shipping plugin.");
}

#-------------------------------------------------------------------

=head2 namespace

Returns the namespace of the plugin.

=cut

sub namespace {
	return $_[0]->{_namespace};
}

sub optionsOk {
	return 1;
}

#-------------------------------------------------------------------

=head2 prepend ( fieldName )

A utility method that prepends fieldName with a string that's used to save configuration data to
the database. Use it on all fields in the configurationForm method.

For instance:

	$f = WebGUI::HTMLForm->new;
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

sub processOptionsForm {
}

sub setOptions {
}

sub setShippingItems {
	my ($self, $items);
	$self = shift;
	$items = shift;

	$self->{_shippingItems} = $items;
}

sub supportsTracking {
	return 0;
}

sub trackingInfo {
	return {};
}

sub trackingNumber {
	return undef;
}

sub optionsOk {
	return 1;	
};

1;

