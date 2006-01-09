#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use Parse::PlainConfig;

my $toVersion = "6.8.4"; # make this match what version you're going to
my $quiet; # this line required

start(); # this line required

fixDefaultThreadTemplate();
enableAvatarProfileField();
updateDataFormEmailFields();

finish(); # this line required


#-------------------------------------------------
sub fixDefaultThreadTemplate {
	print "\Enable Avatars in the default Thread template.\n" unless ($quiet);
my $template = <<EOT1;
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a> 

<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>

<style type="text/css">
	.postBorder {
		border: 1px solid #cccccc;
		margin-bottom: 10px;
	}
 	.postBorderCurrent {
		border: 3px dotted black;
		margin-bottom: 10px;
	}
	.postSubject {
		border-bottom: 1px solid #cccccc;
		font-weight: bold;
		padding: 3px;
	}
	.postData {
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postControls {
		border-top: 1px solid #cccccc;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postMessage {
		padding: 3px;
	}
	.currentThread {
		background-color: #eeeeee;
	}
	.threadHead {
		font-weight: bold;
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.threadData {
		font-size: 11px;
		padding: 3px;
	}
</style>
	
<div style="float: left; width: 70%">
	<h1><a href="<tmpl_var collaboration.url>"><tmpl_var collaboration.title></a></h1>
</div>
<div style="width: 30%; float: left; text-align: right;">
	<tmpl_if layout.isFlat>
		<a href="<tmpl_var layout.nested.url>"><tmpl_var layout.nested.label></a>
	<tmpl_else>
		<a href="<tmpl_var layout.flat.url>"><tmpl_var layout.flat.label></a>
	</tmpl_if>
</div>
<div style="clear: both;"></div>

<tmpl_if layout.isFlat>
<!-- begin flat layout -->
	<tmpl_loop post_loop>
		<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
			<a name="<tmpl_var assetId>"></a>
			<div class="postSubject">
				<tmpl_var title>
			</div>
			<div class="postData">
				<div style="float: left; width: 50%">
					<b><tmpl_var user.label>:</b> 
						<tmpl_if user.isVisitor>
							<tmpl_var username><tmpl_if avatar.url><img src="<tmpl_var avatar.url>" /></tmpl_if>
						<tmpl_else>
							<a href="<tmpl_var userProfile.url>"><tmpl_var username><tmpl_if avatar.url><img src="<tmpl_var avatar.url>" border="0" alt="avatar" /></tmpl_if></a>
						</tmpl_if>
						<br />
					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
				</div>	
				<div>
					<b><tmpl_var views.label>:</b> <tmpl_var views><br />
					<b><tmpl_var rating.label>:</b> <tmpl_var rating>
						<tmpl_unless hasRated>
							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
						</tmpl_unless>
						<br />
					<tmpl_if user.isModerator>
						<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
					<tmpl_else>	
						<tmpl_if user.isPoster>
							<b><tmpl_var status.label>:</b> <tmpl_var status><br />
						</tmpl_if>	
					</tmpl_if>	
				</div>	
			</div>
			<div class="postMessage">
				<tmpl_var content>
<tmpl_loop attachment_loop>
	<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
</tmpl_loop>
<div style="clear: both;"></div>

			</div>
			<tmpl_unless isLocked>
				<div class="postControls">
					<tmpl_if user.canReply>
						<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
					</tmpl_if>
					<tmpl_if user.canEdit>
						<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
						<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
					</tmpl_if>
				</div>
			</tmpl_unless>
		</div>
	</tmpl_loop>
<!-- end flat layout -->
</tmpl_if>

<tmpl_if layout.isNested>
<!-- begin nested layout -->
	<tmpl_loop post_loop>
		<div style="margin-left: <tmpl_var depthX10>px;">
			<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
				<a name="<tmpl_var assetId>"></a>
				<div class="postSubject">
					<tmpl_var title>
				</div>
				<div class="postData">
					<div style="float: left; width: 50%">
						<b><tmpl_var user.label>:</b> 
							<tmpl_if user.isVisitor>
								<tmpl_var username><tmpl_if avatar.url><img src="<tmpl_var avatar.url>" /></tmpl_if>
							<tmpl_else>
								<a href="<tmpl_var userProfile.url>"><tmpl_var username><tmpl_if avatar.url><img src="<tmpl_var avatar.url>" border="0" alt="avatar" /></tmpl_if></a>
							</tmpl_if>
							<br />
						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
					</div>	
					<div>
						<b><tmpl_var views.label>:</b> <tmpl_var views><br />
						<b><tmpl_var rating.label>:</b> <tmpl_var rating>
							<tmpl_unless hasRated>
								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
							</tmpl_unless>
							<br />
						<tmpl_if user.isModerator>
							<b><tmpl_var status.label>:</b> <tmpl_var status> &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
						<tmpl_else>	
							<tmpl_if user.isPoster>
								<b><tmpl_var status.label>:</b> <tmpl_var status><br />
							</tmpl_if>	
						</tmpl_if>	
					</div>	
				</div>
				<div class="postMessage">
					<tmpl_var content>
<tmpl_loop attachment_loop>
	<div style="float: left; padding: 5px;"><a href="<tmpl_var url>"><tmpl_if isImage><img src="<tmpl_var thumbnail>" border="0" alt="<tmpl_var filename>" /><tmpl_else><img src="<tmpl_var icon>" border="0" alt="<tmpl_var filename>" align="middle" /> <tmpl_var filename></tmpl_if></a></div>
</tmpl_loop>
<div style="clear: both;"></div>

				</div>
				<tmpl_unless isLocked>
					<div class="postControls">
						<tmpl_if user.canReply>
							<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
						</tmpl_if>
						<tmpl_if user.canEdit>
							<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
							<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
						</tmpl_if>
					</div>
				</tmpl_unless>
			</div>
		</div>
	</tmpl_loop>
<!-- end nested layout -->
</tmpl_if>

<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination" style="margin-top: 20px;">
		[ <tmpl_var pagination.previousPage> | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
	</div>
</tmpl_if>

<div style="margin-top: 20px;">
	<tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
	<tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>
EOT1

	my $asset = WebGUI::Asset->new("PBtmpl0000000000000032","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit;
}


#-------------------------------------------------
sub enableAvatarProfileField {
	print "\tMake user profile Avatar field visible and editable.\n" unless ($quiet);
	WebGUI::SQL->write("update userProfileField set visible=1 where fieldName='avatar'");
	WebGUI::SQL->write("update userProfileField set editable=1 where fieldName='avatar'");
}

#-------------------------------------------------
sub updateDataFormEmailFields {
	print "\tFix default email tabId's.\n" unless ($quiet);
	WebGUI::SQL->write("alter table DataForm_field alter DataForm_tabId set default 0;");
	my $sth = WebGUI::SQL->read('select DataForm_fieldId,DataForm_tabId from DataForm_field');
	my $wrh = WebGUI::SQL->prepare('update DataForm_field set DataForm_tabId=0 where DataForm_fieldId=?');
	while (my %hash = $sth->hash) {
		$wrh->execute([$hash{DataForm_fieldId}]) unless $hash{DataForm_tabId};
	}
}


# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
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

