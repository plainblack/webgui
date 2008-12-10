package WebGUI::Form::AutoComplete;

use strict;
use base 'WebGUI::Form::List';
use WebGUI::International;
use JSON;

=head1 NAME

Package WebGUI::Form::AutoComplete

=head1 DESCRIPTION

Creates a YUI-based AutoComplete field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the superclass for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 255. Determines the maximum number of characters allowed in this field.

=head4 defaultValue

Defaults to undefined

=head4 size

Defaults to the setting textBoxSize or 30 if that's not set. Specifies how big of a text box to display.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift || [];
    push(
        @{$definition},
        {   maxlength => { defaultValue => 255 },
            size      => { defaultValue => $session->setting->get("textBoxSize") || 30 },
            defaultValue => {},
        }
    );
    return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ( $self, $session ) = @_;
    return 'AutoComplete';
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an AutoComplete field.

=cut

sub toHtml {
    my $self         = shift;
    my @yui_includes = qw(
        yahoo-dom-event/yahoo-dom-event.js
        datasource/datasource-min.js
        autocomplete/autocomplete-min.js
    );
    foreach my $yui (@yui_includes) {
        $self->session->style->setScript( $self->session->url->extras("/yui/build/$yui"),
            { type => 'text/javascript' } );
    }

    my $id        = $self->get('id');
    my $name      = $self->get("name");
    my $value     = $self->fixMacros( $self->fixQuotes( $self->fixSpecialCharacters( $self->getOriginalValue ) ) );
    my $size      = $self->get("size");
    my $maxlength = $self->get("maxlength");
    my $extras    = $self->get("extras");

    my $options = $self->getOptions;
    my $data_source = encode_json( [ keys %{$options} ] );

    return <<"END_HTML";
<style type="text/css">
.yui-ac-trigger {
    position:absolute; 
    right: 0; 
    top: 2px; 
    z-index: 2; 
    height: 14px; 
    width: 14px; 
    background: transparent url(uploads/minified/dashSprite.png) repeat scroll 0 -350px;
}
</style>
<div>
	<input id="$id" type="text" name="$name" value="$value" size="$size" maxlength="$maxlength" $extras>
	<div id="yui-ac-$id"></div>
	<div id="yui-ac-trigger-$id" class="yui-ac-trigger"></div>
</div>

<script type="text/javascript">
(function() {
    var ds = new YAHOO.util.LocalDataSource($data_source);
    var ac = new YAHOO.widget.AutoComplete("$id", "yui-ac-$id", ds);
    ac.minQueryLength = 0;
    
    YAHOO.util.Event.on("yui-ac-trigger-$id", 'click', function(){
        if (ac.isContainerOpen()) {
            ac. collapseContainer();
        } else {
            ac.sendQuery('');
        }
    });
})();
</script>
END_HTML
}

1;