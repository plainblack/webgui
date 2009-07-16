package WebGUI::CryptTest;

use Class::InsideOut qw{ :std };


readonly session => my %session;
private cryptEnabled => my %cryptEnabled;
readonly testField => my %testField;
readonly testTable => my %testTable;
private crypt => my %crypt;

sub new{
    my ($class,$session,$testText) = @_;
    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $session{$id} = $session;
    $testField{id $self} = 'testField';
    $testTable{id $self} = 'encryptTest';
    $crypt{id $self} = WebGUI::Crypt->new($session);
    $self->_setCryptDefault();
    $self->_createTestTable($testText);
    return $self;
}

sub findSimpleProvider{
    my ($self) = @_;
    my $crypts = $session{id $self}->config->get('crypt');
    for my $key (keys %$crypts){
        if($crypts->{$key}->{provider} eq 'WebGUI::Crypt::Simple'){
            return ($crypts->{$key},$key);
            last;
        }
    }
    return;
}

sub _createTestTable{
    my ($self,$text) = @_;
    $self->session->db->write("drop table if exists `encryptTest`");
    $self->session->db->write("CREATE TABLE `encryptTest` ( `id` char(22)  NOT NULL, `testField` LONGTEXT  NOT NULL)");
    $self->session->db->write("insert into $testTable{id $self} values ('1',?) on duplicate key update $testField{id $self} = ?",[$text,$text]);
}

sub _setCryptDefault{
    my ($self) = @_;
    $cryptEnabled{id $self} = $self->session->setting->get('cryptEnabled');
    $self->session->setting->set('cryptEnabled',1);
}

sub DEMOLISH{
    my ($self) = @_;
    $self->session->setting->set('cryptEnabled',$cryptEnabled{id $self});
    $self->session->db->write("drop table if exists $testTable{id $self}");
    $self->session->db->write("delete from cryptFieldProviders where `field` = '$testField{id $self}' and `table` = '$testTable{id $self}' and `key` = 'id'");
}
1;
