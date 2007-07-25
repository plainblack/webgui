package WebGUI::Image::Font;

use strict;
use WebGUI::Storage;

#-------------------------------------------------------------------
sub canDelete {
	my $self = shift;

	return 0 if ($self->getId =~ m/^default/);
	return 1;
}

#-------------------------------------------------------------------
sub delete {
	my $self = shift;

	if ($self->canDelete) {
		my $storage = WebGUI::Storage->get($self->session, $self->getStorageId);
		$storage->deleteFile($self->getFilename);
		
		$self->session->db->write('delete from imageFont where fontId=?', [
			$self->getId,
		]);
	}
}

#-------------------------------------------------------------------
sub getId {
	my $self = shift;

	return $self->{_properties}->{fontId};
}

#-------------------------------------------------------------------
sub getFontList {
	my $self = shift;
	my $session = shift || $self->session;

	return $session->db->buildHashRef('select fontId, name from imageFont');
}

#-------------------------------------------------------------------
sub getFile {
	my $self = shift;

	if ($self->getStorageId) {
		return WebGUI::Storage->get($self->session, $self->getStorageId)->getPath($self->getFilename);
	} else {
		return $self->session->config->getWebguiRoot."/lib/default.ttf"
	}
}

#-------------------------------------------------------------------
sub getFilename {
	my $self = shift;

	return $self->{_properties}->{filename};
}

#-------------------------------------------------------------------
sub getName {
	my $self = shift;

	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------
sub getStorageId {
	my $self = shift;

	return $self->{_properties}->{storageId};
}

#-------------------------------------------------------------------
sub new {
	my $class = shift;
	my $session = shift;
	my $fontId = shift;
	my $properties = {};

	if ($fontId eq 'new') {
		$fontId = $session->id->generate;

		$session->db->write('insert into imageFont (fontId) values (?)', [
			$fontId,
		]);
		$properties->{fontId} = $fontId;
	} else {
		$properties = $session->db->quickHashRef('select * from imageFont where fontId=?', [
			$fontId,
		]);

		unless ($properties->{fontId}) {
			$properties = $session->db->quickHashRef('select * from imageFont where fontId=?', [
				'defaultFont',
			]);
		}
	}

	bless {_properties => $properties, _session => $session}, $class;
}

#-------------------------------------------------------------------
sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------
sub setFilename {
	my $self = shift;
	my $filename = shift;
	
	$self->session->db->write('update imageFont set filename=? where fontId=?', [
		$filename,
		$self->getId,
	]);

	$self->{_properties}->{filename} = $filename;
}

#-------------------------------------------------------------------
sub setName {
	my $self = shift;
	my $name = shift;

	$self->session->db->write('update imageFont set name=? where fontId=?', [
		$name,
		$self->getId,
	]);

	$self->{_properties}->{name} = $name;
}

#-------------------------------------------------------------------
sub setStorageId {
	my $self = shift;
	my $storageId = shift;
	
	$self->session->db->write('update imageFont set storageId=? where fontId=?', [
		$storageId,
		$self->getId,
	]);

	$self->{_properties}->{storageId} = $storageId;
}

1;

