package DBIx::Tree::NestedSet::MySQL;

use strict;
use Carp;
$DBIx::Tree::NestedSet::MySQL::VERSION='0.12';

################################################################################
sub new{
    my $class=shift;
    $class=ref($class)||$class;
    my %params=@_;
    my $self={
	      dbh		=>	$params{dbh},
	      left_column_name	=>	$params{left_column_name}	|| 'lft',
	      right_column_name	=>	$params{right_column_name}	|| 'rght',
	      table_name	=>	$params{table_name}		|| 'nested_set',
	      id_name		=>	$params{id_name}		|| 'id',
	      no_alter_table	=>	$params{no_alter_table}		|| undef,
	      no_locking	=>	$params{no_locking}		|| undef
	     };
    bless $self, $class;
}
########################################


################################################################################
sub _lock_tables{
    my $self=shift;
    if(! defined $self->{no_locking}){
	$self->{dbh}->do(qq|lock tables $self->{table_name} as n1 write, $self->{table_name} as n2 write, $self->{table_name} write|) 
    }
}
########################################


################################################################################
sub _unlock_tables{
    my $self=shift;
    if(! defined $self->{no_locking}){
	$self->{dbh}->do(qq|unlock tables|)
    }
}
########################################


################################################################################
sub _alter_table{
    my($self,$name)=@_;
    my $table=$self->{table_name};
    $self->{dbh}->do("alter table $table add column $name varchar(255) not null default ''");
}
########################################


################################################################################
sub _create_default_table{
    my $self=shift;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    
    $dbh->do(_create_table_statement($table,$id,$left,$right));
}
########################################


################################################################################
sub _get_default_create_table_statement{
    my $self=shift;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    return _create_table_statement($table,$id,$left,$right);
}
########################################


################################################################################
sub _create_table_statement{
    my ($table,$id,$left,$right)=@_;
    return qq|
      CREATE TABLE $table (
			   $id mediumint(9) NOT NULL auto_increment,
			   $left mediumint(9) NOT NULL default '0',
			   $right mediumint(9) NOT NULL default '0',
			   PRIMARY KEY  ($id),
			   KEY $left ($left),
			   KEY $right ($right)
			  )
	|;
}
########################################

1;

__END__

=pod

=head1 NAME

DBIx::Tree::NestedSet::MySQL

=head1 SYNOPSIS

A driver class for L<DBIx::Tree::NestedSet> that implements a MySQL interface. There are no publicly available methods in this class.

=cut

