package WebGUI::Navigation;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Operation::Navigation;
use WebGUI::Page;
use WebGUI::Utility;
use WebGUI::Privilege;
use WebGUI::Template;
use WebGUI::Icon;
use WebGUI::International;

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

=head1 OBSOLETE FUNCTIONS

 use WebGUI::Navigation;

 $pageTree = WebGUI::Navigation::tree($pageParentId,$depthToTraverse);

 $html = WebGUI::Navigation::drawHorizontal($tree);
 $html = WebGUI::Navigation::drawVertical($tree);
 
=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------
sub _getEditButton {
        my $self = shift;
        return editIcon("op=editNavigation&navigationId=".$self->{_navigationId}."&identifier=".$self->{_identifier});
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

=head2 drawHorizontal ( tree [ , seperator, class ] )

Draws a horizontal navigation system. Returns HTML.

=over

=item tree

The hash reference created by the tree method in this package.

=item seperator

A string containing HTML to seperate each navigation item. Defaults to "&middot;".

=item class

A stylesheet class for each link in the navigation. Defaults to "horizontalMenu".

=back

=cut

sub drawHorizontal {
        my ($output, $i, $pageId, $first);
        my ($tree, $seperator, $class) = @_;
        $class = "horizontalMenu" unless ($class);
	$seperator = $seperator || '&middot;';
	$first = 1;
        foreach $pageId (keys %{$tree}) {
		if ($first) {
			$first = 0;
		} else {
			$output .= ' '.$seperator.' ';
		}
                $output .= '<a class="'.$class.'"';
		$output .= ' target="_blank"' if ($tree->{$pageId}{newWindow});
		$output .= ' href="'.$tree->{$pageId}{url}.'">';
		if ($pageId == $session{page}{pageId}) {
                       $output .= '<span class="selectedMenuItem">'.$tree->{$pageId}{title}.'</span>';
		} else {
                       $output .= $tree->{$pageId}{title};
               	}
                $output .= '</a>';
        }
        return $output;
}

#-------------------------------------------------------------------

=head2 drawVertical ( tree [, bullet, class, spacing, indent ] )

Draws a vertical navigation system. Returns HTML.

=over

=item tree

The hash reference created by the tree method in this package.

=item bullet

A string containing HTML to generate a bullet that will be placed in front of each tree item. Defaults to none.

=item class

A stylesheet class for each link in the navigation. Defaults to "verticalMenu".

=item spacing

An integer with the linespacing for the navigation. Defaults to 1.

=item indent

An integer with the about of indenting to start with. Defaults to 0.

=back

=cut

sub drawVertical {
	my ($output, $i, $padding, $leading, $pageId);
	my ($tree, $bullet, $class, $spacing, $indent) = @_;
	$class = "verticalMenu" unless ($class);
	$spacing = 1 unless ($spacing);
        for ($i=1;$i<=$indent;$i++) {
                $padding .= "&nbsp;&nbsp;&nbsp;";
        }
        for ($i=1;$i<=$spacing;$i++) {
                $leading .= "<br />";
        }
	foreach $pageId (keys %{$tree}) {
		$output .= $padding.$bullet.'<a class="'.$class.'"';
		$output .= ' target="_blank"' if ($tree->{$pageId}{newWindow});
		$output .= ' href="'.$tree->{$pageId}{url}.'">';
                if ($pageId == $session{page}{pageId}) {
                       $output .= '<span class="selectedMenuItem">'.$tree->{$pageId}{title}.'</span>';
                } else {
                       $output .= $tree->{$pageId}{title};
                }
		$output .= '</a>'.$leading;
		$output .= drawVertical($tree->{$pageId}{sub}, $bullet, $class, $spacing, ($indent+1));
	}
        return $output;
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
			$pageData->{"page.isViewable"} = WebGUI::Privilege::canViewPage($page->get('pageId'));

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
			# Store $pageData in page_loop. Mind the order.
			if ($self->{_reverse}) {
				unshift(@{$var->{page_loop}}, $pageData);
			} else {
				push(@{$var->{page_loop}}, $pageData);
			}
		}
	}
	# Store current page properties in template var
	my $currentPage = WebGUI::Page->getPage();
	foreach my $property (@interestingPageProperties) {
		$var->{'page.current.'.$property} = $currentPage->get($property);
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
	
#-------------------------------------------------------------------

=head2 tree ( parentId [, toLevel ] )

Generates and returns a hash reference containing a page tree with keys of "url", "title", "fullTitle", "synopsis", "newWindow" and "sub" with orignating keys of page ids.  The tree looks like this:

 root
  |-pageId
  |  |-url
  |  |-title
  |  |-fullTitle
  |  |-synopsis
  |  |-newWindow
  |  `-sub (pageId)
  |     |-url
  |     |-title
  |     |-fullTitle
  |     |-synopsis
  |     |-newWindow
  |     `-sub (pageId)
  |        `-etc
  `-pageId
     `-etc

=over

=item parentId

The page id of where you'd like to start the tree.

=item toLevel

The depth the tree should be traversed. Defaults to "0". If set to "0" the entire tree will be traversed.

=back

=cut

sub tree {
        my ($sth, %data, %tree);
	my ($parentId, $toLevel, $depth) = @_;
        $toLevel = 99 if ($toLevel > 100 || $toLevel < 1);
	tie %tree, 'Tie::IxHash';
	tie %data, 'Tie::CPHash';
       	if ($depth < $toLevel) {
               	$sth = WebGUI::SQL->read("select urlizedTitle, menuTitle, pageId, synopsis, hideFromNavigation, 
			newWindow, title from page 
			where parentId='$parentId' order by sequenceNumber");
               	while (%data = $sth->hash) {
                       	if (!($data{hideFromNavigation}) && WebGUI::Privilege::canViewPage($data{pageId})) {
				$tree{$data{pageId}}{url} = WebGUI::URL::gateway($data{urlizedTitle}); 
				$tree{$data{pageId}}{title} = $data{menuTitle}; 
				$tree{$data{pageId}}{synopsis} = $data{synopsis}; 
				$tree{$data{pageId}}{fullTitle} = $data{title};
				$tree{$data{pageId}}{newWindow} = $data{newWindow};
               	                $tree{$data{pageId}}{sub} = tree($data{pageId},$toLevel,($depth+1));
                       	}
                }
       	        $sth->finish;
       	}
        return \%tree;
}




1;


