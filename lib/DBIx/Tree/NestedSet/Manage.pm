package DBIx::Tree::NestedSet::Manage;

use strict;
use Carp;
use base 'CGI::Application';
$DBIx::Tree::NestedSet::Manage::VERSION='0.12';

#POD Below!!

################################################################################
sub setup {
    my $self=shift;
    $self->start_mode('show_nodes');
    $self->mode_param('rm');
    $self->run_modes(
		     show_nodes=>'show_nodes',
		     add_child_form=>'add_child_form',
		     move_up=>'move_up',
		     move_down=>'move_down',
		     delete_node=>'delete_node',
		     edit_node=>'edit_node',
		     denied=>'denied',
		     'AUTOLOAD'=>'show_nodes'
		    );
}
########################################


################################################################################
sub cgiapp_init{
    my $self=shift;
    my $q=$self->query();
    $self->param(
		 template=>$self->load_tmpl(
					    $self->param('template_name'),
					    die_on_bad_params=>0
					   )
		);
}
########################################


################################################################################
sub stuff_in_extra_info{
    my ($self,$array)=@_;
    my $q=$self->query();
    my $script_name=$q->script_name();
    my $upper_sibling;
    my $lower_sibling;
    my $i=1;
    foreach (@$array) {
	$_->{LOWER_SIBLING}=$array->[$i]->{id} if($array->[$i]);
	$_->{UPPER_SIBLING}=$upper_sibling;
	$_->{SCRIPT_NAME}=$script_name;
	$upper_sibling=$_->{id};
	$i++;
    }
}
########################################


################################################################################
sub show_nodes{
    my $self=shift;
    my $q=$self->query();
    my $tree=$self->param('tree');
    my $template=$self->param('template');
    my $id = $q->param('id') || $self->param('start_root') || $tree->get_root();
    
    my $current_nodes=$tree->get_children_flat(
					       id	=>	$id,
					       depth	=>	1
					      );
    #my $foo=shift @$current_nodes;
    my $parents=$tree->get_self_and_parents_flat(id=>$id);
    
    $self->stuff_in_extra_info($parents);
    $self->stuff_in_extra_info($current_nodes);
    my $node_info=$tree->get_hashref_of_info_by_id($id);
    $template->param(
		     SHOW_NODES=>1,
		     CURRENT_NODES=>$current_nodes,
		     PARENTS=>$parents,
		     CURRENT_ID=>$id,
		     NAME=>$node_info->{name}
		    );
    return $template->output();
}
########################################


################################################################################
sub redirect_to_category{
    my ($self,$id)=@_;
    my $q=$self->query();
    $self->header_type('redirect');
    $self->header_add(-location=>$q->script_name().'?rm=show_nodes;id='.$q->escape($id));
}
########################################


################################################################################
sub add_child_form{
    my $self=shift;
    my $q=$self->query();
    my $tree=$self->param('tree');
    my $template=$self->param('template');
    my $id = $q->param('id') || $self->param('start_root') || $tree->get_root();
    
    my $errors={};
    if($q->param('submit')){
	if(! $q->param('name')){
	    $errors->{NO_NAME}=1;
	} else {
	    $tree->add_child_to_right(id=>$id,name=>$q->param('name'));
	    return $self->redirect_to_category($id);
	}
    }
    my $node_info=$tree->get_hashref_of_info_by_id($id);
    my $form .= 
      $q->start_form().
	$q->hidden(-name=>'rm',-value=>'add_child_form',-override=>1).
	  $q->hidden(-name=>'id').
	    $q->textfield(-name=>'name').
	      $q->submit(-name=>'submit').
		$q->end_form();
    $template->param(
		     ADD_CHILD_FORM=>1,
		     FORM=>$form,
		     ERRORS=>$errors,
		     PARENT=>$node_info->{name},
		     ERROR_NO_NAME=>$errors->{NO_NAME}
		    );
    return $template->output();
}
########################################


################################################################################
sub move_up{
    my $self=shift;
    my $q=$self->query;
    my $tree=$self->param('tree');
    my $up_id=$q->param('up_id');
    my $id=$q->param('id');
    if($id && $up_id){
	my $parents=$tree->get_self_and_parents_flat(id=>$id);
	$tree->swap_nodes(first_id=>$id,second_id=>$up_id);
	return $self->redirect_to_category($parents->[-2]->{id} || $tree->get_root);
    }
}
########################################


################################################################################
sub move_down{
    my $self=shift;
    my $q=$self->query;
    my $tree=$self->param('tree');
    my $down_id=$q->param('down_id');
    my $id=$q->param('id');
    if($id && $down_id){
	my $parents=$tree->get_self_and_parents_flat(id=>$id);
	$tree->swap_nodes(first_id=>$id,second_id=>$down_id);
	return $self->redirect_to_category($parents->[-2]->{id} || $tree->get_root);
    }
}
########################################


################################################################################
sub confirm_node_can_be_deleted{
#     You should customize this method to check for you own
#     criteria as to what nodes may be deleted.
#     my $self=shift;
#     my $dbh=$self->param('dbh');
#     my $q=$self->query();
#     my $tree=$self->param('tree');
#     my $nodes=$tree->get_self_and_children_flat(id=>$q->param('id'));
#     my @ids=map{$dbh->quote($_->{id})} @$nodes;
#     my $id_sql=join(',',@ids);
#     my ($count)=$dbh->selectrow_array(qq|select count(*) from doc_categories where primary_cat in($id_sql)|);
#     #If there's a positive count, we can't delete.
#     return ($count) ? 0 : 1 ;
    return 1;
}
########################################


################################################################################
sub delete_node{
    my $self=shift;
    my $q=$self->query();
    my $tree=$self->param('tree');
    my $id=$q->param('id');
    my $confirm_node_can_be_deleted=$self->confirm_node_can_be_deleted();
    if($q->param('confirm') && $id && $confirm_node_can_be_deleted){
	my $parents=$tree->get_self_and_parents_flat(id=>$id);
	$tree->delete_self_and_children(id=>$id);
	return $self->redirect_to_category($parents->[-2]->{id} || $tree->get_root);
    } else {
	my $template=$self->param('template');
	my $node_info=$tree->get_hashref_of_info_by_id($id);
	$template->param(
			 CONFIRM_NODE_DELETION=>1,
			 NODE_CAN_BE_DELETED=>$confirm_node_can_be_deleted,
			 SCRIPT_NAME=>$q->script_name(),
			 NODE_NAME=>$node_info->{name},
			 ID=>$id,
			);
	return $template->output();
    }
}
########################################


################################################################################
sub denied{
    return 'Access is denied.';
}
########################################


################################################################################
sub edit_node{
    my $self=shift;
    my $q=$self->query();
    my $id=$q->param('id');
    my $tree=$self->param('tree');
    my $node_info=$tree->get_hashref_of_info_by_id($id);
    
    if($q->param('name')  && $id){
	# We passed tests.
	$tree->edit_node(id=>$id,name=>$q->param('name'));
	my $parents=$tree->get_self_and_parents_flat(id=>$id);
	return $self->redirect_to_category($parents->[-2]->{id} || $tree->get_root);
    } else {
	my $form={};
	$form->{START_FORM}=$q->start_form().
	  $q->hidden(-name=>'rm',-value=>'edit_node',-override=>1).
	    $q->hidden(-name=>'id');
	$form->{NAME_TEXTFIELD}= $q->textfield(-name=>'name',-value=>$node_info->{name});
	$form->{SUBMIT}=$q->submit(-name=>'submit',-value=>'Edit Node');
	$form->{END_FORM}=$q->end_form();

	$form->{EDIT_NODE}=1;
	$form->{SCRIPT_NAME}=$q->script_name;
	$form->{NODE_NAME}=$node_info->{name};
	$form->{ID}=$id;

	my $template=$self->param('template');
	$template->param(
			 %$form
			);
	return $template->output();
    }
}
########################################

1;

__END__

=pod

=head1 NAME

DBIx::Tree::NestedSet::Manage

=head1 SYNOPSIS

A CGI::Application and HTML::Template based helper class that provides an interface to DBIx::Tree::NestedSet methods.

=head1 DESCRIPTION

The idea of this module is that you subclass it and add your own cgiapp_prerun(), denied(), and cgiapp_postrun() methods.  You should probably tweak the add_child_form() and delete_node() methods too to include the metadata you want in your tree.

confirm_node_can_be_deleted() should be overridden too, it's used to "confirm" whether or not a node can be deleted without messing up your database. Returning a true value means the node is OK to delete.

See the "templates", "cgi-bin", and "graphics" directories of this distribution for an example HTML::Template, graphics (thank you to WebGUI) and an instance script.

Example Module:

 package My::NestedSetTree;
 use base 'DBIx::Tree::NestedSet::Manage';
 use strict;

 sub cgiapp_prerun{
     #Controls access to this module.
     my $self=shift;
     if ($self->access_not_allowed()) {
 	$self->prerun_mode('denied');
     } else {
 	return;
     }
 }


 sub denied{
     #Content returned if a user isn't allowed to access this module
     return 'Access is denied.';
 }


 sub cgiapp_postrun {
     #HTML content to "wrap around" this module.
     my $self = shift;
     my $output_ref = shift;
     
     my $new_output = "<html><head><title>My Tree</title></head><body>";
     $new_output .= $$output_ref;
     $new_output .= "</body></html>";
     
     # Replace old output with new output
     $$output_ref = $new_output;
 }

 sub confirm_node_can_be_deleted{
     #You should customize this method to check for your own
     #criteria as to what nodes may be deleted.
     my $self=shift;
     my $dbh=$self->param('dbh');
     my $q=$self->query();
     my $tree=$self->param('tree');
     my $nodes=$tree->get_self_and_children_flat(id=>$q->param('id'));
     my @ids=map{$dbh->quote($_->{id})} @$nodes;
     my $id_sql=join(',',@ids);
     #Check to see if we have any documents assigned to this category.
     my ($count)=$dbh->selectrow_array(qq|select count(*) from doc_categories where primary_cat in($id_sql)|);
     #If there's a positive count, we can't delete.
     return ($count) ? 0 : 1 ;
 }


 1;

=head1 SEE ALSO

CGI::Application, HTML::Template and DBIx::Tree::NestedSet.

=head1 AUTHOR

Dan Collis Puro, Geekuprising.com.  Email: dan at geekuprising dot com.

This model was inspired by the perlmonks.org thread below:

http://www.perlmonks.org/index.pl?node_id=354049

See "Tilly's" response in particular. I'm "Hero Zzyzzx".

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

