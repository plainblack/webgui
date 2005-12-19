package WebGUI::i18n::English::Macro_If;

our $I18N = {

	'macroName' => {
		message => q|If|,
		lastUpdated => 1128838656,
	},

	'eval error' => {
		message => q|<p><b>If Macro failed:</b> %s <p>Expression: %s
		<br />Display if true: %s<br />Display if false: %s|,
		lastUpdated => 1134967651,
	},

	'if title' => {
		message => q|If Macro|,
		lastUpdated => 1112466408,
	},

	'if body' => {
		message => q|
<b>&#94;If();</b><br>
A simple conditional statement (IF/THEN/ELSE) to control layout and messages.
<p>
<i>Examples:</i><br>
Display Happy New Year on 1st January:
      &#94;If('&#94;D("%m%d");' eq '0101' , Happy New Year);
<p>
Display a message to people on your subnet (192.168.1.*):<br>
&#94;If('&#94;Env("REMOTE_ADDR");' =~ /&#94;192.168.1/,"Hi co-worker","Hi Stranger");
<p>
Display a message to Windows users:<br>
      &#94;If('&#94;URLEncode("&#94;Env("HTTP_USER_AGENT");");' =~ /windows/i,"Hey... Linux is free !");
<p>
Display a message if a user is behind a proxy:<br>
      &#94;If('&#94;Env("HTTP_VIA");' ne "", You're behind a proxy !, Proxy-free is the best...);
<p>
Display Good Morning/Afternoon/Evening:<br>
      &#94;If(&#94;D("%J");<=12,Good Morning,&#94;If(&#94;D("%J");<=18,Good Afternoon,Good evening););
<p>

|,
		lastUpdated => 1112466919,
	},
};

1;
