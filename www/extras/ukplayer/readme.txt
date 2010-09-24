United Knowledge Slideshow Player - readme.txt

Copyright: United Knowledge, 2009

The Slideshow PLayer is licensed under the terms of the GNU General Public License, version 2
http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

SWFObject 2, the code used to display the Slideshow, is licensed under the MIT License
http://www.opensource.org/licenses/mit-license.php

Check out the latest source on:
http://git.st.unitedknowledge.org/git/ukplayer.git
git clone git://git.st.unitedknowledge.org/ukplayer.git
git clone http://git.st.unitedknowledge.org/git/ukplayer.git

More information about licences can be found in the file licences.txt in this directory. 


**********************************************************************************************
*                                                                                            *
*  The configuration XML                                                                     *
*                                                                                            *
**********************************************************************************************

With the configuration .xml file you can customize the look and the behaviour of the
slideshow. It contains the following properties (the values are example values; there are
default values for most, but we recommend setting ALL properties yourself).



**********************************************************************************************
*  Structure of the xml                                                                      *
**********************************************************************************************

<config>
  [properties go here]
</config>



**********************************************************************************************
*  General properties                                                                        *
**********************************************************************************************

<content_url>/someUrl/someXmlFile.xml</content_url>
	The url to the .xml file that contains the content.
	Value: an absolute or relative url to an xml file

<width>400</width>
<height>300</height>
	The width and height of the player itself (this value is overwritten by the flashVars
	but the tags need to be here).
	Value: number in px

<default_duration>8</default_duration>
	The duration of each slide. This can be overwritten by setting the duration per slide
	in the content .xml file.
	Value: number in seconds

<default_slidewidth>400</default_slidewidth>
<default_slideheight>300</default_slideheight>
	If the width or height of a slide is larger than the values specified here, the slide
	will be resized	proportionally. Slides that are smaller than the slidshow will not be
	resized.
	Value: number in px

<background_color>0xeeeeee</background_color>
	The background color for the slideshow. This will be visible during the transitions
	and when a slide is smaller than the slideshow.
	Value: 0x followed by hexadecimal color

<skin>rounded</skin>
	The textarea, controls and thumbnails can be displayed with two different skins.
	Value: simple or rounded



**********************************************************************************************
*  Text properties                                                                           *
**********************************************************************************************

<font>Verdana</font>
	The font of the text in the slideshow.
	Value: Verdana, Arial or TimesNewRoman

<font_size>12</font_size>
	The font size of the text in the slideshow.
	Value: number in px

<font_color>0xffffff</font_color>
	The color of the text in the slideshow.
	Value: 0x followed by hexadecimal color

<text_border_color>0xffffff</text_border_color>
	The color of the border of the textarea.
	Value: 0x followed by hexadecimal color

<text_bg_color>0x000000</text_bg_color>
	The background color of the textarea.
	Value: 0x followed by hexadecimal color

<text_autohide>false</text_autohide>
	When set to true the textarea will hide after a few seconds.
	Value: true or false

<text_display>over</text_display>
	The textarea can be postioned over the slides, above the slides (the height of the player
	should be the sum of the height of the slides and the height of the textarea) or can be
	hidden.
	Value: over, above or none

<text_height>50</text_height>
	The minimum height of the textarea.
	Value: number in px



**********************************************************************************************
*  Controls properties                                                                       *
**********************************************************************************************

<controls_color>0xffffff</controls_color>
	The color of the buttons.
	Value: 0x followed by hexadecimal color

<controls_border_color>0xffffff</controls_border_color>
	The color of the border of the area with the buttons.
	Value: 0x followed by hexadecimal color

<controls_bg_color>0x000000</controls_bg_color>
	The background color of the area with the buttons.
	Value: 0x followed by hexadecimal color

<controls_autohide>true</controls_autohide>
	When set to true the controls will hide after a few seconds.
	Value: true or false

<playbutton_percent_width>20</playbutton_percent_width>
	The width of the big play button (which appears when auto_start is false and, if loop is
	set to false, after the slideshow has finished) can be set in a percentage of the total
	width of the movie.
	Value: percentage of movie width

<playbutton_max_width>200</playbutton_max_width>
	A maximum width for the play button to prevent it from becoming too large.
	Value: number in px



**********************************************************************************************
*  Thumbnail properties                                                                      *
**********************************************************************************************

<thumbnail_width>40</thumbnail_width>
<thumbnail_height>30</thumbnail_height>
	The height and width of each thumbnail image in the bar at the bottom of the
	slideshow.
	Value: number in px

<thumbnail_border_color>0x888888</thumbnail_border_color>
	The color of the border of each thumbnail image.
	Value: 0x followed by hexadecimal color

<menu_autohide>true</menu_autohide>
	When set to true the thumbnail bar will hide after a few seconds.
	Value: true or false

<menu_dead_zone_width>160</menu_dead_zone_width>
	The width of the area in the center of the thumbnail bar in which the user can hover
	the mouse, without the thumbnail bar moving to the left or to the right.
	Value: number in px

<menu_gaps>6</menu_gaps>
	The width of the gap between two thumbnail images.
	Value: number in px

<thumbnails_hide>false</thumbnails_hide>
	When set to true, the thumbnails are hidden.
	Value: true or false



**********************************************************************************************
*  Behaviour properties                                                                      *
**********************************************************************************************

<mute_at_start>true</mute_at_start>
	If true the slideshow will start with the sound muted.
	Value: true or false

<sound>off</sound>
	If the sound is turned off, the audio files will not be played and the mute and volume
	controls will be hidden.
	Value: on or off

<autostart>false</autostart>
	If true the slideshow will start upon loading. If false a play button will be
	displayed.
	Value: true or false

<autopause>true</autopause>
	If true the slideshow will pause when clicking on a thumbnail or clicking the
	previous or next buttons.
	Value: true or false

<loop>false</loop>
	If true the slideshow will loop. If false, when the last slide has been displayed,
	the slideshow will move back to the first slide and show a play button.
	Value: true or false



**********************************************************************************************
*  Error messages                                                                            *
**********************************************************************************************

<error_message_content><![CDATA[Content Xml not found]]></error_message_content>
<error_message_image><![CDATA[Image not found]]></error_message_image>
	Value: any text in CDATA tags: <![CDATA[ ... ]]>




**********************************************************************************************
*                                                                                            *
*  The content XML                                                                           *
*                                                                                            *
**********************************************************************************************

The content .xml file contains the properties for each slide.



**********************************************************************************************
*  Structure of the xml                                                                      *
**********************************************************************************************

<content>
  <slides>
    <slide>[properties go here]</slide>
    <slide>[properties go here]</slide>
    ...
  </slides>
</content>



**********************************************************************************************
*  Properties in the slide tag                                                               *
**********************************************************************************************

<title><![CDATA[My first slide]]></title>
	The title of the slide.
	Value: any text in CDATA tags: <![CDATA[ ... ]]>

<description><![CDATA[This is my first slide!]]></description>
	The description of the slide.
	Value: any text in CDATA tags: <![CDATA[ ... ]]>

<image_source>/someUrl/someImg.jpg</image_source>
	The url to the slide image.
	Value: an absolute or relative url to a .jpg, .gif or .png file

<thumb_source>/someUrl/someImg_thumb.jpg</thumb_source>
	The url to the thumbnail of the slide image.
	Value: an absolute or relative url to a .jpg, .gif or .png file

<sound_source>/someUrl/someImg_thumb.jpg</sound_source>
	The url to the sound file that will be played when the slide is displayed. It will be
	played once for the duration of the slide (if the duration of the sound file is longer
	than the set duration of the slide it will be cut off). This property is optional.
	Value: an absolute or relative url to a .mp3 file

<duration>8</duration>
	The duration for this specific slide. This value will overwrite the duration value set
	in the configuration xml. This property is optional.
	Value: number in seconds

<width>400</width>
<height>300</height>
	The width and height of the slide. This will overwrite the default_slidewidth and
	default_slideheight set in the configuration xml. The width and height properties are
	optional.
	Value: number in px



**********************************************************************************************
*  eof                                                                                       *
**********************************************************************************************
