sub registration_edit{
  $pass = param(pass);
  if(($pass ne "aefrqw" & $action ne "edit")|($action eq "edit" & $login eq 0))
  {
    &registration_login_forma;
    exit;
  }

  if(param(finish) eq "1")
  {

    $nik = &readparam(nik);
    if($nik eq "")
    {
      &noname1;
    }
    $password = param(password);
    $UserNamebuf = $UserName;

    $editid = param(edit);
    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/)
    {
      $UserNamebuf = &Get_User_Name_by_id($editid);
      $useridbuf = $editid;
    }
    else
    {
      $useridbuf = $Userid;
    }

    if(param(edit)eq "my"|(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/))
    {
      if(lc($UserNamebuf) ne lc(&readparam(nik)))
      {
        open (USERS,"<users/users.txt");
        flock(USERS, 1);
        while (<USERS>)
        {
          $a=$_;
          chomp $a;
          if(lc($a) eq lc($nik))
          {
            &noname2;
          }
        }
        close(USERS);
      }
      if($password ne param(password2))
      {
        &nopassword2;
      }
    }
    else
    {
      if($password eq "")
      {
        &nopassword3;
      }
      if($password ne param(password2))
      {
        &nopassword2;
      }
      open (USERS,"<users/users.txt");
      flock(USERS, 1);
      while (<USERS>)
      {
        $a=$_;
        chomp $a;
        if(lc($a) eq lc($nik))
        {
          &noname2;
        }
      }
      close(USERS);
    }

    if(lc($UserNamebuf) ne lc(&readparam(nik)))
    {
      open (USERS,"<users/users.txt");
      flock(USERS, 1);
      open (USERSBUF,">users/users_buf.txt");
      flock(USERSBUF, 2);

      $useridbuf2=0;
      while (<USERS>)
      {
        $useridbuf2++;
        if($useridbuf2 eq $useridbuf)
        {
          print USERSBUF "$nik\n";
        }
        else
        {
          print USERSBUF $_;
        }
      }
      if(param(edit)eq "new")
      {
        $useridbuf2++;
        print USERSBUF &readparam(nik), "\n";
        $useridbuf = $useridbuf2;
      }
    }

    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/ )
    {
      open (USERINFO,"<users/$editid.txt");
    }
    else
    {
      open (USERINFO,"<users/$useridbuf.txt");
    }
    flock(USERINFO, 1);
    @userinfo=<USERINFO>;
    close(USERINFO);

    foreach (@userinfo)
    {chomp $_}

    $userinfo[0] = &readparam(nik);
    if($password ne ""&$password eq param(password2))
    {
      $password = md5_hex($password);
      $userinfo[1] = $password;
    }
    elsif($password eq "")
    {
      $password = $userinfo[1];
    }

    $userinfo[2] = &readparam(fullname);
    $j=0;
    foreach (@mdays)
    {
      $j++;
      if(param(born_mm) eq $_)
      {
        $born_mm = $j;
        $born_mm = "0$born_mm" if ($born_mm<10);
        last;
      }
    }
    $born_dd = param(born_dd);
    ($date3) = (param(born_yyyy) =~ /(\d+)/);
    if($date3 ne ""&param(born_dd) ne ""&$born_mm ne "")
    {$userinfo[3]="$born_dd.$born_mm.$date3"}
    else
    {$userinfo[3]=""}
    $den_rojdeniya = $userinfo[3];
    $userinfo[4] = &readparam(email);
    $userinfo[5] = &readparam(icq);
    $userinfo[6] = "";
    if(param(sex) eq "�������"){$userinfo[6] = "1"}
    elsif(param(sex) eq "�������"){$userinfo[6] = "0"}
    if(param(subscribe1) eq "on"){$subscribe1 = "1"}else{$subscribe1 = "0"}
    if(param(subscribe2) eq "on"){$subscribe2 = "1"}else{$subscribe2 = "0"}
    if(param(subscribe3) eq "on"){$subscribe3 = "1"}else{$subscribe3 = "0"}
    $userinfo[7] = "$subscribe1|$subscribe2|$subscribe3";
    $userinfo[8] = "���������" if($userinfo[8] eq "");
    $userinfo[9] = &readparam(podpis);
    $userinfo[10] = "0" if ($userinfo[10] eq "");
    $userinfo[11] = "0" if ($userinfo[11] eq "");
    $userinfo[12] = $nowtime if ($userinfo[12] eq "");
    $userinfo[13] = &readparam(homesite);

    ########�������� �������#############
    $avatar = param(avatar);
    $avatartype = "";
    my $avatarbuf = "";
    if ($avatar =~ /\.gif$/i)
    {
      $avatartype = "gif";
    }
    elsif ($avatar =~ /\.jpg$|.jpeg$/i)
    {
      $avatartype = "jpg";
    }
    else
    {
      $avatartype = ""
    }

    if($avatartype ne "")
    {
      $nocash = int(rand(999));
      $outfile = "image/avatars/$useridbuf\_$nocash.$avatartype";
      open (OUTFILE, ">$outfile");
      flock(OUTFILE, 2);
      while ($bytesread = read($avatar,$buffer,1024))
      {
         binmode OUTFILE;
         print OUTFILE $buffer;
      }
      close($avatar);
      close(OUTFILE);

      ($img_width, $img_height, $img_type, $img_size) = get_image_info($outfile);

      if(($img_width>100)|($img_height>100)|( not (($img_type eq "GIF")|($img_type eq "JPEG")))|($img_size>10240))
      {
        unlink($outfile);
        &html;
        &noavatar;
      }
      $avatarbuf = "$useridbuf\_$nocash.$avatartype";
      unlink("image/avatars/$userinfo[14]");
      $userinfo[14] = $avatarbuf;
    }
    if(param(delavatar) eq "on")
    {
      $outfile = "image/avatars\/$userinfo[14]";
      unlink($outfile);
      $avatarbuf = "";
      $userinfo[14] = $avatarbuf;
    }
    ####################################

    ########�������� ����#############
    $foto = param(foto);
    $fototype = "";
    my $fotobuf = "";
    if ($foto =~ /\.gif$/i)
    {
      $fototype = "gif";
    }
    elsif ($foto =~ /\.jpg$|.jpeg$/i)
    {
      $fototype = "jpg";
    }
    else
    {
      $fototype = ""
    }

    if($fototype ne "")
    {
      $nocash = int(rand(999));
      $outfile = "image/photos/$useridbuf\_$nocash.$fototype";
      open (OUTFILE, ">$outfile");
      flock(OUTFILE, 2);
      while ($bytesread = read($foto,$buffer,1024))
      {
         binmode OUTFILE;
         print OUTFILE $buffer;
      }
      close($foto);
      close(OUTFILE);

      ($img_width, $img_height, $img_type, $img_size) = get_image_info($outfile);

      if(($img_width>1024)|($img_height>768)|( not (($img_type eq "JPEG")))|($img_size>153600))
      {
        unlink($outfile);
        &html;
        &nofoto;
      }
      $fotobuf = "$useridbuf\_$nocash.$fototype";
      unlink("image/photos/$userinfo[28]");
      $userinfo[28] = $fotobuf;
    }
    if(param(delfoto) eq "on")
    {
      $outfile = "image/photos\/$userinfo[14]";
      unlink($outfile);
      $fotobuf = "";
      $userinfo[28] = $fotobuf;
    }
    ####################################


    $userinfo[15] = &readparam(adress);
    $userinfo[16] = $userinfo[0];
    $userinfo[17] = &readparam(playsonpage);
    $userinfo[18] = &readparam(threadsonpage);
    $userinfo[19] = &readparam(postssonpage);

    $userinfo[20] = "0" if ($userinfo[20] eq "");
    $userinfo[21] = "0" if ($userinfo[21] eq "");
    $userinfo[22] = "0" if ($userinfo[22] eq "");
    $userinfo[23] = "0" if ($userinfo[23] eq "");
    $userinfo[24] = "0" if ($userinfo[24] eq "");
    $userinfo[26] = &readparam(skin);
    $userinfo[27] = &readparam(mobil);

    if($userinfo[0] ne $UserNamebuf)
    {
      @niks = split(/\|/,$userinfo[31]);
      $flag = 0;
      for(@niks)
      {
        if($_ eq $UserNamebuf)
        {
          $flag = 1;
        }
      }

      if($flag eq 0)
      {
        $userinfo[31] = "$userinfo[31]\|$UserNamebuf";
      }
    }

    if($usertype eq "��������������" & $editid =~ /(\d+)/ )
    {
       $userinfo[8] = &readparam(gruppa)
    }

    @userinfo = join("\n", @userinfo);

    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/ )
    {
      open (USERINFOBUF,">users/$editid\_buf.txt");
    }
    else
    {
      open (USERINFOBUF,">users/$useridbuf\_buf.txt");
    }

    flock(USERINFOBUF, 2);
    print USERINFOBUF @userinfo;
    close(USERINFOBUF);


    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/ )
    {
      rename("users/$editid.txt", "users/$editid\_old.txt");
      rename("users/$editid\_buf.txt", "users/$editid.txt");
    }
    else
    {
      rename("users/$useridbuf.txt", "users/$useridbuf\_old.txt");
      rename("users/$useridbuf\_buf.txt", "users/$useridbuf.txt");
    }
    close(USERS);
    close(USERSBUF);

    if(lc($UserNamebuf) ne lc(&readparam(nik)))
    {
      rename("users/users.txt", "users/users_old.txt");
      rename("users/users_buf.txt", "users/users.txt");
    }

    &save_subscribe_mails;
    &save_dni_rojdeniya;


    if( not(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/))
    {
      $Userid_Hash = "$useridbuf\_$password";
      $UserName = &readparam(nik);
      $Userid = $useridbuf;
      $login = 1;
    }
    &html;
    print "<center><br><b>��������� �������</b></center><br>";
    &htmlend;
    exit;
  }
  my @pages = (5, 10, 20, 30, 40, 50);
  &html;
  if($action eq "edit")
  {
    $editid = param(id);
    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/ )
    {
      open (userinfo,"<users/$editid.txt");
      $editbuf = $editid;
    }
    else
    {
      open (userinfo, "<users/$Userid.txt");
      $editbuf = "my";
    }
    flock(userinfo, 1);
    @userinfo = ();
    @userinfo = <userinfo>;
    close userinfo;
    foreach (@userinfo)
    {
      chomp $_;
      $_ =~ s/"/&quot;/gi;
    }
  }
  else
  {
    @userinfo = ();
    $editbuf = "new";
  }
  if($action eq "")
  {
    $title2="<br><b><font size=4>����������� ������ �������</font></b><br><br>";
  }
  else
  {
    $title2="<br><b><font size=4>�������������� �������</font></b><br><br>";
  }

  if (($userinfo[14] ne "")&(-e "image/avatars/$userinfo[14]"))
  {
    $buf6="<input type=checkbox name=delavatar> ������� ������<br><img border=1 src=\"$site/image/avatars/$userinfo[14]\"></td>";
  }

  if (($userinfo[28] ne "")&(-e "image/photos/$userinfo[28]"))
  {
    $buf7="<input type=checkbox name=delfoto> ������� ����<br><img border=1 src=\"$site/image/photos/$userinfo[28]\"></td>";
  }

  $sex1=" selected" if($userinfo[6] eq 1);
  $sex0=" selected" if($userinfo[6] eq 0);

  if($userinfo[7] ne "")
  {
    ($subscribe1, $subscribe2, $subscribe3)= split(/\|/,$userinfo[7]);
  }
  else
  {
    ($subscribe1, $subscribe2, $subscribe3)= (1, 1, 0);
  }

  $subscribe1 = " checked" if($subscribe1 eq 1);
  $subscribe2 = " checked" if($subscribe2 eq 1);
  $subscribe3 = " checked" if($subscribe3 eq 1);

  if($usertype eq "��������������" & $editid =~ /(\d+)/ )
  {
    $bufgruppa = "<tr>
<td>������:</td>
<td><input type=text size=36 name=gruppa value=\"$userinfo[8]\"></td>
</tr>";
  }

  print <<FORMA;
<center>
$title2
<table border=0 cellspacing=0 cellpadding=2>
<form action="$buf1" method=post enctype="multipart/form-data">
<input type=hidden name=mode value=registration>
<input type=hidden name=action value=edit>
<input type=hidden name=finish value=1>
<input type=hidden name=edit value=$editbuf>
<input type=hidden name=pass value=$pass>
<tr>
<td>���:</td>
<td><input type=text name=nik size=36 value=\"$userinfo[0]\"></td>
</tr>
<tr>
<td>������:</td>
<td><input type=password size=36 name=password></td>
</tr>
<tr>
<td>������ (��������):</td>
<td><input type=password size=36 name=password2></td>
</tr>
$bufgruppa
<tr>
<td>���:</td>
<td><input type=text size=36 name=fullname value=\"$userinfo[2]\"></td>
</tr>
<tr>
<tr>
<td>���:</td>
<td>
<select name=sex>
<option>
<option$sex1>�������
<option$sex0>�������
</td>
</tr>
<td>���� ��������:</td>
<td>
<select name=born_dd>
<option>
FORMA

($dey1, $mday1, $year1) = ($userinfo[3] =~ /(\d+)\.(\d+)\.(\d+)/);

for($j=1;$j<=31;$j++)
{
  $daybuf = $j;
  $daybuf = "0$daybuf" if ($daybuf < 10);
  if($dey1 eq $daybuf)
  {print "<option selected>$daybuf"}
  else
  {print "<option>$daybuf"}
}
print "\n";

    print <<FORMA;
</select>
<select name=born_mm>
<option>
FORMA

for($j=0;$j<12;$j++)
{
  $daybuf = $j+1;
  $daybuf = "0$daybuf" if ($daybuf < 10);
  if($mday1 eq $daybuf)
  {print "<option selected>$mdays[$j]"}
  else
  {print "<option>$mdays[$j]"}
}

    print <<FORMA;
</select>
<select name=born_yyyy>
<option>
FORMA

for($j=$year-5;$j>=$year-70;$j--)
{
  $yearbuf = $j;
  if($year1 eq $yearbuf)
  {print "<option selected>$yearbuf"}
  else
  {print "<option>$yearbuf"}
}
print "</select>\n";

    print <<FORMA;
</td>
</tr>
<tr>
<td>����� ����������:</td>
<td><input type=text size=36 name=adress value=\"$userinfo[15]\"></td>
</tr>
<tr>
<td>E-mail:</td>
<td><input type=text size=36 name=email value=\"$userinfo[4]\"></td>
</tr>
<td> </td>
<td><font size=1>�� ����� �������� ������� ������ �����</td>
</tr>
<tr>
<td>ICQ-uin:</td>
<td><input type=text size=36 name=icq value=\"$userinfo[5]\"></td>
</tr>
<tr>
<tr>
<td> </td>
<td><font size=1>��� ������ "-"</td>
</tr>
<td>�������:</td>
<td><input type=text size=36 name=mobil value=\"$userinfo[27]\"></td>
</tr>
<tr>
<td> </td>
<td><font size=1>��������: +79531108892. (������ ����� ����)</td>
</tr>
<tr>
<td>�������� ���������:</td>
<td><input type=text size=36 name=homesite value=\"$userinfo[13]\"></td>
</tr>
<tr>
<td>������:</td>
<td>
<input type="file" name="avatar">
<br>
</tr>
<tr>
<td colspan=2 align=center>(���������� �� 100*100. ������ �� 10KB. ���: jpeg ��� gif.)<br>
$buf6
</td>
</tr>
<tr>
<td>�������:</td>
<td><input type=text size=36 name=podpis maxlength="60" value=\"$userinfo[9]\"></td>
</tr>
<tr>
<td colspan=2 align=center>(������� ����� ��� ����� � ��������)</td>
</tr>
<tr><td></tr>
<tr>
<td colspan=2>
<br><b>��������:</b>
</td>
</tr>
<tr><td colspan=2>
<input type=checkbox name=subscribe1 $subscribe1> ������������� �������� �������� ����
</td></tr>
<tr><td colspan=2>
<input type=checkbox name=subscribe2 $subscribe2> ����� ��������
</td></tr>
<tr><td colspan=2>
<input type=checkbox name=subscribe3 $subscribe3> ����� ��������� �� ������
</td></tr>

<tr>
<td colspan=2>
<br><b>�������� �� ��������:</b>
</td>
</tr>
<tr><td>���������:</td>
<td colspan=2>
<select name=playsonpage>
FORMA
if($userinfo[17] eq ""){$userinfo[17] = 20}
for(@pages)
{
  if($_ eq $userinfo[17])
  {
    print "<option selected>$_";
  }
  else
  {
    print "<option>$_";
  }
}
    print <<FORMA;
</td></tr>
<tr><td>��� �� ������:</td>
<td colspan=2>
<select name=threadsonpage>
FORMA
if($userinfo[18] eq ""){$userinfo[18] = 20}
for(@pages)
{
  if($_ eq $userinfo[18])
  {
    print "<option selected>$_";
  }
  else
  {
    print "<option>$_";
  }
}
    print <<FORMA;
</td></tr>
<tr><td>��������� � ����:</td>
<td colspan=2>
<select name=postssonpage>
FORMA
if($userinfo[19] eq ""){$userinfo[19] = 20}
for(@pages)
{
  if($_ eq $userinfo[19])
  {
    print "<option selected>$_";
  }
  else
  {
    print "<option>$_";
  }
}
    print <<FORMA;
</td></tr>
<tr><td></tr>

<tr>

<tr>
<td>����:</td>
<td>
<input type="file" name="foto">
<br>
</tr>
<tr>
<td colspan=2 align=center>(���������� �� 1024*768. ������ �� 150KB. ���: jpeg.)<br>
$buf7
</td>
</tr>

<td colspan=2 align=center><input type=submit style=\"background-color: $tseriy;\" value=���������></td>
</tr>
</form></table>
</center>
<p align=left>
FORMA
  &htmlend;
  exit;
  }


sub registration_login_forma{
  &html;
  print <<FORMA;
<div align=center><b><font size=4>���� �� ����</font></b><br><br>
<br>
<center>
<b><a href=$site?mode=registration&action=reg>�����������</a></b>
<br><br>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=registration&action=login" method=POST>
<input type=hidden name=loginfinish value=1>
<input type=hidden name=mode value=registration>
<input type=hidden name=redirectto value=\"$ENV{'HTTP_REFERER'}\">
<tr>
<td>��� ���:</td>
<td><input type=text size=16 name=name value="$namebuf"></td>
</tr>
<tr>
<td>��� ������:</td>
<td><input type=password size=16 name=password value="$passwordbuf"></td>
</tr>
<tr>
<td></td>
<td align=center><input type=submit style=\"background-color: $tseriy;\" value=�����></td>
</tr>
</form></table>
<br>
<br>
�������������� �������� ������ <a href=$site?mode=registration&action=vostanov>�����</a>.
<br><br>
�� ���� ��������, ��������� � ������������ ����� ��������� � ��������������: <a href=mailto:agranbox\@ya.ru>agranbox\@ya.ru</a>
</center>
<p align=left>
FORMA
  &htmlend;
  exit;
}

sub registration_reg_forma{
  &html;

# <h2>����������, �������.</h2>
# ���� �����������, ��� �� - ��� ������� �������.<br>
# ���� �����������, ��� ���� � ����� ������ - �� ������������.<br>
# ����-��� � ���������� ����� ������ �������. ��� - ������ ���� ��������� ����.<br>
# �� �� ��������� ���� ����� � �����, ��� �� ����� ���������� � ����� ��������.<br>
# ���� �� ������ �������� � ���� ��������, �� ������ ��������, ��� ������ �����.<br>
# ��������������� ����� - ��� ����� ������� ����� ����� � ��������������� �������� ���������.<br>
# ���� �� ��������� �� ���� � ������������, ���� � ������������� ����-��� ���� ������.<br>
# ��� ��� ����������� �������� � ��� �� ������� ����.<br>
# ����������� ����� ��������� ������. ��� ������ ������ ���������� ���, ��� ������ ������ �� �������������.<br>
# <br>


  if($flag eq 1)
  {
    $buf = "<font color=red><b>������� �������� ����, ������� ���������� ���������.</forn></b><br><br>";
  }
  else
  {
    $buf = "";
  }

  print <<FORMA;
<div align=center><b><font size=4>��������������� �����</font></b><br><br>
<br>
<center>
<form action="$site?mode=registration&action=reg" method=POST>
<input type=hidden name=mode value=registration>
<input type=hidden name=action value=reg>
<input type=hidden name=finish value=1>
��������, ������� ������������ ������� � ������� �� ������� � �������� ���������.<br>������� "���� �� ����������" ��������� �� �����.<br><br>
$name_start<b>�������� ��� �� �����:</b>$name_end<br>
<input type=text size=47 name=name1 value="$name_reg"><br><br>
$password_start<b>�������� ������:</b>$password_end<br>
<input type=password size=47 name=password1 value="$password_reg"><br><br>
$password2_start<b>��������� ������:</b>$password2_end<br>
<input type=password size=47 name=password2 value="$password2_reg"><br><br>
$email_start<b>E-mail (�� ���� ����� ������ �����):</b>$email_end<br>
<input type=text size=47 name=email value="$email_reg"><br><br>
$uznali_start<b>������ �� ������ ��� �������?:</b>$uznali_end<br>
<textarea cols=43 rows=4 name=uznali maxlength=250>$uznali_reg</textarea><br><br>
$vlechenie_start<b>��� ��� ���������� �������?:</b>$vlechenie_end<br>
<textarea cols=43 rows=8 name=vlechenie maxlength=250>$vlechenie_reg</textarea><br><br>
$uchastvoval_start<b>����������� �� �� ������ � ������ ��������:$uchastvoval_end<br>
<select name="uchastvoval"><option>
FORMA

if($uchastvoval_reg eq "����������")
{print "<option selected>����������"}
else
{print "<option>����������"}
if($uchastvoval_reg eq "��� ������������")
{print "<option selected>��� ������������"}
else
{print "<option>��� ������������"}
if($uchastvoval_reg eq "�� ����������")
{print "<option selected>�� ����������"}
else
{print "<option>�� ����������"}

  print <<FORMA;
</select><br>$uchastie_v_akcii_start- ���� ��, �� � �����?:</b>$uchastie_v_akcii_end<br>
<textarea cols=43 rows=4 name=uchastie_v_akcii maxlength=250>$uchastie_v_akcii_reg</textarea>
<br><br>$buf<input type=submit style=\"background-color: $tseriy;\" value="��������� ������">
</form>
</center>
<p align=left>
FORMA

  &htmlend;
  exit;
}

sub registration_finish_reg{

  $name_reg = param(name1);
  $name_reg =~ s~>~&gt;~ig;
  $name_reg =~ s~<~&lt;~ig;
  $password_reg = param(password1);
  $password2_reg = param(password2);

  $email_reg = param(email);
  $email_reg =~ s~>~&gt;~ig;
  $email_reg =~ s~<~&lt;~ig;
  $email_reg =~ s~\|~&#124;~g;

  $uznali_reg = param(uznali);
  $uznali_reg =~ s~>~&gt;~ig;
  $uznali_reg =~ s~<~&lt;~ig;
  $uznali_reg =~ s~\|~&#124;~g;
  $uznali_reg =~ s/\n/<br>/gi;

  $vlechenie_reg = param(vlechenie);
  $vlechenie_reg =~ s~>~&gt;~ig;
  $vlechenie_reg =~ s~<~&lt;~ig;
  $vlechenie_reg =~ s~\|~&#124;~g;
  $vlechenie_reg =~ s/\n/<br>/gi;

  $uchastvoval_reg = param(uchastvoval);

  $uchastie_v_akcii_reg = param(uchastie_v_akcii);
  $uchastie_v_akcii_reg =~ s~>~&gt;~ig;
  $uchastie_v_akcii_reg =~ s~<~&lt;~ig;
  $uchastie_v_akcii_reg =~ s~\|~&#124;~g;
  $uchastie_v_akcii_reg =~ s/\n/<br>/gi;

  $flag = 0;

  open (USERS,"<users/users.txt");
  flock(USERS, 1);
  while (<USERS>)
  {
    $bufnik=$_;
    chomp $bufnik;
    if(lc($bufnik) eq lc($name_reg))
    {
      $name_start = "<font color=red>";
      $name_end = "</font>";
      $flag = 1;
    }
  }


  $email_bil = "";

  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;
  $i=0;
  foreach (@users)
  {
    $i++;
    chomp $_;

    open (userinfo, "<users/$i.txt");
    flock(userinfo, 1);
    @userinfo = <userinfo>;
    close userinfo;
    chomp $userinfo[0];
    chomp $userinfo[1];
    chomp $userinfo[4];

    if ($email_reg eq $userinfo[4] & substr($userinfo[1],0,1) ne ";")
    {
      $email_bil = $userinfo[0];
    }
  }

  if($email_bil ne "")
  {
    $email_start = "<font color=red>";
    $email_end = "</font> <br> <b>������������ � ��������� ������ ��� ��� ���������������.<br> ��� ��� \"$email_bil\"<br><a href=$site?mode=registration&action=vostanov>������������ ������?</a><br> </b>";
    $flag = 1;
  }



  open (USERREG_FILE, "<usersreg.txt");
  flock(USERREG_FILE, 1);
  @usersreg = <USERREG_FILE>;
  close USERREG_FILE;
  $povtorno = 0;
  for(@usersreg)
  {
    ($buf, $buf, $email_buf_reg, $buf, $buf, $buf, $buf, $buf, $buf, $reyting_reg, $za_reg, $protiv_reg, $buf) = split(/\|/,$_);

    if($reyting_reg > $zapros_otkl & $reyting_reg < $zapros_podtv & $email_buf_reg eq $email_reg)
    {
      $povtorno = 1;
    }
  }






  if ($name_reg =~ /\|/)
  {
    $name_start = "<font color=red>";
    $name_end = "</font>";
    $flag = 1;
  }

  close(USERS);

  if($password_reg ne $password2_reg)
  {
    $password_start = "<font color=red>";
    $password_end = "</font>";
    $password2_start = "<font color=red>";
    $password2_end = "</font>";
    $flag = 1;
  }

  if ($password_reg =~ /\|/)
  {
    $password_start = "<font color=red>";
    $password_end = "</font>";
    $flag = 1;
  }

  if ($password2_reg =~ /\|/)
  {
    $password2_start = "<font color=red>";
    $password2_end = "</font>";
    $flag = 1;
  }


  if($name_reg eq "")
  {
    $name_start = "<font color=red>";
    $name_end = "</font>";
    $flag = 1;
  }
  if($password_reg eq "")
  {
    $password_start = "<font color=red>";
    $password_end = "</font>";
    $flag = 1;
  }
  if($password2_reg eq "")
  {
    $password2_start = "<font color=red>";
    $password2_end = "</font>";
    $flag = 1;
  }
  if($email_reg eq ""|not($email_reg =~ m/([^\w\"\=\[\]]|[\n\b]|\A)(([+%_a-zA-Z\d\-\.]+)+@([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+))/gi))
  {
    $email_start = "<font color=red>";
    $email_end = "</font>";
    $flag = 1;
  }
  if($uznali_reg eq "")
  {
    $uznali_start = "<font color=red>";
    $uznali_end = "</font>";
    $flag = 1;
  }
  if($vlechenie_reg eq "")
  {
    $vlechenie_start = "<font color=red>";
    $vlechenie_end = "</font>";
    $flag = 1;
  }
  if($uchastvoval_reg eq "")
  {
    $uchastvoval_start = "<font color=red>";
    $uchastvoval_end = "</font>";
    $flag = 1;
  }
  if($uchastie_v_akcii_reg eq "" & $uchastvoval_reg eq "����������")
  {
    $uchastie_v_akcii_start = "<font color=red>";
    $uchastie_v_akcii_end = "</font>";
    $flag = 1;
  }



  if($flag eq 1)
  {
    &registration_reg_forma;
  }

  if($povtorno eq 0)
  {

    open (usersreg,">>usersreg.txt") || open(usersreg, ">usersreg.txt");;
    flock(usersreg, 2);
    if($guest_random_id eq "")
    {
      $guest_random_id_reg=$Userid;
    }
    else
    {
      $guest_random_id_reg=$guest_random_id;
    }

    print usersreg "$name_reg|$password_reg|$email_reg|$uznali_reg|$vlechenie_reg|$uchastvoval_reg|$uchastie_v_akcii_reg|$ENV{REMOTE_ADDR}|$guest_random_id_reg|0|||$nowtime|\n";
    close(usersreg);

    open(MAIL,"|$mailprog -t");
    print MAIL "To: $name_reg <$email_reg>\n";
    print MAIL "From: robot\@fmob.org.ru\n";
    print MAIL "Content-type:text/plain;charset=windows-1251\n";
    print MAIL "Subject: ������ �� �����������\n\n\n";
    print MAIL "������������, $name_reg!\n";
    print MAIL "�� ��� ���� ������� ������ �� ����������� �� ����� fmob.org.ru. ��� ����� ������������ � ��������� �����.\n";
    print MAIL "\n--------------\n�������� ����� fmob.org.ru.";
    close (MAIL);

    &html;
    print "<center><b><br>���� ������ ����� ����������� � ��������� �����.<br>� ����������� ��� ����� �������� �� email.</b></center>";
    &htmlend;
    exit;
  }
  else
  {
    &html;
    print "<center><b><br>������ ��������.<br>���� ������ ��� �� �����������.<br></b></center>";
    &htmlend;
    exit;
  }

}

sub nopassword2{
  &html;
  print "<br><br><center><b>�� �������� ��� ��������� ����� ������.</b></center>";
  &htmlend;
  exit;
}

sub nopassword3{
  &html;
  print "<br><br><center><b>������ �� ����� ���� ������.</b></center>";
  &htmlend;
  exit;
}

sub noname2{
  &html;
  print "<br><br><center><b>������ ��� ��� �����.</b></center>";
  &htmlend;
  exit;
}

sub noname1{
  &html;
  print "<br><br><center><b>��� �� ����� ���� ������.</b></center>";
  &htmlend;
  exit;
}

sub noavatar{
  print "<br><br><center><b>������ ����� �� ���������� ���.</b><br>";
  print "�����: ���������� �� 100*100. ������ �� 10KB. ���: jpeg ��� gif.<br>";
  print "�� � Aurea �����������, ��� � �������� ����� �������� ����� ��������� ��� Web...</center>";
  &htmlend;
  exit;
}

sub nofoto{
  print "<br><br><center><b>���� ����� �� ���������� ���.</b><br>";
  print "�����: ���������� �� 1024*768. ������ �� 150KB. ���: jpeg.<br>";
  &htmlend;
  exit;
}

sub showuserinfo{
  &html;

  open (userinfo, "<users/$showuserid.txt");
  flock(userinfo, 1);
  @userinfo = <userinfo>;
  close userinfo;
  $userinfo[99] = "";
  foreach (@userinfo)
  {chomp $_}


  if (($userinfo[14] ne "")&(-e "image/avatars/$userinfo[14]"))
  {
    $userinfo[14]="<img src=\"$site/image/avatars/$userinfo[14]\">";
  }

  if (($userinfo[28] ne "")&(-e "image/photos/$userinfo[28]"))
  {
    $userinfo[28]="<img src=\"$site/image/photos/$userinfo[28]\">";
  }

  if($userinfo[5] ne "")
  {
    $userinfo[5]="<a href=\"http://wwp.icq.com/$userinfo[5]\#pager\"><img src=\"http://web.icq.com/whitepages/online?icq=$userinfo[5]\&img=5\" width=18 height=18 border=0 align=absbottom></a> $userinfo[5]";
  }

  $mailaddbuf="&userid=$showuserid";
  $userinfo[4] = &text_process($userinfo[4]);
  $mailaddbuf="";

  if($userinfo[13] ne "")
  {
    $userinfo[13] = &text_process("\[url\]$userinfo[13]\[/url\]");
  }

  if($userinfo[3] ne "")
  {
    ($dey1, $mday1, $year1) = ($userinfo[3] =~ /(\d+)\.(\d+)\.(\d+)/);
    $dey1 = int($dey1);
    $userinfo[3] = "$dey1 $mdays2[$mday1-1] $year1 (" .raznicayears($userinfo[3], $nowdate). ")";
  }

  foreach (@userinfo)
  {if($_ eq ""){$_="<i>��� ����������</i>"}}

  $sex=$userinfo[6];
  $sex = "�������" if($userinfo[6] eq "1");
  $sex = "�������" if($userinfo[6] eq "0");

  $colvoice = $userinfo[20]+$userinfo[21]+$userinfo[22]+$userinfo[23]+$userinfo[24];
  if($colvoice ne 0)
  {
    $averagevoice = sprintf("%.3f",(($userinfo[20]*-2)+($userinfo[21]*-1)+($userinfo[23]*1)+($userinfo[24]*2))/$colvoice);
  }
  else
  {
    $averagevoice = "<i>��� ����������</i>";
  }

  if(($usertype eq "����������")|($usertype eq "��������������"))
  {
    if(substr($userinfo[1], 0, 1) eq ";")
    {
      $deltext = "<br><font size=1>[<a href=\"$site?mode=registration&action=undel&userid=$showuserid\" class=adm>������������ ������������</a>]";
    }
    else
    {
      $deltext = "<br><font size=1>[<a href=\"$site?mode=registration&action=del&userid=$showuserid\" class=adm>������� ������������</a>]";
    }
    $deltext = "$deltext<font size=1> [<a href=\"$site?mode=registration&action=edit&id=$showuserid\" class=adm>������������� �������</a>]";
  }
  elsif($showuserid eq $Userid)
  {
    $deltext = "<br><font size=1> [<a href=\"$site?mode=registration&action=edit\" class=adm>������������� �������</a>]";
  }

  @plays1 = split(/:/,$userinfo[29]);
  @voices1 = split(/:/,$userinfo[30]);

  $i=0;
  $poshli_buf = "";
  $neposhli_buf = "";
  $poshli_col = 0;
  for(@voices1)
  {
    if($plays1[$i] ne "")
    {
      if($_ eq 1)
      {
        open(playinfo, "<plays/$plays1[$i].txt");
        flock(playinfo, 1);
        @playinfo=<playinfo>;
        close (playinfo);

        {chomp $playinfo[5]}

        $poshli_buf = "$poshli_buf, <a href=$site/?play=$plays1[$i]>$playinfo[5]</a>";
        $poshli_col++;
      }
      else
      {
        $neposhli_buf = "$neposhli_buf, $plays1[$i]";
      }
    }
    $i++;
  }

  substr($poshli_buf, 0, 2) = "";
  substr($neposhli_buf, 0, 2) = "";
  $poshli_buf = "<font size='1'>$poshli_buf</font>";

  @niks = split(/\|/,$userinfo[31]);
  $flag = 0;
  for(@niks)
  {
    if(($_ ne $UserName)&($_ ne ""))
    {
      $niksbuf = "$niksbuf, $_";
    }
  }
  substr($niksbuf, 0, 2) = "";

  print <<USERINFO;

<table border=0 cellpadding=4 width=100%>
<tr><td colspan=2 align=center><b><font size="4">���������� � ������������ "$showusername"</font>
$deltext
<tr valign=top>
<td width="50%">
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy><th colspan=2>������ ������
<tr><td bgcolor=$seriy width="30%"><b>�.�.�.</b><td bgcolor=$sseriy width="70%">$userinfo[2]
<tr><td bgcolor=$seriy><b>���<td bgcolor=$sseriy>$sex
<tr><td bgcolor=$seriy><b>���� ��������<td bgcolor=$sseriy>$userinfo[3]
<tr><td bgcolor=$seriy><b>����� ����������<td bgcolor=$sseriy>$userinfo[15]
<tr><td bgcolor=$seriy><b>�������� ���������<td bgcolor=$sseriy>$userinfo[13]
<tr><td bgcolor=$seriy><b>E-mail<td bgcolor=$sseriy>$userinfo[4]
<tr><td bgcolor=$seriy><b>ICQ-uin<td bgcolor=$sseriy>$userinfo[5]
<tr><td bgcolor=$seriy><b>�������<td bgcolor=$sseriy>$userinfo[27]
<tr><td bgcolor=$sseriy colspan=2 align=center><b><a href=\"$site?mode=private&action=new&toid=$showuserid\">�������� ������ ���������
</table>
<td width="50%">
<table border=0 cellpadding=4 width=100%>
<tr bgcolor=$tseriy><th colspan=2>���������� �� �����
<tr><td bgcolor=$seriy width="30%"><b>���</b></td><td bgcolor=$sseriy width="70%">$showusername
<tr><td bgcolor=$seriy><b>������<td bgcolor=$sseriy>$userinfo[8]
<tr><td bgcolor=$seriy><b>������<td bgcolor=$sseriy>$userinfo[14]
<tr><td bgcolor=$seriy><b>�������<td bgcolor=$sseriy>$userinfo[9]
<tr><td bgcolor=$seriy><b>�����������<td bgcolor=$sseriy>$userinfo[12]
<tr><td bgcolor=$seriy><b>��������� ���������</b></td><td bgcolor=$sseriy>$userinfo[25]
<tr><td bgcolor=$seriy><b>���������<td bgcolor=$sseriy>$userinfo[10]
<tr><td bgcolor=$seriy><b>��������� ���������<td bgcolor=$sseriy>$userinfo[11]
<tr><td bgcolor=$seriy><b>������ �������<td bgcolor=$sseriy>$colvoice
<tr><td bgcolor=$seriy><b>������� ���<td bgcolor=$sseriy>$averagevoice
<tr><td bgcolor=$seriy><b>���������� � ����� ($poshli_col)<td bgcolor=$sseriy>$poshli_buf
<tr><td bgcolor=$seriy><b>������ ����<td bgcolor=$sseriy>$niksbuf
</table>
<tr valign=top>
<td colspan=2 bgcolor=$seriy><b>���� �������
<tr valign=top>
<td colspan=2 bgcolor=$sseriy>
$userinfo[28]
</table>

USERINFO

  &htmlend;
  exit;
}

sub show_mobbers {
  $pagebuf = param(page);
  if ($pagebuf eq "") {$pagebuf = 1;}
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;
  $i=0;
  $i1=0;
  foreach (@users)
  {
    $i++;
    chomp $_;

    $usersids{$_} = $i;

    open (userinfo, "<users/$i.txt");
    flock(userinfo, 1);
    @userinfo = <userinfo>;
    close userinfo;
    foreach (@userinfo)
    {
      chomp $_;
    }

    if(substr($_,0,1) eq ";")
    {
      $nikbuf = $_;
      substr($nikbuf,0,1) = "";
      $usersniks{$_} = "<a href=\"?showuser=$usersids{$_}\"><font color=red>$nikbuf";
      if($pagebuf ne -1)
      {
        delete($users[$i-1]);
      }
    }
    else
    {
      if(((&raznica2($userinfo[25], $nowtime) < 14*60*24)&(&raznica2($userinfo[12], $nowtime) > 14*60*24)))
      {
        $usersniks{$_} = "<a href=\"?showuser=$usersids{$_}\">$_";
      }
      else
      {
        $usersniks{$_} = "<a href=\"?showuser=$usersids{$_}\" class=s>$_";
      }
      if($pagebuf eq -1)
      {
        delete($users[$i-1]);
      }
      $i1++;
    }

    if($userinfo[3] ne "")
    {
      $userage{$_} = raznicayears($userinfo[3], $nowdate);
      $userborn{$_} = $userinfo[3];
    }

    if($userinfo[8] eq "��������������")
    {
      $usergroup{$_} = "<font color=red><b>�";
    }
    elsif($userinfo[8] eq "����������")
    {
      $usergroup{$_} = "<font color=blue><b>�";
    }
    else
    {
      $usergroup{$_} = "<b>�";
    }

    if($userinfo[4] ne "")
    {
      $mailaddbuf="&userid=$i";

      $usermail{$_} = $userinfo[4];

      $usermail{$_} =~ s/([^\w\"\=\[\]]|[\n\b]|\A)(([+%_a-zA-Z\d\-\.]+)+@([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+))/&mailcrop2($2, &mailcrop($3, $4))/ge;

      if(substr($usermail{$_},0,3) eq "<a ")
      {
        $usermail2{$_} = lc($userinfo[4]);
      }
      else
      {
        $usermail{$_} = "";
        $usermail2{$_} = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
      }
    }
    else
    {
      $usermail2{$_} = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
    }


    if($userinfo[5] ne "")
    {
      $usericq{$_} = "<img src=\"http://web.icq.com/whitepages/online?icq=$userinfo[5]\&img=5\" width=18 height=18 border=0 align=absbottom> $userinfo[5]";
      $usericquin{$_} = $userinfo[5];
    }
    else
    {
      $usericquin{$_} = 99999999999999999;
    }

    $usermobil{$_} = $userinfo[27];

    if($userinfo[28] ne "")
    {
      $userphoto{$_} = "<a href=\"?showuser=$usersids{$_}\"><img src=\"$site/image/photo.gif\" alt=\"����\" style=\"border: 0pt none ; vertical-align: bottom;\" height=16 width=16></a>";
    }


    if($userinfo[29] ne "")
    {
      @plays1 = split(/:/,$userinfo[30]);
      $buf = 0;

      for(@plays1)
      {
        if($_ eq 1 & $_ ne "")
        {
          $buf++;
        }
      }
      $userposetil{$_} = $buf;
    }
    else
    {
      $userposetil{$_} = 0;
    }

    if($userinfo[6] eq "1")
    {
      $usersex{$_} = "<img src=\"$site/image/m.gif\" alt=\"�\">";
    }
    elsif($userinfo[6] eq "0")
    {
      $usersex{$_} = "<img src=\"$site/image/w.gif\" alt=\"�\" align=absbottom>";
    }
    $userposts{$_} = $userinfo[10];
    $userplays{$_} = $userinfo[11];
    $uservoice{$_} = $userinfo[20]+$userinfo[21]+$userinfo[22]+$userinfo[23]+$userinfo[24];
    if($uservoice{$_} ne 0)
    {
      $useravrvoice{$_} = (($userinfo[20]*-2)+($userinfo[21]*-1)+($userinfo[23]*1)+($userinfo[24]*2))/$uservoice{$_};
      $useravrvoice1{$_} = sprintf("%.3f",$useravrvoice{$_});
    }
    else
    {
      $useravrvoice{$_} = -10;
    }

    if($userinfo[25] ne "")
    {
      $userlastvisit{$_} =  int(raznica2($userinfo[25], $nowtime)/(60*24));
      $userlastvisit2{$_} = $userinfo[25];
    }
    else
    {
      $userlastvisit2{$_} = "�� 23:28 - 04.05.2000";
    }
  }

  $nik_start = "<a href=$site?mode=mobbers&sort=nik&page=$pagebuf>";
  $group_start = "<a href=$site?mode=mobbers&sort=group&page=$pagebuf>";
  $posts_start = "<a href=$site?mode=mobbers&sort=posts&page=$pagebuf>";
  $plays_start = "<a href=$site?mode=mobbers&sort=plays&page=$pagebuf>";
  $sex_start = "<a href=$site?mode=mobbers&sort=sex&page=$pagebuf>";
  $age_start = "<a href=$site?mode=mobbers&sort=age&page=$pagebuf>";
  $id_start = "<a href=$site?mode=mobbers&page=$pagebuf>";
  $icq_start = "<a href=$site?mode=mobbers&sort=icq&page=$pagebuf>";
  $mobil_start = "<a href=$site?mode=mobbers&sort=mobil&page=$pagebuf>";
  $mail_start = "<a href=$site?mode=mobbers&sort=mail&page=$pagebuf>";
  $voice_start = "<a href=$site?mode=mobbers&sort=voice&page=$pagebuf>";
  $avrvoice_start = "<a href=$site?mode=mobbers&sort=avrvoice&page=$pagebuf>";
  $lastvisit_start = "<a href=$site?mode=mobbers&sort=lastvisit&page=$pagebuf>";
  $photo_start = "<a href=$site?mode=mobbers&sort=photo&page=$pagebuf>";
  $posetil_start = "<a href=$site?mode=mobbers&sort=posetil&page=$pagebuf>";

  if(param("sort") eq "nik")
  {
    @users2 = sort {lc($a) cmp lc($b)} @users;
    $buf_start = "$site?mode=mobbers&sort=nik&page=";
    $nik_start = "<b>";
  }
  elsif(param("sort") eq "posts")
  {
    @users2 = sort { $userposts{$b} <=> $userposts{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=posts&page=";
    $posts_start = "<b>";
  }
  elsif(param("sort") eq "plays")
  {
    @users2 = sort { $userplays{$b} <=> $userplays{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=plays&page=";
    $plays_start = "<b>";
  }
  elsif(param("sort") eq "group")
  {
    @users2 = sort { $usergroup{$b} cmp $usergroup{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=group&page=";
    $group_start = "<b>";
  }
  elsif(param("sort") eq "sex")
  {
    @users2 = sort { $usersex{$b} cmp $usersex{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=sex&page=";
    $sex_start = "<b>";
  }
  elsif(param("sort") eq "age")
  {
    @users2 = sort {raznica ($userborn{$b}, $userborn{$a})} @users;
    $buf_start = "$site?mode=mobbers&sort=age&page=";
    $age_start = "<b>";
  }
  elsif(param("sort") eq "icq")
  {
    @users2 = sort {$usericquin{$a} <=> $usericquin{$b}} @users;
    $buf_start = "$site?mode=mobbers&sort=icq&page=";
    $icq_start = "<b>";
  }
  elsif(param("sort") eq "mobil")
  {
    @users2 = sort {$usermobil{$b} <=> $usermobil{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=mobil&page=";
    $mobil_start = "<b>";
  }
  elsif(param("sort") eq "mail")
  {
    @users2 = sort {$usermail2{$a} cmp $usermail2{$b}} @users;
    $buf_start = "$site?mode=mobbers&sort=mail&page=";
    $mail_start = "<b>";
  }
  elsif(param("sort") eq "voice")
  {
    @users2 = sort { $uservoice{$b} <=> $uservoice{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=voice&page=";
    $voice_start = "<b>";
  }
  elsif(param("sort") eq "avrvoice")
  {
    @users2 = sort { $useravrvoice{$b} <=> $useravrvoice{$a}} @users;
    $buf_start = "$site?mode=mobbers&sort=avrvoice&page=";
    $avrvoice_start = "<b>";
  }
  elsif(param("sort") eq "lastvisit")
  {
    @users2 = sort { &raznica2($userlastvisit2{$a}, $userlastvisit2{$b})} @users;
    $buf_start = "$site?mode=mobbers&sort=lastvisit&page=";
    $lastvisit_start = "<b>";
  }
  elsif(param("sort") eq "photo")
  {
    @users2 = sort { $userphoto{$b} cmp $userphoto{$a} } @users;
    $buf_start = "$site?mode=mobbers&sort=photo&page=";
    $photo_start = "<b>";
  }
  elsif(param("sort") eq "posetil")
  {
    @users2 = sort {  $userposetil{$b} <=> $userposetil{$a} } @users;
    $buf_start = "$site?mode=mobbers&sort=posetil&page=";
    $posetil_start = "<b>";
  }
  elsif(param("sort") eq "")
  {
    @users2 = @users;
    $buf_start = "$site?mode=mobbers&page=";
    $id_start = "<b>";
  }

  $all = int(($i1-1) / 50)+1;

  for($i=1;$i <= $all;$i++)
  {
    if($pagebuf ne $i)
    {$stran = "$stran<a href=$buf_start$i>$i</a> ";}
    else
    {$stran = "$stran<b>[$i]</b> ";}
  }

  $i = 0;
  if($pagebuf ne $i)
  {$stran = "$stran<a href=$buf_start$i>���</a> ";}
  else
  {$stran = "$stran<b>[���]</b> ";}

  $i = -1;
  if($pagebuf ne $i)
  {$stran = "$stran<a href=$buf_start$i>��������</a> ";}
  else
  {$stran = "$stran<b>[��������]</b> ";}

  print "<center><font size=\"4\">�������</font><br>";
  print "<table border=0 cellpadding=4 width=100\%>";

  print "<tr><td colspan=16 align=center>�������� ($all): $stran</td></tr>";

  print "<tr bgcolor=$tseriy align=center>\n";
  print "<td width=2\% bgcolor=$beliy></td><td width=5\%>$id_start\ID";
  print "<td>$nik_start���";
  print "<td width=4\%>$sex_start<font size=1>���";
  print "<td width=4\%>$age_start<font size=1>����";
  print "<td width=4\%>$lastvisit_start<font size=1>�� ���";
  print "<td width=5\%>$group_start<font size=1>������";
  print "<td width=6\%>$posts_start<font size=1>�����.";
  print "<td width=5\%>$plays_start<font size=1>����.";
  print "<td width=5\%>$posetil_start<font size=1>���";
  print "<td width=6\%>$voice_start<font size=1>�����.";
  print "<td width=6\%>$avrvoice_start<font size=1>��.���";
  print "<td width=11\%>$icq_start\ICQ-uin";
  print "<td width=11\%>$mobil_start\�������";
  print "<td width=14\%>$mail_start E-mail";
  print "<td width=5\%>$photo_start ����";
  print "</tr>";


  if($pagebuf ne 0&$pagebuf ne -1)
  {
    $buf=50
  }
  else
  {
    $buf=10000;
    $pagebuf=1
  }

  $j=0;
  for(@users2)
  {
    if($usersids{$_} ne "")
    {
      $j++;
      if($j<($pagebuf-1)*$buf+1|$j>($pagebuf)*$buf){next}
      print "<tr class=td2><td bgcolor=$beliy>$j<td>$usersids{$_}<td align=left>$usersniks{$_}<td align=center>$usersex{$_}<td>$userage{$_}<td>$userlastvisit{$_}<td align=center>$usergroup{$_}<td>$userposts{$_}<td>$userplays{$_}<td>$userposetil{$_}<td>$uservoice{$_}<td nowrap>$useravrvoice1{$_}<td align=left><font size=1>$usericq{$_}<td align=left><font size=1>$usermobil{$_}<td align=left>$usermail{$_}<td align=center>$userphoto{$_}\n";
    }
  }
  print "<tr><td colspan=16 align=center>�������� ($all): $stran</td></tr>";

  print "</td></tr></table></center>";

}

sub save_dni_rojdeniya {
#

    open(subscribefile, "+<dni_rojdeniya.txt") || open(subscribefile, ">dni_rojdeniya.txt");
    flock(subscribefile, 2);
    seek subscribefile, 0, 0;
    @subscribemails=<subscribefile>;
    foreach (@subscribemails)
    {
      chomp $_;
    }
    truncate subscribefile, 0;
    seek subscribefile, 0, 0;

    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/)
    {
      $i = $editid - 1;
    }
    else
    {
      $i = $useridbuf-1;
    }

    $subscribemails[$i] = $den_rojdeniya;
    @subscribemails = join("\n", @subscribemails);
    print subscribefile @subscribemails;
    close (subscribefile);
}

sub save_subscribe_mails{
  my @subscribes, @subscribemailscon, @subscribemails, $subscriben;
  my $i=0;
  @subscribemailscon = (0, 0, 0);
  my $email = &readparam(email);

  if($email eq ""){return}

  @subscribes= ($subscribe1, $subscribe2, $subscribe3);
  $subscriben = 0;
  foreach (@subscribes)
  {
    $subscriben++;
    $mailbuf = $email;
    if($_ eq 0 | !($mailbuf =~ s/(([+%_a-zA-Z\d\-\.]+)+@([_a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)+))/$2\@$3/))
    {
      $mailbuf="";
    }

    open(subscribefile, "+<subscribe_$subscriben.txt") || open(subscribefile, ">subscribe_$subscriben.txt");
    flock(subscribefile, 2);
    seek subscribefile, 0, 0;
    @subscribemails=<subscribefile>;
    foreach (@subscribemails)
    {
      chomp $_;
    }
    truncate subscribefile, 0;
    seek subscribefile, 0, 0;

    if(($usertype eq "��������������"|$usertype eq "����������") & $editid =~ /(\d+)/)
    {
      $i = $editid - 1;
    }
    else
    {
      $i = $useridbuf-1;
    }
    $subscribemails[$i] = $mailbuf;
    @subscribemails = join("\n", @subscribemails);
    print subscribefile @subscribemails;
    close (subscribefile);
  }
}

sub registration_del{
  if(($usertype ne "����������")&($usertype ne "��������������"))
  {
    &netdostupa;
  }


  $uderiddel = param(userid);

  if($uderiddel eq "")
  {
    exit
  }

  open(indexfile, "+<users/users.txt");
  flock(indexfile, 2);
  seek indexfile, 0, 0;
  @indexfilebuf=<indexfile>;

  $indexfilebuf[$uderiddel-1] = ";$indexfilebuf[$uderiddel-1]";

  truncate indexfile, 0;
  seek indexfile, 0, 0;
  print indexfile @indexfilebuf;
  close (indexfile);

  open (userfile, "+<users/$uderiddel.txt");
  flock(userfile, 2);
  seek (userfile, 0, 0);
  @userinfo = <userfile>;

  $userinfo[1] = ";$userinfo[1]";
  $userinfo[8] = "<b><font color=red>��������</font></b>\n";
  $userinfo[16] = "$Userid\n";

  seek (userfile, 0, 0);
  print userfile @userinfo;
  truncate(userfile, tell(userfile));
  close (userfile);
  $redirectto = "$site?showuser=$uderiddel";
}

sub registration_undel{
  if(($usertype ne "����������")&($usertype ne "��������������"))
  {
    &netdostupa;
  }


  $uderiddel = param(userid);

  if($uderiddel eq "")
  {
    exit
  }

  open(indexfile, "+<users/users.txt");
  flock(indexfile, 2);
  seek indexfile, 0, 0;
  @indexfilebuf=<indexfile>;
  substr($indexfilebuf[$uderiddel-1], 0, 1) = "";

  truncate indexfile, 0;
  seek indexfile, 0, 0;
  print indexfile @indexfilebuf;
  close (indexfile);

  open (userfile, "+<users/$uderiddel.txt");
  flock(userfile, 2);
  seek (userfile, 0, 0);
  @userinfo = <userfile>;

  substr($userinfo[1], 0, 1) = "";
  $userinfo[8] = "���������\n";
  $userinfo[16] = "$Userid\n";

  seek (userfile, 0, 0);
  print userfile @userinfo;
  truncate(userfile, tell(userfile));
  close (userfile);
  $redirectto = "$site?showuser=$uderiddel";
}

sub registration_zaprosi_list
{
  if(($usertype ne "����������")&($usertype ne "��������������")) # ���� �� �� �� �������� ���
  {
    &html;
    &netdostupa;
  }

  $id_reg = param(id);                  # ��������� ID �������

  open (USERREG_FILE, "<usersreg.txt"); # ��������� ���� �� ������� �������� �� ������
  flock(USERREG_FILE, 1);               # ������ ���������� �� ������, ��� �� ����� �� ����� � ����, ���� �� ��� ������
  @usersreg = <USERREG_FILE>;           # ��������� ���������� ����� � ������
  close USERREG_FILE;                   # ��������� ����

  for(@usersreg) # ���� ������������ ��� �������� �������
  {chomp $_}     # ������� ���� �������� ������� �� ����� ������

  if(param(action2) eq "���������" & $id_reg ne "")
  {
    open (USERREG_FILE,">usersreg.txt");     # ��������� ���� �� ������� �������� �� ������
    flock(USERREG_FILE, 2);                  # ������ ���������� �� ������, ��� �� ����� �� ���� ������� ���� ���� �� � ��� ��������
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts) = split(/\|/,$usersreg[$id_reg-1]); # ��������� ��������� ������ � ��������� ����������

    $message = param(message);
    $message =~ s/\n/<br>/g;
    $message =~ s~\|~&#124;~g;
    $message =~ s~\\~&#47;~g;
    if($message ne "")
    {
      $posts[@posts] = "$Userid\\$message";
    }
    $usersreg[$id_reg-1] = join("|", ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts)); # ���������� ��� �������� ����� � ���� �� ������� ������ ������. ����� ���������� ���������� ������ ���� '|'
    $usersreg[@usersreg-1] = "$usersreg[@usersreg-1]\n"; # � ��������� ������ ������ � ����� ���� �������� ������� �� ����� ������

    @usersreg = join("\n", @usersreg); # ������ �� ���� ����� ��������� ������� � ����� ���� �������� ������� �� ����� ������

    print USERREG_FILE @usersreg;      # ��������� ������ ������ � ����
    close(USERREG_FILE);               # ��������� ����

    $redirectto = "$site?mode=registration&action=zaprosi&id=$id_reg";
  }

  if(param(action2) eq "��" & $id_reg ne "") # ���� ������ ������ �� � ���� ID ������
  {
    open (USERREG_FILE,">usersreg.txt");     # ��������� ���� �� ������� �������� �� ������
    flock(USERREG_FILE, 2);                  # ������ ���������� �� ������, ��� �� ����� �� ���� ������� ���� ���� �� � ��� ��������

    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts) = split(/\|/,$usersreg[$id_reg-1]); # ��������� ��������� ������ � ��������� ����������

    @za_regs = split(/\:/,$za_reg); # ������� ������ ������������ �� � ������. ��������� ID ������������ ����������� ������ ':'
    $flag = 1;
    for(@za_regs)                   # ���� ������������ ��� �������� �������
    {
      if($_ eq $Userid){$flag = 0}  # ���������� � $flag ��� �������� ������������ ��������� �� ��� ������
    }

    if($za_reg eq "") # ���������� � $flag2 ���� ������ ����� �� ��������� ��
    {
      $flag2 = 1
    }
    else
    {
      $flag2 = 0
    }


    if($flag eq 1)                 # ���� �������� ������������ �� ��������� ��, �� ��������� ��� ID � ������ ������������ ��
    {
      $za_reg = "$za_reg:$Userid"; # � ������ ������������ �� ID ����������� ������ ':'
#       if($usertype eq "��������������")
#       {
#         $reyting_reg ++;
#       }
      $reyting_reg ++;             # ����������� ������� ������ �� 1
    }

    if($flag2 eq 1)                # ���� �� ����� ����� �� ��������� �� �� ...
    {
      substr($za_reg, 0, 1) = "";  # ... ������� �� ������ ������ ���� ':'
    }

    @protiv_regs = split(/\:/,$protiv_reg); # ������� ������ ������������ ������ � ������. ��������� ID ������������ ����������� ������ ':'
    $flag = -1;
    $j = 0;
    for(@protiv_regs)              # ���� ������������ ��� �������� �������
    {
      if($_ eq $Userid)            # ���������� ����� ���� �������� ������������ ������ � ������ ������������ ������
      {
        $flag = $j;
      }
      $j++;
    }

    if($flag ne -1)                          # ���� �������� ������������ ���� � ������ ������������ ������, �� ...
    {
      delete($protiv_regs[$flag]);           # ...������� ������ � ������� �������� ��� ������������ ��������� ������
      $protiv_reg = join(":", @protiv_regs);
#       if($usertype eq "��������������")
#       {
#         $reyting_reg ++;
#       }
      $reyting_reg ++;                       # ����������� ������� ������ �� 1
    }

    $password_reg2 = $password_reg;   # ���������� ������ ������ � ���������� $password_reg2
    if($reyting_reg >= $zapros_podtv) # ���� ������� ������ ��� �������� ��� ��������������� ������, �� ...
    {$password_reg = "******"}        # ... �������� ������ � ������, ��� �� �� �� �������� � �������� ����
    $usersreg[$id_reg-1] = join("|", ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg,, @posts)); # ���������� ��� �������� ����� � ���� �� ������� ������ ������. ����� ���������� ���������� ������ ���� '|'
    $usersreg[@usersreg-1] = "$usersreg[@usersreg-1]\n"; # � ��������� ������ ������ � ����� ���� �������� ������� �� ����� ������

    @usersreg = join("\n", @usersreg); # ������ �� ���� ����� ��������� ������� � ����� ���� �������� ������� �� ����� ������

    print USERREG_FILE @usersreg;      # ��������� ������ ������ � ����
    close(USERREG_FILE);               # ��������� ����

    if($reyting_reg >= $zapros_podtv)         # ���� ������� ������ ��� �������� ��� ��������������� ������, �� ...
    {
      open (USERS,"<users/users.txt");        # ��������� ����� ������ �������� �� ������
      flock(USERS, 1);                        # ������ ���������� �� ������
      open (USERSBUF,">users/users_buf.txt"); # ��������� �� ������ ��������� ���� ��� ������ ��������
      flock(USERSBUF, 2);                     # ������ ���������� �� ������
      @USERS=<USERS>;                         # ��������� ���� � ��������� � ������
      close (USERS);                          # ��������� ����

      $useridbuf = @USERS;                    # ���������� ���������� ��������

      $USERS[@USERS]="$name_reg\n";           # ���������� � ����� ��� ������ ������� �� ������
      print USERSBUF @USERS;                  # ��������� ������ �������� � ����
      close (USERSBUF);                       # ��������� � ��������� ����
      rename("users/users.txt", "users/users_old.txt"); # ������� ���� �� ������� �������� ��� ������ users_old.txt
      rename("users/users_buf.txt", "users/users.txt"); # ������ ���� � ������� �� �������� ����� ������ �������� ������ �������

      for(@userinfo)                          # �������� ������ � ������� ����� �������� ������� ���������� � ����� �������...
      {$_= ""}                                # ... ��� ��� � ��� ���������� ���������� � ������ �������

      $userinfo[0] = $name_reg;               # ��������� 0 ��������� ������� ��� �� ������
      $userinfo[1] = md5_hex($password_reg2); # ��������� 1 ��������� ������� ������ � ���� ���� �� ��������� MD5
      $userinfo[4] = $email_reg;              # ��������� 4 ��������� ������� email �� ������
      $userinfo[7] = "1|0|0";                 # ��������� 7 ��������� ������� ��������
      $userinfo[8] = "���������";             # ��������� 8 ��������� ������� ������ �������
      $userinfo[9] = "���������";             # ��������� 9 ��������� ������� ������� �������
      $userinfo[12] = $nowtime;               # ��������� 12 ��������� ������� ���� ����������� �������

      @userinfo = join("\n", @userinfo);      # ������ �� ���� ����� ��������� ������� � ����� ���� �������� ������� �� ����� ������

      $useridbuf++;                                #  |
      open (USERINFOBUF,">users/$useridbuf.txt");  # ��������� ���������� � ����� ������� � ��������������� ����
      flock(USERINFOBUF, 2);                       #  |
      print USERINFOBUF @userinfo;                 #  |
      close(USERINFOBUF);

      close(USERS);
      close(USERSBUF);

      open(MAIL,"|$mailprog -t");                  # �������� ����� ������
      print MAIL "To: $name_reg <$email_reg>\n";   # ������� - ������� �� ������
      print MAIL "From: robot\@fmob.org.ru\n";                       # ����� ������ �� ������� ��� ������������
      print MAIL "Content-type:text/plain;charset=windows-1251\n";
      print MAIL "Subject: ����������� ������������!\n\n";
      print MAIL "������������, $name_reg!\n";
      print MAIL "���� ������ ���� ���������� � �������������.\n";
      print MAIL "����� ���������� � ���� ������������!\n\n";
      print MAIL "��� �����: $name_reg\n";
      print MAIL "��� ������: $password_reg2\n\n";
      print MAIL "���� �� ����: $site?mode=registration&action=login\n";
      print MAIL "������������ ����������� ��������� ���� �������: $site?mode=registration&action=edit\n";

      print MAIL "\n--------------\n������������� fmob.org.ru.";
      close (MAIL);


    }
    $redirectto = "$site?mode=registration&action=zaprosi&id=$id_reg";
  }

  if(param(action2) eq "������" & $id_reg ne "")
  {
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts) = split(/\|/,$usersreg[$id_reg-1]);

    @protiv_regs = split(/\:/,$protiv_reg);
    $flag = 1;
    for(@protiv_regs)
    {
      if($_ eq $Userid){$flag = 0}
    }

    if($protiv_reg eq "")
    {
      $flag2 = 1
    }
    else
    {
      $flag2 = 0
    }

    if($flag eq 1)
    {
      $protiv_reg = "$protiv_reg:$Userid";
#       if($usertype eq "��������������")
#       {
#         $reyting_reg --;
#       }
      $reyting_reg --;
    }

    if($flag2 eq 1)
    {
      substr($protiv_reg, 0, 1) = "";
    }

    @za_regs = split(/\:/,$za_reg);
    $flag = -1;
    $j = 0;
    for(@za_regs)
    {
      if($_ eq $Userid)
      {
        $flag = $j;
      }
      $j++;
    }

    if($flag ne -1)
    {
      delete($za_regs[$flag]);
      $za_reg = join(":", @za_regs);
#       if($usertype eq "��������������")
#       {
#         $reyting_reg --;
#       }

      $reyting_reg --;
    }

    $password_reg2 = $password_reg;
    if($reyting_reg <= $zapros_otkl)
    {$password_reg = "******"}

    $usersreg[$id_reg-1] = join("|", ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts));

    $usersreg[@usersreg-1] = "$usersreg[@usersreg-1]\n";
    @usersreg = join("\n", @usersreg);

    open (USERREG_FILE,">usersreg.txt");
    flock(USERREG_FILE, 2);
    print USERREG_FILE @usersreg;
    close(USERREG_FILE);


    if($reyting_reg <= $zapros_otkl)
    {
      open(MAIL,"|$mailprog -t");
      print MAIL "To: $name_reg <$email_reg>\n";
      print MAIL "From: robot\@fmob.org.ru\n";
      print MAIL "Content-type:text/plain;charset=windows-1251\n";
      print MAIL "Subject: ��� �������� � �����������!\n\n";
      print MAIL "������������, $name_reg!\n";
      print MAIL "���� ������ ���� �����������. � ��������� ��� ���� ��������.\n";

      print MAIL "\n--------------\n������������� fmob.org.ru.";
      close (MAIL);
    }

    $redirectto = "$site?mode=registration&action=zaprosi&id=$id_reg";
  }

  &html;

  if($id_reg ne "")
  {
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg, @posts) = split(/\|/,$usersreg[$id_reg-1]);

    @za_regs = split(/\:/,$za_reg);
    $za_reg = "";
    for(@za_regs)
    {
      $za_reg = "$za_reg, ". &Get_Formated_User_Name($_);
    }
    substr($za_reg, 0, 2) = "";

    @protiv_regs = split(/\:/,$protiv_reg);
    $protiv_reg = "";
    for(@protiv_regs)
    {
      $protiv_reg = "$protiv_reg, ". &Get_Formated_User_Name($_);
    }
    substr($protiv_reg, 0, 2) = "";

    print "<form action=\"\" method=POST>\n";
    print "<input type=hidden name=mode value=registration>\n";
    print "<input type=hidden name=action value=zaprosi>\n";
    print "<input type=hidden name=id value=$id_reg>\n";
    print "<table border=0 cellpadding=4 align=center>\n";
    print "<tr><td colspan=2 align=center><b><font size=4>������� �� �����������</font></b></td></tr>\n";
    print "<tr><td bgcolor=$seriy><b>�������� ���<td bgcolor=$sseriy>$name_reg";
    print "<tr><td bgcolor=$seriy><b>E-mail<td bgcolor=$sseriy>$email_reg";
    print "<tr><td bgcolor=$seriy><b>IP-�����<td bgcolor=$sseriy>$REMOTE_ADDR_reg";
    print "<tr><td bgcolor=$seriy><b>�����<td bgcolor=$sseriy>$guest_random_id";
    print "<tr><td bgcolor=$seriy><b>���� �������<td bgcolor=$sseriy>$date_reg";
    print "<tr><td bgcolor=$seriy><b>���������� � ������<td bgcolor=$sseriy>$uchastvoval_reg";
    print "<tr><td bgcolor=$seriy><b>� �����<td bgcolor=$sseriy>$uchastie_v_akcii_reg";
    print "<tr><td bgcolor=$seriy><b>��� ����������<td bgcolor=$sseriy>$vlechenie_reg";
    print "<tr><td bgcolor=$seriy><b>������ �����<td bgcolor=$sseriy>$uznali_reg";
    print "<tr><td bgcolor=$seriy><b>�������<td bgcolor=$sseriy>$reyting_reg";
    print "<tr><td bgcolor=$seriy><b>��<td bgcolor=$sseriy>$za_reg";
    print "<tr><td bgcolor=$seriy><b>������<td bgcolor=$sseriy>$protiv_reg";
    if($reyting_reg < $zapros_podtv&$reyting_reg > $zapros_otkl)
    {
      print "<tr bgcolor=$sseriy><td colspan=2 align=center><input type=submit style=\"background-color: $tseriy;\" name=action2 value=��> <input type=submit style=\"background-color: $tseriy;\" name=action2 value=������>";
    }

    print "<tr bgcolor=$tseriy><td colspan=2 align=center><b>����������";
    $i = 0;
    for(@posts)
    {
      ($userid_buf, $message_buf) = split(/\\/,$_);
      if($message_buf eq "")
      {
        delete($posts[$i]);
      }
      $i++;
    }
    for(@posts)
    {
      ($userid_buf, $message_buf) = split(/\\/,$_);
      $userid_buf = &Get_Formated_User_Name($userid_buf);
      print "<tr><td bgcolor=$seriy>$userid_buf<td bgcolor=$sseriy>$message_buf";
    }
    print "<tr><td bgcolor=$seriy colspan=2 align=center><textarea name=message rows=5 cols=100 class=post></textarea></td>";
    print "<tr bgcolor=$sseriy><td colspan=2 align=center><input type=submit style=\"background-color: $tseriy;\" name=action2 value=���������>";


    print "</table>\n";
    &htmlend;
    exit;
  }

  print "<table border=0 cellpadding=4 align=center>\n";
  print "<tr><td colspan=8 align=center><b><font size=4>������� �� �����������</font></b></td></tr>\n";
  print "<tr><td colspan=8 align=center>(<font color=red>������� �������� ����������� ������� - ������� $zapros_otkl</font><font color=green> ������ �������� ������������� ������� - ������� +$zapros_podtv</font>)</td></tr>\n";

  print "<tr><td>�<td>���<td>�������<td>���������<td>�����<td>IP<td>���� ������<td>";

  $i=0;
  $razmer= @usersreg;

  for(@usersreg)
  {
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg,  $date_reg, @posts) = split(/\|/,$_);
    $guest_random_ids{$guest_random_id}++;
    $REMOTE_ADDR_regs{$REMOTE_ADDR_reg}++;

    if($guest_random_ids{$guest_random_id}>1)
    {
      $guest_random_id = "<b>$guest_random_ids{$guest_random_id}</b> <font color=blue>$guest_random_id";
    }
    if($REMOTE_ADDR_regs{$REMOTE_ADDR_reg}>1)
    {
      $REMOTE_ADDR_reg = "<b>$REMOTE_ADDR_regs{$REMOTE_ADDR_reg}</b> <font color=blue>$REMOTE_ADDR_reg";
    }

    $_ = join("|", ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg,  $date_reg, @posts));
  }

  for($j=$razmer-1;$j>=0;$j--)
  {
    $buf= $usersreg[$j];
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg,  $date_reg, @posts) = split(/\|/,$buf);
    $i++;
    $buf = $j + 1;
    if($reyting_reg >= $zapros_podtv)
    {$color="green"}
    elsif($reyting_reg <= $zapros_otkl)
    {$color="red"}
    else
    {$color=$sseriy}

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
    }
    else
    {
      $flag = 1;
    }
    $posts_buf = @posts;

    if($posts_buf eq 1)
    {
      if(not($posts[0] =~ m/\\/gi)){$posts_buf = 0}
    }

    if($flag eq 1)
    {
      print "<tr bgcolor=$color><td>$buf<td><a href=$site?mode=registration&action=zaprosi&id=$buf>$name_reg<td>$reyting_reg<td>$posts_buf<td>$guest_random_id<td>$REMOTE_ADDR_reg<td nowrap>$date_reg<td><a href=$site?mode=registration&action=zaprosi&id=$buf>���������";
    }
    else
    {
      print "<tr bgcolor=$color><td><b>$buf<td><b><a href=$site?mode=registration&action=zaprosi&id=$buf>$name_reg<td><b>$reyting_reg<td><b>$posts_buf<td><b>$guest_random_id<td><b>$REMOTE_ADDR_reg<td nowrap><b>$date_reg<td><b><a href=$site?mode=registration&action=zaprosi&id=$buf>���������";
    }
  }
  print "</table>\n";

  &htmlend;
  exit;
}

sub registration_vostanov{

  &html;
  $Userid="";
  open (userstxt, "<users/users.txt");
  flock(userstxt, 1);
  @users = <userstxt>;
  close userstxt;
  $namebuf1=param(name);
  $namebuf=lc(param(name));
  $c = 0;
  $b = 0;
  foreach $a(@users)
  {
    $b++;
    chomp $a;
    $a = lc($a);
    if($namebuf eq $a)
    {
      $c = 1;
      open (userinfo, "<users/$b.txt");
      flock(userinfo, 1);
      @userinfo = <userinfo>;
      close userinfo;

      $pass = int(rand(9999999)+1000000);
      $Userid_Hash=md5_hex($pass);
      $email = @userinfo[4];
      chomp $email;

      if($email ne "")
      {
        @userinfo[1] = "$Userid_Hash\n";

        open (USERINFOBUF,">users/$b\_buf.txt");
        flock(USERINFOBUF, 2);
        print USERINFOBUF @userinfo;
        close(USERINFOBUF);


        rename("users/$b.txt", "users/$b\_old.txt");
        rename("users/$b\_buf.txt", "users/$b.txt");
        close(USERS);
        close(USERSBUF);
      }
    }
  }

  if($c eq 1)
  {
    if($email ne "")
    {
      open(MAIL,"|$mailprog -t");
      print MAIL "To: $email\n";
      print MAIL "From: robot\@fmob.org.ru\n";
      print MAIL "Content-type:text/plain;charset=windows-1251\n";
      print MAIL "Subject: FMob �������������� ������\n\n";
      print MAIL "���: $namebuf1\n";
      print MAIL "����� ������: $pass\n";
      print MAIL "���� �� ����: $site?mode=registration&action=login\n";
      close (MAIL);
      print "<center><b>����� ������ ������ �� $email.</b>";
    }
    else
    {
      print "<center><b>�������������� ����������, �� � ������� �� ������ email!</b>"
    }
  }
  else
  {
    print "<center><b>�� ������ ��������� ������.</b>"
  }
  &htmlend;
  exit;
}

sub registration_vostanov_forma{
  &html;
  print <<FORMA;
<div align=center><b><font size=4>�������������� ������</font></b><br><br>
<br>
<center>
<table border=0 cellspacing=0 cellpadding=2>
<form action="$site?mode=registration&action=vostanov" method=POST>
<input type=hidden name=mode value=registration>
<input type=hidden name=action value=vostanov>
<input type=hidden name=finish value=1>
<tr>
<td>��� ���:</td>
<td><input type=text size=16 name=name></td>
</tr>
<tr>
<td></td>
<td align=center><input type=submit style=\"background-color: $tseriy;\" value=������������></td>
</tr>
</form></table>
<br>
���� �� �� ������� ������ ����, �� ������ ���������� <a href=$site?mode=mobbers>������ ��������</a>.
</center>
<p align=left>
FORMA
  &htmlend;
  exit;
}

sub newreg {

  open (USERREG_FILE, "<usersreg.txt");
  flock(USERREG_FILE, 1);
  @usersreg = <USERREG_FILE>;
  close USERREG_FILE;
  $new_reg = 0;
  for(@usersreg)
  {
    ($name_reg, $password_reg, $email_reg, $uznali_reg, $vlechenie_reg, $uchastvoval_reg, $uchastie_v_akcii_reg, $REMOTE_ADDR_reg, $guest_random_id, $reyting_reg, $za_reg, $protiv_reg, $date_reg) = split(/\|/,$_);

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

  print header(-charset=>"windows-1251");
  print <<FORMA;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Language" content="ru">
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<link href=main.css type=text/css rel=stylesheet>
<title>������������� �����������</title>
</head>
<body topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0>
<table width='100%' height='100%'><tr bgcolor=$tseriy><td align='center' valign='middle'>
<b><font size=4><a href="javascript:showreg()">����� ��������: $new_reg</a></b></font>

<script language="LiveScript">
function showreg() {
  opener.open('$site?mode=registration&action=zaprosi');
  window.close('?mode=newreg', 'newreg');
}

</script>

</body>
</html>
FORMA
  exit;
}

1;