sub show_main{
  $playtype = 2;
  &readindexofplay;
  $nextplay = $indexofplay[0];
  print "<table border=0 cellpadding=0 width=100%>";
  print "<tr><td colspan=2 align=center><b><font size=4>������� ��������</font></b></td></tr>\n";
  print "<tr><td> </tr>\n";
  print "<tr><td> </tr>\n";
  print "<tr align=right valign=top><td width=60%>";


  open(maxindex, "<polls/maxindex.txt");
  flock(maxindex, 1);
  $maxpollid = <maxindex>;
  close (maxindex);

  $hide = "1";
  for($j=$maxpollid;$j > 0;$j--)
  {
    if($hide eq 0){next}
    open (pollfile, "<polls/$j.txt");
    flock(pollfile, 1);
    @pull = <pollfile>;
    close pollfile;

    chomp $pull[0];

    ($Useridbuf, $name, $text, $multi, $time, $close, $hide) = split(/\|/,$pull[0]);
    $buf = $j;
  }


  print "<center>";

  &main_yandex_print;


  print &get_poll_form($buf);

  &main_info_print;
  &main_pravila_print;

  print "</td><td>";
  &server_time_print;

  if($login ne 0)
  {
    if($nextplay>0)
    {
      &next_print;
    }
  }
  $playtype = 1;
  if($login ne 0)
  {
    &readindexofplay;
    &last3new_print;
    &top3best_print;
  }
  $playtype = 3;
  &readindexofplay;
  &last3past_print;
  if($login ne 0)
  {
    &lastthread_print;
  }
  print "</td></tr>";
  print "<tr><td colspan=2>";
  &usersonsite_print;
  &users_dnirojdeniya_print;
  #&context_links;
  print "</td></tr>";
  print "</table>";
}

sub usersonsite_print{
  $buf = "";
  $col = 0;
  $login_col = 0;
  $guest_col = 0;
  foreach $useridbuf ( keys %usersonsitetime ){
    if($mode eq "forum")
    {
      if($usersonsiteplase{$useridbuf} =~ m/mode=forum/)
      {
        if(substr($useridbuf,0,1)ne "+")
        {
          $buf = "$buf". &Get_Formated_User_Name($useridbuf). ", ";
          $login_col++;
        }
        else
        {
          $guest_col++;
        }
      }
    }
    else
    {
      if(substr($useridbuf,0,1)ne "+")
      {
        $buf = "$buf". &Get_Formated_User_Name($useridbuf). ", ";
        $login_col++;
      }
      else
      {
        $guest_col++;
      }
    }
  }
  if($buf ne "")
  {
    substr($buf,-2) = ".";
  }
  $col = $login_col + $guest_col;
  if($mode eq "forum")
  {
    if($categoryofboard{$board} ne 8)
    {
      print "<tr bgcolor=$sseriy width=100\%>";
      print "<td colspan=6><b>�� ������ ������������: </b> $buf</td></tr>";
    }
  }
  else
  {
    print "<table border=0 cellpadding=4 width=100\%><tr bgcolor=$tseriy align=center width=100\%>";
    print "<td colspan=6><b>�� ����� ������������: $col (��������: $login_col, ������: $guest_col.)</b></td></tr>";
    print "<tr bgcolor=$sseriy><td colspan=6>$buf</td></tr>";
    print "</table>";
  }
}

sub users_dnirojdeniya_print{
  $buf = "";
  open(dni_rojdeniyafile, "<dni_rojdeniya.txt");
  flock(dni_rojdeniyafile, 1);
  @dni_rojdeniya=<dni_rojdeniyafile>;
  close(dni_rojdeniyafile);
  $i=0;
  $nowdate1 = substr($nowdate,0,5);
  $j=0;
  $j1=0;
  foreach(@dni_rojdeniya)
  {
    chomp($_);
    $i++;

    open (USERINFO,"<users/$i.txt");
    flock(USERINFO, 1);
    @userinfo=<USERINFO>;
    close(USERINFO);

    if(substr($_,0,5) eq $nowdate1 & $userinfo[8] ne "<b><font color=red>��������</font></b>\n")
    {
      $buf = "$buf". &Get_Formated_User_Name($i). "(". &raznicayears($_, $nowdate)."), ";
    }
  }

  if($buf ne "")
  {
    substr($buf,-2) = ".";
    print "<table border=0 cellpadding=4 width=100\%><tr bgcolor=$tseriy width=100\%>";
    print "<td colspan=6><b>������� ���� �������� �</b></td></tr>";
    print "<tr bgcolor=$sseriy><td colspan=6> $buf</td></tr>";
    print "</table>";
  }
}

sub context_links{
    print "<table border=0 cellpadding=4 width=100\%><tr bgcolor=$tseriy width=100\%>";
    print "<tr bgcolor=$sseriy><td colspan=6></td></tr>";
    print "</table>";
}

sub last3new_print{

  open(lastplay, "<lastplay.txt");
  flock(lastplay, 1);
  @lastplay=<lastplay>;
  close (lastplay);
  foreach (@lastplay)
  {chomp $_}

  print "<table border=0 cellpadding=4 width=100%>";
  print "<tr bgcolor=$tseriy align=center><td colspan=2><a href=$site?mode=voting><b>��������� ����������� ��������";

  $i1 = 0;
  foreach (@lastplay)
  {
    ($playbuf, $titlebuf, $avtorbuf, $timebuf)= split(/\|/,$_);
    if($avtorbuf ne $Userid&$LastLastTimeVisit ne ""&raznica2($timebuf, $LastLastTimeVisit)<=0)
    {
      $colorbuf = "$sseriy";
    }
    else
    {
      $colorbuf = "$seriy";
    }
    $avtorbuf = &Get_Formated_User_Name($avtorbuf);
    print "<tr align=center bgcolor=\"$colorbuf\"><td width=8%>$playbuf<td><a href=\"$site?mode=voting&play=$playbuf#$playbuf\"><b>$titlebuf</b></a>\n";
    print "<div align=right><font size=1>$timebuf - $avtorbuf</font></div>\n";

  }

  print "<tr align=center bgcolor=\"$colorbuf\"><td colspan=2><b><a href=$site?mode=voting&action=add>�������� ����� ��������\n";

  print "</table>";
}

sub sort_plays_by_time{
  my @indexofplaybuf = sort { &comparison_plays_by_time($a, $b) } @indexofplay;
  return @indexofplaybuf;
}

sub comparison_plays_by_time{
  $playa = $_[0];
  $playb = $_[1];
  if(&raznica2($timeofplay{$playa}, $timeofplay{$playb})<=0)
  {return -1}
  else
  {return 1}
}

sub top3best_print{

  print "<table border=0 cellpadding=4 width=100%>";
  print "<tr bgcolor=$tseriy align=center><td colspan=2><a href=$site?mode=voting><b>������ ��������</b>";

  for($i=0;$i <= 2;$i++)
  {
    open(playinfo, "<plays/$indexofplay[$i].txt");
    flock(playinfo, 1);
    @playinfo=<playinfo>;
    close (playinfo);
    chomp $playinfo[3];
    chomp $playinfo[5];
    chomp $playinfo[7];
    chomp $playinfo[8];
    @users=split(/:/,$playinfo[7]);
    @voices=split(/:/,$playinfo[8]);
    $itog = &get_itog(\@voices, \@users);

    if ($itog>0)
    {$znak="+"}else{$znak=""}

    if($playinfo[3] ne $Userid&$LastLastTimeVisit ne ""&raznica2($playinfo[5], $LastLastTimeVisit)<=0)
    {
      $colorbuf = "$sseriy";
    }
    else
    {
      $colorbuf = "$seriy";
    }

    $playinfo[3] = &Get_Formated_User_Name($playinfo[3]);
    $i1=$i+1;
    print "<tr align=center bgcolor=\"$colorbuf\"><td width=8%>$i1</td><td><a href=\"$site?mode=voting&play=$indexofplay[$i]#$indexofplay[$i]\"><b>$playinfo[5]</b></a>";
    print "<div align=right><font size=1>����: <b>$znak$itog</b>, �����: $playinfo[3]</font></div>\n";
  }
  print "</table>";
}

sub next_print{
  print "<table border=0 cellpadding=4 width=100%>";
  print "<tr bgcolor=$tseriy align=center><td colspan=2><a href=$site?mode=next><b>����������� ���</b></td></tr>";

  open(playinfo, "<plays/$nextplay.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);
  chomp $playinfo[3];
  chomp $playinfo[5];
  chomp $playinfo[15];
  if($playinfo[15] eq "")
  {
    $buf="���� ���"
  }
  else
  {
    $buf = &getwday($playinfo[15]);
    $buf="$buf $playinfo[15]";
  }
  $playinfo[3] = &Get_Formated_User_Name($playinfo[3]);
  print "<tr align=center bgcolor=\"$sseriy\"><td><a href=\"$site?mode=next\"><b>$playinfo[5]</b></a>";
  print "<div align=right><font size=\"-2\">����: $buf, �����: $playinfo[3]</font></div></td>\n";

  print "</table>";
}

sub server_time_print{
  $servertimeint = $hour*60*60 + $min*60 + $sec + 1;
  print <<timeprint;
<body onload="start(document.time.result)" onunload="cleartids()">
<script language="LiveScript">
servertimeint = $servertimeint;
starttimeint = 0;
tid = 0;
pause = 0;
var to;
var bcount;
var tcount;

function writer(){
document.write("test");
}

function time(n) {
    today = new Date()
    sec = 0;
    min = 0;
    hor = 0;
    timestr = "";
    nowtimeint = today.getHours()*60*60 + today.getMinutes()*60 + today.getSeconds();

    timeint = servertimeint + (nowtimeint - starttimeint);

    sec = timeint % (60);
    if(sec < 10){padsec = "0"}else{padsec = ""}
    min = ((timeint % (60*60))- sec)/60;
    if(min < 10){padmin = "0"}else{padmin = ""}
    hor = ((timeint % (60*60*60)) - min*60 - sec)/(60*60);

    if(hor>23)
    {
       hor=0;
       min=0;
       sec=0;
       padmin = "0";
       padsec = "0";
       servertimeint = 0;
       starttimeint = today.getHours()*60*60 + today.getMinutes()*60 + today.getSeconds();
    }

    timestr = hor + ":"+padmin+min+":"+padsec+sec;
    n.value = timestr;
    window.clearTimeout(tid);
    tid=window.setTimeout("time(document.time.result)",to);
}

function start(x) {
  today = new Date()
  starttimeint = today.getHours()*60*60 + today.getMinutes()*60 + today.getSeconds();
  f=x;
  to=150;
  time(x);
}

function cleartids() {
        window.clearTimeout(tid);
}

</script>
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy align=center><td colspan=2><b>����� ��� ������ �����</b></td></tr>
<tr align=center bgcolor=\"$sseriy\">
<td>
<form name="time">
<center>
<input type="text" size="10" name="result"
onfocus="this.blur()"
style="text-align: center; border-style: double; border-color: $cherniy; border-width: 3px; font-family: Courier New; font-size: 20px; font-weight: bold; ">
</td></tr>
</table>
timeprint

}

sub last3past_print{

  print "<table border=0 cellpadding=4 width=100%>";
  print "<tr bgcolor=$tseriy align=center><td colspan=2><a href=$site?mode=past><b>��������� ��������� ����</b></td></tr>";
  @indexofplay = &sort_plays_by_time;

  $i1 = @indexofplay;
  for($i=0;$i <= 2;$i++)
  {
    open(playinfo, "<plays/$indexofplay[$i].txt");
    flock(playinfo, 1);
    @playinfo=<playinfo>;
    close (playinfo);
    chomp $playinfo[3];
    chomp $playinfo[5];
    chomp $playinfo[7];
    chomp $playinfo[8];
    @users=split(/:/,$playinfo[7]);
    @voices=split(/:/,$playinfo[8]);
    $za = 0;
    $protiv = 0;
    for($j=0;$j<@voices;$j++)
    {
      if ($voices[$j] eq "1")
      {
        $za++;
      }
      if ($voices[$j] eq "0")
      {
        $protiv++;
      }
    }
    $itog=$za-$protiv;

    if ($itog>0)
    {$znak="+"}else{$znak=""}

    if($playinfo[3] ne $Userid&$LastLastTimeVisit ne ""&raznica2($playinfo[5], $LastLastTimeVisit)<=0)
    {
      $colorbuf = "$sseriy";
    }
    else
    {
      $colorbuf = "$seriy";
    }

    $playinfo[3] = &Get_Formated_User_Name($playinfo[3]);
    print "<tr align=center bgcolor=\"$colorbuf\"><td width=8%>$i1</td><td><a href=\"$site/?mode=past&play=$indexofplay[$i]#$indexofplay[$i]\"><b>$playinfo[5]</b></a>";
    print "<div align=right><font size=1>$timeofplay{$indexofplay[$i]}, �����: $playinfo[3]</font></div>\n";
   $i1--;
  }
  print "</table>";
}

sub lastthread_print{
  open(lastinfo, "<messages/lastthreads.txt");
  flock(lastinfo, 1);
  @lastinfo=<lastinfo>;
  close (lastinfo);
  foreach (@lastinfo)
  {chomp $_}

  print "<table border=0 cellpadding=3 width=100%>";
  print "<tr bgcolor=$tseriy align=center><td colspan=2><a href=$site?mode=forum><b>���������� �� ������";
  &readindexofboards;

  $i1 = 0;
  foreach (@lastinfo)
  {
    ($threadbuf, $titlebuf, $lastposttimebuf, $lastposterbuf, $boardbuf, $messagecountbuf3)= split(/\|/,$_);
    if(($messagecountbuf3 ne "" &$MessageCountInVisitThreads{$threadbuf} ne $messagecountbuf3) &$lastposterbuf ne $Userid&$LastLastTimeVisit ne ""&raznica2($lastposttimebuf, $LastLastTimeVisit)<=0)
    {
      $colorbuf = "$sseriy";
      $postbuf = "new";
    }
    else
    {
      $colorbuf = "$t2seriy";
      $postbuf = "last";
    }
    $lastposterbuf = &Get_Formated_User_Name($lastposterbuf);
    if((($boardbuf eq 11) & (($usertype eq "����������")|($usertype eq "��������������")))|($boardbuf ne 11))
    {
      $i1++;
      if($i1>=14 & $postbuf ne "new"){last}
      if($titleofboard{$boardbuf} eq "���������� � ������ �� ��������� ������"){$titleofboard{$boardbuf} = "��������� ������"}
      if($titleofboard{$boardbuf} eq "���������� ����������� �����"){$titleofboard{$boardbuf} = "����������� ������"}

      print "<tr align=center bgcolor=\"$colorbuf\"><td><table border=0 cellpadding=0 width=100%><tr align=center><td colspan=2><a href=?mode=forum&thread=$threadbuf&post=$postbuf\><b>$titlebuf</b></a> <font size=1><a href=?mode=forum&thread=$threadbuf&post=all\>$messagecountbuf3</a></font>\n";
      print "<tr bgcolor=\"$colorbuf\"><tr><td align=left><font size=1><a href=$site?mode=forum&board=$boardbuf>$titleofboard{$boardbuf}</a><td align=right><font size=1>$lastposttimebuf - $lastposterbuf</font></table>\n";
    }
  }
  print "</table>";
}

sub main_pravila_print{

    print <<MAIN_INFO;
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy align=center><td colspan=2><b>�������� ������� FM-�����</b></td></tr>
<tr align=justify bgcolor=\"$sseriy\"><td>
<Br><b>�� ����������</b><br>
<br>
- ���������� ������ ����� � ��������� � �������� �����. � ���� ����� ������ �������� ��������� ��������� ������������ ��������,
������������ ������ ��������� ���� ��� "����������" ����� �����. ����� �����, ��������� ������� ���� �� ������� �������.<br>
<br>
<b>�� ���������� ��������</b><br>
<br>
- ��� ������. ������, ��� ���� ��� ���������� � ������ �����, ����� ������ ����� ��������� �������� � �������������. � ���-���� ��
���������� ����������� ��� ������ � �������� � �� "�������" ������ ������� ���������� (���� ��� ��������).<br>
<br>
<b>�� ��������</b><br>
<br>
- ���� ��������, ��������� �������, ���� ���� ���� ������� �������� ���������� - � ��� ��� ���� ������ �� ����������. � ����!
�� �������� � ������� ����������� ����, � ��� ����� � � ������ ���������.<br>
<br>
- ���� ���� �� ������ � �������� ������, ����������� �� ������, ������� ������������� ��� � ����� �� ������������ ����� �����. ��� -
���������� ���� ���������� �����. � ���� ������ �������� ������� ��������.<br>
<br>
<b>�� ��������� �������� ��������� �� �����</b><br>
<br>
- ��� ���������� ������������� ������� ���������� ������� ��������, ��� ����� ������� �� ��������. ���� ��������� �������, ������� ����� �
������ - �������� �������� ����������������.<br>
<br>
<b>�� ��������� ������ ��� ���������� ��� ������������ ������������������ �������</b><br>
<br>
- ������, ��� ���� ��� - ��������� �������� �����������, �� ����������, ��� ������� ���������� ����� ������ ���������� �������� �������.<br>
�������� ����� � ����� � �� ������. ������� ����:<ol type="1">
<li>����� ��� ���� ������������� ��������<br>
<li>���� ������� � ���������<br>
<li>�� ��������� �������� ����������<br>
<li>�� ����������� ����� ������ � ������<br>
</ol><br>
</td></tr>
</table>
MAIN_INFO
}

sub main_info_print{
    print <<MAIN_INFO;
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy align=center><td colspan=2><b>��� ����� FlashMob</b></td></tr>
<tr align=justify bgcolor=\"$sseriy\"><td>
<b>Flash Mob</b> - ���������� �����, ������������ ��������������, ������� �������� (����.). ��� ���������� ������� ������ ����� � ����������� �����, � ����������� �����. ��� ���� ������ ��������� �� ������� ����������� ����������, ����� ���� ��������� ��������.<br>
<br>
<b>������� ������ Flash Mob</b>  �������� ������������ �� �����, � ����� ��������� � ����� ����������.<br>
<br>
<b>������� ��� (��)</b> - ��� ����� ��������� ����� ���������� "�����������" ���������� ��������, ������� ������ � �������� �������, �� ���������� ������ ���������� �����, � ������� ����� ������ ������� ����������. <b>��</b> - ��� ������ ���������� �����, ������ �� ��������� �� ���, � ������� ��� �����, �������� ���������� �� ������ ����� ����, �����-�� ��� ��������...
</td></tr>
</table>
MAIN_INFO
}

sub main_yandex_print{
    print <<MAIN_INFO;
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy align=center><td colspan=2><b>���������� ������� �� ���� �����</b></td></tr>
<tr align=center bgcolor=\"$sseriy\"><td>

<script type="text/javascript" src="//yandex.st/share/share.js" charset="utf-8"></script>
<div class="yashare-auto-init" data-yashareL10n="ru" data-yashareType="button" data-yashareQuickServices="vkontakte,facebook,twitter,odnoklassniki,lj"></div>

</td></tr>
</table>
<br>
MAIN_INFO
}

1;