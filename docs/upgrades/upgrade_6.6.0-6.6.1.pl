#!/usr/bin/perl

use lib "../../lib";
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset::Template;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tUpdating Commerce Templates\n" unless ($quiet);
my $template = '<a href="<tmpl_var viewShoppingCart.url>"><tmpl_var viewShoppingCart.label></a> &middot;
<a href="<tmpl_var changePayment.url>"><tmpl_var changePayment.label></a> &middot; 
<a href="<tmpl_var changeShipping.url>"><tmpl_var changeShipping.label></a><br>
<br>

<tmpl_var title><br>
<ul>
<tmpl_loop errorLoop>
<li><tmpl_var message></li>
</tmpl_loop>
</ul>

<table> <tr align="left">
      <th style="border-bottom: 2px solid black">Product</th>
      <th style="border-bottom: 2px solid black">Quantity</th>
      <th style="border-bottom: 2px solid black">Price</th>
      <th style="border-bottom: 2px solid black">Each</th>
  </tr>

  <tmpl_if normalItems>
  </tmpl_if>

  <tmpl_loop normalItemsLoop>
  <tr>
      <td align="left"><tmpl_var name></td>
      <td align="center"><tmpl_var quantity></td>
      <td align="right"><tmpl_var totalPrice></td>
  </tr>
  </tmpl_loop>

  <tmpl_loop recurringItemsLoop>
  <tr>
      <td align="left"><tmpl_var name></td>
      <td align="center"><tmpl_var quantity></td>
      <td align="right"><tmpl_var totalPrice></td>
      <td align="left"><tmpl_var period></td>
  </tr>
</tmpl_loop>
  <tr style="border-top: 1px solid black">
      <td style="border-top: 1px solid black">&nbsp;</td>
      <td align="right" style="border-top: 1px solid black"><b>Subtotal</b></td>
      <td align="right" style="border-top: 1px solid black"><b><tmpl_var subtotal></b></td>
  </tr>
  <tr>
      <td colspan="2" align="right">Shipping</td>
      <td align="right"><tmpl_var shippingCost></td>
  <tr>
      <td colspan="2" align="right" style="border-top: 1px solid black"><b>Total</b></td>
      <td align="right" style="border-top: 1px solid black"><b><tmpl_var total></b></td>

</table>

<br><br>

<tmpl_var form>';
my $asset = WebGUI::Asset::Template->new("PBtmpl0000000000000016");
$asset->update({template=>$template});



WebGUI::Session::close();


