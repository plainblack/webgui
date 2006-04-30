package WebGUI::Image::Graph;

use strict;
use WebGUI::Image;
use WebGUI::Image::Palette;
use WebGUI::Image::Font;
use List::Util;

our @ISA = qw(WebGUI::Image);

#-------------------------------------------------------------------
sub addDataset {
	my $self = shift;
	my $dataset = shift;
	
	push(@{$self->{_datasets}}, $dataset);
}

#-------------------------------------------------------------------
sub configurationForm {
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session, 'Image_Graph');
	
	my $f = WebGUI::HTMLForm->new($self->session);
	$f->trClass('Graph');
	$f->integer(
		-name	=> 'graph_imageWidth',
		-value	=> $self->getImageWidth,
		-label	=> $i18n->get('image width'),
	);
	$f->integer(
		-name	=> 'graph_imageHeight',
		-value	=> $self->getImageHeight,
		-label	=> $i18n->get('image height'),
	);
	$f->color(
		-name	=> 'graph_backgroundColor',
		-value	=> $self->getBackgroundColor,
		-label	=> $i18n->get('background color'),
	);
	$f->selectBox(
		-name	=> 'graph_paletteId',
		-label	=> $i18n->get('palette'),
		-value	=> [ $self->getPalette->getId ],
		-options=> $self->getPalette->getPaletteList,
	);
	$f->float(
		-name	=> 'graph_labelOffset',
		-value	=> $self->getLabelOffset,
		-label	=> $i18n->get('label offset'),
	);
	$f->selectBox(
		-name	=> 'graph_labelFontId',
		-value	=> [ $self->getLabelFont->getId ],
		-label	=> $i18n->get('label font'),
		-options=> WebGUI::Image::Font->getFontList($self->session),
	);
	$f->color(
		-name	=> 'graph_labelColor',
		-value	=> $self->getLabelColor,
		-label	=> $i18n->get('label color'),
	);
	$f->integer(
		-name	=> 'graph_labelFontSize',
		-value	=> $self->getLabelFontSize,
		-label	=> $i18n->get('label fontsize'),
	);
	
	return {'graph' => $f->printRowsOnly};
}

#-------------------------------------------------------------------
sub drawLabel {
	my $self = shift;
	my %properties = @_;
	
	$self->text(
		font		=> $self->getLabelFont->getFile,
		fill		=> $self->getLabelColor,
		style		=> 'Normal',
		pointsize	=> $self->getLabelFontSize,
		%properties,
	);
}

#-------------------------------------------------------------------
sub formNamespace {
	return "Graph";
}

#-------------------------------------------------------------------
sub getConfiguration {
	my $self = shift;

	return {
		graph_formNamespace	=> $self->formNamespace,
		graph_paletteId		=> $self->getPalette->getId,
		graph_labelOffset	=> $self->getLabelOffset,
		graph_labelFontSize	=> $self->getLabelFontSize,
		graph_labelFontId	=> $self->getLabelFont->getId,
		graph_labelColor	=> $self->getLabelColor,
		graph_imageWidth	=> $self->getImageWidth,
		graph_imageHeight	=> $self->getImageHeight,
		graph_backgroundColor	=> $self->getBackgroundColor,
	};
}

#-------------------------------------------------------------------
sub getGraphingTab {
	my (%configForms, $output);
	my $class = shift;
	my $session = shift;
	my $config = shift;

	my (@graphingPlugins, %graphingPlugins, @failedGraphingPlugins);
	
	my $i18n = WebGUI::International->new($session, 'Image_Graph');
		
	my $f = WebGUI::HTMLForm->new($session);
	
	foreach (@{$session->config->get("graphingPlugins")}) {
my		$plugin = WebGUI::Image::Graph->load($session, $_);
		if ($plugin) {
			push(@graphingPlugins, $plugin);
			$plugin->setConfiguration($config);
			$graphingPlugins{$plugin->formNamespace} = $_;
		} else {
			push(@failedGraphingPlugins, $_);
		}
	}
	
	my $ns = $config->{graph_formNamespace};
	# payment plugin
	if (%graphingPlugins) {
		$session->style->setRawHeadTags(<<EOS
		<script type="text/javascript">
			function inNamespace (clas, namespace) {
				var namespaceParts = namespace.split('_');
				var s = '';
				
				for (var i = 0; i < namespaceParts.length; i++) {
					if (i > 0) { 
						s = s + '_';
					}
					s = s + namespaceParts[i];
					
					if (s == clas) {
						return true;
					}
				}

				return false;
			}
		
			function getContainerTag (elem, tagname) {
				var parent = elem.parentNode;
				
				while (parent.tagName != tagname) {
					parent = parent.parentNode;
				}

				return parent;
			}

			function switchGraphingFormElements (elem, namespace) {
				var rowElements = getContainerTag(elem, 'TABLE').getElementsByTagName('TR');

				for (var ix = 0; ix < rowElements.length; ix++) {
					if (inNamespace(rowElements[ix].className, namespace)) {
						rowElements[ix].style.display = '';
					} else {
						if (rowElements[ix].className.match(/^Graph_/)) {
							rowElements[ix].style.display = 'none';
						}
					}
				}
			}
		</script>
EOS
);
		
		$f->selectBox(
			-name		=> 'graphingPlugin',
			-options	=> \%graphingPlugins,
			-label		=> $i18n->get('graph type'),
#### hoverhelp
			-hoverHelp	=> 'Graph type hover',
			-id		=> 'graphTypeSelector',
			-value		=> [ $config->{graph_formNamespace} ],
			-extras		=> 'onchange="switchGraphingFormElements(this, this.value)"'
		);

		foreach my $currentPlugin (@graphingPlugins) {
			%configForms = (%configForms, %{$currentPlugin->configurationForm});
		}
	} else {
		$f->raw('<tr><td colspan="2" align="left">'.$i18n->get('no graphing plugins').'</td></tr>');
	}
	
	foreach (sort keys %configForms) {
		$f->raw($configForms{$_});
	}

	$f->raw('<script type="text/javascript">'.
		"switchGraphingFormElements(document.getElementById('graphTypeSelector'), '$ns');".
		'</script>'
	);
	
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub getDataset {
	my $self = shift;
	my $index = shift;

	return $self->{_datasets} unless (defined $index);
	
	die "Illegal dataset" if ($index >= scalar(@{$self->{_datasets}}));

	return $self->{_datasets}->[$index];
}

#-------------------------------------------------------------------
sub getLabel {
	my $self = shift;
	my $index = shift;

	return $self->{_labels}->{data} || [] unless (defined $index);
	return $self->{_labels}->{data}->[$index];
}
	
#-------------------------------------------------------------------
sub getLabelColor {
	my $self = shift;

	return $self->{_labels}->{labelColor} || '#333333';
}

#-------------------------------------------------------------------
sub getLabelDimensions {
	my $self = shift;
	my $text = shift;
	my $properties = shift || {};
	
	my ($x_ppem, $y_ppem, $ascender, $descender, $width, $height, $max_advance) = $self->image->QueryFontMetrics(
		font		=> $self->getLabelFont->getFile,
#		stroke		=> $self->getLabelColor,
		fill		=> $self->getLabelColor,
		style		=> 'Normal',
		pointsize	=> $self->getLabelFontSize,
		%$properties,
		text		=> $text,
	);

	return {width => $width, height => $height};
}

#-------------------------------------------------------------------
sub getLabelFont {
	my $self = shift;

	return $self->{_labels}->{labelFont} || WebGUI::Image::Font->new($self->session);
}

#-------------------------------------------------------------------
sub getLabelFontSize {
	my $self = shift;

	return $self->{_labels}->{labelFontSize} || 20;
}

#-------------------------------------------------------------------
sub getLabelOffset {
	my $self = shift;

	return $self->{_labels}->{labelOffset} || 10;
}


#-------------------------------------------------------------------
sub getMaxValueFromDataset {
	my $self = shift;
	
	my ($sum, $maxSum);

	if ($self->getDrawMode eq 'stacked') {
		my $maxElements = List::Util::max(map {scalar @$_} @{$self->{_datasets}});
		my $numberOfDatasets = scalar @{$self->{_datasets}};

		for my $currentElement (0 .. $maxElements-1) {
			$sum = 0;
			for my $currentDataset (0 .. $numberOfDatasets - 1) {
				$sum += $self->{_datasets}->[$currentDataset]->[$currentElement];
			}
			$maxSum = $sum if ($sum > $maxSum);
		}
	} else {
		$maxSum = List::Util::max(map {(@$_)} @{$self->{_datasets}});
	}

	return $maxSum;
	
	return List::Util::max(@{$self->{_dataset}});
}

#-------------------------------------------------------------------
sub load {
	my $self = shift;
	my $session = shift;
	my $namespace = shift;

	my $cmd = "use $namespace";
	eval($cmd);

	$cmd = $namespace.'->new($session)';
	my $plugin = eval($cmd);
	return $plugin;
}

#-------------------------------------------------------------------
sub loadByConfiguration {
	my $self = shift;
	my $session = shift;
	my $config = shift;

	my $namespace = "WebGUI::Image::".$config->{graph_formNamespace};
	$namespace =~ s/_/::/g;
	
	$session->errorHandler->fatal("wrong namespace: [$namespace]") unless ($config->{graph_formNamespace} =~ /^[\w\d_]+$/);
	
	my $plugin = $self->load($session, $namespace);
	$plugin->setConfiguration($config);

	return $plugin;
}

#-------------------------------------------------------------------
sub processConfigurationForm {
	my $self = shift;
	my $session = shift;
	
	my $namespace = "WebGUI::Image::".$session->form->process('graphingPlugin');
	$namespace =~ s/_/::/g;

my	$graph = $self->load($session, $namespace);
	
	$graph->setConfiguration($session->form->paramsHashRef);

	return $graph;
}

#-------------------------------------------------------------------
sub setBackground {
	my $self = shift;
	my $backgroundColor = shift;
	
	$self->{_properties}->{backgroundColor} = $backgroundColor;
}

#-------------------------------------------------------------------
sub setConfiguration {
	my $self = shift;
	my $config = shift;

	$self->setPalette(WebGUI::Image::Palette->new($self->session, $config->{graph_paletteId}));
	$self->setLabelOffset($config->{graph_labelOffset});
	$self->setLabelFontSize($config->{graph_labelFontSize});
	$self->setLabelFont(WebGUI::Image::Font->new($self->session, $config->{graph_labelFontId}));
	$self->setLabelColor($config->{graph_labelColor});
	$self->setImageWidth($config->{graph_imageWidth});
	$self->setImageHeight($config->{graph_imageHeight});
	$self->setBackgroundColor($config->{graph_backgroundColor});
	
};

#-------------------------------------------------------------------
sub setLabelColor {
	my $self = shift;
	my $color = shift;

	$self->{_labels}->{labelColor} = $color;
}

#-------------------------------------------------------------------
sub setLabelFont {
	my $self = shift;
	my $font = shift;

	$self->{_labels}->{labelFont} = $font;
}

#-------------------------------------------------------------------
sub setLabelFontSize {
	my $self = shift;
	my $size = shift;

	$self->{_labels}->{labelFontSize} = $size;
}

#-------------------------------------------------------------------
sub setLabelOffset {
	my $self = shift;
	my $offset = shift;

	$self->{_labels}->{labelOffset} = $offset;
}

#-------------------------------------------------------------------
sub setLabels {
	my $self = shift;
	my $labels = shift || [];

	$self->{_labels}->{data} = $labels;
}

#-------------------------------------------------------------------
sub wrapLabelToWidth {
	my (@words, $part, @lines);
	my $self = shift;
	my $text = shift;
	my $maxWidth = shift;
	my $properties = shift;

	@words = split(/ +/, $text);

	foreach (@words) {
		if ($self->getLabelDimensions("$part $_", $properties)->{width} > $maxWidth) {
			if ($part) {
				$part =~ s/ $//;
				push(@lines, $part);
				$part = "$_ ";
			} else {
				push(@lines, $_);
				$part = '';
			}
		} else {
			$part .= "$_ ";
		}
	}
	$part =~ s/ $//;
	push(@lines, $part) if ($part);
	
	return join("\n", @lines);
}

1;


