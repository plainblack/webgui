package WebGUI::Wobject;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI::Carp qw(fatalsToBrowser);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Node;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _reorderWobjects {
	my ($sth, $i, $wid);
	$sth = WebGUI::SQL->read("select wobjectId from wobject where pageId=$_[0] order by templatePosition,sequenceNumber");
	while (($wid) = $sth->array) {
		$i++;
		WebGUI::SQL->write("update wobject set sequenceNumber='$i' where wobjectId=$wid");
	}
	$sth->finish;
}


#-------------------------------------------------------------------
sub _getNextSequenceNumber {
	my ($sequenceNumber);
	($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from wobject where pageId='$_[0]'");
	return ($sequenceNumber+1);
}

#-------------------------------------------------------------------
sub _getPositions {
	my (%hash);
	tie %hash, "Tie::IxHash";
	%hash = WebGUI::Template::getPositions($session{page}{template});
	return \%hash;
}

#-------------------------------------------------------------------

=head2 duplicate ( [ pageId ] )

 Duplicates this wobject with a new wobject ID. Returns the new
 wobject Id.

 NOTE: This method is meant to be extended by all sub-classes.

=item pageId 

 If specified the wobject will be duplicated to this pageId,
 otherwise it will be duplicated to the clipboard.

=cut

sub duplicate {
	my ($pageId, $w);
	$pageId = $_[1] || 2;
	$w = WebGUI::Wobject->new({
		wobjectId => "new",
		namespace => $_[0]->get("namespace")
		});
	$w->set({
		pageId => $pageId,
		title => $_[0]->get("title"),
		description => $_[0]->get("description"),
		displayTitle => $_[0]->get("displayTitle"),
		processMacros => $_[0]->get("processMacros"),
		startDate => $_[0]->get("startDate"),
		endDate => $_[0]->get("startDate"),
		templatePosition => $_[0]->get("templatePosition")
		});
        return $w->get("wobjectId");
}

#-------------------------------------------------------------------

=head2 get ( [ propertyName ] )

 Returns a hash reference containing all of the properties of this
 wobject instance.

=item propertyName

 If an individual propertyName is specified, then only that
 property value is returned as a scalar.

=cut

sub get {
        if ($_[1] ne "") {
                return $_[0]->{_property}{$_[1]};
        } else {
                return $_[0]->{_property};
        }
}

#-------------------------------------------------------------------

sub inDateRange {
	if ($_[0]->get("startDate") < time() && $_[0]->get("startDate") > time()) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 new ( hashRef )

 Constructor.

 NOTE: This method is meant to be extended by all sub-classes.

=item hashRef 

 A hash reference containing at minimum "wobjectId" and "namespace"
 and wobjectId may be set to "new" if you're creating a new
 instance. This hash reference should be the one created by 
 WebGUI.pm and passed to the wobject subclass.

 NOTE: It may seem a little weird that the initial data for the
 wobject instance is coming from WebGUI.pm, but this was done
 to lessen database traffic thus increasing the speed of all
 wobjects.

=cut

sub new {
        bless {_property => $_[1] }, $_[0];
}

#-------------------------------------------------------------------

sub processMacros {
	if ($_[0]->get("processMacros")) {
		return WebGUI::Macro::process($_[1]);
	} else {
		return $_[1];
	}
}

#-------------------------------------------------------------------

=head2 purge ( )

 Removes this wobject from the database and all it's attachments
 from the filesystem.

 NOTE: This method is meant to be extended by all sub-classes.

=cut

sub purge {
	my ($node);
	WebGUI::SQL->write("delete from ".$_[0]->get("namespace")." where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from wobject where wobjectId=".$_[0]->get("wobjectId"));
	$node = WebGUI::Node->new($_[0]->get("wobjectId"));
	$node->delete;
}

#-------------------------------------------------------------------

=head2 set ( [ hashRef ] )

 Stores the values specified in hashRef to the database.

 NOTE: This method should be extended by all subclasses.

=item hashRef 

 A hash reference of the properties of this wobject instance. This
 method will accept any name/value pair and associate it with this
 wobject instance in memory, but will only store the following 
 fields to the database:

 title, displayTitle, description, processMacros,
 pageId, templatePosition, startDate, endDate, sequenceNumber

=cut

sub set {
	my ($key, $sql);
	if ($_[0]->{_property}{wobjectId} eq "new") {
		$_[0]->{_property}{wobjectId} = getNextId("widgetId");
		$_[0]->{_property}{pageId} = ${$_[1]}{pageId} || $session{page}{pageId};
		$_[0]->{_property}{sequenceNumber} = _getNextSequenceNumber($_[0]->{_property}{pageId});
		$_[0]->{_property}{addedBy} = $session{user}{userId};
		$_[0]->{_property}{dateAdded} = time();
		WebGUI::SQL->write("insert into wobject 
			(wobjectId, namespace, dateAdded, addedBy, sequenceNumber, pageId) 
			values (
			".$_[0]->{_property}{wobjectId}.", 
			".quote($_[0]->{_property}{namespace}).",
			".$_[0]->{_property}{dateAdded}.",
			".$_[0]->{_property}{addedBy}.",
			".$_[0]->{_property}{sequenceNumber}.",
			".$_[0]->{_property}{pageId}."
			)");
		WebGUI::SQL->write("insert into ".$_[0]->{_property}{namespace}." (wobjectId) values (".$_[0]->{_property}{wobjectId}.")");
	}
	$_[0]->{_property}{lastEdited} = time();
	$_[0]->{_property}{editedBy} = $session{user}{userId};
	$sql = "update wobject set";
	foreach $key (keys %{$_[1]}) {
		$_[0]->{_property}{$key} = ${$_[1]}{$key};
		if (isIn($key, qw(title displayTitle description processMacros pageId templatePosition startDate endDate sequenceNumber))) {
        		$sql .= " ".$key."=".quote(${$_[1]}{$key}).",";
		}
	}
	$sql .= " lastEdited=".$_[0]->{_property}{lastEdited}.", 
		editedBy=".$_[0]->{_property}{editedBy}." 
		where wobjectId=".$_[0]->{_property}{wobjectId};
	WebGUI::SQL->write($sql);
}

#-------------------------------------------------------------------
sub www_cut {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({pageId=>2});
		_reorderWobjects($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_delete {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = helpIcon(14);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(43);
		$output .= '<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteConfirm&wid='.
			$_[0]->get("wobjectId")).'">';
		$output .= WebGUI::International::get(44); 
		$output .= '</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">';
		$output .= WebGUI::International::get(45);
		$output .= '</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteConfirm {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({pageId=>3});
		_reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($f, $title, $templatePosition, $endDate);
	$title = $_[0]->get("title") || $_[0]->get("namespace");
	$templatePosition = $_[0]->get("templatePosition") || 'A';
	$endDate = $_[0]->get("endDate") || (time()+315360000);
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
	$f->hidden("namespace",$_[0]->get("namespace")) if ($_[0]->get("wobjectId") eq "new");
	$f->hidden("func","editSave");
	$f->readOnly($_[0]->get("wobjectId"),WebGUI::International::get(499));
	$f->text("title",WebGUI::International::get(99),$title);
	$f->yesNo("displayTitle",WebGUI::International::get(174),$_[0]->get("displayTitle"));
	$f->yesNo("processMacros",WebGUI::International::get(175),$_[0]->get("processMacros"));
	$f->select("templatePosition",_getPositions(),WebGUI::International::get(363),[$templatePosition]);
	$f->date("startDate",WebGUI::International::get(497),$_[0]->get("startDate"));
	$f->date("endDate",WebGUI::International::get(498),$endDate);
	$f->HTMLArea("description",WebGUI::International::get(85),$_[0]->get("description"));
	$f->raw($_[1]);
	$f->submit;
	return $f->print; 
}

#-------------------------------------------------------------------
sub www_editSave {
	my ($title, $templatePosition, $startDate, $endDate);
	$title = $session{form}{title} || $_[0]->get("namespace");
        $templatePosition = $session{form}{templatePosition} || 'A';
        $startDate = setToEpoch($session{form}{startDate}) || setToEpoch(time());
        $endDate = setToEpoch($session{form}{endDate}) || setToEpoch(time()+315360000);
	$_[0]->set({
		title=>$title,
		displayTitle=>$session{form}{displayTitle},
		processMacros=>$session{form}{processMacros},
		templatePosition=>$templatePosition,
		startDate=>$startDate,
		endDate=>$endDate,
		description=>$session{form}{description}
	});
	return "";
}

#-------------------------------------------------------------------
sub www_moveBottom {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({sequenceNumber=>99999});
		_reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDown {
	my ($wid, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from wobject where wobjectId=".$_[0]->get("wobjectId"));
		($wid) = WebGUI::SQL->quickArray("select wobjectId from wobject where pageId=".$_[0]->get("pageId")
			." and sequenceNumber=".($thisSeq+1));
		if ($wid ne "") {
                	WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber+1 where wobjectId=".$_[0]->get("wobjectId"));
                	WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber-1 where wobjectId=$wid");
                	_reorderWobjects($_[0]->get("pageId"));
		}
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveTop {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->set({sequenceNumber=>0});
                _reorderWobjects($_[0]->get("pageId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveUp {
        my ($wid, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from wobject where wobjectId=".$_[0]->get("wobjectId"));
                ($wid) = WebGUI::SQL->quickArray("select wobjectId from wobject where pageId=".$_[0]->get("pageId")
			." and sequenceNumber=".($thisSeq-1));
                if ($wid ne "") {
                        WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber-1 where wobjectId=".$_[0]->get("wobjectId"));
                        WebGUI::SQL->write("update wobject set sequenceNumber=sequenceNumber+1 where wobjectId=$wid");
                	_reorderWobjects($_[0]->get("pageId"));
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_paste {
        my ($output, $nextSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from wobject where pageId=$session{page}{pageId}");
		$nextSeq += 1;
		$_[0]->set({sequenceNumber=>$nextSeq, pageId=>$session{page}{pageId}});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

1;
