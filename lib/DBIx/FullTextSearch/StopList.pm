package DBIx::FullTextSearch::StopList;
use strict;

use Carp;

sub create_default {
  my ($class, $dbh, $TABLE, $language) = @_;

  croak("Error: no language specified") unless $language;

  $language = lc $language;

  my @stopList;

  if($language eq 'english'){
    @stopList = qw/ a about after all also an and any are as at be because been but by can co corp could for from had has have he her his if in inc into is it its last more most mr mrs ms mz no not of on one only or other out over s says she so some such than that the their there they this to up was we were when which who will with would /;
   } elsif ($language eq 'czech'){
     @stopList = qw/ a aby ale ani a¾ bude by byl byla bylo být co èi dal¹í do i jak jako je jeho jejich jen je¹tì ji¾ jsem jsme jsou k kde kdy¾ korun která které který kteøí let mezi má mù¾e na nebo není ne¾ o od pak po podle pouze pro proti první pøed pøi roce roku øekl s se si své tak také tedy to tom tím u u¾ v ve v¹ak z za ze ¾e/;
  } elsif ($language eq 'danish'){
    @stopList = qw/ af aldrig alle altid bagved De de der du efter eller en endnu et få fjernt for foran fra gennem god han her hos hovfor hun hurtig hvad hvem hvonår hvor hvordan hvorhen I i imod ja jeg langsom lidt mange måske med meget mellem mere mindre når nede nej nok nu og oppe på rask sammen temmelig til uden udenfor under ved vi /;
  } elsif ($language eq 'dutch'){
    @stopList = qw/ aan aangaande aangezien achter achterna afgelopen al aldaar aldus alhoewel alias alle allebei alleen alsnog altijd altoos ander andere anders anderszins behalve behoudens beide beiden ben beneden bent bepaald betreffende bij binnen binnenin boven bovenal bovendien bovengenoemd bovenstaand bovenvermeld buiten daar daarheen daarin daarna daarnet daarom daarop daarvanlangs dan dat de die dikwijls dit door doorgaand dus echter eer eerdat eerder eerlang eerst elk elke en enig enigszins enkel er erdoor even eveneens evenwel gauw gedurende geen gehad gekund geleden gelijk gemoeten gemogen geweest gewoon gewoonweg haar had hadden hare heb hebben hebt heeft hem hen het hierbeneden hierboven hij hoe hoewel hun hunne ik ikzelf in inmiddels inzake is jezelf jij jijzelf jou jouw jouwe juist jullie kan klaar kon konden krachtens kunnen kunt later liever maar mag meer met mezelf mij mijn mijnent mijner mijzelf misschien mocht mochten moest moesten moet moeten mogen na naar nadat net niet noch nog nogal nu of ofschoon om omdat omhoog omlaag omstreeks omtrent omver onder ondertussen ongeveer ons onszelf onze ook op opnieuw opzij over overeind overigens pas precies reeds rond rondom sedert sinds sindsdien slechts sommige spoedig steeds tamelijk tenzij terwijl thans tijdens toch toen toenmaals toenmalig tot totdat tussen uit uitgezonderd vaak van vandaan vanuit vanwege veeleer verder vervolgens vol volgens voor vooraf vooral vooralsnog voorbij voordat voordezen voordien voorheen voorop vooruit vrij vroeg waar waarom wanneer want waren was wat weer weg wegens wel weldra welk welke wie wiens wier wij wijzelf zal ze zelfs zichzelf zij zijn zijne zo zodra zonder zou zouden zowat zulke zullen zult /;
  } elsif ($language eq 'finnish'){
    @stopList = qw/ aina alla ansiosta ehkä ei enemmän ennen etessa haikki hän he hitaasti hoikein hyvin ilman ja jälkeen jos kanssa kaukana kenties keskellä kesken koskaan kuinkan kukka kyllä kylliksi lähellä läpi liian lla lla luona me mikä miksi milloin milloinkan minä missä miten nopeasti nyt oikea oikealla paljon siellä sinä ssa sta suoraan tai takana takia tarpeeksi tässä te ulkopuolella vähän vahemmän vasen vasenmalla vastan vielä vieressä yhdessä ylös /;
  } elsif ($language eq 'french'){
    @stopList = qw/ a à afin ailleurs ainsi alors après attendant au aucun aucune au-dessous au-dessus auprès auquel aussi aussitôt autant autour aux auxquelles auxquels avec beaucoup ça ce ceci cela celle celles celui cependant certain certaine certaines certains ces cet cette ceux chacun chacune chaque chez combien comme comment concernant dans de dedans dehors déjà delà depuis des dès desquelles desquels dessus donc donné dont du duquel durant elle elles en encore entre et étaient était étant etc eux furent grâce hormis hors ici il ils jadis je jusqu jusque la là laquelle le lequel les lesquelles lesquels leur leurs lors lorsque lui ma mais malgré me même mêmes mes mien mienne miennes miens moins moment mon moyennant ne ni non nos notamment notre nôtre notres nôtres nous nulle nulles on ou où par parce parmi plus plusieurs pour pourquoi près puis puisque quand quant que quel quelle quelque quelques-unes quelques-uns quelqu''un quelqu''une quels qui quiconque quoi quoique sa sans sauf se selon ses sien sienne siennes siens soi soi-même soit sont suis sur ta tandis tant te telle telles tes tienne tiennes tiens toi ton toujours tous toute toutes très trop tu un une vos votre vôtre vôtres vous vu y /;
  } elsif ($language eq 'german'){
    @stopList = qw/ ab aber allein als also am an auch auf aus außer bald bei beim bin bis bißchen bist da dabei dadurch dafür dagegen dahinter damit danach daneben dann daran darauf daraus darin darüber darum darunter das daß dasselbe davon davor dazu dazwischen dein deine deinem deinen deiner deines dem demselben den denn der derselben des desselben dessen dich die dies diese dieselbe dieselben diesem diesen dieser dieses dir doch dort du ebenso ehe ein eine einem einen einer eines entlang er es etwa etwas euch euer eure eurem euren eurer eures für fürs ganz gar gegen genau gewesen her herein herum hin hinter hintern ich ihm ihn Ihnen ihnen ihr Ihre ihre Ihrem ihrem Ihren ihren Ihrer ihrer Ihres ihres im in ist ja je jedesmal jedoch jene jenem jenen jener jenes kaum kein keine keinem keinen keiner keines man mehr mein meine meinem meinen meiner meines mich mir mit nach nachdem nämlich neben nein nicht nichts noch nun nur ob ober obgleich oder ohne paar sehr sei sein seine seinem seinen seiner seines seit seitdem selbst sich Sie sie sind so sogar solch solche solchem solchen solcher solches sondern sonst soviel soweit über um und uns unser unsre unsrem unsren unsrer unsres vom von vor während war wäre wären warum was wegen weil weit welche welchem welchen welcher welches wem wen wenn wer weshalb wessen wie wir wo womit zu zum zur zwar zwischen zwischens /;
  } elsif ($language eq 'italian'){
    @stopList = qw/ a affinchè agl'' agli ai al all'' alla alle allo anzichè avere bensì che chi cioè come comunque con contro cosa da dachè dagl'' dagli dai dal dall'' dalla dalle dallo degl'' degli dei del dell'' delle dello di dopo dove dunque durante e egli eppure essere essi finché fino fra giacchè gl'' gli grazie I il in inoltre io l'' la le lo loro ma mentre mio ne neanche negl'' negli nei nel nell'' nella nelle nello nemmeno neppure noi nonchè nondimeno nostro o onde oppure ossia ovvero per perchè perciò però poichè prima purchè quand''anche quando quantunque quasi quindi se sebbene sennonchè senza seppure si siccome sopra sotto su subito sugl'' sugli sui sul sull'' sulla sulle sullo suo talchè tu tuo tuttavia tutti un una uno voi vostr/;
  } elsif ($language eq 'portuguese'){
    @stopList = qw/ a abaixo adiante agora ali antes aqui até atras bastante bem com como contra debaixo demais depois depressa devagar direito e ela elas êle eles em entre eu fora junto longe mais menos muito não ninguem nós nunca onde ou para por porque pouco próximo qual quando quanto que quem se sem sempre sim sob sobre talvez todas todos vagarosamente você vocês /;
  } elsif ($language eq 'spanish'){
    @stopList = qw/ a acá ahí ajena ajenas ajeno ajenos al algo algún alguna algunas alguno algunos allá allí aquel aquella aquellas aquello aquellos aquí cada cierta ciertas cierto ciertos como cómo con conmigo consigo contigo cualquier cualquiera cualquieras cuan cuán cuanta cuánta cuantas cuántas cuanto cuánto cuantos cuántos de dejar del demás demasiada demasiadas demasiado demasiados el él ella ellas ellos esa esas ese esos esta estar estas este estos hacer hasta jamás junto juntos la las lo los mas más me menos mía mientras mío misma mismas mismo mismos mucha muchas muchísima muchísimas muchísimo muchísimos mucho muchos muy nada ni ninguna ningunas ninguno ningunos no nos nosotras nosotros nuestra nuestras nuestro nuestros nunca os otra otras otro otros para parecer poca pocas poco pocos por porque que qué querer quien quién quienes quienesquiera quienquiera ser si sí siempre sín Sr Sra Sres Sta suya suyas suyo suyos tal tales tan tanta tantas tanto tantos te tener ti toda todas todo todos tomar tú tuya tuyo un una unas unos usted ustedes varias varios vosotras vosotros vuestra vuestras vuestro vuestros y yo /;
  } elsif ($language eq 'swedish'){
    @stopList = qw/ ab aldrig all alla alltid än ännu ånyo är att av avser avses bakom bra bredvid dä där de dem den denna deras dess det detta du efter efterät eftersom ej eller emot en ett fastän för fort framför från genom gott hamske han här hellre hon hos hur i in ingen innan inte ja jag långsamt långt lite man med medan mellan mer mera mindre mot myckett när nära nej nere ni nu och oksa om över på så sådan sin skall som till tillräckligt tillsammans trotsatt under uppe ut utan utom vad väl var varför vart varthän vem vems vi vid vilken /;
  }

  croak("Error: language $language is not a supported") unless @stopList;

  my $sl = $class->create_empty($dbh, $TABLE);

  $sl->add_stop_word(\@stopList);
  return $sl;
}

sub create_empty {
  my ($class, $dbh, $name) = @_;

  my $table = $name . '_stoplist';

  my $SQL = qq{
CREATE TABLE $table
(word VARCHAR(255) PRIMARY KEY)
};
  
  $dbh->do($SQL) or croak "Can't create table $table: " . $dbh->errstr;

  my $self = {};
  $self->{'dbh'} = $dbh;
  $self->{'name'} = $name;
  $self->{'table'} = $table;
  $self->{'stoplist'} = {};
  bless $self, $class;
  return $self;
}

sub open {
  my ($class, $dbh, $name) = @_;

  my $table = $name . '_stoplist';

  my $self = {};
  $self->{'dbh'} = $dbh;
  $self->{'name'} = $name;
  $self->{'table'} = $table;
  $self->{'stoplist'} = {};
  bless $self, $class;

  # load stoplist into a hash
  my $SQL = qq{
SELECT word FROM $table
};
  my $ary_ref = $dbh->selectcol_arrayref($SQL) or croak "Can't load stoplist from $table: " . $dbh->errstr;
  for (@$ary_ref){
    $self->{'stoplist'}->{$_} = 1;
  }

  return $self;
}

sub drop {
  my $self = shift;
  my $dbh = $self->{'dbh'};
  my $table = $self->{'table'};
  my $SQL = qq{
DROP table $table
};
  $dbh->do($SQL) or croak "Can't drop table $table: " . $dbh->errstr;
  $self->{'stoplist'} = {};
}

sub empty {
  my $self = shift;
  my $dbh = $self->{'dbh'};
  my $table = $self->{'table'};
  my $SQL = qq{
DELETE FROM $table
};
  $dbh->do($SQL) or croak "Can't empty table $table: " . $dbh->errstr;
  $self->{'stoplist'} = {};
}

sub add_stop_word {
  my ($self, $words) = @_;
  my $dbh = $self->{'dbh'};

  $words = [ $words ] unless ref($words) eq 'ARRAY';

  my @new_stop_words;

  for my $word (@$words){
    next if $self->is_stop_word($word);
    push @new_stop_words, $word;
    $self->{'stoplist'}->{lc($word)} = 1;
  }
  my $SQL = "INSERT INTO $self->{'table'} (word) VALUES " . join(',', ('(?)') x @new_stop_words);
  $dbh->do($SQL,{},@new_stop_words);
}

sub remove_stop_word {
  my ($self, $words) = @_;
  my $dbh = $self->{'dbh'};

  $words = [ $words ] unless ref($words) eq 'ARRAY';

  my $SQL = qq{
DELETE FROM $self->{'table'} WHERE word=?
};

  my $sth = $dbh->prepare($SQL);

  my $stoplist = $self->{'stoplist'};

  for my $word (@$words){
    next unless $self->is_stop_word($word);
    $sth->execute($word);
    delete $stoplist->{lc($word)};
  }
}

sub is_stop_word {
  exists shift->{'stoplist'}->{lc($_[0])};
}

1;

__END__

=head1 NAME

DBIx::FullTextSearch::StopList - Stopwords for DBIx::FullTextSearch

=head1 SYNOPSIS

  use DBIx::FullTextSearch::StopList;
  # connect to database (regular DBI)
  my $dbh = DBI->connect('dbi:mysql:database', 'user', 'passwd');

  # create a new empty stop word list
  my $sl1 = DBIx::FullTextSearch::StopList->create_empty($dbh, 'sl_web_1');

  # or create a new one with default stop words
  my $sl2 = DBIx::FullTextSearch::StopList->create_default($dbh, 'sl_web_2', 'english');

  # or open an existing one
  my $sl3 = DBIx::FullTextSearch::StopList->open($dbh, 'sl_web_3');

  # add stop words
  $sl1->add_stop_word(['a','in','on','the']);

  # remove stop words
  $sl2->remove_stop_word(['be','because','been','but','by']);

  # check if word is in stoplist
  $bool = $sl1->is_stop_word('in');

  # empty stop words
  $sl3->empty;

  # drop stop word table
  $sl2->drop;

=head1 DESCRIPTION

DBIx::FullTextSearch::StopList provides stop lists that can be used -L<DBIx::FullTextSearch>.
StopList objects can be reused accross several FullTextSearch objects.

=head1 METHODS

=over 4

=head2 CONSTRUCTERS

=item create_empty

  my $sl = DBIx::FullTextSearch::StopList->create_empty($dbh, $sl_name);

This class method creates a new StopList object.

=item create_default

  my $sl = DBIx::FullTextSearch::StopList->create_default($dbh, $sl_name, $language);

This class method creates a new StopList object, with default words loaded in for the
given language.  Supported languages include Czech, Danish, Dutch, English, Finnish, French,
German, Italian, Portuguese, Spanish, and Swedish.

=item open

  my $sl = DBIx::FullTextSearch::StopList->open($dbh, $sl_name);

Opens and returns StopList object

=head2 OBJECT METHODS

=item add_stop_word

  $sl->add_stop_word(\@stop_words);

Adds stop words to StopList object.  Expects array reference as argument.

=item remove_stop_word

  $sl->remove_stop_word(\@stop_words);

Remove stop words from StopList object.  

=item is_stop_word

  $bool = $sl->is_stop_word($stop_word);

Returns true iff stop_word is StopList object

=item empty

  $sl->empty;

Removes all stop words in StopList object.

=item drop

  $sl->drop;

Removes table associated with the StopList object.

=back

=head1 AUTHOR

T.J. Mather, tjmather@tjmather.com,
http://www.tjmather.com/

=head1 COPYRIGHT

All rights reserved. This package is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<DBIx::FullTextSearch>
