package WebGUI::Operation::LDAPLink;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::LDAPLink;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
   my $workarea = shift;
   my $title = shift;
   $title = WebGUI::International::get($title,"AuthLDAP") if ($title);
   my $help = shift;
   my $ac = WebGUI::AdminConsole->new($session,"ldapconnections");
   if ($help) {
      $ac->setHelp($help,"AuthLDAP");
   }
   my $returnUrl = "";
   if($session->form->process("returnUrl")) {
      $returnUrl = ";returnUrl=".$session->url->escape($session->form->process("returnUrl"));
   }
   $ac->addSubmenuItem($session->url->page('op=editLDAPLink;llid=new'.$returnUrl), WebGUI::International::get("LDAPLink_982","AuthLDAP"));
   if ($session->form->process("op") eq "editLDAPLink" && $session->form->process("llid") ne "new") {
      $ac->addSubmenuItem($session->url->page('op=editLDAPLink;llid='.$session->form->process("llid").$returnUrl), WebGUI::International::get("LDAPLink_983","AuthLDAP"));
      $ac->addSubmenuItem($session->url->page('op=copyLDAPLink;llid='.$session->form->process("llid").$returnUrl), WebGUI::International::get("LDAPLink_984","AuthLDAP"));
	  $ac->addSubmenuItem($session->url->page('op=deleteLDAPLink;llid='.$session->form->process("llid")), WebGUI::International::get("LDAPLink_985","AuthLDAP"));
	  $ac->addSubmenuItem($session->url->page('op=listLDAPLinks'.$returnUrl), WebGUI::International::get("LDAPLink_986","AuthLDAP"));
   }
   return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_copyLDAPLink {
	my $session = shift;
   return $session->privilege->insufficient unless ($session->user->isInGroup(3));
   my (%db);
   tie %db, 'Tie::CPHash';
   %db = $session->db->quickHash("select * from ldapLink where ldapLinkId=".$session->db->quote($session->form->process("llid")));
   $db{ldapLinkId} = "new";
   $db{ldapLinkName} = "Copy of ".$db{ldapLinkName};
   $session->db->setRow("ldapLink","ldapLinkId",\%db);
   #$session->db->write("insert into databaseLink (databaseLinkId,title,DSN,username,identifier) values (".$session->db->quote(WebGUI::Id::generate()).", ".$session->db->quote($db{title}." (copy)").", ".$session->db->quote($db{DSN}).", ".$session->db->quote($db{username}).", ".$session->db->quote($db{identifier}).")");
   $session->form->process("op") = "listLDAPLinks";
   return www_listLDAPLinks();
}

#-------------------------------------------------------------------
sub www_deleteLDAPLink {
	my $session = shift;
   return $session->privilege->insufficient unless ($session->user->isInGroup(3));
   $session->db->write("delete from ldapLink where ldapLinkId=".$session->db->quote($session->form->process("llid")));
   $session->form->process("op") = "listLDAPLinks";
   return www_listLDAPLinks();
}

#-------------------------------------------------------------------
sub www_editLDAPLink {
	my $session = shift;
   return $session->privilege->insufficient unless ($session->user->isInGroup(3));
   my ($output, %db, $f);
   tie %db, 'Tie::CPHash';
   %db = $session->db->quickHash("select * from ldapLink where ldapLinkId=".$session->db->quote($session->form->process("llid")));
   
   $f = WebGUI::HTMLForm->new($session, -extras=>'autocomplete="off"' );
   $f->hidden(
   		-name => "op",
		-value => "editLDAPLinkSave",
	     );
   $f->hidden(
   		-name => "llid",
		-value => $session->form->process("llid"),
	     );
   $f->hidden(
   		-name => "returnUrl",
		-value => $session->form->process("returnUrl"),
	     );
   $f->readOnly(
		-label => WebGUI::International::get("LDAPLink_991","AuthLDAP"),
   		-value => $session->form->process("llid"),
	       );
   $f->text(
   		-name  => "ldapLinkName",
		-label => WebGUI::International::get("LDAPLink_992","AuthLDAP"),
		-hoverHelp => WebGUI::International::get("LDAPLink_992 description","AuthLDAP"),
		-value => $db{ldapLinkName},
	   );
   $f->text(
   		-name => "ldapUrl",
		-label => WebGUI::International::get("LDAPLink_993","AuthLDAP"),
		-hoverHelp => WebGUI::International::get("LDAPLink_993 description","AuthLDAP"),
		-value => $db{ldapUrl},
	   );
   $f->text(
   		-name => "connectDn",
		-label => WebGUI::International::get("LDAPLink_994","AuthLDAP"),
		-hoverHelp => WebGUI::International::get("LDAPLink_994 description","AuthLDAP"),
		-value => $db{connectDn},
	   );
   $f->password(
   		-name => "ldapIdentifier",
		-label => WebGUI::International::get("LDAPLink_995","AuthLDAP"),
		-hoverHelp => WebGUI::International::get("LDAPLink_995 description","AuthLDAP"),
		-value => $db{identifier},
		);
   $f->text(
   		-name => "ldapUserRDN",
		-label => WebGUI::International::get(9,'AuthLDAP'),
		-hoverHelp => WebGUI::International::get('9 description','AuthLDAP'),
		-value => $db{ldapUserRDN},
	   );
   $f->text(
		-name => "ldapIdentity",
		-label => WebGUI::International::get(6,'AuthLDAP'),
		-hoverHelp => WebGUI::International::get('6 description','AuthLDAP'),
		-value => $db{ldapIdentity},
   );
   $f->text(
		-name => "ldapIdentityName",
		-label => WebGUI::International::get(7,'AuthLDAP'),
		-hoverHelp => WebGUI::International::get('7 description','AuthLDAP'),
		-value => $db{ldapIdentityName},
   );
   $f->text(
		-name => "ldapPasswordName",
		-label => WebGUI::International::get(8,'AuthLDAP'),
		-hoverHelp => WebGUI::International::get('8 description','AuthLDAP'),
		-value => $db{ldapPasswordName},
   );
   $f->yesNo(
             -name=>"ldapSendWelcomeMessage",
             -value=>$db{ldapSendWelcomeMessage},
             -label=>WebGUI::International::get(868,"AuthLDAP"),
             -hoverHelp=>WebGUI::International::get('868 description',"AuthLDAP"),
             );
   $f->textarea(
                -name=>"ldapWelcomeMessage",
                -value=>$db{ldapWelcomeMessage},
                -label=>WebGUI::International::get(869,"AuthLDAP"),
                -hoverHelp=>WebGUI::International::get('869 description',"AuthLDAP"),
               );
	$f->template(
		-name=>"ldapAccountTemplate",
		-value=>$db{ldapAccountTemplate},
		-namespace=>"Auth/LDAP/Account",
		-label=>WebGUI::International::get("account template","AuthLDAP"),
		-hoverHelp=>WebGUI::International::get("account template description","AuthLDAP"),
		);
	$f->template(
		-name=>"ldapCreateAccountTemplate",
		-value=>$db{ldapCreateAccountTemplate},
		-namespace=>"Auth/LDAP/Create",
		-label=>WebGUI::International::get("create account template","AuthLDAP"),
		-hoverHelp=>WebGUI::International::get("create account template description","AuthLDAP"),
		);
	$f->template(
		-name=>"ldapLoginTemplate",
		-value=>$db{ldapLoginTemplate},
		-namespace=>"Auth/LDAP/Login",
		-label=>WebGUI::International::get("login template","AuthLDAP"),
		-hoverHelp=>WebGUI::International::get("login template description","AuthLDAP"),
		);
   
   $f->submit;
   $output .= $f->print;
   return _submenu($output,"LDAPLink_990","ldap connection add/edit");
}

#-------------------------------------------------------------------
sub www_editLDAPLinkSave {
	my $session = shift;
   return $session->privilege->insufficient unless ($session->user->isInGroup(3));
   my $properties = {};
   $properties->{ldapLinkId} = $session->form->process("llid");
   $properties->{ldapLinkName} = $session->form->process("ldapLinkName");
   $properties->{ldapUrl} = $session->form->process("ldapUrl");
   $properties->{connectDn} = $session->form->process("connectDn");
   $properties->{identifier} = $session->form->process("ldapIdentifier");
   $properties->{ldapUserRDN} = $session->form->process("ldapUserRDN");
   $properties->{ldapIdentity} = $session->form->process("ldapIdentity");
   $properties->{ldapIdentityName} = $session->form->process("ldapIdentityName");
   $properties->{ldapPasswordName} = $session->form->process("ldapPasswordName");
   $properties->{ldapSendWelcomeMessage} = $session->form->yesNo("ldapSendWelcomeMessage");
   $properties->{ldapWelcomeMessage} = $session->form->textarea("ldapWelcomeMessage");
   $properties->{ldapAccountTemplate} = $session->form->template("ldapAccountTemplate");
   $properties->{ldapCreateAccountTemplate} = $session->form->template("ldapCreateAccountTemplate");
   $properties->{ldapLoginTemplate} = $session->form->template("ldapLoginTemplate");
   $session->db->setRow("ldapLink","ldapLinkId",$properties);
   if($session->form->process("returnUrl")) {
      WebGUI::HTTP::setRedirect($session->form->process("returnUrl"));
   }
   return www_listLDAPLinks();
}

#-------------------------------------------------------------------
sub www_listLDAPLinks {
	my $session = shift;
   return $session->privilege->adminOnly() unless($session->user->isInGroup(3));
   my ($output, $p, $sth, $data, @row, $i);
   my $returnUrl = "";
   if($session->form->process("returnUrl")) {
      $returnUrl = ";returnUrl=".$session->url->escape($session->form->process("returnUrl"));
   }
   $sth = $session->db->read("select * from ldapLink order by ldapLinkName");
   $row[$i] = '<tr><td valign="top" class="tableData">&nbsp;</td><td valign="top" class="tableData">'.WebGUI::International::get("LDAPLink_1076","AuthLDAP").'</td><td>'.WebGUI::International::get("LDAPLink_1077","AuthLDAP").'</td></tr>';
   $i++;
   while ($data = $sth->hashRef) {
      $row[$i] = '<tr><td valign="top" class="tableData">'
	        .deleteIcon('op=deleteLDAPLink;llid='.$data->{ldapLinkId},$session->url->page(),WebGUI::International::get("LDAPLink_988","AuthLDAP"))
			.editIcon('op=editLDAPLink;llid='.$data->{ldapLinkId}.$returnUrl)
			.copyIcon('op=copyLDAPLink;llid='.$data->{ldapLinkId}.$returnUrl)
			.'</td>';
      $row[$i] .= '<td valign="top" class="tableData">'.$data->{ldapLinkName}.'</td>';
	  
	  my $ldapLink = WebGUI::LDAPLink->new($data->{ldapLinkId});
	  my $status = WebGUI::International::get("LDAPLink_1078","AuthLDAP");
	  if($ldapLink->bind) {
	     $status = WebGUI::International::get("LDAPLink_1079","AuthLDAP");
	  }else{
	     $session->errorHandler->warn($ldapLink->getErrorMessage());
	  }
	  $ldapLink->unbind;
	  $row[$i] .= '<td valign="top" class="tableData">'.$status.'</td>';
	  $row[$i] .= '</tr>';
      $i++;
   }
   $sth->finish;
   $p = WebGUI::Paginator->new($session->url->page('op=listLDAPLinks'));
   $p->setDataByArrayRef(\@row);
   $output .= '<table border="1" cellpadding="3" cellspacing="0" align="center">';
   $output .= $p->getPage;
   $output .= '</table>';
   $output .= $p->getBarTraditional;
   return _submenu($output,"ldap connection links manage");
}


1;
