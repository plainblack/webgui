 FLASH plugin for TinyMCE
-----------------------------

About:
  This is the INSERT FLASH Dioalog contributed by Michael Keck.
  This one supports popup windows and targets.

Note:
  The placeholder for Flash is called 'mce_plugin_flash' and needs a class 'mce_plugin_flash' in the 'css_-style'.
  Do not name another image 'name="mce_plugin_flash"!

Installation instructions:
  * Copy the flash directory to the plugins directory of TinyMCE (/jscripts/tiny_mce/plugins).
  * Add plugin to TinyMCE plugin option list example: plugins : "flash".
  * Add this "img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]" to extended_valid_elements option.

Initialization example:
  tinyMCE.init({
    theme : "advanced",
    mode : "textareas",
    plugins : "flash",
    extended_valid_elements : "img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name]"
  });
