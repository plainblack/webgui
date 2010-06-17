package WebGUI::Asset::Wobject;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

#use CGI::Util qw(rearrange);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::Asset;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::SQL;
use WebGUI::Utility;

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

#-------------------------------------------------------------------

=head2 definition ( session, [definition] )

Returns an array reference of definitions. Adds tableName, className, properties to array definition.

=head3 definition

An array of hashes to prepend to the list

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Wobject');
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
	description=>{
		fieldType=>'HTMLArea',
		defaultValue=>undef,
		tab=>"properties",
		label=>$i18n->get(85),
		hoverHelp=>$i18n->get('85 description')
	},
	displayTitle=>{
		fieldType=>'yesNo',
		defaultValue=>1,
		tab=>"display",
		label=>$i18n->get(174),
		hoverHelp=>$i18n->get('174 description'),
		uiLevel=>5
	},
	styleTemplateId=>{
		fieldType=>'template',
		defaultValue=>'PBtmpl0000000000000060',
		tab=>"display",
		label=>$i18n->get(1073),
		hoverHelp=>$i18n->get('1073 description'),
	    filter=>'fixId',
		namespace=>'style'
	},
	printableStyleTemplateId=>{
		fieldType=>'template',
		defaultValue=>'PBtmpl0000000000000060',
		tab=>"display",
		label=>$i18n->get(1079),
		hoverHelp=>$i18n->get('1079 description'),
	    filter=>'fixId',
		namespace=>'style'
	},
    mobileStyleTemplateId => {
        fieldType       => ( $session->setting->get('useMobileStyle') ? 'template' : 'hidden' ),
        defaultValue    => 'PBtmpl0000000000000060',
        tab             => 'display',
        label           => $i18n->get('mobileStyleTemplateId label'),
        hoverHelp       => $i18n->get('mobileStyleTemplateId description'),
        filter          => 'fixId',
        namespace       => 'style',
    },
	);
	push(@{$definition}, {
		tableName=>'wobject',
		className=>'WebGUI::Asset::Wobject',
		autoGenerateForms=>1,
		properties => \%properties
	});
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 copyCollateral ( tableName, keyName, keyValue )

Copies a row of collateral data where keyName=keyValue.  Generates a new key for keyName.

=head3 tableName

The name of the table you wish to copy the data from.

=head3 keyName

The name of a column in the table. Is not checked for invalid input.

=head3 keyValue

Criteria (value) used to find the data to copy.

=cut

sub copyCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
    my $db = $self->session->db;
    my $newId = $self->session->id->generate;

    my $temp = $self->session->db->buildArrayRefOfHashRefs(
        "select * from ".$db->dbh->quote_identifier($table)." where ".$db->dbh->quote_identifier($keyName)."=".$db->quote($keyValue));
    my $hash = $temp->[0];
    $hash->{$keyName} = $newId;
    my @keys = keys %$hash;
    my $sql = "insert into ".$db->dbh->quote_identifier($table)
            ." (".join(',',map("`$_`",@keys)).") values(".join(',',map("?",@keys)).")";
    $self->session->db->write($sql,[map($hash->{$_},@keys)]);
}

#-------------------------------------------------------------------

=head2 deleteCollateral ( tableName, keyName, keyValue )

Deletes a row of collateral data where keyName=keyValue.

=head3 tableName

The name of the table you wish to delete the data from.

=head3 keyName

The name of a column in the table. Is not checked for invalid input.

=head3 keyValue

Criteria (value) used to find the data to delete.

=cut

sub deleteCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
    my $db = $self->session->db;
        $self->session->db->write("delete from ".$db->dbh->quote_identifier($table)
            ." where ".$db->dbh->quote_identifier($keyName)."=".$db->quote($keyValue));
	$self->updateHistory("deleted collateral item ".$keyName." ".$keyValue);
}


#-------------------------------------------------------------------

=head2 confirm ( message,yesURL [,noURL,vitalComparison] )

Returns an HTML string that presents a link to confirm and a link to cancel an action, both Internationalized text.

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
	my ($self, $message, $yesURL, $noURL, $vitalComparison) = @_;
        return $self->session->privilege->vitalComponent() if ($vitalComparison);
	$noURL = $noURL || $self->getUrl;
	my $i18n = WebGUI::International->new($self->session,'Asset_Wobject');
        my $output = '<h1>'.$i18n->get(42).'</h1>';
        $output .= $message.'<p>';
        $output .= '<div align="center"><a href="'.$yesURL.'">'.$i18n->get(44).'</a>';
        $output .= ' &nbsp; <a href="'.$noURL.'">'.$i18n->get(45).'</a></div>';
        return $output;
}



#-------------------------------------------------------------------

=head2 getCollateral ( tableName, keyName, keyValue )

Returns a hash reference containing a row of collateral data.

=head3 tableName

The name of the table you wish to retrieve the data from.

=head3 keyName

A name of a column in the table. Usually the primary key column.

=head3 keyValue

A string containing the key value. If key value is equal to "new" or null, then an empty hashRef containing only keyName=>"new" will be returned to avoid strict errors.

=cut

sub getCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $keyValue = shift;
    my $db = $self->session->db;
	if ($keyValue eq "new" || $keyValue eq "") {
		return {$keyName=>"new"};
	} else {
		return $db->quickHashRef("select * from ".$db->dbh->quote_identifier($table)
            ." where ".$db->dbh->quote_identifier($keyName)."=?",[$keyValue]);
	}
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
	$self->session->db->beginTransaction;
        my ($seq) = $self->session->db->quickArray("select sequenceNumber from $table where $keyName=".$self->session->db->quote($keyValue)." and $setName=".$self->session->db->quote($setValue));
        my ($id) = $self->session->db->quickArray("select $keyName from $table where $setName=".$self->session->db->quote($setValue)." and sequenceNumber=$seq+1");
        if ($id ne "") {
                $self->session->db->write("update $table set sequenceNumber=sequenceNumber+1 where $keyName=".$self->session->db->quote($keyValue)." and $setName=" .$self->session->db->quote($setValue));
                $self->session->db->write("update $table set sequenceNumber=sequenceNumber-1 where $keyName=".$self->session->db->quote($id)." and $setName=" .$self->session->db->quote($setValue));
         }
	$self->session->db->commit;
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
	$self->session->db->beginTransaction;
        my ($seq) = $self->session->db->quickArray("select sequenceNumber from $table where $keyName=".$self->session->db->quote($keyValue)." and $setName=".$self->session->db->quote($setValue));
        my ($id) = $self->session->db->quickArray("select $keyName from $table where $setName=".$self->session->db->quote($setValue)
		." and sequenceNumber=$seq-1");
        if ($id ne "") {
                $self->session->db->write("update $table set sequenceNumber=sequenceNumber-1 where $keyName=".$self->session->db->quote($keyValue)." and $setName="
			.$self->session->db->quote($setValue));
                $self->session->db->write("update $table set sequenceNumber=sequenceNumber+1 where $keyName=".$self->session->db->quote($id)." and $setName="
			.$self->session->db->quote($setValue));
        }
	$self->session->db->commit;
}


#-------------------------------------------------------------------

=head2 processStyle ( )

Returns output parsed under the current style.  See also Asset::processStyle.

=cut

sub processStyle {
	my ($self, $output, $options) = @_;
    $output   = $self->SUPER::processStyle($output, $options);
    my $style = $self->session->style;
    if ($style->useMobileStyle) {
        return $style->process($output,$self->get("mobileStyleTemplateId"));
    }
    return $style->process($output,$self->get("styleTemplateId"));
}


#-------------------------------------------------------------------

=head2 reorderCollateral ( tableName,keyName [,setName,setValue] )

Resequences collateral data. Typically useful after deleting a collateral item to remove the gap created by the deletion.

=head3 tableName

The name of the table to resequence.

=head3 keyName

The key column name used to determine which data needs sorting within the table.

=head3 setName

Defaults to "assetId". This is used to define which data set to reorder.

=head3 setValue

Used to define which data set to reorder. Defaults to the value of setName (default "assetId", see above) in the wobject properties.

=cut

sub reorderCollateral {
	my $self = shift;
	my $table = shift;
	my $keyName = shift;
	my $setName = shift || "assetId";
	my $setValue = shift || $self->get($setName);
	my $i = 1;
        my $sth = $self->session->db->read("select $keyName from $table where $setName=? order by sequenceNumber", [$setValue]);
	my $sth2 = $self->session->db->prepare("update $table set sequenceNumber=? where $setName=? and $keyName=?");
        while (my ($id) = $sth->array) {
		$sth2->execute([$i, $setValue, $id]);
                $i++;
        }
	$sth2->finish;
        $sth->finish;
        $sth->finish;
}


#-----------------------------------------------------------------

=head2 setCollateral ( tableName,keyName,properties [,useSequenceNumber,useAssetId,setName,setValue] )

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

=head3 updateSequence

If set to "1" an update of existing collateral data will also update the sequence number. This option is used when
importing collateral data in a package. Defaults to "0".

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
    my $updateSequence = shift;
    my $db = $self->session->db;
	my ($key, $seq, $dbkeys, $dbvalues);
	my $counter = 0;
	my $sql;
	
    if ($properties->{$keyName} eq "new" || $properties->{$keyName} eq "") {
		$properties->{$keyName} = $self->session->id->generate();
		$sql = "insert into ".$db->dbh->quote_identifier($table)." (";
		my $dbkeys = "";
     		my $dbvalues = "";
		unless ($useSequence eq "0") {
			unless (exists $properties->{sequenceNumber}) {
				my ($seq) = $self->session->db->quickArray("select max(sequenceNumber) "
                    ." from ".$db->dbh->quote_identifier($table)." where $setName=?",[$setValue]);
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
			$dbkeys .= $db->dbh->quote_identifier($key);
			$dbvalues .= $self->session->db->quote($properties->{$key});
		}
		$sql .= $dbkeys.') values ('.$dbvalues.')';
		$self->updateHistory("added collateral item ".$table." ".$properties->{$keyName});
	} else {
		$sql = "update ".$db->dbh->quote_identifier($table)." set ";
		foreach my $key (keys %{$properties}) {
			unless ($key eq "sequenceNumber" && $updateSequence ne "1") {
				$sql .= ',' if ($counter++ > 0);
				$sql .= $db->dbh->quote_identifier($key)."=".$db->quote($properties->{$key});
			}
		}
		$sql .= " where ".$db->dbh->quote_identifier($keyName)."=".$db->quote($properties->{$keyName});
		$self->updateHistory("edited collateral item ".$table." ".$properties->{$keyName});
	}
  	$self->session->db->write($sql);
	$self->reorderCollateral($table,$keyName,$setName,$setValue) if ($properties->{sequenceNumber} < 0);
	return $properties->{$keyName};
}


#-------------------------------------------------------------------

=head2 www_view (  )

Renders self->view based upon current style, subject to timeouts. Returns Privilege::noAccess() if canView is False.

=cut

sub www_view {
	my $self = shift;
	my $check = $self->checkView;
	return $check if (defined $check);
	$self->session->http->setLastModified($self->getContentLastModified);
	$self->session->http->sendHeader;
    ##Have to dupe this code here because Wobject does not call SUPER.
    if ($self->get('synopsis')) {
        $self->session->style->setMeta({
                name    => 'Description',
                content => $self->get('synopsis'),
        });
    }
	$self->prepareView;
	my $style = $self->processStyle($self->getSeparator, { noHeadTags => 1 });
	my ($head, $foot) = split($self->getSeparator,$style);
	$self->session->output->print($head, 1);
	$self->session->output->print($self->view);
	$self->session->output->print($foot, 1);
	return "chunked";
}

1;

