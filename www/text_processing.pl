{
  my %killhash2 = (
  ';' => '\;',
  '!' => '\!',
  '(' => '\(',
  ')' => '\)',
  '-' => '\-',
  '.' => '\.',
  '/' => '\/',
  ':' => '\:',
  '?' => '\?',
  '[' => '\[',
  '\\' => '\\\\',
  ']' => '\]',
  '^' => '\^'
  );

{
  open(smiles, "<smiles.txt");
  flock(smiles, 1);
  @smiles = ();
  $buf=0;
  while (<smiles>)
  {
    chomp;
    @smiles[$buf] = [split(/\|/, $_)];
    $buf++;
  }
  close(smiles);
}

sub MakeSmileys{
  $buf=0;
  if($_[0] ne 1)
  {$imgpach = "$site/image/";}
  else
  {$imgpach = "$site/image/";}

  $messagebuf =~ s~:D~<img src=\"$imgpach\icon_biggrin.gif\" width=15 height=15 alt=\"Very Happy\" border=0>~g;
  $messagebuf =~ s~:\)~<img src=\"$imgpach\icon_smile.gif\" width=15 height=15 alt=\"Smile\" border=0>~g;
  $messagebuf =~ s~:\(~<img src=\"$imgpach\icon_sad.gif\" width=15 height=15 alt=\"Sad\" border=0>~g;
  $messagebuf =~ s~:shock:~<img src=\"$imgpach\icon_eek.gif\" width=15 height=15 alt=\"Shocked\" border=0>~g;
  $messagebuf =~ s~:\?~<img src=\"$imgpach\icon_confused.gif\" width=15 height=15 alt=\"Confused\" border=0>~g;
  $messagebuf =~ s~8\)~<img src=\"$imgpach\icon_cool.gif\" width=15 height=15 alt=\"Cool\" border=0>~g;
  $messagebuf =~ s~:lol:~<img src=\"$imgpach\icon_lol.gif\" width=15 height=15 alt=\"Laughing\" border=0>~g;
  $messagebuf =~ s~:x~<img src=\"$imgpach\icon_mad.gif\" width=15 height=15 alt=\"Mad\" border=0>~g;
  $messagebuf =~ s~:P~<img src=\"$imgpach\icon_razz.gif\" width=15 height=15 alt=\"Razz\" border=0>~g;
  $messagebuf =~ s~:oops:~<img src=\"$imgpach\icon_redface.gif\" width=15 height=15 alt=\"Embarassed\" border=0>~g;
  $messagebuf =~ s~:o~<img src=\"$imgpach\icon_surprised.gif\" width=15 height=15 alt=\"Surprised\" border=0>~g;
  $messagebuf =~ s~:cry:~<img src=\"$imgpach\icon_cry.gif\" width=15 height=15 alt=\"Crying or Very sad\" border=0>~g;
  $messagebuf =~ s~:evil:~<img src=\"$imgpach\icon_evil.gif\" width=15 height=15 alt=\"Evil or Very Mad\" border=0>~g;
  $messagebuf =~ s~:twisted:~<img src=\"$imgpach\icon_twisted.gif\" width=15 height=15 alt=\"Twisted Evil\" border=0>~g;
  $messagebuf =~ s~:roll:~<img src=\"$imgpach\icon_rolleyes.gif\" width=15 height=15 alt=\"Rolling Eyes\" border=0>~g;
  $messagebuf =~ s~:wink:~<img src=\"$imgpach\icon_wink.gif\" width=15 height=15 alt=\"Wink\" border=0>~g;
  $messagebuf =~ s~:\[~<img src=\"$imgpach\icon_neutral.gif\" width=15 height=15 alt=\"Neutral\" border=0>~g;
  $messagebuf =~ s~:mrgreen:~<img src=\"$imgpach\icon_mrgreen.gif\" width=15 height=15 alt=\"Mr. Green\" border=0>~g;
  $messagebuf =~ s~:beer:~<img src=\"$imgpach\icon_beer.gif\" width=57 height=16 alt=\"Пивка!\" border=0>~g;
  $messagebuf =~ s~:drink:~<img src=\"$imgpach\icon_drink.gif\" width=24 height=18 alt=\"Пьяный :)\" border=0>~g;
  $messagebuf =~ s~:kos:~<img src=\"$imgpach\icon_kos.gif\" width=40 height=43 alt=\"Косяк\" border=0>~g;
  $messagebuf =~ s~:haha:~<img src=\"$imgpach\icon_haha.gif\" width=15 height=15 alt=\"ХА-ХА!!!\" border=0>~g;
  $messagebuf =~ s~:mol:~<img src=\"$imgpach\icon_pray.gif\" width=27 height=22 alt=\"БОГ!\" border=0>~g;
  $messagebuf =~ s~:super:~<img src=\"$imgpach\icon_super.gif\" width=26 height=28 alt=\"Супер!\" border=0>~g;
  $messagebuf =~ s~:appl:~<img src=\"$imgpach\icon_appl.gif\" width=35 height=31 alt=\"Мои аплодисменты!\" border=0>~g;
  $messagebuf =~ s~:up:~<img src=\"$imgpach\icon_up.gif\" width=15 height=15 alt=\"Здорово!\" border=0>~g;
  $messagebuf =~ s~:down:~<img src=\"$imgpach\icon_down.gif\" width=15 height=15 alt=\"Отстой!\" border=0>~g;
  $messagebuf =~ s~:figa:~<img src=\"$imgpach\icon_figa.gif\" width=20 height=20 alt=\"Фиг тебе!\" border=0>~g;
  $messagebuf =~ s~:ps:~<img src=\"$imgpach\icon_ps.gif\" width=17 height=16 alt=\"Пы СЫ\" border=0>~g;
  $messagebuf =~ s~:copy:~<img src=\"$imgpach\icon_c.gif\" width=28 height=28 alt=\"©\" border=0>~g;
  $messagebuf =~ s~:sla:~<img src=\"$imgpach\icon_sla.gif\" width=28 height=22 alt=\"Наблюдатель\" border=0>~g;
  $messagebuf =~ s~:nnn:~<img src=\"$imgpach\icon_nnn.gif\" width=82 height=16 alt=\"Я не вмешиваюсь\" border=0>~g;
  $messagebuf =~ s~:jump:~<img src=\"$imgpach\icon_2jump.gif\" width=30 height=46 alt=\"Прыжки\" border=0>~g;
  $messagebuf =~ s~:rotate:~<img src=\"$imgpach\icon_rotate.gif\" width=15 height=15 alt=\"Вертится\" border=0>~g;
  $messagebuf =~ s~:vedi:~<img src=\"$imgpach\icon_vedi.gif\" width=60 height=50 alt=\"Поприличнее\" border=0>~g;
  $messagebuf =~ s~:vesel:~<img src=\"$imgpach\icon_vesel.gif\" width=90 height=55 alt=\"Веселись\" border=0>~g;
  $messagebuf =~ s~:leb:~<img src=\"$imgpach\icon_leb.gif\" width=74 height=22 alt=\"Лебединое озеро\" border=0>~g;
  $messagebuf =~ s~:dance:~<img src=\"$imgpach\icon_dance.gif\" width=32 height=32 alt=\"Танец\" border=0>~g;
  $messagebuf =~ s~:kolbasa:~<img src=\"$imgpach\icon_kolbas.gif\" width=48 height=18 alt=\"Колбаса\" border=0>~g;
  $messagebuf =~ s~:ura:~<img src=\"$imgpach\icon_ura.gif\" width=42 height=34 alt=\"Ура!!!\" border=0>~g;
  $messagebuf =~ s~:ura2:~<img src=\"$imgpach\icon_ura2.gif\" width=100 height=20 alt=\"Урааа!!!\" border=0>~g;
  $messagebuf =~ s~:rev:~<img src=\"$imgpach\icon_rev.gif\" width=40 height=25 alt=\"Реверанс\" border=0>~g;
  $messagebuf =~ s~:priznan:~<img src=\"$imgpach\icon_priznan.gif\" width=57 height=38 alt=\"Признание\" border=0>~g;
  $messagebuf =~ s~:dream:~<img src=\"$imgpach\icon_odream.gif\" width=25 height=30 alt=\"Мечтать\" border=0>~g;
  $messagebuf =~ s~:gorgeous:~<img src=\"$imgpach\icon_gorgeous.gif\" width=28 height=20 alt=\"Красотка\" border=0>~g;
  $messagebuf =~ s~:inlove:~<img src=\"$imgpach\icon_inlove.gif\" width=15 height=15 alt=\"Влюблёно\" border=0>~g;
  $messagebuf =~ s~:byl:~<img src=\"$imgpach\icon_byl.gif\" width=54 height=23 alt=\"десь был я\" border=0>~g;
  $messagebuf =~ s~:lam:~<img src=\"$imgpach\icon_lam.gif\" width=60 height=23 alt=\"Ламер\" border=0>~g;
  $messagebuf =~ s~:inv:~<img src=\"$imgpach\icon_inv.gif\" width=80 height=20 alt=\"Инвалид\" border=0>~g;
  $messagebuf =~ s~:spy:~<img src=\"$imgpach\icon_spy.gif\" width=15 height=15 alt=\"Шпион\" border=0>~g;
  $messagebuf =~ s~:weep:~<img src=\"$imgpach\icon_weep.gif\" width=21 height=15 alt=\"Плачет\" border=0>~g;
  $messagebuf =~ s~:no-no:~<img src=\"$imgpach\icon_dont.gif\" width=28 height=27 alt=\"НО-НО!\" border=0>~g;
  $messagebuf =~ s~:nud:~<img src=\"$imgpach\icon_nud.gif\" width=60 height=49 alt=\"Скрипач\" border=0>~g;
  $messagebuf =~ s~:bud:~<img src=\"$imgpach\icon_bud.gif\" width=60 height=40 alt=\"По коням!\" border=0>~g;
  $messagebuf =~ s~:nunu:~<img src=\"$imgpach\icon_nunu.gif\" width=43 height=19 alt=\"Ну-Ну...\" border=0>~g;
  $messagebuf =~ s~:box2:~<img src=\"$imgpach\icon_box2.gif\" width=28 height=21 alt=\"Бокс\" border=0>~g;
  $messagebuf =~ s~:saw:~<img src=\"$imgpach\icon_chain.gif\" width=75 height=26 alt=\"Порублю!!!\" border=0>~g;
  $messagebuf =~ s~:susel:~<img src=\"$imgpach\icon_susel.gif\" width=70 height=29 alt=\"Подходи по одному\" border=0>~g;
  $messagebuf =~ s~:maniac:~<img src=\"$imgpach\icon_maniac.gif\" width=70 height=25 alt=\"Маньяк\" border=0>~g;
  $messagebuf =~ s~:rose:~<img src=\"$imgpach\icon_rose.gif\" width=17 height=22 alt=\"Роза\" border=0>~g;

}
}

sub simplequotemsg {
  my $qmessage = $_[0];
  my $qmessage2;
  $qmessage =~ s~\/me\s+(.*?)(\n.*?)~<font color="#FF0000">* $1</font>~ig;
  $qmessage =~ s~<font color="#FF0000">(.*?)\/me~<font color="#FF0000">$1\&\#47\;me~ig;
  $qmessage =~ s~\/me\s+([\s\S]*)~<font color="#FF0000">* $1</font>~ig;
  $qmessage =~ s~\/me~\&\#47\;me~ig;
  if($_[1] eq 0)
  {$buf=" class=\"qbackr1\""}
  else
  {$buf=" class=\"qbackr2\"";}
  $qmessage2 = qq~<table cellpadding=0 cellspacing=0 class=tableq1><tr height=1><td colspan=2 class=qbackb><tr><td width=15$buf></td><td$buf>QU0TE</td></tr><tr height=1><td colspan=2 class=qbackb></table>~;
  $qmessage2 =~ s~QU0TE~$qmessage~g;
  return $qmessage2;
}

{
  my %killhash = (
  ';' => '&#059;',
  '!' => '&#33;',
  '(' => '&#40;',
  ')' => '&#41;',
  '-' => '&#45;',
  '.' => '&#46;',
  '/' => '&#47;',
  ':' => '&#58;',
  '?' => '&#63;',
  '[' => '&#91;',
  '\\' => '&#92;',
  ']' => '&#93;',
  '^' => '&#94;'
  );

  sub codemsg {
    my $code = $_[0];
    my $codebuf;
    if($code !~ /&\S*;/) { $code =~ s/;/&#059;/g; }
    $code =~ s~([\(\)\-\:\\\/\?\!\]\[\.\^])~$killhash{$1}~g;
    $codebuf = qq~<table border='0' align='center' width='95%' cellpadding='3' cellspacing='1'><tr><td><b>CODE</b> </td></tr><tr><td id='CODE'>C0DE</td></tr></table>~;
    $codebuf =~ s~C0DE~$code~g;
    return $codebuf;
  }
}

sub text_process {

  $messagebuf = $_[0];

  $messagebuf =~ s~\[code\]~ \[code\]~ig;
  $messagebuf =~ s~\[/code\]~ \[/code\]~ig;
  $messagebuf =~ s~\[quote\]~ \[quote\]~ig;
  $messagebuf =~ s~\[/quote\]~ \[/quote\]~ig;
  $messagebuf =~ s~\[glow\]~ \[glow\]~ig;
  $messagebuf =~ s~\[/glow\]~ \[/glow\]~ig;
  $messagebuf =~ s~<br>~\n~ig;
  $messagebuf =~ s~>~&gt;~ig;
  $messagebuf =~ s~<~&lt;~ig;
  $messagebuf =~ s~\n~<br>~ig;


  $messagebuf =~ s~\[code\]\n*(.+?)\n*\[/code\]~&codemsg($1)~eisg;

  my $match = 1;
  my $quote_n = 0;

  while ($match != 0) {
    $match = 0;
    last unless $_[0] =~ m/\[.+\]/;
    $match++ if $messagebuf =~ s~\[b\](.+?)\[/b\]~<b>$1</b>~isg;
    $match++ if $messagebuf =~ s~\[i\](.+?)\[/i\]~<i>$1</i>~isg;
    $match++ if $messagebuf =~ s~\[u\](.+?)\[/u\]~<u>$1</u>~isg;
    $match++ if $messagebuf =~ s~\[s\](.+?)\[/s\]~<s>$1</s>~isg;

    $match++ if $messagebuf =~ s~\[color=(.+?)\](.+?)\[/color\]~<font color="$1">$2</font>~isg;
    $match++ if $messagebuf =~ s~\[black\](.*?)\[/black\]~<font color\=\#000000>$1</font>~isg;
    $match++ if $messagebuf =~ s~\[white\](.*?)\[/white\]~<font color=$beliy>$1</font>~isg;
    $match++ if $messagebuf =~ s~\[red\](.*?)\[/red\]~<font color=FF0000>$1</font>~isg;
    $match++ if $messagebuf =~ s~\[green\](.*?)\[/green\]~<font color=00FF00>$1</font>~isg;
    $match++ if $messagebuf =~ s~\[blue\](.*?)\[/blue\]~<font color=0000FF>$1</font>~isg;

    $match++ if $messagebuf =~ s~\[font=(.+?)\](.+?)\[/font\]~<font face="$1">$2</font>~isg;
    $match++ if $messagebuf =~ s~\[size=(.+?)\](.+?)\[/size\]~<font size="$1">$2</font>~isg;

    $match++ if $messagebuf =~ s~\[left\](.+?)\[/left\]~<p align=left>$1</p>~isg;
    $match++ if $messagebuf =~ s~\[center\](.+?)\[/center\]~<center>$1</center>~isg;
    $match++ if $messagebuf =~ s~\[right\](.+?)\[/right\]~<p align=right>$1</p>~isg;
    $match++ if $messagebuf =~ s~\[sub\](.+?)\[/sub\]~<sub>$1</sub>~isg;
    $match++ if $messagebuf =~ s~\[sup\](.+?)\[/sup\]~<sup>$1</sup>~isg;
    $match++ if $messagebuf =~ s~\[fixed\](.+?)\[/fixed\]~<font face="Courier New">$1</font>~isg;

    if($messagebuf =~ s~\[quote\]\n*(.+?)\n*\[/quote\]~&simplequotemsg($1, $quote_n)~eisg)
    {
      if($quote_n eq 0){$quote_n = 1}else{$quote_n = 0}
      $match++
    }
    $match++ if $messagebuf =~ s~\[list\](.+?)\[/list\]~<ul>$1</ul>~isg;

    $match++ if $messagebuf =~ s~\[list=(.+?)\](.+?)\[/list\]~<ol type="$1">$2</ol>~isg;


    if( $messagebuf =~ m~\[table\](?:.*?)\[/table\]~is ) {
      while( $messagebuf =~ s~<marquee>(.*?)\[table\](.*?)\[/table\](.*?)</marquee>~<marquee>$1<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>$2</table>$3</marquee>~s ) {}
      while( $messagebuf =~ s~<marquee>(.*?)\[table\](.*?)</marquee>(.*?)\[/table\]~<marquee>$1\[//table\]$2</marquee>$3\[//table\]~s ) {}
      while( $messagebuf =~ s~\[table\](.*?)<marquee>(.*?)\[/table\](.*?)</marquee>~\[//table\]$1<marquee>$2\[//table\]$3</marquee>~s ) {}
      $messagebuf =~ s~\n{0,1}\[table\]\n*(.+?)\n*\[/table\]\n{0,1}~<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>$1</table>~isg;
      while( $messagebuf =~ s~\<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1\>(.*?)\n*\[tr\]\n*(.*?)\n*\[/tr\]\n*(.*?)\</table\>~<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>$1<tr bgcolor=$beliy>$2</tr>$3</table>~is ) {}
      while( $messagebuf =~ s~\<tr bgcolor=$beliy\>(.*?)\n*\[td\]\n{0,1}(.*?)\n{0,1}\[/td\]\n*(.*?)\</tr\>~<tr bgcolor=$beliy>$1<td>$2</td>$3</tr>~is ) {}
      $messagebuf =~ s~<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)<tr bgcolor=$beliy>~<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1><tr bgcolor=$beliy>~isg;
      $messagebuf =~ s~<tr bgcolor=$beliy>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)<td>~<tr bgcolor=$beliy><td>~isg;
      $messagebuf =~ s~</td>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)<td>~</td><td>~isg;
      $messagebuf =~ s~</td>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)</tr>~</td></tr>~isg;
      $messagebuf =~ s~</tr>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)<tr bgcolor=$beliy>~</tr><tr bgcolor=$beliy>~isg;
      $messagebuf =~ s~</tr>((?:(?!<tr bgcolor=$beliy>|</tr>|<td>|</td>|<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>|</table>).)*)</table>~</tr></table>~isg;
    }
    $messagebuf =~ s~\[\&table\]~<table bgcolor\=\#e0e0e0 cellpadding=2 cellspacing=1>~g;
    $messagebuf =~ s~\[/\&table\]~</table>~g;
  }

  $messagebuf =~ s~(\<br\>)*\[\*\]n{0,1}(\<br\>)*~<li>~isg;

  $messagebuf =~ s~\[img\][\s*\t*\n*(&nbsp;)*($char_160)*]*(http\:\/\/)*(.+?)[\s*\t*\n*(&nbsp;)*($char_160)*]*\[/img\]~<img src="http\:\/\/$2" alt="" border="0">~isg;

  $messagebuf =~ s~\[hr\]~<hr width=40% align=left size=2 color\=\#000000>~g;
  $messagebuf =~ s~\[br\]~<br>~ig;

  $messagebuf =~ s~([^\w\"\=\[\]]|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~&urlcrop($1, $2, $2)~isge;
  $messagebuf =~ s~[^(?:\://\w+)]([^\"\=\[\]/\:\.]|[\n\b]|\A)\\*(www\.[^\.][\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~&urlcrop($1, "http://$2", $2)~isge;

  $messagebuf =~ s~\[url\]\s*www\.(\S+?)\s*\[/url\]~&urlcrop("", "http://www.$1", "www.$1")~isge;
  $messagebuf =~ s~\[url=\s*(\S\w+\://\S+?)\s*\](.+?)\[/url\]~&urlcrop("", $1, $2)~isge;
  $messagebuf =~ s~\[url=\s*(\S+?)\](.+?)\s*\[/url\]~&urlcrop("", "http://$1", $2)~isge;
  $messagebuf =~ s~\[url\]\s*(\S+?)\s*\[/url\]~&urlcrop("", $1, $1)~isge;

  $messagebuf =~ s~\[poll=(.+?)]~&get_poll_form($1)~isge;

  $messagebuf =~ s/([^\w\"\=\[\]]|[\n\b]|\A)(([+%_a-zA-Z\d\-\.]+)+@([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+))/&mailcrop2($2, &mailcrop($3, $4))/ge;

  $messagebuf =~ s~\[mail=\s*(([+%_a-zA-Z\d\-\.]+)+@([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+))\](.*?)\[/mail\]~&mailcrop2($1, $5)~isge;

  while( $messagebuf =~ s~<a([^>]*?)\n([^>]*)>~<a$1$2>~ ) {}
  while( $messagebuf =~ s~<a([^>]*)>([^<]*?)\n([^<]*)</a>~<a$1>$2$3</a>~ ) {}
  while( $messagebuf =~ s~<a([^>]*?)&amp;([^>]*)>~<a$1&$2>~ ) {}
  while( $messagebuf =~ s~<img([^>]*?)\n([^>]*)>~<img$1$2>~ ) {}
  while( $messagebuf =~ s~<img([^>]*?)&amp;([^>]*)>~<img$1&$2>~ ) {}


  $messagebuf =~ s/<br>ЗЫ /<br>:ps: /gsi;
  $messagebuf =~ s/<br>ЗЫ\:/<br>:ps:/gsi;
  $messagebuf =~ s/<br>ЗЫ\./<br>:ps:/gsi;
  $messagebuf =~ s/<br>PS /<br>:ps: /gsi;
  $messagebuf =~ s/<br>PS\:/<br>:ps:/gsi;
  $messagebuf =~ s/<br>PS\./<br>:ps:/gsi;
  $messagebuf =~ s/<br>P\.S\.\:/<br>:ps:/gsi;
  $messagebuf =~ s/<br>P\.S\./<br>:ps:/gsi;

  &MakeSmileys($_[1]);

  $messagebuf =~ s/    /&nbsp; &nbsp; /g;
  $messagebuf =~ s/   /&nbsp; &nbsp;/g;
  $messagebuf =~ s/  /&nbsp; /g;
  $messagebuf =~ s/\(c\)/©/gsi;
  $messagebuf =~ s/\(с\)/©/gsi;
  $messagebuf =~ s/\(С\)/©/gsi;

  return $messagebuf;
}

sub taghelp{
  my @vvodite = (
    "[b]Текст для примера[/b]",
    "[s]Текст для примера[/s]",
    "[i]Текст для примера[/i]",
    "[u]Текст для примера[/u]",
    "mail\@domain.com",
    "[mail=mail\@domain.com]Нажмите сюда![/mail]",
    "http://www.domain.com",
    "[url]www.domain.com[/url]",
    "[url=http://www.domain.com]Нажмите сюда![/url]",
    "[size=5]Текст для примера[/size]",
    "[font=times]Текст для примера[/font]",
    "[color=red]Текст для примера[/color]",
    "[img]$site/image/icon_beer.gif[/img]",
    "[list][*]Пункт меню[*]Пункт меню[/list]",
    "[list=1][*]Пункт меню [*]Пункт меню[/list]",
    "[list=a][*]Пункт меню [*]Пункт меню[/list]",
    "[list=i][*]Пункт меню [*]Пункт меню[/list]",
    "[quote]<br>&nbsp; [quote]Цитата 1[/quote]<br>&nbsp; Цитата 2<br>[/quote]",
    "[code]\$this_var = \"Hello World!\";[/code]",
    "[table]<br>&nbsp; [tr]<br>&nbsp; &nbsp; [td]Текст 1[/td][td]Текст 2[/td]<br>&nbsp; [/tr]<br>&nbsp; [tr]<br>&nbsp; &nbsp; [td]Текст 3[/td][td]Текст 4[/td]<br>&nbsp; [/tr]<br>[/table]",
    "Текст для примера 1[hr]Текст для примера 2",
    "Текст для примера 1[br]Текст для примера 2",
    "[right]Текст для примера[/right]",
    "[center]Текст для примера[/center]",
    "[left]Текст для примера[/left]",
    "X[sup]2[/sup]+Y[sup]2[/sup]=16",
    "H[sub]2[/sub]O",
    "[fixed]Текст для примера!!![/fixed]",
    );

  print header(-charset=>"windows-1251");
  print <<FORMA;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href=main.css type=text/css rel=stylesheet>
<title>Справка по тегам</title>
</head>
<body topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0>
<table cellspacing='2' cellpadding='4'>
<tr bgcolor=$tseriy>
<td width='50%' align='center' valign='middle'><b>Вводите</b></td>
<td width='50%' align='center' valign='middle'><b>Вид отображения</b></td>
</tr>
FORMA

  foreach $buf1(@vvodite)
  {
    $buf = $buf1;
    $buf =~ s~\[(.+?)\]~<font color=red><b>[$1]</b></font>~isg;
    print "<tr bgcolor=$sseriy>";
    print "<td align=left valign=middle>$buf</td>";
    $buf = &text_process($buf1);
    print "<td align=left valign=middle>$buf</td>";
    print "</tr>\n";
  }

  print "</table>";
  print "</body>";
  print "</html>";

  exit;
}

sub smileshelp{
  print header(-charset=>"windows-1251");
  print <<FORMA;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href=main.css type=text/css rel=stylesheet>
<title>Смайлики</title>
</head>
<body topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0>
<script type="text/javascript" src="$site/bbCode.js"></script>
<table cellspacing='2' cellpadding='4'>
<tr bgcolor=$tseriy>
<td width='50%' align='center' valign='middle'><b>Вводите</b></td>
<td width='50%' align='center' valign='middle'><b>Вид отображения</b></td>
</tr>
FORMA

  $j=0;
  foreach (@smiles)
  {
    $buf = $smiles[$j][0];
    $buf =~ s/ /&nbsp;/g;
    $buf =~ s/\\//g;
    print "<tr bgcolor=$sseriy>";
    print "<td align=center valign=middle><a href=\"javascript:add_smilie2('$buf')\">$buf</a></td>";
    $buf = "<a href=\"javascript:add_smilie2('$buf')\"><img src=\"image\/$smiles[$j][1]\" width=$smiles[$j][2] height=$smiles[$j][3] alt=\"$smiles[$j][4]\" border=0></a>";
    print "<td align=center valign=middle>$buf</td>";
    print "</tr>\n";
    $j++;
  }
  print "</table>";
  print "</body>";
  print "</html>";

  exit;
}

sub urlcrop{
  $buf=$_[2];
  $buf2=$_[1];

  if(length($buf)>80)
  {

    substr($buf,39,length($buf)-(39*2)) = "…";
  }
  if(lc(substr($buf2,0,7)) ne "http://")
  {
    $buf2 = "http://$buf2";
  }
  return "$_[0]<a href=\"$buf2\">$buf</a>";
}

sub mailcrop{
  $buf="";
  $buf=substr(@_[1],0,1);
  return "@_[0]\@$buf…";
}

sub mailcrop2{
    $buf=&savemail($_[0]);
    if($mode eq "mobers")
    {$buf1 = "?mode=sendmail&to=$buf$mailaddbuf class=m"}
    else
    {$buf1 = "$site?mode=sendmail&to=$buf$mailaddbuf"}

    $buf="<a href=$buf1>$_[1]</a>";
    return $buf;
  }

1;
