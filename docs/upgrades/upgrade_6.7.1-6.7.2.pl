use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;

my $toVersion = "6.7.2";
my $configFile;
my $quiet;

start();

fixTimeFields();
fixSpelling();
fixCSTemplate();
speedUpAdminConsole();
removeOldFiles();
updatePageTemplates();
fixSurveyTemplate();

finish();

#-------------------------------------------------
sub fixSurveyTemplate {
        print "\tFixing survey template.\n" unless ($quiet);
	my $template = <<END;
<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>	
		<tmpl_if displayTitle>
    <h1><tmpl_var title></h1>
</tmpl_if>


<tmpl_if description>
  <tmpl_var description><p />
</tmpl_if>


<tmpl_if user.canTakeSurvey>
	<tmpl_if response.isComplete>
		<tmpl_if mode.isSurvey>
			<tmpl_var thanks.survey.label>
		<tmpl_else>
			<tmpl_var thanks.quiz.label>
			<div align="center">
				<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.total>
				<br />
				<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% 
			</div>
		</tmpl_if>
		<tmpl_if user.canRespondAgain>
			<br /> <br /> <a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	<tmpl_else>
		<tmpl_if response.id>
			<tmpl_var form.header>
			<table width="100%" cellpadding="3" cellspacing="0" border="0" class="content">
				<tr>
					<td valign="top">
					<tmpl_loop question_loop>
						<p><tmpl_var question.question></p>
						<tmpl_var question.answer.label><br />
						<tmpl_var question.answer.field><br />
						<br />
						<tmpl_if question.allowComment>
							<tmpl_var question.comment.label><br />
							<tmpl_var question.comment.field><br />
						</tmpl_if>
					</tmpl_loop>
					</td>
					<td valign="top" nowrap="1">
						<b><tmpl_var questions.sofar.label>:</b> <tmpl_var questions.sofar.count> / <tmpl_var questions.total> <br />
						<tmpl_unless mode.isSurvey>
							<b><tmpl_var questions.correct.count.label>:</b> <tmpl_var questions.correct.count> / <tmpl_var questions.sofar.count><br />
							<b><tmpl_var questions.correct.percent.label>:</b><tmpl_var questions.correct.percent>% / 100%<br />
						</tmpl_unless>
					</td>
				</tr>
			</table>
			<div align="center"><tmpl_var form.submit></div>
			<tmpl_var form.footer>
		<tmpl_else>
			<a href="<tmpl_var start.newResponse.url>"><tmpl_var start.newResponse.label></a>
		</tmpl_if>
	</tmpl_if>
<tmpl_else>
	<tmpl_if mode.isSurvey>
		<tmpl_var survey.noprivs.label>
	<tmpl_else>
		<tmpl_var quiz.noprivs.label>
	</tmpl_if>
</tmpl_if>
<br />
<br />
<tmpl_if user.canViewReports>
	<a href="<tmpl_var report.gradebook.url>"><tmpl_var report.gradebook.label></a> 
	&bull;
	<a href="<tmpl_var report.overview.url>"><tmpl_var report.overview.label></a> 
	&bull;
	<a href="<tmpl_var delete.all.responses.url>"><tmpl_var delete.all.responses.label></a> 
	<br />
	<a href="<tmpl_var export.answers.url>"><tmpl_var export.answers.label></a> 
	&bull;
	<a href="<tmpl_var export.questions.url>"><tmpl_var export.questions.label></a> 
	&bull;
	<a href="<tmpl_var export.responses.url>"><tmpl_var export.responses.label></a> 
	&bull;
	<a href="<tmpl_var export.composite.url>"><tmpl_var export.composite.label></a> 
</tmpl_if>


<tmpl_if session.var.adminOn>
	<p>
		<a href="<tmpl_var section.add.url>"><tmpl_var section.add.label></a>
	</p>

	<p>
		<a href="<tmpl_var question.add.url>"><tmpl_var question.add.label></a>
	</p>
<tmpl_loop section.edit_loop>
<tmpl_var section.edit.controls>
<tmpl_var section.edit.sectionName><br /><br />
	<tmpl_loop section.questions_loop>
		&nbsp;&nbsp;<tmpl_var question.edit.controls>
          	<tmpl_var question.edit.question>
		<br />
        </tmpl_loop>
</tmpl_loop>
</tmpl_if>
END
	WebGUI::Asset->new("PBtmpl0000000000000061","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub updatePageTemplates {
        print "\tMaking page templates float better in IE.\n" unless ($quiet);
	# news
	my $template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<!-- begin position 1 -->
<div>
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

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 2 -->
<div style="width: 49%; float: left;">
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
</div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div style="width: 49%; float: left;">
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
</div>
<!-- end position 3 -->
</div>

<div style="clear: both;">&nbsp;</div>


<!-- begin position 4 -->
<div>
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

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 1 -->
<div style="width: 49%; float: left;">
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

<!-- begin position 2 -->
<div style="width: 49%; float: left;">
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
</div>
<!-- end position 2 -->
</div>

<div style="clear: both;">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000135","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# left column
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 1 -->
<div style="width: 33%; float: left;">
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

<!-- begin position 2 -->
<div style="width: 65%; float: left;">
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
</div>
<!-- end position 2 -->
</div>

<div style="clear: both;">&nbsp;</div>

<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000125","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# right column
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 1 -->
<div style="width: 65%; float: left;">
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

<!-- begin position 2 -->
<div style="width: 33%; float: left;">
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
</div>
<!-- end position 2 -->
</div>

<div style="clear: both;">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000131","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# one over three
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<!-- begin position 1 -->
<div>
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

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 2 -->
<div style="width: 32%; float: left;">
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
</div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div style="width: 33%; float: left;">
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
</div>
<!-- end position 3 -->


<!-- begin position 4 -->
<div style="width: 32%; float: left;">
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

</div>

<div style="clear: both;">&nbsp;</div>


<tmpl_if showAdmin> 
	<table><tr id="blank" class="hidden"><td><div><div class="empty">&nbsp;</div></div></td></tr></table>
            <tmpl_var dragger.init>
</tmpl_if>
		
END
	WebGUI::Asset->new("PBtmpl0000000000000109","WebGUI::Asset::Template")->addRevision({template=>$template})->commit;

	# three over one
	$template = <<END;
<a href="<tmpl_var assetId>"></a>

<tmpl_if displayTitle>
  <h1><tmpl_var title></h1>
</tmpl_if>

<tmpl_if description>
  <p><tmpl_var description></p>
</tmpl_if>

<tmpl_if showAdmin>
<p><tmpl_var controls></p>
</tmpl_if>

<div style="clear: both;">&nbsp;</div>

<div>
<!-- begin position 1 -->
<div style="width: 32%; float: left;">
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


<!-- begin position 2 -->
<div style="width: 33%; float: left;">
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
</div>
<!-- end position 2 -->

<!-- begin position 3 -->
<div style="width: 32%; float: left;">
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
</div>
<!-- end position 3 -->

</div>

<div style="clear: both;">&nbsp;</div>

<!-- begin position 4 -->
<div>
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
}

#-------------------------------------------------
sub removeOldFiles {
        print "\tRemoving files that are no longer needed.\n" unless ($quiet);
	unlink("../../lib/WebGUI/Search.pm");
}

#-------------------------------------------------
sub speedUpAdminConsole {
        print "\tMaking admin console load faster.\n" unless ($quiet);
	my $template = <<END;
^StyleSheet(^Extras;/adminConsole/adminConsole.css);
^JavaScript(^Extras;/adminConsole/adminConsole.js);

<div id="application_title">
       <tmpl_var application.title>
</div>
<div id="application_workarea">
       <tmpl_var application.workArea>
</div>
<div id="console_workarea">
        <div class="adminConsoleSpacer">
            &nbsp;
        </div>
        <tmpl_loop application_loop>
                <tmpl_if canUse>
                     <div class="adminConsoleApplication">
                           <a href="<tmpl_var url>"><img src="<tmpl_var icon>" border="0" title="<tmpl_var title>" alt="<tmpl_var title>" /></a><br />
                           <a href="<tmpl_var url>"><tmpl_var title></a>
                     </div>
               </tmpl_if>
       </tmpl_loop>
        <div class="adminConsoleSpacer">
            &nbsp;
        </div>
</div>
<div class="adminConsoleMenu">
        <div id="adminConsoleMainMenu" class="adminConsoleMainMenu">
                <div id="console_toggle_on">
                        <a href="#" onClick="toggleAdminConsole()"><tmpl_var toggle.on.label></a><br />
                </div>
                <div id="console_toggle_off">
                        <a href="#" onClick="toggleAdminConsole()"><tmpl_var toggle.off.label></a><br />
                </div>
        </div>
        <div id="adminConsoleApplicationSubmenu"  class="adminConsoleApplicationSubmenu">
              <tmpl_loop submenu_loop>
                        <a href="<tmpl_var url>" <tmpl_var extras>><tmpl_var label></a><br />
              </tmpl_loop>
        </div>
        <div id="adminConsoleUtilityMenu" class="adminConsoleUtilityMenu">
                <a href="<tmpl_var backtosite.url>"><tmpl_var backtosite.label></a><br />
                ^AdminToggle;<br />
                ^LoginToggle;<br />
        </div>
</div>
<div id="console_title">
       <tmpl_var console.title>
</div>
<div id="application_help">
  <tmpl_if help.url>
    <a href="<tmpl_var help.url>" target="_blank"><img src="^Extras;/adminConsole/small/help.gif" alt="?" border="0" /></a>
  </tmpl_if>
</div>
<div id="application_icon">
    <img src="<tmpl_var application.icon>" border="0" title="<tmpl_var application.title>" alt="<tmpl_var application.title>" />
</div>
<div class="adminConsoleTitleIconMedalian">
<img src="^Extras;/adminConsole/medalian.gif" border="0" alt="*" />
</div>
<div id="console_icon">
     <img src="<tmpl_var console.icon>" border="0" title="<tmpl_var console.title>" alt="<tmpl_var console.title>" />
</div>
<script type="text/javascript">
  initAdminConsole(<tmpl_if application.title>true<tmpl_else>false</tmpl_if>,<tmpl_if submenu_loop>true<tmpl_else>false</tmpl_if>);
</script>

END
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000001","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub fixTimeFields {
        print "\tFixing time fields.\n" unless ($quiet);
	WebGUI::SQL->write("update DataForm_field set type=".quote('TimeField')." where type=".quote('time'));
	WebGUI::SQL->write("update userProfileField set dataType=".quote('TimeField')." where dataType=".quote('time'));
}

#-------------------------------------------------
sub fixCSTemplate {
        print "\tFixing CS Search template.\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmpl0000000000000031","WebGUI::Asset::Template");
	my $template = $asset->get("template");
	$template =~ s/<tmpl_var date>/<tmpl_var dateSubmitted.human>/ixsg;
	$template =~ s/<tmpl_var time>/<tmpl_var timeSubmitted.human>/ixsg;
	$asset->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub fixSpelling {
        print "\tFixing a few spelling problems.\n" unless ($quiet);
	my $asset = WebGUI::Asset->new("PBtmplCP00000000000001","WebGUI::Asset::Template");
	$asset->addRevision({url=>"default_product_template"})->commit;
	$asset = WebGUI::Asset->new("PBtmpl0000000000000134","WebGUI::Asset::Template");
	my $template = $asset->get("template");
	$template =~ s/spesify/specify/ixsg;
	$asset->addRevision({template=>$template})->commit;
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

