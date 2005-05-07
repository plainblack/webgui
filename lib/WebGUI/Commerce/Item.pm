package WebGUI::Commerce::Item;

=head1 NAME

Package WebGUI::Commerce::Item

=head1 DESCRIPTION

This is the SUPER class off all Item plugins. Item plugins are an abstraction layer to connect
arbitrary types of products and other stuff you might want to sell to the commerce system.

The SUPER class new method provides an easy way to load Item plugins: WebGUI::Item->new('1234', 'MyItem') 
is equivalent to WebGUI::Item::MyItem->new('1234'). The SUPER class new has the benefit of added
error checking, so you should use this.


=head1 SYNOPSIS

 use WebGUI::Item;
 $item = WebGUI::Item->new($itemId, $itemType);

 $description = $item->description;
 $duration = $item->duration;
 $item->handler;
 $id = $item->id
 $isRecurring = $item->isRecurring;
 $name = $item->name;
 $price = $item->price;
 $type = $item->type;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 available ( )

Returns a boolean indicating that the item is available or not.

=cut

sub available {
	return 1;
}

#-------------------------------------------------------------------

=head2 description ( )

This returns the description of the item. This must be implemented by an item plugin.

=cut

sub description {
	return WebGUI::ErrorHandler::fatal('The description method of WebGUI::Commerce::Item must be overridden.');
}

#-------------------------------------------------------------------

=head2 duration ( )

This returns the duration of a term when the item is recurring. If your item isn't 
recurring you don't need to override this method. If you do however, you should return 
undef if it's not recurring.

=cut

sub duration {
	return undef;
}

#-------------------------------------------------------------------

=head2 handler ( )

This will execute the handler that's tied to this item. If you don't have a handler for
your item you don't have to override this method or if you do, you can just return undef.

=cut

sub handler {
	return undef;
}

#-------------------------------------------------------------------

=head2 id ( )

This returns the item ID. This must be implemented by an item plugin. This must be implemented 
by an item plugin.

=cut

sub id {
	return WebGUI::ErrorHandler::fatal('The id method of WebGUI::Commerce::Item must be overridden.');
}

#-------------------------------------------------------------------

=head2 isRecurring ( )

A boolean identifying wheter the item is recurring (like, for instance, a subscription) or not.
You must override this method if your item is recurring.

=cut

sub isRecurring {
	return 0;
}

#-------------------------------------------------------------------

=head2 name ( )

Returns the name of the item. This must be implemented by an item plugin.

=cut

sub name {
	return WebGUI::ErrorHandler::fatal('The name method of WebGUI::Commerce::Item must be overridden.');
}

#-------------------------------------------------------------------

=head2 needsShipping ( )

Return a boolean indicating whether the item needs to be shipped or not. Defaults to false. 

=cut

sub needsShipping {
	return 0;
}

#-------------------------------------------------------------------

=head2 new ( itemdId, itemType )

Returns an item object of type itemType and with id itemId. Note that this is an easy way to load 
item plugins. Your custom plugin should also have a new method that returns the actual item object.

The new method of the plugin won't overload this method, since there's no inheritance.

=head3 itemId

The id of the item you want to load.

=head3 itemType

The type (namespace) of the item you want.

=cut

sub new {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
	$id = shift;
	$namespace = shift;
	
	WebGUI::ErrorHandler::fatal('No namespace') unless ($namespace);
	WebGUI::ErrorHandler::fatal('No ID') unless ($id);
	
    	$cmd = "WebGUI::Commerce::Item::$namespace";
	$load = "use $cmd";
	eval($load);
	WebGUI::ErrorHandler::warn("Item plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd."->new('$id', '$namespace')");
	WebGUI::ErrorHandler::warn("Couldn't instantiate Item plugin: $cmd.".$@) if($@);
	return $plugin;
}

#-------------------------------------------------------------------

=head2 price ( )

This method should return the price of the item. If the item is recurring this should be the per 
term price. This must be implemented by an item plugin.

=cut

sub price {
	return WebGUI::ErrorHandler::fatalError('The price method of WebGUI::Commerce::Item must be overridden.');
}

#-------------------------------------------------------------------

=head2 type ( )

Returns the type (namespace) of the item.

=cut 

sub type {
	return WebGUI::ErrorHandler::fatalError('The type method of WebGUI::Commerce::Item must be overridden.');
}

#-------------------------------------------------------------------

=head2 weight ( )

Returns the weight of the item. If your item has a weight, you'll want to overload this method. Weight is calculated on a unit based scale.
So for instance if your units are kg's 3.154 means 3 kg and 154 grams.

=cut

sub weight {
	return 0;
}

1;

