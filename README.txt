= README =
Patrick Donelan (patspam)

= Installation =
To make merging changes from trunk to the Flux branch, the database schema changes needed by Flux are contained in a separate
enable_flux.pl script. If you want to run the Flux_branch, you need to use enable_flux.pl to apply the schema changes to your
site.

e.g. enable_flux.pl -c dev.localhost.localdomain.conf

= Tests =
The official Flux test suite lives under t/Flux

e.g. prove t/Flux

= More Information =
Check out the docs in the fluxdesigndocs directory and/or catch me on IRC