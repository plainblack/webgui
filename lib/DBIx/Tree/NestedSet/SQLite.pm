package DBIx::Tree::NestedSet::SQLite;

use strict;
use Carp;
$DBIx::Tree::NestedSet::SQLite::VERSION='0.12';

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

    #Transactions are automatically created by SQLite, according to the docs.

#    my $self=shift;
#    if(! defined $self->{no_locking}){
#	$self->{dbh}->do(qq|lock tables $self->{table_name} as n1 write, $self->{table_name} as n2 write, $self->{table_name} write|) 
#    }
}
########################################


################################################################################
sub _unlock_tables{

    #Transactions are automatically created by SQLite, according to the docs.

#    my $self=shift;
#    if(! defined $self->{no_locking}){
#	$self->{dbh}->do(qq|unlock tables|) 
#    }
}
########################################


################################################################################
sub _alter_table{
    my($self,$name)=@_;
    my $table=$self->{table_name};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $dbh=$self->{dbh};

    my ($base_create)=$dbh->selectrow_array('select sql from sqlite_master where tbl_name = ? and type="table"',undef,($table));
    $base_create =~ s/^\s?create\s+table\s+$table\s?(.+)/$1/gim;
    $dbh->do('create temporary table '.$table.'_temp'.$base_create);
    $dbh->do("insert into ${table}_temp select * from $table");
    my $recreate=$base_create;
    $recreate =~ s/(.+)\)$/$1/gim;
    $recreate .= ", $name text not null)";
    my $indeces=$dbh->selectcol_arrayref('select sql from sqlite_master where tbl_name=? and type="index"',undef,($table));
    $dbh->do("drop table $table");
    $dbh->do("create table $table ".$recreate);
    foreach (@$indeces) {
	$dbh->do($_);
    }
    $dbh->do("insert into $table select *,'' from ${table}_temp");
    $dbh->do("drop table ".$table."_temp");
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
    my ($create_table,$index1,$index2)=_create_table_statements($table,$id,$left,$right);
    $dbh->do($create_table);
    $dbh->do($index1);
    $dbh->do($index2);
}
########################################


################################################################################
sub _create_table_statements{
    my ($table,$id,$left,$right)=@_;
    return(qq|
	   CREATE TABLE $table (
				$id integer primary key,
				$left mediumint(9) NOT NULL,
				$right mediumint(9) NOT NULL
			       )
	   |,
	   qq|CREATE INDEX $left on $table($left)|,
	   qq|CREATE INDEX $right on $table($right)|
	  );
}
########################################


################################################################################
sub _get_default_create_table_statement{
    my $self=shift;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    return(join(";\n",_create_table_statements($table,$id,$left,$right))).";\n";
}
########################################

1;

=pod

=head1 NAME

DBIx::Tree::NestedSet::SQLite

=head1 SYNOPSIS

A driver class for L<DBIx::Tree::NestedSet> that implements an SQLite interface. There are no publicly available methods in this class.

=head1 WARNING

You should use this class and L<DBIx::Tree::NestedSet> to create your default table:  The way the create table is done in this class is pretty tightly tied to how the "automatic alteration" is done.

=cut

