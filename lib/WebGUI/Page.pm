package WebGUI::Page;

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

use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::Utility;
use DBIx::Tree::NestedSet;
use WebGUI::MetaData;

our @ISA = qw(DBIx::Tree::NestedSet);

=head1 NAME

Package WebGUI::Page

=head1 DESCRIPTION

This package provides utility functions for WebGUI's page system. Some of these work in a
non-object oriented fashion. These are utility functions, not affecting the page tree hiearchy.

The methods that do affect or report on this hiearchy should be called in a object oriented context.

=head1 SYNOPSIS

Non OO functions
 
 use WebGUI::Page;
 $boolean = WebGUI::Page::canEdit();
 $boolean = WebGUI::Page::canView();
 $integer = WebGUI::Page::countTemplatePositions($templateId);
 $html = WebGUI::Page::drawTemplate($templateId);
 $html = WebGUI::Page::generate();
 $hashRef = WebGUI::Page::getTemplateList();
 $template = WebGUI::Page::getTemplate();
 $hashRef = WebGUI::Page::getTemplatePositions($templateId);
 $url = WebGUI::Page::makeUnique($url,$pageId);

 WebGUI::Page::deCache();

Some OO style methods

 use WebGUI::Page;
 $page = WebGUI::Page->getPage($pageId);
 $page = WebGUI::Page->getAnonymousRoot;
 $page = WebGUI::Page->getFirstDaughter($pageId);
 $page = WebGUI::Page->getGrandmother($pageId);
 $page = WebGUI::Page->getLeftSister($pageId);
 $page = WebGUI::Page->getMother($pageId);
 $page = WebGUI::Page->getRightSister($pageId);
 $page = WebGUI::Page->getTop($pageId);
 $page = WebGUI::Page->getWebGUIRoot($pageId);
 $page = WebGUI::Page->new($pageId); # the default constructor

 $page->cut;
 $page->delete;
 $page->paste($newMother);
 $page->move($newMother);
 $page->moveDown;
 $page->moveLeft;
 $page->moveRight;
 $page->moveUp;
 $page->purge;

 @array = $page->ancestors;
 @array = $page->daughters;
 @array = $page->decendants;
 @array = $page->generation; 
 @array = $page->leaves_under; 
 @array = $page->pedigree;
 @array = $page->self_and_ancesters;
 @array = $page->self_and_decendants;
 @array = $page->self_and_sisters;
 @array = $page->self_and_sisters_splitted;
 @array = $page->sisters;

 $boolean = $page->canMoveDown;
 $boolean = $page->canMoveLeft;
 $boolean = $page->canMoveRight;
 $boolean = $page->canMoveUp;
 $boolean = $page->hasDaughter;

 $page->add($otherPageObject,\%properties);
 $page->get("title");
 $page->set(\%properties);				# this automatically recaches the pagetree
 $page->setWithoutRecache;

 $page->traversePreOrder(&mappingFunction);

 $page->recacheNavigation      or     WebGUI::Page->recacheNavigation;

=head1 SEE ALSO

This class is a sub-class of DBIx::Tree::NestedSet, which is included in your WebGUI distribution. See that for additional details on the page tree.

=head1 METHODS

These functions are available from this package:

=cut

#-------------------------------------------------------------------
sub _processWobjectFunctions {
        my ($wobject, $output, $proxyWobjectId, $cmd, $w);        
	if (exists $session{form}{func} && exists $session{form}{wid}) {                
		if ($session{form}{func} =~ /^[A-Za-z]+$/) {                        
			if ($session{form}{wid} eq "new") {                                
				$wobject = {wobjectId=>"new",namespace=>$session{form}{namespace},pageId=>$session{page}{pageId}};                        
			} else {                                
				$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobjectId=".quote($session{form}{wid}),WebGUI::SQL->getSlave); 
				if (${$wobject}{namespace} eq "") {                                        
					WebGUI::ErrorHandler::warn("Wobject [$session{form}{wid}] appears to be missing or "                                    
					."corrupt, but was requested " 
					."by $session{user}{username} [$session{user}{userId}].");                                        
					$wobject = ();                                
				}                        
			}                        
			if ($wobject) {                                
				if (${$wobject}{pageId} != $session{page}{pageId}) {                                        
					($proxyWobjectId) = WebGUI::SQL->quickArray("select wobject.wobjectId from                                                
						wobject,WobjectProxy                                               
						where wobject.wobjectId=WobjectProxy.wobjectId                                                
						and wobject.pageId=".quote($session{page}{pageId})."                                                
						and WobjectProxy.proxiedWobjectId=".quote(${$wobject}{wobjectId}),WebGUI::SQL->getSlave);
				  	${$wobject}{_WobjectProxy} = $proxyWobjectId;
				}
				unless (${$wobject}{pageId} == $session{page}{pageId}                                                                
					|| ${$wobject}{pageId} == 2                                                                
					|| ${$wobject}{pageId} == 3                                                                
					|| ${$wobject}{_WobjectProxy} ne "") {                                        
					$output .= WebGUI::International::get(417);                                        
					WebGUI::ErrorHandler::security("access wobject [".$session{form}{wid}."] on page '"       
						.$session{page}{title}."' [".$session{page}{pageId}."].");                                
				} else {                                        
					if (WebGUI::Page::canView()) {                                                
						$cmd = "WebGUI::Wobject::".${$wobject}{namespace};                                                
						my $load = "use ".$cmd; # gotta load the wobject before you can use it        
						eval($load);                                                
						WebGUI::ErrorHandler::warn("Wobject failed to compile: $cmd.".$@) if($@);
						$w = eval{$cmd->new($wobject)};   
						WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root Cause: ".$@) if($@);
						if ($session{form}{func} =~ /^[A-Za-z]+$/) {                                                        
							$cmd = "www_".$session{form}{func};                                                        
							$output = eval{$w->$cmd};        
							WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace} / $session{form}{func}. Root cause: ".$@) if($@);
                                               	} else {
                                                       	WebGUI::ErrorHandler::security("execute an invalid function: ".$session{form}{func});
                                               	}
                                       	} else {
                                               	$output = WebGUI::Privilege::noAccess();
                                       	}
                         	}
                       	}
               	} else {
                       	WebGUI::ErrorHandler::security("execute an invalid function on wobject "
                               	.$session{form}{wid}.": ".$session{form}{func});
               	}
	}
	return $output;
}


#-------------------------------------------------------------------

=head2 add

Adds page to the right of the children of the object this method is invoked 
on. Returns the new page object.

=over

=item page

A WebGUI::Page instance to be added to the children of the current object.

=back

=cut

sub add {
	my ($self, $page, $newPageId);
	$self = shift;
		
	$newPageId = WebGUI::Id::generate();
	$self->add_child_to_right(
		pageId	=>$self->get('pageId'),
		provided_primary_key => $newPageId,
		parentId=>$self->get('pageId'),
		depth	=>($self->get('depth') + 1),
		);
	
	$self->recacheNavigation;

	return WebGUI::Page->new($newPageId);
}

#-------------------------------------------------------------------

=head2 ancestors

Returns an array of hashes containing the properties of the ancestors of the current node.

=cut

sub ancestors {
	my ($self);
	$self = shift;
	return @{$self->get_parents_flat(
		id	=> $self->get('pageId')
		)};
}

#-------------------------------------------------------------------

=head2 canEdit ( [ pageId ] )
        
Returns a boolean (0|1) value signifying that the user has the required privileges.
        
=over           
        
=item pageId

The unique identifier for the page that you wish to check the privileges on. Defaults to the current page id.

=back

=cut

sub canEdit {
	my $pageId = shift || $session{page}{pageId};
        my (%page);
        tie %page, 'Tie::CPHash';
        if ($pageId ne $session{page}{pageId}) {
                %page = WebGUI::SQL->quickHash("select ownerId,groupIdEdit from page where pageId=".quote($pageId));
        } else {
                %page = %{$session{page}};
        }
        if ($session{user}{userId} == $page{ownerId}) {
                return 1;
        } else {
		return WebGUI::Grouping::isInGroup($page{groupIdEdit});
        }
}       

#-------------------------------------------------------------------

=head2 canMoveDown

Returns true if the current node can be moved down the tree. Ie. can be made
a child of it's left sister.

=cut

sub canMoveDown {
	my ($self) = shift;
	return $self->hasLeftSister;
}

#-------------------------------------------------------------------

=head2 canMoveLeft

Returns true if the current node can be moved left. Ie. if it can swap places
with it's left sister.

=cut

sub canMoveLeft {
	my ($self, $mother);
	$self = shift;
	$mother = $self->getMother;

	return (($self->get('nestedSetLeft') - $mother->get('nestedSetLeft')) > 1);
}

#-------------------------------------------------------------------

=head2 canMoveRight

Returns true if the current node can be moved rightt. Ie. if it can swap places
with it's right sister.

=cut

sub canMoveRight {
	my ($self, $mother);
	$self = shift;
	$mother = $self->getMother;

	return (($mother->get('nestedSetRight') - $self->get('nestedSetRight')) > 1);
}

#-------------------------------------------------------------------

=head2 canMoveUp

Returns true if the current node can be moved up the tree. Ie. if it can be 
made a child of it's grandmother.

=cut

sub canMoveUp {
	my ($self) = shift;
	return ($self->get('depth') > 0);
}

#-------------------------------------------------------------------

=head2 canView ( [ pageId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns users that have the rights to edit this page.

=over

=item pageId

The unique identifier for the page that you wish to check the privileges on. Defaults to the current page id.

=back

=cut

sub canView {
	my $pageId = shift || $session{page}{pageId};
        my %page;
        tie %page, 'Tie::CPHash';
        if ($pageId eq $session{page}{pageId}) {
                %page = %{$session{page}};
        } else {
                %page = WebGUI::SQL->quickHash("select ownerId,groupIdView,startDate,endDate from page where pageId=".quote($pageId),WebGUI::SQL->getSlave);
        }
        if ($session{user}{userId} == $page{ownerId}) {
                return 1;
        } elsif ($page{startDate} < WebGUI::DateTime::time() && $page{endDate} > WebGUI::DateTime::time() && WebGUI::Grouping::isInGroup($page{groupIdView})) {
                return 1;
        } else {
		return canEdit($pageId);
        }
}

#-------------------------------------------------------------------

=head2 countTemplatePositions ( templateId ) 

Returns the number of template positions in the specified page template.

=over

=item templateId

The id of the page template you wish to count.

=back

=cut

sub countTemplatePositions {
        my ($template, $i);
        $template = getTemplate($_[0]);
        $i = 1;
        while ($template =~ m/position$i\_loop/) {
                $i++;
        }
        return $i-1;
}

#-------------------------------------------------------------------

=head2 cut

Cuts the this page object and places it on the clipboard.

=cut

sub cut {
	my ($self, $clipboard, $parentId);
	$self = shift;
	$parentId = $self->get("parentId");
	
	# Place page in clipboard (pageId 2)
	$clipboard = WebGUI::Page->getPage(2);
	if ($self->move($clipboard)) {
		$self->set({
			bufferUserId	=> $session{user}{userId},
			bufferDate	=> time,
			bufferPrevId	=> $parentId,
		});
	}
	
	return $self;
}

#-------------------------------------------------------------------

=head2 daughters

Returns an array of hashes containing the properties of the daughters of the current node.

=cut

sub daughters {
	my ($self);
	$self = shift;
	return @{$self->get_children_flat(
		id 	=> $self->get('pageId'),
		depth	=> 1
		)};
}

#-------------------------------------------------------------------

=head2 deCache ( [ pageId ] )

Deletes the cached version of a specified page. Note that this is something else than the 
cached page tree. This funtion should be invoked in a non-OO context;

=over

=item pageId

The id of the page to decache. Defaults to the current page id.

=back

=cut

sub deCache {
	my $cache = WebGUI::Cache->new;
	my $pageId = $_[0] || $session{page}{pageId};
	$cache->deleteByRegex("m/^page_".$pageId."_\\d+\$/");
}

#-------------------------------------------------------------------

=head2 delete

Deletes this Page object from the tree and places it in the trash. To physically remove
pages from the tree and the database you should use the purge method.

=cut

sub delete {
	my ($self, $trash, $parentId);
	$self = shift;
	$parentId = $self->get("parentId");

	# Place page in trash (pageId 3)
	$trash = WebGUI::Page->getPage(3);

	if ($self->move($trash)) {
		$self->set({
			bufferUserId	=> $session{user}{userId},
			bufferDate	=> time,
			bufferPrevId	=> $parentId,
		});
	}

	return $self;
}

#-------------------------------------------------------------------

=head2 descendants

Returns an array of hashes containing the properties of the descendants of the current node.

=cut

sub descendants {
	my ($self);
	$self = shift;
	return @{$self->get_children_flat(
		id	=> $self->get('pageId')
		)};
}

#-------------------------------------------------------------------

=head2 drawTemplate ( templateId )

Returns an HTML string containing a small representation of the page template.

=over

=item templateId

The id of the page template you wish to draw.

=back

=cut

sub drawTemplate {
	my $template = getTemplate($_[0]);
	$template =~ s/\n//g;
	$template =~ s/\r//g;
	$template =~ s/\'/\\\'/g;
	$template = WebGUI::Macro::negate($template);
	$template =~ s/\<style.*?\>.*?\<\/style\>//gi;
	$template =~ s/\<script.*?\>.*?\<\/script\>//gi;
	$template =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
	$template =~ s/\<tmpl_loop\s+position(\d+)\_loop\>.*?\<\/tmpl\_loop\>/$1/ig;
	$template =~ s/\<tmpl_if.*?\>.*?\<\/tmpl_if\>//ig;
	$template =~ s/\<tmpl_if.*?\>//ig;
	$template =~ s/\<\/tmpl_if\>//ig;
	$template =~ s/\<tmpl_var.*?\>//ig;
	return $template;
}

#-------------------------------------------------------------------

=head2 generate ( )

Generates the content of the page.

=cut

sub generate {
        return WebGUI::Privilege::noAccess() unless (canView());
	my $output = _processWobjectFunctions();
	return $output if ($output);
	my %var;
	if ($session{page}{defaultMetaTags}) {
		WebGUI::Style::setMeta({'http-equiv'=>"Keywords", name=>"Keywords", content=>join(",",$session{page}{title},$session{page}{menuTitle})});
		WebGUI::Style::setMeta({'http-equiv'=>"Description", name=>"Description", content=>$session{page}{synopsis}}) if ($session{page}{synopsis});
        }
	WebGUI::Style::setRawHeadTags($session{page}{metaTags});
	if ($session{page}{redirectURL} && !$session{var}{adminOn}) {
		WebGUI::HTTP::setRedirect(WebGUI::Macro::process($session{page}{redirectURL}));
	}
	$var{'page.canEdit'} = canEdit();
        $var{'page.controls'} = pageIcon()
       		.deleteIcon('op=deletePage')
		.editIcon('op=editPage')
		.moveUpIcon('op=movePageUp')
		.moveDownIcon('op=movePageDown')
		.cutIcon('op=cutPage');
	$var{'page.controls'} .= exportIcon('op=exportPage') if defined ($session{config}{exportPath});
	my $sth = WebGUI::SQL->read("select * from wobject where pageId=".quote($session{page}{pageId})." order by sequenceNumber, wobjectId",WebGUI::SQL->getSlave);
        while (my $wobject = $sth->hashRef) {
		my $wobjectToolbar = wobjectIcon()
         		.deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
              		.editIcon('func=edit&wid='.${$wobject}{wobjectId})
             		.moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
             		.moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
              		.moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
              		.moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
            		.cutIcon('func=cut&wid='.${$wobject}{wobjectId})
            		.copyIcon('func=copy&wid='.${$wobject}{wobjectId});
             	if (${$wobject}{namespace} ne "WobjectProxy" && isIn("WobjectProxy",@{$session{config}{wobjects}})) {
             		$wobjectToolbar .= shortcutIcon('func=createShortcut&wid='.${$wobject}{wobjectId});
         	}
       		if (${$wobject}{namespace} eq "WobjectProxy") {
          		my $originalWobject = $wobject;
      			my ($wobjectProxy) = WebGUI::SQL->quickHashRef("select * from WobjectProxy where wobjectId=".quote(${$wobject}{wobjectId}),WebGUI::SQL->getSlave);
			if($wobjectProxy->{proxyByCriteria}) {
				$wobjectProxy->{proxiedWobjectId} = WebGUI::MetaData::getWobjectByCriteria($wobjectProxy) || $wobjectProxy->{proxiedWobjectId};
			}
	        	$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".quote($wobjectProxy->{proxiedWobjectId}),WebGUI::SQL->getSlave);
           		if (${$wobject}{namespace} eq "") {
             			$wobject = $originalWobject;
         		} else {
           			${$wobject}{startDate} = ${$originalWobject}{startDate};
          			${$wobject}{endDate} = ${$originalWobject}{endDate};
          			${$wobject}{templatePosition} = ${$originalWobject}{templatePosition};
             			${$wobject}{_WobjectProxy} = ${$originalWobject}{wobjectId};
           			if ($wobjectProxy->{overrideTitle}) {
             				${$wobject}{title} = ${$originalWobject}{title};
            			}
         			if ($wobjectProxy->{overrideDisplayTitle}) {
           				${$wobject}{displayTitle} = ${$originalWobject}{displayTitle};
           			}
        			if ($wobjectProxy->{overrideDescription}) {
         				${$wobject}{description} = ${$originalWobject}{description};
         			}
         			if ($wobjectProxy->{overrideTemplate}) {
       					${$wobject}{templateId} = $wobjectProxy->{proxiedTemplateId};
       				}
				my $originalWobjectPage = WebGUI::Page->new($wobject->{pageId});
				$wobject->{'original.page.url'} = WebGUI::URL::gateway($originalWobjectPage->get("urlizedTitle"));
        		}
      		}
                my $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
		my $load = 'use '.$cmd;
		eval($load);
		WebGUI::ErrorHandler::warn("Wobject failed to compile: $cmd.".$@) if($@);
                my $w = eval{$cmd->new($wobject)};
                WebGUI::ErrorHandler::fatalError("Couldn't instanciate wobject: ${$wobject}{namespace}. Root cause: ".$@) if($@);
		push(@{$var{'position'.$wobject->{templatePosition}.'_loop'}},{
                        'wobject.canView'=>$w->canView,
        		'wobject.canEdit'=>$w->canEdit,
			'wobject.controls'=>$wobjectToolbar,
			'wobject.controls.drag'=>dragIcon(),
			'wobject.namespace'=>$wobject->{namespace},
			'wobject.id'=>$wobject->{wobjectId},
			'wobject.isInDateRange'=>$w->inDateRange,
			'wobject.content'=>eval{$w->www_view}
			});
		WebGUI::ErrorHandler::fatalError("Wobject runtime error: ${$wobject}{namespace}. Root cause: ".$@) if($@);
	}
	$sth->finish;
	return WebGUI::Template::process($session{page}{templateId},"page",\%var);
}

#-------------------------------------------------------------------

=head2 generation

Returns an array of hashes containing the properties of the same generation as the current node. The
current node, being a member of it's own generation, is of course included. A generation consists of 
all nodes with the same depth (or level) in the tree.

=cut

sub generation {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.depth = b.depth and 
		      b.pageId = ".quote($self->get('pageId')).
		" order by nestedSetLeft");

	while (%row = $sth->hash) {
		push(@result, {(%row)});
	}

	return @result;
}

#-------------------------------------------------------------------

=head2 get( property )

Returns a hash reference of all the page properties.

=over

=item property

Returns a scalar containing the value of the specififed proeprty.

=back

=cut

sub get {
	my ($self, $property) = @_;
	if ($property) {
		return $self->{_pageProperties}->{$property};
	}
	return $self->{_pageProperties};
}

#-------------------------------------------------------------------

=head2 getAnonymousRoot

Returns the 'ueber'-root, the root with pageId 0, the one that holds all WebGUI roots
together, the node that brings the balance back into the force ;)

Note that this node is only in the database because of design. You cannot put stuff on
it. Well actually you can, but you don't want to. Trust me. Use it to add WebGUI roots
or traverse the whole page tree instead .

=cut

sub getAnonymousRoot {
	return WebGUI::Page->new(0);
}

#-------------------------------------------------------------------

=head2 getFirstDaughter( pageId )

Return the first (leftmost) daughter of the current node when called in instance context,
returns the first daughter of 'pageId' when called in class context.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the 
daughter of. Defaults to the current page.

=back

=cut

sub getFirstDaughter {
	my ($self, $pageId, $daughterId, @daughters); 
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}
	
	@daughters = $self->daughters;
	return undef unless (scalar(@daughters));
	
	$daughterId = $daughters[0]->{pageId};

	return WebGUI::Page->new($daughterId);
}

#-------------------------------------------------------------------

=head2 getGrandmother( pageId )

Returns the grandmother of the current node, or, when called in class context, the garndmother
of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
grandmother of. Defaults to the current page.

=back

=cut

sub getGrandmother {
	my ($self, $pageId, $grannyId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}
	
	return undef if ($self->get('depth') < 1);
	
	# We use self and ancestors here because ancestors strips on the wrong side.
	$grannyId = (reverse $self->self_and_ancestors)[2]->{pageId};
	return WebGUI::Page->new($grannyId);
}

#-------------------------------------------------------------------

=head2 getLeftSister( pageId )

Returns the left sister of the current node, or, when called in class context, the left sister
of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
left sister of. Defaults to the current page.

=back

=cut

sub getLeftSister {
	my ($self, $pageId, $leftSisterId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	($leftSisterId) = WebGUI::SQL->quickArray("select pageId from page where nestedSetRight=".($self->get('nestedSetLeft') - 1));
	return undef unless($leftSisterId);
	
	return WebGUI::Page->new($leftSisterId);
}

#-------------------------------------------------------------------

=head2 getMother( pageId )

Returns the mother of the current node, or, when called in class context, the left sister
of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
mother of. Defaults to the current page.

=back

=cut


sub getMother {
	my ($self, $pageId, $mommyId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}
	
	return undef if ($self->get('depth') < 0);
	
	# We use self and ancestors here because ancestors strips on the wrong side.
	$mommyId = (reverse $self->self_and_ancestors)[1]->{pageId};
	return WebGUI::Page->new($mommyId);
}

#-------------------------------------------------------------------

=head2 getPage( pageId )

Returns the page identified by 'pageId'.

=over

=item pageId

The pageId of the page you want. Defaults to the current page.

=back

=cut

sub getPage {
	my ($pageId);
	$pageId = $session{page}{pageId};
	$pageId = $_[1] if (defined $_[1]);
	
	return WebGUI::Page->new($pageId);
}

#-------------------------------------------------------------------

=head2 getRightSister( pageId )

Returns the right sister of the current node, or, when called in class context, the right sister
of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
right sister of. Defaults to the current page.

=back

=cut


sub getRightSister {
	my ($self,$pageId, $rightSisterId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	($rightSisterId) = WebGUI::SQL->quickArray("select pageId from page where nestedSetLeft=".($self->get('nestedSetRight') + 1));
	return undef unless(defined $rightSisterId);

	return WebGUI::Page->new($rightSisterId);
}

#-------------------------------------------------------------------

=head2 getTop( pageId )

Returns the top page (child of a WebGUI root, depth = 1) of the current node, or, when called in class 
context, the top of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
top page of. Defaults to the current page.

=back

=cut


sub getTop {
	my ($self, $pageId, $topId);
	($self, $pageId) = shift;
	unless (ref($self)) {
		$self= WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	if ($self->get('depth') == 1) {
		$topId = $self->get('pageId');          #The current page is a top level page
	} elsif ($self->get('depth') > 1) {
		$topId = ($self->self_and_ancestors)[2]->{pageId};
	} else {
		$topId = ($self->daughters)[0]->{pageId};
	}
	return WebGUI::Page->new($topId);
}

#-------------------------------------------------------------------

=head2 getTemplateList

Returns a hash reference containing template ids and template titles for all the page templates available in the system. 

=cut

sub getTemplateList {
	return WebGUI::Template::getList("page");
}

#-------------------------------------------------------------------

=head2 getTemplate ( [ templateId ] )

Returns an HTML template.

=over

=item templateId

The id of the page template you wish to retrieve. Defaults to the current page's template id.

=back

=cut

sub getTemplate {
	my $templateId = shift || $session{page}{templateId};
	my $template = WebGUI::Template::get($templateId,"page");
	return $template->{template};
}

#-------------------------------------------------------------------

=head2 getTemplatePositions ( templateId ) 

Returns a hash reference containing the positions available in the specified page template.

=over

=item templateId

The id of the page template you wish to retrieve the positions from.

=back

=cut

sub getTemplatePositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	for ($i=1; $i<=countTemplatePositions($_[0]); $i++) {
		$hash{$i} = $i;
	}
	return \%hash;
}

#-------------------------------------------------------------------

=head2 getWebGUIRoot( pageId )

Returns the WebGUI root (depth = 0) of the current node, or, when called in class 
context, the WebGUI root of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
WebGUI root of. Defaults to the current page.

=back

=cut

sub getWebGUIRoot {
	my ($self, $pageId, $rootId);
	($self, $pageId) = shift;
	unless (ref($self)) {
		$self= WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	if ($self->get('depth') == 0) {		#The current page is a WebGUI root
		$rootId = $self->get('pageId');
	} elsif ($self->get('depth') > 0) {
		$rootId = ($self->ancestors)[1]->{pageId};
	} else {					#There's no root, your tree is broken
		return undef;
	}
	
	return WebGUI::Page->new($rootId);
}

#-------------------------------------------------------------------

=head2 hasDaughter

Returns true if the page has one or more daughters

=cut

sub hasDaughter {
	my ($self) = shift;
	
	return ($self->get('nestedSetRight') - $self->get('nestedSetLeft') > 1);
}

#-------------------------------------------------------------------

=head2 leaves_under

Returns an array of hashes containing the properties of all leaves (pages without children)
under the page

=cut

sub leaves_under {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where (a.nestedSetLeft between b.nestedSetLeft and b.nestedSetRight) and
		      (a.nestedSetRight = a.nestedSetLeft + 1)
		      b.pageId = ".quote($self->get('pageId')).
		" order by nestedSetLeft");

	while (%row = $sth->hash) {
		push(@result, {(%row)});
	}

	return @result;
}

#-------------------------------------------------------------------

=head2 makeUnique ( pageURL, pageId )

Returns a unique page URL.

=over

=item url

The URL you're hoping for.

=item pageId

The page id of the page you're creating a URL for.

=back

=cut

sub makeUnique {
        my $url = $_[0] || "_1";
        my $pageId = $_[1] || "new";
	my $where; 
	unless ($pageId eq "new") {
		$where .= " and pageId<>".quote($pageId);
	}
        my ($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle=".quote($url).$where);
	if ($test) {
		my @parts = split(/\./,$url);
       	 	if ($parts[0] =~ /(.*)(\d+$)/) {
                	$parts[0] = $1.($2+1);
	        } elsif ($test ne "") {
        	        $parts[0] .= "2";
        	}
		$url = join(".",@parts);
		$url = makeUnique($url,$pageId);
	}
        return $url;
}

#-------------------------------------------------------------------

=head2 move( newMother )

Moves a page to another page (ie. makes the page you execute this method on a child of newMother).
Returns 1 if the move was succesfull, 0 otherwise.

=over

=item newMother

The page under which the current page should be moved. This should be an WebGUI::Page object.

=back

=cut

sub move{
	my ($self, $newMother, $parentId, $diff, $diff2, $sql, $depthDiff, $between, $updateRange, $moveNextToMother);
	($self,	$newMother) = @_;

	# Avoid cyclic pages. Not doing this will allow people to freeze your computer, by generating infinite loops.
	return 0 if (isIn($self->get('pageId'), map {$_->{pageId}} $newMother->ancestors));

	# Make sure a page is not moved to itself.
	return 0 if ($self->get('pageId') eq $newMother->get("pageId"));

	# Make sure a page is not moved to it's own mother
	return 0 if ($self->get('parentId') eq $newMother->get('pageId'));

	$parentId = $self->get("parentId");
	
	# We move to the right of the children of $newMother.
	$depthDiff = $self->get('depth') - $newMother->get('depth') - 1;

	# It is important if the page moves 'up' or 'down' in nestedSetLeft and nestedSetRight value
	if ($self->get('nestedSetLeft') < $newMother->get('nestedSetLeft')) {
		$between = ($self->get('nestedSetRight') + 1)." and ".($newMother->get('nestedSetRight') - 1);
		$updateRange = $self->get('nestedSetLeft')." and ".$newMother->get('nestedSetRight');
		$diff = $self->get('nestedSetRight') - $self->get('nestedSetLeft') + 1;
		$diff2 = $newMother->get('nestedSetRight') - $self->get('nestedSetRight') - 1;
	} else {
		$between = $newMother->get('nestedSetRight')." and ".($self->get('nestedSetLeft') - 1);
		$updateRange = $newMother->get('nestedSetLeft')." and ".($self->get('nestedSetRight')+1);
		$diff = $self->get('nestedSetLeft') - $self->get('nestedSetRight') - 1;
		$diff2 = $newMother->get('nestedSetRight') - $self->get('nestedSetLeft');
	}
	
	
	# Set the new depth 
	WebGUI::SQL->write("update page set depth=depth - $depthDiff where nestedSetLeft between ".$self->get('nestedSetLeft')." and ".$self->get('nestedSetRight'));
	
	# Do the magic: cast move on tree
	$sql = "
		update page set
		nestedSetLeft = case
			when nestedSetLeft between ". $self->get('nestedSetLeft')." and ".$self->get('nestedSetRight')."
				then nestedSetLeft + $diff2
			when nestedSetLeft between ". $between ."
				then nestedSetLeft - $diff
			else
				nestedSetLeft
		      end,
		nestedSetRight = case
		        when nestedSetRight between ". $self->get('nestedSetLeft') ." and ". $self->get('nestedSetRight') ."
				then nestedSetRight + $diff2
			when nestedSetRight between ". $between ."
				then nestedSetRight - $diff
			else
		      		nestedSetRight
		      end
		where 
			nestedSetRight between $updateRange or
			nestedSetLeft between $updateRange";
			
	WebGUI::SQL->write($sql);

	# Set the parentId to the right node.
	WebGUI::SQL->write("update page set parentId=".quote($newMother->get('pageId'))." where pageId=".quote($self->get('pageId')));

	WebGUI::Page->recacheNavigation;
	
	return 1;
}

#-------------------------------------------------------------------

=head2 moveDown

Moves the page down the tree. Ie. makes the page a daughter of it's left sister.

=cut

sub moveDown {
	my ($self, $leftSister);
	$self = shift;

	$leftSister = $self->getLeftSister;
	return 0 unless (defined $leftSister);

	$self->move($leftSister);
	return 1;
}

#-------------------------------------------------------------------

=head2 moveLeft

Move the page to the left. Ie. swaps places with it's left sister.

=cut

sub moveLeft {
	my ($self, $leftSister);
	$self = shift;

	$leftSister = $self->getLeftSister;
	return 0 unless (defined $leftSister);

	$self->swap_nodes(
		first_id	=> $self->get('pageId'), 
		second_id	=> $leftSister->get('pageId')
		);

	WebGUI::Page->recacheNavigation;
	return 1;
}

#-------------------------------------------------------------------

=head2 moveRight

Move the page to the right. Ie. swaps places with it's right sister.

=cut

sub moveRight {
	my ($self, $rightSister);
	$self = shift;
	
	$rightSister = $self->getRightSister;
	return 0 unless (defined $rightSister);

	$self->swap_nodes(
		first_id	=> $self->get('pageId'), 
		second_id	=> $rightSister->get('pageId')
		);

	WebGUI::Page->recacheNavigation;
	return 1;
}

#-------------------------------------------------------------------

=head2 moveUp

Moves the page up the tree. Ie. makes the page the right sister of it's mother.

=cut

sub moveUp {
	my ($self, $mother, $diff, $diff2, $sql);
	$self = shift;

	$mother = $self->getMother;
	
	# Don't move to an nonexistent node;
	return 0 if (!defined $mother);

	# Don't allow to move up if node is already a webguiroot;
	return 0 if ($mother->get('pageId') =~ /^\d+$/ && $mother->get('pageId') == 0);

	# Update depth, we do this before the move because now we know the nestedSetRight range of nodes 
	# that change in depth.
	WebGUI::SQL->write("update page set depth=depth-1 where nestedSetRight between ".$self->get('nestedSetLeft')." and ".$self->get('nestedSetRight'));

	# Do some movement magic!
	$diff = $self->get('nestedSetRight') - $self->get('nestedSetLeft') + 1;
	$diff2 = $mother->get('nestedSetRight') - $self->get('nestedSetRight');
	$sql = "
		update page set
		nestedSetLeft =	case
			when nestedSetLeft between ". $self->get('nestedSetLeft')." and ".$self->get('nestedSetRight')."
				then nestedSetLeft + $diff2
			when nestedSetLeft between ". ($self->get('nestedSetRight') + 1) ." and ". $mother->get('nestedSetRight') ."
				then nestedSetLeft - $diff
			else
				nestedSetLeft
			end,
		nestedSetRight = 	case
		        when nestedSetRight between ". $self->get('nestedSetLeft') ." and ". $self->get('nestedSetRight') ."
				then nestedSetRight + $diff2
			when nestedSetRight between ". ($self->get('nestedSetRight') + 1) ." and ". $mother->get('nestedSetRight') ."
				then nestedSetRight - $diff
			else
		      		nestedSetRight
		     	end,
		parentId = case pageId 
			when ". quote($self->get('pageId')) ."
				then ". quote($mother->get('parentId'))."
			else
				parentId
			end
		where 
			nestedSetRight between ". $self->get('nestedSetLeft') ." and ". $mother->get('nestedSetRight')." or 
			nestedSetLeft between ". $self->get('nestedSetLeft') ." and ". $mother->get('nestedSetRight');
			
	WebGUI::SQL->write($sql);

	WebGUI::Page->recacheNavigation;
	
	return 1;
}

#-------------------------------------------------------------------

=head2 new ( pageId || { properties } )

Creates a new page object. You can't create pages in the database with this, though. Use add instead.

If called without arguments it' fetches the current page (the one in $session{page}{pageId}) from the database
and returns an WebGUI::Page object of it.

You can pass one argument. This can be either a pageId of another page than the current you want, or a hashref
containing page properties. You can use the latter if you already have page properties (returned by ancestors or
something like it for example), and save a (redundant) database query. You can of course also use it to fool the 
system with dummy pages and do all kinds of magic that I can't imagine with it.

=over 

=item pageId || { properties }

You can pass either a pageId or a properties hashref. See above for an explanation

=back

=cut

sub new {
	my ($class, $self, $properties);
	($class, $properties) = @_;
	$self = $_[0]->SUPER::new(
		table_name		=> 'page',
		left_column_name	=> 'nestedSetLeft',
		right_column_name	=> 'nestedSetRight',
		id_name			=> 'pageId',
		dbh			=> $session{dbh},
		no_alter_table		=> 1,
		no_locking		=> 1,
		no_id_creation		=> 1,
		);
	unless (ref($properties)) {
		$properties = WebGUI::SQL->quickHashRef("select * from page where pageId=".quote($_[1]));
	}
	
	return undef unless (defined $properties->{pageId});
	$self->{_pageProperties} = $properties;
	return $self;
}

#-------------------------------------------------------------------

=head2 paste( newMother )

Pastes a page under newMother.

=over

=item newMother

The page under which the current page should be pasted. This should be an WebGUI::Page object.

=back

=cut

sub paste{
	my ($self, $newMother);
	($self, $newMother) = @_;

	# You do not want to paste a page onto itself, believe me.
	return $self if ($self->get("pageId") == $newMother->get("pageId"));
	return WebGUI::ErrorHandler::fatalError("You cannot paste a page that's not on the clipboard. parentId:".
		$self->get("parentId").", pageId:".$self->get("pageId")) unless ($self->get("parentId") == 2);
	
	# Place page in clipboard (pageId 2)
	if ($self->move($newMother)) {
		$self->set({
			bufferUserId	=> 'NULL',
			bufferDate	=> 'NULL',
			bufferPrevId	=> 'NULL'
		});
	}

	return $self;
}

#-------------------------------------------------------------------

=head2 pedigree

Ok, this does something funky. It returns an array of hashes containing page properties of the mothers of 
the page and their daughter, the page itself and it's daugthers. It used for the flexmenu.

=cut

sub pedigree {
	my ($self, $leftSisters, $currentPage, $rightSisters, @flexMenu, $node);
	$self = shift;
	
	($leftSisters, $currentPage, $rightSisters) = $self->self_and_sisters_splitted;
	@flexMenu = (@{$leftSisters}, {%{$currentPage}}, $self->daughters, @{$rightSisters});
	while (defined($self=$self->getMother) && ref($self)) {
		($leftSisters, $currentPage, $rightSisters) = $self->self_and_sisters_splitted;
		@flexMenu = (@{$leftSisters}, {%{$currentPage}}, @flexMenu, @{$rightSisters});
	}
	return @flexMenu;
}

#-------------------------------------------------------------------

=head2 purge

This purges this object and all it's children from the tree and the database.

=cut

sub purge {
	my ($self);
	$self = shift;

	$self->delete_self_and_children(
		id	=> $self->get('pageId')
		);

	WebGUI::Page->recacheNavigation;

	return "";
}

#-------------------------------------------------------------------

=head2 recacheNavigation

Actually this doesn't recache anything, but it might be in the future. Hence the name. Currently
it purges all Navigation cache objects. You should call it if you changed the pagetree. Note that 
the methods in this module that modify the tree already call this.

If you only change some navigation properties of a navigation element, you should use a more restricted
cache purge.

=cut

sub recacheNavigation {
	WebGUI::Cache->new("", "Navigation-".$session{config}{configFile})->deleteByRegex(".*");
	return "";
}


#-------------------------------------------------------------------

=head2 self_and_ancestors

Returns an array of hashrefs containing the page properties of this node and it's ancestors.

=cut

sub self_and_ancestors {
	my ($self);
	$self = shift;
	return @{$self->get_self_and_parents_flat(
		id	=> $self->get('pageId')
		)};
}	

#-------------------------------------------------------------------

=head2 self_and_descendants

Returns an array of hashrefs containing the page properties of this node and it's descendants.

=cut


sub self_and_descendants {
	my ($self);
	$self = shift;
	my @options = @_;
	return @{$self->get_self_and_children_flat(
		id	=> $self->get('pageId'),
		@options
		)};
}

#-------------------------------------------------------------------

=head2 self_and_sisters

Returns an array of hashrefs containing the page properties of this node and it's sisters.

=cut

sub self_and_sisters {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.parentId = b.parentId and 
		      b.pageId = ".quote($self->get('pageId')).
		" order by nestedSetLeft");
	while (%row = $sth->hash) {
		push(@result, {(%row)});
	}

	return @result;
}

#-------------------------------------------------------------------

=head2 self_and_sisters_splitted

Returns an array with the following contents:

 - [ leftSisters ] an arrayref of hashref containing the properties of the left sisters of the page.
 - $currentPage    an hashref containing the page properties of this node 
 - [ rightsister ] an arrayref of hashref containing the properties of the right sisters of the page.

=cut

sub self_and_sisters_splitted {
	my ($self, $haveAllLeftSisters, $currentPage, @leftSisters, @rightSisters);
	$self = shift;

	$haveAllLeftSisters = 0;
	foreach ($self->self_and_sisters) {
		if ($_->{pageId} == $self->get('pageId')) {
			$currentPage = $_;
			$haveAllLeftSisters = 1;
		} elsif ($haveAllLeftSisters) {
			push (@rightSisters, $_);
		} else {
			push (@leftSisters, $_);
		}
	}

	return (\@leftSisters, $currentPage, \@rightSisters);
}
		
#-------------------------------------------------------------------

=head2 sisters

Returns an array of hashrefs containing the page properties of this nodes sisters. The node not included.

=cut

sub sisters {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.pageId !=".quote($self->get('pageId'))." and  
		      a.parentId = b.parentId and b.pageId = ".quote($self->get('pageId')).
		" order by nestedSetLeft");
	while (%row = $sth->hash) {
		push(@result, {(%row)});
	}

	return @result;
}

#-------------------------------------------------------------------

=head2 set ( { properties } )

If data is given, invoking this method will set the object to the state given in data. If called without any arguments
the state of the tree is saved to the database.

This method purges the Navigation cache. Note that if you have to save a lot of properties in row, it's better to use 
setWithoutRecache, and call recacheNavigation manually. This saves some time.

=over

=item properties

The properties you want to set. This parameter is optional and should be a hashref of the form {propertyA => valueA, propertyB => valueB, etc...}

=back

=cut

sub set {
	my ($self, $properties); 
	($self, $properties) = @_;
	
	$self->setWithoutRecache($properties);
	WebGUI::Page->recacheNavigation;

	return "";
}

#-------------------------------------------------------------------

=head2 setWithoutRecache ( { properties } )

See set. The only difference with set is that the cached version of the pagetree is not updated. This means that you must
update it manually by invoking recachePageTree afterwards.

=over

=item properties

The properties you want to set. This parameter is optional and should be a hashref of the form {propertyA => valueA, propertyB => valueB, etc...}

=back

=cut

sub setWithoutRecache {
	my ($self, $properties); 
	($self, $properties) = @_;
	
	$properties = $self->{_properties} unless ($properties);
	
	if (scalar(keys(%{$properties}))) {
		WebGUI::SQL->write("update page set ".join(', ', map {"$_=".quote($properties->{$_})} keys %{$properties})." where pageId=".quote($self->get('pageId')));
	}

	return "";
}

#-------------------------------------------------------------------

=head2 traversePreOrder ( &mappingFunction )

Traverses the tree from this node down in pre-order fashion and excutes (maps) the mapping function
onto each node. Also maps onto this node except if it is the anonymous root. This has some but very limited 
compatibility with the callback property of the walk_down method of Tree::DAG_Node.

=over

=item mappingFunction

This should be a coderef pointing to your mapping function. The arguments that are passed to this function are
a page object and a hashref containing only _depth for now.

=back

=cut

sub traversePreOrder {
	my ($self, $mappingFunction, $initialDepth, $page, @pages);
	($self, $mappingFunction, $initialDepth) = @_;
	
	@pages = $self->self_and_descendants;
	# The 'ueber'-root contains no data so we do not want to return i!
	shift @pages if ($pages[0]->{'pageId'} == 0);
	
	foreach (@pages) {
		$page = WebGUI::Page->new($_->{'pageId'});
		&$mappingFunction($page, {_depth=>$page->get('depth')});
	}

	return @pages;
}

1;
