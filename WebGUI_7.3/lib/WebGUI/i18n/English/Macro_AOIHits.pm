package WebGUI::i18n::English::Macro_AOIHits;

our $I18N = {

    'macroName' => {
        message => q|AOI Hits|,
        lastUpdated => 1128837648,
    },

    'aoi hits title' => {
        message => q|Areas of Interest Hits Macro|,
        lastUpdated => 1165355347,
    },

	'aoi hits body' => {
		message => q|
<p><b>&#94;AOIHits();</b><br />
<b>&#94;AOIHits(<i>metadata property</i>, <i>metadata value</i>);</b><br />
This macro displays to a user how many times they have visited Assets
of a given type, based on Metadata and Passive Profiling.  To use the
macro, you will need to enable Passive Profiling in the WebGUI Settings
admin screen, and then add Metadata to the Assets in your site.</p>

<p>Here's an example:</p>

<p>Suppose you run a news site, and you want to tell the user how many times they have
visited several kinds of stories.
You enable Passive Profiling in the WebGUI Settings, then create a new Metadata
field called "contentType".  As your content managers add stories to the site, they also classify
the stories by giving the Metadata field contentType a value, such as "Sports", "General Interest",
"Regional", "Business", "Entertainment" and so on.  On each page, you add
you place these &#94;AOIHits() macro calls to show the user how many times they have
visited Sports, Regional and Business stories:</p>

<p>You visited sports stories: &#94;AOIHits(contentType,Sports); times<br />
You visited sports stories: &#94;AOIHits(contentType,Regional); times<br />
You visited sports stories: &#94;AOIHits(contentType,Business); times</p>

<p>You must give &#94;AOIRank(); two arguments, the Metadata property to use and the
Metadata value whose count you want displayed to the user.</p>
<p>This Macro may be nested inside other Macros.</p>
|,
		lastUpdated => 1168558407,
	},
};

1;
