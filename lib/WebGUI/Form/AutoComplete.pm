package WebGUI::Form::AutoComplete;

use strict;
use base 'WebGUI::Form::Text';
use WebGUI::International;
use JSON;

=head1 NAME

Package WebGUI::Form::AutoComplete

=head1 DESCRIPTION

Creates a YUI-based AutoComplete field.
The options hashref is used to populate the YUI autocomplete data source.
A trigger icon, a la the ExtJS AutoComplete has also been added.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text with a heavy smattering of methods from WebGUI::Form::List.

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

=head4 options

A hash reference containing key values that will be returned with the form post and displayable text pairs. Defaults to an empty hash reference.

=head4 sortByValue

A boolean value for whether or not the values in the options hash should be sorted. Defaults to "0".

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
            options      => { defaultValue => {} },
            sortByValue  => { defaultValue => 0 },
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

=head2 getOptions ( )

Taken from WebGUI::Form::List

=cut

sub getOptions {
    my ($self)         = @_;
    my $possibleValues = $self->get('options');
    my %options        = ();
    tie %options, 'Tie::IxHash';
    if ( ref $possibleValues eq "HASH" ) {
        %options = %{$possibleValues};
    }
    else {
        foreach my $line ( split "\n", $possibleValues ) {
            $line =~ s/^(.*)\r|\s*$/$1/;
            if ( $line =~ m/(.*)\|(.*)/ ) {
                $options{$1} = $2;
            }
            else {
                $options{$line} = $line;
            }
        }
    }
    if ( $self->get('sortByValue') ) {
        my %ordered = ();
        tie %ordered, 'Tie::IxHash';
        foreach my $optionKey ( sort { "\L$options{$a}" cmp "\L$options{$b}" } keys %options ) {
            $ordered{$optionKey} = $options{$optionKey};
        }
        return \%ordered;
    }
    return \%options;
}

=head2 getOriginalValue ( )

Taken from WebGUI::Form::List

=cut

sub getOriginalValue {
    my $self = shift;
    my @values = ();
    foreach my $value ($self->get("value")) {
        if (scalar @values < 1 && defined $value) {
            if (ref $value eq "ARRAY") {
                @values = @{$value};
            }
            else {
				$value =~ s/\r//g;
                @values = split "\n", $value;
            }
        }
    }
    if(@values){
    	return wantarray ? @values : join("\n",@values);
    }
    
    foreach my $value ($self->getDefaultValue()) {
        if (scalar @values < 1 && defined $value) {
            if (ref $value eq "ARRAY") {
                @values = @{$value};
            }
            else {
				$value =~ s/\r//g;
                @values = split "\n", $value;
            }
        }
    }
	return wantarray ? @values : join("\n",@values);
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Taken from WebGUI::Form::List

=cut

sub getValue {
	my ($self, $value) = @_;
    
    my @values = ();
    if (defined $value) {
        if (ref $value eq "ARRAY") {
            @values = @{$value};
        }
        else {
			$value =~ s/\r//g;
            @values = split "\n", $value;
        }
    }
    if (scalar @values < 1 && $self->session->request) {
        my $value = $self->session->form->param($self->get("name"));
        if (defined $value) {
            @values = $self->session->form->param($self->get("name"));
        }
    }
    if (scalar @values < 1) {
        @values = $self->getDefaultValue;
    }
	return wantarray ? @values : join("\n",@values);
}

#-------------------------------------------------------------------

=head2 getDefaultValue ( )

Taken from WebGUI::Form::List

=cut

sub getDefaultValue {
    my $self = shift;
    my @values = ();
    
    foreach my $value ($self->get('defaultValue')) {
        if (scalar @values < 1 && defined $value) {
            if (ref $value eq "ARRAY") {
                @values = @{$value};
            }
            else {
				$value =~ s/\r//g;
                @values = split "\n", $value;
            }
        }
    }
	return wantarray ? @values : join("\n",@values);
}

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns a boolean indicating whether the options of the list are settable. Some have a predefined set of options. This is useful in generating dynamic forms. Returns 1.

=cut

sub areOptionsSettable {
    return 1;
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
    position: absolute; 
    right: 0; 
    top: 2px; 
    cursor: pointer; 
    height: 14px; 
    width: 14px; 
    background: transparent url(extras/yui/build/assets/skins/sam/editor-sprite.gif) -1px -1122px;
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
