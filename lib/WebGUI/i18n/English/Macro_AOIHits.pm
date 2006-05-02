package WebGUI::i18n::English::Macro_AOIHits;

our $I18N = {

    'macroName' => {
        message => q|AOI Hits|,
        lastUpdated => 1128837648,
    },

    'aoi hits title' => {
        message => q|AOI Hits Macro|,
        lastUpdated => 1112466408,
    },

	'aoi hits body' => {
		message => q|

<b>&#94;AOIHits();</b><br />
<b>&#94;AOIHits(<i>metadata property</i>, <i>metadata value</i>);</b><br />
This macro is for displaying Areas of Interest Hits, which is based on passive profiling
of which wobjects are viewed by users, on a per user basis.  The macro takes two arguments,
a metadata property and metadata value, and returns how many times the current user has
viewed content with that property and value.<p>
&#94;AOIHits(contenttype,sport); would display 99 if this user has looked at content that was tagged "contenttype = sport" 99 times.

|,
		lastUpdated => 1112567357,
	},
};

1;
