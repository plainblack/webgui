package WebGUI::FilePump::Admin;

use strict;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use WebGUI::FilePump::Bundle;

=head1 NAME

Package WebGUI::FilePump::Admin

=head1 DESCRIPTION

Web interface for making, building, and editing FilePump bundles.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get('groupIdAdminFilePump') );
}

#-------------------------------------------------------------------

=head2 www_addBundle ( )

Displays a form to add a bundle.

Note, we do not allow bundle names to be edited.  This is why.  The directory to a bundle is based on
the bundle name, and the time stamp of the last build.  If you change the name, then you have a few
options.

1) You delete the build directory with the old name, which will break every macro which references it.

2) You leave it there, which means that they accumulate with time since they can't every be deleted because
you don't know the old name.

In short, this really means that instead of an option to edit the name, it needs a copy function.  When you
copy the bundle, it asks you what you want for a new name, and it is supplied by the user at that time.

=cut

sub www_addBundle {
    my ($session) = @_;
    return $session->privilege->insufficient() unless canView($session);

    ##Build the form
	my $i18n = WebGUI::International->new($session, 'FilePump');
	my $form = WebGUI::HTMLForm->new($session);
	$form->hidden( name=>"op",       value=>"filePump");
	$form->hidden( name=>"func",     value=>"addBundleSave");
    $form->text(
        name         => 'bundleName',
        defaultValue => $i18n->get('new bundle'),
        label        => $i18n->get('bundle name'),
        hoverHelp    => $i18n->get('bundle name help'),
    );
	$form->submit;

	my $ac   = WebGUI::AdminConsole->new($session,'filePump');
	return $ac->render($form->print, $i18n->get('Add Bundle'));
}

#-------------------------------------------------------------------

=head2 www_addBundleSave ( )

Saves the results of www_addBundle().

=cut

sub www_addBundleSave {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $form       = $session->form;
    my $bundleName = $form->get('bundleName');
    my $bundle = WebGUI::FilePump::Bundle->create($session, {
        bundleName   => $bundleName,
        lastModified => time(),
    });
    return www_manage($session);
}

#-------------------------------------------------------------------

=head2 www_addFile ( )

Processes the form to add a file to a bundle.

Form variables used:

=over 4

=item uri

The URI to add.

=item type

The type of file to add.

=item bundleId

The GUID of the bundle to add a file to.

=back

=cut

sub www_addFile {
    my ($session) = @_;
    return $session->privilege->insufficient() unless canView($session);
    my $form     = $session->form;
    my $bundleId = $form->get('bundleId');
    my $bundle   = WebGUI::FilePump::Bundle->new($session, $bundleId);
    return www_editBundle($session) unless $bundle;

    my $type     = $form->get('type');
    my $uri      = $form->get('uri');

    my (undef, $error) = $bundle->addFile($type, $uri);

    return www_editBundle($session, $error);
}

#-------------------------------------------------------------------

=head2 www_buildBundle ( )

Builds a bundle, identified by the form variable, bundleId.

=cut

sub www_buildBundle {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
    return www_editBundle($session) unless $bundle;
    my ($code, $error) = $bundle->build;
    if ($error) {
        my $i18n = WebGUI::International->new($session, 'FilePump');
        $error = sprintf $i18n->get('build error'), $error;
    }
    return www_editBundle($session, $error);
}

#-------------------------------------------------------------------

=head2 www_deleteBundle ( )

Deletes a bundle, identified by the form variable, bundleId.

=cut

sub www_deleteBundle {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
    if (defined $bundle) {
        $bundle->delete;
    }
    return www_manage($session);
}

#------------------------------------------------------------------

=head2 www_deleteFile ( session )

Deletes a file from it's bundle.  The kind of file is set by the form variable filetype,
the id of the bundle is bundleId, and the id of the file to move is fileId.

=head3 session

A reference to the current session.

=cut

sub www_deleteFile {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $form   = $session->form;
    my $bundle = WebGUI::FilePump::Bundle->new($session, $form->get("bundleId"));
    return www_editBundle($session) unless $bundle;
    $bundle->deleteFile($form->get('fileType'), $form->get('fileId'));
	return www_editBundle($session);
}

#------------------------------------------------------------------

=head2 www_demoteFile ( session )

Moves a bundle file down one position.  The kind of file is set by the form variable fileType,
the id of the bundle is bundleId, and the id of the file to move is fileId.

=head3 session

A reference to the current session.

=cut

sub www_demoteFile {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $form   = $session->form;
    my $bundle = WebGUI::FilePump::Bundle->new($session, $form->get("bundleId"));
	return www_editBundle($session) unless $bundle;
    my $type = $form->get('fileType');
    my $fileId = $form->get('fileId');
    $bundle->moveFileDown($type, $fileId);
	return www_editBundle($session);
}

#------------------------------------------------------------------

=head2 www_editBundle ( session )

Interface for managing URIs in a bundle, given by the form param bundleId.  Add, delete,
promote and demote are supported for all three file types.

=head3 session

A reference to the current session.

=cut

sub www_editBundle {
	my ($session, $error) = @_;
	return $session->privilege->insufficient() unless canView($session);
    my $bundleId = $session->form->get("bundleId");
    my $bundle = WebGUI::FilePump::Bundle->new($session, $bundleId);
    return www_addBundle($session) unless $bundle;
    my $i18n   = WebGUI::International->new($session, 'FilePump');
    if ($error) {
        $error = qq|<div class="error">$error</div>\n|;
    }
    my $tableStub = <<EOTABLE;
<h2>%s</h2>
<table border=1>
<tr><th>&nbsp;</th><th>URI</th><th>%s</th></tr>
%s
</table>
<p>%s</p>
EOTABLE
    my $output   = '';
    my $dt       = $session->datetime;
    my $url      = $session->url;
    my $lastModifiedi18n = $i18n->get('last modified');
    foreach my $fileType (qw/jsFiles cssFiles otherFiles/) {
        my $type = $fileType eq 'jsFiles'  ? 'JS'
                 : $fileType eq 'cssFiles' ? 'CSS'
                 : 'OTHER';
        my $form = WebGUI::Form::formHeader($session, {
                       action => $url->gateway($url->getRequestedUrl,'op=filePump;func=addFile;type='.$type.';bundleId='.$bundleId),
                   })
                 . WebGUI::Form::text($session, {
                       name => 'uri',
                       size => 45,
                   })
                 . WebGUI::Form::submit($session)
                 . WebGUI::Form::formFooter()
                 ;

        my $rows = '';
        my $files = $bundle->get($fileType);
        foreach my $file (@{ $files }) {
            my $urlFrag = 'bundleId='.$bundleId.';fileType='.$type.';fileId='.$file->{fileId};
            $rows .= sprintf '<tr><td>%s</td><td>%s</td><td>%s</td></tr>', 
                     $session->icon->delete(   'op=filePump;func=deleteFile;'  . $urlFrag).
                     $session->icon->moveUp(   'op=filePump;func=promoteFile;' . $urlFrag).
                     $session->icon->moveDown( 'op=filePump;func=demoteFile;'  . $urlFrag) ,
                     $file->{uri},
                     $file->{lastModified} ? $dt->epochToHuman($file->{lastModified}) : '&nbsp;'
                   ;
        }
        $output .= sprintf $tableStub, $i18n->get($fileType), $lastModifiedi18n, $rows, $form;
    }

    my $ac = WebGUI::AdminConsole->new($session,'filePump');
    $ac->addSubmenuItem($session->url->page('op=filePump;'),               $i18n->get('list bundles'));
    $ac->addSubmenuItem($session->url->page('op=filePump;func=addBundle'), $i18n->get('add a bundle'));
    $ac->addSubmenuItem($session->url->page('op=filePump;func=buildBundle;bundleId='.$bundleId), $i18n->get('build this bundle'));
    return $ac->render($error.$output, 'File Pump');
}

#------------------------------------------------------------------

=head2 www_promoteFile ( session )

Moves a bundle file up one position.  The kind of file is set by the form variable fileType,
the id of the bundle is bundleId, and the id of the file to move is fileId.

=head3 session

A reference to the current session.

=cut

sub www_promoteFile {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
    my $form   = $session->form;
    my $bundle = WebGUI::FilePump::Bundle->new($session, $session->form->get("bundleId"));
	return www_editBundle($session) unless $bundle;
    my $type = $form->get('fileType');
    my $fileId = $form->get('fileId');
    $bundle->moveFileUp($type, $fileId);
	return www_editBundle($session);
}

#-------------------------------------------------------------------

=head2 www_manage ( session )

Display a list of available bundles.  Provide ways to add, edit and delete them.

=head3 $session

A WebGUI session object.

=cut

sub www_manage {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $i18n   = WebGUI::International->new($session, 'FilePump');
    my $error  = shift;
    my $rows   = '';
    my $dt     = $session->datetime;
    my $url    = $session->url;
    my $getABundle = WebGUI::FilePump::Bundle->getAllIterator($session,{ orderBy => 'bundleName' } );
    my $notYet = $i18n->get('not yet');
    while (my $bundle = $getABundle->()) {
        my $lastModified = $bundle->get('lastModified');
        my $lastBuild    = $bundle->get('lastBuild');
        my $build = '';
        if ($lastModified > $lastBuild) {
            $build = sprintf q| <a href="%s">(%s)</a>|, 
                     $url->gateway($url->getRequestedUrl,'op=filePump;func=buildBundle;bundleId='.$bundle->getId),
                     $i18n->get('build');
        }
        $rows .= sprintf '<tr><td>%s</td><td><a href="%s">%s</a></td><td>%s</td><td>%s</td>',
                 $session->icon->delete('op=filePump;func=deleteBundle;bundleId='.$bundle->getId),
                 $url->gateway($url->getRequestedUrl,'op=filePump;func=editBundle;bundleId='.$bundle->getId),
                 $bundle->get('bundleName'),
                 $bundle->get('lastModified') ? $dt->epochToHuman($lastModified)        : $notYet,
                 $bundle->get('lastBuild')    ? $dt->epochToHuman($lastBuild).$build    : $notYet,
               ;
    }
    my $output = sprintf <<EOHTML, $i18n->get('bundle name'), $i18n->get('last modified'), $i18n->get('last build'), $rows;
<table border="1">
<tr><th>&nbsp;</th><th>%s</th><th>%s</th><th>%s</th></tr>
%s
</table>
EOHTML
    my $ac = WebGUI::AdminConsole->new($session,'filePump');
    $ac->addSubmenuItem($session->url->page('op=filePump;func=addBundle'), $i18n->get('add a bundle'));
    return $ac->render($error.$output, 'File Pump');
}


1;
