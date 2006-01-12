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
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
	my $workarea = shift;
	my $title = shift;
	my $i18n = WebGUI::International->new($session,"AuthLDAP");
   $title = $i18n->get($title) if ($title);
   my $help = shift;
   my $ac = WebGUI::AdminConsole->new($session,"ldapconnections");
   if ($help) {
      $ac->setHelp($help,"AuthLDAP");
   }
   my $returnUrl = "";
   if($session->form->process("returnUrl")) {
      $returnUrl = ";returnUrl=".$session->url->escape($session->form->process("returnUrl"));
   }
   $ac->addSubmenuItem($session->url->page('op=editLDAPLink;llid=new'.$returnUrl), $i18n->get("LDAPLink_982"));
   if ($session->form->process("op") eq "editLDAPLink" && $session->form->process("llid") ne "new") {
      $ac->addSubmenuItem($session->url->page('op=editLDAPLink;llid='.$session->form->process("llid").$returnUrl), $i18n->get("LDAPLink_983"));
      $ac->addSubmenuItem($session->url->page('op=copyLDAPLink;llid='.$session->form->process("llid").$returnUrl), $i18n->get("LDAPLink_984"));
	  $ac->addSubmenuItem($session->url->page('op=deleteLDAPLink;llid='.$session->form->process("llid")), $i18n->get("LDAPLink_985"));
	  $ac->addSubmenuItem($session->url->page('op=listLDAPLinks'.$returnUrl), $i18n->get("LDAPLink_986"));
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
   
	my $i18n = WebGUI::International->new($session,"AuthLDAP");
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
		-label => $i18n->get("LDAPLink_991"),
   		-value => $session->form->process("llid"),
	       );
   $f->text(
   		-name  => "ldapLinkName",
		-label => $i18n->get("LDAPLink_992"),
		-hoverHelp => $i18n->get("LDAPLink_992 description"),
		-value => $db{ldapLinkName},
	   );
   $f->text(
   		-name => "ldapUrl",
		-label => $i18n->get("LDAPLink_993"),
		-hoverHelp => $i18n->get("LDAPLink_993 description"),
		-value => $db{ldapUrl},
	   );
   $f->text(
   		-name => "connectDn",
		-label => $i18n->get("LDAPLink_994"),
		-hoverHelp => $i18n->get("LDAPLink_994 description"),
		-value => $db{connectDn},
	   );
   $f->password(
   		-name => "ldapIdentifier",
		-label => $i18n->get("LDAPLink_995"),
		-hoverHelp => $i18n->get("LDAPLink_995 description"),
		-value => $db{identifier},
		);
   $f->text(
   		-name => "ldapUserRDN",
		-label => $i18n->get(9),
		-hoverHelp => $i18n->get('9 description'),
		-value => $db{ldapUserRDN},
	   );
   $f->text(
		-name => "ldapIdentity",
		-label => $i18n->get(6),
		-hoverHelp => $i18n->get('6 description'),
		-value => $db{ldapIdentity},
   );
   $f->text(
		-name => "ldapIdentityName",
		-label => $i18n->get(7),
		-hoverHelp => $i18n->get('7 description'),
		-value => $db{ldapIdentityName},
   );
   $f->text(
		-name => "ldapPasswordName",
		-label => $i18n->get(8),
		-hoverHelp => $i18n->get('8 description'),
		-value => $db{ldapPasswordName},
   );
   $f->yesNo(
             -name=>"ldapSendWelcomeMessage",
             -value=>$db{ldapSendWelcomeMessage},
             -label=>$i18n->get(868),
             -hoverHelp=>$i18n->get('868 description'),
             );
   $f->textarea(
                -name=>"ldapWelcomeMessage",
                -value=>$db{ldapWelcomeMessage},
                -label=>$i18n->get(869),
                -hoverHelp=>$i18n->get('869 description'),
               );
	$f->template(
		-name=>"ldapAccountTemplate",
		-value=>$db{ldapAccountTemplate},
		-namespace=>"Auth/LDAP/Account",
		-label=>$i18n->get("account template"),
		-hoverHelp=>$i18n->get("account template description"),
		);
	$f->template(
		-name=>"ldapCreateAccountTemplate",
		-value=>$db{ldapCreateAccountTemplate},
		-namespace=>"Auth/LDAP/Create",
		-label=>$i18n->get("create account template"),
		-hoverHelp=>$i18n->get("create account template description"),
		);
	$f->template(
		-name=>"ldapLoginTemplate",
		-value=>$db{ldapLoginTemplate},
		-namespace=>"Auth/LDAP/Login",
		-label=>$i18n->get("login template"),
		-hoverHelp=>$i18n->get("login template description"),
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
	my $i18n = WebGUI::International->new($session,"AuthLDAP");
   my $returnUrl = "";
   if($session->form->process("returnUrl")) {
      $returnUrl = ";returnUrl=".$session->url->escape($session->form->process("returnUrl"));
   }
   $sth = $session->db->read("select * from ldapLink order by ldapLinkName");
   $row[$i] = '<tr><td valign="top" class="tableData">&nbsp;</td><td valign="top" class="tableData">'.$i18n->get("LDAPLink_1076").'</td><td>'.$i18n->get("LDAPLink_1077").'</td></tr>';
   $i++;
   while ($data = $sth->hashRef) {
      $row[$i] = '<tr><td valign="top" class="tableData">'
	        .$session->icon->delete('op=deleteLDAPLink;llid='.$data->{ldapLinkId},$session->url->page(),$i18n->get("LDAPLink_988"))
			.$session->icon->edit('op=editLDAPLink;llid='.$data->{ldapLinkId}.$returnUrl)
			.$session->icon->copy('op=copyLDAPLink;llid='.$data->{ldapLinkId}.$returnUrl)
			.'</td>';
      $row[$i] .= '<td valign="top" class="tableData">'.$data->{ldapLinkName}.'</td>';
	  
	  my $ldapLink = WebGUI::LDAPLink->new($session,$data->{ldapLinkId});
	  my $status = $i18n->get("LDAPLink_1078");
	  if($ldapLink->bind) {
	     $status = $i18n->get("LDAPLink_1079");
	  }else{
	     $session->errorHandler->warn($ldapLink->getErrorMessage());
	  }
	  $ldapLink->unbind;
	  $row[$i] .= '<td valign="top" class="tableData">'.$status.'</td>';
	  $row[$i] .= '</tr>';
      $i++;
   }
   $sth->finish;
   $p = WebGUI::Paginator->new($session,$session->url->page('op=listLDAPLinks'));
   $p->setDataByArrayRef(\@row);
   $output .= '<table border="1" cellpadding="3" cellspacing="0" align="center">';
   $output .= $p->getPage;
   $output .= '</table>';
   $output .= $p->getBarTraditional;
   return _submenu($output,"ldap connection links manage");
}


1;
