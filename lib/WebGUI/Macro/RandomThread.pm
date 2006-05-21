package WebGUI::Macro::RandomThread;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Macro::RandomThread

=head1 DESCRIPTION

This macro displays the starting post of a random thread on the website (a "submission" in the pre-6.3 WebGUI language). The thread is chosen from a (possibly random) Collaboration System based on the parameters. The way the post is displayed is controlled by a template.

=head1 SYNOPSIS

^RandomThread( [ startURL, relatives, templateURL ] );

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------

=head2 process ( [ startURL, relatives, templateURL ] )

Main function that returns the HTML output of the macro.

=head3 startURL

URL of the asset you want to use as the starting point for finding a random CS. If omitted it defaults to 'home' (i.e. the root page of most websites). Must be a valid URL within WebGUI.

=head3 relatives

Only Collaboration Systems that are relatives of the asset in the starting point in the way specified by this parameter are used. Allowed values for this parameter are 'siblings', 'children', 'ancestors', 'self', 'descendants' and 'pedigree'. Default value is descendants. So, if the first two parameters are omitted you get a random thread from all the Collaboration Systems on your site (or more accurately: your home-root).

=head3 templateURL

URL of the template to use to display the random thread. Must be a valid URL within WebGUI. IMPORTANT NOTE: if omitted, a default debug template is used that outputs a list of all the available template variables. Since you almost certainly will not want this output in a production-environment, it makes sense to not omit this parameter.

=cut

sub process {
	my $session = shift;
	my ($startURL, $relatives, $templateURL) = @_;
	# Seed the randomizer:
	srand;

	# Set defaults (default template is set by id later):
	$startURL ||= 'home';
	$relatives ||= 'descendants';
	my $numberOfTries = 2; # try this many times in case we select a thread the user cannot view

	# Sanity check of parameters:
	my $startAsset = WebGUI::Asset->newByUrl($session, $startURL);
	unless ($startAsset) {
		$session->errorHandler->warn('Error: invalid startURL. Check parameters of macro on page '.$session->asset->get('url'));
		return '';
	}

	$relatives = lc($relatives);
	unless ( isIn($relatives, ('siblings','children','ancestors','self','descendants','pedigree')) ) {
		$session->errorHandler->warn('Error: invalid relatives specified. Must be one of siblings, children, ancestors, self, descendants, pedigree. Check parameters of macro on page '.$session->asset->get('url'));
		return '';
	}

	my $template = $templateURL ? WebGUI::Asset::Template->newByUrl($session,$templateURL) : WebGUI::Asset::Template->new($session,'WVtmpl0000000000000001');
	unless ($template) {
		$session->errorHandler->warn('Error: invalid template URL. Check parameters of macro on page '.$session->asset->get('url'));
		return '';
	}

	# Get all CS's that we'll use to pick a thread from:
	my $lineage = $startAsset->getLineage([$relatives],{includeOnlyClasses => ['WebGUI::Asset::Wobject::Collaboration']});
	unless ( scalar(@{$lineage}) ) {
		$session->errorHandler->warn('Error: no Collaboration Systems found with current parameters. Check parameters of macro on page '.$session->asset->get('url'));
		return '';
	}

	# Try to get a random thread that the user can see:
	my $randomThread = _getRandomThread($session, $lineage);
	my $i = 0;
	while ($i < $numberOfTries) {
		if($randomThread->canView()) {
			# Get all vars and process template:
			my $var = $randomThread->getTemplateVars;
			return $template->process($var);
		} else {
			# Keep trying until we find a thread we can actually view:
			$randomThread = _getRandomThread($session, $lineage);
			$i++;
		}
	}
	# If we reach this point, we had no success in finding an asset the user can view:
	$session->errorHandler->warn("Could not find a random thread that was viewable by the user ".$session->user->username." after $numberOfTries tries. Check parameters of macro on page ".$session->asset->get('url'));
	return '';
}

#-------------------------------------------------------------------

=head2 _getRandomThread ( session, lineage )

Helper function that returns a random thread.

=head3 session

A reference to the current session.

=head3 lineage

Reference to an array with lineage of Collaboration Systems to select a random thread from.

=cut

sub _getRandomThread {
	my $session = shift;
	my $lineage = shift;

	# Get random CS:
	my $randomIndex = int(rand(scalar(@{$lineage})));
	my $randomCSId = $lineage->[$randomIndex];
	my $randomCS = WebGUI::Asset->new($session,$randomCSId,'WebGUI::Asset::Wobject::Collaboration');

	# Get random thread in that CS:
	$lineage = $randomCS->getLineage(['children'],{includeOnlyClasses => ['WebGUI::Asset::Post::Thread']});
	$randomIndex = int(rand(scalar(@{$lineage})));
	my $randomThreadId = $lineage->[$randomIndex];
	return WebGUI::Asset->new($session,$randomThreadId,'WebGUI::Asset::Post::Thread');
}

1;

