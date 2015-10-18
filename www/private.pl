sub show_index{

  open (privateindex, "<privates/$Userid/index.txt");
  flock(privateindex, 1);
  @privateindex = <privateindex>;
  close privateindex;

  for(@privateindex)
  {chomp $_}

  print "<table width=\"780\" border=\"0\" cellpadding=\"4\">";
  print "<tr bgcolor=$seriy><td colspan=2 height=28 width=80% align=left><b><a href=$site?mode=private>Личные сообщения<td width=20% align=reight><b><a href=$site?mode=private&action=new>Написать сообщение";
  print "<tr><td width=20%><td 60%>";

  print "<table width=\"100%\" border=\"0\" cellpadding=\"4\">";

  if(@privateindex ne 0)
  {
    print "<tr bgcolor=$tseriy><td><b>Папка<td width=\"10%\"><b>Новых<td width=\"10%\"><b>Всего";
    ($typebuf, $all, $new)=split(/\|/,$privateindex[0]);
    if($new ne 0)
    {$newbuf = "<b>$new</b>"}
    else
    {$newbuf = "&nbsp;"}
    $buf2 = "";
    if($all>0)
    {
      $buf2 = "<a href=$site?mode=private&folder=inbox>"
    }
    print "<tr bgcolor=$sseriy><td><b>$buf2Входящие<td align=center>$newbuf<td  align=center>$all";
    ($typebuf, $all)=split(/\|/,$privateindex[1]);
    $buf2 = "";
    if($all>0)
    {
      $buf2 = "<a href=$site?mode=private&folder=send>"
    }
    print "<tr bgcolor=$sseriy><td><b>$buf2Исходящие<td align=center>&nbsp;<td align=center>$all";
    ($typebuf, $all)=split(/\|/,$privateindex[2]);
    $buf2 = "";
    if($all>0)
    {
      $buf2 = "<a href=$site?mode=private&folder=del>"
    }
    print "<tr bgcolor=$sseriy><td><b>$buf2Удалённые<td align=center>&nbsp;<td align=center>$all";
  }
  else
  {
    print "<tr><td align=center><b><font size=4>Сообщений нет";
  }
  print "</table><td width=30%></tr></table>";
}

sub show_inbox{

  if(param(action2) eq "Удалить")
  {
    open (NEW,">privates/$Userid/inbox_buf.txt");
    open (OLD,"privates/$Userid/inbox.txt");
    $new = 0;
    $all = 0;
    $delnew = 0;
    while (<OLD>)
    {
      ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);
      if(param($idbuf) ne "on")
      {
        print NEW $_;
        $all++;
        if($newbuf eq "1\n")
        {
          $new++;
        }
      }
      else
      {
        $delnew++;

        open(delfile, "+<privates/$Userid/del.txt") || open(delfile, ">privates/$Userid/del.txt");
        flock(delfile, 2);
        seek delfile, 0, 0;
        @delfilebuf=<delfile>;
        truncate delfile, 0;
        seek delfile, 0, 0;
        print delfile qq~$idbuf|$avtorbuf|$zagolovok|$datebuf|$Userid\n~;
        print delfile @delfilebuf;
        close (delfile);

      }
    }
    close(OLD);
    close(NEW);
    rename("privates/$Userid/inbox.txt", "privates/$Userid/inbox_old.txt");
    rename("privates/$Userid/inbox_buf.txt", "privates/$Userid/inbox.txt");

    open(indexfile, "+<privates/$Userid/index.txt");
    flock(indexfile, 2);
    seek indexfile, 0, 0;
    @indexfilebuf=<indexfile>;
    for(@indexfilebuf)
    {chomp $_}
    truncate indexfile, 0;
    seek indexfile, 0, 0;
    print indexfile qq~inbox|$all|$new\n~;
    print indexfile qq~$indexfilebuf[1]\n~;
    ($typebuf, $allbuf)=split(/\|/,@indexfilebuf[2]);
    $allbuf = $delnew + $allbuf;
    print indexfile qq~$typebuf|$allbuf\n~;
    close (indexfile);
  }

  open (privateindex, "<privates/$Userid/inbox.txt");
  flock(privateindex, 1);
  @privateindex = <privateindex>;
  close privateindex;

  for(@privateindex)
  {chomp $_}

  $buf = @privateindex;
  $pagebuf = &buildpegelist($buf, $page, $messonpage, "$site?mode=private&folder=inbox&page=");

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<form action=$site?mode=private&folder=inbox method=POST name="main">
<input type=hidden name=mode value=private>
<input type=hidden name=folder value=inbox>
<table width=\"780\" border=\"0\" cellpadding="4">
<tr bgcolor=$seriy><td colspan=5 height=28 width=80% align=left><b><a href=$site?mode=private>Личные сообщения</b></a> :: <b><a href=$site?mode=private&folder=inbox>Входящие<td width=20% align=right colspan=2><b><a href=$site?mode=private&action=new>Написать сообщение
<tr bgcolor=$sseriy><td colspan=7>$pagebuf
<tr bgcolor=$tseriy><td><td>

<script language="JavaScript">
<!--
document.write('<input type="checkbox" onclick="SelectAll(checked)">');
// -->
</script>
<td><b>ID<td><b>Тема<td><b>Отправитель<td><b>Размер<td><b>Время
FORMA
  $num = 0;
  for(@privateindex)
  {
    $num ++;
    if($num < ($page-1)*$messonpage+1|$num > $page*$messonpage){next}
    ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);

    $sb = stat("privates/$Userid/$idbuf.txt");
    $buf = $sb->size;

    if($zagolovok eq "")
    {
      $zagolovok = "(Без темы)";
    }
    $avtorbuf2=&Get_Formated_User_Name($avtorbuf);
    if($newbuf eq 1)
    {
      print "<tr bgcolor=$seriy><td width=1%><b>$num<td width=1%><input type=checkbox name=$idbuf><td width=1%><b><a href=$site?mode=private&folder=inbox&id=$idbuf>$idbuf<td><b><a href=$site?mode=private&folder=inbox&id=$idbuf>$zagolovok<td width=10%><b>$avtorbuf2<td width=1% nowrap align=right><b>$buf<td width=20% nowrap><b>$datebuf";
    }
    else
    {
      print "<tr bgcolor=$sseriy><td width=1%>$num<td width=1%><input type=checkbox name=$idbuf><td width=1%><a href=$site?mode=private&folder=inbox&id=$idbuf>$idbuf<td><a href=$site?mode=private&folder=inbox&id=$idbuf>$zagolovok<td width=17%>$avtorbuf2<td width=1% nowrap align=right>$buf<td width=20% nowrap>$datebuf";
    }
  }

  print "<tr bgcolor=$sseriy><td colspan=7>$pagebuf";
  print "<tr bgcolor=$sseriy><td colspan=7><input type=submit style=\"background-color: $tseriy;\" name=action2 value=Удалить>";
  print "</table></form>";
}

sub show_send{
  if(param(action2) eq "Удалить")
  {
    open (NEW,">privates/$Userid/send_buf.txt");
    open (OLD,"privates/$Userid/send.txt");
    $new = 0;
    $all = 0;
    $delnew = 0;
    while (<OLD>)
    {

      ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);
      if(param($idbuf) ne "on")
      {
        print NEW $_;
        $all++;
        if($newbuf eq "1\n")
        {
           $new++;
        }
      }
      else
      {
        $delnew++;

        open(delfile, "+<privates/$Userid/del.txt") || open(delfile, ">privates/$Userid/del.txt");
        flock(delfile, 2);
        seek delfile, 0, 0;
        @delfilebuf=<delfile>;
        truncate delfile, 0;
        seek delfile, 0, 0;
        print delfile qq~$idbuf|$Userid|$zagolovok|$datebuf|$avtorbuf\n~;
        print delfile @delfilebuf;
        close (delfile);

      }
    }
    close(OLD);
    close(NEW);
    rename("privates/$Userid/send.txt", "privates/$Userid/send_old.txt");
    rename("privates/$Userid/send_buf.txt", "privates/$Userid/send.txt");

    open(indexfile, "+<privates/$Userid/index.txt");
    flock(indexfile, 2);
    seek indexfile, 0, 0;
    @indexfilebuf=<indexfile>;
    for(@indexfilebuf)
    {chomp $_}
    truncate indexfile, 0;
    seek indexfile, 0, 0;
    print indexfile qq~$indexfilebuf[0]\n~;
    print indexfile qq~inbox|$all|$new\n~;
    ($typebuf, $allbuf)=split(/\|/,@indexfilebuf[2]);
    $allbuf = $delnew + $allbuf;
    print indexfile qq~$typebuf|$allbuf\n~;
    close (indexfile);
  }

  open (privatesend, "<privates/$Userid/send.txt");
  flock(privatesend, 1);
  @privatesend = <privatesend>;
  close privatesend;

  for(@privatesend)
  {chomp $_}

  $buf = @privatesend;
  $pagebuf = &buildpegelist($buf, $page, $messonpage, "$site?mode=private&folder=send&page=");

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<form action=$site?mode=private&folder=send method=POST name="main">
<input type=hidden name=mode value=private>
<input type=hidden name=folder value=send>
<table width=\"780\" border=\"0\" cellpadding="4">
<tr bgcolor=$seriy><td colspan=5 height=28 width=80% align=left><b><a href=$site?mode=private>Личные сообщения</b></a> :: <b><a href=$site?mode=private&folder=send>Исходящие<td width=20% align=right colspan=2><b><a href=$site?mode=private&action=new>Написать сообщение
<tr bgcolor=$sseriy><td colspan=7>$pagebuf
<tr bgcolor=$tseriy><td><td>

<script language="JavaScript">
<!--
document.write('<input type="checkbox" onclick="SelectAll(checked)">');
// -->
</script>
<td><b>ID<td><b>Тема<td><b>Получатель<td><b>Размер<td><b>Время
FORMA
  $num = 0;
  for(@privatesend)
  {
    $num ++;
    if($num < ($page-1)*$messonpage+1|$num > $page*$messonpage){next}

    ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);

    $sb = stat("privates/$Userid/$idbuf.txt");
    $buf = $sb->size;

    if($zagolovok eq "")
    {
      $zagolovok = "(Без темы)";
    }
    $avtorbuf2=&Get_Formated_User_Name($avtorbuf);
    print "<tr bgcolor=$sseriy><td width=1%>$num<td width=1%><input type=checkbox name=$idbuf><td width=1%><a href=$site?mode=private&folder=send&id=$idbuf>$idbuf<td><a href=$site?mode=private&folder=send&id=$idbuf>$zagolovok<td width=17%>$avtorbuf2<td width=1% nowrap align=right>$buf<td width=20% nowrap>$datebuf";
  }
  print "<tr bgcolor=$sseriy><td colspan=7>$pagebuf";
  print "<tr bgcolor=$sseriy><td colspan=7><input type=submit style=\"background-color: $tseriy;\" name=action2 value=Удалить>";
  print "</table></form>";
}

sub show_del{

  if(param(action2) eq "Удалить")
  {
    open (NEW,">privates/$Userid/del_buf.txt");
    open (OLD,"privates/$Userid/del.txt");
    $all = 0;
    while (<OLD>)
    {
      ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);
      if(param($idbuf) ne "on")
      {
        print NEW $_;
        $all++;
      }
      else
      {
        $outfile = "privates/$Userid/$idbuf.txt";
        unlink($outfile);
      }
    }
    close(OLD);
    close(NEW);
    rename("privates/$Userid/del.txt", "privates/$Userid/del_old.txt");
    rename("privates/$Userid/del_buf.txt", "privates/$Userid/del.txt");


    open(indexfile, "+<privates/$Userid/index.txt");
    flock(indexfile, 2);
    seek indexfile, 0, 0;
    @indexfilebuf=<indexfile>;
    for(@indexfilebuf)
    {chomp $_}
    truncate indexfile, 0;
    seek indexfile, 0, 0;
    print indexfile qq~$indexfilebuf[0]\n~;
    print indexfile qq~$indexfilebuf[1]\n~;
    print indexfile qq~del|$all\n~;
    close (indexfile);
  }

  open (privatedel, "<privates/$Userid/del.txt");
  flock(privatedel, 1);
  @privatedel = <privatedel>;
  close privatedel;

  for(@privatedel)
  {chomp $_}

  $buf = @privatedel;
  $pagebuf = &buildpegelist($buf, $page, $messonpage, "$site?mode=private&folder=del&page=");

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<form action=$site?mode=private&folder=del method=POST name="main">
<input type=hidden name=mode value=private>
<input type=hidden name=folder value=del>
<table width=\"780\" border=\"0\" cellpadding="4">
<tr bgcolor=$seriy><td colspan=6 height=28 width=80% align=left><b><a href=$site?mode=private>Личные сообщения</b></a> :: <b><a href=$site?mode=private&folder=del>Удалённые<td width=20% align=right colspan=2><b><a href=$site?mode=private&action=new>Написать сообщение
<tr bgcolor=$sseriy><td colspan=7>$pagebuf
<tr bgcolor=$seriy><td><td>

<script language="JavaScript">
<!--
document.write('<input type="checkbox" onclick="SelectAll(checked)">');
// -->
</script>
<td><b>ID<td><b>Тема<td><b>Отправитель<td><b>Получатель<td><b>Размер<td><b>Время
FORMA

  $num = 0;
  for(@privatedel)
  {
    $num++;

    if($num < ($page-1)*$messonpage+1|$num > $page*$messonpage){next}

    ($idbuf, $avtorbuf, $zagolovok, $datebuf, $toid) = split(/\|/,$_);

    $sb = stat("privates/$Userid/$idbuf.txt");
    $buf = $sb->size;

    if($zagolovok eq "")
    {
      $zagolovok = "(Без темы)";
    }
    $avtorbuf2=&Get_Formated_User_Name($avtorbuf);
    $toid2=&Get_Formated_User_Name($toid);
    print "<tr bgcolor=$sseriy><td width=1%>$num<td width=1%><input type=checkbox name=$idbuf><td width=1%><a href=$site?mode=private&folder=del&id=$idbuf>$idbuf<td><a href=$site?mode=private&folder=del&id=$idbuf>$zagolovok<td width=17%>$avtorbuf2<td width=17%>$toid2<td width=1% nowrap align=right>$buf<td width=20% nowrap>$datebuf";
  }
  print "<tr bgcolor=$sseriy><td colspan=7>$pagebuf";
  print "<tr bgcolor=$sseriy><td colspan=8><input type=submit style=\"background-color: $tseriy;\" name=action2 value=Удалить>";
  print "</table></form>";
}

sub show_mess{
  open (privateindex, "<privates/$Userid/$messid.txt");
  flock(privateindex, 1);
  @privateindex = <privateindex>;
  close privateindex;

  $heder = $privateindex[0];


  ($avtorbuf, $zagolovok, $datebuf) = split(/\|/,$heder);
  $avtor = $avtorbuf;

  if($zagolovok eq "")
  {
    $zagolovok = "(Без темы)";
  }

  $message = $privateindex[1];
  $message =~ s/<br>/\n/g;

  $messagetextbuf = &text_process($message);

  &get_avtor_info;

  if($folder eq "inbox")
  {
    $foldertemp = "Входящие";
  }
  elsif($folder eq "del")
  {
    $foldertemp = "Удалённые";
  }
  elsif($folder eq "send")
  {
    $foldertemp = "Исходящие";
  }

    print <<FORMA;
<a name="T"></a>
<div align="center">
<b><font size="4">Личное сообщение</font></b>

<table width="780" border="0" cellpadding="4">
<tr><td colspan=4 align=right><b><a href=$site?mode=private&action=new>Написать сообщение</a> &nbsp; <b><a href=$site?mode=private&action=new&id=$messid>Ответить
<tr bgcolor=$seriy><td colspan=4 height=28 align=left><b><a href=$site?mode=private>Личные сообщения</b></a> :: <b><a href=$site?mode=private&folder=$folder>$foldertemp</b></a> :: <b><a href=$site?mode=private&folder=$folder&id=$messid>$zagolovok
<tr bgcolor="$seriy">
<td width="17%" align="center"><a name=$_></a>$user_name_buf1</td>
<td colspan=3 align="left">$datebuf</td>
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
FORMA

  open(inboxfile, "+<privates/$Userid/inbox.txt") || open(inboxfile, ">privates/$Userid/inbox.txt");
  flock(inboxfile, 2);
  seek inboxfile, 0, 0;
  @inboxfilebuf = <inboxfile>;
  truncate inboxfile, 0;
  seek inboxfile, 0, 0;

  $newbuf2 = 0;
  for(@inboxfilebuf)
  {
    ($idbuf, $avtorbuf, $zagolovok, $datebuf, $newbuf) = split(/\|/,$_);
    if(($idbuf eq $messid)&($newbuf eq "1\n"))
    {
      $_ = "$idbuf|$avtorbuf|$zagolovok|$datebuf|0\n";
      $newbuf2 = 1;
    }
  }
  print inboxfile @inboxfilebuf;
  close (inboxfile);

  if($newbuf2 eq 1)
  {
    open(indexfile, "+<privates/$Userid/index.txt");
    flock(indexfile, 2);
    seek indexfile, 0, 0;
    @indexfilebuf=<indexfile>;
    for(@indexfilebuf)
    {chomp $_}
    truncate indexfile, 0;
    seek indexfile, 0, 0;
    ($typebuf, $all, $new)=split(/\|/,@indexfilebuf[0]);
    $new--;
    print indexfile qq~inbox|$all|$new\n~;;
    print indexfile qq~$indexfilebuf[1]\n~;;
    print indexfile qq~$indexfilebuf[2]\n~;;
    close (indexfile);
  }
}


sub show_new{

  $toid = param(toid);
  $id = param(id);

  if (param(predv) eq "Предварительный просмотр")
  {
    $message = readparam(message);
    $subj = readparam(subj);
    $to = readparam(to);
  }
  else
  {
  if($id ne "")
  {
    open (privateindex, "<privates/$Userid/$id.txt");
    flock(privateindex, 1);
    @privateindex = <privateindex>;
    close privateindex;

    $heder = $privateindex[0];
    chomp $heder;
    ($avtorbuf, $zagolovok, $datebuf) = split(/\|/,$heder);

    $subj = "Re: $zagolovok";

    $to = &Get_User_Name_by_id($avtorbuf);

    $message = $privateindex[1];
    $message =~ s/<br>/\n/g;
    $message = "Hi, \[b\]$to\[/b\].\nВы писали $datebuf :\n\[quote\]$message\[/quote\]";

    $to = "$to; ";
  }

  if($toid ne "")
  {
    $to = &Get_User_Name_by_id($toid);
    $to = "$to; ";
  }
  }

  print <<FORMA;
<a name="T"></a>
<div align="center">
<table width="780" border="0" cellpadding="4">
<tr bgcolor=$seriy><td colspan=4 height=28 align=left width=80%><b><a href=$site?mode=private>Личные сообщения</b></a> :: <b><a href=$site?mode=private&action=new>Написать сообщение
</table>
FORMA

  if (param(predv) eq "Предварительный просмотр")
  {
    $messagebuf = $message;
    $messagetextbuf = &text_process($message);
    $messagebuf =~ s/\n/<br>/g;

    print <<FORMA;
<br>
<table width="636" border="0" cellpadding="4">
<tr bgcolor="$tseriy">
<td><b>Предварительный просмотр:</td>
</tr>
<tr bgcolor="$sseriy" valign=top>
<td>$messagebuf</td></tr>
</table>
<br>

FORMA



  }

  print <<FORMA;
<script type="text/javascript" src="$site/bbCode.js"></script>
<div align=center><b><font size=4>Форма для отправки сообщения</font></b><br><br>
<script language="javascript1.2" type="text/javascript">
<!--
function emo_pop2()
{
  window.open('?mode=mobbereslist','Legends','width=300,height=500,resizable=yes,scrollbars=yes');
}
        //-->
</script>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=private" method=POST name=post onsubmit="close_pop()">
<input type="hidden" name="action" value=send>
<input type="hidden" name="mode" value=private>
<tr>
    <td nowrap>Получатель:</td>
    <td><input type=text size=70 name=to value="$to">
    <a href="javascript:emo_pop2()">Выбрать</a>
    </td>
</tr>
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
    <td align=center><input type=submit style=\"background-color: $tseriy;\" value=Отправить></td>
    <td align=right><input type=submit style=\"background-color: $tseriy;\" name="predv" value="Предварительный просмотр"></td>
</tr>
</tr>
</form></table>
FORMA
}

sub mobbereslist{
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;

  print header(-charset=>"windows-1251");
  print <<FORMA;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href=main.css type=text/css rel=stylesheet>
<title>Мобберы</title>
</head>
<script language='javascript'>
<!--
        function add_mobber_id(mobber_id)
        {
          mobber_id += "; ";
          var txtarea = opener.document.post.to;
          txtarea.value  += mobber_id;
          txtarea.focus();
        }
//-->
</script>
<body topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0>
<table cellspacing='2' cellpadding='4' width='100%'>
<tr bgcolor=$tseriy>
<td width='10%' align='center' valign='middle'><b>ID</b></td>
<td width='90%' align='center' valign='middle'><b>Ник</b></td>
</tr>
FORMA

  $i=0;
  foreach (@users)
  {
    $i++;
    if(substr($_, 0, 1) eq ";"){next}
    chomp $_;

    print "<tr bgcolor=$sseriy>";
    print "<td>$i";
    print "<td><b><a href='javascript:add_mobber_id(\"$_\")'>$_";
  }
  print "</table>";
  print "</body>";
  print "</html>";

  exit;
}

sub send_private{

  if (param(predv) eq "Предварительный просмотр")
  {
    &show_new;

  }
  else
  {
    $messagebuf = readparam(message);
    $messagebuf =~ s/\n/<br>/g;

    $subjectbuf = readparam(subj);
    $subjectbuf =~ s~\|~&#124;~g;


    open (userstxt, "<users/users.txt");
    flock(userstxt, 1);
    @users = <userstxt>;
    close userstxt;

    $i=0;
    foreach (@users)
    {
      $i++;
      chomp $_;
      $_ = lc($_);
      $usersnik{$_}=$i;
      $userssend{$_}=0;
    }

    $to = lc(param(to));

    if(substr($to,-1) eq " "){substr($to,-1) = ""}

    @tos = split(/;/,$to);

    foreach (@tos)
    {
      if(substr($_,-1) eq " "){substr($_,-1) = ""}
      if(substr($_,0,1) eq " "){substr($_,0,1) = ""}

      if($userssend{$_} ne 0)
      {
        $userssend{$_} = -1;
      }
      else
      {
        $userssend{$_} = 1;
      }
    }

    $bedniks = "";
    $sendcol = 0;
    $senttobuf1 = "";
    foreach ( keys %userssend )
    {
      if($userssend{$_} eq -1)
      {
        $bedniks = "$bedniks<b>$_</b>; ";
      }

      if($userssend{$_} eq 1)
      {
        if($senttobuf1 eq "")
        {
          $senttobuf1 = $usersnik{$_};
        }

        mkdir("privates/$usersnik{$_}");

        open(maxindex, "+<privates/$usersnik{$_}/maxindex.txt") || open(maxindex, ">privates/$usersnik{$_}/maxindex.txt");
        flock(maxindex, 2);
        seek maxindex, 0, 0;
        $postid=<maxindex>;
        $postid++;
        truncate maxindex, 0;
        seek maxindex, 0, 0;
        print maxindex $postid;
        close (maxindex);


        open(messagefile, ">privates/$usersnik{$_}/$postid.txt");
        flock(messagefile, 2);
        print messagefile qq~$Userid|$subjectbuf|$nowtime\n~;
        print messagefile qq~$messagebuf~;
        close(messagefile);

        open(inboxfile, "+<privates/$usersnik{$_}/inbox.txt") || open(inboxfile, ">privates/$usersnik{$_}/inbox.txt");
        flock(inboxfile, 2);
        seek inboxfile, 0, 0;
        @inboxfilebuf=<inboxfile>;
        truncate inboxfile, 0;
        seek inboxfile, 0, 0;

        $postbuf1 = "$postid|$Userid|$subjectbuf|$nowtime|1\n";
        print inboxfile $postbuf1;
        print inboxfile @inboxfilebuf;
        close (inboxfile);

        open(indexfile, "+<privates/$usersnik{$_}/index.txt") || open(indexfile, ">privates/$usersnik{$_}/index.txt");
        flock(indexfile, 2);
        seek indexfile, 0, 0;
        @indexfilebuf=<indexfile>;
        for(@indexfilebuf)
        {chomp $_}
        truncate indexfile, 0;
        seek indexfile, 0, 0;

        ($typebuf, $all, $new)=split(/\|/,@indexfilebuf[0]);
        $all++;
        $new++;
        print indexfile qq~inbox|$all|$new\n~;;

        ($typebuf, $all)=split(/\|/,@indexfilebuf[1]);
        if($all eq ""){$all = 0}
        print indexfile qq~sent|$all\n~;;

        ($typebuf, $all)=split(/\|/,@indexfilebuf[2]);
        if($all eq ""){$all = 0}
        print indexfile qq~del|$all\n~;;

        close (indexfile);

        $sendcol++;
      }
    }

    if($sendcol > 0)
    {
      mkdir("privates/$Userid");
      open(indexfile, "+<privates/$Userid/index.txt") || open(indexfile, ">privates/$Userid/index.txt");
      flock(indexfile, 2);
      seek indexfile, 0, 0;
      @indexfilebuf=<indexfile>;
      for(@indexfilebuf)
      {chomp $_}
      truncate indexfile, 0;
      seek indexfile, 0, 0;
      ($typebuf, $all, $new)=split(/\|/,@indexfilebuf[0]);
      if($all eq ""){$all = 0}
      if($new eq ""){$new = 0}
      print indexfile qq~inbox|$all|$new\n~;;
      ($typebuf, $all)=split(/\|/,@indexfilebuf[1]);
      $all++;
      print indexfile qq~send|$all\n~;
      ($typebuf, $all)=split(/\|/,@indexfilebuf[2]);
      if($all eq ""){$all = 0}
      print indexfile qq~del|$all\n~;;
      close (indexfile);

      open(maxindex, "+<privates/$Userid/maxindex.txt") || open(maxindex, ">privates/$Userid/maxindex.txt");
      flock(maxindex, 2);
      seek maxindex, 0, 0;
      $postid=<maxindex>;
      $postid++;
      truncate maxindex, 0;
      seek maxindex, 0, 0;
      print maxindex $postid;
      close (maxindex);

      open(messagefile, ">privates/$Userid/$postid.txt");
      flock(messagefile, 2);
      print messagefile qq~$senttobuf1|$subjectbuf|$nowtime\n~;
      print messagefile qq~$messagebuf~;
      close(messagefile);

      open(sentfile, "+<privates/$Userid/send.txt") || open(sentfile, ">privates/$Userid/send.txt");
      flock(sentfile, 2);
      seek sentfile, 0, 0;
      @sentfilebuf=<sentfile>;
      truncate sentfile, 0;
      seek sentfile, 0, 0;
      print sentfile qq~$postid|$senttobuf1|$subjectbuf|$nowtime|1\n~;
      print sentfile @sentfilebuf;
      close (sentfile);
    }

    substr($bedniks,-2) = "";
    if($bedniks ne "")
    {
      print "<br><center><b>Неизвестные адресаты:</b> $bedniks.<br>";
    }
    $tos = @tos;
    print "<br><center><b>Всего отправлено $sendcol из $tos.</b><br>";
  }
}

sub newprivate {
  open (privateindex, "<privates/$Userid/index.txt");
  flock(privateindex, 1);
  @privateindex = <privateindex>;
  close privateindex;

  for(@privateindex)
  {chomp $_}

  ($typebuf, $all, $new)=split(/\|/,$privateindex[0]);



  print header(-charset=>"windows-1251");
  print <<FORMA;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href=main.css type=text/css rel=stylesheet>
<title>Личные сообщения</title>
</head>
<body topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0>
<table width='100%' height='100%'><tr bgcolor=$tseriy><td align='center' valign='middle'>
<b><font size=4><a href="javascript:showprivate()">Новых личных сообщений: $new</a></b></font><br>Всего: $all

<script language="LiveScript">
function showprivate() {
  opener.open('$site?mode=private&folder=inbox');
  window.close('?mode=newprivate', 'newprivate');
}

</script>

</body>
</html>
FORMA
  exit;
}

1;
