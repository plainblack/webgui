package WebGUI::Operation::SpellCheck;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Encode;
# Optional, but if unavailable, spell checking will have no effect.
eval 'use Text::Aspell';
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Operation::Spellcheck

=head1 DESCRIPTION

Operation for server side spellchecking functions.

=cut

#-------------------------------------------------------------------

=head2 _getSpeller ( session )

Returns an instanciated Text::Aspell object.

=head3 session

An instanciated session object.

=cut

sub _getSpeller {
	my ($baseDir, $userDir, $homeDir);
	my $session = shift;
	return undef unless Text::Aspell->can('new');
	my $speller = Text::Aspell->new;

	# Get language
	my $lang = $session->form->process('lang');
	return undef unless (isIn($lang, map {m/^.*?:([^:]*):.*?$/} $speller->list_dictionaries));

	# User homedir
	my $userId = $session->user->userId;

	$baseDir = $session->config->get('uploadsPath').'/dictionaries/';

	if (length($userId) < 22) {
		$userDir = 'oldIds/'.$userId;

		mkdir($baseDir.$userDir) unless (-e $baseDir.$userDir);
	} else {
		$userDir = $userId;
		$userDir =~ s/^(.{2})(.{2})*$/$1\/$2\/$userId/;

		mkdir($baseDir.$1) unless (-e $baseDir.$1);
		mkdir($baseDir.$1.'/'.$2) unless (-e $baseDir.$1.'/'.$2);
	}

	$homeDir = $baseDir.$userDir;

	mkdir($homeDir) unless (-e $homeDir);
	
	# Set speller options.
	$speller->set_option('home-dir', $homeDir);
	$speller->set_option('lang', $lang);
	
	return $speller;
}

#-------------------------------------------------------------------

=head2 _processOutput ( session, words, [ id, [ command ] ] )

Processes the wordlist and generates an XML string that the TinyMCE spellchecker
plugin can grok.

=head3 session

The instanciated session object.

=head3 words

An arrayref containing the words that you want to send back to the spellchecker
plugin.

=head3 id

The id that the tinyMCE spellchecker plugin assigined to this specific action.
If not specified the value of the formparam 'id' will be sent.

=head3 command

The spellchecker plugin command that has been issued. If omitted the value of
formparam 'cmd' will be used.

=cut

sub _processOutput {
	my $session = shift;
	my $words = shift || [];
	my $id = shift || $session->form->process('id');
	my $command = shift || $session->form->process('cmd');
	
	$session->http->setMimeType('text/xml; charset=utf-8');
	my $output = '<?xml version="1.0" encoding="utf-8" ?>'."\n";

	if (scalar(@$words) == 0) {
		$output .= '<res id="'.$id.'" cmd="'.$command.'"></res>';
	}
	else {
		$output .= '<res id="'.$id.'" cmd="'.$command.'">'.encode_utf8(join(" ", @$words)).'</res>';
	}

	return $output;
}

#-------------------------------------------------------------------

=head2 www_spellCheck ( session )

Fetches the the text to be checked as sent by the tinyMCE spellchecker and
returns a list of erroneous words in the correct XML format.

=head3 session

The instanciated session object.

=cut

sub www_spellCheck {
	my $session = shift;
	my (@result, $output);

	my $speller = _getSpeller($session);
	return _processOutput($session) unless (defined($speller));

	# Set speller options?

	# Get form params
	my $check = $session->form->process('check');
	my $command = $session->form->process('cmd');
	my $language = $session->form->process('lang');
	my $mode = $session->form->process('mode');
	my $id = $session->form->process('id');

	# Check it!
	my @words = split(/\s/, $check);

	foreach my $word (@words) {
		unless ($speller->check($word)) {
			push(@result, $word);
		}
	}

	return _processOutput($session, \@result);
}

#-------------------------------------------------------------------

=head2 www_suggestWords ( session )

Returns a list of suggested words in the correct XML format for a misspelled
word sent by the tinyMCE spellchecker.

=head3 session

The instanciated session object.

=cut

sub www_suggestWords {
	my $session = shift;

	my $speller = _getSpeller($session);
	return _processOutput($session) unless (defined($speller));
	my $check = $session->form->process('check');
	
	my @result = $speller->suggest($check);

	return _processOutput($session, \@result);
}

#-------------------------------------------------------------------

=head2 www_addWordToDictionary ( session )

Adds a word sent by the tinymce spellchecker plugin to the personal dictionary
of the the current user.

=head3 session

The instanciated session object

=cut

sub www_addWordToDictionary {
	my $session = shift;

	# Visitors do not have a personal dictionary
	return _processOutput($session, ['You must be logged in to add words to your dictionary.']) if ($session->user->userId eq '1');
	
	my $speller = _getSpeller($session);
	return _processOutput($session) unless (defined($speller));
	my $check = $session->form->process('check');

	if ($check) {
		$speller->add_to_personal($check);
		$speller->save_all_word_lists;
	}

	return _processOutput($session);
}

1;

