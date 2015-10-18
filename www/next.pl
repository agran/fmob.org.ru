{
  use locale;
  use POSIX qw(locale_h);
}

sub shownext{
  open(GB, "<plays/plays.txt");
  flock(GB, 1);
  $find=0;
  $nomer = 1;
  while (<GB>)
  {
    ($buf1, $buf2, $buf3, $buf4)=split(/\|/,$_);
    if($buf2 eq 2)
    {
      $find=1;
      $play = $buf1;
    }
    if($buf2 eq 3)
    {
      $nomer++;
    }
  }
  if($find eq 0)
  {
    print "<br><center><b>Ещё не определён.</b></center>";
    return;
  }
  close (GB);

  open(playinfo, "<plays/$play.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  foreach (@playinfo)
  {chomp $_;}

  if((($usertype eq "модераторы")|($usertype eq "администраторы"))&($mode eq "next"))
  {
    $buf7 = qq~<center>
<b><font size="1">
[<a href=$site?mode=next\&action=movetovoting\&play=$play class=\"adm\">Вернуть в голосование</a>]
[<a href=$site?mode=voting\&action=delete\&play=$play class=\"adm\">Удалить</a>]
[<a href=$site?mode=next\&action=edit\&play=$play class=\"adm\">Редактировать</a>]
[<a href=$site?mode=subscribe class=\"adm\">Рассылка</a>]
[<a href=$site?mode=next\&action=movetopast\&play=$play class=\"adm\">Переместить в прошедшие</a>]
</font></b>
</center>~;
  }
  else
  {
    $buf7 = qq~~;
  }

  @users=split(/:/,$playinfo[7]);
  @voices=split(/:/,$playinfo[8]);
  @mobersgo=split(/:/,$playinfo[13]);
  @mobersgon=split(/:/,$playinfo[14]);

  &get_voice_info;

  if($mode eq "next")
  {print "<center><b><font size=4>$title2</font></b></center><br>";}
  print $buf7;
  print "<table border=0 cellpadding=4 width=780>";
  print "<tr bgcolor=$tseriy align=center>";
  print "<td><b>№</b>";
  print "<td width=80\%><b>Название</b>";
  print "<td><b>Автор</b>";
  print "</tr>";
  print "<tr bgcolor=$seriy>";
  print "<td nowrap align=center><b>$nomer</b></td>";
  print "<td align=center><b><a href=$site?play=$play>$playinfo[5]</a></a></td>";
  $avtor=&Get_Formated_User_Name($playinfo[3]);
  print "<td nowrap align=center><b>$avtor</b></td></tr>";
  $buf = &text_process($playinfo[6]);

  $hl=param(hl);
  @dum = split(/ /,$hl);
  foreach (@dum)
  {
    $buf =~ s/($_)/\<span class=searchlite\>$1\<\/span\>/gsi;
  }

  print "<tr><td></tr>";
  print "<tr bgcolor=$seriy><td colspan=3><b>Сценарий</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";
  print "$buf";
  print "</td></tr>";
  print "<tr><td></tr>";


  print "<tr bgcolor=$seriy><td colspan=3><b>Место</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";

   if($playinfo[16] eq "")
   {$buf = "Ещё не определено"}
   else
   {$buf = $playinfo[16]}

  print "<b>Место проведения:</b> $buf<br>";
  if($playinfo[16] eq "")
  {
    open(playmesto, "<plays/$play\_mesto.txt");
    flock(playmesto, 1);
    @playmesto=<playmesto>;
    close (playmesto);

    print "<b>Голосование месту проведения:</b>";
    print "<table width=\"100%\" border=\"0\" cellpadding=\"2\" bgcolor=$beliy>\n";
    print "<table border=0 cellpadding=4 bgcolor=$beliy>";
    print "<form method=\"post\" action=\"$site?mode=next\">\n";
    print "<input type=\"hidden\" name=\"mode\" value=\"next\">\n";
    print "<input type=\"hidden\" name=\"play\" value=\"$play\">\n";
    print "<input type=\"hidden\" name=\"voting\" value=\"mesto\">\n";

    if(@playmesto>0)
    {
      print "<tr align=center bgcolor=$seriy><td><td><b><font size=1>Могу<br>Хочу<td><b><font size=1>Не могу<br>Не хочу<td><b>Место<td><font size=1><b>Могут<br>Хотят<td><font size=1><b>Не могут<br>Не хотят<td><b>Итого\n";

      if(($usertype eq "модераторы")|($usertype eq "администраторы"))
      {
        print "<td><b>Редактировать<td><font size=1><b>Удалить";
      }

      for (@playmesto)
      {
        $tn++;
        chomp $_;
        ($mestoid, $mestobuf, $avtorbuf, $usersbuf, $voicebuf)=split(/\|/,$_);

        $mestobuf =~ s/"/&quot;/g;

        @usersmesto=split(/:/, $usersbuf);
        @voicesmesto=split(/:/, $voicebuf);

        $mogut = 0;
        $nemogut = 0;
        $j = 0;
        $mogutchecked = "";
        $nemogutchecked = "";
        for(@voicesmesto)
        {
          if($_ eq 1)
          {
            $mogut++;
            if($usersmesto[$j] eq $Userid)
            {
              $mogutchecked = " checked";
            }
          }
          elsif($_ eq 0)
          {
            $nemogut++;
            if($usersmesto[$j] eq $Userid)
            {
              $nemogutchecked = " checked";
            }
          }
          $j++;
        }
        $itogo = $mogut - $nemogut;

        $znak = "";
        $znak = "+" if($itogo>0);

        print "<tr align=center bgcolor=$seriy><td>$tn<td><input type=checkbox name=mestoisyes$mestoid$mogutchecked><td><input type=checkbox name=mestoisno$mestoid$nemogutchecked><td>$mestobuf<td>$mogut<td>$nemogut<td>$znak$itogo\n";
        if(($usertype eq "модераторы")|($usertype eq "администраторы"))
        {
          print "<td><input name=next_mesto$mestoid maxlength=100 type=text value=\"$mestobuf\" size=30><td><input type=checkbox name=delete$mestoid>";
        }
      }

      print "<tr bgcolor=$seriy><td colspan=7><input type=\"submit\" style=\"background-color: $tseriy;\" name=\"answer\" value=\"Проголосовать\">\n";
      if(($usertype eq "модераторы")|($usertype eq "администраторы"))
      {
        print "<td colspan=2><input type=\"submit\" style=\"background-color: $tseriy;\" name=\"primenit\" value=\"Применить\">";
      }
    }
    print "<tr bgcolor=$seriy><td colspan=7><input name=next_mesto maxlength=100 type=text size=40> <input type=\"submit\" name=\"answer\" value=\"Добавить\" style=\"background-color: $tseriy;\"></td>";
    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      print "<td colspan=2>";
    }
    print "</form>";
    print "</table>";

  }

  print "</td></tr>";
  print "<tr><td></tr>";

  print "<tr bgcolor=$seriy><td colspan=3><b>Дата и время</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";

  if($playinfo[15] eq "")
  {$buf = "Ещё не определена"}
  else
  {
    $buf3=&raznica($nowdate, $playinfo[15]);

    ($dey1, $mday1, $year1) = ($playinfo[15] =~ /(\d+)\.(\d+)\.(\d+)/);
    $dey1 = int($dey1);
    $datebuf = $mdays2[$mday1-1];
    $datebuf = "$dey1 $datebuf $year1";
    if($buf3 > 1)
    {
      $buf4 = $buf3;
      $buf = &dni($buf4);
      $buf = "$datebuf (через $buf4 $buf)";
    }
    elsif($buf3 eq 0)
    {
      $buf = "$datebuf (сегодня)";
    }
    elsif($buf3 eq 1)
    {
      $buf = "$datebuf (завтра)";
    }
    else
    {
      $buf = "$datebuf (уже прошёл)";
    }
  }
  print "<b>Дата проведения:</b> $buf";

  if($playinfo[15] ne "")
  {
    print "<br><b>День недели:</b> ", &getwday($playinfo[15]);
  }

  if($playinfo[18] eq "")
  {$buf = "Ещё не определена"}
  else
  {$buf = "$playinfo[18] минут"}
  print "<br><b>Длительность:</b> $buf";

  if($playinfo[12] eq "")
  {
    $buf = "Ещё не определено"
  }
  else
  {
    $buf = "$playinfo[12]";
  }
  print "<br><b>Время проведения:</b> $buf";

  open(playtime, "<plays/$play\_time.txt");
  flock(playtime, 1);
  @playtime=<playtime>;
  close (playtime);

  if(($playinfo[15] eq "" | $playinfo[12] eq "")& $login eq 1)
  {
    print "<br><b>Голосование по дате и времени проведения:</b><br>";
    print "<table width=\"100%\" border=\"0\" cellpadding=\"2\" bgcolor=$beliy>\n";
    print "<table border=0 cellpadding=4 bgcolor=$beliy>";
    print "<form method=\"post\" action=\"$site?mode=next\">\n";
    print "<input type=\"hidden\" name=\"mode\" value=\"next\">\n";
    print "<input type=\"hidden\" name=\"play\" value=\"$play\">\n";
    print "<input type=\"hidden\" name=\"voting\" value=\"time\">\n";

    if($playinfo[15] eq "")
    {
      $dateisbuf = "<td><b>Дата<td><b>День недели";
    }
    else
    {
      $dateisbuf = "";
    }
    if(@playtime>0)
    {
    print "<tr align=center bgcolor=$seriy><td><td><b><font size=1>Могу<br>Хочу<td><b><font size=1>Не могу<br>Не хочу$dateisbuf<td><b>Время<td><font size=1><b>Могут<br>Хотят<td><font size=1><b>Не могут<br>Не хотят<td><b>Итого\n";

    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      print "<td><b>Удалить\n";
    }

    $tn=0;
    for (@playtime)
    {
      $tn++;
      chomp $_;
      ($timeid, $datebuf, $timebuf, $avtorbuf, $usersbuf, $voicebuf)=split(/\|/,$_);

      if($playinfo[15] ne "" & $datebuf ne $playinfo[15])
      {
        next;
      }

      @userstime=split(/:/, $usersbuf);
      @voicestime=split(/:/, $voicebuf);

      $mogut = 0;
      $nemogut = 0;
      $j = 0;
      $mogutchecked = "";
      $nemogutchecked = "";
      for(@voicestime)
      {
        if($_ eq 1)
        {
          $mogut++;
          if($userstime[$j] eq $Userid)
          {
            $mogutchecked = " checked";
          }
        }
        elsif($_ eq 0)
        {
          $nemogut++;
          if($userstime[$j] eq $Userid)
          {
            $nemogutchecked = " checked";
          }
        }
        $j++;
      }
      $itogo = $mogut - $nemogut;

      $znak = "";
      $znak = "+" if($itogo>0);

      if($playinfo[15] eq "")
      {
        $dateisbuf2 = &getwday($datebuf);
        $dateisbuf2 = "<td>$datebuf<td>$dateisbuf2";
        $buf = 9;
      }
      else
      {
        $dateisbuf2 = "";
        $buf = 7;
      }
      print "<tr align=center bgcolor=$seriy><td>$tn<td><input type=checkbox name=dateisyes$timeid$mogutchecked><td><input type=checkbox name=dateisno$timeid$nemogutchecked>$dateisbuf2<td>$timebuf<td>$mogut<td>$nemogut<td>$znak$itogo\n";

      if(($usertype eq "модераторы")|($usertype eq "администраторы"))
      {
        print "<td><input type=checkbox name=delete$timeid>";
      }
    }
    print "<tr bgcolor=$seriy><td colspan=$buf><input style=\"background-color: $tseriy;\" type=\"submit\" name=\"answer\" value=\"Проголосовать\"></td>\n";
    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      print "<td><input type=\"submit\" style=\"background-color: $tseriy;\" name=\"primenit\" value=\"Применить\">";
    }
    }
    print "<tr bgcolor=$seriy><td colspan=$buf>";


    if($playinfo[15] eq "")
    {
      print "Дата: <select name=next_dd><option>";
      for($j=1;$j<=31;$j++)
      {
        $daybuf = $j;
        $daybuf = "0$daybuf" if ($daybuf < 10);
        print "<option>$daybuf";
      }
      print "</select><select name=next_mm><option>";

      for($j=0;$j<12;$j++)
      {
        $daybuf = $j+1;
        $daybuf = "0$daybuf" if ($daybuf < 10);
        print "<option>$mdays[$j]";
      }
      print "</select><select name=next_yyyy><option>";

      for($j=$year-3;$j<=$year+3;$j++)
      {
        $yearbuf = $j;
        print "<option>$yearbuf";
      }
      print "</select>";
    }
    else
    {
      ($dey1, $mday1, $year1) = ($playinfo[15] =~ /(\d+)\.(\d+)\.(\d+)/);
      print "<input type=\"hidden\" name=\"next_dd\" value=\"$dey1\">\n";
      print "<input type=\"hidden\" name=\"next_mm\" value=\"$mdays[$mday1-1]\">\n";
      print "<input type=\"hidden\" name=\"next_yyyy\" value=\"$year1\">\n";
    }
    print " Время: <select name=next_hh><option>";
    for($j=0;$j<=23;$j++)
    {
      $daybuf = $j;
      $daybuf = "0$daybuf" if ($daybuf < 10);
      print "<option>$daybuf";
    }
    print "</select>:<select name=next_min><option>";

    for($j=0;$j<=59;$j++)
    {
      $daybuf = $j;
      $daybuf = "0$daybuf" if ($daybuf < 10);
      print "<option>$daybuf";
    }
    print "</select>";

    print " <input type=\"submit\" style=\"background-color: $tseriy;\" name=\"answer\" value=\"Добавить\"></td>";

    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      print "<td>";
    }

    print "</form>";
    print "</table>";
  }

  print "</td></tr>";
  print "<tr><td></tr>";

  print "<tr bgcolor=$seriy><td colspan=3><b>Итоги голосования:</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";
  $buf4=&raznicadeys($playinfo[1], $playinfo[2]);
  print "<b>Находилось в голосовании с</b> $playinfo[1] <b>по</b> $playinfo[2] ($buf4 ", &dni($buf4), ").\n";

  &itogo_print;

  print "</td></tr>";
  print "<tr><td></tr>";
  print "<tr bgcolor=$seriy><td colspan=3><b>Явка</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";
  $mobersgoncol = 0;
  $mobersgobuf = "";
  $mobersnogobuf = "";
  $Usermobersgo = 0;
  $mobersnogoncol = 0;
  if(@mobersgo>0)
  {
    for($j=0;$j<@mobersgo;$j++)
    {
      if($mobersgon[$j] > 0)
      {
        if($mobersgobuf eq ""){$mobersgobuf = "<b>Пойдут на моб:</b><font size=1>\n"};
        $mobersgoncol = $mobersgoncol + $mobersgon[$j];
        $user_name_buf=&Get_Formated_User_Name($mobersgo[$j]);
        $mobersgon[$j]--;
        if($mobersgo[$j] eq $Userid)
        {
          $user_name_buf = "<b>$user_name_buf</b>";
          $Usermobersgo = $mobersgon[$j];
        }
        if($mobersgon[$j] eq 0)
        {$mobersgobuf = "$mobersgobuf$user_name_buf,\n";}
        elsif($mobersgon[$j] > 0)
        {$mobersgobuf = "$mobersgobuf$user_name_buf($mobersgon[$j]),\n";}
      }
      elsif($mobersgon[$j] eq 0)
      {
        if($mobersnogobuf eq ""){$mobersnogobuf = "<b>Не пойдут на моб:</b><font size=1>\n"};
        $mobersnogoncol++;
        $user_name_buf=&Get_Formated_User_Name($mobersgo[$j]);
        $mobersgon[$j]--;
        if($mobersgo[$j] eq $Userid)
        {
          $user_name_buf = "<b>$user_name_buf</b>";
        }
        $mobersnogobuf = "$mobersnogobuf$user_name_buf,\n";
      }
    }
  }
  if($mobersgobuf ne "")
  {
    substr($mobersgobuf,-2) = ".<br>\n(в скобках указывается количество человек, которые не посещают этот сайт, которых мобер приведёт с собой)</font><br>\n";
  }
  if($mobersnogobuf ne "")
  {
    substr($mobersnogobuf,-2) = ".</font><br>\n";
  }
  print "$mobersgobuf";
  print "$mobersnogobuf";
  print "\n<b>Итого:</b> $mobersgoncol " .&moberstext($mobersgoncol). ".<br>\n";
  if($login eq 1)
  {
    print "<form method=\"post\" action=\"$site?mode=next\">";
    print "<input type=\"hidden\" name=\"mode\" value=\"next\">";
    print "<input type=\"hidden\" name=\"action\" value=\"go\">";
    print "<input type=\"hidden\" name=\"play\" value=\"$play\">";
    print "<input type=\"submit\" style=\"background-color: $tseriy;\" style=\"width: 70px;\" name=\"answer\" value=\"Пойду\"> ";
    print "С собой возьму <input type=text style=\"width: 20px;\" name=moberswithme value=\"$Usermobersgo\" tabindex=4 maxlength=1> человек(а).\n";
    print "<input type=\"submit\" style=\"background-color: $tseriy;\" style=\"width: 70px;\" name=\"answer\" value=\"Не пойду\">";
  }
  print "</td></tr>";

  print "<tr><td></tr>";
  print "<tr bgcolor=$seriy><td colspan=3><b>Обсуждение</b></td></tr>";
  print "<tr bgcolor=$sseriy><td colspan=3>";
  $nomerok = $play;

  if($board ne 4)
  {
    open(GB, "<boards/4.txt");
    flock(GB, 1);
    while (<GB>)
    {
      ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
      if($buf1 eq $playinfo[10])
      {
        $timeoflastpostofplay{$nomerok}=$buf7;
        $postcountofplay{$nomerok}=$buf6;
        $threadofplay{$nomerok}=$buf1;
     }
    }
    close (GB);
    $textbuf = "Текущее обсуждение: ";
    &Gen_link_to_fotum;
  }

  print "<br>";

  if($board ne 3)
  {
    open(GB, "<boards/3.txt");
    flock(GB, 1);
    while (<GB>)
    {
      ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
      if($buf1 eq $playinfo[9])
      {
        $timeoflastpostofplay{$nomerok}=$buf7;
        $postcountofplay{$nomerok}=$buf6;
        $threadofplay{$nomerok}=$buf1;
     }
    }
    close (GB);
    $textbuf = "Обсуждение во время голосования (закрыто): ";
    &Gen_link_to_fotum;
  }

  print "</td></tr>";

  print "</form></table>";
}

sub usergotoplay {
  my $voicebuf = $_[0];

  $tempfile="plays/$play.txt";
  if (not -e $tempfile)
  {&playnotfint}
  open(playfile, "+<plays/$play.txt");
  flock(playfile, 2);
  seek playfile, 0, 0;
  @playinfo=<playfile>;
  truncate playfile, 0;
  seek playfile, 0, 0;
  foreach (@playinfo)
  {chomp $_}


  @voices1 = split(/:/,$playinfo[14]);
  @users1 = split(/:/,$playinfo[13]);
  $useris = "0";

  for($i=0;$i<@users1;$i++)
  {
    if(@users1[$i] eq $Userid)
    {
      @voices1[$i] = $voicebuf;
      $useris = "1";
    }
  }
  if($useris ne "1")
  {
    $buf=$voicebuf;
    $playinfo[14] = "$playinfo[14]:$buf";
    $playinfo[13] = "$playinfo[13]:$Userid";
  }
  else
  {
    $playinfo[14] = join(":", @voices1);
  }

  $newplayinfo = join("\n", @playinfo);

  print playfile $newplayinfo;
  close (playfile);
}

sub movetonext{

  if(param(finish) eq "1")
  {
    $message = param(message);
    $playname = readparam(playname);
    $message =~ s/\n/<br>/g;
    $playname =~ s/&quot;/"/g;

    open (PLAYS,"<plays/plays.txt");
    flock(PLAYS, 1);
    open (PLAYSBUF,">plays/plays_buf.txt");
    flock(PLAYSBUF, 2);
    while (<PLAYS>)
    {
      ($playbuf,$typebuf,$aftorbuf,$datebuf)=split(/\|/,$_);
      if($typebuf eq 2|$playbuf eq $play)
      {
        open(playinfo, "+<plays/$playbuf.txt");
        flock(playinfo, 2);
        seek playinfo, 0, 0;
        @playinfo=<playinfo>;
        truncate playinfo, 0;
        seek playinfo, 0, 0;
        foreach (@playinfo)
        {chomp $_}

        if($playbuf eq $play)
        {
          if($playinfo[9] ne "")
          {
            &ThreadClose($playinfo[9]);
          }

          if($playinfo[10] eq "")
          {
            $subjectbuf = $playname;
            $commentbuf = $play;
            $messagebuf = " ";
            $board = 4;
            $typebuf = "2";

            &addthread;
            $playinfo[10] = $newthreadid;
          }
          else
          {
            &ThreadOpen($playinfo[10]);
          }
          $typebuf = 2;
          $playinfo[0] = "2";
          if($typebuf eq 2)
          {
            $playinfo[2] = $nowtime;
          }
          $playinfo[4] = $nowtime;
          $playinfo[5] = $playname;
          $playinfo[6] = $message;
          $playinfo[12] = param(next_time);
          $playinfo[16] = param(next_place);
          $playinfo[17] = $Userid;
          $playinfo[18] = param(next_duration);

          $i=0;
          foreach (@mdays)
          {
            $i++;
            if(param(next_mm) eq $_)
            {
              $next_mm = $i;
              $next_mm = "0$next_mm" if ($next_mm<10);
              last;
            }
          }
          $next_dd = param(next_dd);
          $next_yyyy = param(next_yyyy);

          if($next_yyyy ne ""&$next_dd ne ""&$next_mm ne "")
          {$playinfo[15]="$next_dd.$next_mm.$next_yyyy"}
          else
          {$playinfo[15]="";}
        }
        elsif($typebuf eq 2)
        {
          $typebuf = 1;
          $playinfo[0] = "1";
          $playinfo[4] = $nowtime;
          $playinfo[17] = $Userid;
          &ThreadOpen($playinfo[9]);
          &ThreadClose($playinfo[10]);
        }

        @playinfo = join("\n", @playinfo);
        print playinfo @playinfo;
        close (playinfo);
      }
      print PLAYSBUF "$playbuf|$typebuf|$aftorbuf|$datebuf";
    }
    close(PLAYS);
    close(PLAYSBUF);
    rename("plays/plays.txt", "plays/plays_old.txt");
    rename("plays/plays_buf.txt", "plays/plays.txt");
    $redirectto = "$site?mode=next";
    &html;
    exit;
  }
  &html;
  open(playinfo, "<plays\/$play.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  foreach (@playinfo)
  {chomp $_}

  $playname = $playinfo[5];
  $playname =~ s/"/&quot;/gi;
  $playinfo[16] =~ s/"/&quot;/gi;
  $message = $playinfo[6];
  $message =~ s/<br>/\n/gi;
  $playdate = $nowtime;

  if($action eq "movetonext")
  {
    $buf1="Перемещение сценария в предстоящие мобы";
  }
  else
  {
    $buf1="Редактирование сценария предстоящего моба";
  }

  $buf2 = &Get_Formated_User_Name($playinfo[17]);

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<br>
<table border=0 cellspacing=0 cellpadding=1 width=\"100\%\">
<center><td align=center>
<table border=0 cellspacing=0 cellpadding=2>
<form method=POST name=post action=$postto>
<input type=hidden name=action value=movetonext>
<input type=hidden name=mode value=voting>
<input type=hidden name=play value="$play">
<input type=hidden name=finish value="1">
<tr><td colspan=5 align=center><b><font size=4>$buf1</font></b></td></tr>
<tr>
<td colspan=5>Последние изменения вносил: $buf2 [$playinfo[4]]</td>
</tr>
<tr>
<td colspan=1>Название: </td>
<td colspan=4><input type=text size=80 name=playname value="$playname" tabindex="4"></td>
</tr>
<tr>
<td colspan=1>Дата проведения: </td>
<td colspan=4>
FORMA

  ($dey1, $mday1, $year1) = ($playinfo[15] =~ /(\d+)\.(\d+)\.(\d+)/);

  print "<select name=next_dd><option>";

  for($j=1;$j<=31;$j++)
  {
    $daybuf = $j;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($dey1 eq $daybuf)
    {print "<option selected>$daybuf"}
    else
    {print "<option>$daybuf"}
  }

  print "</select><select name=next_mm><option>";

  for($j=0;$j<12;$j++)
  {
    $daybuf = $j+1;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($mday1 eq $daybuf)
    {print "<option selected>$mdays[$j]"}
    else
    {print "<option>$mdays[$j]"}
  }

  print "</select><select name=next_yyyy><option>";

  for($j=$year-3;$j<=$year+3;$j++)
  {
    $yearbuf = $j;
    if($year1 eq $yearbuf)
    {print "<option selected>$yearbuf"}
    else
    {print "<option>$yearbuf"}
  }

  print "</select> (Оставьте поля пустыми, если дата ещё не известна)";

  print <<FORMA;
</td>
</tr>
<td colspan=1>Время проведения: </td>
<td colspan=4><input type=text size=4 maxlength=5 name=next_time value="$playinfo[12]" tabindex="">
 (Например: "17:15". Оставьте поле пустым, если время ещё не известно)
</td>
</tr>
<tr>
<td colspan=1>Продолжительность: </td>
<td colspan=4><input type=text size=4 maxlength=2 name=next_duration value="$playinfo[18]" tabindex="">
 (Время в минутах. Например: "7".)
</td>
</tr>
<tr>
<td colspan=1>Место проведения: </td>
<td colspan=4><input type=text size=80 name=next_place value="$playinfo[16]" tabindex="">
</td>
</tr>
<tr>
<td valign=bottom colspan=1>Сценарий:</td>
FORMA

  &textinput;

  print <<FORMA;
<tr>
    <td align=center><input type=submit style=\"background-color: $tseriy;\" value=Отправить tabindex="4"></td>
</tr>
</tr>
</form></table>
</td></table>
</center>
</center>
FORMA

}

sub movetovoting{
  open (PLAYS,"<plays/plays.txt");
  flock(PLAYS, 1);
  open (PLAYSBUF,">plays/plays_buf.txt");
  flock(PLAYSBUF, 2);
  while (<PLAYS>)
  {
    ($buf1,$buf2,$buf3,$buf4)=split(/\|/,$_);
    if($buf1 eq $play)
    {
      open(playinfo, "+<plays/$buf1.txt");
      flock(playinfo, 2);
      seek playinfo, 0, 0;
      @playinfo=<playinfo>;
      truncate playinfo, 0;
      seek playinfo, 0, 0;
      foreach (@playinfo)
      {chomp $_}
      if($buf2 eq 2)
      {
        $buf2 = 1;
        $playinfo[0] = "1";
        if($playinfo[9] ne "")
        {
          &ThreadOpen($playinfo[9]);
        }
        if($playinfo[10] ne "")
        {
          &ThreadClose($playinfo[10]);
        }
        $playinfo[17] = $Userid;
      }
      @playinfo = join("\n", @playinfo);
      print playinfo @playinfo;
      close (playinfo);
    }
    print PLAYSBUF "$buf1|$buf2|$buf3|$buf4";
  }
  close(PLAYS);
  close(PLAYSBUF);
  rename("plays/plays.txt", "plays/plays_old.txt");
  rename("plays/plays_buf.txt", "plays/plays.txt");
  $redirectto = "$site?mode=next";
  &html;
  exit;
}

sub votingplaytime{
  open (PLAYTIME,"<plays/$play\_time.txt");
  flock(PLAYTIME, 1);
  open (PLAYTIMEBUF,">plays/$play\_time_buf.txt");
  flock(PLAYTIMEBUF, 2);

  while (<PLAYTIME>)
  {
    $answerbuf = "";
    $playtimebuf = $_;
    chomp $playtimebuf;
    ($timeid, $datebuf, $timebuf, $avtorbuf, $usersbuf, $voicesbuf)=split(/\|/,$playtimebuf);

    if(param("dateisyes$timeid") eq "on" & param("dateisno$timeid") ne "on")
    {
      $answerbuf = 1;
    }

    if(param("dateisno$timeid") eq "on" & param("dateisyes$timeid") ne "on")
    {
      $answerbuf = 0;
    }

    @voices1 = split(/:/,$voicesbuf);
    @users1 = split(/:/,$usersbuf);

    $useris = "0";
    for($i=0;$i<@users1;$i++)
    {
      if(@users1[$i] eq $Userid)
      {
        @voices1[$i] = $answerbuf;
        $useris = "1";
      }
    }

    if($useris ne "1")
    {
      $usersbuf = "$usersbuf\:$Userid";
      $voicesbuf = "$voicesbuf\:$answerbuf";
    }
    else
    {
      $voicesbuf = join(":", @voices1);
    }
    print PLAYTIMEBUF "$timeid|$datebuf|$timebuf|$avtorbuf|$usersbuf|$voicesbuf\n";
  }
  close(PLAYTIMEBUF);

  &sort_playtime;

  close(PLAYTIME);

  rename("plays/$play\_time.txt", "plays/$play\_time\_old.txt");
  rename("plays/$play\_time\_buf.txt", "plays/$play\_time.txt");
}

sub votingplaymesto{
  open (PLAYMESTO,"<plays/$play\_mesto.txt");
  flock(PLAYMESTO, 1);
  open (PLAYMESTOBUF,">plays/$play\_mesto_buf.txt");
  flock(PLAYMESTOBUF, 2);

  while (<PLAYMESTO>)
  {
    $answerbuf = "";
    $playmestobuf = $_;
    chomp $playmestobuf;
    ($mestoid, $mestobuf, $avtorbuf, $usersbuf, $voicesbuf)=split(/\|/,$playmestobuf);

    if(param("mestoisyes$mestoid") eq "on" & param("mestoisno$mestoid") ne "on")
    {
      $answerbuf = 1;
    }

    if(param("mestoisno$mestoid") eq "on" & param("mestoisyes$mestoid") ne "on")
    {
      $answerbuf = 0;
    }

    @voices1 = split(/:/,$voicesbuf);
    @users1 = split(/:/,$usersbuf);

    $useris = "0";
    for($i=0;$i<@users1;$i++)
    {
      if(@users1[$i] eq $Userid)
      {
        @voices1[$i] = $answerbuf;
        $useris = "1";
      }
    }

    if($useris ne "1")
    {
      $usersbuf = "$usersbuf\:$Userid";
      $voicesbuf = "$voicesbuf\:$answerbuf";
    }
    else
    {
      $voicesbuf = join(":", @voices1);
    }
    print PLAYMESTOBUF "$mestoid|$mestobuf|$avtorbuf|$usersbuf|$voicesbuf\n";
  }
  close(PLAYMESTOBUF);

  &sort_playmesto;

  close(PLAYMESTO);

  rename("plays/$play\_mesto.txt", "plays/$play\_mesto\_old.txt");
  rename("plays/$play\_mesto\_buf.txt", "plays/$play\_mesto.txt");
}

sub addplaytime{
  open(PLAYTIMEBUF, "+<plays/$play\_time.txt") || open(PLAYTIMEBUF, ">plays/$play\_time.txt");
  flock(PLAYTIMEBUF, 2);
  seek PLAYTIMEBUF, 0, 0;
  my @playtime=<PLAYTIMEBUF>;
  truncate PLAYTIMEBUF, 0;
  seek PLAYTIMEBUF, 0, 0;

  $i=0;
  foreach (@mdays)
  {
    $i++;
    if(param(next_mm) eq $_)
    {
      $next_mm = $i;
      $next_mm = "0$next_mm" if ($next_mm<10);
      last;
    }
  }
  $next_dd = param(next_dd);
  $next_yyyy = param(next_yyyy);
  $next_hh = param(next_hh);
  $next_min = param(next_min);

  if($next_yyyy ne ""&$next_dd ne ""&$next_mm ne ""&$next_hh ne ""&$next_min ne "")
  {
    $datebuf = "$next_dd.$next_mm.$next_yyyy";
    $timebuf = "$next_hh:$next_min";
  }
  else
  {
    print PLAYTIMEBUF @playtime;
    close(PLAYTIMEBUF);
    return;
  }

  $timeid = 0;
  for (@playtime)
  {
    ($timeidbuf, $datebuf2, $timebuf2, $buf, $buf, $buf)=split(/\|/,$_);
    if($datebuf2 eq $datebuf & $timebuf2 eq $timebuf)
    {
      print PLAYTIMEBUF @playtime;
      close(PLAYTIMEBUF);
      return;
    }
    if($timeidbuf > $timeid){$timeid = $timeidbuf}
  }
  $timeid++;
  $avtorbuf = $Userid;
  $usersbuf = "$Userid";
  $voicesbuf = "1";

  $playtime[@playtime]="$timeid|$datebuf|$timebuf|$avtorbuf|$usersbuf|$voicesbuf\n";
  print PLAYTIMEBUF @playtime;
  close(PLAYTIMEBUF);
}

sub addplaymesto{
  open(PLAYMESTOBUF, "+<plays/$play\_mesto.txt") || open(PLAYMESTOBUF, ">plays/$play\_mesto.txt");
  flock(PLAYMESTOBUF, 2);
  seek PLAYMESTOBUF, 0, 0;
  my @playmesto=<PLAYMESTOBUF>;
  truncate PLAYMESTOBUF, 0;
  seek PLAYMESTOBUF, 0, 0;

#  $mestoid = @playmesto + 1;

  $next_mesto = param(next_mesto);

  if($next_mesto ne "")
  {
    $mestobuf = $next_mesto;
  }
  else
  {
    print PLAYMESTOBUF @playmesto;
    close(PLAYMESTOBUF);
    return;
  }

  $mestoid = 0;
  for (@playmesto)
  {
    ($mestoidbuf, $mestobuf2, $buf, $buf, $buf)=split(/\|/,$_);
    if($mestobuf2 eq $mestobuf)
    {
      print PLAYMESTOBUF @playmesto;
      close(PLAYMESTOBUF);
      return;
    }
    if($mestoidbuf > $mestoid){$mestoid = $mestoidbuf}
  }
  $mestoid++;

  $avtorbuf = $Userid;
  $usersbuf = "$Userid";
  $voicesbuf = "1";

  $playmesto[@playmesto]="$mestoid|$mestobuf|$avtorbuf|$usersbuf|$voicesbuf\n";
  print PLAYMESTOBUF @playmesto;
  close(PLAYMESTOBUF);
}

sub sort_playtime{
  open(PLAYTIMEBUF, "+<plays/$play\_time\_buf.txt");
  flock(PLAYTIMEBUF, 2);
  seek PLAYTIMEBUF, 0, 0;
  my @playtime=<PLAYTIMEBUF>;
  truncate PLAYTIMEBUF, 0;
  seek PLAYTIMEBUF, 0, 0;
  $i=0;
  for $playtime1 (@playtime)
  {
    ($timeid, $datebuf, $timebuf, $avtorbuf, $usersbuf, $voicebuf)=split(/\|/,$playtime1);
    chomp $voicebuf;
    @voicestime=split(/:/, $voicebuf);

    $mogut = 0;
    $nemogut = 0;
    $itogo = 0;
    for $voicestime1 (@voicestime)
    {
      if($voicestime1 eq 1)
      {
        $mogut++;
      }
      elsif($voicestime1 eq 0)
      {
        $nemogut++;
      }
    }
    $itogo = $mogut - $nemogut;

    $itogoofplay{$playtime1} = $itogo;
    $mogutofplay{$playtime1} = $mogut;

    $i++;
  }

  my @playtime2 = sort { &comparison_plays_by_time2($a, $b) } @playtime;

  print PLAYTIMEBUF @playtime2;
  close (PLAYTIMEBUF);
}

sub sort_playmesto{
  open(PLAYMESTOBUF, "+<plays/$play\_mesto\_buf.txt");
  flock(PLAYMESTOBUF, 2);
  seek PLAYMESTOBUF, 0, 0;
  my @playmesto=<PLAYMESTOBUF>;
  truncate PLAYMESTOBUF, 0;
  seek PLAYMESTOBUF, 0, 0;
  $i=0;
  for $playmesto1 (@playmesto)
  {
    ($mestoid, $mestobuf, $avtorbuf, $usersbuf, $voicebuf)=split(/\|/,$playmesto1);
    chomp $voicebuf;
    @voicesmesto=split(/:/, $voicebuf);

    $mogut = 0;
    $nemogut = 0;
    $itogo = 0;
    for $voicesmesto1 (@voicesmesto)
    {
      if($voicesmesto1 eq 1)
      {
        $mogut++;
      }
      elsif($voicesmesto1 eq 0)
      {
        $nemogut++;
      }
    }
    $itogo = $mogut - $nemogut;

    $itogoofplay{$playmesto1} = $itogo;
    $mogutofplay{$playmesto1} = $mogut;

    $i++;
  }

  my @playmesto2 = sort { &comparison_plays_by_time2($a, $b) } @playmesto;

  print PLAYMESTOBUF @playmesto2;
  close (PLAYMESTOBUF);
}

sub comparison_plays_by_time2{
  $playa = $_[0];
  $playb = $_[1];
  if($itogoofplay{$playa} > $itogoofplay{$playb})
  {return -1}
  elsif($itogoofplay{$playa} < $itogoofplay{$playb})
  {return 1}
  else
  {
    if($mogutofplay{$playa} > $mogutofplay{$playb})
    {return -1}
    else
    {return 1}
  }
}

sub modifyplaymesto{
  open (PLAYMESTO,"<plays/$play\_mesto.txt");
  flock(PLAYMESTO, 1);
  open (PLAYMESTOBUF,">plays/$play\_mesto_buf.txt");
  flock(PLAYMESTOBUF, 2);

  while (<PLAYMESTO>)
  {
    $playmestobuf = $_;
    chomp $playmestobuf;
    ($mestoid, $mestobuf, $avtorbuf, $usersbuf, $voicesbuf)=split(/\|/,$playmestobuf);

    if(param("next_mesto$mestoid") ne "")
    {
      $mestobuf = param("next_mesto$mestoid");
    }

    if(param("delete$mestoid") ne "on")
    {
      print PLAYMESTOBUF "$mestoid|$mestobuf|$avtorbuf|$usersbuf|$voicesbuf\n";
    }
  }
  close(PLAYMESTOBUF);

  close(PLAYMESTO);

  rename("plays/$play\_mesto.txt", "plays/$play\_mesto\_old.txt");
  rename("plays/$play\_mesto\_buf.txt", "plays/$play\_mesto.txt");
}

sub modifyplaytime{
  open (PLAYTIME,"<plays/$play\_time.txt");
  flock(PLAYTIME, 1);
  open (PLAYTIMEBUF,">plays/$play\_time_buf.txt");
  flock(PLAYTIMEBUF, 2);

  while (<PLAYTIME>)
  {
    $playtimebuf = $_;
    chomp $playtimebuf;

    ($timeid, $datebuf, $timebuf, $avtorbuf, $usersbuf, $voicesbuf)=split(/\|/,$playtimebuf);

    if(param("delete$timeid") ne "on")
    {
      print PLAYTIMEBUF "$timeid|$datebuf|$timebuf|$avtorbuf|$usersbuf|$voicesbuf\n";
    }
  }
  close(PLAYTIMEBUF);

  close(PLAYTIME);

  rename("plays/$play\_time.txt", "plays/$play\_time\_old.txt");
  rename("plays/$play\_time\_buf.txt", "plays/$play\_time.txt");
}


1;
