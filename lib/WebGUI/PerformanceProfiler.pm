package WebGUI::PerformanceProfiler;

=head1 LEGAL
                                              ,
                                            ,o
                                            :o
                   _....._                  `:o
                 .'       ``-.                \o
                /  _      _   \                \o
               :  /*\    /*\   )                ;o
               |  \_/    \_/   /                ;o
               (       U      /                 ;o
                \  (\_____/) /                  /o
                 \   \_m_/  (                  /o
                  \         (                ,o:
                  )          \,           .o;o'           ,o'o'o.
                ./          /\o;o,,,,,;o;o;''         _,-o,-'''-o:o.
 .             ./o./)        \    'o'o'o''         _,-'o,o'         o
 o           ./o./ /       .o \.              __,-o o,o'
 \o.       ,/o /  /o/)     | o o'-..____,,-o'o o_o-'
 `o:o...-o,o-' ,o,/ |     \   'o.o_o_o_o,o--''
 .,  ``o-o'  ,.oo/   'o /\.o`.
 `o`o-....o'o,-'   /o /   \o \.                       ,o..         o
   ``o-o.o--      /o /      \o.o--..          ,,,o-o'o.--o:o:o,,..:o
                 (oo(          `--o.o`o---o'o'o,o,-'''        o'o'o
                  \ o\              ``-o-o''''
   ,-o;o           \o \
  /o/               )o )      WebGUI::PerformanceProfiler
 (o(               /o /			By Len Kranendonk
  \o\.       ...-o'o /				ilance.nl
    \o`o`-o'o o,o,--' 
      ```o--'''  

=cut

=head1 USAGE

This module provides functionality to profile your
WebGUI code, and find slow routines.

Using this module is simple, just add:

PerlModule WebGUI::PerformanceProfiler
PerlChildInitHandler WebGUI::PerformanceProfiler
PerlOutputFilterHandler WebGUI::PerformanceProfiler

To the apache configuration.  Make sure these directives
are not inside your WebGUI vhost block, but instead above it.

By default all preloaded WebGUI code will get profiled. 
You can limit the profiling to specific modules like this:

PerlSetVar whatToProfile WebGUI::Asset::Wobject

=cut

use strict;
use Time::HiRes qw(time);
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND);
use Apache2::Connection;
use Apache2::ServerUtil;
use Apache2::Filter;
use Apache2::FilterRec;
use Apache2::RequestIO;
use Apache2::RequestRec;
use ModPerl::Util;
use Net::CIDR::Lite;

my @subTimes = ();
my $depth = 0;
my %pointer;

=head2 handler

In Init, adds profiles code to subroutines.

For all other calls, adds profiler output to the file.

=cut

sub handler {
    ##This method does double duty as a ChildInitHandler and as an Output filter.
    ##therefore we don't know what kind of object we get.
	my $object = shift;
	my $callback = ModPerl::Util::current_callback();
	if($callback eq 'PerlChildInitHandler') {
		return addProfilerCode();
	} else {
		return output($object);
	}
}

=head2 addProfilerCode

Based on the Apache config setting WhatToProfile, generate a list of all subs to
profile and adds profiling code to them.  Certain subroutines are excluded, such as this sub,
AUTOLOADS and CONSTANTS.

=cut

sub addProfilerCode {
	my $r = shift; 
	my $s = Apache2::ServerUtil->server;
        my $whatToProfile = $s->dir_config('WhatToProfile') || 'WebGUI';

	my %subs = findSubs($whatToProfile);
	my $myself = __PACKAGE__;
	while(my($name, $ref) = each(%subs)) {
		unless($name =~ /$myself/i 		# Dont instrument ourself.
			|| $name =~ /AUTOLOAD/i		# Dont instrument AUTOLOAD
			|| is_constant($name,$ref)	# Dont instrument CONSTANTS
			){
			instrumentSub($name, $ref);
		}
	}
	return Apache2::Const::DECLINED;
}


=head2 output 

Handler that adds the results to the body of the outgoing page.

=cut

sub output {
	my $f = shift;
	return Apache2::Const::DECLINED unless($f->r->content_type =~ 'text/html');
    my $server = Apache2::ServerUtil->server;
    my $sn = $server->dir_config('ProfileSubnet');
    if ($sn) {
        my $conn = $f->c;
        my $ipAddress = $conn->remote_ip;
        my $net = Net::CIDR::Lite->new($sn);
        if (!$net->find($ipAddress)) {
            return Apache2::Const::DECLINED;
        }
    }
	while($f->read(my $buffer, 1024)) {
		my $content .= $buffer;
		if ($content =~ /(<\/body)/i) {
			my $results = results();
			$content =~ s/<\/body(.*)/${results}<\/body$1/i;
		}	
		$f->print($content);
	}
	return Apache2::Const::OK;
}

=head2 findSubs

Walk the symbol tree and return a list of all subroutines with a given module
hierachy.  Returns a hash of full subroutine names along with a code ref
to that sub.

=head3 pkg

A string indicating which parts of the module namespace should be searched
for subroutines.

=cut

sub findSubs {
	my $pkg = shift;
	my %_subs;
	my @symbols;
	eval('@symbols = keys(%'.$pkg.'::);');
	foreach my $sym (@symbols) {
		next if ($sym eq $pkg.'::');		# Self refering routine 
		next if ($sym =~ /^__/);
		if($sym =~ /\:\:$/) {
			$sym =~ s/\:\:$//;
			%_subs = (%_subs, findSubs($pkg . '::' . $sym));
			next;
		}
		next if ($sym =~ /\W/);
		my $code_ref;
		eval('$code_ref = *'.$pkg.'::'.$sym.'{CODE};');
		next unless($code_ref);
		$_subs{$pkg."::".$sym} = $code_ref;
	}
	return %_subs;
}

=head2 instrumentSub

Wrap profiling code around a subroutine by manipulating the symbol table.

=cut

sub instrumentSub {
	my $name = shift;
	my $coderef = shift;
	my $prototype;
	if(defined(prototype($name))) {
		$prototype = '('.prototype($name).')';
	}
	my $instrumented_body = q(
	{
		profileSubStart( $name );
		my $ret_val_scalar;
		my @ret_val_array;

		if(wantarray) {
			eval { @ret_val_array = &$coderef; };
		} else {
			eval { $ret_val_scalar = &$coderef; };
        	}
		die ($@) if ($@);
		profileSubEnd( $name );
		if(wantarray) {
			return @ret_val_array;
		} else {
			return $ret_val_scalar;
		}
	};
	);
	eval "no warnings 'redefine'; *$name = sub $prototype $instrumented_body" ;
}

=head2 profileSubStart

Record the name of the subroutine, the time it was called and increment the depth.

=cut

sub profileSubStart {
	my $routine = shift;
	push(@subTimes, {
		routine => $routine,
		'start' => time(),
		depth => ++$depth
	});
	$pointer{$routine} = $#subTimes;
}

=head2 profileSubEnd

Record when a subroutine was exited and decrement the depth.

=cut

sub profileSubEnd {
	my $routine = shift;
	my $call = $subTimes[$pointer{$routine}];
	$call->{end} = time();
	$depth--;
}


=head2 results

Produce the output of the profiler.  The expandable, 
collapsible tree of subroutine calls.  Will soon 
include line number of the caller (parent) subroutine, 
and optionally a dump of all the parameters (!). Will 
also soon include a tabular display akin to Devel::DProf's 
formatted tabular output: percent total time spent in sub, 
aggregate exclusive time spent in sub, aggregate inclusive 
time spent in sub, number of calls to the sub, mean 
exclusive time per sub call, mean inclusive time per sub 
call, subroutine name, sorted by aggregate exclusive time 
per sub, descending.

=cut

sub results {
	my @parents = ();
	my $exclTimes = {};
	my $inclTimes = {};
	my $output = qq|
<script> 
function showhide(id){ 
if (document.getElementById){ 
obj = document.getElementById(id); 
if (obj.style.display == "none"){ 
obj.style.display = ""; 
} else { 
obj.style.display = "none"; 
} 
} 
} 
</script>|;
	$output .= '<h2>Stack Profiler</h2>';
	my $total = sprintf("%.4f",($subTimes[-1]->{'end'} - $subTimes[0]->{'start'}));
	$output .= '<i>Function calls: '.scalar(@subTimes).' took: '.$total.'s</i><br><br>';
	for(my $entry=0;$entry <= $#subTimes;$entry++) {
		my $call = $subTimes[$entry];
		$call->{entry} = $entry;
		$call->{duration} = $call->{end} - $call->{start};
		$call->{excl} = $call->{duration};
		if (defined $parents[0]) {
			$subTimes[$parents[-1]]->{excl} -= $call->{duration};
		}
		if($subTimes[$entry + 1] && ($subTimes[$entry + 1]->{depth} > $call->{depth})) {
			# Do stuff to the next line if it's at a deeper depth.
			push(@parents,$entry);
		}
		my $nextDepth;
		if(ref($subTimes[$entry +1])) {
			$nextDepth = $subTimes[$entry + 1]->{depth};
		} else {
			$nextDepth = 1;
		}
		if($nextDepth < $call->{depth}) {
			$nextDepth++;
			for(1 .. ($call->{depth} - $nextDepth + 1)) {
				pop @parents;
			}
		}
	}
	
	for(my $entry=0;$entry <= $#subTimes;$entry++) {
		my $call = $subTimes[$entry];
		$output .= "\n".'&nbsp;&nbsp;';
		$output .= '&nbsp;&nbsp;|&nbsp;' for(2..($call->{depth}));
		$exclTimes->{$call->{routine}} = [] unless exists $exclTimes->{$call->{routine}};
		push(@{$exclTimes->{$call->{routine}}},$call->{excl});
		$inclTimes->{$call->{routine}} = [] unless exists $inclTimes->{$call->{routine}};
		push(@{$inclTimes->{$call->{routine}}},$call->{duration});
		if($subTimes[$entry + 1] && ($subTimes[$entry + 1]->{depth} > $call->{depth})) {
			# Do stuff to the next line if it's at a deeper depth.
			$output .= qq|<a href="#" onclick="showhide('profile$call->{entry}'); return(false);"> + </a>|;
		} else {
			$output .= '&mdash;&nbsp;';
		}
		$output .= "<b>" if($total < ($call->{duration} * 40));
		$output .= $call->{routine} . " ( ".sprintf("%.4f",$call->{duration})."s )";
		$output .= " &nbsp;". sprintf("%.2f",(($call->{duration} / $total)*100)).'%</b>' if($total < ($call->{duration} * 40));
		$output .= "<b> Exclusive: ".sprintf("%.4f",$call->{excl})."s </b>" if ($call->{excl} ne $call->{duration});
		$output .= "<br>\n";
		my $nextDepth;
		if(ref($subTimes[$entry +1])) {
			$output .= qq|<div id="profile$entry" style="display:none;">| if ($subTimes[$entry + 1]->{depth} > $call->{depth});
			$nextDepth = $subTimes[$entry + 1]->{depth};
		} else {
			$nextDepth = 1;
		}
		if($nextDepth < $call->{depth}) {
			$nextDepth++;
			for(0 .. ($call->{depth} - $nextDepth)) {
				$output .= "\n</div>\n";
			}
		}
	}
	$output .= "<br>\n<br>\n";
	$output .= '<h2>Subroutine Calls Aggregate Data</h2>';
	$output .= '"Exclusive" measures the time spent in the subroutine call, excluding the time spent in its called subroutines.  Inclusive measures...'."<br>\n<br>\n";
	$output .= qq|
	<style>
	.sort-table {
	font:		Icon;
	border:		1px Solid ThreeDShadow;
	background:	Window;
	color:		WindowText;
}
.evenST {
	background:	#eee;
}

.oddST {

}
.sort-table thead {
	background:	ButtonFace;
}

.sort-table td {
	padding:	2px 5px;
}

.sort-table thead td {
	border:			1px solid;
	border-color:	ButtonHighlight ButtonShadow
					ButtonShadow ButtonHighlight;
	cursor:			default;
}

.sort-table thead td:active {
	border-color:	ButtonShadow ButtonHighlight
					ButtonHighlight ButtonShadow;
	padding:		3px 4px 1px 6px;
}

.sort-table thead td[_sortType=None]:active {
	border-color:	ButtonHighlight ButtonShadow
					ButtonShadow ButtonHighlight;
	padding:		2px 5px;
}

.sort-arrow {
	width:					11px;
	height:					11px;
	background-position:	center center;
	background-repeat:		no-repeat;
	margin:					0 2px;
}

.sort-arrow.descending {
	background-image:		url("/extras/wobject/Profiler/downsimple.png");

}

.sort-arrow.ascending {
	background-image:		url("/extras/wobject/Profiler/upsimple.png");
}
	
	</style>
	<script type="text/javascript" src="/extras/wobject/Profiler/sortabletable.js"></script>
		<table class="sort-table" id="subStatsTable" cellspacing="0">
<thead>
	<tr>
		<td>Inclusive %</td>
		<td>Inclusive Total</td>
		<td>Inclusive Mean</td>
		<td>Calls Total</td>
		<td>Exclusive %</td>
		<td>Exclusive Total</td>
		<td>Exclusive Mean</td>
		<td>Sub Name</td>
	</tr>
</thead>
<tbody>|;
my $rawtotal = ($subTimes[-1]->{'end'} - $subTimes[0]->{'start'});
foreach my $rout (keys %{$inclTimes}) {
	my $totExcl = sum($exclTimes->{$rout});
	my $totIncl = sum($inclTimes->{$rout});
	next if ((($totExcl+0) > 1000000) || (($totExcl+0) < -1000000)); # skip problem subs.
	$output .= sprintf("<tr><td>%.2f%%</td><td>%.5f</td><td>%.5f</td><td>%u</td><td>%.2f%%</td><td>%.5f</td><td>%.5f</td><td>%s</td></tr>",
		(100 * $totIncl / $rawtotal ),                         # Inclusive %
		$totIncl,                                       # Inclusive Total
		($totIncl / (scalar(@{$inclTimes->{$rout}}))),  # Inclusive Mean
		(scalar(@{$inclTimes->{$rout}})),               # Calls Total
		(100 * $totExcl / $rawtotal),                         # Exclusive %
		$totExcl,                                       # Exclusive Total
		($totExcl / (scalar(@{$exclTimes->{$rout}}))),  # Exclusive Mean
		$rout                                           # Sub Name
	);
}
$output .= q@
</tbody>
</table>

<script type="text/javascript">
//<![CDATA[
	
function addSTClassName(el, sClassName) {
	var s = el.className;
	var p = s.split(" ");
	var l = p.length;
	for (var i = 0; i < l; i++) {
		if (p[i] == sClassName)
			return undef;
	}
	p[p.length] = sClassName;
	el.className = p.join(" ").replace( /(^\s+)|(\s+$)/g, "" );
}

function removeSTClassName(el, sClassName) {
	var s = el.className;
	var p = s.split(" ");
	var np = [];
	var l = p.length;
	var j = 0;
	for (var i = 0; i < l; i++) {
		if (p[i] != sClassName) {
		np[j++] = p[i]; }
	}
	el.className = np.join(" ").replace( /(^\s+)|(\s+$)/g, "" );
}
	
function perceST(str) {
	return Number(str.replace(
		/%/,""));
}

SortableTable.prototype.addSortType( "Percent", perceST );
var stST = new SortableTable( document.getElementById("subStatsTable"),
	["Percent", "Number", "Number", "Number", "Percent", "Number", "Number", "String"] );

// restore the class names
stST.onsort = function () {
	var rows = stST.tBody.rows;
	var l = rows.length;
	for (var i = 0; i < l; i++) {
		removeSTClassName(rows[i], i % 2 ? "oddST" : "evenST");
		addSTClassName(rows[i], i % 2 ? "evenST" : "oddST");
	}
};



stST.sort( 6 , 1 ); // sort by exclusive mean, descending.

//]]>
</script>@;
	
	$output .= "<br>\n<br>\n<br>\n<br>\n";
	undef(@subTimes);
	return $output;
}

=head2 is_constant

Determine if a given subroutine is used to generate constants, such as subroutines created
by C<use constant foo => 2>.

=cut

sub is_constant {
	no strict 'refs';
	my ($name, $code) = @_;
	my $proto = prototype($code);
	return 0 if defined $proto and length $proto;
	my $is_const;
	{
        	local $SIG{__WARN__} = sub { $is_const = 1 if $_[0] =~ /^Constant/ };
		eval { *{$name} = sub { "TEST" } };
		eval { *{$name} = $code; };
	}
	return $is_const;
}


=head2 sum ($arrRef)

Calculates and returns the sum of the elements in the array reference.

=head3 $arrRef

An array reference.

=cut

sub sum {
	my $sum = 0;
	my $arrRef = shift;
	foreach my $elem (@{$arrRef}) { $sum += $elem; }
	return($sum);
}

1;
