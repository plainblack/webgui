package WebGUI::Image::Graph;

use strict;
use WebGUI::Image;
use WebGUI::Image::Palette;
use WebGUI::Image::Font;
use List::Util;
use WebGUI::Pluggable;

our @ISA = qw(WebGUI::Image);

=head1 NAME

Package WebGUI::Image::Graph

=head1 DESCRIPTION

Base class for graphs.

=head1 SYNOPSIS

This package provides the basic needs for creating graphs.

Among others this package provides the base methods for configuration forms,
dataset addition, loading plugins, and setting general parameters like
backgraound color.

=cut

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addDataset ( dataset )

Adds a dataset to the graph. Please not that not all graph types can handle
multiple datasets and will therefore ignore any dataset but the first.

=head3 dataset

An arrayref containg the values of the data. The dat must be numeric.

=cut

sub addDataset {
	my $self = shift;
	my $dataset = shift;
	
	push(@{$self->{_datasets}}, $dataset);
}

#-------------------------------------------------------------------

=head2 configurationForm ( $tab )

Adds form fields for this type of graph plugin to a WebGUI::FormBuilder::Tab object.
Your plugin should extend this method by first calling SUPER.

Check some of the plugins that come with WebGUI for examples.

=head3 $tab

A WebGUI::FormBuilder::Tab object to append the form fields to.

=cut

sub configurationForm {
	my $self = shift;
    my $tab  = shift;

	my $i18n = WebGUI::International->new($self->session, 'Image_Graph');
	
	$tab->addField('integer', 
		name	=> 'graph_imageWidth',
		value	=> $self->getImageWidth,
		label	=> $i18n->get('image width'),
		hoverHelp => $i18n->get('image width description'),
	);
	$tab->addField('integer',
		name	=> 'graph_imageHeight',
		value	=> $self->getImageHeight,
		label	=> $i18n->get('image height'),
		hoverHelp => $i18n->get('image height description'),
	);
	$tab->addField('color',
		name	=> 'graph_backgroundColor',
		value	=> $self->getBackgroundColor,
		label	=> $i18n->get('background color'),
		hoverHelp => $i18n->get('background color description'),
	);
	$tab->addField('selectBox',
		name	=> 'graph_paletteId',
		label	=> $i18n->get('palette'),
		hoverHelp => $i18n->get('palette description'),
		value	=> [ $self->getPalette->getId ],
		options=> $self->getPalette->getPaletteList,
	);
	$tab->addField('float',
		name	=> 'graph_labelOffset',
		value	=> $self->getLabelOffset,
		label	=> $i18n->get('label offset'),
		hoverHelp => $i18n->get('label offset description'),
	);
	$tab->addField('selectBox',
		name	=> 'graph_labelFontId',
		value	=> [ $self->getLabelFont->getId ],
		label	=> $i18n->get('label font'),
		hoverHelp => $i18n->get('label font description'),
		options=> WebGUI::Image::Font->getFontList($self->session),
	);
	$tab->addField('color',
		name	=> 'graph_labelColor',
		value	=> $self->getLabelColor,
		label	=> $i18n->get('label color'),
		hoverHelp => $i18n->get('label color description'),
	);
	$tab->addField('integer',
		name	=> 'graph_labelFontSize',
		value	=> $self->getLabelFontSize,
		label	=> $i18n->get('label fontsize'),
		hoverHelp => $i18n->get('label fontsize description'),
	);
}

#-------------------------------------------------------------------

=head2 drawLabel ( label, [ properties ] )

Draws a label with your preferred properties. Defaults the font, font size and
color which you can override.

=head3 label

The text of the label you want to print.

=head3 properties

A hash containing imagemagick Annotate properties.

=cut

sub drawLabel {
	my $self = shift;
	my $label = shift;
	my %properties = @_;
	
	$self->text(
		text		=> $label,
		font		=> $self->getLabelFont->getFile,
		fill		=> $self->getLabelColor,
		style		=> 'Normal',
		pointsize	=> $self->getLabelFontSize,
		%properties,
	);
}

#-------------------------------------------------------------------

=head2 formNamespace ( )

Returns the namespace used in the configuration form. You must extend this
method by concatenating an underscore and the last part of your namespace to the
output of the SUPER method.

For examples please see the implementation in the plugins that come with WebGUI.

=cut

sub formNamespace {
	return "Graph";
}

#-------------------------------------------------------------------

=head2 getConfiguration ( )

Returns the configuration hashref of the plugin. You must extend this method by
adding your configuration keys to the hashref returned by the SUPER method. To
avoid conflicts prepend your configuration keys with the namespace of your
plugin, encoded as follows: take the part of the namespace without
WebGUI::Image, convert it to lowercase and substitute the :: with a single
underscore.

Check out the plugins that are shipped with WebGUI for examples.

=cut

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

=head2 getGraphingTab ( tab, [ config ] )

Returns the contents of the graphing tab you can add to your asset. 

This is a class method.

=head3 tab 

An instanciated WebGUI::FormBuilder::Tab object.  The session is taken
from this.

=head3 config

Optionally you can pass a configuration hash to populate the form

=cut

sub getGraphingTab {
	my $class   = shift;
	my $tab     = shift;
	my $config  = shift;
    my $session = $tab->session;

	my (@graphingPlugins, %graphingPlugins, @failedGraphingPlugins);
	
	my $i18n = WebGUI::International->new($session, 'Image_Graph');
		
	my $f = WebGUI::HTMLForm->new($session);

	unless ($session->config->get("graphingPlugins")) {
        $tab->addField('readOnly', { value => $i18n->get('no graphing plugins in config'), });
	}
	
	foreach (@{$session->config->get("graphingPlugins")}) {
        my $plugin = WebGUI::Image::Graph->load($session, $_);
		if ($plugin) {
			push(@graphingPlugins, $plugin);
			$plugin->setConfiguration($config);
			$graphingPlugins{$plugin->formNamespace} = $_;
		} else {
			push(@failedGraphingPlugins, $_);
		}
	}
	
	my $ns = $config->{graph_formNamespace};
	my %configForms;
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

        $tab->addField('selectBox',
			name		=> 'graphingPlugin',
			options	    => \%graphingPlugins,
			label		=> $i18n->get('graph type'),
			hoverHelp	=> $i18n->get('graph type description'),
			id		    => 'graphTypeSelector',
			value		=> [ $config->{graph_formNamespace} ],
			extras		=> 'onchange="switchGraphingFormElements(this, this.value)"', 
		);

		foreach my $currentPlugin (@graphingPlugins) {
			$currentPlugin->configurationForm($tab);
		}
	} else {
		$tab->addField('readOnly', value => $i18n->get('no graphing plugins'), );
	}

	foreach (sort keys %configForms) {
		$f->raw($configForms{$_});
	}

    $tab->addField('readOnly', value => <<EOJS );
<script type="text/javascript">
    switchGraphingFormElements(document.getElementById('graphTypeSelector'), '$ns')
</script>
EOJS
}

#-------------------------------------------------------------------

=head2 getDataset ( [ index ] )

Returns the dataset indicated by index.

=head3 index

The index of the array containing the datasets. The first dataset is indicated
by index 0. If ommitted this method returns an arrayref of arrayrefs containing
all datasets.

=cut

sub getDataset {
	my $self = shift;
	my $index = shift;

	return $self->{_datasets} unless (defined $index);
	
	die "Illegal dataset" if ($index >= scalar(@{$self->{_datasets}}));

	return $self->{_datasets}->[$index];
}

#-------------------------------------------------------------------

=head2 getLabel ( [ index ] )

Returns the index'th label or an arrayref containing all labels.

=head3 index

The index of label to return. Numbering starts at 0. If omitted an arrayref
containing all labels is returned.

=cut

sub getLabel {
	my $self = shift;
	my $index = shift;

	return $self->{_labels}->{data} || [] unless (defined $index);
	return $self->{_labels}->{data}->[$index];
}
	
#-------------------------------------------------------------------

=head2 getLabelColor

Returns the triplet of the label color. Defaults to '#333333'.

=cut

sub getLabelColor {
	my $self = shift;

	return $self->{_labels}->{labelColor} || '#333333';
}

#-------------------------------------------------------------------

=head2 getLabelDimensions ( text, [ properties ] )

Returns a hashref containg the width and height in pixels of the passed text.
Width and height are referenced by the keys 'width' and 'height' respectively.

=head3 text

The text you want to know the dimensions of.

=head3 properties

Optionally you can pass a hashref containing imagemagick's Annotate properties.

=cut

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

=head2 getLabelFont ( )

Returns the WebGUI::Image::Font object this image is set to. Defaults to the
default font.

=cut

sub getLabelFont {
	my $self = shift;

	return $self->{_labels}->{labelFont} || WebGUI::Image::Font->new($self->session);
}

#-------------------------------------------------------------------

=head2 getLabelFontSize ( )

Returns the font size of the labels. Defaults to 20.

=cut

sub getLabelFontSize {
	my $self = shift;

	return $self->{_labels}->{labelFontSize} || 20;
}

#-------------------------------------------------------------------

=head2 getLabelOffset ( )

Returns the label offset. This is the distance between the label and the axis.
Defaults to 10 pixels.

=cut

sub getLabelOffset {
	my $self = shift;

	return $self->{_labels}->{labelOffset} || 10;
}

#-------------------------------------------------------------------

=head2 getMaxValueFromDataset ( )

Returns the highest value of all added datasets.

=cut

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

=head2 getPluginList ( )

Returns an arrayref containing the namespaces of the enabled graphing plugins.

=cut

sub getPluginList {
	my $self = shift;
	my $session = shift || $self->session;
	
	return $session->config->get("graphingPlugins");
}

#-------------------------------------------------------------------

=head2 load ( session, namespace )

Instanciates an WebGUI::Graph object with the given namespace.

=head3 session

A WebGUI::Session object.

=head3 namespace

The full namespace of the plugin you want to load.

=cut

sub load {
	my $self = shift;
	my $session = shift;
	my $namespace = shift;

	my $plugin = eval { 
        WebGUI::Pluggable::instanciate($namespace, 'new', [$session, ]);
    };
	return $plugin;
}

#-------------------------------------------------------------------

=head2 loadByConfiguration ( session, configuration )

Loads a plugin defined by a configuration hash.

=head3 session

A WebGUI::Session object.

=head3 configuration

A configuration hashref.

=cut

sub loadByConfiguration {
	my $self = shift;
	my $session = shift;
	my $config = shift;

	my $namespace = "WebGUI::Image::".$config->{graph_formNamespace};
	$namespace =~ s/_/::/g;
	
	$session->log->fatal("wrong namespace: [$namespace]") unless ($config->{graph_formNamespace} =~ /^[\w\d_]+$/);
	
	my $plugin = $self->load($session, $namespace);
	$plugin->setConfiguration($config);

	return $plugin;
}

#-------------------------------------------------------------------

=head2 processConfigurationForm ( session )

Processes the configuration form that is submitted and returns the correct
instanciated graphing plugin.

=head3 session

The WebGUI session object.

=cut

sub processConfigurationForm {
	my $class = shift;
	my $session = shift;

	if (! $class->getPluginList($session)) {
	     WebGUI::Error->throw(error => "No graphing plugins listed in config")
    }
	
	my $namespace = "WebGUI::Image::".$session->form->process('graphingPlugin');
	$namespace =~ s/_/::/g;

     if (! $namespace ~~ $class->getPluginList($session)) {
	     WebGUI::Error->throw(error => "Graphing plugin not available")
     }

    my $graph = $class->load($session, $namespace);
	
	$graph->setConfiguration($session->form->paramsHashRef);

	return $graph;
}

#-------------------------------------------------------------------

=head2 setConfiguration ( config )

Configures the pluging according to the configuration hashref that is passed.
You must extend this method by calling the SUPER method with the configuration
hashref and processing your part of the configuration options.

=head3 config

The configuration hashref.

=cut

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

=head2 setLabelColor ( color )

Sets the color triplet of the labels.

=head3 color 

The triplet defining the color. The triplet should be in the form of '#ffffff'.

=cut

sub setLabelColor {
	my $self = shift;
	my $color = shift;

	$self->{_labels}->{labelColor} = $color;
}

#-------------------------------------------------------------------

=head2 setLabelFont ( font )

Set the label font.

=head3 font

A WebGUI::Image::Font object.

=cut

sub setLabelFont {
	my $self = shift;
	my $font = shift;

	$self->{_labels}->{labelFont} = $font;
}

#-------------------------------------------------------------------

=head2 setLabelFontSize ( size )

Sets the font size of the labels.

=head3 size

The desired font size.

=cut

sub setLabelFontSize {
	my $self = shift;
	my $size = shift;

	$self->{_labels}->{labelFontSize} = $size;
}

#-------------------------------------------------------------------

=head2 setLabelOffset ( offset )

Sets the label offset. This is the distance in pixels between the labels and the
axis.

=head3 offset

The label offset.

=cut

sub setLabelOffset {
	my $self = shift;
	my $offset = shift;

	$self->{_labels}->{labelOffset} = $offset;
}

#-------------------------------------------------------------------

=head2 setLabels ( labels )

Sets the labels for the datasets.

=head3 labels

An arrayref containig the labels.

=cut

sub setLabels {
	my $self = shift;
	my $labels = shift || [];

	$self->{_labels}->{data} = $labels;
}

#-------------------------------------------------------------------

=head2 wrapLabelToWidth ( text, maxWidth, [ properties ] )

Wraps a text string onto multiple lines having a width of maxWidth.

=head3 text

The text you want to wrap.

=head3 maxWidth

The width the string should have after wrapping/

=head3 properties

An optional hashref containing imagemagick's Annotate properties.

=cut

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

