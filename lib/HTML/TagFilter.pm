package HTML::TagFilter;
use strict;
use warnings;
use base qw(HTML::Parser);
use vars qw($VERSION);

$VERSION = '0.07';  # $Date: 2001/10/25 $

=head1 NAME

HTML::TagFilter - An HTML::Parser-based selective tag remover

=head1 SYNOPSIS

    use HTML::TagFilter;
    my $tf = new HTML::TagFilter;
    my $clean_html = $tf->filter($dirty_html);
    
    # or
    
    my $tf = HTML::TagFilter->new(
        allow=>{...}, 
        deny=>{...}, 
        log_rejects => 1, 
        strip_comments => 1, 
        echo => 1,
    );
    
    $tf->parse($some_html);
    $tf->parse($more_html);
    my $clean_html = $tf->output;
    my $cleaning_summary = $tf->report;
    my @tags_removed = $tf->report;
    my $error_log = $tf->error;

=head1 DESCRIPTION

The tentatively titled HTML::TagFilter is a subclass of HTML::Parser with a single purpose: it will remove unwanted html tags and attributes from a piece of text. It can act in a more or less fine-grained way - you can specify permitted tags, permitted attributes of each tag, and permitted values for each attribute in as much detail as you like.

Tags which are not allowed are removed. Tags which are allowed are trimmed down to only the attributes which are allowed for each tag. It is possible to allow all or no attributes from a tag, or to allow all or no values for an attribute, and so on.

TagFilter doesn't do anything to or with the text between bits of markup: it's only interested in the tags.

The original purpose for this was to screen user input. In that setting you'll often find that just using:

    my $tf = new HTML::TagFilter;
    put_in_database($tf->filter($my_text));

will do. However, it can also be used for display processes (eg text-only translation) or cleanup (eg removal of old javascript). In those cases you'll probably want to override the default rule set with a small number of denial rules. 

    my $filter = HTML::TagFilter->new(deny => {img => {'all'}});
    print $tf->filter($my_text);

Will strip out all images, for example, but leave everything else untouched.

nb (faq #1) the filter only removes the tags themselves: it doesn't affect the text between them.

=head1 CONFIGURATION: RULES

Creating the rule set is fairly simple. You have three options:

=head2 use the defaults

which will produce safe but still formatted html, without images, tables, javascript or much else apart from inline text formatting and links.

=head2 selectively override the defaults

use the allow_tags and deny_tags methods to pass in one or more tag settings. eg:

    $filter->allow_tags({ p => { class=> ['lurid','sombre','plain']} });

will mean that all attributes other than class="lurid|sombre|plain" will be removed from <p> tags. See below for more about specifying rules.

=head2 supply your own configuration

To override the defaults completely, supply the constructor with some rules:

    my $filter = HTML::TagFilter->new( allow=>{ p => { class=> ['lurid','sombre','plain']} });

Only the rules you supply in this form will be applied. You can achieve the same thing after construction by first clearing the rule set:

    my $filter = HTML::TagFilter->new();
    $filter->allow_tags();
    $filter->allow_tags({ p => { align=> ['left','right','center']} });

Future versions are intended to offer a more sophisticated rule system, allowing you to specify combinations of attributes, ranges for values and generally match names in a more fuzzy way. 

I'm also considering adding a set of standard filters for, eg, image or javascript removal. I'd be glad to hear suggestions.

The simple hash interface will continue to work for the foreseeable future, though.

=head1 CONFIGURATION: BEHAVIOURS

There are currently three switches that will change the behaviour of the filter. They're supplied at construction time alongside any rules you care to specify. All of them default to 'off'.

    my $tf = HTML::TagFilter->new(
        log_rejects => 1,
        strip_comments => 1,
        echo => 1,
    );
    
=over 4

=item log_rejects

Set log to something true and the filter will keep a detailed log of all the tags it removes. The log can be retrieved by calling report(), which will return a summary in scalar context and a detailed AoH in list.

=item echo

Set echo to 1, or anything true, and the output of the filter will be sent straight to STDOUT. Otherwise the filter is silent until you call output().

=item strip_comments

Set strip_comments to 1 and comments will be stripped. If you don't, they won't.

=back

=head1 RULES

Each element is tested as it is encountered, in two stages:

=over 4

=item tag filter

Just checks that this tag is permitted, and blocks the whole thing if not. Applied to both opening and closing tags.

=item attribute filter

Any tag that passes the tag filter will remain in the text, but the attribute filter will strip out of it any attributes that are not permitted, or which have values that are not permitted for that tag/attribute combination.

=back

=head2 format for rules

There are two kinds of rule: permissions and denials. They work as you'd expect, and can coexist, but they're not quite symmetrical. Denial rules are intended to complement permission rules, so that they can provide a kind of compound 'unless'.

* If there are any 'permission' rules, then everything that doesn't satisfy any of them is eliminated.

* If there are any 'deny' rules, then anything that satisfies any of them is eliminated.

* If there are both denial and permission rules, then everything either satisfies a denial rule or fails to satisfy any of the permission rules is eliminated.

* If there is neither kind, we strip out everything just to be on the safe side.

The two most likely setups are 

1. a full set of permission rules and maybe a couple of denial rules to eliminate pet hates.

2. no permission rules at all and a small set of denial rules to remove particular tags.

Rules are passed in as a HoHoL:

    { tag name->{attribute name}->[valuelist] }

There are three reserved words: 'any and 'none' stand respectively for 'anything is permitted' and 'nothing is permitted', or if in denial: 'anything is removed' and 'nothing is removed'. 'all' is only used in denial rules and it indicates that the whole tag should be stripped out: see below for an explanation and some mumbled excuses.

For example:

    $filter->allow_tags({ p => { any => [] });

Will permit <p> tags with any attributes. For clarity's sake it may be shortened to:

    $filter->allow_tags({ p => { 'any' });

but note that you'll get a warning about the odd number of hash elements if -w is on, and in the absence of the => the quotes are required. And

    $filter->allow_tags({ p => { none => [] });

Will allow <p> tags to remain in the text, but all attributes will be removed. The same rules apply at all levels in the tag/attribute/value hierarchy, so you can say things like:

    $filter->allow_tags({ any => { align => [qw(left center right)] });
    $filter->allow_tags({ p => { align => ['any'] });

=head2 examples

To indicate that a link destination is ok and you don't mind what value it takes:

    $filter->allow_tags({ a => { 'href' } });

To limit the values an attribute can take:

    $filter->allow_tags({ a => { class => [qw(big small middling)] } });

To clear all permissions:

    $filter->allow_tags({});

To remove all onClicks from links but allow all targets:

    $filter->allow_tags({ a => { onClick => ['none'], target => [], } });

You can combine allows and denies to create 'unless' rules:

    $filter->allow_tags({ a => { any => [] } });
    $filter->deny_tags({ a => { onClick => [] } });

Will remove only the onClick attribute of a link, allowing everything else through. If this was your only purpose, you could achieve the same thing just with the denial rule and an empty permission set, but if there's other stuff going on then you probably need this combination.

=head2 order of application

denial rules are applied first. we take out whatever you specify in deny, then take out whatever you don't specify in allow, unless the allow set is empty, in which case we ignore it. If both sets are empty, no tags gets through.

(We prefer to err on the side of less markup, but I expect this will be configurable soon.)

=head2 oddities

Only one deliberate one, so far. The main asymmetry between permission and denial rules is that from

    allow_tags->{ p => {...}}

it follows that p tags are permitted, but the reverse is not true: 

    deny_tags->{ p => {...}}

doesn't imply that p tags are removed, just that the relevant attributes are removed from them. If you want to use a denial rule to eliminate a whole tag, you have to say so explicitly:

    deny_tags->{ p => {'all'}}

will remove every <p> tag, whereas

    deny_tags->{ p => {'any'}}

will just remove all the attributes from <p> tags. Not very pretty, I know. It's likely to change, but probably not until after we've invented a system for supplying rules in a more readable format.

=cut

my $errstr;

my $allowed_by_default = {
    h1 => { none => [] },
    h2 => { none => [] },
    h3 => { none => [] },
    h4 => { none => [] },
    h5 => { none => [] },
    p => { none => [] },
    a => { href => [], name => [], target => [] },
    br => { clear => [qw(left right all)] },
    ul =>{ type => [] },
    li =>{ type => [] },
    ol => { none => [] },
    em => { none => [] },
    i => { none => [] },
    b => { none => [] },
    tt => { none => [] },
    pre => { none => [] },
    code => { none => [] },
    hr => { none => [] },
    blockquote => { none => [] },
    img => { src => [], height => [], width => [], alt => [], align => [] },
    any => { align => [qw(left right center)]  },
};

my $denied_by_default = {
    blink => { all => [] },
    marquee => { all => [] },
    any => { style => [], class => [], onMouseover => [], onClick => [], onMouseout => [], },
};

sub new {
    my $class = shift;
    my $config = {@_};
    
    my $filter = $class->SUPER::new(api_version => 3);

    $filter->SUPER::handler(start => "_filter_start", 'self, tagname, attr');
    $filter->SUPER::handler(end =>  "_filter_end", 'self, tagname');
    $filter->SUPER::handler(default => "_add_to_output", "self, text");
    $filter->SUPER::handler(comment => "") if delete $config->{strip_comments};

    $filter->{_allows} = {};
    $filter->{_denies} = {};
    $filter->{_settings} = {};
    $filter->{_log} = ();
    $filter->{_error} = ();

    $config->{allow} ||= $allowed_by_default;
    $config->{deny} ||= $denied_by_default;

    $filter->allow_tags(delete $config->{allow});
    $filter->deny_tags(delete $config->{deny});
    
    $filter->{_settings}->{log} = 1 if delete $config->{log_rejects};
    $filter->{_settings}->{echo} = 1 if delete $config->{echo};
    
    $filter->_log_error("[warning] ignored config field: $_") for keys %$config;
    
    return $filter;
}

=head1 METHODS

=over 4

=item HTML::TagFilter->new();

If called without parameters, loads the default set. Otherwise loads the rules you supply. For the rule format, see above.

=item $tf->filter($html);

Exactly equivalent to:

    $tf->parse($html);
    $tf->output();

but more useful, because it'll fit in a oneliner. eg:

    print $tf->filter( $pages{$_} ) for keys %pages;
    
Note that calling filter() will clear anything that was waiting in the output buffer, and will clear the buffer again when it's finished. it's meant to be a one-shot operation and doesn't co-operate well. use parse() and output() if you want to daisychain.

=back

=cut

sub filter {
    my ($filter,$text) = @_;
    $filter->{output} = '';
    $filter->parse($text);
    return $filter->output() unless $filter->{_settings}->{echo};
}

=over 4

=item $filter->parse($text);

The parse method is inherited from HTML::Parser, but most of its normal behaviours are subclassed here and the output they normally print is kept for later. The other configuration options that HTML::Parser normally offers are not passed on, at the moment, nor can you override the handler definitions in this module.

=item $filter->output()

calls $filter->eof, returns and clears the output buffer. This will conclude the processing of your text, but you can of course pass a new piece of text to the same parser object and begin again.

=item $filter->report()

if called in list context, returns the array of rejected tag/attribute/value combinations. 
in scalar context returns a more or less readable summary. returns () if logging not enabled. Clears the log.

=back

=cut

sub output {
    my $filter = shift;
    $filter->eof;
    my $output = $filter->{output};
    $filter->_log_error("[warning] no output from filter") unless $output;
    $filter->{output} = '';
    return $output;
}

sub report {
    my $filter = shift;
    return () unless defined $filter->{_log};
    my @rejects = @{ $filter->{_log} };
    $filter->{_log} = ();
    return @rejects if wantarray;

    my $report = "the following tags and attributes have been stripped:\n";
    for (@rejects) {
        if ($_->{attribute}) {
            $report .= $_->{attribute} . '="' . $_->{value} . '" from the tag &lt;' . $_->{tag} . "&gt;\n";
        } else {
            $report .= '&lt;' . $_->{tag} . "&gt;\n";
        }
    }
    return $report;
}

# _filter_start(): the designated handler for start tags: tests them against the _tag_ok() function
# and then, if they pass, each of their attributes against the attribute_ok() function. Anything that
# fails either test is removed, and the remainder if any passed to output.

sub _filter_start {
    my ($filter, $tagname, $attr) = @_;
    if ($filter->_tag_ok(lc($tagname))) {
        for (keys %$attr) {
            unless ($filter->_attribute_ok(lc($tagname), lc($_), lc($$attr{$_}))) {
                   $filter->_log_denied({ tag => $tagname, attribute => $_, value => $$attr{$_} }) if $filter->{_settings}->{log};
                delete $$attr{$_};
            }
        }
        my $filtered_tag = "<$tagname" . join('',map(qq| $_="$$attr{$_}"|, keys %$attr)) . ">";
        $filter->_add_to_output($filtered_tag);
    } else {
        $filter->_log_denied({tag => $tagname}) if $filter->{_settings}->{log};
    }
}

# _filter_end(): the designated handler for end tags: tests them against the _tag_ok() function
# and passes them to output if they're acceptable.

sub _filter_end {
    my ($filter, $tagname) = @_;
    $filter->_add_to_output("</$tagname>") if ($filter->_tag_ok(lc($tagname)));
}

sub _add_to_output {
    my $filter = shift;
    if ($filter->{_settings}->{echo}) {
        print $_[0];
    } else {
        $filter->{output} .= $_[0];
    }
}

sub _log_denied {
    my ($filter, $bad_tag) = @_;
    push @{ $filter->{_log} } , $bad_tag;
}

sub _tag_ok {
    my ($filter, $tagname) = @_;
    return 0 unless $filter->{_allows} || $filter->{_denies};
    return 0 if $filter->_check('_denies', 'attributes', $tagname, 'all');
    return 1 if $filter->_check('_allows', 'tags', $tagname);
    return 0;
}

sub _attribute_ok {
    my ($filter, $tagname, $attribute, $value) = @_;    

    return 0 if $filter->_check('_denies','values', $tagname, $attribute, 'any',);
    return 0 if $filter->_check('_denies','values', $tagname, $attribute, $value,);
    return 0 if $filter->_check('_denies','attributes', $tagname, 'any',);

    return 1 if $filter->_check('_allows','values', 'any', $attribute, 'any',);
    return 1 if $filter->_check('_allows','values', 'any', $attribute, $value,);

    return 1 if $filter->_check('_allows','attributes', $tagname, 'any',);
    return 1 if $filter->_check('_allows','values', $tagname, $attribute, 'any',);
    return 1 if $filter->_check('_allows','values', $tagname, $attribute, $value,);
    return 0;
}

# _check(): a private function to test for a value buried deep in a HoHoHo 
# without cluttering the place up with autovivifications.

sub _check {
    my $filter = shift;
    my $field = shift;
    my @russian_dolls = @_;
    unless (@russian_dolls) {
        $filter->_log_error("[warning] _check: no keys supplied");
        return 0;
    }
    my $deepref = $filter->{$field};
    for (@russian_dolls) {
        unless (ref $deepref eq 'HASH') {
            $filter->_log_error("[error] _check: deepref not a hashref");
            return 0;
        }
        return 0 unless $deepref->{$_};
        $deepref = $deepref->{$_};
    }
    return 1;
}

=over 4

=item $filter->allow_tags($hashref)

Takes a hashref of permissions and adds them to what we already have, replacing at the tag level where rules are already defined. In other words, you can add a tag to the existing set, but to add an attribute to an existing tag you have to specify the whole set of attribute permissions.  If no rules are sent, this clears the permission rule set.

=item $filter->deny_tags($hashref)

likewise but sets up (or clears) denial rules.

=back

=cut

sub allow_tags {
    my ($filter, $tagset) = @_;
    if ($tagset) {
        $filter->_configurise('_allows',$tagset);
    } else {
        $filter->{_allows} = {};
    }
    return 1;
}

sub deny_tags {
    my ($filter, $tagset) = @_;
   if ($tagset) {
        $filter->_configurise('_denies',$tagset);
    } else {
        $filter->{_denies} = {};
    }
    return 1;
}

# _configurise(): a private function that translates input rules into
# the bushy HoHoHo's we're using for lookup.

sub _configurise {
    my ($filter, $field, $tagset) = @_;

     unless (ref $tagset eq 'HASH') {
         $filter->_log_error("[error] _configurise: supplied rules not a hashref");
         return ();
     }
     $filter->_log_error("[warning] _configurise: supplied rule set empty") unless keys %$tagset;

    foreach my $tag (keys %$tagset) {
        $filter->{$field}->{tags}->{$tag} = 1;
        foreach my $att (keys %{ $tagset->{$tag} }) {
            $filter->{$field}->{attributes}->{$tag}->{$att} = 1;
            $filter->{$field}->{values}->{$tag}->{$att}->{any} = 1
            	unless defined( $tagset->{$tag}->{$att} ) && @{ $tagset->{$tag}->{$att} };
            foreach my $val (@{ $tagset->{$tag}->{$att} }) {
                $filter->{$field}->{values}->{$tag}->{$att}->{$val} = 1;
            }
        }
    }
}

=over 4

=item $filter->allows()

Returns the full set of permissions as a HoHoho. Can't be set this way: ust a utility function in case you want to either display the rule set, or send it back to allow_tags in a modified form.

=item $filter->denies()

Likewise for denial rules.

=back

=cut

sub allows {
    my $filter = shift;
    return $filter->{_allows};
}

sub denies {
    my $filter = shift;
    return $filter->{_denies};
}

=over 4

=item $filter->error()

Returns an error report of currently dubious usefulness.

=back

=cut

sub error {
    my $filter = shift;
    return "HTML::TagFilter errors:\n" . join("\n", @{$filter->{_error}}) if $filter->{_error};
	return '';
}

# _log_error: append a message to the error log

sub _log_error {
    my $filter = shift;
    push @{ $filter ->{_error} } , @_;
}

# handler() exists here only to admonish people who try to use this module as they would
# HTML::Parser. The handler definitions in new() use SUPER::handler() to get around this.

sub handler {
    die("You can't set handlers for HTML::TagFilter. Perhaps you should be using HTML::Parser directly?");
}

1;

=head1 TO DO

More sanity checks on incoming rules

Simpler rule-definition interface

Complex rules. The long term goal is that someone can supply a rule like "remove all images where height or width is missing" or "change all font tags where size="2" to <span class="small">.

Which will be hard. For a start, HTML::Parser does not, as far as I know, see paired start and close tags, which would be required for conditional actions.

An option to preserve tag order (for readability to humans. thanks to mr aas for the tip.)

An option to speed up operations by working only at the tag level and using HTML::Parser's built-in screens.

Some tests.

=head1 REQUIRES

HTML::Parser

=head1 SEE ALSO

L<HTML::Parser>

=head1 AUTHOR

William Ross, will@spanner.org

=head1 COPYRIGHT

Copyright 2001 William Ross

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
