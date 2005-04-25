package WebGUI::Product;

use strict;
use WebGUI::SQL;
use WebGUI::Id;
use WebGUI::Asset::Template;

#-------------------------------------------------------------------
sub _permute {
	my ($currentSet, @permutations, $permutation, $value, @result);
	$currentSet = shift;
	
	@permutations = (@_) ? _permute(@_) : [];
	foreach $permutation (@permutations) {
		foreach $value (@$currentSet) {
			push(@result, [$value, @{$permutation}]);
		}
	}
	
	return @result;
}

#-------------------------------------------------------------------
sub addOptionToParameter {
	my ($self, $parameterId, $properties, $optionId);
	$self = shift;
	$parameterId = shift;
	$properties = shift || {};
	
	$optionId = WebGUI::Id::generate;

	WebGUI::SQL->write("insert into productParameterOptions ".
		"(optionId, parameterId) values ".
		"(".quote($optionId).", ".quote($parameterId).")");

	$self->{_options}->{$optionId} = { 
		%$properties, 
		parameterId => $parameterId,
       		optionId => $optionId,
		};
	push(@{$self->{_parameters}->{$parameterId}->{options}}, $optionId);

	$self->updateVariants;

	return $optionId;
}

#-------------------------------------------------------------------
sub addParameter {
	my ($self, $properties, $parameterId);
	
	$self = shift;
	$properties = shift;

	$parameterId = WebGUI::Id::generate;

	WebGUI::SQL->write("insert into productParameters (parameterId, productId) values ".
		"(".quote($parameterId).", ".quote($self->get('productId')).")");

	$self->{_parameters}->{$parameterId}->{parameterId} = $parameterId;
	$self->{_parameters}->{$parameterId}->{options} = [];

	return $parameterId;
}

#-------------------------------------------------------------------
sub delete {
	my ($self) = shift;

	foreach (@{$self->getParameter}) {
		WebGUI::SQL->write("delete from productParameterOptions where parameterId=".quote($_->{parameterId}));
	}
	
	WebGUI::SQL->write("delete from productParameters where productId=".quote($self->get('productId')));
	WebGUI::SQL->write("delete from productVariants where productId=".quote($self->get('productId')));
	WebGUI::SQL->write("delete from products where productId=".quote($self->get('productId')));

	return undef;
}

#-------------------------------------------------------------------
sub deleteParameter {
	my ($self, $parameterId);
	$self = shift;
	$parameterId = shift;

	WebGUI::SQL->write("delete from productParameterOptions where parameterId=".quote($parameterId));
	WebGUI::SQL->write("delete from productParameters where parameterId=".quote($parameterId));

	$self->updateVariants;

	return undef;
}

#-------------------------------------------------------------------
sub deleteOption {
	my ($self, $optionId, @options, $parameterId);
	$self = shift;
	$optionId = shift;
	
	WebGUI::SQL->write("delete from productParameterOptions where optionId=".quote($optionId));

	$parameterId = $self->{_options}->{$optionId}->{parameterId};

	delete($self->{_options}->{$optionId});

	foreach (@{$self->{_parameters}->{$parameterId}->{options}}) { 
		push(@options, $_) unless ($_ eq $optionId);
	}

	$self->{_parameters}->{$parameterId}->{options} = \@options;
	
	$self->updateVariants;
	
	return undef;
}

#-------------------------------------------------------------------
sub get {
	my ($self, $property);
	$self = shift;
	$property = shift;

	return $self->{_properties}->{$property} if ($property);
	
	return $self->{_properties};	
}

#-------------------------------------------------------------------
sub getByOptionId {
	my ($class, $optionId, $productId);

	$class = shift;
	$optionId = shift;
	

	($productId) = WebGUI::SQL->quickArray("select productId from productParameters as t1, productParameterOptions as t2 ".
		"where t1.parameterId=t2.parameterId and t2.optionId=".quote($optionId));
	
	return undef unless ($productId);

	return WebGUI::Product->new($productId);
}

#-------------------------------------------------------------------
sub getByParameterId {
	my ($class, $parameterId, $productId);
	$class = shift;
	$parameterId = shift;
	
	($productId) = WebGUI::SQL->quickArray("select productId from productParameters where parameterId=".quote($parameterId));

	return WebGUI::Product->new($productId);
}

#-------------------------------------------------------------------
sub getByVariantId {
	my ($class, $productId, $variantId);
	$class = shift;
	$variantId = shift;

	($productId) = WebGUI::SQL->quickArray("select productId from productVariants where variantId=".quote($variantId));

	return WebGUI::Product->new($productId);
}

#-------------------------------------------------------------------
sub getOption {
	my ($self, $optionId);
	$self = shift;
	$optionId = shift;

	return $self->{_options}->{$optionId} if ($optionId);

	return [ values %{$self->{_options}} ];
}

#-------------------------------------------------------------------
sub getParameter {
	my ($self, $parameterId);
	$self = shift;
	$parameterId = shift;

	return $self->{_parameters}->{$parameterId} if ($parameterId);

	return [ values %{$self->{_parameters}} ];
}

#-------------------------------------------------------------------
sub getVariant {
	my ($self, $variantId);
	$self = shift;
	$variantId = shift;
	
	return $self->{_variants}->{$variantId} if ($variantId);
	
	return [ values %{$self->{_variants}} ];
}

#-------------------------------------------------------------------
sub new {
	my ($class, $productId, $properties, $parameters, $variants, $options, $sth, %row, $option, $new);
	$class = shift;
	$productId = shift;
	
	WebGUI::ErrorHandler::fatal('no productId') unless ($productId);

	$parameters = {};
	$variants = {};
	$options = {};
	
	if ($productId eq 'new') {
		$productId = WebGUI::Id::generate;
		$properties = {productId => $productId};
		WebGUI::SQL->write("insert into products (productId) values (".quote($productId).")");
	} else {
		$properties = WebGUI::SQL->quickHashRef("select * from products where productId=".quote($productId));
		
		# fetch parameters and options
		$sth = WebGUI::SQL->read("select opt.*, param.* from productParameters as param left join productParameterOptions as opt ".
			"on param.parameterId=opt.parameterId where param.productId=".quote($productId));
		while (%row = $sth->hash) {
			$parameters->{$row{parameterId}} = {
				name		=> $row{name},
				parameterId	=> $row{parameterId},
				options		=> [],
			} unless (defined $parameters->{$row{parameterId}});
			if ($row{value}) { 
				$option = {
					value		=> $row{value},
					optionId	=> $row{optionId},
					parameterId	=> $row{parameterId},
					priceModifier	=> $row{priceModifier},
					weightModifier	=> $row{weightModifier},
					skuModifier	=> $row{skuModifier}
				};
				push(@{$parameters->{$row{parameterId}}->{options}}, $row{optionId});
				$options->{$row{optionId}} = $option;
			}
		}

		# fetch variants
		$sth = WebGUI::SQL->read("select * from productVariants where productId=".quote($productId));
		while (%row = $sth->hash) {
			$variants->{$row{variantId}} = {%row};
		}

		$new = 0;
	}

	bless {_properties => $properties, _parameters => $parameters, _options => $options, _variants => $variants, _new => $new}, $class; 
}

#-------------------------------------------------------------------
sub set {
	my ($self, $properties);
	$self = shift;
	$properties = shift;
		
	WebGUI::SQL->write("update products set ".join(', ', map {$_."=".quote($properties->{$_})} keys(%$properties)).
		" where productId=".quote($self->get('productId')));

	foreach (keys(%$properties)) {
		$self->{_properties}->{$_} = $properties->{$_};
	}

	$self->updateVariants;
}

#-------------------------------------------------------------------
sub setParameter {
	my ($self, $parameterId, $properties);
	$self = shift;
	$parameterId = shift;
	$properties = shift;
	
	WebGUI::SQL->write("update productParameters set ".join(', ', map {$_."=".quote($properties->{$_})} keys(%$properties)).
		" where parameterId=".quote($parameterId));

	map {$self->{_parameter}->{$parameterId}->{$_} = $properties->{$_}} keys %$properties;
}

#-------------------------------------------------------------------
sub setOption {
	my ($self, $optionId, $properties);
	$self = shift;
	$optionId = shift;
	$properties = shift;

	WebGUI::SQL->write("update productParameterOptions set ".join(', ', map {$_."=".quote($properties->{$_})} keys(%$properties)).
		" where optionId=".quote($optionId));

	foreach (keys(%$properties)) {
		$self->{_options}->{$optionId}->{$_} = $properties->{$_};
	}

	$self->updateVariants;
}

#-------------------------------------------------------------------
sub setVariant {
	my ($self, $variantId, $properties, @pairs, $original, %sku, $parameterName);
	$self = shift;
	$variantId = shift;
	$properties = shift;

my 	%pairs = map {split(/\./, $_)} split(/,/, $self->getVariant($variantId)->{composition});

	$original->{price} = $self->get('price');
	$original->{weight} = $self->get('weight');
	$sku{base} = $self->get('sku');
	
	foreach (values(%pairs)) {
my		$currentOption = $self->getOption($_);
		$original->{price} += $currentOption->{priceModifier};
		$original->{weight} += $currentOption->{weightModifier};
		($parameterName = $self->{_parameters}->{$currentOption->{parameterId}}->{name}) =~ s/ //g;
		$sku{'param.'.$parameterName} = $currentOption->{skuModifier};
	}
	$original->{sku} = WebGUI::Asset::Template->processRaw($self->get('skuTemplate'), \%sku );

	if (defined $properties->{price}) {
		if ($properties->{price} ne '') {
			push(@pairs, 'price='.quote($properties->{price}).', priceOverride=1');
		} else {
			push(@pairs, 'price='.quote($original->{price}).', priceOverride=0');
		}
	}
	if (defined $properties->{weight}) {
		if ($properties->{weight} ne '') {
			push(@pairs, 'weight='.quote($properties->{weight}).', weightOverride=1');
		} else {
			push(@pairs, 'weight='.quote($original->{weight}).', weightOverride=0');
		}
	}
	if (defined $properties->{sku}) {
		if ($properties->{sku} ne '') {
			push(@pairs, 'sku='.quote($properties->{sku}).', skuOverride=1');
		} else {
			push(@pairs, 'sku='.quote($original->{sku}).', skuOverride=0');
		}
	}
	
	push(@pairs, 'available='.quote($properties->{available})) if (defined $properties->{available});

	WebGUI::SQL->write("update productVariants set ".join(', ', @pairs)." where variantId=".quote($variantId)) if (@pairs);

	$self->{_variants}->{$variantId} = {%{$self->{_variants}->{$variantId}}, %$properties};
}

#-------------------------------------------------------------------
sub updateVariants {
	my ($self, %variants, @optionSets, @variants, $variant, %var, @composition, $option, @newVariants, $parameterName);
	$self = shift;

	foreach (@{$self->getVariant}) {
		$variants{$_->{composition}} = $_;
	}

	# group options per parameter so they can be permuted
	foreach my $parameter (@{$self->getParameter}) {
		push (@optionSets, [ map {$self->{_options}->{$_}} @{$parameter->{options}} ] ) if (@{$parameter->{options}});
	}
		
	@variants = _permute(@optionSets);
	
	@variants = ([]) unless	(@variants);
	my %newVariants;
	foreach $variant (@variants) {
		my %sku;
		
		$var{productId} = $self->get('productId');
		$var{price} = $self->get('price');
		$var{weight} = $self->get('weight');
		$var{sku} = $self->get('sku');
		$sku{base} = $self->get('sku');
		@composition = ();

		foreach $option (@{$variant}) {
			$var{price} += $option->{priceModifier};
			$var{weight} += $option->{weightModifier};
			$var{sku} .= $option->{skuModifier};
			($parameterName = $self->{_parameters}->{$option->{parameterId}}->{name}) =~ s/ //g;
			$sku{'param.'.$parameterName} = $option->{skuModifier};
			$var{description} .= $option->{value};
			push (@composition, $option->{parameterId}.".".$option->{optionId});
		}

		$var{composition} = join(',', sort @composition);
		$var{available} = 1;
		$var{sku} = WebGUI::Asset::Template->processRaw($self->get('skuTemplate'), \%sku ) || $self->get('sku');

		if (defined $variants{$var{composition}}) {
			$var{price} = $variants{$var{composition}}{price} if ($variants{$var{composition}}{priceOverride});
			$var{weight} = $variants{$var{composition}}{weight} if ($variants{$var{composition}}{weightOverride});
			$var{sku} = $variants{$var{composition}}{sku} if ($variants{$var{composition}}{skuOverride});
			$var{available} = 0 unless ($variants{$var{composition}}{available});
		}
		
		if (exists $variants{$var{composition}}) {
			$var{variantId} = $variants{$var{composition}}{variantId},
		} else {
			$var{variantId} = WebGUI::Id::generate;
		}

		push (@newVariants, {%var});
		$newVariants{$var{variantId}} = {%var};
	}

	WebGUI::SQL->write("delete from productVariants where productId=".quote($self->get('productId')));
	foreach (values %newVariants) {
		WebGUI::SQL->write("insert into productVariants (variantId, productId, composition, price, weight, sku, available) values ".
			"(".quote($_->{variantId}).", ".quote($_->{productId}).", ".quote($_->{composition}).", ".quote($_->{price}).
			", ".quote($_->{weight}).", ".quote($_->{sku}).", ".quote($_->{available}).")");
	}

	$self->{_variants} = \%newVariants;
}

1;
