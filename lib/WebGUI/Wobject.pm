package WebGUI::Wobject;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

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
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;


=head1 NAME

 Package WebGUI::Wobject

=head1 SYNOPSIS

 use WebGUI::Wobject;
 our @ISA = qw(WebGUI::Wobject);

 See the subclasses in lib/WebGUI/Wobjects for details.

=head1 DESCRIPTION

 An abstract class for all other wobjects to extend. 

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

=item message

 A string containing the message to prompt the user for this action.

=item yesURL

 A URL to the web method to execute if the user confirms the action.

=item noURL

 A URL to the web method to execute if the user denies the action.
 Defaults back to the current page.

=item vitalComparison

 A comparison expression to be used when checking whether the action
 should be allowed to continue. Typically this is used when the
 action is a delete of some sort.

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

=item tableName

 The name of the table you wish to delete the data from.

=item keyName

 The name of the column that is the primary key in the table.

=item keyValue

 An integer containing the key value.

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

 Returns a formRow list of discussion properties, which may be
 attached to any Wobject.

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

 Duplicates this wobject with a new wobject ID. Returns the new
 wobject Id.

 NOTE: This method is meant to be extended by all sub-classes.

=item pageId 

 If specified the wobject will be duplicated to this pageId,
 otherwise it will be duplicated to the clipboard.

=cut

sub duplicate {
	my ($pageId, $w);
	$pageId = $_[1] || 2;
	$w = WebGUI::Wobject->new({
		wobjectId => "new",
		namespace => $_[0]->get("namespace")
		});
	$w->set({
		pageId => $pageId,
		userDefined1 => $_[0]->get("userDefined1"),
		userDefined2 => $_[0]->get("userDefined2"),
		userDefined3 => $_[0]->get("userDefined3"),
		userDefined4 => $_[0]->get("userDefined4"),
		userDefined5 => $_[0]->get("userDefined5"),
		title => $_[0]->get("title"),
		description => $_[0]->get("description"),
		displayTitle => $_[0]->get("displayTitle"),
		processMacros => $_[0]->get("processMacros"),
		startDate => $_[0]->get("startDate"),
		endDate => $_[0]->get("endDate"),
		templatePosition => $_[0]->get("templatePosition")
		});
	WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId")) unless ($_[2]);
        return $w->get("wobjectId");
}

#-------------------------------------------------------------------

=head2 fileProperty ( name, labelId )

 Returns a file property form row which can be used in any Wobject
 properties page. 

 NOTE: This method is meant for use with www_deleteFile.

=item name

 The name of the property that stores the filename.

=item labelId

 The internationalId of the form label for this file.

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

 Returns a hash reference containing all of the properties of this
 wobject instance.

=item propertyName

 If an individual propertyName is specified, then only that
 property value is returned as a scalar.

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

=item tableName

 The name of the table you wish to retrieve the data from.

=item keyName

 The name of the column that is the primary key in the table.

=item keyValue

 An integer containing the key value. If key value is equal to "new"
 or null, then an empty hashRef containing only keyName=>"new" will 
 be returned to avoid strict errors.

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

=head2 inDateRange ( )

 Returns a boolean value of whether the wobject should be displayed
 based upon it's start and end dates.

=cut

sub inDateRange {
	if ($_[0]->get("startDate") < time() && $_[0]->get("endDate") > time()) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 moveCollateralDown ( tableName, idName, id )

 Moves a collateral data item down one position. This assumes that the
 collateral data table has a column called "wobjectId" that identifies
 the wobject, and a column called "sequenceNumber" that determines
 the position of the data item.

=item tableName

 A string indicating the table that contains the collateral data.

=item idName

 A string indicating the name of the column that uniquely identifies
 this collateral data item.

=item id

 An integer that uniquely identifies this collateral data item.

=cut

### NOTE: There is a redundant use of wobjectId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralDown {
        my ($id, $seq);
        ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $_[1] where $_[2]=$_[3] and wobjectId=".$_[0]->get("wobjectId"));
        ($id) = WebGUI::SQL->quickArray("select $_[2] from $_[1] where wobjectId=".$_[0]->get("wobjectId")
		." and sequenceNumber=$seq+1 group by wobjectId");
        if ($id ne "") {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber+1 where $_[2]=$_[3] and wobjectId=".$_[0]->get("wobjectId"));
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber-1 where $_[2]=$id and wobjectId=".$_[0]->get("wobjectId"));
         }
}

#-------------------------------------------------------------------

=head2 moveCollateralUp ( tableName, idName, id )

 Moves a collateral data item up one position. This assumes that the
 collateral data table has a column called "wobjectId" that identifies
 the wobject, and a column called "sequenceNumber" that determines
 the position of the data item.

=item tableName

 A string indicating the table that contains the collateral data.

=item idName

 A string indicating the name of the column that uniquely identifies
 this collateral data item.

=item id

 An integer that uniquely identifies this collateral data item.

=cut

### NOTE: There is a redundant use of wobjectId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralUp {
        my ($id, $seq);
        ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $_[1] where $_[2]=$_[3] and wobjectId=".$_[0]->get("wobjectId"));
        ($id) = WebGUI::SQL->quickArray("select $_[2] from $_[1] where wobjectId=".$_[0]->get("wobjectId")
		." and sequenceNumber=$seq-1 group by wobjectId");
        if ($id ne "") {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber-1 where $_[2]=$_[3] and wobjectId=".$_[0]->get("wobjectId"));
                WebGUI::SQL->write("update $_[1] set sequenceNumber=sequenceNumber+1 where $_[2]=$id and wobjectId=".$_[0]->get("wobjectId"));
        }
}

#-------------------------------------------------------------------

=head2 new ( properties )

 Constructor.

 NOTE: This method should never need to be overridden or extended.

=item properties

 A hash reference containing at minimum "wobjectId" and "namespace"
 and wobjectId may be set to "new" if you're creating a new
 instance. This hash reference should be the one created by 
 WebGUI.pm and passed to the wobject subclass.

 NOTE: It may seem a little weird that the initial data for the
 wobject instance is coming from WebGUI.pm, but this was done
 to lessen database traffic thus increasing the speed of all
 wobjects.

=cut

sub new {
        bless {_property => $_[1]}, $_[0];
}

#-------------------------------------------------------------------

=head2 processMacros ( output )

 Decides whether or not macros should be processed and returns the
 appropriate output.

=item output

 An HTML blob to be processed for macros.

=cut

sub processMacros {
	if ($_[0]->get("processMacros")) {
		return WebGUI::Macro::process($_[1]);
	} else {
		return $_[1];
	}
}

#-------------------------------------------------------------------

=head2 processTemplate ( templateId, vars ) 

 Returns the content generated from this template.

 NOTE: Only for use in wobjects that support templates.

=item templateId

 An id referring to a particular template in the templates table.

=item hashRef

 A hash reference containing variables and loops to pass to the
 template engine.

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

 Removes this wobject from the database and all it's attachments
 from the filesystem.

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

=head2 reorderCollateral ( tableName, keyName )

 Resequences collateral data. Typically useful after deleting a
 collateral item to remove the gap created by the deletion.

=item tableName

 The name of the table to resequence.

=item keyName

 The key column name used to determine which data needs sorting within the table.

=cut

sub reorderCollateral {
        my ($sth, $i, $id);
	$i = 0;
        $sth = WebGUI::SQL->read("select $_[2] from $_[1] where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update $_[1] set sequenceNumber=$i where wobjectId=".$_[0]->get("wobjectId")." and $_[2]=$id");
                $i++;
        }
        $sth->finish;
}



#-------------------------------------------------------------------

=head2 set ( [ hashRef, arrayRef ] )

 Stores the values specified in hashRef to the database.

 NOTE: This method should be extended by all subclasses.

=item hashRef 

 A hash reference of the properties of this wobject instance. This
 method will accept any name/value pair and associate it with this
 wobject instance in memory, but will only store the following 
 fields to the database:

 title, displayTitle, description, processMacros,
 pageId, templatePosition, startDate, endDate, sequenceNumber

=item arrayRef

 An array reference containing a list of properties associated
 with this Wobject class. The items in the list should marry
 up to fields in the Wobject extention table for this class.

=cut

sub set {
	my ($key, $sql, @update, $i);
	if ($_[0]->{_property}{wobjectId} eq "new") {
		$_[0]->{_property}{wobjectId} = getNextId("wobjectId");
		$_[0]->{_property}{pageId} = ${$_[1]}{pageId} || $session{page}{pageId};
		$_[0]->{_property}{sequenceNumber} = _getNextSequenceNumber($_[0]->{_property}{pageId});
		$_[0]->{_property}{addedBy} = $session{user}{userId};
		$_[0]->{_property}{dateAdded} = time();
		WebGUI::SQL->write("insert into wobject 
			(wobjectId, namespace, dateAdded, addedBy, sequenceNumber, pageId) 
			values (
			".$_[0]->{_property}{wobjectId}.", 
			".quote($_[0]->{_property}{namespace}).",
			".$_[0]->{_property}{dateAdded}.",
			".$_[0]->{_property}{addedBy}.",
			".$_[0]->{_property}{sequenceNumber}.",
			".$_[0]->{_property}{pageId}."
			)");
		WebGUI::SQL->write("insert into ".$_[0]->{_property}{namespace}." (wobjectId) values (".$_[0]->{_property}{wobjectId}.")");
	}
	$_[0]->{_property}{lastEdited} = time();
	$_[0]->{_property}{editedBy} = $session{user}{userId};
	$sql = "update wobject set";
	foreach $key (keys %{$_[1]}) {
		$_[0]->{_property}{$key} = ${$_[1]}{$key};
		if (isIn($key, qw(userDefined1 userDefined2 userDefined3 userDefined4 userDefined5 moderationType groupToModerate groupToPost karmaPerPost editTimeout title displayTitle description processMacros pageId templatePosition startDate endDate sequenceNumber))) {
        		$sql .= " ".$key."=".quote(${$_[1]}{$key}).",";
		}
                if (isIn($key, @{$_[2]})) {
                        $update[$i] .= " ".$key."=".quote($_[1]->{$key});
                        $i++;
                }
	}
	$sql .= " lastEdited=".$_[0]->{_property}{lastEdited}.", 
		editedBy=".$_[0]->{_property}{editedBy}." 
		where wobjectId=".$_[0]->{_property}{wobjectId};
	WebGUI::SQL->write($sql);
	if (@update) {
        	WebGUI::SQL->write("update ".$_[0]->{_property}{namespace}." set ".join(",",@update)." where wobjectId=".$_[0]->{_property}{wobjectId});
	}
	WebGUI::ErrorHandler::audit("edited Wobject ".$_[0]->{_property}{wobjectId});
}


#-----------------------------------------------------------------

=head2 setCollateral ( tableName, keyName, properties [ , useSequenceNumber, useWobjectId ] )

 Performs and insert/update of collateral data for any wobject's
 collateral data. Returns the primary key value for that row of
 data.

=item tableName

 The name of the table to insert the data.

=item keyName

 The column name of the primary key in the table specified above.
 This must also be an incrementerId in the incrementer table.

=item properties

 A hash reference containing the name/value pairs to be inserted
 into the database where the name is the column name. Note that
 the primary key should be specified in this list, and if it's value
 is "new" or null a new row will be created.

=item useSequenceNumber

 If set to "1", a new sequenceNumber will be generated and inserted
 into the row. Note that this means you must have a sequenceNumber
 column in the table. Also note that this requires the presence of
 the wobjectId column. Defaults to "1".

=item useWobjectId

 If set to "1", the current wobjectId will be inserted into the table
 upon creation of a new row. Note that this means the table better
 have a wobjectId column. Defaults to "1".

=cut

sub setCollateral {
	my ($key, $sql, $seq, $dbkeys, $dbvalues, $counter);
	my ($class, $table, $keyName, $properties, $useSequence, $useWobjectId) = @_;
	$counter = 0;
	if ($properties->{$keyName} eq "new" || $properties->{$keyName} eq "") {
		$properties->{$keyName} = getNextId($keyName);
		$sql = "insert into $table (";
		$dbkeys = "";
     		$dbvalues = "";
		unless ($useSequence eq "0") {
			($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from $table 
                               	where wobjectId=".$_[0]->get("wobjectId"));
			$properties->{sequenceNumber} = $seq+1;
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
			$sql .= ',' if ($counter++ > 0);
			$sql .= $key."=".quote($properties->{$key});
		}
		$sql .= " where $keyName='".$properties->{$keyName}."'";
		WebGUI::ErrorHandler::audit("edited ".$table." ".$properties->{$keyName});
	}
  	WebGUI::SQL->write($sql);
	return $properties->{$keyName};
}


#-------------------------------------------------------------------

=head2 templateProperties 

 Returns a list of template properties.

=cut

sub templateProperties {
	my ($f, $templates, $templateId, $subtext);
	$templateId = $_[0]->get("templateId") || 1;
	if ($_[0]->get("wobjectId") ne "new" && $session{user}{uiLevel} >= 5) {
		$subtext = '<a href="'.WebGUI::URL::page("op=editTemplate&tid=".$templateId."&return="
			.WebGUI::URL::escape("func=edit&wid=".$_[0]->get("wobjectId"))).'">'
			.WebGUI::International::get(741).'</a> / <a href="'.WebGUI::URL::page("op=listTemplates").'">'
			.WebGUI::International::get(742).'</a>';
	}
	$templates = WebGUI::SQL->buildHashRef("select templateId,name from template where namespace="
		.quote($_[0]->get("namespace"))." order by name");
	$f = WebGUI::HTMLForm->new;
	$f->select(
		-name=>"templateId",
		-options=>$templates,
		-label=>WebGUI::International::get(740),
		-value=>[$templateId],
		-uiLevel=>1,
		-subtext=>$subtext
		);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 uiLevel

 Returns the UI Level of a wobject. Defaults to "0" for all wobjects.
 Override to set the UI Level higher for a given wobject.

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

 Displays a message asking for confirmation to delete a message from
 a discussion.

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

=head2 www_edit ( formRows ) 

 Displays the common properties of any/all wobjects. 

 NOTE: This method should be extended by all wobjects.

=item formRows

 The custom form rows from the wobject subclass edit page.

=cut

sub www_edit {
        my ($f, $startDate, $displayTitle, $title, $templatePosition, $endDate);
        if ($_[0]->get("wobjectId") eq "new") {
               	$displayTitle = 1;
        } else {
        	$displayTitle = $_[0]->get("displayTitle");
        }
	$title = $_[0]->get("title") || $_[0]->get("namespace");
	$templatePosition = $_[0]->get("templatePosition") || 1;
	$startDate = $_[0]->get("startDate") || $session{page}{startDate};
	$endDate = $_[0]->get("endDate") || $session{page}{endDate};
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
	$f->hidden("namespace",$_[0]->get("namespace")) if ($_[0]->get("wobjectId") eq "new");
	$f->hidden("func","editSave");
	$f->submit if ($_[0]->get("wobjectId") ne "new");
	$f->readOnly(
		-value=>$_[0]->get("wobjectId"),
		-label=>WebGUI::International::get(499),
		-uiLevel=>3
		);
	$f->text("title",WebGUI::International::get(99),$title);
	$f->yesNo(
		-name=>"displayTitle",
		-label=>WebGUI::International::get(174),
		-value=>$displayTitle,
		-uiLevel=>5
		);
	$f->yesNo(
		-name=>"processMacros",
		-label=>WebGUI::International::get(175),
		-value=>$_[0]->get("processMacros"),
		-uiLevel=>5
		);
	$f->select(
		-name=>"templatePosition",
		-label=>WebGUI::International::get(363),
		-value=>[$templatePosition],
		-uiLevel=>5,
		-options=>WebGUI::Template::getPositions($session{page}{templateId}),
		-subtext=>WebGUI::Template::draw($session{page}{templateId})
		);
	$f->date(
		-name=>"startDate",
		-label=>WebGUI::International::get(497),
		-value=>$startDate,
		-uiLevel=>9
		);
	$f->date(
		-name=>"endDate",
		-label=>WebGUI::International::get(498),
		-value=>$endDate,
		-uiLevel=>9
		);
	$f->HTMLArea("description",WebGUI::International::get(85),$_[0]->get("description"));
	$f->raw($_[1]);
	$f->submit;
	return $f->print; 
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

 Saves the default properties of any/all wobjects.

 NOTE: This method should be extended by all subclasses.

=cut

sub www_editSave {
	my ($title, $templatePosition, $startDate, $endDate);
	$title = $session{form}{title} || $_[0]->get("namespace");
        $templatePosition = $session{form}{templatePosition} || 1;
        $startDate = setToEpoch($session{form}{startDate}) || $session{page}{startDate};
        $endDate = setToEpoch($session{form}{endDate}) || $session{page}{endDate};
	$session{form}{description} = WebGUI::HTML::cleanSegment($session{form}{description});
	$session{form}{karmaPerPost} ||= 0;
	$session{form}{groupToPost} ||= 2;
	$session{form}{editTimeout} = WebGUI::DateTime::intervalToSeconds($session{form}{editTimeout_interval},$session{form}{editTimeout_units}) || 0;
	$session{form}{groupToModerate} ||= 3;
	$session{form}{moderationType} ||= "after";
	$_[0]->set({
		title=>$title,
		displayTitle=>$session{form}{displayTitle},
		processMacros=>$session{form}{processMacros},
		templatePosition=>$templatePosition,
		startDate=>$startDate,
		endDate=>$endDate,
		description=>$session{form}{description},
		karmaPerPost=>$session{form}{karmaPerPost},
		groupToPost=>$session{form}{groupToPost},
		groupToModerate=>$session{form}{groupToModerate},
		editTimeout=>$session{form}{editTimeout},
		moderationType=>$session{form}{moderationType},
		%{$_[1]}
	});
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
                return WebGUI::Discussion::post();
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

=item menuItem

 You can optionally extend this method by passing in an HTML string
 of menu items to be added to the menu of this display.

=cut

sub www_showMessage {
        my ($output, $defaultMid);
        ($defaultMid) = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=".$_[0]->get("wobjectId"));
        $session{form}{mid} = $session{form}{mid} || $defaultMid || 0;
        $output = WebGUI::Discussion::showMessage($_[1],$_[0]);
        $output .= WebGUI::Discussion::showThreads();
        return $output;
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

=head2 www_view ( )

 The default display mechanism for any wobject. This web method MUST
 be overridden.

=cut

sub www_view {
	my ($output);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
	$output = $_[0]->processMacros($output);
	return $output;
}

1;
