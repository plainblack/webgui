# 1 "y.tab.pl"
#$yysccsid = "@(#)yaccpar 1.8 (Berkeley) 01/20/91 (Perl 2.0 12/31/92)";

# 20 "parser.y"

;# Copyright (c) 2000-2002 Graham Barr <gbarr@pobox.com>. All rights reserved.
;# This program is free software; you can redistribute it and/or
;# modify it under the same terms as Perl itself.

package Convert::ASN1::parser;

;# $Id$

use strict;
use Convert::ASN1 qw(:all);
use vars qw(
  $asn $yychar $yyerrflag $yynerrs $yyn @yyss
  $yyssp $yystate @yyvs $yyvsp $yylval $yys $yym $yyval
);

BEGIN { Convert::ASN1->_internal_syms }

my $yydebug=0;
my %yystate;

my %base_type = (
  BOOLEAN	    => [ asn_encode_tag(ASN_BOOLEAN),		opBOOLEAN ],
  INTEGER	    => [ asn_encode_tag(ASN_INTEGER),		opINTEGER ],
  BIT_STRING	    => [ asn_encode_tag(ASN_BIT_STR),		opBITSTR  ],
  OCTET_STRING	    => [ asn_encode_tag(ASN_OCTET_STR),		opSTRING  ],
  STRING	    => [ asn_encode_tag(ASN_OCTET_STR),		opSTRING  ],
  NULL 		    => [ asn_encode_tag(ASN_NULL),		opNULL    ],
  OBJECT_IDENTIFIER => [ asn_encode_tag(ASN_OBJECT_ID),		opOBJID   ],
  REAL		    => [ asn_encode_tag(ASN_REAL),		opREAL    ],
  ENUMERATED	    => [ asn_encode_tag(ASN_ENUMERATED),	opINTEGER ],
  ENUM		    => [ asn_encode_tag(ASN_ENUMERATED),	opINTEGER ],
  'RELATIVE-OID'    => [ asn_encode_tag(ASN_RELATIVE_OID),	opROID	  ],

  SEQUENCE	    => [ asn_encode_tag(ASN_SEQUENCE | ASN_CONSTRUCTOR), opSEQUENCE ],
  SET               => [ asn_encode_tag(ASN_SET      | ASN_CONSTRUCTOR), opSET ],

  ObjectDescriptor  => [ asn_encode_tag(ASN_UNIVERSAL |  7), opSTRING ],
  UTF8String        => [ asn_encode_tag(ASN_UNIVERSAL | 12), opUTF8 ],
  NumericString     => [ asn_encode_tag(ASN_UNIVERSAL | 18), opSTRING ],
  PrintableString   => [ asn_encode_tag(ASN_UNIVERSAL | 19), opSTRING ],
  TeletexString     => [ asn_encode_tag(ASN_UNIVERSAL | 20), opSTRING ],
  T61String         => [ asn_encode_tag(ASN_UNIVERSAL | 20), opSTRING ],
  VideotexString    => [ asn_encode_tag(ASN_UNIVERSAL | 21), opSTRING ],
  IA5String         => [ asn_encode_tag(ASN_UNIVERSAL | 22), opSTRING ],
  UTCTime           => [ asn_encode_tag(ASN_UNIVERSAL | 23), opUTIME ],
  GeneralizedTime   => [ asn_encode_tag(ASN_UNIVERSAL | 24), opGTIME ],
  GraphicString     => [ asn_encode_tag(ASN_UNIVERSAL | 25), opSTRING ],
  VisibleString     => [ asn_encode_tag(ASN_UNIVERSAL | 26), opSTRING ],
  ISO646String      => [ asn_encode_tag(ASN_UNIVERSAL | 26), opSTRING ],
  GeneralString     => [ asn_encode_tag(ASN_UNIVERSAL | 27), opSTRING ],
  CharacterString   => [ asn_encode_tag(ASN_UNIVERSAL | 28), opSTRING ],
  UniversalString   => [ asn_encode_tag(ASN_UNIVERSAL | 28), opSTRING ],
  BMPString         => [ asn_encode_tag(ASN_UNIVERSAL | 30), opSTRING ],

  CHOICE => [ '', opCHOICE ],
  ANY    => [ '', opANY ],
);

;# Given an OP, wrap it in a SEQUENCE

sub explicit {
  my $op = shift;
  my @seq = @$op;

  @seq[cTYPE,cCHILD,cVAR,cLOOP] = ('SEQUENCE',[$op],undef,undef);
  @{$op}[cTAG,cOPT] = ();

  \@seq;
}

# 74 "y.tab.pl"

sub constWORD () { 1 }
sub constCLASS () { 2 }
sub constSEQUENCE () { 3 }
sub constSET () { 4 }
sub constCHOICE () { 5 }
sub constOF () { 6 }
sub constIMPLICIT () { 7 }
sub constEXPLICIT () { 8 }
sub constOPTIONAL () { 9 }
sub constLBRACE () { 10 }
sub constRBRACE () { 11 }
sub constCOMMA () { 12 }
sub constANY () { 13 }
sub constASSIGN () { 14 }
sub constNUMBER () { 15 }
sub constENUM () { 16 }
sub constCOMPONENTS () { 17 }
sub constPOSTRBRACE () { 18 }
sub constYYERRCODE () { 256 }
my @yylhs = (                                               -1,
    0,    0,    2,    2,    3,    3,    6,    6,    6,    6,
    8,   13,   13,   12,   14,   14,   14,    9,    9,    9,
   10,   17,   17,   17,   17,   17,   11,   15,   15,   18,
   18,   18,   19,    1,    1,   20,   20,   20,   22,   22,
   22,   22,   21,   21,   21,   23,   23,    4,    4,    5,
    5,    5,   16,   16,   24,    7,    7,
);
my @yylen = (                                                2,
    1,    1,    3,    4,    4,    1,    1,    1,    1,    1,
    3,    1,    1,    5,    1,    1,    1,    4,    4,    4,
    4,    1,    1,    1,    1,    1,    1,    1,    2,    1,
    3,    3,    4,    1,    2,    1,    3,    3,    2,    1,
    1,    1,    4,    1,    3,    0,    1,    0,    1,    0,
    1,    1,    1,    3,    2,    0,    1,
);
my @yydefred = (                                             0,
    0,   49,    0,    0,    1,    0,    0,   44,    0,   36,
    0,    0,    0,    0,   52,   51,    0,    0,    0,    3,
    0,    6,    0,   11,    0,    0,    0,    0,   45,    0,
   37,   38,    0,   22,    0,    0,   25,    0,   42,   40,
    0,   41,    0,   27,   43,    4,    0,    0,    0,    0,
    7,    8,    9,   10,    0,   47,   39,    0,    0,    0,
    0,    0,    0,   30,   57,    5,    0,    0,   53,    0,
   18,   19,    0,   20,    0,    0,   55,   21,    0,    0,
    0,   32,   31,   54,    0,    0,   17,   15,   16,   14,
   33,
);
my @yydgoto = (                                              4,
    5,    6,   20,    7,   17,   50,   66,    8,   51,   52,
   53,   54,   43,   90,   62,   68,   44,   63,   64,    9,
   10,   45,   57,   69,
);
my @yysindex = (                                            53,
    5,    0,   -1,    0,    0,   12,   96,    0,   30,    0,
    7,   96,   14,    4,    0,    0,   41,   70,   70,    0,
   96,    0,   92,    0,    7,   17,   20,   43,    0,   33,
    0,    0,   92,    0,   17,   20,    0,   82,    0,    0,
   64,    0,   93,    0,    0,    0,   70,   70,   75,   91,
    0,    0,    0,    0,  110,    0,    0,   33,  106,  117,
   33,  131,   62,    0,    0,    0,  128,   95,    0,   96,
    0,    0,   96,    0,   75,   75,    0,    0,  110,   97,
   92,    0,    0,    0,   17,   20,    0,    0,    0,    0,
    0,
);
my @yyrindex = (                                           127,
   78,    0,    0,    0,    0,  133,   85,    0,   21,    0,
   78,  111,    0,    0,    0,    0,    0,  127,  118,    0,
  111,    0,    0,    0,   78,    0,    0,    0,    0,   78,
    0,    0,    0,    0,   11,   25,    0,   38,    0,    0,
   57,    0,    0,    0,    0,    0,  127,  127,    0,  119,
    0,    0,    0,    0,    0,    0,    0,   78,    0,    0,
   78,    0,  134,    0,    0,    0,    0,    0,    0,  111,
    0,    0,  111,    0,    0,  135,    0,    0,    0,    0,
    0,    0,    0,    0,   40,   66,    0,    0,    0,    0,
    0,
);
my @yygindex = (                                             0,
   89,    0,  123,    3,  -11,   68,    0,   -9,  -17,  -20,
  -15,  121,    0,    0,    0,    0,    0,    0,   63,    0,
  122,    0,    0,   71,
);
sub constYYTABLESIZE () { 150 }
my @yytable = (                                             29,
   23,   22,   40,   12,   13,   39,    2,   41,    2,   33,
   23,   23,   14,   21,   24,   22,   12,   25,   11,   23,
   34,   23,   23,    3,   24,   24,   47,   21,   23,   48,
   13,   34,   12,   24,    2,   24,   24,   26,   26,   23,
   23,   18,   24,   26,   27,   28,   26,   19,   26,   26,
   23,   23,   49,    1,    2,   26,   46,   23,   80,   88,
   70,   81,   87,   73,   89,   24,   24,   46,   46,    3,
   30,    2,   56,   75,   46,   61,   24,   24,   48,   76,
   48,   48,   48,   24,   48,   48,    3,   50,   50,   50,
   48,   55,   34,   48,   35,   36,   28,   34,   58,   85,
   86,   28,   15,   16,   37,   78,   79,   38,   65,   37,
   67,   50,   38,   50,   50,   50,   71,   35,   56,   56,
   48,   48,   48,   50,   48,   48,   50,   72,   35,   48,
   48,   48,    2,   48,   48,   59,   60,   82,   83,   31,
   32,   74,   77,   42,   28,   29,    0,   46,   91,   84,
);
my @yycheck = (                                             17,
   12,   11,   23,    1,    6,   23,    2,   23,    2,   21,
    0,    1,    1,   11,    1,   25,    6,   14,   14,    9,
    0,   11,   12,   17,    0,    1,   10,   25,   18,   10,
    6,   11,   30,    9,    2,   11,   12,    0,    1,    0,
    1,   12,   18,    3,    4,    5,    9,   18,   11,   12,
   11,   12,   10,    1,    2,   18,    0,   18,   70,   80,
   58,   73,   80,   61,   80,    0,    1,   11,   12,   17,
    1,    2,    9,   12,   18,    1,   11,   12,    1,   18,
    3,    4,    5,   18,    7,    8,   17,    3,    4,    5,
   13,   10,    1,   16,    3,    4,    5,    1,    6,    3,
    4,    5,    7,    8,   13,   11,   12,   16,   18,   13,
    1,    1,   16,    3,    4,    5,   11,    0,    0,    1,
    3,    4,    5,   13,    7,    8,   16,   11,   11,    3,
    4,    5,    0,    7,    8,   47,   48,   75,   76,   18,
   19,   11,   15,   23,   11,   11,   -1,   25,   81,   79,
);
sub constYYFINAL () { 4 }



sub constYYMAXTOKEN () { 18 }
# 262 "y.tab.pl"

sub yyclearin { $yychar = -1; }
sub yyerrok { $yyerrflag = 0; }
sub YYERROR { ++$yynerrs; &yy_err_recover; }
sub yy_err_recover
{
  if ($yyerrflag < 3)
  {
    $yyerrflag = 3;
    while (1)
    {
      if (($yyn = $yysindex[$yyss[$yyssp]]) && 
          ($yyn += constYYERRCODE()) >= 0 && 
          $yycheck[$yyn] == constYYERRCODE())
      {




        $yyss[++$yyssp] = $yystate = $yytable[$yyn];
        $yyvs[++$yyvsp] = $yylval;
        next yyloop;
      }
      else
      {




        return(1) if $yyssp <= 0;
        --$yyssp;
        --$yyvsp;
      }
    }
  }
  else
  {
    return (1) if $yychar == 0;
# 313 "y.tab.pl"

    $yychar = -1;
    next yyloop;
  }
0;
} # yy_err_recover

sub yyparse
{

  if ($yys = $ENV{'YYDEBUG'})
  {
    $yydebug = int($1) if $yys =~ /^(\d)/;
  }


  $yynerrs = 0;
  $yyerrflag = 0;
  $yychar = (-1);

  $yyssp = 0;
  $yyvsp = 0;
  $yyss[$yyssp] = $yystate = 0;

yyloop: while(1)
  {
    yyreduce: {
      last yyreduce if ($yyn = $yydefred[$yystate]);
      if ($yychar < 0)
      {
        if (($yychar = &yylex) < 0) { $yychar = 0; }
# 352 "y.tab.pl"

      }
      if (($yyn = $yysindex[$yystate]) && ($yyn += $yychar) >= 0 &&
              $yycheck[$yyn] == $yychar)
      {




        $yyss[++$yyssp] = $yystate = $yytable[$yyn];
        $yyvs[++$yyvsp] = $yylval;
        $yychar = (-1);
        --$yyerrflag if $yyerrflag > 0;
        next yyloop;
      }
      if (($yyn = $yyrindex[$yystate]) && ($yyn += $yychar) >= 0 &&
            $yycheck[$yyn] == $yychar)
      {
        $yyn = $yytable[$yyn];
        last yyreduce;
      }
      if (! $yyerrflag) {
        &yyerror('syntax error');
        ++$yynerrs;
      }
      return undef if &yy_err_recover;
    } # yyreduce




    $yym = $yylen[$yyn];
    $yyval = $yyvs[$yyvsp+1-$yym];
    switch:
    {
my $label = "State$yyn";
goto $label if exists $yystate{$label};
last switch;
State1: {
# 94 "parser.y"

{ $yyval = { '' => $yyvs[$yyvsp-0] }; 
last switch;
} }
State3: {
# 99 "parser.y"

{
		  $yyval = { $yyvs[$yyvsp-2], [$yyvs[$yyvsp-0]] };
		
last switch;
} }
State4: {
# 103 "parser.y"

{
		  $yyval=$yyvs[$yyvsp-3];
		  $yyval->{$yyvs[$yyvsp-2]} = [$yyvs[$yyvsp-0]];
		
last switch;
} }
State5: {
# 110 "parser.y"

{
		  $yyvs[$yyvsp-1]->[cTAG] = $yyvs[$yyvsp-3];
		  $yyval = $yyvs[$yyvsp-2] ? explicit($yyvs[$yyvsp-1]) : $yyvs[$yyvsp-1];
		
last switch;
} }
State11: {
# 124 "parser.y"

{
		  @{$yyval = []}[cTYPE,cCHILD] = ('COMPONENTS', $yyvs[$yyvsp-0]);
		
last switch;
} }
State14: {
# 134 "parser.y"

{
		  $yyvs[$yyvsp-0]->[cTAG] = $yyvs[$yyvsp-2];
		  @{$yyval = []}[cTYPE,cCHILD,cLOOP] = ($yyvs[$yyvsp-4], [$yyvs[$yyvsp-0]], 1);
		  $yyval = explicit($yyval) if $yyvs[$yyvsp-1];
		
last switch;
} }
State18: {
# 147 "parser.y"

{
		  @{$yyval = []}[cTYPE,cCHILD] = ('SEQUENCE', $yyvs[$yyvsp-1]);
		
last switch;
} }
State19: {
# 151 "parser.y"

{
		  @{$yyval = []}[cTYPE,cCHILD] = ('SET', $yyvs[$yyvsp-1]);
		
last switch;
} }
State20: {
# 155 "parser.y"

{
		  @{$yyval = []}[cTYPE,cCHILD] = ('CHOICE', $yyvs[$yyvsp-1]);
		
last switch;
} }
State21: {
# 161 "parser.y"

{
		  @{$yyval = []}[cTYPE] = ('ENUM');
		
last switch;
} }
State27: {
# 174 "parser.y"

{
		  @{$yyval = []}[cTYPE] = ($yyvs[$yyvsp-0]);
		
last switch;
} }
State28: {
# 179 "parser.y"

{ $yyval = $yyvs[$yyvsp-0]; 
last switch;
} }
State29: {
# 180 "parser.y"

{ $yyval = $yyvs[$yyvsp-1]; 
last switch;
} }
State30: {
# 184 "parser.y"

{
		  $yyval = [ $yyvs[$yyvsp-0] ];
		
last switch;
} }
State31: {
# 188 "parser.y"

{
		  push @{$yyval=$yyvs[$yyvsp-2]}, $yyvs[$yyvsp-0];
		
last switch;
} }
State32: {
# 192 "parser.y"

{
		  push @{$yyval=$yyvs[$yyvsp-2]}, $yyvs[$yyvsp-0];
		
last switch;
} }
State33: {
# 198 "parser.y"

{
		  @{$yyval=$yyvs[$yyvsp-0]}[cVAR,cTAG] = ($yyvs[$yyvsp-3],$yyvs[$yyvsp-2]);
		  $yyval = explicit($yyval) if $yyvs[$yyvsp-1];
		
last switch;
} }
State34: {
# 205 "parser.y"

{ $yyval = $yyvs[$yyvsp-0]; 
last switch;
} }
State35: {
# 206 "parser.y"

{ $yyval = $yyvs[$yyvsp-1]; 
last switch;
} }
State36: {
# 210 "parser.y"

{
		  $yyval = [ $yyvs[$yyvsp-0] ];
		
last switch;
} }
State37: {
# 214 "parser.y"

{
		  push @{$yyval=$yyvs[$yyvsp-2]}, $yyvs[$yyvsp-0];
		
last switch;
} }
State38: {
# 218 "parser.y"

{
		  push @{$yyval=$yyvs[$yyvsp-2]}, $yyvs[$yyvsp-0];
		
last switch;
} }
State39: {
# 224 "parser.y"

{
		  @{$yyval=$yyvs[$yyvsp-1]}[cOPT] = ($yyvs[$yyvsp-0]);
		
last switch;
} }
State43: {
# 233 "parser.y"

{
		  @{$yyval=$yyvs[$yyvsp-0]}[cVAR,cTAG] = ($yyvs[$yyvsp-3],$yyvs[$yyvsp-2]);
		  $yyval->[cOPT] = $yyvs[$yyvsp-3] if $yyval->[cOPT];
		  $yyval = explicit($yyval) if $yyvs[$yyvsp-1];
		
last switch;
} }
State45: {
# 240 "parser.y"

{
		  @{$yyval=$yyvs[$yyvsp-0]}[cTAG] = ($yyvs[$yyvsp-2]);
		  $yyval = explicit($yyval) if $yyvs[$yyvsp-1];
		
last switch;
} }
State46: {
# 246 "parser.y"

{ $yyval = undef; 
last switch;
} }
State47: {
# 247 "parser.y"

{ $yyval = 1;     
last switch;
} }
State48: {
# 251 "parser.y"

{ $yyval = undef; 
last switch;
} }
State50: {
# 255 "parser.y"

{ $yyval = undef; 
last switch;
} }
State51: {
# 256 "parser.y"

{ $yyval = 1;     
last switch;
} }
State52: {
# 257 "parser.y"

{ $yyval = 0;     
last switch;
} }
State53: {
# 260 "parser.y"

{
last switch;
} }
State54: {
# 261 "parser.y"

{
last switch;
} }
State55: {
# 264 "parser.y"

{
last switch;
} }
State56: {
# 267 "parser.y"

{
last switch;
} }
State57: {
# 268 "parser.y"

{
last switch;
} }
# 615 "y.tab.pl"

    } # switch
    $yyssp -= $yym;
    $yystate = $yyss[$yyssp];
    $yyvsp -= $yym;
    $yym = $yylhs[$yyn];
    if ($yystate == 0 && $yym == 0)
    {




      $yystate = constYYFINAL();
      $yyss[++$yyssp] = constYYFINAL();
      $yyvs[++$yyvsp] = $yyval;
      if ($yychar < 0)
      {
        if (($yychar = &yylex) < 0) { $yychar = 0; }
# 641 "y.tab.pl"

      }
      return $yyvs[$yyvsp] if $yychar == 0;
      next yyloop;
    }
    if (($yyn = $yygindex[$yym]) && ($yyn += $yystate) >= 0 &&
        $yyn <= $#yycheck && $yycheck[$yyn] == $yystate)
    {
        $yystate = $yytable[$yyn];
    } else {
        $yystate = $yydgoto[$yym];
    }




    $yyss[++$yyssp] = $yystate;
    $yyvs[++$yyvsp] = $yyval;
  } # yyloop
} # yyparse
# 272 "parser.y"


my %reserved = (
  'OPTIONAL' 	=> constOPTIONAL(),
  'CHOICE' 	=> constCHOICE(),
  'OF' 		=> constOF(),
  'IMPLICIT' 	=> constIMPLICIT(),
  'EXPLICIT' 	=> constEXPLICIT(),
  'SEQUENCE'    => constSEQUENCE(),
  'SET'         => constSET(),
  'ANY'         => constANY(),
  'ENUM'        => constENUM(),
  'ENUMERATED'  => constENUM(),
  'COMPONENTS'  => constCOMPONENTS(),
  '{'		=> constLBRACE(),
  '}'		=> constRBRACE(),
  ','		=> constCOMMA(),
  '::='         => constASSIGN(),
);

my $reserved = join("|", reverse sort grep { /\w/ } keys %reserved);

my %tag_class = (
  APPLICATION => ASN_APPLICATION,
  UNIVERSAL   => ASN_UNIVERSAL,
  PRIVATE     => ASN_PRIVATE,
  CONTEXT     => ASN_CONTEXT,
  ''	      => ASN_CONTEXT # if not specified, its CONTEXT
);

;##
;## This is NOT thread safe !!!!!!
;##

my $pos;
my $last_pos;
my @stacked;

sub parse {
  local(*asn) = \($_[0]);
  ($pos,$last_pos,@stacked) = ();

  eval {
    local $SIG{__DIE__};
    compile(verify(yyparse()));
  }
}

sub compile_one {
  my $tree = shift;
  my $ops = shift;
  my $name = shift;
  foreach my $op (@$ops) {
    next unless ref($op) eq 'ARRAY';
    bless $op;
    my $type = $op->[cTYPE];
    if (exists $base_type{$type}) {
      $op->[cTYPE] = $base_type{$type}->[1];
      $op->[cTAG] = defined($op->[cTAG]) ? asn_encode_tag($op->[cTAG]): $base_type{$type}->[0];
    }
    else {
      die "Unknown type '$type'\n" unless exists $tree->{$type};
      my $ref = compile_one(
		  $tree,
		  $tree->{$type},
		  defined($op->[cVAR]) ? $name . "." . $op->[cVAR] : $name
		);
      if (defined($op->[cTAG]) && $ref->[0][cTYPE] == opCHOICE) {
        @{$op}[cTYPE,cCHILD] = (opSEQUENCE,$ref);
      }
      else {
        @{$op}[cTYPE,cCHILD,cLOOP] = @{$ref->[0]}[cTYPE,cCHILD,cLOOP];
      }
      $op->[cTAG] = defined($op->[cTAG]) ? asn_encode_tag($op->[cTAG]): $ref->[0][cTAG];
    }
    $op->[cTAG] |= chr(ASN_CONSTRUCTOR)
      if length $op->[cTAG] && ($op->[cTYPE] == opSET || $op->[cTYPE] == opSEQUENCE);

    if ($op->[cCHILD]) {
      ;# If we have children we are one of
      ;#  opSET opSEQUENCE opCHOICE

      compile_one($tree, $op->[cCHILD], defined($op->[cVAR]) ? $name . "." . $op->[cVAR] : $name);

      ;# If a CHOICE is given a tag, then it must be EXPLICIT
      $op = explicit($op) if $op->[cTYPE] == opCHOICE && defined($op->[cTAG]) && length($op->[cTAG]);

      if ( @{$op->[cCHILD]} > 1) {
        ;#if ($op->[cTYPE] != opSEQUENCE) {
        ;# Here we need to flatten CHOICEs and check that SET and CHOICE
        ;# do not contain duplicate tags
        ;#}
      }
      else {
	;# A SET of one element can be treated the same as a SEQUENCE
	$op->[cTYPE] = opSEQUENCE if $op->[cTYPE] == opSET;
      }
    }
  }
  $ops;
}

sub compile {
  my $tree = shift;

  ;# The tree should be valid enough to be able to
  ;#  - resolve references
  ;#  - encode tags
  ;#  - verify CHOICEs do not contain duplicate tags

  ;# once references have been resolved, and also due to
  ;# flattening of COMPONENTS, it is possible for an op
  ;# to appear in multiple places. So once an op is
  ;# compiled we bless it. This ensure we dont try to
  ;# compile it again.

  while(my($k,$v) = each %$tree) {
    compile_one($tree,$v,$k);
  }

  $tree;
}

sub verify {
  my $tree = shift or return;
  my $err = "";

  ;# Well it parsed correctly, now we
  ;#  - check references exist
  ;#  - flatten COMPONENTS OF (checking for loops)
  ;#  - check for duplicate var names

  while(my($name,$ops) = each %$tree) {
    my $stash = {};
    my @scope = ();
    my $path = "";
    my $idx = 0;

    while($ops) {
      if ($idx < @$ops) {
	my $op = $ops->[$idx++];
	my $var;
	if (defined ($var = $op->[cVAR])) {
	  
	  $err .= "$name: $path.$var used multiple times\n"
	    if $stash->{$var}++;

	}
	if (defined $op->[cCHILD]) {
	  if (ref $op->[cCHILD]) {
	    push @scope, [$stash, $path, $ops, $idx];
	    if (defined $var) {
	      $stash = {};
	      $path .= "." . $var;
	    }
	    $idx = 0;
	    $ops = $op->[cCHILD];
	  }
	  elsif ($op->[cTYPE] eq 'COMPONENTS') {
	    splice(@$ops,--$idx,1,expand_ops($tree, $op->[cCHILD]));
	  }
          else {
	    die "Internal error\n";
          }
	}
      }
      else {
	my $s = pop @scope
	  or last;
	($stash,$path,$ops,$idx) = @$s;
      }
    }
  }
  die $err if length $err;
  $tree;
}

sub expand_ops {
  my $tree = shift;
  my $want = shift;
  my $seen = shift || { };
  
  die "COMPONENTS OF loop $want\n" if $seen->{$want}++;
  die "Undefined macro $want\n" unless exists $tree->{$want};
  my $ops = $tree->{$want};
  die "Bad macro for COMPUNENTS OF '$want'\n"
    unless @$ops == 1
        && ($ops->[0][cTYPE] eq 'SEQUENCE' || $ops->[0][cTYPE] eq 'SET')
        && ref $ops->[0][cCHILD];
  $ops = $ops->[0][cCHILD];
  for(my $idx = 0 ; $idx < @$ops ; ) {
    my $op = $ops->[$idx++];
    if ($op->[cTYPE] eq 'COMPONENTS') {
      splice(@$ops,--$idx,1,expand_ops($tree, $op->[cCHILD], $seen));
    }
  }

  @$ops;
}

sub _yylex {
  my $ret = &_yylex;
  warn $ret;
  $ret;
}

sub yylex {
  return shift @stacked if @stacked;

  while ($asn =~ /\G(?:
	  (\s+|--[^\n]*)
	|
	  ([,{}]|::=)
	|
	  ($reserved)\b
	|
	  (
	    (?:OCTET|BIT)\s+STRING
	   |
	    OBJECT\s+IDENTIFIER
	   |
	    RELATIVE-OID
	  )\b
	|
	  (\w+)
	|
	    \[\s*
	  (
	   (?:(?:APPLICATION|PRIVATE|UNIVERSAL|CONTEXT)\s+)?
	   \d+
          )
	    \s*\]
	|
	  \((\d+)\)
	)/sxgo
  ) {

    ($last_pos,$pos) = ($pos,pos($asn));

    next if defined $1; # comment or whitespace

    if (defined $2 or defined $3) {
      #A comma is not required after a '}' so to aid the
      #parser we insert a fake token after any '}'
      push @stacked, constPOSTRBRACE() if defined $2 and $+ eq '}';

      return $reserved{$yylval = $+};
    }

    if (defined $4) {
      ($yylval = $+) =~ s/\s+/_/g;
      return constWORD();
    }

    if (defined $5) {
      $yylval = $+;
      return constWORD();
    }

    if (defined $6) {
      my($class,$num) = ($+ =~ /^([A-Z]*)\s*(\d+)$/);
      $yylval = asn_tag($tag_class{$class}, $num); 
      return constCLASS();
    }

    if (defined $7) {
      $yylval = $+;
      return constNUMBER();
    }

    die "Internal error\n";

  }

  die "Parse error before ",substr($asn,$pos,40),"\n"
    unless $pos == length($asn);

  0
}

sub yyerror {
  die @_," ",substr($asn,$last_pos,40),"\n";
}

1;

# 947 "y.tab.pl"

%yystate = ('State20','','State21','','State43','','State27','','State28',
'','State45','','State29','','State46','','State47','','State48','',
'State1','','State3','','State4','','State5','','State11','','State14','',
'State30','','State31','','State32','','State33','','State18','','State34',
'','State50','','State19','','State35','','State51','','State36','',
'State52','','State37','','State53','','State38','','State54','','State39',
'','State55','','State56','','State57','');

1;
