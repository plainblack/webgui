package WebGUI::Asset::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';

define assetName   => ['assetName', 'Asset_Template'];
define icon        => 'template.gif';
define tableName   => 'template';

property template => (
             fieldType       => 'codearea',
             syntax          => "html",
             default         => undef,
             trigger         => \&_template_autopack,
             label           => ['assetName', 'Asset_Template'],
             hoverHelp       => ['template description', 'Asset_Template'],
         );
sub _template_autopack {
    my ($self, $new, $old) = @_;
    return if $new eq $old;
    $self->_clear_templatePacked;
}
property isEditable => (
             noFormPost      => 1,
             fieldType       => 'hidden',
             default         => 1,
         );
property isDefault => (
             noFormPost      => 1,
             fieldType       => 'hidden',
             default         => 0,
         );
property showInForms => (
             fieldType       => 'yesNo',
             default         => 1,
             label           => ['show in forms', 'Asset_Template'],
             hoverHelp       => ['show in forms description', 'Asset_Template'],
         );
property parser => (
             noFormPost      => 1,
             fieldType       => 'selectBox',
             lazy            => 1,
             builder         => '_default_parser',
             options        => sub {
                 my $self = shift;
                 my $session = $self->session;
                 tie my %parsers, 'Tie::IxHash';
                 for my $class ( @{$session->config->get('templateParsers')} ) {
                     $parsers{$class} = $self->getParser($session, $class)->getName();
                 }
             },
         );
sub _default_parser {
    my $self = shift;
    return $self->session->config->get('defaultTemplateParser');
}
property namespace => (
             fieldType       => 'combo',
             default         => undef,
			 label           => ['namespace', 'Asset_Template'],
			 hoverHelp       => ['namespace description', 'Asset_Template'],
            options => sub {
                my $namespaces = shift->session->dbSlave->buildHashRef("select distinct(namespace) from template order by namespace");
            },
         );
property templatePacked => (
             fieldType       => 'hidden',
             noFormPost      => 1,
             lazy            => 1,
             clearer         => '_clear_templatePacked',
             builder         => '_build_templatePacked',
         );
sub _build_templatePacked {
    my $self = shift;
    my $template = $self->template;
    if (defined $template) {
        HTML::Packer::minify( \$template, {
            do_javascript       => 'shrink',
            do_stylesheet       => 'minify',
        } );
    }
    $template;
}

property usePacked => (
             fieldType       => 'yesNo',
             default         => 0,
             label           => ['usePacked label', 'Asset_Template'],
             hoverHelp       => ['usePacked description', 'Asset_Template'],
         );

property storageIdExample => (
             fieldType       => 'image',
             label           => ['field storageIdExample', 'Asset_Template'],
             hoverHelp       => ['field storageIdExample description', 'Asset_Template'],
         );

property attachmentsJson => (
    fieldType       => 'JsonTable',
    label           => [ "attachment display label", "Asset_Template" ],
    fields      => [
        {
            type            => "text",
            name            => "url",
            label           => [ 'attachment header url', 'Asset_Template' ],
            size            => '48',
        },
        {
            type            => "select",
            name            => "type",
            label           => ['attachment header type','Asset_Template'],
            options         => [
                stylesheet => ['css label','Asset_Template'],
                headScript => ['js head label','Asset_Template'],
                bodyScript => ['js body label','Asset_Template'],
            ],
        },
    ],
);

use WebGUI::International;
use WebGUI::Asset::Template::HTMLTemplate;
use WebGUI::Form;
use WebGUI::Exception;
use List::MoreUtils qw{ any };
use Tie::IxHash;
use Clone qw/clone/;
use HTML::Packer;
use JSON qw{ to_json from_json };
use Try::Tiny;

=head1 NAME

Package WebGUI::Asset::Template

=head1 DESCRIPTION

Provides a mechanism to provide a templating system in WebGUI.

=head1 SYNOPSIS

    my $template    = WebGUI::Asset::Template->newById( $session, "template id" );
    $template->setParam( param => "value", param2 => "value" );
    print $template->process;


=head1 ATTRIBUTES

#----------------------------------------------------------------------------

=head2 forms

A hash of WebGUI::FormBuilder objects to be included in this template. 
The forms' template variables will be automatically added to the L<param> hash 
when the template is processed.

Hash keys are the form's unique name, which will be prefixed to the form's
template variables

=cut

has forms => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
        addForm => 'set',
        getForm => 'get',
        deleteForm => 'delete',
        hasForms => 'count',
    },
);

#----------------------------------------------------------------------------

=head2 param

Save params in the template for later processing. This allows a template to be
passed around, adding variables until finally it is processed and output for
the user.

Use L<setParam> method to set parameters.

=cut

has param => (
    traits  => [ 'Hash' ],
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    handles => {
        setParam    => 'set',
        getParam    => 'get',
        deleteParam => 'delete',
    },
);

#----------------------------------------------------------------------------

=head2 style

Attach a style template to this template. This will allow you to return the
template from a www_ method and have the WebGUI PSGI handler do the processing.

Accepts an asset ID

=cut

has style => (
    is      => 'rw',
    isa     => 'Maybe[Str]',
);

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addAttachments ( new_attachments )

Adds attachments to this template.  New attachments are added to the end of the current set of
attachments.

=head3 new_attachments

An arrayref of hashrefs, where each hashref should have at least url and type.  All
other keys will be ignored.

=cut

sub addAttachments {
    my ($self, $new_attachments) = @_;
    my $attachments = $self->getAttachments();

    foreach my $a (@{ $new_attachments }) {
        push @{ $attachments }, {
            url  => $a->{url},
            type => $a->{type},
        };
    }
    my $json = JSON->new->encode( $attachments );
    $self->update({ attachmentsJson => $json, });
}

#-------------------------------------------------------------------

=head2 cut ( )

Extend the base method to handle cutting the User Function Style template and destroying your site.
If the current template is the User Function Style template with the Fail Safe template.

=cut

around cut => sub {
    my ( $orig, $self )    = @_;
    my $returnValue = $self->$orig();
    if ($returnValue && $self->getId eq $self->session->setting->get('userFunctionStyleId')) {
        $self->session->setting->set('userFunctionStyleId', 'PBtmpl0000000000000060');
    }
    return $returnValue;
};

#-------------------------------------------------------------------

=head2 addRevision ( )

Override the master addRevision to copy attachments

=cut

override addRevision => sub {
    my ( $self, $properties, @args ) = @_;
    my $asset = super();
    delete $properties->{templatePacked};
    return $asset;
};

#-------------------------------------------------------------------

=head2 duplicate

Subclass the duplicate method so that the isDefault flag is set to 0 on any
copy.

=cut

override duplicate => sub {
    my $self = shift;
    my $newTemplate = super();
    $newTemplate->update({isDefault => 0});
    if ( my $storageId = $self->get('storageIdExample') ) {
        my $newStorage  = WebGUI::Storage->get( $self->session, $storageId )->copy;
        $newTemplate->update({ storageIdExample => $newStorage->getId });
    }
    return $newTemplate;
};

#-------------------------------------------------------------------

=head2 exportAssetData (  )

Override to add attachments to package data

=cut

override exportAssetData => sub {
    my ( $self ) = @_;
    my $data    = $self->SUPER::exportAssetData;
    if ( $self->get('storageIdExample') ) {
        push @{$data->{storage}}, $self->get('storageIdExample');
    }
    return $data;
};

#-------------------------------------------------------------------

=head2 getAttachments ( [type] )

Returns an arrayref of hashrefs representing all attachments for this template
of the specified type (link, bodyScript, headScript).

=head3 type

If defined, will limit the attachments to this type; e.g., passing
'stylesheet' will return only stylesheets.

=cut

sub getAttachments {
	my ( $self, $type ) = @_;

    return [] if !$self->get('attachmentsJson');

    my $attachments = JSON->new->decode( $self->get('attachmentsJson') );

    # We want it all and we want it now
    if ( !$type ) {
        return $attachments;
    }

    my $output  = [];
    for my $attach ( @{$attachments} ) {
        if ( $attach->{type} eq $type ) {
            push @{$output}, $attach;
        }
    }

    return $output;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the WebGUI::FormBuilder object that will be used in generating the edit page for this asset.

=cut

override getEditForm => sub {
	my $self = shift;
	my $tabform = super();
        my $session = $self->session;
        my ( $url, $style ) = $session->quick(qw( url style ));
	my $i18n = WebGUI::International->new($session, 'Asset_Template');
        my $returnUrl = $session->form->get("returnUrl");
	$tabform->addField( "hidden",
		name=>"returnUrl",
		value=>$returnUrl,
		);

	my $previewButtons 
            = $tabform->getTab('properties')->addField( "ButtonGroup", 
                name => 'previewButtons', 
                label => $i18n->get('Preview'),
            );
        $previewButtons->addButton( 'Button' => { id => 'preview', value => $i18n->get('Preview') } );
        $previewButtons->addButton( 'Button' => { id => 'previewConfig', value => $i18n->get('Configure') } );
	my $cform = WebGUI::HTMLForm->new($session);
	$cform->yesNo(
	    id        => 'previewRaw',
	    name      => 'previewRaw',
	    label     => $i18n->get('Plain Text?'),
	    hoverHelp => $i18n->get('Plain Text hoverHelp'),
	);
	$cform->text(
	    id           => 'previewFetchUrl',
	    label        => $i18n->get('URL'),
	    hoverHelp    => $i18n->get('URL hoverHelp'),
	    defaultValue => $returnUrl,
	);
	$cform->button(
	    id        => 'previewFetch',
	    label     => $i18n->get('Fetch Variables'),
	    hoverHelp => $i18n->get('Fetch Variables hoverHelp'),
	    value     => $i18n->get('Fetch'),
	);
	$cform->codearea(
	    id        => 'previewVars',
	    label     => $i18n->get('Variables'),
	    hoverHelp => $i18n->get('Variables hoverHelp'),
	);

	$cform->hidden(id => 'previewId', value => $self->getId);
	$cform->hidden(id => 'previewGateway', value => $url->gateway);
	$tabform->getTab('properties')->addField("ReadOnly", 
            name => 'previewDialog', 
            value => qq(
	        <div id='previewConfigForm'>
	            <div class='hd'>${\ $i18n->get('Configure Preview') }</div>
	            <table class='bd'>${\ $cform->printRowsOnly }</table>
	            <div class='ft' style='margin:0 auto; text-align: center'>
	                <button id='previewConfigClose'>Close</button>
	            </div>
	        </div>
	    ),
        );

	$style->setScript($url->extras($_)) for qw(
	    yui/build/json/json-min.js
	    yui/build/container/container-min.js
	    templatePreview.js
	);

        $tabform->getTab('properties')->addField( image =>
            name        => 'storageIdExample',
            value       => $self->storageIdExample,
            label       => $i18n->get('field storageIdExample'),
            hoverHelp   => $i18n->get('field storageIdExample description'),
        );

	return $tabform;
};

#-------------------------------------------------------------------

=head2 getExampleImageUrl ( )

Get the URL to the example image of this template, if any

=cut

sub getExampleImageUrl {
    my ( $self ) = @_;
    if ( my $storageId = $self->get('storageIdExample') ) {
        my $storage = WebGUI::Storage->get( $self->session, $storageId );
        return $storage->getUrl( $storage->getFiles->[0] );
    }
    return;
}

#-------------------------------------------------------------------

=head2 getList ( session, namespace [,clause] )

Returns a hash reference containing template ids and template names of all the templates in the specified namespace.

NOTE: This is a class method.

=head3 session

A reference to the current session.

=head3 namespace

Specify the namespace to build the list for.  If no namespace is specified,
then an empty hash reference will be returned.

=head3 clause

An extra clause that can be used to further limit the list, such as "assetData.status='approved'

=cut

sub getList {
	my $class = shift;
	my $session = shift;
	my $namespace = shift;
    my $clause      = shift;
    if ($clause) {
        $clause = ' and ' . $clause;
    }
    else {
        $clause = '';
    }
	my $sql = "select asset.assetId, assetData.revisionDate from template left join asset on asset.assetId=template.assetId left join assetData on assetData.revisionDate=template.revisionDate and assetData.assetId=template.assetId where template.namespace=? and template.showInForms=1 and asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' or assetData.tagId=?)) $clause order by assetData.title";
	my $sth = $session->dbSlave->read($sql, [$namespace, $session->scratch->get("versionTag")]);
	my %templates;
	tie %templates, 'Tie::IxHash';
	TEMPLATE: while (my ($id, $version) = $sth->array) {
		my $template = eval { WebGUI::Asset::Template->newById($session,$id,$version); };
        next TEMPLATE if Exception::Class->caught();
		$templates{$id} = $template->getTitle;
	}	
	$sth->finish;	
	return \%templates;
}

#-------------------------------------------------------------------

=head2 getParser ( session, parser )

Returns a template parser object.

NOTE: This is a class method.

=head3 session

A reference to the current session.

=head3 parser

A parser class to use. Defaults to "WebGUI::Asset::Template::HTMLTemplate"

=cut

sub getParser {
    my $class = shift;
    my $session = shift;
    my $parser = shift;

    # If parser is not in the config, throw an error message
    if ( $parser && $parser ne $session->config->get('defaultTemplateParser') 
                && !any { $_ eq $parser } @{$session->config->get('templateParsers')} ) {
        WebGUI::Error::NotInConfig->throw(
            error       => "Attempted to load template parser '$parser' that is not in config file",
            module      => $parser,
            configKey   => 'templateParsers',
        );
    }
    else {
        $parser ||= $session->config->get("defaultTemplateParser") || "WebGUI::Asset::Template::HTMLTemplate";
    }

    WebGUI::Pluggable::load( $parser );
    return $parser->new($session);
}

#-------------------------------------------------------------------
#
# See the warning about using this on processVariableHeaders(). If no
# variables were captured, we'll return the empty string.

sub getVariableJson {
    my ($class, $session) = @_;
    my ($show, $vars, $json);

    return ($show = $session->stow->get('showTemplateVars'))
        && ($vars = $show->{vars})
        && ($json = eval { JSON::encode_json($vars) })
        && ($show->{startDelimiter} . $json . $show->{endDelimiter})
        or '';
}

#-------------------------------------------------------------------

=head2 importAssetCollateralData ( data )

Override to import attachments from old versions of WebGUI

=cut

override importAssetCollateralData => sub {
    my ( $self, $data, @args ) = @_;
    if ( $data->{template_attachments} ) {
        $self->update( { attachmentsJson => JSON::to_json($data->{template_attachments}) } );
    }
    return super();
};
    
#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
	$indexer->addKeywords($self->namespace);
	$indexer->setIsPublic(0);
};

#-------------------------------------------------------------------

=head2 prepare ( headerTemplateVariables )

This method sets the tags from the head block parameter of the template into the HTML head block in the style. You only need to call this method if you're using the HTML streaming features of WebGUI, like is done in the prepareView()/view()/www_view() methods of WebGUI assets.

=head3 headerTemplateVariables

A hash reference containing template variables to be processed for the head block. Typically obtained via $asset->getMetaDataAsTemplateVariables.

=cut

sub prepare {
	my $self = shift;
	my $vars = shift;
	$self->{_prepared} = 1;

	my $sent = $self->session->stow->get('templateHeadersSent');
	unless ($sent) {
		$self->session->stow->set('templateHeadersSent', $sent = []);
	}

	my $id   = $self->getId;
	# don't send head block if we've already sent it for this template
	return if $id ~~ $sent;

	my $session      = $self->session;
	my ($db, $style) = $session->quick(qw(db style));
	my $parser       = $self->getParser($session, $self->parser);
	my $headBlock    = $parser->process($self->getExtraHeadTags, $vars);

	$style->setRawHeadTags($headBlock);

	foreach my $sheet ( @{ $self->getAttachments('stylesheet') } ) {
		my %props = ( type => 'text/css', rel => 'stylesheet' );
		$style->setLink($sheet->{url}, \%props);
	}

	my $doScripts = sub {
		my ($type, $body) = @_;
		foreach my $script ( @{ $self->getAttachments($type) } ) {
			my %props = ( type => 'text/javascript' );
			$style->setScript($script->{url}, \%props, $body);
		}
	};

	$doScripts->('headScript');
	$doScripts->('bodyScript', 1);

	push(@$sent, $id);
}


#-------------------------------------------------------------------

=head2 process ( vars )

Evaluate a template replacing template commands for HTML.  If the internal property templatePacked
is set to true, the packed, minimized template will be used.  Otherwise, the original template
will be used.

Will also process the style template attached to this template

=head3 vars

A hash reference containing template variables and loops. Automatically includes the entire WebGUI session.

These parameters will override any parameters set by L<param> and L<forms>

=cut

sub process {
	my $self    = shift;
	my $vars    = shift;
    my $session = $self->session;

    if ($self->state =~ /^trash/) {
        my $i18n = WebGUI::International->new($session, 'Asset_Template');
        $session->log->warn('process called on template in trash: '.$self->getId
            .'. The template was called through this url: '.$session->asset->url);
        return $session->isAdminOn ? $i18n->get('template in trash') : '';
    }
    elsif ($self->state =~ /^clipboard/) {
        my $i18n = WebGUI::International->new($session, 'Asset_Template');
        $session->log->warn('process called on template in clipboard: '.$self->getId
            .'. The template was called through this url: '.$session->asset->url);
        return $session->isAdminOn ? $i18n->get('template in clipboard') : '';
    }

    # Merge the forms with the prepared vars
    if ( $self->hasForms ) {
        for my $name ( keys %{$self->forms} ) {
            my $form = $self->forms->{$name};
            $self->setParam( %{$form->toTemplateVars( "${name}_" )} );
        }
    }

    # Merge the passed-in vars with the prepared vars
    if ( keys %$vars > 0 ) { # can't call setParam with an empty hash
        $self->setParam( %$vars );
    }


    # Return a JSONinfied version of vars if JSON is the only requested content type.
    if ( defined $session->request && $session->request->header('Accept') eq 'application/json' ) {
       $session->response->content_type( 'application/json' );
       return to_json( $self->param );
    }

    my $stow = $session->stow;
    my $show = $stow->get('showTemplateVars');
    if ( $show && $show->{assetId} eq $self->getId && $self->canEdit ) {
        # This will never be true again, cause we're getting rid of assetId
        delete $show->{assetId};
        $show->{vars} = $vars;
        $stow->set( showTemplateVars => $show );
    }

	$self->prepare unless ($self->{_prepared});
    my $parser      = $self->getParser($session, $self->parser);
    my $template    = $self->usePacked
                    ? $self->templatePacked
                    : $self->template
                    ;
    my $output;
    eval { $output = $parser->process($template, $self->param); };
    if (my $e = Exception::Class->caught) {
        $session->log->error(sprintf "Error processing template: %s, %s, %s", $self->getUrl, $self->getId, $e->error);
        my $i18n = WebGUI::International->new($session, 'Asset_Template');
        $output = sprintf $i18n->get('template error').$e->error, $self->getUrl, $self->getId;
    }

    # Process the style template
    if ( $self->style ) {
        $output = $self->session->style->process( $output, $self->style );
    }

	return $output;
}

#-------------------------------------------------------------------

# Used for debugging and the template test renderer.

# WARNING: Please do not rely on this behavior. It's a bit of a hack, and
# should not be considered part of the core API. Eventually, we will have
# introspectable template objects so that you can more easily (and
# efficiently) get this kind of information.

# If the first value for the 'X-Webgui-Template-Variables' header is our
# assetId, then in addition to processing the template, append add a json
# representation of our template variables to the response. The headers
# "X-Webgui-Template-Variables-Start" and "X-Webgui-Template-Variables-End"
# will contain the delimiters for the start and end of this content so that
# the user agent (who had to have stuck the header in in the first place) can
# parse it out.  The delimiters will make the whole thing look like an xml
# comment (<!-- ... -->) just in case.

# We would just send the vars in the header, but different webservers have
# different limits on header field size and it's impossible to say whether our
# data will fit inside them or not.

# This is intended to be called earlier in the request cycle (in the Content
# URL handler) so that the headers get sent before any chunked content starts
# being set up.  We set the stow here and check it during process() to see
# whether we need to include the delimited json. Later on, Content will call
# call getVariableJson to get the results.

{
    my $head = 'X-Webgui-Template-Variables';
    my @chr  = ('0'..'9', 'a'..'z', 'A'..'Z');

    sub processVariableHeaders {
        my ($class, $session) = @_;
        my $r = $session->request;
        if (my $id = $r->headers->header($head)) {
            my $rnd = join('', map { $chr[int(rand($#chr))] } (1..32));
            my $out = {};
            my $st  = "<!-- $rnd ";
            my $end = " $rnd -->";
            $out->{"$head-Start"} = $st;
            $out->{"$head-End"}   = $end;
            $session->response->headers( $out );
            $session->stow->set(
                showTemplateVars => {
                    assetId        => $id,
                    startDelimiter => $st,
                    endDelimiter   => $end,
                }
            );
        }
    }
}

#-------------------------------------------------------------------

=head2 processEditForm 

Extends the master class to handle template parsers, namespaces and template attachments.

=cut

override processEditForm => sub {
	my $self = shift;
	super();
        my $session = $self->session;
    # TODO: Perhaps add a way to check template syntax before it blows stuff up?
    my %data;
    my $needsUpdate = 0;
	if ($self->parser ne $self->session->form->process("parser","className") && ($self->session->form->process("parser","className") ne "")) {
        $needsUpdate = 1;
		if ($self->session->form->process("parser","className") ~~ $self->session->config->get("templateParsers") ) {
			%data = ( parser => $self->session->form->process("parser","className") );
		} else {
			%data = ( parser => $self->session->config->get("defaultTemplateParser") );
		}
	}
	if ($self->session->form->process("namespace") eq 'style') {
        $needsUpdate = 1;
        $data{extraHeadTags} = '';
    }

    if ($needsUpdate) {
        $self->update(\%data);
    }

    ### Template attachments
    $self->update({ attachmentsJson => $session->form->process( 'attachmentsJson', 'JsonTable' ), });

    return;
};

#-------------------------------------------------------------------

=head2 processRaw ( session, template, vars [ , parser ] )

Process an arbitrary template string. This is a class method.

=head3 session

A reference to the current session.

=head3 template

A scalar containing the template text.

=head3 vars

A hash reference containing template variables to add to the existing params.

=head3 parser

Optionally specify the class name of a parser to use.

=cut

sub processRaw {
	my $class = shift;
	my $session = shift;
	my $template = shift;
	my $vars = shift;
	my $parser = shift;
	return $class->getParser($session,$parser)->process($template, $vars);
}

#-------------------------------------------------------------------

=head2 purge ( )

Extend the base method to handle purging the User Function Style template and destroying your site.
If the current template is the User Function Style template with the Fail Safe template.

=cut

around purge => sub {
	my $orig = shift;
	my $self = shift;
    my $session = $self->session;
    my $assetId = $self->assetId;
    my $returnValue = $self->$orig(@_);
    if ($returnValue && $assetId eq $session->setting->get('userFunctionStyleId')) {
        $session->setting->set('userFunctionStyleId', 'PBtmpl0000000000000060');
    }
	return $returnValue;
};

#-------------------------------------------------------------------

=head2 removeAttachments ( urls )

Removes attachments. 

=head3 urls

C<urls> is an arrayref of URLs to remove. If C<urls>
is not defined, will remove all attachments for this revision.

=cut

sub removeAttachments {
    my ($self, $urls) = @_;

    my @attachments = ();

    if ($urls) {
        @attachments = grep { ! ($_->{url} ~~ $urls) } @{ $self->getAttachments() };
    }

    my $json = JSON->new->encode( \@attachments );
    $self->update({ attachmentsJson => $json, });
}

#----------------------------------------------------------------------------

=head2 replaceParamName ( oldName, newName )

Replace all instances of oldName with newName. Updates the template instance with
the new names and returns the new template data. This is only to be used to alter
the names of template parameters.

=cut

sub replaceParamName {
    my ( $self, $oldName, $newName ) = @_;

    # We're lazy here. If this fails, we'll add more checks, or call out to the parser
    my $template    = $self->template;
    $template =~ s/$oldName/$newName/g;
    $self->template( $template );
    return $template;
}

#-------------------------------------------------------------------

=head2 www_edit 

Hand draw this form so that a warning can be displayed to the user when editing a
default template.

=cut

override www_edit => sub {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
    my $session = $self->session;
    my $form    = $session->form;
    my $url     = $session->url;
    my $i18n    = WebGUI::International->new($session, "Asset_Template");
    my $template = super();

    # Add an unfriendly warning message if this is a default template
    if ( $self->get( 'isDefault' ) ) {
        # Get a proper URL to make the duplicate
        my $duplicateUrl = $self->getUrl( "func=editDuplicate" );
        if ( $form->get( "proceed" ) ) {
            $duplicateUrl = $url->append( $duplicateUrl, "proceed=" . $form->get( "proceed" ) );
            if ( $form->get( "returnUrl" ) ) {
                $duplicateUrl = $url->append( $duplicateUrl, "returnUrl=" . $form->get( "returnUrl" ) );
            }
        }

        my $errors  = $template->getParam('errors') || [];
        my $message .= q{<p>}
                . $i18n->get( "warning default template" )
                . q{</p><p>}
                . sprintf( q{<a href="} . $duplicateUrl . q{">%s</a>}, $i18n->get( "make duplicate label" ) )
                . q{</p>}
                ;
        push @$errors, $message;
        $template->setParam( 'errors' => $errors );
    }

    return $template;
};

#-------------------------------------------------------------------

=head2 www_goBackToPage 

If set, redirect the user to the URL set by the form variable C<returnUrl>.  Otherwise, it returns
the user back to the site.

=cut

sub www_goBackToPage {
	my $self = shift;
	$self->session->response->setRedirect($self->session->form->get("returnUrl")) if ($self->session->form->get("returnUrl"));
	return undef;
}

#----------------------------------------------------------------------------

=head2 www_editDuplicate

Make a duplicate of this template and edit that instead.

=cut

sub www_editDuplicate {
    my $self        = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;

    my $session     = $self->session;
    my $form        = $self->session->form;

    my $newTemplate = $self->duplicate;
    $newTemplate->update( { 
        isDefault   => 0, 
        title       => $self->get( "title" ) . " (copy)",
        menuTitle   => $self->get( "menuTitle" ) . " (copy)",
    } );

    # Make the asset that originally invoked edit template use the newly created asset.
    if ( $self->session->form->get( "proceed" ) eq "goBackToPage" ) {
        if ( my $asset = WebGUI::Asset->newByUrl( $session, $form->get( "returnUrl" ) ) ) {
            # Find which property we should set by comparing namespaces and current values
            DEF: for my $def ( @{ $asset->definition( $self->session ) } ) {
                my $properties  = $def->{ properties };
                PROP: for my $prop ( keys %{ $properties } ) {
                    next PROP unless lc $properties->{ $prop }->{ fieldType } eq "template";
                    next PROP unless $asset->get( $prop ) eq $self->getId;
                    if ( $properties->{ $prop }->{ namespace } eq $self->get( "namespace" ) ) {
                        my $tag = WebGUI::VersionTag->getWorking( $session );
                        $asset->addRevision( { $prop => $newTemplate->getId, tagId => $tag->getId, status => "pending" } );
                        $asset->setVersionLock;

                        # Auto-commit our revision if necessary
                        # TODO: This needs to be handled automatically somehow...
                        my $status = WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
                        ##get a fresh object from the database
                        if ($status eq 'commit') {
                            $newTemplate = $newTemplate->cloneFromDb;
                        }
                        last DEF;
                    }
                }
            }
        }
    }
    
    return $newTemplate->www_edit;
}

#-------------------------------------------------------------------

=head2 www_manage 

If trying to use the assetManager on this asset, push them back to managing the
template's parent instead.

=cut

sub www_manage {
	my $self = shift;
	#takes the user to the folder containing this template.
	return $self->getParent->www_manageAssets;
}

#-------------------------------------------------------------------

=head2 www_preview

Rendes this template with the given variables (posted as JSON)

=cut

sub www_preview {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient unless $self->canEdit;

    my $form = $session->form;
    my $http = $session->http;

    try {
        my $output = $self->processRaw(
            $session,
            $form->get('template'),
            from_json($form->get('variables')),
            $form->get('parser'),
        );
        if ($form->get('plainText')) {
            $http->setMimeType('text/plain');
        }
        elsif ($output !~ /<html>/) {
            $output = $session->style->userStyle($output);
        }
        return $output;
    } catch {
        $http->setMimeType('text/plain');
        $_[0];
    }
}

#-------------------------------------------------------------------

=head2 www_view 

Override the default behavior.  When a template is viewed, it redirects you
to viewing the template's container instead.

=cut

sub www_view {
	my $self = shift;
	return $self->session->asset($self->getContainer)->www_view;
}


__PACKAGE__->meta->make_immutable;

1;
