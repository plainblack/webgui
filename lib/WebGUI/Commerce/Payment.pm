package WebGUI::Commerce::Payment;

use strict;
use WebGUI::SQL;
use WebGUI::International;
use Tie::IxHash;
use WebGUI::HTMLForm;

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $form, $f);
	$self = shift;
	$form = shift;

	$f = WebGUI::HTMLForm->new;
	$f->yesNo(
		-name	=> $self->prepend('enabled'),
		-value	=> $self->enabled,
#### intl ####
		-label	=> 'Enable',
		);
	$f->raw($form);

	return $f->printRowsOnly;
}
	
#-------------------------------------------------------------------
sub enabled {
	return $_[0]->{_enabled};
}

#-------------------------------------------------------------------
sub get {
	return $_[0]->{_properties}{$_[1]};
}

#-------------------------------------------------------------------
sub getEnabledPlugins {
	my (@enabledPlugins, $plugin, @plugins);
	@enabledPlugins = WebGUI::SQL->buildArray("select namespace from commerceSettings where type='Payment' and fieldName='enabled' and fieldValue='1'");

	foreach (@enabledPlugins) {
		$plugin = WebGUI::Commerce::Payment->load($_);
		push(@plugins, $plugin) if ($plugin);
	}

	return \@plugins;
}
	
#-------------------------------------------------------------------
sub init {
	my ($class, $namespace, $properties);
	$class = shift;
	$namespace = shift;
	
	$properties = WebGUI::SQL->buildHashRef("select fieldName, fieldValue from commerceSettings where namespace=".quote($namespace)." and type='Payment'");

	bless {_properties=>$properties, _namespace=>$namespace, _enabled=>$properties->{enabled}}, $class;
}

#-------------------------------------------------------------------
sub load {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
	$namespace = shift;
	
    	$cmd = "WebGUI::Commerce::Payment::$namespace";
	$load = "use $cmd";
	eval($load);
	WebGUI::ErrorHandler::warn("Payment plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd."->init");
	WebGUI::ErrorHandler::warn("Couldn't instantiate payment plugin: $cmd.".$@) if($@);
	return $plugin;
}

#-------------------------------------------------------------------
sub namespace {
	return $_[0]->{_namespace};
}

#-------------------------------------------------------------------
sub prepend {
	my ($self, $name);
	$self = shift;
	$name = shift;

	return "~Payment~".$self->namespace."~".$name;
}

#-------------------------------------------------------------------
sub recurringPeriodValues {
	my ($i18n, %periods);
	$i18n = WebGUI::International->new('Commerce');
	tie %periods, "Tie::IxHash";	
	%periods = (
		Weekly		=> $i18n->get('weekly'),
		BiWeekly	=> $i18n->get('biweekly'),
		FourWeekly	=> $i18n->get('fourweekly'),
		Monthly		=> $i18n->get('monthly'),
		Quarterly	=> $i18n->get('quarterly'),
		HalfYearly	=> $i18n->get('halfyearly'),
		Yearly		=> $i18n->get('yearly'),
		);
	
	return \%periods;
}

1;

