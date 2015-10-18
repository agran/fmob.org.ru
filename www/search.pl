{
  use locale;
  use POSIX qw(locale_h);
}

sub urldecode{
 local($val)=@_;
 $val=~s/\+/ /g;
 $val=~s/%([0-9A-H]{2})/pack('C',hex($1))/ge;
 return $val;
}

sub find_start {

$show_matches = 5;

# Directory where yours html files are located
# Type "." for the current directory
$base_dir = $ENV{DOCUMENT_ROOT};

#minimum word length to index
$min_length = 3;

#number of results per page
$res_num=10;

# site size
# 1 - Tiny    ~1Mb
# 2 - Medium  ~10Mb
# 3 - Big     ~50Mb
# 4 - Large   >100Mb
$site_size = 3;

# List of stopwords
$use_stop_words = "YES";
@stop_words = qw(and any are but can had has have her here him his
 how its not our out per she some than that the their them then there
 these they was were what you);

# Change below only if you need multilanguage support
# With default settings script will work with
# English, Russian (win1251 encoding) and most European languages

# Capital letters
$CAP_LETTERS = '\xC0-\xDF\xA8';

# Lower case letters
$LOW_LETTERS = '\xE0-\xFF\xB8';

# Change this as above
sub to_lower_case {
   my $str = shift;
   $str =~ tr{\xC0-\xDF\xA8}{\xE0-\xFF\xB8};
   return $str;
}

#--- end of configuration ---

if ($site_size == 1) { $HASHSIZE = 20001 }
elsif ($site_size == 3) { $HASHSIZE = 100001 }
elsif ($site_size == 4) { $HASHSIZE = 300001 }
else { $HASHSIZE = 50001 }

%stop_words = ();
if ($use_stop_words eq "YES") {
    foreach $word (@stop_words) { $stop_words{$word} = "" }
}


if(param(name) eq "on"){$search_name = "1"}else{$search_name = "0"}

if(param(onlytopic) eq "on"){$search_onlytopic = "1"}else{$search_onlytopic = "0"}

if(param(predv) eq "on"){$search_predv = "1"}else{$search_predv = "0"}

if(param(plays)eq ""&param(forum)eq "")
{
  $search_plays = "1";
  $search_forum = "1";
  $search_name = "1";
  $search_onlytopic = "0";
  $search_predv = "0";
}
else
{
  if(param(plays) eq "on"){$search_plays = "1"}else{$search_plays = "0"}
  if(param(forum) eq "on"){$search_forum = "1"}else{$search_forum = "0"}
}

if($ENV{'REQUEST_METHOD'} eq 'GET'){
   $query=$ENV{'QUERY_STRING'};
   }
 elsif($ENV{'REQUEST_METHOD'} eq 'POST'){
   read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
   }
@formfields=split /&/,$query;
foreach(@formfields){
   if(/^query=(.*)/){$ndquery=$1}
   if(/^stpos=(.*)/){$stpos=$1}
   if(/^stype=(.*)/){$stype=$1}
   }


$hl = $ndquery;

$time1 = time;


$stpos = param(stpos);
if ($stpos <0) {$stpos = 0};

$query = param(query);
$query =~s/[\."'\?\(\)]/ /g;
$query1 = $query;

$query=~tr/A-Z/a-z/;
$query = to_lower_case($query);

@query = ();
@dum = split(/ /,$query);

foreach $dum (@dum) {
   if (exists($stop_words{$dum})) { next }
   if (length($dum) >= $min_length) { $query[$#query+1] = $dum }
}


for ($i=0; $i<scalar(@query); $i++) {
   if ($query[$i] =~ /\!/)   { $wholeword[$i] = 1;} # WholeWord
   $query[$i] =~s/[\! ]//g;
   if ($stype eq "AND")     { $querymode[$i] = 2;} # AND
   if ($query[$i] =~ /^\-/) { $querymode[$i] = 1;} # NOT
   if ($query[$i] =~ /^\+/) { $querymode[$i] = 2;} # AND
   $query[$i] =~s/^[\+\- ]//g;
}


open HASH, "find2/hash" or die "Could not open hash.";
binmode(HASH);
open HASHWORDS, "find2/hashwords" or die "Could not open hashwords.";
binmode(HASHWORDS);
open SITEWORDS, "find2/sitewords" or die "Could not open sitewords.";
open FINFO, "find2/finfo" or die "Could not open finfo.";
open WORD_IND, "find2/word_ind" or die "Could not open word_ind.";
binmode(WORD_IND);


@allres = ();


for ($j=0; $j<scalar(@query); $j++) {
    $query = @query[$j];
    @{$allresw[$j]} = ();


    @letters = unpack("C*", $query);
    $a = $letters[0];
    $b = $letters[1];
    $c = $letters[2];
    $d = $letters[3];
    $num = int( ($a*14511 - $b*13779 + $c*$d*94333)/5 ) % $HASHSIZE;
    seek(HASH,$num*4,0);
    read(HASH,$dum,4);
    $dum = unpack("N", $dum);
    seek(HASHWORDS,$dum,0);
    read(HASHWORDS,$dum,4);
    $dum1 = unpack("N", $dum);
    for ($i=0; $i<=$dum1; $i++) {
        read(HASHWORDS,$dum,8);
        ($wordpos, $filepos) = unpack("NN", $dum);
        seek(SITEWORDS,$wordpos,0);
        $word = <SITEWORDS>;
        $word =~ s/\x0A//;
        $word =~ s/\x0D//;
        if ( ($wholeword[$j]==1) && ($word ne $query) ) {$word = ""};
        if (index($word,$query)>=0){
            seek(WORD_IND,$filepos,0);
            read(WORD_IND,$dum,4);
            $dum2 = unpack("N",$dum);
            $dum2 = $dum2/4;
            for($k=1; $k<=$dum2; $k++){
                    read(WORD_IND,$dum,4);
                    push(@{$allres[$j]}, $dum);
            };    # for $k
        };
    };   # for $i
}; # for $query


@res = ();
    for ($j=0; $j<scalar(@query); $j++) {
        push(@res,@{$allres[$j]});
    }


for ($i=0; $i<scalar(@query); $i++) {
    %union=%isect=();
    @resonly=();


    if ($querymode[$i] == 1) {               # NOT
       @seen{@{$allres[$i]}} = ();
       foreach $e (@res) {
          push (@resonly, $e) unless exists $seen{$e};
       }
       @res = @resonly;
    }

    if ($querymode[$i] == 2) {               # AND
       foreach $e (@res) { $union{$e} = 1 }
       foreach $e (@{$allres[$i]}) {
          if ($union{$e}) { $isect{$e}=1 }
       }
       @res = keys %isect;
    }
}


%seen = ();
foreach $item (@res) {
   $seen{$item}++;
}
@res = keys %seen;
%bodys = ();
@files = ();
if($search_forum eq "1")
{
  &readindexofboards;
}

$i = 0;

foreach (@res) {
    $bod = "";
    @body = ();
    if ($i == scalar(@res)) {last};
    $strpos = unpack("N",$res[$i]);
    seek(FINFO,$strpos,0);
    $dum = <FINFO>;
    ($num, $filename, $buf) = split(/::/,$dum);
    chomp $buf;
    $f_termcount_db{$filename} = $buf;
    if(($filename =~ /messages/i & $search_forum eq 1) | ($filename =~ /plays/i &  $search_plays eq 1))
    {
      $nums{$filename} = $num;

      open (FILE,$base_dir."/".$filename);
      @body = <FILE>;

      for(@body)
      {chomp $_}

      if($filename =~ /plays/i)
      {
        $bod = &Get_User_Name_by_id($body[3]);
        $avtors{$filename} = &Get_Formated_User_Name($body[3]);
        if($search_onlytopic eq "1")
        {
          $bod = "$body[5]";
        }
        else
        {
          if($search_name eq "1")
          {
            $bod = "$bod $body[5] $body[6] $body[16]";
          }
          else
          {
            $bod = "$body[5] $body[6] $body[16]";
          }
        }
      }
      if($filename =~ /messages/i)
      {

        $forumid = $nums{$filename};
        ($buf1, $buf2, $buf3) = &getforumname($forumid);

        $avtors{$filename} = $buf3;

        if($search_onlytopic eq "1")
        {
          $bod = "$buf1";
        }
        else
        {
        foreach (@body)
        {
          ($avtorbuf, $timebuf, $textbuf, $imagebuf, $editbybuf, $edittimebuf, $hidebuf)=split(/\|/,$_);
          if($hidebuf ne "1")
          {
            if($search_name eq "1")
            {
              $_ = &Get_User_Name_by_id($avtorbuf)." ".$textbuf;
            }
            else
            {
              $_ = $textbuf;
            }
          }
          else
          {
            $_ = "";
          }
          $_ = "$_\(\|\~\)";
        }

        $bod = "$buf1 @body";
        }
      }

      $bod =~ s~\[(.+?)\]~ ~isg;
      $bod =~ s~<br>~ \n ~ig;
      $bodys{$filename} = $bod;
      push @files, $filename;
      close (FILE);
    }
  $i++;
};  # for


$totalmatches = 0;
$i = 0;

$results = 0;
foreach $filename (@files)
{
   $matches = 0;
   $content = $bodys{$filename};
   $content = lc $content;
   foreach $term (@query)
   {
     $term = lc $term;
     while ($content =~ m/$term/ig)
     {
       $matches++;
     }
   }
   $matchess{$filename} = $matches;
   $totalmatches += $matches;
   if($matches eq 0)
   {
     delete ($files[$i]);
   }
   else
   {
     $results ++;
   }
   $i++;
}

foreach $filename (@files)
{
  $score_denominator{$filename} += $f_termcount_db{$filename};

  foreach my $term (@query)
  {        # find +boolean terms/phrases
    my ($weight, $matches, $added);
    my $term_cp = $term;
    if ($term_cp =~ m/^&lt;([0-9]+)&gt;/ && $term_cp !~ /^&lt;[0-9]+&gt;$/)
    {
      if ($1 >= 2 && $1 <= 10000)
      {
        $term_cp =~ s/^&lt;([0-9]+)&gt;//;        # remove user defined weights
        $weight = $1;
      }
      elsif ($term_cp =~ / /)
      {
        $term_cp =~ s/^&lt;[0-9]+&gt;//; # remove user defined weights
      }
    }
    $weight ||= 1;
    my $termcp = $term_cp;


    $matches = 0;
    $content = $bodys{$filename};
    $term = $term_cp;
    while ($content =~ m/$term/ig)
    {
      $matches++;
    }

    if ($matches)
    {
      $termcp =~ s/\s+//g;   # if it is a phrase
      $score_numerator{$filename} += $matches * (length $termcp) * $weight;
    }

  }


  if ($score_denominator{$filename} != 0)
  {
    $finalscores{$filename} = sprintf("%.2f", 100*($score_numerator{$filename}/$score_denominator{$filename}));
  }
  else
  {
    $finalscores{$filename} = "n/a";
  }
}

my @files2 = @files;

@files = sort {$finalscores{$b}*$matchess{$b} <=> $finalscores{$a}*$matchess{$a}} @files2;


$i= 0;
if($search_predv eq "1")
{
foreach $filename (@files)
{
  if($filename eq "")
  {
    next
  }
  else
  {
    $i++;
  }
  if($i<$stpos+1|$i>$stpos+$res_num)
  {
    next;
  }

  my @lines;
  my $bdy;
  $bdy = $bodys{$filename};
  foreach my $term (@query) {
    my $count;
    my $boldterm = $term;
    while ($count < $show_matches && $bdy =~ m/$boldterm/gi)
    {

      $count++; $pre = "$`"; $post = "$'"; $match = $&;

      $count1 = 0;
      while($pre =~ m/\(\|\~\)/gi)
      {
        $count1++;
      }
      $count1++;


      my $LENGTH = 30;
      $buf1 = 0;
      $buf2 = 0;
      if($pre =~ s/(.+?) $/$1/gsi){$buf1 = 1}
      $pre =~ m/ (.{0,$LENGTH})$/; $prem = $1;
      if($post =~ s/$ (.+?)/$1/gsi){$buf2 = 1}
      $post =~ m/^(.{0,$LENGTH}) /; $postm = $1; $post = "$'", $bdy = "$pre $post";


      if($buf1 eq 1)
      {
        $prem = "$prem ";
      }

      if($buf2 eq 1)
      {
        $postm = " $postm";
      }

      $prem =~ s~\(\|\~\)~~isg;
      $postm =~ s~\(\|\~\)~~isg;

      if($filename =~ /messages/i)
      {
        $line = join("", '...', $prem, "(|~)", "<a href=$site?mode=forum&thread=$nums{$filename}&post=$count1&hl=$hl>", $match, "</a>", "(|~", $postm, '...<br>');
      }
      else
      {
        $line = join("", '...', $prem, "(|~)", $match, "(|~", $postm, '...<br>');
      }
      push @lines, $line;

    }

    foreach $desc (@lines)
    {
      $desc =~ s/\(\|\~\)(.+?)\(\|\~/\<b style\=\"background:#dddddd\">$1\<\/b\>/gsi;
    }

    $primeri{$filename} = "@lines";
  }
}
}


  print "<center><b><font size=4>Поиск по сайту</b></font>";
  print "<form action=$site?mode=search&$FORM_INPUT_NAME=$bare_query method=post>";
  print "<table border=0 cellpadding=4 width=100%>";
  print "<tr><td colspan=2 align=center>";
  print "<input type=hidden name=mode value=search>";
  print "<input type=hidden name=reload value=1>";
  print "<input size=35 name=query value=\"$query1\" onfocus=select(this); type=text> ";
  print "<input style='background-color: rgb(224, 224, 224);' value=Найти type=submit></td></tr>";
  print "<tr><td colspan=2 align=center>";

  $subscribe1 = "";
  $subscribe2 = "";
  $subscribe3 = "";
  $subscribe3 = "";
  $subscribe4 = "";
  $subscribe1 = " checked" if($search_plays eq "1");
  $subscribe2 = " checked" if($search_forum eq "1");
  $subscribe3 = " checked" if($search_name eq "1");
  $subscribe4 = " checked" if($search_onlytopic eq "1");
  $subscribe5 = " checked" if($search_predv eq "1");

  print "<input type=checkbox name=plays$subscribe1>Сценарии";
  print "<input type=checkbox name=forum$subscribe2>Форум";
  print "<input type=checkbox name=name$subscribe3>Авторы поста<br>";
  print "<input type=checkbox name=onlytopic$subscribe4>Только по названиям тем/сценариев";
  print "<input type=checkbox name=predv$subscribe5>Показывать предварительный просмотр";
  print "";
  print "</td></tr>";

  if($query ne "")
  {
    print "<tr><td colspan=2>";
    if($results > 0)
    {
      print "Найдено страниц <b>$results</b> по запросу <b>$query1</b>. Всего совпадений: <b>$totalmatches</b><br>";
    }
    else
    {
      print "<b>Ничего не найдено!</b>";
    }
    print "</td></tr>";
  }
  $nom = $stpos;

  $rescount = $results;
  $menu = "";
  for ($i=1; $i<=$rescount; $i += $res_num) {
    if (($i+$res_num-1)<$rescount) {$fini = $i+$res_num-1}
    else {$fini = $rescount};
    if($i eq $stpos+1)
    {
      $menu = "$menu $i-$fini |";
    }
    else
    {
      $i1 = $i-1;
      $menu = "$menu <A HREF=?mode=search&query=$ndquery\&stpos=$i1&plays=". param(plays)."&forum=".param(forum)."&name=".param(name)."&onlytopic=".param(onlytopic)."\>$i-$fini</A> |";
    }
  }
  substr($menu, -1) = "";
  print "<tr><td colspan=2 align=center>";
  print $menu;
  print "</td></tr>";

  $i = 0;


  foreach $filename (@files)
  {
    if($filename eq "")
    {
      next
    }
    else
    {
      $i++;
    }
    if($i<$stpos+1|$i>$stpos+$res_num)
    {
      next;
    }

    $nom++;
    if($filename =~ /messages/i)
    {
      $type = "forum";
    }
    elsif($filename =~ /plays/i)
    {
      $type = "plays";
    }

    print "<tr><td width=1% align=right valign=top>$nom.<td>";

    $finalscore = $finalscores{$filename};
    $matche = $matchess{$filename};
    if($type eq "forum")
    {
      $forumid = $nums{$filename};
      ($buf1, $buf2) = &getforumname($forumid);

      if(($buf2 eq "Модераторский"|$buf2 eq "Корзина"))
      {
        if(($usertype eq "модераторы")|($usertype eq "администраторы"))
        {
          print "<b><a href=$site?mode=forum&thread=$forumid&hl=$hl>Форум : $buf2 : $buf1</a></b><br>Автор: $avtors{$filename}<br>";
          print "$primeri{$filename}";
          print "<font size=1><b>Количество совпадений:</b> $matche &nbsp; ";
          print "<b>Ролевантность:</b> $finalscore &nbsp; ";
          print "<a href=$site?mode=forum&thread=$forumid>$site?mode=forum&thread=$forumid</a></font>";
        }
        else
        {
          print "<b><a href=$site?mode=forum&thread=$forumid&hl=$hl>Форум : $buf2 : $buf1</a></b><br>Автор: $avtors{$filename}<br>";
          print "<font color=red>Нет доступа</font><br>";
          print "<font size=1><b>Количество совпадений:</b> $matche &nbsp; ";
          print "<b>Ролевантность:</b> $finalscore &nbsp; ";
          print "<a href=$site?mode=forum&thread=$forumid>$site?mode=forum&thread=$forumid</a></font>";
        }
      }
      else
      {
        print "<b><a href=$site?mode=forum&thread=$forumid&hl=$hl>Форум : $buf2 : $buf1</a></b><br>Автор: $avtors{$filename}<br>";
        print "$primeri{$filename}";
        print "<font size=1><b>Количество совпадений:</b> $matche &nbsp; ";
        print "<b>Ролевантность:</b> $finalscore &nbsp; ";
        print "<a href=$site?mode=forum&thread=$forumid>$site?mode=forum&thread=$forumid</a></font>";
      }
    }

    if($type eq "plays")
    {

      $forumid = $filename;
      $forumid =~ m/\d+/;
      $forumid = $&;

      open(playinfo, "<plays/$forumid.txt");
      flock(playinfo, 1);
      @playinfo=<playinfo>;
      close (playinfo);

      chomp $playinfo[5];
      $name=$playinfo[5];


      print "<b><a href=$site?play=$forumid&hl=$hl>Сценарий : $name</a></b><br>Автор: $avtors{$filename}<br>";
      print " $primeri{$filename}";
      print "<font size=1><b>Количество совпадений:</b> $matche &nbsp; ";
      print "<font size=1><b>Ролевантность:</b> $finalscore &nbsp; ";
      print "<a href=$site?play=$forumid>$site?play=$forumid</a></font>";
    }

    print "</td></tr>";
  }


  print "<tr><td colspan=2 align=center>";
  print $menu;
  print "</td></tr>";


  if($query ne "")
  {
    $timebuf2 = gettimeofday;
    print "<tr><td colspan=2>";
    $timebuf = sprintf("%.2f", $timebuf2 - $timebuf1);
    print "<BR>Затраченное время: $timebuf сек.\n";
    print "</td></tr>";

    open(logfile, ">>search_logs.txt");
    flock(logfile, 2);

    print logfile "User: ". &Get_User_Name_by_id($Userid). "($Userid)\n";
    print logfile "IP: $ENV{REMOTE_ADDR}\n";
    print logfile "QUERY_STRING: $ENV{QUERY_STRING}\n";
    print logfile "QUERY: $query1\n";
    print logfile "Time: $timebuf\n";
    print logfile "Total matches: $totalmatches\n";
    print logfile "Pages: $results\n";
    print logfile "------------------------\n\n";

    close(logfile);
  }
  print "</table>";


}

sub getforumname {
  my $thread = $_[0];

  if($BoardGetCesh{$thread} eq "")
  {
    $board = &BoardGet($thread);
  }
  else
  {
    $board = $BoardGetCesh{$thread};
  }

  $forumbuf1 = 0;

  if($threadtitle{$thread} eq "" | $threadavtor{$thread} eq "")
  {
    &readindexofthreads;
  }
  return ($threadtitle{$thread}, $titleofboard{$board}, $threadavtor{$thread});
}

1;
