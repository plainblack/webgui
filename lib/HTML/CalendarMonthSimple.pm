# HTML::CalendarMonthSimple.pm
# Generate HTML calendars. An alternative to HTML::CalendarMonth
# Herein, the symbol $self is used to refer to the object that's being passed around.

package HTML::CalendarMonthSimple;
$HTML::CalendarMonthSimple::VERSION = "1.17";
use strict;
use Date::Calc;


# Within the constructor is the only place where values are access directly.
# Methods are provided for accessing/changing values, and those methods
# are used even internally.
# Most of the constructor is assigning default values.
sub new {
   my $class = shift; $class = ref($class) || $class;
   my $self = {}; %$self = @_; # Load ourselves up from the args

   # Set the month and year to either args or today
   ($self->{'month'})  || ($self->{'month'}  = (Date::Calc::Today)[1]);
   ($self->{'year'})   || ($self->{'year'}   = (Date::Calc::Today)[0]);

   # Some defaults
   $self->{'border'}             = 5;
   $self->{'width'}              = '100%';
   $self->{'showdatenumbers'}    = 1;
   $self->{'showweekdayheaders'} = 1;
   $self->{'cellalignment'}      = 'left';
   $self->{'vcellalignment'}     = 'top';
   $self->{'weekdayheadersbig'}  = 1;
   $self->{'nowrap'}             = 0;
   $self->{'mondayisfirstday'}   = 0;

   # Set the default calendar header
   $self->{'header'} = sprintf("<center><font size=+2>%s %d</font></center>",
                               Date::Calc::Month_to_Text($self->{'month'}),$self->{'year'});

   # Get the monthname now so monthname() is fast and efficient
   $self->{'monthname'} = Date::Calc::Month_to_Text($self->{'month'});

   # Initialize the (empty) cell content so the keys are representative of the month
   foreach my $datenumber ( 1 .. Date::Calc::Days_in_Month($self->{'year'},$self->{'month'}) ) {
      $self->{'content'}->{$datenumber}          = '';
      $self->{'datecellclass'}->{$datenumber}    = '';
      $self->{'datecolor'}->{$datenumber}        = '';
      $self->{'datebordercolor'}->{$datenumber}  = '';
      $self->{'datecontentcolor'}->{$datenumber} = '';
   }
   # Initialize the non-standard date buckets: weekdays, etc.
   foreach my $day ('sunday','monday','tuesday','wednesday','thursday','friday','saturday') {
      $self->{'content'}->{$day."s"} = ''; # "Mondays", "Tuesdays", etc.
      foreach my $which (1 .. 5) { $self->{'content'}->{$which.$day}       = ''; } # "2Sunday", "3Wednesday", etc.
   }

   # All done!
   bless $self,$class; return $self;
}



sub as_HTML {
   my $self = shift;
   my $html = '';
   my(@days,$adjustedWeek,$sunday,$weeks,$WEEK,$DAY);

   # To make the grid even, pad the start of the series with 0s
   @days = (1 .. Date::Calc::Days_in_Month($self->year(),$self->month() ) );
   foreach (1 .. (Date::Calc::Day_of_Week($self->year(),$self->month(),1)%7) ) {
      unshift(@days,0);
   }
   $weeks = int((scalar(@days)+6)/7);
   # And pad the end as well, to avoid "uninitialized value" warnings
   foreach (scalar(@days)+1 .. $weeks*7) {
      push(@days,0);
   }

   # Define some scalars for generating the table
   my $border = $self->border();
   my $tablewidth = $self->width();
   $tablewidth =~ m/^(\d+)(\%?)$/; my $cellwidth = (int($1/7))||'14'; if ($2) { $cellwidth .= '%'; }
   my $header = $self->header();
   my $cellalignment = $self->cellalignment();
   my $vcellalignment = $self->vcellalignment();
   my $contentfontsize = $self->contentfontsize();
   my $bgcolor = $self->bgcolor() || '';
   my $weekdaycolor = $self->weekdaycolor() || $self->bgcolor();
   my $weekendcolor = $self->weekendcolor() || $self->bgcolor();
   my $todaycolor = $self->todaycolor() || $self->bgcolor();
   my $contentcolor = $self->contentcolor() || $self->contentcolor();
   my $weekdaycontentcolor = $self->weekdaycontentcolor() || $self->contentcolor();
   my $weekendcontentcolor = $self->weekendcontentcolor() || $self->contentcolor();
   my $todaycontentcolor = $self->todaycontentcolor() || $self->contentcolor();
   my $bordercolor = $self->bordercolor() || $self->bordercolor();
   my $weekdaybordercolor = $self->weekdaybordercolor() || $self->bordercolor();
   my $weekendbordercolor = $self->weekendbordercolor() || $self->bordercolor();
   my $todaybordercolor = $self->todaybordercolor() || $self->bordercolor();
   my $weekdayheadercolor = $self->weekdayheadercolor() || $self->bgcolor();
   my $weekendheadercolor = $self->weekendheadercolor() || $self->bgcolor();
   my $headercontentcolor = $self->headercontentcolor() || $self->contentcolor();
   my $weekdayheadercontentcolor = $self->weekdayheadercontentcolor() || $self->contentcolor();
   my $weekendheadercontentcolor = $self->weekendheadercontentcolor() || $self->contentcolor();
   my $headercolor = $self->headercolor() || $self->bgcolor();
   my $cellpadding = $self->cellpadding() || 0;
   my $cellspacing = $self->cellspacing() || 0;
   my $sharpborders = $self->sharpborders() || 0;
   my $cellheight = $self->cellheight();
   my $cellclass = $self->cellclass();
   my $weekdaycellclass = $self->weekdaycellclass() || $self->cellclass();
   my $weekendcellclass = $self->weekendcellclass() || $self->cellclass();
   my $todaycellclass = $self->todaycellclass() || $self->cellclass();
   my $headerclass = $self->headerclass() || $self->cellclass();
   my $nowrap = $self->nowrap() || 0;
   my $mondayisfirstday = $self->mondayisfirstday();
   # Get today's date, in case there's a todaycolor()
   my($todayyear,$todaymonth,$todaydate) = Date::Calc::Today();

   # the table declaration - sharpborders wraps the table inside a table cell
   if ($sharpborders) {
      $html .= "<table border=\"0\"";
      $html .= " width=\"$tablewidth\"" if $tablewidth;
      $html .= " cellpadding=\"0\" cellspacing=\"0\">\n";
      $html .= "<tr valign=\"top\" align=\"left\">\n";
      $html .= "<td align=\"left\" valign=\"top\"";
      $html .= " bgcolor=\"$bordercolor\"" if $bordercolor;
      $html .= ">";
      $html .= "<table border=\"0\" cellpadding=\"3\" cellspacing=\"1\" width=\"100%\">";
   }
   else {
      $html .= "<table ";
      $html .= "border=\"$border\"" if $border;
      $html .= "width=\"$tablewidth\"" if $tablewidth;
      $html .= "bgcolor=\"$bgcolor\"" if $bgcolor;
      $html .= "bordercolor=\"$bordercolor\"" if $bordercolor;
      $html .= "cellpadding=\"$cellpadding\"" if $cellpadding;
      $html .= "cellspacing=\"$cellspacing\""  if $cellspacing;
      $html .= ">\n";
   }
   # the header
   if ($header) {
      $html .= "<tr><td colspan=7";
      $html .= " bgcolor=\"$headercolor\"" if $headercolor;
      $html .= " class=\"$headerclass\"" if $headerclass;
      $html .= ">";
      $html .= "<font color=\"$headercontentcolor\">" if $headercontentcolor;
      $html .= $header;
      $html .= "</font>"  if $headercontentcolor;
      $html .= "</td></tr>\n";
   }
   # the names of the days of the week
   if ($self->showweekdayheaders) {
      my $celltype = $self->weekdayheadersbig() ? "th" : "td";
      $html .= "<tr>\n";
      $sunday = "<$celltype";
      $sunday.= " bgcolor=\"$weekendheadercolor\"" if $weekendheadercolor;
      $sunday .= " class=\"$weekendcellclass\"" if $weekendcellclass;
      $sunday .= ">";
      $sunday .= "<font color=\"$weekendheadercontentcolor\">" if $weekendheadercontentcolor;
      $sunday .= "Sunday";
      $sunday .= "</font>" if $weekendheadercontentcolor;
      $sunday .= "</$celltype>\n";
      $html .= $sunday unless ($mondayisfirstday);
      foreach ("Monday","Tuesday","Wednesday","Thursday","Friday"){
         $html .= "<$celltype";
         $html .= " bgcolor=\"$weekdayheadercolor\"" if $weekdayheadercolor;
         $html .= " class=\"$weekdaycellclass\"" if $weekdaycellclass;
         $html .= ">";
         $html .= "<font color=\"$weekdayheadercontentcolor\">" if $weekdayheadercontentcolor;
         $html .= "$_";
         $html .= "</font>" if $weekdayheadercontentcolor;
         $html .= "</$celltype>\n";
      }
      $html .= "<$celltype";
      $html .= " bgcolor=\"$weekendheadercolor\"" if $weekendheadercolor;
      $html .= " class=\"$weekendcellclass\"" if $weekendcellclass;
      $html .= ">";
      $html .= "<font color=\"$weekendheadercontentcolor\">" if $weekendheadercontentcolor;
      $html .= "Saturday";
      $html .= "</font>" if $weekendheadercontentcolor;
      $html .= "</$celltype>\n";
      $html .= $sunday if ($mondayisfirstday);
      $html .= "</tr>\n";
   }
   # now do each day, the actual date-content-containing cells
   foreach $WEEK (0 .. ($weeks-1)) {
      $html .= "<TR>\n";
      foreach $DAY (eval{if ($mondayisfirstday) {1..6,0} else {0..6}}) {
         my($thiscontent,$thisday,$thisbgcolor,$thisbordercolor,$thiscontentcolor,$thiscellclass);
	 if ($DAY == 0 && $mondayisfirstday) {
		$adjustedWeek = $WEEK+1;
	 } else {
		$adjustedWeek = $WEEK;
	 }
         $thisday = $days[((7*$adjustedWeek)+$DAY)];

         # Get the cell content
         if (! $thisday) { # If it's a dummy cell, no content
            $thiscontent = '&nbsp;'; }
         else { # A real date cell with potential content
            # Get the content
            if ($self->showdatenumbers()) { 
              if ( $self->getdatehref( $thisday )) {
                $thiscontent = "<p><b><a href=".$self->getdatehref($thisday);
                $thiscontent .= ">$thisday</a></b></p>\n";
              } else {
                $thiscontent = "<p><b>$thisday</b></p>\n";
              }
            }
            # Content for this specific date
            $thiscontent .= $self->getcontent($thisday);
            # Content for "2nd Wednesday", etc.
            $thiscontent .= $self->getcontent(int(1+($thisday/7.1)).('sunday','monday','tuesday','wednesday','thursday','friday','saturday')[$DAY]);
            # Content for "Wednesdays", etc.
            $thiscontent .= $self->getcontent(('sundays','mondays','tuesdays','wednesdays','thursdays','fridays','saturdays')[$DAY]);
            # Normalize if there's no content
            $thiscontent .= '&nbsp;';
         }

         # Get the cell's coloration and CSS class
         if ($self->year == $todayyear && $self->month == $todaymonth && $thisday == $todaydate)
                                              { $thisbgcolor = $self->datecolor($thisday) || $todaycolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $todaybordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $todaycontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $todaycellclass;
                                              }
         elsif (($DAY == 0) || ($DAY == 6))   { $thisbgcolor = $self->datecolor($thisday) || $weekendcolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $weekendbordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $weekendcontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $weekendcellclass;
                                              }
         else                                 { $thisbgcolor = $self->datecolor($thisday) || $weekdaycolor;
                                                $thisbordercolor = $self->datebordercolor($thisday) || $weekdaybordercolor;
                                                $thiscontentcolor = $self->datecontentcolor($thisday) || $weekdaycontentcolor;
                                                $thiscellclass = $self->datecellclass($thisday) || $weekdaycellclass;
                                              }

         # Done with this cell - push it into the table
         $html .= "<td";
         $html .= " nowrap" if $nowrap;
         $html .= " class=\"$thiscellclass\"" if $thiscellclass;
         $html .= " height=\"$cellheight\"" if $cellheight;
         $html .= " width=\"$cellwidth\"" if $cellwidth;
         $html .= " valign=\"$vcellalignment\"" if $vcellalignment;
         $html .= " align=\"$cellalignment\"" if $cellalignment;
         $html .= " bgcolor=\"$thisbgcolor\"" if $thisbgcolor;
         $html .= " bordercolor=\"$thisbordercolor\"" if $thisbordercolor;
         $html .= ">";
         $html .= "<font" if ($thiscontentcolor || $contentfontsize);
         $html .= " color=\"$thiscontentcolor\"" if $thiscontentcolor;
         $html .= " size=\"$contentfontsize\""  if $contentfontsize;
         $html .= ">" if ($thiscontentcolor || $contentfontsize);
         $html .= $thiscontent;
         $html .= "</font>" if ($thiscontentcolor || $contentfontsize);
         $html .= "</td>\n";
      }
      $html .= "</tr>\n";
   }
   $html .= "</table>\n";

   # if sharpborders, we need to break out of the enclosing table cell
   if ($sharpborders) {
      $html .= "</td>\n</tr>\n</table>\n";
   }

   return $html;
}




sub getdatehref {
   my $self = shift;
   my $date = shift || return();
   return $self->{'href'}->{$date};
}

sub setdatehref {
   my $self = shift;
   my $date = shift || return();
   my $datehref = shift || '';
   $self->{'href'}->{$date} = $datehref;
   return(1);
}

sub weekendcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendcolor'} = $newvalue; }
   return $self->{'weekendcolor'};
}

sub weekendheadercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendheadercolor'} = $newvalue; }
   return $self->{'weekendheadercolor'};
}

sub weekdayheadercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadercolor'} = $newvalue; }
   return $self->{'weekdayheadercolor'};
}

sub weekdaycolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaycolor'} = $newvalue; }
   return $self->{'weekdaycolor'};
}

sub headercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'headercolor'} = $newvalue; }
   return $self->{'headercolor'};
}

sub bgcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'bgcolor'} = $newvalue; }
   return $self->{'bgcolor'};
}

sub todaycolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaycolor'} = $newvalue; }
   return $self->{'todaycolor'};
}

sub bordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'bordercolor'} = $newvalue; }
   return $self->{'bordercolor'};
}

sub weekdaybordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaybordercolor'} = $newvalue; }
   return $self->{'weekdaybordercolor'};
}

sub weekendbordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendbordercolor'} = $newvalue; }
   return $self->{'weekendbordercolor'};
}

sub todaybordercolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaybordercolor'} = $newvalue; }
   return $self->{'todaybordercolor'};
}

sub contentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'contentcolor'} = $newvalue; }
   return $self->{'contentcolor'};
}

sub headercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'headercontentcolor'} = $newvalue; }
   return $self->{'headercontentcolor'};
}

sub weekdayheadercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadercontentcolor'} = $newvalue; }
   return $self->{'weekdayheadercontentcolor'};
}

sub weekendheadercontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendheadercontentcolor'} = $newvalue; }
   return $self->{'weekendheadercontentcolor'};
}

sub weekdaycontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdaycontentcolor'} = $newvalue; }
   return $self->{'weekdaycontentcolor'};
}

sub weekendcontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekendcontentcolor'} = $newvalue; }
   return $self->{'weekendcontentcolor'};
}

sub todaycontentcolor {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'todaycontentcolor'} = $newvalue; }
   return $self->{'todaycontentcolor'};
}

sub datecolor {
    my $self = shift;
    my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'datecolor'}->{$date} = $newvalue; }
    return $self->{'datecolor'}->{$date};
}

sub datebordercolor {
    my $self = shift;
    my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'datebordercolor'}->{$date} = $newvalue; }
    return $self->{'datebordercolor'}->{$date};
}

sub datecontentcolor {
    my $self = shift;
    my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'datecontentcolor'}->{$date} = $newvalue; }
    return $self->{'datecontentcolor'}->{$date};
}

sub getcontent {
   my $self = shift;
   my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
   return $self->{'content'}->{$date};
}

sub setcontent {
   my $self = shift;
   my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
   my $newcontent = shift || '';
   return() unless defined($self->{'content'}->{$date});
   $self->{'content'}->{$date} = $newcontent;
   return(1);
}

sub addcontent {
   my $self = shift;
   my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d+\.]+$/;
   my $newcontent = shift || return();
   return() unless defined($self->{'content'}->{$date});
   $self->{'content'}->{$date} .= $newcontent;
   return(1);
}

sub border {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'border'} = int($newvalue); }
   return $self->{'border'};
}


sub cellpadding {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellpadding'} = $newvalue; }
   return $self->{'cellpadding'};
}

sub cellspacing {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellspacing'} = $newvalue; }
   return $self->{'cellspacing'};
}

sub width {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'width'} = $newvalue; }
   return $self->{'width'};
}

sub showdatenumbers {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'showdatenumbers'} = $newvalue; }
   return $self->{'showdatenumbers'};
}
sub showweekdayheaders {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'showweekdayheaders'} = $newvalue; }
   return $self->{'showweekdayheaders'};
}

sub cellalignment {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'cellalignment'} = $newvalue; }
   return $self->{'cellalignment'};
}

sub vcellalignment {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'vcellalignment'} = $newvalue; }
   return $self->{'vcellalignment'};
}

sub contentfontsize {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'contentfontsize'} = $newvalue; }
   return $self->{'contentfontsize'};
}

sub weekdayheadersbig {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'weekdayheadersbig'} = $newvalue; }
   return $self->{'weekdayheadersbig'};
}

sub year {
   my $self = shift;
   return $self->{'year'};
}

sub month {
   my $self = shift;
   return $self->{'month'};
}

sub monthname {
   my $self = shift;
   return $self->{'monthname'};
}


sub header {
   my $self = shift;
   my $newvalue = shift;
   if (defined($newvalue)) { $self->{'header'} = $newvalue; }
   return $self->{'header'};
}

sub mondayisfirstday {
   my $self = shift;
   my $newvalue = shift;
   if (defined ($newvalue)) { $self->{'mondayisfirstday'} = $newvalue; }
   return $self->{'mondayisfirstday'}
}

sub nowrap {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'nowrap'} = $newvalue; }
    return $self->{'nowrap'};
}

sub sharpborders {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'sharpborders'} = $newvalue; }
    return $self->{'sharpborders'};
}

sub cellheight {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'cellheight'} = $newvalue; }
    return $self->{'cellheight'};
}

sub cellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'cellclass'} = $newvalue; }
    return $self->{'cellclass'};
}

sub weekdaycellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'weekdaycellclass'} = $newvalue; }
    return $self->{'weekdaycellclass'};
}

sub weekendcellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'weekendcellclass'} = $newvalue; }
    return $self->{'weekendcellclass'};
}

sub todaycellclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'todaycellclass'} = $newvalue; }
    return $self->{'todaycellclass'};
}

sub datecellclass {
    my $self = shift;
    my $date = lc(shift) || return(); $date = int($date) if $date =~ m/^[\d\.]+$/;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'datecellclass'}->{$date} = $newvalue; }
    return $self->{'datecellclass'}->{$date};
}

sub headerclass {
    my $self = shift;
    my $newvalue = shift;
    if (defined($newvalue)) { $self->{'headerclass'} = $newvalue; }
    return $self->{'headerclass'};
}



__END__;
#################################################################################


=head1 NAME

HTML::CalendarMonthSimple - Perl Module for Generating HTML Calendars


=head1 SYNOPSIS

   use HTML::CalendarMonthSimple;
   $cal = new HTML::CalendarMonthSimple('year'=>2001,'month'=>2);
   $cal->width('50%');
   $cal->border(10);
   $cal->header('Text at the top of the Grid');
   $cal->setcontent(14,"Valentine's Day");
   $cal->setdatehref(14, 'http://localhost/');
   $cal->addcontent(14,"<p>Don't forget to buy flowers.");
   $cal->addcontent(13,"Guess what's tomorrow?");
   $cal->bgcolor('pink');
   print $cal->as_HTML;


=head1 DESCRIPTION

HTML::CalendarMonthSimple is a Perl module for generating, manipulating, and printing a HTML calendar grid for a specified month. It is intended as a faster and easier-to-use alternative to HTML::CalendarMonth.

This module requires the Date::Calc module, which is available from CPAN if you don't already have it.


=head1 INTERFACE METHODS


=head1 new(ARGUMENTS)

Naturally, new() returns a newly constructed calendar object. Recognized arguments are 'year' and 'month', to specify which month's calendar will be used. If either is omitted, the current value is used. An important note is that the month and the year are NOT the standard C or Perl -- use a month in the range 1-12 and a real year, e.g. 2001.

   # Examples:
   # Create a calendar for this month.
   $cal = new HTML::CalendarMonthSimple();
   # One for a specific month/year
   $cal = new HTML::CalendarMonthSimple('month'=>2,'year=>2000);
   # One for "the current month" in 1997
   $cal = new HTML::CalendarMonthSimple('year'=>1997);


=head1 year()

=head1 month()

=head1 monthname()

These methods simply return the year/month of the calendar. monthname() returns the text name of the month, e.g. "December".



=head1 setcontent(DATE,STRING)

=head1 addcontent(DATE,STRING)

=head1 getcontent(DATE)

These methods are used to control the content of date cells within the calendar grid. The DATE argument may be a numeric date or it may be a string describing a certain occurrence of a weekday, e.g. "3MONDAY" to represent "the third Monday of the month being worked with", or it may be the plural of a weekday name, e.g. "wednesdays" to represent all occurrences of the given weekday. The weekdays are case-insensitive.

   # Examples:
   # The cell for the 15th of the month will now say something.
   $cal->setcontent(15,"An Important Event!");
   # Later down the program, we want the content to be boldfaced.
   $foo = "<b>" . $cal->getcontent(15) . "</b>";
   $cal->setcontent(15,$foo);
   # Or we could get extra spiffy:
   $cal->setcontent(15,"<b>" . $cal->getcontent(15) . "</b>");

   # addcontent() does not clobber existing content.
   # Also, if you setcontent() to '', you've deleted the content.
   $cal->setcontent(16,'');
   $cal->addcontent(16,"<p>Hello World</p>");
   $cal->addcontent(16,"<p>Hello Again</p>");
   print $cal->getcontent(16); # Prints 2 sentences

   # Padded and decimal numbers may be used, as well:
   $cal->setcontent(3.14159,'Third of the month');
   $cal->addcontent('00003.0000','Still the third');
   $cal->getcontent('3'); # Gets the 2 sentences

   # The second Sunday of May is some holiday or another...
   $cal->addcontent('2sunday','Some Special Day') if ($cal->month() == 5);
   # So is the third wednesday of this month
   $cal->setcontent('3WedNEsDaY','Third Wednesday!');
   # What's scheduled for the second Friday?
   $cal->getcontent('2FRIDAY');

   # Every Wednesday and Friday of this month...
   $cal->addcontent('wednesdays','Every Wednesday!');
   $cal->getcontent('Fridays');



=head1 as_HTML()

This method returns a string containing the HTML table for the month.

   # Example:
   print $cal->as_HTML();

It's okay to continue modifying the calendar after calling as_HTML(). My guess is that you'd want to call as_HTML() again to print the further-modified calendar, but that's your business...



=head1 setdatehref(DATE,URL_STRING)

=head1 getdatehref(DATE)

These methods are used to control the content of date cells within the calendar grid.

   # Example:
   # The date number in the cell for the 15th of the month will 
   # be a link to the sourceforge website
   $cal->setdatehref(15,"http://sourceforge.net/");

   # Example:
   # You want to add to an URL
   $cal->setdatehref(15, $getdatehref(15)."projects/perl/");


=head1 contentfontsize([STRING])

contentfontsize() sets the font size for the contents of the cell, overriding the browser's default. Can be expressed as an absolute (1 .. 6) or relative (-3 .. +3) size.


=head1 border([INTEGER])

This specifies the value of the border attribute to the <TABLE> declaration for the calendar. As such, this controls the thickness of the border around the calendar table. The default value is 5.

If a value is not specified, the current value is returned. If a value is specified, the border value is changed and the new value is returned.


=head1 width([INTEGER][%])

This sets the value of the width attribute to the <TABLE> declaration for the calendar. As such, this controls the horizintal width of the calendar.

The width value can be either an integer (e.g. 600) or a percentage string (e.g. "80%"). Most web browsers take an integer to be the table's width in pixels and a percentage to be the table width relative to the screen's width. The default width is "100%".

If a value is not specified, the current value is returned. If a value is specified, the border value is changed and the new value is returned.

   # Examples:
   $cal->width(600);    # absolute pixel width
   $cal->width("100%"); # percentage of screen size


=head1 showdatenumbers([1 or 0])

If showdatenumbers() is set to 1, then the as_HTML() method will put date labels in each cell (e.g. a 1 on the 1st, a 2 on the 2nd, etc.) If set to 0, then the date labels will not be printed. The default is 1.

If no value is specified, the current value is returned.

The date numbers are shown in boldface, normal size font. If you want to change this, consider setting showdatenumbers() to 0 and using setcontent()/addcontent() instead.


=head1 showweekdayheaders([1 or 0])

=head1 weekdayheadersbig([1 or 0])

If showweekdayheaders() is set to 1 (the default) then calendars rendered via as_HTML() will display the names of the days of the week. If set to 0, the days' names will not be displayed.

If weekdayheadersbig() is set to 1 (the default) then the weekday headers will be in <th> cells. The effect in most web browsers is that they will be boldfaced and centered. If set to 0, the weekday headers will be in <td> cells and in normal text.

For both functions, if no value is specified, the current value is returned.


=head1 cellalignment([STRING])

=head1 vcellalignment([STRING])

cellalignment() sets the value of the align attribute to the <TD> tag for each day's cell. This controls how text will be horizontally centered/aligned within the cells. vcellalignment() does the same for vertical alignment. By default, content is aligned horizontally "left" and vertically "top"

Any value can be used, if you think the web browser will find it interesting. Some useful alignments are: left, right, center, top, and bottom.


=head1 header([STRING])

By default, the current month and year are displayed at the top of the calendar grid. This is called the "header".

The header() method allows you to set the header to whatever you like. If no new header is specified, the current header is returned.

If the header is set to an empty string, then no header will be printed at all. (No, you won't be stuck with a big empty cell!)

   # Example:
   # Set the month/year header to something snazzy.
   my($y,$m) = ( $cal->year() , $cal->monthname() );
   $cal->header("<center><font size=+2 color=red>$m $y</font></center>\n\n");


=head1 bgcolor([STRING])

=head1 weekdaycolor([STRING])

=head1 weekendcolor([STRING])

=head1 todaycolor([STRING])

=head1 bordercolor([STRING])

=head1 weekdaybordercolor([STRING])

=head1 weekendbordercolor([STRING])

=head1 todaybordercolor([STRING])

=head1 contentcolor([STRING])

=head1 weekdaycontentcolor([STRING])

=head1 weekendcontentcolor([STRING])

=head1 todaycontentcolor([STRING])

=head1 headercolor([STRING])

=head1 headercontentcolor([STRING])

=head1 weekdayheadercolor([STRING])

=head1 weekdayheadercontentcolor([STRING])

=head1 weekendheadercolor([STRING])

=head1 weekendheadercontentcolor([STRING])

These define the colors of the cells. If a string (which should be either a HTML color-code like '#000000' or a color-word like 'yellow') is supplied as an argument, then the color is set to that specified. Otherwise, the current value is returned. To un-set a value, try assigning the null string as a value.

The bgcolor defines the color of all cells. The weekdaycolor overrides the bgcolor for weekdays (Monday through Friday), the weekendcolor overrides the bgcolor for weekend days (Saturday and Sunday), and the todaycolor overrides the bgcolor for today's date. (Which may not mean a lot if you're looking at a calendar other than the current month.)

The weekdayheadercolor overrides the bgcolor for the weekday headers that appear at the top of the calendar if showweekdayheaders() is true, and weekendheadercolor does the same thing for the weekend headers. The headercolor overrides the bgcolor for the month/year header at the top of the calendar. The headercontentcolor(), weekdayheadercontentcolor(), and weekendheadercontentcolor() methods affect the color of the corresponding headers' contents and default to the contentcolor().

The colors of the cell borders may be set: bordercolor determines the color of the calendar grid's outside border, and is the default color of the inner border for individual cells. The inner bordercolor may be overridden for the various types of cells via weekdaybordercolor, weekendbordercolor, and todaybordercolor.

Finally, the color of the cells' contents may be set with contentcolor, weekdaycontentcolor, weekendcontentcolor, and todaycontentcolor. The contentcolor is the default color of cell content, and the other methods override this for the appropriate days' cells.

   # Example:
   $cal->bgcolor('white');                  # Set the default cell bgcolor
   $cal->bordercolor('green');              # Set the default border color
   $cal->contentcolor('black');             # Set the default content color
   $cal->headercolor('yellow');             # Set the bgcolor of the Month+Year header
   $cal->headercontentcolor('yellow')       # Set the content color of the Month+Year header
   $cal->weekdayheadercolor('orange');      # Set the bgcolor of weekdays' headers
   $cal->weekendheadercontentcolor('blue'); # Set the color of weekday headers' contents
   $cal->weekendheadercolor('pink');        # Set the bgcolor of weekends' headers
   $cal->weekdayheadercontentcolor('blue'); # Set the color of weekend headers' contents
   $cal->weekendcolor('palegreen');         # Override weekends' cell bgcolor
   $cal->weekendcontentcolor('blue');       # Override weekends' content color
   $cal->todaycolor('red');                 # Override today's cell bgcolor
   $cal->todaycontentcolor('yellow');       # Override today's content color
   print $cal->as_HTML;                     # Print a really ugly calendar!


=head1 datecolor(DATE,[STRING])

=head1 datecontentcolor(DATE,[STRING])

=head1 datebordercolor(DATE,[STRING])

These methods set the cell color and the content color for the specified date, and will return the current value if STRING is not specified. These color settings will override any of the settings mentioned above, even todaycolor() and todaycontentcolor().

The date must be numeric; it cannot be a string such as "2wednesday"

  # Example: a red-letter day!
  $cal->datecolor(3,'pink');
  $cal->datecontentcolor(3,'red');



=head1 nowrap([1 or 0])

If set to 1, then calendar cells will have the NOWRAP attribute set, preventing their content from wrapping. If set to 0 (the default) then NOWRAP is not used and very long content may cause cells to become stretched out.


=head1 sharpborders([1 or 0])

If set to 1, this gives very crisp edges between the table cells. If set to 0 (the default) standard HTML cells are used. If neither value is specified, the current value is returned.

FYI: To accomplish the crisp border, the entire calendar table is wrapped inside a table cell.


=head1 cellheight([NUMBER])

This specifies the height in pixels of each cell in the calendar. By default, no height is defined and the web browser usually chooses a reasonable default.

If no value is given, the current value is returned.

To un-specify a height, try specifying a height of 0 or undef.



=head1 cellclass([STRING])

=head1 weekdaycellclass([STRING])

=head1 weekendcellclass([STRING])

=head1 todaycellclass([STRING])

=head1 datecellclass(DATE,[STRING])

=head1 headerclass([STRING])


These specify which CSS class will be attributed to the calendar's cells. By default, no classes are specified or used.

cellclass() is used for all calendar cells. weekdaycellclass(), weekendcellclass(), and todaycellclass() override the cellclass() for the corresponding types of cells. headerclass() is used for the calendar's header.

datecellclass() sets the CSS class for the cell for the specified date. This setting will override any of the other cell class settings, even todaycellclass()  This date must be numeric; it cannot be a string such as "2wednesday"

If no value is given, the current value is returned.

To un-specify a class, try specifying an empty string, e.g. cellclass('')




=head1 BUGS, TODO, CHANGES

Changes in 1.01: Added VALIGN to cells, to make alignment work with browsers better. Added showweekdayheaders(). Corrected a bug that results in the month not fitting on the grid (e.g. March 2003).  Added getdatehref() and setdatehref(). Corrected a bug that causes a blank week to be printed at the beginning of some months.

Changes in 1.02: Added the color methods.

Changes in 1.03: More color methods!

Changes in 1.04: Added the "which weekday" capability to addcontent(), setcontent(), and getcontent()

Changes in 1.05: addcontent(), et al can now take strings such as '06' or decimals such as '3.14' and will handle them correctly.

Changes in 1.06: Changed the "which weekday" interface a bit; truncations such as "2Tue" no longer work, and must be spelled out entirely ("2Tuesday"). Added "plural weekdays" support (e.g. "wednesdays" for "every wednesday").

Changes in 1.07: Fixed a typo that caused an entirely empty calendar to be displayed very small.

Changes in 1.08: Re-did the bugfixes described in 1.05, handling padded and non-integer dates.

Changes in 1.09: Fixed the "2Monday", et al support; a bug was found by Dale Wellman <dwellman@bpnetworks.com> where the 7th, 14th, 21st, and 28th days weren't properly computing which Nth weekday they were so "1Monday" wouldn't work if the first Monday was the 7th of the month.

Changes in 1.10: Added the headercontentcolor(), weekendheadercontentcolor(), and weekdayheadercontentcolor() methods, and made content headers use bgcolors, etc properly.

Changes in 1.11: The module's VERSION is now properly specified, so "use" statements won't barf if they specify a minimum version. Added the vcellalignment() method so vertical content alignment is independent of horizontal alignment.

Changes in 1.12: Fixed lots of warnings that were generated if B<-w> was used, due to many values defaulting to undef/blank. Added the sharpborders(), nowrap(), cellheight(), cellclass(), and weekdayheadersbig() methods. cellclass(), the beginning of CSS support. Thanks, Bray!

Changes in 1.13: Added more CSS methods: headerclass(), weekdaycellclass(), weekndcellclass(), todaycellclass(). Added a test to the module distribution at the urging of CPAN testers.

Changes in 1.14: Added the contentfontsize() method.

Changes in 1.15: Added the datecolor(), datecontentcolor(), datebordercolor(), and datecellclass() methods, allowind cosmetic attributes to be changed on a per-date basis.

Changes in 1.16: Fixed a very stupid bug that made addcontent() and setcontent() not work. Sorry!

Changes in 1.17: Corrected B<-w> warnings about uninitialized values in as_HTML().



=head1 AUTHORS, CREDITS, COPYRIGHTS

This Perl module is freeware. It may be copied, derived, used, and distributed without limitation.

HTML::CalendarMonth was written and is copyrighted by Matthew P. Sisk <sisk@mojotoad.com> and provided inspiration for the module's interface and features. None of Matt Sisk's code appears herein.

HTML::CalendarMonthSimple was written by Gregor Mosheh <stigmata@blackangel.net> Frankly, the major inspiration was the difficulty and unnecessary complexity of HTML::CalendarMonth. (Laziness is a virtue.)

This would have been extremely difficult if not for Date::Calc. Many thanks to Steffen Beyer <sb@engelschall.com> for a very fine set of date-related functions!

Dave Fuller <dffuller@yahoo.com> added the getdatehref() and setdatehref() methods, and pointed out the bugs that were corrected in 1.01.

Danny J. Sohier <danny@gel.ulaval.ca> provided many of the color functions.

Bernie Ledwick <bl@man.fwltech.com> provided base code for the today*() functions, and for the handling of cell borders.

Justin Ainsworth <jrainswo@olemiss.edu> provided the vcellalignment() concept and code.

Jessee Porter <porterje@us.ibm.com> provided fixes for 1.12 to correct those warnings.

Bray Jones <bjones@vialogix.com> supplied the sharpborders(), nowrap(), cellheight(), cellclass() methods.

Bill Turner <b@brilliantcorners.org> supplied the headerclass() method and the rest of the methods added to 1.13

Bill Rhodes <wrhodes@27.org> provided the contentfontsize() method for version 1.14

JT Smith <jt@plainblack.com> added the mondayisfirstday() method for truly international calendars.



