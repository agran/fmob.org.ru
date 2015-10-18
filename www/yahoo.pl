sub yahooshow{

  $pagebuf = param(page);
  if($pagebuf eq ""){$pagebuf = 1;}
  open (yahoo_log, "<yahoo.txt");
  flock(yahoo_log, 1);
  @yahoo_log = <yahoo_log>;
  close yahoo_log;

  $bul = 0;
  $record_id = 0;
  for(@yahoo_log)
  {
    if($_ eq "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n")
    {
      if($bul eq 1){$bul = 0}else
      {
        $bul=1;
        $record_id++;
      }
    }
    if($bul eq 1&$_  ne "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n"&$_  ne "--====----====----====----====----====----====----====----====----====----===--\n")
    {
      if(substr($_,0,3) eq "От:")
      {
        $yahoo_avtor{$record_id}=substr($_,10,256);
      }
      elsif(substr($_,0,9) eq "Написано:")
      {
        $yahoo_time{$record_id}=substr($_,10,256);
      }
      elsif(substr($_,0,5) eq "Тема:")
      {
        $yahoo_topic{$record_id}=substr($_,10,256);
        $yahoo_topic{$record_id} =~ s~\[krasnodar_mob\] ~~isg;
      }
      elsif(substr($_,0,5) eq "Кому:")
      {
      }
      elsif(substr($_,0,6) eq "Файлы:")
      {
      }
      else
      {
        $yahoo_record{$record_id}="$yahoo_record{$record_id}$_"
      }
    }
  }

  $buf1 = "";
  $all = int(($record_id-1) / 20)+1;
  for($i=1;$i <= $all;$i++)
  {
    if($pagebuf ne $i)
    {$stran = "$stran<a href=$site/?mode=yahoo&page=$i>$i</a> ";}
    else
    {$stran = "$stran<b>[$i]</b> ";}
  }
  print "<center><b><font size=4>Архивы рассылки Yahoo</font></b></center><br>";
  print "Страницы ($all): $stran";
  print "<table border=0 cellpadding=4 width=780>";
  print "<tr bgcolor=$tseriy align=center>";
  print "<td width=5\%><b>№</b>";
  print "<td><b>Автор</b>";
  print "<td width=40\%><b>Тема</b>";
  print "<td width=18\%><b>Дата</b>";
  print "</tr></table>";

  for($j=($pagebuf-1)*20+1;$j<=($pagebuf)*20;$j++)
  {
    if($yahoo_record{$j} ne "")
    {
      print "<table border=0 cellpadding=0 cellspacing=0 width=780><tr><td>";
      print "<img ilo-ph-fix=fixed ilo-full-src=$site/image/1x1.gif src=$site/image/1x1.gif height=1 width=0></td></tr></table>";
      print "<table border=0 cellpadding=4 width=780>";
      print "<tr bgcolor=$tseriy><td width=5\% align=center><b>$j</td>";

      $buf = &text_process($yahoo_avtor{$j});
      print "<td>$buf</td>";

      print "<td width=40\%>$yahoo_topic{$j}</td>";
      print "<td width=18\%><font size=1>$yahoo_time{$j}</td>";

      print "<tr bgcolor=$sseriy><td colspan=4>";
      $buf = &text_process($yahoo_record{$j});
      print $buf;
      print "</td></tr></table>";
    }
  }

  print "</table>";
  print "Страницы ($all): $stran";
}

1;