package WebGUI::i18n::English::Macro_RandomThread;

our $I18N = {

	'macroName' => {
		message => q|Random Thread|,
		lastUpdated => 1132970060,
	},

	'random thread title' => {
		message => q|Random Thread Macro|,
		lastUpdated => 1132970060,
	},

	'random thread body' => {
		message => q|<p><b>&#94;RandomThread( [ startURL, relatives, templateURL ] );</b><br />
The Collaboration System can be used for much more than just a forum. A few examples of its 
possible usages are an FAQ, photo gallery, job listings, quotes database or weblog. For these 
applications (and others that you might think of) it can be nice to display a random entry 
from such a CS somewhere on your site. That is exactly the functionality that this macro provides.</p>

<p>It displays the start post of a thread that is randomly selected from a (possibly random) CS, 
depending on the parameters. The way the selected post is displayed is controlled by a template. All
the template variables that are normally available in a CS Post template are available in this macro as well.</p>

<p><b>Parameters</b></p>
<p>Although all the parameters can be omitted, it usually makes sense to specify them all. If you
want to display a random thread from a single CS, we suggest you use the URL of the CS as the <i>startURL</i>
and &quot;self&quot; as <i>relatives</i>.</p>
<div>
<dl>
<dt><i>startURL</i></dt>
<dd>URL of the asset you want to use as the starting point for finding a random CS. If omitted 
it defaults to 'home' (i.e. the root page of most websites). Must be a valid URL within WebGUI.</dd>

<dt><i>relatives</i></dt>
<dd>Only posts from Collaboration Systems that are relatives of the start-asset in this way 
are used. Allowed values for this parameter are 'siblings', 'children', 'ancestors', 'self', 
'descendants' and 'pedigree'. Default value is descendants.</dd>

<dt><i>templateURL</i></dt>
<dd>URL of the template to use to display the random thread. Must be a valid URL within WebGUI. 
<br /><br />IMPORTANT NOTE: if omitted, a default debug template is used that outputs a list of all the 
available template variables. Since you almost certainly will not want this output in a 
production-environment, it makes sense to not omit this parameter.</dd>
</dl>
</div>

<p><b>Examples:</b></p>
<div>
<dl>
<dt><tt>&#94;RandomThread(home/photo_album, descendants, templates/randomPhoto);</tt></dt>
<dd>If you have a page with many subpages with photo galleries, you can use the parameters above
to easily retrieve a random thumbnail from all your photo albums.</dd>
<dt><tt>&#94;RandomThread(home/quotes/quotes-db, self, templates/randomQuote);</tt></dt>
<dd>If you have one CS that you use to keep a database of interesting quotes, you could use 
the above example to display a random quote on your website.</dd>
<dt><tt>&#94;RandomThread(home/faq, children, templates/faq);</tt></dt>
<dd>Suppose you have one page with a couple of Collaboration Systems (for different categories 
of questions), then the example above can be used to display a random question from any category.</dd>
<dt><tt>&#94;RandomThread;</tt></dt>
<dd>Gets a random post from all Collaboration Systems in root 'home' with debug output.</dd>
</dl>
</div>
<p>This Macro may be nested inside other Macros if the post does not contain commas or quotes.</p>
|,
		lastUpdated => 1168622915,
	},
};

1;
