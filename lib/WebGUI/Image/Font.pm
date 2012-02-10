package WebGUI::Image::Font;

use strict;
use WebGUI::Storage;
use WebGUI::Paths;

#-------------------------------------------------------------------

=head2 canDelete 

=cut

sub canDelete {
	my $self = shift;

	return 0 if ($self->getId =~ m/^default/);
	return 1;
}

#-------------------------------------------------------------------

=head2 delete 

=cut

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

=head2 getId 

=cut

sub getId {
	my $self = shift;

	return $self->{_properties}->{fontId};
}

#-------------------------------------------------------------------

=head2 getFontList 

=cut

sub getFontList {
	my $self = shift;
	my $session = shift || $self->session;

	return $session->db->buildHashRef('select fontId, name from imageFont');
}

#-------------------------------------------------------------------

=head2 getFile 

=cut

sub getFile {
	my $self = shift;

	if ($self->getStorageId) {
		return WebGUI::Storage->get($self->session, $self->getStorageId)->getPath($self->getFilename);
	} else {
		return WebGUI::Paths->share . '/default.ttf';
	}
}

#-------------------------------------------------------------------

=head2 getFilename 

=cut

sub getFilename {
	my $self = shift;

	return $self->{_properties}->{filename};
}

#-------------------------------------------------------------------

=head2 getName 

=cut

sub getName {
	my $self = shift;

	return $self->{_properties}->{name};
}

#-------------------------------------------------------------------

=head2 getStorageId 

=cut

sub getStorageId {
	my $self = shift;

	return $self->{_properties}->{storageId};
}

#-------------------------------------------------------------------

=head2 new 

=cut

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

=head2 session 

=cut

sub session {
	my $self = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setFilename 

=cut

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

=head2 setName 

=cut

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

=head2 setStorageId 

=cut

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

