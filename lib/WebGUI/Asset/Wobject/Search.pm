package WebGUI::Asset::Wobject::Search;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base "WebGUI::Asset::Wobject";
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Paginator;

=head1 NAME

Package WebGUI::Asset::Wobject::Search

=head1 DESCRIPTION

Asset used to search WebGUI content.

=head2 definition ( $class, $definition )

This method defines all properties of a Search and is used to autogenerate most methods.

=head3 $class

$class is used to make sure that inheritance works on Assets and Wobjects.

=head3 $definition

Definition hashref from subclasses.

=head3 Search specific properties

=over 4

=item templateId

ID of a tempate from the Search namespace to display the search results.

=back

=cut

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Search');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000200',	
				tab=>"display",
				namespace=>"Search",
                		hoverHelp=>$i18n->get('search template description'),
                		label=>$i18n->get('search template')
				},
			searchRoot => {
				fieldType=>"asset",
				defaultValue=>$session->setting->get("defaultPage"),
				tab=>"properties",
				hoverHelp=>$i18n->get("search root description"),
				label=>$i18n->get('search root')
				}
			classLimiter => {
				fieldType => "checkList",
				defaultValue => [],
				tab=>"properties",
				hoverHelp=>$i18n->get("class limiter description"),
				label=>$i18n->get("class limiter"),
				options=>$session->db->buildHashRef("select distinct()")
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'search.gif',
		autoGenerateForms=>1,
		tableName=>'search',
		className=>'WebGUI::Asset::Wobject::Search',
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 view ( )

view defines all template variables, processes the template and
returns the output.

=cut

sub view {
	my $self = shift;
	my %var;
	return $self->processTemplate(\%var, $templateId);
}

1;

