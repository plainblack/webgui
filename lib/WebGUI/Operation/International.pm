package WebGUI::Operation::International;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA    = qw(Exporter);
our @EXPORT = qw(&www_listLanguages &www_editLanguage &www_submitTranslation &www_submitTranslationConfirm
&www_deleteLanguage &www_deleteLanguageConfirm &www_addInternationalMessage &www_addInternationalMessageSave
&www_listInternationalMessages &www_editLanguageSave &www_editInternationalMessage
&www_exportTranslation &www_editInternationalMessageSave );


#-------------------------------------------------------------------
sub _export {
	tie my %data, 'Tie::CPHash';
	%data   = WebGUI::SQL->quickHash( 'select * from language where languageId=' . $_[ 0 ] );
	my $export = '#Exported from ' . $session{ setting }{ companyName } . ' (http://' . $session{ env }{ SERVER_NAME } . ') by '
		. $session{ user }{ username } . ' (' . $session{ user }{ email } . ")\n"
		. '#' . $data{ language } . ' translation export for WebGUI ' . $WebGUI::VERSION . ".\n\n"
		. "#language\n\n"
		. 'delete from language where languageId=' . $_[ 0 ] . ";\n"
		. 'insert into language (languageId,language,characterSet,toolbar) values ('
		. $data{ languageId } . ', ' . quote( $data{ language } ) . ', ' . quote( $data{ characterSet } ) . ', '
		. quote( $data{ toolbar } ) . ");\n"
		. "\n#international messages\n\n";
	my $sth = WebGUI::SQL->read( 'select * from international where languageId=' . $_[ 0 ] . ' order by lastUpdated desc' );

	while ( %data = $sth->hash ) {
		$export .= 'delete from international where languageId=' . $_[ 0 ] . ' and namespace='
			. quote( $data{ namespace } ) . ' and internationalId=' . $data{ internationalId } . ";\n"
			. 'insert into international (internationalId,languageId,namespace,message,lastUpdated) values ('
			. $data{ internationalId } . ',' . $data{ languageId } . ',' . quote( $data{ namespace } )
			. ',' . quote( $data{ message } ) . ', ' . $data{ lastUpdated } . ");\n";
	}
	$sth->finish;
	return $export;
}

#-------------------------------------------------------------------
sub _submenu {
	tie my %menu, 'Tie::IxHash';
	$menu{ WebGUI::URL::page( 'op=editLanguage&lid=new' ) } = WebGUI::International::get( 584 );
	if ( $session{ form }{ lid } == 1 ) {
		$menu{ WebGUI::URL::page( 'op=addInternationalMessage&lid=1' ) } = 'Add a new message.';
	}
	if ( $session{ form }{ lid } ne 'new' && $session{ form }{ lid } ne '' ) {
		$menu{ WebGUI::URL::page( 'op=listInternationalMessages&lid=' . $session{ form }{ lid } ) } =
		WebGUI::International::get( 594 );
		$menu{ WebGUI::URL::page( 'op=exportTranslation&lid=' . $session{ form }{ lid } ) } = WebGUI::International::get( 718 );
		$menu{ WebGUI::URL::page( 'op=submitTranslation&lid=' . $session{ form }{ lid } ) } = WebGUI::International::get( 593 );
		$menu{ WebGUI::URL::page( 'op=editLanguage&lid=' . $session{ form }{ lid } ) }      = WebGUI::International::get( 598 );
		$menu{ WebGUI::URL::page( 'op=deleteLanguage&lid=' . $session{ form }{ lid } ) }    = WebGUI::International::get( 791 );
	}
	$menu{ WebGUI::URL::page( 'op=listLanguages' ) } = WebGUI::International::get( 585 );
	return menuWrapper( $_[ 0 ], \%menu );
}

#-------------------------------------------------------------------
sub www_addInternationalMessage {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my $output = '<h1>Add English Message</h1>';
	my $namespace = $session{ wobject };
	$namespace->{ WebGUI } = 'WebGUI';
	$namespace = { %{ $namespace }, map { 'Auth/' . $_ => 'Authentication: ' . $session{ authentication }->{ $_ } } keys %{ $session{ authentication } } };
	my $f = WebGUI::HTMLForm->new();
	$f->hidden( 'lid', 1 );
	$f->hidden( 'op', 'addInternationalMessageSave' );
	$f->select( 'namespace', $namespace, 'Namespace', [ 'WebGUI' ] );
	$f->textarea( 'message', 'Message' );
	$f->submit;
	$output .= $f->print;
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_addInternationalMessageSave {
	my ( $nextId ) = WebGUI::SQL->quickArray( 'select max(internationalId) from international where languageId=1 
		and namespace=' . quote( $session{ form }{ namespace } ) );
	$nextId++;
	WebGUI::SQL->write( "insert into international (languageId, internationalId, namespace, message, lastUpdated) values
		(1,$nextId," . quote( $session{ form }{ namespace } ) . ',' . quote( $session{ form }{ message } ) . ',' . time() . ')' );
	return "<b>Message was added with id $nextId.</b>" . www_listInternationalMessages();
}

#-------------------------------------------------------------------
sub www_deleteLanguage {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ lid } < 1000 and $session{ form }{ lid } > 0;
	my $output = '<h1>' . WebGUI::International::get( 42 ) . '</h1>'
		. WebGUI::International::get( 587 ) . '<p>'
		. '<div align="center"><a href="'
		. WebGUI::URL::page( 'op=deleteLanguageConfirm&lid=' . $session{ form }{ lid } )
		. '">' . WebGUI::International::get( 44 ) . '</a>'
		. '&nbsp;&nbsp;&nbsp;&nbsp;<a href="' . WebGUI::URL::page( 'op=listLanguages' )
		. '">' . WebGUI::International::get( 45 ) . '</a></div>';
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_deleteLanguageConfirm {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ lid } < 1000 and $session{ form }{ lid } > 0;
	WebGUI::SQL->write( 'delete from language where languageId=' . $session{ form }{ lid } );
	WebGUI::SQL->write( 'delete from international where languageId=' . $session{ form }{ lid } );
	WebGUI::SQL->write( q[delete from userProfileData where fieldName='language' and fieldData=] . $session{ form }{ lid } );
	$session{ form }{ lid } = '';
	return www_listLanguages();
}

#-------------------------------------------------------------------
sub www_editInternationalMessage {
	my ( $output, $message, $f, $language );
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $language ) = WebGUI::SQL->quickArray( 'select language from language where languageId=' . $session{ form }{ lid } );
	my $output = '<h1>' . WebGUI::International::get( 597 ) . '</h1>';
	my $f      = WebGUI::HTMLForm->new;
	$f->readOnly( $session{ form }{ iid }, WebGUI::International::get( 601 ) );
	$f->hidden( 'lid',       $session{ form }{ lid } );
	$f->hidden( 'status',    $session{ form }{ status } );
	$f->hidden( 'iid',       $session{ form }{ iid } );
	$f->hidden( 'pn',        $session{ form }{ pn } );
	$f->hidden( 'namespace', $session{ form }{ namespace } );
	$f->hidden( 'op',        'editInternationalMessageSave' );
	my ( $message ) = WebGUI::SQL->quickArray( 'select message from international where internationalId=' . $session{ form }{ iid }
	. q[ and namespace='] . $session{ form }{ namespace } . q[' and languageId=] . $session{ form }{ lid } );
	$f->textarea( 'message', $language, $message );
	$f->submit;
	( $message ) = WebGUI::SQL->quickArray( 'select message from international where internationalId=' . $session{ form }{ iid }
		. q[ and namespace='] . $session{ form }{ namespace } . q[' and languageId=1] );
	$f->readOnly( $message, 'English' );
	$output .= $f->print;
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_editInternationalMessageSave {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	if ( $session{ form }{ status } eq 'missing' ) {
		WebGUI::SQL->write( 'insert into international (message,namespace,languageId,internationalId,lastUpdated) values ('
			. quote( $session{ form }{ message } ) . ',' . quote( $session{ form }{ namespace } )
			. ',' . $session{ form }{ lid } . ',' . $session{ form }{ iid } . ', ' . time() . ')' );
	}
	else {
		WebGUI::SQL->write( 'update international set message=' . quote( $session{ form }{ message } )
			. ', lastUpdated=' . time() . ' where namespace=' . quote( $session{ form }{ namespace } )
			. ' and languageId=' . $session{ form }{ lid } . ' and internationalId=' . $session{ form }{ iid } );
	}
	return www_listInternationalMessages();
}

#-------------------------------------------------------------------
sub www_editLanguage {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	my $dir = $session{ config }{ extrasPath } . $session{ os }{ slash } . 'toolbar';
	opendir my $dh, $dir or WebGUI::ErrorHandler::warn( "Can't open toolbar directory $dir: $!" );
	my @files = grep !/^\.\.?$/, readdir $dh;
	closedir $dh;

	my %options;
	@options{ @files } = @files;

	tie my %data, 'Tie::CPHash';
	if ( $session{ form }{ lid } eq 'new' ) {
		$data{ characterSet } = 'ISO-8859-1';
		$data{ toolbar }      = 'default';
	}
	else {
		%data = WebGUI::SQL->quickHash( 'select * from language where languageId=' . $session{ form }{ lid } );
	}
	my $f = WebGUI::HTMLForm->new;
	$f->readOnly( $session{ form }{ lid }, WebGUI::International::get( 590 ) );
	$f->hidden( 'lid', $session{ form }{ lid } );
	$f->hidden( 'op', 'editLanguageSave' );
	$f->text( 'language', WebGUI::International::get( 591 ), $data{ language } );
	$f->text( 'characterSet', WebGUI::International::get( 592 ), $data{ characterSet } );
	$f->select( 'toolbar', \%options, WebGUI::International::get( 746 ), [ $data{ toolbar } ] );
	$f->submit;
	return _submenu( '<h1>' . WebGUI::International::get( 589 ) . '</h1>' . $f->print );
}

#-------------------------------------------------------------------
sub www_editLanguageSave {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	if ( $session{ form }{ lid } eq 'new' ) {
		$session{ form }{ lid } = getNextId( 'languageId' );
		WebGUI::SQL->write( "insert into language (languageId) values ($session{form}{lid})" );
	}
	WebGUI::SQL->write( 'update language set language=' . quote( $session{ form }{ language } )
		. ', characterSet=' . quote( $session{ form }{ characterSet } ) . ', toolbar=' . quote( $session{ form }{ toolbar } )
		. ' where languageId=' . $session{ form }{ lid } );
	return www_editLanguage();
}

#-------------------------------------------------------------------
sub www_exportTranslation {
	$session{ header }{ mimetype } = 'text/plain';
	return _export( $session{ form }{ lid } );
}

#-------------------------------------------------------------------
sub www_listInternationalMessages {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	tie my %data, 'Tie::CPHash';
	%data = WebGUI::SQL->quickHash( 'select language from language where languageId=' . $session{ form }{ lid } );

	my $missing    = '<b>' . WebGUI::International::get( 596 ) . '</b>';
	my $outOfDate  = '<b>' . WebGUI::International::get( 719 ) . '</b>';
	my $ok         = WebGUI::International::get( 720 );
	my $deprecated = WebGUI::International::get( 723 );
	my $output     = '<h1>' . WebGUI::International::get( 595 ) . ' (' . $data{ language } . ')</h1>';
	my $f          = WebGUI::HTMLForm->new( 1 );
	$f->hidden( 'op', 'listInternationalMessages' );
	$f->hidden( 'lid', $session{ form }{ lid } );
	$f->text( 'search', '', $session{ form }{ search } );
	$f->submit( 'search' );
	$output .= $f->print;

	my $search = ' and message like ' . quote( '%' . $session{ form }{ search } . '%' )
		if $session{ form }{ search } ne '';
	my $sth = WebGUI::SQL->read( 'select * from international where languageId=' . $session{ form }{ lid } . $search );
	my %list;
	while ( %data = $sth->hash ) {
		@{ $list{ "z-$data{namespace}-$data{internationalId}" } }{ qw[id namespace message lastUpdated status] }
			= ( @data{ qw[internationalId namespace message lastUpdated] }, 'deleted' );
	}
	$sth->finish;

	$sth = WebGUI::SQL->read( 'select * from international where languageId=1' );
	while ( %data = $sth->hash ) {
		my $key = $data{ namespace } . '-' . $data{ internationalId };
		if ( $session{ form }{ search } ne '' ) {
			if ( $list{ 'z-' . $key } ) {
				if ( $list{ 'z-' . $key }{ lastUpdated } < $data{ lastUpdated } ) {
					$list{ 'o-' . $key } = delete $list{ 'z-' . $key };
					$list{ 'o-' . $key }{ status } = 'updated';
				}
				else {
					$list{ 'q-' . $key } = delete $list{ 'z-' . $key };
					$list{ 'q-' . $key }{ status } = 'ok';
				}
			}
		}
		else {
			unless ( $list{ 'z-' . $key } ) {
				@{ $list{ 'a-' . $key } }{ qw[namespace id status] }
					= ( @data{ qw[namespace internationalId] }, 'missing' );
			}
			else {
				if ( $list{ 'z-' . $key }{ lastUpdated } < $data{ lastUpdated } ) {
					$list{ 'o-' . $key } = delete $list{ 'z-' . $key };
					$list{ 'o-' . $key }{ status } = 'updated';
				}
				else {
					$list{ 'q-' . $key } = delete $list{ 'z-' . $key };
					$list{ 'q-' . $key }{ status } = 'ok';
				}
			}
		}
	}
	$sth->finish;

	my @row;
	for my $key ( sort keys %list ) {
		my $status = $ok;
		if ( $list{ $key }{ status } eq 'updated' ) {
			$status = $outOfDate;
		}
		elsif ( $list{ $key }{ status } eq 'missing' ) {
			$status = $missing;
		}
		elsif ( $list{ $key }{ status } eq 'deleted' ) {
			$status = $deprecated;
		}
		push @row, '<tr valign="top"><td nowrap="1">' . $status . '</td><td>'
			. editIcon( 'op=editInternationalMessage&lid=' . $session{ form }{ lid }
			. '&iid=' . $list{ $key }{ id } . '&namespace=' . $list{ $key }{ namespace } . '&pn=' . $session{ form }{ pn }
			. '&status=' . $list{ $key }{ status } ) . '</td><td>' . $list{ $key }{ namespace } . '</td><td>'
			. $list{ $key }{ id } . '</td><td>' . $list{ $key }{ message } . "</td></tr>\n";
	}
	my $p = WebGUI::Paginator->new( WebGUI::URL::page( 'op=listInternationalMessages&lid=' . $session{ form }{ lid } ), \@row, 100 );

	$output .= $p->getBarTraditional( $session{ form }{ pn } )
		. '<table style="font-size: 11px;" width="100%">'
		. '<tr><td class="tableHeader">' . WebGUI::International::get( 434 ) . '</td><td class="tableHeader">'
		. WebGUI::International::get( 575 ) . '</td><td class="tableHeader">' . WebGUI::International::get( 721 )
		. '</td><td class="tableHeader">' . WebGUI::International::get( 722 )
		. '</td><td class="tableHeader" width="100%">' . WebGUI::International::get( 230 ) . '</td></tr>'
		. $p->getPage( $session{ form }{ pn } )
		. '</table>'
		. $p->getBarTraditional( $session{ form }{ pn } );
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_listLanguages {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	tie my %data, 'Tie::CPHash';
	my $output = '<h1>' . WebGUI::International::get( 586 ) . '</h1>';
	my $sth    = WebGUI::SQL->read( 'select languageId,language from language where languageId<>1 order by language' );
	while ( %data = $sth->hash ) {
		$output .= '<a href="' . WebGUI::URL::page( 'op=editLanguage&lid=' . $data{ languageId } ) . '">' . $data{ language } . '<br>';
	}
	$sth->finish;
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_submitTranslation {
	my $output = '<h1>' . WebGUI::International::get( 42 ) . '</h1>'
		. WebGUI::International::get( 588 ) . '<p>'
		. '<div align="center"><a href="'
		. WebGUI::URL::page( 'op=submitTranslationConfirm&lid=' . $session{ form }{ lid } )
		. '">' . WebGUI::International::get( 44 ) . '</a>'
		. '&nbsp;&nbsp;&nbsp;&nbsp;<a href="' . WebGUI::URL::page( 'op=listLanguages' )
		. '">' . WebGUI::International::get( 45 ) . '</a></div>';
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_submitTranslationConfirm {
	WebGUI::Mail::send( 'info@plainblack.com', 'International Message Submission', _export( $session{ form }{ lid } ) );
	return www_editLanguage();
}


1;


