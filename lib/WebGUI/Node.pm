package WebGUI::Node;

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

use File::Path;
use POSIX;
use strict;
use WebGUI::ErrorHandler;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Node

=head1 DESCRIPTION

Package to manipulate WebGUI storage nodes. The nodes system is a two-tiered filesystem hash that WebGUI uses to keep attachment data separated. There should be no need for anyone other than Plain Black Software to use this package.

=head1 SYNOPSIS

 use WebGUI::Node;
 $node = WebGUI::Node->new("100","20");

 $node->create;
 $node->delete;
 $node->getPath;
 $node->getURL;

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 create ( )
 
Creates this node on the file system.

=cut

sub create {
	my ($node);
	$node = $session{config}{uploadsPath}.$session{os}{slash}.$_[0]->{_node1};
	mkdir($node);
	unless ($! eq "File exists" || $! eq "") {
		WebGUI::ErrorHandler::warn("Couldn't create node: $node : $!");
	}
        if ($_[0]->{_node2} ne "") {
		$node = $session{config}{uploadsPath}.$session{os}{slash}.$_[0]->{_node1}.$session{os}{slash}.$_[0]->{_node2};
		mkdir($node);
		unless ($! eq "File exists" || $! eq "") {
                	WebGUI::ErrorHandler::warn("Couldn't create node: $node : $!");
        	}
       	}	
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this node and its contents (if any) from the filesystem. 

=cut

sub delete {
        rmtree($_[0]->getPath);
}


#-------------------------------------------------------------------

=head2 getPath ( )

Returns a full path to this node.

=cut

sub getPath {
        my ($path);
        $path = $session{config}{uploadsPath}.$session{os}{slash}.$_[0]->{_node1};
        if ($_[0]->{_node2} ne "") {
                $path .= $session{os}{slash}.$_[0]->{_node2};
        }
        return $path;
}


#-------------------------------------------------------------------

=head2 getURL ( )

Returns a full URL to this node.

=cut

sub getURL {
	my ($url);
	$url = $session{config}{uploadsURL}.'/'.$_[0]->{_node1};
	if ($_[0]->{_node2} ne "") {
		$url .= '/'.$_[0]->{_node2};
	}
	return $url;
}


#-------------------------------------------------------------------

=head2 new ( node1 [, node2 ] )

Constructor.

=over

=item node1

 The first level of the hash heirarchy.

=item node2

 The second level of the hash heirarchy.

=back

=cut

sub new {
	my ($class, $node1, $node2) = @_;
	bless {_node1 => $node1, _node2 => $node2}, $class;
}



1;


