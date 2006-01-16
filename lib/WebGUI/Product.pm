package WebGUI::Product;

use strict;
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
	
	$optionId = $self->session->id->generate;

	$self->session->db->write("insert into productParameterOptions ".
		"(optionId, parameterId) values ".
		"(".$self->session->db->quote($optionId).", ".$self->session->db->quote($parameterId).")");

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

	$parameterId = $self->session->id->generate;

	$self->session->db->write("insert into productParameters (parameterId, productId) values ".
		"(".$self->session->db->quote($parameterId).", ".$self->session->db->quote($self->get('productId')).")");

	$self->{_parameters}->{$parameterId}->{parameterId} = $parameterId;
	$self->{_parameters}->{$parameterId}->{options} = [];

	return $parameterId;
}

#-------------------------------------------------------------------
sub delete {
	my ($self) = shift;

	foreach (@{$self->getParameter}) {
		$self->session->db->write("delete from productParameterOptions where parameterId=".$self->session->db->quote($_->{parameterId}));
	}
	
	$self->session->db->write("delete from productParameters where productId=".$self->session->db->quote($self->get('productId')));
	$self->session->db->write("delete from productVariants where productId=".$self->session->db->quote($self->get('productId')));
	$self->session->db->write("delete from products where productId=".$self->session->db->quote($self->get('productId')));

	return undef;
}

#-------------------------------------------------------------------
sub deleteParameter {
	my ($self, $parameterId);
	$self = shift;
	$parameterId = shift;

	$self->session->db->write("delete from productParameterOptions where parameterId=".$self->session->db->quote($parameterId));
	$self->session->db->write("delete from productParameters where parameterId=".$self->session->db->quote($parameterId));

	$self->updateVariants;

	return undef;
}

#-------------------------------------------------------------------
sub deleteOption {
	my ($self, $optionId, @options, $parameterId);
	$self = shift;
	$optionId = shift;
	
	$self->session->db->write("delete from productParameterOptions where optionId=".$self->session->db->quote($optionId));

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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	$optionId = shift;
	

	($productId) = $session->db->quickArray("select productId from productParameters as t1, productParameterOptions as t2 ".
		"where t1.parameterId=t2.parameterId and t2.optionId=".$session->db->quote($optionId));
	
	return undef unless ($productId);

	return WebGUI::Product->new($session,$productId);
}

#-------------------------------------------------------------------
sub getByParameterId {
	my ($class, $parameterId, $productId);
	$class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	$parameterId = shift;
	
	($productId) = $session->db->quickArray("select productId from productParameters where parameterId=".$session->db->quote($parameterId));

	return WebGUI::Product->new($session,$productId);
}

#-------------------------------------------------------------------
sub getByVariantId {
	my ($class, $productId, $variantId);
	$class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	$variantId = shift;

	($productId) = $session->db->quickArray("select productId from productVariants where variantId=".$session->db->quote($variantId));

	return WebGUI::Product->new($session,$productId);
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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	$productId = shift;
	$session->errorHandler->fatal('no productId') unless ($productId);
	$parameters = {};
	$variants = {};
	$options = {};
	if ($productId eq 'new') {
		$productId = $session->id->generate;
		$properties = {productId => $productId};
		$session->db->write("insert into products (productId) values (".$session->db->quote($productId).")");
	} else {
		$properties = $session->db->quickHashRef("select * from products where productId=".$session->db->quote($productId));
		
		# fetch parameters and options
		$sth = $session->db->read("select opt.*, param.* from productParameters as param left join productParameterOptions as opt ".
			"on param.parameterId=opt.parameterId where param.productId=".$session->db->quote($productId));
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
		$sth = $session->db->read("select * from productVariants where productId=".$session->db->quote($productId));
		while (%row = $sth->hash) {
			$variants->{$row{variantId}} = {%row};
		}

		$new = 0;
	}

	bless {_session=> $session, _properties => $properties, _parameters => $parameters, _options => $options, _variants => $variants, _new => $new}, $class; 
}

#-------------------------------------------------------------------

=head3 session

Returns a reference to the session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------
sub set {
	my ($self, $properties);
	$self = shift;
	$properties = shift;
		
	$self->session->db->write("update products set ".join(', ', map {$_."=".$self->session->db->quote($properties->{$_})} keys(%$properties)).
		" where productId=".$self->session->db->quote($self->get('productId')));

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
	
	$self->session->db->write("update productParameters set ".join(', ', map {$_."=".$self->session->db->quote($properties->{$_})} keys(%$properties)).
		" where parameterId=".$self->session->db->quote($parameterId));

	map {$self->{_parameter}->{$parameterId}->{$_} = $properties->{$_}} keys %$properties;
}

#-------------------------------------------------------------------
sub setOption {
	my ($self, $optionId, $properties);
	$self = shift;
	$optionId = shift;
	$properties = shift;

	$self->session->db->write("update productParameterOptions set ".join(', ', map {$_."=".$self->session->db->quote($properties->{$_})} keys(%$properties)).
		" where optionId=".$self->session->db->quote($optionId));

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
	$original->{sku} = WebGUI::Asset::Template->processRaw($self->session, $self->get('skuTemplate'), \%sku );

	if (defined $properties->{price}) {
		if ($properties->{price} ne '') {
			push(@pairs, 'price='.$self->session->db->quote($properties->{price}).', priceOverride=1');
		} else {
			push(@pairs, 'price='.$self->session->db->quote($original->{price}).', priceOverride=0');
		}
	}
	if (defined $properties->{weight}) {
		if ($properties->{weight} ne '') {
			push(@pairs, 'weight='.$self->session->db->quote($properties->{weight}).', weightOverride=1');
		} else {
			push(@pairs, 'weight='.$self->session->db->quote($original->{weight}).', weightOverride=0');
		}
	}
	if (defined $properties->{sku}) {
		if ($properties->{sku} ne '') {
			push(@pairs, 'sku='.$self->session->db->quote($properties->{sku}).', skuOverride=1');
		} else {
			push(@pairs, 'sku='.$self->session->db->quote($original->{sku}).', skuOverride=0');
		}
	}
	
	push(@pairs, 'available='.$self->session->db->quote($properties->{available})) if (defined $properties->{available});

	$self->session->db->write("update productVariants set ".join(', ', @pairs)." where variantId=".$self->session->db->quote($variantId)) if (@pairs);

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
		$var{sku} = WebGUI::Asset::Template->processRaw($self->session, $self->get('skuTemplate'), \%sku ) || $self->get('sku');

		if (defined $variants{$var{composition}}) {
			$var{price} = $variants{$var{composition}}{price} if ($variants{$var{composition}}{priceOverride});
			$var{weight} = $variants{$var{composition}}{weight} if ($variants{$var{composition}}{weightOverride});
			$var{sku} = $variants{$var{composition}}{sku} if ($variants{$var{composition}}{skuOverride});
			$var{available} = 0 unless ($variants{$var{composition}}{available});
		}
		
		if (exists $variants{$var{composition}}) {
			$var{variantId} = $variants{$var{composition}}{variantId},
		} else {
			$var{variantId} = $self->session->id->generate;
		}

		push (@newVariants, {%var});
		$newVariants{$var{variantId}} = {%var};
	}

	$self->session->db->write("delete from productVariants where productId=".$self->session->db->quote($self->get('productId')));
	foreach (values %newVariants) {
		$self->session->db->write("insert into productVariants (variantId, productId, composition, price, weight, sku, available) values ".
			"(".$self->session->db->quote($_->{variantId}).", ".$self->session->db->quote($_->{productId}).", ".$self->session->db->quote($_->{composition}).", ".$self->session->db->quote($_->{price}).
			", ".$self->session->db->quote($_->{weight}).", ".$self->session->db->quote($_->{sku}).", ".$self->session->db->quote($_->{available}).")");
	}

	$self->{_variants} = \%newVariants;
}

1;
