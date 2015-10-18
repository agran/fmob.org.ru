{
  use locale;
  use POSIX qw(locale_h);
}

sub showpast{

  &readindexofplay;

  @indexofplay = &sort_plays_by_time;

  if(@indexofplay eq 0)
  {
    print "<br><center><b>Ещё нет. @newplay @indexofplay</b></center>";
    return;
  }

   if($play eq "")
   {$play = @indexofplay[0]}


  if($mode eq "past")
  {print "<center><b><font size=4>$title2</font></b></center><br>";}
  print "<table border=0 cellpadding=4 width=780>";
  print "<tr bgcolor=$tseriy align=center>";
  print "<td><b>№</b>";
  print "<td width=80\%><b>Название</b>";
  print "<td><b>Дата</b>";
  print "<td><b>Автор</b>";
  print "</tr>";
  print "<tr><td> </tr>\n";

  $nomer=@indexofplay;
  foreach (@indexofplay)
  {
    print "<!--start mesto: $mesto play: $_-->\n";
    if ($_ eq $play)
    {&showmaxipast($_)}
    else
    {&showminipast($_)}
    print "<!--end-->\n";
    $nomer--;
  }

  print "</table>";
}

sub showminipast{
  $nomerok=$_[0];
  open(playinfo, "<plays/$nomerok.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  foreach (@playinfo)
  {chomp $_}

  $Useridbuf=$playinfo[3];
  $datebuf=$playinfo[15];

  $avtor=&Get_Formated_User_Name($Useridbuf);
  $name=$playinfo[5];

  print "<tr align=center bgcolor=$seriy>";
  print "<td><b>$nomer</b></td>\n";
  print "<td><b><a href=$site?play=$nomerok>$name</a></b></td>\n";
  print "<td>$datebuf</td>\n";
  print "<td><b>$avtor</b></td>\n";
  print "</tr>";
  print "<tr bgcolor=$sseriy>";
  print "<td colspan=4>";
  $textbuf = "Обсуждение: ";
  &Gen_link_to_fotum;
  print "</td></tr>";

  print "<tr><td> </tr>\n";
}

sub showmaxipast{
  $nomerok=$_[0];

  if((($usertype eq "модераторы")|($usertype eq "администраторы"))&($mode eq "past"))
  {
    $buf7 = qq~<center>
<b><font size="1">
[<a href=$site?mode=voting\&action=delete\&play=$nomerok class="adm">Удалить</a>]
[<a href=$site?mode=past\&action=edit\&play=$nomerok class="adm">Редактировать</a>]
</font></b></center>~;
  }
  else
  {
    $buf7 = qq~~;
  }

  open(playinfo, "<plays/$nomerok.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  foreach (@playinfo)
  {chomp $_}

  $Useridbuf=$playinfo[3];
  $avtor=&Get_Formated_User_Name($Useridbuf);
  $datebuf=$playinfo[15];
  $name=$playinfo[5];

  $NomerUserNameinList=&isUserNameinList;
  $golosoval=0;
  $golosoval=1 if ($NomerUserNameinList >= 0);

  print "<tr align=center bgcolor=$seriy>";
  print "<td><a name=$nomerok></a><b>$nomer</b></td>\n";
  print "<td><b><a href=$site?play=$nomerok>$name</a></b></td>\n";
  print "<td>$datebuf</td>\n";
  print "<td><b>$avtor</b></td>\n";
  print "</tr>";
  print "<tr bgcolor=$sseriy>";
  print "<td colspan=4>";
  print "<center>$buf7</center>";

  $buf1 = $playinfo[6];
  if(param(otch) ne "" | $mode ne "forum")
  {
    $buf1 =~ s~\[otch\](.+?)\[/otch\]~[b]Отчёты:[/b]$1~isg;
  }
  else
  {
    $buf1 =~ s~\[otch\](.+?)\[/otch\]~\[url=$site/?$ENV{QUERY_STRING}&otch=1\]\[b\]Показать отчёты\[/b\]\[/url\]~isg;
  }

  $buf = &text_process($buf1);

  $hl=param(hl);
  @dum = split(/ /,$hl);
  foreach (@dum)
  {
    $buf =~ s/($_)/\<span class=searchlite\>$1\<\/span\>/gsi;
    $playinfo[16] =~ s/($_)/\<span class=searchlite\>$1\<\/span\>/gsi;
  }


  print "<b>Сценарий:</b><br>$buf<br><br>\n";

  print "<b>Место проведения:</b> $playinfo[16]<br><br>";
  print "<b>Дата проведения:</b> $playinfo[15]<br>";
  print "<b>День недели:</b> ", &getwday($playinfo[15]), "<br>";
  print "<b>Время проведения:</b> $playinfo[12]<br>";
  print "<b>Длительность:</b> $playinfo[18] минут.<br><br>";

  if($playinfo[20] ne "")
  {
    print "<b>Участников:</b> $playinfo[20]<br><br>";
  }
  if($playinfo[19] ne "")
  {
    $playinfo[19] =~ s~ ~<br>~g;
    $playinfo[19] = &text_process($playinfo[19]);
    print "<b>Фотографии:</b><br>$playinfo[19]<br><br>";
  }

  if($login eq 1)
  {
    print "<form method=\"post\" action=\"$site?mode=past&play=$nomerok\#$nomerok\">";
    print "<input type=\"hidden\" name=\"mode\" value=\"past\">";
    print "<input type=\"hidden\" name=\"play\" value=\"$nomerok\">";
    print "<input type=\"submit\" style=\"background-color: $tseriy;\" style=\"width: 100px;\" name=\"was\" value=\"Был на мобе\"> ";
    print "<input type=\"submit\" style=\"background-color: $tseriy;\" style=\"width: 100px;\" name=\"was\" value=\"Не был на мобе\"> ";
    print "</form>";
  }

  @users1 = split(/:/,$playinfo[21]);
  @voices1 = split(/:/,$playinfo[22]);

  $i=0;
  $poshli_buf = "";
  $neposhli_buf = "";
  for(@voices1)
  {
    if($users1[$i] ne "")
    {
      if($_ eq 1)
      {
        if($users1[$i] eq $Userid)
        {
          $poshli_buf = "$poshli_buf, <b>".&Get_Formated_User_Name($users1[$i])."</b>";
        }
        else
        {
          $poshli_buf = "$poshli_buf, ".&Get_Formated_User_Name($users1[$i]) ;
        }
      }
      else
      {
        if($users1[$i] eq $Userid)
        {
          $neposhli_buf = "$neposhli_buf, <b>".&Get_Formated_User_Name($users1[$i])."</b>";
        }
        else
        {
          $neposhli_buf = "$neposhli_buf, ".&Get_Formated_User_Name($users1[$i]) ;
        }
      }
    }
    $i++;
  }

  substr($poshli_buf, 0, 2) = "";
  substr($neposhli_buf, 0, 2) = "";

  if($poshli_buf ne "")
  {
    print "<b>Были на мобе:</b> <font size='1'>$poshli_buf</font><br>";
  }
  if($neposhli_buf ne "")
  {
    print "<b>Не были на мобе:</b> <font size='1'>$neposhli_buf</font><br>";
  }

  print "<br><b>Обсуждение:</b><br>";

  if($board ne 5)
  {
    open(GB, "<boards/5.txt");
    flock(GB, 1);
    while (<GB>)
    {
      ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
      if($buf1 eq $playinfo[11])
      {
        $timeoflastpostofplay{$nomerok}=$buf7;
        $postcountofplay{$nomerok}=$buf6;
        $threadofplay{$nomerok}=$buf1;
     }
    }
    close (GB);
    $textbuf = "Текущее обсуждение: ";
    &Gen_link_to_fotum;
    print "<br>";
  }

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
    $textbuf = "Обсуждение по предстоящему мобу (закрыто): ";
    &Gen_link_to_fotum;
    print "<br>";
  }

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
    print "<br>";
  }

  print "</td></tr>";

  print "<tr><td> </tr>\n";
}

sub movetopast{
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
      if($playbuf eq $play)
      {
        open(playinfo, "+<plays/$playbuf.txt");
        flock(playinfo, 2);
        seek playinfo, 0, 0;
        @playinfo=<playinfo>;
        truncate playinfo, 0;
        seek playinfo, 0, 0;
        foreach (@playinfo)
        {chomp $_}

        if($playinfo[10] ne "")
        {
          &ThreadClose($playinfo[10]);
        }

        if($playinfo[11] eq "")
        {
          $subjectbuf = $playname;
          $commentbuf = $play;
          $messagebuf = " ";
          $board = 5;
          $typebuf = "2";

          &addthread;
          $playinfo[11] = $newthreadid;
        }
        else
        {
          &ThreadOpen($playinfo[11]);
        }
        $typebuf = 3;

        $playinfo[0] = "3";
        $playinfo[2] = $nowtime;
        $playinfo[4] = $nowtime;
        $playinfo[5] = $playname;
        $playinfo[6] = $message;
        $playinfo[12] = param(past_time);
        $playinfo[16] = param(past_place);
        $playinfo[17] = $Userid;
        $playinfo[18] = param(past_duration);
        $playinfo[19] = param(past_foto);
        $playinfo[20] = param(past_mobersgo);

        $i=0;
        foreach (@mdays)
        {
          $i++;
          if(param(past_mm) eq $_)
          {
            $past_mm = $i;
            $past_mm = "0$past_mm" if ($past_mm<10);
            last;
          }
        }
        $past_dd = param(past_dd);
        $past_yyyy = param(past_yyyy);

        if($past_yyyy ne ""&$past_dd ne ""&$past_mm ne "")
        {$playinfo[15]="$past_dd.$past_mm.$past_yyyy"}
        else
        {$playinfo[15]="";}

        $datebuf = &getwday($playinfo[15], 1). " $playinfo[12] - $playinfo[15]\n";

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
    $redirectto = "$site?mode=past&play=$play#$play";
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
    $buf1="Перемещение сценария в прошедшие мобы";
  }
  else
  {
    $buf1="Редактирование прошедшего моба";
  }
  $buf2 = &Get_Formated_User_Name($playinfo[17]);

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<br>
<table border=0 cellspacing=0 cellpadding=1 width=\"100\%\">
<center><td align=center>
<table border=0 cellspacing=0 cellpadding=2>
<form method=POST name=post action="">
<input type=hidden name=action value=movetopast>
<input type=hidden name=mode value=next>
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

  print "<select name=past_dd><option>";

  for($j=1;$j<=31;$j++)
  {
    $daybuf = $j;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($dey1 eq $daybuf)
    {print "<option selected>$daybuf"}
    else
    {print "<option>$daybuf"}
  }

  print "</select><select name=past_mm><option>";

  for($j=0;$j<12;$j++)
  {
    $daybuf = $j+1;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($mday1 eq $daybuf)
    {print "<option selected>$mdays[$j]"}
    else
    {print "<option>$mdays[$j]"}
  }

  print "</select><select name=past_yyyy><option>";

  for($j=$year-3;$j<=$year+3;$j++)
  {
    $yearbuf = $j;
    if($year1 eq $yearbuf)
    {print "<option selected>$yearbuf"}
    else
    {print "<option>$yearbuf"}
  }

  print "</select>";

  print <<FORMA;
</td>
</tr>
<td colspan=1>Время проведения: </td>
<td colspan=4><input type=text size=4 maxlength=5 name=past_time value="$playinfo[12]" tabindex="">
 (Например: "17:15".)
</td>
</tr>
<tr>
<td colspan=1>Продолжительность: </td>
<td colspan=4><input type=text size=4 maxlength=2 name=past_duration value="$playinfo[18]" tabindex="">
 (Время в минутах. Например: "7".)
</td>
</tr>
<tr>
<td colspan=1>Место проведения: </td>
<td colspan=4><input type=text size=80 name=past_place value="$playinfo[16]" tabindex="">
</td>
<tr>
<td colspan=1>Фотогалереи: </td>
<td colspan=4><input type=text size=55 name=past_foto value="$playinfo[19]" tabindex="">Ссылки, через пробел
</td>
</tr>
<tr>
<td colspan=1>Реальная явка: </td>
<td colspan=4><input type=text size=4 name=past_mobersgo value="$playinfo[20]" tabindex="">
</td>
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

sub pastwas{
  open(playinfo, "+<plays/$play.txt");
  flock(playinfo, 2);
  seek playinfo, 0, 0;
  @playinfo=<playinfo>;
  truncate playinfo, 0;
  seek playinfo, 0, 0;
  foreach (@playinfo)
  {chomp $_}

  @users1 = split(/:/,$playinfo[21]);
  @voices1 = split(/:/,$playinfo[22]);

  if(param(was) eq "Был на мобе")
  {
    $voicebuf = 1;
  }
  elsif(param(was) eq "Не был на мобе")
  {
    $voicebuf = 0;
  }

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
    $playinfo[22] = "$playinfo[22]:$buf";
    $playinfo[21] = "$playinfo[21]:$Userid";
  }
  else
  {
    $playinfo[22] = join(":", @voices1);
  }

  @playinfo = join("\n", @playinfo);
  print playinfo @playinfo;
  close (playinfo);
##########################################

  open(userinfo, "+<users/$Userid.txt");
  flock(userinfo, 2);
  seek userinfo, 0, 0;
  @userinfo=<userinfo>;
  truncate userinfo, 0;
  seek userinfo, 0, 0;
  foreach (@userinfo)
  {chomp $_}

  @plays1 = split(/:/,$userinfo[29]);
  @voices1 = split(/:/,$userinfo[30]);

  if(param(was) eq "Был на мобе")
  {
    $voicebuf = 1;
  }
  elsif(param(was) eq "Не был на мобе")
  {
    $voicebuf = 0;
  }

  $playis = "0";
  for($i=0;$i<@plays1;$i++)
  {
    if(@plays1[$i] eq $play)
    {
      @voices1[$i] = $voicebuf;
      $playis = "1";
    }
  }
  if($playis ne "1")
  {
    $buf=$voicebuf;
    $userinfo[29] = "$userinfo[29]:$play";
    $userinfo[30] = "$userinfo[30]:$buf";
  }
  else
  {
    $userinfo[30] = join(":", @voices1);
  }

  @userinfo = join("\n", @userinfo);
  print userinfo @userinfo;
  close (userinfo);



}

1;
