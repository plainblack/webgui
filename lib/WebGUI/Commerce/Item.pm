package WebGUI::Commerce::Item;

#-------------------------------------------------------------------
sub new {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
	$id = shift;
	$namespace = shift;
	
    	$cmd = "WebGUI::Commerce::Item::$namespace";
	$load = "use $cmd";
	eval($load);
	WebGUI::ErrorHandler::warn("Item plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd."->new('$id', '$namespace')");
	WebGUI::ErrorHandler::warn("Couldn't instantiate Item plugin: $cmd.".$@) if($@);
	return $plugin;
}

1;

