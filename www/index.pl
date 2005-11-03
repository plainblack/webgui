#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "webgui.conf";
        $webguiRoot = "/data/WebGUI";
        unshift (@INC, $webguiRoot."/lib");
}

#-----------------DO NOT MODIFY BELOW THIS LINE--------------------
#use Devel::Profiler bad_pkgs => [qw(UNIVERSAL Time::HiRes B Carp Exporter Cwd Config CORE DynaLoader XSLoader AutoLoader Safe)];
#use CGI::Carp qw(fatalsToBrowser);
use strict;
use WebGUI;
print WebGUI::page($webguiRoot,$configFile);

#  use Devel::DProfPP;
#  my $pp = Devel::DProfPP->new;
#use Data::Dumper;
#  print Devel::DProfPP->new(
#        file    => "tmon.out",
#        enter   => sub { my ($self, $sub_name)  = shift;
#                         my $frame = ($self->stack)[-1];
#                         print "\t" x $frame->height, $frame->sub_name;
#                       }
#  )->parse;
#  print Dumper(\%hash);