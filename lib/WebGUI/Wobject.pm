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
sub _validateField {
	my ($key, $type) = @_;
	if ($type eq "date") {
        	return WebGUI::DateTime::setToEpoch($session{form}{$key});
        } elsif ($type eq "interval") {
        	return (WebGUI::DateTime::intervalToSeconds($session{form}{$key."_interval"},$session{form}{$key."_units"}) || 0);
        } elsif ($type eq "HTMLArea") {
        	return WebGUI::HTML::cleanSegment($session{form}{$key});
        } else {
		return $session{form}{$key};
	}
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
        my ($output, $noURL);
        if ($_[4]) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
		$noURL = $_[3] || WebGUI::URL::page();
                $output = '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= $_[1].'<p>';
                $output .= '<div align="center"><a href="'.$_[2].'">'.WebGUI::International::get(44).'</a>';
                $output .= ' &nbsp; <a href="'.$noURL.'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
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

=head2 discussionProperties ( )

Returns a formRow list of discussion properties, which may be attached to any Wobject.

=cut

sub discussionProperties {
        my ($f,$editTimeout,$interval, $units, $groupToModerate,%moderationType,$moderationType);
        %moderationType = (before=>WebGUI::International::get(567),after=>WebGUI::International::get(568));
        $f = WebGUI::HTMLForm->new;
        if ($_[0]->get("wobjectId") eq "new") {
                $editTimeout = 3600;
                $moderationType = 'after';
        } else {
                $editTimeout = $_[0]->get("editTimeout");
                $moderationType = $_[0]->get("moderationType");
        }
	my $filterPost = $_[0]->get("filterPost") || "most";
	$f->filterContent(
		-name=>"filterPost",
		-value=>$filterPost,
		-label=>WebGUI::International::get(1,"Discussion"),
		-uiLevel=>7
		);
        $groupToModerate = $_[0]->get("groupToModerate") || 4;
        $f->group(
		-name=>"groupToPost",
		-label=>WebGUI::International::get(564),
		-value=>[$_[0]->get("groupToPost")],
		-uiLevel=>7
		);
	($interval, $units) = WebGUI::DateTime::secondsToInterval($editTimeout);
        $f->interval(
		-name=>"editTimeout",
		-label=>WebGUI::International::get(566),
		-intervalValue=>$interval,
		-unitsValue=>$units,
		-uiLevel=>7
		);
        if ($session{setting}{useKarma} && $session{user}{uiLevel} <= 7) {
                $f->integer("karmaPerPost",WebGUI::International::get(541),$_[0]->get("karmaPerPost"));
        } else {
                $f->hidden("karmaPerPost",$_[0]->get("karmaPerPost"));
        }
        $f->group(
		-name=>"groupToModerate",
		-label=>WebGUI::International::get(565),
		-value=>[$groupToModerate],
		-uiLevel=>7
		);
        $f->select(
		-name=>"moderationType",
		-options=>\%moderationType,
		-label=>WebGUI::International::get(569),
		-value=>[$moderationType],
		-uiLevel=>7
		);
        $f->yesNo(
                -name=>"addEditStampToPosts",
                -label=>WebGUI::International::get(524,"Discussion"),
                -value=>$_[0]->get("addEditStampToPosts"),
                -uiLevel=>9
                );
        return $f->printRowsOnly;
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
	my %properties = %{$_[0]->get};
	$properties{pageId} = $_[1] || 2;
	delete $properties{wobjectId};
	my $cmd = "WebGUI::Wobject::".$properties{namespace};
        my $w = eval{$cmd->new({namespace=>$properties{namespace},wobjectId=>"new"})};
        if ($@) {
        	WebGUI::ErrorHandler::warn("Could duplicate wobject ".$properties{namespace}." because: ".$@);
	}
	$w->set(\%properties);
	WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId")) unless ($_[2]);
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
	if (exists $session{form}{$_[1]}) {
		return $session{form}{$_[1]};
	} elsif (defined $_[0]->get($_[1])) {
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
	my $cmd = "\$WebGUI::Wobject::".$_[0]->get("namespace")."::name";
	my $name = eval($cmd);
	if ($@) {
		WebGUI::ErrorHandler::warn($_[0]->get("namespace")." does not appear to have any sort of name definition at all.");
		return $_[0]->get("namespace");
	} else {
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

An array reference containing a list of properties that extend the wobject class. This list should match the properties that are added to this wobject's namespace table in the database. So if this wobject has a namespace of "MyWobject" and a table definition that looks like this:

 create MyWobject (
	wobjectId int not null primary key,
	something varchar(25),
	foo int not null default 1,
	bar int
 );

Then the extended property list would be "[something, foo, bar]".

NOTE: This is used to define the wobject and should only be passed in by a wobject subclass.

=item -useDiscussion

 Defaults to "0". If set to "1" this will add a discussion properties tab to this wobject to enable content managers to set the properties of a discussion attached to this wobject.

NOTE: This is used to define the wobject and should only be passed in by a wobject subclass.

=back

=cut

sub new {
	my ($self, @p) = @_;
        my ($properties, $extendedProperties, $useDiscussion) = rearrange([qw(properties extendedProperties useDiscussion)], @p);
	$useDiscussion = 0 unless ($useDiscussion);
	my $wobjectProperties = {
		userDefined1=>{},
		userDefined2=>{}, 
		userDefined3=>{}, 
		userDefined4=>{}, 
		userDefined5=>{}, 
		allowDiscussion=>{
			defaultValue=>0
			},
		moderationType=>{
			defaultValue=>"after"
			},
		groupToModerate=>{
			defaultValue=>4
			}, 
		groupToPost=>{
			defaultValue=>2
			},
 		karmaPerPost=>{
			defaultValue=>0
			} ,
		editTimeout=>{
			defaultValue=>1,
			fieldType=>"interval"
			}, 
		filterPost=>{
			defaultValue=>"javascript",
			}, 
		addEditStampToPosts=>{
			defaultValue=>1,
			},
		title=>{}, 
		displayTitle=>{
			defaultValue=>1
			}, 
		description=>{
			fieldType=>"HTMLArea"
			},
 		pageId=>{
			defaultValue=>$session{page}{pageId}
			}, 
		templatePosition=>{
			defaultValue=>1
			}, 
		startDate=>{
			defaultValue=>$session{page}{startDate},
			fieldType=>"date"
			},
		endDate=>{
			defaultValue=>$session{page}{endDate},
			fieldType=>"date"
			},
		sequenceNumber=>{}
		};
        bless({
		_property=>$properties, 
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

=head2 processTemplate ( templateId, vars ) 

Returns the content generated from this template.

NOTE: Only for use in wobjects that support templates.

=over

=item templateId

An id referring to a particular template in the templates table.

=item hashRef

A hash reference containing variables and loops to pass to the template engine.

=back

=cut

sub processTemplate {
	my %vars = (
		%{$_[0]->{_property}},
		%{$_[2]}
		);
	return WebGUI::Template::process(WebGUI::Template::get($_[1],$_[0]->get("namespace")), \%vars);
}

#-------------------------------------------------------------------

=head2 purge ( )

Removes this wobject from the database and all it's attachments from the filesystem.

NOTE: This method is meant to be extended by all sub-classes.

=cut

sub purge {
	my ($node);
	WebGUI::SQL->write("delete from ".$_[0]->get("namespace")." where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from wobject where wobjectId=".$_[0]->get("wobjectId"));
	$node = WebGUI::Node->new($_[0]->get("wobjectId"));
	$node->delete;
	WebGUI::Discussion::purge($_[0]->get("wobjectId"));
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

=head2 www_approvePost ( )

Sets the status flag on a discussion message to "approved".

=cut

sub www_approvePost {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                return WebGUI::Discussion::approvePost();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


#-------------------------------------------------------------------

=head2 www_copy ( )

Copies this instance to the clipboard.

NOTE: Should never need to be overridden or extended.

=cut

sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_cut ( )

Moves this instance to the clipboard.

=cut

sub www_cut {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({pageId=>2, templatePosition=>1});
		_reorderWobjects($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_delete ( )

Prompts a user to confirm whether they wish to delete this instance.

=cut

sub www_delete {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
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
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({pageId=>3, templatePosition=>1});
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->set({$session{form}{file}=>''});
        return $_[0]->www_edit();
}

#-------------------------------------------------------------------

=head2 www_deleteMessage ( )

Displays a message asking for confirmation to delete a message from a discussion.

=cut

sub www_deleteMessage {
        if (WebGUI::Discussion::canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_deleteMessageConfirm ( )

Deletes a message from a discussion.

=cut

sub www_deleteMessageConfirm {
        if (WebGUI::Discussion::canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessageConfirm();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_denyPost ( )

Sets the status flag on a discussion message to "denied".

=cut

sub www_denyPost {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                return WebGUI::Discussion::denyPost();
        } else {
                return WebGUI::Privilege::insufficient();
        }
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
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
			uiLevel=>7
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
	$f->getTab("layout")->select(
		-name=>"templatePosition",
		-label=>WebGUI::International::get(363),
		-value=>[$templatePosition],
		-uiLevel=>5,
		-options=>WebGUI::Page::getTemplatePositions($session{page}{templateId}),
		-subtext=>WebGUI::Page::drawTemplate($session{page}{templateId})
		);
	$f->getTab("privileges")->date(
		-name=>"startDate",
		-label=>WebGUI::International::get(497),
		-value=>$startDate,
		-uiLevel=>6
		);
	$f->getTab("privileges")->date(
		-name=>"endDate",
		-label=>WebGUI::International::get(498),
		-value=>$endDate,
		-uiLevel=>6
		);
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
		$f->getTab("discussion")->raw($_[0]->discussionProperties);
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my %set;
	foreach (keys %{$_[0]->{_wobjectProperties}}) {
		if (exists $session{form}{$_}) {
			$set{$_} = _validateField($_,$_[0]->{_wobjectProperties}{$_}{fieldType}) || $_[0]->{_wobjectProperties}{$_}{defaultValue};
		}
	}
	$set{title} = $session{form}{title} || $_[0]->name;
	foreach (keys %{$_[0]->{_extendedProperties}}) {
		if (exists $session{form}{$_}) {
			$set{$_} = _validateField($_,$_[0]->{_extendedProperties}{$_}{fieldType}) || $_[0]->{_extendedProperties}{$_}{defaultValue};
		}
	}
	%set = (%set, %{$_[1]});
	$_[0]->set(\%set);
	return "";
}

#-------------------------------------------------------------------

=head2 www_lockThread ( )

Locks a discussion thread from the current message down.

=cut

sub www_lockThread {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                WebGUI::Discussion::lockThread();
                return $_[0]->www_showMessage;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_moveBottom ( )

Moves this instance to the bottom of the page.

=cut

sub www_moveBottom {
        if (WebGUI::Privilege::canEditPage()) {
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
        if (WebGUI::Privilege::canEditPage()) {
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
        if (WebGUI::Privilege::canEditPage()) {
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
        if (WebGUI::Privilege::canEditPage()) {
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
        if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from wobject where pageId=$session{page}{pageId}");
		$nextSeq += 1;
		$_[0]->set({sequenceNumber=>$nextSeq, pageId=>$session{page}{pageId}, templatePosition=>1});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_post ( )

Displays a discussion message post form.

=cut

sub www_post {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"))) {
                return WebGUI::Discussion::post($_[0]);
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_post ( )

Saves a message post to a discussion.

=cut 

sub www_postSave {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"))) {
                WebGUI::Discussion::postSave($_[0]);
                return $_[0]->www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_search ( )

Searches an attached discussion.

=cut

sub www_search {
        return WebGUI::Discussion::search();
}

#-------------------------------------------------------------------

=head2 www_showMessage ( [menuItem] )

Shows a message from a discussion.

=over

=item menuItem

You can optionally extend this method by passing in an HTML string of menu items to be added to the menu of this display.

=back

=cut

sub www_showMessage {
        my ($output, $defaultMid);
        ($defaultMid) = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=".$_[0]->get("wobjectId"));
        $session{form}{mid} = $session{form}{mid} || $defaultMid || 0;
        $output = WebGUI::Discussion::showMessage($_[1],$_[0]);
        $output .= WebGUI::Discussion::showReplyTree($_[0]);
        return $output;
}

#-------------------------------------------------------------------

=head2 www_subscribeToThread ( )

Subscribes the current user to a specified discussion thread.

=cut

sub www_subscribeToThread {
	WebGUI::Discussion::subscribeToThread();
	return $_[0]->www_showMessage();
}


#-------------------------------------------------------------------

=head2 www_unlockThread ( )

Unlocks a discussion thread from the current message on down.

=cut

sub www_unlockThread {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))) {
                WebGUI::Discussion::unlockThread();
                return $_[0]->www_showMessage;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------

=head2 www_subscribeToThread ( )

Unsubscribes the current user from a specified discussion thread.

=cut

sub www_unsubscribeFromThread {
        WebGUI::Discussion::unsubscribeFromThread();
        return $_[0]->www_showMessage();
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
