package WebGUI::Wobject;

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

use CGI::Util qw(rearrange);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Node;
use WebGUI::Page;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Wobject

=head1 DESCRIPTION

An abstract class for all other wobjects to extend.

=head1 SYNOPSIS

 use WebGUI::Wobject;
 our @ISA = qw(WebGUI::Wobject);

See the subclasses in lib/WebGUI/Wobjects for details.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _reorderWobjects {
	my ($sth, $i, $wid);
	$sth = WebGUI::SQL->read("select wobjectId from wobject where pageId=$_[0] order by templatePosition,sequenceNumber");
	while (($wid) = $sth->array) {
		$i++;
		WebGUI::SQL->write("update wobject set sequenceNumber='$i' where wobjectId=$wid");
	}
	$sth->finish;
}


#-------------------------------------------------------------------
sub _getNextSequenceNumber {
	my ($sequenceNumber);
	($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from wobject where pageId='$_[0]'");
	return ($sequenceNumber+1);
}

#-------------------------------------------------------------------

=head2 confirm ( message, yesURL, [ , noURL, vitalComparison ] )

=over

=item message

A string containing the message to prompt the user for this action.

=item yesURL

A URL to the web method to execute if the user confirms the action.

=item noURL

A URL to the web method to execute if the user denies the action.  Defaults back to the current page.

=item vitalComparison

A comparison expression to be used when checking whether the action should be allowed to continue. Typically this is used when the action is a delete of some sort.

=back

=cut

sub confirm {
        return WebGUI::Privilege::vitalComponent() if ($_[4]);
	my $noURL = $_[3] || WebGUI::URL::page();
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= $_[1].'<p>';
        $output .= '<div align="center"><a href="'.$_[2].'">'.WebGUI::International::get(44).'</a>';
        $output .= ' &nbsp; <a href="'.$noURL.'">'.WebGUI::International::get(45).'</a></div>';
        return $output;
}


#-------------------------------------------------------------------

=head2 deleteCollateral ( tableName, keyName, keyValue )

Deletes a row of collateral data.

=over

=item tableName

The name of the table you wish to delete the data from.

=item keyName

The name of the column that is the primary key in the table.

=item keyValue

An integer containing the key value.

=back

=cut

sub deleteCollateral {
        WebGUI::SQL->write("delete from $_[1] where $_[2]=".quote($_[3]));
	WebGUI::ErrorHandler::audit("deleted ".$_[2]." ".$_[3]);
}


#-------------------------------------------------------------------

=head2 description ( )

Returns this instance's description if it exists.

=cut

sub description {
        if ($_[0]->get("description")) {
                return $_[0]->get("description").'<p>';
        }
}

#-------------------------------------------------------------------

=head2 displayTitle ( )

Returns this instance's title if displayTitle is set to yes.

=cut

sub displayTitle {
        if ($_[0]->get("displayTitle")) {
                return "<h1>".$_[0]->get("title")."</h1>";
        } else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 duplicate ( [ pageId ] )

Duplicates this wobject with a new wobject ID. Returns the new wobject Id.

NOTE: This method is meant to be extended by all sub-classes.

=over

=item pageId 

If specified the wobject will be duplicated to this pageId, otherwise it will be duplicated to the clipboard.

=back

=cut

sub duplicate {
	my %properties;
	tie %properties, 'Tie::CPHash';
	%properties = %{$_[0]->get};
	$properties{pageId} = $_[1] || 2;
	$properties{sequenceNumber} = _getNextSequenceNumber($properties{pageId});
	my $page = WebGUI::SQL->quickHashRef("select groupIdView,ownerId,groupIdEdit from page where pageId=".$properties{pageId});
	$properties{ownerId} = $page->{ownerId};
        $properties{groupIdView} = $page->{groupIdView};
        $properties{groupIdEdit} = $page->{groupIdEdit};
	if ($properties{pageId} == 2)  {
		$properties{bufferUserId} = $session{user}{userId};
		$properties{bufferDate} = time();
		$properties{bufferPrevId} = {};
	}
	delete $properties{wobjectId};
	my $cmd = "WebGUI::Wobject::".$properties{namespace};
        my $w = eval{$cmd->new({namespace=>$properties{namespace},wobjectId=>"new"})};
        if ($@) {
        	WebGUI::ErrorHandler::warn("Couldn't duplicate wobject ".$properties{namespace}." because: ".$@);
	}
	$w->set(\%properties);
        return $w->get("wobjectId");
}

#-------------------------------------------------------------------

=head2 fileProperty ( name, labelId )

Returns a file property form row which can be used in any Wobject properties page. 

NOTE: This method is meant for use with www_deleteFile.

=over

=item name

The name of the property that stores the filename.

=item labelId

The internationalId of the form label for this file.

=back

=cut

sub fileProperty {
        my ($self, $f, $labelId, $name);
	$self = shift;
        $name = shift;
        $labelId = shift;
        $f = WebGUI::HTMLForm->new;
        if ($self->get($name) ne "") {
                $f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&file='.$name.'&wid='.$self->get("wobjectId")).'">'.
                        WebGUI::International::get(391).'</a>',
			WebGUI::International::get($labelId,$self->get("namespace")));
        } else {
                $f->file($name,WebGUI::International::get($labelId,$self->get("namespace")));
        }
        return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 get ( [ propertyName ] )

Returns a hash reference containing all of the properties of this wobject instance.

=over

=item propertyName

If an individual propertyName is specified, then only that property value is returned as a scalar.

=back

=cut

sub get {
        if ($_[1] ne "") {
                return $_[0]->{_property}{$_[1]};
        } else {
                return $_[0]->{_property};
        }
}


#-------------------------------------------------------------------

=head2 getCollateral ( tableName, keyName, keyValue ) 

Returns a hash reference containing a row of collateral data.

=over

=item tableName

The name of the table you wish to retrieve the data from.

=item keyName

The name of the column that is the primary key in the table.

=item keyValue

An integer containing the key value. If key value is equal to "new" or null, then an empty hashRef containing only keyName=>"new" will be returned to avoid strict errors.

=back

=cut

sub getCollateral {
	my ($class, $tableName, $keyName, $keyValue) = @_;
	if ($keyValue eq "new" || $keyValue eq "") {
		return {$keyName=>"new"};
	} else {
		return WebGUI::SQL->quickHashRef("select * from $tableName where $keyName=".quote($keyValue));
	}
}


#-------------------------------------------------------------------

=head2 getDefaultValue ( propertyName )

Returns the default value for a wobject property.

=over

=item propertyName

The name of the property to retrieve the default value for.

=back

=cut

sub getDefaultValue {
	if (exists $_[0]->{_extendedProperties}{$_[1]}{defaultValue}) {
		return $_[0]->{_extendedProperties}{$_[1]}{defaultValue};
	} elsif (exists $_[0]->{_wobjectProperties}{$_[1]}{defaultValue}) {
		return $_[0]->{_wobjectProperties}{$_[1]}{defaultValue};
	} else {
		return undef;
	}
}


#-------------------------------------------------------------------

=head2 getValue ( propertyName )

Returns a value for a wobject property however possible. It first looks in form variables for the property, then looks to the value stored in the wobject instance, and if all else fails it returns the default value for the property.

=over

=item propertyName

The name of the property to retrieve the value for.

=back

=cut

sub getValue {
	my $currentValue = $_[0]->get($_[1]);
	if (exists $session{form}{$_[1]}) {
		return $session{form}{$_[1]};
	} elsif (defined $currentValue) {
		return $_[0]->get($_[1]);
	} else {
		return $_[0]->getDefaultValue($_[1]);
	}
}



#-------------------------------------------------------------------

=head2 inDateRange ( )

Returns a boolean value of whether the wobject should be displayed based upon it's start and end dates.

=cut

sub inDateRange {
	if ($_[0]->get("startDate") < time() && $_[0]->get("endDate") > time()) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 moveCollateralDown ( tableName, idName, id [ , setName, setValue ] )

Moves a collateral data item down one position. This assumes that the collateral data table has a column called "wobjectId" that identifies the wobject, and a column called "sequenceNumber" that determines the position of the data item.

=over

=item tableName

A string indicating the table that contains the collateral data.

=item idName

A string indicating the name of the column that uniquely identifies this collateral data item.

=item id

An integer that uniquely identifies this collateral data item.

=item setName

By default this method assumes that the collateral will have a wobject id in the table. However, since there is not always a wobject id to separate one data set from another, you may specify another field to do that.

=item setValue

The value of the column defined by "setName" to select a data set from.

=back

=cut

### NOTE: There is a redundant use of wobjectId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralDown {
        my ($id, $seq, $setName, $setValue);
	$setName = $_[4] || "wobjectId";
	$setValue = $_[5] || $_[0]->get($setName);
        ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $_[1] where $_[2]=$_[3] and $setName=".quote($setValue));
        ($id) = WebGUI::SQL->quickArray("select $_[2] from $_[1] where $setName=".quote($setValue)
		." and sequenceNumber=$seq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber+1 where $_[2]=$_[3] and $setName="
			.quote($setValue));
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber-1 where $_[2]=$id and $setName="
			.quote($setValue));
         }
}

#-------------------------------------------------------------------

=head2 moveCollateralUp ( tableName, idName, id [ , setName, setValue ] )

Moves a collateral data item up one position. This assumes that the collateral data table has a column called "wobjectId" that identifies the wobject, and a column called "sequenceNumber" that determines the position of the data item.

=over

=item tableName

A string indicating the table that contains the collateral data.

=item idName

A string indicating the name of the column that uniquely identifies this collateral data item.

=item id

An integer that uniquely identifies this collateral data item.

=item setName

By default this method assumes that the collateral will have a wobject id in the table. However, since there is not always a wobject id to separate one data set from another, you may specify another field to do that.

=item setValue

The value of the column defined by "setName" to select a data set from.

=back

=cut

### NOTE: There is a redundant use of wobjectId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralUp {
        my ($id, $seq, $setValue, $setName);
        $setName = $_[4] || "wobjectId";
        $setValue = $_[5] || $_[0]->get($setName);
        ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $_[1] where $_[2]=$_[3] and $setName=".quote($setValue));
        ($id) = WebGUI::SQL->quickArray("select $_[2] from $_[1] where $setName=".quote($setValue)
		." and sequenceNumber=$seq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber-1 where $_[2]=$_[3] and $setName="
			.quote($setValue));
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber+1 where $_[2]=$id and $setName="
			.quote($setValue));
        }
}

#-------------------------------------------------------------------

=head2 name ( )

This method should be overridden by all wobjects and should return an internationalized human friendly name for the wobject. This method only exists in the super class for reverse compatibility and will try to look up the name based on the old name definition.

=cut

sub name {
	my $namespace = $_[0]->get("namespace");
	if ($namespace eq "") {
		WebGUI::ErrorHandler::warn("No namespace available in this wobject instance.");
		return "! Unknown Wobject !";
	} else {
		my $cmd = "\$WebGUI::Wobject::".$namespace."::name";
		my $name = eval($cmd);
		if ($name eq "") {
			WebGUI::ErrorHandler::warn($namespace." does not appear to have any sort of name definition at all.");
			return $namespace;
		}
		return $name;
	}
} 


#-------------------------------------------------------------------

=head2 new ( -properties, -extendedProperties [, -useDiscussion ] )

Constructor.

NOTE: This method should never need to be overridden or extended.

=over

=item -properties

A hash reference containing at minimum "wobjectId" and "namespace". wobjectId may be set to "new" if you're creating a new instance. This hash reference should be the one created by WebGUI.pm and passed to the wobject subclass.

NOTE: It may seem a little weird that the initial data for the wobject instance is coming from WebGUI.pm, but this was done to lessen database traffic thus increasing the speed of all wobjects.

=item -extendedProperties

A hash reference containing the properties that extend the wobject class. They should match the properties that are added to this wobject's namespace table in the database. So if this wobject has a namespace of "MyWobject" and a table definition that looks like this:

 create MyWobject (
	wobjectId int not null primary key,
	something varchar(25),
	isCool int not null default 0,
	foo int not null default 1,
	bar text
 );

Then the extended property list would be:
 	{
 		something=>{
			fieldType=>"text"
			},
		isCool=>{
			fieldType=>"yesNo",
			defaultValue=>1
			},
		foo=>{
			fieldType=>"integer",
			defaultValue=>1
			},
		bar=>{
			fieldType=>"textarea"
			}
 	}

NOTE: This is used to define the wobject and should only be passed in by a wobject subclass.

=item -useDiscussion

Defaults to "0". If set to "1" this will add a discussion properties tab to this wobject to enable content managers to set the properties of a discussion attached to this wobject.

NOTE: This is used to define the wobject and should only be passed in by a wobject subclass.

=item -useTemplate

Defaults to "0". If set to "1" this will add a template field to the wobject to enable content managers to select a template to layout this wobject.

NOTE: This is used to define the wobject and should only be passed in by a wobject subclass.

=back

=cut

sub new {
	my ($self, @p) = @_;
 	my ($properties, $extendedProperties, $useTemplate, $useDiscussion);
	if (ref $_[1] eq "HASH") {
		$properties = $_[1]; # reverse compatibility prior to 5.2
	} else {
		($properties, $extendedProperties, $useDiscussion, $useTemplate) = 
			rearrange([qw(properties extendedProperties useDiscussion useTemplate)], @p);
	} 
	$useDiscussion = 0 unless ($useDiscussion);
	$useTemplate = 0 unless ($useTemplate);
	my $wobjectProperties = {
		userDefined1=>{
			fieldType=>"text"
		},
		userDefined2=>{
			fieldType=>"text"
			}, 
		userDefined3=>{
			fieldType=>"text"
			}, 
		userDefined4=>{
			fieldType=>"text"
			}, 
		userDefined5=>{
			fieldType=>"text"
			}, 
		bufferUserId=>{
			fieldType=>"hidden"
			}, 
		bufferDate=>{
			fieldType=>"hidden"
			}, 
		bufferPrevId=>{
			fieldType=>"hidden"
			}, 
		forumId=>{
			fieldType=>"hidden"
			},
		allowDiscussion=>{
			fieldType=>"yesNo",
			defaultValue=>0
			},
		title=>{
			fieldType=>"text",
			defaultValue=>$_[0]->get("namespace")
			}, 
		templateId=>{
			fieldType=>"template",
			defaultValue=>1
			},
		displayTitle=>{
			fieldType=>"yesNo",
			defaultValue=>1
			}, 
		description=>{
			fieldType=>"textarea",
			fieldType=>"HTMLArea"
			},
 		pageId=>{
			fieldType=>"hidden",
			defaultValue=>$session{page}{pageId}
			}, 
		templatePosition=>{
			fieldType=>"selectList",
			defaultValue=>1
			}, 
		startDate=>{
			defaultValue=>$session{page}{startDate},
			fieldType=>"dateTime"
			},
		endDate=>{
			defaultValue=>$session{page}{endDate},
			fieldType=>"dateTime"
			},
		ownerId=>{
		    defaultValue=>$session{page}{ownerId},
			fieldType=>"group" 
		    }, 
		groupIdView=>{
		    defaultValue=>$session{page}{groupIdView},
			fieldType=>"group" 
		    }, 
		groupIdEdit=>{
		    defaultValue=>$session{page}{groupIdEdit},
			fieldType=>"group" 
		    }, 
		sequenceNumber=>{
			fieldType=>"hidden"
			}
		};
	my %fullProperties;
	my $extra = WebGUI::SQL->quickHashRef("select * from ".$properties->{namespace}." where wobjectId='".$properties->{wobjectId}."'");
        tie %fullProperties, 'Tie::CPHash';
        %fullProperties = (%{$properties},%{$extra});
        bless({
		_property=>\%fullProperties, 
		_useTemplate=>$useTemplate,
		_useDiscussion=>$useDiscussion,
		_wobjectProperties=>$wobjectProperties,
		_extendedProperties=>$extendedProperties
		}, 
		$self);
}

#-------------------------------------------------------------------

=head2 processMacros ( output )

 Decides whether or not macros should be processed and returns the
 appropriate output.

=over

=item output

 An HTML blob to be processed for macros.

=back

=cut

sub processMacros {
	return WebGUI::Macro::process($_[1]);
}

#-------------------------------------------------------------------

=head2 processTemplate ( templateId, vars [ , namespace ] ) 

Returns the content generated from this template.

NOTE: Only for use in wobjects that support templates.

=over

=item templateId

An id referring to a particular template in the templates table.

=item hashRef

A hash reference containing variables and loops to pass to the template engine.

=item namespace

A namespace to use for the template. Defaults to the wobject's namespace.

=back

=cut

sub processTemplate {
	my %vars = (
		%{$_[0]->{_property}},
		%{$_[2]}
		);
	if (defined $_[0]->get("_WobjectProxy")) {
		$vars{isShortcut} = 1;
		my ($originalPageURL) = WebGUI::SQL->quickArray("select urlizedTitle from page where pageId=".$_[0]->get("pageId"));
		$vars{originalURL} = WebGUI::URL::gateway($originalPageURL."#".$_[0]->get("wobjectId"));
	}
	my $namespace = $_[3] || $_[0]->get("namespace");
	return WebGUI::Template::process(WebGUI::Template::get($_[1],$namespace), \%vars);
}

#-------------------------------------------------------------------

=head2 purge ( )

Removes this wobject from the database and all it's attachments from the filesystem.

NOTE: This method is meant to be extended by all sub-classes.

=cut

sub purge {
	if ($_[0]->get("forumId")) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from wobject where forumId=".$_[0]->get("forumId"));
                unless ($inUseElsewhere > 1) {
			my $forum = WebGUI::Forum->new($_[0]->get("forumId"));
			$forum->purge;
		}
	}
	WebGUI::SQL->write("delete from ".$_[0]->get("namespace")." where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from wobject where wobjectId=".$_[0]->get("wobjectId"));
	my $node = WebGUI::Node->new($_[0]->get("wobjectId"));
	$node->delete;
}


#-------------------------------------------------------------------

=head2 reorderCollateral ( tableName, keyName [ , setName, setValue ] )

Resequences collateral data. Typically useful after deleting a collateral item to remove the gap created by the deletion.

=over

=item tableName

The name of the table to resequence.

=item keyName

The key column name used to determine which data needs sorting within the table.

=item setName

Defaults to "wobjectId". This is used to define which data set to reorder.

=item setValue

Used to define which data set to reorder. Defaults to the wobjectId for this instance. Defaults to the value of "setName" in the wobject properties.

=back

=cut

sub reorderCollateral {
        my ($sth, $i, $id, $setName, $setValue);
	$i = 1;
	$setName = $_[3] || "wobjectId";
	$setValue = $_[4] || $_[0]->get($setName);
        $sth = WebGUI::SQL->read("select $_[2] from $_[1] where $setName=".quote($setValue)." order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=$i where $setName=".quote($setValue)." and $_[2]=$id");
                $i++;
        }
        $sth->finish;
}



#-------------------------------------------------------------------

=head2 set ( [ hashRef ] )

Stores the values specified in hashRef to the database.

=over

=item hashRef 

A hash reference of the properties to set for this wobject instance. 

=back

=cut

sub set {
	my ($key, $sql, @update, $i);
	my $self = shift;
	my $properties = shift;
	my $extendedProperties = shift; # shift for backward compatibility.
	unless (defined $extendedProperties) {
		my @temp;
		foreach (keys %{$self->{_extendedProperties}}) {
			push(@temp,$_);
		}
		$extendedProperties = \@temp;
	}
	my @temp;
        foreach (keys %{$self->{_wobjectProperties}}) {
        	push(@temp,$_);
        }
        my $wobjectProperties = \@temp;
	if ($self->{_property}{wobjectId} eq "new") {
		$self->{_property}{wobjectId} = getNextId("wobjectId");
		$self->{_property}{pageId} = ${$_[1]}{pageId} || $session{page}{pageId};
		$self->{_property}{sequenceNumber} = _getNextSequenceNumber($self->{_property}{pageId});
		$self->{_property}{addedBy} = $session{user}{userId};
		$self->{_property}{dateAdded} = time();
		WebGUI::SQL->write("insert into wobject 
			(wobjectId, namespace, dateAdded, addedBy, sequenceNumber, pageId) 
			values (
			".$self->{_property}{wobjectId}.", 
			".quote($self->{_property}{namespace}).",
			".$self->{_property}{dateAdded}.",
			".$self->{_property}{addedBy}.",
			".$self->{_property}{sequenceNumber}.",
			".$self->{_property}{pageId}."
			)");
		WebGUI::SQL->write("insert into ".$self->{_property}{namespace}." (wobjectId) 
			values (".$self->{_property}{wobjectId}.")");
		foreach my $key (keys %{$self->{_extendedProperties}}) {
			if ($self->{_extendedProperties}{$key}{autoIncrement}) {
				$properties->{$key} = getNextId($key);
			}
		}
	}
	$self->{_property}{lastEdited} = time();
	$self->{_property}{editedBy} = $session{user}{userId};
	$sql = "update wobject set";
	foreach $key (keys %{$properties}) {
		$self->{_property}{$key} = ${$properties}{$key};
		if (isIn($key, @{$wobjectProperties})) {
        		$sql .= " ".$key."=".quote(${$properties}{$key}).",";
		}
                if (isIn($key, @{$extendedProperties})) {
                        $update[$i] .= " ".$key."=".quote($properties->{$key});
                        $i++;
                }
	}
	$sql .= " lastEdited=".$self->{_property}{lastEdited}.", 
		editedBy=".$self->{_property}{editedBy}." 
		where wobjectId=".$self->{_property}{wobjectId};
	WebGUI::SQL->write($sql);
	if (@update) {
        	WebGUI::SQL->write("update ".$self->{_property}{namespace}." set ".join(",",@update)." 
			where wobjectId=".$self->{_property}{wobjectId});
	}
	WebGUI::ErrorHandler::audit("edited Wobject ".$self->{_property}{wobjectId});	
}


#-----------------------------------------------------------------

=head2 setCollateral ( tableName, keyName, properties [ , useSequenceNumber, useWobjectId, setName, setValue ] )

Performs and insert/update of collateral data for any wobject's collateral data. Returns the primary key value for that row of data.

=over

=item tableName

The name of the table to insert the data.

=item keyName

The column name of the primary key in the table specified above.  This must also be an incrementerId in the incrementer table.

=item properties

A hash reference containing the name/value pairs to be inserted into the database where the name is the column name. Note that the primary key should be specified in this list, and if it's value is "new" or null a new row will be created.

=item useSequenceNumber

If set to "1", a new sequenceNumber will be generated and inserted into the row. Note that this means you must have a sequenceNumber column in the table. Also note that this requires the presence of the wobjectId column. Defaults to "1".

=item useWobjectId

If set to "1", the current wobjectId will be inserted into the table upon creation of a new row. Note that this means the table better have a wobjectId column. Defaults to "1".  

=item setName

If this collateral data set is not grouped by wobjectId, but by another column then specify that column here. The useSequenceNumber parameter will then use this column name instead of wobjectId to generate the sequenceNumber.

=item setValue

If you've specified a setName you may also set a value for that set.  Defaults to the value for this id from the wobject properties.

=back

=cut

sub setCollateral {
	my ($key, $sql, $seq, $dbkeys, $dbvalues, $counter);
	my ($class, $table, $keyName, $properties, $useSequence, $useWobjectId, $setName, $setValue) = @_;
	$counter = 0;
	$setName = $setName || "wobjectId";
	$setValue = $setValue || $_[0]->get($setName);
	if ($properties->{$keyName} eq "new" || $properties->{$keyName} eq "") {
		$properties->{$keyName} = getNextId($keyName);
		$sql = "insert into $table (";
		$dbkeys = "";
     		$dbvalues = "";
		unless ($useSequence eq "0") {
			unless (exists $properties->{sequenceNumber}) {
				($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from $table 
                               		where $setName=".quote($setValue));
				$properties->{sequenceNumber} = $seq+1;
			}
		} 
		unless ($useWobjectId eq "0") {
			$properties->{wobjectId} = $_[0]->get("wobjectId");
		}
		foreach $key (keys %{$properties}) {
			if ($counter++ > 0) {
				$dbkeys .= ',';
				$dbvalues .= ',';
			}
			$dbkeys .= $key;
			$dbvalues .= quote($properties->{$key});
		}
		$sql .= $dbkeys.') values ('.$dbvalues.')';
		WebGUI::ErrorHandler::audit("added ".$table." ".$properties->{$keyName});
	} else {
		$sql = "update $table set ";
		foreach $key (keys %{$properties}) {
			unless ($key eq "sequenceNumber") {
				$sql .= ',' if ($counter++ > 0);
				$sql .= $key."=".quote($properties->{$key});
			}
		}
		$sql .= " where $keyName='".$properties->{$keyName}."'";
		WebGUI::ErrorHandler::audit("edited ".$table." ".$properties->{$keyName});
	}
  	WebGUI::SQL->write($sql);
	$_[0]->{_property}{lastEdited} = time();
        $_[0]->{_property}{editedBy} = $session{user}{userId};
	WebGUI::SQL->write("update wobject set lastEdited=".$_[0]->{_property}{lastEdited}
		.", editedBy=".$_[0]->{_property}{editedBy}." where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->reorderCollateral($table,$keyName,$setName,$setValue) if ($properties->{sequenceNumber} < 0);
	return $properties->{$keyName};
}


#-------------------------------------------------------------------

=head2 uiLevel

Returns the UI Level of a wobject. Defaults to "0" for all wobjects.  Override to set the UI Level higher for a given wobject.

=cut

sub uiLevel {
	return 0;
}

#-------------------------------------------------------------------

=head2 www_copy ( )

Copies this instance to the clipboard.

NOTE: Should never need to be overridden or extended.

=cut

sub www_copy {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->duplicate;
        return "";
}

#-------------------------------------------------------------------

=head2 www_createShortcut ( )

Creates a shortcut (using the wobject proxy) of this wobject on the clipboard.

NOTE: Should never need to be overridden or extended.

=cut

sub www_createShortcut {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my $w = WebGUI::Wobject::WobjectProxy->new({wobjectId=>"new",namespace=>"WobjectProxy"});
	$w->set({
		pageId=>2,
		templatePosition=>1,
		title=>$_[0]->getValue("title"),
		proxiedNamespace=>$_[0]->get("namespace"),
		proxiedWobjectId=>$_[0]->get("wobjectId"),
	    	bufferUserId=>$session{user}{userId},
		bufferDate=>time(),
		bufferPrevId=>$session{page}{pageId}
		});
        return "";
}

#-------------------------------------------------------------------

=head2 www_cut ( )

Moves this instance to the clipboard.

=cut

sub www_cut {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->set({
		pageId=>2, 
		templatePosition=>1,
	    	bufferUserId=>$session{user}{userId},
		bufferDate=>time(),
		bufferPrevId=>$session{page}{pageId}
		});
	_reorderWobjects($session{page}{pageId});
        return "";
}

#-------------------------------------------------------------------

=head2 www_delete ( )

Prompts a user to confirm whether they wish to delete this instance.

=cut

sub www_delete {
        my ($output);
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
                $output = helpIcon(14);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(43);
		$output .= '<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteConfirm&wid='.
			$_[0]->get("wobjectId")).'">';
		$output .= WebGUI::International::get(44); 
		$output .= '</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">';
		$output .= WebGUI::International::get(45);
		$output .= '</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2  www_deleteConfirm ( )

Moves this instance to the trash.

=cut

sub www_deleteConfirm {
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
		$_[0]->set({pageId=>3, templatePosition=>1,
                        bufferUserId=>$session{user}{userId},
                        bufferDate=>time(),
                        bufferPrevId=>$session{page}{pageId}});
		WebGUI::ErrorHandler::audit("moved Wobject ".$_[0]->{_property}{wobjectId}." to the trash.");
		_reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_deleteFile ( )

Displays a confirmation message relating to the deletion of a file.

=cut

sub www_deleteFile {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(WebGUI::International::get(728),
                WebGUI::URL::page('func=deleteFileConfirm&wid='.$_[0]->get("wobjectId").'&file='.$session{form}{file}),
                WebGUI::URL::page('func=edit&wid='.$_[0]->get("wobjectId"))
                );
}

#-------------------------------------------------------------------

=head2 www_deleteFileConfirm ( )

Deletes a file from this instance.

=cut

sub www_deleteFileConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->set({$session{form}{file}=>''});
        return $_[0]->www_edit();
}

#-------------------------------------------------------------------

=head2 www_edit ( [ -properties, -layout, -privileges, -helpId, -heading, -headingId ] ) 

Displays the common properties of any/all wobjects. 

=over

=item -properties, -layout, -privileges 

WebGUI::HTMLForm objects that extend these tabs.

=item -helpId

An id in this namespace in the WebGUI help system for this edit page. If specified a help link will be created on the edit page.

=item -heading

A text string to put in the heading of this page.

=item -headingId

An id this namespace of the WebGUI international system. This message will be retrieved and displayed in the heading of this edit page.

=back

=cut

sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$session{page}{useAdminStyle} = 1;
	my ($self, @p) = @_;
        my ($properties, $layout, $privileges, $heading, $helpId, $headingId) = 
		rearrange([qw(properties layout privileges heading helpId headingId)], @p);
        my ($f, $startDate, $displayTitle, $templatePosition, $endDate);
        if ($_[0]->get("wobjectId") eq "new") {
               	$displayTitle = 1;
        } else {
        	$displayTitle = $_[0]->get("displayTitle");
        }
	my $title = $_[0]->get("title") || $_[0]->name;
	$templatePosition = $_[0]->get("templatePosition") || 1;
	$startDate = $_[0]->get("startDate") || $session{page}{startDate};
	$endDate = $_[0]->get("endDate") || $session{page}{endDate};
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	%tabs = (	
		properties=>{
			label=>WebGUI::International::get(893)
			},
		layout=>{
                        label=>WebGUI::International::get(105),
                        uiLevel=>5
                        },
                privileges=>{
                        label=>WebGUI::International::get(107),
                        uiLevel=>6
                        }
		);
	if ($_[0]->{_useDiscussion}) {
		$tabs{discussion} = {
			label=>WebGUI::International::get(892),
			uiLevel=>5
			};
	}
	$f = WebGUI::TabForm->new(\%tabs);
	$f->hidden({name=>"wid",value=>$_[0]->get("wobjectId")});
	$f->hidden({name=>"namespace",value=>$_[0]->get("namespace")}) if ($_[0]->get("wobjectId") eq "new");
	$f->hidden({name=>"func",value=>"editSave"});
	$f->getTab("properties")->readOnly(
		-value=>$_[0]->get("wobjectId"),
		-label=>WebGUI::International::get(499),
		-uiLevel=>3
		);
	$f->getTab("properties")->text("title",WebGUI::International::get(99),$title);
	$f->getTab("layout")->yesNo(
		-name=>"displayTitle",
		-label=>WebGUI::International::get(174),
		-value=>$displayTitle,
		-uiLevel=>5
		);
	if ($_[0]->{_useTemplate}) {
		$f->getTab("layout")->template(
                	-value=>$_[0]->getValue("templateId"),
                	-namespace=>$_[0]->get("namespace"),
                	-afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                	);
	}
	$f->getTab("layout")->selectList(
		-name=>"templatePosition",
		-label=>WebGUI::International::get(363),
		-value=>[$templatePosition],
		-uiLevel=>5,
		-options=>WebGUI::Page::getTemplatePositions($session{page}{templateId}),
		-subtext=>WebGUI::Page::drawTemplate($session{page}{templateId})
		);
	$f->getTab("privileges")->dateTime(
		-name=>"startDate",
		-label=>WebGUI::International::get(497),
		-value=>$startDate,
		-uiLevel=>6
		);
	$f->getTab("privileges")->dateTime(
		-name=>"endDate",
		-label=>WebGUI::International::get(498),
		-value=>$endDate,
		-uiLevel=>6
		);
	my $subtext;
	if (WebGUI::Privilege::isInGroup(3)) {
		$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listUsers').'">'.WebGUI::International::get(7).'</a>';
	} else {
	   $subtext = "";
    	}
	if ($session{page}{wobjectPrivileges}) {
	    	my $clause; 
		if (WebGUI::Privilege::isInGroup(3)) {
	   		my $contentManagers = WebGUI::Grouping::getUsersInGroup(4,1);
		   	push (@$contentManagers, $session{user}{userId});
		   	$clause = "userId in (".join(",",@$contentManagers).")";
	    	} else {
		   	$clause = "userId=".$_[0]->getValue("ownerId");
	    	}
		my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
		$f->getTab("privileges")->selectList(
		   -name=>"ownerId",
		   -options=>$users,
		   -label=>WebGUI::International::get(108),
		   -value=>[$_[0]->getValue("ownerId")],
		   -subtext=>$subtext,
		   -uiLevel=>6
		);
		if (WebGUI::Privilege::isInGroup(3)) {
		   $subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listGroups').'">'.WebGUI::International::get(5).'</a>';
		} else {
		   $subtext = "";
		}
		$f->getTab("privileges")->group(
			-name=>"groupIdView",
			-label=>WebGUI::International::get(872),
			-value=>[$_[0]->getValue("groupIdView")],
			-subtext=>$subtext,
			-uiLevel=>6
		);
	    	$f->getTab("privileges")->group(
        		-name=>"groupIdEdit",
	        	-label=>WebGUI::International::get(871),
	        	-value=>[$_[0]->getValue("groupIdEdit")],
		        -subtext=>$subtext,
	    		-excludeGroups=>[1,7],
	        	-uiLevel=>6
   		);
	} else {
		$f->hidden({name=>"ownerId",value=>$_[0]->getValue("ownerId")});
		$f->hidden({name=>"groupIdView",value=>$_[0]->getValue("groupIdView")});
		$f->hidden({name=>"groupIdEdit",value=>$_[0]->getValue("groupIdEdit")});
	}
	$f->getTab("properties")->HTMLArea(
		-name=>"description",
		-label=>WebGUI::International::get(85),
		-value=>$_[0]->get("description")
		);
	$f->getTab("properties")->raw($properties);
	$f->getTab("layout")->raw($layout);
	$f->getTab("privileges")->raw($privileges);
	if ($_[0]->{_useDiscussion}) {
		$f->getTab("discussion")->yesNo(
                	-name=>"allowDiscussion",
                	-label=>WebGUI::International::get(894),
                	-value=>$_[0]->get("allowDiscussion"),
                	-uiLevel=>5
                	);
		$f->getTab("discussion")->raw(WebGUI::Forum::UI::forumProperties($_[0]->get("forumId")));
	}
	my $output;
	$output = helpIcon($helpId,$_[0]->get("namespace")) if ($helpId);
	$heading = WebGUI::International::get($headingId,$_[0]->get("namespace")) if ($headingId);
        $output .= '<h1>'.$heading.'</h1>' if ($heading);
	return $output.$f->print; 
}

#-------------------------------------------------------------------

=head2 www_editSave ( [ hashRef ] )

Saves the default properties of any/all wobjects.

NOTE: This method should only need to be extended if you need to do some special validation.

=over

=item hashRef

A hash reference of extra properties to set.

=back

=cut

sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my %set;
	foreach my $key (keys %{$_[0]->{_wobjectProperties}}) {
		my $temp = WebGUI::FormProcessor::process(
			$key,
			$_[0]->{_wobjectProperties}{$key}{fieldType},
			$_[0]->{_wobjectProperties}{$key}{defaultValue}
			);
		$set{$key} = $temp if (defined $temp);
	}
	$set{title} = $session{form}{title} || $_[0]->name;
	foreach my $key (keys %{$_[0]->{_extendedProperties}}) {
		my $temp = WebGUI::FormProcessor::process(
			$key,
			$_[0]->{_extendedProperties}{$key}{fieldType},
			$_[0]->{_extendedProperties}{$key}{defaultValue}
			);
		$set{$key} = $temp if (defined $temp);
	}
	%set = (%set, %{$_[1]});
	$set{forumId} = WebGUI::Forum::UI::forumPropertiesSave()  if ($_[0]->{_useDiscussion});
	$_[0]->set(\%set);
	return "";
}

#-------------------------------------------------------------------

=head2 www_moveBottom ( )

Moves this instance to the bottom of the page.

=cut

sub www_moveBottom {
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
		$_[0]->set({sequenceNumber=>99999});
		_reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_moveDown ( )

Moves this instance down one spot on the page.

=cut

sub www_moveDown {
	my ($wid, $thisSeq);
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
		($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from wobject where wobjectId=".$_[0]->get("wobjectId"));
		($wid) = WebGUI::SQL->quickArray("select wobjectId from wobject where pageId=".$_[0]->get("pageId")
			." and sequenceNumber=".($thisSeq+1));
		if ($wid ne "") {
                	WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber+1 where wobjectId=".$_[0]->get("wobjectId"));
                	WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber-1 where wobjectId=$wid");
                	_reorderWobjects($_[0]->get("pageId"));
		}
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_moveTop ( )

Moves this instance to the top of the page.

=cut

sub www_moveTop {
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
                $_[0]->set({sequenceNumber=>0});
                _reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_moveUp ( )

Moves this instance up one spot on the page.

=cut

sub www_moveUp {
        my ($wid, $thisSeq);
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from wobject where wobjectId=".$_[0]->get("wobjectId"));
                ($wid) = WebGUI::SQL->quickArray("select wobjectId from wobject where pageId=".$_[0]->get("pageId")
			." and sequenceNumber=".($thisSeq-1));
                if ($wid ne "") {
                        WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber-1 where wobjectId=".$_[0]->get("wobjectId"));
                        WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber+1 where wobjectId=$wid");
                	_reorderWobjects($_[0]->get("pageId"));
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_paste ( )

Moves this instance from the clipboard to the current page.

=cut

sub www_paste {
        my ($output, $nextSeq);
        if (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"))) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from wobject where pageId=$session{page}{pageId}");
		$nextSeq += 1;
		WebGUI::SQL->write("UPDATE wobject SET "
					."pageId=". $session{page}{pageId} .", "
					."templatePosition=1, "
					."sequenceNumber=". $nextSeq .", "
                            		."bufferUserId=NULL, bufferDate=NULL, bufferPrevId=NULL "
					."WHERE wobjectId=". $session{form}{wid} );
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_view ( )

The default display mechanism for any wobject. This web method MUST be overridden.

=cut

sub www_view {
	my ($output);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
	return $output;
}

1;
