print "start of script\n";
use lib '/data/WebGUI/lib';
use WebGUI::Session;
use WebGUI::Asset::Sku::Ad ;
sub install {
    print "inside install function\n";
    my $confg = $ARGV[0];
    my $home = $ARGV[1] || "/data/WebGUI";
    my $className = "WebGUI::Asset::SKu::Ad";
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
	<tmpl_if error_msg>
	<div class="error"><tmpl_var error_msg></div>
	</tmpl_if>
	<h3><tmpl_var adsku_title></h3>
	<h4>TODO:Manage my ads link</h4>
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
	<td><tmpl_var form_clicks> @ <tmpl_var clicks_price> per click</td>
	<td><tmpl_var click_discount></td>
	</tr>
	<tr>
	<td>number of impressions</td>
	<td><tmpl_var form_impressions> @ <tmpl_var clicks_price> per impression</td>
	<td><tmpl_var impression_discount></td>
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
	<h3>Manage My Ads</h3>
	<h4>TODO:Buy Ad Space link</h4>
	<br /><br />
	<table border="0" cellpadding="3" cellspacing="0">
	    <tbody>
		<tr>Title<th>
		<tr>Clicks<th>
		<tr>impressions<th>
		<tr>renew<th>
	    </th>
	    <loop my_ads>
		</tr>
		    <td><tmpl_var loop.title></td>
		    <td><tmpl_var loop.clicks></td>
		    <td><tmpl_var loop.impressions></td>
		    <td><tmpl_var loop.renew></td>
		</tr>
	    </loop>
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
