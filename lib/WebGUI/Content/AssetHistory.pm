package WebGUI::Content::AssetHistory;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;


=head1 NAME

Package WebGUI::Content::AssetHistory

=head1 DESCRIPTION

Give the admins an interface to view the history of assets on their site.

=head1 SYNOPSIS

 use WebGUI::Content::AssetHistory;
 my $output = WebGUI::Content::AssetHistory::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    return undef unless ($session->form->get('op') eq 'assetHistory');
    my $method  = $session->form->get( 'method' )
                ? 'www_' . $session->form->get( 'method' )
                : 'www_view'
                ;
    
    # Validate the method name
    if ( !__PACKAGE__->can( $method ) ) {
        return "Invalid method";
    }
    else {
        return __PACKAGE__->can( $method )->( $session );
    }
    my $output = "";
    # ...
    return $output;
}

#-------------------------------------------------------------------

=head2 www_getHistoryAsJson (  )

Servers side pagination for asset history data displayed in a YUI DataTable.

=cut

sub www_getHistoryAsJson {
    my ($session) = @_;
    return $session->privilege->insufficient
        unless $session->user->isInGroup(12);
    my ($db, $form) = $session->quick(qw(db form));
    my $startIndex      = $form->get('startIndex') || 0;
    my $numberOfResults = $form->get('results')    || 25;
    my %goodKeys = qw/assetId 1 url 1 username 1 dateStamp 1/;
    my $sortKey = $form->get('sortKey');
    $sortKey = $goodKeys{$sortKey} == 1 ? $sortKey : 'dateStamp';
    my $sortDir = $form->get('sortDir');
    $sortDir = lc($sortDir) eq 'desc' ? 'desc' : 'asc';
    my @placeholders = ();
    my $sql = <<EOSQL;
select SQL_CALC_FOUND_ROWS assetHistory.*,users.username from assetHistory join users on assetHistory.userId=users.userId
EOSQL
    my $keywords = $form->get("keywords");
    if ($keywords ne "") {
        $db->buildSearchQuery(\$sql, \@placeholders, $keywords, [qw{url assetId username}])
    }
    push(@placeholders, $startIndex, $numberOfResults);
    $sql .= sprintf (" order by %s limit ?,?","$sortKey $sortDir");
    my %results = ();
    my @records = ();
    my $sth = $db->read($sql, \@placeholders);
	while (my $record = $sth->hashRef) {
		push(@records,$record);
	}
    $results{'recordsReturned'} = $sth->rows()+0;
	$sth->finish;
    $results{'records'}      = \@records;
    $results{'totalRecords'} = $db->quickScalar('select found_rows()')+0; ##Convert to numeric
    $results{'startIndex'}   = $startIndex;
    $results{'sort'}         = undef;
    $results{'dir'}          = $sortDir;
    $session->response->content_type('application/json');
    my $json = JSON::to_json(\%results);
    return $json;
}

#-------------------------------------------------------------------

=head2 www_view

YUI DataTable for browsing asset history.

=cut

sub www_view {
    my $session = shift;
    return $session->privilege->insufficient
        unless $session->user->isInGroup(12);
    ##YUI specific datatable CSS
    my $ac = WebGUI::AdminConsole->new( $session, "assetHistory" );
    my ($style, $url) = $session->quick(qw(style url));
    $style->setCss($url->extras('/yui/build/fonts/fonts-min.css'));
    $style->setCss($url->extras('yui/build/datatable/assets/skins/sam/datatable.css'));
    $style->setCss($url->extras('yui/build/paginator/assets/skins/sam/paginator.css'));
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'));
    $style->setScript($url->extras('yui/build/json/json-min.js'));
    $style->setScript($url->extras('yui/build/paginator/paginator-min.js'));
    $style->setScript($url->extras('yui/build/datasource/datasource-min.js'));
    ##YUI Datatable
    $style->setScript($url->extras('yui/build/datatable/datatable-min.js'));
    ##WebGUI YUI AssetHistory
    $style->setScript( $url->extras( 'yui-webgui/build/i18n/i18n.js' ));
    $style->setScript( $url->extras('yui-webgui/build/assetHistory/assetHistory.js'));
    ##Default CSS
    $style->setRawHeadTags('<style type="text/css"> #paging a { color: #0000de; } #search form { display: inline; } </style>');
    my $i18n=WebGUI::International->new($session);

    my $output;
    
    $output .= q|
  <div class="yui-skin-sam">  
    <div id="search"><form id="keywordSearchForm"><input type="text" name="keywords" id="keywordsField" /><input type="submit" value="|.$i18n->get(364, 'WebGUI').q|" /><input type="submit" value="|.$i18n->get('Clear', 'WebGUI').q|" onclick="this.form.keywords.value='';"/></form></div>
    <div id="paginationTop"></div>
    <div id="historyData"></div>
    <div id="paginationBot"></div>
  </div>
<script type="text/javascript">
    YAHOO.util.Event.onDOMReady( WebGUI.AssetHistory.initManager );
</script>
|;
    
    return $ac->render( $output );
}

1;

#vim:ft=perl
