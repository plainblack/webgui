package WebGUI::Asset::Wobject::SQLForm;

=head1 LEGAL

 -------------------------------------------------------------------
  /SQLForm is Copyright 2006 Procolix
 -------------------------------------------------------------------
  Please read the legal notices (legal.txt) and the license
  (license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.procolix.nl                     info@procolix.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::HTMLForm;
use WebGUI::Form;
use WebGUI::Asset::Wobject;
use WebGUI::Utility;
use WebGUI::DatabaseLink;
use WebGUI::International;
use WebGUI::User;
use Storable;
use Tie::IxHash;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::SQLForm

=cut

#-------------------------------------------------------------------
# This hash contains the allowed database field types. Keys indicate the MySQL name of the field type and 
# the values are the the way they are showed in the form.
my ($allowedDbFieldTypes, $allowedFormFieldTypes);
tie %{$allowedDbFieldTypes}, 'Tie::IxHash';
tie %{$allowedFormFieldTypes}, 'Tie::IxHash';


=head1 Usage of reserved keywords

It is not allowed to use columnnames that are in the list of reserved keywords. These
keywords are in the @reservedKeywords variable.

The list with reserved keywords is MySQL specific and is generously copy-pasted from:
 	http://dev.mysql.com/doc/mysql/en/reserved-words.html

=cut

my @reservedKeywords = qw(
	ACTION 	ADD 	AFTER
	AGAINST 	AGGREGATE 	ALGORITHM
	ALL 	ALTER 	ANALYZE
	AND 	ANY 	AS
	ASC 	ASCII 	ASENSITIVE
	AUTO_INCREMENT 	AVG 	AVG_ROW_LENGTH
	BACKUP 	BDB 	BEFORE
	BEGIN 	BERKELEYDB 	BETWEEN
	BIGINT 	BINARY 	BINLOG
	BIT 	BLOB 	BOOL
	BOOLEAN 	BOTH 	BTREE
	BY 	BYTE 	CACHE
	CALL 	CASCADE 	CASCADED
	CASE 	CHAIN 	CHANGE
	CHANGED 	CHAR 	CHARACTER
	CHARSET 	CHECK 	CHECKSUM
	CIPHER 	CLIENT 	CLOSE
	COLLATE 	COLLATION 	COLUMN
	COLUMNS 	COMMENT 	COMMIT
	COMMITTED 	COMPACT 	COMPRESSED
	CONCURRENT 	CONDITION 	CONNECTION
	CONSISTENT 	CONSTRAINT 	CONTAINS
	CONTINUE 	CONVERT 	CREATE
	CROSS 	CUBE 	CURRENT_DATE
	CURRENT_TIME 	CURRENT_TIMESTAMP 	CURRENT_USER
	CURSOR 	DATA 	DATABASE
	DATABASES 	DATE 	DATETIME
	DAY 	DAY_HOUR 	DAY_MICROSECOND
	DAY_MINUTE 	DAY_SECOND 	DEALLOCATE
	DEC 	DECIMAL 	DECLARE
	DEFAULT 	DEFINER 	DELAYED
	DELAY_KEY_WRITE 	DELETE 	DESC
	DESCRIBE 	DES_KEY_FILE 	DETERMINISTIC
	DIRECTORY 	DISABLE 	DISCARD
	DISTINCT 	DISTINCTROW 	DIV
	DO 	DOUBLE 	DROP
	DUAL 	DUMPFILE 	DUPLICATE
	DYNAMIC 	EACH 	ELSE
	ELSEIF 	ENABLE 	ENCLOSED
	END 	ENGINE 	ENGINES
	ENUM 	ERRORS 	ESCAPE
	ESCAPED 	EVENTS 	EXECUTE
	EXISTS 	EXIT 	EXPANSION
	EXPLAIN 	EXTENDED 	FALSE
	FAST 	FETCH 	FIELDS
	FILE 	FIRST 	FIXED
	FLOAT 	FLOAT4 	FLOAT8
	FLUSH 	FOR 	FORCE
	FOREIGN 	FOUND 	FRAC_SECOND
	FROM 	FULL 	FULLTEXT
	FUNCTION 	GEOMETRY 	GEOMETRYCOLLECTION
	GET_FORMAT 	GLOBAL 	GOTO
	GRANT 	GRANTS 	GROUP
	HANDLER 	HASH 	HAVING
	HELP 	HIGH_PRIORITY 	HOSTS
	HOUR 	HOUR_MICROSECOND 	HOUR_MINUTE
	HOUR_SECOND 	IDENTIFIED 	IF
	IGNORE 	IMPORT 	IN
	INDEX 	INDEXES 	INFILE
	INNER 	INNOBASE 	INNODB
	INOUT 	INSENSITIVE 	INSERT
	INSERT_METHOD 	INT 	INT1
	INT2 	INT3 	INT4
	INT8 	INTEGER 	INTERVAL
	INTO 	INVOKER 	IO_THREAD
	IS 	ISOLATION 	ISSUER
	ITERATE 	JOIN 	KEY
	KEYS 	KILL 	LABEL
	LANGUAGE 	LAST 	LEADING
	LEAVE 	LEAVES 	LEFT
	LEVEL 	LIKE 	LIMIT
	LINES 	LINESTRING 	LOAD
	LOCAL 	LOCALTIME 	LOCALTIMESTAMP
	LOCK 	LOCKS 	LOGS
	LONG 	LONGBLOB 	LONGTEXT
	LOOP 	LOW_PRIORITY 	MASTER
	MASTER_CONNECT_RETRY 	MASTER_HOST 	MASTER_LOG_FILE
	MASTER_LOG_POS 	MASTER_PASSWORD 	MASTER_PORT
	MASTER_SERVER_ID 	MASTER_SSL 	MASTER_SSL_CA
	MASTER_SSL_CAPATH 	MASTER_SSL_CERT 	MASTER_SSL_CIPHER
	MASTER_SSL_KEY 	MASTER_USER 	MATCH
	MAX_CONNECTIONS_PER_HOUR 	MAX_QUERIES_PER_HOUR 	MAX_ROWS
	MAX_UPDATES_PER_HOUR 	MAX_USER_CONNECTIONS 	MEDIUM
	MEDIUMBLOB 	MEDIUMINT 	MEDIUMTEXT
	MERGE 	MICROSECOND 	MIDDLEINT
	MIGRATE 	MINUTE 	MINUTE_MICROSECOND
	MINUTE_SECOND 	MIN_ROWS 	MOD
	MODE 	MODIFIES 	MODIFY
	MONTH 	MULTILINESTRING 	MULTIPOINT
	MULTIPOLYGON 	MUTEX 	NAME
	NAMES 	NATIONAL 	NATURAL
	NCHAR 	NDB 	NDBCLUSTER
	NEW 	NEXT 	NO
	NONE 	NOT 	NO_WRITE_TO_BINLOG
	NULL 	NUMERIC 	NVARCHAR
	OFFSET 	OLD_PASSWORD 	ON
	ONE 	ONE_SHOT 	OPEN
	OPTIMIZE 	OPTION 	OPTIONALLY
	OR 	ORDER 	OUT
	OUTER 	OUTFILE 	PACK_KEYS
	PARTIAL 	PASSWORD 	PHASE
	POINT 	POLYGON 	PRECISION
	PREPARE 	PREV 	PRIMARY
	PRIVILEGES 	PROCEDURE 	PROCESSLIST
	PURGE 	QUARTER 	QUERY
	QUICK 	RAID0 	RAID_CHUNKS
	RAID_CHUNKSIZE 	RAID_TYPE 	READ
	READS 	REAL 	RECOVER
	REDUNDANT 	REFERENCES 	REGEXP
	RELAY_LOG_FILE 	RELAY_LOG_POS 	RELAY_THREAD
	RELEASE 	RELOAD 	RENAME
	REPAIR 	REPEAT 	REPEATABLE
	REPLACE 	REPLICATION 	REQUIRE
	RESET 	RESTORE 	RESTRICT
	RESUME 	RETURN 	RETURNS
	REVOKE 	RIGHT 	RLIKE
	ROLLBACK 	ROLLUP 	ROUTINE
	ROW 	ROWS 	ROW_FORMAT
	RTREE 	SAVEPOINT 	SCHEMA
	SCHEMAS 	SECOND 	SECOND_MICROSECOND
	SECURITY 	SELECT 	SENSITIVE
	SEPARATOR 	SERIAL 	SERIALIZABLE
	SESSION 	SET 	SHARE
	SHOW 	SHUTDOWN 	SIGNED
	SIMPLE 	SLAVE 	SMALLINT
	SNAPSHOT 	SOME 	SONAME
	SOUNDS 	SPATIAL 	SPECIFIC
	SQL 	SQLEXCEPTION 	SQLSTATE
	SQLWARNING 	SQL_BIG_RESULT 	SQL_BUFFER_RESULT
	SQL_CACHE 	SQL_CALC_FOUND_ROWS 	SQL_NO_CACHE
	SQL_SMALL_RESULT 	SQL_THREAD 	SQL_TSI_DAY
	SQL_TSI_FRAC_SECOND 	SQL_TSI_HOUR 	SQL_TSI_MINUTE
	SQL_TSI_MONTH 	SQL_TSI_QUARTER 	SQL_TSI_SECOND
	SQL_TSI_WEEK 	SQL_TSI_YEAR 	SSL
	START 	STARTING 	STATUS
	STOP 	STORAGE 	STRAIGHT_JOIN
	STRING 	STRIPED 	SUBJECT
	SUPER 	SUSPEND 	TABLE
	TABLES 	TABLESPACE 	TEMPORARY
	TEMPTABLE 	TERMINATED 	TEXT
	THEN 	TIME 	TIMESTAMP
	TIMESTAMPADD 	TIMESTAMPDIFF 	TINYBLOB
	TINYINT 	TINYTEXT 	TO
	TRAILING 	TRANSACTION 	TRIGGER
	TRIGGERS 	TRUE 	TRUNCATE
	TYPE 	TYPES 	UNCOMMITTED
	UNDEFINED 	UNDO 	UNICODE
	UNION 	UNIQUE 	UNKNOWN
	UNLOCK 	UNSIGNED 	UNTIL
	UPDATE 	USAGE 	USE
	USER 	USER_RESOURCES 	USE_FRM
	USING 	UTC_DATE 	UTC_TIME
	UTC_TIMESTAMP 	VALUE 	VALUES
	VARBINARY 	VARCHAR 	VARCHARACTER
	VARIABLES 	VARYING 	VIEW
	WARNINGS 	WEEK 	WHEN
	WHERE 	WHILE 	WITH
	WORK 	WRITE 	X509
	XA 	XOR 	YEAR
	YEAR_MONTH 	ZEROFILL 	 
);

%{$allowedDbFieldTypes} = (
	# Integer column types
	tinyint		=> {
		name			=> 'tinyint',
		maxLength		=> 255,
		maxValue		=> 127,
		minValue		=> -128,
		maxValueUnsigned	=> 255,
		hasSign			=> 1,
		canAutoIncrement	=> 1,
		defaultFormElement	=> 'integer',
		defaultRegEx		=> 'defaultSigned',
	},
	smallint	=> {
		name			=> 'smallint',
		maxLength		=> 255,
		maxValue		=> 32_767,
		minValue		=> -32_768,
		maxValueUnsigned	=> 65_535,
		hasSign			=> 1,
		canAutoIncrement	=> 1,
		defaultFormElement	=> 'integer',
		defaultRegEx		=> 'defaultSigned',
	},
	mediumint	=> {
		name			=> 'mediumint',
		maxLength		=> 255,
		maxValue		=> 8_388_607,
		minValue		=> -8_388_608,
		maxValueUnsigned	=> 16_777_215,
		hasSign			=> 1,
		canAutoIncrement	=> 1,
		defaultFormElement	=> 'integer',
		defaultRegEx		=> 'defaultSigned',
	},
	'int'		=> {
		name			=> 'int',
		maxLength		=> 255,
		maxValue		=> 2_147_483_647,
		minValue		=> -2_147_483_648,
		maxValueUnsigned	=> 4_294_967_295,
		hasSign			=> 1,
		canAutoIncrement	=> 1,
		defaultFormElement	=> 'integer',
		defaultRegEx		=> 'defaultSigned',
	},
	bigint		=> {
		name			=> 'bigint',
		maxLength		=> 255,
		maxValue		=> 9_223_372_036_854_775_807,
		minValue		=> -9_223_372_036_854_775_808,
		maxValueUnsigned	=> 18_446_744_073_709_551_615,
		hasSign			=> 1,
		canAutoIncrement	=> 1,
		defaultFormElement	=> 'integer',
		defaultRegEx		=> 'defaultSigned',
	},

	# String column types
	char		=> {
		name			=> 'char',
		supportsFulltext	=> 1,
		maxLength		=> 255,
		defaultFormElement	=> 'text',
		defaultRegEx		=> 'defaultText',
	},	
	varchar		=> {
		name			=> 'varchar',
		supportsFulltext	=> 1,
		maxLength		=> 255,
		defaultFormElement	=> 'text',
		defaultRegEx		=> 'defaultText',
	},
	tinyblob	=> {
		name			=> 'tinyblob',
		supportsFulltext	=> 1,
		maxLength		=> 255,
		defaultFormElement	=> 'textarea',
		defaultRegEx		=> 'defaultText',
	},
	blob		=> {
		name			=> 'blob',
		supportsFulltext	=> 1,
		maxLength		=> 65_535,
		defaultFormElement	=> 'textarea',
		defaultRegEx		=> 'defaultText',
	},
	mediumblob	=> {
		name			=> 'mediumblob',
		supportsFulltext	=> 1,
		maxLength		=> 16_777_215,
		defaultFormElement	=> 'file',
		defaultRegEx		=> '',
	},
	longblob	=> {
		name			=> 'longblob',
		supportsFulltext	=> 1,
		maxLength		=> 4_294_967_295,
		defaultFormElement	=> 'file',
		defaultRegEx		=> '',
	},
	tinytext	=> {
		name			=> 'tinytext',
		supportsFulltext	=> 1,
		maxLength		=> 255,
		defaultFormElement	=> 'textarea',
		defaultRegEx		=> 'defaultText',
	},
	text		=> {
		name			=> 'text',
		supportsFulltext	=> 1,
		maxLength		=> 65_535,
		defaultFormElement	=> 'textarea',
		defaultRegEx		=> 'defaultText',
	},
	mediumtext	=> {
		name			=> 'mediumtext',
		supportsFulltext	=> 1,
		maxLength		=> 16_777_215,
		defaultFormElement	=> 'file',
		defaultRegEx		=> '',
	},
	longtext	=> {
		name			=> 'longtext',
		supportsFulltext	=> 1,
		maxLength		=> 4_294_967_295,
		defaultFormElement	=> 'file',
		defaultRegEx		=> '',
	},

	# Temporal column types
	datetime	=> {
		name			=> 'datetime',
		defaultFormElement	=> 'dateTime',
	},
	timestamp	=> {
		name			=> 'timestamp',
		readOnly		=> 1,
	},
	date		=> {
		name			=> 'date',
		defaultFormElement	=> 'date',
	},
	'time'		=> {
		name			=> 'time',
		defaultFormElement	=> 'timeField',
	},
	set	=> {
		name			=> 'set',
		supportsFulltext	=> 0,
		maxLength		=> 65_535,
		defaultFormElement	=> 'selectList',
		multipleAllowed		=> 1,
	},
);

=head1 Form element definitions

The $allowedFormFieldTypes hashref contains the allowed WebGUI form elements. Method names are indicated 
by the keys of the hash while the values are the screen labels in the form.

If you want to add addional form elements, you must add them to this hash. The elements you define here 
should be implemented in WebGUI::Form::myELement.

=cut

%{$allowedFormFieldTypes} = (
	text 		=> {
		name			=> 'Text',
		widthParam		=> 'size',
		maxLength		=> 255,
		searchElement		=> 'text',
		type			=> 'text',
		},
	textarea 	=> {
		name			=> 'Text area',
		widthParam		=> 'columns',
		heightParam		=> 'rows',
		searchElement		=> 'text',
		type			=> 'text',
		},
	HTMLArea 	=> {
		name			=> 'HTML area',
		widthParam		=> 'columns',
		heightParam		=> 'rows',
		searchElement		=> 'text',
		type			=> 'text',
		},
	integer		=> {
		name			=> 'Integer',
		widthParam		=> 'size',
		maxLength		=> 255,
		searchElement		=> 'integer',
		type			=> 'number',
		},
	float		=> {
		name			=> 'Float',
		widthParam		=> 'size',
		maxLength		=> 255,
		searchElement		=> 'float',
		type			=> 'number',
		},
	selectList 	=> {
		name 			=> 'Select list',
		heightParam		=> 'size',
		hasOptions		=> 1,
		canHaveMultipleValues	=> 1,
		searchElement		=> 'selectList',
		type			=> 'list',
		},
	radioList 	=> {
		name			=> 'Radio list',
		hasOptions		=> 1,
		searchElement		=> 'radioList',
#		type			=> 'list',
		},
	checkList 	=> {
		name			=> 'Check list',
		hasOptions		=> 1,
		canHaveMultipleValues	=> 1,
		searchElement		=> 'checkList',
		type			=> 'list',
		},
	date		=> {
		name			=> 'Date',
		searchElement		=> 'date',
		type			=> 'temporal',
	},
	timeField	=> {
		name			=> 'Time',
		searchElement		=> 'timeField',
		type			=> 'temporal',
	},
	dateTime	=> {
		name			=> 'Date/Time combo',
		searchElement		=> 'dateTime',
		type			=> 'temporal',
	},
	email		=> {
		name			=> 'Email address',
		searchElement		=> 'text',
		type			=> 'text',
	},
	url		=> {
		name			=> 'URL',
		searchElement		=> 'text',
		type			=> 'text',
	},
	file		=> {
		name			=> 'File',
	},
);

# The two hasrefs below are used by the search system
my $types = {
	text		=> {'' => 'Don\'t care', 1 => '=', 100 => 'like', 101 => 'regexp'},
	number		=> {'' => 'Don\'t care', 1 => '=', 2 => '<', 3 => '>', 4 => '<=', 5 => '>=', 6 => '!=', 10 => 'is between'},
	temporal	=> {'' => 'Don\'t care', 1 => '=', 2 => '<', 3 => '>', 4 => '<=', 5 => '>=', 6 => '!=', 10 => 'is between'},
	list		=> {'' => 'Don\'t care', 200 => 'match any', 201 => 'match all', 100 => 'like', 101 => 'regexp'},
};

my $typeFunctions = {
	text		=> 'switchTextField',
	number		=> 'switchNumberField',
	temporal	=> 'switchTemporalField',
	list		=> 'switchListField',
};

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 _canAlterTable ( )

Returns a boolean indicating whether the user is allowed to change (alter) the table structure. Ie. manage field etc.

=cut

sub _canAlterTable {
	my $self = shift;
	
	return ($self->canEdit || $self->session->user->isInGroup($self->get('alterGroupId')));
}

#-------------------------------------------------------------------

=head2 _canEditRecord ( )

Returns a boolean indicating whether the user is allowed to edit, delete and restore records.

=cut

sub _canEditRecord {
	my $self = shift;
	
	return ($self->canEdit || $self->session->user->isInGroup($self->get('submitGroupId')));
}

#-------------------------------------------------------------------

=head2 _canPurge ( )

Returns a boolean indictating whether the user is allowed to purge deleted records.

=cut

sub _canPurge {
	my $self = shift;

	return $self->_canAlterTable;
}

#-------------------------------------------------------------------

=head2 _constructColumnType ( fieldProperties )

Will construct a MySQL column definition string from the field properties passed as argument.

=head3 fieldProperties

A hashref containing the properties of the field for which this column definition is made. Properties
taken into account are: 

	* dbFieldType,
	* maxFieldLength,
	* formPopulationKeys,
	* signed

=cut

sub _constructColumnType {
	my $self = shift;
	my $processed = shift;
	
	# Construct the type specifier
	my $type = $processed->{dbFieldType};
	if ($type eq 'varchar' && $allowedDbFieldTypes->{$type}->{maxLength}) {
		$type .= '('.$processed->{maxFieldLength}.')' if ($processed->{maxFieldLength});
	}

	if ($type eq 'set') {
		my $formPopulationKeys = $self->session->form->process("formPopulationKeys");
		$formPopulationKeys =~ s/\r?\n/\',\'/g;
		$type .= '(\''.$formPopulationKeys.'\')';
	}
	
	if ($allowedDbFieldTypes->{$processed->{dbFieldType}}->{hasSign}) {
		if ($processed->{signed}) {
			# Explicitly add the signed flag, so we won't have to worry if mysql changes its defaults.
			$type .= ' signed';
		} else {
			$type .= ' unsigned';
		}
	}

	return $type;
}

#-------------------------------------------------------------------

=head2 _createFieldType ( dbFieldType, formFieldType )

Inserts a new field type into the SQLForm_fieldTypes table.

=head3 dbFieldType

The column type connected to this field type.

=head3 formFieldType

The form element to be used for this field type.

=cut

sub _createFieldType {
	my $self = shift;
	my $dbFieldType = shift;
	my $formFieldType = shift;
	
	my $fieldTypeId = $self->session->id->generate;

	$self->session->db->write('insert into SQLForm_fieldTypes (fieldTypeId, dbFieldType, formFieldType) '.
		' values ('.$self->session->db->quote($fieldTypeId).', '.$self->session->db->quote($dbFieldType).', '.$self->session->db->quote($formFieldType).')');

	return $fieldTypeId;
}

#-------------------------------------------------------------------

=head2 _databaseLinkHasPrivileges ( wantedPrivileges, databaseLink )

Returns true if the database link has at least the given privileges.

=head3 wantedPrivileges

Arrayref containing the desired privileges (eg. ['SELECT','ALTER'])

=head3 databaseName

The name of the database you want to check the privileges of.

=head3 databaseLink

An instanciated databaselink object. Defaults to the databaselink of the sqlform table.

=cut

sub _databaseLinkHasPrivileges {
	my (@privileges, @grants, $databaseName, @dsnEntries);
	my $self = shift;
	my $wantedPrivileges = shift;
	my $dbLink = shift || $self->_getDbLink;

	# DSN can have a potpourri of forms
	# DBI:mysql:dbName:dbHost:dbPort (databaseHost and dbPort are optional)
	# DBI:mysql:database=dbName;host=dbHost (databaseHost is optional)
	# But also this:
	# DBI:mysql:db=dbName;dbHost:dbPort etc, etc.
	# The following code tries to extract the databasename
	@dsnEntries = split(/[:;]/, $dbLink->get->{DSN});

	if ($dsnEntries[2] !~ /=/) {
		$databaseName = $dsnEntries[2];
	} else {
		foreach (@dsnEntries) {
			if ($_ =~ m/^(database|db|dbname)=(.+)$/) {
				$databaseName = $2;
				last;
			}
		}
	}

	# Get all the grants for the db link user and fetch the one referring to the 
	# database of the db link.
	@grants = $dbLink->db->buildArray('show grants for current_user');

	foreach (@grants) {
		if (m/GRANT ([\w\s\d,]*?) ON .$databaseName.*$/) {
			push(@privileges, (split(/, /,$1)));
		}
	}

	# Check ik all required privs are present.
	return 1 if (isIn('ALL PRIVILEGES', @privileges));
	
	foreach (@$wantedPrivileges) {
		return 0 unless (isIn(uc($_), @privileges));
	}
}

#-------------------------------------------------------------------

=head2 _getDbLink ( )

Returns a WebGUI::DatabaseLink object for the database the SQLForm table is in.

=cut

sub _getDbLink {
	my $self = shift;

	return WebGUI::DatabaseLink->new($self->session, $self->getValue('databaseLinkId'));
}

#-------------------------------------------------------------------

=head2 _getFieldProperties ( fieldId )

Returns a hashref containing the properties of the field indicated by fieldId. 

=head3 fieldId

The id of the field of which the properties should be returned.

=cut

sub _getFieldProperties {
	my ($dbLink, $fieldId, %definition, $properties, @tables, @where, $query, $options, @keys, @values, $numberOfJoins);
	my $self = shift;
	$fieldId = shift;

	return $self->{_fieldPropertiesCache}->{$fieldId} if exists ($self->{_fieldPropertiesCache}->{$fieldId});

	$dbLink = $self->_getDbLink;
	%definition = $self->session->db->buildHash("select property, value from SQLForm_fieldDefinitions where fieldId = ".$self->session->db->quote($fieldId));
	
	$properties = { %{$allowedFormFieldTypes->{$definition{formFieldType}}}, %{$allowedDbFieldTypes->{$definition{dbFieldType}}} };

	#### This should be preprocessed in editFieldSave to increase performance ####
	# Calculate the number of tables in the join
	foreach (keys(%definition)) {
		if (m/^table(\d+)$/) {
			$numberOfJoins = $1 if ($1 > $numberOfJoins);
		}
	}
	$definition{numberOfJoins} = $numberOfJoins;
			
	tie %$options, "Tie::IxHash";
	if (exists $definition{formPopulationKeys}) {
		@keys = split(/[\r\n]+/, $definition{formPopulationKeys});
		@values = split(/[\r\n]+/, $definition{formPopulationValues});

		##Assign all values to keys in an ordered, 1:1 way
		@{ $options }{@keys} = @values;
	}

	
	if ($definition{selectField1} && $definition{selectField2}) {
my		$sth = $dbLink->db->unconditionalRead($definition{sqlQuery}." order by ".$definition{selectField2});
		while (my @row = $sth->array) {
			$options->{$row[0]} = $row[1];
		}
#		$options = $dbLink->db->buildHashRef($definition{sqlQuery}." order by ".$definition{selectField2});
	}
	
	if (exists $definition{sqlQueryAllOptions}) {
		$properties->{allOptions} = $dbLink->db->buildHashRef($definition{sqlQueryAllOptions});
	} else {
		$properties->{allOptions} = $options;
	}

	$properties->{options} = $options;
	$properties->{processedDefaultValue} = WebGUI::Macro::process($self->session, $definition{defaultValue});
	$properties->{fieldId} = $fieldId;

	$self->{_fieldPropertiesCache}->{$fieldId} = {%definition, %$properties};

	return {%definition, %$properties};
}

#-------------------------------------------------------------------

=head2 _getDatabaseInfo ( )

Returns a hashref containing all tables and columns including column properties in the database in which the SQLForm 
resides.

=cut

sub _getDatabaseInfo {
	my (@tables, $tableName, $sth, $columnDefinition, $currentColumn, $databaseDefinition);
	my $self = shift;

	my $dbLink = $self->_getDbLink;
	@tables = $dbLink->db->buildArray("show tables");

	foreach $tableName (@tables) {
		$sth = $dbLink->db->read("describe ".$tableName);
		
		while ($columnDefinition = $sth->hashRef) {

			$currentColumn = {
				name		=> $columnDefinition->{Field},
				type		=> $columnDefinition->{Type},
				canBeNull	=> $columnDefinition->{Null},
				defaultValue	=> $columnDefinition->{Default},
				# Might need these fields in the future 
				#extra		=> $columnDefinition->{Extra},
				#key		=> $columnDefinition->{Key},
			};
			$databaseDefinition->{$tableName}->{$currentColumn->{name}} = $currentColumn;
		}
	}

	$dbLink->disconnect;
	return $databaseDefinition; 
}

#-------------------------------------------------------------------

=head2 _getFileFromDatabase ( recordId, fieldName, [ revision ] )

Returns the file contents and mime type of files stored in file fields.

=head3 recordId

The recordId of the record you want the file contents of.

=head3 fieldName

The the name of the column containing the actual file data.

=head3 revision

The revision number of the record you wan to select. If this is omitted the most
recent revision will be fetched.

=cut

sub _getFileFromDatabase {
	my ($constraint, $dbLink);
	my $self = shift;
	my $recordId = shift || return undef;
	my $fieldName = shift || return undef;
	my $revision = shift;

	$dbLink = $self->_getDbLink;

	if ($revision =~ m/^\d+$/) {
		$constraint = '__revision='.$self->session->db->quote($revision);
	} else {
		$constraint = '__archived = 0';
	}
	
	my $sql = 
		'select '.
			' __'.$fieldName.'_mimeType, '.
			$fieldName.
		' from '.
			$self->get('tableName').
		' where '.
			'__recordId='.$self->session->db->quote($recordId).' and '.
			$constraint;

	return $dbLink->db->quickArray($sql);
}



#-------------------------------------------------------------------

=head2 _getManagementLinks ( )

Returns a string containg all of the management function the user is allowed to use.

=cut

sub _getManagementLinks {
	my (@links, $i18n);
	my $self = shift;
	
	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	push(@links, '<a href="'.$self->getUrl('func=editRecord;rid=new').'">'.$i18n->get('add record title').'</a>') if ($self->_canEditRecord);
	push(@links, '<a href="'.$self->getUrl('func=search').'">'.$i18n->get('search records title').'</a>') if ($self->canView);
	push(@links, '<a href="'.$self->getUrl('func=listFields').'">'.$i18n->get('manage fields').'</a>') if ($self->_canAlterTable);
	push(@links, '<a href="'.$self->getUrl('func=listRegexes').'">'.$i18n->get('manage regexes').'</a>') if ($self->_canAlterTable);
	push(@links, '<a href="'.$self->getUrl('func=listFieldTypes').'">'.$i18n->get('manage field types').'</a>') if ($self->_canAlterTable);

	return join('&middot;',@links);
}

#-------------------------------------------------------------------

=head2 _matchField ( string, regexId )

Excutes the regex identified by regexId on the string passed as first argument and return a boolean indicating 
whether it is a match or not. Will return true if no regex id or a non-existing regex id is passed.

=head3 string

The string to be matched.

=head3 regexId

The id of the regex to used.

=cut

sub _matchField {
	my $self = shift;
	my $data = shift;
	my $regexId = shift;

	return 1 unless ($regexId);

	my ($regex) = $self->session->db->quickArray('select regex from SQLForm_regexes where regexId='.$self->session->db->quote($regexId));

	return 1 unless ($regex);
	
	if ($data =~ m/$regex/) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 _resolveFieldConstraintType ( type )

Translates the numerical value used in field constraint types to a perl operator.

=head3 type

The numerical id for the operator. If omitted this method will return a hasref containing
all numerical <-> operator mappings.

=cut

sub _resolveFieldConstraintType {
	my $self = shift;
	my $type = shift;

	my $i18n = WebGUI::International->new($self->session, 'Asset_SQLForm');

	my $types = {'0' => $i18n->get('none'), 1 => '>', 2 => '>=', 3 => '<', 4 => '<=', 5 => '='};

	return $types->{$type} if ($type);
	return $types;
}

#-------------------------------------------------------------------

=head2 _uncacheFieldProperties ( fieldId )

Removes the cached properties of the given field. Fiekd properties are automatically cached
by _getFieldProperties.

=head3 fieldId

The GUID of the field to uncache the properties of.

=cut

sub _uncacheFieldProperties {
	my $self = shift;
	my $fieldId = shift;

	delete($self->{_fieldPropertiesCache}->{$fieldId});
}

#-------------------------------------------------------------------

=head2 definition ( )

The asset definition of the SQLForm.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	
	push(@{$definition}, {
		tableName=>'SQLForm',
		className=>'WebGUI::Asset::Wobject::SQLForm',
		icon=>'sqlform.gif',
		properties=>{
			formId		=> {
				fieldType	=> 'text',
				defaultValue	=> undef,
			},
			tableName	=> {
				fieldType	=> 'text',
				defaultValue	=> undef,
			},
			maxFileSize	=> {
				fieldType	=> 'integer',
				defaultValue	=> 1_500_000,
			},
			sendMailTo	=> {
				fieldType	=> 'email',
				defaultValue	=> undef,
			},
			showMetaData	=> {
				fieldType	=> 'yesNo',
				defaultValue	=> 1,
			},
			searchTemplateId=> {
				fieldType	=> 'template',
				defaultValue	=> 'SQLFormSearchTmpl00001',
			},
			editTemplateId	=> {
				fieldType	=> 'template',
				defaultValue	=> 'SQLFormEditTmpl0000001',
			},
			submitGroupId	=> {
				fieldType	=> 'group',
				defaultValue	=> undef,
			},
			alterGroupId	=> {
				fieldType	=> 'group',
				defaultValue	=> undef,
			},
				databaseLinkId	=> {
				fieldType	=> 'databaseLink',
				defaultValue	=> 0,
			},
			defaultView	=> {
				fieldType	=> 'selectBox',
				defaultValue	=> 'normalSearch',
			},
		}
	});
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 uiLevel ( )

The uiLevel of the SQLForm asset. It is a power tool so the uiLevel is set to 9.

=cut

sub uiLevel {
	return 9;
}

#-------------------------------------------------------------------

=head2 getAdminConsoleWithSubmenu ( )

Return the adminconsole but adds three submenu items for manage fields/field types/regexes.

=cut

sub getAdminConsoleWithSubmenu {
	my $self = shift;
	my $ac = $self->getAdminConsole;

	my $i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

	$ac->addSubmenuItem($self->getUrl('func=listFields'), $i18n->get('manage fields'));
	$ac->addSubmenuItem($self->getUrl('func=listFieldTypes'), $i18n->get('manage field types'));
	$ac->addSubmenuItem($self->getUrl('func=listRegexes'), $i18n->get('manage regexes'));

	return $ac;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Creates the edit form of the SQLForm asset.

=cut

sub getEditForm {
	my ($availableDbLinks, $i18n);
	my $self = shift;

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	$availableDbLinks = WebGUI::DatabaseLink->getList($self->session);
	delete($availableDbLinks->{'0'});

	my $tabform = $self->SUPER::getEditForm;

	unless (keys(%$availableDbLinks)) {
		$tabform->getTab('properties')->readOnly(
			-value	=> 
				'<script type="text/javascript">'.
				'	alert("'.$i18n->get('gef no db links').'");'.
				'	history.go(-1);'.
				'	</script>',
		);

		return $tabform;
	}

	$tabform->submit({
		id	=> 'zeSubmitButton',
	});

	$tabform->getTab('properties')->text(
		-name		=> 'tableName',
		-label		=> $i18n->get('gef table name'),
		-hoverHelp	=> $i18n->get('gef table name description'),
		-value		=> $self->get('tableName'),
		-extras		=> 'onkeyup="e = document.getElementById(\'zeSubmitButton\'); '
					.' if (this.value != \'\' ) { e.disabled = false} else {e.disabled = true};"',
	);
	$tabform->getTab('properties')->checkbox(
		-name		=> 'importTable',
		-label		=> $i18n->get('gef import table'),
		-hoverHelp	=> $i18n->get('gef import table description'),
		-value		=> [1],
		-checked	=> $self->session->form->process('importTable'),
	);
	$tabform->getTab('properties')->selectList(
		-name		=> 'databaseLinkId',
		-label		=> $i18n->get('gef database to use'),
		-hoverHelp	=> $i18n->get('gef database to use description'),
		-options	=> $availableDbLinks,
		-value		=> [$self->get('databaseLinkId') || (keys(%$availableDbLinks))[0]],
		-size		=> 1,
		-multiple	=> 0,
	);
	$tabform->getTab('properties')->integer(
		-name		=> 'maxFileSize',
		-label		=> $i18n->get('gef max file size'),
		-hoverHelp	=> $i18n->get('gef max file size description'),
		-value		=> $self->getValue('maxFileSize'),
	);
	$tabform->getTab('properties')->text(
		-name		=> 'sendMailTo',
		-label		=> $i18n->get('gef send mail to'),
		-hoverHelp	=> $i18n->get('gef send mail to description'),
		-value		=> $self->getValue('sendMailTo'),
	);
	$tabform->getTab('properties')->yesNo(
		-name		=> 'showMetaData',
		-label		=> $i18n->get('gef show meta data'),
		-hoverHelp	=> $i18n->get('gef show meta data description'),
		-value		=> $self->getValue('showMetaData'),
	);
	$tabform->getTab('display')->template(
		-name		=> 'editTemplateId',
		-label		=> $i18n->get('gef edit template'),
		-hoverHelp	=> $i18n->get('gef edit template description'),
		-value		=> $self->get('editTemplateId'),
		-namespace	=> 'SQLForm/Edit',
	);
	$tabform->getTab('display')->template(
		-name		=> 'searchTemplateId',
		-label		=> $i18n->get('gef search template'),
		-hoverHelp	=> $i18n->get('gef search template description'),
		-value		=> $self->get('searchTemplateId'),
		-namespace	=> 'SQLForm/Search',
	);
	$tabform->getTab('display')->selectBox(
		-name		=> 'defaultView',
		-label		=> $i18n->get('gef default view'),
		-hoverHelp	=> $i18n->get('gef default view description'),
		-value		=> [$self->get('defaultView')],
		-options	=> {
			'normalSearch' => $i18n->get('s normal search'), 
			'superSearch' => $i18n->get('s advanced search')
		},
		-multiple	=> 0,
	);
	$tabform->getTab('security')->group(
		-name		=> 'submitGroupId',
		-label		=> $i18n->get('gef submit group'),
		-hoverHelp	=> $i18n->get('gef submit group description'),
		-value		=> [ $self->get('submitGroupId') ],
	);
	
	$tabform->getTab('properties')->readOnly(
		-value		=> '<script type="text/javascript">'
			."document.getElementById('zeSubmitButton').disabled = true;"
			.'</script>',
	) unless ($self->get('tableName'));

	return $tabform;
}

#-------------------------------------------------------------------

=head2 getIndexerParams ( )

Should index the data in the table of this SQLForm. Not functional in 6.8.x due to a crippled 
search framework.

=cut

sub getIndexerParams {
        my $self = shift;
        my $now = shift;
	my $sth = $self->session->db->read("select t1.url, t2.* from asset as t1, SQLForm as t2 where t1.assetId = t2.assetId");

	my $result = {};
	while (my %row = $sth->hash) {
		my $tableName = $row{tableName};
		my $assetId = $row{assetId};

		if ($row{databaseLinkId}) {
			my $dbName;
			my %dbInfo = WebGUI::DatabaseLink::get($row{databaseLinkId});
			($dbName = $dbInfo{DSN}) =~ s/DBI\:\w+\:(\w+)/$1/i;
			$tableName = $dbName.'.'.$tableName;
		}
		my @indexFields = $self->session->db->buildArray("select t2.value from SQLForm_fieldDefinitions as t1, SQLForm_fieldDefinitions as t2 where ".
			" t1.fieldId=t2.fieldId and t1.property='useFulltext' and t1.value=1 and t2.property='fieldName' and t1.assetId=".$self->session->db->quote($assetId));

		my $concatFields = 'concat('. join(",' | ',",@indexFields).')';
		$result->{'SQLForm_'.$tableName} = {
                        sql => "select 
					* 
				from 
					$tableName
				where
					__archived = 0 and
					__deleted = 0
				",
                        fieldsToIndex => \@indexFields,
                        contentType => 'content',
                        url => 'my $url=\''.$row{url}.'\'; $self->session->url->gateway($url,\'func=editRecord;rid=\'.$data{__recordId})',
                        headerShortcut => 'select title from asset where assetId = \''.$assetId.'\'',
                        bodyShortcut => 'select '.$concatFields.' from '.$tableName.' where __recordId = \'$data{__recordId}\''
                };
	}

	return $result;
}

#-------------------------------------------------------------------

=head2 getName ( )

Return the internationalized name of the SQLForm.

=cut

sub getName {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_SQLForm');
	return $i18n->get('assetName');
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Processes the data in the edit form of the SQLForm asset. In WebGUI 6.8.x there's no way to feed back any errors on 
asset addition. Therefore if something is wrong this method will use die to stop the processing. This will heave the 
effect that an SQLForm asset is added to the asset tree, but it won't have any properties saved. You should delete 
the 'empty' asset from your asset tree using the asset manager.

This problem will be solved in 7.0.0.

=cut

sub processPropertiesFromFormPost {
	my ($tableName, @tables, @usedTables);
	my $self = shift;

	my $dbLink = WebGUI::DatabaseLink->new($self->session, $self->session->form->process("databaseLinkId"));

	# $dbLink->db will raise a fatal error if there is a connection error.
#	return ["Can't connect to database through the selected database link"] unless ($dbLink->db);

	unless ($self->_databaseLinkHasPrivileges([qw(ALTER CREATE DELETE INDEX INSERT SELECT UPDATE)], $dbLink)) {
		return ["Databaselink does not have enough privileges (Needs ALTER, CREATE, DELETE, INDEX, INSERT, SELECT, UPDATE)"];
	}

	$tableName = $self->session->form->process("tableName");

	if ($self->session->form->process("assetId") eq 'new') {
		#if table exists and not in SQLForm format, put in SQLFormFormat.
		@tables = $dbLink->db->buildArray("show tables");
		
		@usedTables = $self->session->db->buildArray("select tableName, state  from SQLForm, asset where asset.assetID=SQLForm.assetId and state='published'");

		if (isIn(lc($tableName), map {lc} @usedTables)) {
			return ["The table is already used in an SQLForm."];
		}
		elsif ($tableName !~ m/^[\w\d_]+$/i) {
			return ["The table name is illegal."];
		}
		elsif (isIn(lc($tableName), map {lc} @tables) && !$self->session->form->process('importTable')) {
			return ["The table already exists in the database but the import flag has not been set."];
		}
		elsif (isIn(lc($tableName), map {lc} @tables)) { #&& !(isIn(lc($tableName), map {lc} @usedTables))) {
			# exisiting table
		        # Write column data to db -----------------------------------------------------------------------------
			my $controlDefined = 0;
	                my $sth = $dbLink->db->read("describe ".$tableName);
			my $processed;
			my @columnNames;
			my $rank = 0;
		        while (my $columnDefinition = $sth->hashRef) {
				if ($columnDefinition->{Field} =~ m/^__*/ ) {
					$controlDefined = 1;
				} else {
					# clear properties hash
					$processed = {};

					my $type = $columnDefinition->{Type};
					my $set = $columnDefinition->{Type};
					my $length;
					$set =~ s/^.*\(//;
					$set =~ s/\)$//;
					$set =~ s/,/\r\n/g;
					$set =~ s/'//g;
					$length = $set + 0;
					$type =~ s/\(.*\)//;

					my $currentField = $allowedDbFieldTypes->{$type};
					
					# Get the fieldTypeId of this column
					my ($fieldType) = $self->session->db->quickArray("select fieldTypeId from SQLForm_fieldTypes "
						." where dbFieldType=".$self->session->db->quote($type)." and formFieldType=".$self->session->db->quote($currentField->{defaultFormElement}));
					
					# Create the field type if it doesn't exist
					unless ($fieldType) {
						$fieldType = $self->_createFieldType($type, $currentField->{defaultFormElement});
					}
					
					# Check for 
					if ($columnDefinition->{Extra} =~ /auto_increment/) {
						$processed->{useAutoIncrement} = 1;
						my $dropAutoIncrementSQL = "alter table $tableName change column ".$columnDefinition->{Field}.
							" ".$columnDefinition->{Field}." ". $columnDefinition->{Type};
						$dropAutoIncrementSQL .= " NOT NULL " if ($columnDefinition->{Null} ne 'YES');
						$dropAutoIncrementSQL .= " default '".$columnDefinition->{Default}."' " if ($columnDefinition->{Default} && ($columnDefinition->{Default} ne 'NULL'));
					
						$dbLink->db->write($dropAutoIncrementSQL);
					}

					$processed->{defaultValue} = $columnDefinition->{Default} if ($columnDefinition->{Default} ne 'NULL');
					$processed->{isRequired} = 1 if ($columnDefinition->{Null} ne 'YES');
					$processed->{formPopulationValues} = $set if ($type =~ m/^set/i);
					$processed->{formPopulationKeys} = $set if ($type =~ m/^set/i);
					$processed->{dbFieldType} = $type;
					$processed->{formFieldType} = $currentField->{defaultFormElement};
					$processed->{fieldType} = $fieldType;
					$processed->{maxFieldLength} = $currentField->{maxLength} if ($currentField->{maxLength});
					$processed->{regex} = $currentField->{defaultRegEx} if ($currentField->{defaultRegEx});
					$processed->{fieldName} = $columnDefinition->{Field};
					$processed->{displayName} = $columnDefinition->{Field};
					$processed->{signed} = '1';
					$processed->{showInSearchResults} = '1';
					$processed->{isSearchable} = '1';
					my $fieldId = $self->session->id->generate;
       	         			$self->session->db->write('delete from SQLForm_fieldDefinitions where fieldId='.$self->session->db->quote($fieldId));
	                		foreach (keys(%$processed)) {
	                        		$self->session->db->write('insert into SQLForm_fieldDefinitions (fieldId, assetId, property, value) values '.
	                        	        	'('.$self->session->db->quote($fieldId).','.$self->session->db->quote($self->get('assetId')).','.$self->session->db->quote($_).','.$self->session->db->quote($processed->{$_}).')');
					}
	                       		$self->session->db->write('insert into SQLForm_fieldOrder (fieldId, assetId, rank) values '.
	                       	        	'('.$self->session->db->quote($fieldId).','.$self->session->db->quote($self->get('assetId')).','.$self->session->db->quote($rank).')');
					$rank++;

					push (@columnNames, $columnDefinition->{Field});
				}
                	}

			# We can't allow primary keys in the table because of the versioning.
			# A composite pk with __recordId and __revision would work but makes no sense because
			# __recordId and __revision are always unique and hence the pk.
my %dropKeys;
my $hasPrimaryKey = 0;
			$sth = $dbLink->db->read("show keys from $tableName");
			while (my %row = $sth->hash) {
				if ($row{Key_name} eq 'PRIMARY') {
					$hasPrimaryKey = 1;
				} else {
					$dropKeys{$row{Key_name}} = 1;
				}
			}
			
			$dbLink->db->write("alter table $tableName drop primary key") if ($hasPrimaryKey);
			
			foreach (keys(%dropKeys)) {
				$dbLink->db->write("alter table $tableName drop index $_ ");
			}
			
			if ($controlDefined == 0){	
				# add control fields
				$dbLink->db->write("alter table $tableName  ".
					" add __recordId varchar(22) binary not null,".
					" add __creationDate bigint(20),".
					" add __createdBy varchar(22) binary,".
					" add __initDate bigint(20),".
					" add __userId varchar(22) binary,".
					" add __deletionDate bigint(20),".
					" add __deleted tinyint(1) default 0,".
					" add __deletedBy varchar(22),".
					" add __archived tinyint(1) default 0,".
					" add __revision int(11) not null".
				" ");
			
				# fill status fields
				my $sql = 	
					"update $tableName set ".
					"__recordId = (select concat(rand(),rand())),".
					"__creationDate = ".$self->session->db->quote(time).", ".
					"__createdBy = ".$self->session->db->quote($self->session->user->userId).", ".
					"__initDate = ".$self->session->db->quote(time).", ".
					"__userId = ".$self->session->db->quote($self->session->user->userId).", ".
					"__archived = 0, ".
					"__revision = 1 ";
				$dbLink->db->write($sql);
				#print "$sql\n";
			}
			
			$dbLink->db->write("alter table $tableName add primary key (__recordId, __revision)");
		} 
		else {
			#new table
			$dbLink->db->write("create table $tableName (".
				" __recordId varchar(22) binary not null,".
				" __creationDate bigint(20) not null,".
				" __createdBy varchar(22) not null,".
				" __initDate bigint(20) not null,".
				" __userId varchar(22) not null,".
				" __deletionDate bigint(20),".
				" __deleted tinyint(1) default 0,".
				" __deletedBy varchar(22),".
				" __archived tinyint(1) default 0,".
				" __revision int(11) not null,".
				" primary key (__recordId, __revision)".
			")");
		}
	} 
	else {
		if ($self->get('tableName') ne $tableName) {
			$dbLink->db->write("rename table ".$self->get('tableName')." to $tableName");
		}
	}

	$dbLink->disconnect;
	return $self->SUPER::processPropertiesFromFormPost;
}

#-------------------------------------------------------------------

=head2 purge ( )

This method purges the Asset completely from the WebGUI instance.

=cut

sub purge {
	my $self = shift;
	
	$self->session->db->write("delete from SQLForm_fieldDefinitions where assetId=".$self->session->db->quote($self->getId));
	$self->session->db->write("delete from SQLForm_fieldOrder where assetId=".$self->session->db->quote($self->getId));

	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view ( )

The view function of the Asset.

=cut

sub view {
	my $self = shift;
	my ($output, @links);

	if ($self->get('defaultView') eq 'superSearch') {
		return $output .$self->www_superSearch;
	}else{
		return $output .$self->www_search;
	}
}

#-------------------------------------------------------------------

=head2 www_deleteFieldType ( )

This will delete the field type with the id that is passed in a form param called 'ftid'.

=cut

sub www_deleteFieldType {
	my ($isUsed);
	my $self = shift;

	my $i18n = WebGUI::International->new($self->session, 'Asset_SQLForm');
	
	return $self->session->privilege->insufficient unless ($self->_canAlterTable);
	
	($isUsed) = $self->session->db->quickArray(' select count(fieldId) '.
		' from SQLForm_fieldDefinitions '.
		' where property="fieldType" and value='.$self->session->db->quote($self->session->form->process("ftid")));
	
	if ($isUsed) {
		return $self->processStyle($i18n->get('dft cannot delete')." $isUsed ".$i18n->get('sqlforms').".");
	} else {
		$self->session->db->write('delete from SQLForm_fieldTypes where fieldTypeId='.$self->session->db->quote($self->session->form->process("ftid")));
		return $self->www_listFieldTypes;
	}
}

#-------------------------------------------------------------------

=head2 www_deleteRecord ( )

Will put the record with the id given by the form param 'rid', in the trash of the SQLForm.

=cut

sub www_deleteRecord {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canEditRecord);
	my $dbLink = $self->_getDbLink;
	
	$dbLink->db->write("update ".$self->get('tableName')." set ".
		" __deleted=1,".
		" __deletionDate=".$self->session->db->quote(time).",".
		" __deletedBy=".$self->session->db->quote($self->session->user->userId).
		" where __recordId=".$self->session->db->quote($self->session->form->process("rid"))
	);

	$dbLink->disconnect;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteRegex ( )

Deletes the regex with the id given in the form param 'regexId'.

=cut

sub www_deleteRegex {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	unless ($self->session->form->process("regexId") =~ /^default/) {
		$self->session->db->write('delete from SQLForm_regexes where regexId='.$self->session->db->quote($self->session->form->process("regexId")));
	} else {
		return $self->session->privilege->vitalComponent;
	}
	
	return $self->www_listRegexes;
}

#-------------------------------------------------------------------

=head2 www_disableField ( )

Will mark the field indicated by the id given by the form param 'fid' as deleted. This means
that the field is not included in searches and edits. No data is actually purged though.

=cut

sub www_disableField {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$self->session->db->write('delete from SQLForm_fieldDefinitions '.
		' where property="disabled" and assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($self->session->form->process("fid")));
	$self->session->db->write('insert into SQLForm_fieldDefinitions '.
		' (assetId, fieldId, property, value) values '.
		' ('.$self->session->db->quote($self->getId).', '.$self->session->db->quote($self->session->form->process("fid")).', "disabled", 1)');

	return $self->www_listFields;
}

#-------------------------------------------------------------------

=head2 www_enableField ( )

Will mark the 'deleted' field identified by the id given in the form param 'fid' as normal again.

=cut

sub www_enableField {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$self->session->db->write('delete from SQLForm_fieldDefinitions '.
		' where property="disabled" and assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($self->session->form->process("fid")));
		
	return $self->www_listFields;
}

#-------------------------------------------------------------------

=head2 www_editField ( )

Returns the 'edit field properties' form of the field attached to the id given in form param 'fid'. If fid is set
to 'new' it will add a new field. The form generated relies heavily on three javascript files included in the 
<webgui-root>/extras/SQLForm directory.

=cut

sub www_editField {
	my ($databaseDefinition, $fieldId, $properties, $f, $tabForm, $jsDatabaseDef, $table, $jsInitForm, $regexes, 
		%dbFields, %formFields, $output, $i18n, @jsFieldTypeList);
	my $self = shift;
	my $errors = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

	my $dbLink = $self->_getDbLink;
	
	# generate column properties hash in javascript
	my $jsDataStruct = "var fieldTypes = new Object;\n";
	$jsDataStruct .= "fieldTypes = {\n";
	foreach my $type (keys(%{$allowedDbFieldTypes})) {
		my $jsFieldType = "\t'$type' : {\n";
		$jsFieldType .= join(",\n", map {"\t\t'$_' : '".$allowedDbFieldTypes->{$type}->{$_}."'"} keys(%{$allowedDbFieldTypes->{$type}}));
		$jsFieldType .= "\n\t}";

		push(@jsFieldTypeList, $jsFieldType);
	}

	$jsDataStruct.= join(",\n", @jsFieldTypeList)."};"; 
	$self->session->style->setRawHeadTags('<script type="text/javascript">'.$jsDataStruct.'</script>');

	$fieldId = $self->session->form->process("fid");
	return $self->www_view unless ($fieldId);

	if ($self->session->form->process("func") eq 'editFieldSave') {
		$properties = $self->session->form->paramsHashRef;
	} elsif ($fieldId eq 'new') {
		$properties = {
			signed			=> 1,
			useAutoIncrement	=> 0,
			isSearchable		=> 1,
			isReadOnly		=> 0,
			useFulltext		=> 0,
			showInSearchResults	=> 1,
		};
	} else {
		$properties = $self->session->db->buildHashRef('select property, value from SQLForm_fieldDefinitions where fieldId = '.$self->session->db->quote($fieldId));
	}
	
	tie %$regexes, "Tie::IxHash";
	$regexes = $self->session->db->buildHashRef("select regexId, concat(name, ' (', regex, ')') from SQLForm_regexes order by name");
	$regexes->{''} = 'No regex';
	
	$databaseDefinition = $self->_getDatabaseInfo;

	tie %dbFields, 'Tie::IxHash';
	tie %formFields, 'Tie::IxHash';
	%dbFields = map {$_ => $allowedDbFieldTypes->{$_}->{name}} keys %{$allowedDbFieldTypes};
	%formFields = map {$_ => $allowedFormFieldTypes->{$_}->{name}} keys %{$allowedFormFieldTypes};
my	%fieldTypes = $self->session->db->buildHash('select fieldTypeId, concat(formFieldType, "/", dbFieldType) from SQLForm_fieldTypes');

	unless (%fieldTypes) {
		return $self->processStyle('There are no field types defined. Please define field types first.<br>'.
			'To add a field type please go to <a href="'.$self->getUrl('func=listFieldTypes').'">Manage field types</a>.'
		);
	}
	
	$tabForm = WebGUI::TabForm->new($self->session, undef, undef, $self->getUrl('func=listFields'));
	$tabForm->hidden({
		name	=> 'func', 
		value	=> 'editFieldSave'
	});
	$tabForm->hidden({
		name	=> 'fid', 
		value	=> $fieldId
	});

	# Insert warning
	unless ($fieldId eq 'new') {
my		$message = $i18n->get('change field warning');
		$tabForm->formHeader({
			extras	=> 'onsubmit="'.
				"if (document.getElementById('SQLFormFieldType').value != '".$properties->{fieldType}."' || ".
				"document.getElementById('SQLFormMaxFieldLength').value < ".($properties->{maxFieldLength} || '0').
#				" || "."document.getElementById('SQLFormSigned').value != '".$properties->{signed}."'"
				") ".
				"return confirm('$message')\""
		});
	}

	# Field definition
	$tabForm->addTab('general', 'General Properties');
	$f = $tabForm->getTab('general');
	$f->text(
		-name	=> 'fieldName',
		-label	=> $i18n->get('ef field name'),
		-hoverHelp	=> $i18n->get('ef field name description'),
		-value	=> $properties->{fieldName},
		-maxlength => 64,
	);
	$f->text(
		-name	=> 'displayName',
		-label	=> $i18n->get('ef display name'),
		-hoverHelp	=> $i18n->get('ef display name description'),
		-value	=> $properties->{displayName},
	);
	$f->selectList(
		-name	=> 'fieldType',
		-label	=> $i18n->get('ef field type'),
		-hoverHelp	=> $i18n->get('ef field type description'),
		-value	=> [$properties->{fieldType}],
		-options=> \%fieldTypes,
		-extras => 'onchange="updateFormFields()"',
		-id	=> "SQLFormFieldType",
		-multiple => 0,
		-size	=> 1,
	);
	$f->trClass('SQLFormSignedRow');
	$f->radioList(
		-name	=> 'signed',
		-label	=> $i18n->get('ef signed'),
		-hoverHelp	=> $i18n->get('ef signed description'),
		-value	=> $properties->{signed} || '0',
		-options=> {
			'1' => $i18n->get('ef signed label'), 
			'0' => $i18n->get('ef unsigned label')
		},
		-id	=> 'SQLFormSigned',
	);
	$f->trClass('SQLFormAutoIncrementRow');
	$f->yesNo(
		-name	=> 'useAutoIncrement',
		-label	=> $i18n->get('ef autoincrement'),
		-hoverHelp	=> $i18n->get('ef autoincrement description'),
		-value	=> $properties->{useAutoIncrement},
		-id	=> 'SQLFormAutoIncrement',
	);
	$f->trClass('');
	$f->integer(
		-name	=> 'formFieldHeight',
		-label	=> $i18n->get('ef form height'),
		-hoverHelp	=> $i18n->get('ef form height description'),
		-value	=> $properties->{formFieldHeight},
	);
	$f->integer(
		-name	=> 'formFieldWidth',
		-label	=> $i18n->get('ef form width'),
		-hoverHelp	=> $i18n->get('ef form width description'),
		-value	=> $properties->{formFieldWidth},
	);
	$f->trClass('SQLFormMaxFieldLengthRow');
	$f->integer(
		-name	=> 'maxFieldLength',
		-label	=> $i18n->get('ef max field length'),
		-hoverHelp	=> $i18n->get('ef max field length description'),
		-value	=> $properties->{maxFieldLength},
		-id	=> 'SQLFormMaxFieldLength',
	);
	$f->trClass('SQLFormRegexRow');
	$f->selectList(
		-name	=> 'regex',
		-label	=> $i18n->get('ef regex'),
		-hoverHelp	=> $i18n->get('ef regex description'),
		-value	=> [ $properties->{regex} ],
		-options=> $regexes,
		-id	=> 'SQLFormRegex',
		-size	=> 1,
		-multiple=> 0,
	);
	$f->trClass('');
	$f->yesNo(
		-name	=> 'isRequired',
		-label	=> $i18n->get('ef required'),
		-hoverHelp	=> $i18n->get('ef required description'),
		-value	=> $properties->{isRequired},
	);
	$f->trClass('SQLFormReadOnlyRow');
	$f->yesNo(
		-name	=> 'isReadOnly',
		-label	=> $i18n->get('ef read only'),
		-hoverHelp	=> $i18n->get('ef read only description'),
		-value	=> $properties->{isReadOnly},
		-id	=> 'SQLFormReadOnly',
	);
	$f->trClass('');
	$f->text(
		-name	=> 'defaultValue',
		-label	=> $i18n->get('ef default value'),
		-hoverHelp	=> $i18n->get('ef default value description'),
		-value	=> $properties->{defaultValue},
	);
	$f->readOnly(
		-label	=> $i18n->get('ef field constraint'),
		-hoverHelp	=> $i18n->get('ef field constraint description'),
		-value	=> WebGUI::Form::selectList($self->session, {
			name	=> 'fieldConstraintType',
			options	=> {'0' => 'none', 1 => '>', 2 => '>=', 3 => '<', 4 => '<=', 5 => '='},
			value	=> [ $properties->{fieldConstraintType} || '0' ],
			extras	=> 'onchange="updateFormFields()"',
			id	=> 'SQLFormFieldConstraintType',
			size	=> 1,
			multiple=> 0,
		}).
		WebGUI::Form::selectList($self->session, {
			name	=> 'fieldConstraintTarget',
			options	=> {}, #{'value' => 'Value', 'joinColumn1' => 'Join field 1', joinColumn2 => 'Join field 2'},
			value	=> [ $properties->{fieldConstraintTarget} ],
			extras	=> 'onchange="updateFormFields()"',
			id	=> 'SQLFormFieldConstraintTarget',
			size	=> 1,
			multiple=> 0,
		}).
		WebGUI::Form::text($self->session, {
			name	=> 'fieldConstraintValue',
			value	=> $properties->{fieldConstraintValue},
			id	=> 'SQLFormFieldConstraintValue',
		}),
	);
		
	# Search and summary options
	$tabForm->addTab('search', 'Search and Summary');
	$f = $tabForm->getTab('search');
	$f->yesNo(
		-name	=> 'isSearchable',
		-label	=> $i18n->get('ef searchable'),
		-hoverHelp	=> $i18n->get('ef searchable description'),
		-value	=> $properties->{isSearchable},
	);
	$f->yesNo(
		-name	=> 'useFulltext',
		-label	=> $i18n->get('ef fulltext'),
		-hoverHelp	=> $i18n->get('ef fulltext description'),
		-value	=> $properties->{useFulltext},
	);
	$f->yesNo(
		-name	=> 'showInSearchResults',
		-label	=> $i18n->get('ef show in search'),
		-hoverHelp	=> $i18n->get('ef show in search description'),
		-value	=> $properties->{showInSearchResults},
	);
	$f->integer(
		-name	=> 'summaryLength',
		-label	=> $i18n->get('ef summary length'),
		-hoverHelp	=> $i18n->get('ef summary length description'),
		-value	=> $properties->{summaryLength},
	);

	# Form pouplation params
	$tabForm->addTab('population', 'Form Population');
	$f = $tabForm->getTab('population');
	$f->textarea(
		-name	=> 'formPopulationKeys',
		-label	=> $i18n->get('ef populate keys'),
		-hoverHelp	=> $i18n->get('ef populate keys description'),
		-value	=> $properties->{formPopulationKeys},
	);
	$f->textarea(
		-name	=> 'formPopulationValues',
		-label	=> $i18n->get('ef populate values'),
		-hoverHelp	=> $i18n->get('ef populate values description'),
		-value	=> $properties->{formPopulationValues},
	);

	$f->readOnly(
		-value	=> '<b>Query generation</b>',
	);
	# This is quite a special field and is completely built by javascript. The file sqlform.js contains the HTML
	# for the row layout.
	$f->readOnly(
		-label	=> $i18n->get('ef join selector'),
		-hoverHelp	=> $i18n->get('ef join selector description'),
		-value	=> '<table id="SQLFormJoinSelectorTable"></table>',
	);
	$f->readOnly(
		-label	=> $i18n->get('ef join constraint'),
		-hoverHelp	=> $i18n->get('ef join constraint description'),
		-value	=> WebGUI::Form::selectList($self->session, {
			name	=> 'joinConstraintColumn',
			options	=> {},
			id	=> 'joinConstraintColumn',
			size	=> 1,
			multiple=> 0,
		}).' = '.
		WebGUI::Form::selectList($self->session, {
			name	=> 'joinConstraintField',
			options => $self->session->db->buildHashRef('select fieldId, value from SQLForm_fieldDefinitions where property="displayname" and assetId='.$self->session->db->quote($self->getId)),
			value	=> [ $properties->{joinConstraintField} ],
			id	=> 'joinConstraintField',
			size	=> 1,
			multiple=> 0,
		}),
	);
	$f->selectList(
		-name	=> 'selectField1',
		-label	=> $i18n->get('ef join keys'),
		-hoverHelp	=> $i18n->get('ef join keys description'),
		-options=> {},
		-id	=> 'selectField1',
		-size	=> 1,
		-multiple=> 0,
	);
	$f->selectList(
		-name	=> 'selectField2',
		-label	=> $i18n->get('ef join values'),
		-hoverHelp	=> $i18n->get('ef join values description'),
		-options=> {},
		-id	=> 'selectField2',
		-size	=> 1,
		-multiple=> 0,
	);

	# This js file contains code to handle the dynamics of this form.
	$self->session->style->setScript($self->session->url->extras('wobject/SQLForm/SQLFormJoinSelector.js'), {type => 'text/javascript'});
	$self->session->style->setScript($self->session->url->extras('js/at/AjaxRequest.js'), {type => 'text/javascript'});
	$self->session->style->setScript($self->session->url->extras('wobject/SQLForm/SQLFormEditField.js'), {type => 'text/javascript'});
		
my 	$jsDatabases = '[' . join(',', map {"{key : '$_', value : '$_'}"} $dbLink->db->buildArray('show databases')) . ']';
my 	$jsInitJoinSelector;
my	$js = "<script type=\"text/javascript\">\n";
	$js .= "\tupdateFormFields();\n";
	$js .= "\tinitDatabaseMap(".$jsDatabases.");\n";
	$js .= "\tsetResultFields('selectField1', 'selectField2')\n";
	
	#### Will break if there are more than 9 joins ####
	foreach (sort(keys(%$properties))) {
		if ($_ =~ m/^table(\d+)$/) {
			$jsInitJoinSelector .= "\taddSelectorRow(";
			$jsInitJoinSelector .= "'SQLFormJoinSelectorTable'";
			$jsInitJoinSelector .= ", '".$properties->{"database$1"}."'";
			$jsInitJoinSelector .= ", '".$properties->{"table$1"}."'";
			$jsInitJoinSelector .= ", '".$properties->{"joinOnA$1"}."'";
			$jsInitJoinSelector .= ", '".$properties->{"joinOnB$1"}."'";
			$jsInitJoinSelector .= ", '".$properties->{"joinFunction$1"}."'";
			$jsInitJoinSelector .= ");\n";	
		}
	}
	$js .= $jsInitJoinSelector || "addSelectorRow('SQLFormJoinSelectorTable');\n";
	$js .= "var rowNumber = document.getElementById('SQLFormJoinSelectorTable').rows.length;\n";
	$js .= "\taddJoinButtonRow('SQLFormJoinSelectorTable', rowNumber);\n";
	$js .= "\ttoggleJoinButton(rowNumber - 1)\n";
	$js .= "\tupdateFields(rowNumber,'".$properties->{selectField1}."','".$properties->{selectField2}."','".
		$properties->{joinConstraintColumn}."','".$properties->{fieldConstraintTarget}."');\n";
	$js .= "</script>\n";

	$output = '<h2>'.$i18n->get('ef errors occurred').'</h2><ul><li>'.join('</li><li>', @{$errors}).'</li></ul><br />' if ($errors);
	$output .= $tabForm->print . $js;

	$self->getAdminConsole->setHelp("edit field", "Asset_SQLForm");
	return $self->getAdminConsoleWithSubmenu->render($output, $i18n->get('edit field title'));
}

#-------------------------------------------------------------------

=head2 www_editFieldSave ( )

Processes and stores the field properties, and will alter the table according to these properties.

=cut

sub www_editFieldSave {
	my ($databaseDef, $key, $joinNumber, @tables, $processed, $tableName,
		$joinAColumnName, $joinATableName, $joinBColumnName, $joinBTableName,
		@joinConstraints, @differenceConstraints, $maxAllowedLength, $fieldId, 
		@error, $properties, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	$databaseDef = $self->_getDatabaseInfo;
	
	# Get the right field id and load properties if applicable ------------------------------------
	if ($self->session->form->process("fid") eq 'new') {
		$fieldId = $self->session->id->generate;
	} else {
		$fieldId = $self->session->form->process("fid");
		$properties = $self->session->db->buildHashRef("select property, value from SQLForm_fieldDefinitions where fieldId=".$self->session->db->quote($fieldId));
		$self->_uncacheFieldProperties($fieldId);
	}

	# If no value  (or zero) is given for any of these values just discard them and use the WebGUI defaults.
	
	push (@error, $i18n->get('efs height error')) unless ($self->session->form->process("formFieldHeight") =~ m/^\d*$/);
	$processed->{formFieldHeight} = $self->session->form->integer('formFieldHeight') if ($self->session->form->process("formFieldHeight"));
	push (@error, $i18n->get('efs width error')) unless ($self->session->form->process("formFieldWidth") =~ m/^\d*$/);
	$processed->{formFieldWidth} = $self->session->form->integer('formFieldWidth') if ($self->session->form->process("formFieldWidth"));
	
	push (@error, $i18n->get('efs populate error')) if (scalar(split(/\n/,$self->session->form->process("formPopulationKeys"))) != scalar(split(/\n/,$self->session->form->process("formPopulationValues"))));
	$processed->{formPopulationKeys} = $self->session->form->process("formPopulationKeys");
	$processed->{formPopulationValues} = $self->session->form->process("formPopulationValues");
	
	$processed->{isSearchable} = 1 if $self->session->form->process("isSearchable");
	$processed->{showInSearchResults} = 1 if ($self->session->form->process("showInSearchResults"));
	
	$processed->{summaryLength} = $self->session->form->process("summaryLength") if ($self->session->form->process("summaryLength") =~ m/^\d+$/);
	$processed->{useAutoIncrement} = 1 if ($self->session->form->process("useAutoIncrement"));
	$processed->{signed} = 1 if ($self->session->form->process("signed"));
	$processed->{isRequired} = 1 if ($self->session->form->process("isRequired"));
	$processed->{isReadOnly} = 1 if ($self->session->form->process("isReadOnly"));
	$processed->{defaultValue} = $self->session->form->process("defaultValue");

	if ($self->session->form->process("fieldConstraintType") > 0 && defined $self->session->form->process("fieldConstraintTarget")) {
		$processed->{fieldConstraintType} = $self->session->form->process("fieldConstraintType");
		$processed->{fieldConstraintTarget} = $self->session->form->process("fieldConstraintTarget");
		if ($processed->{fieldConstraintTarget} eq 'value') {
			$processed->{fieldConstraintValue} = $self->session->form->process("fieldConstraintValue");
			push (@error, $i18n->get('efs constraint error')) unless (defined $self->session->form->process("fieldConstraintValue"));
		}
		if ($processed->{fieldConstraintTarget} eq 'joinColumn1' && !$self->session->form->process("selectField1")) {
			push (@error, $i18n->get('efs jf1 error'));
		}
		if ($processed->{fieldConstraintTarget} eq 'joinColumn2' && !$self->session->form->process("selectField2")) {
			push (@error, $i18n->get('efs jf2 error'));
		}
	
	}		

	$processed->{joinConstraintColumn} = $self->session->form->process("joinConstraintColumn");
	$processed->{joinConstraintField} = $self->session->form->process("joinConstraintField");
	
	# Process fieldType ----------------------------------------------------------------------------
my	($dbFieldType, $formFieldType) = $self->session->db->quickArray('select dbFieldType, formFieldType from SQLForm_fieldTypes '.
		' where fieldTypeId='.$self->session->db->quote($self->session->form->process("fieldType")));
	if ($dbFieldType && $formFieldType) {
		$processed->{dbFieldType} = $dbFieldType;
		$processed->{formFieldType} = $formFieldType;
		$processed->{fieldType} = $self->session->form->process("fieldType");
	} else {
		push(@error, $i18n->get('efs field type error'));
	}

	# Process the join stuff -----------------------------------------------------------------------
	if ($allowedFormFieldTypes->{$processed->{formFieldType}}->{hasOptions} &&
	    $self->session->form->process("table1") && 
	    !($self->session->form->process("selectField1") && $self->session->form->process("selectField2"))) {
		push(@error, $i18n->get('efs join populate error'));
	}
	if ($self->session->form->process("table1")) {
		$processed->{selectField1} = $self->session->form->process("selectField1");
		$processed->{selectField2} = $self->session->form->process("selectField2");
	}

	#### Will break if there are more than 9 joins ####
my	@columnConstraints;
my 	%fingerprint;
my 	$dbLink = $self->_getDbLink;

	foreach $key (sort(keys(%{$self->session->form->paramsHashRef}))) {
		if ($key =~ m/^database(\d+)/ && $self->session->form->process($key)) {
			$joinNumber = $1;
my			$databaseName = $self->session->form->process("database$joinNumber");
			if (isIn($databaseName, $dbLink->db->buildArray('show databases'))) {
				$processed->{"database$joinNumber"} = $databaseName;
				
				$tableName = $self->session->form->process("table$joinNumber");
				if (isIn($tableName, $dbLink->db->buildArray("show tables from $databaseName"))) {
					unless ($self->session->form->process("joinFunction$joinNumber") eq 'difference') {
						push(@tables, "$databaseName.$tableName as table$joinNumber");
					}
					$processed->{"table$joinNumber"} = $tableName;

					
my					@columns = $dbLink->db->buildArray("describe $databaseName.$tableName");
					if (isIn('__deleted', @columns) && isIn('__archived', @columns)) {
						push(@columnConstraints, "table$joinNumber.__deleted=0 and table$joinNumber.__archived=0") if ($joinNumber == 1);
						$fingerprint{$joinNumber} = 1;
					}
					
my 					$joinAIsSQLForm = 0;
					if ($joinNumber > 1) {
my $joinADatabaseName;
						if ($self->session->form->process('joinOnA'.$joinNumber) =~ m/^table(\d+)\.(.+)$/) {
							$joinAColumnName = $2;
							$joinATableName = $self->session->form->process('table'.$1);
							$joinADatabaseName = $self->session->form->process('database'.$1);
							$joinAIsSQLForm = $fingerprint{$1};
						} else {
							push(@error, $i18n->get('efs left join column error').$joinNumber.".");
						}

my $joinBDatabaseName;
						if ($self->session->form->process('joinOnB'.$joinNumber) =~ m/^table(\d+)\.(.+)$/) {
							$joinBColumnName = $2;
							$joinBTableName = $self->session->form->process('table'.$1);
							$joinBDatabaseName = $self->session->form->process('database'.$1);
						} else {
							push(@error, $i18n->get('efs right join column error').$joinNumber.".");
						}
						if ($joinATableName && $joinBTableName &&
						    isIn($joinAColumnName, $dbLink->db->buildArray("describe $joinADatabaseName.$joinATableName")) &&
						    isIn($joinBColumnName, $dbLink->db->buildArray("describe $joinBDatabaseName.$joinBTableName"))) {
							if ($self->session->form->process("joinFunction$joinNumber") eq 'difference') {
my								$subSelect = "select $joinAColumnName from $joinADatabaseName.$joinATableName";
								$subSelect .= " where __deleted=0 and __archived=0" if ($joinAIsSQLForm);
								push(@differenceConstraints, $self->session->form->process('joinOnB'.$joinNumber).' not in ('.$subSelect.')');
							} else {
								push(@joinConstraints, $self->session->form->process('joinOnA'.$joinNumber) .'='. $self->session->form->process('joinOnB'.$joinNumber));
								push(@columnConstraints, "table$joinNumber.__deleted=0 and table$joinNumber.__archived=0") if ($fingerprint{$joinNumber});
							}

							$processed->{'joinOnA'.$joinNumber} = $self->session->form->process('joinOnA'.$joinNumber);
							$processed->{'joinOnB'.$joinNumber} = $self->session->form->process('joinOnB'.$joinNumber);
							$processed->{'joinFunction'.$joinNumber} = $self->session->form->process('joinFunction'.$joinNumber);
						} else {
							push(@error, $i18n->get('efs column name error')." [$joinAColumnName][$joinBColumnName]");
						}
					}
				} else {
					push(@error, $i18n->get('efs table error').' ['.$self->session->form->process($key).'.'.$tableName.']');
				}
			} else {
				push(@error, $i18n->get('efs database error').' ['.$self->session->form->process("database$joinNumber").']');
			}

		}
	}

	# Generate a sqlquery here so we don't have to generate it everytime the form view is called ---
	$processed->{sqlQuery} = "select ".$self->session->form->process("selectField1").", ".$self->session->form->process("selectField2"). " from ".
		join(', ', @tables);
	$processed->{sqlQuery} .= " where " if (@joinConstraints || @differenceConstraints || @columnConstraints);
	$processed->{sqlQuery} .= join(' and ', (@joinConstraints, @differenceConstraints, @columnConstraints));

	# If there are set-differences defined we also need a query without them to be able to show 
	# the correct values in search results.
	if (@differenceConstraints) {
		$processed->{sqlQueryAllOptions} = "select ".$self->session->form->process("selectField1").", ".$self->session->form->process("selectField2"). " from ".
			join(', ', @tables);
		$processed->{sqlQueryAllOptions} .= " where ".join(' and ', @joinConstraints) if (@joinConstraints);
	}
	
	# Check if fulltext search is allowed ----------------------------------------------------------
	if ($self->session->form->process("useFulltext") && $allowedDbFieldTypes->{$processed->{dbFieldType}}->{supportsFulltext}) {
		$processed->{useFulltext} = 1;
	} elsif ($self->session->form->process("useFulltext")) {
		push (@error, $i18n->get('efs fulltext error'));
	}
	
	# Check whether a correct fieldname has been given ---------------------------------------------
	if ($self->session->form->process("fieldName") =~ m/^[a-zA-Z0-9_]+$/) {
		if (($self->session->form->process("fieldName") ne $properties->{fieldName}) &&
			isIn($self->session->form->process("fieldName"), keys(%{$databaseDef->{$self->get('tableName')}}))) 
		{
			push(@error, $i18n->get('efs column name exists error'));
		} elsif (isIn(uc($self->session->form->process("fieldName")), @reservedKeywords)) {
			push(@error, $i18n->get('efs column name is reserved error'));
		} else {
			$processed->{fieldName} = $self->session->form->process("fieldName");
		}
	} elsif (!$self->session->form->process("useAutoIncrement")) { 
		push(@error, $i18n->get('efs field name error'));
	}

	# Make sure the maxlength is supported by the field types --------------------------------------
	$maxAllowedLength = ($allowedDbFieldTypes->{$processed->{dbFieldType}}->{maxLength} > $allowedFormFieldTypes->{$processed->{formFieldType}}->{maxLength}) ?
		$allowedDbFieldTypes->{$processed->{dbFieldType}}->{maxLength} : $allowedFormFieldTypes->{$processed->{formFieldType}}->{maxLength};
	if ($self->session->form->integer('maxFieldLength') <= $maxAllowedLength || !$maxAllowedLength) { 
		$processed->{maxFieldLength} = $self->session->form->integer('maxFieldLength') || $maxAllowedLength || undef;
	} else {
		push (@error, "Allow maximum length to large for chosen fields");
	}

	# Check if population params are given in case of a set-field ----------------------------------
	if ($processed->{dbFieldType} eq 'set' and scalar(split(/\r?\n/, $processed->{formPopulationKeys})) == 0) {
		push (@error, "You have to enter population key/value pairs if you use the set column type");
	}

	# Process regex
	$processed->{regex} = $self->session->form->combo('regex');
	if ($self->session->form->process("regex") eq '_new_') {
my		$regexName = $self->session->form->process("regex_name") || 'untitled';
		$self->session->db->write('insert into SQLForm_regexes (name, regex) values ('.$self->session->db->quote($regexName).','.$self->session->db->quote($processed->{regex}).')');
	}
	
	# Process display name
	$processed->{displayName} = $self->session->form->process("displayName") || $processed->{fieldName};

	# Return errors if necessarry, else write the whole lot to the db.
	if (@error) {
		return $self->www_editField(\@error);
	} else {
	# Write data to db -----------------------------------------------------------------------------
		my $dbLink = $self->_getDbLink;	

		# Store/update definition	
		$self->session->db->write('delete from SQLForm_fieldDefinitions where fieldId='.$self->session->db->quote($fieldId));
		foreach (keys(%$processed)) {
			$self->session->db->write('insert into SQLForm_fieldDefinitions (fieldId, assetId, property, value) values '.
				'('.$self->session->db->quote($fieldId).','.$self->session->db->quote($self->get('assetId')).','.$self->session->db->quote($_).','.$self->session->db->quote($processed->{$_}).')');
		}

		# Set new column at the last position
		if ($self->session->form->process("fid") eq 'new') {
			my ($rank) = $self->session->db->quickArray('select max(rank)+1 from SQLForm_fieldOrder where assetId ='.$self->session->db->quote($self->getId).' group by assetId');
			$rank ||= '0';
			$self->session->db->write(
				 " insert into SQLForm_fieldOrder (assetId, fieldId, rank) values "
				." (".$self->session->db->quote($self->getId).", ".$self->session->db->quote($fieldId).", $rank )"
			);
		}
		
		# Construct the type specifier
		my $type = $self->_constructColumnType($processed);

		# If id = new create column in table
		if ($self->session->form->process("fid") eq 'new') {
			$dbLink->db->write('alter table '.$self->get('tableName').' add column '.$processed->{fieldName}.' '.$type);
		} else {
			$dbLink->db->write('alter table '.$self->get('tableName').' change column '.$properties->{fieldName}.' '.$processed->{fieldName}.' '.$type);
		}

		# Add mimetype column for file fields.
		if ($processed->{formFieldType} eq 'file') {
			unless (isIn('__'.$processed->{fieldName}.'_mimeType' , keys(%{$databaseDef->{$self->get('tableName')}}))) {
				$dbLink->db->write('alter table '.$self->get('tableName').
					' add column '.'__'.$processed->{fieldName}.'_mimeType'.' varchar(64)');
			}
		}

		# Process fulltext columns
		if ($processed->{useFulltext} && !$properties->{useFulltext}) {
			$dbLink->db->write('alter table '.$self->get('tableName').' add fulltext ('.$processed->{fieldName}.')');
		} elsif (!$processed->{useFulltext} && $properties->{useFulltext}) {
			$dbLink->db->write('alter table '.$self->get('tableName').' drop index '.$processed->{fieldName});
		}

		$dbLink->disconnect;
	}
	
	return $self->www_listFields;
}

#-------------------------------------------------------------------

=head2 www_editFieldType ( )

Returns the form for editing field types. Only allows editing of field types that are not in use by 
any SQLForm asset withing the instance. Pass the field type id through the form param 'ftid'. Pass
ftid=new to add a new field type.

=cut

sub www_editFieldType {
	my (%dbFields, %formFields, $f, $properties, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);
	
	tie %dbFields, 'Tie::IxHash';
	tie %formFields, 'Tie::IxHash';
	%dbFields = map {$_ => $allowedDbFieldTypes->{$_}->{name}} keys %{$allowedDbFieldTypes};
	%formFields = map {$_ => $allowedFormFieldTypes->{$_}->{name}} keys %{$allowedFormFieldTypes};

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	if ($self->session->form->process("ftid") eq 'new') {
		$properties = {};
	} else {
		$properties = $self->session->db->quickHashRef('select * from SQLForm_fieldTypes where fieldTypeId='.$self->session->db->quote($self->session->form->process("ftid")));
	}
	
	$f = WebGUI::HTMLForm->new($self->session,
		-action => $self->getUrl
	);
	$f->hidden(
		-name	=> 'func',
		-value	=> 'editFieldTypeSave'
	);
	$f->hidden(
		-name	=> 'ftid',
		-value	=> $self->session->form->process("ftid"),
	);
	$f->readOnly(
		-label	=> 'fieldTypeId',
		-value	=> $self->session->form->process("ftid"),
	);
	$f->selectList(
		-name	=> 'dbFieldType',
		-label	=> $i18n->get('eft db field type'),
		-hoverHelp => $i18n->get('eft db field type description'),
		-value	=> [$properties->{dbFieldType}],
		-options=> \%dbFields,
		-id	=> 'SQLFormDbFieldType',
		-size	=> 1,
		-multiple=> 0,
	);
	$f->selectList(
		-name	=> 'formFieldType',
		-label	=> $i18n->get('eft form field type'),
		-hoverHelp => $i18n->get('eft form field type description'),
		-value	=> [$properties->{formFieldType}],
		-options=> \%formFields,
		-id	=> 'formTypeSelector',
		-size	=> 1,
		-multiple=> 0,
	);
	$f->readOnly(
		-value	=> 
			WebGUI::Form::submit($self->session).
			WebGUI::Form::button($self->session, {
				value	=> $i18n->get('cancel'),
				extras	=> 'onClick="location.href=\''.$self->getUrl('func=listFieldTypes').'\'"'
			})
	);

	$self->getAdminConsole->setHelp("edit field type", "Asset_SQLForm");
	return $self->getAdminConsoleWithSubmenu->render($f->print, $i18n->get('edit field type title'));
}

#-------------------------------------------------------------------

=head2 www_editFieldTypeSave ( )

Saves the field type properties entered in the form returned by www_editFieldType to the database. The form 
param 'ftid' is used to pass the field type id. Setting the id to 'new' will create a new field type.

=cut

sub www_editFieldTypeSave {
	my ($fieldTypeId);
	my $self = shift;
	
	if ($self->session->form->process("ftid") eq 'new') {
		$self->_createFieldType($self->session->form->process("dbFieldType"), $self->session->form->process("formFieldType"));			
	} else {
		$self->session->db->write('update SQLForm_fieldTypes '.
			' set dbFieldType='.$self->session->db->quote($self->session->form->process("dbFieldType")).', formFieldType='.$self->session->db->quote($self->session->form->process("formFieldType")).
			' where fieldTypeId='.$self->session->db->quote($self->session->form->process("ftid")));
	}

	return $self->www_listFieldTypes;
}
		
#-------------------------------------------------------------------

=head2 _getFieldValue ( field, recordValues, readOnly )

Returns the the value for the field represented by the field hashref for the current record, If the record 
has no value for this field it will return the default value. The returned value has the correct data type
for the for element that belongs to the field.

=head3 field

A hashref containing the field properties of this field.

=head3 recordValues

A hasref containg the values of this record.

=head3 readOnly

A boolean indicating the value should be outputted in read only mode.

=cut

sub _getFieldValue {
	my ($fieldValue);
	my $self = shift;
	my $field = shift;
	my $recordValues = shift;
	my $readOnly = shift;
	
	$fieldValue = $self->session->form->process($field->{fieldName}) || $recordValues->{$field->{fieldName}} || $field->{processedDefaultValue};

	if ($fieldValue && !$readOnly) {
		$fieldValue = $self->session->datetime->setToEpoch($fieldValue) if (isIn($field->{formFieldType}, qw(date dateTime)));
		$fieldValue = $self->session->datetime->timeToSeconds($fieldValue) if ($field->{formFieldType} eq 'timeField');
	}

	#### This might break? ####
	if ($field->{canHaveMultipleValues}) {
		$fieldValue = [ split(/\n/, $recordValues->{$field->{fieldName}}) ];
		$fieldValue = [ $self->session->request->param($field->{fieldName}) ] if (defined $self->session->form->process($field->{fieldName}));
	}

	# Handle file uploads
	if ($field->{formFieldType} eq 'file') {
		unless ($recordValues->{$field->{fieldName}}) {
#			$fieldValue .= 'No file uploaded yet';
		} else {
			$fieldValue = '<a href="'.$self->session->url->page('func=viewFile;rid='.$self->session->form->process("rid").';fid='.$_, $self->getUrl).'">';
			if ($recordValues->{'__'.$field->{fieldName}.'_mimeType'} =~ /^image/i) {
				$fieldValue .= '<img src="'.
					$self->session->url->page('func=viewThumbnail;rid='.$self->session->form->process("rid").'&fid='.$_, $self->getUrl).'" />';
			} else {
				$fieldValue .= WebGUI::Internation::get('click here for file', 'Asset_SQLForm');
			}
			$fieldValue .= '</a>';
		}
	}

	return $fieldValue;
}

#-------------------------------------------------------------------

=head2 _getFormElement ( field, recordValues, readOnly )

Returns the for element tied to this field.

=head3 field

A hashref containing the field properties of this field.

=head3 recordValues

A hasref containg the values of this record.

=head3 readOnly

A boolean indicating the value should be outputted in read only mode.

=cut

sub _getFormElement {
	my ($fieldValue, $fieldParameters, $maxLength, $fieldType, $formElement, $cmd, $i18n);
	my $self = shift;
	my $field = shift;
	my $recordValues = shift;
	my $readOnly = shift || !$self->_canEditRecord || $field->{isReadOnly} || $field->{readOnly} || $field->{useAutoIncrement};
	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	# Get field type and value
	$fieldType = $field->{formFieldType};
	$fieldValue = $self->_getFieldValue($field, $recordValues, $readOnly);

	# Resolve value to key in case of read only and key/value pairs
	if ($field->{canHaveMultipleValues}) {
                $fieldValue = join(', ', @{$field->{allOptions}}{@$fieldValue}) if ($field->{hasOptions} && $readOnly);
        }else{
                $fieldValue = $field->{allOptions}->{$fieldValue} if ($field->{hasOptions} && $readOnly);
        }
	$maxLength = $field->{maxFieldLength} || $allowedDbFieldTypes->{$field->{dbFieldType}}->{maxLength};

	# Construct the form element
	if ($readOnly) {
		$formElement = $fieldValue;
	} else {
		# Set up form element parameters
		$fieldParameters->{options}			= $field->{options};
		# make sure that previously selected items still appear for this for element, even if
		# if is set to a set difference.
		if ($fieldValue && $field->{hasOptions}) {
			if ($field->{canHaveMultipleValues}) {
				@{$fieldParameters->{options}}{@$fieldValue} 	= @{$field->{allOptions}}{@$fieldValue};
			} else {
				$fieldParameters->{options}->{$fieldValue}	= $field->{allOptions}->{$fieldValue};
			}
		}
		$fieldParameters->{options}->{''}		= '-leave empty-' if (!$field->{isRequired});
		$fieldParameters->{name} 			= $field->{fieldName};
		$fieldParameters->{value}			= $fieldValue unless ($fieldType eq 'file');
		$fieldParameters->{multiple}			= $field->{multipleAllowed} == 1;
		$fieldParameters->{$field->{widthParam}}	= $field->{formFieldWidth} if ($field->{formFieldWidth});
		$fieldParameters->{$field->{heightParam}}	= $field->{formFieldHeight} if ($field->{formFieldHeight});
		$fieldParameters->{maxlength}			= $maxLength;
		$fieldParameters->{extras}			= 'onkeyup="if (this.value.length > '.$maxLength.') {this.value = this.value.substring(0,'.$maxLength.');}"';
		$fieldParameters->{id}				= 'sqlform'.$field->{fieldId};

		# Show file if a file is uploaded
		$formElement = $fieldValue.'<br />' if ($fieldType eq 'file' && $fieldValue);
		
		# Add form element
		$cmd = 'WebGUI::Form::'.$fieldType.'($self->session, $fieldParameters)';
		$formElement .= eval($cmd);
		$self->session->errorHandler->fatal('Could not instanciate formelement via WebGUI::Form: '.$@) if ($@);

		if ($fieldType eq 'selectList' && !$field->{isRequired}) {
			$formElement .= WebGUI::Form::button($self->session, {
					value	=> $i18n->get('clear'),
					extras	=> 'onclick="var a =document.getElementById(\'sqlform'.$field->{fieldId}.'\'); for (i=0; i < a.options.length; i++) { a.options[i].selected = false;};"',
				});
		}
		
		# Add file upload controls if necessary
		if ($fieldType eq 'file') {
			if ($fieldValue) {
				$formElement .= WebGUI::Form::radioList($self->session, {
					name 	=> '_'.$field->{fieldName}.'_action', 
					options => {
						'keep'		=> $i18n->get('keep'), 
						'overwrite' 	=> $i18n->get('overwrite'), 
						'delete'	=> $i18n->get('delete'),
					},
					value	=> 'keep',
				});
			} else {
				$formElement .= WebGUI::Form::hidden($self->session, {
					name 	=> '_'.$field->{fieldName}.'_action', 
					value 	=> 'overwrite',
				});
			}
		}
	}

	return $formElement;
}

#-------------------------------------------------------------------

=head2 www_editRecord ( )

Generates the record edit form for the record with the id given by the form param 'rid'. Setting rid to 'new' will
cause a new record to be added. If the user is not allowed to edit but can view, this method will output in view
mode, which means that only the contents of the record are shown. The view mode is also initiated when the form 
param 'viewOnly' is set to a non-zero value.

=cut

sub www_editRecord {
	my ($recordId, $fieldType, $canEditRecord, @fields, $properties, $f, $field, @fieldParameters, $cmd, $var, @formLoop, 
		$formElement, $numberOfFields, $i18n, $recordControls);
	my $self = shift;
	my $errors = shift || [];

	return $self->session->privilege->insufficient() unless ($self->canView);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

	my $dbLink = $self->_getDbLink;

	@fields = $self->session->db->buildArray(
		 " select distinct t1.fieldId "
		." from SQLForm_fieldDefinitions as t1, SQLForm_fieldOrder as t2 "
		." where t1.fieldId=t2.fieldId and t1.assetId=t2.assetId and t1.assetId=".$self->session->db->quote($self->getId)
		." order by t2.rank");

	if ($self->session->form->process("rid") eq 'new') {
		$recordId = $self->session->form->process("copyRecordId");
	} else {
		$recordId = $self->session->form->process("rid");
	}
	
	if ($recordId) {
		$properties = $dbLink->db->quickHashRef("select * from ".$self->get('tableName').
			" where __archived=0 and __recordId=".$self->session->db->quote($recordId));
		return $i18n->get("invalid record id") unless ($properties->{__recordId});
	} else {
		$properties = {};
	}
	
	$canEditRecord = ($self->_canEditRecord && $properties->{__deleted} == 0) ? 1 : 0;
	$canEditRecord = 0 if ($self->session->form->process("viewOnly"));

	$f = WebGUI::HTMLForm->new($self->session,
		-action	=> $self->getUrl,
	);
	$f->hidden(
		-name	=> 'func',
		-value	=> 'editRecordSave',
	);
	$f->hidden(
		-name	=> 'rid',
		-value	=> $self->session->form->process("rid"),
	);

	foreach (@fields) {
		$field = $self->_getFieldProperties($_, $properties);

		# Skip 'deleted' columns.
		next if ($field->{disabled} || ($self->session->form->process("rid") eq 'new' && $field->{useAutoIncrement}));

		$numberOfFields++;

		# Add element to preconstructed form
		my $formElement = $self->_getFormElement($field, $properties, !$canEditRecord);
		$f->readOnly(
			-label		=> $field->{displayName},
			-value		=> $formElement
		);
		
		my $fieldValue = $self->_getFieldValue($field, $properties, !$canEditRecord);
		
		# Add element to the form loop
		push(@formLoop, {
			'field.label'		=> $field->{displayName},
			'field.formElement'	=> $formElement,
			'field.value'		=> $fieldValue,
		});
		
		$var->{'field.'.$field->{fieldName}.'.formElement'} = $formElement;
		$var->{'field.'.$field->{fieldName}.'.label'} = $field->{displayName};
		$var->{'field.'.$field->{fieldName}.'.value'} = $fieldValue;
	}

	if ($canEditRecord) {
		$f->submit;
		push(@formLoop, {'field.formElement' => WebGUI::Form::submit($self->session)});
	}

	if ($self->_canEditRecord) {
		unless ($properties->{__deleted}) {
			$recordControls = $self->session->icon->delete('func=deleteRecord'.';rid='.$properties->{__recordId},$self->get("url"),
				$i18n->get('_psq confirm delete message', 'Asset_SQLForm'));
			$recordControls .= $self->session->icon->edit('func=editRecord;rid='.$properties->{__recordId},$self->get("url"));
			$recordControls .= $self->session->icon->copy('func=editRecord;rid=new;copyRecordId='.$properties->{__recordId},$self->get("url"));
		}

		$var->{'record.controls'} = $recordControls;
	}

	
	$var->{formHeader} = WebGUI::Form::formHeader($self->session).
		WebGUI::Form::hidden($self->session, {name=>'func', value=>'editRecordSave'}).
		WebGUI::Form::hidden($self->session, {name=>'rid', value=>$self->session->form->process("rid")});
	$var->{formFooter} = WebGUI::Form::formFooter($self->session);
	$var->{formLoop} = \@formLoop;
	$var->{completeForm} = $f->print;
	$var->{errorOccurred} = scalar(@$errors);
	$var->{errorLoop} = $errors;
	$var->{isNew} = 1 if ($self->session->form->process("rid") eq 'new');
	$var->{'viewHistory.label'} = $i18n->get('view history');
	$var->{'viewHistory.url'} = $self->getUrl('func=viewHistory;rid='.$self->session->form->process("rid"));
	$var->{managementLinks} = $self->_getManagementLinks;

	$dbLink->disconnect;

	unless ($numberOfFields) {
		return $self->processStyle($i18n->get('no fields defined message').' <a href="'.$self->getUrl('func=listFields').'">'.$i18n->get('manage fields title').'</a>.');
	}

	return $self->processStyle($self->processTemplate($var, $self->getValue('editTemplateId')));
}

#-------------------------------------------------------------------

=head2 www_editRecordSave ( )

Will process and save the record data inputted in the form generated by www_editRecord. In errors occur they will 
be fed back to www_editRecord. Set the record id using the form param 'rid', and use 'new' as id to add a new 
record.

=cut

sub www_editRecordSave {
	my (@fields, $field, $fieldName, @error, @update, $recordId, $lastRevision, $revision, $previousRecord, $value, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canEditRecord);
	
	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	my $dbLink = $self->_getDbLink;
	@fields = $self->session->db->buildArray("select distinct fieldId from SQLForm_fieldDefinitions where assetId=".$self->session->db->quote($self->getId));
my	%regexes = $self->session->db->buildHash("select regex, concat(name, ' (', regex, ')') from SQLForm_regexes");

my 	$now = time;
my 	($creationDate, $creator);

	if ($self->session->form->process("rid") eq 'new') {
		$recordId = $self->session->id->generate;
		$creationDate = $now;
		$creator = $self->session->user->userId;
		
		$revision = 0;
	} elsif (defined $self->session->form->process("rid")) {
		$recordId = $self->session->form->process("rid");
		($lastRevision) = $dbLink->db->quickArray('select max(__revision) from '.$self->get('tableName').' where __recordId='.$self->session->db->quote($recordId));
		return $i18n->get('invalid record id') unless (defined $lastRevision);
	
		$revision = $lastRevision + 1;
		$previousRecord = $dbLink->db->quickHashRef("select * from ".$self->get('tableName')." where __archived=0 and __recordId=".$self->session->db->quote($recordId));
		$creationDate = $previousRecord->{__creationDate};
		$creator = $previousRecord->{__createdBy};
	}

	# Set the metadata fields
	push(@update, "__creationDate=$creationDate");
	push(@update, "__createdBy=".$self->session->db->quote($creator));
	push(@update, "__revision=$revision");
	push(@update, "__initDate = ".$now);
	push(@update, "__userId = ".$self->session->db->quote($self->session->user->userId));
	push(@update, "__recordId = ".$self->session->db->quote($recordId));
	push(@update, "__archived = 0");

	foreach (@fields) {
		$field = $self->_getFieldProperties($_);
		$fieldName = $field->{fieldName};
		
		# Skip 'deleted' columns.
		next if $field->{disabled};

		# Get field constraint
my 		$fieldConstraint = undef;
		if ($field->{fieldConstraintType} && $field->{fieldConstraintTarget} ne 'value') {
my			$sql = $field->{sqlQuery};
			if ($field->{joinConstraintColumn}) {
				#### This will still fail if a column is called 'from'. It's better to seperate the join construction 
				#### from the column selection. Even better would be giving the contraint settings their own join selector.
				$sql =~ s/^select .+? from/select $field->{fieldConstraintTarget} from/;
				if ($sql =~ / where /) {
				 	$sql .= ' and ';
				} else {
					$sql .= ' where ';
				}
				$sql .= $field->{joinConstraintColumn} . ' = ' .
					$self->session->db->quote($self->session->form->process($self->_getFieldProperties($field->{joinConstraintField})->{fieldName}));
			}
			
my			@results = $self->session->db->quickArray($sql);
			$fieldConstraint = $results[0];
		}
		
		# Process autoincrement fields.
		if ($field->{useAutoIncrement}) {
			if ($revision == 0 || $previousRecord->{$fieldName} eq '') {
				($value) = $dbLink->db->quickArray("select max($fieldName) + 1 from ".$self->get('tableName'));
				$value = 0 unless $value;
			} else {
				$value = $previousRecord->{$fieldName};
			}
			push (@update, "$fieldName = ".$self->session->db->quote($value));
		# Process timestamp fields.
		} elsif ($field->{dbFieldType} eq 'timestamp') {
			push (@update, "$fieldName = now()");
		} elsif ($field->{isReadOnly}) {
			push (@update, "$fieldName =".$self->session->db->quote($field->{processedDefaultValue}));
		# Process file uploads.
		} elsif ($field->{formFieldType} eq 'file') {
			if ($self->session->form->process('_'.$fieldName.'_action') eq 'keep') {
				push(@update, "$fieldName = ".$self->session->db->quote($previousRecord->{$fieldName}));
				push(@update, "__".$fieldName."_mimeType=".$self->session->db->quote($previousRecord->{"__".$fieldName."_mimeType"}));
			} elsif ($self->session->form->process('_'.$fieldName.'_action') eq 'overwrite' && $self->session->form->process($fieldName)) {
				require Apache2::Request;
				require Apache2::Upload;

				# Get Apache2::Upload object
				my $upload = $self->session->request->upload($fieldName);

				# Check file size
				my $maxFileSize = ($self->get('maxFileSize') > $self->session->setting->get("maxAttachmentSize")) ? 
					$self->session->setting->get("maxAttachmentSize") : $self->get('maxFileSize');
				if ($upload->size > $maxFileSize * 1024) {
					push(@error, $i18n->get('ers file too large'));
				} else {
					my $fileType = $upload->type;
					my $fileContents = '';
					
					# Slurp file into scalar for use in query. Blocked reads will save memory, but then you
					# have to stream the data, which is not possible in mysql queries as far as I know.
					$upload->slurp($fileContents);
					
					# Include file content and mime type in query.
					push(@update, "$fieldName = ".$self->session->db->quote($fileContents));
					push(@update, "__".$fieldName."_mimeType=".$self->session->db->quote($fileType));
				}
			} else {
				push(@error, $i18n->get('ers field required').' '.$field->{displayName}) if ($field->{isRequired});
			}
		# Throw error if field is required and empty.
		} elsif ($self->session->form->process($fieldName) eq '' && $field->{isRequired}) {
			push(@error, $i18n->get('ers field required').' '.$field->{displayName}) if ($field->{isRequired});
		# Process other fields.
		} else {
			# Get input in correct format.
my			$fieldValue;
			if (defined $self->session->form->process($fieldName)) {
my 				$cmd = '$self->session->form->'.$field->{formFieldType}.'($fieldName)';
				$fieldValue = eval($cmd);	#$self->session->form->process($fieldName)
				
				if ($field->{formFieldType} eq 'dateTime' && $field->{dbFieldType} eq 'datetime') {
					$fieldValue = $self->session->form->process($fieldName);
				}
				if ($field->{formFieldType} eq 'date' && $field->{dbFieldType} eq 'date') {
					$fieldValue = $self->session->form->process($fieldName);
				}
				if ($field->{formFieldType} eq 'timeField' && $field->{dbFieldType} eq 'time') {
					$fieldValue = $self->session->form->process($fieldName);
				}
			} else {
				$fieldValue = $field->{processedDefaultValue};
			}

			# Check if input matches its regex
			if (_matchField($self, $self->session->form->process($fieldName), $field->{regex})) {
				push(@update, "$fieldName = ".$self->session->db->quote($fieldValue));
			} else {
				push(@error, $i18n->get('ers regex mismatch').' '.$regexes{$field->{regex}}.' '.$field->{displayName});
			}

			# Check if input is of allowed length.
			if ($field->{maxLength} && length($fieldValue) > $field->{maxLength}) {
				push (@error, $i18n->get('ers too long').' '.$field->{maxLength}.' '.$field->{displayName});
			}
			
			# Check if input is in compliance with field constraint
			if ($field->{fieldConstraintType}) {
my				$result = 1;
my				$fieldValueCompare = $fieldValue;
				if ($field->{formFieldType} eq 'dateTime' || $field->{formFieldType} eq 'date') {
					$fieldValueCompare = $self->session->datetime->setToEpoch($self->session->form->process($fieldName));
					$fieldConstraint = $self->session->datetime->setToEpoch($fieldConstraint);
				}
				if ($field->{formFieldType} eq 'timeField'){
					$fieldValueCompare = $self->session->datetime->timeToSeconds($self->session->form->process($fieldName));
					$fieldConstraint = $self->session->datetime->timeToSeconds($fieldConstraint);
				}
				
my 				$cmd = '$result = 0 if ($fieldValueCompare '.$self->_resolveFieldConstraintType($field->{fieldConstraintType}).' $fieldConstraint)';
				eval($cmd);

				push(@error, $i18n->get('ers value not allowed').' '.$field->{displayName}) if $result;
			}
			
			# Check if input is within field range
			if ($allowedDbFieldTypes->{$field->{dbFieldType}}->{maxValue}) {
				my $maxValue = ($field->{signed}) ? $allowedDbFieldTypes->{$field->{dbFieldType}}->{maxValue} : $allowedDbFieldTypes->{$field->{dbFieldType}}->{maxValueUnsigned};
				my $minValue = ($field->{signed}) ? $allowedDbFieldTypes->{$field->{dbFieldType}}->{minValue} : 0;
				if ($self->session->form->process($fieldName) > $maxValue || $self->session->form->process($fieldName) < $minValue) {
					push (@error, $i18n->get('ers out of range').' '.$field->{displayName});
				}
			}
		}
	}

	# Return with a list of errors if there are any.
	if (@error) {
		return $self->www_editRecord([ map {{'error.message'=>$_}} @error ]);
		return "<ul><li>".join('</li><li>',@error).'</li></ul>';
	}

	# In case of no errors write the new values to a new version.
	if (@update) {
		$dbLink->db->write('update '.$self->get('tableName').' set __archived=1 where __recordId='.$self->session->db->quote($recordId));
		$dbLink->db->write('insert into '.$self->get('tableName').' set '.join(', ', @update));
	}

	$dbLink->disconnect;

	# Send an email notification.
	if ($self->get('sendMailTo')) {
		my $mail = WebGUI::Mail::Send->create($self->session, {
			to	=> $self->get('sendMailTo'),
			subject	=> $i18n->get('ers change notification'),
		});
		$mail->addText($i18n->get('ers change on table').' '.$self->get('tableName').
			' '.$i18n->get('ers by user').' '.$self->session->user->username."\n".
			$i18n->get('ers view url').' '.$self->getUrl('func=editRecord;rid='.$recordId)
		);
		$mail->queue;
	}

	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_editRegex ( )

Returns the form for editing regexes. Pass the id of the regex you want to edit in the form param 'regexId'. To 
add a new regex pass 'new' for the regex id.

=cut

sub www_editRegex {
	my ($output, $properties, $f, $i18n);
	my $self = shift;
	my $errors = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	if ($errors) {
		$output = '<b>'.$i18n->get('er error message').'</b><ul><li>'.join('</li><li>', @$errors).'</li></ul>';
	}
	
	if ($self->session->form->process("regexId") eq 'new') {
		$properties = {};
	} else {
		$properties = $self->session->db->quickHashRef('select * from SQLForm_regexes where regexId='.$self->session->db->quote($self->session->form->process("regexId")));
	}
	
	$f = WebGUI::HTMLForm->new($self->session,
		-action	=> $self->getUrl
	);
	$f->hidden(
		-name	=> 'func',
		-value	=> 'editRegexSave',
	);
	$f->hidden(
		-name	=> 'regexId',
		-value	=> $self->session->form->process("regexId"),
	);
	$f->readOnly(
		-label	=> 'Id',
		-value	=> $self->session->form->process("regexId"),
	);
	$f->text(
		-name	=> 'name',
		-label	=> $i18n->get('er name'),
		-hoverHelp => $i18n->get('er name description'),
		-value	=> $self->session->form->process("name") || $properties->{name},
	);
	$f->text(
		-name	=> 'regex',
		-label	=> $i18n->get('er regex'),
		-hoverHelp => $i18n->get('er regex description'),
		-value	=> $self->session->form->process("regex")|| $properties->{regex},
		-size	=> 30,
	);
	$f->readOnly(
		-value	=> 
			WebGUI::Form::submit($self->session).
			WebGUI::Form::button($self->session, {
				value	=> $i18n->get('cancel'),
				extras	=> 'onClick="location.href=\''.$self->getUrl('func=listRegexes').'\'"'
			})
	);
	
	$self->getAdminConsole->setHelp("edit regex", "Asset_SQLForm");
	return $self->getAdminConsoleWithSubmenu->render($f->print, $i18n->get('edit regex title'));
}

#-------------------------------------------------------------------

=head2 www_editRegexSave ( )

Saves the regex properties entered in the form generated by www_editRegex to the database. Pass the regex id 
in the form param 'regexId'. Set the id to 'new' to add a regex.

=cut

sub www_editRegexSave {
	my (@error, $regexId, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
	push(@error, $i18n->get('ers no name')) unless ($self->session->form->process("name"));
	push(@error, $i18n->get('ers no regex')) unless ($self->session->form->process("regex"));

	return $i18n->get('er error message').'<ul><li>'.join('</li><li>', @error).'</li></ul>'.$self->www_editRegex if (@error);

	if ($self->session->form->process("regexId") eq 'new') {
		$regexId = $self->session->id->generate();
		$self->session->db->write("insert into SQLForm_regexes set ".
			" regexId=".$self->session->db->quote($regexId).", name=".$self->session->db->quote($self->session->form->process("name")).", regex=".$self->session->db->quote($self->session->form->process("regex")));
	} elsif ($self->session->form->process("regexId")) {
		$regexId = $self->session->form->process("regexId");
		$self->session->db->write("update SQLForm_regexes set ".
			"name=".$self->session->db->quote($self->session->form->process("name")).", regex=".$self->session->db->quote($self->session->form->process("regex"))." where regexId=".$self->session->db->quote($self->session->form->process("regexId")));
	}

	return $self->www_listRegexes;
}
	
#-------------------------------------------------------------------

=head2 www_listFields ( )

Shows the list of fields, including edit and delete buttons.

=cut

sub www_listFields {
	my (@fields, $output, $thisField, $fieldTypesDefined, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	
#	$output = '<h2>'.$self->get('title').'</h2>' if $self->get('displayTitle');
	$output .= $self->_getManagementLinks.'<br />';

	($fieldTypesDefined) = $self->session->db->quickArray("select count(*) from SQLForm_fieldTypes");
	unless ($fieldTypesDefined) {
		return $self->processStyle($output.
			$i18n->get('no field types message').' '.'<a href="'.$self->getUrl('func=listFieldTypes').'">'.$i18n->get('manage field types').'</a>.'
		);
	}


	@fields = $self->session->db->buildArray(
		 " select fieldId "
		." from SQLForm_fieldOrder "
		." where assetId=".$self->session->db->quote($self->getId) 
		." order by rank"
	);

	$output .= '<table border="0">';
	foreach (@fields) {
		$thisField = $self->_getFieldProperties($_);
		$output .= '<tr>';
		$output .= '<td>'.$self->session->icon->delete('func=disableField;fid='.$_).'</td>' unless ($thisField->{disabled});
		$output .= '<td>'.'<a href="'.$self->getUrl('func=enableField;fid='.$_).'">Undelete</a>'.'</td>' if ($thisField->{disabled});
		$output .= '<td>'.$self->session->icon->moveDown('func=moveFieldDown;fid='.$_).'</td>';
		$output .= '<td>'.$self->session->icon->moveUp('func=moveFieldUp;fid='.$_).'</td>';
		$output .= '<td>'.$self->session->icon->edit('func=editField;fid='.$_, $self->get("url")).'</td>';
		$output .= '<td>'.$thisField->{fieldName}." (".$thisField->{displayName}.")".'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	
	$output .= '<br /><a href="'.$self->getUrl('func=editField;fid=new').'">'.$i18n->get('lf add field').'</a>';

	$self->getAdminConsole->setHelp("manage fields", "Asset_SQLForm");
	return $self->getAdminConsoleWithSubmenu->render($output, $i18n->get('manage fields title'));
}

#-------------------------------------------------------------------

=head2 www_listFieldTypes ( )

Shows the list of field types.

=cut

sub www_listFieldTypes {
	my ($sth, $row, $output, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);
	
	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

#	$output = '<h2>'.$self->get('title').'</h2>' if $self->get('displayTitle');
	$output .= $self->_getManagementLinks.'<br />';
	
	$sth = $self->session->db->read("select * from SQLForm_fieldTypes order by dbFieldType");

my	$js = "function toggleList(id) {\n" 
		."\tvar a = document.getElementById(id);\n"
		."\tif (a.style.display == 'none') {\n"
		."\t\ta.style.display = ''\n"
		."\t} else { \n"
		."\t\ta.style.display = 'none'\n"
		."\t}\n"
		."}";
	
my (@usedTypes, @unusedTypes);
	while ($row = $sth->hashRef) {
my		$assetsUsing = $self->session->db->read(
			' select distinct t2.url, t2.title, t1.fieldId, t3.value '.
			' from SQLForm_fieldDefinitions as t1, assetData as t2, SQLForm_fieldDefinitions as t3 '.
			' where t1.assetId=t2.assetId and '.
			'	t1.fieldId=t3.fieldId and t3.property="fieldName" and '.
			' 	t1.property="fieldType" and t1.value='.$self->session->db->quote($row->{fieldTypeId}));
my		$currentRow = '<tr align="left" bgcolor="#bbbbbb">';
		$currentRow .= "<td>";
		$currentRow .= $self->session->icon->delete('func=deleteFieldType;ftid='.$row->{fieldTypeId}, $self->get('url'), $i18n->get('lft delete confirm message')) unless ($assetsUsing->rows);
		$currentRow .= "</td>";

		$currentRow .= "<td>".$row->{dbFieldType}."</td><td>".$row->{formFieldType}."</td>";
		if ($assetsUsing->rows) {
			$currentRow .= '</tr><tr><td bgcolor="#bbbbbb"></td><td bgcolor="#dddddd" colspan="2">';
			$currentRow .= '<span style="cursor : crosshair" onclick="toggleList(\'SQLForm_'.$row->{fieldTypeId}.'\')">'
				.$i18n->get('lft show assets using').'</span>';
			$currentRow .= '<ul style="display: none" id="SQLForm_'.$row->{fieldTypeId}.'">';
			while (my $currentField = $assetsUsing->hashRef) {
				$currentRow .= '<li>';
				$currentRow .= $self->session->icon->edit('func=editField;fid='.$currentField->{fieldId}, $currentField->{url});
				$currentRow .= $currentField->{title}.' '.$i18n->get('lft in field').' '.$currentField->{value};
				$currentRow .= '</li>';
			}
			$currentRow .= '</ul></td><tr height="5"></tr>'.'</tr>';
			push(@usedTypes, $currentRow);
		} else {
			$currentRow .= "</tr>";
			push(@unusedTypes, $currentRow);
		}
	}

	$output .= '<script type="text/javascript">'.$js.'</script>';
	$output .= '<table>';
	$output	.= '<tr align="left"><td colspan="3"><h2>'.$i18n->get('lft unused field types').'</h2></td></tr>';
	$output .= '<tr align="left"><th></th><th>'.$i18n->get('lft db type').'</th><th>'.$i18n->get('lft form type').'</th></tr>';
	$output .= join('',@unusedTypes);
	$output .= '<tr align="left"><td colspan="3"><h2>'.$i18n->get('lft used field types').'</h2></td></tr>';
	$output .= '<tr align="left"><th></th><th>'.$i18n->get('lft db type').'</th><th>'.$i18n->get('lft form type').'</th></tr>';
	$output .= join('',@usedTypes);
	$output .= '</table>';
	$output .= '<a href="'.$self->getUrl('func=editFieldType;ftid=new').'">'.$i18n->get('lft add field type').'</a>';

	$self->getAdminConsole->setHelp("manage field types", "Asset_SQLForm");
	return $self->getAdminConsoleWithSubmenu->render($output,$i18n->get('manage field types title'));
}

#-------------------------------------------------------------------

=head2 www_listRegexes ( )

Displays the list of regexes.

=cut

sub www_listRegexes {
	my ($sth, $row, $output, $i18n);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

#	$output = '<h2>'.$self->get('title').'</h2>' if $self->get('displayTitle');
	$output .= $self->_getManagementLinks.'<br />';
	
	$sth = $self->session->db->read("select * from SQLForm_regexes order by name");
	
my	$js = "function toggleList(id) {\n" 
		."\tvar a = document.getElementById(id);\n"
		."\tif (a.style.display == 'none') {\n"
		."\t\ta.style.display = ''\n"
		."\t} else { \n"
		."\t\ta.style.display = 'none'\n"
		."\t}\n"
		."}";
	
my (@usedTypes, @unusedTypes);
	while ($row = $sth->hashRef) {
my		$assetsUsing = $self->session->db->read(
			' select distinct t2.url, t2.title, t1.fieldId, t3.value '.
			' from SQLForm_fieldDefinitions as t1, assetData as t2, SQLForm_fieldDefinitions as t3 '.
			' where t1.assetId=t2.assetId and '.
			'	t1.fieldId=t3.fieldId and t3.property="fieldName" and '.
			' 	t1.property="regex" and t1.value='.$self->session->db->quote($row->{regexId}));
my		$currentRow = '<tr align="left" bgcolor="#bbbbbb">';
		$currentRow .= "<td>";
		$currentRow .= $self->session->icon->delete('func=deleteRegex;regexId='.$row->{regexId}, $self->get('url'), 'Are you sure?') unless ($assetsUsing->rows);
		$currentRow .= "</td>";

		$currentRow .= "<td>".$row->{name}."</td><td>".$row->{regex}."</td>";
		if ($assetsUsing->rows) {
			$currentRow .= '</tr><tr><td bgcolor="#bbbbbb"></td><td bgcolor="#dddddd" colspan="2">';
			$currentRow .= '<span style="cursor : crosshair" onclick="toggleList(\'SQLForm_'.$row->{regexId}.'\')">'
				.$i18n->get('lr show assets using').'</span>';
			$currentRow .= '<ul style="display: none" id="SQLForm_'.$row->{regexId}.'">';
			while (my $currentField = $assetsUsing->hashRef) {
				$currentRow .= '<li>';
				$currentRow .= $self->session->icon->edit('func=editField;fid='.$currentField->{fieldId}, $currentField->{url});
				$currentRow .= $currentField->{title}.' '.$i18n->get('lr in field').' '.$currentField->{value};
				$currentRow .= '</li>';
			}
			$currentRow .= '</ul></td><tr height="5"></tr>'.'</tr>';
			push(@usedTypes, $currentRow);
		} else {
			$currentRow .= "</tr>";
			push(@unusedTypes, $currentRow);
		}
	}

	$output .= '<script type="text/javascript">'.$js.'</script>';
	$output .= '<table>';
	$output	.= '<tr align="left"><td colspan="3"><h2>'.$i18n->get('lr unused regexes').'</h2></td></tr>';
	$output .= '<tr align="left"><th></th><th>'.$i18n->get('lr name').'</th><th>'.$i18n->get('lr regex').'</th></tr>';
	$output .= join('',@unusedTypes);
	$output .= '<tr align="left"><td colspan="3"><h2>'.$i18n->get('lr used regexes').'</h2></td></tr>';
	$output .= '<tr align="left"><th></th><th>'.$i18n->get('lr name').'</th><th>'.$i18n->get('lr regex').'</th></tr>';
	$output .= join('',@usedTypes);
	$output .= '</table>';
	$output .= '<a href="'.$self->getUrl('func=editRegex;regexId=new').'">'.$i18n->get('lr add regex').'</a>';

	$self->getAdminConsole->setHelp("manage regexes", "Asset_SQLForm");	
	return $self->getAdminConsoleWithSubmenu->render($output,$i18n->get('manage regexes title'));
}

#-------------------------------------------------------------------

=head2 www_moveFieldDown ( )

Moves the field one position to the end in the field ordering. The field id should be passed in the form param 'fid'.

=cut

sub www_moveFieldDown {
	my (@fieldOrder, $currentField, $i, $nextField);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);
	
	@fieldOrder = $self->session->db->buildArray('select fieldId from SQLForm_fieldOrder where assetId = '.$self->session->db->quote($self->getId).' order by rank');
	$currentField = $self->session->form->process("fid");
	
	for ($i = 0; $i < scalar(@fieldOrder); $i++) {
		if ($fieldOrder[$i] eq $currentField && $i < (scalar(@fieldOrder) - 1)) {
			$nextField = $fieldOrder[$i + 1];
			last;
		}
	}
	
	if ($nextField) {
		$self->session->db->write('update SQLForm_fieldOrder set rank = rank + 1 where assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($currentField));
		$self->session->db->write('update SQLForm_fieldOrder set rank = rank - 1 where assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($nextField));
	}

	return $self->www_listFields;
}

#-------------------------------------------------------------------

=head2 www_moveFieldUp ( )

Moves the field one position to the beginning in the field ordering. The field id should be passed in the form param 'fid'.

=cut

sub www_moveFieldUp {
	my (@fieldOrder, $currentField, $i, $previousField);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canAlterTable);
	
	@fieldOrder = $self->session->db->buildArray('select fieldId from SQLForm_fieldOrder where assetId = '.$self->session->db->quote($self->getId).' order by rank');
	$currentField = $self->session->form->process("fid");
	
	for ($i = 0; $i < scalar(@fieldOrder); $i++) {
		if ($fieldOrder[$i] eq $currentField) {
			$previousField = $fieldOrder[$i - 1];
			last;
		}
	}
	
	if ($i > 0 && $previousField) {
		$self->session->db->write('update SQLForm_fieldOrder set rank = rank - 1 where assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($currentField));
		$self->session->db->write('update SQLForm_fieldOrder set rank = rank + 1 where assetId='.$self->session->db->quote($self->getId).' and fieldId='.$self->session->db->quote($previousField));
	}

	return $self->www_listFields;
}

#-------------------------------------------------------------------

=head2 www_purgeRecord ( )

Will purge a record from the record trash. The id of the record must be passed in form param 'rid'.

=cut

sub www_purgeRecord {
	my (@recordIds, $whereClause, $dbLink);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canPurge);

	@recordIds = $self->session->request->param('rid');
	$whereClause = join(' or ', map {'__recordId = '.$self->session->db->quote($_)} @recordIds);
	
	$dbLink = $self->_getDbLink;
	$dbLink->db->write("delete from ".$self->get('tableName')." where $whereClause") if ($whereClause);
	$dbLink->disconnect;

	return $self->processStyle($self->www_search);
}

#-------------------------------------------------------------------

=head2 www_purgeTrash ( )

Purges every record that is in the record trash.

=cut

sub www_purgeTrash {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canPurge);

	my $dbLink = $self->_getDbLink;
	$dbLink->db->write('delete from '.$self->get('tableName').' where __deleted=1');
	$dbLink->disconnect;
	
	return $self->processStyle($self->www_search);
}

#-------------------------------------------------------------------

=head2 www_viewHistory ( )

Shows the history of a record. The record id should be passed through the form param 'rid'.

=cut

sub www_viewHistory {
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->canView);

	my $dbLink = $self->_getDbLink;
	my $recordId = $self->session->form->process('rid');

	my @includeMetaFields = qw|__recordId __initDate __userId __revision|;
	my @metaFieldHeadings = ("Record ID", "Changed on", "Changed by", "Revision #");

	my @fieldIds = $self->session->db->buildArray(
		 " select fieldId "
		." from SQLForm_fieldOrder "
		." where assetId=".$self->session->db->quote($self->getId) 
		." order by rank"
	);

	my $tableHeading = '<tr><th>'.join('</th><th>', (@metaFieldHeadings, map {$self->_getFieldProperties($_)->{displayName}} @fieldIds)).'</th></tr>';

	my $sth = $dbLink->db->read('select * from '.$self->get('tableName').' where __recordId='.$dbLink->db->quote($recordId).' order by __revision');

	my ($tableBody);
	while (my $row = $sth->hashRef) {
		$row->{__initDate} = $self->session->datetime->epochToHuman($row->{__initDate});
		$row->{__userId} = WebGUI::User->new($self->session, $row->{__userId})->username;
		$tableBody .= '<tr>';
		$tableBody .= '<td>'.join('</td><td>', map {$row->{$_}} @includeMetaFields).'</td>';

		foreach (@fieldIds) {
			my $field = $self->_getFieldProperties($_);
			$tableBody .= '<td>';
			if ($field->{formFieldType} eq 'file') {
				$tableBody .= '<a href="'.$self->getUrl('func=viewFile;rid='.$row->{__recordId}.';rev='.$row->{__revision}.';fid='.$_).'">';
				if ($row->{'__'.$field->{fieldName}.'_mimeType'} =~ /^image/) {
					$tableBody .= '<img src="'.$self->getUrl('func=viewThumbnail;rid='.$row->{__recordId}.';rev='.$row->{__revision}.';fid='.$_).'">';
				} else {
					$tableBody .= 'Click here for file.';
				}
				$tableBody .= '</a>';
			} else {
				if ($field->{hasOptions}) {
					$tableBody .= $field->{allOptions}->{$row->{$field->{fieldName}}};
				} else {
					$tableBody .= $row->{$field->{fieldName}};
				}
			}
			$tableBody .= '</td>';
		}
		$tableBody .= '</tr>';
	}

	my $output = $self->_getManagementLinks;
	$output .= '<style type="text/css">.historyTable td, th { border: 1px solid #ccc; padding: 2px; }</style>';
	$output .= '<table class="historyTable">';
	$output .= $tableHeading;
	$output .= $tableBody;
	$output .= '</table>';

	$dbLink->disconnect;
	return $self->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_viewFile ( )

Returns the file saved in a file upload field, and sets the mime-type to the correct value. Pass the record id
via form param 'rid' and the field id of the upload field through form param 'fid'. Optionally you can pass the 
revision number in form param 'rev'; otherwise the latest revision is used.

=cut

sub www_viewFile {
	my ($field, $revision);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->canView);

	my $fieldId = $self->session->form->process('fid');
	my $recordId = $self->session->form->process('rid');
	my $revision = $self->session->form->process('rev');

	$field = $self->_getFieldProperties($fieldId);

	if ($field->{formFieldType} eq 'file') {
		my ($mimeType, $data) = $self->_getFileFromDatabase($recordId, $field->{fieldName}, $revision); 
		$self->session->http->setMimeType($mimeType);
	
		return $data;
	}

	return "No file found";
}

#-------------------------------------------------------------------

=head2 www_viewThumbnail ( )

Returns a thumbnail of the image stored in an upload field.

This particular caching scheme is used in stead of storage, since privileges should still be checked.

=cut

sub www_viewThumbnail {
	my ($field, $revision, $thumbnailData);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->canView);

	my $fieldId = $self->session->form->process('fid');
	my $recordId = $self->session->form->process('rid');
	my $revision = $self->session->form->process('rev');
	$field = $self->_getFieldProperties($self->session->form->process("fid"));

	if ($field->{formFieldType} eq 'file') {
		my $cache = WebGUI::Cache->new($self->session, ["sqlform",$recordId,$fieldId,$revision], 24*60*60);

		$thumbnailData = $cache->get;
		
		unless ($thumbnailData) {	
			my ($mimeType, $data) = $self->_getFileFromDatabase($recordId, $field->{fieldName}, $revision);

			# Create thumbnail. I use this method b/c it seems to be impossible to feed
			# image magick scalars containing pictures. Even using IO::Scalar or PerlIO::Scalar.
			# This is b/c Image::Magick cannot handle perl GLOBS.
			my $tempStorage	= WebGUI::Storage::Image->createTemp($self->session);
			$tempStorage->addFileFromScalar('tempthumb.png', $data);
			$tempStorage->generateThumbnail('tempthumb.png', 100);
			
			open my $FH1, "<", $tempStorage->getPath().'/thumb-tempthumb.png';
			while (<$FH1>) {
				$thumbnailData .= $_;
			}
			close $FH1;
	
			$tempStorage->delete;
			$cache->set($thumbnailData);
		}

		$self->session->http->setMimeType('image/png');
		
		return $thumbnailData;
	}

	return "No file found";
}


#-------------------------------------------------------------------

=head2 www_restoreRecord ( )

Restores a record in the record trash. Pass the record id through for param 'rid'.

=cut

sub www_restoreRecord {
	my ($dbLink, @recordIds, $whereClause);
	my $self = shift;

	return $self->session->privilege->insufficient() unless ($self->_canEditRecord);

	@recordIds = $self->session->request->param('rid');
	$whereClause = join(' or ', map {'__recordId = '.$self->session->db->quote($_)} @recordIds);
	
	$dbLink = $self->_getDbLink;
	$dbLink->db->write("update ".$self->get('tableName')." set ".
		" __deleted=0,".
		" __deletionDate=NULL,".
		" __deletedBy=NULL".
		" where $whereClause"
	) if ($whereClause);
	$dbLink->disconnect;

	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_search ( )

Generates the normal search form.

=cut

sub www_search {
	my (%searchableFields, @showFields, $query, $searchInTrash, @searchIn, $f, $output, %fieldProperties,
		$useRegex, $sortColumn, $sortAscending, $recordControls, $queryLike,
		%row, $sth, @headerLoop, $var, @recordLoop, %searchInTrashOptions, $i18n);
	my $self = shift;
	my $error = shift;

	return $self->session->privilege->insufficient() unless ($self->canView);
	
	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	my $dbLink = $self->_getDbLink;
	
	# Get field properties;
	tie %searchableFields, "Tie::IxHash";
my	@fields = $self->session->db->buildArray("select distinct fieldId from SQLForm_fieldOrder where assetId=".$self->session->db->quote($self->getId)." order by rank");
	foreach (@fields) {
		$fieldProperties{$_} = $self->_getFieldProperties($_);
		unless ($fieldProperties{$_}->{disabled}) {
			$searchableFields{$_} = $fieldProperties{$_}->{displayName} if $fieldProperties{$_}->{isSearchable};
			push(@showFields, $_) if $fieldProperties{$_}->{showInSearchResults};
		}
	}

	$var->{showFieldsDefined} = 1 if (@showFields);

	# Set up search parameters
#	@searchIn = @{Storable::thaw($self->session->scratch->get('SQLForm_'.$self->getId.'searchIn'))} if (defined $self->session->scratch->get('SQLForm_'.$self->getId.'searchIn'));
	@searchIn = $self->session->form->checkList('searchIn') if (defined $self->session->form->process("searchIn"));
	@searchIn = split(/\n/,$self->session->scratch->get('SQLForm_'.$self->getId.'searchIn')) unless (defined $self->session->form->process("searchIn"));
	@searchIn = keys(%searchableFields) unless (@searchIn);
	
	$query = $self->session->form->process("searchQuery");
	$query = $self->session->scratch->get('SQLForm_'.$self->getId.'query') unless ($query);
	
	$useRegex = $self->session->form->process("searchMode");
	$useRegex = $self->session->scratch->get('SQLForm_'.$self->getId.'searchMode') unless (defined $self->session->form->process("useRegex"));
	$useRegex ||= 'normal';
	
	$searchInTrash = $self->session->form->process("searchInTrash");
	$searchInTrash = $self->session->scratch->get('SQLForm_'.$self->getId.'searchInTrash') unless (defined $self->session->form->process("searchInTrash"));
	$searchInTrash ||= '0';

	$sortColumn = $self->session->form->process("sortColumn");
	$sortColumn = $self->session->scratch->get('SQLForm_'.$self->getId.'sortColumn') unless ($sortColumn);
	
	$sortAscending = $self->session->form->process("sortAscending");
	$sortAscending = $self->session->scratch->get('SQLForm_'.$self->getId.'sortAscending') unless (defined $self->session->form->process("sortAscending"));

	# Save search parameters
	$self->session->scratch->set('SQLForm_'.$self->getId.'searchIn', join("\n", @searchIn)) if (@searchIn);
	$self->session->scratch->set('SQLForm_'.$self->getId.'query', $query);
	$self->session->scratch->set('SQLForm_'.$self->getId.'searchMode', $useRegex);
	$self->session->scratch->set('SQLForm_'.$self->getId.'searchInTrash', $searchInTrash);
	$self->session->scratch->set('SQLForm_'.$self->getId.'searchType', 'or');

	tie %searchInTrashOptions, "Tie::IxHash";
	%searchInTrashOptions = (0 => 'Only normal', 1 => 'Only trash', 2 => 'Normal and trash');

	my $elementCounter = 0;
	my $searchInFormElement = '<table border="0"><tr>';
	foreach (keys %searchableFields) {
		$elementCounter++;
		$searchInFormElement .= '<td>';
		$searchInFormElement .= WebGUI::Form::Checkbox($self->session, { 
			-name	=> 'searchIn',
			-value	=> $_,
			-checked=> WebGUI::Utility::isIn($_, @searchIn),
		});
		$searchInFormElement .= " $searchableFields{$_}</td>";
		$searchInFormElement .= '</tr><tr>' if ($elementCounter % 2 == 0);
	}
	$searchInFormElement .= '</tr><tr><td>';
	$searchInFormElement .= '<input type="checkbox" name="checkAllSerachIns" onchange="switchCheckboxen(this.form.searchIn, this.checked)"> <b>All</b>';
	$searchInFormElement .= '</td></tr></table>';
	
	$f = WebGUI::HTMLForm->new($self->session,
		-action	=> $self->getUrl
	);
	$f->hidden(
		-name	=> 'func',
		-value	=> 'search',
	);
	$f->hidden(
		-name	=> 'searchType',
		-value	=> 'or',
	);
	$f->text(
		-name	=> 'searchQuery',
		-label	=> $i18n->get('s query'),
		-value	=> $query,
	);
	$f->radioList(
		-name	=> 'searchMode',
		-label	=> $i18n->get('s mode'),
		-value	=> $useRegex ,
		-options=> {'normal' => 'Normal search', 'regexp' => 'Regex search'},
	);
	$f->readOnly(
		-label	=> $i18n->get('s search in fields'),
		-value	=> $searchInFormElement,
	);
	$f->radioList(
		-name	=> 'searchInTrash',
		-label	=> $i18n->get('s location'),
		-options=> \%searchInTrashOptions,
		-value	=> $searchInTrash,
	);
	$f->submit(
		-value	=> $i18n->get('s search button'),
	);

	$var->{searchForm} = qq|
	<script type="text/javascript">
	function switchCheckboxen(elem,setValue ){
		for(var i = 0; i < elem.length; i++) {
			elem[i].checked = setValue;
		}
	};
	</script>|.$f->print;

	foreach (@showFields) {
		$fieldProperties{$_} = $self->_getFieldProperties($_);
		push(@headerLoop, {
			'header.title' => $fieldProperties{$_}->{displayName},
			'header.sort.url' => $self->getUrl('func=search;sortColumn='.$_.';sortAscending='.($sortAscending ? '0' : '1')),
			'header.sort.onThis' => ($sortColumn eq $_),
			'header.sort.ascending' => $sortAscending,
		});
	}

	$var->{'headerLoop'} = \@headerLoop;

        $var->{searchFormHeader} = WebGUI::Form::formHeader($self->session,
		{action => $self->getUrl}).
	        WebGUI::Form::hidden($self->session, {name=>'func', value=>'search'}).
		WebGUI::Form::hidden($self->session, {name=>'searchType', value=>'or'});

	$var->{'searchFormQuery.label'} = $i18n->get('s query');
	$var->{'searchFormQuery.form'} = WebGUI::Form::text($self->session,{
                name=>'searchQuery',
                value=>$query
               });
        $var->{'searchFormMode.label'} = $i18n->get('s mode');
        $var->{'searchFormMode.form'} = WebGUI::Form::radioList($self->session,{
                name=>'searchMode',
                value=>$useRegex,
                options=> {'normal' => 'Normal search', 'regexp' => 'Regex search'},
               });
        $var->{'searchFormSearchIn.label'} = $i18n->get('s search in fields');
        $var->{'searchFormSearchIn.form'} = WebGUI::Form::checkList($self->session,{
                name=>'searchIn',
                value=>\@searchIn,
                options=> \%searchableFields,
               });
        $var->{'searchFormTrash.label'} = $i18n->get('s location');
        $var->{'searchFormTrash.form'} = WebGUI::Form::radioList($self->session,{
                name=>'searchInTrash',
                value=>$searchInTrash,
                options=> \%searchInTrashOptions,
               });
        $var->{searchFormSubmit} = WebGUI::Form::submit($self->session,{value => $i18n->get('s search button')});
        $var->{searchFormFooter} = WebGUI::Form::formFooter($self->session);

	if (@searchIn && ($query || $searchInTrash)) {
my		$sql = $self->_constructSearchQuery(\@searchIn, \@showFields, \%fieldProperties, $query);

		if ($sql) {
			# Execute query
			$sth = $dbLink->db->unconditionalRead($sql);
	
			# Handle invalid queries
			push(@$error, $i18n->get('s query error').' '. $sth->errorMessage) unless ($sth->errorCode < 1);
		
			$var->{'searchResults.recordLoop'} = $self->_processSearchQuery($sth, \@showFields, \%fieldProperties);
		}
	}

	$var->{'superSearch.url'} = $self->getUrl('func=superSearch');
	$var->{'superSearch.label'} = $i18n->get('s advanced search');
	$var->{'normalSearch.url'} = $self->getUrl('func=search');
	$var->{'normalSearch.label'} = $i18n->get('s normal search');
	
	$var->{'searchResults.header'} = WebGUI::Form::formHeader($self->session).
		WebGUI::Form::hidden($self->session, {name=>'func',value=>'', id=>'SearchResultsAction'});
	$var->{'searchResults.footer'} = WebGUI::Form::formFooter($self->session);
	$var->{'searchResults.actionButtons'} = 
		WebGUI::Form::button($self->session, {
			value	=> $i18n->get('s restore'),
			extras  => "onclick=\"document.getElementById('SearchResultsAction').value='restoreRecord'; this.form.submit();\"",
		}).
		WebGUI::Form::button($self->session, {
			value	=> $i18n->get('s purge'),
			extras	=> "onclick=\"document.getElementById('SearchResultsAction').value='purgeRecord'; this.form.submit();\"",
		}) if ($searchInTrash);
		
	$var->{showMetaData} = $self->get('showMetaData');
	$var->{managementLinks} = $self->_getManagementLinks;
	$var->{errorOccurred} = defined $error;
	$var->{errorLoop} = [ map {{'error.message' => $_}} @$error ];

	$dbLink->disconnect;
	
	# Only process style if search is called directly;	
	return $self->processTemplate($var, $self->getValue('searchTemplateId')) unless ($self->session->form->process("func") eq 'search');
	return $self->processStyle($self->processTemplate($var, $self->getValue('searchTemplateId')));
}

#-------------------------------------------------------------------

=head2 www_processAjaxRequest ( )

Returns an XML string containing database information, depending on the form params passed. If you pass a database
name in form param 'dbName' only, this method will return an XML string containing the tables available within that
database. If you also pass a table name through form param 'tName' an XML string containing the columns in that table
are returned.

Format of the XML must follow the next convention:

<SQLForm>
	<Option>
		<Key>keyName1</Key>
		<Value>valueName1</Value>
	</Option>
	<Option>
		<Key>keyName2</Key>
		<Value>valueName2</Value>
	</Option>
	
	...etc...
	
</SQLForm>

=cut

sub www_processAjaxRequest {
	my $self = shift;

	my $dbLink = $self->_getDbLink;
	return $self->session->privilege->insufficient unless $self->_canAlterTable;
	
	$self->session->http->setMimeType('text/xml');

my	$xml = "<SQLForm>\n";
	
	if (isIn($self->session->form->process("dbName"), $dbLink->db->buildArray('show databases'))) {
		
my		@zut;
		if ($self->session->form->process("tName") && isIn($self->session->form->process("tName"), $dbLink->db->buildArray('show tables from '.$self->session->form->process("dbName")))) {
			@zut = $dbLink->db->buildArray('describe '.$self->session->form->process("dbName").'.'.$self->session->form->process("tName"));
		} else {
			@zut = $dbLink->db->buildArray('show tables from '.$self->session->form->process("dbName"));
		}
	
		foreach (@zut) {
			$xml .= "\t<Option>\n";
			$xml .= "\t\t<Key>$_</Key>\n";
			$xml .= "\t\t<Value>$_</Value>\n";
			$xml .= "\t</Option>\n";
		}
	}

	$xml .= "</SQLForm>";
	
	return $xml;
}

#-------------------------------------------------------------------

=head2 _constructSearchForm ( fieldList, fieldProperties )

Returns the form for super search.

=head3 fieldList

Arrayref containing the field that should be included in the search.

=head3 fieldProperties

Hashref containing the properties of the fields that are in the search.

=cut

sub _constructSearchForm {
	my ($form, $js, %searchInTrashOptions, $i18n);
	my $self = shift;
	my $var = shift;
	my $fieldList = shift;
	my $fieldProperties = shift;

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');
	tie %searchInTrashOptions, "Tie::IxHash";
	%searchInTrashOptions = (
		0 => $i18n->get('_csf only normal'), 
		1 => $i18n->get('_csf only trash'), 
		2 => $i18n->get('_csf normal and trash')
	);

my	$searchType = $self->session->form->process("searchType") || $self->session->scratch->get('SQLForm_'.$self->getId.'searchType') || 'or';

my	$searchInTrash = $self->session->form->process("searchInTrash");
	$searchInTrash = $self->session->scratch->get('SQLForm_'.$self->getId.'searchInTrash') unless (defined $self->session->form->process("searchInTrash"));
	$searchInTrash ||= '0';

	$var->{searchFormHeader} = WebGUI::Form::formHeader($self->session ,{action => $self->getUrl});
	$var->{searchFormHeader} .= WebGUI::Form::hidden($self->session, {name => 'func', value => 'superSearch'});
	$var->{searchFormHeader} .= WebGUI::Form::hidden($self->session, {name => 'searchQueried', value => 1});
	
	$form = $var->{searchFormHeader};
	$form .= '<table>';
	$form .= '<tr valign="top">';
	
	$var->{'searchFormTrash.label'} = $i18n->get('s location');
        $var->{'searchFormTrash.form'} = WebGUI::Form::radioList($self->session, {
	       name    => "searchInTrash",
	       options => \%searchInTrashOptions,
	       value   => $searchInTrash,
	});
								 
	$form .= '<td><b>'.$var->{'searchFormTrash.label'}.'</b></td><td colspan="2">'.$var->{'searchFormTrash.form'};
	$form .= '</td></tr>';
	$var->{'searchFormType.label'} = $i18n->get('s search type');
	$var->{'searchFormType.form'} = WebGUI::Form::radioList($self->session, {
                name    => "searchType",
                options => {'or' => $i18n->get('or'), 'and' => $i18n->get('and')},
	        value   => $searchType,
	});
							
	$form .= '<td><b>'.$var->{'searchFormType.label'}.'</b></td><td colspan="2">'.$var->{'searchFormType.form'};
	$form .= '</td></tr>';

	$self->session->scratch->set('SQLForm_'.$self->getId.'searchType', $searchType);
	$self->session->scratch->set('SQLForm_'.$self->getId.'searchInTrash', $searchInTrash);

	my @field_loop;
	foreach (@$fieldList) {
		my ($searchForm1, $searchForm2, $conditionalForm);
		if ($self->session->form->process("searchQueried")) {
			$self->session->scratch->delete('SQLForm_'.$self->getId.'---'.$_.'v1');
			$self->session->scratch->delete('SQLForm_'.$self->getId.'---'.$_.'v2');
			$self->session->scratch->delete('SQLForm_'.$self->getId.'---'.$_.'c');
		}
		
my		$formValue1 = $self->session->form->process($_.'-1') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$_.'v1');
my		$formValue2 = $self->session->form->process($_.'-2') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$_.'v2');
my		$conditional = $self->session->form->process('_'.$_.'_conditional') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$_.'c');

		$self->session->scratch->set('SQLForm_'.$self->getId.'---'.$_.'v1', $formValue1);
		$self->session->scratch->set('SQLForm_'.$self->getId.'---'.$_.'v2', $formValue2);
		$self->session->scratch->set('SQLForm_'.$self->getId.'---'.$_.'c', $conditional);

		if ($fieldProperties->{$_}->{type} eq 'list') {
			if ($self->session->form->process($_.'-2')) {
				$formValue2 = [ $self->session->request->param($_.'-2') ];
				$self->session->scratch->set('SQLForm_'.$self->getId.'---'.$_.'v2', Storable::freeze($formValue2));
			} else {
				$formValue2 = eval('Storable::thaw($formValue2)');
			}
		}

		$form .= '<tr valign="top">';
		$form .= '<td valign="top"><b>'.$fieldProperties->{$_}->{displayName}.'</b></td>';

		$form .= '<td>';
		if (exists $types->{$fieldProperties->{$_}->{type}}) {
			$conditionalForm = WebGUI::Form::selectList($self->session, {
				name	=> '_'.$_.'_conditional',
				value	=> [ $conditional || '' ],
				options	=> $types->{$fieldProperties->{$_}->{type}},
				extras	=> 'onchange="'.$typeFunctions->{$fieldProperties->{$_}->{type}}.'(this.value, \''.$_.'\')"',
				size	=> 1,
				multiple=> 0,
			});
			$js .= $typeFunctions->{$fieldProperties->{$_}->{type}}."('".$conditional."', '$_');";
		}
		$form .= $conditionalForm;
		$form .= '</td>';		
		$form .= '<td>';

		my $parameters = {};
		$parameters->{name} 	= $_.'-1';
		$parameters->{value}	= $formValue1;
		$parameters->{options}	= $fieldProperties->{$_}->{options} if ($fieldProperties->{$_}->{hasOptions});
		$parameters->{id}	= $_.'-1"';

my 		$searchElement = $fieldProperties->{$_}->{searchElement};
		$searchElement = 'text' if ($searchElement eq 'selectList');
my		$cmd = "WebGUI::Form::$searchElement".'($self->session, $parameters)';
		$searchForm1 = eval($cmd);
		$form .= $searchForm1;

		unless ($fieldProperties->{$_}->{type} eq 'text') {
			$searchElement = $fieldProperties->{$_}->{searchElement};
			$parameters->{name}	= $_.'-2';
			$parameters->{value}	= $formValue2;
			$parameters->{size}	= undef;
			$parameters->{id}	= $_.'-2"';
			if ($fieldProperties->{$_}->{type} eq 'list') {
				$parameters->{multiple}	= 1;
				$parameters->{size}	= 5;
				$parameters->{value}	= $formValue2;
			}
	
			$cmd = "WebGUI::Form::$searchElement".'($self->session, $parameters)';
			$searchForm2 = eval($cmd);
			$form .= $searchForm2;
		}

		$form .= '</td>';
		$form .= '</tr>';
	
                push (@field_loop, {
	                        'field.'.$fieldProperties->{$_}->{fieldName}.'.id' => $_,
	                        'field.label' => $fieldProperties->{$_}->{displayName},
	                        'field.conditionalForm' => $conditionalForm,
	                        'field.searchForm1' => $searchForm1,
	                        'field.searchForm2' => $searchForm2,
	                        'field.formValue1' => $formValue1,
	                        'field.formValue2' => $formValue2,
	                        'field.conditional' => $conditional,
	                        });
	
	}
	$var->{'searchForm.field_loop'} = \@field_loop;

	$var->{searchFormSubmit} = WebGUI::Form::submit($self->session, {value => $i18n->get('s search button')});
	$var->{searchFormFooter} = WebGUI::Form::formFooter($self->session);
	$var->{searchFormJavascript} = '<script src="'.$self->session->url->extras('wobject/SQLForm/SQLFormSearch.js').'" type="text/javascript"></script>'; 
	$var->{searchFormJavascript} .= '<script type="text/javascript">'.$js.'</script>';
	
	$form .= '<td>'.$var->{searchFormSubmit}.'</td>';
	$form .= '</table>';
	$form .= $var->{searchFormFooter};
	$form .= $var->{searchFormJavascript};

	$var->{searchForm} = $form;
}

#-------------------------------------------------------------------

=head2 _constructSearchQuery ( searchInFields, showFields, fieldProperties )

Constructs an SQL query from the search query

=head3 searchInFields

Arrayref containing the field id's that should be included in the search.

=head3 showFields

List of field id's that should be shown in the results.

=head3 fieldProperties

Hashref containing the properties of the fields that are in the search.

=cut

sub _constructSearchQuery {
	my (@tables, @joinConstraints, $tableCounter, @constraints, $currentField, $conditional, @joinSequence);
	my $self = shift;
	my $searchInFields = shift;
	my $showFields = shift;
	my $fieldProperties = shift;
	my $passedQuery = shift;

	# This variable should be set to value of the minimum word length for fulltext searches
	# as it is set in your MySQL database. Normally this is 3.
	my $minimumFulltextLength = 3;
	
	# Include the table the form writes to.
	$tableCounter = 2;

	# Process search fields.
	foreach $currentField (@$searchInFields) {
		# Set conditional given for this field or to like or regexp mode if in normal search
my 		$searchMode = $self->session->form->process("searchMode") || $self->session->scratch->get('SQLForm_'.$self->getId.'searchMode');
		if ($searchMode) {
			$conditional = 100 if ($searchMode eq 'normal');
			$conditional = 101 if ($searchMode eq 'regexp');
		} else {
			$conditional = $self->session->form->process('_'.$currentField.'_conditional') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$currentField.'c');
		}

		$tableCounter++;
		
		if ($conditional ne '') {
my			$currentFieldProperties = $fieldProperties->{$currentField};
my			$fieldName = $currentFieldProperties->{fieldName};
my			$fieldType = $currentFieldProperties->{type};
my			$fullFieldName = "t1.$fieldName";
my 			$constraint;
my			$query = $passedQuery || $self->session->form->process("searchQuery") || $self->session->form->process($currentField.'-1') || $self->session->scratch->get('SQLForm_'.$self->getId.'query');
my $queryLike;
			if ($conditional == 100 || $conditional == 101) {
				$query =~ s/\\/\\\\/g;
				$query =~ s/'/\\'/g;

				# Search on 'like'
				if ($conditional == 100) {
					$queryLike = $query;
					$queryLike =~ s/%/\\%/g;
					$queryLike =~ s/\*/%/g;
					$queryLike = "'%".$queryLike."%'";
				}
				$query = "'$query'";
			}

my			$formValue1 = $self->session->form->process($currentField.'-1') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$currentField.'v1');
my			$formValue2 = $self->session->form->process($currentField.'-2') || $self->session->scratch->get('SQLForm_'.$self->getId.'---'.$currentField.'v2');

			if ($fieldType eq 'list') {
				if ($self->session->form->process($currentField.'-2')) {
					$formValue2 = [ $self->session->request->param($currentField.'-2') ];
				} else {
					$formValue2 = Storable::thaw($formValue2);
				}
			}	

			if ($conditional == 200 && $formValue2) {
				#$constraint = "(".join(' or ', map {"$fullFieldName = ".$self->session->db->quote($_)} $self->session->request->param($currentField.'-2')).")";
				$constraint = "(".join(' or ', map {"$fullFieldName = ".$self->session->db->quote($_)} @$formValue2).")";
			} elsif ($conditional == 201 && $formValue2) {
				#$constraint = "(".join(' and ', map {"$fullFieldName = ".$self->session->db->quote($_)} $self->session->request->param($currentField.'-2')).")";
				$constraint = "(".join(' or ', map {"$fullFieldName = ".$self->session->db->quote($_)} @$formValue2).")";
			# Match the joined columns only if type is a list and has joins.
			# Else the regular like and regex will handle this.
			} elsif ($fieldType eq 'list' && $currentFieldProperties->{numberOfJoins}) {
my				$prepend = "t$tableCounter";
				for my $joinCounter (1 .. $currentFieldProperties->{numberOfJoins}) {
my					$joinStatement = $currentFieldProperties->{"database$joinCounter"}.'.'.
						$currentFieldProperties->{"table$joinCounter"}." as ".$prepend."table$joinCounter";
						
					if ($joinCounter > 1) {
						$joinStatement .= " on ".
							$prepend.$currentFieldProperties->{"joinOnA$joinCounter"}.'='.
							$prepend.$currentFieldProperties->{"joinOnB$joinCounter"};
					} else {
						$joinStatement .= " on ".
							$fullFieldName." = ".$prepend.$currentFieldProperties->{selectField1};
						$joinStatement .= " or ".$fullFieldName." = ''" if (!$currentFieldProperties->{isRequired});
							
					}
					push(@joinConstraints, $prepend."table$joinCounter.__archived='0'");
					push(@joinSequence, $joinStatement);
				}
				if ($conditional == 100) {	
					$constraint .= $prepend.$currentFieldProperties->{selectField2}." like ".$queryLike;
				} else {
					$constraint .= $prepend.$currentFieldProperties->{selectField2}." regexp($query)";
				}
			# 10 = between
			} elsif ($conditional == 10) {
				$constraint = 
					"($fullFieldName > ".$self->session->db->quote($formValue1)." and ".
					" $fullFieldName <".$self->session->db->quote($formValue2).")";
			# 100 = like
			} elsif ($conditional == 100) {
				if ($currentFieldProperties->{useFulltext} && length($query) >= $minimumFulltextLength) {
					$constraint = "match($fullFieldName) against($query in boolean mode)";
				} else {
					$constraint = "$fullFieldName like $queryLike";
				}
			# 101 = regexp
			} elsif ($conditional == 101) {
				$constraint = "$fullFieldName regexp($query)";
			} else {
				$constraint = "$fullFieldName ".$types->{$fieldType}->{$conditional}." ".$self->session->db->quote($formValue1);
			}

			push(@constraints, $constraint) if $constraint;
		}
	}

my 	@selectColumns = qw(t1.__recordId t1.__deletionDate t1.__deletedBy t1.__initDate t1.__userId t1.__deleted t1.__archived t1.__revision);
	foreach (@$showFields) {
my		$fieldName = $fieldProperties->{$_}->{fieldName};
	
		push(@selectColumns, "t1.$fieldName");

		# In case of files also select mimetype
		if ($fieldProperties->{$_}->{formFieldType} eq 'file') {
			push(@selectColumns, 't1.__'.$fieldName.'_mimeType');
		}
	}

my	$searchInTrash = $self->session->scratch->get('SQLForm_'.$self->getId.'searchInTrash') || $self->session->form->process("searchInTrash") || '0';

my	$searchType = ($self->session->form->process("searchType") || $self->session->scratch->get('SQLForm_'.$self->getId.'searchType')) eq 'and' ? 'and' : 'or';

	return undef if (!@constraints);

	# Construct the search query
my	$sql = " select distinct ".join(', ', @selectColumns);
	$sql .= " from ".$self->get('tableName').' as t1 ';
	$sql .= " left join ".join(" left join \n", @joinSequence)."\n" if (@joinSequence);
	$sql .= " where ";
	$sql .= "(".join(" $searchType \n", @constraints).")\n" if (@constraints);
	$sql .= " and " if (@constraints);
	$sql .= "(".join(" and \n", @joinConstraints).")\n" if (@joinConstraints);
	$sql .= " and " if (@joinConstraints);
	$sql .= " t1.__archived=0 ";
	$sql .= " and t1.__deleted=".$self->session->db->quote($searchInTrash) if ($searchInTrash < 2);

my	$sortColumn = $self->session->form->process("sortColumn");
	$sortColumn = $self->session->scratch->get('SQLForm_'.$self->getId.'sortColumn') unless ($sortColumn);
	$self->session->scratch->set('SQLForm_'.$self->getId.'sortColumn', $sortColumn);
	
my	$sortAscending = $self->session->form->process("sortAscending");
	$sortAscending = $self->session->scratch->get('SQLForm_'.$self->getId.'sortAscending') unless (defined $self->session->form->process("sortAscending"));
	$self->session->scratch->set('SQLForm_'.$self->getId.'sortAscending', $sortAscending);

	if (isIn($sortColumn, @$showFields)) {
		$sql .= " order by ".$fieldProperties->{$sortColumn}->{fieldName};
		$sql .= " desc " unless ($sortAscending);
	}

	return $sql;
}

#-------------------------------------------------------------------

=head2 _processSearchQuery ( sth, showFields, fieldProperties )

Processes the results of a search query and returns an arrayref suitable for use as a template loop.

=head3 sth

Statement handle of the executed query.

=head3 showFields

List of field id's that should be shown in the results.

=head3 fieldProperties

Hashref containing the properties of the fields that are in the search.

=cut

sub _processSearchQuery {
	my $self = shift;
	my $sth = shift;
	my $showFields = shift;
	my $fieldProperties = shift;

	my $i18n = WebGUI::International->new($self->session, 'Asset_SQLForm');
	
my 	$recordControls;
my 	$searchInTrash;
my 	@recordLoop;

	while (my %row = $sth->hash) {
		my %record;
		my $fieldValues;
		$record{'record.id'} = $row{__recordId};
		if ($self->_canEditRecord) {
			if ($row{__deleted}) {
				$recordControls = WebGUI::Form::checkbox($self->session, {name=>'rid', value=>$row{__recordId}});
				$recordControls .= '<a href="'.$self->getUrl('func=editRecord;rid='.$row{__recordId}).'">'.
					'<img src="'.$self->session->url->extras('wobject/SQLForm/SQLFormViewButton.gif').'"'.
					'alt="View" title="View" align="middle" border="0" /></a>';
			} else {
				$recordControls = $self->session->icon->delete('func=deleteRecord'.';rid='.$row{__recordId},$self->get("url"),
					$i18n->get('_psq confirm delete message'));
				$recordControls .= $self->session->icon->edit('func=editRecord;rid='.$row{__recordId},$self->get("url"));
				$recordControls .= $self->session->icon->copy('func=editRecord;rid=new;copyRecordId='.$row{__recordId},$self->get("url"));
			}
			$record{'record.controls'} = $recordControls;
		}
		
		$record{'record.controls'} .= '<a href="'.$self->getUrl('func=editRecord;viewOnly=1;rid='.$row{__recordId}).'">'.
				'<img src="'.$self->session->url->extras('wobject/SQLForm/SQLFormViewButton.gif').'"'.
				'alt="View" title="View" align="middle" border="0" /></a>';
		
		if ($searchInTrash) {
			$record{'record.deletionDate'} = $self->session->datetime->epochToHuman($row{__deletionDate});
			$record{'record.deletedBy'} = WebGUI::User->new($self->session, $row{__deletedBy})->username;
		} else {
			$record{'record.updateDate'} = $self->session->datetime->epochToHuman($row{__initDate});
			$record{'record.updatedBy'} = WebGUI::User->new($self->session, $row{__userId})->username;
		}

		foreach (@$showFields) {
my			$value;

			$fieldProperties->{$_} = $self->_getFieldProperties($_) unless (exists $fieldProperties->{$_});
			
			if ($fieldProperties->{$_}->{hasOptions}) {
				my @options = split(/\n/, $row{$fieldProperties->{$_}->{fieldName}});
				$value = join(', ', @{$fieldProperties->{$_}->{allOptions}}{@options});
			} else {
				$value = $row{$fieldProperties->{$_}->{fieldName}};
			}
		
			$value = substr($value, 0, $fieldProperties->{$_}->{summaryLength}) if ($fieldProperties->{$_}->{summaryLength});
			
			$value =~ s/\n/<br \/>/g if (1);

			my $props = { 
				'record.value'  => $value,
			};
			
			if ($fieldProperties->{$_}->{formFieldType} eq 'file') {
				$props->{'record.value.isFile'} = 1;
				$props->{'record.value.isImage'} = 1 if ($row{'__'.$fieldProperties->{$_}->{fieldName}.'_mimeType'} =~ m/^image/);
				$props->{'record.value.thumbnailUrl'} = 
					$self->getUrl('func=viewThumbnail;rid='.$row{__recordId}.';fid='.$_);
			
				$props->{'record.value.downloadUrl'} = 
					$self->getUrl('func=viewFile;rid='.$row{__recordId}.';fid='.$_);
			}

			push(@$fieldValues, $props);
		}
			
		$record{'record.valueLoop'} = $fieldValues;

		push(@recordLoop, {%record});
	}

	return \@recordLoop;
}

#-------------------------------------------------------------------

=head2 www_superSearch

Returns the super search.

=cut

sub www_superSearch {
	my (@searchableFields, %fieldProperties, $var, @headerLoop, $sortAscending, $sortColumn, $i18n);
	my $self = shift;

	$i18n = WebGUI::International->new($self->session,'Asset_SQLForm');

	$sortColumn = $self->session->form->process("sortColumn");
	$sortColumn = $self->session->scratch->get('SQLForm_'.$self->getId.'sortColumn') unless ($sortColumn);

	$sortAscending = $self->session->form->process("sortAscending");
	$sortAscending = $self->session->scratch->get('SQLForm_'.$self->getId.'sortAscending') unless (defined $self->session->form->process("sortAscending"));

	
	$self->session->scratch->delete('SQLForm_'.$self->getId.'searchMode');
	
my	@fields = $self->session->db->buildArray("select distinct fieldId from SQLForm_fieldOrder where assetId=".$self->session->db->quote($self->getId)." order by rank");
my 	@showFields;
	foreach (@fields) {
		$fieldProperties{$_} = $self->_getFieldProperties($_);
		unless ($fieldProperties{$_}->{disabled}) {
			push(@searchableFields, $_) if ($fieldProperties{$_}->{isSearchable});
			push(@showFields, $_) if ($fieldProperties{$_}->{showInSearchResults});
		}
	}

	foreach (@showFields) {
		$fieldProperties{$_} = $self->_getFieldProperties($_);
		push(@headerLoop, {
			'header.title' => $fieldProperties{$_}->{displayName},
			'header.sort.url' => $self->getUrl('func=superSearch;sortColumn='.$_.';sortAscending='.($sortAscending ? '0' : '1')),
			'header.sort.onThis' => ($sortColumn eq $_),
			'header.sort.ascending' => $sortAscending,
		});
	}

	$var->{'headerLoop'} = \@headerLoop;

	
	# Construct search form
	$self->_constructSearchForm($var, \@searchableFields, \%fieldProperties);

	# Build search query
my	$sql = $self->_constructSearchQuery(\@searchableFields, \@showFields, \%fieldProperties);

	if ($sql) {
		# Retrieve search results
my 		$dbLink = $self->_getDbLink;	
my		$sth = $dbLink->db->unconditionalRead($sql);

		# Process search results
		$var->{'searchResults.recordLoop'} = $self->_processSearchQuery($sth, \@showFields, \%fieldProperties);

		# Close db connections to prevent memory leaks
		$sth->finish;
		$dbLink->disconnect;
	}

	$var->{'superSearch.url'} = $self->getUrl('func=superSearch');
	$var->{'superSearch.label'} = $i18n->get('s advanced search');
	$var->{'normalSearch.url'} = $self->getUrl('func=search');
	$var->{'normalSearch.label'} = $i18n->get('s normal search');
	
	$var->{showFieldsDefined} = 1 if (@showFields);	
	$var->{'searchResults.header'} = WebGUI::Form::formHeader($self->session).
		WebGUI::Form::hidden($self->session, {name=>'func',value=>'', id=>'SearchResultsAction'});
	$var->{'searchResults.footer'} = WebGUI::Form::formFooter($self->session);
	$var->{'searchResults.actionButtons'} = 
		WebGUI::Form::button($self->session, {
			value	=> $i18n->get('s restore'),
			extras  => "onclick=\"document.getElementById('SearchResultsAction').value='restoreRecord'; this.form.submit();\"",
		}).
		WebGUI::Form::button($self->session, {
			value	=> $i18n->get('s purge'),
			extras	=> "onclick=\"document.getElementById('SearchResultsAction').value='purgeRecord'; this.form.submit();\"",
		}) if ($self->session->form->process("searchInTrash"));

	$var->{showMetaData} = $self->get('showMetaData');
	$var->{managementLinks} = $self->_getManagementLinks;	

	# Only process style if search is called directly;
	return $self->processTemplate($var, $self->getValue('searchTemplateId')) unless ($self->session->form->process("func") eq 'superSearch');
	return $self->processStyle($self->processTemplate($var, $self->getValue('searchTemplateId')));
}

1;
