#!/usr/bin/perl

# index.cgi  ������ ����������� ����� ���������� �������� ����� (http://fmob.org.ru/index.cgi)
# bbCode.js  ������ ���������� �� ����� Javascript. ������������� � �������� ��� �������� ����� �������� ����������
#
#
#  �����: ��������� ���� ��������� (Agran)
#  email: agranbox@mail.ru
#
#  User: Demo Pass: demo
#

$zapros_podtv = 1; # ������� ������ ��� ����������� �� �������
$zapros_otkl = -2; # ������� ������ ��� ���������� �������

use locale;
use POSIX qw(locale_h);
use CGI::Cookie;
use CGI::Carp qw (fatalsToBrowser);
use CGI qw/:standard/;
use CGI;
use Digest::MD5 qw(md5_hex);
use MIME::Lite;
use Time::Local;
use Time::HiRes qw(gettimeofday);
use File::stat;
use Fcntl;
use Image::Magick;

setlocale(LC_ALL,"ru_RU.cp1251");

require "text_processing.pl";   # ������ ���������� �� ������� ������-html ����� � �������� html
require "search.pl";            # ������ ����� (http://fmob.org.ru?mode=search). # find2/index.pl - ������������� ������. ����������� ������ 6 �����.
require "registration.pl";      # ������ ����������� (http://fmob.org.ru?mode=registration&action=login, http://fmob.org.ru?mode=registration&action=reg, http://fmob.org.ru?mode=registration&action=zaprosi). ������ ������� (http://fmob.org.ru?mode=mobbers) ������� ������������� (http://fmob.org.ru?showuser=1)
require "voting.pl";            # ������ ����������� (http://fmob.org.ru?mode=voting)
require "common.pl";            # ������ � ��������� ������ ����������
require "forum.pl";             # ������ ����� (http://fmob.org.ru?mode=forum)
require "sendmail.pl";          # ������ ���������� �� �������� ����� � �������� (hhttp://fmob.org.ru?mode=sendmail&to=0&userid=1)
require "main.pl";              # ������ ������� �������� (http://fmob.org.ru)
require "sendsotik.pl";         # ������ SMS �������� (http://fmob.org.ru?mode=sms)
require "next.pl";              # ������ ����������� (http://fmob.org.ru?mode=next)
require "past.pl";              # ������ ��������� (http://fmob.org.ru?mode=past)
require "subscribe.pl";         # ������������� ������ �������� (http://fmob.org.ru?mode=subscribe)
require "pda.pl";               # ��������� ������ ������� �������� (http://fmob.org.ru?mode=pda)
require "private.pl";           # ������ ������ ��������� (http://fmob.org.ru?mode=private)
require "yahoo.pl";             # ������ ������ �������� Yahoo (http://fmob.org.ru?mode=yahoo)
require "polls.pl";             # ������, ���������� �� ������� ������� ����� (http://fmob.org.ru?mode=polls)
require "kisses.pl";            # ������, ���������� �� ��� ������� (http://fmob.org.ru?mode=kisses)
require "gallery.pl";           # ������, ���������� ������� (http://fmob.org.ru?mode=gallery)
require "GetExifJPEG.pm";       # ������, ���������� ���������� �� JPG Exif ����������

@days = ('��','��','��','��','��','��','��');
@days_exp = ('�����������', '�����������', '�������', '�����', '�������', '�������', '�������');

@mdays=('������', '�������', '����', '������', '���', '����', '����', '������', '��������', '�������', '������', '�������');
@mdays2=('������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������');

$timeoffset = 4*60*60;

$timebuf1 = gettimeofday;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time + ($timeoffset));

# Hours, minutes, seconds, day and month should be in two-digit format.

$mon++;
$hour = "0$hour" if ($hour < 10);
$min  = "0$min" if ($min < 10);
$sec  = "0$sec" if ($sec < 10);
$mday = "0$mday" if ($mday < 10);
$mon  = "0$mon" if ($mon < 10);

# Y2K!
$year1 = $year;
$year = 2000 + ($year - 100);
$nowtime = "$days[$wday] $hour:$min - $mday.$mon.$year";
$nowdate = "$mday.$mon.$year";

$domen=$ENV{SERVER_NAME};
if ($domen =~ "/home/vu3004/fmob.org.ru/" | $domen =~ "/home/vu3004/fmob.org.ru/")
{
  $domen="http://fmob.org.ru/";
}
$site="http://fmob.org.ru/";


$mailprog = '/usr/sbin/sendmail ';

$title="������� � ���������� - �����������";
$messagesonpage = 20;
$messagesonpage2 = $messagesonpage;
$threadsonpage = 20;
$playsonpage = 20;
$albumonpage = 20;
$photoonpage = 20;
$playpage = 1;
$usertype = "";

srand();
# -------------------------------

$action = param(action);
if (param(play) ne ""){$play=param(play)};
if (param(mode) ne ""){$mode=param(mode)}else{$mode="main"}
if (param(poll) ne ""){$mode="polls"}


$redirectto = param(redirectto);

#Login-----------------------------

%cookies = fetch CGI::Cookie;
if($cookies{"Userid_Hash"})
{$Userid_Hash = $cookies{"Userid_Hash"}->value;}
else{$Userid_Hash = "";}


$login=0;

if((param(name) ne "")&(param(password) ne ""))
{
  $Userid_Hash=md5_hex(param(password));
  $Userid="";
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;
  $namebuf=lc(param(name));
  $b = 0;
  foreach $a(@users)
  {
    $b++;
    chomp $a;
    $User_Name_cesh{$b} = $a;
    $a = lc($a);
    if($namebuf eq $a)
    {
      open (userinfo, "<users/$b.txt");
      flock(userinfo, 1);
      @userinfo = <userinfo>;
      close userinfo;
      chomp @userinfo[1];
      $buf=$userinfo[1];
      if($userinfo[1] eq $Userid_Hash)
      {
        $Userid=$b;
      }
    }
  }
  if($Userid ne "")
  {
    $Userid_Hash="$Userid\_$Userid_Hash"
  }
  else
  {
    $Userid_Hash = "";
    $mode = "registration";
    $action = "login";
    $redirectto="";
    $namebuf = param(name);
    $passwordbuf = param(password);
    sleep (5);
  }
}

if ($mode eq "registration"&$action eq "exit")
{
  ($b) = ($Userid_Hash =~ /(\d+)_.+/);
  &usersonsite($b);
  $Userid_Hash="";
  $redirectto=$ENV{HTTP_REFERER};
  $login = 1;
  &html;
  exit;
}


if ($Userid_Hash ne "")
{
  ($b) = ($Userid_Hash =~ /(\d+)_.+/);

  open (userinfo, "<users/$b.txt");
  flock(userinfo, 1);
  @userinfo = <userinfo>;
  close userinfo;

  foreach (@userinfo)
  {chomp $_}

  $user_sex = $userinfo[6];

  $LastTimeVisit = $userinfo[25];

  $buf=$userinfo[1];
  if("$b\_$buf" eq $Userid_Hash)
  {
    $Userid=$b;
    $UserName=$userinfo[0];
    $usertype = @userinfo[8];
    if($userinfo[17] ne "")
    {
      $playsonpage = $userinfo[17];
    }
    if($userinfo[18] ne "")
    {
      $threadsonpage = $userinfo[18];
    }
    if($userinfo[19] ne "")
    {
      $messagesonpage = $userinfo[19];
    }
    $messagesonpage2 = $messagesonpage;

    $login=1;
  }
}

if($login eq 1)
{
  if($cookies{"PollShow$Userid"})
  {$PollShowbuf = $cookies{"PollShow$Userid"}->value;}
  else{$PollShowbuf = "";}

  @PollShow = split(/\|/,$PollShowbuf);

}

($cherniy, $ttseriy, $tseriy, $t2seriy, $seriy, $sseriy, $beliy, $top3png, $verhpng, $levopng, $pravopng, $mdvagif, $modingif, $nolgif, $podingif, $pdvagif, $icon1gif, $newgif, $boardgif, $board_newgif, $threadgif, $thread_new, $thread_new_closegif, $icon_newest_replygif, $thread_closegif) = ("#000000", "#707070", "#e0e0e0", "#e7e7e7", "#f0f0f0", "#f7f7f7", "#ffffff", "image/top3.png", "image/verh.png", "image/levo.png", "image/pravo.png", "image/-2.gif", "image/-1.gif", "image/0.gif", "image/+1.gif", "image/+2.gif", "image/icon1.gif", "image/new.gif", "image/board.gif", "image/board_new.gif", "image/thread.gif", "image/thread_new.gif", "image/thread_new_close.gif", "image/icon_newest_reply.gif", "image/thread_close.gif");

if($cookies{"GuestRandomID"})
{$guest_random_id = $cookies{"GuestRandomID"}->value;}
else
{
  $guest_random_id = int(rand(999999999));
  $guest_random_id = "+$guest_random_id";
}

if($login eq 1)
{
  open (random_idtxt, "<random_id.txt");
  flock(random_idtxt, 1);
  @random_id = <random_idtxt>;

  foreach (@random_id)
  {chomp $_}

  $random_id[$Userid-1]="$Userid:$UserName:$guest_random_id";

  @random_id = join("\n", @random_id);

  open (random_idBUF,">random_id_buf.txt");
  flock(random_idBUF, 2);
  print random_idBUF @random_id;
  close(random_idBUF);

  close random_idtxt;


  rename("random_id.txt", "random_id_old.txt");
  rename("random_id_buf.txt", "random_id.txt");

}

if($cookies{"LastLastTimeVisit$Userid"})
{$LastLastTimeVisit = $cookies{"LastLastTimeVisit$Userid"}->value;}
else{$LastLastTimeVisit = "";}

if($cookies{"MessageCountInVisitThreads$Userid"})
{
  $MessageCountInVisitThreadsbuf = $cookies{"MessageCountInVisitThreads$Userid"}->value;
  @MessageCountInVisitThreadsbuf2 = split(/,/,$MessageCountInVisitThreadsbuf);
  foreach (@MessageCountInVisitThreadsbuf2)
  {
    ($threadbuf1,$MessageCountInVisitThread1) = split(/=/,$_);
    $MessageCountInVisitThreads{$threadbuf1} = $MessageCountInVisitThread1;
  }
}

# End -------------------------------

if($mode eq "private")
{
  if (param(folder) eq "inbox")
  {
    $title="������� � ���������� - ������ ��������� - ��������";
  }
  elsif(param(folder) eq "send")
  {
    $title="������� � ���������� - ������ ��������� - ���������";
  }
  elsif(param(folder) eq "del")
  {
    $title="������� � ����������  - ������ ��������� - ��������";
  }
  else
  {
    $title="������� � ����������  - ������ ���������";
  }
  $messid = param(id);
  if ($messid ne "")
  {
    open (privateindex, "<privates/$Userid/$messid.txt");
    flock(privateindex, 1);
    @privateindex = <privateindex>;
    close privateindex;

    $heder = $privateindex[0];

    ($avtorbuf, $zagolovok, $datebuf) = split(/\|/,$heder);
    $title = "$title - $zagolovok";
  }
}


if($mode eq "main")
{
  $title="������� � ����������";
  if(param(showuser) ne "")
  {
    $showuserid = param(showuser);
    $showusername = Get_User_Name_by_id($showuserid);
    $title="������� � ���������� - ���������� � ������������ \"$showusername\""
  }

  if(param(play) ne "")
  {
    open(plays, "<plays/plays.txt");
    flock(plays, 1);
    while (<plays>)
    {
      ($playidbuf, $typebuf) = split(/\|/,$_);
      if($play eq $playidbuf)
      {
        if($typebuf eq 2)
        {
          $redirectto = "$site?mode=next";
        }
        elsif($typebuf eq 3)
        {
          $redirectto = "$site?mode=past&play=$play";
        }
        else
        {
          $redirectto = "$site?mode=voting&play=$play";
        }
        if(param(hl) ne "")
        {
          $redirectto = "$redirectto&hl=".param(hl);
        }
        if($typebuf ne 2)
        {
          $redirectto = "$redirectto#$play"
        }
        &html;
        exit;
      }
    }
  }
}

if($mode eq "voting")
{
  if($action eq "add"){$title="������� � ���������� - ���������� ������ ��������"}
  if($action eq "edit"){$title="������� � ���������� - �������������� ��������"}
  if($action eq "delete"){$title="������� � ���������� - �������� ��������"}
  if($action eq "movetonext"){$title="������� � ���������� - ����������� �������� � ����������� ����"}
  $title2="�����������";
  $playtype=1;
}
elsif($mode eq "past")
{
  $title="������� � ���������� - ��������� ����";
  $title2="��������� ����";
  $playtype=3;
}
elsif($mode eq "next")
{
  $title="������� � ���������� - ����������� ���";
  if($action eq "edit"){$title="������� � ���������� - �������������� �������� ������������ ����"}
  $title2="����������� ���";
  $playtype=2;
}
elsif($mode eq "registration")
{
  if($action eq "login"){$title="������� � ���������� - ���� �� ����"}
  if($action eq "add"|$action eq ""){$title="������� � ���������� - ����������� ������ �������"}
  if($action eq "edit"){$title="������� � ���������� - �������������� �������"}
  if($action eq "reg"){$title="������� � ���������� - ������ �����������"}
  if($action eq "vostanov"){$title="������� � ���������� - �������������� ������"}
  if($action eq "zaprosi"){$title="������� � ���������� - ������������� �����������"}
}
elsif($mode eq "sendmail")
{
  $title="������� � ���������� - �������� ���������";
}
elsif($mode eq "subscribe")
{
  $title="������� � ���������� - ���������� ����������";
}
elsif($mode eq "sms")
{
  $title="������� � ���������� - SMS-��������";
}
elsif($mode eq "error")
{
  $title="������� � ���������� - ������";
}
elsif($mode eq "mobbers")
{
  $title="������� � ���������� - �������";
}
elsif($mode eq "yahoo")
{
  $title="������� � ���������� - ������ �������� Yahoo";
}
elsif($mode eq "search")
{
  $title="������� � ���������� - �����";
}
elsif($mode eq "polls")
{
  $title="������� � ���������� - ������";
}
elsif($mode eq "kisses")
{
  $title="������� � ���������� - ������ ������� ��� ���� �������";
}
elsif($mode eq "gallery")
{
  $title="������� � ���������� - �������";
}


#-------------------------------------------------------------------------------

if ($mode ne "main")
{
  $modeurl="mode=$mode&";
}

if($mode eq "gallery")
{
  if(param(hidealbum) ne "")
  {
    &hidealbum;
  }

  if(param(hidephoto) ne "")
  {
    &hidephoto;
  }

  if(param(phototoprev10) ne "")
  {
    $photomove = param(phototoprev10);
    $offset = -1;
    &photomove10;
  }

  if(param(phototoprev) ne "")
  {
    $photomove = param(phototoprev);
    $offset = -1;
    &photomove;
  }

  if(param(phototonext10) ne "")
  {
    $photomove = param(phototonext10);
    $offset = 1;
    &photomove10;
  }

  if(param(phototonext) ne "")
  {
    $photomove = param(phototonext);
    $offset = 1;
    &photomove;
  }

  if(param(action) eq "addphoto")
  {
    &add_form_photo;
    &htmlend;
    exit;
  }

  if(param(action3) eq "��������")
  {
    if(param(editphoto) ne "")
    {
      &edit_photo;
      &htmlend;
      exit;
    }

    &add_photo;
    &htmlend;
    exit;
  }

  if(param(editphoto) ne "")
  {
    &add_form_photo;
    &htmlend;
    exit;
  }

  if(param(action) eq "addalbum")
  {
    &add_form_album;
    &htmlend;
    exit;
  }

  if(param(action2) eq "��������")
  {
    if(param(edit) eq 1)
    {
      &edit_album;
      &htmlend;
      exit;
    }
    &add_album;
    &htmlend;
    exit;
  }

  if(param(editalbum) ne "")
  {
    &edit_form_album;
    &htmlend;
    exit;
  }

  if(param(action3) eq "��������")
  {
    &add_photo;
    &htmlend;
    exit;
  }

  if(param(album) ne ""&param(photo) ne "")
  {
    &show_photo(param(album), param(photo));
    &htmlend;
    exit;
  }

  if(param(album) ne "")
  {
    &show_gallery(param(album));
    &htmlend;
    exit;
  }

  &html;
  &show_galleries;
  &htmlend;
  exit;
}

if($mode eq "search")
{
  if(param(reload) eq "1")
  {
    $redirectto = "$site?mode=search&query=".param(query)."&plays=". param(plays)."&forum=".param(forum)."&name=".param(name)."&onlytopic=".param(onlytopic)."&predv=".param(predv);
  }

  &html;
  &find_start;
  &htmlend;
  exit;
}


if($mode eq "private")
{
  $messonpage = $threadsonpage;
  $folder = param(folder);
  $messid = param(id);

  $page = param(page);
  if($page eq ""){$page = 1;}
  if($login eq 1)
  {
    &html;

    if ($action eq "new")
    {
      &show_new;
    }
    elsif ($action eq "send")
    {
      &send_private;
    }
    elsif ($folder eq "inbox")
    {
      if($messid ne "")
      {
        &show_mess;
      }
      else
      {
        &show_inbox;
      }
    }
    elsif ($folder eq "send")
    {
      if($messid ne "")
      {
        &show_mess;
      }
      else
      {
        &show_send;
      }
    }
    elsif ($folder eq "del")
    {
      if($messid ne "")
      {
        &show_mess;
      }
      else
      {
        &show_del;
      }
    }
    else
    {
      &show_index;
    }

    &htmlend;
  }
  else
  {
    &html;
    &netdostupa;
  }
  exit;
}

if($mode eq "main")
{
  if(param(showuser) ne "")
  {
    &showuserinfo;
  }
  if(param(action) eq "voting")
  {
    &html;

    $voice11 = param(voice);

    if((login eq 0)|($voice11 ne 1&$voice11 ne 2&$voice11 ne 3&$voice11 ne 4&$voice11 ne 5&$voice11 ne 6&$voice11 ne 7&$voice11 ne 8&$voice11 ne 9))
    {
      print "<center><h1>������!!!</h1></center>\n";
      &htmlend;
      exit;
    }

    open (referendum,">>referendum.txt") || open(referendum, ">referendum.txt");;
    flock(referendum, 2);
    print referendum "$Userid|$nowtime|$voice11|$ENV{HTTP_REFERER}\n";
    close(referendum);
    print "<center><h3>���� ����� ��������.</h3></center>\n";


    &htmlend;
    exit;
  }
  &html;
  &show_main;
  &htmlend;
  exit;
}

if($mode eq "pda")
{
  &show_pda;
  exit;
}

if($mode eq "sms")
{
  &html;
  if ($action eq "send")
  {&sendsotik}
  if ($action eq "")
  {&sendsotik_forma;}
  &htmlend;
  exit;
}

if($mode eq "mobbers")
{
  &html;
  &show_mobbers;
  &htmlend;
  exit;
}

if($mode eq "registration")
{
  if($action eq "zaprosi")
  {
    &registration_zaprosi_list;
  }
  if($action eq "vostanov")
  {
    if(param(finish)eq 1)
    {
      &registration_vostanov;
    }
    else
    {
      &registration_vostanov_forma;
    }
  }

  if($action eq "login"&$login ne 1)
  {
    &registration_login_forma;
  }

  if(($action eq "edit")|($action eq ""&$login eq "0"))
  {
    &registration_edit
  }

  if(($action eq "del"))
  {
    &registration_del;
  }

  if(($action eq "undel"))
  {
    &registration_undel;
  }

  if($action eq "reg")
  {
    if(param(finish) eq 1)
    {
      &registration_finish_reg;
    }
    else
    {
      &registration_reg_forma;
    }
  }

  &html;
  &htmlend;
  exit;
}

if($mode eq "sendmail")
{
  &html;
  $to = param(to);
  if ($action eq "send")
  {&mail_sen}
  &mail_forma;
  &htmlend;
  exit;
}

if($mode eq "yahoo")
{
  &html;
  &yahooshow;
  &htmlend;
  exit;
}

if($mode eq "subscribe")
{
  &html;

  if(!(($usertype eq "����������")|($usertype eq "��������������")))
  {
    &netdostupa;
  }

  if ($action eq "sent")
  {
    &sent_list;
    &htmlend;
    exit;
  }

  if ($action eq "smslist")
  {
    &smslist;
    &htmlend;
    exit;
  }

  if ($action eq "send")
  {
    &subscribe_sen;
  }
  else
  {
    &subscribe_forma;
  }
  &htmlend;
  exit;
}

if($mode eq "taghelp")
{
  &taghelp;
}

if($mode eq "rules")
{
  &ruleshelp;
}

if($mode eq "smiles")
{
  &smileshelp;
}

if($mode eq "mobbereslist")
{
  &mobbereslist;
}

if($mode eq "newprivate")
{
  &newprivate;
}


if($mode eq "newreg")
{
  &newreg;
}

if($mode eq "taghelp")
{
  &taghelp;
}

if($mode eq "forum")
{
  &showforum;
  &htmlend;
  exit;
}

if($mode eq "error")
{
  &html;
  print "<br><center><b>������ ������ ����</b></center>";
  exit;
}

if($mode eq "next")
{
  if($login eq 1)
  {
    if($action eq "go")
    {
      if(param(answer) eq "�� �����")
      {
        $voicebuf2 = "0";
      }
      else
      {
        $voicebuf2 = param(moberswithme);
        $voicebuf2 =~ /(\d+)/;
        $voicebuf2++;
      }
      &usergotoplay($voicebuf2);
      $redirectto = $ENV{HTTP_REFERER};
      &html;
      exit;
    }

    if(param(voting) eq "time")
    {
      if(param(answer) eq "�������������")
      {
        &votingplaytime;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }

      if(param(answer) eq "��������")
      {
        &addplaytime;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }
      if(param(primenit) eq "���������"&(($usertype eq "����������")|($usertype eq "��������������")))
      {
        &modifyplaytime;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }
    }

    if(param(voting) eq "mesto")
    {
      if(param(answer) eq "�������������")
      {
        &votingplaymesto;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }

      if(param(answer) eq "��������")
      {
        &addplaymesto;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }
      if(param(primenit) eq "���������"&(($usertype eq "����������")|($usertype eq "��������������")))
      {
        &modifyplaymesto;
        $redirectto = $ENV{HTTP_REFERER};
        &html;
        exit;
      }
    }

    if(($usertype eq "����������")|($usertype eq "��������������"))
    {
      if($action eq "edit")
      {
        &movetonext;
        &htmlend;
        exit;
      }
      if($action eq "movetovoting")
      {
        &movetovoting;
        &htmlend;
        exit;
      }
      if($action eq "movetopast")
      {
        &movetopast;
        &htmlend;
        exit;
      }
    }
  }
  &html;
  &shownext;
  &htmlend;
  exit;
}

if($mode eq "past")
{
  if(param(was) ne "")
  {
    &pastwas;
  }

  if(($usertype eq "����������")|($usertype eq "��������������"))
  {
    if($action eq "edit")
    {
      &movetopast;
      &htmlend;
      exit;
    }
  }
  &html;
  &showpast;
  &htmlend;
  exit;
}

if($mode eq "polls")
{
  $messonpage = $threadsonpage;
  if(param("poll") ne "")
  {
    $redirectto = "$site?mode=polls#poll_".param(poll);
    &html;
    exit;
  }
  if($action eq "add")
  {
    &html;
    &new_poll;
    &htmlend;
    exit;
  }
  if(param("vote") ne "")
  {
    &poll_vote;
    $buf = $ENV{'HTTP_REFERER'};
    $buf =~ s~(.+?)\#(.+?)$~$1~isg;
    $redirectto = $buf."#poll_".param(pollid);
    &html;
    exit;
  }
  if(param("close") ne "")
  {
    &close_poll;
    $buf = $ENV{'HTTP_REFERER'};
    $buf =~ s~(.+?)\#(.+?)$~$1~isg;
    $redirectto = $buf."#poll_".param(pollid);
    &html;
    exit;
  }
  if(param("hide") ne "")
  {
    &hide_poll;
    $buf = $ENV{'HTTP_REFERER'};
    $buf =~ s~(.+?)\#(.+?)$~$1~isg;
    $redirectto = $buf."#poll_".param(pollid);
    &html;
    exit;
  }

  if(param("edit") ne "")
  {
    $redirectto = "$site?mode=polls&action=edit&pollid=".param(pollid);
    &html;
    exit;
  }

  if(param("show") ne "")
  {
    $pollid = param("pollid");
    $PollShow[@PollShow] = $pollid;

    $buf = $ENV{'HTTP_REFERER'};
    $buf =~ s~(.+?)\#(.+?)$~$1~isg;
    $redirectto = $buf."#poll_".$pollid;
    &html;
    exit;
  }

  if($action eq "edit")
  {
    &edit_poll;
    &htmlend;
    exit;
  }

  &html;
  &show_polls;
  &htmlend;
  exit;
}

&readindexofplay;

if($mode eq "kisses")
{
  if($login eq 1)
  {

    if(param("action2") ne "")
    {
      &html;
      &kisses_finish;
      &htmlend;
      exit;
    }
    if((param("action") eq "show")&(($usertype eq "����������")|($usertype eq "��������������")))
    {
      &html;
      &kisses_show_list;
      &htmlend;
      exit;
    }
    &html;
    &kisses_show;
    &htmlend;
    exit;
  }
  else
  {
    &html;
    &netdostupa;
  }
}

if($mode eq "voting")
{
  if($login eq 1)
  {

    if($action eq "�������������")
    {
      &voting1;
    }
    if(param(voice) ne "")
    {
      &voting2;
    }
    if($action eq "add")
    {
      &html;
      &addplay;
      &htmlend;
      exit;
    }
    if($action eq "edit")
    {
      &html;
      &addplay;
      &htmlend;
      exit;
    }
    if($action eq "delete")
    {
      &deleteplay;
      &htmlend;
      exit;
    }
    if(($usertype eq "����������")|($usertype eq "��������������"))
    {
      if($action eq "movetonext")
      {
        &movetonext;
        &htmlend;
        exit;
      }
    }
    if($action eq "addplayfinish")
    {
      &addplayfinish;
    }
    if($action eq "editplayfinish")
    {
      &editplayfinish;
    }
  }
  elsif($action ne "")
  {
    &html;
    &netdostupa
  }
  $voting=1;
  if($action eq "")
  {
    &html;
  }
}

&showvoting;
&htmlend;
