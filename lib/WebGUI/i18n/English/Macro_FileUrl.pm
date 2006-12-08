package WebGUI::i18n::English::Macro_FileUrl;

our $I18N = {

    'macroName' => {
        message => q|File Url|,
        lastUpdated => 1128838332,
    },

    'file url title' => {
        message => q|File Url Macro|,
        lastUpdated => 1112315917,
    },

    'file url body' => {
        message => q|
<p><b>&#94;FileUrl</b>();<br />
<b>&#94;FileUrl</b>(<i>Asset URL</i>);<br />
This macro is used to return a filesystem URL to an Asset which stores a single file (File, Image, ZipArchive, etc.) identified by its Asset URL.  The Macro will <i>not</i> work on Assets which store multiple files, such as the Post or Article Assets.</p>
        |,
        lastUpdated => 1165599338,
    },

    'invalid url' => {
        message => q|Invalid Asset URL|,
        lastUpdated => 1134855446,
    },

    'no storage' => {
        message => q|The Asset you requested does not store files.|,
        lastUpdated => 1153498370,
    },

    'no filename' => {
        message => q|The Asset you requested does not have a filename property.|,
        lastUpdated => 1153618016,
    },

};

1;
