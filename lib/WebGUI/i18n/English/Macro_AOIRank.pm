package WebGUI::i18n::English::Macro_AOIRank;

our $I18N = {

    'macroName' => {
        message => q|AOI Rank|,
        lastUpdated => 1128837912,
    },

    'aoi rank title' => {
        message => q|AOI Rank Macro|,
        lastUpdated => 1112466408,
    },

	'aoi rank body' => {
		message => q|

<p>
<b>&#94;AOIRank(<i>metadata property</i>, [<i>rank</i>]);</b><br>
This macro is for displaying Areas of Interest Rankings, which is based on passive profiling
of which wobjects are viewed most frequently by users, on a per user basis.  The macro
takes up to two arguments, a metadata property and the rank of the metadata value to
be returned.  If the rank is left out, it defaults to 1, the highest rank.<br>
&#94;AOIRank(contenttype); would display "sport" if the current user has looked at content tagged "contenttype = sport" the most.<br>
&#94;AOIRank(contenttype, 2); would return the second highest ranked value for contenttype.

|,
		lastUpdated => 1112560105,
	},
};

1;
