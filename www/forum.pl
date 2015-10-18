{
  use locale;
  use POSIX qw(locale_h);
}

sub showforum{
  $category = param(category);
  $board = param(board);
  $thread = param(thread);
  $forumpage = param(page);
  $post = param(post);
  $answertopost = param(answertopost);
  $editpost = param(editpost);
  $hidepost = param(hidepost);
  $setupthread = param(setupthread);

  if($setupthread ne "")
  {
    $thread = $setupthread;
  }

  if($login eq 1 & $action eq "addthread")
  {
    $subjectbuf = readparam(subj);
    $commentbuf = readparam(comm);
    $messagebuf = readparam(message);

    $typebuf = 1;
    if(&addthread ne 0)
    {
      &Inc_Col_Mes;
      &lastthread_update($newthreadid, $subjectbuf, $nowtime, $Userid, $board, 0);

      ($buf,$to2)=&get_subscribe_mails(3);

      if($new_upload_name ne "")
      {
        $new_upload_name_buf = "\[br\]\[b\]Присоединённое изображение:\[/b\] $site/image/upload/$new_upload_name";
      }
      else
      {
        $new_upload_name_buf = "";
      }
      if($board ne 11)
      {
        &send_subscribe("\[url=$site?mode=forum&thread=$newthreadid\]\[size=4\]$subjectbuf\[/size\]\[/url\]\[br\]\[color=gray\] $commentbuf \[/color\]\[br\]\[b\]Автор:\[/b\] \[url=$site?showuser=$Userid\]$UserName\[/url\]\[br\]\[br\]\[hr\]$messagebuf$new_upload_name_buf\[hr\]\[br\]$site?mode=forum&thread=$newthreadid\[br\]\[br\]$site", "FMob: Создана новая тема: \"$subjectbuf\"", "\"$UserName\" <subscribe\@fmob.org.ru>", "", $to2);
      }
      $redirectto = "$site?mode=forum&thread=$newthreadid#1";
      &html;
      exit;
    }
  }

  if($login eq 1 & $action eq "addmessage")
  {
    $board = &BoardGet($thread);

    $messagebuf = readparam(message);

    if(&addmessage ne 0)
    {
      $messagecountbuf++;
      $topage = int(($messagecountbuf-1)/$messagesonpage)+1;
      $topage = "&page=$topage";
      $nocash = int(rand(999));
      $redirectto = "$site?mode=forum&nocash=$nocash&thread=$thread$topage#$messagecountbuf";
      &html;
      exit;
    }
  }
  if($answertopost ne "")
  {$forumpage = int(($answertopost-1)/$messagesonpage)+1;}

  if($post ne ""&$thread ne "" & $post ne "all")
  {
    if($post eq "last")
    {
      $board = &BoardGet($thread);
      &getthreadinfo($thread);
      $post = $threadmessagecount{$thread}+1;
    }
    if($post eq "new")
    {
      $board = &BoardGet($thread);
      &getthreadinfo($thread);

      ($maxpost, $minpost) = ($threadmessagecount{$thread}, 0);
      &readindexofmessages;

      if($MessageCountInVisitThreads{$thread} ne "")
      {
        $post = $MessageCountInVisitThreads{$thread}+2;
      }
      else
      {
        for($i=$threadmessagecount{$thread}+1;$i>0;$i--)
        {
          if(&raznica2($messagetime{$i}, $LastLastTimeVisit)>0)
          {
            $post = $i+1;
            last
          }
        }

      }
      if($post > $threadmessagecount{$thread}+1)
      {$post = $threadmessagecount{$thread}+1;}
    }
    $topage = int(($post-1)/$messagesonpage)+1;
    if($topage>1)
    {
      $topage = "&page=$topage";
    }
    else
    {
      $topage = "";
    }
    $redirectto = "$site?mode=forum&thread=$thread$topage";
    if(param(hl) ne "")
    {
      $redirectto = "$redirectto\&hl=".param(hl);
    }
    $redirectto = "$redirectto#$post";
    &html;
    exit;
  }


  &readindexofboards;


  if($board ne ""|$thread ne "")
  {
    if($thread ne "")
    {$board = &BoardGet($thread)}
    if($thread eq "")
    {
      if($forumpage eq ""){$forumpage=1}
      ($maxthread, $minthread) = &getmaxandmin($threadcountofboard{$board}, $forumpage, $threadsonpage);
      &readindexofthreads;
    }
    else
    {
      &getthreadinfo($thread);
      if($post eq "all")
      {
        $messagesonpage = $threadmessagecount{$thread}+1;
      }
  }


    if($forumpage eq "")
    {
      $forumpage = 1;
    }
    if($editpost ne "")
    {
      $maxpost = $editpost-1;
      $minpost = $editpost-1;
    }
    elsif(param(startpost) ne ""&param(endpost) ne "")
    {
      $maxpost = param(endpost)-1;
      $minpost = param(startpost)-1;
    }
    else
    {
      ($maxpost, $minpost) = &getmaxandmin($threadmessagecount{$thread}+1, $forumpage, $messagesonpage);
    }
    &readindexofmessages;
  }

  $title="Флешмоб в Краснодаре - Форум";

  if($board ne "")
  {
    $title="$title :: $titleofboard{$board}"
  }

  if($thread ne "")
  {
    $title="$title :: $threadtitle{$thread}"
  }

  if($setupthread ne "")
  {
    &setupthread_forma;
    &htmlend;
    exit;
  }

  if($thread ne "")
  {$MessageCountInVisitThreads{$thread} = $threadmessagecount{$thread};}

  if($hidepost ne "")
  {
    $hidepost1 = &hidepost;
  }

  if($editpost ne "")
  {
    $editpost1 = &editpost;
  }

  if($editpost1 ne 0)
  {
    &html;
    if($thread ne "")
    {
      if($visibleofboard{$board} eq 1 | $login eq 1)
      {
        &printthread;
      }
      else
      {
        &netdostupa;
      }
    }
    elsif($board eq "")
    {
      &printboardlist;
    }
    else
    {
      if($visibleofboard{$board} eq 1 | $login eq 1)
      {
        &printboard;
      }
      else
      {
        &netdostupa;
      }
    }
  }
}

sub printboardlist{

  if($category ne "")
  {$categorybuf =  " :: <b><a href=\"$site?mode=forum&category=$category\">$titleofboard{$category}</a></b>";}

  print <<forumstart;
<table width="780" border="0" cellpadding="4">
<tr><td> </tr>
<tr bgcolor=$seriy><td colspan=5 height=28 align=left><b><a href="$site?mode=forum">Форум на $domen</a></b>$categorybuf</td>
</tr>
forumstart
&usersonsite_print;
  print <<forumstart;
<tr bgcolor=$tseriy>
<td width="60%" colspan=2 align=center><b>Форум</b></td>
<td width="10%" align=center><b>Тем</b></td>
<td width="10%" align=center><b>Ответов</b></td>
<td width="20%" align=center><b>Обновление</b></td>
</tr>
forumstart
  foreach (@indexofboards)
  {
    if(($category eq ""&$categoryofboard{$_} eq 0)&($visibleofboard{$_} eq 1 | $login eq 1)&($visibleofboard{$_} ne 2 | (($usertype eq "модераторы")|($usertype eq "администраторы"))))
    {
      print "<tr><td></tr><tr bgcolor=$seriy><th colspan=5 height=28 align=left><a href=\"$site?mode=forum&category=$_\">$titleofboard{$_}</a></th></tr>";
    }
    elsif(($category eq ""|($category ne ""&$categoryofboard{$_} eq $category))&($visibleofboard{$_} eq 1 | $login eq 1)&($visibleofboard{$_} ne 2 | (($usertype eq "модераторы")|($usertype eq "администраторы"))))
    {
      if($LastLastTimeVisit ne ""&raznica2($lastposttimeofboard{$_}, $LastLastTimeVisit)<=0)
      {$boardicon = "$board_newgif"}
      else
      {$boardicon = "$boardgif"}
      print <<forum1;
<tr bgcolor=$sseriy>
<td width="4%"><img width="26" height="25" src="$site/$boardicon" align="absbottom"></td>
<td><b><a href=\"$site?mode=forum&board=$_\">$titleofboard{$_}</a></b><br><font color=$ttseriy>$commentofboard{$_}</font></td>
<td align=center>$threadcountofboard{$_}</td>
<td align=center>$messagecountofboard{$_}</td>
<td align=center>$lastposttimeofboard{$_}<br>$lastposterofboard{$_}</td>
</tr>
forum1

    }
  }
  print "</table>";
}

sub printboard{
  $pegelist = &buildpegelist($threadcountofboard{$board}, $forumpage, $threadsonpage, "?mode=forum&board=$board&page=", "","");

  if($titleofboard{$categoryofboard{$board}} eq "")
  {
    &netdostupa;
  }

  if(!($visibleofboard{$board} ne 2 | (($usertype eq "модераторы")|($usertype eq "администраторы"))))
  {
     &netdostupa;
  }

  print <<forumstart;
<table width="780" border="0" cellpadding="4">
<tr><td></tr>
<tr bgcolor=$seriy><td colspan=6 height=28 align=left><b><a href="$site?mode=forum">Форум на $domen</a></b> :: <b><a href=\"$site?mode=forum&category=$categoryofboard{$board}\">$titleofboard{$categoryofboard{$board}}</a></b> :: <b><a href=\"$site?mode=forum&board=$board\">$titleofboard{$board}</a></b></td>
</tr>
forumstart
&usersonsite_print;

  print <<forumstart;
<tr><td colspan=5 align=left>$pegelist</td><td align=right><a href=#T>Новая тема</a> <a href=$site?mode=polls&action=add>Новый опрос</a></td></tr>
</tr>
<tr bgcolor=$tseriy>
<td width="50%" colspan=2 align=center><b>Тема</b></td>
<td width="10%" align=center><b>Автор</b></td>
<td width="1%" align=center><b><font size=1>Ответов</b></td>
<td width="1%" align=center><b><font size=1>Просмотров</b></td>
<td width="20%" align=center><b>Обновление</b></td>
</tr>
forumstart
  foreach (@indexofthreads)
  {
    if($Userid ne $threadlastposter{$_}&$MessageCountInVisitThreads{$_} ne $threadmessagecount{$_}&$LastLastTimeVisit ne ""& &raznica2($threadlastposttime{$_}, $LastLastTimeVisit)<=0)
    {
      if($threadclose{$_} eq 1)
      {
        $threadicon = "$thread_new_closegif";
      }
      else
      {
        $threadicon = "$thread_new";
      }
      if ($threadmessagecount{$_} ne 0)
      {
        $newbuf = "<a href=\"$site?mode=forum&thread=$_&post=new\"><img src=\"$site/$icon_newest_replygif\" border=\"0\" width=18 height=9></a> ";
      }
      else
      {
        $newbuf = "";
      }
    }
    else
    {
      if($threadclose{$_} eq 1)
      {
        $threadicon = "$thread_closegif";
      }
      else
      {
        $threadicon = "$threadgif";
      }
      $newbuf = "";
    }

    $threadlastposterbuf = &Get_Formated_User_Name($threadlastposter{$_});

    if($threadmessagecount{$_}+1 > $messagesonpage)
    {
      $threadpegelist = &buildpegelist($threadmessagecount{$_}+1, -1, $messagesonpage, "?mode=forum&thread=$_&page=", "1", "");
      $threadpegelist = "<font size=1>( $newbuf$threadpegelist)</font>";
    }
    else
    {
      if($newbuf ne "")
      {
        $threadpegelist = "<font size=1>( $newbuf)</font>";
      }
      else
      {$threadpegelist = ""}
    }

    if((($usertype eq "модераторы")|($usertype eq "администраторы"))|($threadavtor{$_} eq &Get_Formated_User_Name($Userid)))
    {
      $setup_buton = "<a href=\"$site?mode=forum&setupthread=$_\"><img width=\"15\" height=\"16\" src=\"$site/image/setup.gif\" border=0 align=\"absbottom\"></a> ";
    }
    else
    {
      $setup_buton = "";
    }
    print <<hread;
<tr bgcolor=$sseriy align=center>
<td width=3%><img width="19" height="18" src="$site/$threadicon\" align="absbottom"></td>
<td align=left>$setup_buton<b><a href=\"$site?mode=forum&thread=$_\">$threadtitle{$_}</a></b> $threadpegelist <br><font color=$ttseriy>$threadcomment{$_}</font></td>
<td>$threadavtor{$_}</td>
<td><a href=\"$site?mode=forum&thread=$_&post=all\">$threadmessagecount{$_}</td>
<td>$threadviewcount{$_}</td>
<td>$threadlastposttime{$_}<br>$threadlastposterbuf</td>
</tr>
hread
  }

  print <<forumend;
<tr><td colspan=2 align=left>$pegelist</td></tr>
</tr>
</table>
forumend

  if($login eq 1)
  {
    print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<a name="T"></a>
<div align="center">
<b><font size="4">Новая тема для обсуждения</font></b>
$predvtext
<table border="0" cellspacing="0" cellpadding="2">
<form action="$site?mode=forum&board=$board\#T" method="POST" name="post" enctype="multipart/form-data">
<input type="hidden" name="mode" value="forum">
<input type="hidden" name="action" value="addthread">
<input type="hidden" name="board" value="$board">
<tr>
    <td nowrap>$subjstartНазвание темы:$subjend</td>
    <td><input type=text maxlength="80" size="80" name=subj value="$subj"></td>
</tr>
<tr>
    <td nowrap><font color="$ttseriy">Описание темы:</font></td>
    <td><input type=text maxlength="80" size="80" name=comm value="$comm"></td>
</tr>
<tr><td valign=bottom>$messagestart\Cообщение:$messageend</td>
FORMA

    &textinput;

    print <<FORMA;
<tr>
  <td colspan=2 align=center>$uploadstartПрисоединить картинку (jpg, gif, png до 150KB):$uploadend
  <input type="file" name="file_upload" size=40></td>
</tr>
<tr>
  <td colspan=2 align=center>
  <input type=checkbox name=headeris> Закрепить первое сообщение на каждой странице
</tr>
<tr>
    <td align=center><input type=submit style="background-color: $tseriy;" value=Отправить></td>
    <td align=right><input type=submit style="background-color: $tseriy;" name="predv" value="Предварительный просмотр"></td>
</tr>
</tr>
</form></table>
</div>
FORMA
}
}

sub printthread{

  if($poiskovik eq 0)
  {
    ThreadViewInc($thread);
  }

  if($messagesonpage2 eq $messagesonpage){$forumpage2 = $forumpage}else{$forumpage2 = 0}
  $pegelist = &buildpegelist($threadmessagecount{$thread}+1, $forumpage2, $messagesonpage2, "?mode=forum&thread=$thread&page=", "", "");

  if($threadcomment{$thread} ne "")
  {$threadcommentbuf = " ($threadcomment{$thread})";}

  if(!($visibleofboard{$board} ne 2 | (($usertype eq "модераторы")|($usertype eq "администраторы"))))
  {
     &netdostupa;
  }

  $setup_buton = "";

  if(($usertype eq "модераторы")|($usertype eq "администраторы")|($threadavtor{$thread} eq &Get_Formated_User_Name($Userid)))
  {
    $setup_buton = " <a href=\"$site?mode=forum&setupthread=$thread\"><img width=\"15\" height=\"16\" src=\"$site/image/setup.gif\" border=0 align=\"absbottom\"></a>";
  }

  print <<forumstart;
<table width="780" border="0" cellpadding="4">
<tr><td></tr>
<tr bgcolor=$seriy><td colspan=2 align=left><b><a href="$site?mode=forum">Форум на $domen</a></b> :: <b><a href=\"$site?mode=forum&category=$categoryofboard{$board}\">$titleofboard{$categoryofboard{$board}}</a></b> :: <b><a href=\"$site?mode=forum&board=$board\">$titleofboard{$board}</a></b></td>
</tr>
forumstart
&usersonsite_print;
  print <<forumstart;
<tr bgcolor=$tseriy><td colspan=2 align=left><b><a href=\"$site?mode=forum&thread=$thread\">$threadtitle{$thread}</a></b>$threadcommentbuf$setup_buton</td>
</tr>
</table>
forumstart

  open(playinfo, "<plays/$threadplay{$thread}.txt");
  flock(playinfo, 1);
  @playinfo=<playinfo>;
  close (playinfo);

  chop $playinfo[0];

  if($playinfo[0] eq "1")
  {
    print "<table width=780 border=0 cellpadding=4>";
    print "<tr bgcolor=$tseriy>";
    print "<td><b>Тип</b>";
    print "<td><font size=1><b>Место</b></font>";
    print "<td><b>Итог</b>";
    print "<td align=center width=80\%><b>Название</b>";
    print "<td align=center width=10\%><b>Автор</b>";
    print "</tr>";

    $playtype = 1;
    &readindexofplay;
    for($j=0;$j<@indexofplay;$j++)
    {
      if($indexofplay[$j] eq $threadplay{$thread})
      {
        $mesto = $j + 1;
      }
    }
    &showmaxiplay($threadplay{$thread});
    print "</table>";
  }

  if($playinfo[0] eq "2")
  {
    &shownext;
  }

  if($playinfo[0] eq "3")
  {
    print "<table border=0 cellpadding=4 width=780>";
    print "<tr bgcolor=$tseriy>";
    print "<th>№";
    print "<th width=80\%>Название";
    print "<th>Автор";
    print "</tr>";
    &showmaxipast($threadplay{$thread});
    print "</table>";
  }

  print "<table width=780 border=0 cellpadding=4><tr>";

  if(($forumpage ne 1)&($ThreadHead eq 1))
  {}else
  {
    print "<td align=left>$pegelist";
    if($login eq 1&$threadclose{$thread} ne 1)
    {
      print "<td align=right><a href=#T>Ответить</a></td>";
    }
  }
  print "</tr></table>";


  foreach (@indexofmessages)
  {
    if(($usertype ne "модераторы")&($usertype ne "администраторы")&($messageavtor{$_} ne $Userid)&($messagehide{$_} eq 1))
    {
      next;
    }

    $avtor = $messageavtor{$_};
    if($avtorlast ne $avtor)
    {
      $avtorlast = $avtor;
      &get_avtor_info;
    }

    $messagetextbuf = &text_process($messagetext{$_});
    if($messageimg{$_} ne ""&$messageimg{$_} ne ".")
    {
      $messageimgbuf = "";
      if($messagetextbuf ne "")
      {$messageimgbuf = "<br>"}
      $messageimgbuf = "$messageimgbuf<b>Присоединённое изображение</b><br><img style=\"border-color: #606060;\" src=\"$site/image/upload/$messageimg{$_}\" border=2>";
    }
    else
    {
      $messageimgbuf = "";
    }


    if($messageeditby{$_} ne "")
    {
      $editflagbuf = "<br>•<font size=1 color=$sseriy><b>Это сообщение отредактировал(а):</b> " .&Get_Formated_User_Name($messageeditby{$_},"","h"). ". &nbsp; <b>Дата редактирования:</b> $messageedittime{$_}."
    }
    else
    {
      $editflagbuf = ""
    }

    if((($usertype eq "модераторы")|($usertype eq "администраторы"))|((&raznica2($messagetime{$_}, $nowtime)<=30)& $avtor eq $Userid))
    {
      $editbuf = "<a href=\"$site?mode=forum&thread=$thread&editpost=$_\">Редактировать</a> ";
      if($messagehide{$_} ne 1)
      {
        $editbuf = "<a href=\"$site?mode=forum&thread=$thread&hidepost=$_\">Скрыть</a> $editbuf";
      }
      else
      {
        $editbuf = "<a href=\"$site?mode=forum&thread=$thread&hidepost=$_\">Показать</a> $editbuf";
      }
    }
    else
    {
      $editbuf = "";
    }

    if($messagehide{$_} ne 1)
    {
      $colorbuf = "$sseriy";
    }
    else
    {
      $colorbuf = "FFE3E3";
    }

    if($login eq 1)
    {
      $answerbuf = "<a href=\"$site?mode=forum&thread=$thread&answertopost=$_#T\">Цитировать</a>";
    }
    else
    {
      $answerbuf = "";
    }

    $hl=param(hl);
    @dum = split(/ /,$hl);
    foreach (@dum)
    {
      $messagetextbuf =~ s/($_)/\<span class=searchlite\>$1\<\/span\>/gsi;
    }


#<a name=$_></a>$user_name_buf1 = 'Мед'; $avtor $userinfo[6]
$user_name_buf1="<b><a href=\"javascript:quote('$userinfo[0]')\" onmouseover='get_selection();'><img src=\"http://stat.livejournal.com/img/userinfo.gif\" style=\"border: 0pt none ; vertical-align: bottom;\" height=17 width=17>$userinfo[0]</a></b>";

    print qq~
<table width="780" border="0" cellpadding="4">
<tr bgcolor="$seriy">
<td width="17%" align="center"><a name=$_></a>$user_name_buf1</td>
<td align="center" width="5%"><a href=\"$site?mode=forum&thread=$thread&post=$_\"><b>$_</b></a></td>
<td>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td>$messagetime{$_}</td>
<td align=right><b>$editbuf$answerbuf</b></td>
</tr>
</table>
</td>
</tr>
<tr bgcolor="$colorbuf" valign=top>
<td>$levo</td>
<td colspan="3">$messagetextbuf$messageimgbuf$editflagbuf</td>
</tr>
<tr bgcolor="$t2seriy">
<td> </td>
<td colspan="3">$niz</td>
</tr>
</table>
<table width=780 border="0" cellspacing="0" cellpadding="0"><tr><td>
~;
    if(($_ eq 1)&($forumpage ne 1)&($ThreadHead eq 1))
    {
      print "<br> &nbsp;$pegelist";

      if($login eq 1&$threadclose{$thread} ne 1)
      {
        print "<td align=right><br><a href=#T>Ответить</a>";
      }
      print "<tr><td colspan=2><img src=\"$site/image/1x1.gif\" height=3 width=\"100%\" alt=\"\"></table>";
    }
    else
    {
      print "<img src=\"$site/image/1x1.gif\" height=1 width=\"100%\" alt=\"\"></td></tr></table>";
    }
    if($login eq 1 & $answertopost eq $_)
    {
      $usernamebuf="\[b\]$userinfo[0]\[/b\]";

      if($userinfo[6] eq 1)
      {$posterbuf = "$usernamebuf, написал: "}
      elsif($userinfo[6] eq 0)
      {$posterbuf = "$usernamebuf, написала: "}
      else
      {$posterbuf = "$usernamebuf, написал(а): "}
      $message = $messagetext{$answertopost};
      $message =~ s~<br>~\n~isg;
      $message="\[quote\]$posterbuf$message\[/quote\]";
    }
  }

  print <<forumend;
<table width="780" border="0" cellpadding="4">
<tr><td colspan=2 align=left>$pegelist</td></tr>
</table>
forumend
  if($login eq 1&$threadclose{$thread} ne 1&$board ne 12)
  {

    $buf = int(($threadmessagecount{$thread})/$messagesonpage)+1;
    if($forumpage ne "")
    {
      $buf = $forumpage;
    }

    print <<FORMA;
<a name="T"></a>
<div align="center">
<b><font size="4">Ваш комментарий</font></b>
$predvtext
<script type="text/javascript" src="$site/bbCode.js"></script>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=forum&thread=$thread&page=$buf#T" method=POST name=post onsubmit="submit1()" enctype="multipart/form-data">
<input type="hidden" name="mode" value="forum">
<input type="hidden" name="action" value="addmessage">
<input type="hidden" name="thread" value="$thread">
<input type="hidden" name="page" value="$buf">
<tr>
    <td valign=bottom>$messagestart\Cообщение:$messageend</td>
FORMA

    &textinput;

    print <<FORMA;
<tr>
  <td colspan=2 align=center>$uploadstartПрисоединить картинку (jpg, gif, png до 150KB):$uploadstart
  <input type="file" name="file_upload" size=40></td>
</tr>
<tr>
<td align=center><input type=submit style=\"background-color: $tseriy;\" name=submit value=Отправить></td>
<td align=right><input type=submit style=\"background-color: $tseriy;\" name="predv" value="Предварительный просмотр"></td>
</tr>
</tr>
</form></table>
</div>
FORMA
}
}

sub readindexofboards{
  open(boards, "<boards/boards.txt");
  flock(boards, 1);
  @indexofboards=<boards>;
  close (boards);

  foreach (@indexofboards)
  {
    chomp $_;
    ($typebuf, $visiblebuf, $titlebuf, $idbuf, $commentbuf)=split(/\|/,$_);
    if($typebuf ne 0)
    {
      $commentofboard{$idbuf}=$commentbuf;
      ( $threadcount, $messagecount, $lastposttime, $lastposter ) = &BoardCountGet($idbuf);
      $threadcountofboard{$idbuf} = $threadcount;
      $messagecountofboard{$idbuf} = $messagecount;
      $lastposttimeofboard{$idbuf} = $lastposttime;
      $lastposterofboard{$idbuf} = &Get_Formated_User_Name($lastposter);
    }
    $categoryofboard{$idbuf}=$typebuf;
    $visibleofboard{$idbuf}=$visiblebuf;
    $titleofboard{$idbuf}=$titlebuf;

    $_ = $idbuf;
  }
}

sub readindexofthreads{
  open(threads, "<boards/$board.txt");
  flock(threads, 1);

  $threadnum = 0;
  $threadnum1 = 0;
  while (<threads>)
  {
    if(($threadnum>=$minthread & $threadnum<=$maxthread)|$forumbuf1 eq 0)
    {
      $threadbuf = $_;
      chomp $threadbuf;
      ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf, $lastposttimebuf, $lastposterbuf)=split(/\|/,$threadbuf);
      $threadtype{$idbuf} = $typebuf;
      if($typebuf eq 2)
      {
        $threadcomment{$idbuf} = "Сценарий: <a href=\"$site?play=$commentbuf\">$site?play=$commentbuf</a>";
      }
      else
      {
        $threadcomment{$idbuf} = $commentbuf;
      }
      $threadtitle{$idbuf} = $titlebuf;
      $threadavtor{$idbuf} = &Get_Formated_User_Name($avtorbuf);
      $threadmessagecount{$idbuf} = $messagecountbuf;
      ($threadviewcount{$idbuf}, $threadclose{$idbuf}) = &ThreadViewGet($idbuf);
      $threadlastposttime{$idbuf} = $lastposttimebuf;
      $threadlastposter{$idbuf} = $lastposterbuf;
      @indexofthreads[$threadnum1] = $idbuf;
      $threadnum1++;
    }
    $threadnum++;
  }

  close (threads);
}

sub getthreadinfo{
  open(threads, "<boards/$board.txt");
  flock(threads, 1);
  $idbuf1 = $_[0];
  while (<threads>)
  {
    $threadbuf = $_;
    chomp $threadbuf;
    ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf, $lastposttimebuf, $lastposterbuf)=split(/\|/,$threadbuf);
    if($idbuf eq $idbuf1)
    {
      $threadtype{$idbuf} = $typebuf;
      if($typebuf eq 2)
      {
        $threadplay{$idbuf} = $commentbuf;
        $threadcomment{$idbuf} = "Сценарий: <a href=\"$site?play=$commentbuf\">$site?play=$commentbuf</a>";
      }
      else
      {
        $threadcomment{$idbuf} = $commentbuf;
      }

      $threadtitle{$idbuf} = $titlebuf;
      $threadavtor{$idbuf} = &Get_Formated_User_Name($avtorbuf);
      $threadmessagecount{$idbuf} = $messagecountbuf;
      ($threadviewcount{$idbuf}, $threadclose{$idbuf}) = &ThreadViewGet($idbuf);
      $threadlastposttime{$idbuf} = $lastposttimebuf;
      $threadlastposter{$idbuf} = &Get_Formated_User_Name($lastposterbuf);
    }
  }
  close (threads);
}

sub readindexofmessages{
  my ($postnum, $postnum1, $postbuf);
  open(messages, "<messages/$thread.txt");
  flock(messages, 1);
  $postnum = 0;
  $postnum1 = 0;
  @indexofmessages=();


  while (<messages>)
  {
    if(($postnum>=$minpost & $postnum<=$maxpost & !($postnum eq 0 & $threadtype{$thread} ne 1))|(($postnum eq 0)&($ThreadHead eq 1)))
    {
      $postbuf = $_;
      chomp $postbuf;
      $idbuf = $postnum + 1;
      ($avtorbuf, $timebuf, $textbuf, $imagebuf, $editbybuf, $edittimebuf, $hidebuf)=split(/\|/,$postbuf);

      $messageavtor{$idbuf} = $avtorbuf;
      $messagetime{$idbuf} = $timebuf;
      $messagetext{$idbuf} = $textbuf;
      $messageimg{$idbuf} = $imagebuf;
      $messageeditby{$idbuf} = $editbybuf;
      $messageedittime{$idbuf} = $edittimebuf;
      $messagehide{$idbuf} = $hidebuf;

      $indexofmessages[$postnum1] = $idbuf;
      $postnum1++;
    }
    $postnum++;
  }
  close (messages);
}

sub ThreadViewGet {
  if( open(boardinfo, "<messages/$_[0]_info.txt") )
  {
    flock(boardinfo, 1);
    $buf = <boardinfo>;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    close(boardinfo);
    return ($Viewcol, $ThreadClose);
  }
  else
  {return (0, 0)}
}

sub ThreadViewInc {
  if( open(boardinfo, "+<messages/$_[0]_info.txt") )
  {
    flock(boardinfo, 2);
    seek boardinfo, 0, 0;
    $buf = <boardinfo>;
    chomp $buf;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    $Viewcol++;
    seek (boardinfo, 0, 0);
    print boardinfo "$Viewcol|$boardbuf|$ThreadClose|$ThreadHead";
    close(boardinfo);
  }
}

sub ThreadClose {
  if( open(boardinfo, "+<messages/$_[0]\_info.txt") )
  {
    flock(boardinfo, 2);
    seek boardinfo, 0, 0;
    $buf = <boardinfo>;
    chomp $buf;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    $ThreadClose = 1;
    seek (boardinfo, 0, 0);
    print boardinfo "$Viewcol|$boardbuf|$ThreadClose|$ThreadHead";
    close(boardinfo);
  }
}

sub ThreadOpen {
  if( open(boardinfo, "+<messages/$_[0]_info.txt") )
  {
    flock(boardinfo, 2);
    $buf = <boardinfo>;
    chomp $buf;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    $ThreadClose = 0;
    seek (boardinfo, 0, 0);
    print boardinfo "$Viewcol|$boardbuf|$ThreadClose|$ThreadHead";
    close(boardinfo);
  }
}

sub BoardGet {
  if(open(boardinfo, "<messages/$_[0]_info.txt"))
  {
    flock(boardinfo, 1);
    $buf = <boardinfo>;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    close(boardinfo);
    $BoardGetCesh{$_[0]} = $boardbuf;
    return $boardbuf;
  }
  else
  {return -1}
}

sub BoardCountGet {
  if(open(boardinfo, "<boards/$_[0]_info.txt") )
  {
    flock(boardinfo, 1);
    $_ = <boardinfo>;
    chomp;
    close(boardinfo);
    return split(/\|/,$_);
  }
  else
  {
    return (0, 0, "<i>Нет информации</i>","")
  }
}

sub getmaxandmin{
  $colmessbuf = $_[0];
  $pagebuf = $_[1];
  $messonpagebuf = $_[2];
  if($pagebuf ne "")
  {return ($pagebuf*$messonpagebuf-1, ($pagebuf-1)*$messonpagebuf)}
  else
  {return ($colmessbuf-1, 0)}
}

sub addthread{
  if($messagebuf eq ""|$subjectbuf eq "")
  {
    $message = $messagebuf;
    $subj = $subjectbuf;
    $comm = $commentbuf;
    if($subjectbuf eq "")
    {
      $subjstart = "<font color=red>";
      $subjend = "</font>";
    }
    if($messagebuf eq "")
    {
      $messagestart = "<font color=red>";
      $messageend = "</font>";
    }
    return 0;
  }

  if(param(file_upload) ne "")
  {
    $new_upload_name = &upload;
    if($uploaderror eq 1)
    {
      $message = $messagebuf;
      $subj = $subjectbuf;
      $comm = $commentbuf;
      $uploadstart = "<font color=red>";
      $uploadend = "</font>";
      return 0;
    }
  }

  if(param(predv)eq "Предварительный просмотр")
  {
    $message = $messagebuf;
    $messagebuf =~ s/\n/<br>/g;
    $messagebuf = &text_process($messagebuf);
    $predvtext ="<table border=0 width=632 cellpadding=4>
<tr><td colspan=2 bgcolor=$tseriy>
<b>Предварительный просмотр:</b>
</td></tr>
<tr><td colspan=2 bgcolor=$sseriy>
$messagebuf
</td><tr>
</table>";
    $subj = $subjectbuf;
    $comm = $commentbuf;
    return 0;
  }

  $messagebuf =~ s/\n/<br>/g;
  open(boardfile, "+<boards/$board.txt") || open(boardfile, ">boards/$board.txt");
  flock(boardfile, 2);
  seek boardfile, 0, 0;
  my @boardtemp = <boardfile>;
  truncate boardfile, 0;
  seek boardfile, 0, 0;

  ($buf, $buf, $titlebuf, $buf, $avtorbuf)=split(/\|/,$boardtemp[0]);

  if($titlebuf eq $subjectbuf & $avtorbuf eq $Userid)
  {
    print boardfile @boardtemp;
    close(boardfile);
    return 0;
  }

  open(maxindex, "+<messages/maxindex.txt") || open(maxindex, ">messages/maxindex.txt");
  flock(maxindex, 2);
  seek maxindex, 0, 0;
  $newthreadid=<maxindex>;
  $newthreadid++;
  truncate maxindex, 0;
  seek maxindex, 0, 0;
  print maxindex $newthreadid;
  close (maxindex);

  print boardfile qq~$newthreadid|$typebuf|$subjectbuf|$commentbuf|$Userid|0|$nowtime|$Userid\n~;
  print boardfile @boardtemp;
  close(boardfile);

  open(messagefile, ">messages/$newthreadid.txt");
  flock(messagefile, 2);
  print messagefile qq~$Userid|$nowtime|$messagebuf|$new_upload_name\n~;
  close(messagefile);

  if(param(headeris) eq "on")
  {$header_buf = "1"}
  else
  {$header_buf = "0"}

  open(messageinfofile, ">messages/$newthreadid\_info.txt");
  flock(messageinfofile, 2);
  print messageinfofile qq~0|$board|0|$header_buf~;
  close(messageinfofile);

  open(boardinfofile, "+<boards/$board\_info.txt") || open(boardinfofile, ">boards/$board\_info.txt");
  flock(boardinfofile, 2);
  seek boardinfofile, 0, 0;
  my $boardinfotemp = <boardinfofile>;
  truncate boardinfofile, 0;
  seek boardinfofile, 0, 0;
  ( $threadcount, $messagecount, $lastposttime, $lastposter ) = split(/\|/,$boardinfotemp);
  if($messagecount eq ""){$messagecount = 0;}
  $threadcount ++;
  print boardinfofile qq~$threadcount|$messagecount|$nowtime|$Userid~;

  close(boardinfofile);
  return 1;
}

sub addmessage{
  if($ThreadClose eq 1){return 0;}
  if($messagebuf eq ""&param(file_upload) eq "")
  {
    $message = param(message);
    $messagestart = "<font color=red>";
    $messageend = "</font>";
    return 0;
  }
  if(param(file_upload) ne "")
  {
    $new_upload_name = &upload;
    if($uploaderror eq 1)
    {
      $message = param(message);
      $uploadstart = "<font color=red>";
      $uploadend = "</font>";
      return 0;
    }
  }

  if(param(predv)eq "Предварительный просмотр")
  {
    $message = $messagebuf;
    $messagebuf =~ s/\n/<br>/g;
    $messagebuf = &text_process($messagebuf);
    $predvtext ="<table border=0 width=632 cellpadding=4>
<tr><td colspan=2 bgcolor=$tseriy>
<b>Предварительный просмотр:</b>
</td></tr>
<tr><td colspan=2 bgcolor=$sseriy>
$messagebuf
</td><tr>
</table>";
    return 0;
  }
  $messagebuf =~ s/\n/<br>/g;

  open(boardfile, "+<boards/$board.txt");
  flock(boardfile, 2);
  seek boardfile, 0, 0;
  my @boardtemp = <boardfile>;
  truncate boardfile, 0;
  seek boardfile, 0, 0;

  $threadnum = 0;
  foreach (@boardtemp)
  {
    ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf) = split(/\|/,$_);

    if($idbuf eq $thread)
    {
      for($j=$threadnum-1;$j>=0 ;$j--)
      {
        $boardtemp[$j+1] = $boardtemp[$j];
      }
      $messagecountbuf++;
      $boardtemp[0] = "$idbuf|$typebuf|$titlebuf|$commentbuf|$avtorbuf|$messagecountbuf|$nowtime|$Userid\n";
      last;
    }
    $threadnum++;
  }
  print boardfile @boardtemp;
  close(boardfile);

  open(messagefile, ">>messages/$thread.txt");
  flock(messagefile, 2);
  print messagefile qq~$Userid|$nowtime|$messagebuf|$new_upload_name\n~;
  close(messagefile);

  open(boardinfofile, "+<boards/$board\_info.txt");
  flock(boardinfofile, 2);
  seek boardinfofile, 0, 0;
  my $boardinfotemp = <boardinfofile>;
  truncate boardinfofile, 0;
  seek boardinfofile, 0, 0;
  ( $threadcount, $messagecount, $lastposttime, $lastposter ) = split(/\|/,$boardinfotemp);
  $messagecount ++;
  print boardinfofile qq~$threadcount|$messagecount|$nowtime|$Userid~;
  close(boardinfofile);
  &Inc_Col_Mes;

  &lastthread_update($thread, $titlebuf, $nowtime, $Userid, $board, $messagecountbuf);

  ($buf,$to2)=&get_subscribe_mails(3);
  $messagecountbuf2 = $messagecountbuf + 1;


  if($typebuf eq 2)
  {
    $commentbuf2 = "Сценарий: \[url=$site?play=$commentbuf\]$site?play=$commentbuf\[/url\]";
  }
  else
  {
    $commentbuf2 = $commentbuf;
  }
  if($new_upload_name ne "")
  {
    $new_upload_name_buf = "\[br\]\[b\]Присоединённое изображение:\[/b\] $site/image/upload/$new_upload_name";
  }
  else
  {
    $new_upload_name_buf = "";
  }

  if($board ne 11)
  {
    &send_subscribe("\[url=$site?mode=forum&thread=$thread\]\[size=4\]$titlebuf\[/size\]\[/url\]\[br\]\[color=gray\] $commentbuf2 \[/color\]\[br\]\[b\]Автор:\[/b\] \[url=$site?showuser=$Userid\]$UserName\[/url\]\[br\]\[hr\]$messagebuf$new_upload_name_buf\[hr\]\[br\]$site?mode=forum&thread=$thread&post=$messagecountbuf2\[br\]\[br\]\[url=$site\]Перейти на главную страницу сайта\[/url\]", "FMob: Новый ответ в теме: \"$titlebuf\"", "\"$UserName\" <subscribe\@fmob.org.ru>", "", $to2);
  }


  return 1;
}

sub lastthread_update {
  my ($threadbuf, $titlebuf, $lastposttimebuf, $lastposterbuf, $boardbuf, $messagecountbuf3) = ($_[0], $_[1], $_[2], $_[3], $_[4], $_[5]);

  open(lastthreads, "+<messages/lastthreads.txt") || open(boardinfofile, ">messages/lastthreads.txt");
  flock(lastthreads, 2);
  seek lastthreads, 0, 0;
  my @boardtemp = <lastthreads>;
  truncate lastthreads, 0;
  seek lastthreads, 0, 0;
  $est = 0;
  $threadnum = 0;
  foreach (@boardtemp)
  {
    ($threadbuf2, $buf, $buf, $buf, $buf, $buf) = split(/\|/,$_);

    if($threadbuf2 eq $threadbuf)
    {
      for($j=$threadnum-1;$j>=0 ;$j--)
      {
        $boardtemp[$j+1] = $boardtemp[$j];
      }
      $est = 1;
      $boardtemp[0] = "$threadbuf|$titlebuf|$lastposttimebuf|$lastposterbuf|$boardbuf|$messagecountbuf3\n";
      last;
    }
    $threadnum++;
  }
  if($est eq 0)
  {
    for($j=18;$j>=0 ;$j--)
    {
      $boardtemp[$j+1] = $boardtemp[$j];
    }
    $boardtemp[0] = "$threadbuf|$titlebuf|$lastposttimebuf|$lastposterbuf|$boardbuf|$messagecountbuf3\n";
  }
  print lastthreads @boardtemp;
  close(lastthreads);
}

sub upload{
  $uploaderror = 0;
  if(param(predv) eq "Предварительный просмотр")
  {
    return "";
  }
  $file_upload = param(file_upload);
  if($file_upload =~ /\.jpg$|\.jpeg$/i)
  {
    $file_tipe = "jpg";
  }
  elsif($file_upload =~ /\.gif$/i)
  {
    $file_tipe = "gif";
  }
  elsif($file_upload =~ /\.png$/i)
  {
    $file_tipe = "png";
  }
  else
  {
    $file_tipe = "";
  }
  if($file_tipe ne "")
  {
    open(maxindex, "+<image/upload/maxindex.txt") || open(maxindex, ">image/upload/maxindex.txt");
    flock(maxindex, 2);
    seek maxindex, 0, 0;
    $newuploadid=<maxindex>;
    $newuploadid++;
    truncate maxindex, 0;
    seek maxindex, 0, 0;
    print maxindex $newuploadid;
    close (maxindex);

    $outfile = "image/upload/$newuploadid.$file_tipe";
    open (OUTFILE, ">$outfile");
    flock(OUTFILE, 2);
    while ($bytesread = read($file_upload,$buffer,1024)) {
      binmode OUTFILE;
      print OUTFILE $buffer;
    }
    close(OUTFILE);

    open (OUTFILE, "$outfile");
    $file_size = -s OUTFILE;
    close(OUTFILE);

    if($file_size eq 0|$file_size > 153600)
    {
      unlink($outfile);
      $uploaderror = 1;
      return "";
    }
    return "$newuploadid.$file_tipe";
  }  $uploaderror = 1;
  return "";
}

sub editpost{
  $avtor = $messageavtor{$editpost};

  if(!((($usertype eq "модераторы")|($usertype eq "администраторы"))|((&raznica2($messagetime{$editpost}, $nowtime)<=30)& $avtor eq $Userid)))
  {
    &html;
    &netdostupa;
  }

  if(param(finish) eq 1)
  {
    $messagebuf = param(message);
    if($messagebuf ne "")
    {
      $messagebuf =~ s/\n/<br>/g;
      $messagebuf =~ s~\|~&#124;~g;

      open (MESSAGES,"<messages/$thread.txt");
      flock(MESSAGES, 1);
      open (MESSAGESBUF,">messages/$thread\_buf.txt");
      flock(MESSAGESBUF, 2);

      $postbuf = 0;
      while (<MESSAGES>)
      {
        $postbuf++;
        if($postbuf eq $editpost)
        {
          $postinfobuf = $_;
          chomp $postinfobuf;
          ($avtorbuf, $timebuf, $textbuf, $imagebuf, $editbybuf, $edittimebuf, $editvisiblbuf)=split(/\|/,$postinfobuf);

          print MESSAGESBUF qq~$avtorbuf|$timebuf|$messagebuf|$imagebuf|$Userid|$nowtime|$editvisiblbuf\n~;
        }
        else
        {
          print MESSAGESBUF $_;
        }
      }

      close(MESSAGES);
      close(MESSAGESBUF);
      rename("messages/$thread.txt", "messages/$thread\_old.txt");
      rename("messages/$thread\_buf.txt", "messages/$thread\.txt");
    }
    $redirectto = "$site?mode=forum&thread=$thread&post=$editpost";
    &html;
    exit;
  }

  $title="$title :: Редактирование";
  &html;

  $message = $messagetext{$editpost};
  $message =~ s/<br>/\n/g;

  $messagetextbuf = &text_process($messagetext{$editpost});

  &get_avtor_info;

  if($messageeditby{$editpost} ne "")
  {
    $editflagbuf = "<br><br><hr color=$beliy><font size=1 color=$ttseriy><b>Это сообщение отредактировал(а):</b> " .&Get_Formated_User_Name($messageeditby{$editpost}). ". &nbsp; <b>Дата редактирования:</b> $messageedittime{$editpost}."
  }
  else
  {
    $editflagbuf = ""
  }

  if($messageimg{$editpost} ne "" & $messageimg{$editpost} ne ".")
  {
    $messageimgbuf = "";
    if($messagetextbuf ne "")
    {$messageimgbuf = "<br>"}
    $messageimgbuf = "$messageimgbuf<b>Присоединённое изображение</b><br><img style=\"border-color: #606060;\" src=\"$site/image/upload/$messageimg{$editpost}\" border=2>";
  }
  else
  {
    $messageimgbuf = "";
  }

  print <<forumstart;
<table width="780" border="0" cellpadding="4">
<tr><td></tr>
<tr bgcolor=$seriy><td colspan=2 align=left><b><a href="$site?mode=forum">Форум на $domen</a></b> :: <b><a href=\"$site?mode=forum&category=$categoryofboard{$board}\">$titleofboard{$categoryofboard{$board}}</a></b> :: <b><a href=\"$site?mode=forum&board=$board\">$titleofboard{$board}</a></b></td>
</tr>
forumstart
&usersonsite_print;
  print <<forumstart;
<tr bgcolor=$tseriy><td colspan=2 align=left><b><a href=\"$site?mode=forum&thread=$thread\">$threadtitle{$thread}</a></b>$threadcommentbuf</td>
</tr>
</table>
forumstart


    print <<FORMA;
<a name="T"></a>
<div align="center">
<b><font size="4">Редактирование сообщения</font></b>

<table width="780" border="0" cellpadding="4">
<tr bgcolor="$seriy">
<td width="17%" align="center"><a name=$_></a>$user_name_buf1</td>
<td align="center" width="5%"><a href=\"$site?mode=forum&thread=$thread&post=$editpost\"><b>$editpost</b></a></td>
<td>$messagetime{$editpost}</td>
</td>
</tr>
<tr bgcolor="$sseriy" valign=top>
<td>$levo</td>
<td colspan="3">$messagetextbuf$messageimgbuf$editflagbuf</td>
</tr>
<tr bgcolor="$t2seriy">
<td> </td>
<td colspan="3">$niz</td>
</tr>
</table>
<table width=780 border="0" cellspacing="0" cellpadding="0"><tr><td><img src=\"$site/image/1x1.gif\" height=1 width="100%" alt=""></td></tr></table>
<script type="text/javascript" src="$site/bbCode.js"></script>
<table border=0 cellspacing=0 cellpadding=2>
<form action="" method=POST name=post onsubmit="submit1()" enctype="multipart/form-data">
<input type="hidden" name="mode" value="forum">
<input type="hidden" name="thread" value="$thread">
<input type="hidden" name="editpost" value="$editpost">
<input type="hidden" name="finish" value="1">
<tr>
    <td valign=bottom>$messagestart\Cообщение:$messageend</td>
FORMA

    &textinput;

    print <<FORMA;
<tr>
<td align=center><input type=submit name=submit style=\"background-color: $tseriy;\" value=Отправить></td>
</tr>
</tr>
</form></table>
</div>
FORMA
  return 0;
}

sub hidepost{

  if(!((($usertype eq "модераторы")|($usertype eq "администраторы"))|!((&raznica2($messagetime{$editpost}, $nowtime)<=30)& $avtor eq $Userid)))
  {
    &html;
    &netdostupa;
  }

  open (MESSAGES,"<messages/$thread.txt");
  flock(MESSAGES, 1);
  open (MESSAGESBUF,">messages/$thread\_buf.txt");
  flock(MESSAGESBUF, 2);

  $postbuf = 0;
  while (<MESSAGES>)
  {
    $postbuf++;
    if($postbuf eq $hidepost)
    {
      $postinfobuf = $_;
      chomp $postinfobuf;
      ($avtorbuf, $timebuf, $textbuf, $imagebuf, $editbybuf, $edittimebuf, $hidebuf)=split(/\|/,$postinfobuf);
      if($hidebuf eq 1)
      {
        $hidebuf = "0"
      }
      else
      {
        $hidebuf = "1"
      }
      print MESSAGESBUF qq~$avtorbuf|$timebuf|$textbuf|$imagebuf|$Userid|$nowtime|$hidebuf\n~;
    }
    else
    {
      print MESSAGESBUF $_;
    }
  }

  close(MESSAGES);
  close(MESSAGESBUF);
  rename("messages/$thread.txt", "messages/$thread\_old.txt");
  rename("messages/$thread\_buf.txt", "messages/$thread\.txt");

  $redirectto = "$site?mode=forum&thread=$thread&post=$hidepost";
  &html;
  exit;
}

sub get_avtor_info {

  open (userinfo, "<users/$avtor.txt");
  flock(userinfo, 1);
  @userinfo = <userinfo>;
  close userinfo;
  foreach (@userinfo)
  {chomp $_}

  $niz = "<b><a href=\"$site?showuser=$avtor\">профиль</a></b>";

  if($mode eq "private")
  {
    $user_name_buf1="<b><a href=\"$site?showuser=$avtor\">$userinfo[0]</a></b>";
  }
  else
  {
    $buf = $userinfo[0];
    $buf =~ s~'~`~g;

    $user_name_buf1="<b><a href=\"javascript:quote('$buf', '$userinfo[6]')\" onmouseover='get_selection();'><img src=\"http://stat.livejournal.com/img/userinfo.gif\" style=\"border: 0pt none ; vertical-align: bottom;\" height=17 width=17>$userinfo[0]</a></b>";
  }

  if($userinfo[6]eq 1)
  {$user_name_buf1 = "$user_name_buf1 <img src=\"$site/image/m.gif\" alt=\"М\">"}
  if($userinfo[6]eq 0)
  {$user_name_buf1 = "$user_name_buf1 <img src=\"$site/image/w.gif\" alt=\"Ж\" align=absbottom>"}

  $levo = "<font size=1><div align=\"center\">";

  if ($userinfo[14] ne "")
  {
    $userinfo[14]="<img src=\"$site/image/avatars/$userinfo[14]\">";
    $levo = "$levo $userinfo[14]<br>";
  }
  if($userinfo[9] ne "")
  {
    $levo = "$levo $userinfo[9]<br>";
  }

  $levo = "$levo</div><br>";

  if(($userinfo[8] eq "модераторы")|($userinfo[8] eq "администраторы")|($userinfo[8] eq "подпольные администраторы"))
  {
    $levo = "$levoгруппа: правящая верхушка<br>";
  }
  else
  {
    $levo = "$levoгруппа: $userinfo[8]<br>";
  }

  $levo = "$levoсообщений: $userinfo[10]<br>";
  if($userinfo[15] ne "")
  {
    $levo = "$levoпроживает:<br>&nbsp;&nbsp;&nbsp;$userinfo[15]<br>";
  }

  $levo = "$levo</font><br>";

  $niz = "$niz <b><a href=\"$site?mode=private&action=new&toid=$avtor\">ЛС</a></b>";

  if($userinfo[4] ne "")
  {
    $buf=&savemail($userinfo[4]);
    $userinfo[4] = "<a href=$site?mode=sendmail&to=$buf&userid=$avtor>e-mail</a>";
    $niz = "$niz <b>$userinfo[4]</b>";
  }

  if($userinfo[5] ne "")
  {
    $userinfo[5]="<a href=\"http://wwp.icq.com/$userinfo[5]\#pager\">ICQ</a>";
    $niz = "$niz <b>$userinfo[5]</b>";
  }
  $levo = "$levo<img src=\"$site/image/1x1.gif\" alt=\"\" width=140 height=1><br>";
}

sub setupthread_forma {
  if(!((($usertype eq "модераторы")|($usertype eq "администраторы"))|($threadavtor{$setupthread} eq &Get_Formated_User_Name($Userid))))
  {
    &html;
    &netdostupa;
  }

  if(param(finish) eq 1)
  {
    open(boardinfo, "+<messages/$setupthread\_info.txt");
    flock(boardinfo, 2);
    seek boardinfo, 0, 0;
    $buf = <boardinfo>;
    chomp $buf;
    ($Viewcol, $boardbuf, $ThreadClose, $ThreadHead) = split(/\|/,$buf);
    seek (boardinfo, 0, 0);
    if(param(threadclose) eq "on")
    {$ThreadClose = 1;}else{$ThreadClose = 0;}
    if(param(threadheader) eq "on")
    {$ThreadHead = 1;}else{$ThreadHead = 0;}

    ($boardbuf2) = (param(razdel) =~ /(\d+)*/);
    $boardold = $boardbuf;

    if((($usertype eq "модераторы")|($usertype eq "администраторы")))
    {
      if($boardbuf2 ne $boardbuf)
      {
        $pereezd = 1;
        $boardbuf = $boardbuf2;
      }
      else
      {
        $pereezd = 0
      }
    }

    $threadtitle_new = param(threadtitlenew);
    $threadcomment_new = param(threadcommentnew);
    if(($threadtitle_new ne $threadtitle{$setupthread})|($threadcomment_new ne $threadcomment{$setupthread}))
    {$pereinen = 1}else{$pereinen = 0}
    print boardinfo "$Viewcol|$boardbuf|$ThreadClose|$ThreadHead";
    close(boardinfo);

    if($pereezd eq 1)
    {
      open(boardfile1, "+<boards/$boardold.txt");
      flock(boardfile1, 2);
      seek boardfile1, 0, 0;
      my @boardtemp1 = <boardfile1>;
      truncate boardfile1, 0;
      seek boardfile1, 0, 0;
      $i = 0;
      foreach (@boardtemp1)
      {
        ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf) = split(/\|/,$_);

        if($idbuf eq $setupthread)
        {
          $ThreadBuf = $_;
          splice @boardtemp1, $i, 1;
          last;
        }
        $i++;
      }
      print boardfile1 @boardtemp1;
      close(boardfile1);

      open(boardinfofile, "+<boards/$boardold\_info.txt");
      flock(boardinfofile, 2);
      seek boardinfofile, 0, 0;
      my $boardinfotemp = <boardinfofile>;
      truncate boardinfofile, 0;
      seek boardinfofile, 0, 0;
      ( $threadcount, $messagecount, $lastposttime, $lastposter ) = split(/\|/,$boardinfotemp);
      chomp $messagecountbuf;
      $messagecount = $messagecount - $messagecountbuf;
      $threadcount--;
      print boardinfofile qq~$threadcount|$messagecount|$lastposttime|$lastposter~;
      close(boardinfofile);

      open(boardfile2, "+<boards/$boardbuf.txt");
      flock(boardfile2, 2);
      seek boardfile2, 0, 0;
      my @boardtemp2 = <boardfile2>;
      truncate boardfile2, 0;
      seek boardfile2, 0, 0;
      print boardfile2 $ThreadBuf;
      print boardfile2 @boardtemp2;
      close(boardfile2);

      open(boardinfofile, "+<boards/$boardbuf\_info.txt");
      flock(boardinfofile, 2);
      seek boardinfofile, 0, 0;
      my $boardinfotemp = <boardinfofile>;
      truncate boardinfofile, 0;
      seek boardinfofile, 0, 0;
      ( $threadcount, $messagecount, $lastposttime, $lastposter ) = split(/\|/,$boardinfotemp);
      $messagecount = $messagecount + $messagecountbuf;
      $threadcount++;
      print boardinfofile qq~$threadcount|$messagecount|$lastposttime|$lastposter~;
      close(boardinfofile);
    }

    if($pereinen eq 1)
    {
      open(boardfile, "+<boards/$boardbuf.txt");
      flock(boardfile, 2);
      seek boardfile, 0, 0;
      my @boardtemp = <boardfile>;
      truncate boardfile, 0;
      seek boardfile, 0, 0;

      foreach (@boardtemp)
      {
        ($idbuf, $typebuf, $titlebuf, $commentbuf, $avtorbuf, $messagecountbuf) = split(/\|/,$_);

        if($idbuf eq $setupthread)
        {
          if($typebuf ne 2)
          {
            $commentbuf = $threadcomment_new;
          }
          $_ = "$idbuf|$typebuf|$threadtitle_new|$commentbuf|$avtorbuf|$messagecountbuf|$nowtime|$Userid\n";
          last;
        }
      }
      print boardfile @boardtemp;
      close(boardfile);
    }

    $redirectto = "$site?mode=forum&board=$boardbuf";
    &html;
    exit;
  }

  &html;
  $threadtitle{$setupthread} =~ s/"/&quot;/gi;
  $threadcomment{$setupthread} =~ s/"/&quot;/gi;

  $razdel_buf = "<select name=razdel>";
  foreach (@indexofboards)
  {
    if(($category eq ""&$categoryofboard{$_} eq 0)&($visibleofboard{$_} eq 1 | $login eq 1))
    {
    }
    elsif(($category eq ""|($category ne ""&$categoryofboard{$_} eq $category))&($visibleofboard{$_} eq 1 | $login eq 1))
    {
      if($board eq $_)
      {
        $razdel_buf = "$razdel_buf<option selected>$_ : $titleofboard{$_}";
      }
      else
      {
        $razdel_buf = "$razdel_buf<option>$_ : $titleofboard{$_}";
      }
    }
 }
    $razdel_buf = "$razdel_buf</select>";

  if($ThreadHead eq 1)
  {$ThreadHead_buf = " checked"}else{$ThreadHead_buf = ""}

  print <<FORMA;
<div align="center"><font size="4">Настройки темы \"$threadtitle{$setupthread}\"</font></div><br>
<table border=0 cellspacing=0 cellpadding=2>
<form action="" method=post enctype="multipart/form-data">
<input name="mode" value="forum" type="hidden">
<input value="$setupthread" name="setupthread" type="hidden">
<input value="1" name="finish" type="hidden">
<tr>
<td>Название темы:</td>
<td><input type=text name=threadtitlenew size=36 value="$threadtitle{$setupthread}"></td>
</tr>
FORMA

  if($threadtype{$setupthread} ne 2)
  {
  print <<FORMA;
<tr>
<td>Описание темы:</td>
<td><input type=text name=threadcommentnew size=36 value="$threadcomment{$setupthread}"></td>
</tr>
FORMA
  }

  print <<FORMA;
<tr>
<td>Первое сообщение закреплено:</td>
<td><input type=checkbox name=threadheader$ThreadHead_buf></td>
</tr>
FORMA

  if((($usertype eq "модераторы")|($usertype eq "администраторы")))
  {
    if($threadclose{$thread} eq 1)
    {$threadclose_buf = " checked"}else{$threadclose_buf = ""}
    print <<FORMA;
<tr>
<td>Тема закрыта:</td>
<td><input type=checkbox name=threadclose$threadclose_buf></td>
</tr>
<tr>
<td>Раздел форума:</td>
<td>$razdel_buf</td>
</tr>
FORMA
  }
    print <<FORMA;
<tr>
<td colspan="2" align="center"><input style="background-color: rgb(224, 224, 224);" value="Отправить" type="submit"></td>
</tr>

</form></table>
FORMA

}

1;
