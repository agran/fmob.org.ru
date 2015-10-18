sub html{
  &cookies_create;
  if($redirectto ne "")
  {
    print redirect(-cookie=>[$c1, $c2, $c3, $c4, $c5, $c6], -Location=>$redirectto);
    print $buf;
    exit;
  }
  else
  {
    open(attention, "<attention.txt");
    $attention = <attention>;

    close(attention);
    $attentionbuf = "";

    if($attention ne "")
    {
      $attentionbuf = "<tr><td colspan=2><table cellpadding=\"2\" cellspacing=\"1\" bgcolor=\"$cherniy\" width=\"100%\"><tr bgcolor=\"$beliy\"><td align=center>$attention</td></tr></table></td></tr>";
    }
    if($login eq 0)
    {
      $menu = "<table width=\"780\"><tr><td><b>Здравствуйте, гость</b> ( <a href=$site?mode=registration&action=login>Вход</a> | <a href=$site?mode=registration&action=reg>Регистрация</a> )</td></tr>$attentionbuf</table>";
      if($mode ne "registration" & $mode ne "main" & $mode ne "past" & $mode ne "forum" & $mode ne "mobbers" & $mode ne "gallery" & $mode ne "yahoo" & $mode ne "sendmail")
      {

        $redirectto = "$site?mode=registration&action=login";
        print redirect(-cookie=>[$c1, $c2, $c3, $c4, $c5, $c6], -Location=>$redirectto);
        print $buf;
        exit;
      }
    }
    else
    {
      $user_name_buf=&Get_Formated_User_Name($Userid, $UserName);

      $menu = "<table width=\"780\"><tr><td><b>Здравствуйте, $user_name_buf</b> ( <a href=$site?mode=registration&action=exit>Выход</a> )</td>";


      if($mode ne "private")
      {
        open (privateindex, "<privates/$Userid/index.txt");
        flock(privateindex, 1);
        @privateindex = <privateindex>;
        close privateindex;


        for(@privateindex)
        {chomp $_}


        ($typebuf, $all, $new)=split(/\|/,$privateindex[0]);


        if(($new ne 0)&($new ne ""))
        {
          $private_new = " <a href=$site?mode=private&folder=inbox>($new)</a>";
          $pupupbuf = "<body onload=\"javascript:bbc_pop('newprivate')\" onunload=\"javascript:cloce_pop('newprivate')\"><script type='text/javascript' src='$site/bbCode.js'></script>\n";
        }
        else
        {
          $private_new = " (0)"
        }
      }



      if(($usertype eq "модераторы")|($usertype eq "администраторы"))
      {

        open (USERREG_FILE, "<usersreg.txt");
        flock(USERREG_FILE, 1);
        @usersreg = <USERREG_FILE>;
        close USERREG_FILE;
        $new_reg = 0;
        for(@usersreg)
        {
          ($buf, $buf, $buf, $buf, $buf, $buf, $buf, $buf, $buf, $reyting_reg, $za_reg, $protiv_reg, $buf) = split(/\|/,$_);

          if($reyting_reg > $zapros_otkl & $reyting_reg < $zapros_podtv)
          {
            $flag = 0;
            @za_regs = split(/\:/,$za_reg);
            for(@za_regs)
            {
              if($_ eq $Userid){$flag = 1;}
            }
            @protiv_regs = split(/\:/,$protiv_reg);
            for(@protiv_regs)
            {
              if($_ eq $Userid){$flag = 1;}
            }
            if($flag eq 0)
            {
              $new_reg ++
            }
          }
        }
        if($new_reg > 0)
        {
          $buf = " ($new_reg)";
          if (param(action) ne "zaprosi")
          {
            $pupupbuf = "<body onload=\"javascript:bbc_pop('newreg')\" onunload=\"javascript:cloce_pop('newreg')\"><script type='text/javascript' src='$site/bbCode.js'></script>\n";
          }
        }
        else
        {$buf = " (0)"}


        $menu1 = "<a href=\"$site?mode=registration&action=zaprosi\" style=\"color:#BA7C0A;\" >Подтверждение регистраций$buf</a> | $menu1";
      }

      $menu = "$menu\n<td nowrap align=right width=1\%>$menu1<a href=$site?mode=rules>Правила</a> | <a href=$site?mode=private>Личные сообщения</a>$private_new | <a href=$site?mode=registration&action=edit>Мой профиль</a></td></tr>$attentionbuf</table>";


      $buf88 = &Get_User_Really($Userid);
      $User_Really_cesh{$Userid} = "";


      open (userinfobuf, "+<users/$Userid.txt");
      flock(userinfobuf, 2);
      seek (userinfobuf, 0, 0);
      @userinfobuf = <userinfobuf>;
      foreach (@userinfobuf)
      {
        chomp $_;
      }


      $userinfobuf[25] = $nowtime;
      @userinfobuf  = join("\n", @userinfobuf);


      seek (userinfobuf, 0, 0);
      print userinfobuf @userinfobuf;
      truncate(userinfobuf, tell(userinfobuf));
      close (userinfobuf);


      $buf99 = &Get_User_Really($Userid);


      if($buf88 ne $buf99)
      {
        &sort_plays_by_voice;
      }
    }


    print header(-cookie=>[$c1, $c2, $c3, $c4, $c5, $c6], -charset=>"windows-1251");



    if($mode eq "forum")
    {
      $tablebuf0 = "";
      $tablebuf1 = "</table><table width=\"780\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">";
      $tablebuf2 = "</table>";
    }
    else
    {
      $tablebuf0 = "height=\"90\%\"";
      $tablebuf1 = "<tr><td colspan=\"3\" valign=\"top\">";
      $tablebuf2 = "</td></tr></table>";
    }


    &usersonsite;


    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      $usermenu = "<a href=\"$site?mode=subscribe\" class=\"menu\" style=\"color:#BA7C0A;\" >Рассылки</a>";
    }

    if($login eq 1)
    {
      $usermenu = "<a href=\"$site\" class=\"menu\" style=\"border-left-width: 1px;\">Главная</a><a href=\"$site?mode=polls\" class=\"menu\">Опросы</a><a href=\"$site?mode=voting\" class=\"menu\">Голосование</a><a href=\"$site?mode=next\" class=\"menu\">Предстоящий моб</a><a href=\"$site?mode=past\" class=\"menu\">Прошедшие мобы</a><br><a href=\"$site?mode=gallery\" class=\"menu\" style=\"border-left-width: 1px;\">Галерея</a><a href=\"$site?mode=sms\" class=\"menu\">SMS-рассылка</a>$usermenu<a href=\"$site?mode=mobbers\" class=\"menu\">Мобберы</a><a href=\"$site?mode=yahoo\" class=\"menu\">Yahoo</a><a href=\"$site?mode=forum\" class=\"menu\">Форум</a>";

    }
    else
    {
      $usermenu = "<a href=\"$site\" class=\"menu\" style=\"border-left-width: 1px;\">Главная</a><a href=\"$site?mode=past\" class=\"menu\">Прошедшие мобы</a><a href=\"$site?mode=gallery\" class=\"menu\">Галерея</a><a href=\"$site?mode=mobbers\" class=\"menu\">Мобберы</a><a href=\"$site?mode=yahoo\" class=\"menu\">Yahoo</a><a href=\"$site?mode=forum\" class=\"menu\">Форум</a>";
    }


    print <<header;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<link rel="icon" href="favicon.ico" type="image/x-icon">
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name="KeyWords" content="FlashMob, Flash-Mob, ФлэшМоб, Флэш Моб, Краснодар, Проведение ФлэшМоба в Краснодаре">
<meta name="description" content="Официальный сайт краснодарских ФлэшМоберов. Выбор и обсуждение сценариев для ФлэшМоба.">
<link href="main.css" type="text/css" rel="stylesheet">
<title>$title</title>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bottommargin="0">

<!-- Yandex.Metrika counter -->
<div style="display:none;"><script type="text/javascript">
(function(w, c) {
    (w[c] = w[c] || []).push(function() {
        try {
            w.yaCounter11007568 = new Ya.Metrika({id:11007568, enableAll: true, webvisor:true});
        }
        catch(e) { }
    });
})(window, "yandex_metrika_callbacks");
</script></div>
<script src="//mc.yandex.ru/metrika/watch.js" type="text/javascript" defer="defer"></script>
<noscript><div><img src="//mc.yandex.ru/watch/11007568" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
<!-- /Yandex.Metrika counter -->

$pupupbuf
<div align="center">
<table width="780" $tablebuf0 cellspacing="0" cellpadding="0" border="0">
<tr>
<td valign="top" align="center" nowrap height="113" colspan="3">
 <img border="0" width="780" height="113" src="$site/$top3png"></td>
<!-- <img border="0" width="280" height="140" src="$site/$top3png"></td> -->
</tr>
<tr>
<td valign="top" align="center" colspan="3" height="1" bgcolor="$tseriy" nowrap>
$usermenu
</td>
</tr>
<tr bgcolor="$sseriy">
<td colspan="3" valign="top" height="1" width="100\%">
$menu
</td>
</tr>

$tablebuf1
header
  }
}


sub cookies_create{
  if($login eq 1)
  {
    $c1 = new CGI::Cookie(
      -name => "Userid_Hash",
      -value => $Userid_Hash,
      -expires => "+3M",
      -domain => $domen,
    );
  }
  else
  {
  }
  $c2 = new CGI::Cookie(
    -name => "LastTimeVisit$Userid",
    -value => $nowtime,
    -expires => "+3M",

    -domain => $domen,
    );


  if($LastLastTimeVisit eq "")
  {
    if($LastTimeVisit eq "")
    {
      $LastLastTimeVisit = $nowtime;
    }
    else
    {
      $LastLastTimeVisit = $LastTimeVisit;
    }
  }


  $c3 = new CGI::Cookie(
    -name => "LastLastTimeVisit$Userid",
    -value => $LastLastTimeVisit,
    -expires => "+10m",
    -domain => $domen,
    );


  $MessageCountInVisitThreadsbuf = "";
  $threadbuf1 = "";
  $MessageCountInVisitThread1 = "";
  while(($threadbuf1, $MessageCountInVisitThread1) = each(%MessageCountInVisitThreads))
  {
    $MessageCountInVisitThreadsbuf = "$MessageCountInVisitThreadsbuf$threadbuf1=$MessageCountInVisitThread1,"
  }


  $c4 = new CGI::Cookie(
    -name => "MessageCountInVisitThreads$Userid",
    -value => $MessageCountInVisitThreadsbuf,
    -expires => "+15m",
    -domain => $domen,
    );


  $PollShowbuf  = join("|", @PollShow);

  $c5 = new CGI::Cookie(
    -name => "PollShow$Userid",
    -value => $PollShowbuf,
    -expires => "+3M",
    -domain => $domen,
    );

  $c6 = new CGI::Cookie(
      -name => "GuestRandomID",
      -value => $guest_random_id,
      -expires => "+90M",
      -domain => $domen,
    );

}


sub sub_time_save{
  $subbuf = $_[0];
  if($_[1] eq 1)
  {
    $sub_time_start{$subbuf} = gettimeofday;
  }
  else
  {
    $sub_time_end{$subbuf} = gettimeofday;
    $sub_time_all{$subbuf} = $sub_time_all{$subbuf} + ($sub_time_end{$subbuf} - $sub_time_start{$subbuf});
  }
}


sub htmlend{

print <<end1;

</center>$tablebuf2
<table border="0" height=10% width="780" cellspacing=0 cellpadding=0>
<tr valign="bottom">
<td colspan="4">
<img border="0" src="$site/$verhpng" width="780" height="11"></td>
</tr>
<tr height="31">
<td width="302" valign=top>
<img border="0" src="$site/$levopng" width="302" height="31"></td>
<td nowrap width="88" height="31" bgcolor="#000000">

</td>
<td nowrap width="88" height="31" bgcolor="#000000">

</td>
<td width="302" height="31">
<img border="0" src="$site/$pravopng" width="302" height="31" useMap="#buttons2">
<map name="buttons2">
<area shape="rect" coords="187,3,269,20" href="$site?showuser=1">
</map>
</td>
</tr>
</table>
</body>
</html>
end1
}


sub dni
{
  $buf3="";
  $buf2=substr($_[0],-1);
  if(substr($_[0],-2,1) eq "1")
  {$buf3="дней";}
  elsif($buf2 eq "1")
  {$buf3="день";}
  elsif($buf2>1&$buf2<5)
  {$buf3="дня";}
  elsif($buf2>4|$buf2 eq 0)
  {$buf3="дней";}
  return $buf3;
}


sub moberstext
{
  $buf3="";
  $buf2=substr($_[0],-1);
  if(substr($_[0],-2,1) eq "1")
  {$buf3="мобберов";}
  elsif($buf2 eq "1")
  {$buf3="моббер";}
  elsif($buf2>1&$buf2<5)
  {$buf3="моббера";}
  elsif($buf2>4|$buf2 eq 0)
  {$buf3="мобберов";}
  return $buf3;
}


sub playstext
{
  $buf3="";
  $buf2=substr($_[0],-1);
  if(substr($_[0],-2,1) eq "1")
  {$buf3="добавлено $_[0] новых сценариев";}
  elsif($buf2 eq "1")
  {$buf3="добавлен $_[0] новый сценарий";}
  elsif($buf2>1&$buf2<5)
  {$buf3="добавлено $_[0] новых сценария";}
  elsif($buf2>4|$buf2 eq 0)
  {$buf3="добавлено $_[0] новых сценариев";}
  return $buf3;
}


sub raznica
{
  if($_[0] eq ""&$_[1] ne ""){return -1}
  if($_[0] ne ""&$_[1] eq ""){return 1}


 ($dd, $mm, $yyyy) = ($_[0] =~ /(\d+)\.(\d+)\.(\d+)/);
 if($mm < 3)
 {
   $mm+=12;
   $yyyy--;
 }


 $JD1 = int($yyyy*365.25) + int($mm*30.6 + 0.7) + $dd;


 ($dd, $mm, $yyyy) = ($_[1] =~ /(\d+)\.(\d+)\.(\d+)/);
 if($mm < 3)
 {
   $mm+=12;
   $yyyy--;
 }
 $JD2 = int($yyyy*365.25) + int($mm*30.6 + 0.7) + $dd;


  return ($JD2-$JD1);
}


sub raznicayears
{
  ($dd1, $mm1, $yyyy1) = ($_[0] =~ /(\d+)\.(\d+)\.(\d+)/);
  if($mm1 < 3)
  {
    $mm1+=12;
    $yyyy1--;
  }

  $JD1 = int($mm1*30.6 + 0.7) + $dd1 - 1;

  ($dd2, $mm2, $yyyy2) = ($_[1] =~ /(\d+)\.(\d+)\.(\d+)/);
  if($mm2 < 3)
  {
    $mm2+=12;
    $yyyy2--;
  }

  $JD2 = int($mm2*30.6 + 0.7) + $dd2;


  if($JD2 > $JD1)
  {
    return ($yyyy2 - $yyyy1);
  }
  else
  {
    return ($yyyy2 - $yyyy1 - 1);
  }
}


sub raznica2
{

 ($hour1, $min1, $dey1, $mday1, $year1) = ($_[0] =~ /.. (\d+):(\d+) \- (\d+)\.(\d+)\.(\d+)/);


 $year1 = $year1 - 2000;


 if($mday1 < 3)
 {
   $mday1+=12;
   $year1--;
 }


 $JD1 = &round1($year1*365.25)*1440 + &round1($mday1*30.6 + 0.7)*1440 + $dey1*1440 + $hour1*60 + $min1;


 ($hour1, $min1, $dey1, $mday1, $year1) = ($_[1] =~ /.. (\d+):(\d+) \- (\d+)\.(\d+)\.(\d+)/);


 $year1 = $year1 - 2000;


 if($mday1 < 3)
 {
   $mday1+=12;
   $year1--;
 }
 $JD2 = &round1($year1*365.25)*1440 + &round1($mday1*30.6 + 0.7)*1440 + $dey1*1440 + $hour1*60 + $min1;


 return $JD2-$JD1;
}


sub round1{
  $l1 = $_[0];
  $l2 = int($_[0]);



  if($l1 >= $l2+0.5)
  {
    $l1 = $l2 + 1;
  }
  else
  {
    $l1 = $l2;
  }
  return $l1;
}


sub getwday{

  ($dd, $mm, $yy) = ($_[0] =~ /(\d+)\.(\d+)\.(\d+)/);
  my($tmp, $a, $b, $c, $e);
  my @years = (0, 2, 3, 4);
  my @month = (undef, 0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5);

  $dd =~ s/^0//;
  $mm =~ s/^0//;
  my($tmp, $a, $b, $c, $e);
  $tmp = $yy - 1996;
  $a = $tmp & 3;
  $b = ($tmp >> 2) + ($tmp & hex("FC"));
  $c = $month[$mm];

  if($a == 0 && $mm > 2){$c++;}
  $a = $years[$a];
  $e = ($a+$b+$c+$dd) % 7;

  if($_[1] eq 1)
  {return "$days[$e]";}
  else
  {return "$days_exp[$e]";}
}

sub round2 {
  return sprintf "%.0f", $_[0];
}


sub raznicadeys
{
  return int(&raznica2($_[0],$_[1])/1440)+1;
}


sub playnotfint{
  print "<br><br><center><b>Не найден сценарий.</b></center>";
  &htmlend;
  exit;
}


sub netdostupa{
  print "<br><br><center><b>У вас нет прав для выполнения данной функции.</b><br>";
  print "<a href=\"javascript:history.back();\">Вернуться назад...</a></center>";
  &htmlend;
  exit;
}


sub textinput{
    print <<textinput1;
<td colspan=4 nowrap>
<a href="javascript:bbstyle('', '')">Закрыть теги</a> &nbsp;
<a href="javascript:bbc_pop('taghelp')">Помощь по тегам</a>
<br>
<input type="button" style="font-weight: bold; width: 30px; background-color: $tseriy;" name="addcodeb" value=" b "  onClick="bbstyle('b', '')"/>
<input type="button" style="font-style: italic; width: 30px; background-color: $tseriy;" name="addcodei" value=" i "  onClick="bbstyle('i', '')"/>
<input type="button" style="text-decoration: underline; background-color: $tseriy; width: 30px;" name="addcodeu" value=" u "  onClick="bbstyle('u', '')"/>
<input type="button" style="text-decoration: line-through; width: 30px; background-color: $tseriy;" name="addcodes" value=" s "  onClick="bbstyle('s', '')"/>
<input type="button" style="width: 40px; background-color: $tseriy;" name="addcodeimg" value="Img" onClick="bbstyle('img', '')"/>
<input type="button" style="width: 50px; background-color: $tseriy;" name="addcodequote" value="Quote" onClick="bbstyle('quote', '')"/>
<select name="addcodefont" class="codebuttons" onchange="bbstyle('font', this.options[this.selectedIndex].value)">
<option value="0">ШРИФТ</option>
<option value="Arial" style="font-family: Arial">Arial</option>
<option value="Times" style="font-family: Times">Times</option>
<option value="Courier" style="font-family: Courier">Courier</option>
<option value="Impact" style="font-family: Impact">Impact</option>
</select>
<select name='addcodesize' class='codebuttons' onchange="bbstyle('size', this.options[this.selectedIndex].value)">
<option value='0'>РАЗМЕР</option>
<option value='1'>Малый</option>
<option value='5'>Большой</option>
<option value='7'>Огромный</option>
</select>
<select name="addcodecolor" class="codebuttons" onchange="bbstyle('color', this.options[this.selectedIndex].value)">
<option value=0>ЦВЕТ</option>
<option value=red style='color:red'>Красный</option>
<option value=orange style='color:orange'>Оранжевый</option>
<option value=yellow style='color:yellow'>Жёлтый</option>
<option value=green style='color:green'>Зелёный</option>
<option value=blue style='color:blue'>Синий</option>
<option value=purple style='color:purple'>Фиолетовый</option>
<option value=gray style='color:gray'>Серый</option>
</select>
</td>
</tr>
<tr>
<td colspan=5 valign=top align=center>
<textarea name=message rows=10 cols=100 class="post" onselect="storeCaret(this);" onclick="storeCaret(this);" onkeyup="storeCaret(this);">$message</textarea></td>
</tr>
<tr>
<td colspan=5 align=center>
</td>
</tr>
<tr>
<td colspan=5 align=center>
<script language="javascript1.2" type="text/javascript">
<!--
function emo_pop()
{
  window.open('?mode=smiles','Legends','width=300,height=500,resizable=yes,scrollbars=yes');
}
        //-->
</script>
textinput1


for($j=0;$j<=18;$j++)
{
  print "<a href=\"javascript:add_smilie('$smiles[$j][0]')\"><img src=\"$site/image\/$smiles[$j][1]\" width=$smiles[$j][2] height=$smiles[$j][3] alt=\"$smiles[$j][4]\" border=0></a>\n";
}
print "<a href=\"javascript:emo_pop()\">Ещё...</a>\n";


print "</td></tr>";


}


sub Get_User_Name_by_id {
  my $namebuf;
  if($User_Name_cesh{$_[0]} ne "")
  {
    $namebuf = $User_Name_cesh{$_[0]};
  }
  else
  {
    open (userinfo, "<users/$_[0].txt");
    flock(userinfo, 1);
    @userinfo = <userinfo>;
    close userinfo;
    chomp $userinfo[0];
    $namebuf = $userinfo[0];
    $User_Name_cesh{$_[0]} = $namebuf;
  }
  return $namebuf;
}


sub Get_Formated_User_Name {
  my $user_name_buf1;
  if($_[1] eq "")
  {$user_name_buf1=&Get_User_Name_by_id($_[0]);}
  else
  {$user_name_buf1=$_[1];}
  if($_[2] ne "")
  {$classbuf=" class=$_[2]"}
  else
  {$classbuf=""}

 $user_name_buf1="<a href=\"?showuser=$_[0]\"><img src=\"http://stat.livejournal.com/img/userinfo.gif\" style=\"border: 0pt none ; vertical-align: bottom;\" height=17 width=17></a><a href=\"?showuser=$_[0]\"$classbuf>$user_name_buf1</a>";
#$user_name_buf1="<a href=\"?showuser=$_[0]\"><img src=\"http://stat.livejournal.com/img/userinfo.gif\" style=\"border: 0pt none ; vertical-align: bottom;\" height=17 width=17></a><a href=\"?showuser=$_[0]\"$classbuf>Мед</a>";

  return $user_name_buf1;
}


sub Inc_Col_Mes {
  Inc_Col(10);
}


sub Inc_Col_Play {
  Inc_Col(11);
}


sub Inc_Col {
  $linebuf = $_[0];
  open (userfile, "+<users/$Userid.txt");
  flock(userfile, 2);
  seek (userfile, 0, 0);
  @userinfo = <userfile>;
  chomp $userinfo[$linebuf];
  $userinfo[$linebuf]++;
  $userinfo[$linebuf] = "$userinfo[$linebuf]\n";
  seek (userfile, 0, 0);

  print userfile @userinfo;
  truncate(userfile, tell(userfile));
  close (userfile);
}


sub Inc_Voice_Col {
  my $old_voice = $_[0];
  my $new_voice = $_[1];


  if($old_voice eq "")
  {$LineOldBuf = ""}
  elsif($old_voice > -3 & $old_voice < 3)
  {$LineOldBuf = 22 + $old_voice}


  if($new_voice eq "")
  {$LineNewBuf = ""}
  elsif($new_voice > -3 & $new_voice < 3)
  {$LineNewBuf = 22 + $new_voice}


  $linebuf = $_[0];
  open (userfile, "+<users/$Userid.txt");
  flock(userfile, 2);
  seek (userfile, 0, 0);
  @userinfo = <userfile>;


  if($LineOldBuf ne "")
  {
    chomp $userinfo[$LineOldBuf];
    if($userinfo[$LineOldBuf] eq "")
    {$userinfo[$LineOldBuf] = 0}
    $userinfo[$LineOldBuf]--;
    $userinfo[$LineOldBuf] = "$userinfo[$LineOldBuf]\n";
  }


  if($LineNewBuf ne "")
  {
    chomp $userinfo[$LineNewBuf];
    if($userinfo[$LineNewBuf] eq "")
    {$userinfo[$LineNewBuf] = 0}
    $userinfo[$LineNewBuf]++;
    $userinfo[$LineNewBuf] = "$userinfo[$LineNewBuf]\n";
  }


  seek (userfile, 0, 0);
  print userfile @userinfo;
  truncate(userfile, tell(userfile));
  close (userfile);
}


sub readparam {
  my $parambuf = param($_[0]);
  $parambuf =~ s/</&lt;/gi;
  $parambuf =~ s/>/&gt;/gi;
  $parambuf =~ s/\|/&#124;/gi;
  return $parambuf;
}


sub buildpegelist{
  $colmessbuf = $_[0];
  $pagebuf = $_[1];
  $messonpagebuf = $_[2];
  $buf1=$_[3];
  $buf2=$_[5];
  $all1 = int(($colmessbuf-1) / $messonpagebuf)+1;
  if($_[4] eq "")
  {$buf = "Страницы ($all1): ";}
  else


  {$buf = "";}
  for($i=1;$i <= $all1;$i++)
  {
    $to=$i;


    if( $pagebuf ne $i)
    {$buf = "$buf<a href=$buf1$to$buf2>$i</a> ";}
    else
    {$buf = "$buf<b>[$i]</b> ";}
  }
  return $buf;
}


sub usersonsite {
  if(($ENV{HTTP_USER_AGENT} =~ /Yandex/i |
     $ENV{HTTP_USER_AGENT} =~ /Googlebot/i |
     $ENV{HTTP_USER_AGENT} =~ /Slurp/i |
     $ENV{HTTP_USER_AGENT} =~ /WebCrawler/i |
     $ENV{HTTP_USER_AGENT} =~ /ZyBorg/i |
     $ENV{HTTP_USER_AGENT} =~ /google/i |
     $ENV{HTTP_USER_AGENT} =~ /scooter/i |
     $ENV{HTTP_USER_AGENT} =~ /stack/i |
     $ENV{HTTP_USER_AGENT} =~ /aport/i |
     $ENV{HTTP_USER_AGENT} =~ /lycos/i |
     $ENV{HTTP_USER_AGENT} =~ /fast/i |
     $ENV{HTTP_USER_AGENT} =~ /rambler/i |
     $ENV{HTTP_USER_AGENT} =~ /FAST-WebCrawler/i |
     $ENV{HTTP_USER_AGENT} =~ /Gigabot/i |
     $ENV{HTTP_USER_AGENT} =~ /Scrubby/i |
     $ENV{HTTP_USER_AGENT} =~ /inktomi.com/i |
     $ENV{HTTP_USER_AGENT} =~ /ZyBorg/i |
     $ENV{HTTP_USER_AGENT} =~ /archive_org/i |
     $ENV{HTTP_USER_AGENT} =~ /Yahoo/i))
  {
    $poiskovik = 1;
  }
  else
  {
    $poiskovik = 0;
  }
  if($poiskovik eq 0)
  {
    $exit = $_[0];
    open(USERSONSITEFILE, "+<usersonsite.txt") || open(USERSONSITEFILE, ">usersonsite.txt");
    flock(USERSONSITEFILE, 2);
    seek USERSONSITEFILE, 0, 0;
    my @usersonsitelist = <USERSONSITEFILE>;
    truncate USERSONSITEFILE, 0;
    seek USERSONSITEFILE, 0, 0;
    foreach (@usersonsitelist)
    {
      chomp $_;
      ($useridbuf, $plasebuf, $timebuf) = split(/\|/,$_);
      $usersonsiteplase{$useridbuf} = $plasebuf;
      $usersonsitetime{$useridbuf} = $timebuf;
    }
    if($login eq 1)
    {
      $usersonsiteplase{$Userid} = $ENV{QUERY_STRING};
      $usersonsitetime{$Userid} = $nowtime;
    }
    else
    {
      $usersonsiteplase{$guest_random_id} = $ENV{QUERY_STRING};
      $usersonsitetime{$guest_random_id} = $nowtime;
    }


    if($exit ne "")
    {
      delete($usersonsiteplase{$exit});
      delete($usersonsitetime{$exit});
    }


    foreach $useridbuf ( keys %usersonsitetime )
    {
      $plasebuf = $usersonsiteplase{$useridbuf};

      $timebuf = $usersonsitetime{$useridbuf};
      if(&raznica2($timebuf, $nowtime) <= 10 & $exit ne $useridbuf)
      {
        print USERSONSITEFILE "$useridbuf|$plasebuf|$timebuf\n"
      }
      else
      {
        delete($usersonsiteplase{$useridbuf});
        delete($usersonsitetime{$useridbuf});
      }
    }

#  if($login eq 1)
#  {
#  if(!($ENV{QUERY_STRING} =~ m/password=/))
#  {
#    mkdir("logs");
#    mkdir("logs/$year");
#    mkdir("logs/$year/$mon");
#    mkdir("logs/$year/$mon/$mday");
#    open(logfile, ">>logs/$year/$mon/$mday/logs.txt");
#    flock(logfile, 2);
#    print logfile qq~$Userid|$nowtime|$ENV{REMOTE_ADDR}|$ENV{QUERY_STRING}\n~;
#    close(logfile);
#  }
#  }

    close(USERSONSITEFILE);
  }
}


sub ruleshelp{
  $title="FlashMob в Краснодаре - Правила сайта";
  &html;
  if($action eq "edit" & param(finish) eq 1)
  {
    if(!(($usertype eq "модераторы")|($usertype eq "администраторы")))
    {
      &netdostupa;
    }


    $rules = param(message);
    open(rulesfile, ">rules.txt");
    flock(rulesfile, 2);
    print rulesfile $rules;
    print rulesfile "\nВерсия от $nowtime. Последние изменения: \[url=$site?showuser=$Userid\]$UserName\[/url\]";
    close(rulesfile);
  }


  open(rulesfile, "<rules.txt");
  flock(rulesfile, 1);
  @rulesmas = <rulesfile>;
  close(rulesfile);
  print "<table border=0 cellpadding=4 width=100%><tr bgcolor=$tseriy align=center><td><font size=3><b>Правила сайта fmob.org.ru</b></td></tr><tr bgcolor=$sseriy><td>";


  if($action eq "edit" & param(finish) ne 1)
  {
    $rulesmas[$rulesmas-1]="";
    $rules = join("", @rulesmas);
    substr($rules,-1)="";
    print "<form method=POST name=post action=$site?mode=rules>";
    print "<input type=hidden name=action value=edit>";
    print "<input type=hidden name=mode value=rules>";
    print "<input type=hidden name=finish value=1>";
    print "<center><textarea name=message rows=20 cols=130>$rules</textarea></center>";
    print "<br><input type=submit style=\"background-color: $tseriy;\" value=Сохранить></form>";
  }
  else
  {
    $rules = join("", @rulesmas);
    $rules = &text_process($rules);
    if(($usertype eq "модераторы")|($usertype eq "администраторы"))
    {
      print "<center><b><font size=\"1\">";
      print "[<a href=$site?mode=rules&action=edit class=\"adm\">Редактировать</a>]";
      print "</font></b></center>";
    }
    print $rules;
  }
  print "</tr></td></table>";
  &htmlend;
  exit;
}


sub get_image_info {
    my ($file) = @_ ;
    my ($img_width, $img_height, $img_type, $img_size) = ();


    open(IMGDIR, "$file") || die "Can't open graphic $file $!";
    binmode(IMGDIR); # necessary for non UNIX perl


    if ($file =~ /\.gif$/i) {
        ($img_width, $img_height, $img_type) = &gifSize(IMGDIR);
    } elsif ($file =~ /\.jpg$|.jpeg$/i) {
        ($img_width, $img_height, $img_type) = &jpegSize(IMGDIR);
    }


    $img_size = -s IMGDIR;


    close (IMGDIR);
    return ($img_width, $img_height, $img_type, $img_size);
}


sub gifSize {
    my ($GIF) = @_;
    my ($width, $height, $imgwidth, $imgwidth2, $imgheight, $imgheight2,
        $gifwidth, $gifsize) = () ;


    read ($GIF, $img_type, 3);
    seek ($GIF, 6, 0);
    read ($GIF, $imgwidth, 1);
    read ($GIF, $imgwidth2, 1);
    read ($GIF, $imgheight, 1);
    read ($GIF, $imgheight2, 1);


    $img_width = ord ($imgwidth) + ord ($imgwidth2) * 256;
    $img_height = ord ($imgheight) + ord ($imgheight2) * 256;
    return ($img_width, $img_height, $img_type);
}


sub jpegSize {
  my ($JPEG) = @_;
  my ($done) = 0;
  my ($size) = "";


  read($JPEG, $c1, 1); read($JPEG, $c2, 1);
  if( !((ord($c1) == 0xFF) && (ord($c2) == 0xD8))){
    print "This is not a JPEG!";
    $done=1;
  }

  while (ord($ch) != 0xDA && !$done) {
    # Find next marker (JPEG markers begin with 0xFF)
    # This can hang the program!!
    while (ord($ch) != 0xFF) { read($JPEG, $ch, 1); }
    # JPEG markers can be padded with unlimited 0xFF's
    while (ord($ch) == 0xFF) { read($JPEG, $ch, 1); }
    # Now, $ch contains the value of the marker.
    if ((ord($ch) >= 0xC0) && (ord($ch) <= 0xC3)) {
      read ($JPEG, $junk, 3); read($JPEG, $s, 4);
      ($a,$b,$c,$d)=unpack("C"x4,$s);
      $size=join("", 'HEIGHT=',$a<<8|$b,' WIDTH=',$c<<8|$d );
      $done=2;
    } else {
      # We **MUST** skip variables, since FF's within variable names are
      # NOT valid JPEG markers
      read ($JPEG, $s, 2);
      ($c1, $c2) = unpack("C"x2,$s);
      $length = $c1<<8|$c2;
      if( ($length < 2) ){
        print "Erroneous JPEG marker length";
        $done=1;
      } else {
        read($JPEG, $junk, $length-2);
      }
    }
  }
  if ($done > 1) {
    $img_type = "JPEG";
  }
  return ($c<<8 |$d, $a<<8|$b, $img_type);
}

sub Get_User_Really {
  my $User_Really_buf = 0;
  if($User_Really_cesh{$_[0]} ne "")
  {
    $User_Really_buf = $User_Really_cesh{$_[0]};
  }
  else
  {
    open (userinfo, "<users/$_[0].txt");
    flock(userinfo, 1);
    @userinfo = <userinfo>;
    close userinfo;
    chomp $userinfo[12];
    chomp $userinfo[25];
    if($userinfo[25] eq "")
    {$userinfo[25] = "Чт 23:28 - 04.05.2000"}


    if(substr($userinfo[8],0,19) ne "<b><font color=red>")

    {
      if((&raznica2($userinfo[25], $nowtime) < 14*60*24)&(&raznica2($userinfo[12], $nowtime) > 0*60*24))
      {
        $User_Really_buf = 1;
      }
    }
    $User_Really_cesh{$_[0]} = $User_Really_buf;
  }
  return $User_Really_buf;
}

1;