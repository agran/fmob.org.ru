sub mail_sen{
#  if($login ne 1){&netdostupa}

  $subj = param(subj);
  if(param(name) eq ""|param(mail) eq ""|$subj eq ""|param(message) eq "")
  {
    &mail_error;
  }

  if(param(subscribe)eq "1")
  {
    if(($usertype ne "модераторы")&($usertype ne "администраторы"))
    {
      &netdostupa;
    }
    ($buf, $subscribemails) = &get_subscribe_mails(1);
  }

  $message=param(message);
  $message =~ s/\n/<br>/g;

  if(param(predv)eq "Предварительный просмотр")
  {
    &mail_forma;
    &htmlend;
    exit;
  }

  $from = param(name);
  $from =~ s/&quot;/"/gi;

  if(param(subscribe)eq "1")
  {
    $to = "";
    $to2 = $subscribemails;
    $to1 = "";
    $to12 = "email-list";
  }
  else
  {
    $mail = param(mail);
    $mail =~ s/&quot;/"/gi;

    $from = "$from <$mail>";

    $to = &loadmail(param(to));

    $to1 = "$to";
    $to12 = "";
  }

  if(param(userid) ne "")
  {
    $useridbuf = Get_User_Name_by_id(param(userid));
    $to = "$useridbuf <$to>";
    $to2 = "";

    $to1 = "$to";
    $to12 = "";
  }

  &send_subscribe($message, $subj, $from, $to, $to2);

  open (mail_log, ">>mail_log.txt");
  flock(mail_log, 2);
  print mail_log "-=-=-=-[$nowtime]-=-=-=-\n";
  print mail_log "User: $UserName ($Userid)\n";
  print mail_log "IPadr: $ENV{REMOTE_ADDR}\n";
  print mail_log "From: $from\n";
  print mail_log "To: $to1\n";
  print mail_log "Bcc: $to12\n";
  print mail_log "Subject: $subj\n";
  if(param(subscribe)eq "1")
  {
    print mail_log "-=---------------------------------=-\n";
    $message=param(message);
    print mail_log "$message\n";
    print mail_log "-=---------------------------------=-\n";
  }
  print mail_log "-=-=-=-=-=-=-=-=[end]=-=-=-=-=-=-=-=-\n\n";
  close mail_log;

  print "<br><br><center><b>Сообщение отправлено.</b></center>";
  &htmlend;
  exit;
}

sub mail_forma{
  if($login ne 1){&netdostupa}

  $useridbuf1 = param(userid);

  if(param(subscribe)eq "1")
  {
    if(($usertype ne "модераторы")&($usertype ne "администраторы"))
    {
      &netdostupa;
    }
    ($subscribemailscon) = &get_subscribe_mails(1);
  }

  if(param(predv)eq "Предварительный просмотр")
  {
    $subj=param(subj);
    $subj =~ s/"/&quot;/gi;
    $message=param(message);
    $name=param(name);
    $name =~ s/"/&quot;/gi;
    $mail=param(mail);
    $mail =~ s/"/&quot;/gi;
  }

  if($useridbuf1 ne "")
  {
    $useridbuf = &Get_Formated_User_Name($useridbuf1);
  }
  else
  {$useridbuf = "";}

  if(param(subscribe) ne "1")
  {
    $text2 = &loadmail($to);
    $text2 = &text_process($text2);
    if($useridbuf ne "")
    {$text2 = " &lt;$text2&gt;";}
    $text2 ="<tr><td nowrap>Адресат:</td><td>$useridbuf$text2</td></tr>";
  }

  if(param(subscribe)eq "1")
  {
    $textNameBuf = "<tr><td nowrap>Отправитель:</td><td>subscribe\@fmob.org.ru</td></tr>
<input type=\"hidden\" name=\"name\" value=\"subscribe\@fmob.org.ru\">
<input type=\"hidden\" name=\"subscribe\" value=\"1\">";
    $textMailBuf = "<input type=\"hidden\" name=\"mail\" value=\"subscribe\@fmob.org.ru\">";
    $text2 ="<tr><td nowrap>Адресат:</td><td>Подписчики ($subscribemailscon) на получение окончательного сценария будущего моба</td></tr>";
    $subj = "Окончательный сценарий будущего моба";
  }
  elsif($login eq 1)
  {
    open (userinfo, "<users\/$Userid.txt");
    flock(userfile, 1);
    @userinfo = <userinfo>;
    close userinfo;
    chomp $userinfo[4];

    $textToBuf = "<input type=\"hidden\" name=\"userid\" value=\"$useridbuf1\">";

    if($userinfo[4] eq "")
    {
      $UserNameBuf = $UserName;
      $UserNameBuf =~ s/"/&quot;/gi;
      $textNameBuf = "<tr><td nowrap>Ваше имя:</td><td>$UserName</td></tr>
<input type=\"hidden\" name=\"name\" value=\"$UserNameBuf\">";

      $textMailBuf = "<tr>
<td nowrap>Ваш E-mail:</td>
<td><input type=text size=16 name=mail value=\"$mail\"></td>
</tr>";
    }
    else
    {
      $textNameBuf = "<tr><td nowrap>Отправитель:</td><td>$UserName &lt;$userinfo[4]&gt;</td></tr>
<input type=\"hidden\" name=\"name\" value=\"$UserName\">";

      $textMailBuf = "<input type=\"hidden\" name=\"mail\" value=\"$userinfo[4]\">";
    }
  }
  else
  {
  $textNameBuf = "<tr>
<td nowrap>Ваше имя:</td>
<td><input type=text size=16 name=name value=\"$name\"></td>
</tr>";
  $textMailBuf = "<tr>
<td nowrap>Ваш E-mail:</td>
<td><input type=text size=16 name=mail value=\"$mail\"></td>
</tr>";
  }

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<div align=center><b><font size=4>Форма для отправки сообщения</font></b><br><br>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=sendmail&to=$to" method=POST name=post>
<input type="hidden" name="action" value=send>
<input type="hidden" name="mode" value=sendmail>
<input type="hidden" name="to" value=$to>
$textToBuf
$text2
$textNameBuf
$textMailBuf
<tr>
    <td nowrap>Тема сообщения:</td>
    <td><input type=text size=80 name=subj value="$subj"></td>
</tr>
<tr>
    <td valign=bottom>Ваше сообщение:</td>
FORMA

&textinput;

print <<FORMA;
<tr>
    <td align=center><input type=submit value=Отправить tabindex="4"></td>
    <td align=right><input type=submit name="predv" value="Предварительный просмотр" tabindex="5"></td>
</tr>
</tr>
</form></table>
FORMA

  if(param(predv)eq "Предварительный просмотр")
  {
    print "<table border=0 width=100% cellpadding=4>";
    print "<tr>";
    print "<td></td>";
    print "<td colspan=2><b>Предварительный просмотр:</b></td>";
    print "</tr>";
    print "<tr>";
    print "<td width=20></td>";
    print "<td colspan=2 bgcolor=#F7F7F7>";
    print &text_process($message);
    print "</td>";
    print "<td width=20></td>";
    print "<tr>";
    print "</table>";
  }
}

sub loadmail{
  open(mails, "<hide_mails.txt");
  flock(mails, 1);
  $nashol=0;
  $mailidbuf=0;
  @mails1 = <mails>;
  if (@mails1>0)
  {
    foreach $mails2 (@mails1)
    {
      ($mail3, $mailid) = split(/::/,$mails2);
      if ($mailid eq "@_[0]\n")
      {
        $nashol=1;
        return $mail3;
      }
    }
  }
  if ($nashol eq 0)
  {
    print "<center><b>Не найден адресат.</b></center>";
    &htmlend;
    exit;
  }
  close (mails);
}

sub savemail{

  open(mails, "+<hide_mails.txt");
  flock(mails, 2);
  @mails1 = <mails>;
  $mailsnum = @mails1;
  $nashol=0;
  $mailidbuf=0;
  $buf=lc($_[0]);

  if (@mails1>0)
  {
    foreach (@mails1)
    {
      $mails2 = $_;
      chomp $mails2;
      ($mail3, $mailid) = split(/::/,$mails2);
      if ($mail3 eq $buf)
      {
        close (mails);
        $nashol=1;
        return $mailid;
      }
    }
  }

  if ($nashol eq 0)
  {
    seek (mails, 0, 0);
    $mails1[$mailsnum]="$buf\:\:$mailsnum\n";
    print mails @mails1;
    close (mails);
    return $mailsnum;
  }
  else
  {close (mails);}
}

sub mail_error{
  print "<br><br><center><b>Необходимо заполнить все поля.</b><br>";
  print "<a href=\"javascript:history.back();\">Вернуться назад...</a></center>";
  &htmlend;
  exit;
}

sub send_subscribe{

  $FromBuf = $_[2];
  if($FromBuf eq "")
  {$FromBuf = "subscribe\@fmob.org.ru"}

  $ToBuf = $_[3];
  if($ToBuf eq "")
  {$ToBuf = "subscribe\@fmob.org.ru"}

  $BCCBuf = $_[4];

  $msg = MIME::Lite->new(
         From     =>$FromBuf,
         Return-Path => $FromBuf,
         Reply-To => $FromBuf,
         To       =>$ToBuf,
         BCC      =>$BCCBuf,
         Subject  =>$_[1],
         Type    =>'multipart/mixed'
         );

  $msg->add('Precedence' => 'bulk');

  $mailbuf = &text_process($_[0], 1);

  $mailbuf ="<style type=\"text/css\">
<!--
body { font-size: 13px; font-family: Tahoma; background: #f7f7f7; align: center}
td {font-size: 13px; font-family: Tahoma; align: center}
a, a:visited, a:active, a:hover { text-decoration: underline; color: black;}
a:hover {color: #606060;}
.tableq1 {width: 99%; padding: 2px 0px 3px 0px; border: 0px;}
.qbackb {background-color: #333333;}
.qbackr1 {background-color: #E7E7E7}
.qbackr2 {background-color: #F7F7F7}
input, select, textarea { border:1px solid #000000; font-family: Tahoma; font-size: 13px; padding-left:2px; padding-right:2px;}
#CODE {padding:2px; font-family: Courier New, Courier, Verdana, Arial; color: #000000; background-color: #FFFFFF; border: 1px solid #000000;}
-->
</style>
$mailbuf
";

  $msg->attach(
        Type     =>'text/html',
        Data     =>$mailbuf,
        );

 $msg->send;
}

1;