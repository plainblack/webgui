package WebGUI::Asset::Wobject;

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

use CGI::Util qw(rearrange);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::AdminConsole;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Node;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Style;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::Asset::Template;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::MetaData;
#use WebGUI::Asset::Wobject::WobjectProxy;

our @ISA = qw(WebGUI::Asset);

=head1 NAME

Package WebGUI::Asset::Wobject

=head1 DESCRIPTION

An abstract class for all other wobjects to extend.

=head1 SYNOPSIS

 use WebGUI::Wobject;
 our @ISA = qw(WebGUI::Wobject);

See the subclasses in lib/WebGUI/Wobjects for details.

=head1 METHODS

These methods are available from this class:

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'wobject',
                className=>'WebGUI::Asset::Wobject',
                properties=>{
                                description=>{
                                        fieldType=>'HTMLArea',
                                        defaultValue=>undef
                                        },
                                displayTitle=>{
                                        fieldType=>'yesNo',
                                        defaultValue=>1
                                        },
                                cacheTimeout=>{
                                        fieldType=>'interval',
                                        defaultValue=>60
                                        },
                                cacheTimeoutVisitor=>{
                                        fieldType=>'interval',
                                        defaultValue=>600
                                        },
				styleTemplateId=>{
					fieldType=>'template',
					defaultValue=>undef
					},
				printableStyleTemplateId=>{
					fieldType=>'template',
					defaultValue=>undef
					}
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 deleteCollateral ( tableName, keyName, keyValue )

Deletes a row of collateral data.

=head3 tableName

The name of the table you wish to delete the data from.

=head3 keyName

The name of the column that is the primary key in the table.

=head3 keyValue

An integer containing the key value.

=cut

sub deleteCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
        WebGUI::SQL->write("delete from $table where $keyName=".quote($keyValue));
	$self->updateHistory("deleted collateral item ".$keyName." ".$keyValue);
}


#-------------------------------------------------------------------

=head2 confirm ( message, yesURL, [ , noURL, vitalComparison ] )

=head3 message

A string containing the message to prompt the user for this action.

=head3 yesURL

A URL to the web method to execute if the user confirms the action.

=head3 noURL

A URL to the web method to execute if the user denies the action.  Defaults back to the current page.

=head3 vitalComparison

A comparison expression to be used when checking whether the action should be allowed to continue. Typically this is used when the action is a delete of some sort.

=cut

sub confirm {
        return WebGUI::Privilege::vitalComponent() if ($_[4]);
	my $noURL = $_[3] || $_[0]->getUrl;
        my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= $_[1].'<p>';
        $output .= '<div align="center"><a href="'.$_[2].'">'.WebGUI::International::get(44).'</a>';
        $output .= ' &nbsp; <a href="'.$noURL.'">'.WebGUI::International::get(45).'</a></div>';
        return $output;
}


#-------------------------------------------------------------------

=head2 duplicate ( asset )

Extends the Asset duplicate method to also duplicate meta data.

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(shift);
	WebGUI::MetaData::MetaDataDuplicate($self->getId, $newAsset->getId);
        return $newAsset; 
}



#-------------------------------------------------------------------

=head2 getCollateral ( tableName, keyName, keyValue ) 

Returns a hash reference containing a row of collateral data.

=head3 tableName

The name of the table you wish to retrieve the data from.

=head3 keyName

The name of the column that is the primary key in the table.

=head3 keyValue

An integer containing the key value. If key value is equal to "new" or null, then an empty hashRef containing only keyName=>"new" will be returned to avoid strict errors.

=cut

sub getCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
	if ($keyValue eq "new" || $keyValue eq "") {
		return {$keyName=>"new"};
	} else {
		return WebGUI::SQL->quickHashRef("select * from $table where $keyName=".quote($keyValue),WebGUI::SQL->getSlave);
	}
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this wobject.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>WebGUI::International::get(174),
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>WebGUI::International::get(1073),
		-value=>$self->getValue("styleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp}
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>WebGUI::International::get(1079),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp}
		);
	$tabform->getTab("properties")->HTMLArea(
                -name=>"description",
                -label=>WebGUI::International::get(85),
                -value=>$self->getValue("description")
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>WebGUI::International::get(895),
                -value=>$self->getValue("cacheTimeout"),
                -uiLevel=>8
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896),
                -value=>$self->getValue("cacheTimeoutVisitor"),
                -uiLevel=>8
                );
	return $tabform;
}




#-------------------------------------------------------------------
                                                                                                                             
=head2 logView ( )
              
Logs the view of the wobject to the passive profiling mechanism.                                                                                                               
=cut

sub logView {
	my $self = shift;
	if ($session{setting}{passiveProfilingEnabled}) {
		WebGUI::PassiveProfiling::add($self->get("assetId"));
# not sure what this will do in the new model
#		WebGUI::PassiveProfiling::addPage();	# add wobjects on asset to passive profile log
	}
 # disabled for the time being because it's dangerous
                #       if ($session{form}{op} eq "" && $session{setting}{trackPageStatistics} && $session{form}{wid} ne "new") {
                #               WebGUI::SQL->write("insert into pageStatistics (dateStamp, userId, username, ipAddress, userAgent, referer,
                #                       assetId, assetTitle, wobjectId, wobjectFunction) values (".time().",".quote($session{user}{userId})
                #                       .",".quote($session{user}{username}).",
                #                       ".quote($session{env}{REMOTE_ADDR}).", ".quote($session{env}{HTTP_USER_AGENT}).",
                #                       ".quote($session{env}{HTTP_REFERER}).", ".quote($session{asset}{assetId}).",
                #                       ".quote($session{asset}{title}).", ".quote($session{form}{wid}).", ".quote($session{form}{func}).")");
                #       }
	return;
}


#-------------------------------------------------------------------

=head2 moveCollateralDown ( tableName, keyName, keyValue [ , setName, setValue ] )

Moves a collateral data item down one position. This assumes that the collateral data table has a column called "assetId" that identifies the wobject, and a column called "sequenceNumber" that determines the position of the data item.

=head3 tableName

A string indicating the table that contains the collateral data.

=head3 keyName

A string indicating the name of the column that uniquely identifies this collateral data item.

=head3 keyValue

An iid that uniquely identifies this collateral data item.

=head3 setName

By default this method assumes that the collateral will have an assetId in the table. However, since there is not always a assetId to separate one data set from another, you may specify another field to do that.

=head3 setValue

The value of the column defined by "setName" to select a data set from.

=cut

### NOTE: There is a redundant use of assetId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralDown {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
	my $setName = shift || "assetId";
        my $setValue = shift;
	unless (defined $setValue) {
		$setValue = $self->get($setName);
	}
	WebGUI::SQL->beginTransaction;
        my ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $table where $keyName=".quote($keyValue)." and $setName=".quote($setValue));
        my ($id) = WebGUI::SQL->quickArray("select $keyName from $table where $setName=".quote($setValue)." and sequenceNumber=$seq+1");
        if ($id ne "") {
                WebGUI::SQL->write("update $table set sequenceNumber=sequenceNumber+1 where $keyName=".quote($keyValue)." and $setName=" .quote($setValue));
                WebGUI::SQL->write("update $table set sequenceNumber=sequenceNumber-1 where $keyName=".quote($id)." and $setName=" .quote($setValue));
         }
	WebGUI::SQL->commit;
}


#-------------------------------------------------------------------

=head2 moveCollateralUp ( tableName, keyName, keyValue [ , setName, setValue ] )

Moves a collateral data item up one position. This assumes that the collateral data table has a column called "assetId" that identifies the wobject, and a column called "sequenceNumber" that determines the position of the data item.

=head3 tableName

A string indicating the table that contains the collateral data.

=head3 keyName

A string indicating the name of the column that uniquely identifies this collateral data item.

=head3 keyValue

An id that uniquely identifies this collateral data item.

=head3 setName

By default this method assumes that the collateral will have a asset in the table. However, since there is not always a assetId to separate one data set from another, you may specify another field to do that.

=head3 setValue

The value of the column defined by "setName" to select a data set from.

=cut

### NOTE: There is a redundant use of assetId in some of these statements on purpose to support
### two different types of collateral data.

sub moveCollateralUp {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
        my $setName = shift || "assetId";
        my $setValue = shift;
	unless (defined $setValue) {
		$setValue = $self->get($setName);
	}
	WebGUI::SQL->beginTransaction;
        my ($seq) = WebGUI::SQL->quickArray("select sequenceNumber from $table where $keyName=".quote($keyValue)." and $setName=".quote($setValue));
        my ($id) = WebGUI::SQL->quickArray("select $table from $keyName where $setName=".quote($setValue)
		." and sequenceNumber=$seq-1");
        if ($id ne "") {
                WebGUI::SQL->write("update $table set sequenceNumber=sequenceNumber-1 where $keyName=".quote($keyValue)." and $setName="
			.quote($setValue));
                WebGUI::SQL->write("update $table set sequenceNumber=sequenceNumber+1 where $keyName=".quote($id)." and $setName="
			.quote($setValue));
        }
	WebGUI::SQL->commit;
}

#-------------------------------------------------------------------

=head2 processMacros ( output )

 Decides whether or not macros should be processed and returns the
 appropriate output.

=head3 output

 An HTML blob to be processed for macros.

=cut

sub processMacros {
	return WebGUI::Macro::process($_[1]);
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	my $output = $self->SUPER::processPropertiesFromFormPost;
	WebGUI::MetaData::metaDataSave($self->getId);
}



#-------------------------------------------------------------------

sub processStyle {
	my $self = shift;
	my $output = shift;
	return WebGUI::Style::process($output,$self->get("styleTemplateId"));
}


#-------------------------------------------------------------------

=head2 processTemplate ( vars, templateId ) 

Returns the content generated from this template.

=head3 hashRef

A hash reference containing variables and loops to pass to the template engine.

=head3 templateId

An id referring to a particular template in the templates table. 

=cut

sub processTemplate {
	my $self = shift;
	my $var = shift;
	my $templateId = shift;
        my $meta = WebGUI::MetaData::getMetaDataFields($self->get("wobjectId"));
        foreach my $field (keys %$meta) {
		$var->{$meta->{$field}{fieldName}} = $meta->{$field}{value};
	}
	$var->{'controls'} = $self->getToolbar;
	my %vars = (
		%{$self->{_properties}},
		%{$var}
		);
	if (defined $self->get("_WobjectProxy")) {
		$vars{isShortcut} = 1;
		my ($originalPageURL) = WebGUI::SQL->quickArray("select url from asset where assetId=".quote($self->getId),WebGUI::SQL->getSlave);
		$vars{originalURL} = WebGUI::URL::gateway($originalPageURL."#".$self->getId);
	}
	return WebGUI::Asset::Template->new($templateId)->process(\%vars);
}

#-------------------------------------------------------------------

=head2 purge ( )

Removes this wobject and it's descendants from the database.

=cut

sub purge {
	my $self = shift;
	$self->SUPER::purge();
	WebGUI::MetaData::metaDataDelete($self->getId);
}


#-------------------------------------------------------------------

=head2 reorderCollateral ( tableName, keyName [ , setName, setValue ] )

Resequences collateral data. Typically useful after deleting a collateral item to remove the gap created by the deletion.

=head3 tableName

The name of the table to resequence.

=head3 keyName

The key column name used to determine which data needs sorting within the table.

=head3 setName

Defaults to "assetId". This is used to define which data set to reorder.

=head3 setValue

Used to define which data set to reorder. Defaults to the assetId for this instance. Defaults to the value of "setName" in the wobject properties.

=cut

sub reorderCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $setName = shift || "assetId";
	my $setValue = shift || $self->get($setName);
	my $i = 1;
        my $sth = WebGUI::SQL->read("select $keyName from $table where $setName=".quote($setValue)." order by sequenceNumber");
        while (my ($id) = $sth->array) {
                WebGUI::SQL->write("update $keyName set sequenceNumber=$i where $setName=".quote($setValue)." and $keyName=".quote($id));
                $i++;
        }
        $sth->finish;
}


#-----------------------------------------------------------------

=head2 setCollateral ( tableName, keyName, properties [ , useSequenceNumber, useAssetId, setName, setValue ] )

Performs and insert/update of collateral data for any wobject's collateral data. Returns the primary key value for that row of data.

=head3 tableName

The name of the table to insert the data.

=head3 keyName

The column name of the primary key in the table specified above. 

=head3 properties

A hash reference containing the name/value pairs to be inserted into the database where the name is the column name. Note that the primary key should be specified in this list, and if it's value is "new" or null a new row will be created.

=head3 useSequenceNumber

If set to "1", a new sequenceNumber will be generated and inserted into the row. Note that this means you must have a sequenceNumber column in the table. Also note that this requires the presence of the assetId column. Defaults to "1".

=head3 useAssetId

If set to "1", the current assetId will be inserted into the table upon creation of a new row. Note that this means the table better have a assetId column. Defaults to "1".  

=head3 setName

If this collateral data set is not grouped by assetId, but by another column then specify that column here. The useSequenceNumber parameter will then use this column name instead of assetId to generate the sequenceNumber.

=head3 setValue

If you've specified a setName you may also set a value for that set.  Defaults to the value for this id from the wobject properties.

=cut

sub setCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $properties = shift;
	my $useSequence = shift;
	my $useAssetId = shift;
	my $setName = shift || "assetId";
	my $setValue = shift || $self->get($setName);
	my ($key, $sql, $seq, $dbkeys, $dbvalues, $counter);
	my $counter = 0;
	my $sql;
	if ($properties->{$keyName} eq "new" || $properties->{$keyName} eq "") {
		$properties->{$keyName} = WebGUI::Id::generate();
		$sql = "insert into $table (";
		my $dbkeys = "";
     		my $dbvalues = "";
		unless ($useSequence eq "0") {
			unless (exists $properties->{sequenceNumber}) {
				my ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from $table where $setName=".quote($setValue));
				$properties->{sequenceNumber} = $seq+1;
			}
		} 
		unless ($useAssetId eq "0") {
			$properties->{assetId} = $self->get("assetId");
		}
		foreach my $key (keys %{$properties}) {
			if ($counter++ > 0) {
				$dbkeys .= ',';
				$dbvalues .= ',';
			}
			$dbkeys .= $key;
			$dbvalues .= quote($properties->{$key});
		}
		$sql .= $dbkeys.') values ('.$dbvalues.')';
		$self->updateHistory("added collateral item ".$table." ".$properties->{$keyName});
	} else {
		$sql = "update $table set ";
		foreach my $key (keys %{$properties}) {
			unless ($key eq "sequenceNumber") {
				$sql .= ',' if ($counter++ > 0);
				$sql .= $key."=".quote($properties->{$key});
			}
		}
		$sql .= " where $keyName=".quote($properties->{$keyName});
		$self->updateHistory("edited collateral item ".$table." ".$properties->{$keyName});
	}
  	WebGUI::SQL->write($sql);
	$self->reorderCollateral($table,$keyName,$setName,$setValue) if ($properties->{sequenceNumber} < 0);
	return $properties->{$keyName};
}





#-------------------------------------------------------------------

=head2 www_createShortcut ( )

Creates a shortcut (using the wobject proxy) of this wobject on the clipboard.

B<NOTE:> Should never need to be overridden or extended.

=cut

sub www_createShortcut {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my $w = WebGUI::Wobject::WobjectProxy->new({wobjectId=>"new",namespace=>"WobjectProxy"});
	$w->update({
		pageId=>'2',
		templatePosition=>1,
		title=>$self->getValue("title"),
		proxiedNamespace=>$self->get("namespace"),
		proxiedWobjectId=>$self->get("wobjectId"),
	    	bufferUserId=>$session{user}{userId},
		bufferDate=>WebGUI::DateTime::time(),
		bufferPrevId=>$session{page}{pageId}
		});
        return "";
}




#-------------------------------------------------------------------

sub www_view {
	my $self = shift;
	$self->logView();
	return WebGUI::Privilege::noAccess() unless $self->canView;
	my $cache;
	my $output;
        my $useCache = (
		$session{form}{op} eq "" && 
		(
			( $self->get("cacheTimeout") > 10 && $session{user}{userId} !=1) || 
			( $self->get("cacheTimeoutVisitor") > 10 && $session{user}{userId} == 1)
		) && 
		not $session{var}{adminOn}
	);
#	if ($useCache) {
 #              	$cache = WebGUI::Cache->new("asset_".$self->getId."_".$session{user}{userId});
  #         	$output = $cache->get;
#	}
	unless ($output) {
		$output = $self->view;
		my $ttl;
		if ($session{user}{userId} == 1) {
			$ttl = $self->get("cacheTimeoutVisitor");
		} else {
			$ttl = $self->get("cacheTimeout");
		}
#		$cache->set($output, $ttl) if ($useCache && !WebGUI::HTTP::isRedirect());
	}
	return $self->processStyle($output);
}

1;

