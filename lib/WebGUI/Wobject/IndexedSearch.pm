package WebGUI::Wobject::IndexedSearch;
$VERSION = "1.4";

#Test to see if Time::HiRes will load.
my $hasTimeHiRes=1;
eval "use Time::HiRes"; $hasTimeHiRes=0 if $@;

use strict;
use WebGUI::Wobject::IndexedSearch::Search;
use WebGUI::HTMLForm;
use WebGUI::HTML;
use WebGUI::Macro;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;
use Tie::IxHash;
use WebGUI::Utility;
use WebGUI::Paginator;

our @ISA = qw(WebGUI::Wobject);

#-------------------------------------------------------------------
sub name {
	return WebGUI::International::get(17,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
	my $class = shift;
	my $property = shift;
	my $self = WebGUI::Wobject->new(
		-useTemplate=>1,
		-properties=>$property,
		-extendedProperties=>{
                        indexName=>{
                                defaultValue=>'default'
                                },
                        searchRoot=>{
                                fieldType=>'selectList',
                                defaultValue=>'any'
                                },
                        users=>{
                                fieldType=>'selectList',
                                defaultValue=>'any'
                                },
                        namespaces=>{
                                fieldType=>'selectList',
                                defaultValue=>'any'
                                },
                        languages=>{
                                fieldType=>'selectList',
                                defaultValue=>'any'
                                },
                        contentTypes=>{
                                fieldType=>'selectList',
                                defaultValue=>'any'
                                },
                        paginateAfter=>{
                                defaultValue=>10
                                },
                        highlight=>{
                                defaultValue=>1
                                },
                        previewLength=>{
                                defaultValue=>130
                                },
			highlight_1=>{
				defaultValue=>'#ffff66'
				},
			highlight_2=>{
				defaultValue=>'#A0FFFF'
				},
			highlight_3=>{
				defaultValue=>'#99ff99'
				},
			highlight_4=>{
				defaultValue=>'#ff9999'
				},
			highlight_5=>{
				defaultValue=>'#ff66ff'
				},
           	      }
		);
	bless $self, $class;
}

#-------------------------------------------------------------------
sub uiLevel {
	return 5;
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	my (@data, %indexName);

	tie my %searchRoot, 'Tie::IxHash';

	my $layout = WebGUI::HTMLForm->new;
	my $properties = WebGUI::HTMLForm->new;
	my $privileges = WebGUI::HTMLForm->new;

	# Unconditional read to catch intallation errors.
	my $sth = WebGUI::SQL->unconditionalRead("select distinct(indexName), indexName from IndexedSearch_docInfo");
	unless ($sth->errorCode < 1) { 
		return "<p><b>" . WebGUI::International::get(1,$self->get("namespace")) . $sth->errorMessage."</b></p>";
	}
	while (@data = $sth->array) {
		$indexName{$data[0]} = $data[1];
	}
	$sth->finish;
	unless(%indexName) {
		return "<p><b>" . WebGUI::International::get(2,$self->get("namespace")) .
			 "<p>" . WebGUI::International::get(3,$self->get("namespace")) . "</b></p>";
	}
	
	# Index to use
	$properties->radioList(	-name=>'indexName',
					-options=>\%indexName,
					-label=>WebGUI::International::get(5,$self->get("namespace")),
					-value=>$self->getValue("indexName"),
					-vertical=>1
				);

	# Page roots
	%searchRoot = (	'any'=>WebGUI::International::get(15,$self->get("namespace")), 
				$session{page}{pageId}=>WebGUI::International::get(4,$self->get("namespace")),
				WebGUI::SQL->buildHash("select pageId,title from page where parentId=0 and (pageId=1 or pageId>999) order by title")
			);
	$properties->checkList (	-name=>'searchRoot',
						-options=>\%searchRoot, 
						-label=>WebGUI::International::get(6,$self->get("namespace")),
						-value=>[ split("\n", $self->getValue("searchRoot")) ],
						-multiple=>1,
						-vertical=>1,
				);

	# Content of specific user
	$properties->selectList (	-name=>'users',
						-options=>$self->_getUsers(),
						-label=>WebGUI::International::get(7,$self->get("namespace")),
						-value=>[ split("\n", $self->getValue("users")) ],
						-multiple=>1,
						-size=>5
				);

	# Content in specific namespaces
	$properties->selectList (	-name=>'namespaces',
						-options=>$self->_getNamespaces,
						-label=>WebGUI::International::get(8,$self->get("namespace")),
						-value=>[ split("\n", $self->getValue("namespaces")) ],
						-multiple=>1,
						-size=>5
				);

	# Content in specific language
	$properties->checkList (	-name=>'languages',
						-options=>$self->_getLanguages(),
						-label=>WebGUI::International::get(9,$self->get("namespace")),
						-value=>[ split("\n", $self->getValue("languages")) ],
						-multiple=>1,
				);

	# Only specific content types
	my $contentTypes = $self->_getContentTypes();
	delete $contentTypes->{content};
	$properties->checkList (	-name=>'contentTypes',
						-options=>$contentTypes,
						-label=>WebGUI::International::get(10,$self->get("namespace")),
						-value=>[ split("\n", $self->getValue("contentTypes")) ],
						-multiple=>1,
						-vertical=>1,
				);
	$layout->integer (	-name=>'paginateAfter',
					-label=>WebGUI::International::get(11,$self->get("namespace")),
					-value=>$self->getValue("paginateAfter"),
				);
	$layout->integer        (       -name=>'previewLength',
                                        -label=>WebGUI::International::get(12,$self->get("namespace")),
                                        -value=>$self->getValue("previewLength"),
                                );
	$layout->yesNo	(	-name=>'highlight',
					-label=>WebGUI::International::get(13,$self->get("namespace")),
					-value=>$self->getValue("highlight"),
				);

	# Color picker for highlight colors
	$layout->raw 	(	-value=>'
				<SCRIPT LANGUAGE="Javascript" SRC="'.$session{config}{extrasURL}.'/wobject/IndexedSearch/ColorPicker2.js"></SCRIPT>
				<SCRIPT LANGUAGE="JavaScript">
				var cp = new ColorPicker("window");
				</SCRIPT>'
			);
	for (1..5) {
		my $highlight = "highlight_$_";
		$layout->text	(	-name=>$highlight,
					-label=>WebGUI::International::get(14,$self->get("namespace")) ." $_:",
					-size=>7,
					-value=>$self->getValue($highlight),
					-subtext=>qq{
						<A HREF="#" onClick="cp.select($highlight,'$highlight');
						return false;" NAME="$highlight" ID="$highlight">Pick</A>}
				);
	}

	return $self->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-heading=>"Edit Search",
		-helpId=>1
	);

}

#-------------------------------------------------------------------
sub www_editSave {
	# default editSave overruled to build & save the pageList for faster retrieval.
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my $self = shift;
	$self->SUPER::www_editSave();
	my (%pages, $pageList);
	my $searchRoot = $self->get("searchRoot");
	if ($searchRoot =~ /any/i) {
		$pageList = 'any';
	} else {
		foreach my $pageId (split(/\n+/,$searchRoot)) {
			%pages = (%pages, _getSearchablePages($pageId), $pageId => defined);
		}
		$pageList = join(" , ", keys %pages);
	}
	WebGUI::SQL->write("update IndexedSearch set pageList = ".quote($pageList)." where wobjectId = ".$self->get("wobjectId"));
	return '';
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	my (%var, @resultsLoop);

	# Do some query handling
	$var{exactPhrase} = $session{form}{exactPhrase};
	$var{allWords} = $session{form}{allWords};
	$var{atLeastOne} = $session{form}{atLeastOne};
	$var{without} = $session{form}{without};
	$var{query} = $session{form}{query};
	$var{query} .= qq{ +"$var{exactPhrase}"} if ($var{exactPhrase});
	$var{query} .= " ".join(" ",map("+".$_,split(/\s+/,$var{allWords}))) if ($var{allWords});
	$var{query} .= qq{ $var{atLeastOne}} if ($var{atLeastOne});
	$var{query} .= " ".join(" ",map("-".$_,split(/\s+/,$var{without}))) if ($var{without});

	# Set some standard vars
	$var{submit} = WebGUI::Form::submit({value=>WebGUI::International::get(16, $self->get("namespace"))});
	$var{"int.search"} = WebGUI::International::get(16,$self->get("namespace"));
	$var{wid} = $self->get("wobjectId");
      $var{numberOfResults} = '0';
      $var{"select_".$self->getValue("paginateAfter")} = "selected";

	# Do the search
	my $startTime = ($hasTimeHiRes) ? Time::HiRes::time() : time();
      my $filter = $self->_buildFilter;
      my $search = WebGUI::Wobject::IndexedSearch::Search->new($self->getValue('indexName'));
      $search->open;
      my $results = $search->search($var{query},$filter);
      $var{duration} = (($hasTimeHiRes) ? Time::HiRes::time() : time()) - $startTime;
      $var{duration} = sprintf("%.3f", $var{duration}) if $hasTimeHiRes; # Duration rounded to 3 decimal places

	# Let's see if the search returned any results
	if (defined ($results)) {
		$var{numberOfResults} = scalar(@$results);

		# Deal with pagination
		my $url = "wid=".$self->get("wobjectId")."&func=view&query=".WebGUI::URL::escape($var{query});
		map {$url .= "&users=".WebGUI::URL::escape($_)} $session{cgi}->param('users');
		map {$url .= "&namespaces=".WebGUI::URL::escape($_)} $session{cgi}->param('namespaces');
		map {$url .= "&languages=".WebGUI::URL::escape($_)} $session{cgi}->param('languages');
		map {$url .= "&contentTypes=".WebGUI::URL::escape($_)} $session{cgi}->param('contentTypes');
		$url .= "&paginateAfter=".$self->getValue("paginateAfter");
		my $p = WebGUI::Paginator->new(WebGUI::URL::page($url), $results, $self->getValue("paginateAfter"));
		$var{startNr} = 1;
		if($session{form}{pn}) {
			$var{startNr} = (($session{form}{pn} - 1) * $self->getValue("paginateAfter")) + 1;
		}

		my @highlightColors = map { $self->getValue("highlight_$_") } (1..5);
		$var{queryHighlighted} = $search->highlight($var{query}, undef, \@highlightColors);

 		# Get result details for this page
		if($p->getPageNumber > $p->getNumberOfPages) {
			$var{numberOfResults} = 0; 
			$var{resultsLoop} = [];
		} else {
			$var{resultsLoop} = $search->getDetails($p->getPageData, 
									highlightColors => \@highlightColors,
									previewLength => $self->getValue('previewLength'),
									highlight => $self->getValue('highlight')
								);
			# Pagination variables
			$var{endNr} = $var{startNr}+(scalar(@{$var{resultsLoop}}))-1;
			$p->appendTemplateVars(\%var);
		}
	}

	# Create a loop with namespaces
	$var{namespaces} = [];
	my $namespaces = $self->_getNamespaces('restricted');
	foreach(keys %$namespaces) {
		my $selected = 0;
		if (scalar $session{cgi}->param('namespaces')) {
			$selected = isIn($_, $session{cgi}->param('namespaces'));
		} else {
			$selected = ($session{form}{namespaces} =~ /$_/);
		}
		push(@{$var{namespaces}}, { value => $_, name => $namespaces->{$_}, selected => $selected });
	} 

	# Create a loop with contentTypes
	#
	# And while we are busy we also create a loop with simplified contentTypes
	# This means: wobject, page, wobjectDetail are masked in one option: content

	$var{contentTypes} = [];
	$var{contentTypesSimple} = [];
	my $contentTypes = $self->_getContentTypes('restricted');
	foreach(keys %$contentTypes) {
		my $selected = 0;
		if (scalar $session{cgi}->param('contentTypes')) {
			$selected = isIn($_, $session{cgi}->param('contentTypes'));
		} else {
			$selected = ($session{form}{contentTypes} =~ /$_/);
		}
		unless(/^content$/) {	# No shortcut in the detailed contentType list
			push(@{$var{contentTypes}}, { value => $_, 
								name => $contentTypes->{$_}, 
								selected => $selected,
								'type_'.$_ => 1 });
		}
		unless(/^page|wobject|wobjectDetail$/) {	# No details in the simple contentType list
			push(@{$var{contentTypesSimple}}, { value => $_, 
									name => $contentTypes->{$_}, 
									selected => $selected,
									'type_'.$_ => 1 });
		}
	}

	# Create a loop with users
	$var{users} = [];
	my $users = $self->_getUsers('restricted');
	foreach(keys %$users) {
		my $selected = 0;
		if (scalar $session{cgi}->param('users')) {
			$selected = isIn($_, $session{cgi}->param('users'));
		} else {
			$selected = ($session{form}{users} =~ /$_/);
		}
		push(@{$var{users}}, { value => $_, name => $users->{$_}, selected => $selected });
	}

	# Create a loop with languages
	$var{languages} = [];
	my $languages = $self->_getLanguages('restricted');
	foreach(keys %$languages) {
		my $selected = 0;
		if (scalar $session{cgi}->param('languages')) {
			$selected = isIn($_, $session{cgi}->param('languages'));
		} else {
			$selected = ($session{form}{languages} =~ /$_/);
		}
		push(@{$var{languages}}, { value => $_, name => $languages->{$_}, selected => $selected });
	}

	# close the search
	$search->close; 

	return $self->processTemplate($self->get("templateId"),\%var);
}

#-------------------------------------------------------------------
sub _buildFilter {
	my $self = shift;
	my %filter = ();
	
	# pages
	if($self->getValue('pageList') ne 'any') {
		$filter{pageId} = [ split(/\n+/, $self->getValue('pageList')) ];
	}

	# languages
	if($session{form}{languages} && ! isIn('any', $session{cgi}->param('languages'))) {
		$filter{languageId} = [ map { quote($_) } $session{cgi}->param('languages') ];
	} elsif ($self->getValue('languages') !~ /any/i) {
		$filter{languageId} = [ map { quote($_) } split(/\n/, $self->getValue('languages')) ];
	}
        push(@{$filter{languageId}}, '0') if (exists $filter{languageId}); # Some content (i.e. profiles) 
									   # don't have a language. They 
									   # must be found as well.
	
	# content-types
	if($session{form}{contentTypes} && ! isIn('any', $session{cgi}->param('contentTypes'))) {
		$filter{contentType} = [ map { quote($_) } $session{cgi}->param('contentTypes') ];

		# contentType "content" is a shortcut for "page", "wobject" and "wobjectDetail"
		if (isIn('content', $session{cgi}->param('contentTypes'))) {
			push(@{$filter{contentType}}, map { quote($_) } qw/page wobject wobjectDetail/);
		}
	} elsif ($self->getValue('contentTypes') !~ /any/i) {
		$filter{contentType} = [ map { quote($_) } split(/\n/, $self->getValue('contentTypes')) ];
	}

	# users
	if($session{form}{users} && ! isIn('any', $session{cgi}->param('users'))) {
		$filter{ownerId} = [];
		foreach my $user ($session{cgi}->param('users')) {
			if ($user =~ /\D/) {
				$user =~ s/\*/%/g;
				($user) = WebGUI::SQL->buildArray("select userId from users where username like ".quote($user));
			}
			push(@{$filter{ownerId}}, quote($user)) if ($user =~ /^\d+$/);
		}
	} elsif ($self->getValue('users') !~ /any/i) {
		$filter{ownerId} = [ map { quote($_) } split(/\n/, $self->getValue('users')) ];
	}

	# namespaces
	if($session{form}{namespaces} && ! isIn('any', $session{cgi}->param('namespaces'))) {
		$filter{namespace} = [ map { quote($_) } $session{cgi}->param('namespaces') ];
	} elsif ($self->getValue('namespaces') !~ /any/i) {
		$filter{namespace} = [ map { quote($_) } split(/\n/, $self->getValue('namespaces')) ];
	}

	# delete $filter{ownerId} if it is an empty array reference
	if(exists($filter{ownerId})) {
		delete $filter{ownerId} unless (scalar(@{$filter{ownerId}}));
	}
	return \%filter;
}

#-------------------------------------------------------------------
sub _getLanguages {
	my ($self, $restricted) = @_;
	my $international = WebGUI::SQL->buildHashRef("select distinct(IndexedSearch_docInfo.languageId), language.language from IndexedSearch_docInfo, language 
		where language.languageId = IndexedSearch_docInfo.languageId");
	tie my %languages, 'Tie::IxHash';
	if ($restricted and $self->get('languages') !~ /any/i) {
		$languages{any} = WebGUI::International::get(24,$self->get("namespace"));
		foreach (split/\n/, $self->get('languages')) {
			$languages{$_} = $international->{$_};
		}
	} else {
		%languages = ('any' => WebGUI::International::get(24,$self->get("namespace")) , %$international);
	}
	return \%languages;
}

#-------------------------------------------------------------------
sub _getNamespaces {
	my ($self, $restricted) = @_;
	my %international;
	foreach my $wobject (@{$session{config}{wobjects}}){
		my $cmd = "WebGUI::Wobject::".$wobject;
		my $w = $cmd->new({namespace=>$wobject, wobjectId=>'new'});
		$international{$wobject} = $w->name;
	}
	tie my %namespaces, 'Tie::IxHash';
	if ($restricted and $self->get('namespaces') !~ /any/i) {
		$namespaces{any} = WebGUI::International::get(18,$self->get("namespace"));
		foreach (split/\n/, $self->get('namespaces')) {
			$namespaces{$_} = $international{$_} || ucfirst($_);
		}
	} else {
		$namespaces{any} = WebGUI::International::get(18,$self->get("namespace"));
		foreach (WebGUI::SQL->buildArray("select distinct(namespace) from IndexedSearch_docInfo order by namespace")) {
			$namespaces{$_} = $international{$_} ||ucfirst($_);
		}
	}
	return \%namespaces;
}

#-------------------------------------------------------------------
sub _getContentTypes {
	my ($self, $restricted) = @_;
	my %international = (	'page' => WebGUI::International::get(2),
					'wobject' => WebGUI::International::get(19,$self->get("namespace")),
					'wobjectDetail' => WebGUI::International::get(20,$self->get("namespace")),
					'content' => WebGUI::International::get(21,$self->get("namespace")),
					'discussion' => WebGUI::International::get(892),
					'profile' => WebGUI::International::get(22,$self->get("namespace")),
					'help' => WebGUI::International::get(93),
					'any' => WebGUI::International::get(23,$self->get("namespace")),
				);
	tie my %contentTypes, 'Tie::IxHash';
	if ($restricted and $self->get('contentTypes') !~ /any/i) {
		$contentTypes{any} = $international{any};
		$contentTypes{content} = $international{content};	# shortcut for page, wobject and wobjectDetail
		foreach (split/\n/, $self->get('contentTypes')) {
			$contentTypes{$_} = $international{$_};
		}
	} else {
		%contentTypes = (	'any' =>  $international{any},
					'content' => $international{content},	# shortcut for page, wobject and wobjectDetail
				);
		foreach (WebGUI::SQL->buildArray("select distinct(contentType) from IndexedSearch_docInfo order by contentType")) {
			$contentTypes{$_} = $international{$_} || ucfirst($_);
		}
	}
	return \%contentTypes;
}

#-------------------------------------------------------------------
sub _getSearchablePages {
	my $searchRoot = shift;
	my %pages;
	my $sth = WebGUI::SQL->read("select pageId from page where parentId = $searchRoot");
	while (my %data = $sth->hash) {
		$pages{$data{pageId}} = defined;
		%pages = (%pages, _getSearchablePages($data{pageId}) );
	}
	return %pages;
}
	
#-------------------------------------------------------------------
sub _getUsers {
	my ($self, $restricted) = @_;
	tie my %users, 'Tie::IxHash';
	if ($restricted and $self->get('users') !~ /any/i) {
		$users{any} = WebGUI::International::get(25,$self->get("namespace"));
		foreach (split/\n/, $self->get('users')) {
			$users{$_} = $_;
		}
	} else {
		%users = (	'any' =>  WebGUI::International::get(25,$self->get("namespace")),
				WebGUI::SQL->buildHash("select userId, username from users order by username")
			);
	}
	return \%users;
}

1;
