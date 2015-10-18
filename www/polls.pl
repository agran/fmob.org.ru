sub new_poll {

  if(param(finish)eq 1)
  {
    $name = param(name);
    $name =~ s~\|~&#124;~g;
    $text = param(text);
    $text =~ s/\n/<br>/g;
    $text =~ s~\|~&#124;~g;

    if(param(multi) eq "on")
    {
      $multi = 1;
    }
    else
    {
      $multi = 0;
    }

    if($name eq "")
    {
      print "<center><br><b>Необходимо ввести название опроса.";
      &htmlend;
      exit;
    }

    if($text eq "")
    {
      print "<center><br><b>Необходимо тест опроса.";
      &htmlend;
      exit;
    }

    @variants = ();
    $flag = 0;
    for($i=1;$i <= 25;$i++)
    {
      if(param("variant$i")ne "")
      {
        $variants[$i - 1] = param("variant$i");
        $flag ++;
      }
    }
    if($flag eq 0)
    {
      print "<center><br><b>Необходимо ввести не менее одного вариата опроса.";
      &htmlend;
      exit;
    }

    open(maxindex, "+<polls/maxindex.txt") || open(maxindex, ">polls/maxindex.txt");
    flock(maxindex, 2);
    seek maxindex, 0, 0;
    $pollid=<maxindex>;
    $pollid++;
    truncate maxindex, 0;
    seek maxindex, 0, 0;
    print maxindex $pollid;
    close (maxindex);

    if(param("forum") eq "on")
    {
      $subjectbuf = $name;
      $messagebuf = "[poll=$pollid]";
      $commentbuf = "Опрос";
      $board = 14;
      $typebuf = "1";

      &addthread;
      &Inc_Col_Mes;
      &lastthread_update($newthreadid, $subjectbuf, $nowtime, $Userid, $board, 0);
      ($buf,$to2)=&get_subscribe_mails(3);
      &send_subscribe("\[url=$site?mode=forum&thread=$newthreadid\]\[size=4\]$subjectbuf\[/size\]\[/url\]\[br\]\[color=gray\] $commentbuf \[/color\]\[br\]\[b\]Автор:\[/b\] \[url=$site?showuser=$Userid\]$UserName\[/url\]\[br\]\[br\]\[hr\]$messagebuf\[hr\]\[br\]$site?mode=forum&thread=$newthreadid\[br\]\[br\]$site", "FMob: Создана новая тема: \"$subjectbuf\"", "\"$UserName\" <subscribe\@fmob.org.ru>", "", $to2);
    }


    open(pollfile, ">polls/$pollid.txt");
    flock(pollfile, 2);
    print pollfile qq~$Userid|$name|$text|$multi|$nowtime|0|0||$newthreadid\n~;
    $i = 0;
    for(@variants)
    {
      $i++;
      if($_ ne "")
      {
        print pollfile qq~$_|\n~;
      }
    }
    close(pollfile);

    print "<center><br><b>Опрос добавлен.</b><br>";
    print "Для использования опроса используйте код:  <input name=codecopy size=10 value=\"[poll=$pollid]\" type=text><br>";
    if(param("forum") eq "on")
    {
      print "Обсуждение опроса: <a href=$site?mode=forum&thread=$newthreadid&post=new>$site?mode=forum&thread=$newthreadid&post=new</a>";
    }
  }
  else
  {
    print <<FORMA;
<body onload="javascript:reloadad(0);">
<center>
<b><font size=4>Добавление нового опроса</font></b><br><br>
<script type="text/javascript" src="$site/bbCode.js"></script>
<form action="$site?mode=polls&action=add" name=forma method=post>
<input type=hidden name=mode value=polls>
<input type=hidden name=action value=add>
<input type=hidden name=finish value=1>
<table border=0 cellspacing=0 cellpadding=2>
<tr>
<td>Название опроса:</td>
<td><input type=text name=name size=50 value=\"\"></td>
</tr>
<tr>
<td colspan="2">Разрешать голосовать сразу за несколько:
<input name="multi" type="checkbox"></td>
</tr>
<tr>
<td colspan="2">Создать сопутствующую тему на форуме:
<input name="forum" type="checkbox" checked></td>
</tr>
<td colspan="2">Текст опроса:</td>
</tr>
<tr><td colspan="2">
<textarea name=text rows=5 cols=100 class=post></textarea>
</td></tr>
<tr>
<td colspan="2">Варианты опроса:
</tr>
<tr><td colspan="2">
<input type="Hidden" name="qs" value="0">
<div id="div"></div><br>
</tr>
<tr>
<td colspan="2" align="center">
<a style="cursor: hand;" onclick="javascript:ad();">Добавить ещё один пункт</a><br>
(Внимание! При добавлении новых пунктов в некоторых браузерах введённая информация может обнуляться.)
</tr>
<tr>
<td colspan=2 align=center><br><input type=submit style=\"background-color: $tseriy;\" value=Отправить></td>
</tr>
</table>
</form>
FORMA
  }
}

sub get_poll_form{

  $pollid = $_[0];

  @pull = ();

  if(not(-e "polls/$pollid.txt"))
  {
    return "<b>Ошибка. Нет такого опроса.</b>"
  }

  open (pollfile, "<polls/$pollid.txt");
  flock(pollfile, 1);
  @pull = <pollfile>;
  close pollfile;

  for(@pull)
  {
    chomp $_;
  }

  ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

  $text = &text_process($text);

  @variants = ();
  $i = -1;
  for(@pull)
  {
    $i++;
    if($i eq 0){next}
    ($varianttext, $variantusers) = split(/\|/,$_);
    $variants[$i-1] = $i;
    $variantusers{$i} = $variantusers;
    $varianttexts{$i} = $varianttext;
  }

  $Useridbuf2 = &Get_Formated_User_Name($Useridbuf);

  if($mode eq "polls"&($Useridbuf eq $Userid|$usertype eq "модераторы"|$usertype eq "администраторы"))
  {
    $buf = "<tr bgcolor=$beliy><td colspan=5>Код для использования: <input name=codecopy size=10 value=\"[poll=$pollid]\" type=text>\n";

    if($close eq "0")
    {
      $buf2 = "<tr bgcolor=$beliy><td colspan=5 align=center><input type=submit style=\"background-color: $tseriy;\" name=close value=Закрыть>\n";
    }
    else
    {
      $buf2 = "<tr bgcolor=$beliy><td colspan=5 align=center><b>Опрос закрыт</b> <input type=submit style=\"background-color: $tseriy;\" name=close value=Открыть>\n";
    }

    if($hide eq "0")
    {
      $buf2 = "$buf2<input type=submit style=\"background-color: $tseriy;\" name=hide value=Скрыть>\n";
    }
    else
    {
      $buf2 = "$buf2<b>Опрос скрыт</b> <input type=submit style=\"background-color: $tseriy;\" name=hide value=Показать>\n";
    }

    if($usertype eq "администраторы"|$usertype eq "модераторы")
    {
      $buf2 = "$buf2<input type=submit style=\"background-color: $tseriy;\" name=edit value=Редактировать>";
    }

  }
  else
  {
    $buf = "";
    $buf2 = "";
  }


  if($hide eq "0")
  {
    $buf3 = $sseriy;
    if($close eq "0")
    {
      $buf3 = $sseriy;
    }
    else
    {
      $buf3 = "A0E3E3";
    }
  }
  else
  {
    if(not($Useridbuf eq $Userid|$usertype eq "модераторы"|$usertype eq "администраторы"))
    {
      return "Опрос <b>$name</b> скрыт.<br>"
    }
    $buf3 = "FFE3E3";
  }

  $returnbuf = "<a name=poll_$pollid></a>
<form action=$site?mode=polls&action=vote name=form_poll_$pollid method=post>
<input type=hidden name=mode value=polls>
<input type=hidden name=action value=vote>
<input type=hidden name=pollid value=$pollid>
<table border=0 cellspacing=1 cellpadding=5 bgcolor=$tseriy>
<tr bgcolor=$buf3><td colspan=5 align=center><a href=$site?poll=$pollid><b>$name
<tr bgcolor=$beliy><td colspan=5>Автор: $Useridbuf2
$buf$buf2<tr bgcolor=$beliy><td colspan=5>$text\n";

  $all = 0;
  $i=0;
  for(@variants)
  {
    @varusers = split(/\:/,$variantusers{$_});
    $all += @varusers;
    $i++;
  }

  $golosoval = 2;
  for(@variants)
  {
    @varusers = split(/\:/,$variantusers{$_});

    for(@varusers)
    {
      if($_ eq $Userid)
      {
        $golosoval = 1;
      }
    }

  }
  if($login eq 0|$close eq "1")
  {
    $golosoval = 1;
  }

  $i=0;

  for(@PollShow)
  {
    if($_ eq $pollid)
    {
      $golosoval = 1;
    }
  }

  for(@variants)
  {
    $i++;

    @varusers = split(/\:/,$variantusers{$_});

    $colusers = @varusers;
    $buf = "";
    for(@varusers)
    {
      if($_ eq $Userid)
      {
        $buf = " checked";
      }
    }

    if($login eq 1&$close eq "0")
    {
      if($multi eq "1")
      {
        $returnbuf = "$returnbuf<tr bgcolor=$beliy><td align=righ nowrap>$i.<input name=variant$variants[$i-1] type=checkbox$buf>";
      }
      else
      {
        $returnbuf = "$returnbuf<tr bgcolor=$beliy><td align=right nowrap>$i.<input name=variant value=$variants[$i-1] type=radio$buf>";
      }
      $returnbuf = "$returnbuf<td colspan=$golosoval>$varianttexts{$variants[$i-1]}\n";
    }
    else
    {
      $returnbuf = "$returnbuf<tr bgcolor=$beliy><td colspan=2>$varianttexts{$variants[$i-1]}\n";
    }

    if($golosoval eq 1)
    {
      if($all>0)
      {
        $returnbuf = "$returnbuf<td>$colusers\n";
        $procent = $colusers / $all;
        $procent2 = sprintf("%.2f", 100*$procent);
        $width = int($procent * 200);
        if($mode eq "polls")
        {
          $returnbuf = "$returnbuf<td><img src=$site/image/bar_left.gif border=0 height=11 width=2><img src=$site/image/bar.gif border=0 height=11 width=$width><img src=$site/image/bar_right.gif border=0 height=11 width=2> [$procent2%]\n";
          $buf = "<font size=1>";
          for(@varusers)
          {
            if($_ eq $Userid)
            {
              $buf = "$buf, <b>".&Get_Formated_User_Name($_)."</b>";
            }
            else
            {
              $buf = "$buf, ".&Get_Formated_User_Name($_);
            }
          }
          $buf = "$buf</font>";
          if(@varusers>0)
          {
            substr($buf,13,2) = "";
          }
          $returnbuf = "$returnbuf<td>$buf\n";
        }
        else
        {
          $returnbuf = "$returnbuf<td colspan=2><img src=$site/image/bar_left.gif border=0 height=11 width=2><img src=$site/image/bar.gif border=0 height=11 width=$width><img src=$site/image/bar_right.gif border=0 height=11 width=2> [$procent2%]\n";
        }
      }
      else
      {

        $returnbuf = "$returnbuf<td colspan=3>$colusers\n";
      }
    }
  }
  if($threadid ne "")
  {

    $buf = &BoardGet($threadid);


    if($threadid ne $thread)
    {
      open(GB, "<boards/$buf.txt");
      flock(GB, 1);
      while (<GB>)
      {
        ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
        if($buf1 eq $threadid)
        {
          $timeoflastpostofplay{$threadid}=$buf7;
          $postcountofplay{$threadid}=$buf6;
          $threadofplay{$threadid}=$buf1;
       }
      }
      close (GB);
      $returnbuf = "$returnbuf<tr><td colspan=5 bgcolor=$beliy><b><a href=$site?mode=forum&thread=$threadid&post=new>Обсуждение ($postcountofplay{$threadid})</a></b>\n";
    }


  }
  if($login eq 1&$close eq "0")
  {
    $returnbuf = "$returnbuf<tr><td colspan=5 bgcolor=$sseriy align=center><input type=submit style=\"background-color: $tseriy;\" name=vote value=Проголосовать>\n";

    if($golosoval eq 2)
    {
      $returnbuf = "$returnbuf <input type=submit style=\"background-color: $tseriy;\" name=show value=\"Показать результаты\">";
    }
  }

  $returnbuf = "$returnbuf</table></form>\n";

  return $returnbuf;
}

sub poll_vote{
  $pollid = param("pollid");
  open (pollfile, "<polls/$pollid.txt");
  flock(pollfile, 1);
  @pull = <pollfile>;

  for(@pull)
  {
    chomp $_;
  }

  ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

  @variants = ();
  $i = -1;
  for(@pull)
  {
    $i++;
    if($i eq 0){next}
    ($varianttext, $variantusers) = split(/\|/,$_);
    $variants[$i-1] = $i;
    $variantusers{$i} = $variantusers;
    $varianttexts{$i} = $varianttext;
  }

  if($multi eq 1)
  {
    for(@variants)
    {
      $variant = $_;
      @varusers = split(/\:/,$variantusers{$variant});
      if(param("variant$variant")eq "on")
      {
        $flag = 0;
        for(@varusers)
        {
          if($_ eq $Userid)
          {
            $flag = 1;
          }
        }
        if($flag eq 0)
        {
          $variantusers{$variant} = "$variantusers{$variant}:$Userid"
        }
        if(substr($variantusers{$variant},0,1) eq ":")
        {
          substr($variantusers{$variant},0,1) = "";
        }
      }
      else
      {
        $flag = -1;
        $i=0;
        for(@varusers)
        {
          if($_ eq $Userid)
          {
            $flag = $i;
          }
          $i++;
        }
        if($flag > -1)
        {
          delete($varusers[$flag]);
          $variantusers{$variant}="";
          for(@varusers)
          {
            if($_ ne "")
            {
              $variantusers{$variant} = "$variantusers{$variant}:$_";
            }
          }
          substr($variantusers{$variant},0,1) = "";
        }
      }
    }
  }
  else
  {
    for(@variants)
    {
      $variant = $_;
      @varusers = split(/\:/,$variantusers{$variant});

      $flag = -1;
      $i=0;
      for(@varusers)
      {
        if($_ eq $Userid)
        {
          $flag = $i;
        }
        $i++;
      }

      if($flag > -1)
      {
        delete($varusers[$flag]);
        $variantusers{$variant}="";
        for(@varusers)
        {
          if($_ ne "")
          {
            $variantusers{$variant} = "$variantusers{$variant}:$_";
          }
        }
        substr($variantusers{$variant},0,1) = "";
      }
    }

    $variant = param("variant");

    $variantusers{$variant} = "$variantusers{$variant}:$Userid";

    if(substr($variantusers{$variant},0,1) eq ":")
    {
      substr($variantusers{$variant},0,1) = "";
    }
  }

  close pollfile;
  open(pollfile, ">polls/$pollid.txt");
  flock(pollfile, 2);
  print pollfile qq~$Useridbuf|$name|$text|$multi|$time|$close|$hide|$editby|$threadid\n~;
  $i = 0;
  for(@variants)
  {
    if($_ ne "")
    {
      print pollfile qq~$varianttexts{$_}|$variantusers{$_}\n~;
    }

  }
  close(pollfile);
}

sub show_polls{
  $page = param(page);
  if($page eq "")
  {
    $page=1;
  }
  open(maxindex, "<polls/maxindex.txt");
  flock(maxindex, 1);
  $maxpollid=<maxindex>;
  close (maxindex);

  print "<br><center><a href=$site?mode=polls&action=add><b>Добавить новый опрос</b></a><br><br></center>";

  $pagebuf = &buildpegelist($maxpollid, $page, $messonpage, "$site?mode=polls&page=");

  print "<center>$pagebuf</center><br>";

  for($j=$maxpollid;$j > 0;$j--)
  {
    if($j <= $maxpollid-($page-1)*$messonpage&$j > $maxpollid-$page*$messonpage)
    {
      print &get_poll_form($j);
    }
  }
  print "<br><center>$pagebuf</center><br>";
}

sub close_poll{
  $pollid = param(pollid);
  open (pollfile, "<polls/$pollid.txt");
  flock(pollfile, 1);
  @pull = <pollfile>;
  close pollfile;

  for(@pull)
  {
    chomp $_;
  }

  ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

  if($close eq "0")
  {
    $close = "1";
  }
  else
  {
    $close = "0";
  }

  open(pollfile, ">polls/$pollid.txt");
  flock(pollfile, 2);
  print pollfile qq~$Useridbuf|$name|$text|$multi|$time|$close|$hide|$editby|$threadid\n~;
  $i = 0;
  for(@pull)
  {
    if($i > 0)
    {
      print pollfile qq~$_\n~;
    }
    $i++;
  }
  close(pollfile);
}

sub hide_poll{
  $pollid = param(pollid);
  open (pollfile, "<polls/$pollid.txt");
  flock(pollfile, 1);
  @pull = <pollfile>;
  close pollfile;

  for(@pull)
  {
    chomp $_;
  }

  ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

  if($hide eq "0")
  {
    $hide = "1";
  }
  else
  {
    $hide = "0";
  }

  open(pollfile, ">polls/$pollid.txt");
  flock(pollfile, 2);
  print pollfile qq~$Useridbuf|$name|$text|$multi|$time|$close|$hide|$editby|$threadid\n~;
  $i = 0;
  for(@pull)
  {
    if($i > 0)
    {
      print pollfile qq~$_\n~;
    }
    $i++;
  }
  close(pollfile);
}


sub edit_poll {
  $pollid = param("pollid");

  if(param("finish") eq 1)
  {
    open (pollfile, "<polls/$pollid.txt");
    flock(pollfile, 1);
    @pull = <pollfile>;

    for(@pull)
    {
      chomp $_;
    }

    ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

    $editby = $Userid;

    $name = param("name");
    $name =~ s~\|~&#124;~g;

    $text = param("text");
    $text =~ s/\n/<br>/g;
    $text =~ s~\|~&#124;~g;

    @variants = ();
    $i = -1;
    for(@pull)
    {
      $i++;
      if($i eq 0){next}
      ($varianttext, $variantusers) = split(/\|/,$_);
      $variants[$i-1] = $i;
      $variantusers{$i} = $variantusers;
      $varianttexts{$i} = $varianttext;
    }

    @variants = ();
    $flag = 0;
    for($i=1;$i <= 25;$i++)
    {
      if(param("variant$i")ne "")
      {
        $variants[$i - 1] = $i;
        $varianttexts{$i} = param("variant$i");
        $flag ++;
      }
    }

    if($flag eq 0)
    {
      &html;
      print "<center><br><b>Необходимо ввести не менее одного вариата опроса.";
      &htmlend;
      exit;
    }

    if(param("multi") eq "on")
    {
      $multi = 1;
    }
    else
    {
      $multi = 0;
    }

    close pollfile;
    open(pollfile, ">polls/$pollid.txt");
    flock(pollfile, 2);
    print pollfile qq~$Useridbuf|$name|$text|$multi|$time|$close|$hide|$editby|$threadid\n~;
    $i = 0;
    for(@variants)
    {
      $i++;
      if($_ ne "" & param("variantdel$i") ne "on" & $varianttexts{$_} ne "")
      {
        print pollfile qq~$varianttexts{$_}|$variantusers{$_}\n~;
      }

    }

    $redirectto = "$site?poll=$pollid";
    &html;
    exit;
  }

  &html;

  open (pollfile, "<polls/$pollid.txt");
  flock(pollfile, 1);
  @pull = <pollfile>;
  close pollfile;

  for(@pull)
  {
    chomp $_;
  }

  ($Useridbuf, $name, $text, $multi, $time, $close, $hide, $editby, $threadid) = split(/\|/,$pull[0]);

  $text =~ s/<br>/\n/g;

  @variants = ();
  $i = -1;
  for(@pull)
  {
    $i++;
    if($i eq 0){next}
    ($varianttext, $variantusers) = split(/\|/,$_);
    $variants[$i-1] = $i;
    $variantusers{$i} = $variantusers;
    $varianttexts{$i} = $varianttext;
  }


  if($editby eq "")
  {
    $editby = "Нет";
  }
  else
  {
    $editby = &Get_Formated_User_Name($editby);
  }

  $buf1 = "";
  $buf1 = " checked" if($multi eq "1");
  $variantscol = @variants;

  print <<FORMA;
<body onload="javascript:reloadad($variantscol);">
<center>
<b><font size=4>Добавление нового опроса</font></b><br><br>
<script type="text/javascript" src="$site/bbCode.js"></script>
<form action="$site?mode=polls&action=add" name=forma method=post>
<input type=hidden name=mode value=polls>
<input type=hidden name=action value=edit>
<input type=hidden name=finish value=1>
<input type=hidden name=pollid value=$pollid>
<table border=0 cellspacing=0 cellpadding=2>
<tr>
<td>Последняя правка:</td>
<td>$editby</td>
</tr>
<tr>
<td>Название опроса:</td>
<td><input type=text name=name size=50 value=\"$name\"></td>
</tr>
<tr>
<td colspan="2">Разрешать голосовать сразу за несколько:
<input name="multi" type="checkbox"$buf1></td>
</tr>
<td colspan="2">Текст опроса:</td>
</tr>
<tr><td colspan="2">
<textarea name=text rows=5 cols=100 class=post>$text</textarea>
</td></tr>
<tr>
<td colspan="2">Варианты опроса:
</tr>
<tr><td colspan="2">
FORMA

  $i = 0;
  for(@variants)
  {
    $i++;
    @varusers = split(/\:/,$variantusers{$i});
    $buf = @varusers;
    print "<table border=0 cellspacing=0 cellpadding=2><tr><td>$i. <td><input type=text name=variant$i size=50 maxlength=100 value=\"$varianttexts{$_}\"> $buf голос(ов/а). <input name=variantdel$i type=checkbox> Удалить </tr></table>";
  }
  $i--;
  print <<FORMA;
<input type="Hidden" name="qs" value="$i">
<div id="div"></div><br>
</tr>
<tr>
<td colspan="2" align="center">
<a style="cursor: hand;" onclick="javascript:ad();">Добавить ещё один пункт</a><br>
(Внимание! При добавлении новых пунктов в некоторых браузерах введённая информация может обнуляться.)
</tr>
<tr>
<td colspan=2 align=center><br><input type=submit style=\"background-color: $tseriy;\" value=Отправить></td>
</tr>
</table>
</form>
FORMA

}

1;
