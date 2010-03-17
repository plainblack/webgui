use lib '/data/WebGUI/lib';
use WebGUI;

# Some ways to achieve the same thing from the command line:
#  plackup -MWebGUI -e 'WebGUI->new'
#  plackup -MWebGUI -e 'WebGUI->new("dev.localhost.localdomain.conf")'
#  plackup -MWebGUI -e 'WebGUI->new(root => "/data/WebGUI", site => "dev.localhost.localdomain.conf")'
#
# Or from a .psgi file:
#  my $app = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' )->psgi_app;
# Or equivalently (using the defaults):
WebGUI->new;