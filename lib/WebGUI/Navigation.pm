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
                                                return WebGUI::Page->getPage()->root;
                                        },
                                },
                        'WebGUIroot' => {
                                name => WebGUI::International::get(2,'Navigation'),
                                handler => sub {
                                                my $p = WebGUI::Page->getPage;
                                                my @ancestors = reverse $p->ancestors;
                                                if(scalar(@ancestors) == 1) { # I am WebGUI root. I have one ancestor, which
                                                        return $p             # is nameless root. Return myself
                                                } elsif(scalar(@ancestors) > 1) { # I am a page under WebGUI root.
                                                        return $ancestors[1];     # 1st element of ancestors is WebGUI root
                                                } else {
                                                        return undef;         # huh ? No root ???
                                                }
                                        },
                                },
                        'top' => {
                                name => WebGUI::International::get(3,'Navigation'),
                                handler => sub {
                                                my $p = WebGUI::Page->getPage;
                                                my @ancestors = reverse $p->ancestors;
                                                if(scalar(@ancestors) == 2) {   # I am top, my ancestors are nameless root
                                                        return $p;              # and my WebGUI root. Return myself.
                                                } elsif(scalar(@ancestors) > 2) { # I am a page under top, so return the
                                                        return $ancestors[2];     # 2nd element of ancestors is top.
                                                } else {                        # No top page or I am root.
                                                        return ($p->daughters)[0]; # 1st element
                                                }
                                        },
                                },
                        'grandmother' => {
                                name => WebGUI::International::get(4,'Navigation'),
                                handler => sub {
                                                my $p = WebGUI::Page->getPage();
                                                return $p->mother->mother;
                                        },
                                },
                        'mother' => {
                                name => WebGUI::International::get(5,'Navigation'),
                                handler => sub {
                                                my $p = WebGUI::Page->getPage();
                                                return $p->mother;
                                        },
                                },
                        'current' => {
                                name => WebGUI::International::get(6,'Navigation'),
                                handler => sub {
                                                return WebGUI::Page->getPage();
                                        },
                                },
                        'daughter' => {
                                name => WebGUI::International::get(7,'Navigation'),
                                handler => sub {
                                                my $p = WebGUI::Page->getPage;
                                                return ($p->daughters)[0]; # 1st daughter
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
	my @pages = eval $method;
	if ($@) {
		WebGUI::ErrorHandler::warn("Error in WebGUI::Navigation::build while trying to execute $method".$@);
	}

	# Store current page properties in template var
	my $currentPage = WebGUI::Page->getPage();
	foreach my $property (@interestingPageProperties) {
		$var->{'page.current.'.$property} = $currentPage->get($property);
	}

	if (@pages) {
		my $startPageDepth = ($p->ancestors);
		my $maxDepth = $startPageDepth + $self->{_depth};
		my $minDepth = $startPageDepth - $self->{_depth};

		foreach my $page (@pages) {
			my $pageData = {};

			# Initial page info
                        $pageData->{"page.url"} = WebGUI::URL::gateway($page->get('urlizedTitle'));
                        $pageData->{"page.absDepth"} = scalar($page->ancestors);
                        $pageData->{"page.relDepth"} = $pageData->{"page.absDepth"} - $startPageDepth;
                        $pageData->{"page.isCurrent"} = ($page->get('pageId') == $session{page}{pageId});
			$pageData->{"page.isHidden"} = $page->get('hideFromNavigation');
			$pageData->{"page.isSystem"} = (($page->get('pageId') < 1000 && $page->get('pageId') > 1) || 
							$page->get('pageId') == 0);
			$pageData->{"page.isViewable"} = WebGUI::Page::canView($page->get('pageId'));

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
			
			# Check privileges
			next if (! $pageData->{"page.isViewable"} && ! $self->{_showUnprivilegedPages});

			# Deal with hidden pages
			next if($page->get('hideFromNavigation') && ! $self->{_showHiddenPages});

			# Put page properties in $pageData hashref
			foreach my $property (@interestingPageProperties) {
				$pageData->{"page.".$property} = $page->get($property);
			}
			$pageData->{"page.isRoot"} = (! $page->get('parentId'));
			$pageData->{"page.isTop"} = ($pageData->{"page.absDepth"} == 2);
			$pageData->{"page.hasDaughter"} = scalar($page->daughters);
			$pageData->{"page.isMyDaughter"} = ($page->get('parentId') == 
								$currentPage->get('pageId'));
			$pageData->{"page.isMyMother"} = ($page->get('pageId') ==
                                                                $currentPage->get('parentId'));

			# Some information about my mother
			if(ref($page->mother)) {
				foreach (qw(title urlizedTitle parentId pageId)) {
					$pageData->{"page.mother.$_"} = $page->mother->get($_);
				}
			}
			# Some information about my depth
			$pageData->{"page.depthIs".$pageData->{"page.absDepth"}} = 1;
			$pageData->{"page.relativeDepthIs".$pageData->{"page.absDepth"}} = 1;

			# Store $pageData in page_loop. Mind the order.
			if ($self->{_reverse}) {
				unshift(@{$var->{page_loop}}, $pageData);
			} else {
				push(@{$var->{page_loop}}, $pageData);
			}
		}
	}

	# Configure button
	$var->{'config.button'} = $self->_getEditButton();

	return WebGUI::Template::process($self->{_template} || WebGUI::Template::get($self->{_templateId}, "Navigation"), $var);
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


