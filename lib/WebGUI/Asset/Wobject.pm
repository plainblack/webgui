package WebGUI::Asset::Wobject;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use CGI::Util qw(rearrange);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::AdminConsole;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Node;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Style;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::MetaData;
#use WebGUI::Asset::Wobject::WobjectProxy;

our @ISA = qw(WebGUI::Asset);

=head1 NAME

Package WebGUI::Asset::Wobject

=head1 DESCRIPTION

An abstract class for all other wobjects to extend.

=head1 SYNOPSIS

 use WebGUI::Wobject;
 our @ISA = qw(WebGUI::Wobject);

See the subclasses in lib/WebGUI/Wobjects for details.

=head1 METHODS

These methods are available from this class:

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'wobject',
                className=>'WebGUI::Asset::Wobject',
                properties=>{
                                description=>{
                                        fieldType=>'HTMLArea',
                                        defaultValue=>undef
                                        },
                                displayTitle=>{
                                        fieldType=>'yesNo',
                                        defaultValue=>1
                                        },
                                cacheTimeout=>{
                                        fieldType=>'interval',
                                        defaultValue=>60
                                        },
                                cacheTimeoutVisitor=>{
                                        fieldType=>'interval',
                                        defaultValue=>600
                                        },
				templateId=>{
					fieldType=>'template',
					defaultValue=>undef
					},
				styleTemplateId=>{
					fieldType=>'template',
					defaultValue=>undef
					},
				printableStyleTemplateId=>{
					fieldType=>'template',
					defaultValue=>undef
					}
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 confirm ( message, yesURL, [ , noURL, vitalComparison ] )

=head3 message

A string containing the message to prompt the user for this action.

=head3 yesURL

A URL to the web method to execute if the user confirms the action.

=head3 noURL

A URL to the web method to execute if the user denies the action.  Defaults back to the current page.

=head3 vitalComparison

A comparison expression to be used when checking whether the action should be allowed to continue. Typically this is used when the action is a delete of some sort.

=cut

sub confirm {
        return WebGUI::Privilege::vitalComponent() if ($_[4]);
	my $noURL = $_[3] || $_[0]->getUrl;
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= $_[1].'<p>';
        $output .= '<div align="center"><a href="'.$_[2].'">'.WebGUI::International::get(44).'</a>';
        $output .= ' &nbsp; <a href="'.$noURL.'">'.WebGUI::International::get(45).'</a></div>';
        return $output;
}


#-------------------------------------------------------------------

=head2 duplicate ( [ pageId ] )

Duplicates this wobject with a new wobject Id. Returns the new wobject Id.

B<NOTE:> This method is meant to be extended by all sub-classes.

=head3 pageId 

If specified the wobject will be duplicated to this pageId, otherwise it will be duplicated to the clipboard.

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate();
	WebGUI::MetaData::MetaDataDuplicate($self->getId, $newAsset->getId);
        return $newAsset; 
}




#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this wobject.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>WebGUI::International::get(174),
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5
                );
	$tabform->getTab("display")->template(
                -value=>$self->getValue("templateId"),
                -namespace=>$self->get("namespace"),
                -afterEdit=>'func=edit&amp;wid='.$self->get("wobjectId")."&amp;namespace=".$self->get("namespace")
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>WebGUI::International::get(1073),
		-value=>$self->getValue("styleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp}
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>WebGUI::International::get(1079),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp}
		);
	$tabform->getTab("properties")->HTMLArea(
                -name=>"description",
                -label=>WebGUI::International::get(85),
                -value=>$self->getValue("description")
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>WebGUI::International::get(895),
                -value=>$self->getValue("cacheTimeout"),
                -uiLevel=>8
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896),
                -value=>$self->getValue("cacheTimeoutVisitor"),
                -uiLevel=>8
                );
	return $tabform;
}




#-------------------------------------------------------------------
                                                                                                                             
=head2 logView ( )
              
Logs the view of the wobject to the passive profiling mechanism.                                                                                                               
=cut

sub logView {
	my $self = shift;
	if ($session{setting}{passiveProfilingEnabled}) {
		WebGUI::PassiveProfiling::add($self->get("assetId"));
# not sure what this will do in the new model
#		WebGUI::PassiveProfiling::addPage();	# add wobjects on asset to passive profile log
	}
 # disabled for the time being because it's dangerous
                #       if ($session{form}{op} eq "" && $session{setting}{trackPageStatistics} && $session{form}{wid} ne "new") {
                #               WebGUI::SQL->write("insert into pageStatistics (dateStamp, userId, username, ipAddress, userAgent, referer,
                #                       assetId, assetTitle, wobjectId, wobjectFunction) values (".time().",".quote($session{user}{userId})
                #                       .",".quote($session{user}{username}).",
                #                       ".quote($session{env}{REMOTE_ADDR}).", ".quote($session{env}{HTTP_USER_AGENT}).",
                #                       ".quote($session{env}{HTTP_REFERER}).", ".quote($session{asset}{assetId}).",
                #                       ".quote($session{asset}{title}).", ".quote($session{form}{wid}).", ".quote($session{form}{func}).")");
                #       }
	return;
}


#-------------------------------------------------------------------

=head2 processMacros ( output )

 Decides whether or not macros should be processed and returns the
 appropriate output.

=head3 output

 An HTML blob to be processed for macros.

=cut

sub processMacros {
	return WebGUI::Macro::process($_[1]);
}

#-------------------------------------------------------------------

=head2 processTemplate ( vars, namespace [ , templateId ] ) 

Returns the content generated from this template.

=head3 hashRef

A hash reference containing variables and loops to pass to the template engine.

=head3 namespace

A namespace to use for the template. Defaults to the wobject's namespace.

=head3 templateId

An id referring to a particular template in the templates table. Defaults to $self->get("templateId").

=cut

sub processTemplate {
	my $self = shift;
	my $var = shift;
	my $namespace = shift;
	my $templateId = shift || $self->get("templateId");
        my $meta = WebGUI::MetaData::getMetaDataFields($self->get("wobjectId"));
        foreach my $field (keys %$meta) {
		$var->{$meta->{$field}{fieldName}} = $meta->{$field}{value};
	}
	$var->{'controls'} = $self->getToolbar;
	my %vars = (
		%{$self->{_properties}},
		%{$var}
		);
	if (defined $self->get("_WobjectProxy")) {
		$vars{isShortcut} = 1;
		my ($originalPageURL) = WebGUI::SQL->quickArray("select url from asset where assetId=".quote($self->getId),WebGUI::SQL->getSlave);
		$vars{originalURL} = WebGUI::URL::gateway($originalPageURL."#".$self->getId);
	}
	return WebGUI::Template::process($templateId,$namespace, \%vars);
}

#-------------------------------------------------------------------

=head2 purge ( )

Removes this wobject and it's descendants from the database.

=cut

sub purge {
	my $self = shift;
	$self->SUPER::purge();
	WebGUI::MetaData::metaDataDelete($self->get("wobjectId"));
}



#-------------------------------------------------------------------

=head2 www_createShortcut ( )

Creates a shortcut (using the wobject proxy) of this wobject on the clipboard.

B<NOTE:> Should never need to be overridden or extended.

=cut

sub www_createShortcut {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my $w = WebGUI::Wobject::WobjectProxy->new({wobjectId=>"new",namespace=>"WobjectProxy"});
	$w->update({
		pageId=>'2',
		templatePosition=>1,
		title=>$self->getValue("title"),
		proxiedNamespace=>$self->get("namespace"),
		proxiedWobjectId=>$self->get("wobjectId"),
	    	bufferUserId=>$session{user}{userId},
		bufferDate=>WebGUI::DateTime::time(),
		bufferPrevId=>$session{page}{pageId}
		});
        return "";
}


#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves the default properties of any/all wobjects.

B<NOTE:> This method should only need to be extended if you need to do some special validation that you can't achieve via filters.

=cut

sub www_editSave {
	my $self = shift;
	my $output = $self->SUPER::www_editSave();
	WebGUI::MetaData::metaDataSave($self->getId);
	return $output;
}





#-------------------------------------------------------------------

sub www_view {
	my $self = shift;
	$self->logView();
	return WebGUI::Privilege::noAccess() unless $self->canView;
	my $cache;
	my $output;
        my $useCache = (
		$session{form}{op} eq "" && 
		(
			( $self->get("cacheTimeout") > 10 && $session{user}{userId} !=1) || 
			( $self->get("cacheTimeoutVisitor") > 10 && $session{user}{userId} == 1)
		) && 
		not $session{var}{adminOn}
	);
#	if ($useCache) {
 #              	$cache = WebGUI::Cache->new("asset_".$self->getId."_".$session{user}{userId});
  #         	$output = $cache->get;
#	}
	unless ($output) {
		$output = $self->view;
		my $ttl;
		if ($session{user}{userId} == 1) {
			$ttl = $self->get("cacheTimeoutVisitor");
		} else {
			$ttl = $self->get("cacheTimeout");
		}
#		$cache->set($output, $ttl) if ($useCache && !WebGUI::HTTP::isRedirect());
	}
	return WebGUI::Style::process($output,$self->get("styleTemplateId"));
}

1;

