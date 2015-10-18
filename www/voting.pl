use locale;
use POSIX qw(locale_h);

sub addplay{
  $playbuf=$play;
  $j=-1;

  if(param(predv)eq "��������������� ��������")
  {
    $playname=param(playname);
    $message=param(message);
    $playname =~ s/"/&quot;/gi;
    $messagebuf = &text_process($message);
    $predvtext ="<table border=0 width=100% cellpadding=4>
<tr><td colspan=2 bgcolor=$tseriy>
<b>��������������� ��������:</b>
</td></tr>
<tr><td colspan=2 bgcolor=$sseriy>
$messagebuf
</td><tr>
</table>";
    $buf2="";
  }
  else
  {$predvtext ="";}
  if($action eq "edit")
  {
    $buf2="<center>��� �������������� �������� ��������� �����:</center>";
    $buf3="editplayfinish";

    $tempfile="plays/$playbuf.txt";
    if (not -e $tempfile)
    {&playnotfint}

    open(playinfo, "<plays/$playbuf.txt");
    flock(playinfo, 1);
    @playinfo=<playinfo>;
    close (playinfo);
    foreach (@playinfo)
    {chomp $_}

    if($playinfo[0] ne 1){&playnotfint}

    if($playinfo[17] ne "")
    {
      $buf10 = $playinfo[17];
      $buf10 = &Get_Formated_User_Name($buf10);
      $buf10 = "<tr>
<td colspan=5>��������� ��������� ������: $buf10 [$playinfo[4]]</td>
</tr>";
    }
    else
    {
      $buf10 = "";
    }


    $Useridbuf=$playinfo[3];
    if($predvtext eq "")
    {
      $playname=$playinfo[5];
      $message=$playinfo[6];
    }

    if(($Useridbuf ne $Userid)&($usertype ne "����������")&($usertype ne "��������������"))
    {&netdostupa}

    $message =~ s/<br>/\n/gi;
    $buf5="readonly ";
    $playname =~ s/"/&quot;/gi;
    $postto="$site?action=edit&play=$playbuf";
  }
  if($action eq "add")
  {
    for($j=0;$j<@indexofplay;$j++)
    {
     if ($indexofplay[$j]>$playbuf)
     {$playbuf=$indexofplay[$j]}
    }
    $playbuf++;
    if($predvtext eq "")
    {
      $buf2="
<tr><td colspan=4 align=center>
<table border=0 cellspacing=0 cellpadding=2>
<tr><td>
<center><h2>��������!</h2></center>
����� ��� ��� ��������� ��������, �������, �� �������� �� �� <a href=\"javascript:ShowHide('rules_open','rules_closed')\">������ Flash Mob'�</a><br>
<div id=rules_open style=\"display: none; z-index: 2;\"><br>
<b>1.</b> Flash Mob �� ������ ������ ������������, ����������� ��� ������������ ��������.<br>
<b>2.</b> ������������ ���������� ��� ����� ������� �����.<br>Flash Mob �� ������ ��������� ���� � ���������� �� ����������, �� ����������.<br>
<b>3.</b> ��������� �� ����������� �� ������ �������� � ������ Flash Mob.<br>
<b>4.</b> Flash Mob ������ ���������� � ������������� ��������� ��������.<br>
</div><br>
</td></tr>
</table>
</td></tr>";
    }
    $buf3="addplayfinish";
    $name="";
    $buf5="";
    $buf10="";
    $postto="$site?action=add";
  }

    print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<br>
$predvtext
<table border=0 cellspacing=0 cellpadding=1 width=\"100\%\">
$buf2
<center><td align=center>
<table border=0 cellspacing=0 cellpadding=2>
<form method=POST name=post action=$postto>
<input type=hidden name=action value=$buf3>
<input type=hidden name=mode value=voting>
<input type=hidden name=play value="$playbuf">
$buf10
<tr>
<td colspan=1>��������: </td>
<td colspan=4><input type=text size=80 name=playname value="$playname" tabindex="4"></td>
</tr>
<tr>
<td valign=bottom colspan=1>��������:</td>
FORMA

&textinput;

print <<FORMA;
<tr>
    <td align=center><input type=submit style=\"background-color: $tseriy;\" value=��������� tabindex="4"></td>
    <td align=right><input type=submit style=\"background-color: $tseriy;\" name="predv" value="��������������� ��������" tabindex="5"></td>
</tr>
</tr>
</form></table>
</td></table>
</center>
</center>
FORMA

}

sub addplayfinish{
  $message = param(message);
  $playname = readparam(playname);

  if ($playname eq ""|$message eq "")
  {&error11;}

  if(param(predv)eq "��������������� ��������")
  {
    $title="������� � ���������� - ���������� ������ ��������";

    &html;
    $action="add";
    &addplay;
    &htmlend;
    exit;
  }
  $message =~ s/\n/<br>/g;
  $playname =~ s/&quot;/"/g;

  open(maxindex, "<plays/maxindex.txt");
  flock(maxindex, 1);
  $num=<maxindex>;
  close (maxindex);
  if($num eq ""){$num=0;}
  $num++;
  $ujebilo=0;
  for($j=1;$j<$num;$j++)
  {
    open(votings, "<plays/$j.txt");
    flock(votings, 1);
    @buf=<votings>;
    close (votings);
    chomp $buf[5];
    if($buf[5] eq $playname)
    {
      $ujebilo=1;
      last
    }
  }
  if($ujebilo ne 1)
  {
    $num=0;
    open(maxindex, "+<plays/maxindex.txt");
    flock(maxindex, 2);
    seek maxindex, 0, 0;
    $num=<maxindex>;
    truncate maxindex, 0;
    seek maxindex, 0, 0;
    $num++;
    print maxindex $num;
    close (maxindex);

    $subjectbuf = $playname;
    $commentbuf = "$num";
    $messagebuf = " ";
    $board = 3;
    $typebuf = "2";

    &addthread;

    &lastthread_update($newthreadid, $subjectbuf, $nowtime, $Userid, $board, 0);

    @newplayinfo = ();

    $newplayinfo[0] = "1";
    $newplayinfo[1] = $nowtime;
    $newplayinfo[3] = $Userid;
    $newplayinfo[4] = $nowtime;
    $newplayinfo[5] = $playname;
    $newplayinfo[6] = $message;
    $newplayinfo[9] = $newthreadid;
    $newplayinfo[17] = $Userid;

    @newplayinfo  = join("\n", @newplayinfo);

    open(fnewplayinfo, ">plays/$num.txt");
    flock(fnewplayinfo, 2);
    print fnewplayinfo @newplayinfo;
    close (fnewplayinfo);

    open(votings, ">>plays/plays.txt");
    flock(votings, 2);
    print votings "$num|1|$Userid|$nowtime\n";
    close (votings);

    $textbuf="\[url=$site?play=$num\]\[size=5\]$playname\[/size\]\[/url\]\[br\]\[b\]�����:\[/b\] \[url=$site?showuser=$Userid\]$Username\[/url\]\[br\]\[b\]��������:\[/b\]\[br\]$message\[br\]\[br\]\[url=$site?play=$num\]������� � �����������\[/url\]\[br\]\[url=$site?mode=forum&thread=$newthreadid\]������� �� �������� ����������\[/url\]\[br\]\[url=$site\]������� �� ������� �������� �����\[/url\]";

    ($buf,$to2)=&get_subscribe_mails(2);

    &send_subscribe($textbuf, "FMob: �������� ����� �������� \"$playname\"", "", "", $to2);
    &Inc_Col_Play;
    &lastplay_update($num, $playname, $Userid, $nowtime);
    $redirectto="$site?mode=voting&play=$num#$num";
  }
  &html;
}

sub editplayfinish {
  $message=param(message);
  $playname=readparam(playname);

  if ($playname eq ""|$message eq "")
  {&error11;}

  if(param(predv)eq "��������������� ��������")
  {
    $playname =~ s/"/&quot;/g;
    $redirectto="";
    $title="������� � ���������� - �������������� ��������";
    &html;
    $action="edit";
    &addplay;
    &htmlend;
    exit;
  }

  $message =~ s/\n/<br>/g;
  $playname =~ s/&quot;/"/g;

  $ujebilo=0;
  for($j=1;$j<=$num;$j++)
  {
    open(votings, "<plays/$j.txt");
    flock(votings, 1);
    @buf=<votings>;
    close (votings);
    chomp $buf[5];
    if($buf[5] eq $playname&$j ne $play)
    {
      $ujebilo=1;
      last
    }
  }
  if($ujebilo eq 1)
  {&noplayname}

  $tempfile="plays/$play.txt";
  if (not -e $tempfile)
  {&playnotfint}

  open(playinfo, "<plays/$play.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);
  foreach (@playinfo)
  {chomp $_}

  if (($playinfo[3] ne $Userid)&($usertype ne "����������")&($usertype ne "��������������"))
  {&netdostupa;}

  $message =~ s/\n/<br>/g;
  $playinfo[5]=$playname;
  $playinfo[6]=$message;
  $playinfo[17] = $Userid;
  $playinfo[4] = $nowtime;

  $newplayinfo = join("\n", @playinfo);

  open(fnewplayinfo, ">plays/$play.txt");
  flock(fnewplayinfo, 2);
  print fnewplayinfo $newplayinfo;
  close (fnewplayinfo);
  &html;
}


sub votingonplay {
  my $votingplay = $_[0];
  my $voicebuf = $_[1];

  $voicebuf = $voicebuf + 5;
  if($voicebuf<3|$voicebuf>7)
  {
    return;
  }
  $tempfile="plays/$votingplay.txt";
  if (not -e $tempfile)
  {&playnotfint}

  open(playfile, "+<$tempfile");
  flock(playfile, 2);
  seek playfile, 0, 0;
  my @playinfo=<playfile>;
  truncate playfile, 0;
  seek playfile, 0, 0;

  foreach (@playinfo)
  {chomp $_}

  if($playinfo[0] ne "1")
  {
    @playinfo = join("\n", @playinfo);
    print playinfo $playinfo;
    close (playinfo);
    return;
  }

  @voices1 = split(/:/,$playinfo[8]);
  @users1 = split(/:/,$playinfo[7]);

  $useris = "0";
  for($i=0;$i<@users1;$i++)
  {
    if(@users1[$i] eq $Userid)
    {
      &Inc_Voice_Col(@voices1[$i]-5, $voicebuf-5);
      @voices1[$i] = $voicebuf;
      $useris = "1";
    }
  }

  if($useris ne "1")
  {
    $playinfo[7] = "$playinfo[7]\:$Userid";
    $playinfo[8] = "$playinfo[8]\:$voicebuf";
    &Inc_Voice_Col("", $voicebuf-5);
  }
  else
  {
    $playinfo[8] = join(":", @voices1);
  }

  @playinfo = join("\n", @playinfo);

  print playfile @playinfo;
  close (playfile);
}

sub voting1 {
  $playpage = param(page);
  $shownotvoice = param(shownotvoice);

  &readindexofplay;

  foreach (@indexofplay)
  {
    if(param($_) ne "")
    {
      &votingonplay($_, param($_));
      &sort_plays_by_voice;
    }
  }

  $buf = "&exp=1";
  if($shownotvoice eq 1)
  {
    $buf = "$buf&shownotvoice=1";
  }
  if($playpage ne "")
  {
    $buf = "$buf&page=$playpage";
  }

  $redirectto = "$site?mode=voting$buf";

  &html;
  exit;
}

sub voting2 {

  if($ENV{HTTP_REFERER} =~ m/voting/)
  {
    &votingonplay($play, param(voice));
    &sort_plays_by_voice;
    srand;
    $nocash = int(rand(999));

    if($ENV{HTTP_REFERER} =~ m/exp=1/)
    {
      $redirectto = "$site?mode=voting&nocash=$nocash&exp=1&play=$play#$play";
    }
    else
    {
      $redirectto = "$site?mode=voting&nocash=$nocash&play=$play#$play";
    }
  }
  elsif($ENV{HTTP_REFERER} =~ m/forum/)
  {
    &votingonplay($play, param(voice));
    &sort_plays_by_voice;
    $redirectto = $ENV{HTTP_REFERER};
  }
  else
  {
    $redirectto = "$site";
  }
  &html;
}

sub sort_plays_by_voice{
  open(playsfile, "+<plays/plays.txt");
  flock(playsfile, 2);
  seek playsfile, 0, 0;
  my @indexofplaybuf2=<playsfile>;
  truncate playsfile, 0;
  seek playsfile, 0, 0;

  my @indexofplaybuf = sort { &comparison_plays_by_voice($a, $b) } @indexofplaybuf2;

  print playsfile @indexofplaybuf;
  close (playsfile);
}

sub comparison_plays_by_voice{

  ($playa) = split(/\|/,$_[0]);
  ($playb) = split(/\|/,$_[1]);

  open(playinfo, "<plays/$playa.txt");
  flock(playinfo, 1);
  @playinfo0=<playinfo>;
  close (playinfo);

  chomp $playinfo0[1];
  chomp $playinfo0[7];
  chomp $playinfo0[8];

  open(playinfo, "<plays/$playb.txt");
  flock(playinfo, 1);
  @playinfo1=<playinfo>;
  close (playinfo);

  chomp $playinfo1[1];
  chomp $playinfo1[7];
  chomp $playinfo1[8];

  @voices0 = split(/:/,$playinfo0[8]);
  @voices1 = split(/:/,$playinfo1[8]);
  @users0 = split(/:/,$playinfo0[7]);
  @users1 = split(/:/,$playinfo1[7]);

  $itog0 = &get_itog(\@voices0, \@users0);
  $itog1 = &get_itog(\@voices1, \@users1);

  if($itog0>$itog1)
  {
    return -1
  }
  elsif($itog0<$itog1)
  {
    return 1
  }
  elsif($itog0 eq $itog1)
  {
    $za0=&get_za(\@voices0, \@users0);
    $za1=&get_za(\@voices1, \@users1);
    if($za0>$za1)
    {
      return -1
    }
    elsif($za0<$za1)
    {
      return 1
    }
    elsif($za0 eq $za1)
    {
      if(&raznica2($playinfo0[1], $playinfo1[1])<=0)
      {return -1}
      else
      {return 1}
    }
  }
}

sub get_itog{
  my ($voicesbuf, $usersbuf) = @_;
  my $itogbuf = 0;
  my $i;

  for($i=0;$i<@$usersbuf;$i++)
  {
    if(($voicesbuf->[$i] >= 3 & $voicesbuf->[$i] <= 7)&(&Get_User_Really($usersbuf->[$i])))
    {
      $itogbuf = $itogbuf + $voicesbuf->[$i] - 5;
    }
  }
  return $itogbuf;
}

sub get_za{
  my ($voicesbuf, $usersbuf) = @_;
  $za=0;
  for($i=0;$i<@$usersbuf;$i++)
  {
    if(($voicesbuf->[$i] > 5)&(&Get_User_Really($usersbuf->[$i])))
    {
      $za = $za + $voicesbuf->[$i] - 5;
    }
  }
  return $za;
}

sub showvoting{
  $exp = param("exp");
  $shownotvoice = param("shownotvoice");
  if($shownotvoice eq 1)
  {
    $playpage = "";
  }
  else
  {
    $shownotvoice = 0;
    if(param(play) eq "")
    {
      if(param(page) ne "")
      {$playpage=param(page)};

      $play=@indexofplay[0];
    }
    else
    {
      $mesto=0;
      foreach (@indexofplay)
      {
        $mesto++;
        if($_ eq $play)
        {
          $playpage=int(($mesto-1)/$playsonpage)+1
        }
      }
    }
  }
  print "<table border=0 cellpadding=4 width=100\%>\n";
  print "<tr><td colspan=6 align=center><b><font size=4>$title2</font></b></td></tr>\n";

  print "<tr><td align=center colspan=6>\n";
  print "����� ��������� - ",&colplay;

  if($shownotvoice ne 1){$pagebuf = "&page=$playpage"}else{$pagebuf = "&shownotvoice=1"}
  if($exp eq "1")
  {
    print " - <a href=\"$site?mode=voting$pagebuf\">��������</a>\n";
  }
  else
  {
    print " - <a href=\"$site?mode=voting$pagebuf&exp=1\">��������</a>\n";
  }

  print "</td></tr>\n";

  if($mode eq "voting"&$login eq 1)
  {
    if($LastLastTimeVisit ne "")
    {
      @newplay = grep {&raznica2($timeofplay{$_}, $LastLastTimeVisit)<=0} @indexofplay;
      $newplaycol=@newplay;
      if($newplaycol>0)
      {
        print "<tr><td align=center colspan=6>\n";
        print "<table border=0 cellpadding=4 width=50\%>\n";
        print "<tr><td bgcolor=$tseriy align=center><b>� �������� ��������� ",&playstext($newplaycol),"</b></td></tr>";

        foreach (@newplay)
        {
          open(playinfo, "<plays/$_.txt");
          flock(playinfo, 1);
          @playinfo=<playinfo>;
          close (playinfo);

          print "<tr><td align=center colspan=4 bgcolor=$sseriy>\n";
          print "<b><a href=$site?play=$_>$playinfo[5]</a></b>\n";
          print "</td></tr>\n";
        }

        print "</table>\n";
        print "</td></tr>\n";
      }
    }

    print "<tr><td align=left colspan=5>", &buildpegelist( &colplay, $playpage, $playsonpage, "$site?mode=voting&page=", "", "");

    if($shownotvoice eq 1)
    {
      print "<b>[��������, �� ��������� ����]</b>";
    }
    else
    {
      print "<a href=$site?mode=voting&shownotvoice=1>��������, �� ��������� ����";
    }
    print "</td>\n<td nowrap align=right><a href=$site?mode=voting&action=add>����� ��������</a></td></tr>\n";
  }

  if($exp eq "1"&$login eq 1)
  {
    print "<form action=$site?mode=voting&exp=1 method=POST>\n";
    print "<input type=hidden name=page value=$playpage>\n";
    print "<input type=hidden name=mode value=voting>\n";
    print "<input type=hidden name=shownotvoice value=$shownotvoice>\n";
  }

  print "<tr bgcolor=$tseriy>";
  print "<td><b>���</b>";
  print "<td><font size=1><b>�����</b></font>";
  print "<td><b>����</b>";
  print "<td width=100\% align=center><b>��������</b>";
  print "<td><b>����������</b>";
  print "<td align=center><b>�����</b>";
  print "</tr>";
  print "<tr><td>\n";
  print "</td></tr>\n";

  $mesto=0;
  foreach (@indexofplay)
  {
    $mesto++;
    $readmtntemp=$indexofplay[$mesto-1];
    if((int(($mesto-1)/$playsonpage)+1 eq $playpage & $shownotvoice ne 1)|($shownotvoice eq 1& &neGolosoval($readmtntemp)))
    {
      print "<!--start mesto: $mesto play: $_-->\n";
      if ($readmtntemp eq $play|$exp eq "1")
      {&showmaxiplay($_)}
      else
      {&showminiplay($_)}
      print "<!--end-->\n";
    }
  }

  if ($login eq 1& $mode eq "voting")
  {
    print "<tr><td align=left colspan=5>", &buildpegelist( &colplay, $playpage, $playsonpage, "$site?mode=voting&page=", "", "");
    if($shownotvoice eq 1)
    {
      print "<b>[��������, �� ��������� ����]</b>";
    }
    else
    {
      print "<a href=$site?mode=voting&shownotvoice=1>��������, �� ��������� ����";
    }

    print "</td>\n<td nowrap align=right><a href=$site?mode=voting&action=add>����� ��������</a></td></tr>\n";
  }

  if($exp eq "1"&$login eq 1)
  {
    print "<tr><td align=center colspan=6>";
    print "<input type=submit style=\"background-color: $tseriy;\" name=action value=�������������>";
    print "</td></tr></form>\n"
  }
  print "</table>\n";
}

# ��������� �������������� ��������� � ����� @indexofplay � ��������� � ����.
sub readindexofplay{

  if($mode eq "voting")
  {
    open(GB, "<boards/3.txt");
  }
  if($mode eq "past")
  {
    open(GB, "<boards/5.txt");
  }

  flock(GB, 1);
  while (<GB>)
  {
    ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
    if($buf2 eq "2")
    {
      $timeoflastpostofplay{$buf4}=$buf7;
      $postcountofplay{$buf4}=$buf6;
      $threadofplay{$buf4}=$buf1;
    }
  }
  close (GB);

  open(GB, "<plays/plays.txt");
  flock(GB, 1);
  @indexofplaybuf=<GB>;
  close (GB);

  foreach (@indexofplaybuf)
  {
    chomp $_;
    ($buf1, $buf2, $buf3, $buf4)=split(/\|/,$_);
    $typeofplay{$buf1}=$buf2;
    $useridofplay{$buf1}=$buf3;
    $timeofplay{$buf1}=$buf4;
    $_=$buf1;
  }

  @indexofplay = grep { $typeofplay{$_} eq $playtype} @indexofplaybuf;
}

# ������� readmtn ���������� ������ ����������� � �����.
sub readmtn{
  return $indexofplay[0];
}


sub noplayname{
  print "<br><br><center><b>�������� � ����� ������ ��� ������������ � �����������, ���� ��� ����� �� ����������� �����.</a></center></b>";
  &htmlend;
  exit;
}

# ������� colplay ���������� ����� ���������� ���������
sub colplay{
  $colplay=@indexofplay;
  return $colplay;
}

sub showmaxiplay{

  $nomerok=$_[0];
  open(playinfo, "<plays/$nomerok.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);
  foreach (@playinfo)
  {chomp $_}

  $date01=$playinfo[1];
  $date02=$playinfo[2];
  $Useridbuf=$playinfo[3];
  $avtor=&Get_Formated_User_Name($Useridbuf);
  $name=$playinfo[5];
  $description=$playinfo[6];
  @users=split(/:/,$playinfo[7]);
  @voices=split(/:/,$playinfo[8]);

  &get_voice_info;

  $description = &text_process($description);

  $hl=param(hl);
  @dum = split(/ /,$hl);
  foreach (@dum)
  {
    $description =~ s/($_)/\<span class=searchlite\>$1\<\/span\>/gsi;
  }

  &zazolovok_print;

  print "<tr bgcolor=$sseriy><td colspan=6>";
  if($login eq 1&(($Useridbuf eq $Userid)|($usertype eq "����������")|($usertype eq "��������������"))&$mode eq "voting")
  {
    print "<center><b><font size=\"1\">";
    print "[<a href=\"$site?mode=voting&action=delete&play=$readmtntemp\" class=\"adm\">�������</a>]\n";
    print "[<a href=\"$site?mode=voting&action=edit\&play=$readmtntemp\" class=\"adm\">�������������</a>]\n";
    if(($usertype eq "����������")|($usertype eq "��������������"))
    {
      print "[<a href=\"$site?mode=voting&action=movetonext&play=$readmtntemp\" class=\"adm\">��������� ����������� �����</a>]\n";
    }
    print "</font></b></center>";
  }

  print "<b>��������:</b><br> $description\n";

  $buf4=&raznicadeys($date01, $nowtime);

  print "<br><br><b>���� ����������:</b> $date01 ($buf4-� ���� � �����������)\n";
  print "<br><br>\n";

  &itogo_print;

  if($mode ne "forum")
  {
    $textbuf = "<br><b>����������</b>: ";
    &Gen_link_to_fotum;
  }
  print "</td></tr>";
  print "<tr><td>\n";
  print "</td></tr>\n";

}

sub showminiplay{

  $nomerok=$_[0];
  open(playinfo, "<plays/$nomerok.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  foreach (@playinfo)
  {chomp $_}

  $date01=$playinfo[1];
  $Useridbuf=$playinfo[3];
  $avtor=&Get_Formated_User_Name($Useridbuf);
  $name=$playinfo[5];
  @users=split(/:/,$playinfo[7]);
  @voices=split(/:/,$playinfo[8]);

  $itog = 0;
  $j = 0;
  for(@voices)
  {
    if(($_>0)&(&Get_User_Really($users[$j])))
    {
      $itog = $itog + $_ - 5;
    }
    $j++;
  }

  &zazolovok_print;

  print "<tr><td></tr>\n";
}

# ������� �� ����� ����� ������ �������� � �������� �������� ���
sub zazolovok_print{
  $image="";
  print "<tr bgcolor=$seriy align=center>\n";
  if($login eq 1)
  {
    $NomerUserNameinList=&isUserNameinList;
    $golosoval=0;
    $golosoval=1 if ($NomerUserNameinList >= 0);
    if($LastLastTimeVisit ne ""&raznica2($date01, $LastLastTimeVisit)<=0)
    {$image="<img width=27 height=27 src=\"$site/$newgif\" alt=\"New\" align=absbottom>";}
    else
    {
      if ($golosoval ne 1)
      {
        $image="<img width=19 height=19 src=\"$site/$icon1gif\" alt=\"!\" align=absbottom>";
      }
      else
      {
        if($voices[$NomerUserNameinList] eq 3)
        {
          $image="<img width=28 height=19 src=\"$site/$mdvagif\" alt=\"-2\" align=absbottom>"
        }
        elsif($voices[$NomerUserNameinList] eq 4)
        {
          $image="<img width=27 height=19 src=\"$site/$modingif\" alt=\"-1\" align=absbottom>"
        }
        elsif($voices[$NomerUserNameinList] eq 5)
        {
          $image="<img width=19 height=19 src=\"$site/$nolgif\" alt=\"0\" align=absbottom>"
        }
        elsif($voices[$NomerUserNameinList] eq 6)
        {
          $image="<img width=27 height=19 src=\"$site/$podingif\" alt=\"+1\" align=absbottom>"
        }
        elsif($voices[$NomerUserNameinList] eq 7)
        {
          $image="<img width=28 height=19 src=\"$site/$pdvagif\" alt=\"+2\" align=absbottom>"
        }
        else
        {
          $image="<img width=19 height=19 src=\"$site/$icon1gif\" alt=\"!\" align=absbottom>";
        }
      }
    }
  }
  print "<td>$image</td>\n";
  print "<td><a name=$readmtntemp></a><b>$mesto</b></td>\n";

  if ($itog>0)
  {$znak="+"}else{$znak=""}

  print "<td><b>$znak$itog</b></td>\n";
  print "<td><b><a href=$site?play=$nomerok>$name</a></b></td>\n";
  if($mode ne "forum")
  {
    print "<td>";
    $textbuf = "";
    &Gen_link_to_fotum;
    print "</td>\n";
  }
  print "<td><b>$avtor</b></td>\n";
  print "</tr>";
}

sub get_voice_info{
  $voice_plus2 = 0;
  $voice_plus1 = 0;
  $voice_nul = 0;
  $voice_minus1 = 0;
  $voice_minus2 = 0;

  $voice_plus2_users = "";
  $voice_plus1_users = "";
  $voice_nul_users = "";
  $voice_minus1_users = "";
  $voice_minus2_users = "";

  for($j=0;$j<@voices;$j++)
  {
    if(&Get_User_Really($users[$j]) eq 1)
    {
      $user_name_buf=&Get_Formated_User_Name($users[$j]);
      $addbuf = 1;
    }
    else
    {
      $user_name_buf=&Get_Formated_User_Name($users[$j], "", "s");
      $addbuf = 0;
    }

    if($users[$j] eq $Userid)
    {$user_name_buf = "<b>$user_name_buf</b>"}

    if ($voices[$j] eq 7)
    {
      $voice_plus2 = $voice_plus2 + $addbuf;
      $voice_plus2_users="$voice_plus2_users$user_name_buf,\n";
    }
    elsif ($voices[$j] eq 6)
    {
      $voice_plus1 = $voice_plus1 + $addbuf;
      $voice_plus1_users="$voice_plus1_users$user_name_buf,\n";
    }
    elsif ($voices[$j] eq 5)
    {
      $voice_nul = $voice_nul + $addbuf;
      $voice_nul_users="$voice_nul_users$user_name_buf,\n";
    }
    elsif ($voices[$j] eq 4)
    {
      $voice_minus1 = $voice_minus1 + $addbuf;
      $voice_minus1_users="$voice_minus1_users$user_name_buf,\n";
    }
    elsif ($voices[$j] eq 3)
    {
      $voice_minus2 = $voice_minus2 + $addbuf;
      $voice_minus2_users="$voice_minus2_users$user_name_buf,\n";
    }
  }

  if($voice_plus2_users ne "")
  {
    substr($voice_plus2_users,-2)=".";
    $voice_plus2_users = "<a href=\"javascript:ShowHide('voice\_$nomerok\_2_open','voice\_$nomerok\_2_closed')\"><b>$voice_plus2</b> ". &moberstext($voice_plus2) ."</a></td></tr><tr bgcolor=$sseriy><td colspan=3><div id=\"voice\_$nomerok\_2_open\" style=\"z-index: 2; display: none;\">$voice_plus2_users</div></td></tr>\n";
  }
  else
  {
    $voice_plus2_users = "<b>0</b> ��������</td></tr>";
  }
  if($voice_plus1_users ne "")
  {
    substr($voice_plus1_users,-2)=".";
    $voice_plus1_users = "<a href=\"javascript:ShowHide('voice\_$nomerok\_1_open','voice\_$nomerok\_1_closed')\"><b>$voice_plus1</b> ". &moberstext($voice_plus1) ."</a></td></tr><tr bgcolor=$sseriy><td colspan=3><div id=\"voice\_$nomerok\_1_open\" style=\"z-index: 2; display: none;\">$voice_plus1_users</div></td></tr>\n";
  }
  else
  {
    $voice_plus1_users = "<b>0</b> ��������</td></tr>";
  }
  if($voice_nul_users ne "")
  {
    substr($voice_nul_users,-2)=".";
    $voice_nul_users = "<a href=\"javascript:ShowHide('voice\_$nomerok\_\o_open','voice\_$nomerok\_\o_closed')\"><b>$voice_nul</b> ". &moberstext($voice_nul) ."</a></td></tr><tr bgcolor=$sseriy><td colspan=3><div id=\"voice\_$nomerok\_\o_open\" style=\"z-index: 2; display: none;\">$voice_nul_users</div></td></tr>\n";
  }
  else
  {
    $voice_nul_users = "<b>0</b> ��������</td></tr>";
  }
  if($voice_minus1_users ne "")
  {
    substr($voice_minus1_users,-2)=".";
    $voice_minus1_users = "<a href=\"javascript:ShowHide('voice\_$nomerok\_-1_open','voice\_$nomerok\_-1_closed')\"><b>$voice_minus1</b> ". &moberstext($voice_minus1) ."</a></td></tr><tr bgcolor=$sseriy><td colspan=3><div id=\"voice\_$nomerok\_-1_open\" style=\"z-index: 2; display: none;\">$voice_minus1_users</div></td></tr>\n";
  }
  else
  {
    $voice_minus1_users = "<b>0</b> ��������</td></tr>";
  }
  if($voice_minus2_users ne "")
  {
    substr($voice_minus2_users,-2)=".";
    $voice_minus2_users = "<a href=\"javascript:ShowHide('voice\_$nomerok\_-2_open','voice\_$nomerok\_-2_closed')\"><b>$voice_minus2</b> ". &moberstext($voice_minus2) ."</a></td></tr><tr bgcolor=$sseriy><td colspan=3><div id=\"voice\_$nomerok\_-2_open\" style=\"z-index: 2; display: none;\">$voice_minus2_users</div></td></tr>\n";
  }
  else
  {
    $voice_minus2_users = "<b>0</b> ��������</td></tr>";
  }

  $itog=2*$voice_plus2 + $voice_plus1 - $voice_minus1 - 2*$voice_minus2;
}

sub itogo_print{
  $voice_plus2_buf2 = "";
  $voice_plus1_buf2 = "";
  $voice_nul_buf2 = "";
  $voice_minus1_buf2 = "";
  $voice_minus2_buf2 = "";

  if ($login eq 1&$playinfo[0] eq 1)
  {
    $voice_plus2_buf = "<a href=\"$site?mode=voting&play=$nomerok&voice=+2\" class=\"vot\">+2</a>";
    $voice_plus1_buf = "<a href=\"$site?mode=voting&play=$nomerok&voice=+1\" class=\"vot\">+1</a>";
    $voice_nul_buf = "<a href=\"$site?mode=voting&play=$nomerok&voice=0\" class=\"vot\">&nbsp;0</a>";
    $voice_minus1_buf = "<a href=\"$site?mode=voting&play=$nomerok&voice=-1\" class=\"vot\">-1</a>";
    $voice_minus2_buf = "<a href=\"$site?mode=voting&play=$nomerok&voice=-2\" class=\"vot\">-2</a>";

    if($exp eq "1")
    {
      $voice_plus2_buf2 = "<input type=radio name=$nomerok value=\"+2\"> ";
      $voice_plus1_buf2 = "<input type=radio name=$nomerok value=\"+1\"> ";
      $voice_nul_buf2 = "<input type=radio name=$nomerok value=\"0\"> ";
      $voice_minus1_buf2 = "<input type=radio name=$nomerok value=\"-1\"> ";
      $voice_minus2_buf2 = "<input type=radio name=$nomerok value=\"-2\"> ";
    }

    if($golosoval eq 1)
    {
      if($voices[$NomerUserNameinList] eq 7)
      {
        $voice_plus2_buf = "<kbd>+2</kbd>";
        $voice_plus2_buf2 = "";
      }
      elsif($voices[$NomerUserNameinList] eq 6)
      {
        $voice_plus1_buf = "<kbd>+1</kbd>";
        $voice_plus1_buf2 = "";
      }
      elsif($voices[$NomerUserNameinList] eq 5)
      {
        $voice_nul_buf = "<kbd>&nbsp;0</kbd>";
        $voice_nul_buf2 = "";
      }
      elsif($voices[$NomerUserNameinList] eq 4)
      {
        $voice_minus1_buf = "<kbd>-1</kbd>";
        $voice_minus1_buf2 = "";
      }
      elsif($voices[$NomerUserNameinList] eq 3)
      {
        $voice_minus2_buf = "<kbd>-2</kbd>";
        $voice_minus2_buf2 = "";
      }
    }
  }
  else
  {
    $voice_plus2_buf = "<kbd>+2</kbd>";
    $voice_plus1_buf = "<kbd>+1</kbd>";
    $voice_nul_buf = "<kbd>&nbsp;0</kbd>";
    $voice_minus1_buf = "<kbd>-1</kbd>";
    $voice_minus2_buf = "<kbd>-2</kbd>";
  }

  print "<table width=\"100%\" border=\"0\" cellpadding=\"2\" bgcolor=$beliy>\n";
  print "<script type=\"text/javascript\" src=\"$site/bbCode.js\"></script>\n";
  print "<tr bgcolor=$seriy><td colspan=5><b>�����������</b></td></tr>\n";

  print "<tr bgcolor=$seriy><td nowrap width=34 height=24 align=center>$voice_plus2_buf</td><td width=90%>$voice_plus2_buf2�������� ��������, ����� ���� �������������</td><td nowrap>$voice_plus2_users\n";
  print "<tr bgcolor=$seriy><td nowrap width=34 height=24 align=center>$voice_plus1_buf</td><td>$voice_plus1_buf2������� ��������, �� ���� � �����</td><td nowrap>$voice_plus1_users\n";
  print "<tr bgcolor=$seriy><td nowrap width=34 height=24 align=center>$voice_nul_buf</td><td>$voice_nul_buf2�� ���� ������������</td><td nowrap>$voice_nul_users\n";
  print "<tr bgcolor=$seriy><td nowrap width=34 height=24 align=center>$voice_minus1_buf</td><td>$voice_minus1_buf2������</td><td nowrap>$voice_minus1_users\n";
  print "<tr bgcolor=$seriy><td nowrap width=34 height=24 align=center>$voice_minus2_buf</td><td>$voice_minus2_buf2������ �� �������</td><td nowrap>$voice_minus2_users\n";

  print "<tr bgcolor=$seriy><td colspan=5>";
  if ($itog>0)
  {
    print "<b>����: +$itog</b>";
  }
  else
  {
    print "<b>����: $itog</b>";
  }
  print "</td></td>\n";
  print "</table>\n";
}

sub isUserNameinList{
  $buf=-1;
  for($j=0;$j<@users;$j++)
  {
    if ($Userid eq $users[$j])
    {$buf=$j;}
  }
  return $buf;
}

sub neGolosoval{
  $nomerok=$_[0];
  open(playinfo, "<plays/$nomerok.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);
  chomp $playinfo[7];
  @users=split(/:/,$playinfo[7]);
  return (isUserNameinList eq -1);
}

sub Gen_link_to_fotum{
  if($postcountofplay{$nomerok}+1>$messagesonpage)
  {
    $threadpegelist = &buildpegelist($postcountofplay{$nomerok}+1, -1, $messagesonpage, "?mode=forum&thread=$threadofplay{$nomerok}&page=", "1", "");
  }
  else
  {
    $threadpegelist="";
  }

  if($postcountofplay{$nomerok} ne 0 & $MessageCountInVisitThreads{$threadofplay{$nomerok}} ne $postcountofplay{$nomerok} & $LastLastTimeVisit ne ""&raznica2($timeoflastpostofplay{$nomerok}, $LastLastTimeVisit)<=0)
  {
    $newbuf = "<a href=\"$site?mode=forum&thread=$threadofplay{$nomerok}&post=new\"><img src=\"$site/$icon_newest_replygif\" border=\"0\" width=18 height=9></a> ";
    $threadpegelist=" <font size=1>( $newbuf$threadpegelist)</font>";
  }
  else
  {
    if($threadpegelist ne "")
    {
      $threadpegelist=" <font size=1>( $threadpegelist)</font>";
    }
  }
  print "<a href=\"$site?mode=forum&thread=$threadofplay{$nomerok}\">$textbuf$postcountofplay{$nomerok}</a>$threadpegelist\n";
}


sub error11{
  $redirect=0;
  &html;
  print "<br><br><center><b>���������� ��������� ��� ����.</b><br>";
  print "<a href=\"javascript:history.back();\">��������� �����...</a></center>";
  &htmlend;
  exit;
}

sub deleteplay {
  if(param(deleteans) eq "")
  {
    &html;
    open(playinfo, "<plays\/$play.txt");
    flock(playinfo, 1);
    @playinfo=<playinfo>;
    close (playinfo);
    chomp $playinfo[3];
    chomp $playinfo[5];

    if(!(($playinfo[3] eq $Userid)|($usertype eq "����������")|($usertype eq "��������������")))
    {
      &netdostupa;
    }

    print "<br><table width=100\%>\n";
    print "<tr align=center><td>\n";
    print "<form action=$site method=POST>\n";
    print "<input type=hidden name=play value=$play>\n";
    print "<input type=hidden name=mode value=\"voting\">\n";
    print "<input type=hidden name=action value=\"delete\">\n";
    print "<input type=hidden name=REFERER value=\"$ENV{HTTP_REFERER}\">\n";
    print "�������� $plays �������� \"<b>$playinfo[5]</b>\".<br>\n";
    print "�� ������������� ������ ������� �������� �� �����������?\n";
    print "</td></tr>\n";
    print "<tr align=center><td>\n";
    print "<input type=submit style=\"background-color: $tseriy;\" name=deleteans value=\"�� \">\n";
    print "<input type=submit style=\"background-color: $tseriy;\" name=deleteans value=\"���\">\n";
    print "</td></tr>\n";
    print "</form>\n";
    print "</table>\n";
  }
  if(param(deleteans) eq "���")
  {
    $redirectto = param(REFERER);
    &html;
    exit;
  }
  if(param(deleteans) eq "�� ")
  {
    open(playinfo, "<plays/$play.txt");
    flock(playinfo, 1);
    @playinfo=<playinfo>;
    close (playinfo);
    foreach (@playinfo)
    {chomp $_}

    if(!(($playinfo[3] eq $Userid)|($usertype eq "����������")|($usertype eq "��������������")))
    {
      &netdostupa;
    }

    if($playinfo[9] ne "")
    {
      &ThreadClose($playinfo[9]);
    }
    if($playinfo[10] ne "")
    {
      &ThreadClose($playinfo[10]);
    }
    if($playinfo[11] ne "")
    {
      &ThreadClose($playinfo[11]);
    }

    open (NEW,">plays/plays_buf.txt");
    open (OLD,"plays/plays.txt");
    while (<OLD>)
    {
      ($buf1)=split(/\|/,$_);
      if($buf1 ne $play)
      {
        print NEW $_;
      }
    }
    close(OLD);
    close(NEW);
    rename("plays/plays.txt", "plays/plays_old.txt");
    rename("plays/plays_buf.txt", "plays/plays.txt");

    rename("plays\/$play.txt", "plays\/$play\_del_by_$Userid.txt");
    unlink($outfile);

    $redirectto = "$site?mode=voting";
    &html;
    exit;
  }
}

sub lastplay_update {
  my ($playbuf, $titlebuf, $avtor, $timebuf) = ($_[0], $_[1], $_[2], $_[3]);

  open(lastplay, "+<lastplay.txt") || open(lastplay, ">lastplay.txt");
  flock(lastplay, 2);
  seek lastplay, 0, 0;
  my @lastplaytemp = <lastplay>;
  truncate lastplay, 0;
  seek lastplay, 0, 0;

  for($j=1;$j>=0 ;$j--)
  {
    $lastplaytemp[$j+1] = $lastplaytemp[$j];
  }
  $lastplaytemp[0] = "$playbuf|$titlebuf|$avtor|$timebuf\n";

  print lastplay @lastplaytemp;
  close(lastplay);
}

1;