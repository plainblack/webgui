package WebGUI::Asset::File::ZipArchive;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset::File;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

use Archive::Tar;
use Archive::Zip;

our @ISA = qw(WebGUI::Asset::File);


=head1 NAME

Package WebGUI::Asset::ZipArchive

=head1 DESCRIPTION

Provides a mechanism to upload and automatically extract a zip archive
containing related items.  An asset setting will set the launch point of the archive.

=head1 SYNOPSIS

use WebGUI::Asset::ZipArchive;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub unzip {
   my $self = shift;
   my $storage = $_[0];
   my $filename = $_[1];
   
   my $filepath = $storage->getPath();
   chdir $filepath;
   
   if($filename =~ m/\.zip/i){
	  my $zip = Archive::Zip->new();
	  unless ($zip->read($filename) == $zip->AZ_OK){
	     WebGUI::ErrorHandler::warn(WebGUI::International::get("zip_error","Asset_ZipArchive"));
		 return 0;
	  }
	  $zip->extractTree();  
   } elsif($filename =~ m/\.tar/i){
      Archive::Tar->extract_archive($filepath.'/'.$filename,1);
	  if (Archive::Tar->error){
         WebGUI::ErrorHandler::warn(Archive::Tar->error);
	     return 0;
	  }
   } else{
      WebGUI::ErrorHandler::warn(WebGUI::International::get("bad_archive","Asset_ZipArchive"));
   }
   
   return 1;
}

#-------------------------------------------------------------------
=head2 addRevision

   This method exists for demonstration purposes only.  The superclass
   handles revisions to ZipArchive Assets.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->SUPER::addRevision(@_);
	return $newSelf;
}

#-------------------------------------------------------------------
=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
   my $class = shift;
   my $definition = shift;
   push(@{$definition}, {
      assetName=>WebGUI::International::get('assetName',"Asset_ZipArchive"),
      tableName=>'ZipArchiveAsset',
      className=>'WebGUI::Asset::File',
      properties=>{
         showPage=>{
	        fieldType=>'text',
            defaultValue=>'index.html'
         },
		 templateId=>{
		    fieldType=>'template',
		    defaultValue=>''
		 },
      }
   });
   return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------
=head2 duplicate

   This method exists for demonstration purposes only.  The superclass
   handles duplicating ZipArchive Assets.  This method will be called 
   whenever a copy action is executed

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	return $newAsset;
}


#-------------------------------------------------------------------
=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
   my $self = shift;
   my $tabform = $self->SUPER::getEditForm();
   $tabform->getTab("display")->template(
      -value=>$self->getValue("templateId"),
	  -label=>WebGUI::International::get('template label', 'Asset_ZipArchive'),
	  -namespace=>"ZipArchiveAsset"
   );
   $tabform->getTab("properties")->text (
      -name=>"showPage",
      -label=>WebGUI::International::get('show page', 'Asset_ZipArchive'),
	  -value=>$self->getValue("showPage"),
	  -hoverHelp=>WebGUI::International::get('show page description', 'Asset_ZipArchive'),
   );
   return $tabform;
}


#-------------------------------------------------------------------
=head2 getIcon ( [small] )

Returns the icons to be associated with this asset

=head3 small

If this evaluates to True, then the smaller icon is returned.

=cut

sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/ziparchive.gif' unless ($small);
    return $session{config}{extrasURL}.'/assets/small/ziparchive.gif';
}


#-------------------------------------------------------------------
=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  In this asset, we use
this method to deflate the zip file into the proper folder

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	#File should be saved here by the superclass
	$self->SUPER::processPropertiesFromFormPost;
	my $storage = $self->getStorageLocation();
	
	my $file = $self->get("filename");
	
	#return unless $file;
    unless($session{form}{showPage}) {
	   $storage->delete;
	   WebGUI::SQL->write("update FileAsset set filename=NULL where assetId=".quote($self->getId));
	   WebGUI::Session::setScratch("za_error",WebGUI::International::get("za_show_error","Asset_ZipArchive"));
	   return;
	}
	
	unless($file =~ m/\.tar/i || $file =~ m/\.zip/i) {
	   $storage->delete;
	   WebGUI::SQL->write("update FileAsset set filename=NULL where assetId=".quote($self->getId));
	   WebGUI::Session::setScratch("za_error",WebGUI::International::get("za_error","Asset_ZipArchive"));
	   return;
	}
	
	unless ($self->unzip($storage,$self->get("filename"))) {
	   WebGUI::ErrorHandler::warn(WebGUI::International::get("unzip_error","Asset_ZipArchive"));
	}
}


#-------------------------------------------------------------------
=head2 purge ( )

This method is called when data is purged by the system.

=cut

sub purge {
	my $self = shift;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

sub purgeRevision {
	my $self = shift;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the container www_view method.  In this asset, this is
used to show the file to administrators.

=cut

sub view {
	my $self = shift;
	my %var = %{$self->get};
	#WebGUI::ErrorHandler::warn($self->getId);
	$var{controls} = $self->getToolbar;
	if($session{scratch}{za_error}) {
	   $var{error} = $session{scratch}{za_error};
	}
	WebGUI::Session::deleteScratch("za_error");
	my $storage = $self->getStorageLocation;
	if($self->get("filename") ne "") {
	   $var{fileUrl} = $storage->getUrl($self->get("showPage"));
	   $var{fileIcon} = $storage->getFileIconUrl($self->get("showPage"));
	}
	unless($self->get("showPage")) {
	   $var{pageError} = "true";
	}
	return $self->processTemplate(\%var,$self->get("templateId"));
}


#-------------------------------------------------------------------
=head2 www_edit ( )

Web facing method which is the default edit page

=cut

sub www_edit {
   my $self = shift;
   return WebGUI::Privilege::insufficient() unless $self->canEdit;
   $self->getAdminConsole->setHelp("zip archive add/edit", "Asset_ZipArchive");
   return $self->getAdminConsole->render($self->getEditForm->print,
              WebGUI::International::get('zip archive add/edit title',"Asset_ZipArchive"));
}

#-------------------------------------------------------------------
=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	if (WebGUI::Session::isAdminOn()) {
		return $self->getContainer->www_view;
	}
	WebGUI::HTTP::setRedirect($self->getFileUrl($self->getValue("showPage")));
	return "";
}


1;

