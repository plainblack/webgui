package DBIx::Tree::NestedSet;

use strict;
use Carp;
$DBIx::Tree::NestedSet::VERSION='0.12';

#POD Below!!

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
	      db_type		=>	$params{db_type}		|| 'MySQL',
	      no_locking	=>	$params{no_locking}		|| undef
	     };
    bless $self, $class;
    croak("Not a DBI connection")
      unless($params{dbh}->isa('DBI::db'));

    foreach('left_column_name','right_column_name','table_name','id_name'){
	croak('"'.$self->{$_}."\" doesn't look like a valid SQL table or column name to me")
	  unless ($self->{$_} =~ m/^[_A-Za-z\d]+$/);
    }

    my $db_type=$self->{db_type};
    
    my $driver = "DBIx::Tree::NestedSet::$db_type";
    eval "require $driver;" or
      croak("That DBD source doesn't have a driver implemented yet");

    my $db_obj=$driver->new(
			    dbh			=>	$self->{dbh},
			    left_column_name	=>	$self->{left_column_name},
			    right_column_name	=>	$self->{right_column_name},
			    table_name		=>	$self->{table_name},
			    no_alter_table	=>	$self->{no_alter_table},
			    id_name		=>	$self->{id_name},
			    no_locking		=>	$self->{no_locking}
			   );
    $self->{_db_obj}=$db_obj;
    #$self->{start_id}=$params{start_id}|| scalar $self->{dbh}->selectrow_array('select min('.$self->{left_column_name}.')  from '.$self->{table_name} );
    $params{dbh}->{RaiseError} = 1 if(not defined $params{No_RaiseError});
    $params{dbh}->trace($params{trace}) if($params{trace});
    return $self;
}
########################################


################################################################################
sub get_root{
    my $self=shift;
    my $left=$self->{left_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    my ($min_left)=$self->{dbh}->selectrow_array("select min($left) from $table");
    return scalar $self->{dbh}->selectrow_array("select $id from ".$self->{table_name}." where $left=?",undef,($min_left));
}
########################################


################################################################################
sub _lock_tables{
    my $self=shift;
    $self->{_db_obj}->_lock_tables;
}
########################################


################################################################################
sub _unlock_tables{
    my $self=shift;
    $self->{_db_obj}->_unlock_tables;
}
########################################


################################################################################
sub _fix_root{
    my $self=shift;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    $self->_lock_tables();
    if (not defined $self->{_prepared_fix_table_root_SQL_statement}){
	$self->{_prepared_fix_table_root_SQL_statement}=$self->{dbh}->prepare("update $table set $right = ? where $left = 1");
    }
    if(not defined $self->{_prepared_table_count_SQL_statement}){
	$self->{_prepared_table_count_SQL_statement}=$self->{dbh}->prepare("select count(*) from $table");
    }
    my ($count)=$self->{dbh}->selectrow_array($self->{_prepared_table_count_SQL_statement});
    $self->{_prepared_fix_table_root_SQL_statement}->execute($count * 2);
    $self->_unlock_tables();
}
########################################


################################################################################
sub add_child_to_right{
    my($self,%params)=@_;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    $self->_lock_tables();
    if(!$params{id} && scalar $dbh->selectrow_array("select count(*) from $table")){
	#They haven't given us an id for this child.  Assume they want to add a child DIRECTLY 
	#under the parent, as they can't have more than one root.
	$params{id}=$self->get_root();
    }
    if(not defined $self->{_prepared_rightmost_SQL_statement}){
	$self->{_prepared_rightmost_SQL_statement}=$dbh->prepare("SELECT $right FROM $table WHERE $id=?");
    }
    my ($rightmost)=$dbh->selectrow_array($self->{_prepared_rightmost_SQL_statement},undef,($params{id}));
    if(not defined $self->{_prepared_rightmost_SQL_tree_fix_statement}){
	$self->{_prepared_rightmost_SQL_tree_fix_statement}=
	  $dbh->prepare(
			"UPDATE $table SET $left = CASE WHEN $left > ? THEN $left + 2 ELSE $left END,
$right = CASE WHEN $right >= ? THEN $right + 2  ELSE $right END WHERE $right >= ?"
		       );
    }
    $self->{_prepared_rightmost_SQL_tree_fix_statement}->execute($rightmost,$rightmost,$rightmost);
    my ($params,$values)=_get_params_and_values(\%params,$left,$right,$id);
    my ($columns,$placeholders)=_prepare_columns_and_placeholders_for_adding_child_to_right($params,$left,$right);
    $self->_alter_table_if_needed($params);
    my $insert=$dbh->prepare("INSERT INTO $table ($columns) VALUES($placeholders)");
    $insert->execute($rightmost||1,$rightmost||1,@$values);
    my ($new_id)=$dbh->do("select max($id) from $table");
    $self->_unlock_tables();
    return $new_id;
}
########################################


################################################################################
sub add_child_to_left{
    my($self,%params)=@_;
    my $dbh=$self->{dbh};
    
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    
    $self->_lock_tables();
    if(!$params{id} && scalar $dbh->selectrow_array("select count(*) from $table")){
	#They haven't given us an id for this child.  Assume they want to add a child DIRECTLY 
	#under the parent, as they can't have more than one root.
	$params{id}=$self->get_root();
    }
    
    if(not defined $self->{_prepared_leftmost_SQL_statement}){
	$self->{_prepared_leftmost_SQL_statement}=$dbh->prepare("SELECT $left FROM $table WHERE $id=?");
    }
    my ($leftmost)=$dbh->selectrow_array($self->{_prepared_leftmost_SQL_statement},undef,($params{id}));
    if(not defined $self->{_prepared_leftmost_SQL_tree_fix_statement}){
	$self->{_prepared_leftmost_SQL_tree_fix_statement}=
	  $dbh->prepare(
			qq|UPDATE $table 
			SET $right = 
			CASE WHEN $right > ? 
			THEN $right + 2 
			ELSE $right END,
			$left = 
			CASE WHEN $left > ? 
			THEN $left + 2  
			ELSE $left 
			END 
			|
		       );
    }
    $self->{_prepared_leftmost_SQL_tree_fix_statement}->execute($leftmost,$leftmost);
    my ($params,$values)=_get_params_and_values(\%params,$left,$right,$id);
    my ($columns,$placeholders)=_prepare_columns_and_placeholders_for_adding_child_to_left($params,$left,$right);
    $self->_alter_table_if_needed($params);
    my $insert=$dbh->prepare("INSERT INTO $table ($columns) VALUES($placeholders)");
    $insert->execute($leftmost||1,$leftmost||1,@$values);
    $insert->finish();
    my ($new_id)=$dbh->do("select max($id) from $table");
    $self->_unlock_tables();
    return $new_id;
}
########################################


################################################################################
sub _alter_table_if_needed{
    #$params is an arrayref with all the proper columns in order.
    my ($self,$params)=@_;

    #We don't want to invoke the "automagical" table altering behavior
    return if(defined $self->{no_alter_table});

    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $dbh=$self->{dbh};
    my $id=$self->{id_name};

    #my %columns_we_are_requesting=map{$_=>1} @$params;
    my @columns_we_need_to_create;
    #With MySQL I could use "Explain $table" but I'd like this to be a bit more cross-RDBMS
    my $get_columns=$dbh->prepare("select *,count(*) as _ignore_me_sdfas from nested_set group by $id");
    $get_columns->execute();
    my %columns_that_we_have={};
    foreach(@{$get_columns->{NAME}}){
	$columns_that_we_have{$_}=1 if($_ ne '_ignore_me_sdfas');
    }
    $get_columns->finish();
    foreach(@$params){
	push @columns_we_need_to_create, $_ if(not defined $columns_that_we_have{$_});
    }
    my $db_obj=$self->{_db_obj};
    foreach(@columns_we_need_to_create){
	croak('"'.$_."\" doesn't look like a valid SQL table or column name to me")
	  unless ($_ =~ m/^[_A-Za-z\d]+$/);
	$db_obj->_alter_table($_);
	$dbh->do("create index $_ on  $table($_)");
    }
}
########################################


################################################################################
sub _get_params_and_values{
    my ($params,$left,$right,$id,$no_left_or_right)=@_;
    my %ignore=(
		$left=>1,
		$right=>1,
		$id=>1
	       );
    my @params=($no_left_or_right) ? () :($left,$right); #Keep in order. . .
    my @values;
    foreach my $column (keys %$params){
	if (not defined $ignore{$column}){
	    push @params, $column;
	    push @values, $params->{$column}||''
	}
    }
    return (\@params,\@values);
}
########################################


################################################################################
sub edit_node{
    my ($self,%params)=@_;
    my $dbh=$self->{dbh};
    
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    $self->_lock_tables();
    my ($params,$values)=_get_params_and_values(\%params,$left,$right,$id,1);
    my ($columns)=_prepare_columns_and_placeholders_for_edit($params);
    $self->_alter_table_if_needed($params);
    my $update=$dbh->prepare("update $table set $columns where $id=?");
    $update->execute(@$values,$params{id});
    $update->finish();
    $self->_unlock_tables();
}
########################################


################################################################################
sub _prepare_columns_and_placeholders_for_edit{
    my ($params)=@_;
    my $columns=join('=? ,',(@$params)).'=?';
    return ($columns);
}
########################################


################################################################################
sub _prepare_columns_and_placeholders_for_adding_child_to_right{
    my ($params,$left,$right)=@_;
    my $columns=join(',',(@$params));
    my $placeholders=join(',',('?','? + 1')).
      ((scalar @$params -2 > 0) ? ',':''). #If there isn't more than 2 params, don't put in a comma
	substr(('?,' x (scalar @$params -2 )),0,-1);
    return ($columns,$placeholders);
}
########################################


################################################################################
sub _prepare_columns_and_placeholders_for_adding_child_to_left{
    my ($params,$left,$right)=@_;
    my $columns=join(',',(@$params));
    my $placeholders=join(',',('? + 1','? + 2')).
      ((scalar @$params -2 > 0) ? ',':''). #If there isn't more than 2 params, don't put in a comma
	substr(('?,' x (scalar @$params -2 )),0,-1);
    return ($columns,$placeholders);
}
########################################


################################################################################
sub get_id_by_key{
    my($self,%params)=@_;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $key_name=$params{key_name};
    my $id=$self->{id_name};
    my $ids=$self->{dbh}->selectcol_arrayref("select $id from $table where $key_name = ?",undef,($params{key_value}));
    return (@$ids > 1) ? $ids : $ids->[0] ;
}
########################################


################################################################################
sub get_self_and_parents_flat{
    my($self,%params)=@_;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
#    my $node=$self->{node_column_name};
    if(not defined $self->{_prepared_get_self_and_parents_flat_SQL_statement}){
	$self->{_prepared_get_self_and_parents_flat_SQL_statement}=$dbh->prepare("select n2.* from $table as n1, $table as n2 where (n1.$left between n2.$left and n2.$right) and (n1.$id=?) order by n2.$left");
    }
    my $tree_structure=$dbh->selectall_arrayref($self->{_prepared_get_self_and_parents_flat_SQL_statement},{Columns=>{}},($params{id} || 1));
    my $level=1;
    foreach(@$tree_structure){
	$_->{level}=$level;
	$level++;
    }
    return $tree_structure;
}
########################################


################################################################################
sub get_parents_flat{
    my $self=shift;
    my $tree=$self->get_self_and_parents_flat(@_);
    my $poo=pop @$tree if(@$tree);
    return $tree;
}
########################################


################################################################################
sub delete_self_and_children{
    my ($self,%params)=@_;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    if(!$params{id}){
	carp("You didn't give us an ID that we could start the delete from");
	return [];
    } else {
	$self->_lock_tables();
	my $ids;
	if($params{not_self}){
	    #We don't want to delete the starting node.
	    #Start with the next level and go through them.

	    my $outer_tree=$self->get_children_flat(id=>$params{id},depth=>1);
	    foreach my $outer_node(@$outer_tree){
		my $temp_tree=$self->get_self_and_children_flat(id=>$outer_node->{$id});
		$self->_delete_node(id=>$outer_node->{$id});
		foreach my $inner_node (@$temp_tree){
		    push @$ids,$inner_node->{id};
		}
	    }
	    
	} else {
	    #Delete it all. Hasta la bye-bye!
	    my $tree=$self->get_self_and_children_flat(id=>$params{id});
	    $self->_delete_node(%params);
	    foreach my $node (@$tree){
		push @$ids,$node->{id};
	    }
	}
	$self->_unlock_tables();
	return $ids;
    }
}
########################################


################################################################################
sub delete_children{
    my $self=shift;
    $self->delete_self_and_children(@_,not_self=>1);
}
########################################


################################################################################
sub _delete_node{
    my($self,%params)=@_;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    my $dbh=$self->{dbh};
    my $node_info=$self->get_hashref_of_info_by_id($params{id});

    if(not defined $self->{_prepared_delete_node_delete_statement}){
	$self->{_prepared_delete_node_delete_statement}=$dbh->prepare("delete from $table where $left between ? and ?");
    }
    $self->{_prepared_delete_node_delete_statement}->execute($node_info->{$left},$node_info->{$right});
    
    if(not defined $self->{_prepared_delete_node_fix_nodes}){
	$self->{_prepared_delete_node_fix_nodes}=
	  $dbh->prepare("UPDATE $table
     SET $left = CASE
                 WHEN $left > ? THEN $left - (? - ? + 1)
                 ELSE $left
               END,
         $right = CASE
                 WHEN $right > ? THEN $right - (? - ? + 1)
                 ELSE $right
               END
   WHERE $right > ?
");
	
    }
    $self->{_prepared_delete_node_fix_nodes}->execute(
						      $node_info->{$left},
						      $node_info->{$right},
						      $node_info->{$left},
						      $node_info->{$right},
						      $node_info->{$right},
						      $node_info->{$left},
						      $node_info->{$left},
						     );

}
########################################


################################################################################
sub get_self_and_children_flat{
    my($self,%params)=@_;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
#    my $node=$self->{node_column_name};
    my $id_SQL;
    if (defined $params{id}) {
	my ($left_value,$right_value)=$dbh->selectrow_array("select $left,$right from $table where $id=?",undef,($params{id}));
	$id_SQL="and (n1.$left between " . $dbh->quote($left_value)." and ".$dbh->quote($right_value).") ";
    }
    my $tree_structure=$dbh->selectall_arrayref("select count(n2.${id}) as level,n1.* from $table as n1, $table as n2 where (n1.$left between n2.$left and n2.$right) $id_SQL group by n1.${id} order by n1.$left",{Columns=>{}});
    my $start_level=$tree_structure->[0]->{level};
    if (defined $params{depth} && $tree_structure) {
	#We wanna chop down the tree.
	my @temp_tree;
	if (defined $params{depth}) {
	    foreach my $node (@$tree_structure) {
		if ($node->{level} <= ($params{depth} + $start_level)) {
		    push @temp_tree,$node;
		}
	    }
	}
	return \@temp_tree;
    } else {
	return $tree_structure;
    }
}
########################################


################################################################################
sub get_children_flat{
    my $self=shift;
    my $tree=$self->get_self_and_children_flat(@_);
    my $poo=shift @$tree if(@$tree);
    return $tree;
}
########################################


################################################################################
sub swap_nodes{
    my($self,%params)=@_;
    my $dbh=$self->{dbh};
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};

    my $first_id=$params{first_id};
    my $second_id=$params{second_id};
    croak("You didn't give me valid IDs to swap!\n") if(! $first_id || ! $second_id);
    croak("You can't switch a node with itself!\n") if($first_id == $second_id);

    $self->_lock_tables();
    my $first_id_info=$self->get_hashref_of_info_by_id($first_id);
    my $second_id_info=$self->get_hashref_of_info_by_id($second_id);

    my ($left_node,$right_node);
    if($first_id_info->{$left} < $second_id_info->{$left}){
	$left_node=$first_id_info;
	$right_node=$second_id_info;
    } else {
	$left_node=$second_id_info;
	$right_node=$first_id_info;
    }
    $dbh->do(qq|update $table set 
	     $left =
	     CASE WHEN $left between $left_node->{$left} and $left_node->{$right}
	     THEN $right_node->{$right} + $left - $left_node->{$right}
	     WHEN $left between $right_node->{$left} and $right_node->{$right}
	     THEN $left_node->{$left} + $left - $right_node->{$left}
	     ELSE $left_node->{$left} + $right_node->{$right} + $left - $left_node->{$right} - $right_node->{$left} END,
	     $right =
	     CASE WHEN $right between $left_node->{$left} and $left_node->{$right}
	     THEN $right_node->{$right} + $right - $left_node->{$right}
	     WHEN $right between $right_node->{$left} and $right_node->{$right}
	     THEN $left_node->{$left} + $right - $right_node->{$left}
	     ELSE $left_node->{$left} + $right_node->{$right} + $right - $left_node->{$right} - $right_node->{$left} END
	     WHERE ($left between $left_node->{$left} and $right_node->{$right})
	     AND $left_node->{$left} < $left_node->{$right}
	     AND $left_node->{$right} < $right_node->{$left}
	     AND $right_node->{$left} < $right_node->{$right}|);
    
    $self->_unlock_tables();
}
########################################


################################################################################
sub get_hashref_of_info_by_id{
    my $id=$_[0]->{id_name};
    return $_[0]->{dbh}->selectrow_hashref("select * from ".$_[0]->{table_name}." where $id=?",undef,($_[1]));
}
########################################


################################################################################
sub get_hashref_of_info_by_id_with_level{
    my $self=shift;
    my $left=$self->{left_column_name};
    my $right=$self->{right_column_name};
    my $table=$self->{table_name};
    my $id=$self->{id_name};
    return $self->{dbh}->selectrow_hashref("select count(n2.$id) as level,n1.* from $table as n1, $table as n2 where (n1.$left between n2.$left and n2.$right) and n1.$id=? group by n1.$id",undef,($_[1]));
}
########################################


################################################################################
sub create_report{
    my ($self,%params)=@_;
    my $ancestors=$self->get_self_and_children_flat(id => $params{id}||$self->get_root);
    my $report;
    foreach (@$ancestors) {
	$report.= (($_->{level} > 1) ? ((" " x ($params{indent_level} || 2)) x ($_->{level} - 1)) :'');
	$report.= $_->{name}." (".$_->{id}.")(".$_->{level}.")\n";
    }
    return $report;
}
########################################


################################################################################
sub create_default_table{
    my $self=shift;
    $self->{_db_obj}->_create_default_table();
}
########################################


################################################################################
sub get_default_create_table_statement{
    my $self=shift;
    $self->{_db_obj}->_get_default_create_table_statement();
}
########################################


################################################################################
sub DESTROY{
    my $self=shift;
    foreach(keys %$self){
	if(substr($_,0,10) eq '_prepared_'){
	    warn("Finished: $_\n") if (defined $self->{trace});
	    $self->{$_}->finish();
	}
    }
}
########################################


1;


__END__

=pod

=head1 NAME

DBIx::Tree::NestedSet

=head1 SYNOPSIS

Implements a "Nested Set" parent/child tree.

=head1 DESCRIPTION

This module implements a "Nested Set" parent/child tree, and is focused (at least in my mind) towards offering methods that make developing web applications easier. It should be generally useful, though.

See the "SEE ALSO" section for resources that explain the advantages and features of a nested set tree.  This module gives you arbitrary levels of categorization,  the ability to put in metadata associated with a category via simple method arguments and storage via DBI.  It's been tested on MySQL but I've taken pains to avoid using MySQL specific SQL statements.

The basic thing is that a nested set tree is "expensive" on updates because you have to edit quite a bit of the tree on inserts, deletes, or the movement of nodes.  Conversely, it is "cheaper" on just queries of the tree because nearly every action (getting children, getting parents, getting siblings, etc) can be done *with one SQL query*.  So if you're developing apps that require many reads and few updates to a tree (like pretty much every web app I've ever built) a nested set should offer significant performance advantages over the recursive queries required by an adjacency list model.

Whew. Say that fast three times.

You'll need to create a table in your database and then pass options to new().  See the "Table Definition" section for an example "create table" statement.

=head1 METHODS

=head2 new

new() accepts a number of parameters. You MUST pass new() a valid DBI handle.

=over 4

=item dbh

The DBI handle returned by DBI::connect().

=item id_name

The name of the unique ID associated with this category. Defaults to "id".

=item left_column_name

The name of the column that describes the left hand side of a node.  Defaults to "lft".

=item right_column_name

The name of the column that describes the right hand side of a node.  Defaults to "rght".

=item table_name

The name of the table that describes the nested set. Defaults to "nested_set".

=item No_RaiseError

By default this module will turn on the "RaiseError" attribute in $dbh.  Setting the "No_RaiseError" value to true (because you do not want RaiseError enabled or because it is turned it on elsewhere) will disable this behavior.

=item no_locking

Setting this option to a true value will disable file locking for methods that alter the tree stored via DBI. Currently,  we lock the entire table, as most "editing" methods have the potential to edit every value on even minor changes.

=item no_alter_table

Don't do the automagical table altering stuff used to create columns on-the-fly. See "add_child_to_right" for a description of how this module stores meta-data. Turning off the automagical table altering will probably increase performance, but you won't be able to add in meta-data whenever you want on adding or updating nodes.

Turning off automagical table altering will cause the module to error out if you try and add in new meta-data that doesn't have a column defined for it in the DBI table. You are warned.

It probably makes sense to turn off automagical table altering after you've put the application into production and you're done development, but that depends on how you build your app.

=item trace

Will turn on DBI::trace() at the level you specify here and output some additional debugging info to STDERR.

=item db_type

The type of RDBMS you're using, currently drivers are only implemented for MySQL and SQLite. Defaults to MySQL if not defined. Drivers abstract non-portable (or non-implemented) SQL. See L<DBIx::Tree::NestedSet::MySQL> and L<DBIx::Tree::NestedSet::SQLite> for examples.

=back

Examples:

 #Create a nested set tree, including SQL
 my $tree=DBIx::Tree::NestedSet->new(dbh=>$dbh);
 $tree->create_default_table();

 #Create a nested set tree using SQLite and a few tweaked defaults
 my $tree=DBIx::Tree::NestedSet->new(dbh=>$dbh,db_type=>'SQLite',id_name=>'pageID');
 $tree->create_default_table();

=head2 create_default_table

Create a Nested Set table in the data source defined in $dbh that will work for the db_type you specify in new().  Any options (id_name, left_column_name, etc.) you pass to new() will be respected as well.

=head2 get_default_create_table_statement

Return the SQL used to create the table above as a scalar.

=head2 get_root

Gets the id of the "root" node of the tree.

=head2 add_child_to_right

This will add a child to the "right" of all its siblings.

Takes the following parameters as a hash:

=over 4

=item id

The ID of the parent node we want to add the child to. If you don't give an ID or the id isn't valid,  it will add the child under the root node.

=back

Any other parameter passed in as a hash will cause the module to alter the table to add a column to hold it, and then store that data for you. Example:

Say you have a table that looks like:

 +----------+--------------+------+-----+---------+----------------+
 | Field    | Type         | Null | Key | Default | Extra          |
 +----------+--------------+------+-----+---------+----------------+
 | id       | mediumint(9) |      | PRI | NULL    | auto_increment |
 | lft      | mediumint(9) |      | MUL | 0       |                |
 | rght     | mediumint(9) |      | MUL | 0       |                |
 | name     | varchar(255) |      | MUL |         |                |
 +----------+--------------+------+-----+---------+----------------+

and you execute:

 $tree->add_node_to_right(id=>$tree->get_root(),name=>'Foo Name',template=>'Bar');

Then the module will create a node named "Foo Name" under the root as the "rightmost" child. The "template" column will be created and "Bar" will be put in this nodes "template" column. The table would then look like:

 +----------+--------------+------+-----+---------+----------------+
 | Field    | Type         | Null | Key | Default | Extra          |
 +----------+--------------+------+-----+---------+----------------+
 | id       | mediumint(9) |      | PRI | NULL    | auto_increment |
 | lft      | mediumint(9) |      | MUL | 0       |                |
 | rght     | mediumint(9) |      | MUL | 0       |                |
 | name     | varchar(255) |      | MUL |         |                |
 | template | varchar(255) |      | MUL |         |                |
 +----------+--------------+------+-----+---------+----------------+

Feel free to tweak the columns after the module creates them (or create them in advance, it doesn't really matter).  You may want to add indeces if you're going to be doing other selects on the nested_set table.

This table altering behavior allows you to store metadata about a node simply, with a tradeoff that your metadata could be "flat" and potentially poorly normalized.

Returns the id of the newly added child.

=head2 add_child_to_left

Same as add_child_to_right, except this puts the child to the left of its siblings.

=head2 edit_node

Edits a node and will exhibit the same "table altering" behavior of add_child_to_right. Pass in parameters as a hash, and "id" controls which node you're editing.

Example:

 #All other values are retained, we're just changing the name of the node
 #with the id in "$edit_id"
 $tree->edit_node(id=>$edit_id,name=>'New Name');

=head2 get_id_by_key

Looks up a node(s) by a key name and key value.  Takes two parameters:

=over 4

=item key_name

The name of the column in the database you're doing a lookup on.

=item key_value

The value you want to look up.

=back

If there is more than one node found,  we return an array reference. Otherwise we return a scalar. If nothing is found, you'll get a non-true value.

Example:

 my $node=$tree->get_id_by_key(key_name=>'name',key_value=>'Foo Name');
 if(ref $node){
     #We have more than one id returned.
 } else {
     #We have a single id/node.
 }

=head2 get_self_and_parents_flat

This will get a node and it's parents down to the root node.  Takes the id of the starting node as a hash.

Returns an arrayref of hashrefs (AoH).  The hashrefs will have as keys the column names of the table, including those automatically added by the add_*() and edit_node() methods.

This method does NOT return a "nested hash" or "nested array" of nodes, hence the "flat" in the method name.

Additionally there will be a "level" hashkey that's the level of the node, with level 1 being the root.

Example:

 my $self_and_parents=$tree->get_self_and_parents(id=>$starting_id);
 foreach(@$self_and_parents){
     print 'ID: '.$_->{id}.' is at level '.$_->{level}."\n";
 }

Besides arrays of hashrefs being easy to use,  this object is PERFECT for passing to HTML::Template::param(). Returns non-true in the event a node doesn't have parents.

=head2 get_parents_flat

Same as get_self_and_parents_flat but excludes the starting node.

=head2 delete_self_and_children

Similar to get_self_and_children, but deletes nodes from the starting id inclusively.  Returns an arrayref of the IDs that were deleted or a non-true value if none.

Example:
 my $ids=$tree->delete_self_and_children(id=>$delete_from);

Will delete from the ID in $delete_from and $ids will contain an arrayref of the deleted IDs. 

=head2 delete_children

Similar to delete_self_and_children, but leaves the starting id untouched. This method just deletes the children (recursively) of the starting node.

=head2 get_self_and_children_flat

Nearly identical to get_self_and_parents flat, except it retrieves the children of the starting node (and the starting node itself) recursively.

Takes a depth parameter additionally, which will specify how far down in the tree from the starting node to go.

Example:

 my $self_and_children=$tree->get_self_and_children_flat(id=>$start_id,depth=>2);

Will retrieve an AoH starting from $start_id going down a maximum of 2 levels.

=head2 get_children_flat

Same as get_self_and_children_flat but excludes the starting node.

=head2 swap_nodes

Takes two parameters: first_id and second_id. It will "swap" the nodes represented by these ids, essentially replacing one node with the other.  Children will tag along and order will be preserved.  swap_nodes() can be used to reorder nodes in a tree OR swap nodes to different levels within a tree.

Example:

 $tree->swap_nodes(first_id=>$first_id,second_id=>$second_id);

$first_id and $second_id will be "swapped" in the tree.

=head2 get_hashref_of_info_by_id

Will return a hashref of the information associated with a node specified by the "id" parameter.  Umm. . . Except "level".

This is probably dumb, but in this case you don't need to pass in the ID as a hash, because this method only every takes one argument.  Returns "undef" if a node without that ID isn't found.

Example:

 my $node_info=$tree->get_hashref_of_info_by_id($node_id);
 print $node_info->{id};

=head2 get_hashref_of_info_by_id_with_level

Just like get_hashref_of_info_by_id, except returns the "level" of the node within the tree as well, where the "root" node is level 1.  Computing the level is quite a bit more expensive, so you should use get_hashref_of_info_by_id normally.

=head2 create_report

Returns a very simple report (in a scalar) of the tree. Takes a few parameters:

=over 4

=item id

The id to start the report from. If none is given, it'll start from the root node.

=item indent_level

The number of spaces to indent each level with. Defaults to 2 spaces per level.

=back

Example:

 my $report=$tree->create_report(indent_level=>4);
 print $report;

Will create a report starting from the "root" with 4 spaces of indentation per level.

=head1 TABLE DEFINITION

The base "nested_set" table definition for MySQL is below. Please see each driver class (L<DBIx::Tree::NestedSet::MySQL> or L<DBIx::Tree::NestedSet::SQLite> currently) for create statements specific to your RDBMS.  Columns will be added when you pass extra parameters to methods noted above, unless "no_alter_table" is set to true in the constructor.

You can add columns you're going to use proactively, and/or "tweak" the columns after you've let this module create them.  Just make sure that you use valid SQL column names for the attributes you pass to the edit_node() and add_*() methods.

 ########################################
 #MySQL specific.
 CREATE TABLE nested_set (
   id mediumint(9) NOT NULL primary key,
   lft mediumint(9) NOT NULL,
   rght mediumint(9) NOT NULL
 );
 CREATE INDEX lft nested_set(lft);
 CREATE INDEX rght nested_set(rght);
 ########################################

This module has been tested on MySQL 3.x and 4.x and SQLite 2.x.

=head1 WHY?

I've implemented a couple different nested tree models in the past, from a flat "one column per level" monstrosity to a typical "adjacency list" parent/child model.  

The "one column per level" model was a BEAR to work with, especially when it came to adding more levels, editing/deleting children and creating parent lists.

An "adjacency list" is the typical "id/parent_id" model, as illustrated below:

           food                food_id   parent_id
           ==================  =======   =========
           Food                001       NULL
           Beans and Nuts      002       001
           Beans               003       002
           Nuts                004       002
           Black Beans         005       003
           Pecans              006       004

(That table was ripped off directly from DBIx::Tree)

The recursive queries involved with "adjacency list" models always bugged me and I couldn't get acceptable performance metrics without caching bits of the tree.

The "nested set" model appears, theoretically, to be perfect for most of the web applications I develop: it's very fast to create lists of children and parents, at the cost of much more complicated and processor-intense updating.

I've also taken pains to create methods that are useful for web application development but not specific to it.

If you have an application that sees many reads of a nested tree but not as many writes or updates, the "nested set" model this module implements should offer significant performance benefits over an adjacency list.

=head1 SEE ALSO

DBIx::Tree, which implements an "adjacency list" model of nested trees.  

DBIx::NestedSet::Manage which is included with this distribution and implements a CGI::Application and HTML::Based system for managing trees via DBIx::NestedSet and implements most DBIx::NestedSet methods.

  http://www.intelligententerprise.com/001020/celko.jhtml
  http://www.dbmsmag.com/9603d06.html
  http://www.dbmsmag.com/9604d06.html
  http://www.dbmsmag.com/9605d06.html
  http://www.dbmsmag.com/9606d06.html

For those last three links, the "Nested Set" discussion starts about halfway through the articles.

=head1 BUGS

Yes. I'm sure there are some.  Please contact me if you find any.

Things to avoid:

=over 4

=item *

Keep the names of columns, the table,  and any automagically added meta-data keys to fit m/^[_A-Za-z\d]+$/, which is A-Z, a-z, digits, and the underscore. And don't use SQL reserved words.

=back

=head1 TODO

I may implement some or all of these. PATCHES ARE WELCOME!

=over 4

=item *

Methods to translate an adjacency list into a nested set tree.

=item *

The ability to associate other user-defined SQL statements with methods. "Pre-" and "post-" triggered SQL.

=item *

Create methods to get children that DO implement "nested array" trees.

=item *

Do benchmarking to see how a nested set model performs under various scenarios.

=item *

Maybe create a "traversal" system other than the very simple: 

 my $nodes=$tree->get_self_and_children(id=$tree->get_root);
 foreach my $node(@$nodes){
     #do something with the hashref that represents this node.
 }

=back

=head1 THANKS

The following folks have provided patches, bug alerts, ideas, guidance and suggestions related directly to this module. THANKS! Sorry if I left anyone out.

=over 4

=item Giuseppe Maxia

gmax on www.perlmonks.org. He pushed me to make it more RDBMS-independent and offered other suggestions to improve the module and documentation.

=item Martin Kamerbeek

www.procolix.com, a core WebGUI developer. One of the original guineau pigs. Bug fixes and feature enhancements.

=item Hansen 

On www.perlmonks.org,  algorithm improvement for node dropping.

=item Tilly 

On www.perlmonks.org for the original idea.

=back

=head1 AUTHOR

Dan Collis Puro, Geekuprising.com.  Email: dan at geekuprising dot com.

This model was inspired by the perlmonks.org thread below:

http://www.perlmonks.org/index.pl?node_id=354049

See "Tilly's" response in particular. I'm "Hero Zzyzzx".

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
