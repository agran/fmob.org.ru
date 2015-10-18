sub subscribe_sen{
  if($login ne 1){&netdostupa}

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

  if(param(subscribetype) eq 3)
  {
    $to2 = param(subscribemailssms);
    @tolist = split(/\, /, $to2);
    foreach (@tolist)
    {
      open(MAIL,"|$mailprog -t");
      print MAIL "To: $_\n";
      print MAIL "From: $name <sms\@fmob.org.ru>\n";
      print MAIL "Return-Path: <sms\@fmob.org.ru>\n";
      print MAIL "Reply-To: <sms\@fmob.org.ru>\n";
      print MAIL "Content-type:text/plain;charset=windows-1251\n";
      print MAIL "Subject: $subj\n\n";
      print MAIL "$message\n\n";
      close (MAIL);
      print "$_<br>\n";
      sleep 3;
    }
    $to2 = 'SMS-list';
    $to = 'SMS-list';

  }
  elsif(param(subscribetype) eq 1)
  {
    $to2 = param(subscribemails1);

    &send_subscribe($message, $subj, $from, "", $to2);
    $to2 = 'email-list';
    $to = 'email-list';
  }

  open (mail_log, ">>mail_log.txt");
  flock(mail_log, 2);
  print mail_log "-=-=-=-[$nowtime]-=-=-=-\n";
  print mail_log "User: $UserName ($Userid)\n";
  print mail_log "IPadr: $ENV{REMOTE_ADDR}\n";
  print mail_log "From: $from\n";
  print mail_log "To: $to\n";
  print mail_log "Bcc: $to2\n";
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

sub subscribe_forma{
  if($login ne 1){&netdostupa}

  $useridbuf1 = param(userid);

  if(!(($usertype eq "модераторы")|($usertype eq "администраторы")|($login eq 1)))
  {
    &netdostupa;
  }

  ($subscribemailscon0, $subscribemails0) = &get_subscribe_mails(0);
  ($subscribemailscon1, $subscribemails1) = &get_subscribe_mails(1);
  ($subscribemailscon2, $subscribemails2) = &get_subscribe_mails(2);
  ($subscribemailscon3, $subscribemails3) = &get_subscribe_mails(3);
  ($subscribemailssmscon, $subscribemailssms) = &get_subscribe_mails(4);

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

  $useridbuf = "";

  $textNameBuf = "<tr><td nowrap>Отправитель:</td><td>subscribe\@fmob.org.ru</td></tr>
<input type=\"hidden\" name=\"name\" value=\"subscribe\@fmob.org.ru\">
<input type=\"hidden\" name=\"subscribe\" value=\"1\">";
  $textMailBuf = "<input type=\"hidden\" name=\"mail\" value=\"subscribe\@fmob.org.ru\">";
  $subj = "Окончательный сценарий будущего моба";

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<div align=center><b><font size=4>Управление рассылками</font></b><br>
<a href=$site?mode=subscribe&action=sent>Отправленные</a>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=subscribe" method=POST name=post>
<input type="hidden" name="action" value=send>
<input type="hidden" name="mode" value=subscribe>
<input type="hidden" name="to" value=$to>
$textToBuf
<tr><td colspan=2>Подписчиков на получение новых сценариев: <b>$subscribemailscon2</b>.</td></tr>
<tr><td colspan=2>Подписчиков на получение новых сообщений на форуме: <b>$subscribemailscon3</b>.</td></tr>
<tr><td colspan=2>Подписчики (<b>$subscribemailscon1</b>) на получение окончательного сценария будущего моба:</td></tr>
<tr><td colspan=2><textarea name=subscribemails1 rows=3 cols=100 tabindex="4" >$subscribemails1</textarea></td></tr>
<tr><td colspan=2>Подписчики sms-рассылки (<b>$subscribemailsconbad</b>):</td></tr>
<tr><td colspan=2><textarea name=subscribemailssmsbad rows=3 cols=100 tabindex="4" >$subscribemailsbad</textarea></td></tr>
<tr><td colspan=2 align=right><a href=$site?mode=subscribe&action=smslist>Редактировать список sms-подписчиков</a></td></tr>

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
$subscribemailssmscon = int ($subscribemailssmscon / 60);
print <<FORMA;
<tr><td colspan=2>Тип рассылки:</td></tr>
<tr><td colspan=2><input type="radio" name="subscribetype" value="1" checked="checked"> Окончательный сценарий</td></tr>
td></tr>
<tr><td></tr>
<tr>
    <td align=center><input type=submit style=\"background-color: $tseriy;\" value=Отправить tabindex="4"></td>
    <td align=right><input type=submit style=\"background-color: $tseriy;\" name="predv" value="Предварительный просмотр" tabindex="5"></td>
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
    print "<td colspan=2 bgcolor=$sseriy>";
    print &text_process($message);
    print "</td>";
    print "<td width=20></td>";
    print "<tr>";
    print "</table>";
  }
}

sub get_subscribe_mails{
  my $subscribe_n = $_[0];
  my $subscribemails = "";
  my $subscribemailscon, $i = 0;
  my @subscribemailsbuf;

  if($subscribe_n eq ""){return}

  if($subscribe_n eq 4)
  {
    open (subscribefile, "<sms.txt");
    flock(subscribefile, 1);
    @subscribemailsbuf = <subscribefile>;
    close subscribefile;
    $subscribemailsbad = "";
    $subscribemailsconbad = 0;
    foreach (@subscribemailsbuf)
    {
      chomp $_;
      ($namebuf, $numerbuf, $ipbuf, $commentbuf) = split(/\|/,$_);

      $subscribemailsbad = "$subscribemailsbad\"$namebuf\" $numerbuf\n";
      $subscribemailsconbad++;

    }
    substr($subscribemails,-2)="";
    return ($subscribemailscon, $subscribemails)
  }

  open (subscribefile, "<subscribe_$subscribe_n.txt");
  flock(subscribefile, 1);
  @subscribemailsbuf = <subscribefile>;
  close subscribefile;

  foreach (@subscribemailsbuf)
  {
    $i++;
    chomp $_;
    if($_ ne "")
    {
      $subscribemails = "$subscribemails\"". &Get_User_Name_by_id($i) ."\" <$_>, ";
      $subscribemailscon++;
    }
  }

  substr($subscribemails,-2)="";
  return ($subscribemailscon, $subscribemails)
}

sub sent_list{
  open (mail_log, "<mail_log.txt");
  flock(mail_log, 1);
  @mail_log = <mail_log>;
  close mail_log;
  for(@mail_log)
  {
    $_ =~ s/</&lt;/gi;
    $_ =~ s/>/&gt;/gi;
    print "$_<br>";
  }
}

sub smslist{
  if(param(action2) eq "Удалить")
  {
    open (NEW,">sms_buf.txt");
    open (OLD,"sms.txt");
    $i=0;
    while (<OLD>)
    {
      $i++;
      if(param($i) ne "on")
      {
        print NEW $_;
      }
    }
    close(OLD);
    close(NEW);
    rename("sms.txt", "sms_old_$Userid.txt");
    rename("sms_buf.txt", "sms.txt");
  }
  open (SMS_FILE, "<sms.txt");
  flock(SMS_FILE, 1);
  @smslist = <SMS_FILE>;
  close SMS_FILE;
  print "<form action=$site?mode=subscribe&action=smslist method=POST>\n";
  print "<input type=hidden name=mode value=subscribe>\n";
  print "<input type=hidden name=action value=smslist>\n";

  print "<table border=0 cellpadding=4 align=center >\n";
  print "<tr><td colspan=6 align=center><b><font size=4>Подписчики sms-рассылки</font></b></td></tr>\n";
  print "<tr><td colspan=6>Обозначения:  <font color=red>Красным, если повторяются</font>";
  print "<tr><td>№<td><td>Имя<td>Телефон<td>IP<td>Коментарий";
  $i=0;
  for(@smslist)
  {
    ($usernamebuf, $numbuf, $ipbuf, $combuf) = split(/\|/,$_);
    $numpovtorbuf{$numbuf}++;
  }

  for(@smslist)
  {
    $i++;
    ($usernamebuf, $numbuf, $ipbuf, $combuf) = split(/\|/,$_);
    if($numpovtorbuf{$numbuf}>1){$numbuf = "<font color=red>$numbuf"}
    else{$numbuf = "<font color=#408080>$numbuf"}
    $numpovtorbuf{$usernamebuf}++;

    if($numpovtorbuf{$usernamebuf}>1)
    {$usernamebuf = "<b>$numpovtorbuf{$usernamebuf}</b> $usernamebuf"}

    print "<tr bgcolor=$sseriy><td>$i<td><input type=checkbox name=$i><td>$usernamebuf<td>$numbuf<td>$ipbuf<td>$combuf";
  }
  print "<tr bgcolor=$sseriy><td colspan=6><input type=submit style=\"background-color: $tseriy;\" name=action2 value=Удалить>";
  print "</table></form>\n";
}

1;
