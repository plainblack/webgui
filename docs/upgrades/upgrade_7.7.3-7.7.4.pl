#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;
use JSON;

my $toVersion = '7.7.4';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
updateSurveyQuestionTypes($session);
finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}
sub updateSurveyQuestionTypes{
    my $session = shift;
    my $refs = $session->db->buildArrayRefOfHashRefs("SELECT * FROM Survey_questionTypes");
    for my $ref(@$refs){
        my $name = $ref->{questionType};
        my $params;
        my @texts = split/,/,$ref->{answers};
        #next if(@texts == 0);
        my $count = 0;
        for my $text(@texts){
            my $verbatim = 0;
            $verbatim = 1 if($text =~ /verbatim/);
            push(@$params,[$text,$count++,$verbatim]);
        }
        _loadValues($name,$params,$session);
    }
}

sub _loadValues{
    my $name = shift;
    my $values = shift;
    my $session = shift;
    my $answers = [];
    for my $value(@$values){
        my $answer = _getAnswer();
        $answer->{text} = $value->[0];
        $answer->{recordedAnswer} = $value->[1];
        $answer->{verbatim} = $value->[2];
        push @$answers,$answer;
    }
    my $json = to_json($answers);
    $session->db->write("UPDATE Survey_questionTypes SET answers = ? WHERE questionType = ?",[$json,$name]);
}

sub _getAnswer{
    my $answer = {
            text           => q{},
            verbatim       => 0,
            textCols       => 10,
            textRows       => 5,
            goto           => q{},
            gotoExpression => q{},
            recordedAnswer => q{},
            isCorrect      => 1,
            min            => 1,
            max            => 10,
            step           => 1,
            value          => 1,
            terminal       => 0,
            terminalUrl    => q{},
            type           => 'answer'
    };
    return $answer;
}







# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Turn off the package flag, and set the default flag for templates added
    my $assetIds = $package->getLineage( ['self','descendants'] );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        my $properties = { isPackage => 0 };
        if ($asset->isa('WebGUI::Asset::Template')) {
            $properties->{isDefault} = 1;
        }
        $asset->update( $properties );
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
