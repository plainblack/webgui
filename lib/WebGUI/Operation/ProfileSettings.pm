package WebGUI::Operation::ProfileSettings;

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
use Tie::IxHash;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA    = qw(Exporter);
our @EXPORT = qw(&www_deleteProfileCategoryConfirm &www_deleteProfileFieldConfirm &www_editProfileCategorySave &www_editProfileFieldSave &www_deleteProfileCategory &www_deleteProfileField &www_editProfileCategory &www_editProfileField &www_moveProfileCategoryDown &www_moveProfileCategoryUp &www_moveProfileFieldDown &www_moveProfileFieldUp &www_editProfileSettings);

#-------------------------------------------------------------------
sub _reorderCategories {
	my $sth = WebGUI::SQL->read( 'select profileCategoryId from userProfileCategory order by sequenceNumber' );
	my $i = 1;
	while ( my ( $id ) = $sth->array ) {
		WebGUI::SQL->write( q[update userProfileCategory set sequenceNumber='] . $i++ . q[' where profileCategoryId=] . $id );
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub _reorderFields {
	my ( $sth, $i, $id );
	my $sth = WebGUI::SQL->read( 'select fieldName from userProfileField where profileCategoryId=' . quote( $_[ 0 ] ) . ' order by sequenceNumber' );
	my $i = 1;
	while ( my ( $id ) = $sth->array ) {
		WebGUI::SQL->write( q[update userProfileField set sequenceNumber='] . $i++ . q[' where fieldName=] . quote( $id ) );
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub _submenu {
	tie my %menu, 'Tie::IxHash';
	$menu{ WebGUI::URL::page( 'op=editProfileCategory' ) } = WebGUI::International::get( 490 );
	$menu{ WebGUI::URL::page( 'op=editProfileField' ) }    = WebGUI::International::get( 491 );
	if ( ( $session{ form }{ op } eq 'editProfileField' and $session{ form }{ fid } ne 'new' ) or $session{ form }{ op } eq 'deleteProfileField' ) {
		$menu{ WebGUI::URL::page( 'op=editProfileField&fid=' . $session{ form }{ fid } ) }   = WebGUI::International::get( 787 );
		$menu{ WebGUI::URL::page( 'op=deleteProfileField&fid=' . $session{ form }{ fid } ) } = WebGUI::International::get( 788 );
	}
	if ( ( $session{ form }{ op } eq 'editProfileCategory' and $session{ form }{ cid } ne 'new' ) or $session{ form }{ op } eq 'deleteProfileCategory' ) {
		$menu{ WebGUI::URL::page( 'op=editProfileCategory&cid=' . $session{ form }{ cid } ) }   = WebGUI::International::get( 789 );
		$menu{ WebGUI::URL::page( 'op=deleteProfileCategory&cid=' . $session{ form }{ cid } ) } = WebGUI::International::get( 790 );
	}
	$menu{ WebGUI::URL::page( 'op=editProfileSettings' ) } = WebGUI::International::get( 492 );
	$menu{ WebGUI::URL::page( 'op=manageSettings' ) }      = WebGUI::International::get( 4 );
	return menuWrapper( $_[ 0 ], \%menu );
}

#-------------------------------------------------------------------
sub www_deleteProfileCategory {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ cid } < 1000;
	my $output = '<h1>' . WebGUI::International::get( 42 ) . '</h1>'
		. WebGUI::International::get( 466 ) . '<p>'
		. '<div align="center"><a href="' . WebGUI::URL::page( 'op=deleteProfileCategoryConfirm&cid='
		. $session{ form }{ cid } ) . '">' . WebGUI::International::get( 44 ) . '</a>'
		. '&nbsp;&nbsp;&nbsp;&nbsp;<a href="' . WebGUI::URL::page( 'op=editProfileSettings' ) . '">'
		. WebGUI::International::get( 45 ) . '</a></div>';
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	return WebGUI::Privilege::vitalComponent() if $session{ form }{ cid } < 1000;
	WebGUI::SQL->write( "delete from userProfileCategory where profileCategoryId=$session{form}{cid}" );
	WebGUI::SQL->write( "update userProfileField set profileCategoryId=1 where profileCategoryId=$session{form}{cid}" );
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_deleteProfileField {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $protected ) = WebGUI::SQL->quickArray( 'select protected from userProfileField where fieldname=' . quote( $session{ form }{ fid } ) );
	return WebGUI::Privilege::vitalComponent() if $protected;
	my $output = '<h1>' . WebGUI::International::get( 42 ) . '</h1>'
		. WebGUI::International::get( 467 ) . '<p>'
		. '<div align="center"><a href="' . WebGUI::URL::page( 'op=deleteProfileFieldConfirm&fid=' . $session{ form }{ fid } )
		. '">' . WebGUI::International::get( 44 ) . '</a>'
		. '&nbsp;&nbsp;&nbsp;&nbsp;<a href="' . WebGUI::URL::page( 'op=editProfileSettings' ) . '">'
		. WebGUI::International::get( 45 ) . '</a></div>';
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $protected ) = WebGUI::SQL->quickArray( 'select protected from userProfileField where fieldname=' . quote( $session{ form }{ fid } ) );
	return WebGUI::Privilege::vitalComponent() if $protected;
	WebGUI::SQL->write( 'delete from userProfileField where fieldName=' . quote( $session{ form }{ fid } ) );
	WebGUI::SQL->write( 'delete from userProfileData where fieldName='  . quote( $session{ form }{ fid } ) );
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	tie my %data, 'Tie::CPHash';
	my $f = WebGUI::HTMLForm->new;
	$f->hidden( 'op', 'editProfileCategorySave' );
	if ( $session{ form }{ cid } ) {
		$f->hidden( 'cid', $session{ form }{ cid } );
		$f->readOnly( $session{ form }{ cid }, WebGUI::International::get( 469 ) );
		%data = WebGUI::SQL->quickHash( "select * from userProfileCategory where profileCategoryId=$session{form}{cid}" );
	}
	else {
		$f->hidden( 'cid', 'new' );
	}
	$f->text( 'categoryName', WebGUI::International::get( 470 ), $data{ categoryName } );
	$f->submit;

	return _submenu( '<h1>' . WebGUI::International::get( 468 ) . '</h1>' . $f->print );
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	$session{ form }{ categoryName } = 'Unamed' if $session{ form }{ categoryName } eq '' or $session{ form }{ categoryName } eq q[''];
	my $test = eval $session{ form }{ categoryName };
	$session{ form }{ categoryName } = "'$session{form}{categoryName}'" if $test eq '';
	if ( $session{ form }{ cid } eq 'new' ) {
		my $categoryId = getNextId( 'profileCategoryId' );
		my ( $sequenceNumber ) = WebGUI::SQL->quickArray( 'select max(sequenceNumber) from userProfileCategory' );
		WebGUI::SQL->write( "insert into userProfileCategory values ($categoryId, " . quote( $session{ form }{ categoryName } )
			. ', ' . $sequenceNumber + 1 . ')' );
	}
	else {
		WebGUI::SQL->write( 'update userProfileCategory set categoryName=' . quote( $session{ form }{ categoryName } )
			. " where	profileCategoryId=$session{form}{cid}" );
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileField {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );

	tie my %data, 'Tie::CPHash';
	my $f = WebGUI::HTMLForm->new;
	$f->hidden( 'op', 'editProfileFieldSave' );
	if ( $session{ form }{ fid } ) {
		$f->hidden( 'fid', $session{ form }{ fid } );
		$f->readOnly( $session{ form }{ fid }, WebGUI::International::get( 470 ) );
		%data = WebGUI::SQL->quickHash( 'select * from userProfileField where fieldName=' . quote( $session{ form }{ fid } ) );
	}
	else {
		$f->hidden( 'new', 1 );
		$f->text( 'fid', WebGUI::International::get( 470 ) );
	}
	$f->text( 'fieldLabel', WebGUI::International::get( 472 ), $data{ fieldLabel } );
	$f->yesNo( 'visible',   WebGUI::International::get( 473 ), $data{ visible } );
	$f->yesNo( 'required',  WebGUI::International::get( 474 ), $data{ required } );
	tie my %hash, 'Tie::IxHash';
	my %hash = (
		'text'     => WebGUI::International::get( 475 ),
		'textarea' => WebGUI::International::get( 476 ),
		'HTMLArea' => WebGUI::International::get( 477 ),
		'url'      => WebGUI::International::get( 478 ),
		'date'     => WebGUI::International::get( 479 ),
		'email'    => WebGUI::International::get( 480 ),
		'phone'    => WebGUI::International::get( 481 ),
		'integer'  => WebGUI::International::get( 482 ),
		'yesNo'    => WebGUI::International::get( 483 ),
		'select'   => WebGUI::International::get( 484 )
	);
	$f->selectList( 'dataType', \%hash, WebGUI::International::get( 486 ), [ $data{ dataType } ] );
	untie %hash;
	$f->textarea( 'dataValues',  WebGUI::International::get( 487 ), $data{ dataValues } );
	$f->textarea( 'dataDefault', WebGUI::International::get( 488 ), $data{ dataDefault } );
	tie %hash, 'Tie::CPHash';
	%hash = WebGUI::SQL->buildHash( 'select profileCategoryId,categoryName from userProfileCategory order by categoryName' );
	for my $key ( keys %hash ) {
		$hash{ $key } = eval $hash{ $key };
	}
	$f->select( 'profileCategoryId', \%hash, WebGUI::International::get( 489 ), [ $data{ profileCategoryId } ] );
	$f->submit;

	return _submenu( '<h1>' . WebGUI::International::get( 471 ) . '</h1>' . $f->print );
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
	return WebGUI::Privilege::adminOnly() unless ( WebGUI::Privilege::isInGroup( 3 ) );

	$session{ form }{ fieldLabel } = 'Unamed' if $session{ form }{ fieldLabel } eq '' or $session{ form }{ fieldLabel } eq q[''];
	my $test = eval $session{ form }{ fieldLabel };
	$session{ form }{ fieldLabel } = "'$session{form}{fieldLabel}'" if $test eq '';
	if ( $session{ form }{ new } ) {
		my ( $fieldName ) = WebGUI::SQL->quickArray( 'select count(*) from userProfileField where fieldName='
			. quote( $session{ form }{ fid } ) );
		$session{ form }{ fid } .= '2' if $fieldName;
		my ( $sequenceNumber ) = WebGUI::SQL->quickArray( "select max(sequenceNumber) 
			from userProfileField where profileCategoryId=$session{form}{profileCategoryId}" );
		WebGUI::SQL->write( 'insert into userProfileField (fieldName, sequenceNumber, protected) values ('
			. quote( $session{ form }{ fid } ) . ', ' . $sequenceNumber + 1 . ', 0)' );
	}
	WebGUI::SQL->write( 'update userProfileField set
			fieldLabel='        . quote( $session{ form }{ fieldLabel } )        . ",
			visible='$session{form}{visible}',
			required='$session{form}{required}',
			dataType="          . quote( $session{ form }{ dataType } )          . ',
			dataValues='        . quote( $session{ form }{ dataValues } )        . ',
			dataDefault='       . quote( $session{ form }{ dataDefault } )       . ',
			profileCategoryId=' . quote( $session{ form } {profileCategoryId } ) . '
			where fieldName='   . quote( $session{ form }{ fid } ) );
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
	return WebGUI::Privilege::adminOnly() unless ( WebGUI::Privilege::isInGroup( 3 ) );

	my $output = helpIcon( 22 )
		. '<h1>' . WebGUI::International::get( 308 ) . '</h1>';
	my $a = WebGUI::SQL->read( 'select * from userProfileCategory order by sequenceNumber' );

	tie my %category, 'Tie::CPHash';
	while ( %category = $a->hash ) {
		$output .= deleteIcon(    'op=deleteProfileCategory&cid='   . $category{ profileCategoryId } )
				. editIcon(     'op=editProfileCategory&cid='     . $category{ profileCategoryId } )
				. moveUpIcon(   'op=moveProfileCategoryUp&cid='   . $category{ profileCategoryId } )
				. moveDownIcon( 'op=moveProfileCategoryDown&cid=' . $category{ profileCategoryId } )
				. ' <b>'
				. eval $category{ categoryName }
				. '</b><br>';
		my $b = WebGUI::SQL->read( "select * from userProfileField where 
			profileCategoryId=$category{profileCategoryId} order by sequenceNumber" );
		tie my %field, 'Tie::CPHash';
		while ( %field = $b->hash ) {
			$output .= '&nbsp;' x 5
				. deleteIcon(   'op=deleteProfileField&fid='   . $field{ fieldName } )
				. editIcon(     'op=editProfileField&fid='     . $field{ fieldName } )
				. moveUpIcon(   'op=moveProfileFieldUp&fid='   . $field{ fieldName } )
				. moveDownIcon( 'op=moveProfileFieldDown&fid=' . $field{ fieldName } )
				. ' '
				. eval $field{ fieldLabel }
				. '<br>';
		}
		$b->finish;
	}
	$a->finish;
	return _submenu( $output );
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $thisSeq ) = WebGUI::SQL->quickArray( "select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}" );
	my ( $id )      = WebGUI::SQL->quickArray( "select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq+1" );
	if ( $id ne '' ) {
		WebGUI::SQL->write( "update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$session{form}{cid}" );
		WebGUI::SQL->write( "update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$id" );
		_reorderCategories();
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $thisSeq ) = WebGUI::SQL->quickArray( "select sequenceNumber from userProfileCategory where profileCategoryId=$session{form}{cid}" );
	my ( $id )      = WebGUI::SQL->quickArray( "select profileCategoryId from userProfileCategory where sequenceNumber=$thisSeq-1" );
	if ( $id ne '' ) {
		WebGUI::SQL->write( "update userProfileCategory set sequenceNumber=sequenceNumber-1 where profileCategoryId=$session{form}{cid}" );
		WebGUI::SQL->write( "update userProfileCategory set sequenceNumber=sequenceNumber+1 where profileCategoryId=$id" );
		_reorderCategories();
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $thisSeq, $profileCategoryId ) = WebGUI::SQL->quickArray( 'select sequenceNumber,profileCategoryId from userProfileField where fieldName=' . quote( $session{ form }{ fid } ) );
	my ( $id ) = WebGUI::SQL->quickArray( "select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq+1" );
	if ( $id ne '' ) {
		WebGUI::SQL->write( 'update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=' . quote( $session{ form }{ fid } ) );
		WebGUI::SQL->write( 'update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=' . quote( $id ) );
		_reorderFields( $profileCategoryId );
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
	return WebGUI::Privilege::adminOnly() unless WebGUI::Privilege::isInGroup( 3 );
	my ( $thisSeq, $profileCategoryId ) = WebGUI::SQL->quickArray( 'select sequenceNumber,profileCategoryId from userProfileField where fieldName=' . quote( $session{ form }{ fid } ) );
	my ( $id ) = WebGUI::SQL->quickArray( "select fieldName from userProfileField where profileCategoryId=$profileCategoryId and sequenceNumber=$thisSeq-1" );
	if ( $id ne '' ) {
		WebGUI::SQL->write( 'update userProfileField set sequenceNumber=sequenceNumber-1 where fieldName=' . quote( $session{ form }{ fid } ) );
		WebGUI::SQL->write( 'update userProfileField set sequenceNumber=sequenceNumber+1 where fieldName=' . quote( $id ) );
		_reorderFields( $profileCategoryId );
	}
	return www_editProfileSettings();
}


1;

