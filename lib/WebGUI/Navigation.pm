package WebGUI::Navigation;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Navigation;
use WebGUI::Page;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Navigation

=head1 DESCRIPTION

A package used to generate navigation.

=head1 SYNOPSIS

 use WebGUI::Navigation;

 $nav = WebGUI::Navigation->new(identifier=>'FlexMenu');
 $html = $nav->view;

 $custom = WebGUI::Navigation->new(
				startAt=>'root',
				'reverse'=>1,
				method=>'self_and_sisters',
				template=>'<tmpl_loop page_loop><tmpl_var page.title><br></tmpl_loop>'
				);
 $html = $custom->build;
 
=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------
sub _getEditButton {
        my $self = shift;
        return editIcon("op=editNavigation&navigationId=".$self->{_navigationId}."&identifier=".$self->{_identifier})
		.manageIcon("op=listNavigation");
}

#-------------------------------------------------------------------
sub _getStartPageObject {
        my $self = shift;
        my $levels = $self->_levels();
        my $p;
        if (isIn($self->{_startAt}, keys %{$self->getLevelNames()})) {  # known startAt level
                $p = &{$levels->{$self->{_startAt}}{handler}};          # initiate object.
        } else {
                if($self->{_startAt} !~ /^\d+$/) {
                        ($self->{_startAt}) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle="
                                                        .quote($self->{_startAt}));
                }
                if($self->{_startAt}) {
                        $p = WebGUI::Page->getPage($self->{_startAt});
                }
        }
        return $p;
}

#-------------------------------------------------------------------
sub _levels {
        tie my (%levels), 'Tie::IxHash';        # Maintain ordering
        #
        # Please note that the WebGUI root (for example /home) and the Tree::DAG_node
        # root are not the same. All WebGUI roots share a fictive parent, the nameless root.
        # If you call $node->root, you will get that nameless root (with has pageId=0).
        #
        # The WebGUI root for a page is the second last element in the $node->ancestors list.
        #
        %levels = (     'root' => {
                                name => WebGUI::International::get(1,'Navigation'),
                                handler => sub {
                                                return WebGUI::Page->getAnonymousRoot;
                                        },
                                },
                        'WebGUIroot' => {
                                name => WebGUI::International::get(2,'Navigation'),
                                handler => sub {
						return WebGUI::Page->getWebGUIRoot;
                                        },
                                },
                        'top' => {
                                name => WebGUI::International::get(3,'Navigation'),
                                handler => sub {
						return WebGUI::Page->getTop;
                                        },
                                },
                        'grandmother' => {
                                name => WebGUI::International::get(4,'Navigation'),
                                handler => sub {
                                                return WebGUI::Page->getGrandmother;
                                        },
                                },
                        'mother' => {
                                name => WebGUI::International::get(5,'Navigation'),
                                handler => sub {
                                                return WebGUI::Page->getMother;
                                        },
                                },
                        'current' => {
                                name => WebGUI::International::get(6,'Navigation'),
                                handler => sub {
                                                return WebGUI::Page->getPage;
                                        },
                                },
                        'daughter' => {
                                name => WebGUI::International::get(7,'Navigation'),
                                handler => sub {
						return WebGUI::Page->getFirstDaughter;
                                        },
                                },
                );
        return \%levels;
}

#-------------------------------------------------------------------
sub _methods {
        tie my (%methods),  'Tie::IxHash';      # Maintain ordering
        %methods = (    'daughters' => {
                                name => WebGUI::International::get(8,'Navigation'),
                                method => '$p->daughters',
                                },
                        'sisters' => {
                                name => WebGUI::International::get(9,'Navigation'),
                                method => '$p->sisters',
                                },
                        'self_and_sisters' => {
                                name => WebGUI::International::get(10,'Navigation'),
                                method => '$p->self_and_sisters',
                                },
                        'descendants' => {
                                name => WebGUI::International::get(11,'Navigation'),
                                method => '$p->descendants',
                                },
                        'self_and_descendants' => {
                                name => WebGUI::International::get(12,'Navigation'),
                                method => '$p->self_and_descendants',
                        },
                        'leaves_under' => {
                                name => WebGUI::International::get(13,'Navigation'),
                                method => '$p->leaves_under',
                                },
                        'generation' => {
                                name => WebGUI::International::get(14,'Navigation'),
                                method => '$p->generation',
                                },
                        'ancestors' => {
                                name => WebGUI::International::get(15,'Navigation'),
                                method => '$p->ancestors',
                                },
                        'self_and_ancestors' => {
                                name => WebGUI::International::get(16,'Navigation'),
                                method => '$p->self_and_ancestors',
                                },
                        'pedigree' => {
                                name => WebGUI::International::get(17,'Navigation'),
                                method => '$p->pedigree',
                                },
                );
        return \%methods;
}

#-------------------------------------------------------------------
sub _storeConfigInClass {
        my $self = shift;
        my $config = shift;
        foreach my $key (keys %{$config}) {
                $self->{'_'.$key} = $config->{$key};
        }
}

#-------------------------------------------------------------------
sub _toKeyValueHashRef {
        my $hashRef = shift;
        tie my (%keyValues) , 'Tie::IxHash';
        foreach my $key (keys %$hashRef) {
                $keyValues{$key} = $hashRef->{$key}{'name'};
        }
        return \%keyValues;
}


#-------------------------------------------------------------------

=head2 build ( )

This method builds a navigation item based on the parameters stored
in the class and returns HTML.

=cut

sub build {
	my $self = shift;
	my @interestingPageProperties = ('pageId', 'parentId', 'title', 'ownerId', 'urlizedTitle',
			'synopsis', 'newWindow', 'menuTitle');
	my $var = {'page_loop' => []};
	my $p = $self->_getStartPageObject();
	my $method = $self->_methods()->{$self->{_method}}{method};

	my $cache = WebGUI::Cache->new($self->{_identifier}.'-'.$session{page}{pageId}, "Navigation-".$session{config}{configFile});
	my $cacheContent = $cache->get;

	my (@page_loop, $lastPage, %unfolded);
	tie %unfolded, "Tie::IxHash";

        # Store current page properties in template var
        my $currentPage = WebGUI::Page->getPage();
        foreach my $property (@interestingPageProperties) {
        	$var->{'page.current.'.$property} = $currentPage->get($property);
        }
	unless (defined $cacheContent && 
			! $session{url}{siteURL}) {	# Never use cache if an alternate site url is specified.
		# The loop was not cached
		my @pages = eval $method;
		if ($@) {
			WebGUI::ErrorHandler::warn("Error in WebGUI::Navigation::build while trying to execute $method".$@);
		}
		if (@pages) {
			my $startPageDepth = ($p->ancestors);
			my $maxDepth = $startPageDepth + $self->{_depth};
			my $minDepth = $startPageDepth - $self->{_depth};

			foreach my $page (@pages) {
				my $pageData = {};

				# Initial page info
				$pageData->{"page.url"} = WebGUI::URL::gateway($page->{'urlizedTitle'});
				$pageData->{"page.absDepth"} = $page->{'depth'} + 1;
				$pageData->{"page.relDepth"} = $pageData->{"page.absDepth"} - $startPageDepth;
				$pageData->{"page.isCurrent"} = ($page->{'pageId'} == $session{page}{pageId});
				$pageData->{"page.isHidden"} = $page->{'hideFromNavigation'};
				$pageData->{"page.isSystem"} = (($page->{'pageId'} < 1000 && $page->{'pageId'} > 1) || 
							$page->{'pageId'} == 0);

				
				# indent
				my $indent = 0;
				if ($self->{_method} eq 'pedigree' 	# reverse traversing 
				    || $self->{_method} eq 'ancestors' 		# needs another way to calculate
				    || $self->{_method} eq 'self_and_ancestors') {	# the indent
					if ($self->{_stopAtLevel} <= $startPageDepth && $self->{_stopAtLevel} > 0) {
						$indent = $pageData->{"page.absDepth"} - ($self->{_stopAtLevel} - 1) - 1;
					} elsif ($self->{_stopAtLevel} > $startPageDepth && $self->{_stopAtLevel} > 0) {
						$indent = 0;
					} else {
						$indent = $pageData->{"page.absDepth"} - 1;
					}
				} else {
					$indent = $pageData->{"page.absDepth"} - $startPageDepth - 1;
				}
				$pageData->{"page.indent_loop"} = [];
				push(@{$pageData->{"page.indent_loop"}},{'indent'=>$_}) for(1..$indent);
				$pageData->{"page.indent"} = "&nbsp;&nbsp;&nbsp;" x $indent;

				# Check if in depth range
				next if ($pageData->{"page.absDepth"} > $maxDepth || $pageData->{"page.absDepth"} < $minDepth);
				
				# Check stopAtLevel
				next if ($pageData->{"page.absDepth"} < $self->{_stopAtLevel});

				# Check showSystemPages
				next if (! $self->{_showSystemPages} && $pageData->{"page.isSystem"}); 
			
				# Deal with hidden pages
				next if($page->{'hideFromNavigation'} && ! $self->{_showHiddenPages});

				# Put page properties in $pageData hashref
				foreach my $property (@interestingPageProperties) {
					$pageData->{"page.".$property} = $page->{$property};
				}
				$pageData->{"page.isRoot"} = (! $page->{'parentId'});
				$pageData->{"page.isTop"} = ($pageData->{"page.absDepth"} == 2);
				$pageData->{"page.hasDaughter"} = ($page->{'nestedSetRight'} - $page->{'nestedSetLeft'} > 1);
				$pageData->{"page.isMyDaughter"} = ($page->{'parentId'} == 
									$currentPage->get('pageId'));
				$pageData->{"page.isMyMother"} = ($page->{'pageId'} ==
									$currentPage->get('parentId'));
				$pageData->{"page.inCurrentRoot"} = 
					(($page->{'nestedSetLeft'} > $currentPage->get('nestedSetLeft')) && ($page->{'nestedSetRight'} < $currentPage->get('nestedSetRight'))) ||
					(($page->{'nestedSetLeft'} < $currentPage->get('nestedSetLeft')) && ($page->{'nestedSetRight'} > $currentPage->get('nestedSetRight')));

                                # Anchestor info
                                foreach my $ancestor ($currentPage->ancestors) {
                                        $pageData->{"page.isMyAncestor"} += ($ancestor->{'pageId'} == $page->{'pageId'});
                                }
				# Some information about my mother
				
				my $mother = WebGUI::Page->getPage($page->{parentId});
				if ($page->{parentId} > 0) {
					foreach (qw(title urlizedTitle parentId pageId)) {
						$pageData->{"page.mother.$_"} = $mother->get($_);
					}
				}
				
				$pageData->{"page.isLeftMost"} = (($page->{'nestedSetLeft'} - 1) == $mother->get('nestedSetLeft'));
				$pageData->{"page.isRightMost"} = (($page->{'nestedSetRight'} + 1) == $mother->get('nestedSetRight'));
				my $depthDiff = ($lastPage) ? ($lastPage->{'page.absDepth'} - $pageData->{'page.absDepth'}) : 0;
				if ($depthDiff > 0) {
					$pageData->{"page.depthDiff"} = $depthDiff if ($depthDiff > 0);
					$pageData->{"page.depthDiffIs".$depthDiff} = 1;
					push(@{$pageData->{"page.depthDiff_loop"}},{}) for(1..$depthDiff);
				}
				
				# Some information about my depth
				$pageData->{"page.depthIs".$pageData->{"page.absDepth"}} = 1;
				$pageData->{"page.relativeDepthIs".$pageData->{"page.relDepth"}} = 1;

				# We need a copy of the last page for the depthDiffLoop
				$lastPage = $pageData;
				
				# Store $pageData in page_loop. Mind the order.
				if ($self->{_reverse}) {
					unshift(@page_loop, $pageData);
				} else {
				
					push(@page_loop, $pageData);
				}
			}
		}

		# We had a cache miss, so let's put the data in cache
		$cache->set(\@page_loop, 3600*24);
	} else {
		# We had a cache hit
		@page_loop = @{$cacheContent};
	}
	
	# Do the user-dependent checks (which cannot be cached globally)
	foreach my $pageData (@page_loop) {
		$pageData->{"page.isViewable"} = WebGUI::Page::canView($pageData->{'page.pageId'});

		# Check privileges
		if ($pageData->{"page.isViewable"} || $self->{_showUnprivilegedPages}) {
			push (@{$var->{page_loop}}, $pageData);
			push (@{$unfolded{$pageData->{"page.parentId"}}}, $pageData);
		}
	}

	foreach (values %unfolded) {
		push(@{$var->{unfolded_page_loop}}, @{$_});
	}
	
	# Configure button
	$var->{'config.button'} = $self->_getEditButton();
	
	if ($self->{_template}) {
		return WebGUI::Template::processRaw($self->{_template}, $var);
	} else {
		return WebGUI::Template::process($self->{_templateId}, "Navigation", $var);
	}
}

#-------------------------------------------------------------------

=head2 getConfig ( [identifier] )

Returns a hash reference containing the configuration in
key => value pairs for the requested identifier.
If no identifier is specified, the class identifier will be used.

This routine can be called both as a method or as a function.

=over

=item identifier

The configuration to use. Config is stored in the table Navigation
in the database.

=back

=cut

sub getConfig {
        my $identifier;
        if (ref($_[0]) && ! $_[1]) {
                $identifier = $_[0]->{_identifier};
        } elsif (ref($_[0])) {
                $identifier = $_[1];
        } else {
                $identifier = $_[0];
        }
        return WebGUI::SQL->quickHashRef('select * from Navigation where identifier = '.quote($identifier));

}

#-------------------------------------------------------------------

=head2 getLevelNames ( )

Returns a hash reference with starting levels.  

=cut

sub getLevelNames {
	return _toKeyValueHashRef(_levels());
}

#-------------------------------------------------------------------

=head2 getMethodNames ( )

Returns a hash reference with methods.

=cut

sub getMethodNames {
	return _toKeyValueHashRef(_methods());
}

#-------------------------------------------------------------------

=head2 new ( identifier => $id,  [ %options ] )

Constructor.

=over

=item identifier

The configuration to use. Config is stored in the table Navigation
in the database.

=item options

Instead of using an existing configuration, you can also drop
in your own parameters of the form: option => value. 

$custom = WebGUI::Navigation->new(
                                startAt=>'root',
                                'reverse'=>1,
                                method=>'self_and_sisters',
                                template=>'<tmpl_loop page_loop><tmpl_var page.title><br></tmpl_loop>'
                                );

=back

=cut

sub new {
        my $class = shift;
        WebGUI::ErrorHandler::fatalError('WebGUI::Navigation->new() called with odd number of option parameters - should be of the form option => value') unless $#_ % 2;;
        my %var = @_;
        my $self = bless {}, $class;
	my %default = ( identifier => time(),
			depth => 99,
			method => 'descendants',
			startAt => 'current',
			stopAtLevel => -1,
			templateId => 1,
			);
	%var = ( %default, %var);
        $self->_storeConfigInClass(\%var);
        return $self;
}

#-------------------------------------------------------------------

=head2 view ( )

This is an interface for WebGUI::Macro::Navigation and returns HTML.  
It builds a navigation item based on the identifier. If the identifier
is not found, a link for initial configuration is returned.

=cut

sub view {
	my $self = shift;
	my $config = $self->getConfig;
	if(defined($config->{identifier})) {
		$self->_storeConfigInClass($config);
		return $self->build;
	} else {
		return '<a href="'.WebGUI::URL::page('op=editNavigation&identifier='.$self->{_identifier}).'">'.
		       'Configure '.$self->{_identifier}.'</a>';
	}
}
	




1;


