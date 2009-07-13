= FLUX README =
This is the Flux branch of WebGUI (which also contains WebGUI::History).

= Installation =
To enable flux for a site, simply run the sbin/flux.pl script.

 wgd util sbin/flux.pl --demo
 wreservice.pl --restart modperl spectre
 wgd test t/Flux -r

This basically involves adding some extra db tables, modifying your webgui config file etc.. 
(check out the source for full details).

You can run flux.pl multiple times against the same site without any adverse effects.

= Tests =
The official Flux test suite lives under t/Flux
You obviously need to flux-enable your dev site before the tests will pass.

= More Information =
Check out the docs in the fluxdesigndocs directory and/or catch me on IRC

- Patrick Donelan (patspam) http://patspam.com
