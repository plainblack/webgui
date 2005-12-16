#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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

my $toVersion = "6.8.3"; # make this match what version you're going to
my $quiet; # this line required


start(); # this line required

fixMatrixTemplate();

finish(); # this line required


#-------------------------------------------------
sub fixMatrixTemplate {
	print "\tFix matrix template.\n" unless ($quiet);
my $template = <<STOP;
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>
<h2><tmpl_var title></h2>

<tmpl_if description>
  <tmpl_var description><br /><br />
</tmpl_if>

<table class="content" width="100%">
<tr><td valign="top" width="50%">
<p>Use the form below to select up to <tmpl_var maxCompares> listings to compare at once.
</p>
<tmpl_var compare.form>

</td><td valign="top">


<p>
<b>Narrow The Matrix</b><br>
You can narrow the scope of the matrix by <a href="<tmpl_var search.url>">searching</a> for exactly the criteria you're looking for in a listing.
</p>


<p>
<br><b>Expand The Matrix</b><br>
<tmpl_if isLoggedIn>
   <a href="<tmpl_var listing.add.url>">Click here to add a new listing.</a> Please note that you will be the official maintainer of the listing, and will be responsible for keeping it up to date.
<tmpl_else>
If you are the maker of a product, or are an expert user and are willing to maintain the listing, <a href="^a(linkonly);">create an account</a> so you can register your listing.
</tmpl_if>

</p>



<br><b>Listing Statistics</b><br>
<table class="content">
<tr>
  <td>Most clicks:</td>
  <td><tmpl_var best.clicks.count></td>
  <td><a href="<tmpl_var best.clicks.url>"><tmpl_var best.clicks.name></a></td>
</tr>
<tr>
  <td>Most views:</td>
  <td><tmpl_var best.views.count></td>
  <td><a href="<tmpl_var best.views.url>"><tmpl_var best.views.name></a></td>
</tr>
<tr>
  <td>Most compares:</td>
  <td><tmpl_var best.compares.count></td>
  <td><a href="<tmpl_var best.compares.url>"><tmpl_var best.compares.name></a></td>
</tr>
<tr>
  <td>Most recently updated:</td>
  <td><tmpl_var best.updated.date></td>
  <td><a href="<tmpl_var best.updated.url>"><tmpl_var best.updated.name></a></td>
</tr>
<tr>
  <td colspan="3"><hr size="1"></td>
</tr>
<tr>
  <td align="center" colspan="3">Best Rated By Users</td>
</tr>
<tmpl_loop best_rating_loop>
<tr>
  <td><tmpl_var category></td>
  <td><tmpl_var mean>/10</td>
  <td><a href="<tmpl_var url>"><tmpl_var name></a></td>
</tr>
</tmpl_loop>


<tr>
  <td colspan="3"><hr size="1"></td>
</tr>
<tr>
  <td colspan="3" align="center"><a href="<tmpl_var ratings.details.url>">View Ratings Details</a></td>
</tr>
<tr>
  <td colspan="3"><hr size="1"></td>
</tr>


<tr>
  <td align="center" colspan="3">Worst Rated By Users</td>
</tr>
<tmpl_loop worst_rating_loop>
<tr>
  <td><tmpl_var category></td>
  <td><tmpl_var mean>/10</td>
  <td><a href="<tmpl_var url>"><tmpl_var name></a></td>
</tr>
</tmpl_loop>

<tr>
  <td colspan="3"><hr size="1"></td>
</tr>

</table>

<br>
<br><b>Site Statistics</b><br>
<table class="content">
<tr>
  <td>Listing Count:</td>
  <td><tmpl_var listing.count></td>
</tr>
<tr>
  <td>Current Visitors:</td>
  <td><tmpl_var current.user.count></td>
</tr>
<tr>
  <td>Registered Users:</td>
  <td><tmpl_var user.count></td>
</tr>
</table>




<tmpl_if session.var.adminOn>
<p>   <a href="<tmpl_var field.list.url>">List Fields</a> 
</p>
<tmpl_if pending_list>
<b>PENDING LISTINGS:</b>
</tmpl_if>
<ul>
<tmpl_loop pending_list>
<li><a href="<tmpl_var url>"><tmpl_var productName></a></li>
</tmpl_loop>
</ul>
</tmpl_if>

</td></tr></table>
STOP
	my $asset = WebGUI::Asset->new("matrixtmpl000000000001","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template})->commit if (defined $template);
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

