package WebGUI::Persistent::Tree;

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


use strict;
use warnings;

use Tree::DAG_Node;
use WebGUI::Persistent;
use WebGUI::SQL ();
use WebGUI::Persistent::Query::Update;

our @ISA = qw(WebGUI::Persistent Tree::DAG_Node);

=head1 NAME

Package WebGUI::Persistent

=head1 DESCRIPTION

An abstract base class for objects stored in the database, that represent tree
structures.

This class inherits from both WebGUI::Persistent (to provide get() and set() 
methods), and from Tree::DAG_Node (to provide tree manipulation methods).

=head1 SYNOPSIS

 package MyTreeClass;

 use WebGUI::Persistent::Tree;
 our @ISA = qw(WebGUI::Persistent::Tree);

 sub classSettings { 
      {
           properties => {
                A => { key => 1 },
                B => { defaultValue => 5},
                C => { quote => 1 , defaultValue => "hello world"},
                parentId       => { defaultValue => 0 },
                sequenceNumber => { defaultValue => 1 }
           },
           table => 'myTreeTable'
      }
 }

 1;

 .
 .
 .

 use MyTreeClass;

 my $nodes = $class->getTree({-minmumFields});
 print join("\n",@{$nodes->{0}->draw_ascii_tree()});

=head1 METHODS

#-------------------------------------------------------------------

=head2 buildTree( \@objs, [ \%nodes ] )

Given an array reference of objects this method will attempt to build them
into a tree.

=cut

sub buildTree {
     my ($class,$objs,$nodes) = @_;

     $nodes ||= {};
     my %parentToChild = ();
     my $keyColumn = $class->keyColumn();
     foreach my $obj (grep {$_} @$objs) {
          $nodes->{$obj->get($keyColumn)} = $obj;
          $obj->{daughters} ||= [];
          next if ($obj->get('parentId') == $obj->get($keyColumn));
          push @{ $parentToChild{$obj->get('parentId')} }, $obj; 
     }

     foreach my $parentId (keys %parentToChild) {
          if (my $parent = $nodes->{$parentId}) {
               $parent->add_daughters($class->sortSiblings($parentToChild{$parentId}));
          }
     }

     return $nodes;
}

#-------------------------------------------------------------------

=head2 canDown

Returns tree if this object can be moved down within the current tree.

=cut

sub canDown   { $_[0]->right_sister }

#-------------------------------------------------------------------

=head2 canLeft

Returns tree if this object can be moved left within the current tree.

=cut

sub canLeft   { $_[0]->mother ? 1 : 0 }

#-------------------------------------------------------------------

=head2 canRight

Returns tree if this object can be moved right within the current tree.

=cut

sub canRight  { $_[0]->left_sister  }

#-------------------------------------------------------------------

=head2 canUp

Returns tree if this object can be moved up within the current tree.

=cut

sub canUp     { $_[0]->left_sister  }

#-------------------------------------------------------------------

=head2 classSettings

This class method must be overridden to return a hash reference with one or
more of the following keys.

=head3 useDummyRoot

This should be set to true for classes that don't store their root node in
the database.

=head3 properties

This should be a hash reference keyed by the field names of the table that 
this class refers to (and should be able to be manipulated with this classes
get() and set() methods). The values of the hash reference should be hash
references containing settings for each field.

=head3 * defaultValue 

The default value for this field (optional).

=head3 * key

Should be true for the primary key column (one field must be set in this way).

=head3 * quote

Should be true for fields that need to be quoted in database queries.

=cut

#-------------------------------------------------------------------

=head2 dummyRoot

This creates a dummy root object for classes that do not store their root in
the database.

=cut

sub dummyRoot {
     $_[0]->new(
          -properties => { pageId => 0 },
          -noSet => 1
     );
}

#-------------------------------------------------------------------

=head2 getTree ( [ \%p, $maxDepth, \%nodes ] )

This method has varying behaviour depending on the context from which it is 
called.

In instance context rows from the table will be recursivley selected using the 
current object as the root, and then the tree will be built:

  $self->getTree();

In class context, the all rows are selected from the table, and then the tree
is built.

  $class->getTree();

In all cases a hashref is returned.

 { keyColumnValue => WebGUI::Persistent::Tree object }

If defined $maxDepth maybe used to limit the depth of the recursion.

If %p is defined, the arguments are passed directly to the new or multiNew
methods, this allows multiple trees to be easily stored in one table:

 $class->getTree({treeId => 4});

$nodes can be a hash reference to objects that have already been obtained from
the database.

=cut

sub getTree {
     my ($self,$p,$maxDepth,$nodes) = @_;
     my $class = ref($self) || $self;
     $nodes ||= {};
     $p ||={};

     unless (ref($self)) {
          if ($class->useDummyRoot()) {
               $nodes->{0} = $self = $class->dummyRoot(); 
          }

          if (!defined($maxDepth)) {
               return $class->buildTree([$class->multiNew(%$p)],$nodes);
          } elsif (!ref($self)) {
               $self = $class->new(%$p,$class->keyColumn() => 0); 
          }
     }
     $nodes->{$self->get($class->keyColumn())} ||= $self;

     return $nodes if (defined($maxDepth) && --$maxDepth < 0);

     my @objs = $class->multiNew(
          parentId => $self->get($class->keyColumn()),%$p
     );
     if (@objs) {
          $self->buildTree(\@objs,$nodes);
          return $nodes if (defined($maxDepth) && !$maxDepth) ;
          $_->getTree($p,$maxDepth,$nodes) foreach @objs;
     }
  
     return $nodes;
}

#-------------------------------------------------------------------

=head2 grandmotherChildrenAndSelf( $keyColumnId )

Using the given $keyColumnId this method fetches the grandmother, children,
and the object refered to by the $keyColumnId.

Returns a list of objects.

=cut

sub grandmotherChildrenAndSelf {
     my ($class,$keyColumnId) = @_;
     return undef unless defined($keyColumnId);
     my $self = $class->new(-minimumFields=>1,$class->keyColumn() => $keyColumnId);
     return undef unless $self;
     return ($self,$class->motherSelfAndSisters($self->get('parentId')));
}

#-------------------------------------------------------------------

=head2 minimumFields

The minimumFields for Trees must also include the parentId, and the 
sequenceNumber.

See WebGUI::Persistent.

=cut

sub minimumFields {
     my ($class) = @_;
     unless ($class->classData->{minimumFields}) {
          my $fields = $class->SUPER::minimumFields();
          push @$fields, 'parentId';
          push @$fields, 'sequenceNumber' if ($class->properties->{sequenceNumber});
     }
     return $class->classData->{minimumFields};
}

#-------------------------------------------------------------------

sub name {
     my $self = shift;
     return $self->keyColumn().':'.$self->get($self->keyColumn());
}

#-------------------------------------------------------------------

# Avoid a bug in Tree::DAG_Node. 
# When a new node is created and has no daughters. This sometimes causes
# problems for Tree::DAG_Node::walk_down()

sub new {
     my $class = shift;
     my $self = $class->SUPER::new(@_);
     $self->{daughters} ||= [] if $self;
     $self->attributes({});
     return $self;
}

#-------------------------------------------------------------------

=head2 motherSelfAndSisters( $keyColumnId )

Given the $keyColumnId, this method fetches the related mother and sisters.

Returns a list of objects.

=cut

sub motherSelfAndSisters {
     my ($class,$keyColumnId) = @_;
     return undef unless defined($keyColumnId);
     my $self = $class->new(-minimumFields=>1,$class->keyColumn() => $keyColumnId);
     return undef unless $self;
  
     my $parentId = $self->get('parentId');
     my @objs = $class->multiNew(
          -minimumFields => 1,
          -where => [
               [{
                    parentId => $parentId,
                    $class->keyColumn() => $parentId,
               }],
               $class->keyColumn()." != $keyColumnId",
          ]
     );
     if ($class->useDummyRoot() && $parentId == 0) {
          push @objs, $class->dummyRoot();
     }
     return ($self,@objs);
}

#-------------------------------------------------------------------

=head2 moveDown( [ $keyColumnId ] )

In class context:

 $class->moveDown($keyColumnId);

The required parent, sister and child objects are fetched from the database,
and the tree is built and manipulated.This class' inheritance from 
WebGUI::Persistent takes care of any database work.

In instance context:

 $self->moveDown();

The current object is assumed to be in a pre-built tree, and so the tree is 
simply manipulated. This class' inheritance from WebGUI::Persistent takes care
of any database work.

=cut

sub moveDown {
     my ($self,$keyColumnId) = @_;
     my $class = ref($self) || $self;
     return unless $class->properties->{sequenceNumber};
  
     unless (ref($self)) {
          my $nodes = $class->buildTree([$class->motherSelfAndSisters($keyColumnId)]);
          $self = $nodes->{$keyColumnId};
     }

     return unless ($self && $self->canDown());

     my $right = $self->right_sister;
     $self->swapSisters($right);
}

#-------------------------------------------------------------------

=head2 moveLeft( [ $keyColumnId ] )

In class context:

 $class->moveLeft($keyColumnId);

The required parent, sister and child objects are fetched from the database,
and the tree is built and manipulated.This class' inheritance from 
WebGUI::Persistent takes care of any database work.

In instance context:

 $self->moveLeft();

The current object is assumed to be in a pre-built tree, and so the tree is 
simply manipulated. This class' inheritance from WebGUI::Persistent takes care
of any database work.

=cut

sub moveLeft {
     my ($self,$keyColumnId) = @_;
     my $class = ref($self) || $self;

     unless (ref($self)) {
          my $nodes = $class->buildTree([$class->grandmotherChildrenAndSelf($keyColumnId)]);
          $self = $nodes->{$keyColumnId};
     }

     return unless ($self && $self->canLeft());

     my $sister = $self->mother;

     # Close up hole left by imminent move
     map {
          $_->set({sequenceNumber => $_->get('sequenceNumber') - 1 })
     } $self->right_sisters();

     $self->unlink_from_mother;
     $sister->add_right_sister($self);

     my $newSequenceNumber = $sister->get('sequenceNumber') + 1;

     map {
          $_->set({sequenceNumber => $_->get('sequenceNumber') + 1 })
     } $self->right_sisters();

     $self->set({
          parentId => $sister->get('parentId'), 
          sequenceNumber => $newSequenceNumber
     });
}

#-------------------------------------------------------------------

=head2 moveRight( [ $keyColumnId ] )

In class context:

 $class->moveRight($keyColumnId);

The required parent, sister and child objects are fetched from the database,
and the tree is built and manipulated.This class' inheritance from 
WebGUI::Persistent takes care of any database work.

In instance context:

 $self->moveRight();

The current object is assumed to be in a pre-built tree, and so the tree is 
simply manipulated. This class' inheritance from WebGUI::Persistent takes care
of any database work.

=cut

sub moveRight {
     my ($self,$keyColumnId) = @_;
     my $class = ref($self) || $self;
  
     unless (ref($self)) {
          my @objs = $class->motherSelfAndSisters($keyColumnId);
          my $nodes = $class->buildTree(\@objs);
          $self = $nodes->{$keyColumnId};
     }

     return unless ($self && $self->canRight());

     my $keyColumn = $class->keyColumn();
     my $mother = $self->left_sister;
     $mother->getTree({-minimumFields => 1},1);

     # Close up hole left by imminent move
     map {
          $_->set({sequenceNumber => $_->get('sequenceNumber') -1 })
     } $self->right_sisters();

     # Add as right-most daughter of current left-sister
     $self->unlink_from_mother;
     $mother->add_daughter($self);

     my $newSequenceNumber = 1;
     if (my $sister = $self->left_sister()) {
          $newSequenceNumber = $sister->get('sequenceNumber') + 1;
     }

     $self->set({
          parentId => $mother ? $mother->get($keyColumn) : 0, 
          sequenceNumber => $newSequenceNumber
     });
}

#-------------------------------------------------------------------

=head2 moveUp( [ $keyColumnId ] )

In class context:

 $class->moveUp($keyColumnId);

The required parent, sister and child objects are fetched from the database,
and the tree is built and manipulated.This class' inheritance from 
WebGUI::Persistent takes care of any database work.

In instance context:

 $self->moveUp();

The current object is assumed to be in a pre-built tree, and so the tree is 
simply manipulated. This class' inheritance from WebGUI::Persistent takes care
of any database work.

=cut

sub moveUp {
     my ($self,$keyColumnId) = @_;
     my $class = ref($self) || $self;
     return unless $class->properties->{sequenceNumber};

     unless (ref($self)) {
          my $nodes = $class->buildTree([$class->motherSelfAndSisters($keyColumnId)]);
          $self = $nodes->{$keyColumnId};
     }

     return unless ($self && $self->canUp());

     my $left = $self->left_sister;
     $self->swapSisters($left);
}

#-------------------------------------------------------------------

=head2 recursiveDelete

Deletes this element, and all subsequent elements in the tree. The C<getTree> 
method must have been called to build the tree.

=cut

sub recursiveDelete {
     my ($self) = @_;
     my @ids;
     $self->walk_down({callback => sub {push @ids, $_[0]->get($_[0]->keyColumn())}});
     $self->multiDelete(collateralFolderId => \@ids) if @ids;
     return @ids;
}

#-------------------------------------------------------------------

=head2 pedigree 

=cut

sub pedigree {
	my $node = shift;
	my @flexMenu = ($node->left_sisters,$node,$node->daughters,$node->right_sisters);
	while(defined($node = $node->{'mother'} ) && ref($node)) {
		@flexMenu = ($node->left_sisters,$node,@flexMenu,$node->right_sisters);
	}
	return @flexMenu;
}

#-------------------------------------------------------------------

=head2 self_and_ancestors 

=cut

sub self_and_ancestors {
        my $node = shift;
	return ($node, $node->ancestors);
}

#-------------------------------------------------------------------

=head2 sortSiblings( \@siblings )

Sorts an array of objects according to sequenceNumber

=cut

sub sortSiblings {
     my ($class,$siblings) = @_;
     return @$siblings unless $class->properties->{sequenceNumber};
     return sort { 
          ($a->get('sequenceNumber') <=> $b->get('sequenceNumber')) 
     } @$siblings;
}

#-------------------------------------------------------------------

=head2 swapSisters( $sister )

Swaps two sisters over (they must be in a built tree), and updates their
sequenc numbers.

=cut

sub swapSisters {
     my $self = shift;
     my ($other) = @_;
     my @daughters = $self->self_and_sisters;
     my $a = $self ->my_daughter_index;
     my $b = $other->my_daughter_index;
     @daughters[$a, $b] = ($other, $self);
     $self->mother->set_daughters(@daughters);

     my $tmp = $self->get('sequenceNumber');
     $self->set({sequenceNumber => $other->get('sequenceNumber')});
     $other->set({sequenceNumber => $tmp});
}

=head2 useDummyRoot

Returns true if useDummyRoot is set in classSettings().

=cut 

sub useDummyRoot {
     my ($class) = @_;
     unless ($class->classData->{useDummyRoot}) {
          $class->classData->{useDummyRoot} = $class->classSettings->{useDummyRoot};
     }
     return $class->classData->{useDummyRoot}
}

1;
