sub kisses_show{

  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  open (kissestxt, "<kisses.txt");
  flock(kissestxt, 1);
  @kisses = <kissestxt>;
  close kissestxt;

  foreach (@kisses)
  {chomp $_}

  @kisses_za = split(/\:/,$kisses[$Userid-1]);

  $kisses_buf = "";
  foreach $a (@kisses_za)
  {
    $flag = 0;
    @kisses_za2 = split(/\:/,$kisses[$a-1]);
    foreach $b (@kisses_za2)
    {
      if ($b eq $Userid){$flag = 1}
    }
    if($flag eq 1)
    {
      $kisses_buf = "$kisses_buf, ".&Get_Formated_User_Name($a);
    }
  }
  substr($kisses_buf, 0, 2) = "";

  if($kisses_buf eq ""){$kisses_buf = "Никто";}

  print <<FORMA;
<center><h1>Подбор партнёра для моба Поцелуи</h1>
Просьба помнить, что это всего лишь моб и ничего более.<br>
О вашем выборе никто не узнает до тех пор, пока вам не ответят взаимностью.<br><br>
<b>Вам ответили взаимностью:</b> $kisses_buf<br><br>
Пожалуйста, отметьте галочками мобберов с которыми вы хотели бы участвовать в мобе Поцелуи.<br><br></center>
<form action=$site?mode=kisses method=POST name="main">
<input type=hidden name=mode value=kisses>
<table cellspacing='2' cellpadding='4' width='100%'>
<tr bgcolor=$tseriy>
<td width='5%' align='center' valign='middle'></td>
<td width='1%' align='center' valign='middle'><b>ID</b></td>
<td width='70%' align='center' valign='middle'><b>Ник</b></td>
<td width='10%' align='center' valign='middle'><b>Фото</b></td>
</tr>
FORMA

  $i=0;
  foreach (@users)
  {
    $i++;
    if(substr($_, 0, 1) eq ";"){next}
    chomp $_;

    open (userinfo, "<users/$i.txt");
    flock(userinfo, 1);
    @userinfo1 = <userinfo>;
    close userinfo;

    chomp $userinfo1[6];

    if (($userinfo1[6] eq $user_sex)&($userinfo1[6] ne "")){next}

    chomp $userinfo1[25];
    chomp $userinfo1[12];
    chomp $userinfo1[28];

    print "<tr bgcolor=$sseriy>";

    $buf = "";
    for(@kisses_za)
    {
      if($i eq $_)
      {
        $buf = " checked";
        last;
      }
      else
      {
        $buf = ""
      }
    }

    print "<td align='center'><input type=checkbox name=$i$buf>";
    print "<td>$i";

    if(((&raznica2($userinfo1[25], $nowtime) < 14*60*24)&(&raznica2($userinfo1[12], $nowtime) > 14*60*24)))
    {
      print "<td><a href=?showuser=$i>$_";
    }
    else
    {
      print "<td><a href=?showuser=$i class=s>$_";
    }
    if($userinfo1[28] ne "")
    {
      print "<td><a href=?showuser=$i>Посмотреть";
    }
    else
    {
      print "<td>";
    }

  }
  print "</table>";
  print "<tr><td colspan=4><input type=submit style=\"background-color: $tseriy;\" name=action2 value=Отправить>";
  print "</form>";
}

sub kisses_finish{
  open (kissestxt, "<kisses.txt");
  flock(kissestxt, 1);
  @kisses = <kissestxt>;
  close kissestxt;

  foreach (@kisses)
  {chomp $_}

  @users = ();
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  $kisses_buf = "";
  $i = 0;
  foreach (@users)
  {
    $i++;
    if(param($i) eq "on")
    {
      $kisses_buf = "$kisses_buf:$i"
    }
  }

  substr($kisses_buf, 0, 1) = "";

  $kisses[$Userid-1] = "$kisses_buf";

  @kisses = join("\n", @kisses);

  open (KISSESBUF,">kisses_buf.txt");
  flock(KISSESBUF, 2);
  print KISSESBUF @kisses;
  close(KISSESBUF);

  rename("kisses.txt", "kisses_old.txt");
  rename("kisses_buf.txt", "kisses.txt");

  print "<center><b>Запрос обработан.</b><br>";
  print "<a href=$site?mode=kisses>Вернуться.</a>";

}

sub kisses_show_list{

  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  open (kissestxt, "<kisses.txt");
  flock(kissestxt, 1);
  @kisses = <kissestxt>;
  close kissestxt;



  foreach (@kisses)
  {chomp $_}

  $kisses_reyting = ();
  foreach $c (@kisses)
  {
    @kisses_za = split(/\:/,$c);
    foreach $a (@kisses_za)
    {
      $kisses_reyting{$a}++;
    }
  }
    
  print <<FORMA;
<center><h1>Подбор партнёра для моба Поцелуи</h1>
<form action=$site?mode=kisses method=POST name="main">
<input type=hidden name=mode value=kisses>
<table cellspacing='2' cellpadding='4' width='100%'>
<tr bgcolor=$tseriy>
<td width='5%' align='center' valign='middle'><b>ID</td>
<td width='15%' align='center' valign='middle'><b>Ник</td>
<td width='10%' align='center' valign='middle'><b>Их выбрали</td>
<td width='70%' align='center' valign='middle'><b>Кого выбрал</td>
</tr>
FORMA

  $i=0;
  foreach (@users)
  {
    $i++;
    if(substr($_, 0, 1) eq ";"){next}
    chomp $_;


    open (userinfo, "<users/$i.txt");
    flock(userinfo, 1);
    @userinfo1 = <userinfo>;
    close userinfo;

    chomp $userinfo1[25];
    chomp $userinfo1[12];

    print "<tr bgcolor=$sseriy>";

    $buf = "";

    print "<td>$i";

    if(((&raznica2($userinfo1[25], $nowtime) < 14*60*24)&(&raznica2($userinfo1[12], $nowtime) > 14*60*24)))
    {
      print "<td><a href=?showuser=$i>$_</a>";
    }
    else
    {
      print "<td><a href=?showuser=$i class=s>$_</a>";
    }

    print "<td align='center'>$kisses_reyting{$i}";


    @kisses_za = split(/\:/,$kisses[$i-1]);
    $kisses_buf = "";
    foreach (@kisses_za)
    {
      $kisses_buf = "$kisses_buf, ".&Get_Formated_User_Name($_);
    }
    substr($kisses_buf, 0, 2) = "";
    print "<td>$kisses_buf";
  }
  print "</table>";
}

1;
