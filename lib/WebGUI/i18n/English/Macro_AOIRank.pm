package WebGUI::i18n::English::Macro_AOIRank;

our $I18N = {

    'macroName' => {
        message => q|AOI Rank|,
        lastUpdated => 1128837912,
    },

    'aoi rank title' => {
        message => q|Areas of Interest Rank Macro|,
        lastUpdated => 1165355407,
    },

	'aoi rank body' => {
		message => q|
<p>
<b>&#94;AOIRank(<i>metadata property</i>, [<i>rank</i>]);</b><br />
This macro is for displaying which Assets are the most frequently viewed on your site, based on 
Metadata and Passive Profiling.  To use the macro, you will need to enable Passive Profiling in the 
WebGUI Settings admin screen, and then add Metadata to the Assets in your site.</p>

<p>Here's an example:</p>

<p>Suppose you run a news site, and you want to know what kinds of news stories are the
most popular.  You enable Passive Profiling in the WebGUI Settings, then create a new Metadata
field called "contentType".  As your content managers add stories to the site, they also classify
the stories by giving the Metadata field contentType a value, such as "Sports", "General Interest",
"Regional", "Business", "Entertainment" and so on.  Next, on a separate page of your site,
you place these &#94;AOIRank() macro calls:</p>

<p>Most popular kind of story: &#94;AOIRank(contentType);<br />
Second-most popular kind of story: &#94;AOIRank(contentType,2);<br />
Third most popular kind of story: &#94;AOIRank(contentType,3);</p>

<p>By default, &#94;AOIRank(contentType); will always display the most popular Metadata property,
which in our case is called contentType.  If you wish to see which Metadata properties are lower
ranked, pass the macro the rank that you want to see.</p>

<p>As users visit your site, each story they read will be counted up and added to the counter for
the correct contentType.  As you visit you separate page, you'll see the three most popular types
of stories.</p>
|,
		lastUpdated => 1165361640,
	},
};

1;
