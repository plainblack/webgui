#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::International;
use WebGUI::SQL;
use WebGUI::Utility;


my $configFile;
my $quiet;

GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

print "\tUpdating config file.\n" unless ($quiet);

my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
$macros->{RootTab} = "RootTab";
$macros->{RandomSnippet} = "RandomSnippet";
$macros->{RandomImage} = "RandomImage";
$macros->{CanEditText} = "CanEditText";
$macros->{If} = "If";
$macros->{Spacer} = "Spacer";
$macros->{SpecificDropMenu} = "SpecificDropMenu";
$macros->{LastModified} = "LastModified";
$macros->{PreviousDropMenu} = "PreviousDropMenu";
$macros->{TopDropMenu} = "TopDropMenu";
$macros->{SI} = "SI_scaledImage";
$conf->set("macros"=>$macros);
my $wobjects = $conf->get("wobjects");
foreach my $i ($wobjects) {
	if ($wobjects->[$i] eq "MailForm") {
		$wobjects->[$i] = "DataForm";
	}
}
$conf->set("wobjects"=>$wobjects);
$conf->write;


print "\tRemoving unneeded files.\n" unless ($quiet);

unlink("../../lib/WebGUI/Wobject/MailForm.pm");
unlink("../../www/extras/floatCheck.js");
unlink("../../www/extras/numberCheck.js");


print "\tMigrating Mail Form to Data Form.\n" unless ($quiet);

WebGUI::Session::open("../..",$configFile);

#renaming namespace
my @sql = (
	"update wobject set namespace='DataForm' where namespace='MailForm'",
	"alter table MailForm rename DataForm",
	"alter table MailForm_entry rename DataForm_entry",
	"alter table MailForm_entryData rename DataForm_entryData",
	"alter table MailForm_field rename DataForm_field",
	"update incrementer set incrementerId='DataForm_entryId' where incrementerId='MailForm_entryId'",
	"update incrementer set incrementerId='DataForm_fieldId' where incrementerId='MailForm_fieldId'",
	"alter table DataForm_field change MailForm_fieldId DataForm_fieldId int not null",
	"alter table DataForm_entryData change MailForm_entryId DataForm_entryId int not null",
	"alter table DataForm_entry change MailForm_entryId DataForm_entryId int not null",
	"alter table DataForm drop column storeEntries",
	"alter table DataForm_field add column isMailField int not null default 0",
	"alter table DataForm add column mailData int not null default 1",
	"alter table DataForm_field add column label varchar(255)",
	"update DataForm_field set label=name"
	);
foreach my $query (@sql) {
	WebGUI::SQL->write($query);
}

#migrating data
my $sth = WebGUI::SQL->read("select * from DataForm");
while (my %dataform = $sth->hash) {
	my $startInsert = "insert into DataForm_field (wobjectId, DataForm_fieldId, sequenceNumber, name, status, type, 
		defaultValue, width, isMailField, label) values";
	WebGUI::SQL->write($startInsert." ($dataform{wobjectId}, ".getNext("DataForm_fieldId").", -5, 'from', 
		".quote($dataform{fromStatus}).", 'email', ".quote($dataform{fromField}).", $dataform{width}, 1,
		".quote(WebGUI::International::get(10,"DataForm")).")");
	WebGUI::SQL->write($startInsert." ($dataform{wobjectId}, ".getNext("DataForm_fieldId").", -4, 'to', 
		".quote($dataform{toStatus}).", 'email', ".quote($dataform{toField}).", $dataform{width}, 1,
		".quote(WebGUI::International::get(11,"DataForm")).")");
	WebGUI::SQL->write($startInsert." ($dataform{wobjectId}, ".getNext("DataForm_fieldId").", -3, 'cc', 
		".quote($dataform{ccStatus}).", 'email', ".quote($dataform{ccField}).", $dataform{width}, 1,
		".quote(WebGUI::International::get(12,"DataForm")).")");
	WebGUI::SQL->write($startInsert." ($dataform{wobjectId}, ".getNext("DataForm_fieldId").", -2, 'bcc', 
		".quote($dataform{bccStatus}).", 'email', ".quote($dataform{bccField}).", $dataform{width}, 1,
		".quote(WebGUI::International::get(13,"DataForm")).")");
	WebGUI::SQL->write($startInsert." ($dataform{wobjectId}, ".getNext("DataForm_fieldId").", -1, 'subject', 
		".quote($dataform{subjectStatus}).", 'text', ".quote($dataform{subjectField}).", $dataform{width}, 1,
		".quote(WebGUI::International::get(14,"DataForm")).")");
	my $i = 1;
        my $sth2 = WebGUI::SQL->read("select DataForm_fieldId from DataForm_field where wobjectId=$dataform{wobjectId} order by sequenceNumber");
        while (my ($id) = $sth2->array) {
                WebGUI::SQL->write("update DataForm_fieldId set sequenceNumber=$i where MailForm_entryId=$id");
                $i++;
        }
        $sth2->finish;
}
$sth->finish;

#removing unneeded fields and changing structures for the new data form
@sql = (
        "alter table DataForm drop column width",
        "alter table DataForm drop column fromField",
        "alter table DataForm drop column fromStatus",
        "alter table DataForm drop column toField",
        "alter table DataForm drop column toStatus",
        "alter table DataForm drop column ccField",
        "alter table DataForm drop column ccStatus",
        "alter table DataForm drop column bccField",
        "alter table DataForm drop column bccStatus",
        "alter table DataForm drop column subjectField",
        "alter table DataForm drop column subjectStatus",
        "alter table DataForm_field change status status varchar(35)",
	"update DataForm_field set status='hidden' where status=1",
	"update DataForm_field set status='visible' where status=2",
	"update DataForm_field set status='editable' where status=3",
	"update DataForm_field set type='selectList' where type='select'",
	"alter table DataForm add column templateId int not null default 1",
	"alter table DataForm_entryData drop column sequenceNumber",
	"alter table DataForm add column emailTemplateId int not null default 2",
	"alter table DataForm add column acknowlegementTemplateId int not null default 3",
	"alter table DataForm_field drop column validation"
        );
foreach my $query (@sql) {
        WebGUI::SQL->write($query);
}

WebGUI::Session::close();


