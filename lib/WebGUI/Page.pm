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

use warnings;
use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::Utility;
use DBIx::Tree::NestedSet;

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


 Some OO style methods

 use WebGUI::Page;
 $page = WebGUI::Page->getPage($pageId);
 $newMother = WebGUI::Page->getPage($anotherPageId);
 $page->cut;
 $page->paste($newMother);

 $page->set;				# this automatically recaches the pagetree

 $page->setWithoutRecache;
 WebGUI::Page->recacheNavigation	# here we've got to recache manually

=head1 METHODS

These functions are available from this package:

=cut

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
		
	$newPageId = getNextId('pageId');
	$self->add_child_to_right(
		id	=>$self->get('pageId'),
		pageId	=>$newPageId,
		parentId=>$self->get('pageId'),
		depth	=>($self->get('depth') + 1),
		);
	
	# Fixup the 'id' column that has the wrong value.
	WebGUI::SQL->write("update page set id=pageId where pageId=$newPageId");

	$self->recacheNavigation;

	return WebGUI::Page->new($newPageId);
}

#-------------------------------------------------------------------
=head2 ancestors

Returns an array of hashes containing the properties of the ancestors of the current node.

=back

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
                %page = WebGUI::SQL->quickHash("select ownerId,groupIdEdit from page where pageId=$pageId");
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

=back

=cut

sub canMoveDown {
	my ($self) = shift;
	return $self->hasLeftSister;
}

#-------------------------------------------------------------------
=head2 canMoveLeft

Returns true if the current node can be moved left. Ie. if it can swap places
with it's left sister.

=back

=cut

sub canMoveLeft {
	my ($self, $mother);
	$self = shift;
	$mother = $self->getMother;

	return (($self->get('lft') - $mother->get('lft')) > 1);
}

#-------------------------------------------------------------------
=head2 canMoveRight

Returns true if the current node can be moved rightt. Ie. if it can swap places
with it's right sister.

=back

=cut

sub canMoveRight {
	my ($self, $mother);
	$self = shift;
	$mother = $self->getMother;

	return (($mother->get('rgt') - $self->get('rgt')) > 1);
}

#-------------------------------------------------------------------
=head2 canMoveUp

Returns true if the current node can be moved up the tree. Ie. if it can be 
made a child of it's grandmother.

=back

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
                %page = WebGUI::SQL->quickHash("select ownerId,groupIdView,startDate,endDate from page where pageId=$pageId",WebGUI::SQL->getSlave);
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

=back

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

=back

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
	my $sth = WebGUI::SQL->read("select * from wobject where pageId=".$session{page}{pageId}." order by sequenceNumber, wobjectId",WebGUI::SQL->getSlave);
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
      			my ($wobjectProxy) = WebGUI::SQL->quickHashRef("select * from WobjectProxy where wobjectId=".${$wobject}{wobjectId},WebGUI::SQL->getSlave);
        		$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$wobjectProxy->{proxiedWobjectId},WebGUI::SQL->getSlave);
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

=back

=cut

sub generation {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.depth = b.depth and 
		      b.pageId = ".$self->get('pageId').
		" order by lft");

	while (%row = $sth->hash) {
		push(@result, {(%row)});
	}

	return @result;
}

#-------------------------------------------------------------------
=head2 get( property )

Returns the disired page property.

=over

=item property

The name of the property you wanna have

=back

=cut

sub get {
	my ($self, $property);
	($self, $property) = @_;

	return $self->{_pageProperties}->{$_[1]};
}

#-------------------------------------------------------------------
=head2 getAnonymousRoot

Returns the 'ueber'-root, the root with pageId 0, the one that holds all WebGUI roots
together, the node that brings the balance back into the force ;)

Note that this node is only in the database because of design. You cannot put stuff on
it. Well actually you can, but you don't want to. Trust me. Use it to add WebGUI roots
or traverse the whole page tree instead .

=back

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
	my ($self, $pageId, $daughterId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}
	
	$daughterId = ($self->daughters)[0]->{pageId};

	return WebGUI::Page->new($daughterId);
}

#-------------------------------------------------------------------
=head2 getGrandMother( pageId )

Returns the grandmother of the current node, or, when called in class context, the garndmother
of 'pageId'.

=over

=item pageId

Only required if called in class context. The pageId of the page of which you want the
grandmother of. Defaults to the current page.

=back

=cut

sub getGrandMother {
	my ($self, $pageId, $grannyId);
	($self, $pageId) = @_;
	unless (ref($self)) {
		$self = WebGUI::Page->new($pageId || $session{page}{pageId});
	}
	
	return undef if ($self->get('depth') < 2);
	
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

	($leftSisterId) = WebGUI::SQL->quickArray("select pageId from page where rgt=".($self->get('lft') - 1));
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
	
	return undef if ($self->get('depth') < 1);
	
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

	($rightSisterId) = WebGUI::SQL->quickArray("select pageId from page where lft=".($self->get('rgt') + 1));
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
	my ($self, $pageId, $topId, @descendants);
	($self, $pageId) = shift;
	unless (ref($self)) {
		$self= WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	@descendants = $self->descendants;
	if (scalar(@descendants) == 2) {
		$topId = $self->get('pageId');		#The current page is a top level page
	} elsif (scalar(@descendants) > 2) {
		$topId = $descendants[2]->{pageId};
	} else {					#Either the current page is a root page or there's no top level page.
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
	my ($self, $pageId, $node, $rootId, @descendants);
	($self, $pageId) = shift;
	unless (ref($self)) {
		$self= WebGUI::Page->new($pageId || $session{page}{pageId});
	}

	@descendants = $self->descendants;
	if (scalar(@descendants) == 1) {		#The current page is a WebGUI root
		$rootId = $self->get('pageId');
	} elsif (scalar(@descendants) > 1) {
		$rootId = $descendants[1]->{pageId};
	} else {					#There's no root, your tree is broken
		return undef;
	}
	
	return WebGUI::Page->new($rootId);
}

#-------------------------------------------------------------------
=head2 hasDaughter

Returns true if the page has one or more daughters

=back

=cut

sub hasDaughter {
	my ($self) = shift;
	
	return ($self->get('rgt') - $self->get('lft') > 1);
}

#-------------------------------------------------------------------
=head leaves_under

Returns an array of hashes containing the properties of all leaves (pages without children)
under the page

=back

=cut

sub leaves_under {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where (a.lft between b.lft and b.rgt) and
		      (a.rgt = a.lft + 1)
		      b.pageId = ".$self->get('pageId').
		" order by lft");

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
	my $where = "where urlizedTitle=".quote($url);
	unless ($pageId eq "new") {
		$where .= " and pageId<>".$pageId;
	}
        while (my ($test) = WebGUI::SQL->quickArray("select urlizedTitle from page ".$where)) {
                if ($url =~ /(.*)(\d+$)/) {
                        $url = $1.($2+1);
                } elsif ($test ne "") {
                        $url .= "2";
                }
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
	return 0 if ($self->get('pageId') == $newMother->get("pageId"));

	# Make sure a page is not moved to it's own mother
	return 0 if ($self->get('parentId') == $newMother->get('pageId'));
	
	$parentId = $self->get("parentId");
	
	# We move to the right of the children of $newMother.
	$depthDiff = $self->get('depth') - $newMother->get('depth') - 1;

	# It is important if the page moves 'up' or 'down' in lft and rgt value
	if ($self->get('lft') < $newMother->get('lft')) {
		$between = ($self->get('rgt') + 1)." and ".($newMother->get('rgt') - 1);
		$updateRange = $self->get('lft')." and ".$newMother->get('rgt');
		$diff = $self->get('rgt') - $self->get('lft') + 1;
		$diff2 = $newMother->get('rgt') - $self->get('rgt') - 1;
	} else {
		$between = $newMother->get('rgt')." and ".($self->get('lft') - 1);
		$updateRange = $newMother->get('lft')." and ".($self->get('rgt')+1);
		$diff = $self->get('lft') - $self->get('rgt') - 1;
		$diff2 = $newMother->get('rgt') - $self->get('lft');
	}
	
	
	# Set the new depth 
	WebGUI::SQL->write("update page set depth=depth - $depthDiff where lft between ".$self->get('lft')." and ".$self->get('rgt'));
	
	# Do the magic: cast move on tree
	$sql = "
		update page set
		lft = case
			when lft between ". $self->get('lft')." and ".$self->get('rgt')."
				then lft + $diff2
			when lft between ". $between ."
				then lft - $diff
			else
				lft
		      end,
		rgt = case
		        when rgt between ". $self->get('lft') ." and ". $self->get('rgt') ."
				then rgt + $diff2
			when rgt between ". $between ."
				then rgt - $diff
			else
		      		rgt
		      end
		where 
			rgt between $updateRange";
	WebGUI::SQL->write($sql);

	# Set the parentId to the right node.
	WebGUI::SQL->write("update page set parentId=".$newMother->get('pageId')." where pageId=".$self->get('pageId'));

	WebGUI::Page->recacheNavigation;
	
	return 1;
}

#-------------------------------------------------------------------
=head2 moveDown

Moves the page down the tree. Ie. makes the page a daughter of it's left sister.

=back

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

=back

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

=back

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

=back

=cut

sub moveUp {
	my ($self, $mother, $diff, $diff2, $sql);
	$self = shift;

	$mother = $self->getMother;
	return 0 unless (defined $mother);

	# Update depth, we do this before the move because now we know the rgt range of nodes 
	# that change in depth.
	WebGUI::SQL->write("update page set depth=depth-1 where rgt between ".$self->get('lft')." and ".$self->get('rgt'));

	# Do some movement magic!
	$diff = $self->get('rgt') - $self->get('lft') + 1;
	$diff2 = $mother->get('rgt') - $self->get('rgt');
	$sql = "
		update page set
		lft =	case
			when lft between ". $self->get('lft')." and ".$self->get('rgt')."
				then lft + $diff2
			when lft between ". ($self->get('rgt') + 1) ." and ". $mother->get('rgt') ."
				then lft - $diff
			else
				lft
			end,
		rgt = 	case
		        when rgt between ". $self->get('lft') ." and ". $self->get('rgt') ."
				then rgt + $diff2
			when rgt between ". ($self->get('rgt') + 1) ." and ". $mother->get('rgt') ."
				then rgt - $diff
			else
		      		rgt
		     	end,
		parentId = case pageId 
			when ". $self->get('pageId') ."
				then ".$mother->get('parentId')."
			else
				parentId
			end
		where 
			rgt between ". $self->get('lft') ." and ". $mother->get('rgt');
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
		left_column_name	=> 'lft',
		right_column_name	=> 'rgt',
		dbh			=> $session{dbh},
		no_alter_table		=> 1,
		no_locking		=> 1
		);
	unless (ref($properties)) {
		$properties = WebGUI::SQL->quickHashRef("select * from page where pageId=$_[1]");
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

=back

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

=over

=cut

sub recacheNavigation {
	WebGUI::Cache->new("", "Navigation-".$session{config}{configFile})->deleteByRegex(".*");

	return "";
}


#-------------------------------------------------------------------
=head2 self_and_ancestors

Returns an array of hashrefs containing the page properties of this node and it's ancestors.

=back

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

=back

=cut


sub self_and_descendants {
	my ($self);
	$self = shift;
	return @{$self->get_self_and_children_flat(
		id	=> $self->get('pageId')
		)};
}

#-------------------------------------------------------------------
=head2 self_and_sisters

Returns an array of hashrefs containing the page properties of this node and it's sisters.

=back

=cut

sub self_and_sisters {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.parentId = b.parentId and 
		      b.pageId = ".$self->get('pageId').
		" order by lft");
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

=back

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

=back

=cut

sub sisters {
	my ($self, $sth, %row, @result);
	$self = shift;
	$sth = WebGUI::SQL->read(
		"select a.* 
		from page as a, 
		     page as b 
		where a.pageId !=".$self->get('pageId')." and  
		      a.parentId = b.parentId and b.pageId = ".$self->get('pageId').
		" order by lft");
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
		WebGUI::SQL->write("update page set ".join(', ', map {"$_=".quote($properties->{$_})} keys %{$properties})." where pageId=".$self->get('pageId'));
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
