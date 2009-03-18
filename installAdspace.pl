print "start of script\n";
use lib '/data/WebGUI/lib';
use WebGUI::Session;
use WebGUI::Asset::Sku::Ad ;
sub install {
    print "inside install function\n";
    my $confg = $ARGV[0];
    my $home = $ARGV[1] || "/data/WebGUI";
    my $className = "WebGUI::Asset::Sku::Ad";
    unless ($home && $confg) {
	die "usage: Perl -M$className -e install yoursite.conf\n";
    }
    print "Installing asset.\n";
    my $session = WebGUI::Session->open($home, $confg);
    print "Add wobject to confg fle\n";
    $session->config->addToHash("assets",$className => { category => 'shop' } );
     print "Create database tables\n";
    $session->db->write("CREATE TABLE AdSku (
	assetId VARCHAR(22) BINARY NOT NULL,
	revisionDate BIGINT NOT NULL,
	purchaseTemplate VARCHAR(22) BINARY NOT NULL,
	manageTemplate VARCHAR(22) BINARY NOT NULL,
	adSpace VARCHAR(22) BINARY NOT NULL,
	priority INTEGER DEFAULT '1',
	pricePerClick Float DEFAULT '0',
	pricePerImpression Float DEFAULT '0',
	clickDiscounts VARCHAR(1024) default '',
	impressionDiscounts VARCHAR(1024) default '',
	PRIMARY KEY (assetId,revisionDate)
    )");
    print "Create a folder asset to store the default templates\n";
    my $importNode = WebGUI::Asset->getImportNode($session);
    my $newFolder = $importNode->addChild({
	className => "WebGUI::Asset::Wobject::Folder",
	title => "AdSku",
	menuTitle => "AdSku",
	url => "ad_sku_folder",
	groupIdView => "3"
    },"AdSkuFolder001");
		    #Create the templates
    print "create purchase Ad Template\n";
    my $purchaseAdTmpl = q|
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>
	<tmpl_if error_msg>
	<div class="error"><tmpl_var error_msg></div>
	</tmpl_if>
	<h3><tmpl_var adsku_title></h3>
	<h4><a href='<tmpl_var manageLink>'>^International("form manage link","Asset_AdSku");</a></h4>
	<tmpl_var adsku_description>
	<tmpl_var form_header>
	<tmpl_var form_hidden>
	<table border="0" cellpadding="3" cellspacing="0">
	<tbody>
	<tr>
	<td>Ad Title</td>
	<td><tmpl_var form_title></td>
	</tr>
	<tr>
	<td>Ad Link</td>
	<td><tmpl_var form_link></td>
	</tr>
	<tr>
	<td>Image</td>
	<td><tmpl_var form_image></td>
	</tr>
	<tr>
	<td>number of clicks</td>
	<td><tmpl_var form_clicks> ^International("per click","Asset_AdSku", <tmpl_var click_price> );
	<br>^International("click discount","Asset_AdSku",<tmpl_var click_discount>);</td>
	</tr>
	<tr>
	<td>number of impressions</td>
	<td><tmpl_var form_impressions> ^International("per impression","Asset_AdSku", <tmpl_var impression_price> );
	<br>^International("impression discount","Asset_AdSku",<tmpl_var impression_discount>);</td>
	</tr>
	<tr>
	<td colspan="2" align="right"><tmpl_var form_submit></td>
	</tr>
	</tbody>
	</table>
	<tmpl_var form_footer>
	|;
    print "Manage Ads Template\n";
    my $manageAdTmpl = q|
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>
	<tmpl_if error_msg>
	<div class="error"><tmpl_var error_msg></div>
	</tmpl_if>
	<h3>^International("form manage title","Asset_AdSku");</h3>
	<h4><a href='<tmpl_var purchaseLink>'>^International("form purchase link","Asset_AdSku");</a></h4>
	<br /><br />
	<table border="0" cellpadding="3" cellspacing="0">
	    <tbody> <tr>
                <th>^International("manage form table header title","Asset_AdSku");</th>
		<th>^International("manage form table header clicks","Asset_AdSku");</th>
		<th>^International("manage form table header impressions","Asset_AdSku");</th>
		<th>^International("manage form table header renew","Asset_AdSku");</th>
	    </tr>
	    <tmpl_loop myAds>
		</tr>
		    <td><tmpl_var rowTitle></td>
		    <td><tmpl_var rowClicks></td>
		    <td><tmpl_var rowImpressions></td>
		    <td><tmpl_if rowDeleted>
                        ^International("manage form table value deleted","Asset_AdSku");
                    <tmpl_else>
                        <a href="rowRenewLink">^International("manage form table value renew","Asset_AdSku");</a>
                    </tmpl_if></td>
		</tr>
	    </tmpl_loop>
	</tbody>
	</table>
	|;
    print "Add the templates to the folder\n";
    $newFolder->addChild({
	className=>"WebGUI::Asset::Template",
	ownerUserId=>'3',
	groupIdView=>'7',
	groupIdEdit=>'12',
	title=>"Default Purchase Ad Sku Template",
	menuTitle=>"Default Purchase Ad Sku Template",
	url=>"default_purchase_adsku_template",
	namespace=>"AdSku/purchase",
	template=>$purchaseAdTmpl,
    },'AdSku000000001');
    $newFolder->addChild({
	className=>"WebGUI::Asset::Template",
	ownerUserId=>'3',
	groupIdView=>'7',
	groupIdEdit=>'12',
	title=>"Default Manage AdSku Template",
	menuTitle=>"Default Manage AdSku Template",
	url=>"default_manage_adsku_template",
	namespace=>"AdSku/manage",
	template=>$manageAdTmpl,
    },'AdSku000000002');
    print "Commit the working version tag\n";
    my $workingTag = WebGUI::VersionTag->getWorking($session);
    my $workingTagId = $workingTag->getId;
    my $tag = WebGUI::VersionTag->new($session,$workingTagId);
    if (defined $tag) {
	print "Committing tag\n";
	$tag->set({comments=>"Folder created by Asset Install Process"});
	$tag->requestCommit;
    }
    $session->var->end;
    $session->close;
    print "Done. Please restart Apache.\n";
}
print "end of function\n";
install();
print "end of script\n";
