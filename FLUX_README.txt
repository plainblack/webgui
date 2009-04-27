= FLUX README =

= Installation =
To keep the number of core WebGUI files modified for Flux to a minimum, I've created a script called
 enable_flux.pl
that you need to run against a site to have it "flux enabled". This basically involves adding some extra
db tables, modifying your webgui config file etc.. (check out the source for full details).

You can run enable_flux.pl multiple times against the same site without any adverse effects.

> perl enable_flux.pl -c dev.localhost.localdomain.conf

= Tests =
The official Flux test suite lives under t/Flux
You obviously need to run enable_flux.pl against the site you want to run the tests against.

> prove -r t/Flux

= More Information =
Check out the docs in the fluxdesigndocs directory and/or catch me on IRC

- Patrick Donelan (patspam) http://patspam.com
