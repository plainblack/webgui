/*  -*-mode: Java; coding: latin-1;-*- Time-stamp: "2005-05-13 20:47:10 ADT"

 "Resizeable textarea functions" by Sean M. Burke, sburke@cpan.org, 2005

 You can use, modify, and redistribute this only under the terms of the
 Perl Artistic License: 
  http://www.perl.com/pub/a/language/misc/Artistic.html

*/

var // Configurables:
  tar_Drag_increments = 15, // number of pixels that we grow by

  // Sizes (in pixels) that no draggable textarea should exceed:
  tar_Min_Height =  120,    tar_Min_Width =  120,
  tar_Max_Height = 1400,   tar_Max_Width  = 1400
;

// End of configurables

//==========================================================================
var tar_Textarea, tar_Orig_width, tar_Orig_height, tar_Grip, tar_Cursor_start_x, tar_Cursor_start_y;

function tar_drag_start (event, textarea_id) {
  Textarea = tar_id(textarea_id);

  Grip = Textarea.parentNode;

  tar_add_class(Grip, "activedrag");

  Cursor_start_x = event.clientX;
  Cursor_start_y = event.clientY;
  Orig_width   = parseInt( Textarea.style.width    , 10 );
  Orig_height  = parseInt( Textarea.style.height   , 10 );

  // Capture mousemove and mouseup events on the page.
  if (document.attachEvent)
  {
	  document.attachEvent("mousemove",tar_drag_move,true);
	  document.attachEvent("mouseup",tar_drag_stop,true);
	  event.returnValue = false;
  }
  else
  {
	  document.addEventListener("mousemove", tar_drag_move, true);
	  document.addEventListener("mouseup",   tar_drag_stop, true);
	  event.preventDefault();
  }
  
  
  return;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

function tar_drag_move(event) {
  var
   new_width  = event.clientX - Cursor_start_x + Orig_width ,
   new_height = event.clientY - Cursor_start_y + Orig_height;

  new_width  = tar_constrain_range(tar_Min_Width ,new_width , tar_Max_Width,  tar_Drag_increments);;
  new_height = tar_constrain_range(tar_Min_Height,new_height, tar_Max_Height, tar_Drag_increments);;

  Textarea.style.width  = new_width+'px';
  Textarea.style.height = new_height+'px';

  if (document.attachEvent)
	  event.returnValue = false;
  else
	  event.preventDefault();
  return;
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

function tar_drag_stop(event) {
  // Stop capturing the mousemove and mouseup events.
  tar_remove_class(Grip, "activedrag");
  // Capture mousemove and mouseup events on the page.
  if (document.attachEvent)
  {
	  document.detachEvent("mousemove",tar_drag_move,true);
	  document.detachEvent("mouseup",tar_drag_stop,true);
  }
  else 
  {
	  document.removeEventListener("mousemove", tar_drag_move, true);
	  document.removeEventListener("mouseup",   tar_drag_stop, true);
  }
  return;
}

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

function tar_constrain_range (min, i, max, incr) {
  if(incr)  i = Math.floor(i/incr) * incr;
  return(
	 (i > max) ? max
	:(i < min) ? min
        : i
  );
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

function tar_find_draggable (event) {
  if(!event)  throw tar_complaining("No event?!");

  var el = event.target;
  if(!el) {
    if(window.event) throw tar_complaining(
"Your browser is too old to allow textarea resizing.  Upgrade at getfirefox.com"
    );
    // Modern browsers implement the DOM Events model, dammit!

    throw tar_complaining("No event target?!");
  }

  //trace("Dragging ", el.tagName, "#", el.id);

  if (el.nodeType == document.TEXT_NODE)  el = el.parentNode;
  while(el) {
    if( el.tagName == "BODY" ) { el = false; break; }
    if( tar_has_class(el, 'draggable') ) break; // found it!
    el = el.parentNode;
  }
  if(!el) return false; // undraggable
  Grip = el;
  return true;
}


// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
// Misc library functions:

function tar_has_class (el, classname) {
  return(
	 (" " + (el.className || '') + " ").indexOf(classname) >= 0
  );
}

function tar_add_class (el, newclass) {
  var classes = (el.className || '').split(" ");
  classes.push(newclass);
  el.className = classes.join(" ");
  return el;
}

function tar_remove_class (el, endclass) {
  if(!el.className) return el;
  var classes = el.className.split(" ");
  for(var i = 0; i < classes.length; i++) {
    if(classes[i] == endclass) classes[i] = '';
  }
  el.className = classes.join(" ");
  return el;
}

function tar_id (name) { // find element with the given ID, else exception.
  var object = tar_id_try(name);
  if( ! object ) throw tar_complaining("Failed to find element with id='"
   + name + "' in " + document.location );
  return object;
}

function tar_id_try (name) {
  var object = document.getElementById(name);
  return object;
}

function tar_complaining () {
  var _ = [];
  for(var i = 0; i < arguments.length; i++) { _.push(arguments[i]) }
  _ = _.join("");
  if(! _.length) out = "Unknown error!?!";
  void alert(_);
  return new Error(_,_);
}

// And a sanity-check:
if(!document.getElementById) throw tar_complaining(
"Your browser is too old to show this page quite right.  Upgrade at getfirefox.com"
);


//End

