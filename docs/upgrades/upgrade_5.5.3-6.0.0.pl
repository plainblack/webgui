#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Session;
use WebGUI::SQL;

my $configFile;
my $quiet;
GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);
WebGUI::Session::open("../..",$configFile);


#--------------------------------------------
print "\tMigrating styles.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from style");
while (my $style = $sth->hashRef) {
	my ($header,$footer) = split(/\^\-\;/,$style->{body});
	my ($newStyleId) = WebGUI::SQL->quickArray("select max(templateId) from template where namespace='style'");
       	if ($style->{styleId} > 0 && $style->{styleId} < 25) {
		$newStyleId = $style->{styleId};
	} elsif ($newStyleId > 999) {
       		$newStyleId++;
     	} else {
     		$newStyleId = 1000;
	}
	my $newStyle = $session{setting}{docTypeDec}.'
		<html>
		<head>
			<title><tmpl_var session.page.title> - <tmpl_var session.setting.companyName></title>
			<tmpl_var head.tags>
		'.$style->{styleSheet}.'
		</head>
		'.$header.'
			<tmpl_var body.content>
		'.$footer.'
		</html>
		';
	WebGUI::SQL->write("insert into template (templateId, name, template, namespace) values (".$newStyleId.",
		".quote($style->{name}).", ".quote($newStyle).", 'style')");
	WebGUI::SQL->write("update page set styleId=".$newStyleId." where styleId=".$style->{styleId});
	WebGUI::SQL->write("update themeComponent set id=".$newStyleId.", type='template' where id=".$style->{styleId}." and type='style'");
}
$sth->finish;
WebGUI::SQL->write("delete from incrementer where incrementerId='styleId'");
WebGUI::SQL->write("delete from settings where name='docTypeDec'");
WebGUI::SQL->write("drop table style");


#--------------------------------------------
print "\tMigrating page templates.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace='Page'");
while (my $template = $sth->hashRef) {
	#eliminate the need for compatibility with old-style page templates
	$template->{template} =~ s/\^(\d+)\;/_positionFormat5x($1)/eg; 
	$template->{template} = '
		<tmpl_if session.var.adminOn>
		<style>
			div.wobject:hover {
				border: 1px outset #cccccc;
			}
		</style>
		</tmpl_if>
		<tmpl_if session.var.adminOn> <tmpl_if page.canEdit>
			<tmpl_var page.toolbar>
		</tmpl_if> </tmpl_if>
		'.$template->{template};
	$template->{template} =~ s/\<tmpl_var page\.position(\d+)\>/_positionFormat6x($1)/eg; 
	WebGUI::SQL->write("update template set namespace='page', template=".quote($template->{template})
		." where templateId=".$template->{templateId}." and namespace='Page'");
}
$sth->finish;

#--------------------------------------------
#print "\tUpdating config file.\n" unless ($quiet);
#my $pathToConfig = '../../etc/'.$configFile;
#my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
#my $wobjects = $conf->get("wobjects");
#$conf->set("wobjects"=>$wobjects);
#$conf->write;



#--------------------------------------------
print "\tRemoving unneeded files.\n" unless ($quiet);
unlink("../../lib/WebGUI/Operation/Style.pm");
#unlink("../../lib/WebGUI/Wobject/LinkList.pm");
#unlink("../../lib/WebGUI/Wobject/FAQ.pm");




WebGUI::Session::close();


#-------------------------------------------------------------------
sub _positionFormat5x {
        return "<tmpl_var page.position".($_[0]+1).">";
}

#-------------------------------------------------------------------
sub _positionFormat6x {
	my $newPositionCode = '	
		<tmpl_loop position'.$_[0].'_loop>
			<tmpl_if wobject.canView> 
				<div class="wobject"> <div class="wobject<tmpl_var wobject.namespace>" id="wobjectId<tmpl_var wobject.id>">
				<tmpl_if session.var.adminOn> <tmpl_if wobject.canEdit>
					<tmpl_var wobject.toolbar>
				</tmpl_if> </tmpl_if>
				<tmpl_if wobject.isInDateRange>
                      			<a name="<tmpl_var wobject.id>"></a>
					<tmpl_var wobject.content>
				</tmpl_if wobject.isInDateRange> 
				</div> </div>
			</tmpl_if>
		</tmpl_loop>
	';
	return $newPositionCode;
}


