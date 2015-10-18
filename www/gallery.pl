sub show_gallery {
  $galleryid = $_[0];

  open (galleryfile, "<galleries/$galleryid.txt");
  flock(galleryfile, 1);
  @gallery = <galleryfile>;
  close galleryfile;

  for(@gallery)
  {
    chomp $_;
  }

  ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($galleryid);

  $title="$title - $gallerynamebuf";

  &html;

  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center colspan=4>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=70%><font size=+1><b><a href=$site?mode=gallery>Галерея</a> :: ";
  print "<a href=$site?mode=gallery&album=$galleryid>$gallerynamebuf</a>";

  if($galleryavtorbuf eq $Userid | (($usertype eq "модераторы")|($usertype eq "администраторы")))
  {
    print "<td align=center nowrap><font size=1><b>[<a class=adm href=$site?mode=gallery&editalbum=$galleryid>Редактировать</a>]\n";
  }
  print "<td align=center nowrap>$gallerydatebuf\n";
  print "<td align=center>".&Get_Formated_User_Name($galleryavtorbuf)."\n";
  print "</table>\n";

  $page = param(page);
  if($page eq "")
  {
    $page=1;
  }
  $photoscol = @gallery;

  $pagebuf = &buildpegelist($photoscol, $page, $photoonpage, "$site?mode=gallery&album=$galleryid&page=");

  print "<tr bgcolor=$beliy>\n";
  print "<td align=center colspan=3>$pagebuf";
  print "<td align=right><a href=$site?mode=gallery&album=$galleryid&action=addphoto>Добавить фото";

  if(@gallery>0)
  {
    $i = 4;
    $j = 0;


    for($k=0;$k<$photoscol;$k++)
    {
      if(int(($k)/$photoonpage)+1 ne $page)
      {
        next
      }

      ($imagebuf, $avtorbuf, $timebuf, $commentbuf, $visiblebuf, $tbwidthbuf, $tbheightbuf, $widthbuf,  $heightbuf, $sizebuf, $viewbuf) = split(/\|/,$gallery[$k]);

      if($i eq 4)
      {
        print "<tr bgcolor=$beliy>\n";
        $i = 0;
      }

      if($visiblebuf eq 1|($visiblebuf eq 0&($avtorbuf eq $Userid|(($usertype eq "модераторы")|($usertype eq "администраторы")))))
      {
        $i++;
        print "<td>\n";
        if($visiblebuf eq 0)
        {
          $color = "FFE3E3";
        }
        else
        {
          $color = $beliy;
        }
        print "<table border=0 cellspacing=0 cellpadding=0 bgcolor=$color width=100%>\n";

        $tbimagebuf = "tb_$imagebuf";

        if($imagebuf =~ /\.avi$|\.wmv$/i)
        {
          $tbimagebuf = "no_photo.gif";
          $$tbwidthbuf = 180;
          $tbheightbuf = 135;
        }

        print "<tr>\n";

        print "<td align=center colspan=2><a href=?mode=gallery&album=$galleryid&photo=$imagebuf><b>$imagebuf\n";
        print "</tr><tr>\n";
        print "<td align=center colspan=2><font size=1>Дата: $timebuf\n";
        print "</tr><tr>\n";
        print "<td align=center colspan=2><a href=?mode=gallery&album=$galleryid&photo=$imagebuf><img style=\"border: 0pt none\" src=photos/$tbimagebuf width=$tbwidthbuf height=$tbheightbuf alt='$commentbuf'></a>\n";
        print "</tr><tr>\n";
        print "<td align=center colspan=2><font size=1>$commentbuf\n";
        print "</tr><tr>\n";
        print "<td align=center nowrap><font size=1>Автор: ". &Get_Formated_User_Name($avtorbuf)."</td>\n";
        print "<td align=center><font size=1>Просмотров:<br>$viewbuf\n";

        if($avtorbuf eq $Userid | (($usertype eq "модераторы")|($usertype eq "администраторы")))
        {
          print "<tr>\n";
          print "<td align=center colspan=2>\n";
          print "<table border=0 cellspacing=0 cellpadding=0 bgcolor=$color width=100%>\n";
          print "<tr>\n";
          if($k eq 0)
          {
            print "<td align=center><font size=1 color=$ttseriy><b>[&lt;]\n";
            print "<td align=center><font size=1 color=$ttseriy><b>[&lt;&lt;]\n";
          }
          else
          {
            print "<td align=center><font size=1><b>[<a class=adm href=?mode=gallery&album=$galleryid&phototoprev=$imagebuf>&lt;</a>]\n";
            print "<td align=center><font size=1><b>[<a class=adm href=?mode=gallery&album=$galleryid&phototoprev10=$imagebuf>&lt;&lt;</a>]\n";
          }
          if($visiblebuf eq 0)
          {
            $buf = "Восстановить";
          }
          else
          {
            $buf = "Скрыть";
          }
          print "<td align=center><font size=1><b>[<a class=adm href=?mode=gallery&album=$galleryid&hidephoto=$imagebuf>$buf</a>]\n";
          if($k eq $photoscol-1)
          {
            print "<td align=center><font size=1 color=$ttseriy><b>[&gt;&gt;]\n";
            print "<td align=center><font size=1 color=$ttseriy><b>[&gt;]\n";
          }
          else
          {
            print "<td align=center><font size=1><b>[<a class=adm href=?mode=gallery&album=$galleryid&phototonext10=$imagebuf>&gt;&gt;</a>]\n";
            print "<td align=center><font size=1><b>[<a class=adm href=?mode=gallery&album=$galleryid&phototonext=$imagebuf>&gt;</a>]\n";
          }
          print "</tr></table>";
        }

        print "</tr></table>";
      }
      else
      {
        $photoscol++;
      }
    }


    for($j=$i;$j<=3;$j++)
    {
      print "<td align=center><img src=$site/photos/no_item.gif width=180 height=135>\n";
    }
  }
  else
  {
    print "<tr bgcolor=$beliy>\n";
    print "<td align=center colspan=4><h2>В этом альбоме нет фотографий.\n";
  }

  print "<tr bgcolor=$beliy>\n";
  print "<td align=center colspan=3>$pagebuf";
  print "<td align=right><a href=$site?mode=gallery&album=$galleryid&action=addphoto>Добавить фото";

  if($galleryforumbuf ne "")
  {
    $buf = &BoardGet($galleryforumbuf);

    open(GB, "<boards/$buf.txt");
    flock(GB, 1);
    while (<GB>)
    {
      ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
      if($buf1 eq $galleryforumbuf)
      {
        $timeoflastpostofplay{$galleryforumbuf}=$buf7;
        $postcountofplay{$galleryforumbuf}=$buf6;
        $threadofplay{$galleryforumbuf}=$buf1;
      }
      close (GB);
    }

    print "<tr bgcolor=$beliy>\n";
    print "<td colspan=4><b><a href=$site?mode=forum&thread=$galleryforumbuf&post=new>Обсуждение ($postcountofplay{$galleryforumbuf})</a></b>\n";
  }
  print "</table>";
}

sub get_gallery_info {
  $galleryidbuf = $_[0];

  open (galleriesfile, "<galleries/galleries.txt");
  flock(galleriesfile, 1);
  @galleries = <galleriesfile>;
  close galleriesfile;

  $gallerybuf = @galleries[$galleryidbuf-1];
  chomp $gallerybuf;

  return (split(/\|/,$gallerybuf))
}

sub show_photo {
  $galleryid = $_[0];
  $photobuf = $_[1];

  open (galleryfile, "+<galleries/$galleryid.txt");
  flock(galleryfile, 2);
  @gallery = <galleryfile>;

  for(@gallery)
  {
    chomp $_;
  }

  ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($galleryid);


  $photobuf = 0;
  $flagposle = 0;
  $photoidbuf = -1;
  $i = 0;
  LINE: for(@gallery)
  {
     if($flagposle eq 0&$visiblebuf1 eq 1)
     {
       $imagedobuf = $imagebuf1;
     }
     ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1) = split(/\|/,$_);
     if($flagposle eq 1&$visiblebuf1 eq 1)
     {
       $imageposlebuf = $imagebuf1;
       last LINE;
     }
     if($imagebuf1 eq $_[1])
     {
       ($imagebuf, $avtorbuf, $timebuf2, $commentbuf, $visiblebuf, $tbwidthbuf, $tbheightbuf, $widthbuf,  $heightbuf, $sizebuf, $viewbuf) = ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1);
       $viewbuf ++;
       $photoidbuf = $i;
       $photobuf = $imagebuf;
       $flagposle = 1;
     }
     $i++;
  }

  truncate galleryfile, 0;
  seek (galleryfile, 0, 0);
  if($photoidbuf>=0)
  {
    $gallery[$photoidbuf] = "$imagebuf|$avtorbuf|$timebuf2|$commentbuf|$visiblebuf|$tbwidthbuf|$tbheightbuf|$widthbuf|$heightbuf|$sizebuf|$viewbuf";
  }
  @gallery = join("\n", @gallery);
  print galleryfile @gallery;
  close galleryfile;

  $title="$title - $gallerynamebuf - $imagebuf";

  &html;

  if($visiblebuf eq 0 & not($galleryavtorbuf eq $Userid | (($usertype eq "модераторы")|($usertype eq "администраторы"))))
  {
    &netdostupa;
  }

  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=70%><font size=+1><b><a href=$site?mode=gallery>Галерея</a> :: ";
  print "<a href=$site?mode=gallery&album=$galleryid>$gallerynamebuf</a> :: ";
  print "<a href=$site?mode=gallery&album=$galleryid&photo=$photobuf>$imagebuf</a>";
  print "<td align=center>$timebuf2\n";
  print "<td align=center>".&Get_Formated_User_Name($avtorbuf)."\n";
  print "</table>\n";

  print "<tr bgcolor=$beliy><td align=center>\n";
  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$beliy width=100%>\n";
  print "<tr bgcolor=$beliy>\n";
  if($imagedobuf ne "")
  {
    print "<td align=center><a href=?mode=gallery&album=$galleryid&photo=$imagedobuf>Предыдущее\n";
  }
  else
  {
    print "<td align=center><font color=$ttseriy>Предыдущее\n";
  }
  print "<td align=center width=70%>$commentbuf\n";
  if($imageposlebuf ne "")
  {
    print "<td align=center><a href=$site?mode=gallery&album=$galleryid&photo=$imageposlebuf>Следующее\n";
  }
  else
  {
    print "<td align=center><font color=$ttseriy>Следующее\n";
  }

  print "</table>\n";

  $widthbuf2 = $widthbuf;
  $heightbuf2 = $heightbuf;

  $buf = "";
  if($photobuf =~ /\.avi$|\.wmv$/i)
  {
    $buf = "<a href=photos/$photobuf> Скачать $photobuf<br><br>";
    $photobuf = "no_photo.gif";
    $widthbuf2 = 180;
    $heightbuf2 = 135;
  }

  print "<tr bgcolor=$beliy><td align=center>\n";
  print "$buf<img style=\"border: 0pt none\" src=photos/$photobuf width=$widthbuf2 height=$heightbuf2 alt='$sizebuf КБ; $commentbuf'>\n";


  print "<tr bgcolor=$beliy><td align=center>\n";
  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$beliy width=100%>\n";
  print "<tr bgcolor=$beliy>\n";
  print "<td>Просмотров: $viewbuf\n";
  print "<td>Размер: $sizebuf1 КБ\n";
  print "<td>Разрешение: $widthbuf х $heightbuf\n";

  if($avtorbuf eq $Userid | (($usertype eq "модераторы")|($usertype eq "администраторы")))
  {
    print "<td align=right><font size=1><b>[<a class=adm href=$site?mode=gallery&album=$galleryid&editphoto=$photobuf>Редактировать</a>]\n";
  }
  print "</table>\n";

  if($galleryforumbuf ne "")
  {
    $buf = &BoardGet($galleryforumbuf);


    open(GB, "<boards/$buf.txt");
    flock(GB, 1);
    while (<GB>)
    {
      ($buf1, $buf2, $buf3, $buf4, $buf5, $buf6, $buf7, $buf8)=split(/\|/,$_);
      if($buf1 eq $galleryforumbuf)
      {
        $timeoflastpostofplay{$galleryforumbuf}=$buf7;
        $postcountofplay{$galleryforumbuf}=$buf6;
        $threadofplay{$galleryforumbuf}=$buf1;
      }
      close (GB);
    }

    print "<tr bgcolor=$beliy>\n";
    print "<td colspan=4><b><a href=$site?mode=forum&thread=$galleryforumbuf&post=new>Обсуждение ($postcountofplay{$galleryforumbuf})</a></b>\n";
  }

  print "</table>\n";
}

sub show_galleries {

  open (galleriesfile, "<galleries/galleries.txt");
  flock(galleriesfile, 1);
  @galleries = <galleriesfile>;
  close galleriesfile;

  for(@galleries)
  {
    chomp $_;
  }


  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center colspan=4>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=90%><font size=+1><b><a href=$site?mode=gallery>Галерея</a>";
  print "<td nowrap><a href=$site?mode=gallery&action=addalbum>Новый альбом</a>";
  print "</table>\n";


  $page = param(page);
  if($page eq "")
  {
    $page=1;
  }
  $galleriescol = @galleries;

  $pagebuf = &buildpegelist($galleriescol, $page, $albumonpage, "$site?mode=gallery&page=");

  print "<tr bgcolor=$beliy>\n";
  print "<td align=center colspan=4>$pagebuf";

  $i = 4;
  for($k=$galleriescol;$k>0;$k--)
  {
    if(int(($galleriescol - $k)/$albumonpage)+1 ne $page)
    {
      next
    }

    ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = split(/\|/,$galleries[$k-1]);

    if($galleryimagebuf eq "")
    {
      $galleryimagebuf = "no_photo.gif";
      $gallerytbwidthbuf = 180;
      $gallerytbheightbuf = 135;
    }
    else
    {
      $galleryimagebuf = "tb_$galleryimagebuf";
    }


    if($i eq 4)
    {
      print "<tr bgcolor=$beliy>\n";
      $i = 0;
    }

    open (galleryfile, "galleries/$k.txt");
    flock(galleryfile, 1);
    @gallery = <galleryfile>;
    close galleryfile;

    for(@gallery)
    {
      chomp $_;
    }

    $gallerycolphotosbuf = 0;
    $gallerycolviewbuf = 0;
    my(@album) = ();
    my(@albumsort) = ();
    for(@gallery)
    {
      ($imagebuf, $avtorbuf, $timebuf, $commentbuf, $visiblebuf, $tbwidthbuf, $tbheightbuf, $widthbuf,  $heightbuf, $sizebuf, $viewbuf) = split(/\|/,$_);
      if($visiblebuf eq 1)
      {
        $gallerycolphotosbuf++;
        $gallerycolviewbuf = $gallerycolviewbuf + $viewbuf;
      }
      if($visiblebuf eq 1)
      {
        $photoview{"tb_$imagebuf"} = $viewbuf;
        $phototbwidth{"tb_$imagebuf"} = $tbwidthbuf;
        $phototbheight{"tb_$imagebuf"} = $tbheightbuf;
        $album[@album] = "tb_$imagebuf";
      }
    }
    if(@gallery>0)
    {
      @albumsort = sort { $photoview{$b} <=> $photoview{$a}} @album;
      @album = ();
      $buf = $photoview{$albumsort[0]};
      for(@albumsort)
      {
        if($photoview{$_} eq $buf)
        {
          $album[@album] = $_;
        }
      }
      $buf = $album[int(rand(@album))];
      $galleryimagebuf = $buf;
      $gallerytbwidthbuf = $phototbwidth{$buf};
      $gallerytbheightbuf = $phototbheight{$buf};
    }

    if($galleryimagebuf =~ /\.avi$|\.wmv$/i)
    {
      $galleryimagebuf = "no_photo.gif";
      $gallerytbwidthbuf = 180;
      $gallerytbheightbuf = 135;
    }


    if($galleryvisiblebuf eq 1|($galleryvisiblebuf eq 0&($galleryavtorbuf eq $Userid|(($usertype eq "модераторы")|($usertype eq "администраторы")))))
    {
      $i++;
      print "<td>\n";
      if($galleryvisiblebuf eq 0)
      {
        $color = "FFE3E3";
      }
      else
      {
        $color = $beliy;
      }
      print "<table border=0 cellspacing=0 cellpadding=0 bgcolor=$color width=100%>\n";
      print "</tr><tr>\n";
      print "<td align=center colspan=2><a href=?mode=gallery&album=$k><b>$gallerynamebuf</b></a><br>";
      print "<font size=1>Дата: $gallerydatebuf<br>\n";
      print "<a href=?mode=gallery&album=$k><img style=\"border: 0pt none\" src=photos/$galleryimagebuf width=$gallerytbwidthbuf height=$gallerytbheightbuf alt='$gallerynamebuf'></a></center>\n";
      print "</tr><tr>\n";
      print "<td align=center nowrap><font size=1>Автор: ". &Get_Formated_User_Name($galleryavtorbuf)."</td>\n";
      print "<td align=center><font size=1>Просмотров:<br>$gallerycolviewbuf\n";
      print "</tr><tr>\n";
      print "<td align=center colspan=2><font size=1>Фотографий: $gallerycolphotosbuf\n";
      if($galleryavtorbuf eq $Userid | (($usertype eq "модераторы")|($usertype eq "администраторы")))
      {
        print "<tr>\n";
        print "<td align=center colspan=2>\n";
        if($galleryvisiblebuf eq 0)
        {
          $buf = "Восстановить";
        }
        else
        {
          $buf = "Скрыть";
        }
        print "<font size=1><b>[<a class=adm href=?mode=gallery&hidealbum=$k>$buf</a>]\n";
      }
      print "</tr></table>";
    }
  }


  for($j=$i;$j<=3;$j++)
  {
    print "<td align=center><img src=$site/photos/no_item.gif width=180 height=135>\n";
  }

  print "<tr bgcolor=$beliy>\n";
  print "<td align=center colspan=4>$pagebuf";

  print "</table>\n";
}

sub add_form_album {
  $title="$title - Добавление нового альбома";
  &html;
  if($login eq 0){&netdostupa};


  $dey1 = param(album_dd);
  $mday1 = "";
  $i=0;
  foreach (@mdays)
  {
    $i++;
    if(param(album_mmm) eq $_)
    {
      $mday1 = $i;
      $mday1 = "0$mday1" if ($mday1<10);
      last;
    }
  }
  $year1 = param(album_yyyy);
  $hour1 = param(album_hh);
  $min1 = param(album_mm);

  $albumname = param(albumname);
  $albumforum = param(albumforum);
  if(param(albumnewforum) eq "on")
  {
    $albumnewforum = " checked";
  }

  print "<form action='$site?mode=gallery&action=addalbum' method=post>";
  print "<input name='mode' value='gallery' type='hidden'>";

  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center colspan=2>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=80%><font size=+1><b><a href=$site?mode=gallery>Галерея</a> :: ";
  print "<a href=$site?mode=gallery&action=addalbum>Добавление нового альбома</a>";
  print "</table>\n";


  print "<tr bgcolor=$beliy>\n";
  print "<td colspan=2>Для добавления нового альбома заполните форму и нажмите \"Добавить\".";
  print "<tr bgcolor=$beliy>\n";
  print "<td>$redbufНазвание альбома:";
  print "<td width=80%><input type=text name=albumname size=66 value='$albumname'></td>";
  print "<tr bgcolor=$beliy>\n";
  print "<td>ID темы на форуме:";
  print "<td width=80%><input type=text name=albumforum size=16 value='$albumforum'> Укажите ID темы на форуме в которой будет идти обсуждение данного альбома<br>";
  print "<input type=checkbox name=albumnewforum$albumnewforum> Создать новую тему на форуме";

#  ($dey1, $mday1, $year1, $hour1, $min1) = ("", "", "", "", "");

  print "<tr bgcolor=$beliy>\n";
  print "<td>Дата и время события:";
  print "<td width=80%>";
  print "<select name=album_dd><option>";

  for($j=1;$j<=31;$j++)
  {
    $daybuf = $j;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($dey1 eq $daybuf)
    {print "<option selected>$daybuf"}
    else
    {print "<option>$daybuf"}
  }

  print "</select><select name=album_mmm><option>";

  for($j=0;$j<12;$j++)
  {
    $daybuf = $j+1;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($mday1 eq $daybuf)
    {print "<option selected>$mdays[$j]";}
    else
    {print "<option>$mdays[$j]"}
  }

  print "</select><select name=album_yyyy><option>";

  for($j=1995;$j<=$year+1;$j++)
  {
    $yearbuf = $j;
    if($year1 eq $yearbuf)
    {print "<option selected>$yearbuf"}
    else
    {print "<option>$yearbuf"}
  }

  print "</select>&nbsp; &nbsp;<select name=album_hh><option>";

  for($j=0;$j<=23;$j++)
  {
    $hourbuf = $j;
    $hourbuf = "0$hourbuf" if ($hourbuf < 10);
    if($hour1 eq $hourbuf)
    {print "<option selected>$hourbuf"}
    else
    {print "<option>$hourbuf"}
  }

  print "</select>:<select name=album_mm><option>";
  for($j=0;$j<=59;$j++)
  {
    $minbuf = $j;
    $minbuf = "0$minbuf" if ($minbuf < 10);
    if($min1 eq $minbuf)
    {print "<option selected>$minbuf"}
    else
    {print "<option>$minbuf"}
  }
  print "</select>";

  print "<br> Для того, что бы установить текущую дату и время оставьте поле незаполненным</td>\n";

  print "<tr bgcolor=$beliy>\n";
  print "<td colspan=2 align=center><input type=submit name=action2 style=\"background-color: $tseriy;\" value=Добавить>";


  print "</table>\n";
  print "</form>"
}

sub add_album {
  if(param(albumname) eq "")
  {
    $redbuf = "<font color=red>";
    &add_form_album;
    &htmlend;
    exit;
  }

  open (galleriesfile, "<galleries/galleries.txt");
  flock(galleriesfile, 2);
  @galleries = <galleriesfile>;
  close galleriesfile;

  $gallerynamebuf = param(albumname);
  $galleryavtorbuf = $Userid;
  $galleryvisiblebuf = 1;
  $galleryimagebuf = "";
  $gallerytbwidthbuf = "";
  $gallerytbheightbuf = "";
  $galleryid = @galleries;
  $galleryid ++;

  $gallerynamebuf =~ s~>~&gt;~ig;
  $gallerynamebuf =~ s~<~&lt;~ig;
  $gallerynamebuf =~ s~\|~&#124;~g;

  if(param(albumnewforum) eq "on")
  {
    $subjectbuf = $gallerynamebuf;
    $messagebuf = "$site?mode=gallery&album=$galleryid";
    $commentbuf = "Альбом";
    $board = 15;
    $typebuf = "1";

    &addthread;
    &Inc_Col_Mes;
    &lastthread_update($newthreadid, $subjectbuf, $nowtime, $Userid, $board, 0);
    ($buf,$to2)=&get_subscribe_mails(3);
    &send_subscribe("\[url=$site?mode=forum&thread=$newthreadid\]\[size=4\]$subjectbuf\[/size\]\[/url\]\[br\]\[color=gray\] $commentbuf \[/color\]\[br\]\[b\]Автор:\[/b\] \[url=$site?showuser=$Userid\]$UserName\[/url\]\[br\]\[br\]\[hr\]$messagebuf\[hr\]\[br\]$site?mode=forum&thread=$newthreadid\[br\]\[br\]$site", "FMob: Создана новая тема: \"$subjectbuf\"", "\"$UserName\" <subscribe\@fmob.org.ru>", "", $to2);
    $galleryforumbuf = $newthreadid;
  }
  else
  {
    $galleryforumbuf = param(albumforum);
    $galleryforumbuf =~ /(\d+)/;
  }

  if(param(album_dd) ne "" & param(album_mm) ne "" & param(album_yyyy) ne "" & param(album_hh) ne "" & param(album_mm) ne "")
  {
    $i=0;
    foreach (@mdays)
    {
      $i++;
      if(param(album_mmm) eq $_)
      {
        $album_mmm = $i;
        $album_mmm = "0$album_mmm" if ($album_mmm<10);
        last;
      }
    }
    $album_dd = param(album_dd);
    $album_yyyy = param(album_yyyy);
    $album_hh = param(album_hh);
    $album_mm = param(album_mm);

    $datebuf = "$album_dd.$album_mmm.$album_yyyy";

    $timebuf = "$album_hh:$album_mm";

    $gallerydatebuf = &getwday($datebuf, 1). " $timebuf - $datebuf";
  }
  else
  {
    $gallerydatebuf = $nowtime;
  }

  open (galleriesfile, ">>galleries/galleries.txt") || open(galleriesfile, ">galleries/galleries.txt");;
  flock(galleriesfile, 2);
  print galleriesfile "$gallerynamebuf|$gallerydatebuf|$galleryavtorbuf|$galleryvisiblebuf|$galleryimagebuf|$gallerytbwidthbuf|$gallerytbheightbuf|$galleryforumbuf\n";
  close galleriesfile;

  $redirectto = "$site?mode=gallery&album=$galleryid";
  &html;
  exit;
}

sub add_form_photo {
  $editphoto = param(editphoto);
  if(param(editphoto) ne "")
  {
    $title="$title - Редактирование фотографии";
  }
  else
  {
    $title="$title - Добавление новой фотографии";
  }
  &html;

  if($login eq 0){&netdostupa};
  
  $albumid = param(album);

  $dey1 = param(album_dd);
  $mday1 = "";
  $i=0;
  foreach (@mdays)
  {
    $i++;
    if(param(album_mmm) eq $_)
    {
      $mday1 = $i;
      $mday1 = "0$mday1" if ($mday1<10);
      last;
    }
  }
  $year1 = param(album_yyyy);
  $hour1 = param(album_hh);
  $min1 = param(album_mm);

  $photocoment = param(photocoment);

  if(param(editphoto) ne "" & param(notfinish) ne 1)
  {
    open (albumfile, "<galleries/$albumid.txt");
    flock(albumfile, 2);
    @album = <albumfile>;
    close albumfile;

    LINE: for(@album)
    {
      ($imagebuf, $avtorbuf, $timebuf, $commentbuf, $visiblebuf, $tbwidthbuf, $tbheightbuf, $widthbuf,  $heightbuf, $sizebuf, $viewbuf) = split(/\|/,$_);
      if($imagebuf eq param(editphoto))
      {

        ($hour1, $min1, $dey1, $mday1, $year1) = ($timebuf =~ /.. (\d+)\:(\d+) - (\d+)\.(\d+)\.(\d+)/);
        $photocoment = $commentbuf;
        last LINE;
      }
    }
  }

  ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($albumid);

  if(param(editphoto) ne "")
  {
    print "<form action='$site?mode=gallery&album=$albumid&editphoto=$editphoto' method=post enctype='multipart/form-data'>";
  }
  else
  {
    print "<form action='$site?mode=gallery&action=addphoto' method=post enctype='multipart/form-data'>";
  }
  print "<input name='mode' value='gallery' type='hidden'>";
  print "<input name='album' value='$albumid' type='hidden'>";
  if(param(editphoto) ne "")
  {
    print "<input name='editphoto' value='$editphoto' type='hidden'>";
    print "<input name='notfinish' value='1' type='hidden'>";
  }
  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center colspan=2>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=80%><font size=+1><b><a href=$site?mode=gallery>Галерея</a> :: ";
  print "<a href=$site?mode=gallery&album=$albumid>$gallerynamebuf</a> :: ";

  if(param(editphoto) ne "")
  {
    print "<a href=$site?mode=gallery&album=$albumid&editphoto=$editphoto>Редактирование фотографии</a>";
  }
  else
  {
    print "<a href=$site?mode=gallery&action=addphoto>Добавление новой фотографии</a>";
    print "<tr bgcolor=$beliy>\n";
    print "<td colspan=2>$photoagainДля добавления новой фотографии заполните форму и нажмите \"Добавить\".<br>Рекомендуеться загружать несжатые фотографии.";
  }
  print "</table>\n";

  print "<tr bgcolor=$beliy>\n";
  print "<td>Комментарий:";
  print "<td width=80%><input type=text name=photocoment size=66 value='$photocoment'></td>";
  if(param(editphoto) eq "")
  {
    print "<tr bgcolor=$beliy>\n";
    print "<td>Уменьшить до:";
    print "<td width=80%><select name=photoresize><option>640x480<option selected>800x600<option>1024x768</select>";
    print " Фото будет уменьшено, если оно больше выбранного разрешения";
  }

  print "<tr bgcolor=$beliy>\n";
  print "<td>Дата и время фото:";
  print "<td width=80%>";

  $cheked2buf = " checked";
  if(param(editphoto) ne "")
  {
    $cheked2buf = "";
    $cheked1buf = " checked";
  }

  print "<input name=photodatetime value=1 type=radio$cheked1buf> <select name=album_dd><option>";

  for($j=1;$j<=31;$j++)
  {
    $daybuf = $j;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($dey1 eq $daybuf)
    {print "<option selected>$daybuf"}
    else
    {print "<option>$daybuf"}
  }

  print "</select><select name=album_mmm><option>";

  for($j=0;$j<12;$j++)
  {
    $daybuf = $j+1;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($mday1 eq $daybuf)
    {print "<option selected>$mdays[$j]";}
    else
    {print "<option>$mdays[$j]"}
  }

  print "</select><select name=album_yyyy><option>";

  for($j=1995;$j<=$year+1;$j++)
  {
    $yearbuf = $j;
    if($year1 eq $yearbuf)
    {print "<option selected>$yearbuf"}
    else
    {print "<option>$yearbuf"}
  }

  print "</select>&nbsp; &nbsp;<select name=album_hh><option>";

  for($j=0;$j<=23;$j++)
  {
    $hourbuf = $j;
    $hourbuf = "0$hourbuf" if ($hourbuf < 10);
    if($hour1 eq $hourbuf)
    {print "<option selected>$hourbuf"}
    else
    {print "<option>$hourbuf"}
  }

  print "</select>:<select name=album_mm><option>";
  for($j=0;$j<=59;$j++)
  {
    $minbuf = $j;
    $minbuf = "0$minbuf" if ($minbuf < 10);
    if($min1 eq $minbuf)
    {print "<option selected>$minbuf"}
    else
    {print "<option>$minbuf"}
  }
  print "</select>";

  print "<br> Для того, что бы установить текущую дату и время оставьте поле незаполненным<br>\n";

  if($noexif ne 1)
  {
    print "<input name=photodatetime value=2$cheked2buf type=radio>  Использовать информацию о дате фото из JPEG<br>";
  }
  else
  {
    if($cheked3buf eq "")
    {
      $cheked3buf = " checked";
    }
  }
  print "<input name=photodatetime value=3 type=radio$chekedbuf>  Использовать дату альбома";

  print "</td>";

  if(param(editphoto) eq "")
  {
    print "<tr bgcolor=$beliy>\n";
    print "<td nowrap>Ваш файл:</td>\n";
    print "<td><input name='file_upload' size='40' type='file'>\n";
    print "<br>Форматы: JPG, GIF, PNG; AVI, WMV (не более 6 МБ)\n";
    print "</td>";
    print "<tr bgcolor=$beliy>\n";
    print "<td colspan=2>\n";
    print "<input type=checkbox name=photoagain checked> После загрузки загрузить ещё одно фото";
  }

  print "<tr bgcolor=$beliy>\n";
  print "<td colspan=2 align=center><input type=submit name=action3 style=\"background-color: $tseriy;\" value=Добавить>";


  print "</table>\n";
  print "</form>"
}

sub add_photo {
  $albumid = param(album);

  if(param(photodatetime) eq "1")
  {
    if(param(album_dd) ne "" & param(album_mm) ne "" & param(album_yyyy) ne "" & param(album_hh) ne "" & param(album_mm) ne "")
    {
      $i=0;
      foreach (@mdays)
      {
        $i++;
        if(param(album_mmm) eq $_)
        {
          $album_mmm = $i;
          $album_mmm = "0$album_mmm" if ($album_mmm<10);
          last;
        }
      }
      $album_dd = param(album_dd);
      $album_yyyy = param(album_yyyy);
      $album_hh = param(album_hh);
      $album_mm = param(album_mm);

      $datebuf = "$album_dd.$album_mmm.$album_yyyy";

      $timebuf = "$album_hh:$album_mm";

      $photodatebuf = &getwday($datebuf, 1). " $timebuf - $datebuf";
    }
    else
    {
      $photodatebuf = $nowtime;
    }
  }

  if(param(photodatetime) eq "3")
  {
    ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($albumid);
     $photodatebuf = $gallerydatebuf;
  }


  $file_upload = param(file_upload);

  my($file_type) = $file_upload =~ /\.(.+?)$/;

  my($outfile) = $file_upload =~ m#([^\\/:]+)$#;

  $outfile = k82tr($outfile);

  $newname = "";
  $b = 0;
  while (-e "photos/$newname$outfile")
  {
    $b++;
    $newname = "$b\_";
  }
  $outfile = "$newname$outfile";

  open (OUTFILE, ">photos/$outfile");
  flock(OUTFILE, 2);
  while ($bytesread = read($file_upload,$buffer,1024))
  {
    binmode OUTFILE;
    print OUTFILE $buffer;
  }
  $sizebuf = -s OUTFILE;
  close(OUTFILE);

  if(not($outfile =~ /\.gif$|\.jpg$|\.jpeg$|\.png$|\.avi$|\.wmv$/i))
  {
    unlink("photos/$outfile");
    &noformat;
  }

  if($outfile =~ /\.avi$|\.wmv$/i)
  {
    if($sizebuf>6291456)
    {
      unlink("photos/$outfile");
      &nosize;
    }
  }

  if(param(photodatetime) eq "2")
  {
    %ii=getexifjpeg( "photos/$outfile" );
    $img_datetime = $ii{'DateTime'};

    if($img_datetime eq "")
    {
      $noexif = 1;
      $photoagain = "<font color=red><b>JPEG не содержит информации о дате</b></font><br>";
      unlink("photos/$outfile");
      &add_form_photo;
      &htmlend;
      exit;
    }
    else
    {
      ($album_yyyy, $album_mmm, $album_dd, $album_hh, $album_mm) = ($img_datetime =~ /(\d+)\:(\d+)\:(\d+) (\d+)\:(\d+)\:(\d+)/);

      $datebuf = "$album_dd.$album_mmm.$album_yyyy";

      $timebuf = "$album_hh:$album_mm";

      $photodatebuf = &getwday($datebuf, 1). " $timebuf - $datebuf";
    }
  }


  if($outfile =~ /\.gif$|\.jpg$|\.jpeg$|\.png$/i)
  {
    my($image, $x); #переменные
    $image = Image::Magick->new; #новый проект
    $x = $image->Read("photos/$outfile"); #открываем файл
    ($img_width,$img_height)=$image->Get('base-columns','base-rows'); #определяем ширину и высоту изображения


    if($img_width>$img_height)
    {
      $tbheightbuf = int(($img_height/$img_width)*180);
      $tbwidthbuf = 180;
    }
    else
    {
      $tbwidthbuf = int(($img_width/$img_height)*180);
      $tbheightbuf = 180;
    }

   $image->Resize(geometry=>geometry, width=>$tbwidthbuf, height=>$tbheightbuf);
   $image->Set('quality', 85);
   $x = $image->Write("photos/tb_$outfile"); #Сохраняем изображение

   $image = Image::Magick->new; #новый проект
   $x = $image->Read("photos/$outfile"); #открываем файл

    if(param(photoresize)eq "640x480")
    {
      $resizewidth = 640;
      $resizeheight = 480;
    }
    elsif(param(photoresize)eq "800x600")
    {
      $resizewidth = 800;
      $resizeheight = 600;
    }
    elsif(param(photoresize)eq "1024x768")
    {
      $resizewidth = 1024;
      $resizeheight = 768;
    }

    if($img_width*$img_height > $resizewidth*$resizeheight)
    {
      if($img_width>=$img_height)
      {
        $img_width_new = $resizewidth;
        $img_height_new = int(($img_width_new / $img_width) * $img_height);
      }
      else
      {
        $img_height_new = $resizewidth;
        $img_width_new = int(($img_height_new / $img_height) * $img_width);
      }
      $image->Resize(geometry=>geometry, width=>$img_width_new, height=>$img_height_new);
    }
    else
    {
      $img_height_new = $img_height;
      $img_width_new = $img_width;
    }

   $image->Label('Annotate');
   $image->Annotate(text=>'http://fmob.org.ru',geometry=>'+4+2',font=>'arialbd.ttf',
     fill=>'black',gravity=>'NorthWest',pointsize=>12);
   $image->Annotate(text=>'http://fmob.org.ru',geometry=>'+3+1',font=>'arialbd.ttf',
     fill=>'white',gravity=>'NorthWest',pointsize=>12);

   $image->Set('quality', 85);
   $x = $image->Write("photos/$outfile"); #Сохраняем изображение
   $sizebuf = $image->Get('filesize');
  }

  $imagebuf = $outfile;
  $avtorbuf = $Userid;
  $timebuf = $photodatebuf;
  $commentbuf = param(photocoment);
  $commentbuf =~ s~>~&gt;~ig;
  $commentbuf =~ s~<~&lt;~ig;
  $commentbuf =~ s~\|~&#124;~g;
  $visiblebuf = 1;
  $tbwidthbuf;
  $tbheightbuf;
  $widthbuf = $img_width_new;
  $heightbuf = $img_height_new;
  $sizebuf = sprintf("%.1f",$sizebuf/1024);
  $viewbuf = 0;

  open (albumfile, "+<galleries/$albumid.txt") || open(albumfile, ">galleries/$albumid.txt");
  flock(albumfile, 2);
  seek albumfile, 0, 0;
  my @album = <albumfile>;
  truncate albumfile, 0;
  seek albumfile, 0, 0;

  for(@album)
  {chomp $_}

  $album[@album] = "$imagebuf|$avtorbuf|$timebuf|$commentbuf|$visiblebuf|$tbwidthbuf|$tbheightbuf|$widthbuf|$heightbuf|$sizebuf|$viewbuf";

  @album  = join("\n", @album);

  print albumfile @album;
  close albumfile;

  if(param(photoagain) eq "on")
  {
    $photoagain = "<b>Фото $imagebuf успешно загруженно</b><br>";
    &add_form_photo;
    &htmlend;
    exit;
  }
  else
  {
    $redirectto = "$site?mode=gallery&album=$albumid&photo=$imagebuf";
    &html;
    exit;
  }
}

sub nosize{
  &html;
  print "<div align=center><b><font size=4>Файл слишком велик!</font></b><br>$sizebuf";
  &htmlend;
  exit;
}

sub noformat{
  &html;
  print "<div align=center><b><font size=4>Файл имеет некорректный формат!</font></b>";
  &htmlend;
  exit;
}

sub k82tr
    { ($_)=@_;

#
# Fonetic correct translit
#

s/Сх/Sh/; s/сх/sh/; s/СХ/SH/;
s/Ш/Sh/g; s/ш/sh/g;

s/Сцх/Sch/; s/сцх/sch/; s/СЦХ/SCH/;
s/Щ/Sch/g; s/щ/sch/g;

s/Цх/Ch/; s/цх/ch/; s/ЦХ/CH/;
s/Ч/Ch/g; s/ч/ch/g;

s/Йа/Ja/; s/йа/ja/; s/ЙА/JA/;
s/Я/Ja/g; s/я/ja/g;

s/Йо/Jo/; s/йо/jo/; s/ЙО/JO/;
s/Ё/Jo/g; s/ё/jo/g;

s/Йу/Ju/; s/йу/ju/; s/ЙУ/JU/;
s/Ю/Ju/g; s/ю/ju/g;

s/Э/E/g; s/э/e/g;
s/Е/E/g; s/е/e/g;

s/Зх/Zh/g; s/зх/zh/g; s/ЗХ/ZH/g;
s/Ж/Zh/g; s/ж/zh/g;

tr/
абвгдзийклмнопрстуфхцъыьАБВГДЗИЙКЛМHОПРСТУФХЦЪЫЬ/
abvgdzijklmnoprstufhc\"y\'ABVGDZIJKLMNOPRSTUFHC\"Y\'/;

tr/
\+\`\'\"\:\;\?\\\!\@\#\$\%\^\&\*\(\)\<\> /
_/;

return $_;

}

sub edit_photo{

  $albumid = param(album);
  $editphoto = param(editphoto);

  if(param(photodatetime) eq "1")
  {
    if(param(album_dd) ne "" & param(album_mm) ne "" & param(album_yyyy) ne "" & param(album_hh) ne "" & param(album_mm) ne "")
    {
      $i=0;
      foreach (@mdays)
      {
        $i++;
        if(param(album_mmm) eq $_)
        {
          $album_mmm = $i;
          $album_mmm = "0$album_mmm" if ($album_mmm<10);
          last;
        }
      }
      $album_dd = param(album_dd);
      $album_yyyy = param(album_yyyy);
      $album_hh = param(album_hh);
      $album_mm = param(album_mm);

      $datebuf = "$album_dd.$album_mmm.$album_yyyy";

      $timebuf = "$album_hh:$album_mm";

      $photodatebuf = &getwday($datebuf, 1). " $timebuf - $datebuf";
    }
    else
    {
      $photodatebuf = $nowtime;
    }
  }

  if(param(photodatetime) eq "3")
  {
    ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($albumid);
     $photodatebuf = $gallerydatebuf;
  }

  if(param(photodatetime) eq "2")
  {
    %ii=getexifjpeg( "photos/$editphoto" );
    $img_datetime = $ii{'DateTime'};

    if($img_datetime eq "")
    {
      $noexif = 1;
      $photoagain = "<font color=red><b>JPEG не содержит информации о дате</b></font><br>";
      &add_form_photo;
      &htmlend;
      exit;
    }
    else
    {
      ($album_yyyy, $album_mmm, $album_dd, $album_hh, $album_mm) = ($img_datetime =~ /(\d+)\:(\d+)\:(\d+) (\d+)\:(\d+)\:(\d+)/);

      $datebuf = "$album_dd.$album_mmm.$album_yyyy";

      $timebuf = "$album_hh:$album_mm";

      $photodatebuf = &getwday($datebuf, 1). " $timebuf - $datebuf";
    }
  }


  open (albumfile, "+<galleries/$albumid.txt");
  flock(albumfile, 2);
  seek albumfile, 0, 0;
  my @album = <albumfile>;
  truncate albumfile, 0;
  seek albumfile, 0, 0;

  for(@album)
  {chomp $_}

  $i = 0;
  LINE: for(@album)
  {
    ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1) = split(/\|/,$_);
    if($imagebuf1 eq param(editphoto))
    {
      $timebuf1 = $photodatebuf;
      $commentbuf1 = param(photocoment);
      $commentbuf1 =~ s~>~&gt;~ig;
      $commentbuf1 =~ s~<~&lt;~ig;
      $commentbuf1 =~ s~\|~&#124;~g;

      last LINE;
    }
    $i++;
  }

  if($avtorbuf1 ne $Userid & not(($usertype eq "модераторы")|($usertype eq "администраторы")))
  {
    @album  = join("\n", @album);
    print albumfile @album;
    close albumfile;

    &html;
    &netdostupa;
  }

  $album[$i] = "$imagebuf1|$avtorbuf1|$timebuf1|$commentbuf1|$visiblebuf1|$tbwidthbuf1|$tbheightbuf1|$widthbuf1|$heightbuf1|$sizebuf1|$viewbuf1";

  @album  = join("\n", @album);

  print albumfile @album;
  close albumfile;

  $redirectto = "$site?mode=gallery&album=$albumid&photo=$imagebuf";
  &html;
  exit;
}

sub photomove {
  $albumid = param(album);

  open (albumfile, "+<galleries/$albumid.txt");
  flock(albumfile, 2);
  @album = <albumfile>;
  seek (albumfile, 0, 0);
  truncate albumfile, 0;

  for(@album)
  {
    chomp $_;
  }

  $photoidbuf = 0;
  $i = 0;
  LINE: for(@album)
  {
     ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1) = split(/\|/,$_);
     if($imagebuf1 eq $photomove)
     {
       $photoidbuf = $i;
       last LINE;
     }
     $i++;
  }

  if(($photoidbuf > 0 & $offset eq -1)|($photoidbuf < @album & $offset eq 1))
  {
    ($album[$photoidbuf + $offset], $album[$photoidbuf]) = ($album[$photoidbuf], $album[$photoidbuf + $offset]);
  }

  @album  = join("\n", @album);

  seek (albumfile, 0, 0);
  print albumfile @album;
  close albumfile;

  $redirectto = $ENV{'HTTP_REFERER'};
  &html;
  exit;
}

sub photomove10 {
  $albumid = param(album);

  open (albumfile, "+<galleries/$albumid.txt");
  flock(albumfile, 2);
  @album = <albumfile>;
  seek (albumfile, 0, 0);
  truncate albumfile, 0;

  for(@album)
  {
    chomp $_;
  }

  $photoidbuf = 0;
  $i = 0;
  LINE: for(@album)
  {
     ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1) = split(/\|/,$_);
     if($imagebuf1 eq $photomove)
     {
       $photoidbuf = $i;
       last LINE;
     }
     $i++;
  }

  for($i=0;$i<10;$i++)
  {
    if(($photoidbuf > 0 & $offset eq -1)|($photoidbuf < @album & $offset eq 1))
    {
      ($album[$photoidbuf + $offset], $album[$photoidbuf]) = ($album[$photoidbuf], $album[$photoidbuf + $offset]);
    }
    $photoidbuf = $photoidbuf + $offset;
  }

  @album  = join("\n", @album);

  seek (albumfile, 0, 0);
  print albumfile @album;
  close albumfile;

  $redirectto = $ENV{'HTTP_REFERER'};
  &html;
  exit;
}

sub hidephoto {
  $hidephoto = param(hidephoto);
  $albumid = param(album);

  open (albumfile, "+<galleries/$albumid.txt");
  flock(albumfile, 2);
  @album = <albumfile>;
  seek (albumfile, 0, 0);
  truncate albumfile, 0;

  for(@album)
  {
    chomp $_;
  }

  LINE: for(@album)
  {
     ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1) = split(/\|/,$_);
     if($imagebuf1 eq $hidephoto)
     {
       if($visiblebuf1 eq 1)
       {
         $visiblebuf1 = 0;
       }
       else
       {
         $visiblebuf1 = 1;
       }
       $_  = join("|", ($imagebuf1, $avtorbuf1, $timebuf1, $commentbuf1, $visiblebuf1, $tbwidthbuf1, $tbheightbuf1, $widthbuf1,  $heightbuf1, $sizebuf1, $viewbuf1));
       last LINE;
     }
  }

  @album  = join("\n", @album);

  seek (albumfile, 0, 0);
  print albumfile @album;
  close albumfile;

  $redirectto = $ENV{'HTTP_REFERER'};
  &html;
  exit;
}


sub edit_form_album {

  $title="$title - Редактирование альбома";
  &html;

  $editalbum = param(editalbum);

  $dey1 = param(album_dd);
  $mday1 = "";
  $i=0;
  foreach (@mdays)
  {
    $i++;
    if(param(album_mmm) eq $_)
    {
      $mday1 = $i;
      $mday1 = "0$mday1" if ($mday1<10);
      last;
    }
  }
  $year1 = param(album_yyyy);
  $hour1 = param(album_hh);
  $min1 = param(album_mm);

  $albumname = param(albumname);
  $albumforum = param(albumforum);
  if(param(albumnewforum) eq "on")
  {
    $albumnewforum = " checked";
  }

  if(param(edit) ne 1)
  {
    ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = &get_gallery_info($editalbum);
    ($hour1, $min1, $dey1, $mday1, $year1) = ($gallerydatebuf =~ /.. (\d+)\:(\d+) - (\d+)\.(\d+)\.(\d+)/);
    $albumname = $gallerynamebuf;
    $albumforum = $galleryforumbuf;
  }

  print "<form action='$site?mode=gallery&editalbum=$editalbum' method=post>";
  print "<input name='mode' value='gallery' type='hidden'>";
  print "<input name='edit' value='1' type='hidden'>";
  print "<input name='editalbum' value='$editalbum' type='hidden'>";

  print "<table border=0 cellspacing=1 cellpadding=2 bgcolor=$tseriy width=100%>\n";

  print "<tr bgcolor=$beliy><td align=center colspan=2>\n";
  print "<table border=0 cellspacing=1 cellpadding=4 bgcolor=$tseriy width=100%>\n";
  print "<tr bgcolor=$seriy>\n";
  print "<td width=80%><font size=+1><b><a href=$site?mode=gallery>Галерея</a> :: ";
  print "<a href=$site?mode=gallery&editalbum=$editalbum>Редактирование альбома</a>";
  print "</table>\n";


  print "<tr bgcolor=$beliy>\n";
  print "<td>$redbufНазвание альбома:";
  print "<td width=80%><input type=text name=albumname size=66 value='$albumname'></td>";
  print "<tr bgcolor=$beliy>\n";
  print "<td>ID темы на форуме:";
  print "<td width=80%><input type=text name=albumforum size=16 value='$albumforum'> Укажите ID темы на форуме в которой будет идти обсуждение данного альбома";

  print "<tr bgcolor=$beliy>\n";
  print "<td>Дата и время события:";
  print "<td width=80%>";
  print "<select name=album_dd><option>";

  for($j=1;$j<=31;$j++)
  {
    $daybuf = $j;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($dey1 eq $daybuf)
    {print "<option selected>$daybuf"}
    else
    {print "<option>$daybuf"}
  }

  print "</select><select name=album_mmm><option>";

  for($j=0;$j<12;$j++)
  {
    $daybuf = $j+1;
    $daybuf = "0$daybuf" if ($daybuf < 10);
    if($mday1 eq $daybuf)
    {print "<option selected>$mdays[$j]";}
    else
    {print "<option>$mdays[$j]"}
  }

  print "</select><select name=album_yyyy><option>";

  for($j=1995;$j<=$year+1;$j++)
  {
    $yearbuf = $j;
    if($year1 eq $yearbuf)
    {print "<option selected>$yearbuf"}
    else
    {print "<option>$yearbuf"}
  }

  print "</select>&nbsp; &nbsp;<select name=album_hh><option>";

  for($j=0;$j<=23;$j++)
  {
    $hourbuf = $j;
    $hourbuf = "0$hourbuf" if ($hourbuf < 10);
    if($hour1 eq $hourbuf)
    {print "<option selected>$hourbuf"}
    else
    {print "<option>$hourbuf"}
  }

  print "</select>:<select name=album_mm><option>";
  for($j=0;$j<=59;$j++)
  {
    $minbuf = $j;
    $minbuf = "0$minbuf" if ($minbuf < 10);
    if($min1 eq $minbuf)
    {print "<option selected>$minbuf"}
    else
    {print "<option>$minbuf"}
  }
  print "</select>";

  print "<br> Для того, что бы установить текущую дату и время оставьте поле незаполненным</td>\n";

  print "<tr bgcolor=$beliy>\n";
  print "<td colspan=2 align=center><input type=submit name=action2 style=\"background-color: $tseriy;\" value=Добавить>";

  print "</table>\n";
  print "</form>"
}

sub edit_album {
  $editalbum = param(editalbum);
  if(param(albumname) eq "")
  {
    $redbuf = "<font color=red>";
    &edit_form_album;
    &htmlend;
    exit;
  }

  $gallerynamebuf1 = param(albumname);
  $gallerynamebuf1 =~ s~>~&gt;~ig;
  $gallerynamebuf1 =~ s~<~&lt;~ig;
  $gallerynamebuf1 =~ s~\|~&#124;~g;
  $galleryforumbuf1 = param(albumforum);
  $galleryforumbuf1 =~ /(\d+)/;

  if(param(album_dd) ne "" & param(album_mm) ne "" & param(album_yyyy) ne "" & param(album_hh) ne "" & param(album_mm) ne "")
  {
    $i=0;
    foreach (@mdays)
    {
      $i++;
      if(param(album_mmm) eq $_)
      {
        $album_mmm = $i;
        $album_mmm = "0$album_mmm" if ($album_mmm<10);
        last;
      }
    }
    $album_dd = param(album_dd);
    $album_yyyy = param(album_yyyy);
    $album_hh = param(album_hh);
    $album_mm = param(album_mm);

    $datebuf = "$album_dd.$album_mmm.$album_yyyy";

    $timebuf = "$album_hh:$album_mm";

    $gallerydatebuf1 = &getwday($datebuf, 1). " $timebuf - $datebuf";
  }
  else
  {
    $gallerydatebuf1 = $nowtime;
  }

  open (galleriesfile, "+<galleries/galleries.txt");
  flock(galleriesfile, 2);
  seek galleriesfile, 0, 0;
  my @galleries = <galleriesfile>;
  truncate galleriesfile, 0;
  seek galleriesfile, 0, 0;

  ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = split(/\|/, $galleries[$editalbum-1]);

  if($galleryavtorbuf ne $Userid & not(($usertype eq "модераторы")|($usertype eq "администраторы")))
  {
    print galleriesfile @galleries;
    close galleriesfile;

    &html;
    &netdostupa;
  }

  $gallerynamebuf = $gallerynamebuf1;
  $gallerydatebuf = $gallerydatebuf1;
  $galleryforumbuf = $galleryforumbuf1;

  $galleries[$editalbum-1] = "$gallerynamebuf|$gallerydatebuf|$galleryavtorbuf|$galleryvisiblebuf|$galleryimagebuf|$gallerytbwidthbuf|$gallerytbheightbuf|$galleryforumbuf\n";

  print galleriesfile @galleries;
  close galleriesfile;

  $redirectto = "$site?mode=gallery&album=$editalbum";
  &html;
  exit;
}

sub hidealbum {
  $hidealbum = param(hidealbum);

  open (galleriesfile, "+<galleries/galleries.txt");
  flock(galleriesfile, 2);
  @galleries = <galleriesfile>;
  seek (galleriesfile, 0, 0);
  truncate galleriesfile, 0;

  for(@galleries)
  {
    chomp $_;
  }

  ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf) = split(/\|/,$galleries[$hidealbum-1]);

  if($galleryvisiblebuf eq 1)
  {
    $galleryvisiblebuf = 0;
  }
  else
  {
    $galleryvisiblebuf = 1;
  }

  $galleries[$hidealbum-1] = join("|", ($gallerynamebuf, $gallerydatebuf, $galleryavtorbuf, $galleryvisiblebuf, $galleryimagebuf, $gallerytbwidthbuf, $gallerytbheightbuf, $galleryforumbuf));

  @galleries  = join("\n", @galleries);

  seek (galleriesfile, 0, 0);
  print galleriesfile @galleries;
  close galleriesfile;

  $redirectto = $ENV{'HTTP_REFERER'};
  &html;
  exit;
}

1;
