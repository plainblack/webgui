use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;

my $toVersion = "6.7.4";
my $configFile;
my $quiet;

start();

updatePageTemplates();
addDebug();
fixFutureDates();
makeQueriesFaster();
readdingIsSystem();

finish();


#-------------------------------------------------
sub readdingIsSystem {
        print "\tRe-adding the isSystem flag to the asset table.\n" unless ($quiet);
	WebGUI::SQL->write("alter table asset add column isSystem int not null default 0");
	WebGUI::SQL->write("update asset set isSystem=1 where assetId='PBasset000000000000001'");
	WebGUI::SQL->write("update asset set isSystem=1 where assetId='PBasset000000000000002'");
}


#-------------------------------------------------
sub makeQueriesFaster {
        print "\tMaking queries a little faster.\n" unless ($quiet);
	WebGUI::SQL->write("alter table assetData add index assetId_url (assetId,url)");
	WebGUI::SQL->write("alter table assetData add index assetId_revisionDate_status_tagId (assetId,revisionDate,status,tagId)");
	WebGUI::SQL->write("alter table asset add index className_assetId_state (className,assetId,state)");
}

#-------------------------------------------------
sub fixFutureDates {
        print "\tFixing end dates which appear too far in the future.\n" unless ($quiet);
	WebGUI::SQL->write("update assetData set endDate = 32472169200 where  endDate > 32472169200");
}

#-------------------------------------------------
sub addDebug {
        print "\tAdding more debug options.\n" unless ($quiet);
	WebGUI::Setting::add("debugIp","");
	WebGUI::Setting::add("showPerformanceIndicators","0");
}

#-------------------------------------------------
sub updatePageTemplates {
        print "\tMaking page templates float better in IE.\n" unless ($quiet);
	# news
	my $template = <<END;
<a href="<tmpl_var assetId>"></a>
<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 50%;
}
.secondColumn {
	float: left; 
	width: auto; 
	max-width: 50%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>
<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div>

<!-- end position 1 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 2 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div> </div>
<!-- end position 3 -->

<div class="endFloat">&nbsp;</div>


<!-- begin position 4 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div>
<!-- end position 4 -->

<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000094","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# side by side
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 50%;
}
.secondColumn {
        float: left;
        width: auto;
        max-width: 50%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>


<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000135","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# left column
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: auto;
        max-width: 65%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>


<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>

<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000125","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# right column
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 65%;
}
.secondColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->

<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<div class="endFloat">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000131","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# one over three
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: 33%;
}
.thirdColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div>
<!-- end position 1 -->

<div class="endFloat">&nbsp;</div>

<!-- begin position 2 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 3 -->


<!-- begin position 4 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 4 -->


<div class="endFloat">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000109","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# three over one
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

^RawHeadTags(<style type="text/css">
.firstColumn {
  float: left;
  width: 33%;
}
.secondColumn {
        float: left;
        width: 33%;
}
.thirdColumn {
        float: left;
        width: auto;
        max-width: 33%;
}
.endFloat {
 clear: both;
}
</style>);

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<!-- begin position 1 -->
<div class="firstColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 1 -->


<!-- begin position 2 -->
<div class="secondColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position2" class="content"><tbody>
</tmpl_if>

<tmpl_loop position2_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div class="thirdColumn"><div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position3" class="content"><tbody>
</tmpl_if>

<tmpl_loop position3_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div></div>
<!-- end position 3 -->


<div class="endFloat">&nbsp;</div>

<!-- begin position 4 -->
<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position4" class="content"><tbody>
</tmpl_if>

<tmpl_loop position4_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div>
<!-- end position 4 -->

<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000118","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# three over one
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<div class="layoutColumnPadding">
<tmpl_if showAdmin>
	<table border="0" id="position1" class="content"><tbody>
</tmpl_if>

<tmpl_loop position1_loop>
	<tmpl_if showAdmin>
            	<tr id="td<tmpl_var id>">
            		<td><div id="td<tmpl_var id>_div" class="dragable">      
	</tmpl_if>

	<div class="content"><tmpl_var dragger.icon><tmpl_var content></div>

	<tmpl_if showAdmin>
         			</div></td>
            	</tr>
	</tmpl_if>
</tmpl_loop>

<tmpl_if showAdmin> 
            </tbody></table>
</tmpl_if>
</div>
<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
END
	WebGUI::Asset->new("PBtmpl0000000000000054","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;
}





#-------------------------------------------------
sub start {
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	WebGUI::Session::open("../..",$configFile);
	WebGUI::Session::refreshUserInfo(3);
	WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

