package WebGUI::Operation::Help;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::Macro;
use WebGUI::Utility;
use WebGUI::TabForm;

=head1 NAME

Package WebGUI::Operation::Help

=head1 DESCRIPTION

Handles displaying WebGUI's internal help to the user as an operation.

=cut

#-------------------------------------------------------------------

=head2 _loadHelp ( $session, $helpPackage )

Safely load's the Help file for the requested helpPackage if it hasn't
been already and logs errors during the load.

=cut

sub _loadHelp {
	my $session = shift;
	my $helpPackage = shift;
	if (defined *{"$helpPackage\::HELP"}) {  ##Symbol table lookup
		our $table;
		*table = *{"$helpPackage\::HELP"};  ##Create alias into symbol table
		return $table;  ##return whole hashref
	}
	$session->errorHandler->warn("cache miss for $helpPackage");
	my $load = sprintf 'use %-s; $%-s::HELP', $helpPackage, $helpPackage;
	my $help = eval($load);
	if ($@) {
		$session->errorHandler->error("Help failed to compile: $helpPackage. ".$@);
		return {};
	}
	return $help;
}

#-------------------------------------------------------------------

=head2 _process ( $session, $cmd, $key )

Do all post processing for an entry in a freshly loaded help file.
Resolve the related key, add a default isa key if it is missing,
and set the __PROCESSED flag to prevent processing entries twice.

=cut

sub _process {
	my ($session, $helpEntry, $key) = @_;
	return if exists($helpEntry->{__PROCESSED}) and $helpEntry->{__PROCESSED};
	$helpEntry->{related} = [ _related($session, $helpEntry->{related}) ];
	##Add an ISA link unless it already exists.
	##This simplifies handling later.
	unless (exists $helpEntry->{isa} and ref $helpEntry->{isa} eq 'ARRAY') {
		$helpEntry->{isa} = [];
	}
	unless (exists $helpEntry->{__PROCESSED}) {
		$helpEntry->{__PROCESSED} = 0;
	}
	foreach my $isa ( @{ $helpEntry->{isa} } ) {
		my $oCmd = "WebGUI::Help::".$isa->{namespace};
		my $other = _loadHelp($session, $oCmd);
		my $otherHelp = $other->{ $isa->{tag} };
		_process($session, $otherHelp, $isa->{tag});
		my $add = $otherHelp->{fields};
		@{$helpEntry->{fields}} = (@{$helpEntry->{fields}}, @{$add});
		$add = $otherHelp->{related};
		@{$helpEntry->{related}} = (@{ $helpEntry->{related} }, @{ $add });
		$add = $otherHelp->{variables};
		foreach my $row (@{$add}) {
			push(@{$helpEntry->{variables}}, {
				name=> $row->{name},
				description => $row->{description},
				namespace => $row->{namespace} || $isa->{namespace}
				});
		}
	}
	$helpEntry->{__PROCESSED} = 1;
}

#-------------------------------------------------------------------

=head2 _load ( $session, $namespace )

Safely load's the Help file for the requested namespace and logs errors
during the load.

=cut

sub _load {
	my $session = shift;
	my $namespace = shift;
	my $cmd = "WebGUI::Help::".$namespace;
	my $help = _loadHelp($session, $cmd);
	foreach my $tag (keys %{ $help }) {
		_process($session, $help->{$tag}, $tag);
	}
	return $help;
}

#-------------------------------------------------------------------

=head2 _get ( $session, $id, $namespace )

Safely load's the Help file for the requested namespace and returns
the specified id (help key).

=cut

sub _get {
	my $session = shift;
	my $id = shift;
	my $namespace = shift;
	my $help = _load($session,$namespace);
	if (keys %{ $help } ) {
		return $help->{$id};
	}
	else {
		$session->errorHandler->warn("Unable to load help for $namespace -> $id");
		return undef;
	}
}

#-------------------------------------------------------------------

=head2 _link ( $session, $id, $namespace )

Utility routine for formatting a link for returning a help entry in the requested
namespace.

=cut

sub _link {
	my $session = shift;
	return $session->url->page('op=viewHelp;hid='.$session->url->escape($_[0]).';namespace='.$_[1]);
}

#-------------------------------------------------------------------

=head2 _linkTOC ( $session, $namespace )

Utility routine for formatting a link for returning a table of contents entry
for a Help namespace.

=cut

sub _linkTOC {
	my $session = shift;
	return $session->url->page('op=viewHelpChapter;namespace='.$_[0]);
}

#-------------------------------------------------------------------

=head2 _getHelpFilesList ( $session )

Utility routine for returning a list of all Help files in the lib/WebGUI/Help folder.

=cut

sub _getHelpFilesList {
	my $session = shift;
        my $dir = join '/', $session->config->getWebguiRoot,"lib","WebGUI","Help";
        opendir (DIR,$dir) or $session->errorHandler->fatal("Can't open Help directory!");
	my @files;
	foreach my $file (readdir DIR) {
		next unless $file =~ /.pm$/;
		my $modName;
		($modName = $file) =~ s/\.pm$//;
		push @files, [ $file, $modName ];
	}
        closedir(DIR);
	return @files;
}

#-------------------------------------------------------------------

=head2 _getHelpName ( $session, $file )

To support the table of contents, all WebGUI help files have a corresponding
entry in the i18n file for the name of the chapter.  This utility routine
will fetch the correct i18n name for the chapter.

=cut

sub _getHelpName {
	my $session = shift;
	my $file = shift;
	my $helpName;
	if ($file =~ /^Asset_/) {
		$helpName = 'assetName';
	}
	elsif ($file =~ /^Macro_/) {
		$helpName = 'macroName';
	}
	elsif ($file =~ /^Workflow_Activity_/) {
		$helpName = 'activityName';
	}
	elsif ($file =~ /^Template_/) {
		$helpName = 'templateParserName';
	}
	else {
		$helpName = 'topicName';
	}
	my $i18n = WebGUI::International->new($session);
	return $i18n->get($helpName,$file);
}

#-------------------------------------------------------------------

=head2 _related ( $session, $related )

Utility routine for returning a list of topics related the the current help
entry.

=head3 $related

A scalar ref to either an array ref, which will be dereferenced to return a list, or
a code ref, which will be executed and should return a list.

=cut

sub _related {
	my ($session, $related) = @_;
	if (ref $related eq 'CODE') {
		return $related->($session);
	}
	else {
		return @{ $related };
	}
}

#-------------------------------------------------------------------

=head2 _columnar ( $columns, $list )

Utility routine for taking a list of data and returning it multiple columns.

=head3 $columns

The number of columns to create.

=head3 $list

A scalar ref to the array of data that will be broken into columns.

=cut

sub _columnar {
	my ($columns, $list) = @_;
	my @entries = @{ $list };
	my $fraction = round(@entries/$columns + 0.50);
	my $output = '<tr><td valign="top">';
	@entries = sort { $a->{name} cmp $b->{name} } @entries;
	my $i = 0;
	foreach my $helpEntry (@entries) {
                $output .= '<p><a href="'.$helpEntry->{link}.'">'.$helpEntry->{name}."</a></p>\n";
                $i++;
                if ($i % $fraction == 0) {
                        $output .= '</td><td valign="top">';
                }	
	}
	$output .= "</tr>";
	return $output;
}

#-------------------------------------------------------------------

=head2 www_viewHelp ( $session )

Display a single help entry in a namespace.  The entry and namespace are passed in as
form parameters.  Entries in the fields key of the hash are filtered by the user's
UI level, and this can be toggled on and off by another form parameter, uiOverride.

=cut

sub www_viewHelp {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $ac = WebGUI::AdminConsole->new($session,"help");
	$session->style->setLink($session->url->extras("/help.css"), {rel=>"stylesheet", type=>"text/css"});
	my $namespace = $session->form->process("namespace","className") || "WebGUI";
        my $i18n = WebGUI::International->new($session, $namespace);
	my $help = _get($session,$session->form->process("hid"),$namespace);
	my @related = @{ $help->{related} };
	foreach my $row (@related) {
		my $relatedHelp = _get($session,$row->{tag},$row->{namespace});
		next unless (defined $relatedHelp);
		$ac->addSubmenuItem(_link($session,$row->{tag},$row->{namespace}),$i18n->get($relatedHelp->{title},$row->{namespace}));
	}
        my %vars;
        $vars{uiLevelLabel} = $i18n->get('739', 'WebGUI');
	if (ref $help->{body} eq 'CODE') {
		$vars{body} = $help->{body}->($session);
	}
	else {
		$vars{body} = $i18n->get($help->{body});
	}
	my $userUiLevel = $session->user->profileField("uiLevel");
	my $uiOverride = $session->form->process("uiOverride");
        foreach my $row (@{ $help->{fields} }) {
                push @{ $vars{fields} }, 
			{ 'title'       => $i18n->get($row->{title},$row->{namespace}),
                          'description' => $i18n->get($row->{description},$row->{namespace}),
                          'uiLevel'     => $row->{uiLevel},
			} if ($uiOverride || ($userUiLevel >= ($row->{uiLevel} || 1)));
        }
	$vars{variable_loop1} = _getTemplateVars($session, 1,  $help->{variables}, $i18n);
        my $body = WebGUI::Asset::Template->new($session,"PBtmplHelp000000000001")->process(\%vars);
	my $uiOverrideText = $uiOverride ? $i18n->get('show my fields','WebGUI') : $i18n->get('show all fields','WebGUI');
	$ac->addSubmenuItem(_link($session, $session->form->process("hid"), $namespace).";uiOverride=".!$uiOverride, $uiOverrideText) if $userUiLevel < 9;
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95, 'WebGUI'));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents', 'WebGUI'));
	WebGUI::Macro::process($session,\$body);
    	return $ac->render(
		$body, 
		$i18n->get(93, 'WebGUI').': '.$i18n->get($help->{title})
		);
}

#-------------------------------------------------------------------

=head2 _getTemplateVars ( )

Generates help template vars for a template help file.

=cut

sub _getTemplateVars {
	my $session = shift;
	my $level = shift;
	my $variables = shift;
	my $i18n = shift;
	my $template = [];
	foreach my $row (@{$variables}) {
		my $indent = [];
		my $label = "";
		if (exists $row->{variables}) {
			my $newLevel = $level + 1;
			$indent = _getTemplateVars($session, $newLevel, $row->{variables}, $i18n);
			$label = "variable_loop".$newLevel;
		}	
		push ( @{$template}, {
			title => $row->{name}, 
			description=> $i18n->get(($row->{description} || $row->{name}), $row->{namespace}),
			$label => $indent
			});
	}	
	return $template;
}

#-------------------------------------------------------------------

=head2 _viewHelpIndex ( $session )

Display the index of all help entries in all namespaces.

=cut

sub www_viewHelpIndex {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $i18n = WebGUI::International->new($session);
        my @helpIndex;
	my $i;
	my @files = _getHelpFilesList($session,);
        foreach my $fileSet (@files) {
		my $namespace = $fileSet->[1];
		my $help = _load($session,$namespace);
		foreach my $key (keys %{$help}) {
			push @helpIndex, [$namespace, $key,
					$i18n->get($help->{$key}{title},$namespace)];
			$i++;
		}
        }
	my $output = '<table width="100%" class="content"><tr><td valign="top">';
	my $halfway = round($i/2);
	$i = 0;
        @helpIndex = sort { $a->[2] cmp $b->[2] } @helpIndex;
        foreach my $helpEntry (@helpIndex) {
                my ($namespace, $id, $title) = @{ $helpEntry };
                $output .= '<p><a href="'._link($session,$id,$namespace).'">'.$title.'</a></p>';
                $i++;
                if ($i == $halfway) {
                        $output .= '</td><td valign="top">';
                }	
	}
	$output .= '</td></tr></table>';
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents'));
	return $ac->render($output, join ': ',$i18n->get(93), $i18n->get('help index'));
}

#-------------------------------------------------------------------

=head2 www_viewHelpTOC ( $session )

Display the table of contents for the Help system.  This generates a list of
the assetName,macroName,topicNames for each installed Help file.

=cut

sub www_viewHelpTOC {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $i18n = WebGUI::International->new($session);
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	%tabs = (
		other => {
			label => $i18n->get('topicName', 'WebGUI'),
			uiLevel => 1,
		},
		asset => {
			label => $i18n->get('topicName', 'Asset'),
			uiLevel => 1,
		},
        	macro => {
			label => $i18n->get('topicName', 'Macros'),
			uiLevel => 1,
		},
        	workf => {
			label => $i18n->get('topicName', 'Workflow'),
			uiLevel => 1,
		},
        	templ => {
			label => $i18n->get('template parsers', 'Asset_Template'),
			uiLevel => 1,
		},
	);

	my @files = _getHelpFilesList($session,);
	my %entries;
	foreach my $fileSet (@files) {
		my $moduleName = $fileSet->[1];
		##This whole sorting routine sucks and should be replaced
		my $tab = lc substr $moduleName, 0, 5;
		unless (exists $tabs{$tab} or $tab eq "wobje" or $tab eq "workf") {
			$tab = 'other';
		}
		my $helpTopic = _loadHelp($session, "WebGUI::Help::".$moduleName);
		my @helpEntries = keys %{ $helpTopic };
		my $link;
		if (scalar @helpEntries > 1) {
			##Chapter
			$link = _linkTOC($session, $moduleName);
		}
		else {
			##Single page
			$link = _link($session, $helpEntries[0], $moduleName);
		}
		push @{ $entries{$tab} } ,
			{
				link => $link,
				name => _getHelpName($session,$moduleName),
			};
	}

	my $tabForm = WebGUI::TabForm->new($session, \%tabs);
	foreach my $tab ( keys %tabs ) {
		my $tabPut = '<table width="100%" class="content"><tr><td valign="top">';
		$tabPut .= _columnar(3, $entries{$tab});
		$tabPut .= '</table>';
		$tabForm->getTab($tab)->raw($tabPut);
	}
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95));
	$tabForm->{_submit} = $tabForm->{_cancel} = '';
	return $ac->render($tabForm->print, join(': ',$i18n->get(93), $i18n->get('help toc')));
}
#-------------------------------------------------------------------

=head2 www_viewHelpChapter ( $session )

Display all entries in one chapter of the help.  The namespace is passed in via
the form paramter "namespace".

=cut

sub www_viewHelpChapter {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $namespace = $session->form->process("namespace","className");
	my $help = _load($session,$namespace);
	my @entries = sort keys %{ $help };
	my $output = '';
	my $i18n = WebGUI::International->new($session);
        foreach my $id (@entries) {
                $output .= '<p><a href="'._link($session,$id,$namespace).'">'.$i18n->get($help->{$id}{title},$namespace).'</a></p>';
	}
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents'));
	return $ac->render($output, join ': ',$i18n->get(93), _getHelpName($session,$namespace));
}

1;
