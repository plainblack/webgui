// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.str == "undefined") {
    WebGUI.str = {};
}


/**
 * This object contains generic string manipulation functions
 */

WebGUI.str.sprintfWrapper = {
	init : function () {

		if (typeof arguments == "undefined") { return null; }
		if (arguments.length < 1) { return null; }
		if (typeof arguments[0] != "string") { return null; }
		if (typeof RegExp == "undefined") { return null; }

		var string = arguments[0];
		var exp = new RegExp(/(%([%]|(\-)?(\+|\x20)?(0)?(\d+)?(\.(\d)?)?([bcdfosxX])))/g);
		var matches = new Array();
		var strings = new Array();
		var convCount = 0;
		var stringPosStart = 0;
		var stringPosEnd = 0;
		var matchPosEnd = 0;
		var newString = '';
		var match = null;

		while (match = exp.exec(string)) {
			if (match[9]) { convCount += 1; }

			stringPosStart = matchPosEnd;
			stringPosEnd = exp.lastIndex - match[0].length;
			strings[strings.length] = string.substring(stringPosStart, stringPosEnd);

			matchPosEnd = exp.lastIndex;
			matches[matches.length] = {
				match: match[0],
				left: match[3] ? true : false,
				sign: match[4] || '',
				pad: match[5] || ' ',
				min: match[6] || 0,
				precision: match[8],
				code: match[9] || '%',
				negative: parseInt(arguments[convCount]) < 0 ? true : false,
				argument: String(arguments[convCount])
			};
		}
		strings[strings.length] = string.substring(matchPosEnd);

		if (matches.length == 0) { return string; }
		if ((arguments.length - 1) < convCount) { return null; }

		var code = null;
		var match = null;
		var i = null;

		for (i=0; i<matches.length; i++) {

			if (matches[i].code == '%') { substitution = '%' }
			else if (matches[i].code == 'b') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(2));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'c') {
				matches[i].argument = String(String.fromCharCode(parseInt(Math.abs(parseInt(matches[i].argument)))));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'd') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'f') {
				matches[i].argument = String(Math.abs(parseFloat(matches[i].argument)).toFixed(matches[i].precision ? matches[i].precision : 6));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'o') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(8));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 's') {
				matches[i].argument = matches[i].argument.substring(0, matches[i].precision ? matches[i].precision : matches[i].argument.length)
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i], true);
			}
			else if (matches[i].code == 'x') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i]);
			}
			else if (matches[i].code == 'X') {
				matches[i].argument = String(Math.abs(parseInt(matches[i].argument)).toString(16));
				substitution = WebGUI.str.sprintfWrapper.convert(matches[i]).toUpperCase();
			}
			else {
				substitution = matches[i].match;
			}

			newString += strings[i];
			newString += substitution;

		}
		newString += strings[i];

		return newString;

	},

	convert : function(match, nosign){
		if (nosign) {
			match.sign = '';
		} else {
			match.sign = match.negative ? '-' : match.sign;
		}
		var l = match.min - match.argument.length + 1 - match.sign.length;
		var pad = new Array(l < 0 ? 0 : l).join(match.pad);
		if (!match.left) {
			if (match.pad == "0" || nosign) {
				return match.sign + pad + match.argument;
			} else {
				return pad + match.sign + match.argument;
			}
		} else {
			if (match.pad == "0" || nosign) {
				return match.sign + match.argument + pad.replace(/0/g, ' ');
			} else {
				return match.sign + match.argument + pad;
			}
		}
	}
}

/****************************************************************************
 * WebGUI.str.sprintf ( formater, var1, var2, var3 )

  Formatter looks like:

    %% - Returns a percent sign
    %b - Binary number
    %c - The character according to the ASCII value
    %d - Signed decimal number
    %f - Floating-point number
    %o - Octal number
    %s - String
    %x - Hexadecimal number (lowercase letters)
    %X - Hexadecimal number (uppercase letters)

  Additional format values. These are placed between the % and the letter (example %.2f):

    + (Forces both + and - in front of numbers. By default, only negative numbers are marked)
    - (Left-justifies the variable value)
    0 zero will be used for padding the results to the right string size
    [0-9] (Specifies the minimum width held of to the variable value)
    .[0-9] (Specifies the number of decimal digits or maximum string length)

 */

WebGUI.str.sprintf = WebGUI.str.sprintfWrapper.init;


/****************************************************************************
 * WebGUI.str.trim ( string, chars )

 Removes all leading and trailing occurrences of a set of characters specified. If no characters are specified it will trim whitespace characters from the beginning or end or both of the string. Without the second parameter, they will trim these characters:

    " " (ASCII 32 (0x20)), an ordinary space.
    "\t" (ASCII 9 (0x09)), a tab.
    "\n" (ASCII 10 (0x0A)), a new line (line feed).
    "\r" (ASCII 13 (0x0D)), a carriage return.
    "\0" (ASCII 0 (0x00)), the NUL-byte.
    "\x0B" (ASCII 11 (0x0B)), a vertical tab.

*/

WebGUI.str.trim = function (str, chars) {
    return WebGUI.str.ltrim(WebGUI.str.rtrim(str, chars), chars);
}

/****************************************************************************
 * WebGUI.str.ltrim ( string, chars )

    Only trims from the left side.

*/

WebGUI.str.ltrim = function (str, chars) {
    chars = chars || "\\s";
    return str.replace(new RegExp("^[" + chars + "]+", "g"), "");
}

/****************************************************************************
 * WebGUI.str.trim ( string, chars )

    Only trims from the right side.

*/

WebGUI.str.rtrim = function (str, chars) {
    chars = chars || "\\s";
    return str.replace(new RegExp("[" + chars + "]+$", "g"), "");
}

/**
*
* sprintf, trim, ltrim, and rtrim all used with permission from:
*
*  http://www.webtoolkit.info/
*
**/


