package WebGUI::Form::Keywords;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Text';
use WebGUI::International;
use JSON ();
use WebGUI::Keyword;

=head1 NAME

Package WebGUI::Form::Keywords

=head1 DESCRIPTION

Creates a keywords chooser field with multiple select and autocomplete.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectList.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut

sub getDatabaseFieldType {
    return "CHAR(255)";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Asset')->get('keywords');
}

#-------------------------------------------------------------------

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
    my $session = $self->session;
    my $style = $session->style;
    my $url = $session->url;

    $style->setCss($url->extras("yui/build/autocomplete/assets/skins/sam/autocomplete.css"));
    $style->setScript($url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js"));
    $style->setScript($url->extras("yui/build/datasource/datasource-min.js"));
    $style->setScript($url->extras("yui/build/autocomplete/autocomplete-min.js"));
    $style->setRawHeadTags('<style type="text/css">.yui-skin-sam.webgui-keywords-autocomplete .yui-ac-input { position: static; width: auto }</style>');
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

Returns a keyword pull-down field. A keyword pull down provides a select list that provides name value pairs for all the keywords in the WebGUI system.  

=cut

sub toHtml {
    my $self = shift;

    my $name = $self->generateIdParameter($self->get('name'));
    my $autocompleteDiv = $self->privateName('autocomplete');
    my $pageUrl = $self->session->url->page;
    my $output
        = '<div class="yui-skin-sam webgui-keywords-autocomplete"><div>' . $self->SUPER::toHtml
        . '<div id="' . $autocompleteDiv . '"></div>'
        . '<script type="text/javascript">' . <<"END_SCRIPT" . '</script></div></div>';
(function() {
    var oDS = new YAHOO.util.XHRDataSource('$pageUrl');
    oDS.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
    oDS.responseSchema = {
        resultsList : "keywords"
    };

    var oAC = new YAHOO.widget.AutoComplete("$name", "$autocompleteDiv", oDS);
    oAC.queryDelay = 0.5;
    oAC.maxResultsDisplayed = 20;
    oAC.minQueryLength = 3;
    oAC.delimChar = [','];

    oAC.generateRequest = function(sQuery) {
        return "?op=formHelper;class=Keywords;sub=searchAsJSON;search=" + sQuery ;
    };
})();
END_SCRIPT
    return $output;
}

#-------------------------------------------------------------------

=head2 www_searchAsJSON 

Returns search results in the form variable C<search> as JSON.

=cut

sub www_searchAsJSON {
    my $session = shift;
    my $search = $session->form->param('search');
    my $keyword = WebGUI::Keyword->new($session);

    my $keywords = $keyword->findKeywords({search => $search, limit => 20});
    $session->response->content_type('application/json');

    return JSON::to_json({keywords => $keywords});
}

#-------------------------------------------------------------------

=head2 getDefaultValue 

Extends the base method to return keywords in a comma delimited string.

=cut

sub getDefaultValue {
    my $self = shift;
    return _formatKeywordsAsWanted($self->SUPER::getDefaultValue(@_));
}

#-------------------------------------------------------------------

=head2 getOriginalValue 

Extends the base method to return keywords in a comma delimited string.

=cut

sub getOriginalValue {
    my $self = shift;
    return _formatKeywordsAsWanted($self->SUPER::getOriginalValue(@_));
}

#-------------------------------------------------------------------

=head2 getValue 

Extends the base method to return keywords in a comma delimited string.

=cut

sub getValue {
    my $self = shift;
    return _formatKeywordsAsWanted($self->SUPER::getValue(@_));
}

sub _formatKeywordsAsWanted {
    my @keywords;
    if (@_ == 1 && ref $_[0] eq 'ARRAY') {
        @keywords = @{ $_[0] };
    }
    else {
        for my $param (@_) {
            for my $keyword (split /,/, $param) {
                $keyword =~ s/^\s+//;
                $keyword =~ s/\s+$//;
                push @keywords, $keyword;
            }
        }
    }
    if (wantarray) {
        return @keywords;
    }
    return join(', ', @keywords);
}

1;

